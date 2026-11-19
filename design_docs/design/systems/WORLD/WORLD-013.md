# WORLD-013 — Location bounds and entry events

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-14 with “I approve”. Updated 2026-11-14.

## Gameplay purpose and intended player experience

Make settlement presence and boundary reactions correspond to the places the player actually reaches. Nearby towns remain distinct even within one map pixel. Entering a building can advance an interior objective while preserving membership in the surrounding town. Hidden sites follow their own reveal rules.

## Confirmed requirements

- **WORLD-013-D01.** Use authored settlement footprints for ordinary presence. Support optional authored areas for law, discovery, ambient effects and other declared owner policies. Mods can define footprints and those areas.
- **WORLD-013-D02.** Publish a direct town-to-town move as one committed transition with previous and current memberships. Where consumers need ordered reactions, process the old town exit before the new town entry. Preserve town presence when entering a building within it.
- **WORLD-013-D03.** Treat entry as an input to discovery eligibility. Ordinary settlements can be discovered on eligible entry, while hidden sites may require an authorized reveal. Successful teleport may count as entry based on its endpoints. Native load restores presence without generating an entry.

The [gameplay decision log](../../GAMEPLAY_DECISIONS.md#world-013-interview-decisions) records these decisions and approval of the complete specification.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Internal/PlayerGPS.cs#CalculateWorldLocationRect` builds an exterior rectangle from terrain placement and block dimensions. `PlayerLocationRectCheck` checks inclusive bounds with a 4,096-classic-unit margin on each side. On entry it calls discovery before raising the entry event. Leaving the bounds or losing the current location can raise exit. `Game/Questing/Actions/WhenPcEntersExits.cs` and `Game/AmbientEffectsPlayer.cs` subscribe to those events. These findings come from static inspection.

## Detailed rules and behaviors

1. Test the exterior position against authored location footprints using WORLD-012. Locations can share or span map pixels. Outside all footprints, ordinary exterior presence is absent. A query requiring a single location in an overlap uses an explicit validated selection rule. LOC supplies nested interior membership and stable door and scope identity.
2. Owners may use an explicitly authored area for a distinct reaction, such as nearby ambient sound, discovery or local enforcement. Resolve each area through its declared policy. An ambient area does not grant settlement presence or establish legal authority. LAW retains the jurisdiction and scope rules for enforcement and durable charges.
3. Compare previous and current committed membership under one WORLD-012 context transition. A direct transfer records both sides with no intermediate wilderness state. Process exit before entry where ordered reactions are required. A nested scope can change while its parent stays present. Carry the verified entrance identity when the transition supplies one.
4. Apply ordinary traversal, successful fast travel and teleport using their committed endpoints for the relevant scope. A teleport has no implied route through intervening areas. Failed and cancelled operations, streaming activation, rebases and native restoration create no traversal effects. Presence remains queryable independently of entry and exit.
5. Offer a committed entry fact to the discovery owner for eligible scopes. Apply hidden-site restrictions and authorized disclosure rules before revealing a location. Preserve earned discovery and handle repeat delivery through owner rules under QUEST-014 and the exploration feature specifications.

## Relevant formulas, parameters and configuration

An entry is a change from absent to present for a declared scope. An exit is a change from present to absent. Evaluate both against the same committed transition. Configure footprints, optional owner areas and overlap rules in validated content. Exact shape representation, edge inclusion and tolerances remain open. DFU's margin is a reference value.

## Required data

Stable scope and location IDs, authored footprints and optional area definitions, parent or containment references, validated overlap rules, committed endpoint membership, transition and session identity, origin of the change, and any verified entrance ID. Discovery and legal policies stay with their respective owners.

## Inputs, outputs and events

- **Inputs** — Committed position or transition, validated footprint and area data, interior containment, and restore context.
- **Outputs** — Presence by scope, committed entries and exits with previous and current memberships, and explicit failure for unresolved required scope.
- **Events** — Publish boundary changes from the coherent WORLD-012 update. Supply one transition identity for deduplication and exit-before-entry ordering when applicable. Detailed dispatch APIs remain open.

## Cross-system interactions

- **WORLD-001/003/006/012 and LOC** provide position, committed arrivals, exterior coverage, context updates and nested scope identity.
- **QUEST-014 and discovery owners** interpret presence, entry and exit and authorize disclosures. **LAW-001/016** interpret enforcement areas and preserve durable legal attribution.
- **NPC, AV and UI** consume relevant membership without treating scene availability as entry. **DATA/MOD** validate authored definitions. **CORE/SAVE** restore committed context and coordinate recovery.

## Edge cases and failure conditions

- Test two towns in one pixel, a footprint that crosses a pixel seam, a direct change at a shared boundary, and a valid overlap. Selection must be deterministic.
- Test walking indoors while remaining in the same town, and entering a room or named door within the larger scope.
- Test fast travel and teleport between areas, including routes whose line crosses a third settlement. Use committed endpoints for those transitions.
- Test eligible and hidden discovery, repeated crossing, save/load at the edge and failed arrival. Restoration and retries cannot manufacture discovery or repeat credited reactions.

## Save/load considerations

Save committed pose, stable location and scope references, and durable discovery, quest and legal state through their owners. Recompute current membership against validated geometry before play resumes. Retain transition identity where needed by a dependent owner's supported pending work. Changed required footprints or mappings follow approved compatibility or recovery. Load establishes presence without emitting live entry or exit.

## Technical constraints

Target Godot 4.7.2. Use authoritative spatial coordinates and coherent endpoint membership. Content validation must make single-location selection deterministic where required. Exact geometry, sampling tolerance and owner dispatch mechanics remain open.

## Acceptance criteria

1. Presence changes at the authored footprint independently of pixel crossings. Optional owner areas can differ and affect only their declared rules.
2. A direct move from town A to town B yields one committed transition with exit A before entry B for ordered reactions. Entering a building in B preserves town membership.
3. Successful fast travel and teleport produce eligible endpoint changes. Failed transitions, pure rebases, streaming and native loading do not produce live crossings.
4. Eligible ordinary entry can reveal a site through its discovery policy. A hidden site requiring a clue remains hidden until an authorized reveal.
5. A location exit preserves existing legal facts according to their owner and cannot duplicate quest progress on retry or save/load.

## Outstanding questions

- Define footprint shapes, exact boundary inclusion, overlap selection and validation with LOC.
- Define stock discovery profiles and area semantics with the exploration, LAW and AV owners.
- Verify dispatch order, deduplication and save compatibility for content changes at shared boundaries.
