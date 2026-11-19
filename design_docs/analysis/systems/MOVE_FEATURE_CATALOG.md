# MOVE feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Source paths are relative to `Assets/Scripts/`. Symbols follow `#`. Complexity estimates review scope. Confidence rates the static trace.

## MOVE-001 — Action polling

- **Parent subsystem** — Controls
- **Purpose** — Turn device input into gameplay actions.
- **Existing implementation** — InputManager polls keyboard and axes and exposes held, started and completed actions. It also supplies movement and look axes and controller cursor handling.
- **Source** — `Game/InputManager.cs#PollInput`, `Game/InputManager.cs#ActionStarted`, `Game/InputManager.cs#ActionComplete`, `Game/InputManager.cs#UpdateControllerCursorPosition`
- **Inputs and outputs** — Device state → action edges and axes
- **Dependencies** — CORE-016, UI
- **Edge cases and interactions** — Check pause/resume and multiple devices pressing the same action.
- **Design questions** — Which inputs should be buffered or suppressed across UI transitions?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-06); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-001 specification](../../design/systems/MOVE/MOVE-001.md), finalized v1 under MOVE-001-A01. No implementation is authorized.

## MOVE-002 — Binding profiles

- **Parent subsystem** — Controls
- **Purpose** — Let players configure movement and interaction controls.
- **Existing implementation** — InputManager exposes primary and secondary bindings, combination codes, controller UI bindings and axis inversion. It saves and loads keybind data separately from gameplay state.
- **Source** — `Game/InputManager.cs#SetBinding`, `Game/InputManager.cs#GetComboCode`, `Game/InputManager.cs#SaveKeyBinds`, `Game/InputManager.cs#LoadKeyBinds`
- **Inputs and outputs** — Profile and reassignment → active bindings
- **Dependencies** — UI, CORE-003
- **Edge cases and interactions** — Verify modifier conflicts and restoration of deliberately removed bindings.
- **Design questions** — How should conflicting and unmapped actions be handled?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-06); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-002 specification](../../design/systems/MOVE/MOVE-002.md), finalized v1 under MOVE-002-A01. No implementation is authorized.

## MOVE-003 — View and cursor control

- **Parent subsystem** — Controls
- **Purpose** — Aim the player view or operate the cursor.
- **Existing implementation** — PlayerMouseLook applies look and smoothing and exposes facing setters. Activation can use cursor ray or camera forward. Startup config supplies sensitivity, inversion and smoothing.
- **Source** — `Game/PlayerMouseLook.cs#ApplyLook`, `Game/PlayerMouseLook.cs#ApplySmoothing`, `Game/PlayerMouseLook.cs#SetFacing`, `Game/PlayerActivate.cs#Update`
- **Inputs and outputs** — Look input, facing and cursor mode → camera/player orientation and targeting ray
- **Dependencies** — UI, CORE-006, COMBAT
- **Edge cases and interactions** — Check smoothing at different frame rates and input handoff when windows close.
- **Design questions** — Which aiming modes and smoothing options should be supported?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-06); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-003 specification](../../design/systems/MOVE/MOVE-003.md), finalized v1 under MOVE-003-A01. No implementation is authorized.

## MOVE-004 — Ground motor and movement arbitration

- **Parent subsystem** — Ground locomotion
- **Purpose** — Coordinate which movement logic is active.
- **Existing implementation** — FixedUpdate takes grounding from collision flags, runs forward/head scans, invokes rappel and climb checks on foot, and yields ordinary movement during levitation, swimming or climbing. Cancellation clears motion, platform and fall state.
- **Source** — `Game/PlayerMotor.cs#FixedUpdate`, `Game/PlayerMotor.cs#ResetPlayerState`
- **Inputs and outputs** — Input, collision and motor flags → selected movement path
- **Dependencies** — CHAR, MAGIC, TIME
- **Edge cases and interactions** — Freeze countdown and cancellation return early. The hanging checks are commented out in this dispatcher.
- **Design questions** — Which states can overlap, and which owns movement when they do?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-06); documented engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-004 specification](../../design/systems/MOVE/MOVE-004.md), finalized v1 under MOVE-004-A01. No implementation is authorized.

## MOVE-005 — Walk, run and sneak speed

