# Windows native media boundary — IMP-008 increment 3

Implemented, Windows-verified and user-accepted on 2026-11-21 for the concrete
increment-3 inventories. All three approved IMP-008 implementation increments
are accepted; named real-owner/shared-feature and M1 integration gates remain open.

The project-owned C++ extension uses the existing vendored official Godot C ABI
header, while leaving `WindowsStorageLease` unchanged. Its typed Variant interface
accepts checked `PackedByteArray` input and returns dictionaries containing typed
byte buffers and metadata. The standard Windows x86-64 float_64 Variant storage is
24 bytes, aligned to 8; built-in payload access uses official interface functions.
Strings and StringNames retain the existing 8-byte ABI. No godot-cpp dependency,
machine-wide install or additional C++ runtime DLL is introduced.

## Rebuild

Use the previously accepted portable Zig 0.13.0 installation. From repository root:

```powershell
./main_project/tools/fetch_media_dependencies.ps1
./main_project/tools/build_media.ps1
```

`dependencies.lock.json` pins archive and shipped DLL identities. The build checks
the archives/default bank and the extracted runtime DLLs. Generated DLLs, compiler
caches, SDKs and the copied default bank are ignored. A clean checkout needs these
commands before import/export. The bank is a reproducibly fetched application
asset; it is not a classic payload or an optional machine-specific path.

The selected FluidSynth 2.4.7 official Windows x64 release uses the upstream Windows
recipe at `v2.4.7/.azure/azure-pipelines-win.yml`, with MSVC `v141_xp`, Release,
`enable-floats=1`, static MSVC CRT and dynamic bundled libraries. The observed
transitives are GLib/GObject/GThread 2.26.1, gettext libintl 0.18.1, libinstpatch
1.1.7, libsndfile 1.2.2 and SDL 3.2.10. These are dependencies of the upstream
binary, not alternate game audio devices. No FluidSynth device driver is created.
The FluidSynth DLL's observed PE linker version is 14.16. Its bundled sndfile DLL
is byte-identical to the official libsndfile 1.2.2 Windows x64 archive (SHA-256
`2173935c0c1ed13cf627951d34483f9d405ead2eb473190461c42ba220643a3f`). That DLL
statically includes FLAC 1.4.2, Ogg 1.3.5, Vorbis 1.3.7, Opus 1.4, mpg123 1.31.3
and LAME 3.100. Their upstream notices and matching vcpkg source recipes/patches
are retained under `notices/libsndfile` and `provenance/libsndfile`. The mpg123
archive SHA-512 matches the source-directory digest embedded in the actual DLL.
This identifies corresponding sources without claiming a byte-for-byte rebuild
of the upstream manual MSVC environment.

The selected FFmpeg archive is the dated `n8.1.3-39-g660b5aa7db-20261121` Windows
x64 **LGPL shared** build. Its recipe revision is
`7f2a6b1050d302144de8366afa37a75e46f326aa`; GCC 16.2.0/crosstool-NG
1.29.0.36_fbb6372. The runtime reports its complete configure string and license.
The build enables version3/shared, disables GPL/nonfree, x264 and x265. Actual
library versions are avformat 62.12.103, avcodec 62.28.103, avutil 60.26.103,
swscale 9.5.103 and swresample 6.3.103. `ffmpeg.exe` is used only to author fixtures;
it is never shipped or invoked as the game playback backend. avdevice/avfilter,
ffplay and ffprobe are not game runtime dependencies.

The adapter verifies every declared runtime DLL's SHA-256 **before** loading either
stack, preloads the dependencies by absolute path, restricts loader search to the
adapter directory and Windows system libraries, and checks the resulting module
path. A corrupt/missing stack fails its capability independently; recordings do
not require either native stack. Native executable inputs never come from mods.
`provenance/windows-pe-imports.json` records the actual import closure: the pinned
adapter/runtime DLLs plus Windows system libraries, including the OS UCRT. No
additional VC runtime redistributable or machine-wide package is installed.

The adjacent installation-owned `media-runtime.sha256` permits replacement of
interface-compatible LGPL DLLs by updating their identities without rebuilding the
game. It admits only the known fixed names, never additional paths or modules.
Without it the compiled original pins apply. Actual verified hashes remain part
of the capability/cache identity, including compatible user builds.

## Native calls and ownership

`NativeMediaAdapter.invoke(operation, ...)` is a checked vararg method. Every call
returns `ok`, `kind`, `reason`, `converter`; invalid arguments do not throw through
the Godot ABI. One adapter owns at most one MIDI and one video instance.

