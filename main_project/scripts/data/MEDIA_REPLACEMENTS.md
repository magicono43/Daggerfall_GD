# Media replacement resources — IMP-008 increment 2

`media-declarations-v1`, `replacement-codec-v1`, and `static-glb-v1` are the
initial concrete profiles. DATA owns selection/decoded reusable resources;
`av/replacement_instances.gd` owns independently editable resources and live
visual/audio instances. These are bounded consumers, not WORLD room rendering,
spatial sound, music scheduling, cinematics, physics, or SAVE integration.

IMP-061 increment 1 reuses that same instance factory for selected static GLB
models in the LOC assembly owner. LOC builds collision from their actual included
node/mesh transforms in the accepted engine-metre frame. Independent material
ownership is retained; source classic models use the single shared geometry
converter instead. See [DUNGEON_ASSEMBLY.md](../loc/DUNGEON_ASSEMBLY.md). This
consumer adds no media format, alias catalog, replacement precedence or native
dependency, and does not qualify actor placement or SAVE restoration.

## Registration and declarations

The normal shell explicitly calls `enable_media_replacements()` before classic
source preparation. It registers one trusted DATA adapter for `media.assets` and
capability `data.media-v1`. No package code is loaded. No additional classic
sources or bulk library scans are enabled by this registration. Consumer owners
must register required sources before classic preparation using the existing
provider contract; no late registry reconstruction is allowed.

Owners call `register_target(canonical, type, aliases, baseline_callable)` before
the first candidate. IDs and aliases use the existing case-sensitive lowercase
stable-ID grammar. Aliases are an explicit owner table, never inferred from a
display name, filename, adjacent ordinal or arbitrary numeric index. Duplicate
canonical/alias bindings reject atomically. The bounded fixture declares
`classic.sound.3` / `sound.3`, `classic.model.44005` / `model.44005`, and
`classic.texture.2.0.0` / `texture.2.0.0`. This is not a universal classic alias
catalog. Its real baseline callbacks read the accepted classic registry.

Packages declare normal checked JSON contribution files in manifest `content`.
No new unvalidated manifest metadata is an export service. Example:

```json
{"domain":"media.assets","path":"exports","operation":"add","entries":[
  {"id":"stone","value":{"schema":"media-declarations-v1","kind":"export",
    "type":"image","file":"art/stone.png","profile":"png-v1"}}
]}
```

```json
{"domain":"media.assets","path":"targets","operation":"patch","entries":[
  {"id":"texture.2.0.0","value":{"asset":{"provider":"pack.id","key":"stone"}}}
]}
```

An initial complete target has `schema`, `kind:"target"`, `type`, and exact
`asset:{provider,key}`. Owner targets use their declared type. A mod-added target
uses `asset.<origin package ID>.<local ID>` and retains the originating definition
identity on subsequent replacements/patches. Unknown owner targets and unsupported
target/type combinations reject. Type names are image/model/audio/midi/bank/video;
the latter three have no usable backend in this increment.

Only `targets` and `exports` author paths are supported. DATA internally qualifies
exports as `exports/<contribution provider>`, preventing another provider's
same-named key from satisfying a direct request or patching that provider's
export. Provider names come from checked transport, never a file's identity claim.
Whole-resource replace, add collisions, patch existence, omitted-field retention,
whole nested-field replacement, and whole-contribution rejection use DATA's
existing transaction. Unknown fields/deletion/implicit variants reject. Top-level
field winners, all ordered contributors, original definition keys and latest
winner remain separate. Export bytes are read from the source of the `file` field.

The optional trusted adapter hooks are `begin_candidate(mods,ticket,registry)`,
`resource_path(path,source)`, `record_id(id,value,path)`,
`validate_source_record(id,value,fields,path,source,origin)`, and
`finish_candidate(resources,valid)`. They run synchronously inside DATA preparation.
Only the source-record hook does domain byte/resource work. It validates every
selected entry, including earlier contributions superseded by a valid later
winner. Rejected files leave no partial records. Combined exact-export references
then validate. No hook can submit MOD edits or yield. Final CORE media publication
is a direct assignment-only `commit_candidate()` after the existing durable step;
DATA's final commit does not call arbitrary adapter callbacks.

