# MOVE-007 — Surface motion, slopes and steps

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Traverse uneven ground and stairs reliably, with stable footing and gentle vertical camera motion. Ordinary walking respects slope and step limits while required steep dungeon connectors remain traversable through validated exceptions. Surface behavior supports mod customization without introducing vanilla sliding or material penalties.

## Confirmed requirements

MOVE-007-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record three interviews and the user's explicit qualifications. Stable footing replaces the initially suggested forced downhill sliding. Steep original dungeon connectors are user-reported context; reliable differentiation remains unresolved rather than presumed implemented.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths below are relative to the reference directory. Static inspection only; no source modifications or runtime verification.

- `Assets/Scripts/Game/Player/FrictionMotor.cs#GroundedMovement` resolves ground intent or optional downhill sliding. Its code defaults for `slideWhenOverSlopeLimit` and `slideOnTaggedObjects` are false; effective asset configuration is a separate question.
- `SetSliding` compares a downward ground sample's normal with a limit derived from controller slope limit; it also tries a contact-point fallback. The optional sliding path uses a downhill vector and `slideSpeed`.
- `Assets/Scripts/Game/Player/PlayerMoveScanner.cs#FindStep` samples below/ahead with a sphere cast, records distance and suppresses its sampling result during jumping. It does not alone establish a complete explicit step-up solver. Unity CharacterController also supplies step handling.
- `Assets/Prefabs/Player/PlayerAdvanced.prefab` declares slope limit 70 and step offset 0.5; `PlayerStandalone.prefab` declares 80 and 0.5. These differing asset values are not one verified universal gameplay setting or selected Godot defaults.
- `FrictionMotor.HeadDipHandling` adjusts standing height near some doorway/ramp geometry. Approved MOVE-006 disallows using such adjustments to bypass deliberate crouching.

## Detailed rules and behaviors

### Coordinated surface movement

Resolve all surface motion within MOVE-004's coordinated physics sequence. Use actual support, current collision shape and validated surface observations. MOVE-005 supplies gait speed and proportional direction magnitude; no diagonal or combined-device speed bonus applies.

Measure ordinary movement speed along the walkable surface. Do not preserve horizontal speed by adding an unrestricted vertical component on inclines. Connector exceptions do not increase total gait speed. Exact treatment of corners, seams and mixed normals requires fixtures; surface projection must not turn walls into walkable ground.

### Automatic steps and downward following

Automatically traverse small upward steps within a configured height only when the full player shape has clearance along the route and at the destination. Taller obstacles need another supported traversal action. Do not teleport through intervening collision or shrink posture automatically to fit. MOVE-006 remains authoritative for deliberate crouching and clearance.

While grounded, follow small downward steps within a configured distance to avoid repeated tiny falls on stairways. Larger drops transition to ordinary airborne movement. Ground following cannot pull a jumping player downward, catch arbitrary distant ground or bridge gaps without valid support. Step-up and step-down bounds are explicit tuning parameters, not assumed equal.

Automatic stair corrections must not create jump events, repeated landing/fall outcomes or activity rewards merely from repeated probe/contact delivery. MOVE-009/010 and CHAR own actual event consequences. Exact classification at the step/drop boundary requires shared fixtures.

### Walkable slopes and stable footing

Use a configurable maximum ordinary walkable angle. Ordinary uphill movement cannot bypass it by diagonal travel or repeated step attempts. Specialized climbing remains a separate eligible movement mode.

The uphill limit does not itself remove physical support. Vanilla permits stable footing on a surface that genuinely supports the player; do not automatically enter a slide mode solely because that surface is steep. If valid support is absent or lost, ordinary falling applies. This does not make all surfaces standable or uphill-walkable.

Exact support criteria, contact normals/margins and handling of mixed floor/wall contacts must be established through physics tests. Do not promise support from any tiny contact or use the walkable-angle cutoff as the only support predicate. Descending steep supported surfaces must respect validated collision/support behavior; no automatic downhill propulsion is introduced.

### Required steep dungeon connectors

Required original dungeon block/border connectors can have unusually steep geometry according to the user's report. Identify such required connectors during content preparation and assign scoped, validated traversal exceptions. Preserve the normal slope limit on other terrain and dungeon surfaces; do not make every steep dungeon polygon climbable.

