# COMBAT-007 — Bow draw, release and cooldown

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Provide predictable press-to-fire and optional hold-and-release bow controls. Make shot intent, actual release, cancellation and recovery distinct, with responsive aiming and no repeated firing from stale holds. Recover canceled draws without spending arrows/fatigue, while retaining the approved cooldown for every started bow attack.

## Confirmed requirements

COMBAT-007-D01–D15 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record five interviews. Press-to-fire is default; hold-and-release is optional. Existing COMBAT-001–004 input, commitment, fatigue, practice and timing contracts remain binding. The complete specification is approved under COMBAT-007-A01.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity remains unverified. Source unchanged. Paths are relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#Update` uses BowDrawback to choose draw/hold versus direct firing. Its lastAttackHand guard requires release before another bow attack. Draw holds at frame 3; lack of held SwingWeapon advances firing. Activation input or GetAnimTime exceeding MaxBowHeldDrawnSeconds=10 returns to idle.
- On bow attack completion, WeaponManager starts FormulaHelper.GetBowCooldownTime. Source uses Time.time and recomputes then; the target retains approved attack-start capture and eligible gameplay time instead.
- `Game/FPSWeapon.cs#AnimateWeapon`, `ChangeWeaponState` and `GetHitFrame` progress drawing/holding and firing, with release frame 5. `GetAnimTickTime` returns GameManager.classicUpdateInterval=0.0625 for bows. `Utility/WeaponBasics.cs#BowWeaponAnims` defines four draw frames and seven firing frames. These records need phase/marker verification rather than deriving exact total durations from frame counts alone.
- FPSWeapon's no-arrow presentation path calls SheathWeapons and displays feedback. Target intentionally retains drawn intent instead.
- User's DOS Daggerfall comparison motivates press-to-fire default but is not independently verified classic-parity evidence.

## Detailed rules and behaviors

### Modes, start admission and one-shot input

Offer Press-to-fire (default) and Hold-and-release bow modes independently of COMBAT-003 melee modes. Both require an eligible fresh logical Attack press for each shot. No held-button auto-repeat and no attack/recovery input queue. A release during recovery cannot turn a rejected press into a future shot.

Start admission requires valid bow/source/readiness/context and at least one eligible arrow. Missing ammunition gives brief no-ammunition feedback without starting an attack or cooldown. COMBAT-008 owns ammo eligibility/priority. Once admitted, capture attack identity/source, mode, timing/profile, cooldown and COMBAT-004 cost/practice context. Attack start is this admitted transition, not merely button state, visible bow or a rejected request.

Drawing neither consumes nor reserves an arrow. Ammunition remains in inventory until successful release, so inventory changes can invalidate the shot. Validate again at actual release under COMBAT-004/008. A bow with no ammo retains stored drawn intent instead of automatically sheathing; new shots remain unavailable. Adding ammo cannot revive rejected input or fire from an old hold.

### Press-to-fire and hold-and-release

Press-to-fire immediately enters a progressing firing sequence on accepted start, reaching its actual release marker according to the profile. The button need not remain held. Activate does not cancel this sequence; forced COMBAT-001 interruption remains possible before/after release with its defined consequences.

Hold-and-release draws while Attack is held. At minimum/full draw, it may wait for deliberate release. Releasing earlier records intent to finish minimum draw and fire once; no partial-strength default shot and no quick-tap cancellation. That deliberate release begins the progressing firing intent even while the minimum draw is unfinished. It is no longer a player-held draw and Activate no longer cancels it.

During an uncommitted player-held draw only, a fresh Activate press cancels and consumes that input so it cannot also interact/talk/cast. This is a bow-owned cancellation route, not ordinary world activation. MOVE/UI arbitration must preserve one input owner and distinguish deliberate release from cancellation. Exact ties between release/cancel/timeout need authoritative ordering before implementation; they cannot cause both a shot and an interaction.

### Full-draw holding and timeout

After reaching full draw while still held, count eligible gameplay hold time. Cancel automatically at the configured limit, baseline 10 seconds, excluding initial draw and paused/loading intervals. Timeout cancels rather than fires. Hold limit is moddable; numeric domain/maximum require validation.

Additional hold grants no default damage, accuracy or projectile-speed bonus/penalty and no new holding-fatigue charge. Mods may define explicit charge effects through supported policies, without silently altering approved baseline damage/timing stages. Cosmetic animation progression alone cannot create a charge bonus.

### Actual release, aim and costs

Firing intent is distinct from actual shot commitment. At the COMBAT-004 release marker, validate ammunition/source and safely commit one arrow release. Looking remains available through drawing, holding and firing. Capture aim from current resolved camera facing at actual release, not draw start; cosmetic bob does not redirect aim. Gameplay cursor does not direct default bow aim. Mods may explicitly change aim policy. COMBAT-009 owns projectile origin, wall clearance and collision/source attribution.

