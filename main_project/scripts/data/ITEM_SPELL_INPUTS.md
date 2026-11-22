# Item and spell structural inputs — v1

IMP-009 increment 2, Godot 4.7.2 / Windows. Registered by
`StartupProviderBoundary.enable_item_spell_inputs()` before source preparation;
normal startup enables this alongside accepted actor inputs. The domain is
`item-spell.inputs`, logical resource `catalog`, schema `item-spell-inputs-v1`,
capability `data.item-spell-inputs-v1`. It reuses definition_registry, MOD checked
readers and the actual CORE menu transaction; there is no second registry.

## Source boundaries and identity

Required selected sources are only `SPELLS.STD / spells-std-v1` and
`MAGIC.DEF / magic-def-v1`, plus the existing foundation declarations. Caller
selects ARENA2 explicitly. No ITEMS.DAT, executable-offset guess, recursive
discovery, alternate installation or source-file writes occur. FALL.EXE is absent
at the authorized location. The user authorized DFU packaged items on 2026-11-21
and clarified consistency rather than exact classic parity. The 288-entry shipped
baseline and mapping/license hashes are documented in
[PROVENANCE.md](../../content/items/PROVENANCE.md).

Reader initialization parses the complete bounded relevant source, rejects empty,
truncated, trailing and count-inconsistent payloads without partial success, and
caches a private detached record set. Read rechecks file SHA-256: changed external
bytes return `source_unavailable`, requiring restart. `close()` retires access.
`read_record("@all")` returns the complete detached source map; a decimal ordinal
addresses a transport record. Missing, unavailable, malformed and unsupported
are distinct. A source record address is **not** a universal definition identity.

The selected edition has SHA-256:

| Format | Selected bytes / count | SHA-256 |
| --- | --- | --- |
| SPELLS.STD | 7,921 / 89 | `d8b34e983a9c646c7e145f862f3c410a046ea889b429f84740c9ff3d3ec3dd47` |
| MAGIC.DEF | 3,662 / 59 | `04ba8a529be11653e8d2bc66adaec2dfc3009f93ceec75f5c175cdeddab808ba` |

`selected-installation-2026-11-21-v1` assigns stable local keys
`classic-spell-000..088` and `classic-magic-000..058` to this verified edition's
records. Its fingerprint establishes which assignment table is applicable;
the ordinal alone does not establish identity for arbitrary editions. Every
record retains file hash, original ordinal, byte offset and record hash. Raw
readers accept other structurally valid editions and report `profile_known:false`.
Definition publication for an unknown identity edition returns `unsupported`
at the identity adapter, rather than guessing correspondence or reusing a known
profile. Additional editions require an explicit reviewed identity mapping.
This is separate from structural source readiness and gameplay validation.

Shipped item IDs are `dfu-item-000..287`, based on explicit packaged `index`,
never array position. Definition keys are the registry's domain, original package
and `catalog#stable-id`. The origin is `@shipped/item-spell-inputs-v1` for this
baseline. Mod additions use the adding package as origin, with arbitrary stable
local keys; they need no classic numeric mapping. Renaming, appearance changes,
reordered entries and replacement contributors preserve keys. Original input
receipts and mappings cannot be fabricated, removed or changed by contributions.

## Binary field inventory

All offsets are zero-based; multi-byte integers are little endian. Bytes are
preserved exactly as source parameters. No duration/chance/magnitude arithmetic,
material multiplier, cost formula or target/element normalization is selected.
Names expose byte code points until the first NUL; all original name-storage
bytes remain available, including bytes following a terminator. This is not a
new localized glyph/code-page policy.

### spells-std-v1

Complete 89-byte records, no header; maximum source size 16 MiB. Physical ordinal
is transport context. Source kind `spell_source` deliberately does not claim
usable MAGIC semantics.

| Offset / bytes | Data fields | Source range / treatment |
| --- | --- | --- |
| 0 / 6 | 3 effect type/subtype pairs | Signed bytes -128..127; type -1 is unused, subtype still retained |
| 6 / 1 | `element` | Raw u8; owner mapping required |
| 7 / 1 | `range` | Raw u8; owner target mapping required |
| 8 / 2 | `cost` | u16 stored source cost; zero permitted |
| 10 / 4 | `unused.gap4` | Exact safe unused bytes |
| 14 / 9 | per-slot `duration` | u8 [base, modifier, per-level divisor] |
| 23 / 9 | per-slot `chance` | u8 [base, modifier, per-level divisor] |
| 32 / 15 | per-slot `magnitude` | u8 [base-low, base-high, level-low, level-high, per-level divisor] |
| 47 / 25 | `name`, `name_storage` | NUL-terminated view and complete storage |
| 72 / 1 | `icon` | Raw u8; not identity |
| 73 / 1 | `legacy_index` | Raw u8; not unique identity |
| 74 / 15 | `unused.gap15` | Exact safe unused bytes |