Reliable identification is a required content-analysis dependency. No metadata field, geometric heuristic or existing detector has been established. Investigate representative connector assets/placements and verify identification against both required connectors and ordinary steep surfaces. If evidence cannot establish reliable identification, return the unresolved policy for design review rather than silently choosing a broad dungeon exemption.

Exceptions permit traversal without granting speed bonuses, ignoring body clearance or disabling collision. Exact exception representation and permitted angle/route rules belong to DATA/WORLD/LOC/MOVE integration. This specification approves the scoped-exception policy, not an unverified automatic classification algorithm.

### Stair camera response

Smooth vertical camera response to automatic steps in both directions while the collider follows the actual stair geometry immediately. Avoid harsh repeated down/up motion and add no extra rhythmic stair bob. Optional ordinary walking head bob remains separate AV behavior.

Keep smoothing within safe geometry; shorten or snap the visual offset when needed to prevent seeing through walls/ceilings. Reset stair smoothing on teleport/load rather than dragging the view from an old position. Camera treatment cannot move the collider, change facing or erase fall state, consistent with MOVE-003/006. Ordinary suspension pauses gameplay-linked stair response without catch-up.

Exact duration, displacement bounds, near-plane safety and interaction with crouch-height animation require rendered testing. Do not smooth real large drops as if they were stair corrections or use stale camera offset to alter gameplay reach/aim.

### Vanilla traction and modded surfaces

Vanilla ordinary ground has consistent traction. Introduce no material-based slowdown or ice-like slipping by default. Water and specialized traversal retain their own specifications.

Support explicit mod-defined surface rules for traction, gait-speed contributions and sliding eligibility/motion parameters. Sliding is optional mod behavior, not enabled by the initially suggested limited-steering slide proposal. Exact slide speed, acceleration, steering, stop conditions and state persistence require the selected mod rule's contract.

Mod surface motion remains under MOVE-004 authority; gait contributions follow MOVE-005 source ownership, validation and caps. Surface rules cannot silently bypass collision, duplicate fatigue/practice or change unsupported global physics behavior. Define stable surface identity, rule precedence, absent/invalid handling and RULE-004 provider semantics before implementation is complete; this capability does not approve arbitrary callback stacking or a general scripting framework.

## Relevant formulas and parameters

Ordinary surface-tangent voluntary speed is bounded by the selected gait speed times resolved input magnitude, with MOVE-005 modifiers/cap applied once. Classify ordinary uphill eligibility using a configured angle relative to world up, while physical support uses its separately validated criteria. Scoped connector exceptions modify traversal eligibility, not gait speed or body clearance.

No exact slope angle, upward/downward step limit, support tolerance, camera smoothing value or mod slide parameter is selected. DFU's 70/80-degree and 0.5 asset values are reference observations. Limits must be compatible with world scale, collider shape and required content.

## Required data

Resolved gait/direction; actual shape/posture; support/contact observations and surface normals; step-up/down limits; ordinary slope limit; surface identity/rules; validated connector exception identity/scope; requested/resolved displacement; stair camera offset/state; lifecycle/input gates and event/activity identity. Concrete schemas, detection/probe ordering and caches remain engineering dependencies.

## Inputs, outputs and events

Inputs: movement intent, gait target, current contacts/geometry, surface definitions and connector exceptions, mode/shape changes and placement/suspension transitions. Outputs: checked surface movement/step result, support and airborne transition context, source-owned speed contributions, safe camera response and actual activity reports. APIs/signals remain unselected. Probe hits are observations, not independent landing/practice events.

## Cross-system interactions

MOVE-004 owns motion authority, physical history and recovery; MOVE-005 gait speed/modifiers; MOVE-006 shape/clearance; MOVE-008 moving platforms; MOVE-009/010 air/fall behavior; MOVE-011/012 climbing/rappel; MOVE-026/027 placement. WORLD/LOC/DATA own geometry and connector/surface identity. AV/UI own camera presentation; CHAR consumes actual movement without passive-motion training. CORE gates suspension/readiness, SAVE restores authoritative state, MOD/RULE supply supported extension contracts.

