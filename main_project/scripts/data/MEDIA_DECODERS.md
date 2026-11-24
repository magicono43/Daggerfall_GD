# Classic media — IMP-008 increment 1

The separately delivered [increment-2 media replacement contract](MEDIA_REPLACEMENTS.md)
adds logical/package export selection and engine resources without broadening
this accepted classic inventory, source-space units or HMI/VID timing policy.

Versioned DATA values: `decoded-media-v1`. Source decoders are application GDScript,
not native playback adapters. No library, compiler, backend, default sound bank,
cache budget, package resolver or gameplay/world conversion is added.

## Entry points and lifetime

`StartupProviderBoundary.enable_classic_media(required_sources)` declares only an
enabled consumer's exact filenames/formats before preparation. Loose formats use
`classic_media_source.gd`; BSA remains `bsa-v1`. Unknown/conflicting formats fail
closed. Normal startup retains its four foundation containers plus TEXT.RSC;
it does not enable a universal media/video manifest. Optional startup-video absence
remains silent and CORE's specific death-video bypass is unchanged.

Use published `classic.read_record(file,{record:int,frame:int})` for loose media,
`decode_model(classic_id_or_physical_ordinal)`, `decode_sound(...)` and
`decode_sequence(exact_HMI_name_or_physical_ordinal)` for BSA domains. Sequence
consumers must first declare MIDI.BSA/bsa-v1. Numeric IDs are never interpreted as
ordinals. BSA returns the actual physical ordinal even for an ID query; ambiguous
IDs still reject. No alias search or neighboring-record substitution exists.

Readers validate real record/frame-zero decoding during preparation, discard that
temporary decoded value, and retain only source metadata. On demand they reopen
READ and reconstruct one requested result. VID requests replay bounded source
blocks to the requested frame, retaining one frame, not a whole decoded movie.
This is not streaming/native playback or an integrity scan of every frame/record.
Transient source-byte buffers are not an application preload/cache. There is no
same-length-edit snapshot guarantee; supported external changes require restart.

Existing validation/unpublished initialization/original ticket/assignment-only
activation, aggregate failure cleanup, application lifetime, source restart rules
and CORE/MOD/DATA menu commitment remain in force. This increment adds no package
contribution schema and does not rebuild/unlock a committed content plan.

`decoded_media.gd` retains copied values and exposes detached `projection()` and
`identity()` copies. Schema/domain distinguish model, image, palette, audio,
sequence and video_frame. Source path, provider `classic`, classic ID, actual
ordinal where applicable, requested address, source position and converter version
remain separate. Decoded-record keys include physical record identity to avoid
collapsing duplicate classic IDs. They identify records within the established
source, not canonical replacement targets or persistent definition keys. Classic
IDs remain separate mapping inputs for the later logical resolver; do not persist
physical decoded-record keys as gameplay references. They are not placement,
save-instance or cursor identities.
Failures preserve source/request context and converter/provider attribution;
rejected reads never become successful empty media.

## Supported/rejected inventory v1