Duration, chance and magnitude arrays are retained even for unused effects.
Zero divisors are not clamped. Negative type values other than -1 remain raw
active interpretation requests, subject to owner rejection. All-unused source
slots are structurally representable; empty-runtime-spell legality is unavailable.
Added definitions may contain more than three effects; classic transport alone
has the three-slot limit. Stable addition IDs are not byte indexes.

The complete observed collision inventory has one shared index: **58**,
`classic-spell-054` Holy Word (range 3) and `classic-spell-055` Holy Touch
(range 1), both element 4, stored cost 550. Both definitions survive. A unique
`spell:58` mapping is never published. `lookup_classic(registry,"spell_source",
"spell:58", "classic-spell-054")` supplies explicit stable context. Names and
patch order never choose a winner; patch entry ID `58` is not a stable target.

### magic-def-v1

Signed i32 record count followed by exactly count × 62 bytes; count must be
positive and match the complete bounded payload. Each source record retains:

| Record offset / bytes | Data field | Source range / treatment |
| --- | --- | --- |
| 0 / 32 | `name`, `name_storage` | Complete name storage and NUL view |
| 32 / 1 | `type` | u8; DFU evidence 0 regular, 1/2 artifact classes; interpretation gated |
| 33 / 1 | `group` | u8 explicit base-item context |
| 34 / 1 | `group_index` | u8 explicit base-item context |
| 35 / 20 | ten `enchantments` | signed i8 `type`, signed i8 `parameter` per slot |
| 55 / 2 | `uses` | i16 source uses/condition input, not an instance |
| 57 / 4 | `value` | i32 artifact-value input, not a settlement/pricing rule |
| 61 / 1 | `material` | u8 source material in base-item context; zero retained |

Enchantment type -1 is no enchantment and preserves its parameter. DFU enum
evidence names 0..26 (cast used/held/strikes are 0/1/2); other bytes are preserved
for explicit unsupported-owner outcomes. Parameters are not blindly treated as
spell IDs for every enchantment. Cast types require an unambiguous spell mapping;
other required parameters and materials must pass the separate ITEM/MAGIC owner
interpretation boundary. No material default, artifact effect substitution or
signed-to-unsigned parameter correction is enabled.

The baseline resolves all 59 base group/index pairs and all cast references.
There are 23 artifact-class sources, exposed by `artifacts()` as detached
structural projections rebuilt from the locked catalog, not gameplay objects.
Legacy `magic-offset:N` and `magic-ordinal:N` mappings apply only within the
explicit edition; the original offset is never used as a universal ID.

### dfu-packaged-items-v1

Shipped UTF-8 JSON array, exact pinned hash, 288 explicit integer indexes. Each
entry validates completely after adaptation; schema lists every allowed field:

| Fields | Type / units / bounds |
| --- | --- |
| `index` | Integer 0..2^31-1, source metadata; stable key/mappings own lookup |
| `name` | String, presentation independent of identity |
| `baseWeight` | Finite nonnegative kilograms, before owner material rules |
| `hitPoints` | u16 source durability input |
| `capacityOrTarget`, `basePrice` | i32 source units; contextual interpretation/pricing remains owner-defined |
| `enchantmentPoints` | i16 source input |
| `rarity`, `variants`, `drawOrderOrEffect` | u8 contextual source fields; no distribution or effect semantics inferred |
| `isBluntWeapon`, `isLiquid`, `isOneHanded`, `isIngredient` | Explicit booleans from the exported property interpretation |
| `worldTextureArchive`, `playerTextureArchive` | Integer 0..511 |
| `worldTextureRecord`, `playerTextureRecord` | Integer 0..127 |
| `dfu_extensions` | Only explicitly present boolean `isNotRepairable` / `hasNoEncumbrance`; no absent defaults |

Classic mappings are `template:N` and supported `group:G:I` pairs. The mapping
table preserves enum aliases such as book contexts, excludes magic/artifact
subtype groups, and does not publish Deeds' gem aliases. Mapping availability
does not select readable-book contents or executable item behavior.

