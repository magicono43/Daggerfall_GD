extends RefCounted
## HMI event interpretation and deterministic SMF conversion, never synthesis.
const Cursor = preload("res://scripts/data/media_cursor.gd")
const Value = preload("res://scripts/data/decoded_media.gd")
const VERSION = "classic-hmi-v1"
const PROFILE = "jukebox-192-v1"
const DIVISION = 192
const TEMPO = 1605631 # 0x187fff: Daggerfall Jukebox's declared SMF conversion.

func _failure(raw: Dictionary, reason: String, position: int) -> Dictionary:
	return {"ok":false,"kind":"malformed_or_unsupported","reason":reason,"position":position,"source":raw.get("source"),"record":raw.get("record"),"classic_id":raw.get("identity"),"provider":"classic","converter":VERSION}

func _vlq(cursor: RefCounted) -> int:
	var value := 0
	for unused in 4:
		var byte: int = cursor.u8()
		value = (value << 7) | (byte & 127)
		if byte < 128: return value
	cursor.reason = "VLQ exceeds the supported 28-bit extent."
	return 0

func _write_vlq(value: int) -> PackedByteArray:
	var result := PackedByteArray([value & 127])
	value >>= 7
	while value > 0:
		result.insert(0,(value & 127) | 128)
		value >>= 7
	return result

func _be(value: int, length: int) -> PackedByteArray:
	var result := PackedByteArray()
	for index in length: result.append((value >> ((length - index - 1) * 8)) & 255)
	return result

func _track(events: Array, end_tick := -1) -> PackedByteArray:
	var payload := PackedByteArray()
	var previous := 0
	for event: Dictionary in events:
		payload.append_array(_write_vlq(event.tick - previous))
		payload.append_array(event.midi)
		previous = event.tick
	payload.append_array(_write_vlq(maxi(previous,end_tick) - previous))
	payload.append_array(PackedByteArray([255,47,0]))
	var result := "MTrk".to_ascii_buffer()
	result.append_array(_be(payload.size(),4))
	result.append_array(payload)
	return result

