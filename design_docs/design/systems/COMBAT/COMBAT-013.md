# COMBAT-013 — Player damage intake and death handoff

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Deliver resolved player damage consistently, preserving source identity, once-only health mutation and authoritative prevention/death outcomes. Show injury feedback only from settled actual health loss. Optional player pain voices are available in settings and off by default; presentation cannot decide whether damage/death occurs.

## Confirmed requirements

COMBAT-013-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record three interviews. The complete specification is approved under COMBAT-013-A01. CHAR-018/023 already govern health/prevention/death; MOVE-010 owns fall calculation and COMBAT-010/011 own physical resolution/effects. This feature coordinates intake rather than reapproving those formulas or death presentation.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete prefab receiver bindings and runtime/classic parity remain unverified. Source unchanged. Paths below are relative to reference `Assets/Scripts/`.

- `Game/EnemyAttack.cs#SendDamageToPlayer` sends string-named RemoveHealth to PlayerObject, then selects weapon/weaponless sound messages from current enemy equipment. Its mutable damage field and deferred guard response need explicit captured context, not repeated lookup at eventual delivery.
- `Game/PlayerHealth.cs#RemoveHealth` flashes ShowPlayerDamage before PlayerEntity.DecreaseHealth. `ApplyPlayerFallDamage` locally computes trunc(5×(distance−5)) and calls RemoveHealth. Target uses approved MOVE-010 validated landing outcome instead of adding a second fall formula at intake.
- `Game/PlayerFootsteps.cs#RemoveHealth` receives the same message for optional 40% race/gender pain sound, using supplied amount against MaxHealth/4 and presentation pitch variation. Presentation being a separate receiver is useful evidence but the string message does not provide typed intake/result or exactly-once semantics.
- `Game/Entities/PlayerEntity.cs#SetHealth` participates in lethal prevention/health state. Its intended corrected once-per-event prevention and final death flow are already specified in CHAR-023; source death/god-mode details are not new approvals here.

## Detailed rules and behaviors

### Shared intake and source boundaries

Enemy attacks, released projectiles, magical damage and hazards use one explicit player-health intake contract carrying resolved amount, damage type, source/provenance, operation identity and current session/character. This is not a universal attack resolver: each source owns admission, mitigation/formulas, contact and additional effects.

Apply the already-resolved amount without rerunning accuracy, armor, resistance or damage formulas. CHAR's applicable intake/prevention policies still run. A fall does not gain weapon poison/wear/practice from sharing health mutation; magic retains its resistance/type policy; physical attack phases and projectile snapshots remain COMBAT-010/011/009-owned. No new generic damage reduction or immunity is introduced.

Retain original responsible actor/item/projectile or hazard identity even if scene source disappears. Valid committed damage must not depend on a live scene object. Never bind attribution to a replacement/reused actor or newly equipped item. Optional absent attribution differs from missing required formula/application data, which fails explicitly. LAW/QUEST and other owners consume truthful stable source context rather than guessed blame.

### Validation and ordering

Validate current player/session, source authorization, operation identity, type and supported amount. A valid zero request returns a no-loss outcome without injury flash or lethal-prevention checks. Negative, nonfinite, overflowing or unsupported values fail validation rather than clamp into a harmless result or become healing. Healing is separate. CHAR-023 explicit lethal requests such as exhaustion remain their declared operations, not a zero-damage request reinterpreted as death.

Resolve incoming operations once in explicit authoritative order. Fully settle applicable prevention/final death before the next incoming operation proceeds. Do not merge distinct genuine hits into an aggregate that changes prevention opportunities or damage accounting. Exact simultaneous-source tie ordering remains CORE/COMBAT engineering work; callback arrival order alone is not a complete contract.

After confirmed death reject remaining ordinary damage and stale gameplay callbacks. If prevention leaves player alive and eligible, a later genuine hit can resolve normally under owner cooldown/charge rules. No new invulnerability window, damage grace period or automatic heal is introduced. Duplicate delivery of the same hit returns/reuses retained outcomes without rerolling prevention or consuming another benefit.

### Authoritative health, prevention and death

Use CHAR-018 saturating damage and CHAR-023 scoped lethal evaluation. Retain requested/resolved damage, actual health loss, prevention outcome and confirmed death distinctly under COMBAT-010. Never infer actual loss solely from an earlier health snapshot when prevention/restoration or earlier effects can intervene; CHAR intake must report its authoritative mutation/accounting.

Applicable prevention resolves once per lethal event in approved deterministic order with retained cost/outcome receipts. Only authoritative CHAR results establish survival/death. If prevention succeeds, preserve its valid positive survival health and resulting state; if none succeeds, commit death once and gate ordinary simulation/input before further damage.