- **Parent subsystem** — Ground locomotion
- **Purpose** — Resolve ordinary gait and speed.
- **Existing implementation** — PlayerSpeedChanger captures input, applies adjustments and exposes separate walk/run calculations and modifier registration. Running eligibility has a riding-related check. Toggle sneak is applied from startup settings.
- **Source** — `Game/Player/PlayerSpeedChanger.cs#CaptureInputSpeedAdjustment`, `Game/Player/PlayerSpeedChanger.cs#ApplyInputSpeedAdjustment`, `Game/Player/PlayerSpeedChanger.cs#GetWalkSpeed`, `Game/Player/PlayerSpeedChanger.cs#GetRunSpeed`
- **Inputs and outputs** — Gait, settings, character and modifiers → speed
- **Dependencies** — CHAR-020, CORE-006, MAGIC, MOD
- **Edge cases and interactions** — Audit modifier stacking and the difference between a requested run and actual movement.
- **Design questions** — Should running and sneaking be hold, toggle or both?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-06); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-005 specification](../../design/systems/MOVE/MOVE-005.md), finalized v1 under MOVE-005-A01. No implementation is authorized.

## MOVE-006 — Crouch and clearance

- **Parent subsystem** — Ground locomotion
- **Purpose** — Coordinate stance with camera and controller height.
- **Existing implementation** — PlayerHeightChanger selects height actions and has distinct crouch, stand, mount, dismount and sinking paths. Crouch lowers camera before controller resizing. Stand adjusts controller height first.
- **Source** — `Game/Player/PlayerHeightChanger.cs#DecideHeightAction`, `Game/Player/PlayerHeightChanger.cs#DoCrouch`, `Game/Player/PlayerHeightChanger.cs#DoStand`, `Game/Player/PlayerMoveScanner.cs#FindHeadHit`
- **Inputs and outputs** — Stance, overhead clearance and movement mode → camera and controller height
- **Dependencies** — WORLD, LOC, UI
- **Edge cases and interactions** — Test low ceilings, crouched swimming and restoration after load.
- **Design questions** — When should stand or dismount wait for clearance?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-07); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-006 specification](../../design/systems/MOVE/MOVE-006.md), finalized v1 under MOVE-006-A01. No implementation is authorized.

## MOVE-007 — Surface motion, slopes and steps

- **Parent subsystem** — Ground locomotion
- **Purpose** — Move along floors and traverse small obstacles.
- **Existing implementation** — The grounded path calls FrictionMotor.GroundedMovement, then scans for steps before movement. The motor tracks exterior static geometry, water and path state separately.
- **Source** — `Game/PlayerMotor.cs#FixedUpdate`, `Game/Player/FrictionMotor.cs#GroundedMovement`, `Game/Player/PlayerMoveScanner.cs#FindStep`
- **Inputs and outputs** — Move vector, collision geometry and surface samples → adjusted movement and surface flags
- **Dependencies** — WORLD, LOC, AV
- **Edge cases and interactions** — Exact step, slope and layer behavior depends on physics and serialized parameters.
- **Design questions** — Which surfaces should affect traction and step-up?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-07); documented connector-identification, tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-007 specification](../../design/systems/MOVE/MOVE-007.md), finalized v1 under MOVE-007-A01. No implementation is authorized.

## MOVE-008 — Moving platforms and collision consequences

- **Parent subsystem** — Ground locomotion
- **Purpose** — Maintain contact with moving geometry.
- **Existing implementation** — PlayerGroundMotor moves with the active platform and supports clearing its reference. PlayerMotor receives controller collision callbacks. PlayerCrush and PlayerCollisionHandler provide separate collision consequence paths.
- **Source** — `Game/Player/PlayerGroundMotor.cs#MoveWithMovingPlatform`, `Game/Player/PlayerGroundMotor.cs#ClearActivePlatform`, `Game/PlayerMotor.cs#OnControllerColliderHit`, `Game/PlayerCollisionHandler.cs#OnCharacterCollided`, `Game/PlayerCrush.cs`
- **Inputs and outputs** — Platform motion and collision events → movement and collision handling
- **Dependencies** — LOC, CHAR, COMBAT
- **Edge cases and interactions** — Verify platform rotation, stationary push and crush scene wiring.
- **Design questions** — When should moving geometry carry, push or damage the player?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-07); documented mechanism-testing, tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-008 specification](../../design/systems/MOVE/MOVE-008.md), finalized v1 under MOVE-008-A01. No implementation is authorized.

