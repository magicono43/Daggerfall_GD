# ITEM-013 — Condition loss and breakage

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Apply condition loss and resolve breakage/exhaustion once while preserving owner ordering, item identity and explicit retention/destruction policies.

## Intended player experience

Wear predictably reduces condition without free repairs or repeated break effects. Ordinary equipment can remain as a broken possession, while regular enchanted items/artifacts default to disappearance on break. Validated mods can change those outcomes without losing state or bypassing protected-item lifecycles.

## Confirmed requirements

- **ITEM-013-D01:** Separate checked wear, repair and charge-expenditure operations. Negative wear is not repair; wear cannot increase condition and excess wear stops at zero. Non-durable items require a supported profile, not automatic broken classification.
- **ITEM-013-D02:** Break feedback, cleanup and declared Breaks payloads occur once on first reaching zero. Further wear at zero does not repeat them. Authorized repair can permit a later genuine break transition.
- **ITEM-013-D03:** Ordinary physical equipment initially remains in inventory at zero, unequipped/unusable until authorized repair. Break retention/destruction is moddable through explicit profiles, not a universal global fate switch. Magic/consumable exhaustion may explicitly destroy. User proposed artifacts disappear entirely on break and noted vanilla magic-item destruction; concrete artifact and regular-magic defaults await focused confirmation.
- **ITEM-013-D04:** Regular enchanted items and artifacts default to destruction at zero condition, with explicit profiles allowed to retain broken items. Separate charge depletion causes destruction only if its profile declares it; depletion is not automatically physical breakage.
- **ITEM-013-D05:** Complete an already committed last-condition power, then source cleanup and declared Breaks payload once, followed by destruction/identity retirement where applicable. Earlier ordinary melee wear retains COMBAT-011 exclusion of later strike powers from the broken source.
- **ITEM-013-D06:** Quest-linked/protected items require explicit compatibility between protection and break/destruction policy. Generic artifact defaults cannot silently delete required quest state. Unsupported conflicts require validation/recovery, not invented indestructibility or discard.
- **ITEM-013-D07:** Retained broken ordinary equipment is repairable where its validated profile permits. Enchanted/artifact repair needs an explicit supported profile; retention alone grants no repair permission. Repair cannot resurrect destroyed identity or restore spent charges without separate authorization.
- **ITEM-013-D08:** Condition operations identify actual item/custody/source/operation context. Never damage a newly equipped replacement or omit required cleanup because caller omitted owner. Per-unit versus stack-wide condition is explicit; unsupported special-stack wear rejects.
- **ITEM-013-D09:** Show current/max condition and broken state where knowledge rules permit; one concise break notification per genuine transition. Inspection causes no wear/hidden-power disclosure. Configurable low-condition warnings do not change mechanics.
- **ITEM-013-D10:** Increased maximum condition never refills current condition automatically; supported decreases clamp current to new maximum. Removing durability or reducing its maximum to zero requires explicit transformation/migration policy, not silently manufactured breakage.
- **ITEM-013-D11:** A new break episode requires authorized restoration above zero after previous break/recovery completion. Repair/retry during unresolved break handling cannot reset once-only guards or farm Breaks payloads.
- **ITEM-013-D12:** Persist current/max condition, durability profile, break episode and completed cleanup/payload/destruction phases. Load preserves broken/destroyed outcomes without replay/repair/duplication. Missing profiles/incomplete technical settlement require explicit migration/recovery; unsupported pending saves explain temporary blocking.

User confirmed D01/D02 and D03 with: “3. Yes, but make sure this is moddable, and perhaps by default artifacts disappear entirely when they break, which magic items in the vanilla game generally are destroyed when they run out of condition.” See [the decision log](../../GAMEPLAY_DECISIONS.md). “Perhaps” is retained as a proposed default, not final approval of every artifact profile.

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”, resolving the default destruction choice while retaining explicit per-profile exceptions and protected-item compatibility.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

