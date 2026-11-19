# ITEM-012 — Armor and enchantment lifecycle

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Maintain protection and item powers from committed equipment without duplicate contributions, stale cleanup or replayed effects.

## Intended player experience

Equipment protection and passive powers consistently match the committed arrangement. Replacing or losing one item removes only its relevant benefits. Refreshing, retrying or loading cannot accumulate armor, restore dispelled powers or grant free charges.

## Confirmed requirements

- **ITEM-012-D01:** Track protection by stable item source and derive effective body-part protection from committed equipment. Repeated notifications/refresh cannot accumulate armor bonuses; removing one source cannot remove another contribution. Protection formulas remain separately governed.
- **ITEM-012-D02:** Coordinate equipment bindings, armor contributions and continuous-power changes before dependent gameplay observes the result. Failed admission changes nothing; actual partial technical commitment retains completed facts for recovery, not whole-transition replay.
- **ITEM-012-D03:** Genuine equip activates valid source-bound powers once; unequip/break/expiry/source loss removes only those source-bound contributions. Independently released timed spells/projectiles retain approved lifetimes. Refresh/load is not fresh equip; preserve dispel suppression.
- **ITEM-012-D04:** Explicit profiles declare protected body parts and contributions, supporting validated mod armor/shields/clothing. Do not infer coverage from appearance or slot names. Approved combat formulas remain binding; unresolved baseline values require separate verification.
- **ITEM-012-D05:** Explicit composition rules govern overlapping armor/shield/magic protection. Multi-slot occupancy cannot double-count one contribution. Additional coverage/items do not implicitly choose additive/replacement/strongest-value semantics.
- **ITEM-012-D06:** Authorized material/enchantment/condition-dependent property/eligibility changes update affected contributions without simulated unequip/re-equip. Refresh cannot reset cooldowns, suppression, rewards or resources.
- **ITEM-012-D07:** Ordinary protection and valid continuous equipped powers activate at equipment commitment, independently of attack preparation. Drawn/selected/ready-source power requirements must be explicitly declared; COMBAT preparation remains binding for attacks.
- **ITEM-012-D08:** Suppression identifies source item and affected power/contribution. Dispel cannot remove unrelated protection/powers unless approved policy includes them. Reactivation follows MAGIC-027, normally a genuine unequip/equip cycle, not refresh/load/unrelated property change.
- **ITEM-012-D09:** Persist authoritative bindings, relevant contribution state, suppression, resources and completed lifecycle phases. Rebuild derived protection coherently before gameplay. No load reroll/recharge/equip-or-break replay; missing required source/provider needs explicit migration/recovery rather than silent contribution loss.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/DaggerfallEntity.cs#UpdateEquippedArmorValues` incrementally subtracts/adds material armor value ×5 for eligible armor/clothing body parts; shields apply their declared protected-body-part values, treating shield protection as material-independent in this path.
- `Game/Items/ItemEquipTable.cs#StartEquippedItem` dispatches Equipped/Held payloads through the actor's effect manager; `StopEquippedItem` dispatches Unequipped. The list-taking unequip wrapper can dispatch cleanup again after the slot overload.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; reference source unchanged.

## Existing approved constraints

ITEM-010/011 own complete equipment planning, restrictions and no-op/restore behavior. ITEM-001–009 preserve identity/state/custody/resources. MAGIC-016 owns source-bound continuous and independently released lifetimes, once-only costs/break phases and no-replay reconstruction. MAGIC-027 retains item dispel suppression until declared reactivation. CHAR/MAGIC own modifier composition; COMBAT owns protection consumption/attack ordering. This feature does not automatically adopt every reference protection constant.

## Detailed rules and behaviors

### Protection and source identity

Represent each protection contribution with stable owning item and applicable body-part/profile context. Derive effective protection from committed equipment and approved owner composition rather than repeatedly modifying a total on refresh. Duplicate notifications/rebuilds cannot accumulate bonuses; removing a source clears only its contributions. Multi-slot reservation is not multiple copies of a protection source.

Validated armor, shield and clothing profiles declare covered body parts, contribution interpretation and supported material/state dependencies. Appearance or slot name alone cannot establish coverage. Added content requires complete compatible profile mappings. Exact baseline body-part values and overlap rules remain explicit dependencies, not automatic adoption of the source ×5 arithmetic or signed-byte storage.

