# COMBAT-003 — Attack gesture and click input

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Translate deliberate melee input into one accepted attack direction while offering classic directional gestures and simpler press/hold alternatives. Prevent stale holds, gesture leftovers and rejected inputs from becoming unexpected later attacks. Input recognition does not itself apply damage, costs or practice.

## Confirmed requirements

COMBAT-003-D01–D15 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record five interviews, each answered with three “Yes” responses. The complete specification is approved under COMBAT-003-A01. COMBAT-001/002 readiness, cancellation and attack-source rules remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity remains unverified. Source unchanged. Paths below are relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#Update` uses WeaponSwingMode 0 for gestures, press-start for click mode, and held input for mode 2 repetition. Bows use a separate path and a release-before-next-attack guard.
- Click attacks uniformly choose among eight input directions, then `Game/FPSWeapon.cs#OnAttackDirection` maps Up/UpLeft/UpRight to StrikeUp. This weights the resulting upward attack more heavily than other distinct directions; the target deliberately uses equal probabilities over distinct supported attack directions instead.
- `WeaponManager.Gesture` retains motion for a one-second window, tracks both vector sum and total path length, and `TrackMouseAttack` compares path length to AttackThreshold=0.05 of the longest screen dimension. It uses vector angle for six-direction mapping. The target uses net displacement for qualification as well as direction.
- Controller tracking uses a neutral/reset region and a once-swung flag. `ExecuteAttacks` delegates direction to FPSWeapon; its one-shot guard prevents ordinary animation replacement, with a bow draw-to-release exception. Input acceptance and attack commitment are separate concerns.

## Detailed rules and behaviors

### Modes and attack admission

Expose Gesture, Press-once and Hold-to-repeat melee modes in settings. Gesture is default. All modes submit requests through current session/input context, selected attack source and COMBAT readiness validation. Rejected input expires; no combat queue or cooldown buffering is introduced.

Press-once starts at most one attack per eligible fresh logical press. Presses delivered during an active attack or recovery are discarded. MOVE-001 retains brief eligible presses for normal delivery; this does not retain a rejected request until readiness returns.

Hold-to-repeat intentionally starts another melee attack after the preceding attack/recovery finishes while its eligible hold continues. Ordinary active attack/recovery is a wait condition, not a reason to disarm repetition. Input cancellation, actual weapon/hand changes or other blocking restrictions disarm repetition and require a fresh press. Clearing a restriction cannot rearm an old hold. COMBAT-001 governs whether the already progressing attack freezes, cancels or completes; disarming repetition does not undo its committed effects.

These melee modes do not alter bow draw/release. COMBAT-007/008 own that input lifecycle under COMBAT-001 cooldown and cancellation rules.

### Gesture recognition and directions

Hold Attack to capture swing motion. Baseline directions are Up, Down, Left, Right, Down-left and Down-right; upward diagonals map to Up. Use the inspected DFU angular partition as the baseline directional layout; exact angular boundaries/axis conversion need explicit fixtures, not incidental floating-point ties. Mods may define additional directions with matching animations and explicit mappings.

For mouse gestures, collect eligible post-readiness mouse deltas within a rolling recognition window. Qualification uses the magnitude of their net vector, and direction uses that same vector. Opposing motion cancels; total traveled path alone cannot qualify. Zero net displacement cannot choose an arbitrary direction. Baseline window is one eligible gameplay second. Gesture sensitivity/threshold and recognition window are configurable separately from camera sensitivity, with mod support. DFU's 5% path-length threshold is reference only; target sensitivity defaults and normalization require Godot testing.

After consuming a gesture, discard its motion. While Attack remains held, a further swing requires new motion after prior attack/recovery completion. Motion performed during attack/recovery cannot be saved toward the next gesture. Releasing Attack ends capture and clears unfinished motion without triggering an attack. Cancellation is distinct from release and cannot fire either.

For controller gestures, reserve the look stick while capturing. Require neutral before an attacking deflection on entry, even if the stick was already tilted for looking, and before each subsequent swing. A continuously tilted stick cannot repeatedly attack. Activation and neutral thresholds are separately tunable; exact shapes/defaults/hysteresis require controller fixtures alongside MOVE deadzones. Do not buffer attack-ineligible stick motion as a later gesture.

