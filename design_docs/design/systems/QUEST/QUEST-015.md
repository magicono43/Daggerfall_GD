# QUEST-015 — Quest people and interaction binding

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-015-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-015-interview-decisions).

## Gameplay purpose and intended player experience

Let players find and interact with the person a quest actually refers to. A merchant can continue trading while offering quest dialogue. Quests can introduce new characters, use people already in the world, or explicitly replace an occupant when the story calls for it.

## Confirmed requirements

- Authors can bind the quest giver or a named actor, select and retain an eligible existing actor, create a new quest actor, or explicitly replace an occupant with a declared disposition for the original actor and their service.
- Scope reservations to the intended interaction. Support observation and explicit replacement of an interaction. Resolve ambiguous competing quest actions through the player choice defined in QUEST-009.
- Control physical presence and dialogue availability independently. Unloaded actors retain their bindings. Genuinely unavailable actors follow authored wait, alternative or failure rules. Substitution requires explicit authoring and owner-controlled updates to clues and directions.

See QUEST-015-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-015-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Person.cs` tracks a person's home, assigned place and dialogue context. `SetupQuestorNPC` uses the last-clicked NPC and can proceed with a virtual person if the giver is absent. `Actions/PlaceNpc.cs`, `HideNpc.cs` and `MuteNpc.cs` change authored placement, visibility and dialogue state. `Components/QuestResourceBehaviour.cs#DoClick` signals the linked resource and can forward clicks to quests using the same individual NPC. These findings come from static inspection.

## Detailed rules and behaviors

1. Declare the role's binding mode. For the quest giver, use the authorized giver captured under QUEST-008. For a named actor, resolve a stable actor ID. For a selector such as a local merchant, evaluate authored eligibility, resolve one actor under the selector policy, and retain the selection when settled. Several actors sharing a faction or name remain distinct. A generated person receives their own stable actor identity.
2. Place or move a quest actor through QUEST-013 and the NPC owner. Movement, appearance changes and scene reconstruction preserve actor identity. An explicit occupant replacement creates a distinct actor and declares the original actor's disposition. Service continuity requires an authorized provider assignment. Personal and quest history stays with the original actor under NPC-004. Validate occupant disposition and required service bindings before committing replacement.
3. Bind reservations to the actor, quest role and interaction they observe or replace. Unreserved capabilities remain available under their owners. Use MOVE-023 authorization and revalidate at consequential choice. Route competing consuming actions through QUEST-009. An observer can react only under its authored scope and cannot claim the click. Release reservations through their declared lifecycle.
4. Represent physical presence and dialogue availability separately. Hiding an actor suppresses their world presence under the authored policy. Muting leaves the actor present and disables only the declared dialogue scope. Track each quest's scoped changes independently so releasing one quest's restriction cannot clear another owner's active restriction.
5. Treat scene unload as deferred attachment. If the actor is genuinely unavailable, use the authored wait, alternative or failure policy. An authorized substitute receives a new role binding with their own actor identity. Revalidate affected interactions and update current clues through NPC-020/022. Historical journal facts keep their original meaning under QUEST-007.

## Required data, inputs, outputs and events

Inputs include quest instance, role, actor and site IDs, binding mode and eligibility, placement and availability state, interaction scope, reservation lifetime, service authorization, and recovery policy. Outputs include resolved or pending binding, committed placement or replacement, scoped interaction availability, and an explicit unavailable or recovery outcome. Committed NPC and quest events carry the stable actor and operation identities.

## Cross-system interactions

NPC-004 owns actor and provider identity. NPC-023 owns offer identity and reservations affecting ordinary work. MOVE-023 and QUEST-009 govern scoped dispatch, claims and ambiguous choices. QUEST-008 supplies authorized giver context. QUEST-013 owns placement links. NPC-020/022 govern disclosure, QUEST-007 governs historical messages, and QUEST-011 governs cleanup. NPC-024, QUEST-022 and SAVE coordinate restoration.

## Edge cases and failure conditions

- The player clicks a different NPC before activation. The giver role retains the original authorized actor. Invalid required context uses owner recovery.
- Two quests use one merchant. One can observe trade or add its own dialogue without disabling unrelated capabilities. Competing consuming actions with no unique route require a choice.
- A muted person remains visible. An unloaded person retains the role. If replacement fails validation, the current occupant and provider assignment remain in force.
- An actor disappears after a clue was issued. Use the authored outcome. A substitute or new site requires authorization before updated directions can reveal it.

## Configuration and balancing

Authors configure binding mode, selection criteria, placement, observation or replacement scope, presence and dialogue changes, and unavailable-actor policy. Service permission remains with its owner. This feature adds no numeric balance formulas.

## Save/load considerations

Persist stable actor and role bindings, selected actor, applicable reservations and presence or dialogue changes, and supported outstanding placement, replacement or recovery work. Restore authoritative actor and provider state before enabling interactions. Reattach unloaded representations when ready. Changed or missing references use explicit migration or recovery. Restoration does not dispatch a click or repeat a replacement.

## Technical constraints

Target Godot 4.7.2. Keep quest roles, actor identity, placement and interaction state distinct. Use authoritative owner operations for changes, with stable scope and operation identity across retries. Validate fixed references under QUEST-005 and runtime availability through NPC and placement owners.

## Acceptance criteria

1. Giver and named-actor bindings preserve identity. A selected actor is retained across reload. Generated or replacement actors receive distinct IDs.
2. An authorized replacement preserves original personal history and applies its declared occupant and service policies. Failed replacement preserves the prior occupant.
3. Quest dialogue can coexist with trade. Explicit replacement affects only its reserved scope. Ambiguous consuming actions require a player choice and stale choices revalidate.
4. Muting leaves the actor visible, and unloading preserves the binding. True unavailability uses the authored outcome. Substitution updates current clues only through authorized disclosure.
5. Cleanup releases only the applicable quest state. Repeated callbacks and reload do not duplicate actors, roles or interaction effects.

## Compatibility review and outstanding questions

The specification follows NPC-004 identity and service ownership, MOVE-023 reservations, QUEST-008 giver context, QUEST-009 click ownership and QUEST-013 placement. Exact selector policies, replacement eligibility, actor availability reasons, and save schemas remain open.