Overlapping physical armor/shield/magical contributions require explicit composition. This feature does not choose additive, replacement or strongest-value semantics universally. Preserve already approved COMBAT/RULE protection consumption and source-owned CHAR/MAGIC modifiers. Condition-dependent protection applies only under a declared rule; wear alone does not invent a universal degradation curve.

### Coherent equipment lifecycle

ITEM-010/011 validate the full equipment/restriction plan before changes. Coordinate bindings, protection and continuous powers before dependent gameplay observes the result. Admission rejection leaves the old arrangement/contributions/preparation intact. A genuine technical partial commitment records completed phases and recovery obligations, without presenting it as completed equip or blindly replaying the transition.

At genuine equip commitment, ordinary protection and valid continuous equipped powers activate once. Attack preparation remains separate under COMBAT-002. A specific power may explicitly require drawn, selected or ready state; do not infer that requirement from its visual representation or delay all passive protection until a weapon is ready.

Unequip, break, expiry or source loss removes only the applicable source-bound contributions once through approved owner ordering. Item retention/destruction and restrictions follow ITEM owners; ongoing powers and independently released effects follow MAGIC. Refresh, repeated equip/no-op, scene rebuild and native reconstruction are not new equip events. Removing one source cannot clear another surviving source.

MAGIC-016/COMBAT-011 retain last-condition committed-payload completion and once-only break rules. Released timed spells/projectiles retain declared lifetimes independently of live source, unless an explicit power contract says otherwise. No blanket cancel-all-effects rule applies when equipment disappears.

### Equipped-state changes and suppression

Authorized changes to material, enchantments, condition-dependent properties or eligibility update affected derived contributions coherently, preserving unrelated state. Do not simulate unequip/equip to refresh. No cooldown/resource reset, reward replay, free refill, expiry restart or implicit suppression reactivation.

Track suppression by source item and affected power/contribution under MAGIC-027. Dispel removes only eligible scoped state; it neither destroys/disenchants the item nor strips unrelated ordinary armor or another power unless an explicit approved policy includes them. Suppressed continuous powers remain suppressed through refresh/load/recreation. Default reactivation is a genuine unequip/equip cycle under MAGIC-027; other supported reactivation policies must be explicit. Later genuine use/recast follows the applicable approved power rules, not a universal suppression reset.

### Completion and observers

Lifecycle requests/results carry actor/item/power/session/operation identity and completed phases as needed to prevent duplicate activation/cleanup. Delayed work revalidates source and current session; matching item IDs alone do not authorize an old callback. Observer notifications report committed facts and cannot independently rerun protection mutation, use payloads or break events. Exact receipt and failure recovery APIs remain design dependencies; no generalized transaction framework is mandated.

## Relevant formulas and parameters

Effective body-part protection = the approved owner composition of valid active source contributions for that body part. This is a responsibility boundary, not a selected arithmetic formula. No new material armor table, shield coverage/value, clothing bonus, condition scaling, overlap operation, mitigation formula or timing constant is approved here. Attack preparation follows COMBAT-002; power costs/lifetimes/break ordering remain MAGIC-016 and relevant COMBAT contracts.

## Required data

Stable actor/item/power/contribution/profile/body-part/session identities; committed bindings; explicit coverage/material/state inputs and composition policies; source lifetime/eligibility conditions; scoped suppression/reactivation state; resources/timers/retained outcomes; lifecycle operation and completed-phase/recovery facts; compatibility/provider versions. Exact schemas and derived-versus-stored field choices remain dependencies.

## Inputs, outputs and events

Inputs: admitted equip/unequip/source-loss transitions; authorized equipped-state changes; owner dispel/reactivation; readiness/context changes for explicitly conditional powers; native restore and recovery. Outputs: coherent active contributions/effective protection, scoped source cleanup/suppression, committed lifecycle results or explicit recovery/errors. Pure queries and display refresh cause no activation/cost/reward. Concrete APIs/signals remain unselected.

## Cross-system interactions

ITEM-010/011 own bindings/restrictions; ITEM-013/024 govern break/expiry; ITEM-001–009 preserve identity/custody/state/resources. MAGIC-009/010/016 own source composition/persistence and continuous/released power lifecycle; MAGIC-027 owns dispel suppression. CHAR owns resulting actor modifiers/resources and COMBAT/RULE consume protection with established attack/break ordering. DATA/MOD validate profiles/providers. UI displays committed known state under ITEM-011/019; SAVE/CORE reconstruct coherently before gameplay. Future ITEM features are not finalized here.

