# COMBAT-015 — Enemy attack cadence and animation commitment

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Make enemies initiate attacks at predictable, moddable cadence with readable wind-up and once-only commitment. Let movement/interruptions and target changes matter without delayed animation flags delivering stale hits. Preserve approved reflex coupling and independent released projectiles across pause/load/source loss.

## Confirmed requirements

COMBAT-015-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews. The complete specification is approved under COMBAT-015-A01. The concrete interval/opportunity policy below is melee-specific; it does not automatically define enemy bow/spell cooldown. COMBAT-016/017 and MAGIC retain detailed contact/ranged/casting admission.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths relative to reference `Assets/Scripts/`.

- `Game/EnemyAttack.cs#FixedUpdate` rejects DisableAI, paralysis and selected action-blocking one-shots; decreases MeleeTimer; floors live Speed at 8; sets FrameSpeedDivisor from permanent/live Speed; and tests a ClassicUpdate random gate before MeleeAnimation/ResetMeleeTimer.
- Gate is DFRandom.rand()%speed >= (speed>>3)+6. Source explicitly says comparison is reversed from classic. Target retains this inspected initiation relationship with unbiased owned selection, not a claim of DOS parity.
- `ResetMeleeTimer` draws inclusive 1500–3000, subtracts 50×(player level−10), adds 450×(reflex enum−2), clamps nonnegative and divides by 980. Timer begins on animation initiation rather than damage delivery.
- `Update` checks paralysis and consumes mobile.DoMeleeDamage/ShootArrow flags; its guard differs from initiation. `MeleeAnimation` checks sight/yaw/approach-adjusted distance. MeleeDamage can use later sensed target/current weapon and fall back to door bash. Target establishes explicit identity/lifecycle; COMBAT-016/017 must define contact/action purpose rather than copying mutable fallback behavior.
- `Game/EnemyMotor.cs` also uses MeleeTimer in touch/ranged selection paths. This is evidence for owner integration, not automatic approval of one cadence formula for all actions.

## Detailed rules and behaviors

### Intent, admission and captured state

NPC AI proposes an attack intent; COMBAT admits it only with current valid session/actor/source/action/target/readiness. Each admitted attack has identity, wind-up, commitment and recovery with one animation-synchronized gameplay marker. Crossing a skipped visual frame still reaches the marker; duplicate flags/callbacks cannot commit twice. Presentation alone never starts another hit.

Capture intended target stable identity at attack start. Revalidate at commitment through COMBAT-016/017, rather than silently retargeting to current AI selection mid-swing. Invalid/out-of-reach target may cause owner-defined miss/cancel; no undeclared replacement actor or door bash. AI can choose another target/action for the next attack. Exact melee sight/yaw/range and bow targeting remain next-feature decisions.

Capture source identity and start-time animation profile/timing using then-current Speed. Later Speed effects alter future attacks, not active wind-up/markers. Initial pacing may retain permanent-Speed/max(8,live-Speed) relationship, but resulting timing must remain valid positive and match authored animation. Modded profiles supported; exact divisor rounding/clamp/minimum and extreme Speed bounds require native contracts rather than copying unsafe integer division. This captures timing, not all melee damage stats; COMBAT-010 retains live per-component resolution, COMBAT-009/014 their released payload snapshots.

### Melee interval and opportunities

At actual admitted melee start draw one inclusive U in [1500,3000] and capture interval T=max(0,U−50×(player level−10)+Areflex)/980 eligible seconds. CHAR-010 supplies current character's fixed approved reflex adjustment (−900/−450/0/+450/+900 from Very High to Very Low). Parameters/policies are moddable. Player level/reflex used for this start do not recalculate that already-running interval later.

Begin interval at attack start, alongside wind-up/animation. Another attack requires both current attack finished and interval expired. Cancellation retains remaining value; do not reroll or restart full interval. Zero computed interval does not permit a second simultaneous attack, recursive same-marker start or bypass opportunity/admission.

On 0.0625 eligible-second opportunity ticks, otherwise-eligible melee actor with expired interval may test the Speed-based gate. Let S=max(8,validated live Speed), Q=floor(S/8)+6. Draw unbiased integer R from [0,S−1]; opportunity passes iff R>=Q. This preserves inspected DFU comparison without modulo bias. It is separate from accuracy/critical/natural-component reflex gates. Later opportunity checks use current valid Speed; admitted attack keeps captured timing.

When no valid target/action is available, keep expired interval and do not roll a new interval/store an attack request. Interval is drawn only for genuine admitted start. Exact order of final admission versus opportunity evaluation must be declared to ensure no technical duplicate consumes extra randomness. Use RULE-003 owned combat randomness and retain logical results for technical retry. Preview/animation refresh consumes none.