## MOVE-009 — Jump, air control and gravity

- **Parent subsystem** — Vertical locomotion
- **Purpose** — Handle intentional jumps and unsupported motion.
- **Existing implementation** — AcrobatMotor handles jump input on grounded updates, initializes falling and checks air control in airborne updates, applies gravity and handles overhead hits before ground-motor movement.
- **Source** — `Game/Player/AcrobatMotor.cs#HandleJumpInput`, `Game/Player/AcrobatMotor.cs#CheckAirControl`, `Game/Player/AcrobatMotor.cs#ApplyGravity`, `Game/Player/AcrobatMotor.cs#HitHead`
- **Inputs and outputs** — Input, grounding, movement speed and collision → vertical motion
- **Dependencies** — CHAR-020, MAGIC, LOC
- **Edge cases and interactions** — Inspect jump effect limits, ceiling impacts and air-control settings in play.
- **Design questions** — How should momentum and control change after leaving the ground?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-07); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-009 specification](../../design/systems/MOVE/MOVE-009.md), finalized v1 under MOVE-009-A01. No implementation is authorized.

## MOVE-010 — Landing and fall damage

- **Parent subsystem** — Vertical locomotion
- **Purpose** — Resolve consequences when returning to ground.
- **Existing implementation** — The ground path checks falling damage. AcrobatMotor tracks and adjusts fall start and exposes fall reset. PlayerFootsteps contains landing alert/damage handlers.
- **Source** — `Game/Player/AcrobatMotor.cs#CheckFallingDamage`, `Game/Player/AcrobatMotor.cs#AdjustFallStart`, `Game/Player/AcrobatMotor.cs#ClearFallingDamage`, `Game/PlayerFootsteps.cs#ApplyPlayerFallDamage`
- **Inputs and outputs** — Fall distance, landing and resets → feedback and possible health loss
- **Dependencies** — CHAR-018, CHAR-023, MAGIC, AV
- **Edge cases and interactions** — Check moving platforms, water, slowfall and origin shifts at threshold distances.
- **Design questions** — Which landings should damage the player or be softened?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-07); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-010 specification](../../design/systems/MOVE/MOVE-010.md), finalized v1 under MOVE-010-A01. No implementation is authorized.

## MOVE-011 — Wall climb entry and movement

- **Parent subsystem** — Vertical locomotion
- **Purpose** — Transition onto walls and move along them.
- **Existing implementation** — ClimbingMotor checks entry, samples climbed wall information, controls climb movement and can stop or eject the player. It exposes a skill check and restores advanced climbing data.
- **Source** — `Game/Player/ClimbingMotor.cs#ClimbingCheck`, `Game/Player/ClimbingMotor.cs#ClimbMovement`, `Game/Player/ClimbingMotor.cs#ClimbingSkillCheck`, `Game/Player/ClimbingMotor.cs#RestoreSaveData`
- **Inputs and outputs** — Foot state, wall probes, skill and saved state → climb, slip or exit
- **Dependencies** — RULE-011, CHAR-012, LOC, SAVE, MAGIC
- **Edge cases and interactions** — Trace geometry tolerances, lip transitions and interruptions separately. Validate climbing restoration with actual walls.
- **Design questions** — What should allow attachment, cornering and safe release?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-07); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-011 specification](../../design/systems/MOVE/MOVE-011.md), finalized v1 under MOVE-011-A01. No implementation is authorized.

## MOVE-012 — Rappel and edge transitions

- **Parent subsystem** — Vertical locomotion
- **Purpose** — Handle staged movement around ledges.
- **Existing implementation** — The on-foot motor invokes RappelChecks before climbing. RappelMotor uses direction and stage enums and separate curl paths for movement around edges.
- **Source** — `Game/Player/RappelMotor.cs#InitialSetRappelType`, `Game/Player/RappelMotor.cs#RappelChecks`, `Game/Player/RappelMotor.cs#ResetRappelState`, `Game/PlayerMotor.cs#FixedUpdate`
- **Inputs and outputs** — Player movement, ledge geometry and stage → staged traversal
- **Dependencies** — LOC, CHAR, MOVE-011
- **Edge cases and interactions** — Verify eligible edge geometry and which conditions return control to climbing or ground movement.
- **Design questions** — Which ledge transitions should be explicit actions?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-07); documented geometry, tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-012 specification](../../design/systems/MOVE/MOVE-012.md), finalized v1 under MOVE-012-A01. No implementation is authorized.

