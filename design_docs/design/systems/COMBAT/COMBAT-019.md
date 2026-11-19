# COMBAT-019 — Guard surrender during combat

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Offer a deliberate surrender choice during authorized guard enforcement, retaining the exact pending hit until its outcome is known. Accepted arrest replaces that hit; refusal/rejection resolves it once. Preserve later forced-surrender opportunities without failed requests damaging health, repeated prompt spam or mutable delayed damage.

## Confirmed requirements

COMBAT-019-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews. The complete specification is approved under COMBAT-019-A01. LAW owns enforcement episode/eligibility, arrest acceptance/reputation and court outcome. CHAR-023 remains authoritative for lethal prevention/death if damage proceeds; CORE/UI own scoped suspension and safe handoff.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime prompt/guard/save/classic parity unverified. Source unchanged. Paths relative to reference `Assets/Scripts/`.

- `Game/EnemyAttack.cs#ApplyDamageToPlayer` performs formula/strike processing before positive-damage City Watch offer. It lowers reputation, shows Yes/No and sets HaveShownSurrenderToGuardsDialogue. Later potentially fatal hits may call SurrenderToCityGuards(false) before SendDamageToPlayer.
- `SurrenderToGuardsDialogue_OnButtonClick` requests voluntary surrender on Yes; No calls SendDamageToPlayer using mutable instance damage. Target captures an operation, defers mutations and never consults a later shared damage value.
- `Game/Entities/PlayerEntity.cs#SurrenderToCityGuards` rejects already-zero health but sets health to 1 before some reputation/chance rejection checks. CourtWindow may transition outside, mark arrested and open court. Target changes health only after successful arrest commitment and leaves safe destination/court policy to LAW/CORE/MOVE.
- Source legal reputation thresholds/chances, reputation-loss timing and sentencing data are observations, not complete approvals through this combat feature.

## Detailed rules and behaviors

### Offer eligibility and pending-hit boundary

On first qualifying positive original resolved physical guard hit in an active enforcement episode, request surrender eligibility/offer from LAW before hit mutations. Guard identity/contact alone is not arrest authorization. Qualifying guard melee and arrows both apply; arrow uses captured responsible guard context from COMBAT-009, not later equipment/sensed target. Spell-trigger surrender requires explicit LAW/MAGIC policy.

Resolve and retain eligible numeric route/material/body-part/critical/hit/original physical result using approved rules, then stop before this hit's gameplay mutations. Original positive D0 qualifies even if later deferred strike modifiers would change pending physical damage. Do not run poison, wear, strike payloads/costs, physical health intake, reactive/racial gameplay effects or their mutation callbacks merely to decide prompt. Numeric evaluation must not secretly execute such side effects. Exact decomposition/phase identities require COMBAT-010/011 adapters.

Retain attack/component/source/target/session/episode identity, captured projectile context where applicable, resolved rolls/amounts and pending phase state. No delayed current enemy field lookup, reroll or silent new target. Already-completed unrelated attacks/incidents remain real; discarding the offered hit does not roll back prior world state.

### Prompt and suspension

At most one active surrender decision. Acquire owned gameplay suspension before presenting; ordinary attacks/projectiles/world simulation do not advance while decision pending. UI remains usable. Prompt requires explicit Yes/No; Escape/window-close cannot select implicitly. Opening/closing/context inputs are consumed under CORE/MOVE so they cannot also attack or act in another window.

Release only surrender-owned suspension after a coherent terminal outcome/handoff; other UI/readiness reasons remain. Acceptance transfers control to arrest/court coordination without a briefly resumed combat frame. Technical UI/presentation failure requires explicit recovery preserving pending hit/choice; never invent refusal/acceptance or let invisible pending decision resume unsafe gameplay.

### Yes, No and legitimate rejection

Yes requests voluntary arrest from LAW; clicking it alone is not committed success. Revalidate current session/living character and LAW episode/eligibility before publishing outcome. LAW owns acceptance/charges/reputation and safe court handoff requirements; no automatic reputation penalty merely from showing the prompt is introduced here.

Only successfully committed arrest/handoff discards the deferred hit and its pending damage/poison/wear/strikes/costs. Set living player health to 1 as the committed voluntary/forced arrest result; modded arrest-health policy may differ explicitly. Coordinate health and arrest state coherently so failed request/destination preparation cannot prematurely reduce health or silently delete pending hit. No weapon cost or kill/practice fact is fabricated for canceled pending application.