## Transport and supported bytes

Folder/ZIP reads use `mod_configuration.read_package_file` and the existing
path/link/normalized-name/ZIP/CRC validators; no extraction or ResourceLoader of
package scripts/scenes occurs. PNG and WAV are ordinary direct package files:
authoring/export tooling is optional. Extension and MIME never establish decoding.

Trusted bundled declarations name explicit `res://content/media/...` roots and
files. Their raw `.bytes` fixture payloads and JSON declarations are included in
the Windows PCK by the export filter and opened with FileAccess at runtime. This
is separate from DATA's existing absolute-filesystem shipped intake; it does not
claim virtual archive support for that transport. Normal startup has no implicit
verification exports. Fixture registration alone opts into the synthetic goldens.

`Overrides/*.json` remains declaration intake. With the media adapter enabled,
payloads under `Overrides/media/` with the declared media extensions are retained
as non-contribution bytes at initial intake. They use the same checked physical
reader and shared normalized path keys (including mixed-case references); ambiguous
normalized sources reject instead of selecting a file. Absent/failed reads are retained, too. Loose edits/additions/removals need
restart. Other unsupported loose files still reject. Package payload reads are
retained until an explicit MOD rescan, distinguished by `discovery_generation`
from ordinary order/profile revisions. Reordering does not adopt external payload
edits. Package repair uses explicit rescan; classic source replacement retains its
existing restart rule. Neither is a live watcher or concurrent snapshot guarantee.

| Profile | Supported | Explicit exclusions |
| --- | --- | --- |
| `png-v1` | PNG signature/chunk bounds/CRC, 8-bit RGB, RGBA or indexed palette/transparency; Godot decodes RGBA8 top-left pixels | Other depths/color types, APNG; malformed/truncated bytes fail |
| `pcm-wav-v1` | RIFF/WAVE PCM tag 1, unsigned8 or little-endian signed16, mono/stereo, positive rate within engine integer range, complete aligned frames | Compressed/float/extensible encodings, duplicate fmt/data, truncated/misaligned extents; 22050/44100/48000 fixtures verified |
| `vorbis-v1` | One finite mono/stereo Ogg Vorbis stream; complete page extents/CRC/serial/sequence/continuation, identification/comment/setup, positive source rate and EOS granule; actual Godot runtime decoder and duration | Chained/multiplexed streams, other codecs, absent/incomplete EOS; no extension-only admission |
| `static-glb-v1` | glTF 2.0 GLB with exactly JSON/BIN chunks and one checked embedded buffer, indexed triangles, float POSITION/NORMAL/UV0, unsigned8/16/32 indices, static hierarchy, finite TRS with positive scale/unit quaternion, embedded 8-bit base-color PNG and factors, opaque/mask/blend | External/data-URI dependencies, required/optional extensions, skins/animations/morphs, matrix/negative/zero-scale transforms, other vertex attributes/material maps, explicit sampler features; malformed references/types/extents/cycles fail |
| `midi-v1`, `sf2-v1`, `webm-v1`, `mp4-v1` | Classified `backend_unavailable` only | No synthesis/general-video admission or playback. FluidSynth/FFmpeg remains increment 3, separately authorized and unverified here |

GLB uses a project GDScript parser feeding actual Godot ArrayMesh/material/texture
resources at runtime, including exported builds. It never imports a package scene
or executes scene extras/extensions. glTF source values are preserved in the named
`gltf-rh-y-up-meters-to-godot-rh-y-up-v1` visual frame. CCW source indices reverse
to Godot clockwise fronts; normals/UVs are preserved (ArrayMesh normal storage has
measured quantization, tested within 0.0001). Node transforms compose local T*R*S
without DFU scale, motor tolerances, placement patches, collision, scripts,
markers, interactions or gameplay authority. Preview camera placement is inspection
only. No climate/season/dye/random variant rule is inferred; unknown inputs reject.
Original classic profiles, source units and HMI/VID timing policies are unchanged.

## Requests, ownership, cache and diagnostics

