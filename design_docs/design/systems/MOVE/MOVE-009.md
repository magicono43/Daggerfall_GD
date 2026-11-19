# MOVE-009 — Jump, air control and gravity

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Provide deliberate jumps and predictable airborne motion influenced by character capability, with explicit platform momentum and optional enhanced-jump steering. Collision, pause and restoration cannot manufacture boosts, repeat jump costs or erase falls.

## Confirmed requirements

MOVE-009-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews, each confirmed with three “Yes” answers. The following rules consolidate those choices. MOVE-001–008, CHAR-020 and CORE eligibility/restoration contracts remain binding. Fall damage is MOVE-010 scope.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths below are relative to the reference directory. Static inspection only; source unchanged.

- `Assets/Scripts/Game/Player/AcrobatMotor.cs#HandleJumpInput` blocks jumps for paralysis, exterior swimming, Slow Fall and cart transport. It normally waits for 0.1 seconds grounded, checks held Jump, and computes an impulse from Jumping/traits/effects, with separate horse behavior. Crouch multiplies vertical impulse by 0.8; moving jumps receive a small camera-forward boost.
- `CheckAirControl` can replace horizontal motion from input when air control, enhanced jumping or rappel conditions permit. `HitHead` reverses positive vertical motion on overhead collision.
- `ApplyGravity` applies ordinary gravity, an anti-bump correction and a special Slow Fall path. Its Slow Fall velocity includes delta before later movement integration; this source expression is not approved as the target timing formula.
- `CheckInitFall`/`CheckFallingDamage` track fall state separately; damage notification uses string messages. These do not define this feature's future damage policy.
- `Assets/Prefabs/Player/PlayerAdvanced.prefab` uses jumpSpeed 4.5, gravity 20 and airControl off; `PlayerStandalone.prefab` has jumpSpeed 8. Asset values differ and do not establish universal runtime defaults.

Target behavior below explicitly selects fresh presses, ceiling cancellation without a downward kick, bounded enhanced steering and no vanilla extra forward boost.

## Detailed rules and behaviors

### Jump eligibility and commitment

One fresh eligible Jump press can initiate one jump when valid support exists and no applicable restriction blocks it. No held-repeat, coyote time or pre-landing jump buffer is introduced initially. Rejected airborne presses expire rather than waiting for landing. MOVE-001 retention to the next appropriate delivery is not a landing buffer.

Snapshot live Jumping, relevant traits/effects and actual posture at successful takeoff. Calculate and apply impulse once; later equipment, effect or crouch changes cannot recalculate it. Explicit airborne effects can modify motion only under their own declared rules.

Identify the successful jump so fatigue and Jumping practice occur once under CHAR-020: its approved additional base fatigue cost and +1 raw Jumping practice apply, with approved trait modifiers. Rejected requests, contact callbacks, restore and animation cannot repeat them. CHAR retains exhaustion/action restrictions.

Paralysis prohibits voluntary jumping under MOVE-004. Slow Fall blocks ordinary jumping through an explicit moddable restriction. Swimming, riding/cart/horse, climb-eject and other specialized eligibility/impulses remain their mode contracts; the ordinary on-foot formula does not silently authorize all supported modes or copy every DFU restriction.

### Initial impulse and gravity

Accepted moddable on-foot baseline:

`v_jump = 4.5 × (1 + J/200 + A + I + E) × C`

- J: live Jumping at takeoff.
- A: 0.1 with Athleticism, otherwise 0.
- I: 0.1 only with both Athleticism and Improved Athleticism, otherwise 0.
- E: 0.6 with enhanced jumping, otherwise 0.
- C: 0.8 if actually crouched at takeoff, otherwise 1.

Gravity baseline is 20 in the reference movement scale. Validate physical trajectories against chosen Godot world scale; copying numerical constants alone is not proof of matching height/range. Supported skill/formula domains and finite arithmetic must be validated.

Cap otherwise valid jump impulse at a finite positive moddable maximum. Use a validated moddable maximum downward speed during falling. Exact caps require world-scale/collision testing. Caps do not silently repair malformed configuration, clear fall history or confer fall-damage immunity. Invalid/nonfinite values follow approved validation/recovery.

Apply ordinary gravity with eligible simulation time consistently across frame rates. No jump-height charging/release-shortening behavior is selected. Slow Fall descent speed and fall-history protection belong to MAGIC/MOVE-010, with explicit frame-independent start/end transitions rather than copied double-delta integration.

### Horizontal momentum and air steering

