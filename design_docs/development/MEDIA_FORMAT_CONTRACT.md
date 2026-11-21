# Media format and verification contract

Reviewed 2026-11-18 for IMP-008. Direct PNG textures and WAV audio with optional authoring tools are user-approved. Windows is the first verification target. This inventory specifies acceptance targets. Exported Godot 4.7.2 verification is pending.

IMP-008 increment 1 implementation now has a concrete, bounded
[classic source/decoded-data/AV inspection contract](../../main_project/scripts/data/MEDIA_DECODERS.md).
Its execution evidence records actual Windows structural/inspection checks and
unsupported subformats separately from the parent feature and native acceptance.
Replacement/cache and FluidSynth/FFmpeg integrations are not delivered by classic
decoding. The selected playback backends below remain binding; the historical
table's earlier open-backend wording does not reopen their selection.

## Replacement profiles

| Asset | Initial profile | Required checks |
| --- | --- | --- |
| Static model | glTF 2.0 GLB, triangle meshes, normals, UVs and supported base-color PNG materials | Validate dependencies, transforms, winding, normals and UVs. Preserve gameplay-owned collision, markers and interaction. Unsupported required extensions fail explicitly. |
| Texture/image | PNG, 8-bit RGB/RGBA and indexed PNG with decoded palette/transparency | Verify dimensions, corner orientation, exact colors and alpha. Material roles and animation frame order are explicit metadata. |
| Sound/recorded music | RIFF WAV, uncompressed PCM unsigned 8-bit or signed little-endian 16-bit, mono/stereo, positive declared sample rate | Validate chunk bounds, alignment and frame count. Preserve rate/channel metadata. Exercise 22050, 44100 and 48000 Hz fixtures. Reject unsupported encodings with an attributable result. |
| Recorded music | Ogg Vorbis | Decode metadata and verify start/end and independent playback. Confirm codec identity rather than relying on extension. |
| MIDI | Standard MIDI file type 0/1 and SF2 bank input under AV-012 | Verify tempo change, simultaneous instances, bank selection and recording independence from synthesis readiness. Backend selection remains open. |
| Video | WebM VP8/VP9 with Vorbis/Opus, and MP4 H.264 with AAC under AV-013 | Verify each supported combination in a Windows export, including video-only, aspect, synchronized playback and classified terminal results. Backend selection remains open. |

These baseline profiles do not advertise support for every optional feature of their containers. Additional profiles require a declared adapter with fixtures. Use controlled valid files outside the supported encoding profiles to verify unsupported-format results.

