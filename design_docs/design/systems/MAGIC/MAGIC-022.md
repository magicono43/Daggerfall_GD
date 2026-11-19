# MAGIC-022 — Paralysis, silence and magical defense

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Resolve source-owned action restrictions and protections, including paralysis suppression, silence, damage Shield and elemental cancellation, with coherent cleanup and moddable policies.

## Intended player experience

Paralysis restricts voluntary actions without pausing hazards. Free Action prevents new paralysis and temporarily suppresses existing restrictions; uncured paralysis can return afterward. Silence has explicit casting scope, not blanket item shutdown. Shield spends a visible finite protection pool by default; elemental resistance supplies its declared cancellation chance. Mods may change supported action, shield and defense rules without source-loss or replay exploits.

## Confirmed requirements

MAGIC-022-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm source ownership, Free Action suppression/prevention and separate cure, silence scope, aging suppression/restriction transitions, physics, Shield coverage/capacity/recast/mod alternatives, additive elemental chance, binary statuses and persistence. The complete specification is approved under MAGIC-022-A01. D02 explicitly extends the original prevention-only recommendation to suppress existing paralysis without curing it.

COMBAT-001 weapon interruptions, MAGIC-003/004 casting restrictions/commitments, MAGIC-014 drinking allowance, MAGIC-016 item silence, MAGIC-009 source cleanup and RULE-017 saving order remain binding.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full status/physics/damage fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/`.

- `MagicAndEffects/Effects/Alteration/Paralyze.cs` and `Mysticism/Silence.cs` maintain status flags with duration-adding incumbent merges. Direct End flag clearing is not adopted as surviving-source aggregation.
- `Effects/Restoration/FreeAction.cs` sets paralysis-immunity flag; CureParalyzation ends a paralysis incumbent. Existing-paralysis suppression here is an explicit confirmed target rule, not claimed proven solely by those source classes.
- `Effects/Alteration/Shield.cs` stores starting/remaining pool, subtracts damage/returns overflow, and ends on depletion. Recasts extend duration and top up capped at starting capacity; source power calculation context requires fixture/owner verification.
- `Entities/DaggerfallEntity.cs#DecreaseHealth` passes damage through active Shield, commenting physical/magic/fall coverage. `RaiseResistanceChance` adds matching-element chance contributions. `Effects/Alteration/ElementalResistance.cs` provides element flag/chance, consumed by saving logic.

## Detailed rules and behaviors

### Contributions, admission and timing

Statuses/protections derive from valid surviving source contributions under MAGIC-009/CHAR-011. Removing one cannot clear another restriction, immunity or defense. Compatible recasts may extend under declared family policy; matching/source compatibility and power inventories must be explicit rather than universal flag mutation.

Admit paralysis/silence through MAGIC-006 applicability/hard immunity, applicable MAGIC-007 stages, on-cast chance then binary RULE-017 save. R=0 rejects, R>0 permits full duration. No default per-round escape save. Supported mod duration-scaling, escape checks and stacking require declared policy/identity/cadence. No rejected status startup or initial restriction before acceptance.

Hard paralysis immunity rejects new admission unless explicit specific exception; source race/career composition must be mapped under approved rules rather than a generic bypass-all flag. Free Action is a declared protection source, not automatic deletion of existing disease/poison or every control effect.

Use MAGIC-008 profile clocks/default rounds and no paused-wall catch-up. Constant state rebuild is idempotent, not another status application, aggro attempt or save roll.

### Paralysis and Free Action

Paralysis blocks voluntary locomotion and ordinary combat actions. Gravity, falling, external forces and environmental hazards continue; it is neither world pause nor invulnerability. Exact movement/interaction/physics masks must be integrated with MOVE; moddable action restrictions supported.

Potion drinking remains allowed by MAGIC-014 default, including while paralyzed. Spellcasting exceptions remain MAGIC-004's explicitly moddable start/interruption rules. Weapon cancellation/readiness remains COMBAT-001; this effect cannot queue a delayed attack behind restriction.

Free Action prevents new ordinary paralysis and suppresses restrictions from existing accepted paralysis without removing/curing its contribution. Suppressed paralysis ages normally, with no pause/refresh of its lifetime. Cure can remove it while suppressed. Explicit mod suppression/timing alternatives supported.

If Free Action ends while valid paralysis remains, immediately derive/reapply effective restriction and cancel unfinished actions under their approved rules. Preserve committed hits/projectiles/payment, do not undo past gameplay. If paralysis expired while suppressed, ending Free Action does not recreate it.

Gaining Free Action restores eligibility but does not resume canceled attack or automatically cast blocked spell. Require fresh applicable input. Cure Paralyzation removes all eligible active paralysis contributions without granting ongoing immunity. Combined prevention+cure spells or selective/modded cure policies must be explicit.