If the requested direction is unsupported, produce no attack and do not silently substitute a random or nearest direction. Mods may explicitly declare a mapping. Exact feedback and rearm handling after unsupported input remain owner integration details, without permitting repeated attacks from one unchanged deflection or retaining a rejected request.

### Automatic directions

For each accepted new press-once or repeat attack, choose uniformly among the active weapon/form's distinct supported directions. Aliased input directions cannot duplicate entries to bias a direction. An empty supported list blocks the attack as invalid configuration.

Resolve ordinary readiness and validate the direction set before drawing. Capture the accepted attack's chosen direction and source; repeated delivery, presentation refresh and technical retries cannot reroll it or create another attack. Rejected requests consume no direction roll. Use owned combat gameplay randomness under RULE-003, separate from presentation/previews; no frame-based reseeding. Successful load cancels unfinished attacks under COMBAT-001 rather than restoring an input queue.

### Look ownership and settings changes

Gesture-mode Attack holds reserve corresponding mouse/look-stick motion throughout capture, including swing and recovery. During attack/recovery discard that motion for both attack accumulation and looking. On capture entry stop pending camera smoothing under MOVE-003; on exit never replay reserved motion into camera rotation. This controls the gesture motion sources, not an unapproved universal ban on every other look input.

Other melee modes allow looking under MOVE-003. Context changes, UI/HUD consumption and device arbitration remain MOVE/UI contracts; held motion cannot leak into another context. After loss of context or restriction, a held Attack cannot reestablish capture or repetition without fresh input.

Attack-mode and gesture-setting changes may apply during a session. Coherently clear pending recognition/repetition, release old capture ownership and require fresh Attack input. Do not rewrite an already-started attack's captured timing, direction or results; COMBAT-001 continues its applicable lifecycle. Bow-hand configuration retains COMBAT-002's outside-session restriction.

## Relevant formulas and parameters

For eligible samples di within configured window W, net gesture vector G=sum(di); qualify only when magnitude(G) reaches the validated positive threshold and G is nonzero. Determine direction from G under explicit axis/sector mapping. Baseline W=1 eligible gameplay second. Deltas must be sampled/scaled consistently without multiplying physical mouse displacement by frame time again. Exact resolution/DPI normalization, sensitivity curve and threshold defaults remain engineering/tuning dependencies.

For N distinct supported automatic directions, each has probability 1/N. Use an unbiased discrete selection contract; duplicate aliases do not increase probability. Controller activation/neutral thresholds require validated separation and a neutral-before-next-deflection state, with concrete values unselected. Attack cadence comes from COMBAT/RULE timing, not rendering speed or an additional repeat timer invented here.

## Required data

Mode/preferences and validated gesture parameters; session/context eligibility; logical Attack start/hold/release/cancel; active hand/source and supported direction profile; eligible recognition samples/time; controller neutral/rearm state; capture ownership; repetition armed state; accepted attack identity/chosen direction and captured timing; mod mapping/provider identity. Transient device holds and gesture trails are not durable save identity.

## Inputs, outputs and events

Inputs: logical Attack transitions, eligible mouse/stick motion, readiness/recovery transitions, selected source changes, mode/settings changes, context cancellation and load. Outputs: one accepted attack with selected direction/source, rejected request or invalid-configuration result, gesture capture/release and repetition disarm. Concrete APIs/signals remain unselected. A recognition preview cannot spend randomness, fatigue or practice.

## Cross-system interactions

MOVE-001/002 own logical input aggregation, device arbitration, bindings and cancellation; MOVE-003 owns actual look/smoothing handoff. COMBAT-001 readiness/interruption, COMBAT-002 selected source/presentation and modded hand extensibility, COMBAT-004 costs/commitment/practice, COMBAT-007/008 bows. RULE-003 owns randomness and RULE-015 captured timing. CORE owns settings/context/suspension/eligible time; ITEM/MAGIC provide weapon/form validity; AV supplies direction animations; MOD/DATA validate locked direction profiles and mappings. No direction-specific damage/accuracy bonus is approved by this feature.

## Edge cases and failure conditions

Test brief taps, overlapping physical Attack bindings, cancellation versus release, focus/menu/disconnect, controller drift, stick tilted at capture entry, rapid mode changes, and source changes while held. None can create an unintended fresh attack.