## MOVE-013 — Levitation

- **Parent subsystem** — Special locomotion
- **Purpose** — Provide effect-driven three-dimensional movement.
- **Existing implementation** — LevitateMotor accepts camera-relative movement and explicit ascend/descend controls. Paralysis exits the movement update. The ordinary motor yields while levitating.
- **Source** — `Game/LevitateMotor.cs#Update`, `Game/LevitateMotor.cs#SetLevitating`, `Game/PlayerMotor.cs#FixedUpdate`
- **Inputs and outputs** — Levitation state, input and camera → free movement
- **Dependencies** — MAGIC, CHAR, LOC
- **Edge cases and interactions** — Test simultaneous swimming and levitation and the effect expiring over a fall.
- **Design questions** — How should ending levitation transfer velocity and grounding?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-07); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-013 specification](../../design/systems/MOVE/MOVE-013.md), finalized v1 under MOVE-013-A01. No implementation is authorized.

## MOVE-014 — Water entry and submersion

- **Parent subsystem** — Special locomotion
- **Purpose** — Determine water movement and breath context.
- **Existing implementation** — Dungeon block water level drives separate swimming and submersion comparisons. Entry can play a splash. Underwater checks are gated by active gameplay. Exterior water tile handling is a distinct path.
- **Source** — `Game/PlayerEnterExit.cs#Update`, `Game/PlayerMotor.cs#OnShallowWaterTile`, `Game/PlayerFootsteps.cs#PlayLargeSplash`
- **Inputs and outputs** — Block height, player height and tile context → swimming and submerged flags
- **Dependencies** — WORLD, LOC, CHAR, AV, CORE-017
- **Edge cases and interactions** — Separate thresholds and offsets can create surface boundary cases. Trace breath damage and exterior water fixtures.
- **Design questions** — How should surface entry, exiting water and underwater breath be distinguished?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-07); documented geometry, tuning and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-014 specification](../../design/systems/MOVE/MOVE-014.md), finalized v1 under MOVE-014-A01. No implementation is authorized.

## MOVE-015 — Swimming control and buoyancy

- **Parent subsystem** — Special locomotion
- **Purpose** — Move in water under weight and effect restrictions.
- **Existing implementation** — LevitateMotor suppresses camera-derived vertical swim motion without levitation. Explicit up/down input controls depth. Heavy swimmers can sink unless climbing, water walking or exempt via god mode. Water walking uses ordinary movement speed.
- **Source** — `Game/LevitateMotor.cs#Update`, `Game/LevitateMotor.cs#AddMovement`, `Game/Player/PlayerSpeedChanger.cs#GetSwimSpeed`
- **Inputs and outputs** — Water state, carried weight, effects and input → swim vector and speed
- **Dependencies** — CHAR-020, ITEM, MAGIC, MOVE-014
- **Edge cases and interactions** — A surface guard suppresses upward movement near the waterline. Verify shallow water and climb takeover.
- **Design questions** — How should weight, water walking and vertical controls combine?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-07); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-015 specification](../../design/systems/MOVE/MOVE-015.md), finalized v1 under MOVE-015-A01. No implementation is authorized.

## MOVE-016 — Mount and transport transitions

- **Parent subsystem** — Special locomotion
- **Purpose** — Switch between on-foot and vehicle or mount modes.
- **Existing implementation** — TransportManager exposes mount toggle and ownership checks and reacts to world transitions. PlayerHeightChanger has mount/dismount geometry actions. Ordinary climbing and rappel checks are gated to on-foot mode.
- **Source** — `Game/TransportManager.cs#ToggleMount`, `Game/TransportManager.cs#HandleTransition`, `Game/TransportManager.cs#HasHorse`, `Game/Player/PlayerHeightChanger.cs#DoMount`
- **Inputs and outputs** — Ownership, transport request and world context → transport mode and controller height
- **Dependencies** — TIME, ITEM, ECON, LOC, AV
- **Edge cases and interactions** — Trace eligibility and speed by mode. Ship travel and ownership remain TIME/ECON scope.
- **Design questions** — Where should mounts and carts be usable?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-07); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-016 specification](../../design/systems/MOVE/MOVE-016.md), finalized v1 under MOVE-016-A01. No implementation is authorized.

## MOVE-017 — Movement feedback

