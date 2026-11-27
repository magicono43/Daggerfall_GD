# Native playback — IMP-008 increment 3

IMP-015 increment 4 adds an optional creation sequence through this same consumer,
using ordered logical targets `creation.intro.0..2`. The baseline supplies bounded
classic VID source receipts; replacements use the existing native profiles.
The requester retains its exact CORE preflight ticket and advances only scoped
terminal results after cleanup. Disabled/missing/failed clips cannot certify
playable readiness. Creation's video preference is distinct from startup/death.
The consumer's release-only `input_released` signal lets the shell observe a
physical release that cinematic input consumed. It clears UI/gameplay quarantine
without activating covered controls; held-input fences persist across clips.
See [creation identity/presentation](../char/CREATION_IDENTITY.md) for the boundary.

IMP-012 increment 4 adds the narrow `movement_audio.gd` listener-relative bridge:
validated classic PCM is prepared at binding, four engine voices consume scoped
committed cues, and pause/live gain/retirement remain independent of gameplay.
Missing optional clips are diagnosed silence. This does not deliver broad local
spatial/ambient audio or NPC hearing. See
[PLATFORMS_FEEDBACK.md](../move/PLATFORMS_FEEDBACK.md).

`music_playback.gd` and `video_playback.gd` are bounded realization consumers.
They resolve committed DATA targets, retain original provider/source provenance
and operate on checked bytes. They do not select playlists, world music, dialogue,
quest continuations or SAVE state. Native code does not resolve mod paths.

## Music

`request(target, type, scope, loop)` accepts `audio` or `midi`; `admit` also accepts
the checked classic sequence result. Scope contains original attempt, session and
operation identities. CORE retirement releases playback for that session. Callers
own selection and continuation; IDs reject stale callbacks after retirement.

Every request captures its bank and owns its player, sample cursor and gain.
Incoming preparation succeeds before `handoff(id, seconds)` begins a fade.
Retargeting captures current gains. `gain` changes the active mixer value.
`set_music_gain` applies a live scalar independently of the fade envelope;
`pause(id, value)` suspends that instance. A paused incoming track freezes the
handoff envelope until resumed. The retarget fixture checks the retained gain,
paused sample cursor and actual engine volume after a live gain change.
One-shot MIDI and whole-score loops are supported; partial loop ranges are not.
MIDI is SMF type 0/1, positive PPQ, with checked track lengths, running status,
tempo changes, rational 48 kHz positions and source byte offsets. Type 2, SMPTE
and non-reset SysEx reject explicitly. Known GM/GS reset messages are accepted.
GS bank/program requests must exist in the captured bank; no silent substitution.

The application setting `media/midi_bank` captures an exact DATA provider/export
reference for the *next* request. Missing optional references report an issue and
use the bundled default. Present wrong-type/invalid selected banks do not fall
through. Existing playback retains its bank. The shipped bank is pinned GeneralUser
GS 2.0.3; its license and author's sample-origin caveat remain beside the asset.

Terminals are emitted after native disposal and the engine playback WeakRef has
expired. `shutdown` waits for mixer retirement. Whole-score loop boundary events
carry the original scope and monotonically increasing boundary number.
MIDI requests a 250 ms generator buffer and records the actual engine frame
capacity separately; an explicit silence tail advances
the final source sample through device latency before natural retirement.

## Video

Modern supported containers/codecs are WebM VP8/VP9 with optional Vorbis/Opus,
and MP4 H.264 with optional AAC. One video stream and at most one audio stream;
finite duration, even progressive 8-bit YUV420 dimensions up to 4096×2160,
mono/stereo audio 8–192 kHz. BT.601/709 limited/full conversion is explicit;
unspecified metadata uses the documented SDR fallback. HDR/10-bit, interlaced,
other codecs/containers and unsupported declared transfer functions reject.
Midstream dimension/pixel-format and audio-format/rate/channel changes reject.
Dynamic color-metadata transitions are outside the verified profile matrix.
The verified fixtures cover 192×144 and 1280×720, including authored SAR
3:4, full-range BT.709 and AAC at 44.1 kHz. The dimension ceiling is an admission
bound, not a claim that every 4K device/profile has been qualified.

Full DATA admission decodes on a native worker without retaining a decoded movie.
Playback creates a separate worker with queues capped at 16 pictures and 16 audio
packets. Cancel wakes a blocked producer and joins it before disposal. The main
thread converts byte buffers to engine objects. A frame displays once, selecting
the latest eligible source PTS; missed frames are counted rather than stretching
audio. Authored sample aspect controls fitting. Audio is normalized to 48 kHz
stereo float; packet PTS inserts silence for gaps and trims overlap/codec priming.
The audio presentation clock uses submitted/queued frames and engine output
latency; video-only clips use monotonic elapsed microseconds, independently of
the world clock. Modern audio stays paused until its actual generator capacity
is primed; classic audio starts after its first checked PCM block is submitted.
First-buffer preparation and a clock that makes no progress are each bounded
to 5000 ms, after which the attempt fails, cancels/joins its worker and releases
its scopes. This is a consumer progress limit, not an automatic content fallback.
The final silence tail drains device latency while the source duration remains
unchanged. Diagnostic presentation traces reset per attempt and retain at most
1024 markers, so instrumentation does not become an unbounded movie cache.

Classic VID uses the checked active classic source, one GDScript worker and a
16-frame queue. Its 11025 Hz unsigned mono samples feed a generator at that exact
rate, duplicated to stereo without block-rounding drift. Raw source delays and
source sample positions remain intact; there is no 740-sample timing patch.
The bounded classic fixture supplies 320:200 (1.6) square-pixel aspect, matching
DFU's normal uniform ScaleToFit path. Future retro scaling policy stays with its
caller; this adapter does not impose an unverified 4:3 correction.

## Scoped input and cleanup

A cinematic acquires its own UI layer, HUD gate, cursor policy and ambience
attenuation lease. It releases only those leases and its original layer, retaining
newer independent owners. Fresh key/mouse/digital-controller presses can skip;
held input, key echo and analogue motion cannot. Authored any/skip/back/none policy
and the application preference apply to ordinary cinematics. Startup and death
always accept any fresh press. Callers supply a current-attempt predicate; stale
session/operation/window ownership cancels safely.

An admitted attempt emits exactly one Finished/Skipped/Cancelled/Failed terminal
after worker join, queue/texture disposal, mixer retirement and scoped cleanup.
Native failures are attributed to the original attempt. Preparation failure never
becomes success, and retry creates fresh decoder state. Application quit follows
the same media cleanup path, including preference-save and CORE cleanup failures.

The native build/API/dependency contract is in
`res://native/media/README.md`; versioned verification IDs are in
`res://tests/native_inventory.json` and `native_fault_inventory.json`.
Real IMP-024/035 requesters, full music selection/environment layers and SAVE
integration remain named future checks; these bounded consumers do not close them.
