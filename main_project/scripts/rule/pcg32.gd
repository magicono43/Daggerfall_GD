extends "res://scripts/rule/random_source.gd"
# PCG Random Number Generation for C: Copyright 2014 Melissa O'Neill <oneill@pcg-random.org>.
# Licensed under Apache License 2.0; see PCG_LICENSE.txt.
# Changed 2026-11-20: GDScript adaptation, explicit limb arithmetic, checked local API.
# Derived from the C reference, itself derived from canonical C++ PCG.
# https://www.pcg-random.org / https://github.com/imneme/pcg-c-basic/blob/master/pcg_basic.c
const U = preload("res://scripts/rule/unsigned64.gd")
const VERSION := "pcg32-xsh-rr-v1"
var _initialized := false
var _state := [0, 0, 0, 0]
var _increment := [0, 0, 0, 0]

static func create(initstate: Array, initseq: Array) -> RefCounted:
	if initstate.size() != 4 or initseq.size() != 4:
		return null
	for limb in initstate + initseq:
		if typeof(limb) != TYPE_INT or limb < 0 or limb > 65535:
			return null
	var source = load("res://scripts/rule/pcg32.gd").new()
	source._initialized = true
	source._increment = U.add(U.multiply(initseq, [2, 0, 0, 0]), [1, 0, 0, 0])
	source.raw()
	source._state = U.add(source._state, initstate)
	source.raw()
	source.raw_count = 0
	return source

func raw() -> Dictionary:
	if not _initialized:
		return {"ok": false, "error": "uninitialized_source"}
	var old := _state
	_state = U.add(U.multiply(old, [32557, 19605, 62509, 22609]), _increment)
	var shifted := U.shift(old, 18)
	for i in 4:
		shifted[i] ^= old[i]
	shifted = U.shift(shifted, 27)
	var x: int = shifted[0] | (shifted[1] << 16)
	var rotation: int = old[3] >> 11
	var value := ((x >> rotation) | (x << ((-rotation) & 31))) & 0xffffffff
	raw_count += 1
	return {"ok": true, "value": value}


func bounded(bound: Variant) -> Dictionary:
	return preload("res://scripts/rule/random_mapping.gd").bounded(self, bound)