### Silence

Default silence blocks ordinary spell readiness/release and deliberate Cast When Used absent explicit silence bypass. Zero magicka cost alone grants no bypass. Preserve existing readied spell on failed use under MAGIC-003; no cost or automatic retry. MAGIC-004 release/interruption policy settles already-started casting without undoing released effects.

Potion drinking and existing continuous/automatic item effects retain prior defaults; a profile may explicitly require speech. Silence does not automatically mute dialogue, remove active spells or suppress every item. Broader validated restriction policies are moddable but cannot silently override mandatory source/death/content validity.

Multiple silence sources aggregate; expiry/cure/removal clears only selected source contribution. No implicit new silence cure spell is introduced by this framework.

### Shield coverage and damage accounting

Default Shield absorbs ordinary incoming health damage after applicable calculation/resistance but before health pool mutation and lethal prevention, covering physical, magical and fall damage. It does not intercept fatigue/magicka damage, arbitrary maximum-health changes or explicit lethal operations unless owner policy explicitly supports that case. Damage-type coverage moddable.

Let S be remaining protection and D valid eligible damage. Absorbed A=min(S,D); S'=S−A; overflow H=D−A. Route H onward to normal health/prevention intake; retain requested/resolved/absorbed/actual-health-loss distinctions. Fully absorbed hit has zero health loss, but earlier valid attack/poison/wear commitment under COMBAT contracts is not undone. Zero damage spends no Shield.

Store starting capacity and remaining points independently of duration. End default protection when depleted or expired; no automatic refill on pause/load. Capacity, depletion, overflow and refill behavior explicitly moddable through validated complete profiles. Alternative leak/regen/independent-shield models must specify safe domains/order/resource behavior; no guessed formula is approved.

Compatible recast extends duration and restores points by accepted incoming refill amount up to incumbent original starting capacity, without automatically raising that capacity. This is explicit family exception to duration-only extension. Stronger replacement/independent shields/alternate refill-capacity policies supported under MAGIC-009; initial/refill power context must be explicitly mapped, not silently substitute current recipient for caster.

Once-only intake ensures duplicate callbacks cannot consume Shield twice. Native restore and UI updates never reroll starting capacity/refill depleted points. Multiple sources/default incumbent compatibility and mod shield ordering require declared family schema, not arbitrary component enumeration.

### Elemental Resistance

Eligible surviving contributions add their declared cancellation chances for matching element. Clamp resolved chance to 0–100 and supply RULE-017's initial granted-elemental-resistance cancellation check. On failure continue remaining RULE-017 stages; do not run another duplicate check in admission/damage getters.

This is distinct from MAGIC-007 Spell Resistance. Use declared effect/element classification and source power context; compatible merges/independent sources must not be double-counted as both stored incumbent and absorbed contribution. Composition/scaling policies moddable; exact field inventory and current/captured chance context need owner mapping rather than implicit live recalculation.

Removing one source recomputes remaining chance/flag. Source absence, negative/unsupported/nonfinite values and missing classifications fail under owner validation rather than becoming unrelated immunity. Preview uses nonrandom truthful conditional chance and actual outcomes retain authorized draws.

### Feedback and transitions

HUD/details show effective versus Free-Action-suppressed paralysis, protection lifetime and Shield remaining/starting capacity where disclosed under MAGIC-010. Suppression is not cure. Expiry messages must reflect surviving sources, not falsely announce freedom while another paralysis remains.

Publish coherent restriction/protection changes before next gameplay action. No fresh attack/cast on unblocking, restoration or menu handoff. Optional feedback cannot interrupt a second time, roll defenses or change remaining Shield. Exact wording/layout and accessibility remain UI work.

## Relevant formulas and parameters

Default status save R=0 cancel/R>0 full duration, on-cast chance first. Shield A=min(S,D), S'=S−A, H=D−A. Compatible top-up S'=min(starting capacity,S+accepted refill). Elemental chance P=clamp(sum eligible source chances,0,100), checked once at RULE-017 stage. No new shield magnitude formula, escape interval, paralysis immunity table or universal action whitelist selected beyond confirmed rules.

## Required data

Status/protection/application/source/actor IDs; lifetime/timing/admission outcomes; effective/suppressed relationship and Free Action sources; action/silence permissions; Shield starting/remaining/depleted state, coverage/refill policy and committed intake results; elemental classifications/contribution chances/checks; source compatibility/order; native transition/recovery facts. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: accepted status/protection/cure, source expiry/removal, eligible damage, action attempt, current profiles and native restore. Outputs: coherent effective restrictions/immunity/suppression, scoped cure, Shield absorption/overflow, elemental cancellation or continuation, retained outcomes and truthful feedback. APIs/signals unselected. Cosmetic status display is not authority for movement or damage.