Explicit No or legitimate completed LAW rejection resolves retained hit once through normal COMBAT-010/011/013 phases, then returns control only when eligibility/other suspensions permit. This is continuation of the same operation, not a fresh roll. CHAR applies normal prevention/death if needed. Earlier source/target state changes require owner revalidation without rewriting retained results or charging replacement items.

Technical arrest/evaluation failure is not rejection/refusal. Retain pending operation and any already-resolved LAW decision/cost receipts for explicit recovery; do not consume another acceptance chance on retry, apply hit as fallback or undo partial committed arrest. Exact recoverable stages/cleanup remain LAW/CORE contracts.

### Episode frequency and forced surrender

Explicit refusal or legitimate rejection after Yes suppresses further ordinary offers for that enforcement episode. Episode identity/end/reset are LAW-owned; no permanent character-wide already-shown flag. New episode may offer again only under its policy, not by closing/recreating UI or saving/loading.

After refusal/rejection, a later qualifying guard hit with original resolved physical amount D0>=current player health requests LAW forced surrender before that hit's mutations. Equality qualifies. This criterion uses known original physical amount, not speculative later magical/strike lethality. LAW owns forced acceptance probability/reputation/other applicability; no source threshold/chance is adopted here.

Accepted forced arrest replaces that pending hit and commits health 1/handoff; legitimate rejection resolves normal phases and CHAR prevention/death. Each genuine later qualifying hit may evaluate under LAW's applicable policy; technical retry of same hit cannot reroll. Later damage made lethal only by deferred modifiers still follows ordinary CHAR prevention unless another explicit policy applies; do not invent a second forced check after partial mutation.

### Current-state validity, attribution and court ownership

Pending operation retains originating character/guard/episode and stable source even when source scene changes. Stale prompt/callback cannot affect another session, replacement guard or character. Context/session invalidation uses owner cancellation/recovery; it is not default No or automatic hit deletion. Exact obsolete-enforcement/source validity policy must be defined by LAW/COMBAT before implementation.

Court location, exterior transition, sentencing, fines, reputation consequences and restraint/control are LAW/CORE/MOVE owner work. Do not directly copy unsafe transition calls, teleport to arbitrary geometry, independently mark arrested or run a second court UI. Required placement/readiness must be validated for committed handoff. COMBAT-018 lawful facts/guard identity remain unchanged; guard conversion does not authorize arrest by itself.

## Relevant formulas and parameters

Ordinary offer requires qualifying LAW-authorized positive physical D0>0. Later forced trigger after refusal/rejection: D0>=current valid living player health before pending-hit mutations. Both use original retained physical amount, not combined separate magic or actual health loss, which does not exist yet.

Successful arrest sets health 1 for living character under valid positive CHAR maximum, with explicitly moddable arrest-health policy. Rejected/failed surrender does not set health at all before normal damage. No new prevention fraction, LAW acceptance chance, reputation threshold, guard count or sentencing formula is selected. At most one active decision and one resolved response per pending operation.

## Required data

Session/character/guard/attack/component/projectile/episode identity; qualifying enforcement authorization; retained original numeric rolls/damage and unapplied phase context; pending voluntary/forced decision/results; ordinary-offer suppression; LAW acceptance/cost/handoff stage; committed arrest/health receipt; owned suspension/save restriction; source/target validity and failure/recovery status. Mutable enemy.damage, UI object pointer or a global boolean is insufficient.

## Inputs, outputs and events

Inputs: qualifying resolved guard hit, LAW eligibility, explicit Yes/No, forced criterion, LAW decision/handoff preparation and context lifecycle. Outputs: owned prompt/suspension, pending hit, committed arrest/health result with hit discard, retained-hit continuation, episode suppression or explicit recovery. Concrete APIs/signals remain unselected. Prompt observers cannot apply hit or consume arrest chance independently.

## Cross-system interactions

LAW enforcement episode/voluntary-forced acceptance/court/reputation; COMBAT-018 guard identity/incidents; COMBAT-009 captured arrow attribution; COMBAT-010/011 numeric/mutation boundary; COMBAT-013 health intake and CHAR-023 prevention/death; CORE-015/016 scoped lifecycle/suspension, UI deliberate response, MOVE safe transitions and fresh input; SAVE pending-decision restriction; FACT benefits/legal reputation; DATA/MOD validated policies. No unreviewed LAW court behavior is approved wholesale.

## Edge cases and failure conditions

Verify several guards/projectiles reaching commitment, one active decision, duplicate Yes/No, Escape, focus/menu changes, source removal, changed character/episode and UI recreation. No queued second prompt, mutable damage replacement or unnoticed resumed frame. Exact admission tie/ordering follows authoritative COMBAT/CORE scheduler rather than arbitrary callback races.

