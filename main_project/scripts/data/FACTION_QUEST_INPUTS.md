# Faction and quest source inputs — v1

IMP-009 increment 3, DATA-009/012; Godot 4.7.2 / Windows. Approved GAD-01/10,
DATA-001/002/003 and PROJECT-DATA-D01 apply. The source profile and licenses are
in [PROVENANCE.md](../../content/faction_quest/PROVENANCE.md). Source publication
does not establish gameplay usability, opening-content readiness or compatibility
with saved state.

## Production registration and lifetime

Normal startup calls `enable_faction_quest_inputs()` before preparation, alongside
accepted actor/item/spell inputs. This adapter requires no new classic source;
its complete baseline is shipped DFU text. Existing selected classic dependencies
are unchanged. `bundled_contributions()` reads the explicit fingerprinted profile
through PCK-capable `FileAccess`, validates every source and emits one atomic
shipped contribution. Failed sources do not emit successful empty catalogs.

The existing `definition_registry.gd` resolves shipped → checked MOD folder/ZIP
in dependency order → captured `Overrides/`. Only versioned JSON envelopes enter
package/loose transport. Quest text is supplied as a complete JSON string, never
loaded/executed as package code. Reuse checked MOD file access and explicit
rescan/revalidation; loose edits retain existing restart rules. Every candidate
reconstructs source mappings, table indexes and hierarchy from scratch. CORE owns
reservation, interrupted/stale commit rejection, durable profile ordering and
actual menu publication. Menu entry locks the configuration for the run.

`faction_quest_source_reader.gd` additionally accepts an explicitly selected path
for checked raw source access, including `res://`. It opens READ, bounds the file,
closes handles, caches a private complete result, verifies the current hash on
each read, and returns detached copies. Changed/retired sources require restart.
No directory discovery or source switching occurs.

## Identity and operations

Domain `faction-quest.inputs`, schema/capability `faction-quest-inputs-v1` /
`data.faction-quest-inputs-v1`. Required baseline resource `packs/dfu` has 643
records: 366 factions, 265 quests, two lists, ten shared tables. Each registry key
retains domain, originating package and `packs/<origin>#local-record`.

Shipped origin is `@shipped/faction-quest-inputs-v1`. Its explicit profile assigns
`faction-<classic ID>`, fixed `quest-000..264`, and explicit list/table IDs.
Legacy mappings are `faction:<number>`, `quest:<classic source name>`,
`list:<declared list name>` and `table:<declared table name>`. Mappings are exact,
case-sensitive and explicit; names/localization and basename discovery cannot
allocate or remap IDs. Unrelated packages may both add `same-basename` under
`packs/package.a` and `packs/package.b`. They remain independent definitions.
New records must use their origin's resource (`packs/loose` for loose additions),
with arbitrary stable local keys and no coordinated numeric range. Display names
may repeat. Optional mappings cannot be ambiguous in the resolved catalog.

Envelopes support `add`, whole-resource `replace`, and record `patch`. Existing
explicit targets retain original identity and accumulate contributors/field
winners. A patch replaces supplied top-level fields; `data`, arrays, list entries,
table rows and complete text replace as units. No nested deep merge, executable
line merge, row append, implicit weighting, delete, or null reset exists. Omitted
fields retain prior values. Baseline kind, input receipt and classic mappings
are immutable; additions cannot claim shipped receipts. Replacement data may
change authored values but retains original evidence separately. Invalid late
entries reject the complete contribution. Omitting one contribution revalidates
all remaining mandatory references; it cannot waive them.

## Versioned source schemas

All sources are complete UTF-8, at most 16 MiB, without NUL or invalid scalars.
An optional BOM and original line endings survive in complete text. Parsing uses
a separate normalized line view. Positions are one-based physical lines; zero
denotes authored additions without a physical line. Encoded source integers are
signed i32; table tokens also accept nonnegative `0x` hexadecimal up to u32.
Those are raw source values, not owner-enforced gameplay bounds.