- **Parent subsystem** — Presentation
- **Purpose** — Communicate gait, surface and impact.
- **Existing implementation** — PlayerFootsteps handles movement audio, splashes and landing cues. HeadBobber selects style and updates view offsets separately from collision movement.
- **Source** — `Game/PlayerFootsteps.cs#FixedUpdate`, `Game/PlayerFootsteps.cs#HardFallAlert`, `Game/Player/HeadBobber.cs#GetBobbingStyle`
- **Inputs and outputs** — Movement and settings → sound and camera feedback
- **Dependencies** — AV, UI, WORLD
- **Edge cases and interactions** — Verify authored assets, surface selection and disabling camera motion.
- **Design questions** — Which cues should remain when bobbing is disabled?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-07); documented tuning, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-017 specification](../../design/systems/MOVE/MOVE-017.md), finalized v1 under MOVE-017-A01. No implementation is authorized.

## MOVE-018 — Targeting and dispatch order

- **Parent subsystem** — Interaction
- **Purpose** — Route one activation ray to applicable handlers.
- **Existing implementation** — PlayerActivate casts from cursor or crosshair and checks quest resource, building, doors, action, loot, board and NPC handlers before fixtures and custom hooks. Several checks are independent. A pending touch cast suppresses mobile NPC and enemy handlers in this section.
- **Source** — `Game/PlayerActivate.cs#Update`, `Game/PlayerActivate.cs#SetClickDelay`
- **Inputs and outputs** — Activation input, ray hit, mode and spell state → handler calls
- **Dependencies** — UI, MAGIC, LOC, QUEST
- **Edge cases and interactions** — One collider can satisfy multiple checks. Out-of-range quest hit or missing building summary can return early.
- **Design questions** — Should an activation be exclusive or allow multiple consumers?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented routing, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-018 specification](../../design/systems/MOVE/MOVE-018.md), finalized v1 under MOVE-018-A01. No implementation is authorized.

## MOVE-019 — Interaction modes and information

- **Parent subsystem** — Interaction
- **Purpose** — Choose what activation means.
- **Existing implementation** — Mode switching cycles Steal, Grab, Info and Talk, with optional feedback. Building and NPC handlers expose information paths. Non-person quest clicks are suppressed in Info mode.
- **Source** — `Game/PlayerActivate.cs#ChangeInteractionMode`, `Game/PlayerActivate.cs#NextInteractionMode`, `Game/PlayerActivate.cs#PresentNPCInfo`, `Game/PlayerActivate.cs#ActivateBuilding`
- **Inputs and outputs** — Mode selection and hit context → mode, text or alternate action
- **Dependencies** — UI, NPC, LOC, QUEST
- **Edge cases and interactions** — Verify mode behavior by target type and persistence across save/load.
- **Design questions** — Which targets should have explicit actions instead of mode-dependent behavior?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented mapping, inspection, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-019 specification](../../design/systems/MOVE/MOVE-019.md), finalized v1 under MOVE-019-A01. No implementation is authorized.

## MOVE-020 — Exterior access and trespass

- **Parent subsystem** — Interaction
- **Purpose** — Evaluate building access before transitioning.
- **Existing implementation** — Static door handling uses building directory, lock value and unlock checks. Entry interacts with shop opening, active quests, bashing and magic. Lockpicking and some trespass paths can tally skill or trigger guards.
- **Source** — `Game/PlayerActivate.cs#ActivateStaticDoor`, `Game/PlayerActivate.cs#BuildingIsUnlocked`, `Game/PlayerActivate.cs#IsActiveQuestBuilding`, `Game/PlayerActivate.cs#AttemptExteriorDoorBash`, `Game/PlayerActivate.cs#HandleOpenEffectOnExteriorDoor`
- **Inputs and outputs** — Building, time, quest and action → entry, feedback or crime
- **Dependencies** — RULE-009, LAW, LOC, TIME, MAGIC, QUEST
- **Edge cases and interactions** — Verify quest exceptions, owned/rented properties and operation order on locked doors.
- **Design questions** — Which entry methods should count as trespass?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented policy, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-020 specification](../../design/systems/MOVE/MOVE-020.md), finalized v1 under MOVE-020-A01. No implementation is authorized.

## MOVE-021 — Interior doors, mechanisms and fixtures