Successful release commits ammo consumption, vanilla 11 internal fatigue drain and +1 Archery/+1 Critical Strike practice under COMBAT-004. No further practice is awarded on impact. If ammo is missing/invalid at the marker, cancel without projectile, ammo consumption, attack fatigue or practice, retaining cooldown. Technical release failure uses explicit recovery without reporting false success or duplicating costs/projectiles. COMBAT-008/009/ITEM must specify atomicity/recovery around projectile activation and consumption; no universal rollback is promised.

### Cancellation, recovery and visibility

Every admitted bow attack gets its attack-start captured cooldown. Successful shot starts cooldown after firing animation finishes; canceled attack starts it immediately. Animation and cooldown do not overlap by default. Duplicate finish/cancel callbacks do not restart cooldown. Existing recovery retains its remaining duration.

COMBAT-001 paralysis/climbing/active-source mutation cancels immediately and preserves already released arrows and committed results. Context loss cancels an unfinished player-held draw without firing; already progressing press-to-fire or deliberate-release sequences freeze/resume with ordinary suspension as approved. Menu/focus/device cancellation must not masquerade as a release. Post-context new shots require fresh input regardless of held buttons. Ordinary pause freezes active sequence/cooldown/hold clock; no wall-time catch-up.

Ready Weapon and hand switching remain blocked during active attacks/cooldown under COMBAT-001/002. Hide bow during cooldown. Reveal automatically afterward only if still drawn and all other gates permit, without changing selected hand or starting another shot. No-ammo intent preservation does not override equipment delay, spell, paralysis/climb or other visibility gates.

### Live control changes

Bow input mode may change during a session under CORE settings. Existing attacks retain original captured mode/timing. Clear pending input and require a fresh press for the next shot. Cancel an unfinished player-held draw with captured cooldown on the control-setting change so it cannot wait on an obsolete hold. An already progressing firing sequence continues under its captured state. This does not make COMBAT-002 bow-hand equipment setting live-editable; that still requires no active session.

## Relevant formulas and parameters

Initial bow animation step =0.0625 eligible gameplay seconds, independent of Speed; profile timing/markers are moddable and captured per attack. Exact draw, release and postrelease total durations require authored-profile verification. Do not substitute RULE-015's melee-frame formula or infer a 16 Hz simulation requirement from this profile step.

Captured cooldown Tb=max(Mb,(10×(100−S)+800)/980) seconds under RULE-015, vanilla Mb=0.1 and attack-start live Speed S. Later buffs/equipment changes cannot recalculate the current attack's cooldown. Eligible cooldown elapsed starts at animation finish or cancellation as above, never at draw start or in parallel with successful-shot animation.

Full-draw hold limit H=10 eligible seconds by default. No hold-time damage/accuracy/velocity multiplier is introduced. Fatigue/practice/ammunition consequences remain COMBAT-004/008 contracts, not rendered-frame counts.

## Required data

Attack/session/source identity; captured input mode/profile/timing/cooldown/cost/practice context; phase and deliberate-release intent; full-draw hold elapsed; actual release completion; eligible ammunition presence and release validation; captured release aim; remaining recovery and once-only completion state; stored drawn intent; input-context cancellation. Physical button holds/raw scene references are not durable save identity.

## Inputs, outputs and events

Inputs: eligible Attack start/hold/deliberate release/cancel, fresh Activate, phase markers/time, ammo changes, source/restriction/context changes, settings changes and load. Outputs: rejected start/no-ammo feedback, admitted draw/firing intent, full-draw wait, cancellation, one committed shot, cooldown start/progress/completion and effective visibility. Concrete API/event names remain unselected. Animation/audio refresh cannot release an arrow or restart timers.

## Cross-system interactions

Confirmed extension: COMBAT-008-D13–D15 support optional modded multishot, requiring configured full ammo count at start/release unless an explicit partial-volley policy applies. One volley retains one attack-level fatigue charge/cooldown; release practice is per successfully released ammunition-bearing arrow. Baseline remains one arrow. See [COMBAT-008](COMBAT-008.md) for its separate approval status and partial-failure contracts.

COMBAT-001 readiness/interruption/load; COMBAT-002 source/bow-hand option; COMBAT-003 independent melee controls; COMBAT-004 release marker, fatigue/practice and exhaustion ordering; COMBAT-008 ammo eligibility/consumption/recovery; COMBAT-009 projectile origin/aim collision/attribution. RULE-015 captured timing; MOVE-001/002/003 input/binding/current look; CORE-003/006 settings and CORE-016/017 context/eligible time; ITEM ammo/bow validity; MAGIC active spell ownership; AV profiles/presentation; SAVE committed state and MOD/DATA validated overrides.

## Edge cases and failure conditions

Verify quick press/release before full draw, press held through recovery, deliberate cancellation versus context cancellation, timeout boundaries, overlapping bindings and Activate consumption. A fresh cancel cannot also open a door or cast; a canceled hold cannot fire on resume. Input aggregation follows MOVE-001 rather than individual physical releases creating extra shots.

