# DATA-023 — Sound, music and video inputs

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Resolve supported media and validated replacements for AV/UI playback while preserving explicit logical identity, source provenance and truthful failure. Keep resource access distinct from playback outcomes and gameplay authority.

## Intended player experience

Supported original and replacement sounds/music/video play through appropriate owners. Missing or unsupported input follows the requesting feature's policy rather than silently advancing gameplay. Independent playback instances do not share position/state. Optional startup video and approved death-video bypass remain intact.

## Confirmed requirements

DATA-023-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish stable media IDs/classic mappings; DATA/AV playback separation; explicit format support; absent-versus-invalid replacement handling with approved playback exceptions; owner-declared requiredness; and reusable source-aware resources with independent playback state and verification.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `SoundReader.cs#GetAudioClip` looks up/caches clips, tries replacement sound and otherwise reads classic `API/SndFile.cs` data. It converts classic unsigned samples using `(sample - 128) / 128`, creating mono clips at the reader's source sample rate. Index and record-ID lookup are distinct paths.
- `Internal/DaggerfallSongPlayer.cs` supports imported song clips or packaged/replacement MIDI and sound-font synthesis. It distinguishes loading/playback state and has sound-font/default-bank loading paths. Exact backend behavior and fallback coverage need fixtures.
- `Utility/AssetInjection/SoundReplacement.cs` exposes separate sound, recorded-song and MIDI imports; observed loose extensions include WAV, OGG and MIDI. These paths do not establish universal target codec support.
- `Utility/AssetInjection/VideoReplacement.cs#TryImportMovie` looks for loose movies or mod VideoClip assets; loose movie extension varies by Unity platform branch. Finding a file constructs a player drawer, not proof playback completes.
- `Game/UserInterface/DaggerfallVideo.cs` and `API/VidFile.cs` provide a separate classic VID path, including source frame orientation. Timing, synchronization and complete classic support require runtime verification.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Codec/platform, synthesis and playback fixtures were not tested. Source remains unchanged.

## Detailed rules and behaviors

### Identity and source selection

Use stable domain-scoped sound, music and video IDs with explicit classic ID/index/name mappings. Preserve distinctions between a classic archive record ID, list index and filename. Mods may add media without classic index limits or accidental basename collisions. Requests use logical media identity rather than transient decoder/player handles.

Apply DATA-003's declared operations, precedence, provenance and whole-contribution recovery to applicable sources. Absent replacement uses supported original media. Present but invalid selected replacement requires explicit recovery rather than silently choosing an earlier asset. Optionality alone does not permit hiding an invalid contribution during configuration resolution.

Approved playback-specific recovery takes precedence when that playback fails. In particular, CORE-008 missing/failed death-video playback bypasses directly to the menu without a replacement death notice; do not introduce a blocking replacement-repair prompt into that flow. DATA-001 keeps videos optional for startup. These exceptions do not approve every other missing-media behavior.

### Formats and decoding

Preserve supported classic content and timing metadata as the baseline, allowing validated replacements. Explicitly declare supported codecs, channels, sample rates, video/audio synchronization and MIDI sound-font requirements. Filename/extension match or file existence does not establish valid decoding or playable output.

DATA supplies supported decoded data or decoder inputs and descriptive metadata. AV/platform integration verifies actual decoding and playback capabilities. Exact format list, sample conversion, video orientation, color/audio interpretation and synthesis policy remain technical contracts; this specification does not require Unity's decoder extensions or select a Godot codec/backend.

Validate required media metadata/references before declaring usable input. Actual runtime decoder/read failures remain explicit; static validation cannot certify all future playback. Do not normalize unsupported input into a successful empty clip or invented replacement. An optional sound-font fallback requires a declared supported policy rather than automatic adoption of DFU's default-bank behavior.

### Playback authority and requiredness

AV/UI own playback, volume, looping, scheduling, skipping and completion. Finding/loading/decoding media is distinct from starting, completing, skipping or failing playback. DATA lookup does not advance quests, release gameplay gates or commit cinematics by itself.

Each requesting feature declares requiredness and failure behavior. Optional media may continue silently only where explicitly allowed. Missing audio must not erase an authoritative gameplay event or masquerade as completed playback. A supported bypass may permit a flow to proceed while still preserving truthful playback outcome; bypass is not successful media completion.

CORE-008 death presentation and DATA-001 optional startup video remain binding. Other cinematics, quest actions, combat cues and music need their own owner policies. No universal retry timeout, silence-success rule or mandatory-video set is invented here.

### Resource sharing and activation

Share reusable decoded media separately from per-playback position, loop and instance state. Multiple consumers may reuse immutable source resources without one playback seeking/stopping another. AV owns instance allocation, cancellation and lifecycle under CORE scope rules.

Cache identity includes resolved source and relevant decoding/sound-font inputs. Avoid returning synthesized results for a changed bank or old replacement winner. Pre-menu configuration changes invalidate affected candidate results under DATA-003; actual main-menu entry locks installed resources. External edits/classic-source changes retain restart rules. Runtime selection of already resolved music/media is distinct from installing new resources.

Streaming versus full loading, synthesis buffering, cache eviction and memory budgets remain measured AV choices. Source availability can differ under streaming/cached access; actual failure must remain truthful rather than implying a full immutable snapshot. Resource readiness does not certify playback readiness or session readiness.

### Verification

Verify representative classic and replacement sound, recorded music, MIDI and video for timing, channels, synchronization, failures and independent instances. Include source mapping, malformed/missing resources and relevant cache/sound-font combinations. Use production decoder/playback paths where appropriate; static file inspection alone cannot establish support.