Godot documents runtime PNG, WAV and Ogg Vorbis loading and exported glTF loading. Those capabilities justify the adapter choices above. Published documentation establishes available integration paths; the required target build still needs exported acceptance evidence. [Runtime loading documentation](https://docs.godotengine.org/en/stable/tutorials/io/runtime_file_loading_and_saving.html)

## Classic inputs and boundaries

Preserve DATA-021/022/023 and the source adapters for ARCH3D, texture archives and supported IMG/CIF/RCI imagery, classic sounds, soundtrack conversion and VID. Use the DFU API readers as structural references and user-supplied ARENA2 as read-only fixture input. For each enabled source family, record one selected file/record and expected decoded geometry, pixel, sample or timing values before its adapter acceptance. The fixture manifest names actual verified records and required sources; directory presence alone establishes no decoding result.

Adapter output includes stable identity and provenance plus typed immutable geometry, images, samples or media metadata. AV owns playback state and renderer instances. Owners declare requiredness and compatible optional fallback. Present invalid replacements use explicit configuration recovery. The death-video bypass and optional startup-video scope remain governed by CORE-008 and UI-008.

## Selected playback backends

Godot's core video support is Ogg Theora. The approved AV-013 launch targets require an additional decoder path for WebM and MP4. Selecting Theora alone would leave approved coverage incomplete. [Godot video documentation](https://docs.godotengine.org/en/latest/tutorials/animation/playing_videos.html)

Select FluidSynth for Standard MIDI file sequencing and SF2 synthesis. Use sample-clock sequencing and render audio into the game's audio path. Each admitted MIDI playback owns its synthesizer/player state, gain, captured bank and cancellation scope. Recordings remain independently playable if MIDI initialization fails. A bank switch affects the next admitted request. Serialize access to each synthesizer and coordinate shutdown before freeing its resources. [MIDI player](https://www.fluidsynth.org/api/MIDIPlayer.html), [sample timing](https://www.fluidsynth.org/api/settings_player.html), [application-managed audio](https://www.fluidsynth.org/api/CreatingAudioDriver.html)

Select FFmpeg libraries for local WebM and MP4 demuxing and software decoding. The adapter uses libavformat, libavcodec, libavutil, libswscale and libswresample. Expose the declared profiles rather than every format available in a library build. Use bounded packet/frame queues. Decode away from the main thread and publish engine resources on their supported thread. Each playback owns decoder state and its scoped completion. Synchronize frames to presented audio when present and an independent presentation clock for video-only clips. Cancel outstanding decode work and join it before releasing its owner. [Decoder interface](https://ffmpeg.org/doxygen/trunk/group__lavc__decoding.html)

Integrate through project-owned GDExtension adapters with platform libraries behind the media interface. Windows is the first export target. Pin exact library revisions and build options when creating the dependency build and include those identities in test reports. Existing plugins can inform implementation; no third-party Godot wrapper's compatibility is assumed. [Godot native extension interface](https://docs.godotengine.org/en/stable/engine_details/engine_api/gdextension/what_is_gdextension.html)

## Alternatives and distribution

Godot's core Theora decoder does not cover the approved WebM/MP4 targets. A WebM-only extension also leaves MP4 uncovered. FFmpeg supplies one adapter boundary for those containers. A platform-specific multimedia player would require different capability checks on future platforms. FluidSynth supplies documented MIDI sequencing and SF2 input with application-managed audio, matching AV-012's independent backend and sample-clock needs.

Use dynamically linked builds with recorded licenses and dependency configuration. FFmpeg's license depends on enabled components. Select a build without GPL or nonfree components for this integration and verify the resulting notices, corresponding sources and distribution requirements against the actual build. Preserve FluidSynth's license and dependency notices as well. SoundFont redistribution is a separate asset permission check. [FFmpeg build licensing guidance](https://www.ffmpeg.org/legal.html), [FluidSynth license](https://github.com/FluidSynth/fluidsynth/blob/master/LICENSE)

The default SF2 bank is an implementation asset selection under AV-012. Its manifest must name the actual bank, provenance and redistribution terms and its tests must exercise it before stock MIDI readiness passes. A small project-authored bank may serve as an isolated synthesis fixture. Required bank failure returns classified MIDI failure and preserves the recording path.

## Backend acceptance

- In a Windows Godot 4.7.2 export, initialize both adapters from the shipped dependency set and report actual versions. Test a missing library and an unsupported codec profile with attributable failure.
- Use MIDI type 0 and type 1 fixtures with a known note sequence, tempo change and finite end. Compare note/event order and sample-clock positions to the fixture's declared schedule. Run two overlapping tracks and cancel one without changing the other. Verify invalid SF2, missing optional selected bank and failed default-bank behavior under AV-012.
- Exercise WebM VP8/VP9 paired with Vorbis/Opus and MP4 H.264/AAC, plus video-only. Use 10-second clips with visible timestamp and audio clicks every second. At 30 fps, require each corresponding visible mark to be within two frame periods of its audio marker in the controlled capture. Record underruns and timing evidence. Inspect aspect-preserving output and actual decoded color/range handling.
- Verify natural finish, fresh-input skip, cancellation during preparation and decode failure each publish one classified outcome. Repeat completion callbacks and retire a playback during preparation to verify stale results cannot advance the requester.
- Validate adapter teardown during crossfade and session replacement, queue draining at end-of-stream and responsive cancellation. IMP-035 closes live music/cinematic integration. IMP-024 closes room audio and rendered resource use.

## Required fixture matrix

Run successful structural decoding and rejected/truncated-input cases for every profile. Test a known-orientation textured triangle, PNG alpha and palette, WAV sample extrema, stereo channel separation, MIDI tempo change, video aspect and independent playback instances. Assert source attribution, invalid-selected versus absent behavior, candidate cache invalidation and independent mutable material resources. Separate headless adapter assertions from rendered/audio playback checks under IMP-003.
