# FACT-003 — Propagated faction standing

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-003-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-003-interview-decisions).

## Gameplay purpose and intended experience

Let an action change how connected factions regard the player. A quest author can make a favor matter to one chapter or give it consequences across an organization and its political relationships. Imported quests preserve the reputation effects of their supported DFU behavior.

## Confirmed requirements

- New and modded effects default to direct standing. An author explicitly selects propagation when intended. Supported imported DFU effects retain their propagation intent and special guild and temple routes.
- DFU compatibility preserves ordered writes and clamps each write. New propagation policies sum signed contributions per faction and clamp once per faction.
- Use the authorized starting faction under FACT-001 and QUEST-019 and apply FACT-002's integer range and settlement semantics. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-003-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Actions/ChangeReputeWith.cs` requests propagation for the quest person's faction. `Game/Player/PersistentFactionData.cs#ChangeReputation` and `PropagateReputationChange` apply the following order.

1. For each of the three indexed slots, apply half the original amount to the ally and negative half to the enemy, ally first. These are direct writes. Integer division truncates toward zero.
2. For a knightly order, apply the full amount to the initiating faction and invoke propagation for Generic Knightly Order. DFU includes the generic order's descendants. The source identifies this as a difference from classic.
3. Otherwise, walk up the parent chain while the parent resolves and stop early at the Dark Brotherhood. If the selected node has children, visit that node and its descendants in child list order, depth first. Apply the full amount to the initiating faction, nodes with parent ID 0, and IDs in the designated questor set. Apply half to other nodes. The Dark Brotherhood walk stop alone does not grant the full amount. If the selected node has no child list, apply the full amount directly to the initiator.
4. If the selected node is a deity, invoke propagation for Generic Temple after the hierarchy writes. A generic invocation runs the same ordered policy from its own starting faction.

Repeated paths and repeated slots can produce several writes to one faction. These findings are from static inspection of the local source.

## Detailed rules and formulas

- The consequence declares a signed integer amount and the applicable policy. Resolve its starting faction from authorized context. A direct effect uses FACT-002. An imported propagation request uses the compatibility policy.
- The compatibility policy plans the ordered contributions above, including the supported questor set, slot order, and child order. Each contribution updates the working value using `clamp(current + contribution, -100, 100)`. Preserve repeated visits and contributions. Preserve empty legacy slots as absence under the adapter.
- A new propagation policy declares which routes contribute, their signed weights and rounding where applicable, how far traversal goes, and whether a repeated path represents an independent contribution. Each faction receives `clamp(previous + sum(contributions), -100, 100)`. Use arithmetic that can represent intermediate values safely. A policy defines its contribution rules independently of standing caps and traversal order.
- Example. At +98, ordered contributions of +5 and −5 produce +95 under compatibility. Summing the two contributions before clamping produces +98 under a new policy. In the compatibility policy, an amount of −3 gives an ally −1 and an enemy +1.

## Settlement and validation rules

- Evaluate one consequence against a coherent view of faction relationships and current standing. Validate its required targets and routes before committing. Publish the resulting standing together and return each affected faction's previous and final values and actual change. Notify standing observers once per faction whose final value differs. Compatibility still preserves intermediate clamping in the calculation.
- Keep a declared empty slot distinct from a missing required faction. Reject invalid hierarchy and recursive routing configurations that cannot terminate. An ordinary ally or enemy relationship cycle is valid under DATA-009 and the compatibility slot writes do not recurse through those relationships. Custom routes need a finite traversal rule.
- Treat a valid plan with zero final change as settled. A retained quest result is returned on retry, including when political relationships or standing have changed since settlement.

## Required data, inputs, outputs, and events

Use the authorized starting ID, signed amount, policy reference, validated parent and ordered child links, applicable directional relationships, and current standing. Compatibility also needs classic role mappings, slot order, faction classifications, and the questor set. Outputs include a settled per-faction result or an explicit failure. The consequence owner retains the result where retries are supported. Publish final changes after commitment.

## Cross-system interactions

FACT-001 supplies faction identity and hierarchy. FACT-002 supplies standing bounds and direct write semantics. DATA-009 supplies validated definitions and authored relationships. FACT-006 owns changes to political relationships. QUEST-019 authorizes and settles quest effects, and QUEST-022 restores their retained outcomes. NPC reactions and guild rules consume committed standing. LAW owns legal standing and authorizes any separate legal consequence.

## Edge cases and failure conditions

- A recipient can be both a hierarchy member and an ally. Compatibility preserves both contributions and their order. New policies count declared contributions and apply the combined result.
- A cap can reduce an intermediate write. Opposing contributions can cancel entirely in a new policy. Neither result leaves a valid consequence pending.
- A missing required route target or an invalid recursive route fails before any standing changes. Repeated valid routes remain possible under the selected policy.
- Two deliberately distinct quest effects follow QUEST-019's declared order and each settles under its own identity.

## Configuration and balancing

New content can select direct standing or a validated propagation policy. Author route scope and weights with attention to how many factions receive a change. The compatibility policy preserves the DFU fractions, routing, and write order. FACT-002 establishes the common cap.

## Save/load considerations

Persist resulting standing through FACT-002. For a settled quest consequence, retain its resolved starting target and settled recipient results under QUEST-019/022. Reload and retry use the retained result. Resolve required policy and faction references for unsettled work through applicable DATA and SAVE compatibility rules.

## Technical constraints and consistency review

Separate route planning from applying changes so failures leave coherent state and legacy ordering can be verified. Preserve stable IDs across definition reload and distinguish structural ancestry from directional political links. The draft follows FACT-001 target resolution, FACT-002 bounds and notifications, DATA-009 hierarchy and reference validation, and QUEST-019/022 consequence ordering and retry rules.

## Acceptance criteria

1. A new effect without a propagation policy changes only its authorized faction. An imported propagation effect uses the compatibility routes.
2. Compatibility reproduces ordered slot writes, truncation toward zero, subtree weights, and the knightly order, deity, and Dark Brotherhood cases. An overlapping +5 and −5 at +98 yields +95 in that order.
3. A new policy combining those contributions yields +98 regardless of evaluation order. An unchanged recipient emits no standing change event.
4. An invalid required reference or unbounded recursive route fails before any write. Ordinary directional relationship cycles work with finite route rules.
5. Reloading and retrying a settled quest consequence returns the recorded outcome without applying it again, including when the original outcome was zero or relationships later changed.

## Outstanding questions

Exact policy representation, baseline content verification, and save schema remain technical dependencies. The stock relationship update rules belong to FACT-006.
