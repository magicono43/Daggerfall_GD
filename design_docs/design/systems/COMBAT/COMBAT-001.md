# COMBAT-001 — Readying and attack interruptions

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose

Coordinate player weapon readiness with attack recovery, spells, movement restrictions, equipment readiness and session transitions. Prevent delayed attacks, duplicated consequences and recovery bypasses.

## Intended player experience

Drawing weapons provides a predictable return from an uncast readied spell. Restrictions preserve the player's readiness intent while preventing attacks. Forced cancellation never resumes an old strike; pauses preserve already progressing attacks without turning canceled physical input into an arrow release.

## Confirmed requirements

COMBAT-001-D01–D15 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record five interviews, each answered with three “Yes” responses. D13 explicitly qualifies D11 for a bow awaiting deliberate release. The complete specification is approved under COMBAT-001-A01. No implementation or coding tasks are authorized.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime parity is unverified. Source unchanged. Paths below are relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#Update` refreshes hands, resets completed-attack flags and starts bow cooldown after an attack finishes. Cooldown returns before paralysis/climbing, spell and ordinary ready/hand-switch processing.
- Paralysis/climbing hide weapons and return. A ready spell or casting animation also hides weapons unless Ready Weapon is accepted while no weapon attack is active. That path calls AbortReadySpell and ensures weapons end drawn.
- Ordinary Ready Weapon and SwitchHand are gated against active attacks. Selected-hand equipment delay hides weapons and blocks attack processing; readiness toggling occurs before that delay gate.
- Bow drawback can be canceled without release by activation input or exceeding its hold limit. The hit-frame branch dispatches melee or creates an arrow missile, removes ammunition and charges swing fatigue. This does not establish all interruption behavior merely from visibility changes.
- `ToggleSheath` changes stored readiness and plays an applicable draw sound; `SheathWeapons` explicitly sheathes/hides; `Reset` resets hand references and sheathes.

## Detailed rules and behaviors

### Readiness and request admission

Store drawn/sheathed intent separately from effective visibility and attack availability. Temporary hiding does not itself sheath weapons or change selected hand.

Ignore Ready Weapon during an active weapon attack, bow cooldown, paralysis or climbing. Ignore hand switching during bow cooldown, paralysis or climbing. Requests rejected by these gates expire without queuing; require fresh requests after the gate clears. COMBAT-002 owns remaining hand-selection/admission details, including equipment changes.

When otherwise eligible, Ready Weapon toggles drawn/sheathed intent. During an equipment delay this toggle is allowed, but weapons remain hidden and attacks unavailable until the selected hand is ready and all other gates permit. This permission does not bypass attack/cooldown/spell/movement restrictions.

### Spells

Ready Weapon cancels an uncast readied spell and ends with weapons drawn, including when weapons were already logically drawn beneath that spell. Preparing a spell temporarily hides weapons without changing stored readiness.

Once actual casting begins, ignore Ready Weapon without queuing; require a fresh press after casting finishes. MAGIC owns the precise uncast-to-casting boundary and forced spell interruption. After casting finishes, previously drawn weapons reappear when other gates permit; no automatic attack follows and fresh attack input is required. These rules do not authorize refunding spell costs or undoing committed effects.

### Forced attack cancellation

Paralysis, entering climbing, or removal/breakage/replacement of the active weapon cancels the active attack immediately. The canceled attack cannot deliver a subsequent hit/release or resume when the restriction ends. Do not substitute a replacement weapon into that attack.

Preserve already committed hits, released projectiles and committed costs/results. Before melee commitment or arrow release, cancellation consumes no attack fatigue or ammunition. A committed melee swing can cost fatigue even when it misses; “contact” does not require hitting a target. COMBAT-004 defines the precise melee commitment boundary and practice eligibility. Cancellation itself grants no practice.

After paralysis/climbing ends, restore previously drawn weapons when other gates permit, retain selected hand/readiness, and require fresh attack input. ITEM/COMBAT-002 still determine whether an equipment change is admissible; this cancellation rule governs a change that actually occurs.