| Kind | Checked structure / units / optional fields |
| --- | --- |
| Faction source | Positive unique classic IDs after `#`; tab depth supplies parent; no skipped depths. Explicit root is `{}` after adaptation. Semicolon comments ignored for structure. Case-insensitive tags; repeated `flags` OR, other scalar duplicates fail. Original raw tags/values/lines survive in immutable `input.original.authored_fields`. |
| Faction definition | Exact `metadata`, `defaults`, `parent`, `allies`, `enemies`, `flats`, `line`, `field_lines`. Name/type required. `rep` and optional `rank` are authored defaults, never live values. Optional omitted fields stay absent. |
| Quest source | Complete uninterpreted `text` and physical `line_count`. No grammar, command activation, QRC/QBN transport conversion or unsupported-line stripping. Arbitrary nonempty readable text is structurally stored; it remains semantically unavailable. |
| Selection list | Exact `*name,group,membership,minReq,flag,notes`; strings except i32 `minReq`. Flag is `0`, `1`, or `X`; one-character membership and nonempty group retained for QUEST interpretation. Each row has primary key, typed values, source line and explicit path/ID quest target. |
| Shared table | Explicit `id,*name`, `*name,p1,p2`, or `*name,p1,p2,p3`. `id`/`p1..p3` are numeric raw parameters; `name` is the case-sensitive primary symbol, not a faction/quest definition ID. Preserve all rows and exact complete text, columns, primary key, derived index and line locations. |

Faction numeric metadata: `type`, `summon`, `region`, `power`, `flags`, `ruler`,
`face`, `race`, `sgroup`, `ggroup`, `minf`, `maxf`, `vam`; name is presentation.
None is silently normalized into gameplay state. `region` retains source one-based
units and `-1` sentinel (DFU decrements nonnegative regions during interpretation).
`ruler` remains a raw source parameter, not an invented faction-ID reference.
Summon/face/race `-1`, unknown group/type codes, power and min/max parameters remain
raw interpretation inputs. FACT/LOC/WORLD/appearance owners must define supported
classification, reference requiredness, region mapping and appearance selection.
An absent field is distinct from explicit zero or `-1`.

Raw allies/enemies retain source integer slots including zero in original receipts.
Adapted positive targets are explicit faction path/ID references; zero is an unused
source slot. No reciprocal edge or fixed extension capacity is imposed. Relationship
cycles, overlapping allies/enemies and self-relations await FACT policy; parent
cycles always fail with complete paths. Each validated parent yields fresh sorted
children; reparenting removes old edges. Appearance preserves `[-1]` or
`[archive,record]` (archive 0..16,777,215; record 0..127), not random face selection
or a claim that an actor/texture owner has validated the reference.

Table comments/sections begin `-`; inline `--` is a comment. One schema is required.
Exact cell counts reject truncation/trailing values; unsupported schemas fail.
Primary symbols cannot repeat; numeric non-primary aliases may (e.g. static message
1006 with two case-distinct names). A schema-only table/list is an explicit valid
empty source; empty bytes are `empty`. Complete text and typed projection must agree
on every contribution. Duplicate same-list quest targets fail even via aliases;
membership in different lists is allowed. No combined-pool eligibility/weight/RNG
policy is selected. Shared p1/p2/p3/id references remain source parameters until
the real table consumers validate them; in particular spell index 58 never picks
one accepted spell collision arbitrarily.

## Access, validation and unavailable owners

`lookup(registry,path,id)` returns detached structural records only after actual
publication. Any other use returns `semantic_unavailable`. `lookup_mapping()`
requires exactly one explicit match; `children()` derives a detached faction
projection; `table_row()` addresses the declared primary key exclusively.
Missing, unavailable/unreadable, empty, malformed, ambiguous, unsupported,
before-readiness and changed-source outcomes remain distinct. Parser failures
carry source/line/record/referring/target; registry failures retain provider and
reference/cycle context. No successful empty quest substitutes for failure.

`validate_handoff(record, trusted_controlled_callable, resources)` is a pure
`faction-quest-validation-v1` interface probe. Inputs are detached and identify
all required faction field checks or QUEST grammar/command/reference checks.
Responses require `ok`, `static_valid`, exact sorted `checked` acknowledgements,
empty `unsupported`, explicit `runtime_checks` and typed static `references`.
Static references must resolve in the supplied candidate resources. Every quest
physical line requires exact line/text disposition; executable lines additionally
require a supported command identity. Unknown commands, incomplete coverage,
missing static targets and malformed responses reject the entire handoff. Deferred
runtime checks remain separate. Controlled providers always return
`interface_only:true, semantic_ready:false`; they cannot certify production,
register custom commands or execute package callbacks. FACT/QUEST still must
supply real interpretation/grammar/command providers at IMP-032/028. Source
readiness alone never marks these gates green.

Source operations never draw live RNG, create actors/quest instances, allocate
persistent IDs, mutate reputation/membership/politics, register opening quests,
mark acceptance/completion, grant rewards or reset a save. Startup-list membership
is distinct from CORE-012 mandatory opening content and optional tutorial policy.
SAVE/FACT/QUEST must validate changed-content compatibility and explicit migrations;
same ID/name never authorizes state reset, quest restart or repeated rewards.
Parent IMP-009 and M1 remain open.