Fourth interview confirmed D10–D12 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Source relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`: `Game/Items/DaggerfallUnityItem.cs`.

- `LowerCondition` subtracts amount, clamps at zero, calls ItemBreaks and may remove from a supplied collection if AllowMagicRepairs is disabled. It can invoke break handling repeatedly at zero.
- `ItemBreaks` displays feedback, optionally unequips from supplied owner and dispatches Breaks via its effect manager; no owner returns before payload dispatch.
- `UnequipItem` scans owner slots and updates armor. Optional owner/collection arguments make call context important rather than establishing a complete destruction policy.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; source unchanged.

## Existing approved constraints

RULE-016 owns physical-hit wear routing/formula/retained random results. COMBAT-011/MAGIC-016 own ordinary wear versus strike-power order, last-condition committed payload completion and bounded once-only break payloads. ITEM-010–012 own complete equipment cleanup/source contributions; ITEM-001–009 preserve custody/state/resources and explicit recovery. ITEM-014 will own repair jobs; this feature does not automatically authorize repair of every retained item.

## Detailed rules and behaviors

### Condition operations

Use explicit checked wear, repair, charge expenditure and authorized maximum/profile transformation operations. Wear amounts cannot be negative and cannot repair. Zero wear changes no condition or break state; excess valid wear saturates at zero. Invalid amounts, unsupported durability representation or missing required context fail explicitly before mutation. Non-durable items are not broken merely because no condition pool exists.

Identify the actual item, authoritative custody, source/cause and operation/session context. Do not retarget wear to currently equipped replacements or skip cleanup because the caller omitted an owner argument. Resolve required owner context through the operation contract; unavailable required context is technical recovery/failure, not permission for incomplete cleanup. Explicit profiles distinguish per-unit and stack-wide condition; unsupported special-stack mutation rejects rather than duplicating or losing resources.

RULE-016 remains the physical-hit routing/formula owner; COMBAT-011 owns phase integration. Reuse retained selected source and random wear results on retry. MAGIC-016/030 and other owners declare nonphysical condition costs; do not add ordinary wear a second time or turn charge expenditure into physical wear implicitly.

### Break episodes and ordering

A genuine transition from positive condition to zero creates one break episode. Record enough completion state to run required feedback, equipment/source cleanup and declared Breaks payloads once. Repeated wear at zero cannot create another episode, reward or payload; it reports an already-broken/no-change outcome as applicable. Owner removal spans complete multi-slot arrangements under ITEM-010–012.

For a valid power spending the last condition, complete its committed payload under MAGIC-016, then clean source-bound contributions and process declared Breaks once, then destroy/retire if the profile requires. Earlier ordinary physical wear breaking a live melee source still prevents later strike powers under COMBAT-011 while retaining the committed physical outcome. Released projectile/timed-effect exceptions keep their approved provenance/lifetime. No generic break callback can resurrect live-source eligibility or recurse without the approved bounds.

A new episode requires authorized restoration above zero after the prior break/recovery episode completes. Pending repair or retry cannot reset phase guards. Destroyed identities cannot be restored by a repair call. Concrete Breaks effect inventories and recursion bounds follow approved MAGIC/COMBAT profiles, not a new universal free spell.

### Retention, destruction and protection

Ordinary physical equipment initially remains in inventory at zero, unequipped and unusable until authorized repair. Regular enchanted items and artifacts initially destroy at zero condition. Explicit validated type/template profiles can override these defaults, including retaining broken magical items. This resolves the earlier proposed artifact default; it does not reintroduce a universal global setting controlling every item.

Separate charge depletion is not automatically physical breakage or destruction. Its resource profile declares the outcome. Consumable exhaustion/destruction similarly follows an explicit profile; possessing an enchantment or a visual effect is not permission to infer an unsupported resource model.

Destruction removes the item from authoritative custody and retires its identity after required committed phases. Preserve recovery facts and historical released-action attribution without retaining a usable duplicate. Destruction does not automatically authorize replacement loot, artifact respawn or reacquisition; those are separate content/QUEST profiles.

Quest-linked/protected items require explicit compatibility with break/destruction. Unsupported conflicts fail validation or require recovery; do not silently delete required quest state or grant indestructibility. Curse/removal policies under ITEM-011 must declare compatible forced-lifecycle behavior, rather than vetoing break cleanup through an ordinary cannot-unequip flag.

### Repair and maximum changes

Retained ordinary broken equipment may be repaired where its validated repairability profile permits. Magical/artifact repair needs explicit support; retention alone does not authorize it. ITEM-014 owns repair jobs/services and MAGIC owns applicable magical restoration. Restoring condition cannot refill separately spent charges or clear unrelated state unless separately authorized.

Increased maximum condition preserves current condition. Supported decreases clamp current to the new valid maximum. Removing durability or setting maximum zero needs explicit transformation/migration and lifecycle policy, not automatic break manufacture. Existing ITEM-003/004 compatibility rules prohibit silently rebasing/resetting items from changed definitions.

### Feedback and completion

Show current/maximum condition and broken status where knowledge rules permit, without revealing hidden enchantments/curses or their future fate. Provide one concise break notification per genuine episode; exact timing must respect the owner commitment/recovery boundary. Optional low-condition warnings are configurable and mechanically inert. Inspecting/previewing never wears, repairs or triggers Breaks.

Return explicit applied amount/current state/new-or-existing break episode/retention or destruction progress, or distinct rejected/recovery results. Notifications describe committed facts and cannot repeat mutations. Pre-admission rejection leaves state unchanged; a real partial technical commitment retains completed facts and remaining obligations rather than replaying the whole break or pretending nothing happened.

## Relevant formulas and parameters

For validated wear a >= 0 and current condition c >= 0, cNew = max(0, c − a), using checked arithmetic/saturation without intermediate overflow. A new episode requires c > 0 and cNew = 0. A supported positive maximum decrease mNew gives cNew = min(c, mNew); increase leaves c unchanged. No new physical-wear formula, repair price/rate, warning threshold, charge cost or Breaks payload magnitude is selected. RULE-016 and MAGIC/COMBAT source profiles retain their approved formulas.

## Required data

Stable item/custody/source/session/operation IDs; durability/resource profile/version; current/max condition and repairability; explicit retention/destruction/charge-exhaustion rules; quest/curse compatibility; break episode and completed payload/cleanup/destruction/feedback facts; relevant owner/released-action provenance and recovery. Exact schemas and numeric domains remain dependencies.

## Inputs, outputs and events

Inputs: owner-authorized wear/condition cost/repair/max-change request; retained wear result; required source/equipment context; profile/protection policy; native restore/recovery. Outputs: checked condition mutation, break episode/progress, retained broken or retired destroyed item, knowledge-safe feedback or explicit rejection/recovery. Pure inspection is not wear, repair or break. Concrete APIs/signals and receipts remain unselected.

## Cross-system interactions

RULE-016 owns physical wear; COMBAT-010/011 retain hit-phase/source-break ordering. MAGIC-016/030 own condition-cost/Breaks payload semantics and independently released effects. ITEM-001–012 preserve identity/custody/state, split resources, full equipment cleanup, source contributions and curse restrictions. ITEM-014 and ECON own repair/service settlement; QUEST validates protected resources. DATA/MOD validate profiles and SAVE/CORE reconstruct no-replay progress. Future repair/break content is not finalized automatically.

## Edge cases and failure conditions

- Negative wear cannot repair; zero/excess wear cannot generate repeated breaks or arithmetic wrap.
- Wear at zero: no repeated feedback/cleanup/payload/destruction.
- Item changed/equipped replacement or absent owner: no retarget or cleanup omission; explicit context validation/recovery.
- Last-condition spell versus ordinary melee wear: preserve the two distinct approved orderings.
- Retained magical item/zero charges: outcome follows explicit profile, not automatic repair or destruction.
- Quest/curse conflict: explicit validated lifecycle or recovery, no deletion/indestructibility fallback.
- Repair while break pending: no guard reset or payload farming.
- Changed maximum/profile: no free refill or silent new break; zero/no-durability migration explicit.
- Destroyed identity/history: no repair resurrection, duplicate item or automatic artifact respawn.

## Configuration and balancing options

Validated wear/repairability/durability and per-item retention/destruction/exhaustion profiles are moddable. Ordinary retention and enchanted/artifact destruction are defaults, not immutable policies. Warning thresholds may be configured separately from mechanics. No universal magic repair switch, artifact respawn, vanilla curse cure or destruction reward is introduced. Special profiles must remain compatible with source/cost/quest lifecycle contracts.

## Save/load considerations

Persist current/max condition, profile compatibility, episode and completed cleanup/payload/destruction facts. Loading preserves retained broken state or completed retirement without repairing, reissuing items, replaying Breaks or resetting episode guards. A saved zero condition is not a new break trigger.

Retain true partial technical progress for explicit recovery; unsupported pending saves are temporarily blocked with an explanation under existing ITEM/MAGIC/CORE rules. Missing required profiles/owners or changed fate/resource semantics need explicit migration/recovery, not generic retention/destruction fallback. New session context rejects old callbacks. Exact native migration/phase schemas and once-only feedback handling remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate wear calculation, authoritative condition/resource mutation, break lifecycle and presentation. Use stable original source/custody and episode facts rather than optional owner arguments or repeated zero checks as lifecycle authority. Checked numeric contracts and bounded owner payloads are required; no particular transaction framework is mandated. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Checked wear cannot repair or overflow; zero/no-durability semantics explicit and excess wear saturates at zero.
2. A positive-to-zero transition creates one episode; repeated zero wear cannot repeat cleanup/feedback/Breaks/destruction.
3. Ordinary equipment retains broken/unequipped/unusable by default; enchanted/artifacts destroy by default, with validated moddable exceptions and separate charge policies.
4. Committed last-condition payload completes before cleanup/Breaks/destruction; earlier ordinary melee break still excludes later strike powers.
5. Source/custody context targets the actual item and complete cleanup; unsupported special-stack condition rejects.
6. Quest/curse protections have explicit compatible break semantics without silent deletion, indestructibility or forced-lifecycle bypass.
7. Repair is explicitly authorized, cannot resurrect destroyed IDs/refill separate charges, and rearms only after prior episode completion and restoration above zero.
8. Maximum increases do not refill; supported decreases clamp; zero/no-durability changes need explicit migration/transformation.
9. Knowledge-safe display/warnings cause no wear or hidden-property disclosure; notification duplication cannot repeat mechanics.
10. Native restore/retry preserves state/phases/retirement without replay, repair, duplicate item or guard reset; missing profiles and unsupported pending saves use explicit recovery/admission.

## Contradiction review

Reviewed against approved ITEM-001–012, RULE-016, COMBAT-011 and MAGIC-016/030. No direct contradiction identified. Default enchanted/artifact destruction resolves a previously open ITEM fate policy while preserving explicit profiles and committed last-condition completion. Retained broken equipment does not grant universal repair. Source cleanup preserves independently released lifetimes. ITEM-011 curse and QUEST compatibility remain explicit; item retention/destruction does not invent artifact reacquisition. Concrete repair jobs remain ITEM-014 work.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: concrete durability/repairability/fate profiles and numeric bounds; per-unit/stack condition schemas; quest/curse/break compatibility; source cleanup/Breaks/feedback/retirement phase receipts and recursion bounds; max-change migrations; native recovery/guard and exploit fixtures. Material gameplay exceptions require explicit owner decisions before support is claimed. These cannot waive once-only break, committed payload ordering or possession/state preservation.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-013-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented durability/repairability/fate profiles, numeric/stack condition schemas, quest/curse compatibility, break phase receipts/bounds, maximum-change migrations and native recovery dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
