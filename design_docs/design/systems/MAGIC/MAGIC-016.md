# MAGIC-016 — Enchanted item triggers

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Execute item powers through explicit equip/use/strike/periodic/unequip/break contracts with correct source lifetime, resource commitment and once-only restoration.

## Intended player experience

Item powers work consistently across player/NPC sources and custom payloads. Selecting an uncast power costs nothing; committed use consumes declared condition/charges even if later resisted. Multiple powers cannot overwrite readiness or bypass item exhaustion. Continuous benefits clean up by source, while released spells retain their own lifetime. Mods can configure timing, costs, permissions, potency and trigger policies.

## Confirmed requirements

MAGIC-016-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm explicit trigger contracts, default no-magicka/no-practice/history behavior, release commitment, ordered power groups, source-bound versus released lifetimes, ten-point Used/Strikes wear, grouped aim, bounded break handling, periodic/reroll policy, power context, silence and native restoration. The complete specification is approved under MAGIC-016-A01.

COMBAT-011 strike eligibility/phase/cost-source rules remain authoritative. MAGIC-015 retained enchantment payloads, MAGIC-009 source cleanup, MAGIC-008 timing and MAGIC-003/004 casting safeguards remain binding. Exact vanilla held-item wear/power inventories are dependencies, not guessed constants.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete enchantment/runtime failure fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/MagicAndEffects/`.

- `EntityEffectManager.cs#DoItemEnchantmentPayloads` iterates combined entries and dispatches Equipped, Held, Unequipped, Used, Strikes, Breaks, MagicRound and RerollEffect. Returned callbacks can modify physical damage or lower item condition. A missing template returns early rather than producing a complete typed result.
- `StartHeldItem` creates a stateful item-linked bundle; `UnequipHeldItem` removes relevant held contributions. Internal Held lifecycle flag is distinct from named CastWhenHeld power.
- `Effects/Enchanting/CastWhenUsed.cs` applies self spells directly or readies targeted classic spells for free; custom branch is TODO. `CastWhenStrikes.cs` applies a classic spell to struck target and also has a custom branch TODO. Both declare ten condition points per activation.
- `CastWhenHeld.cs` applies item-linked persistent spell, periodic wear and reroll behavior. It charges an equip-time value, skips some synthetic-time wear and uses global round counts. Exact native baseline schedules require verification rather than copying broad assumptions.

## Detailed rules and behaviors

### Explicit contracts and source context

Each power declares trigger/event predicate, valid source state, recipient/targeting, timing, resource model, potency context and cleanup. Supported custom retained payloads must work across applicable trigger types; no silent TODO branch with charged resources. Names alone do not define behavior.

Use stable item/power/event/actor/session identity. Source validity means the correct original item and required state, not the currently selected replacement item. Required provider/settings failures are explicit technical recovery, not ordinary no-effect success or fallback to another power.

Each power selects creation-fixed potency, wielder inputs captured at activation/release, or a declared live dependency. NPC use supplies its actual wielder context, never silent current-player skills. Retain released payload power/source attribution under MAGIC-005; continuous effects follow declared live/source rules. Exact vanilla context inventory must be verified.

### Casting permissions and timing

Default activated item spells cost zero caster magicka. Condition/charge costs are separate and may still apply. No default magic-school practice or recast-history replacement; explicit progression extensions require owner-valid once-only eligibility rather than treating item origin as ordinary spellcasting.

Default deliberate Cast When Used obeys silence. Existing continuous powers and automatic strike/periodic powers continue unless their profile explicitly requires speech. Silence bypass is separate permission; blocked activation spends no condition/charge. Chance, save, immunity and absorption/reflection permissions remain independent under MAGIC-006/007; zero magicka cost grants none automatically.

Manual item casting uses MAGIC-003/004 readiness, explicit wind-up/release/recovery and current eligibility. Do not infer timing from animation suppression. Selection/readiness/cancel before release costs nothing by default. Automatic/instant powers declare their actual commit marker rather than acquiring an implicit repeat-per-frame path.

### Multiple powers and grouped use

Powers triggered by one event execute in explicit stable order. Recheck source/resource/target eligibility after each earlier committed mutation. Keep prior committed results/costs when a later power fails; required technical failure uses retained-progress recovery without replaying the list.

One deliberate use retains eligible power group instead of repeatedly overwriting shared ready state. Targeted powers share captured release aim but retain their own target/admission/resource outcomes. Incompatible targeting combinations require a supported explicit profile or clear rejection; no guessed self/ranged conversion or effect loss.

Each power has its own commitment. Pre-release cancellation is free; already committed members cannot be undone by later invalid members. Exact group scheduling, mixed immediate/targeted power timing and presentation must be explicitly defined in profiles before support is claimed. A group is not permission for parallel uncontrolled resource races.