- **Parent subsystem** — Interaction
- **Purpose** — Activate authored objects in place.
- **Existing implementation** — Action-door handling is distinct from static building doors. A direct action record can receive a trigger within default range. Separate handling covers ladders and bookshelves and Open/Lock spell hooks.
- **Source** — `Game/PlayerActivate.cs#ActivateActionDoor`, `Game/PlayerActivate.cs#ActivateLaddersAndShelves`, `Game/PlayerActivate.cs#HandleOpenEffect`, `Game/PlayerActivate.cs#HandleLockEffect`, `Internal/DaggerfallAction.cs`
- **Inputs and outputs** — Hit, action record and effect state → door, fixture or authored action response
- **Dependencies** — LOC, MAGIC, ITEM, QUEST
- **Edge cases and interactions** — Classic action chains require map fixtures and Unity collider wiring. Verify whether a single hit invokes both door and action logic.
- **Design questions** — Which fixtures should expose alternate actions?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented collision-testing, engineering and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-021 specification](../../design/systems/MOVE/MOVE-021.md), finalized v1 under MOVE-021-A01. No implementation is authorized.

## MOVE-022 — Loot and property prompts

- **Parent subsystem** — Interaction
- **Purpose** — Route pickup and container access.
- **Existing implementation** — Activation identifies DaggerfallLoot and invokes container handling, with branches for private property, empty corpse cleanup and dungeon wagon access.
- **Source** — `Game/PlayerActivate.cs#ActivateLootContainer`, `Game/PlayerActivate.cs#PrivateProperty_OnButtonClick`, `Game/PlayerActivate.cs#DisableEmptyCorpseContainer`, `Game/PlayerActivate.cs#DungeonWagonAccess_OnButtonClick`
- **Inputs and outputs** — Loot hit, ownership, mode and context → prompt, inventory interaction or cleanup
- **Dependencies** — ITEM, LAW, UI, LOC
- **Edge cases and interactions** — Trace which containers require prompts and what happens if contents or context change while a prompt is open.
- **Design questions** — When should opening a container count as taking property?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented ownership, content, transfer, persistence and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-022 specification](../../design/systems/MOVE/MOVE-022.md), finalized v1 under MOVE-022-A01. No implementation is authorized.

## MOVE-023 — NPC, quest and board activation

- **Parent subsystem** — Interaction
- **Purpose** — Hand clicked actors and markers to dialogue or quests.
- **Existing implementation** — Static/mobile NPC and enemy handlers dispatch based on context. StaticNPCClick records LastNPCClicked and checks quest resource clicks. Bulletin boards have a separate handler.
- **Source** — `Game/PlayerActivate.cs#ActivateStaticNPC`, `Game/PlayerActivate.cs#ActivateMobileNPC`, `Game/PlayerActivate.cs#ActivateMobileEnemy`, `Game/PlayerActivate.cs#StaticNPCClick`, `Game/PlayerActivate.cs#ActivateBulletinBoard`
- **Inputs and outputs** — Target, mode and quest context → interaction handoff
- **Dependencies** — NPC, QUEST, UI
- **Edge cases and interactions** — Verify when a quest consumes the click and suppresses ordinary dialogue or service.
- **Design questions** — How should competing quest and service interactions be prioritized?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented routing, content, persistence and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-023 specification](../../design/systems/MOVE/MOVE-023.md), finalized v1 under MOVE-023-A01. No implementation is authorized.

## MOVE-024 — Pickpocket execution

- **Parent subsystem** — Interaction
- **Purpose** — Resolve theft interaction after target selection.
- **Existing implementation** — Pickpocket tallies practice and calculates chance with FormulaHelper using the optional enemy entity. A detected path sets Pickpocketing crime and can spawn guards.
- **Source** — `Game/PlayerActivate.cs#Pickpocket`, `Game/Formulas/FormulaHelper.cs#CalculatePickpocketingChance`
- **Inputs and outputs** — Target and skill → theft outcome, tally and possible crime
- **Dependencies** — RULE-010, CHAR-012, ITEM, LAW, NPC
- **Edge cases and interactions** — Check civilian and hostile target differences and empty inventories.
- **Design questions** — What should happen when theft fails or there is nothing to take?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented identity, transaction, reaction, persistence and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-024 specification](../../design/systems/MOVE/MOVE-024.md), finalized v1 under MOVE-024-A01. No implementation is authorized.

## MOVE-025 — Mod and component activation