Losing ammo after start cancels at release with cooldown; lacking it before start rejects without cooldown. Adding ammo cannot revive old input. Weapon loss/breakage and climbing/paralysis follow COMBAT-001 even after firing intent begins; an already released projectile is not recalled. A successful release causing fatigue depletion settles under COMBAT-004 before exhaustion consequences.

Modded timing/charge profiles need valid finite duration/marker ordering and explicit provider policies. Missing/invalid required profile or technical projectile failure requires truthful recovery; no repeated release on a skipped/duplicate visual marker. Hold clocks, animation and cooldown must remain consistent across slow frames and suspension.

## Configuration and balancing options

Press-to-fire default; optional hold-and-release; moddable bow timing/markers, full-draw timeout, explicit charge effects and aim policies. Existing cooldown parameters remain RULE-015-owned. No vanilla automatic repeat, variable-strength draw, hold penalty, cursor aim or extra cancel animation penalty is selected. Exact setting IDs, numeric ranges, profile/provider schemas and precedence remain owner dependencies.

## Save/load considerations

COMBAT-001 load cancels unfinished attacks, retaining committed costs/results and applicable remaining cooldown. A started bow attack not already in recovery begins its captured cooldown through load cancellation; one already in recovery retains remaining time. Do not restore a held draw, pending release intent or physical Attack hold into automatic firing. Require fresh input and no wall-time progress during load.

Retain sufficient captured timing/commitment facts for the approved load policy without recalculating later Speed or replaying ammo/fatigue/practice. Input mode preference remains application settings independently of character saves. Existing bow-hand compatibility reconciliation remains COMBAT-002. In-flight arrow persistence and exact mid-release save eligibility/recovery remain COMBAT-008/009/SAVE; this feature does not decide them.

## Technical constraints

Target Godot 4.7.2. Separate admitted attack start, player-held draw, progressing firing intent, actual release, animation finish and cooldown. Use explicit eligible clocks and idempotent markers, not button absence as proof of deliberate release or exact frame equality as a gameplay trigger. Publish coherent state through input/settings handoffs. Native profile timing, release atomicity and save schemas require verification. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Settings offer press-to-fire default and optional hold-and-release independently of melee mode; one fresh press is required per shot, with no queued/repeated firing from a hold.
2. No-ammo start rejects with brief feedback and no attack/cooldown; drawing reserves/consumes nothing, and no-ammo state preserves drawn intent.
3. Early deliberate release finishes minimum draw and fires once; after firing intent begins Activate cannot cancel it, but forced interruption remains effective.
4. Fresh Activate cancels only a player-held uncommitted draw and is consumed without world action/cast. Cancellation grants no release cost/practice and starts captured cooldown.
5. Full-draw holding cancels at 10 eligible seconds excluding draw/pause time; longer hold grants no default shot-strength change.
6. Looking remains available; actual release uses current resolved facing without cosmetic/cursor redirection. One release commits approved costs/practice exactly once.
7. Missing ammo at release cancels without shot/cost/practice but with cooldown; technical failure uses explicit nonduplicating recovery.
8. Successful firing animation completes before cooldown; cancellation begins cooldown immediately. Captured durations remain stable through buffs/settings and never progress during suspension/loading.
9. Cooldown hides the bow, blocks ready/hand switch and reveals only when other gates permit, without firing. Adding ammo never revives stale input.
10. Context loss cancels held draws; already progressing sequences freeze/resume under COMBAT-001. Live control changes cancel held draws, preserve progressing sequences and require fresh next-shot input.
11. Load applies COMBAT-001 cancellation/recovery without replaying release, costs or practice; released projectiles remain separately owned.

## Contradiction review

Reviewed against approved COMBAT-001–006, RULE-015, MOVE-001/002/003 and CORE-016/017 plus source/catalog/architecture. No direct contradiction identified. Early deliberate release becomes progressing firing intent, distinct from a player-held draw canceled on context loss. Activate cancellation is an explicitly consumed bow action and cannot fall through to MOVE-018 spell/interaction dispatch; exact arbitration remains an integration contract. Cooldown begins at explicit finish/cancel boundaries while using RULE-015 attack-start capture. No-ammo intent retention intentionally differs from DFU without changing visibility gates. Broader architecture proposals remain Proposed.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: verify exact phase totals/marker mapping and profile schemas; define release/cancel/timeout simultaneous ordering; integrate consumed Activate with spell/UI routing; validate timer bounds and live setting publication; finalize ammo/projectile atomicity, near-wall origin and save boundaries through COMBAT-008/009/SAVE. These cannot silently change default mode, one-shot input, cancellation costs, timeout origin or captured cooldown semantics.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-007-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented animation/profile timing, input arbitration, release/projectile atomicity and save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