| Family / converter | Supported interpretation | Explicitly rejected / remaining coverage |
| --- | --- | --- |
| ARCH3D / `classic-model-v1` | v2.5/v2.6/v2.7 headers, aligned point references (v2.5 reference ×3), exact signed source coordinates/normals, per-plane texture archive/record, encoded UVs and first-three delta/affine UV interpretation, polygon triangulation preserving source winding | Unknown versions, invalid extents/references, fewer than three points, degenerate first-three UV basis and polygons that cannot triangulate. IMP-013 adds input-matched DFU packed-UV decoding for IDs below 905 and the first three vertices only (`dfu-packed-uv-first-three-pre905-v1`), independently pinned on source model 546; encoded UVs remain unchanged. No DFU model-specific patches, smoothing, collision, object-data behavior or world placement. Non-render geometry fields retain source metadata rather than gaining gameplay semantics. |
| Texture archives / `classic-image-v1` | 20-byte directories at 26, signed offsets/dimensions, logical size/data offset, raw single-frame profiles 0x0000 and verified 0x0900 with physical 256-byte row stride; row-table 0x0108/0x1108, explicit raw/0x8000 rows, frame-table order; user-authorized IMP-010 transparent/literal-run multi-frame profile below | Unknown compression/row encodings, solid synthetic archives TEXTURE.000/.001 and invalid dimensions/runs. These are not silently decoded through a default branch. Logical RecordSize is not a physical pixel boundary for interleaved single-frame terrain. |
| IMG / `classic-image-v1` | Standard 12-byte header, uncompressed pixels, signed offsets; headerless dimensions for the explicit byte-length inventory in `classic_image.gd`; six named embedded six-bit palettes | Compressed IMG, unexplained trailing bytes, short pixels/palettes, unknown mappings. The DFU 44-byte→22×22 case is deliberately not accepted: those extents conflict. |
| CIF / `classic-image-v1` | Sequential standard IMG records, uncompressed or 0x0002 run/literal compression, record order and offsets | Weapon animation CIF headers/frames; unknown compression, truncated headers/data and oversized runs. |
| RCI / `classic-image-v1` | Exact filename/dimension mappings FACES.CIF, CHLD00I0.RCI, TFAC00I0.RCI (64×64), BUTTONS.RCI (32×16), MPOP.RCI (17×17), NOTE.RCI (44×9), SPOP.RCI (22×22); exact record multiples | Unknown names/dimensions, partial final records, nonexistent record/frame. Filename is an explicit format mapping, never a domain alias inference. |
| Palette / `classic-image-v1` | 768 RGB bytes or 776-byte COL layout; MAP.PAL and embedded IMG/VID six-bit components multiply by four; explicit caller alpha index -1 or 0..255 | Other lengths, six-bit components >63, invalid alpha index. No guessed universal alpha or palette fallback. |
| DAGGER.SND / `classic-sound-v1` | Entire nonempty numeric BSA payload is unsigned 8-bit mono PCM, 11025 Hz; exact centered integer samples -128..127, rational duration | Empty/non-numeric domain records, malformed/missing/ambiguous container requests. No WAV/container guessing or normalization. Classic ID and physical index stay distinct. |
| MIDI.BSA HMI / `classic-hmi-v1` | HMI-MIDISONG061595, checked track directory/signature/header lengths, bounded MIDI VLQ, channel/running events, duration-based generated releases, meta tempo/events, retained FE10/14/15 markers; deterministic type-1 SMF and rational event times under `jukebox-192-v1` | Other HMI/HMP versions, system-exclusive/system events outside this profile, unknown proprietary events, invalid seven-bit channel data, missing terminal, invalid tempo/track/time extents. Markers are preserved as sequencer metadata; loops are not executed. No synthesis/SF2/default bank readiness. |
| VID / `classic-vid-v1` | VID 512/14 header profile, palette, null, 124/125 audio at rate tag 166→11025 Hz unsigned mono, full/delta/row-offset video blocks, explicit frame order, exact audio chunks/sample positions and raw global/frame delays | Unknown blocks/header/rate, invalid row/run/palette, premature end and out-of-range frame. Last-frame requests check terminal/end count and retain trailing audio. No DFU minimum-740-sample timing patch, cinematic scheduling or general video playback. |

Unsupported subformats remain explicit coverage limits of this version, not
missing source families hidden as success. Later owners must not advertise these
subformats without a versioned decoder/fixture extension.

## Geometry and AV inspection conversion

IMP-061 increment 1 now supplies the separate, shared
[`dungeon-geometry-metres-v1` LOC consumer](../loc/DUNGEON_ASSEMBLY.md). The decoded
model remains immutable source-space data; successful model provenance additionally
includes SHA-256 of the exact requested ARCH3D payload. LOC fingerprints effective
geometry resources without reopening/decoding a model for point queries. This
additive provenance does not broaden the supported model/UV/action format limits.
The inspection-only conversion below retains its original scope and axes.