## Edge cases and failure conditions

- Duplicate equip/cleanup notification: same effective protection and no repeated payload/resource effects.
- Multi-slot item or overlapping coverage: no duplicate source contribution; composition explicit.
- One of several sources removed: surviving source contributions remain.
- Weapon not attack-ready: ordinary committed passive protection active; explicitly conditional powers evaluate their declared conditions.
- Property refresh on suppressed power: suppression remains, no synthetic equip cycle.
- Last-condition power breaks source: preserve committed payload then owner-ordered cleanup/break, not premature cancellation or repeated break.
- Released projectile/timed buff outlives item: follow its approved lifetime, not blanket source cleanup.
- Missing required provider or partial transition: explicit recovery, no silent contribution omission or whole-operation replay.

## Configuration and balancing options

Validated contribution/coverage/composition profiles, conditional activation and scoped suppression/reactivation are extensible through owner contracts. No universal additive stacking, readiness delay for passives, condition penalty or material-independent shield target rule is adopted solely from reference code. Concrete baseline/mod profiles must resolve required arithmetic and compatibility before support is claimed.

## Save/load considerations

Persist authoritative bindings and required source/contribution/suppression/resources/timing/resolved outcomes and completed phases. Rebuild derived protection and continuous state coherently before gameplay, preserving source identity and active suppression. Do not apply saved derived totals and add the same contributions again.

Load cannot reroll, recharge, replay equip/rewards/break, restart lifetime or treat reconstruction as genuine reactivation. Independently released effects restore through their owner without recasting. Missing/incompatible required sources/providers require explicit migration/recovery under CORE-013/DATA/ITEM/MAGIC, not silent loss or generic fallback. Coherent or explicitly supported partial save boundaries retain true progress; unsupported transitions use explained safe-boundary restrictions under existing contracts. Old-session callbacks cannot mutate restored sources.

## Technical constraints

Target Godot 4.7.2. Separate authoritative equipment, source contribution state, derived protection, power lifecycle and presentation. Stable identities and explicit owner phases replace repeated add/subtract callbacks or dependence on signed-byte legacy arrays. Native numeric/profile schemas must validate bounds and compatibility. No specific component/registry/transaction framework is mandated. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Derived protection matches committed source profiles without notification/refresh accumulation or multi-slot duplicate counting.
2. Removing one source preserves others; body coverage and overlap use explicit validated policies rather than appearance inference.
3. Equipment/protection/continuous powers become visible coherently; admission failure unchanged and partial technical commitment retains recovery facts.
4. Ordinary protection/passives activate at equip commitment, attack preparation remains separate and special readiness requirements are explicit.
5. Source-bound cleanup occurs once for unequip/break/expiry/loss; independently released effects retain approved lifetime and break ordering.
6. Authorized state changes update affected contributions without synthetic equip, cooldown reset, recharge or reward replay.
7. Suppression is source/power-scoped, preserves unrelated protection and survives refresh/load until declared genuine reactivation.
8. Native reconstruction preserves resources/outcomes/phases and avoids duplicate totals, rerolls or equip/break replay.
9. Required source/provider incompatibility and stale callbacks produce explicit recovery/rejection, not silent contribution loss or repeated mutation.

## Contradiction review

Reviewed against approved ITEM-001–011, MAGIC-016/027 and COMBAT-002/011 lifecycle boundaries. No direct contradiction identified. Source derivation does not select a new armor/mitigation formula. Coherent passive activation remains independent of attack preparation. Last-condition completion and independently released lifetime qualify source-loss cleanup exactly as approved. Suppression preserves MAGIC-027 behavior without arbitrary refresh reactivation. Detailed ITEM-013 break rules and concrete protection profiles remain owner dependencies.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: verified baseline body-part/material/shield/clothing values and overlap composition; custom contribution/state schemas and numeric domains; lifecycle ordering/commit/recovery receipts; readiness-conditional powers; suppression/reactivation mappings; native source/phases/migration fixtures. Concrete gameplay protection profiles require explicit owner decisions before support is claimed; these deferrals cannot waive coherent transitions, once-only contributions or suppression/lifetime preservation.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-012-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented baseline protection/composition profiles, contribution schemas, lifecycle ordering/recovery, conditional powers, suppression mappings and native migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
