# QUEST-014 — Location predicates and discovery

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-014-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-014-interview-decisions).

## Gameplay purpose and intended player experience

Advance objectives when the player reaches the place the quest requires. A settlement objective can advance at arrival, while a room objective waits until the player reaches the room. Hidden destinations can be learned through exploration, conversation, or an authored clue, with precision appropriate to what the player has learned.

## Confirmed requirements

- Authors can check a settlement, specific building interior, dungeon, room or location type. Any valid entrance into the destination qualifies unless the objective requires a particular entrance.
- Presence, entry and exit are separate checks. Presence can pass when a quest starts inside the destination. Entry and exit require a new committed boundary crossing. Fast travel and teleportation can count when they cross that boundary. Reload and failed transitions do not count as entry.
- Authors can reveal a hint, region or exact map mark and keep destinations hidden until authorized discovery. Commit an authorized reveal once for its bound site. Preserve earned discoveries by default and allow cleanup of explicitly temporary quest marks.

See QUEST-014-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-014-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Place.cs#IsPlayerHere` dispatches building, town and dungeon checks. Separate predicates check building or dungeon type. `Actions/WhenPcEntersExits.cs` tracks entry and exit and can match a location type. `Actions/RevealLocation.cs#Update` discovers a bound place and can add a notebook entry for reading a map. These findings come from static inspection.

## Detailed rules and behaviors

1. A predicate declares its target scope and check mode. Use stable world IDs for exact targets and validated type IDs for type selectors. Use LOC/WORLD containment to determine whether the current committed player context satisfies the scope. A nested interior satisfies its containing settlement or dungeon scope. A room check requires membership in that room.
2. A presence check reads current context and has no discovery effects. An entry check matches a committed transition from outside the selected scope to inside it. An exit check matches the reverse. Track the identity of a matched transition under QUEST-009. An objective that requires a specific entrance also checks the transition's verified entrance ID.
3. Use the committed origin and destination contexts for fast travel, teleportation and ordinary traversal. Evaluate those endpoints for boundary crossings. A move within the same declared scope does not leave and re-enter that scope. A failed or canceled transition leaves the previous context in force. Restore establishes context without manufacturing a traversal event.
4. A bound quest place remains hidden until an authorized disclosure or ordinary discovery. An authored disclosure can provide text only, a region-level clue or an exact mark. Resolve the bound site and allowed precision through QUEST and the discovery owner. Authored disclosure can come from conversation, exploration, a map item or a quest action. Rendering, preview and binding alone do not reveal anything.
5. Commit an authorized discovery with stable site and operation identity. Repeated delivery reuses the recorded outcome. Retain independent disclosure sources so removing a temporary quest mark leaves any independently earned discovery intact. A moved objective requires authorization to disclose its new site. The prior discovery keeps its historical meaning.

## Required data, inputs, outputs and events

Inputs include the quest and objective IDs, exact or type selector, target scope, optional entrance ID, current player context, committed transition ID and endpoints, and the disclosure source, precision and retention policy. Outputs include a presence result, a matched entry or exit, a committed disclosure, or explicit failure for invalid or unavailable required context. A predicate result reaches task processing through QUEST-009. LOC/WORLD own authoritative map mutations.

## Cross-system interactions

QUEST-012 supplies the bound site and QUEST-013 supplies placement when required. MOVE-026 and travel or teleport owners publish committed transitions. LOC/WORLD provide stable containment and map discovery. NPC-020 governs directions and map precision, NPC-022 governs authored clue reveals, and QUEST-007 keeps rendering free of gameplay effects. QUEST-011 owns applicable temporary cleanup and QUEST-022 and SAVE coordinate restoration.

## Edge cases and failure conditions

- Entering a dungeon through either valid doorway satisfies a dungeon entry objective. An objective restricted to one doorway requires that exact verified route.
- Moving from a street into a building can enter the building without re-entering the settlement. Entering a room can satisfy its room predicate while the enclosing dungeon remains continuously occupied.
- Loading inside the target allows presence to pass without repeating entry. Duplicate delivery of a genuine transition cannot replay committed effects.
- A hidden location or incompatible saved target uses its actual visibility or explicit recovery. A similarly named place cannot satisfy the predicate or receive the mark.
- Retiring a temporary exact mark preserves independent discovery and historical journal entries under their owner rules.

## Configuration and balancing

Authors configure scope, target identity or type, entrance restriction, predicate mode, disclosure precision and temporary mark policy. Authored hints and exact marks can support different exploration experiences. This feature adds no numeric formula or change to NPC-020's ordinary hint odds.

## Save/load considerations

Persist committed discoveries, applicable temporary disclosure sources, and supported transition and task progress. Restore player location and quest references before evaluating presence. A restored location supplies context and does not emit a new traversal. Recover incompatible site references through explicit mappings or owner recovery.

## Technical constraints

Target Godot 4.7.2. Use stable world and transition identities with authoritative containment. Keep predicate evaluation, transition dispatch and disclosure commits distinct. Require explicit compatibility for changed scopes or entrance mappings.

## Acceptance criteria

1. Settlement, building interior, dungeon and room predicates match their declared scope. Equivalent entrances qualify unless a particular entrance is required. Type selectors match eligible locations by type.
2. Activation inside the target satisfies presence. Entry and exit require actual committed crossings, including qualifying fast travel or teleportation. Reload and failed traversal do not produce entry.
3. Authored clues grant only their authorized precision. An undisclosed bound site can remain hidden. A committed reveal does not duplicate on redraw, retry or reload.
4. Cleanup removes eligible temporary marks while preserving independently earned discoveries and historical records.

## Compatibility review and outstanding questions

The specification follows QUEST-009 event retention, QUEST-012 stable sites, MOVE-026 committed traversal, and NPC-020/022 disclosure. Exact room and region boundary data, transition mappings, discovery representation and save schemas remain open.