DATA keeps source int32 coordinate triples and normals; source coordinates have
1/256 classic-unit granularity and UVs use sixteenths of a pixel. The encoded
first-three UV deltas are retained alongside derived values. DFU's older-ID UV
correction is not applied; suspected packed components reject until independently
verified conversion vectors establish that profile. Source polygons retain every referenced point; Godot Geometry2D
triangulates the dominant-plane projection, and DATA restores original winding.
No 0.025 world scale, tolerances, placement correction or origin change is adopted.
No decoder itself applies the LOC geometry conversion or qualifies a motor pose.

`av/classic_media_inspector.gd` is a bounded real consumer. Its preview resources
divide positions by 256 into classic units, keep source axes, normalize supplied
plane normals, divide UVs by explicit texture dimensions×16, and reverse triangle
indices for Godot clockwise front faces. The fixture camera frames the source
bounding box; this is an inspection view, never gameplay coordinate conversion.
All required surface textures must be supplied by exact archive/record keys.
No replacement, optional-surface fallback, room, automap or collider is created.

Every inspection mesh has independent StandardMaterial3D objects and independently
created mutable ImageTextures, including nested texture mutation. Audio resources
are independent AudioStreamWAVs, explicitly converting centered samples to Godot
signed 8-bit storage. The fixture owns two AudioStreamPlayers and checks that seek/
stop cannot affect the other cursor. It stops/frees players and viewports before
disposing the DATA provider. No RNG or gameplay owner operation is invoked.

## HMI evidence and timing scope