## Relevant formulas and parameters

DFU's classic sample conversion above is source behavior to verify, not a universal audio formula. No codec roster, sample rate, frame rate, loudness normalization, buffer size, sound-font choice, timeout or memory budget is approved. Supported metadata/decoder contracts and owner playback policies determine these values later.

## Required data

Stable logical media IDs and classic mappings; source/package provenance; format/codec metadata; audio channels/sample rate/duration; video frame/timing/audio metadata; MIDI/sound-font inputs as required; cache/decoder context; differentiated access/validation outcomes. Playback positions/loops and completion state remain AV/UI/requesting-owner data. Exact schemas and optionality remain dependencies.

## Inputs, outputs and events

Inputs: logical/legacy media query, active resolved sources, decoding/synthesis options and required provider metadata. Outputs: validated decoder inputs/decoded resources or explicit missing/unavailable/invalid/unsupported failure with context. These are conceptual contracts, not APIs/signals. Requested/found/decoded/playing/completed/skipped/bypassed/failed outcomes must not collapse into a misleading single success.

## Cross-system interactions

- DATA-001/002 retain source/readiness/failure rules; DATA-003 owns applicable contributions and configuration lock. Videos are optional for startup.
- AV/UI own playback and presentation; MOD owns executable/provider lifecycle. Platform support must be verified rather than inferred from Unity behavior.
- CORE-005/007 manage scope and operation outcomes. CORE-008's death-video silent bypass remains a specific overriding playback rule. CORE-012 ordered opening flow does not equate decoder readiness with presentation completion.
- QUEST/COMBAT/NPC and other consumers own gameplay effects and media requiredness. Missing cues do not undo committed gameplay; unsuccessful playback does not automatically satisfy quest actions.
- SAVE/owners decide supported active media/sequence restoration independently of resource handles. CORE-002 owns optional diagnostic logging/privacy.

## Edge cases and failure conditions

- No replacement: use original supported source. Invalid selected replacement: explicit recovery except an approved specific playback bypass.
- Classic ID and index differ: explicit mappings prevent playing another clip by numeric coincidence.
- Matching extension but unsupported/malformed content: explicit failure, not playable-ready status.
- MIDI input resolves but required bank/provider fails: use only declared fallback or truthful failure; no implicit synthesis support guarantee.
- Video exists/decoder initializes but playback fails: preserve failed outcome and requesting-owner recovery. CORE-008 bypass does not become a new death notice.
- Two playback instances share data: positions/loop/stop state remain independent.
- Pre-menu source or synthesis inputs change: invalidate affected cache results. Streamed source later disappears: report actual read/playback failure.

## Configuration and balancing options

Validated media additions/replacements follow declared schemas. AV/CORE own volume, music choices and supported presentation preferences; this feature does not approve new disable/skip settings or loudness rules. Optionality and bypass are feature contracts, not a generic failure-ignore switch. No gameplay balance changes are introduced.

## Save/load considerations

Use stable media references where owners persist a sequence, not decoder/audio/GPU handles or cache slots. SAVE/AV/requesting owners define whether an active sequence resumes, restarts, skips or cannot be saved; no universal rule is selected here. Loading resources must not replay gameplay events or claim a prior presentation completed. Content lock and compatibility checks remain binding.

## Technical constraints

Target engine: Godot 4.7.2. Separate source resolution/decoding, reusable resources, playback instances and gameplay authority. Keep source inputs read-only and outcomes truthful. Concrete decoder/synth APIs, formats, buffering, resource lifecycle and caches remain choices to verify; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Stable domain IDs/classic mappings resolve supported originals/additions without filename collisions or index confusion.
2. Explicit format requirements are verified; extension/existence alone never proves playability.
3. DATA resolution/decoding does not imply playback completion or gameplay progression; AV/UI retain playback authority.
4. Absent replacements use original sources; present invalid selections use explicit recovery, preserving approved playback-specific exceptions.
5. Owner requiredness governs failure. DATA-001 optional videos and CORE-008 death-video bypass remain intact; no false completion or erased gameplay events.
6. Shared resources preserve independent playback state; cache identity includes source/decoder/sound-font inputs and candidate invalidation.
7. Streaming/full-loading choices preserve truthful failures and content locks without imposing fixed budgets or undocumented snapshots.
8. Representative classic/replacement sound/MIDI/video fixtures verify mappings, timing, channels, synchronization, failures and independent instances before implementation is complete.

These are future verification criteria. No implementation, decoder fixtures or runtime/playback tests were performed during specification.

## Consistency review

Reviewed against DATA-001–022 and approved CORE lifecycle/presentation/load contracts. No contradiction identified. Specific CORE-008 bypass overrides generic invalid-replacement playback recovery without approving silent configuration rejection everywhere. Resource sharing complements DATA-021/022 while instance playback remains independent. Decoder readiness remains distinct from CORE ordered-presentation and gameplay completion.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: stable media/legacy schemas; source/codec/platform support inventory; timing/audio/video conversion and synthesis/sound-font policy; per-consumer requiredness/completion/recovery; AV resource/stream/cache budgets and lifecycle; SAVE sequence behavior and representative fixtures. These deferrals do not waive truthful media outcomes, independent instances or approved video bypass.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-023-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including AV/platform formats, synthesis, playback policies and save contracts. Approved optional-video and death-video bypass rules remain binding. Approval does not initiate implementation, coding tasks or another feature review.