Ordinary air motion retains actual horizontal takeoff momentum without steering. Looking changes view, not the direction of existing momentum. MOVE-005 takeoff gait stays latched until landing; changing gait requests or crouching in flight cannot instantly switch airborne speed. Airborne changes to ground-speed modifiers do not rewrite ordinary retained momentum absent an explicitly supported airborne effect.

Do not add DFU's camera-forward boost in vanilla. Support an explicit modded jump-boost rule without implicit repeated boosting from held input. MOVE-006 airborne resizing preserves foot/base position and cannot add upward impulse or reset fall history.

Enhanced jumping may enable directional steering via bounded horizontal acceleration toward requested direction. Do not instantly replace velocity. Validate acceleration and speed bounds; steering cannot add unlimited speed or repeatedly amplify inherited platform momentum. Losing the effect stops further steering while retaining existing momentum. Input restrictions such as paralysis stop voluntary steering, not gravity or existing passive momentum. Exact directional response and how bounds handle already-fast inherited motion require fixtures and explicit tuning; no automatic momentum deletion is selected here.

### Leaving moving platforms

On jump or walking off valid support, inherit platform velocity at the support point once, including rotational point motion. Detach immediately; subsequent platform motion cannot pull or continuously accelerate the player. Platform inertia combines with player takeoff motion without adding carriage twice. Inheritance is configurable for mods.

Support-point translation/rotation velocity, integration order and trajectory discontinuities require MOVE-008/LOC fixtures. Restoring platform/player state or moving a platform instantaneously during placement is not a new takeoff inheritance event. No repeated momentum gain from stale support references is permitted.

### Collisions and transitions

On overhead collision while ascending, cancel upward velocity and let gravity produce descent; do not reverse the full upward velocity into a downward kick. Horizontal motion remains collision-constrained. Ceiling contact does not authorize a crush kill without MOVE-008's validated compression conditions.

Ordinary support loss starts airborne motion under MOVE-004. Ground-following steps cannot pull a jumping player down under MOVE-007. Landing/support classification, fall history and damage thresholds remain MOVE-010 and shared contact contracts; probes cannot duplicate a landing or jump.

All physical operations run through MOVE-004 authority. Suspension preserves physical state without gameplay-time catch-up or repeated impulse. Explicit mode transitions transfer motion/history under their declared rules; levitation, swimming or climb grabs do not implicitly erase falls through this feature.

## Relevant formulas and parameters

The impulse formula and gravity baseline above are selected moddable defaults in reference scale. Ordinary vertical integration conceptually advances velocity by gravity times eligible duration, respecting the declared downward bound; exact integration/collision scheme remains engineering choice to verify. Overhead collision removes positive vertical velocity rather than negating it.

Unselected parameters: world conversion, impulse/downward caps, supported extended-stat ranges, enhanced steering acceleration/speed bounds and platform-inheritance configuration details. No target physics frequency, grounded-delay requirement, coyote interval or landing-buffer interval is approved. No new fall-damage formula is introduced.

## Required data

Eligible fresh Jump intent; support/mode/restrictions; actual posture; takeoff skill/trait/effect snapshot and bounded impulse; actual velocity; takeoff gait and jump/airborne identity; gravity/downward limit; enhanced steering eligibility/bounds; support-point velocity and inheritance-completion context; contacts and lifecycle gates. SAVE/MOVE-010 additionally define necessary fall history. Concrete schema and event IDs remain implementation dependencies.

## Inputs, outputs and events

Inputs: Jump/direction intent, support loss/landing, live capability at takeoff, effect/restriction changes, platform point motion, overhead/world collision, suspension and native restore. Outputs: successful jump identity/impulse, checked airborne displacement, one-time CHAR activity report, detach/inherited velocity, ceiling outcome and mode transitions. API/signal names remain unselected. Input eligibility alone does not prove a successful jump.

## Cross-system interactions

MOVE-001/002 own input/bindings; MOVE-003 view cannot redirect momentum; MOVE-004 physical authority/history; MOVE-005 gait; MOVE-006 airborne posture; MOVE-007 step/support; MOVE-008 platform attachment; MOVE-010 falls; specialized modes own their transition rules. CHAR-012/020 own practice/fatigue and CHAR traits/restrictions; MAGIC owns enhanced jump/Slow Fall lifecycle. LOC/WORLD supply geometry/platform state; CORE pause/readiness and SAVE restore without replay. MOD/RULE/DATA own validated definitions/hooks; no arbitrary effect-stacking framework is approved.

## Edge cases and failure conditions

