# RULE-027 — Seeded building names

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Assign repeatable contextual building names through isolated classic-compatible generation, explicit mappings and stable localization-aware assignment records.

## Intended player experience

Buildings keep recognizable assigned names through saves/content changes. Supported localized patterns can translate presentation without random renaming. Remote buildings use their own context/culture. State labels and quest renaming do not silently erase persistent identity.

## Confirmed requirements

RULE-027-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve DFU-compatible local seeded generation, explicit building context, retained components/proprietor identity, compatible localized recipes, moddable explicit type/faction mappings, intentional unnamed states and future-only content changes/isolated previews.

RULE-002 governs classic seed/range/draw compatibility and persistent results. DATA-013/015/016/017 govern localized text, expansion and persistent naming. RULE-003 isolates gameplay randomness; RULE-004/DATA-003 validate locked naming extensions. LOC owns buildings, QUEST explicit contextual renames and SAVE assignment persistence.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#GenerateBuildingName` exposes an override, seeds global DFRandom and selects localized parts by building type. Tavern draws B then A; supported shops use type-specific B then StoresA.
- Bank uses a region label, guild uses faction name, temple uses first faction child, and palace matches localized location strings for special text records or uses a generic palace label. HouseForSale returns a fixed label; unsupported types return empty text.
- City/proprietor/ruler macros are expanded; proprietor macro burns an extra classic draw and generates a male first name using region race from current PlayerGPS. Source comments describe fixing a classic always-Breton naming behavior. Complete ruler-context behavior requires further owner tracing.
- `Utility/BuildingNames.cs` wraps the formula. Source comments document discovered-name caching and developer refresh commands; complete discovery/save integration remains unverified.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; exact fixtures/list provenance, all macros and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Explicit assignment context

Provide stable building/type/location/region/faction identities and explicit RULE-002 unsigned 32-bit seed. Signed legacy seed conversion belongs to an explicit adapter. Use the building region, never the player's incidental current region, for culture/name-bank selection. Required location/faction/ruler inputs must resolve explicitly; missing data cannot select an unrelated region/culture silently.

Building identity is independent from display name. Duplicate names are valid; do not reroll for uniqueness unless a separate owner policy approves it. Assignment timing/discovery lifecycle belongs to LOC, but once assigned the result must be retained and ordinary queries cannot reassign it.

### Classic generation and compatibility

Use a private classic generator per operation, seeded once. Preserve supported DFU part-selection order, remainder mapping and intentional macro draws, including the extra proprietor draw. Same seed/version/content/context produces the same selected values. No global seed swapping or shared single-slot checkpoint is required.

Compatibility target is the inspected DFU behavior for supported reference contexts, not unverified DOS equivalence. Explicit context mapping corrections replace unsafe current-player-region/child-order/string comparisons while reproducing intended reference mappings. Distinguish numeric sequence fixtures from feature-output fixtures when content/localization differs.

Fixed labels/nonrandom patterns need no artificial simulation draw or global reseed merely because DFU seeded before branching. They remain isolated from combat/loot regardless. Previews use independent operation state and cannot consume live draws or commit assignments.

### Type and faction mappings

Retain supported shop/tavern part-composition patterns, bank-region pattern, guild/temple faction labels and palace special/generic labels as moddable defaults. Use stable IDs and explicit mappings for special locations and temple display faction rather than localized equality/first-child order. Complete adapters preserve intended base associations and must be fixture-verified before implementation.

Mod-added types can supply validated patterns, banks and required context. Definitions must declare component order/macros/required fields and supported joining/localization rules. Known non-named types may explicitly be unnamed. Unknown required type/pattern/bank mapping is an error, not successful empty text.

House-for-sale is a current-state label, not a permanent replacement of assigned building identity. LOC/UI determine presentation precedence with an underlying name. QUEST may own explicit temporary/permanent rename behavior; this feature does not approve automatic rename on quest/load/ownership changes.

### Persistent identity and localization

Retain assigned name identity/components and resolved proprietor values. Supported localized presentation uses an explicit compatible recipe with stable component references and sufficient retained context/version data; switching language may translate labels/patterns without making random selections or renaming a proprietor.

Literal/custom assigned names remain retained text unless their owner explicitly supplies localization. Retain enough original values/fallback context to prevent missing translations or changed banks from forcing random replacement. Seed alone is insufficient when component order/content/generator changes, under RULE-002/DATA-017.

Ruler/location/faction macro inputs have declared assignment-versus-live-presentation lifetimes. Existing assignments cannot silently change because a global ruler/context getter now differs; dynamic title/label updates require explicit LOC/FACT/QUEST policy. Compatible translation of retained components differs from selecting new identity components.