Opportunity ticks follow CORE-017 eligible simulation, not rendered frames. Slow rendering must not produce queued intent or simultaneous catch-up attack bursts. Exact bounded backlog scheduling retains approved ordering/workload constraints without adding unapproved zero-time attacks or silently discarding committed operations.

### Restrictions, clocks and interruption

Death, paralysis or explicit attack-disable/interrupt cancels unfinished enemy attack work immediately. It cannot resume when restriction clears. Preserve completed damage/effects/costs and independent released arrows/spells. Remaining natural components stop under COMBAT-010 validity/interruption rules.

Replacing/removing/breaking active weapon cancels unfinished work without substituting unarmed or another weapon. Keep current-target committed outcomes under COMBAT-004/010 where already in settlement; cancel later targets/components at their valid boundaries. Future attack may choose a new RULE-012 route. This is not approval of NPC equipment-changing behavior generally.

Explicit transformations, scripted incapacitation and declared action-blocking states prevent new starts. Ordinary animation playback is not a universal lock and cosmetic Hurt alone cannot cancel an active attack. Whether a declared blocking state also interrupts current attack must be explicitly represented as an interrupt policy, not inferred from visual one-shot playback.

Paralysis, explicit AI/attack disable, ordinary pause and loading freeze remaining interval. Ordinary pause freezes progressing attack state rather than canceling it. Ending paralysis/disable does not resume the canceled attack; when allowed, fresh AI decision/opportunity and remaining interval govern next attack.

Knockback alone lets interval progress but blocks new attack starts until knockback ends. Already-started attack can finish under COMBAT-012 unless a separate genuine interruption applies. Declared content-specific immunities/resistance remain NPC/MOD policies, not incidental animation branch precedence. Exact clocks for other action-blocking states require explicit owner classification before implementation.

### Commitment and recovery ownership

At commitment revalidate actor/source/target/action and use COMBAT-010 component resolution or COMBAT-017/MAGIC release operation. No local second damage formula, mutable later weapon lookup or direct animation-triggered health message. Commitment miss/gate failure and technical error remain distinct retained outcomes.

Completed impacts and released projectiles are not undone by later interruption. Remaining animation/recovery and melee interval are independent state: interval expiry alone cannot reset a still-active attack. Melee cancellation does not gain player bow's full-cooldown rule; enemy ranged recovery remains separate. Technical failures retain completed phases/random results and use explicit recovery without whole-attack reroll or silent replacement action.

## Relevant formulas and parameters

T=max(0,U−50×(L−10)+Areflex)/980 seconds, U uniform inclusive 1500–3000, L valid player level at start. At level 10/Average, initial interval spans 1500/980 to 3000/980 seconds. Higher level/reflex adjustments retain approved signs. Safe arithmetic and finite supported parameter ranges required.

Opportunity tick=0.0625 eligible seconds; S=max(8,live Speed); Q=floor(S/8)+6; pass R>=Q for unbiased R∈[0,S−1]. Probability is max(0,S−Q)/S within valid domains: S=8 gives 1/8; S=100 gives 82/100. This is not final hit probability or a requirement that full simulation run at 16 Hz.

Initial animation pacing relationship uses permanent Speed/S through a validated positive profile contract; exact native rounding/minimum/divisor safeguards remain unselected engineering dependencies. No player melee-frame/bow-cooldown formula is applied automatically to enemy animations. No new enemy fatigue/practice cost is invented.

## Required data

Enemy/attack/session/action/target identity; captured source and animation timing/profile; current lifecycle/marker/completion; remaining melee interval and opportunity phase; admitted interval/gate results; current live Speed and captured player level/reflex for interval; restriction/clock classification; commitment component/release progress; actual validity and pending recovery. Durable actor identity cannot be current sensed-target reference or animation flag.

## Inputs, outputs and events

Inputs: NPC attack intent, current eligibility/target/source, eligible clock/opportunity tick, animation marker crossing, restriction/source changes and save/load. Outputs: rejected intent, admitted attack/captured interval, commitment/release request, miss/cancel/settled result, interval progress/expiry and recovery state. API names remain unselected. Audio/animation notifications cannot authorize extra damage or interval rerolls.

## Cross-system interactions

NPC attack selection/state/profile/senses; COMBAT-016 reach/facing/door purpose, COMBAT-017 ranged release/supply, COMBAT-010 component validity/death and COMBAT-012 noninterrupting knockback; COMBAT-009/014 independent released projectiles; RULE-012 route and CHAR-010 reflex parameters; RULE-003 RNG and CORE-016/017 eligible time; MAGIC paralysis/casting; ITEM source mutations; AV animation sync; SAVE canceled wind-up/remaining interval and DATA/MOD validated overrides. Enemy spell/touch cadence integration remains MAGIC/NPC/COMBAT owner work, not automatic extension of melee defaults.

## Edge cases and failure conditions

