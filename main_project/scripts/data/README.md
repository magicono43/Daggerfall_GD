# Classic access — IMP-004

IMP-007 increment 4 adds the separate [editable codec/import operation](TRANSLATION_AUTHORING.md)
and [application mod preferences](../mod/PREFERENCES.md). Neither changes active
classic readers or bypasses DATA/MOD's menu publication lock.

IMP-007 increment 1 now supplies [production text catalogs](TEXT_CATALOGS.md),
CSV intake and bundled recovery labels through the separate DATA publication
pipeline. Increment 2 adds the real [TEXT.RSC reader and structured profile](STRUCTURED_TEXT.md).
Normal startup enables a fifth required source; legacy fixture compositions keep
their explicit capability scopes. Earlier text-unavailable notes
below describe the IMP-004 foundation inventory.

IMP-005 increment 3 adds the separate
[definition candidate/publication contract](DEFINITION_PUBLICATION.md). It shares
this application's lifetime but never replaces classic readers during a pre-menu
MOD rebuild. Domain adapters must register their real required sources before
reader preparation. The production text catalog schema is delivered; remaining
media/world schemas retain their owner gates. Isolated bounded adapters continue
to verify the pipeline without inventing those domains.

`StartupProviderBoundary.classic` owns one `classic_access.gd` registry for the
application. CORE's character/menu lifecycle does not own or dispose it. The
startup shell disposes it before releasing the storage lease at process shutdown.
No character/world mutable state, engine resources or decoded gameplay definitions
are stored here. No new native dependency is needed for binary reads; the existing
pinned Windows C++ storage adapter still owns leases and settings replacement.

## Registered manifest and capability boundary

The enabled foundation capability is `classic-containers-v1`. Its declaration
requires these four source-level adapters using the common `bsa-v1` reader:

| Required filename | Delivered access | Later schema owner |
| --- | --- | --- |
| `ARCH3D.BSA` | Numeric/ordinal directory, raw payload bytes | IMP-008 meshes |
| `BLOCKS.BSA` | Named/ordinal directory, raw payload bytes | IMP-010 layouts, IMP-061 dungeon assembly |
| `MAPS.BSA` | Named/ordinal directory, raw payload bytes | IMP-010 geography |
| `DAGGER.SND` | Numeric/ordinal directory, raw payload bytes | IMP-008 audio |

This is an explicit **foundation container inventory**, not the complete eventual
game manifest. The enabled production consumer is the startup required-reader
gate; raw container requests are the delivered DATA interface. Normal startup now
also enables IMP-007's real text reader and catalogs. Media/world consumers remain
with their later owners.
The four initialized containers are mandatory, not optional substitutes for those
later capabilities. The registry composes/deduplicates declarations of enabled
capabilities and retains their adapter IDs in each manifest entry.

Before initialization, owners use `register_adapter(id, sources)` and
`enable_capability(id)`. The former currently accepts implemented `bsa-v1` and `text-rsc-v1`
checks; unsupported formats are rejected. Enabling an undeclared capability fails
manifest composition with `capability_unavailable`, including when a caller has
not supplied an implementation. Registration/enabling after preparation or
activation is rejected. Owners must check these request results. This is a DATA
registration boundary, not MOD's package permission/registration policy.

IMP-007 must add classic text/localization sources and their schemas; IMP-008
must add actual mesh/image/texture/audio/music/video formats and enabled required
dependencies; IMP-009 must add authored definition sources, including packaged
sources; IMP-010 must add terrain/climate sources (including `WOODS.WLD` where
required), mapping and typed layouts; IMP-061 must validate assembled dungeon
records/arrival markers. Their complete manifests require their actual consumer
declarations and verification. None is implemented, marked optional, or claimed
ready here. Each enabled capability must join validation/initialization before
normal entry. Adding a non-BSA format requires its owner's real checked reader,
not changing the format label or accepting opaque presence alone.

Videos are absent from this startup manifest: their absence causes no startup
warnings. Playback owners retain their approved missing/unplayable-media policy.
IMP-005 now has a separate real definition-publication pipeline; normal production
domain adapters are still unavailable until their owners deliver them. Passing
classic DATA alone does not create a package configuration or authorize gameplay/
session readiness. Bounded schema fixtures qualify the publication mechanism only.

## Supported structural checks

All integers are little-endian. Evidence: read-only DFU snapshot
`Assets/Scripts/API/BsaFile.cs`, `DirectoryTypes`, `ReadHeader`, `ReadDirectory`
and `GetRecordBytes`; representative installed archives were actually checked.
This implementation independently implements the documented container layout;
it does not import a DFU decoder or change the approved language/runtime split.

- Every required filename opens with `FileAccess.READ`, must be nonempty, and
  have a complete four-byte header. Windows filename matching is case-insensitive.
- Header: signed nonnegative 16-bit directory count (0–32767) followed by directory
  type `0x0100` (named) or `0x0200` (numeric). Zero records are structurally valid;
  no original population or minimum texture count is required.