### Content changes and recovery

Changed banks/patterns affect future assignments by default. Existing assignments persist unless explicit migration/rename is authorized. Versioned reconstruction is acceptable only if it reproduces the retained result; do not regenerate old names against current lists and call it restoration.

Missing required parts/mappings/unsupported macros fail with building/pattern/source context. Explicit unnamed is distinct from unavailable/malformed names. Retained localization uses approved text fallback/recovery; no unapproved culture retry or random replacement. DATA-003/RULE-004 govern valid overrides/provider identity/run-long configuration and runtime failure without automatic fallback callbacks.

## Relevant formulas and parameters

No new numerical naming probability is selected beyond the supported DFU-compatible part/macro draw schedule. Seed/domain/classic ranges follow RULE-002. Tables/pattern lengths/order and context mappings are part of compatibility/version inputs, not incidental presentation arrays. Exact reference name vectors remain required validation work.

## Required data

Stable building/type/location/region/faction identity; explicit seed; selected pattern/bank/algorithm versions; retained component/proprietor values and render recipe; literal fallback/custom text where applicable; explicit unnamed/status/rename context and source provenance. Concrete schema/assignment identity remains LOC/DATA/SAVE dependency.

## Inputs, outputs and events

Inputs: valid authorized assignment request or nonmutating display/preview query. Outputs: candidate/committed retained assignment, compatible localized display, explicit unnamed or error. LOC owns commitment/events; generation does not reveal maps, rename quest resources or change gameplay randomness. APIs/signals are unselected.

## Cross-system interactions

LOC owns building/discovery identity; DATA naming/text/banks/recipes; FACT explicit faction/ruler display context; QUEST rename policies. RULE-002 classic compatibility, RULE-003 isolation, RULE-004/DATA-003 validated locked rules. SAVE retains assigned identity/recipe versions; UI renders labels/localization without reroll; DEV previews remain isolated.

## Edge cases and failure conditions

- Remote generation cannot depend on player region or current locale for stable identity selection.
- Empty required banks/unknown IDs fail before unsafe range access; deliberate unnamed remains valid.
- Duplicate names do not imply duplicate building identity or authorize uniqueness draws.
- Localized list reorder/content updates cannot reinterpret retained component identities silently.
- State labels/quest renames require owner precedence and cannot erase underlying assignment merely through display refresh.

## Configuration and balancing options

Support validated building-type patterns/banks/context mappings/macros and explicit naming hooks, including localized alternatives with declared generation/recipe semantics. No arbitrary string execution, universal rename UI or procedural ownership/ruler simulation is introduced. Reference male-proprietor/bank choices require complete adapter fixtures; alternatives are moddable rather than automatically global demographic policy.

## Save/load considerations

Save assigned name/components/proprietor and sufficient versioned rendering/reconstruction context under stable building identity. Loading/display/language changes consume no live RNG and cannot reroll assignments. Added/removed required components/patterns use explicit migration/recovery; seed-only reconstruction against changed content is insufficient. Quest/custom rename persistence and discovery caching belong to LOC/QUEST/SAVE rather than developer refresh commands as gameplay.

## Technical constraints

Target: Godot 4.7.2. Separate private deterministic generation, assignment commitment, localized rendering and state labels. Use stable IDs/explicit contexts and safe macro/list validation. Interfaces/schema/cache mechanics remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Supported seed/content/context fixtures reproduce inspected DFU selection/macro order using isolated classic state.
2. Remote context uses building region/faction/location IDs; special palace/temple mappings do not rely on localized equality/incidental child order.
3. Assignments/components/proprietor remain stable across saves/content updates; compatible localization renders without reroll.
4. Literal/custom names, explicit unnamed and missing required definitions are distinct; recovery never selects random replacement culture/name.
5. Mod-added patterns/types validate supported context/macros and follow locked provider/version rules.
6. Fixed state labels/quest renames do not silently overwrite identity; inspection/preview cannot commit or affect gameplay draws.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed RULE-002/003/004 and DATA-013/015/016/017. Explicit designation adopts classic compatibility for this feature while retaining assigned outcomes. Localization is a compatible presentation recipe, not random regeneration. State-label/rename lifetimes and complete mapping fixtures remain owner contracts, not source-implied gameplay approval.

## Outstanding questions and approval

No blocking shared-naming policy question remains. Before implementation: establish complete type/faction/palace/proprietor/macro fixtures, stable recipe/component schemas, localization fallback/version retention, assignment timing and LOC/FACT/QUEST/SAVE integration. These cannot waive explicit remote context, classic private draw order or retained identity.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-027-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented compatibility-fixture, rendering/mapping and LOC/FACT/QUEST/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