### Resource commitment and wear

Wear/charges commit with actual trigger gameplay, never merely selection/readiness. Technical preparation failure preserves resource without granting payload. Committed later miss/resistance remains paid. Use checked ITEM operations with stable original source; no charging another newly equipped item.

Default standard Used and Strikes powers cost ten condition points per committed power activation. Require full resource for declared cost unless explicit final-underfunded-break profile permits less. Condition and separate charge stores remain distinct. Validated alternative costs/charge models supported. Other trigger families declare their own wear; default ten is not automatically applied to every callback.

If valid payment spends last condition, finish that power's committed payload, then clean continuous contributions and run declared break event once before later ordinary powers. Broken/exhausted source stops later ordinary live-source work absent explicit profile. Break callback recursion must be bounded; no unlimited free casts from repeatedly reporting the same break. Item destruction/retention itself is ITEM-owned, not invented here.

Partial mutation failures retain known payment/delivery/break obligations for same-event recovery; do not blindly refund a live spell or reroll/re-execute a paid list. Exact preparation/commit receipts remain engineering scope, not a mandated generic transaction framework.

### Strike integration

Preserve COMBAT-011 default positive original resolved physical damage trigger, player/NPC parity, stable ordered strike phase after poison/ordinary wear and before primary physical damage. Distinguish D0/original physical amount, current Dp and separate magical effects. Power declares supported numeric basis and type; no unexplained combined damage bypasses resistance.

Ordinary wear breaking live melee source before strike phase prevents remaining strike powers; retain committed physical outcome. A last-condition enchantment payment during its own valid strike finishes that committed power, then applies break handling. These are different phase cases.

Cleave/multiple targets follow COMBAT-011 per-component/target accounting and explicit cost counting unit. Released arrows retain captured offense even if bow later breaks/disappears; charge-bearing payload must declare absent-original-source settlement. Do not charge replacement bow or recall projectile. This draft does not invent a universal once-per-swing cost or blanket projectile resource exception.

### Continuous/equip/unequip lifetime

Continuous equipped powers remain required-item-source bound. Equip activates valid source contributions once, unequip/break/source loss removes only those contributions once under MAGIC-009/CHAR-011. Other surviving sources remain; no transient modifier/capacity loss or free refill during coherent transitions.

A separately triggered timed spell follows declared released lifetime; unequipping does not universally erase it. Exact powers that genuinely require ongoing source remain explicit dependencies. Creating/looting/restoring an item is not a fresh use/strike/break event. Any equip reward/charge is a deliberate lifecycle event, not per-frame constant rebuild.

### Periodic events and rerolls

Profiles declare interval/clock, ordinary/rest/travel advancement, wear, affected properties and retained random outcomes under MAGIC-008. Default round system and supported real-time alternatives apply without silent catch-up loss. Exact vanilla held schedules/reroll intervals/equip costs remain verified-inventory work.

No per-frame reroll, load-time/offline wear or double generic-plus-family progression. Reroll changes only declared state, preserving unrelated effects/resources and retained commitments. Re-equip cannot silently reset cooldown, recharge or reroll unless explicit profile permits it. Supported randomness follows RULE-001/003; retries/restoration cannot replace already resolved results.

## Relevant formulas and parameters

Standard Used/Strikes default condition debit=10 per committed power under applicable event counting contract; full available resource required unless explicit exception. No caster magicka by default. Strike eligibility/basis follow COMBAT-011, not a new formula. No held wear/reroll interval, charge pool maximum, power scaling equation or group cooldown is guessed here.

## Required data

Stable source item/power/trigger/group/cast/target/session IDs; retained custom payload/version; explicit source state/potency/permissions; phase/order/D0 or Dp basis; selected aim/context; condition/charge cost and committed results; continuous contribution identity; periodic/reroll clock/phase/outcome; break progress; native recovery/compatibility. Exact schema remains dependencies.

## Inputs, outputs and events

Inputs: authoritative equip/use/strike/periodic/unequip/break/reroll event, current valid source/target/resource context and resolved profile. Outputs: rejected/unavailable power, ready group, committed payload/resource change, source cleanup/once-only break, retained partial recovery and optional feedback. Concrete APIs/signals unselected. Observer notifications cannot independently repeat callbacks or damage/resource changes.

## Cross-system interactions

