# FACT-014 — Service routing and rank gates

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-014-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-014-interview-decisions).

## Gameplay purpose and intended experience

A guild representative shows the ordinary services they offer and explains why a locked service is unavailable. For example, an enchanter can show that the player needs Mages Guild rank 5. An explicitly secret service stays concealed until its discovery rule is satisfied. Players can trust that the service and terms they confirm belong to the provider they approached.

## Confirmed requirements

- Show ordinary services offered by the current representative, with a short reason when locked. Stock and modded services may explicitly hide their existence.
- Preserve DFU stock membership and rank gates as moddable defaults. Allow guild and variant overrides, including custom guilds. Use actual rank for stock service gates. Check the exact provider and applicable membership when opening the service and before payment or effects commit. Shortcuts and custom callbacks follow the same checks. Changed prices require renewed acceptance under RULE-021. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-014-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Guilds/Services.cs#GetService` maps NPC service identifiers to service kinds and supports custom mappings, handlers, labels, and shortcuts. `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#DoGuildService` checks `CanAccessService` when the player selects the service. It displays a member-only or insufficient-rank denial on failure. On success it dispatches a registered custom callback or the stock action. `Game/Guilds/Guild.cs` and its overrides own the service checks. The inspected route establishes an opening gate. Individual downstream transactions have their own behavior.

## Detailed rules and behaviors

1. Resolve the service through the authorized representative's declared mapping. Bind the exact provider, establishment or interaction context where applicable, guild and variant, and stable service ID. FACT-009 supplies the applicable membership set and exact membership or valid nonmember context. Use current committed rank after any due FACT-011 review.
2. Evaluate visibility and eligibility separately. Show an ordinary offered service even when its gate fails, with a brief reason appropriate to the player's context. Apply authored discovery rules before exposing a secret service or its requirements. An actor who does not offer the service has no route to it.
3. Evaluate the service's applicable membership, actual rank and other explicitly declared conditions. A service available to nonmembers uses the exact provider's nonmember policy. A membership in another variant grants no member access here. FACT-013's player-level substitution stays scoped to quest offer requirements. Passing the service gate for quests opens the offer flow, where QUEST-002 still evaluates the applicable audience and progression requirements.
4. Apply the same opening authorization through menu, shortcut, or custom route. Opening or inspecting the service has no payment or fulfillment effect. Before a consequential action commits, revalidate the bound provider, exact membership and current rank, and any other required context or entitlement. The service owner validates the proposed action and settles its transaction.
5. When eligibility is lost, reject the pending action without charging or granting its effect. When a refreshed final price changes and access still passes, present the new price and request renewed acceptance under RULE-021. A prior confirmation covers only the authorized action and terms.

## Stock defaults and approved integration rules

- Preserve stock access profiles from the service mapping and guild access methods. In the Mages Guild, buying spells is open to nonmembers, spellmaking requires membership, buying magic items requires rank 3, soul gems rank 4, enchanting rank 5, Daedra summoning rank 6, and guild teleport rank 8. Temple potion and spell gates use the deity's service profile. Verify the complete mapping and threshold inventory before implementation.
- For a given offered service, resolve an explicit variant override first, then the guild policy and its declared stock baseline. An unresolved required mapping or missing handler yields explicit unavailability. Custom service definitions register their route and entitlement policy together and use the same authorization and fulfillment boundaries.
- A shortcut cannot reveal or invoke a hidden service before discovery. For a visible locked service, menu and shortcut expose the same denial. A custom handler receives the checked context and must revalidate before a consequential commitment.

## Required data, inputs, outputs, and events

Use stable service, provider, guild, variant and membership set IDs, authorized provider mapping, committed membership and rank, visibility and access policies, and a stock or custom handler reference. Include applicable service terms and request identity when committing an action. Return available, visible but locked with a reason, hidden, or unavailable. Route successful openings to the owning service. Eligibility reads emit no payment, reward, or membership event.

## Formulas, configuration, and balancing

Stock minimum-rank gates pass at equality and use committed actual rank. Content can configure offered services, membership audiences, rank thresholds, additional supported conditions, and discovery rules. Keep entitlement separate from prices and transaction rules. FACT-015–017 own specialized benefits and their balancing parameters.

## Cross-system interactions

FACT-009/011 supply exact membership and rank. NPC and LOC supply authorized provider context. FACT-008 supplies regional condition facts when a service explicitly uses them. QUEST-002/FACT-013 own quest offer requirements. ECON and RULE-021 own trade pricing and renewed acceptance. CHAR, MAGIC, ITEM, TIME and other service owners validate and fulfill their actions. UI presents available routes and denials. DATA and MOD validate definitions, overrides and registrations.

## Edge cases and failure conditions

- An eligible Mages Guild customer can buy spells as a nonmember. A rank 4 member sees the ordinary enchanting route as locked. Higher character level does not unlock it.
- A member visiting a different deity's provider uses that provider's nonmember service policy.
- A provider change, rank loss, or newly applicable restriction can invalidate an open action. A denied action has no payment or fulfillment effects. A technical failure in a required route remains distinct from insufficient rank.
- Repeated confirmation follows the service owner's settlement rules and cannot duplicate an already committed effect.

## Save/load considerations

Restore durable service inputs through membership, discovery, and other applicable owners. Rebuild service routes from validated content. Any supported pending service action must revalidate provider, entitlement and terms before commitment after reload. Settled effects and obligations follow the service owner's save contract.

## Technical constraints and consistency review

Keep provider routing, visibility, entitlement, and fulfillment distinct. Use the same checks through all supported entry points. The draft preserves FACT-009's exact variant context, FACT-011's committed rank, FACT-013's quest-specific substitution, FACT-008's explicit regional restrictions, and RULE-021's quote revalidation.

## Acceptance criteria

1. An offered ordinary service is visible when locked and explains its gate. An explicitly hidden service is concealed and cannot be invoked through a shortcut.
2. Stock checks admit an eligible nonmember to spell buying and require actual rank 5 for enchanting. A variant override or validated custom guild rule changes only its applicable service context.
3. The same provider, membership, and gate checks apply to menus, shortcuts, and custom handlers. Missing required mappings or handlers return unavailability.
4. If access is lost before commitment, the action grants no effect and charges nothing. A changed price requires renewed acceptance.
5. Opening a quest service leaves offer eligibility to QUEST-002. Repeated settlement or reload does not repeat an already committed service effect.

## Outstanding questions

Complete stock service mapping verification, custom handler schema, and owner-specific continuation formats remain integration work.
