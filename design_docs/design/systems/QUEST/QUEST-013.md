# QUEST-013 — Marker selection and site links

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-013-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-013-interview-decisions).

## Gameplay purpose and intended player experience

Place quest resources at reliable locations while allowing quests to share a dungeon. Custom dungeons can support quests without dedicated quest markers. A quest can designate an existing enemy slot for a quest foe, and returning to the dungeon preserves that assignment and its resolved state.

## Confirmed requirements

- Try the authored marker first, then explicitly permitted alternatives within the declared room or area. A marker defaults to one claim and can declare greater capacity or sharing.
- Secure and validate the new slot before releasing the old one during relocation. Preserve quest resource identity and prevent duplicate appearances.
- Save stable site, placed-block, marker and quest resource identities where applicable. Defer scene attachment until geometry is ready. Changed layout requires a compatible mapping or explicit recovery.
- Support markerless quests and objectives, including custom dungeons without dedicated quest markers and authored replacement of an existing dungeon enemy with a quest enemy.

See QUEST-013-D01–D04 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-013-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Place.cs#GetSiteMarker` prefers spawn markers for people and foes and item markers for items. It supports specific indices, combined marker selection, and reuse of an already selected marker. `AssignQuestResource` normally culls an earlier resource target before assigning the new one. `QuestMachine.cs#CreateSiteLink` provides links for layout builders, and restoration calls legacy marker reassignment. These findings come from static inspection.

## Detailed rules and behaviors

1. A quest selects a logical site under QUEST-012 and declares the placement required by each resource. For a marker-based request, resolve the authored marker by stable scoped identity and verify purpose, capacity and existing claims. Evaluate authorized alternatives in declared order within the allowed area. A placement failure identifies the unmet requirement and whether it is temporary or exhausted.
2. Objectives that refer to a site or an existing world entity can declare that they require no new placement. Resources that need placement at a markerless site can use a bounded, validated area placement or a compatible existing world slot. A quest may explicitly allow one of these modes as a fallback. Apply the relevant world and resource owner's readiness and placement checks.
3. For a quest enemy replacement, target an eligible enemy slot by stable identity within the declared site. Validate ownership, current occupant state and competing claims before replacement. Commit the quest foe and the suppression of the original occupant together. Preserve the quest foe's stable identity and ensure at most one active occupant for that slot. The quest's authored rules and NPC/COMBAT owners determine eligibility for occupied, previously defeated or already reserved slots. A defeated or looted occupant cannot silently be reset to satisfy the request.
4. Reserve only the capacity a quest needs. A single-capacity marker or slot cannot serve conflicting claims. Honor explicit shared capacity and site exclusivity. Validate provisional claims before publishing the settled offer or activation. Release unused claims on failed generation, cancellation or quest cleanup under the owner rules.
5. Relocation stages and validates the new binding before transferring authority from the old binding. A failure leaves the old placement valid. A successful move reuses the resource identity and retires its old representation. Stream-out detaches only the scene representation. Re-entry recreates or reconnects the current representation from the retained binding and owner state.

## Required data, inputs, outputs and events

Inputs include quest instance and resource IDs, site and placement scope, stable marker or world-slot ID where applicable, placement mode and purpose, capacity, claims, and readiness and occupant state. Outputs include a retained logical link or explicit no-placement result, a committed move or attachment, a deferred attachment, or a classified failure. Author diagnostics identify the target, selected mode and conflicting claim or failed constraint.

## Cross-system interactions

QUEST-012 owns site selection and site-level constraints. DATA-005 supplies scoped layout and marker identity. LOC and WORLD supply area, geometry and slot data. NPC-007 supplies scripted actor placement constraints. QUEST-015 through QUEST-017 and the NPC, ITEM and COMBAT owners govern resource state and representation. QUEST-008 publishes required logical bindings. QUEST-011 handles terminal cleanup. QUEST-022 and SAVE coordinate restoration.

## Edge cases and failure conditions

- A custom dungeon has no markers. A site-only objective can proceed. A required resource can use an authorized area or slot if compatible. Otherwise report a placement failure.
- Two quests want the same enemy slot. Respect the first valid claim and let the other request use its declared alternatives or report a conflict.
- A relocation target is invalid or blocked. Preserve the original binding and its state until a move can commit.
- A previously resolved quest foe is defeated. Streaming or restoring the slot preserves the committed defeat and custody outcomes. Cleanup must respect the authored post-quest occupant policy and the responsible owner's state.
- A layout update removes a bound marker or slot. Use an explicit compatible mapping or owner recovery. Proximity alone does not establish equivalence.

## Configuration and balancing

Authors configure marker purpose and preference, capacity and sharing, bounded fallback areas, markerless modes, and compatible slot selectors. Encounter difficulty and permitted replacement targets remain authored and owner-validated. No placement distances or probability formulas are set here.

## Save/load considerations

Persist stable site and placement references, resource and claim identity, and enough owner state to recover supported moves and enemy replacements. A markerless area placement retains its resolved position in a compatible area reference. Restore logical bindings before attaching streamed representations. Restore replacement and defeat state before populating the slot. Incompatible geometry, markers, or slots require explicit migration or recovery.

## Technical constraints

Target Godot 4.7.2. Keep logical links independent of scene nodes. Validate streamed attachment and retry against authoritative state. Use stable scoped identities for claims and owner operations so duplicate load or attachment callbacks cannot duplicate resources.

## Acceptance criteria

1. A preferred marker is used when eligible. A conflict can use an explicitly permitted alternative. Exhausted capacity reports a placement failure.
2. Failed relocation preserves the old binding. Successful relocation preserves resource identity and yields one active representation.
3. In a dungeon with no quest markers, a site-only objective and an authorized markerless placement can work. An authored quest enemy replacement occupies one eligible slot and restores without duplicating or reviving the defeated foe.
4. Streaming and reload preserve settled links and claims. An incompatible layout change requires an explicit mapping or recovery.
5. Generation failure and cleanup release the applicable claims without modifying unrelated resources.

## Compatibility review and outstanding questions

The specification follows QUEST-012 capacity and site retention, DATA-005 scoped layout references, NPC-007 scripted placement, and QUEST-011 owner cleanup. Exact area validation, compatible enemy-slot criteria, post-quest occupant policy, legacy marker mapping and persistence schemas remain open.