## Contribution, references and publication

Values have required `schema`, `kind`, `data`, `mappings` (array of strings) and
`references` (array of `{id,kind}` or `{mapping,kind}`). Supported kinds are `item`,
`magic_item_source` and `spell_source`. The optional `input` receipt is trusted
baseline provenance only. Unknown required top-level/data fields fail; safe
author metadata belongs in optional top-level `unused` dictionary. No instance
quantity, custody, equipment, enchantment state, learned spells or active effects
belong in these definitions.

Add/replace/patch use the shared registry: replace replaces the complete resource
record set while retaining matching definition origins; patch replaces supplied
top-level fields and whole lists/objects, without implicit deep merging, deletion
or null defaults. Patches cannot change schema/kind/mappings/input identity.
Validated replacements retain baseline receipts/mappings. The registry retains
contributors and winners for supplied top-level fields. A late invalid entry
rejects the entire contribution without mutating earlier resources.

Cross-reference checks run after all contributions. Item/magic mapping collisions
fail; spell mappings may explicitly remain ambiguous. Required references need
one target of the declared kind. Required base mappings and cast-spell dependencies
are also derived from magic source data, so stripping `references` cannot bypass
them. Magic items can declare `spell_contexts:{"slot":"stable-spell-id"}` to
disambiguate a cast slot: the selected ID must actually belong to that legacy
mapping. Canonical slots 0..9 and stable IDs validate; wrong contexts fail.
Required `behavior:"provider.key"` always fails until a real registered ITEM/MOD
provider exists; no package code, C# type serialization or generic fallback runs.

Shipped bytes use `FileAccess` on `res://`, including in PCK exports. Folder/ZIP
JSON uses checked MOD package reads, then captured loose `Overrides/` wins last.
Explicit omission must rebuild/revalidate remaining references. Invalid required
references cannot be omitted into success. Clean rebuilds regenerate all source
receipts and mappings; stale tickets fail and actual menu entry locks content
for the run. Source/loose edits require restart; external classic reader state
does not change when MOD candidates rebuild.

## Corrections, conversion and truthful readiness

There are **no enabled production spell corrections**. Free Action's original
type 3/subtype 2 is preserved. `conditional_correction` is a pure trusted-code
mechanism: a named individually approved rule matches complete expected data,
returns a detached replacement plus original/approval annotation, and leaves
externally modified input alone. Controlled vectors exercise match/nonmatch and
later registry override precedence. Packages cannot register correction approvals.
Future approved baseline rules must run before MOD/loose resolution and retain
the returned annotation; this increment enables no such rule.

`convert_spell(value, owner_callable)` is a pure checked interface probe, not a
MAGIC implementation. The callable receives `("context", complete_data_copy)` or
`("effect", active_effect_copy)` and returns `{ok:true,value:nonempty_dictionary}`
for checked settings, or `{ok:false,kind,reason}`. Empty successful settings are
rejected; rejection without optional diagnostics still returns checked failure.
The owner checks the complete target/element context, then
every active effect. Any rejected context/effect fails the whole conversion,
with slot/type/parameter context and no partial bundle. Unused slots remain in
the detached source. A successful controlled probe is always `interface_only`
and `semantic_ready:false`, and never changes production readiness.
`validate_magic_interpretation` similarly requires a checked owner projection
for material, magic type, every active enchantment and any required behavior;
missing/unsupported interpretation fails as a whole. Zero/no-enchantment values
are preserved without requiring positive values or synthetic effects.
Its callable receives `{stage,value,slot?}` and returns a checked `{ok}` outcome.
Both interfaces are synchronous trusted application callbacks, with no package
registration or executable activation. They must be pure and must not yield or
create gameplay state. Runtime owner lifecycle/registration is still unavailable.

`lookup(...,use="structural")` returns detached source definitions after menu
commit; any gameplay-use request returns `semantic_unavailable`. Real ITEM
construction/equipment/state (IMP-017), MAGIC effect/formula/runtime conversion
and execution (IMP-033), and SAVE compatibility/migrations remain open. No
controlled owner can make a production semantic gate green. Reads, conversion
probes and validation allocate no persistent instances, draw no live RNG, grant
no item/spell and tick/restart no effect. No saved content is migrated, discarded,
reset or reapplied. Parent IMP-009, increment 3 and M1 are not accepted here.