Quick taps reach delivery once but illegal airborne taps cannot queue for landing. Held Jump cannot cause bunny hopping. Takeoff crouch reduces impulse; later crouch changes cannot increase it. Ceiling impacts do not create artificial downward kicks or reset fall consequences.

Rotating/upward/downward platforms need representative jump/walk-off fixtures, ensuring no duplicate inheritance or attachment pullback. Enhanced steering cannot pump inherited momentum indefinitely; effect loss and paralysis must not zero ordinary physical momentum incidentally. Very high valid skills are bounded; malformed definitions cannot become collision-bypassing speeds.

Pause midflight preserves velocity/history and adds no elapsed motion. Restore cannot invoke a new jump or replay CHAR events. Optional jump boosts/inheritance changes need explicit mod semantics and safe state handling. Mode-invalid motion uses checked transition/recovery, not silent floor teleport.

## Configuration and balancing options

Baseline impulse/trait/effect/crouch parameters, gravity, validated caps, enhanced steering and platform inheritance support declared moddable configuration. Optional mod jump boosts are supported; vanilla omits the extra forward boost. Vanilla uses fresh presses, ordinary no-steering air motion and Slow Fall jump restriction. No sprint meter, charge jump, double jump, coyote time or landing buffer is introduced by this specification.

## Save/load considerations

Save actual velocity, jump/airborne state and takeoff gait needed to continue supported flight. Restore after geometry/context validation without recalculating impulse, inheriting platform velocity again or repeating fatigue/practice. MOVE-005's cleared Run/Sneak requests and Walk selection govern later ordinary grounded gait, not saved flight.

Fall-history fields remain MOVE-010/SAVE contracts. Source effect state is restored once under MAGIC; current allowed steering derives from validated restored effects, not a replayed takeoff grant. Raw queued input, engine support references and stale platform deltas are not durable authority. Exact schema, numeric compatibility and midflight save validation require shared fixtures.

## Technical constraints

Target: Godot 4.7.2. Separate impulse commitment, retained velocity, rate-based forces, steering and collision resolution within one coordinated physics owner. Validate finite parameters and frame-rate/step behavior against actual trajectories. Engine gravity/jump defaults, copied Unity constants or sampled shared flags are insufficient verification. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Supported grounded fresh presses start one jump; held input/rejected airborne presses cannot repeat or buffer until landing.
2. Valid takeoff snapshots reproduce the approved impulse formula, including trait nesting and actual crouch factor, subject to configured cap and verified scale.
3. Successful jumps charge/award CHAR activity once; later capability changes cannot recalculate committed impulse.
4. Ordinary air motion retains horizontal takeoff momentum; looking/gait requests/airborne crouch do not redirect or boost it.
5. Platform point velocity, including rotation, is inherited once on jump/walk-off with immediate detachment and no later pullback.
6. Vanilla adds no camera-forward boost; supported mod boost behavior cannot duplicate from repeated delivery.
7. Enhanced jumping steers via bounded acceleration without unlimited speed/platform amplification; effect loss stops steering while retaining momentum.
8. Ceiling contact cancels positive vertical velocity without a downward kick; gravity and collision continue appropriately.
9. Slow Fall blocks ordinary jumps under its declared moddable restriction; its descent/damage transitions remain explicit owner integration.
10. Gravity/downward caps behave consistently over eligible time without clearing fall history or granting immunity.
11. Pause and native restore preserve flight without catch-up, reapplied impulse/inheritance or repeated fatigue/practice; Walk selection waits for grounded gait resumption.

These are future verification criteria; no implementation or runtime tests have been performed.

## Consistency review

Reviewed against MOVE-001–008, CHAR-020, relevant CORE pause/placement contracts, MOVE catalog/architecture and twelve confirmed decisions. No direct contradiction identified. Fresh-press retention is distinct from prohibited landing buffering. Platform inertia is an explicitly selected airborne contribution, separate from gait speed. Native Walk selection does not rewrite restored velocity/takeoff gait. Airborne crouch cannot reapply its impulse multiplier. Once-per-success activity preserves CHAR accounting. Slow Fall fall-history rules, specialized takeoff and fall damage remain unresolved owner scope rather than inferred DFU parity.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Before implementation is complete resolve world-scale trajectories, validated domains/caps, steering bounds and already-fast inherited velocity treatment, rotating-platform sampling/discontinuities, ground/landing boundaries, specialized jump eligibility, Slow Fall integration, supported mod hook semantics and native flight/fall schemas. Representative jump/ceiling/platform/frame-rate/save fixtures remain required. These deferrals do not waive fresh presses, momentum preservation or once-only jump consequences.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-009-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