COMBAT-011 owns strike phases/triggers/breakage/projectile exceptions; MAGIC-015 attaches retained payloads; MAGIC-003/004 manual readiness/commit/recovery; MAGIC-005/006/007 target/admission/defenses; MAGIC-008 clocks and MAGIC-009/010 contribution/restore. ITEM owns wear/charges/equipment/original identity. CHAR handles actual resource/modifier/progression effects. DATA/MOD validate profiles; UI routes deliberate stable requests; SAVE/CORE-013 restore coherent state before gameplay.

## Edge cases and failure conditions

- Multiple targeted entries: retained explicit group, no ready-slot overwrite or silent omitted power.
- Earlier power breaks/exhausts source: finish committed result, once-only break/cleanup, stop later ordinary live-source work.
- Earlier ordinary melee wear breaks source: strike powers do not execute; released-arrow exception retains its original contract.
- Silence/manual versus automatic: default used blocked/free of cost; existing continuous/automatic unaffected unless declared speech rule.
- Uncast canceled power: no wear/charge. Paid projectile misses/resists: resource remains spent, no ordinary refund.
- Unequip continuous plus released buff: clear only source-bound state, preserve timed spell per policy.
- Reroll/re-equip/load: no fresh random result/resource reset/duplicate callback unless genuine permitted event.
- NPC use/custom payload: explicit own context and fully implemented supported bundle, not TODO/free partial success.

## Configuration and balancing options

Validated trigger eligibility/order/grouping, source state, timing, wear/charges, power context, silence/defense permissions, periodic/reroll rules, bounded break payloads and explicit progression are moddable. Profiles must declare complete counting/reset/commit/cleanup contracts. Default no caster magicka and ten Used/Strikes wear remain stated policies. Broad moddability does not override finite reflection, source identity or COMBAT-011 phase safety implicitly.

## Save/load considerations

Preserve item resources, continuous contributions, cooldowns/reroll phase and retained outcomes, committed triggers/break progress and released delivery context. Native load cancels unfinished manual wind-up without spend/auto-release; restore valid item readiness with fresh input. Retain committed recovery/delivery rather than recasting or recharging.

Reconstruct equipped continuous state without equip fees/rewards, initial payloads, break callbacks or rerolls. Required source/provider incompatibility follows CORE-013 recovery. Save coherently or retain explicitly supported partial operation facts; unsupported transitions use explained safe-boundary admission. MAGIC-008 timing migrations and MAGIC-010 state contracts apply. Classic/DFU save import outside scope.

## Technical constraints

Target Godot v4.7.2. Explicit item/event/power identity and phases replace implicit shared callbacks/current-item references. Retain per-power outcomes and scalable custom payload/group data without fixed legacy indexes. Exact API, group scheduler, bounded break semantics, ITEM commit contracts and native schema require implementation design. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. All supported trigger families declare complete eligibility/source/timing/cost/cleanup and custom payload support; missing branch fails explicitly without spend.
2. Default item magicka/practice/history/silence behavior follows origin/permissions, not animation/free flags.
3. Selection/uncast cancellation does not wear; committed Used/Strikes cost ten by default and full resource checks/declared exceptions work once.
4. Same-event powers execute stable order with revalidation and explicit grouping/aim, never overwriting readiness or undoing prior commits.
5. Last-condition valid power completes, then cleanup/bounded break before later powers; COMBAT-011 earlier-wear break/projectile distinctions hold.
6. Continuous state cleans by source without removing released timed spells or other sources; restore never replays equip rewards.
7. Periodic/reroll profiles use declared clocks/retained RNG and preserve unrelated state without reset exploits or load-time wear.
8. Native resources/readiness/recovery/trigger state restore without duplicate costs/payloads/break/reroll/history/practice.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved COMBAT-011, MAGIC-003–010/015 and recorded MAGIC-016-D01–D12. No direct contradiction identified. Explicit item resource replaces caster magicka without granting silence immunity or ordinary practice/history. Last-condition payload completion differs from prior physical-wear source loss and preserves COMBAT phase order. Continuous source cleanup follows MAGIC-009; periodic progression follows MAGIC-008. Custom payloads fulfill MAGIC-015 rather than adopting source TODO omissions. Exact vanilla lifecycle costs/group profiles remain documented dependencies, not assumed completed implementation.

## Outstanding questions

No further blocking trigger-framework player-policy choice is identified. Before implementation is complete: verify per-power trigger/potency/held-wear/reroll inventories; define group targeting/timing and numeric D0/Dp effect schemas, charge-bearing projectile original-source settlement, break bounds and source cleanup; specify mod selectors/permissions/commit receipts, native partial snapshots and migrations. These deferrals cannot authorize free TODO effects, ready-slot loss, charge/reset exploits, duplicate triggers or silent item-source substitution.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: MAGIC-016-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented power/wear inventories, grouped timing/targeting, item resource/cleanup contracts, mod schemas and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