`resolve(target,expected_type,ticket)` and
`export_resource(provider,key,expected_type,ticket)` require the current valid
preview ticket before entry, or committed media afterward. Preview context also
checks exact revision/profile/plan input. Qualified lookup cannot cross providers.
No selected target calls its owner baseline unless the replacement is absent after
successful validation (including permitted explicit omission/revalidation).
Baseline results retain their typed classic DATA value, canonical target and
`resolution:"baseline"`; replacement results expose engine resource data plus
target and export records/provenance. Consumers adapt these explicit kinds.

Failures distinguish invalid/unsupported bytes, wrong type, missing provider,
missing export/source, unavailable backend/resource, unknown target and premature
or obsolete requests. Preparation failures include provider/export, physical path,
profile and reason; normal DATA recovery binds their entire contribution token to
the exact ticket/revision/plan. Omission never bypasses a remaining required export.

The cache is confined to the prepared generation and keyed by ticket/revision/
profile/full plan, qualified export ID, complete validated value, physical file-field
source/token, SHA-256 bytes, converter version, named frame and target engine build.
Logical request keys additionally include canonical target (or provider/export)
and expected type. No variants/material/decoder options are silently accepted;
adding one requires a new validated result-changing input and inventory extension.
Clean builds retire prior lookup/cache ownership; rejected whole-file intermediate
resources are pruned. Rejected/obsolete candidates cannot change resources retained
by another consumer. Measurements record explicitly declared source bytes, decode
time and count. No fixed budget, eviction policy, bulk library preload or gameplay
RNG consumption is introduced. Every selected declaration is checked before menu
history/persistence, rather than postponing a selected failure until after commit.

Resource result dictionaries/provenance are detached projections. Their reusable
engine resources are read-only by contract. AV's `model_resources` shares meshes
but deep-copies mutable material/texture/nested resources; `model` creates only
visual Node3Ds/MeshInstances. `image_material` creates caller-owned editable
material/texture/next-pass resources. `audio` creates a caller-owned player and
deep-copied stream, isolating loop/cursor/seek/stop. Consumers free returned nodes
and release result references; disposal releases only the service's references.
The headless dummy renderer is not used to claim node presentation or natural
audio-driver progress: resource checks and explicit AudioStreamPlayback mixing
run headless; real nodes/frame/audio-driver behavior additionally run rendered.

Pre-menu **Content Diagnostics** is on-demand and rebuilds the actual candidate.
It shows generation/profile/revision, failures, ordered contributors, record and
field winners, qualified source/hash/profile/converter context. Valid overlaps are
informational. Recovery retains the existing current-ticket contribution omission
controls. No per-asset toggle, implicit package disable or post-menu rebuild exists.
The normal CORE durable-write failure/retry, run/save choice and run-long lock
remain authoritative. Real WORLD/SAVE/native consumers and downstream room,
collision, automap, spatial audio, music/cinematic assembly gates remain open.

## Increment 3 native extension

`native_media.gd` now validates MIDI/SF2/WebM/MP4 through the project native
adapter. The earlier unavailable-backend statements describe increment 2; its
preserved four failure assertions explicitly select an unavailable provider.
Actual native success uses a separate versioned inventory. Native cache identity
includes the actual runtime DLL identities/configuration, decoder version and
source/profile inputs. MIDI bank selection is captured by each playback instance.
Provider/export isolation, checked reads, preview tickets and publication ordering
remain the same owners' contracts. A selected invalid bank fails before menu
commit; recording-only admission does not require a native MIDI bank.

See [the bounded playback contract](../av/NATIVE_PLAYBACK.md) and
[native build and provenance](../../native/media/README.md). Real WORLD/SAVE,
room/spatial playback and full requester assembly gates remain open.

## Dungeon surface instance consumer

IMP-061 context slots may bind an exact published DATA image export by source
record. `AV.dungeon_palette` prepares an immutable model atlas; `AV.dungeon_material`
constructs independently owned mutable atlas textures and materials, uses original classic pixel dimensions for UV normalization, and
preserves replacement alpha interpretation. Preparation-private image caching
does not expose DATA mutation. Selected asset/generation/create failures abort
assembly without fallback; existing publication recovery remains authoritative.