### Bow cooldown

Every started bow attack incurs its captured cooldown when it finishes or is canceled, including cancellation before release and cancellation caused by context loss or load. An already running cooldown retains its remaining duration rather than restarting on repeated cancellation or load. No duplicate notification can charge costs, release another arrow or restart recovery.

Use RULE-015's attack-start timing capture and eligible gameplay time. Later Speed/equipment changes cannot recalculate this attack's cooldown. Cooldown continues to block ready/hand-switch requests. Bow attack start/release phase boundaries remain COMBAT-007/008 integration contracts; a rejected attack request is not a started bow attack.

### Suspension and input context loss

Ordinary gameplay suspension freezes progressing attacks and cooldowns and resumes their progression with eligible gameplay. It neither completes recovery nor ordinarily cancels an already progressing swing/bow-release animation.

Exception: a bow awaiting deliberate player release is canceled when its physical-input context is lost, applying captured cooldown without firing. Menu entry, focus loss and device/context cancellation follow MOVE-001/CORE-016; cancellation is never interpreted as deliberate release. Cooldown initiated during suspension cannot advance until gameplay is eligible. An already committed animation can resume without a new press, but starting another attack requires eligible fresh input under MOVE-001. No stale hold or menu-closing input starts a new attack.

## Relevant formulas and parameters

RULE-015 supplies captured bow cooldown Tb=max(Mb,(10×(100−S)+800)/980) seconds, with vanilla minimum Mb=0.1 seconds and captured live Speed S. Its captured melee frame interval and minima remain binding; this feature adds no new swing-duration formula. Only eligible gameplay duration reduces remaining cooldown; pause/load wall time contributes zero.

Equipment-delay durations, attack commitment markers and bow start/release timing are not newly selected here. No numeric interruption penalty, extra recovery period or attack queue is introduced.

## Required data

Session/character identity; stored readiness and selected hand; active weapon identity/validity; selected-hand equipment readiness; current movement restrictions; uncast-ready versus casting spell state; attack identity/phase and commitment status; captured timing and remaining cooldown; input context and cancellation state. Persist gameplay identity/state rather than engine object pointers or physical key holds. Exact representation remains an engineering dependency.

## Inputs, outputs and events

Inputs: eligible Ready Weapon/hand-switch requests, attack phase transitions, spell readiness/casting changes, paralysis/climbing transitions, equipment mutations, suspension/context loss and load reconstruction.

Outputs: accepted readiness change or expired request, derived visibility/availability, canceled attack, retained commitment results, cooldown start/progress/completion and owner notifications. Signal/API names remain unselected. Presentation notifications cannot independently authorize damage or duplicate gameplay effects.

## Cross-system interactions

MOVE-001/002 own input delivery/bindings and rejection without combat queuing. MOVE owns climbing state; MAGIC owns paralysis/spell state and forced spell interruption. MOVE-018 spell-first activation remains binding: this specification does not grant one input both casting and interaction. COMBAT-002 owns hand/equipment presentation; COMBAT-003 attack input; COMBAT-004 commitment/cost/practice; COMBAT-007/008 bow lifecycle; COMBAT-009 and SAVE released-projectile persistence. ITEM owns equipment mutation. CHAR owns fatigue/practice mutation. RULE-015 owns captured timing; CORE-015/016/017 own lifecycle, suspension and eligible time; AV derives presentation from authoritative state.

## Edge cases and failure conditions

- Overlapping restrictions cannot reveal weapons early: ending casting does not bypass climbing, paralysis, equipment delay or cooldown.
- Repeated restriction/cancellation callbacks cannot undo committed effects or create a second cooldown. A projectile already released remains independent of canceling its source attack; persistence is separately governed.
- Readiness changes during equipment delay preserve latest accepted intent; delay completion cannot itself attack.
- At a commitment/interruption tie, use a declared authoritative order: retain a commitment already made; cancellation prevents any later commitment. Exact scheduling/tie ordering needs COMBAT/CORE integration tests.
- Stale callbacks from replaced attacks/sessions cannot affect the current attack or character. Invalid required restore state requires SAVE/CORE recovery, not invented readiness or zero-duration recovery.
- Removing ammunition before release requires COMBAT/ITEM release-time validation; this feature does not authorize consuming nonexistent ammunition or choosing a substitute policy.