## Edge cases and failure conditions

Test alternating stair sizes, narrow treads, ramps into low doors, seams, overhangs, sloped step tops and diagonally approached obstacles. Step logic cannot repeatedly ratchet up an otherwise forbidden slope. A missing support sample is not automatically proof of standing or permission to bridge a gap.

Stable footing on steep valid support does not imply uphill walking. Moving/lost support transitions follow MOVE-004/008. Jumping suppresses downward following; real large drops retain fall consequences. Connector exceptions must not leak to nearby ordinary surfaces. Unknown required exception data cannot silently use a broad fallback or claim traversal success.

Camera smoothing cannot expose geometry or continue old-location offsets after placement. Invalid required surface/mod definitions use approved recovery, not silent collision bypass or default sliding. Exact prolonged-contact and numeric tolerance behavior remains tested engineering work.

## Configuration and balancing options

Validated ordinary slope, step and camera-response tuning are configurable. Scoped connector exceptions and mod traction/speed/sliding rules are supported. No player-facing slope slider, default sliding, automatic ice physics or material slowdown is introduced. Numeric defaults and optional mod tuning require their owner contracts and fixtures.

## Save/load considerations

Restore authoritative pose/mode/fall state under geometry readiness; re-evaluate support and current validated surface rules. Do not persist raw collision references or replay stair contacts as new landings. Reset stair camera smoothing on teleport/load. Connector definitions retain stable content identity under DATA/SAVE compatibility; optional mod slide state requires explicit native schema/restoration policy. No generic save of probe caches or automatic safe teleport is approved.

## Technical constraints

Target: Godot 4.7.2. Use one coordinated movement sequence, full-body clearance checks, explicit support versus walkability and validated content exceptions. Concrete floor snapping, casts, contact filtering, interpolation and numerical margins are implementation choices to verify. Engine defaults alone do not establish approved behavior. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Small steps within validated limits traverse automatically only with full-route/destination clearance; taller obstacles cannot be bypassed by automatic stepping.
2. Small grounded downward steps follow support without repeated tiny falls; jumping and larger drops are not pulled down or bridged.
3. Ordinary uphill movement respects slope limit, including diagonal/repeated-step attempts.
4. Vanilla maintains stable footing on genuine support without forced slope sliding; loss of support causes normal falling.
5. Required steep connectors have validated scoped traversal exceptions; unrelated steep geometry retains normal restrictions. Reliable identification is demonstrated with representative positive/negative fixtures before coverage is claimed.
6. Surface-tangent speed respects gait/input magnitude with no incline/connector speed bonus.
7. Stairs produce gentle camera response in both directions without added rhythmic bob, collider lag or through-wall views.
8. Teleport/load resets stair-camera offsets; suspension creates no camera/movement catch-up or erased fall history.
9. Vanilla ordinary surfaces have consistent traction; supported mod rules can add explicit traction/speed/sliding behavior without bypassing authority/validation.
10. Surface transitions/probes cannot duplicate jump/landing consequences or CHAR activity rewards; missing required data follows explained owner recovery.

These are future verification criteria; no runtime/physics/rendered tests or implementation have been performed.

## Consistency review

Reviewed against MOVE-001–006, relevant CORE suspension/placement requirements, MOVE catalog/architecture and nine interview decisions. No direct contradiction identified. Explicit user qualifications supersede forced sliding. Stable support and uphill walkability are separate, so ordinary angle limits coexist with stationary steep footing. Scoped connector policy preserves required routes without broadly relaxing collision/slope rules. Camera smoothing remains presentation and deliberate crouching remains required. Modded traction/sliding capabilities do not introduce vanilla penalties or approve unspecified provider stacking.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Required dependencies: reliable connector identification and scoped metadata; exact slope/step/support values and query ordering; surface-tangent handling at seams; stair/air/fall event boundaries; camera safety/tuning and crouch interaction; surface rule identity/precedence/mod lifecycle; native mod slide persistence; representative terrain/dungeon/moving-geometry and rendered fixtures. Connector differentiation is unresolved work, not an assumed future success; return for design review if reliable identification cannot be established.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-007-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented connector-identification, tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