- **Parent subsystem** — Interaction
- **Purpose** — Allow content to implement custom clicks.
- **Existing implementation** — Registration supports model ID or texture archive/record and an activation distance. Dispatch normalizes the hit object name, checks registered range and separately invokes IPlayerActivable on the hit transform.
- **Source** — `Game/PlayerActivate.cs#RegisterCustomActivation`, `Game/PlayerActivate.cs#HandleRegisterCustomActivation`, `Game/PlayerActivate.cs#Update`
- **Inputs and outputs** — Registered keys or component plus hit → custom callback
- **Dependencies** — MOD, DATA, LOC
- **Edge cases and interactions** — Object naming and collider ownership affect lookup. A matched mod callback and component callback can both run.
- **Design questions** — Should custom handlers augment or consume built-in activation?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 (2026-11-08); documented hook, provider, lifetime, persistence and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-025 specification](../../design/systems/MOVE/MOVE-025.md), finalized v1 under MOVE-025-A01. No implementation is authorized.

## MOVE-026 — Building and dungeon doorway traversal

- **Parent subsystem** — Transitions
- **Purpose** — Move the player between world contexts.
- **Existing implementation** — PlayerEnterExit has separate building and dungeon entry/exit paths, toggles world parents and exposes pre-transition, success and failure notifications. Several exit paths can fade.
- **Source** — `Game/PlayerEnterExit.cs#TransitionInterior`, `Game/PlayerEnterExit.cs#TransitionExterior`, `Game/PlayerEnterExit.cs#TransitionDungeonInterior`, `Game/PlayerEnterExit.cs#TransitionDungeonExterior`, `Game/PlayerEnterExit.cs#RaiseOnFailedTransition`
- **Inputs and outputs** — Door, current context and fade choice → position/context switch and events
- **Dependencies** — LOC, WORLD, CORE, QUEST, AV
- **Edge cases and interactions** — Trace invalid doors, missing markers and notification ordering with location fixtures.
- **Design questions** — What should remain usable when a doorway transition fails?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented mapping, readiness, placement, persistence and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-026 specification](../../design/systems/MOVE/MOVE-026.md), finalized v1 under MOVE-026-A01. No implementation is authorized.

## MOVE-027 — Spawn and placement recovery

- **Parent subsystem** — Transitions
- **Purpose** — Restore player coordinates and standing state.
- **Existing implementation** — Respawn and saved-position helpers handle positioning across world contexts. Dungeon marker helpers and motor ground searches offer placement/standing correction.
- **Source** — `Game/PlayerEnterExit.cs#RespawnPlayer`, `Game/PlayerEnterExit.cs#RestorePositionHelper`, `Game/PlayerEnterExit.cs#MovePlayerToMarker`, `Game/PlayerMotor.cs#FindGroundPosition`, `Game/PlayerMotor.cs#FixStanding`
- **Inputs and outputs** — Saved/target coordinates, world context and markers → player pose and placement
- **Dependencies** — CORE-011, CORE-013, SAVE, WORLD, LOC
- **Edge cases and interactions** — Check fall-state reset, obstructed markers, world-origin changes and load ordering.
- **Design questions** — What is the fallback when a restored position is invalid?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 (2026-11-08); documented tuning, geometry, persistence and cross-owner dependencies remain open.

### My Intended Specification

See [approved MOVE-027 specification](../../design/systems/MOVE/MOVE-027.md), finalized v1 under MOVE-027-A01. No implementation is authorized.

## Classic inheritance and unresolved evidence

- Dungeon water levels and object action records originate in classic-style location data. DFU explicitly comments on a classic-to-Unity position offset in water checks and uses Unity controllers, colliders and camera transforms to realize movement. Actual original movement parity remains unknown. The swim-speed comment describes classic vertical speed as fixed, while the branch delegates speed to PlayerSpeedChanger.
- Review input and motor arbitration first, then run movement fixtures for slopes, stairs, ceilings, platform motion, climbing lips and water transitions. Follow with a composite collider, locked building, loot container and quest NPC to test activation order. Verify transitions with representative classic blocks and native saves.
- Runtime physics, serialized component configuration, collision masks, asset geometry and mod activation combinations remain unverified. The catalog separates locomotion, interaction dispatch and world handoffs. Location construction, NPC dialogue, effects, loot contents and legal outcomes remain under their owning systems.
