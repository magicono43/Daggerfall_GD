# DATA-009 — Faction source records

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Supply validated faction identities, metadata, authored defaults and structural relationships to faction, quest, NPC and save consumers. Keep reusable definitions distinct from changing character/political state.

## Intended player experience

Factions retain identity through renames and localization. Validated mods can add or replace definitions without accidental ID collisions. Malformed hierarchies fail clearly rather than breaking traversal, and loading never silently substitutes a similarly named faction or resets its reputation.

## Confirmed requirements

DATA-009-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish stable faction IDs/classic mappings; separate definitions and live state; supported classic baseline with owner-defined behavior; validated acyclic parent hierarchy and derived children; directional ally/enemy data; and explicit reference/compatibility failures.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Utility/ContentReader.cs#GetFactionFilePath` selects packaged `StreamingAssets/Factions/FACTION.TXT`, not the original ARENA2 faction file.
- `API/FactionFile.cs#FactionData` includes ID, parent, type/name, reputation, region, power, flags, ruler, fixed ally/enemy slots, appearance references, social/guild groups, rank and hierarchy-related fields. The structure mixes definition/default and potentially live-state inputs; field presence alone does not establish target ownership or gameplay semantics.
- `RegisterCustomFaction` rejects duplicate keys within its static custom registry. This does not itself establish a collision policy against the complete resolved base/mod set.
- `Load` parses definitions then calls `RelinkChildren`. That method appends child IDs to available parents and does not itself clear existing child lists or detect parent cycles.
- `GetFactionData` supports ID lookup. `GetFactionID(name)` is explicitly documented as experimental and unsuitable for gameplay. Source comments also identify some duplicate classic names.
- `Merge(SaveVars)` creates a separate dictionary and copies classic saved reputation onto matching authored factions, retaining authored structure, then relinks children. It is documented as classic import, not native DFU restoration. `IsAlly`/`IsEnemy` inspect only the first faction's slots, demonstrating directional source queries rather than proof that all gameplay relations are reciprocal.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Packaged-versus-original faction differences and full runtime faction behavior have not been verified. Source remains unchanged; classic-save import is not approved by this reference description.

## Detailed rules and behaviors

### Identity and content resolution

Use stable faction IDs with explicit classic-ID mappings. Gameplay, quests and saves reference IDs rather than display names, table positions or transient objects. Names may repeat or change through localization without changing identity; name-based tools must not silently turn ambiguity into an authoritative reference.

Support validated faction additions without relying on an uncoordinated global numeric range. Exact namespaces/key encoding/allocation remain technical dependencies. Reject duplicate IDs and ambiguous classic mappings in final definitions. Explicit replacement under DATA-003 retains the targeted identity; add collisions do not become implicit replacements. A stable ID alone does not certify semantic compatibility with an old save.

Apply DATA-003's declared operations, precedence, provenance, whole-contribution rejection and explicit recovery. Resolve required definitions/references before publishing readiness or entering the actual main menu. Pre-menu rebuilds produce coherent candidate indexes, not accumulated mutations of a prior candidate. Main-menu entry locks the configuration under DATA-003; classic-source rules under DATA-001/002 remain unchanged.

### Definitions, defaults and live state

Preserve supported classic metadata and authored relationships as the initial baseline, allowing explicit validated overrides. Verify provenance and packaged differences rather than assuming DFU's FACTION.TXT is identical to original data.

Reusable definitions and starting defaults remain separate from character/session reputation, memberships, ranks and changing political state. FACT and other authoritative owners determine mutable fields and their persistence. Reading definitions or rebuilding indexes does not mutate a character or reset an existing session. New-session initialization and restored-state application follow owner/CORE contracts.

Reputation propagation, alliance changes, guild eligibility, services and political simulation remain FACT/other-owner decisions. Importing source flags, classifications or default values does not approve every corresponding formula or fixed slot limit.

### Parent hierarchy

Require every non-root parent reference to resolve. Explicit roots are valid. Reject self-parenting and parent cycles before publishing required definitions. Derive child lists from the validated parent relationships so repeated rebuilding cannot accumulate duplicate children or retain an obsolete parent edge.

The parent relationship is distinct from allies/enemies and social/guild classifications. Exact root representation and supported schema remain technical contracts; a source sentinel must be interpreted explicitly rather than treated as a missing faction. This feature approves no reputation-propagation rule merely because ancestry exists.

### Authored relationships

Preserve ally/enemy direction. DATA validates target identities without automatically adding reciprocal edges, removing relationship cycles or resolving gameplay conflicts. FACT must define reciprocity, contradictory ally/enemy declarations, capacities, self-relations where relevant and resulting behavior before implementation is complete. Cycles in these relationships are not inherently invalid like parent cycles.

Appearance and regional references must use their domain mapping/requiredness contracts, including DATA-004 region identity and DATA-007 appearance links. Required unresolved targets fail validation; optional fields may be absent only under a declared owner rule. Do not invent appearance, faction or regional defaults to claim successful resolution.

### Failures and restoration

Duplicate faction identities, ambiguous classic mappings, missing required faction targets and invalid parent graphs fail coherent publication. Apply DATA-002/003 recovery according to whether the failure belongs to a required source/index or a contribution. Explicit omission of an invalid contribution is allowed only when the remainder is valid; it cannot bypass a required reference.

An older save referencing a removed faction receives an explicit compatibility failure for SAVE/FACT. Do not match by name, silently reset reputation or substitute another faction. SAVE/FACT may define an explicit migration/recovery contract later; none is invented here. Loading must not rerun new-character defaults over restored state.

## Relevant formulas and parameters

