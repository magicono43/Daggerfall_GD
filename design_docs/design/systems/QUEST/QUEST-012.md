# QUEST-012 — Local, fixed and remote site selection

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-012-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-012-interview-decisions).

## Gameplay purpose and intended player experience

Give quest authors control over where an adventure takes place. Quests can use an appropriate site nearby, send the player to a particular location, or lead across regional borders. Directions and travel deadlines refer to the site the quest actually selected. Several quests can send the player to the same dungeon when their requirements allow it.

## Confirmed requirements

- Capture the selection origin from the authorized quest context at generation. For NPC offers, local means the issuing settlement and remote defaults to a different location in the issuing region. Authors can narrow or widen scope, including explicitly selecting destinations outside the acquisition region. Fixed sites use stable IDs. Settled selections survive travel and reload.
- Relax requirements only through explicit ordered fallback. Supported DFU imports can retain known fallback behavior.
- Allow shared sites by default. Honor declared exclusivity and required placement capacity. Exact marker selection and conflicts belong to QUEST-013.

See QUEST-012-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-012-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Place.cs` supports local, remote, permanent, and random permanent declarations. `SetupLocalSite` uses the player's current location and can redirect a local dungeon request to a remote search. `SetupRemoteSite` dispatches town, dungeon and exterior searches in the player's current region. Remote town selection excludes the current settlement and can broaden specific house types. A failed typed dungeon search can retry with any dungeon type. The town search has an attempt limit. Fixed selection resolves through location data. These findings come from static inspection.

## Detailed rules and behaviors

1. Resolve and retain the authorized origin when generating the quest. For NPC offers, use the issuing settlement and region. Giverless or scripted starts supply authored context when a selector requires an origin. Missing required context produces an explicit failure.
2. A local selector searches within the origin settlement. A default remote selector searches the issuing region and excludes the origin location. Explicit constraints can restrict selection to particular regions or allow destinations outside the origin region. Authors can also require a destination outside that region. A fixed selector names one stable location or a set of stable locations for authored selection. A fixed destination can be in another region.
3. Evaluate hard constraints for the requested site purpose, type and scope, required placement capacity, and active exclusivity. An exterior objective can use a location exterior without a resource marker when its contract needs none. Use QUEST-013 and world data to check required placement capacity. Leave marker choice and physical placement to their owners.
4. Evaluate fallback tiers in declared order. Within the first eligible tier, apply the selector's policy. Native random selectors default to a uniform draw over distinct eligible sites. Use scoped RULE-003 randomness and retain the result. Bound search work. If the search cannot establish whether candidates remain, distinguish that condition from verified exhaustion.
5. Allow quests to share a settlement, building or dungeon when capacity and active claims permit it. A declared exclusive reservation conflicts with other uses within the declared scope. Revalidate a provisional site claim before publishing a settled offer or active quest that relies on it. A failed claim can lead to another eligible candidate while generation is unresolved, subject to the selector and offer rules. Release provisional claims when generation fails or the pending offer ends. Release committed claims through the applicable quest lifecycle.
6. Retain the selected site and authorized scope after the offer or generated binding settles. Travel, re-entry and reload reuse that result. A changed or incompatible site uses explicit owner recovery or supported migration. A selector fallback does not silently relocate a settled objective.

## Required data, inputs, outputs and events

Inputs include stable quest and place IDs, selection origin, location and region IDs, selector scope, type and purpose, ordered fallback tiers, capacity requirements, active claims, candidate data and scoped randomness. Outputs include a resolved logical site and claim where applicable, or classified failure with the failed selector and tier. Site selection itself does not reveal a map destination, place a physical resource, or start a quest.

## Cross-system interactions

DATA-004/005 and LOC/WORLD supply stable site identity, type and placement metadata. QUEST-005 validates fixed references and selector declarations. QUEST-003 owns social offer fallback before settlement. QUEST-008 owns activation and logical binding publication. QUEST-010 uses the resolved route for applicable clocks. QUEST-013 owns marker conflicts and placement links. NPC and QUEST disclosure rules govern when players learn the chosen site. QUEST-011 and SAVE coordinate claim cleanup and restoration.

## Edge cases and failure conditions

- A local request from wilderness with no authorized settlement origin fails or uses an authored alternative. It does not infer a settlement from an unrelated current location.
- If the exact house subtype is unavailable, an authored any-house tier can qualify. A required palace with no allowed alternative produces a no-site outcome.
- A remote selector restricted to the acquisition region cannot cross the border. An explicit cross-region selector can select an eligible destination beyond it. Unsupported fixed references fail validation under QUEST-005.
- Two quests can use one dungeon if both have capacity and compatible claims. An exclusive claim or exhausted required capacity makes a site unavailable to the conflicting selector. Failed generation cannot leave an orphaned claim.
- A valid selector with no eligible site produces a classified runtime failure. Invalid selector definitions and required references use validation recovery.

## Configuration and balancing

Authors configure scope, site type, purpose, required capacity, exclusivity, fixed destinations, and fallback tiers. Supported imports can retain verified legacy rules, including house and dungeon fallback. Exact candidate indexes, search limits and legacy distribution fidelity remain integration decisions.

## Save/load considerations

Persist settled origin and site IDs, required content compatibility references and supported claims with the owning offer or quest. Restore site references and reconcile claims before dependent placement or interaction. Preserve the resolved site through reload. Incompatible references require explicit migration or recovery under DATA and SAVE. Exact reservation persistence and restoration order remain owner integration decisions.

## Technical constraints

Target Godot 4.7.2. Keep logical site selection separate from exact marker assignment and streamed scene attachment. Validate fixed references before use. Use stable site identities, deterministic candidate ordering for scoped draws, and bounded search. Revalidate conflicting claims through their authoritative owner.

## Acceptance criteria

1. NPC offers use the issuing settlement for local selection. Default remote selection uses another location in the issuing region. An explicit cross-region selector can require a destination outside that region.
2. Fixed sites resolve by stable ID. Fallback uses only declared tiers, and a hard constraint remains binding unless its authored fallback permits a change.
3. Shared sites support simultaneous quests with compatible claims and capacity. An exclusive claim prevents conflicting use, and a failed generation leaves no stale provisional claim.
4. A settled site survives travel and reload without a new draw. Incompatible site data enters explicit recovery.
5. Invalid selectors, verified exhaustion and unresolved search failures are distinguishable. Generation leaves disclosure and exact marker placement to their owners.

## Compatibility review and outstanding questions

The specification follows QUEST-005 validation, QUEST-003 pre-settlement offer fallback, QUEST-008 logical bindings, QUEST-010 travel estimates and DATA-004/005 stable location references. Exact capacity queries, reservation scopes and lifecycle, legacy selector coverage, and save schemas remain open.