| Operation | Arguments after operation | Result |
| --- | --- | --- |
| `capabilities` | none | Real stack readiness, versions, FFmpeg license/configuration |
| `bank` | SF2 bytes | Actual FluidSynth admission and enumerated bank/program presets |
| `midi` | SMF bytes, SF2 bytes, whole-score loop int 0/1 | Prepared independent sample-clock player |
| `render` | sample frames 1..48000 | Stereo float32 at 48000 Hz, cursor/tick/end and per-render actual note callback records |
| `inspect_video` | source bytes, explicit profile, queue capacity | Full worker decode/convert without retaining a movie cache; metadata/diagnostics |
| `video` | same | Asynchronously preparing, bounded owned decoder worker |
| `video_status` | none | Pending or published stream metadata and classified failure |
| `picture`, `sound` | none | One RGBA8 frame or stereo float32 block, source PTS and queue/end state |
| `workers` | none | Diagnostic number of live decoder workers |
| `memory` | none | Windows process private/working-set/peak working-set bytes |
| `close` | none | Cancel, wake, join/drain, then dispose owned native state; repeat safe |

SF2 bytes are served by callbacks retaining the admitted instance's bank. The
opaque loader token `<checked-bank>` is an invalid Windows filename: built-in
fallback loaders cannot satisfy rejection from an installation or working-folder
file. MIDI uses `player.timing-source=sample`; no FluidSynth device driver, system
MIDI service or gameplay RNG is used. Calls to a given synth are serialized by
its GDScript consumer on the engine thread. Native video workers touch no Godot
objects. Only main-thread GDScript creates/uploads ImageTextures or audio buffers.

Actual MIDI callbacks forward every event to FluidSynth unchanged. Note callbacks
are recorded only for the current render, as little-endian 24-byte records:
sample u64, type/channel/key/velocity i32. Rendering splits at FluidSynth's actual
internal sample-block boundaries, making that diagnostic independent of caller
render chunk size. The native fixture measures note-on samples 0, 0 and 24000.

Queues use caller-supplied positive capacity (verified 1..256); bounded consumer
measurements and the selected capacities belong in execution evidence. This is
not a cache budget, bulk preload policy or environmental music implementation.

## Licenses and source provenance

See `notices/`, the dependency lock and the upstream recipes. FluidSynth, GLib,
gettext/libintl, libinstpatch and libsndfile use their corresponding LGPL terms;
SDL uses the zlib license. This FFmpeg binary reports LGPL version 3 or later.
Corresponding FFmpeg dependency source versions/options are those of the pinned
build recipe, including statically incorporated components; the archive's LGPL
label is not permission to omit their notices/source obligations.
The statically incorporated GCC compiler runtimes retain GPLv3 and the GCC
Runtime Library Exception 3.1; their hashes and source are recorded in
`provenance/compiler-runtime.json`. Adapter LLVM/MinGW runtime notices are retained
separately. The FFmpeg configuration remains LGPL-shared without GPL/nonfree
components enabled.

`provenance/ffmpeg-source.json` identifies exact FFmpeg source commit
`660b5aa7dbce1f95cb04b3c7b8e94d79f893d15d`. The source catalog retains the enabled
Windows LGPL-shared recipe stages, their exact source revisions, and fetched
notice URLs/hashes; these include build tools and dependencies of optional
libraries, not a claim that every stage is linked into the five distributed DLLs.
The original build/download scripts and stage patches/options are retained.
The export wrapper puts these and the notices in `licenses/native-media` beside
the executable. Source recipients can rebuild/replace interface-compatible DLLs
and update the installation manifest. A public binary distributor must also
provide the corresponding source access required by those licenses, including
transitive source/build inputs; a list of URLs alone is not a written source offer.

GeneralUser GS 2.0.3 is by S. Christian Collins, pinned to
`684543d5e5efaef08d02be50dcda8d552478fa60`. Its License v2.0 permits software use
and modification; the full license is retained beside the bank. The author
explicitly notes uncertainty about the original provenance of some samples. That
caveat is preserved, not replaced with a claim that all samples were independently
audited. The fixtures enumerate all 128 GM melodic programs and GM percussion,
then synthesize the actual D1 score; the project-authored sine bank is only an
alternate isolated fixture.

See the [execution evidence](../../../design_docs/development/evidence/IMP-008-increment-3-2026-11-21.md)
for exact qualified debug/release exports and retained obligations. This work does
not publish a release or make a written source offer. A public binary distributor
must provide the corresponding-source access required by the retained licenses;
the pinned source catalog and build recipes support that packaging step.