The local DFU `Internal/DaggerfallSongPlayer.cs#LoadSong` reads preconverted
`Resources/Songs/*.mid.bytes`; it is not an original HMI converter. The user first
selected a supplied source, then clarified on 2026-11-20 that no source was known
and authorized researching original conversion. Primary converter evidence:
[hmi2mid 0.1.1 source](https://docs.rs/hmi2mid/0.1.1/src/hmi2mid/lib.rs.html),
which identifies Daggerfall Jukebox/WinRipper ancestry. This is format evidence;
no Rust/native library or fixed-size converter buffer/queue is imported.

`jukebox-192-v1` explicitly declares 192 ticks/quarter and initial SMF tempo
0x187fff (1605631 us/quarter), matching that converter's constants. Source header
D2/D4 words remain raw, named by offset, not asserted to be authoritative time
units. Standard tempo changes integrate exactly as integer microsecond numerators
over denominator192. HMI proprietary markers retain source bytes/positions, with
no implied loop execution. This is a versioned conversion policy, not a claim of
original driver clock equivalence or FluidSynth readiness. The local DFU D1 MIDI
is type0 and has tempo0x187fbe at offset49: its provenance/rewrites are unknown;
it is **not** falsely used as a byte-exact original-conversion golden.

[WildMIDI's own HMI reader](https://github.com/Mindwerks/wildmidi/blob/master/src/f_hmi.c)
independently corroborates the directory/header and duration fields, but explicitly
labels its alternative BPM interpretation uncertain. No WildMIDI code/backend is
adopted. Native original-clock fidelity/loop synthesis and full preconverted-track
equivalence remain unverified; consumers must capture the named conversion profile.

## Read-only reference evidence

DFU snapshot root: `reference_material/daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`.
Source files were inspected, never modified. SHA-256 values:

| API file / helpers | SHA-256 |
| --- | --- |
| Arch3dFile.cs ReadHeader/ReadMesh/WritePlane/WritePoint/UVunpack | B79F1D51A3D5D6E3630B1DA01A3AA1B3116990CC0FD10841CE26CCDD6B054490 |
| TextureFile.cs ReadRecordHeaders/ReadRecords/ReadImage/ReadRle | 1E211987FD9B3E3F93274333F313D8DB96A451A8AE4CB4570564D53A5D73FB71 |
| ImgFile.cs ReadHeader/GetHeaderlessFileImageDimensions/ReadPalette | 46E267B6BBCE8850A503311D6AFC73CCFDDB9F4B39D55CB467BE6D104349E984 |
| CifRciFile.cs ReadRci/ReadImage/ReadRle/ReadWeaponCif | 48C7865EF44D29510584C2DEFCD6218024DAAC8866F33F7BEC0FC30281FC4984 |
| DFPalette.cs Load/Read/Multiply | 16791E036115DF8EE8132226FDF95F15AFD6BB03C432FD74E1C36AF08F06EA7B |
| DFSound.cs sample format declaration | 8C73E02A9473C903BE807CF56426B24400E5E19681593D52A5442DF18064AF96 |
| SndFile.cs ReadWaveData/CreatePcmHeader | C4F719CEC736317E391E1697F7253AB1D65E66EFE5A02DBF8CE3ECB58FFAA93F |
| VidFile.cs ReadHeader/ReadPalette/ReadAudio*/ReadVideo* | 3C189A69D0A4D720FE919D96BFD5B7884644F44FAE5EDFDC11CD92B0A8DD192A |
| BaseImageFile.cs ReadImgFileHeader/ReadRleData | 119CC251B5461FAF9CCF2516A3431E06AFF801FC5B8B90EE0A3CB534EF642841 |
| FaceUVTool.cs ComputeFaceUVCoordinates | 2C847D81898E1F330F7ACF8E2E522AB5DF725FFC2F9D05449745F415DA45C257 |
| Internal/DaggerfallSongPlayer.cs LoadSong/Play | 7BA8F3E714EBD5240BBF0A5F75C0497FA1302F9A6B654A59D4950540DE789FB1 |

Actual acceptance scope, pinned fixture values, report paths and open integrations
are recorded in IMP-008 execution evidence. Replacement/export/cache resolution,
FluidSynth/SF2, FFmpeg profiles and default-bank licensing remain separately
authorized later increments. IMP-013/024/035/061 and M1 gates remain open.

## IMP-010 required transparent-run texture profile

The user authorized this additive decoder extension on 2026-11-22 after the
existing reader correctly rejected TEXTURE.210. `classic-image-v1` retains its
accepted interfaces; `classic-texture-transparent-runs-v1` names the additional
profile. No native dependency or playback scheduler changed.

For compression 0x0000/0x0900 with multiple frames, the source data starts with
`frame_count` signed little-endian 32-bit offsets relative to the data base.
Offsets must follow the complete table and fit the bounded animation record.
Each frame begins with signed 16-bit width/height, matching the record dimensions
in this supported profile. Every row contains unsigned-byte transparent count,
unsigned-byte literal count, then literal bytes, repeated to the exact width.
Zero-progress, row overflow, truncated literals/table, cross-header extents and
unknown required profiles reject without partial pixels. Explicit source zero
runs produce transparent indices; no failed decode substitutes an empty image.
Reordered/repeated offsets remain supported. Unused frame-tail bytes are retained.

Only this animation profile treats RecordSize as its bounded storage extent;
legacy interleaved single-frame terrain and existing RLE profiles keep their
accepted rules. Output retains frame/source/storage extents and metadata. Pixel
orientation stays top-left row-major; palette and alpha remain explicit. No FPS,
loop timing, gameplay action, model/world scale or engine pose is selected.

Independent observations under `tests/layout_source_observation.json` pin all 30
TEXTURE.210 records / 83 frames. The layout selection tests their actual reader
results and known synthetic transparent/literal runs, malformed inputs, detached
shared-frame outputs, source order and a later frame failure after an earlier
success. Existing classic-media 119/136 inventories remain separate and unchanged.

## Solid texture swatches for dungeon context

IMP-061 increment 2 narrowly adds `classic-solid-swatches-v1` for TEXTURE.000/001:
exact 2,586-byte, 128-record directories with verified explicit indices, zero
reserved fields, record 0..127 and frame zero. Each produces a 32x32 opaque-index
swatch (record or 128+record), following DFU TextureFile.ReadSolid (MIT).
Unsupported extents/fields fail; no generic missing-texture fallback is added.
Independent observer hashes both complete files. Dungeon UV/pixel and actual
source assemblies exercise this profile; existing media inventories stay intact.