Verify zero interval, Speed below eight/very high/invalid, permanent/live ratio yielding unsafe timing, target lost/AI retargeting, missing source and stale animation flags. No source/target fallback from malformed data; new attacks use explicit admission. Exact initialization of new actor timer/opportunity phase remains NPC contract, not implied by source field default zero.

Verify pause versus paralysis/disable cancellation, interval freeze, knockback-only progression/new-start suppression, source break during current target, multiple natural components and declaration of transformation states. Death/source changes cannot recall an already released shot or duplicate completed effects.

Verify slow-frame opportunity backlog, duplicate tick/marker callbacks, simultaneous interruption/commitment and technical failure after interval roll/partial damage. Retain outcomes/order; no queued burst, reset-on-every-update or whole-operation reroll. Exact per-actor scheduling/tie semantics require native fixtures.

## Configuration and balancing options

Moddable interval parameters, Speed gate/tick policy, animation timing/profile and explicit state eligibility/interrupt policies. Approved CHAR reflex coupling remains default. Native validation limits/profile schemas/provider precedence are dependencies; no new difficulty slider, global combat RNG reset, universal stun or ranged cooldown is added. Alternate policies must declare cadence/clock/commitment semantics rather than rely on animation callbacks.

## Save/load considerations

Native load cancels unfinished enemy wind-up/unreleased components, preserves saved remaining melee interval and completed results, and requires fresh eligible AI decision/opportunity. Never restore DoMeleeDamage/ShootArrow as fresh authorization, reroll interval or replay component costs/effects. Preserve required committed phase obligations under COMBAT-010 rather than deleting partially applied work.

Released arrows/spells persist independently under COMBAT-009/014. Their saved impact/source contexts must not also be recreated as new enemy releases. Ordinary pause retains progressing attack/interval without wall-time debt, distinct from load cancellation. Exact opportunity fractional phase, schema/migration and coherent mid-commit save boundaries require SAVE/CORE contracts; they cannot produce free immediate attacks or repeated rolls.

## Technical constraints

Target Godot 4.7.2. Separate AI intent, admission, interval/opportunity scheduler, attack phase/marker and authoritative resolution. Use explicit stable identities, eligible clocks, positive validated animation timing and retained RNG results. Native tick/backlog/marker/interruption/save fixtures required; no exact Unity FixedUpdate/Update flag architecture is mandated. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Enemy attacks have explicit wind-up/commitment/recovery; marker crossing commits at most once despite skipped/duplicate frames.
2. Intended target/source identity is captured at start; later sensed target cannot silently replace it, and commitment revalidates through proper contact owner.
3. Admitted melee starts draw approved level/reflex interval once and count it alongside animation; next start requires finished attack/expired interval/opportunity.
4. Speed-floor-8 unbiased opportunity checks follow eligible 0.0625-second ticks without queued/burst attacks or confusion with accuracy/component gates.
5. Active animation timing remains captured through later Speed changes; invalid positive-timing contracts fail explicitly.
6. Death/paralysis/explicit disable/interrupt/source loss cancels unfinished work without resumption/substitution or interval reroll; committed hits/projectiles remain.
7. Pause/loading/paralysis/disable freeze remaining interval; knockback alone progresses it while suppressing new starts and preserving existing attack unless separately interrupted.
8. Declared blocking states prevent starts; cosmetic Hurt/ordinary animation does not by itself cancel active gameplay.
9. Rejected target/action opportunity cannot draw new interval/store intent. Duplicate markers/ticks/recovery cannot produce extra hits or RNG draws.
10. Native restore cancels unreleased work, retains interval/results and requires fresh eligible AI intent, while restored projectiles do not re-release.

## Contradiction review

Reviewed against approved CHAR-010, COMBAT-001/004/009–014, RULE-012/015 and CORE-016/017 plus source/catalog/architecture. No direct contradiction identified. Enemy interval starts at initiation by confirmed choice and is not player bow cooldown. Timing capture borrows approved principle without automatically applying player formulas. Knockback preserves started attacks while blocking new ones, consistent with COMBAT-012. Actual source/death/paralysis interruptions retain prior termination rules; target locking does not guarantee contact. Native load cancels unfinished enemy attacks without deleting independent projectile persistence or committed obligations. Architecture proposals remain Proposed beyond confirmed requirements.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: exact animation divisor/rounding/safe minima; NPC timer initialization, action/restriction clock inventory; intent/target/source admission; opportunity backlog/tie/phase scheduling; COMBAT-016/017/MAGIC contact and ranged cadence; schema/provider validation and save/partial-operation fixtures. These cannot reintroduce mutable-target commitment, reset canceled timers, cancel attacks from Hurt visuals or create catch-up bursts. Subsequent enemy contact/ranged reviews remain separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-015-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented animation timing, NPC admission/clock policies, scheduling, ranged integration and save/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