## Cross-system interactions

MOVE handles voluntary/forced motion and hazards; COMBAT-001/010 weapon interruptions/commitments; MAGIC-003/004 casting and MAGIC-014/016 item/potion exceptions. MAGIC-006/007 admission/interception, RULE-017 elemental/save stages, MAGIC-008 timing, MAGIC-009 source cleanup and MAGIC-010 native/HUD. CHAR/COMBAT intake owns health/prevention and stable actual loss; DATA/MOD validate policies and SAVE/CORE restore before input/simulation.

## Edge cases and failure conditions

- Paralysis active then Free Action: no cure, countdown continues; Free Action ending first restores restrictions without replayed actions.
- Multiple protections/status sources: remove one without clearing another; cure selects actual contributions.
- Paralyzed airborne/underwater actor: hazards/physics continue, default potion use preserved; no pause/invulnerability.
- Silenced free cast/item: obey independent source permission, no automatic bypass from cost/animation.
- Shield absorbs all versus partial lethal hit: preserve A/H/actual loss and once-only prevention ordering, no double mitigation.
- Shield top-up repeated/load: cap at original start under default, no accidental stronger shield/refill from rebuild.
- Elemental contributions overlap: sum eligible resolved sources once, one initial cancellation check, no Spell Resistance conflation.
- Restore suppressed status/depleted defense: same state, no free protection or resumed canceled attack.

## Configuration and balancing options

Validated suppression/action restrictions, cure combinations, silence scope/bypasses, status duration/save/escape models, Shield coverage/capacity/depletion/refill/order and elemental composition supported. Defaults remain explicit above. Mod alternatives require coherent safe profiles/permissions, not global bypass-everything flags. Individual power/context/immunity inventories and selector precedence remain owner design dependencies.

## Save/load considerations

Preserve all source status/protection contributions, suppressed paralysis remaining lifetime, Shield starting/remaining points, retained checks and declared power/profile state. Rebuild effective restrictions/protections before gameplay without refill, duration refresh, repeated interrupt callbacks or admission rerolls.

Fresh action input required; loading cannot resume canceled attacks or auto-cast blocked spells. MAGIC-008 profile migration/continuation and MAGIC-010 source linking/compatibility apply. Partial damage/cure/transition work uses coherent boundary or supported retained recovery, not double Shield spending/cleanup. Classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. Separate underlying paralysis from effective restriction and protection sources; separate damage amount/absorption/actual loss. Stable source/event IDs and coherent owner operations replace direct shared-flag clearing. Exact action masks, shield intake stage/adapters, profile schemas and native formats remain implementation work. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Surviving sources determine statuses/immunity/defense; no one-source cleanup erases another.
2. Free Action prevents new/suppresses existing paralysis with normal aging; cure removes eligible paralysis without immunity; restrictions return only if underlying effect remains.
3. Paralysis preserves forced physics/hazards and approved potion/casting exceptions; restriction changes never replay canceled actions.
4. Silence scope respects independent casting/item/potion rules, no cost-based bypass or automatic ongoing-effect removal.
5. Shield ordinary coverage/intake A/S/H/depletion/top-up works once with explicit mod alternatives and no load/rebuild refill.
6. Elemental sources compose/clamp once and feed correct RULE-017 stage independently of Spell Resistance.
7. Binary status admission/no default escape and explicit alternatives preserve retained results/accepted-only startup.
8. Native reconstruction/HUD retain suppression/resources/effective state coherently without interrupted-action or protection replay.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-003/004/006–010/014/016/017, RULE-017 and COMBAT-001/health intake boundaries plus MAGIC-022-D01–D12. No direct contradiction identified. Free Action suppression is explicit new target requirement beyond prevention-only source summary. Potion/casting exceptions remain separate from weapon restrictions. Shield reduces eligible health loss once without undoing earlier strike/poison/wear outcomes. Elemental cancellation occupies existing RULE-017 stage rather than duplicate defense. Mod shield alternatives do not silently change default or revive dead actors. Inventory/timing/action adapters remain dependencies rather than assumed tested integration.

## Outstanding questions

No further blocking control/defense player-policy choice is identified. Before implementation is complete: inventory status/immunity/element classifications and source power contexts; define MOVE action masks/forced physics integration, Shield typed intake ordering/compatibility/refill adapters, elemental source merge rules, mod selector schemas, HUD transitions and coherent native damage/cure state. These deferrals cannot authorize cured-versus-suppressed confusion, source flag loss, duplicate Shield spending, live power fallback or action replay.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: MAGIC-022-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented classification/power inventories, action masks, Shield intake/refill adapters, elemental composition, mod schemas and native transition/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