CHAR-023/CORE-008 own initial unskippable death presentation, subsequent original death movie/menu handoff, failure-safe timers and cleanup. Intake publishes/returns the settled outcome and hands off without running a second death coordinator. Do not revive a confirmed-dead session, autosave, delete saves, auto-load or add a new death popup. Missing audio/flash/camera does not block confirmed death or safe handoff.

Required prevention/intake failure stops for explicit owner/CORE recovery, preserving completed state and unresolved obligations. A technical failure is not failed prevention, immunity, ordinary zero damage or permission to try another formula. No automatic reroll/whole-hit replay after partial mutation.

### Suspension, context and committed obligations

New ordinary damage stops while ordinary gameplay simulation is paused/loading/ineligible. Retain already-committed unfinished operation obligations for safe continuation; menu entry cannot erase a committed hit or generate a fresh attack. This is not a hidden general damage queue: only admitted committed work has a continuation identity.

Explicit rest/travel/scripted simulation may authorize damage through its declared owner contract and clock; paused UI alone is not such authorization. Reject old-session and already-dead-character callbacks. Native restoration assigns saved health without generating new damage/prevention/death events under CHAR-017. Exact safe continuation/publication boundaries during context changes remain CORE/domain integration work.

### Player feedback and settings

Ordinary player injury flash requires settled actual health loss. Respect applicable visual/accessibility preferences; disabled/missing presentation cannot suppress health or replay the hit. Zero-loss/prevented operations may use explicit source/owner feedback but do not automatically produce an injury flash. No new camera shake, forced movement or player knockback is introduced; COMBAT-012 keeps baseline player knockback off.

Provide a Player Pain Voices settings option, off by default. When enabled, eligible surviving injury may produce race/form-appropriate pain audio with 40% chance; heavy iff actual health loss >= one-quarter effective maximum health for the settled intake context. Use an exact fractional comparison with safe arithmetic, not accidental integer-floor threshold changes. Voice random draws/pitch variation are presentation-only and cannot alter gameplay RNG.

Source/type policies may suppress/replace feedback so one landing does not automatically play overlapping landing and duplicate pain sounds. MOVE-010 hard-landing feedback can qualify even when health damage rounds to zero; it remains separate from injury flash/pain admission. Lethal results use approved death audio/presentation rather than an extra surviving-pain response. Racial/form optional voice suppression remains its explicit owner policy.

The player pain option is not a change to NPC pain chance/settings or death audio configuration. Exact setting identity/UI and source sound mappings remain CORE/AV/CHAR integration; no additional default volume/pitch/flash-duration values are selected here. Feedback observes retained outcomes at most once, not a second RemoveHealth-style mutation receiver.

## Relevant formulas and parameters

Intake consumes supported upstream nonnegative resolved amount through CHAR saturating damage without second mitigation. Explicit zero is no loss/no lethal check. Health/prevention arithmetic remains CHAR-018/023; no new health formula is added.

Enabled surviving-player pain chance=40%; heavy iff 4L>=M, where L is authoritative actual health loss and M valid effective max health for the settled intake context. Player Pain Voices default=false. Use safe numeric comparison; max-health snapshot timing and source type mappings require implementation contracts. No universal resistance percentage, grace period, extra fall penalty or player knockback value is introduced.

## Required data

Operation/session/player identity; source actor/item/projectile/hazard provenance and required captured context; resolved amount/type/policy; admitted/committed/application phase; authoritative actual health loss/health/prevention/final-death outcome; retained random/source-cost receipts; simulation authorization; pending continuation/recovery status; feedback identity/preferences and presentation RNG. Durable identity cannot be a raw scene reference or mutable shared enemy damage field.

## Inputs, outputs and events

Inputs: validated source damage, current health/prevention context, explicit simulation eligibility, CHAR mutation/result and settings. Outputs: rejected/zero-loss/applied/prevented/confirmed-death result, truthful attribution, once-only optional injury feedback, required recovery or approved death handoff. Concrete APIs/signals remain unselected. Observers cannot rerun mitigation, health application or lethal evaluation.

## Cross-system interactions

CHAR-017 reconstruction, CHAR-018 pools, CHAR-022 exhaustion and CHAR-023 prevention/death; COMBAT-010/011 physical/effect phases; COMBAT-009 projectile source/current defender; COMBAT-012 feedback and no baseline player knockback; MOVE-010 hazards/fall outcome; MAGIC damage/resistance/payloads; NPC/LAW guard response and attribution; CORE lifecycle/settings/suspension/death-menu orchestration; AV/UI feedback; SAVE consistent health/operation state and MOD/DATA typed policy validation. Guard surrender decisions remain COMBAT-019/LAW scope, not redefined here.

## Edge cases and failure conditions