func decode(raw: Dictionary) -> Dictionary:
	if not raw.get("ok",false):
		var rejected := raw.duplicate(true)
		rejected.converter = VERSION
		rejected.provider = "classic"
		return rejected
	if not raw.get("identity") is String: return _failure(raw,"MIDI.BSA domain decoding requires a named classic ID.",0)
	var bytes: PackedByteArray = raw.bytes
	var cursor := Cursor.new(bytes)
	if not cursor.has(370) or cursor.take(18).get_string_from_ascii() != "HMI-MIDISONG061595": return _failure(raw,"Unsupported/truncated HMI signature/header.",0)
	cursor.seek(0xd2)
	var division_source := cursor.u16()
	var duration_source := cursor.u32()
	cursor.seek(0xe4)
	var count := cursor.u32()
	if count == 0 or count > (bytes.size() - 370) / 4 or count > 65534: return _failure(raw,"Invalid HMI track count.",0xe4)
	cursor.seek(370)
	var starts: Array[int] = []
	for index in count:
		var offset := cursor.u32()
		if offset < 370 + count * 4 or offset >= bytes.size() or (index > 0 and offset <= starts[index - 1]): return _failure(raw,"Invalid/overlapping HMI track offsets.",cursor.position - 4)
		starts.append(offset)
	var tracks: Array = []
	var all_events: Array = []
	var end_tick := 0
	var midi := "MThd".to_ascii_buffer()
	midi.append_array(_be(6,4))
	midi.append_array(_be(1,2))
	midi.append_array(_be(count + 1,2))
	midi.append_array(_be(DIVISION,2))
	midi.append_array(_track([{"tick":0,"midi":PackedByteArray([255,81,3,24,127,255])}]))
	for track in count:
		var start := starts[track]
		var end: int = starts[track + 1] if track + 1 < count else bytes.size()
		cursor = Cursor.new(bytes,start,end)
		if cursor.take(13).get_string_from_ascii() != "HMI-MIDITRACK": return _failure(raw,"Invalid HMI track signature.",start)
		cursor.seek(start + 0x57)
		var header := cursor.u32()
		if header < 0x5b or header >= end - start: return _failure(raw,"Invalid HMI track header length.",start + 0x57)
		cursor.seek(start + header)
		var tick := 0
		var running := 0
		var events: Array = []
		var markers: Array = []
		var terminated := false
		var serial := 0
		while cursor.position < end and cursor.reason.is_empty():
			tick += _vlq(cursor)
			if tick > 0x0fffffff: return _failure(raw,"Track time exceeds supported SMF tick extent.",cursor.position)
			var at := cursor.position
			if not cursor.has(1): break
			var status := cursor.u8()
			if status < 128:
				cursor.position -= 1
				status = running
			elif status < 240: running = status
			var data := PackedByteArray([status])
			if status == 255:
				var type := cursor.u8()
				var length := _vlq(cursor)
				var contents := cursor.take(length)
				if type == 47:
					if length != 0: return _failure(raw,"Invalid HMI end-track event.",at)
					terminated = true
					break
				if type == 81 and length != 3: return _failure(raw,"Invalid HMI tempo event.",at)
				data.append(type)
				data.append_array(_write_vlq(length))
				data.append_array(contents)
			elif status == 254:
				var type := cursor.u8()
				var length := 0
				if type == 16:
					if not cursor.has(3): break
					length = int(bytes[at + 4]) + 9
				elif type == 20: length = 4
				elif type == 21: length = 8
				else: return _failure(raw,"Unsupported HMI proprietary event.",at)
				cursor.seek(at)
				var contents := cursor.take(length)
				markers.append({"tick":tick,"type":type,"position":at,"bytes":contents})
				# Preserve markers in SMF as sequencer-specific metadata, never execute loops.
				data = PackedByteArray([255,127])
				data.append_array(_write_vlq(contents.size()))
				data.append_array(contents)
			elif status >= 128 and status < 240:
				var length := 1 if (status & 240) in [192,208] else 2
				var contents := cursor.take(length)
				for byte in contents:
					if byte >= 128: return _failure(raw,"MIDI channel data exceeds seven bits.",at)
				data.append_array(contents)
				if (status & 240) == 144:
					var duration := _vlq(cursor)
					if not cursor.reason.is_empty(): break
					if duration + tick > 0x0fffffff: return _failure(raw,"Note release exceeds supported tick extent.",at)
					events.append({"tick":tick + duration,"order":serial + 1,"position":at,"generated_release":true,"midi":PackedByteArray([status,contents[0],0])})
			else: return _failure(raw,"Unsupported HMI system event or missing running status.",at)
			if not cursor.reason.is_empty(): break
			events.append({"tick":tick,"order":serial,"position":at,"generated_release":false,"midi":data})
			serial += 2
		if not cursor.reason.is_empty() or not terminated: return _failure(raw,"Incomplete HMI track: " + cursor.reason,cursor.position)
		events.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.tick < b.tick or (a.tick == b.tick and a.order < b.order))
		var last: int = maxi(tick,events.back().tick if not events.is_empty() else 0)
		end_tick = maxi(end_tick,last)
		# Encode the terminal delta directly; do not invent a sequencer event
		# merely to preserve source end time after the last note or tempo.
		midi.append_array(_track(events,last))
		tracks.append({"track":track,"position":start,"data_position":start + header,"source_end_tick":tick,"end_tick":last,"events":events,"markers":markers})
		for event: Dictionary in events:
			var copied := event.duplicate(true)
			copied.track = track
			all_events.append(copied)
	all_events.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.tick < b.tick or (a.tick == b.tick and (a.track < b.track or (a.track == b.track and a.order < b.order))))
	var tempo := TEMPO
	var previous_tick := 0
	var elapsed_numerator := 0
	for event: Dictionary in all_events:
		elapsed_numerator += (int(event.tick) - previous_tick) * tempo
		previous_tick = event.tick
		event.time_us_numerator = elapsed_numerator
		event.time_us_denominator = DIVISION
		var data: PackedByteArray = event.midi
		if data.size() == 6 and data[0] == 255 and data[1] == 81 and data[2] == 3:
			tempo = (int(data[3]) << 16) | (int(data[4]) << 8) | int(data[5])
			if tempo == 0: return _failure(raw,"Zero MIDI tempo is invalid.",event.position)
	elapsed_numerator += (end_tick - previous_tick) * tempo
	return {"ok":true,"kind":"ready","value":Value.new({"schema":Value.SCHEMA,"domain":"sequence",
		"identity":{"origin":"classic","domain":"sequence","local_id":"MIDI.BSA/%s/record/%d" % [str(raw.identity),int(raw.get("ordinal",-1))]},
		"provenance":{"source":raw.source,"record":raw.record,"classic_id":raw.identity,"ordinal":raw.get("ordinal",-1),"offset":raw.offset,"provider":"classic","converter":VERSION},
		"conversion_profile":PROFILE,"header_d2_u16":division_source,"header_d4_u32":duration_source,
		"ticks_per_quarter":DIVISION,"initial_tempo_us":TEMPO,"tracks":tracks,"events":all_events,"end_tick":end_tick,
		"duration_us_numerator":elapsed_numerator,"duration_us_denominator":DIVISION,"smf":midi,"synthesis_ready":false})}
