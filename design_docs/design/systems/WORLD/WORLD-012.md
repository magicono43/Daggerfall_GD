# WORLD-012 — Climate, political and location context

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Make the current place consistent across maps, regional services, weather, quests and law. Players can move between neighboring towns within one map pixel and receive the context of the town they actually entered. Arrival and restoration establish the correct context before dependent gameplay resumes.

## Confirmed requirements

- **WORLD-012-D01.** Publish one coherent update with previous and current context and the fields that changed. Consumers can observe the fields they need.
- **WORLD-012-D02.** Select exterior location from the committed position and validated footprints. Report no current exterior location between footprints. Apply a validated selection rule when overlap requires one answer. Indoors use the committed location and its WORLD-001 anchor.
- **WORLD-012-D03.** Distinguish valid absence from missing required data. Publish stable geographic identities and associations. LAW, FACT, NPC and TIME apply their own policies. Allow validated modded boundaries and regional associations.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-012-interview-decisions) records these decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Internal/PlayerGPS.cs#UpdateWorldInfo` reads climate and political indexes and resolves region and location data by pixel. `Update` raises the pixel event after refreshing world information. `RaiseEvents` then reports changes to region, climate and political indexes before `PlayerLocationRectCheck` evaluates the actual location boundary. Regional helpers resolve faction, dominant race and name-bank data. This is a static source trace.

## Detailed rules and behaviors

1. Resolve pixel, geographic region, climate, political area and location from the matching committed pose and context under WORLD-001. Climate is authored geography under DATA-006. TIME and presentation owners resolve weather, season and their effects. Regional lookups may expose stable associations such as local faction, naming or population profile. Their owners interpret those associations.
2. Outdoors, use the pixel as a spatial lookup aid and test applicable authored footprints against the committed position. Support changes of current location within one pixel, including transitions through space outside every footprint. When a consumer needs one location in an overlap, resolve it through an explicit validated rule independent of load order. Indoors use the committed location and anchor, while retaining door and transition references under MOVE.
3. Publish all changed fields together so observers read one coherent before-and-after state. A committed movement or arrival applies the context for its accepted pose. A pure origin shift, provisional destination or streaming activation alone produces no geographic change. Preserve the operation origin so initialization and native restoration can establish context without replaying live crossings, discovery or entry reactions.
4. Represent valid absence for fields where the resolved geography declares it, such as no applicable jurisdiction in open water. Keep missing, invalid and unavailable required context distinguishable and route required failures through readiness or recovery. Consumers use their own declared behavior for valid absence. Avoid silently substituting a neighboring region, settlement or authority.
5. Support validated geographic boundary and association overrides through DATA and MOD. A border crossing changes the current context used by consumers. Existing charges, quest references and other durable records retain their owner-defined attribution. WORLD supplies facts and associations, and each owner controls resulting gameplay.

## Relevant formulas, parameters and configuration

Use the approved WORLD-001 coordinate conversion and resolved spatial definitions. Define edge inclusion, overlap selection and association precedence explicitly so matching inputs give the same result. Exact footprint geometry, field schemas and precedence formats remain open. Mods can change supported boundaries and associations through validated content.

## Required data

Committed pose and location context, coordinate and content versions, pixel index, resolved region, climate and political coverage, location footprints and overlap rules, stable identity and association references, and request or session identity for staged operations.

## Inputs, outputs and events

- **Inputs** — Committed movement, arrival or restore context, validated spatial definitions and associations, and matching origin state.
- **Outputs** — Resolved geographic context, changed fields, and explicit absence or failure results as applicable.
- **Events** — Coherent old and new context with change origin and relevant request identity. Consumers can filter by changed field. Public event names and dispatch mechanics remain open.

## Cross-system interactions

- **WORLD-001/002/003/004** own committed position, rebases, arrival and readiness. **WORLD-006 and LOC** supply exterior footprints and interior identity. **WORLD-013** owns detailed location-boundary reactions.
- **DATA-004/006 and MOD** supply validated definitions, coordinate context and mod overrides. **LAW, FACT, NPC, TIME, QUEST and UI** consume relevant context under their own rules.
- **CORE/SAVE** coordinate restore and required-data recovery. Durable associations stay with their authoritative owners.

## Edge cases and failure conditions

- Test walking between towns that share a pixel, including leaving all footprints and entering an overlap. Results must be independent of activation order.
- Test a move or teleport changing several fields together. Subscribers must see the same committed context. Failed placement must not publish the provisional destination.
- Test valid unclaimed waters, missing required climate or region data and invalid mod associations. Keep valid absence distinct from failure.
- Test a boundary crossing during rebasing or restoration and verify that stale work cannot publish context or duplicate live consequences.

## Save/load considerations

Persist authoritative pose, location and owner-specific durable references through SAVE. Rebuild derived geographic context from validated current inputs before dependent gameplay resumes. Required incompatibility follows approved migration or explicit recovery. Restoring context does not replay live crossings or change the jurisdiction already attached to a durable charge.

## Technical constraints

Target Godot 4.7.2. Resolve all fields from a coherent committed state before publication. Use stable identity across content and scene lifecycle. Exact indexing, field notification, spatial selection and migration mechanics remain open.

## Acceptance criteria

1. A transition changing several context fields publishes one coherent update. Every subscriber can read the same previous and current state.
2. Two towns sharing a pixel can be entered and left independently. Space outside their footprints reports no current exterior location. Validated overlap selection is deterministic.
3. Indoor movement uses the committed location and anchor. Failed arrivals and pure rebases produce no synthetic context change.
4. Valid absence and invalid required data are distinguishable. Modded boundaries and regional associations pass validation before use.
5. Native load establishes context without replaying live crossing effects. Existing legal and quest records retain their owner-defined attribution.

## Outstanding questions

- Define footprint edge and overlap rules with LOC and WORLD-013.
- Specify required versus optional context fields per consumer, including political area and jurisdiction associations.
- Define notification ordering with dependent owner actions and validate restore and simultaneous-boundary scenarios.