## Configuration and balancing options

Retain RULE-015's approved moddable timing parameters/hooks and ITEM-owned readiness data. This feature approves no additional mod override API, player interruption setting or alternate cancellation policy. Exact supported mod schemas and validation remain owner dependencies; architecture proposals are not approved wholesale.

## Save/load considerations

For saves made during an attack, loading cancels its unfinished portion, retains committed costs/results and restores remaining cooldown. If a bow attack had started but had not entered recovery, cancellation begins its captured full cooldown; if already in recovery, preserve the remaining value. Repeated loads of the same snapshot reconstruct the same applicable state rather than accumulating penalties or completing cooldown through wall time.

Retain sufficient captured attack/commitment/timing facts to apply this policy without recapturing later Speed or replaying hits/costs. Restore readiness/selected hand and recompute effective visibility/availability from restored owner state before control returns. Do not restore pending physical presses/holds; require fresh attack input. Exact save eligibility, schema/migration, released-projectile persistence and active spell restoration remain SAVE/domain contracts, not approvals of partial projectile or spell persistence here.

## Technical constraints

Target: Godot 4.7.2. Represent authoritative readiness, attack phase, commitment and cooldown independently of rendered visibility/frame equality. Handle crossed markers without duplicate commitment; invalidate canceled attack work before later delivery. Explicit owner ordering must reconcile costs, equipment changes and restrictions. Concrete engine APIs and scheduler/state representation require engineering verification. No game code changes or implementation tasks are authorized.

## Acceptance criteria

1. Ready Weapon during active attack/cooldown/paralysis/climbing is ignored and never executes later; hand-switch gates obey the specified restrictions.
2. Ready Weapon cancels an uncast readied spell and ends drawn, but does not cancel actual casting or queue a later toggle.
3. Paralysis/climbing/active-weapon mutation cancels an attack without a later hit or replacement-weapon strike. Existing committed effects survive exactly once.
4. Precommit cancellation charges no attack fatigue/ammunition; postcommit cancellation retains committed costs. A miss does not automatically waive a committed swing's cost.
5. Every started bow attack gets its captured cooldown on finish/cancellation. Repeated cancellation cannot restart it or release an arrow.
6. Ordinary suspension freezes progressing attacks/recovery. Context loss cancels a bow waiting for deliberate release without firing; already progressing animations can resume.
7. Clearing restrictions/casting restores previously drawn weapons only when all applicable gates permit and never starts another attack from stale input.
8. During equipment delay, accepted readiness toggles change intent while visibility/attacks remain blocked.
9. Mid-attack load cancels unfinished work, preserves committed facts and applicable captured/remaining cooldown, excludes load time and requires fresh input.
10. Combined restrictions, commitment/interruption ordering, equipment mutation, context cancellation and stale/duplicate notifications are verified without duplicated effects or bypassed recovery.

## Contradiction review

Reviewed against approved MOVE-001/002/018, CORE-016/017, RULE-015 and relevant CHAR activity/practice ownership, plus COMBAT catalog/architecture and D01–D15. No direct contradiction identified. D13 explicitly reconciles suspension with MOVE-001 physical-input cancellation; D12 supplies the load cancellation option left open by RULE-015. Captured timing survives cancellation/load without mandating attack resumption. Broader COMBAT-AR-01 recommendations remain Proposed. Adjacent combat/equipment/magic features retain their unapproved details.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation, owner contracts must settle exact attack-start/commit/release/casting boundaries, simultaneous-event order, equipment-delay/hand-switch details, missing ammunition, spell restoration, save schema/migration and projectile persistence. Those decisions cannot silently change the confirmed cancellation, cost, input or timing rules. No broader save eligibility or transport combat policy is established here.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-001-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