Verify no/miss/zero/material-ineligible guard result, positive D0 later reduced to zero, refusal followed by exact-health lethal hit, legitimate forced rejection and subsequent CHAR prevention. Defer hit effects until decision; do not preserve source poison/wear side effects that should never have run on accepted arrest.

Verify arrest evaluation/handoff failure before/after partial mutation, invalid court geometry and persisted LAW costs. Failed request must not reduce health to 1; partial committed state uses explicit recovery, not pretend rollback or normal-combat fallback. Existing saves remain untouched. Other owned suspension reasons cannot be released by prompt cleanup.

## Configuration and balancing options

Moddable offer eligibility and arrest-health policy; LAW owns ordinary/forced acceptance/reputation/episode rules and spell-specific surrender policies. No new generic surrender key, lifetime one-off prompt, implicit dismissal, accepted-arrest damage or failed-request health penalty is added. Exact schema/provider precedence/numeric bounds and safe court dependencies remain owner contracts.

## Save/load considerations

Block ordinary saving while surrender decision, forced evaluation or arrest handoff is unresolved. Explain temporary restriction; do not drop/replay pending hit to permit saving. Existing saves remain unchanged. CHAR unresolved lethal/death save restrictions remain independent.

Lifecycle/load transitions cannot apply stale prompt responses to replacement sessions. Any owner-approved teardown must settle/clean pending work safely under CORE rather than leave orphaned UI/suspension. Once normal save is allowed, persist episode offer-suppression/arrest consequences through LAW, without reoffering or rerolling completed decisions simply on restore. Exact state schema/episode migration and invalidation cleanup are integration dependencies, not approval of serializing an unresolved prompt.

## Technical constraints

Target Godot 4.7.2. Represent one retained pending-hit/LAW operation with explicit numeric/application/arrest phases and scoped suspension/save restriction. Use stable identity and idempotent receipts across UI, damage and court owners. Do not read mutable shared damage, run gameplay mutations from prompt rendering or infer legitimate rejection from exceptions. Native simultaneous-hit/UI/handoff/failure tests required. No implementation or coding tasks are authorized.

## Acceptance criteria

1. First qualifying positive physical guard hit requests authorized episode offer before hit mutations; guard arrows use captured source and spells need explicit policy.
2. One prompt owns suspension and explicit Yes/No; other attacks freeze, dismissal cannot decide and cleanup releases only owned reasons.
3. Pending hit retains exact rolls/source/damage/phase and cannot mutate/reroll/duplicate while waiting.
4. Only committed arrest/handoff discards pending hit effects/costs and sets health 1; clicking Yes or failed/rejected request does neither.
5. No/legitimate rejection resolves same hit once through normal phases/CHAR prevention, not fresh formula/current enemy field.
6. Refusal/rejection suppresses ordinary offer for episode, while later D0>=health hits may request forced surrender under LAW; technical retries reuse decisions.
7. Forced acceptance replaces hit; rejection follows normal prevention/death with no failed-surrender health reduction or extra check after partial damage.
8. Technical UI/arrest/placement failure preserves operation for explicit recovery, without resumed combat, duplicated costs or false refusal.
9. Ordinary saves are blocked/explained until decision/handoff resolves; restore/invalidation cannot revive stale prompt/hit or reset episode suppression without LAW policy.
10. Court/reputation/sentencing and safe transition remain owner-authorized; no source-specific arbitrary teleport/global pause release is introduced.

## Contradiction review

Reviewed against approved COMBAT-009/010/011/013/015/018, CHAR-023 and CORE suspension/load/MOVE transition ownership plus source/catalog/architecture. No direct contradiction identified. Deferred pre-mutation hit is an explicit qualifying guard exception to immediate settlement, not replay of already-applied phases. Accepted arrest cancels pending application while keeping prior unrelated facts. Forced rejection still uses CHAR prevention/death. Health 1 only on success corrects source preacceptance mutation. Owned modal/save restriction preserves CORE/CHAR obligations without global pause clearing. Broader architecture proposals remain Proposed outside confirmed requirements.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: LAW episode/authorization/acceptance/reputation schemas; exact preoffer numeric-versus-mutation adapters; simultaneous-hit ordering; guard/source invalidation; arrest/court/placement commit boundaries; retained decision receipts; UI failure and teardown/save restriction fixtures. These cannot reroll pending hit, apply failed-arrest health penalty, silently dismiss prompt or import unapproved sentencing chances. Detailed LAW/court review remains separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-019-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented LAW episode/acceptance schemas, pending-hit boundaries, ordering, handoff, UI recovery and save-restriction dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