Verify zero/invalid amount, source removed before delivery, simultaneous distinct hits, duplicate delivery, multiple prevention sources, successive lethal hits after survival, partial prevention failure and stale callbacks after death/session replacement. Preserve genuine separate attempts without duplicating one event's benefits.

Verify paused gameplay versus explicitly authorized simulated damage, menu at committed-hit boundary, restore without fabricated damage, and feedback disabled/missing. Damage source removal does not change valid projectile damage, but missing required context cannot be fabricated. Deferred guard/player prompts must eventually submit captured validated context through their owner, not mutable later damage; their exact admission/deferral remains separate review.

Verify mixed physical/magical damage accounting, upstream resistance applied once, zero-health reconstruction, no-health-loss prevention and landing feedback at zero rounded damage. Presentation must distinguish source/type without universally running combat effects. Technical failure needs truthful recovery with no whole-operation replay.

## Configuration and balancing options

Player Pain Voices option off by default; applicable injury visual/accessibility preferences and explicit source feedback policies. Existing prevention benefits, source mitigation and mod hooks retain their own approved owners. No new generic invulnerability toggle, damage multiplier, active-session death bypass or universal sound rule is added. Exact schemas/provider order and numeric bounds remain engineering dependencies.

## Save/load considerations

Persist health and committed results through CHAR/SAVE, not by replaying intake. CHAR-023 blocks ordinary saves during unresolved lethal evaluation and confirmed death; preserve its pending owner obligations and no-death-reconstruction replay rules. Exact admission for other mid-intake operations needs coherent boundaries or retained completion facts so damage, prevention charge and attribution cannot repeat/disappear.

COMBAT-001 cancels unfinished attacks with committed results retained; COMBAT-009 restores flying/pending-impact arrows. Retained committed intake must reconcile these without applying both a restored projectile impact and a duplicate saved damage message. Application preferences remain independent of character saves; loading cannot restore a historical player pain-voice setting. Already-presented flash/pain audio is not replayed just by restoring health.

## Technical constraints

Target Godot 4.7.2. Use an explicit typed, scoped intake/result contract rather than string dispatch to arbitrary health/presentation receivers. Keep health/prevention mutation, attribution, death handoff and optional feedback distinct but coherently ordered. Retain operation identity/results and preserve source provenance after scene removal. Native health/prevention/pause/save and missing-resource fixtures require verification; no implementation or coding tasks are authorized.

## Acceptance criteria

1. Enemy/projectile/magic/hazard damage shares intake with explicit source/type/amount/identity while preserving source formulas and effect eligibility.
2. Intake does not double-apply accuracy/armor/resistance. Zero returns no loss/flash/lethal checks; malformed amounts fail instead of heal/clamp silently.
3. Distinct hits settle in declared order; duplicates cannot apply damage or prevention twice. Confirmed death rejects remaining ordinary damage; survival adds no new invulnerability.
4. Original source attribution survives disappearance and cannot attach to replacements; required missing data invokes explicit recovery.
5. CHAR prevention/final death remains authoritative; intake cannot start duplicate death sequences or depend on camera/audio/flash success.
6. New ordinary damage stops during suspension/loading; already-committed obligations survive safely and authorized simulated damage follows explicit owner contracts.
7. Injury flash requires actual health loss and respects preferences; zero-loss/prevention and independent landing feedback are not conflated.
8. Player Pain Voices is off by default; when enabled, eligible survivors use 40% chance and exact quarter-max heavy threshold with presentation-only randomness and source sound arbitration.
9. No default player knockback/camera shake or universal weapon effects are added. Optional feedback cannot mutate/replay health.
10. Native restore preserves health/committed obligations without replayed damage, lethal checks, charges, attribution or already-played feedback; pain preference remains application-owned.

## Contradiction review

Reviewed against approved CHAR-017/018/022/023, COMBAT-001/009–012, MOVE-010 and CORE suspension/load/death ownership plus inspected source/catalog/architecture. No direct contradiction identified. Zero intake is not a CHAR explicit lethal request; restore remains consequence-free. Actual-loss flash and optional player voices align with settled feedback while source landing sound may qualify independently. Player pain off-by-default is the confirmed scope and does not alter NPC/death audio. No-second-mitigation preserves upstream physical/magic/fall policies. Pending committed completion is distinct from authorizing new paused damage. Architecture proposals remain Proposed outside confirmed contracts.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: typed source/type adapters, simultaneous-operation order, authoritative actual-loss/max-health accounting, committed-pause continuation boundaries, optional attribution validation, source sound/setting mappings, prevention failure recovery and save/projectile deduplication fixtures. These cannot rerun mitigation, replay health/prevention from restore, enable player pain by default or replace approved death orchestration. COMBAT-014 and guard-surrender review remain separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-013-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented source adapters, ordering, accounting, suspension boundaries, feedback mappings and save/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