Mouse backtracking, expired samples, zero vectors, diagonal boundaries, dropped frames and device changes require consistent recognition without path-length accumulation or replay. Controller neutral during recovery cannot supply a stored attacking deflection afterward; use fresh post-readiness deflection. Exact sampling order must establish this without depending on callback order.

Validate direction/animation profiles before play; missing/empty required data uses explicit DATA/AV recovery rather than a random fallback source. No unsupported direction spends attack costs merely because recognition occurred. Accepted attacks crossing cancellation/commitment boundaries follow COMBAT-001 and authoritative ordering. Duplicate callbacks cannot consume another random choice or start another attack. Exact diagnostics/feedback remain UI/DEV owner contracts.

## Configuration and balancing options

Gesture default with two alternative modes; independently adjustable mouse gesture sensitivity/window; separately tunable controller activation/neutral thresholds; validated moddable gesture parameters and additional directions/mappings. Automatic baseline selection remains equal over distinct supported directions. No weighted default, hidden streak protection, attack input buffer, gesture damage multiplier or new bow option is introduced. Exact setting IDs/ranges/default sensitivity and mod schemas/provider precedence remain dependencies.

## Save/load considerations

Modes and control preferences follow CORE application settings, independent of character saves. Do not save/replay physical holds, pending presses, partial gestures, neutral-reset state or armed repetition. Native load requires fresh Attack input and fresh controller neutral qualification. COMBAT-001 cancels unfinished attacks while preserving its specified costs/cooldown/results. Persist committed consequences through their owners rather than replaying input or rerolling a retained operation. Successful-load future randomness follows RULE-003; exact stream/schema details remain owner contracts.

## Technical constraints

Target Godot 4.7.2. Keep recognition, attack admission, accepted attack state and presentation distinct. One accepted input/request must not become several attacks through physics/render callback duplication. Eligible gameplay clocks and sampled device deltas must give stable behavior across frame rates. Concrete engine APIs, input-source arbitration during gestures, angular normalization, sample storage bounds and scheduler ordering need native verification. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Settings expose all three modes with Gesture default; live changes reset pending recognition/repetition without changing a started attack.
2. Press-once starts at most one attack per accepted press; attack/recovery rejection never queues a later swing.
3. Hold-to-repeat repeats only while armed and eligible, respecting attack/recovery timing; cancellation/source changes/restrictions require fresh input.
4. Six baseline gestures map as specified; unsupported gestures cannot silently select another attack. Modded directions require explicit validated profiles/assets.
5. Mouse qualification uses net displacement within the configured eligible-time window, with no attack from zero net motion or accumulated backtracking alone.
6. After a swing, only fresh post-recovery gesture motion can start another; release/cancellation cannot fire an unfinished gesture.
7. Controller entry and successive swings require neutral then fresh eligible deflection; held tilt/drift cannot auto-repeat.
8. Automatic directions have equal chances over distinct supported directions, draw only on accepted starts and remain fixed through retries/refreshes.
9. Gesture capture consumes corresponding look motion across swing/recovery, stops smoothing drift and never replays motion; other modes allow looking.
10. Menu/focus/device/load boundaries cannot revive pending input, gestures or repetition. Bow behavior remains under its separate feature owners.

## Contradiction review

Reviewed against approved COMBAT-001/002, MOVE-001/002/003, CORE-016/017, RULE-003/015 and the COMBAT catalog/architecture. No direct contradiction identified. Hold-to-repeat is deliberate continuation from an eligible hold, not MOVE-001 replay of a discrete press; its disarm rules preserve fresh-input requirements after gates/context changes. Gesture capture explicitly uses MOVE-003's approved motion reservation. Automatic selection changes DFU's remapped weighting by confirmed choice. COMBAT-001 still owns already progressing attacks when input is canceled; disarming repeat does not cancel them independently. Architecture proposals remain Proposed outside individually confirmed contracts.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: fix/test mouse normalization/sensitivity defaults, angular boundaries, controller thresholds/hysteresis, device arbitration during capture, unsupported-direction feedback/rearm details, validated schemas/provider precedence, admission/RNG ordering and bounded sample storage. These dependencies cannot waive net-displacement recognition, no-buffer rules, equal selection or fresh-input boundaries. Bow lifecycle and attack costs remain separate feature reviews.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-003-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