- Directory starts at actual file length minus count × stride. Stride is 18 for
  named records (14-byte name plus signed 32-bit size), 8 for numeric records
  (unsigned 32-bit ID plus signed 32-bit size). The directory cannot overlap the
  four-byte header. Named keys use the bytes before the first NUL, or all 14 bytes,
  with case-normalized ASCII lookup; empty names are unsupported.
- Payload extents accumulate from byte 4. Reject negative signed sizes, extents
  beyond the directory boundary and failed/short index reads. All calculations
  use Godot 64-bit integers. Index/payload gaps and extra unrelated files are
  allowed. No original checksum, length, count or content value gates acceptance.
- Duplicate record IDs/names are allowed and retain every physical record.
  An ambiguous ID-only query fails explicitly; an ordinal query can retrieve
  either record. Supplied ARCH3D/SND archives actually contain duplicate IDs.
- This is lightweight index validation, not an integrity scan of every payload.
  BSA validation does not decode meshes, maps, blocks or sounds. Later adapter
  parsers must return their own malformed/unsupported outcomes for bad payloads.

## Requests, lifetime and result semantics

`resolve(candidate)` accepts an explicit absolute ARENA2 directory or exactly one
immediate ARENA2 child of its parent. CORE resolves remembered executable-relative
paths first. No recursive discovery, fallback, source aggregation or machine path
default exists. Root access/enumeration failure returns one root failure without
inventing individual-file inspections. Otherwise `validate(candidate)` checks the
whole composed manifest, closes validation handles, and aggregates required
failures with source path, manifest entry, category, reason and record when known.

`validate` success has `stage=validated, ready=false`.
`initialize_readers(validated)` rereads all required indexes to detect intervening
failure. `prepare(candidate)` composes those two requests. Complete preparation
has `stage=initialized_unpublished`, a source-bound attempt ticket and
`ready=false`; ordinary `read_record` still rejects it. Failed preparation closes
and discards every staged reader/index before another attempt. Old tickets cannot
publish a replacement attempt. `activate(checked)` publishes the complete set;
there is no partial publication. `discard_prepared()` handles canceled/failed
settings publication and pending source changes. Initial selection persists before
activation; remembered selections are validated again on launch. A source-specific
failed settings write restores the prior accepted setting as well as retaining
the committed file. Other preference accepted/unsaved semantics are unchanged.

Active readers/indexes are reused for the same source, including across characters
and menu returns. CORE retains them even while a different validated source is
saved pending restart. Replacing an already active source is rejected by DATA.
The setup UI shows the active source separately from pending preferences. Package
recovery can retain initialized DATA even though menu readiness remains blocked.

`read_record(filename, identity)` returns:

| `kind` | Meaning |
| --- | --- |
| `ready` (`ok=true`) | Raw payload bytes, source, requested record, stored identity and offset |
| `before_readiness` | Required access has not been published; never a successful default |
| `record_not_found` | Source is accessible, but indexed ID/name or ordinal is absent |
| `source_unavailable` | Unregistered source, failed read-only open, or incomplete read |
| `malformed_or_unsupported` | Changed source length, invalid identity type, ambiguous ID-only query, or unsupported/malformed header/index during preparation |

Numeric IDs use integers, named IDs use strings; physical identity uses
`{"ordinal": n}` with a zero-based index. These are container-local addresses,
not persistent GAD-01 domain definition keys. Domain adapters must provide stable
domain/package/local keys and any numeric/ordinal mappings. Failures carry source
and requested identity where available, including staged-source premature access.
No error becomes a successful empty/default record. An explicitly indexed
zero-length raw payload is valid container data, not a decoded domain record.

Disk-on-demand reads retain only reusable metadata, close each READ handle on
every path and allocate the requested payload only. The selected fixture has
89,819,607 source bytes but only 113,454 encoded directory bytes; validation time
and successful raw-record sizes/hashes are retained per run. These measurements
support avoiding a full source-byte memory copy at this stage; no latency budget
or decoded-cache policy is invented. Registry metadata has additional GDScript
object overhead and is not claimed to occupy only encoded-index bytes.

Actual reads reopen READ access and check current length. Disappearance/read
failure differs from index absence. There is no live index refresh, filesystem
watcher or immutable snapshot guarantee; same-length external edits can affect
returned bytes, and require restart to be supported. Consumers own recovery.
Required-service loss remains CORE-005's integration obligation; an isolated raw
record failure does not itself implement a session recovery policy.

## IMP-007 increment 3

See [LOCALE_FONTS.md](LOCALE_FONTS.md) for `text.fonts:installed`, pinned bundled
resources, checked fallback graphs, application lifetime and live presentation.
Normal startup explicitly composes fonts with the accepted text/reader adapters;
legacy fixtures retain their declared inventories. Text catalogs remain real CSV.