No reputation bounds, propagation fractions, political schedules, alliance capacities, guild thresholds or numeric ID ranges are approved here. Parent graphs must be acyclic and references unambiguous. Classic fixed fields/slots are adapter facts rather than universal extension limits; exact supported target schemas remain to be defined.

## Required data

Stable faction ID and classic mappings; authored names/localization references; supported type/flags/classifications; parent/root representation; derived child index; directional ally/enemy targets; region/appearance/group references; authored starting values; package/source provenance and validation outcomes. Live reputation, membership, rank and political state remain owner-managed. Complete field ownership, schema and original/packaged baseline verification remain dependencies.

## Inputs, outputs and events

Inputs: packaged/classic-adapted definitions as supported, mod contributions, faction/legacy-ID queries, graph validation and owner restore requests. Outputs: validated definitions/defaults, derived hierarchy, directional relationships, provenance and explicit missing/unavailable/invalid/compatibility outcomes. These are conceptual contracts, not concrete APIs/signals. Lookup does not emit reputation changes, join guilds or apply political updates.

## Cross-system interactions

- DATA-001/002 retain source/readiness/failure contracts; faction sources may be packaged. DATA-003 owns contribution resolution and activation lock.
- DATA-004 maps region references; DATA-007 supplies appearance references without inferring faction identity from sprites. DATA-008 exposes biography effects for FACT-owned application.
- FACT owns live faction rules, reputation, affiliations and political interpretation. NPC/QUEST consume stable references under explicit owner operations rather than mutating shared definitions.
- Guild/service owners define eligibility and benefits; ECON interprets political/economic inputs under its own rules. Source classifications alone do not approve those behaviors.
- SAVE/FACT restore state and validate compatibility. CORE-005/010/012/013 retain lifecycle, clean initialization, biography ordering and load recovery. MOD owns package identity/dependencies and executable registration.

## Edge cases and failure conditions

- Rename/localization or duplicate display names: preserve ID-based references; never silently choose a gameplay identity by first name match.
- Add reuses an existing ID or legacy mapping becomes ambiguous: reject invalid content rather than relying on registration order. Explicit replacement remains valid when its references validate.
- Parent missing, self-parent or cycle: fail validation. Explicit root and legal independent trees remain possible.
- Rebuild after changing a parent: child lists reflect the new graph once, with no stale/duplicate children.
- A lists B as ally without B listing A: preserve the authored direction; do not infer reciprocal state. FACT's eventual policy determines gameplay effects.
- A faction is both ally/enemy through authored references: DATA exposes the definitions and FACT must supply conflict policy; no priority is fabricated here.
- Save references removed/changed content: report explicit compatibility context; no name substitution, reputation reset or default reapplication.
- Source flag/field semantics are uncertain: document the uncertainty and validate supported interpretation; do not invent rules. Required unsupported data remains explicit failure under shared DATA contracts.

## Configuration and balancing options

Validated faction additions/replacements/patches follow declared schemas. No player-facing graph-validation bypass or silent missing-faction recovery is approved. Reputation, political and guild balancing options remain owner specifications. Supported runtime mod settings do not unlock the resolved definition plan.

## Save/load considerations

Persist stable faction references and owner-defined mutable state separately from authored definitions/derived child indexes. Reconstruct definition indexes without overwriting restored reputation, memberships, ranks or political state. Missing/replaced definitions require SAVE/FACT compatibility checks and explicit migrations where supported. Neither DFU's classic reputation-only merge nor native/DFU save import is adopted by this feature.

## Technical constraints

Target engine: Godot 4.7.2. Keep parsing, validated definitions, graph derivation and live-state ownership separate. Publish complete validated indexes and keep original sources read-only. Avoid public mutable dictionaries as the authority boundary and guard graph traversal through validated structure. Concrete registry/API, namespace representation, schemas and save formats remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Stable faction IDs/classic mappings survive renames/localization; duplicate names do not determine authoritative references.
2. Validated mod additions do not rely on an uncoordinated shared numeric range. Duplicate IDs/ambiguous mappings fail; explicit replacements follow DATA-003.
3. Definitions/defaults remain separate from live reputation, membership, rank and political state; reads/rebuilds do not mutate characters.
4. Supported classic metadata/relationships form the baseline with explicit overrides, without implicitly approving FACT gameplay formulas.
5. Non-root parents resolve; self-parenting/cycles fail before publication. Repeated child-index rebuilds are idempotent.
6. Ally/enemy targets validate while direction is preserved. Reciprocal links and relationship-cycle removal are not synthesized.
7. Required missing references prevent coherent publication under DATA-002/003 recovery; partial invalid graphs are never ready.
8. Missing factions in old saves produce explicit compatibility failure, without name substitution, reputation reset or replay of starting defaults.
9. Configuration lock and source read-only contracts remain intact. Representative duplicate/missing/cyclic/renamed/modded fixtures verify identity and graph behavior before implementation is complete.

These are future verification criteria. No implementation, original-data fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–008 and approved CORE lifecycle/start/load contracts. No contradiction identified. Definition/live-state separation preserves character isolation and CORE-012 biography ordering. DATA-003's later-source precedence does not excuse invalid identity or parent graphs. Directional relationship preservation leaves FACT gameplay choices open rather than adopting DFU mutation behavior. Save compatibility remains separate from successful definition resolution.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: original-versus-packaged baseline comparison; complete field/schema/ownership inventory; stable ID/classic mapping and root conventions; group/region/appearance requiredness; FACT relationship reciprocity/conflict/self-relation/capacity rules; starting-default and mutable-state contracts; source fixtures; SAVE compatibility/migrations and MOD registration integration. These deferrals do not waive identity, graph validation or explicit failure requirements.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-009-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including baseline/schema verification, FACT relationship rules and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.
