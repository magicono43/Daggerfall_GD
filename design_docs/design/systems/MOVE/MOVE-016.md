# MOVE-016 — Mount and transport transitions

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Switch safely between walking, horse and cart, preserving convenient inventory-based vanilla access and mounted overworld-water travel. Owned ship boarding teleports to its static offshore destination. Explicit mod contracts can change access, lifecycle and compatibility without silently enabling those mechanics in vanilla.

## Confirmed requirements

MOVE-016-D01–D12 in [the decision log](../../GAMEPLAY_DECISIONS.md) record four interviews with explicit vanilla-water/ship and modding clarifications. These qualify proposed restrictions: surface-only exterior water remains traversable mounted; ship boarding remains teleportation, not mandatory simulated travel.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/TransportManager.cs#HasHorse`/`HasCart` inspect transportation inventory items. `ToggleMount` dismounts Horse/Cart or selects Horse before Cart.
- `HandleTransition` sets Foot on pre-transition to building/dungeon interiors. `UpdateMode` changes riding flags, artwork/audio and special Ship teleport/return handling. Ship is explicitly not a persistent player transport mode.
- `IsOnShip` combines recorded boarding position and owned ship coordinates. Boarding stores return context and caches scene, teleports to ship coordinates and restores cached scene; disembarking restores prior context. Terrain sampler changes have a source fallback not automatically approved here.
- `Game/Player/PlayerHeightChanger.cs#DoMount`/`DoDismount` change controller/camera height. `PlayerSpeedChanger.GetBaseSpeed` selects riding bases, and `AcrobatMotor.HandleJumpInput` supplies horse impulse 1.75 and blocks cart jumping.

Target behavior below adds validated mode commitment, remembered selection and explicit policy/mod ownership. Source fade timing, terrain fallback and scene-cache implementation are not required architecture.

## Detailed rules and behaviors

### Access and selection

Vanilla inventory ownership supplies horse/cart access without a nearby simulated animal/parked vehicle. No feed, horse health or retrieval system is introduced. ITEM/ECON own purchase, item identity and wagon storage.

Provide a rebindable quick toggle plus explicit Horse/Cart UI choices. Quick toggle dismounts when mounted; otherwise choose last successfully selected owned transport, initially Horse then Cart. Unavailable requests explain the reason and preserve current mode. Persist selection preference/context under an explicit settings/SAVE schema rather than incidental inventory iteration.

Support modded access/requirements and mount lifecycle capabilities, including nearby presence, resource/health/retrieval behavior where provided by a validated owner contract. This capability request does not define those added systems' formulas, UI or save schemas. They remain disabled in vanilla.

### Safe mount/dismount

Mount only from valid supported Foot movement with clearance for the complete mounted shape. Dismount requires a valid on-foot shape/support. Use MOVE-004 coordination and MOVE-006 clearance; rejection leaves mode intact, without fall reset or ceiling bypass. Exact mounted dimensions, base-position preservation, velocity transfer and camera interpolation require fixtures.

Prohibit voluntary mount/dismount while airborne, climbing, rappelling or levitating. Mode compatibility is moddable through declared rules. Changing shape cannot erase motion history or create a jump boost. Riding crouch/sneak posture combinations require explicit support rather than copying ordinary Foot controls.

### Speed, jumps and consequences

Moddable reference baselines: Horse speed=(live Speed+375)/39.5; Cart=(live Speed+250)/39.5. Ordinary Run/Sneak toggles do not change mounted speed. Preserve proportional input and cap diagonal magnitude. Validate scale, numeric domains, contributions and safe speed bounds before implementation; no hidden extended-stat overflow is allowed.

Horse jump impulse baseline=4.5*1.75, independent of rider Jumping/Athleticism impulse bonuses. Cart cannot jump in vanilla. Apply MOVE-009 fresh-press, gravity, ceiling and momentum rules, subject to declared mounted shape/limits. Horse jumps charge CHAR-020 ordinary jump cost/practice once; impulse bonus independence does not remove approved activity-cost trait handling.

Mounted falls damage the player under MOVE-010 without separate vanilla horse health. Riding alone awards no Running practice. Exact riding periodic fatigue classification remains CHAR/MOVE integration; do not invent an extra mount drain. Protection/weapon/interaction compatibility outside these decisions remains its owner's specification.

### Water and interiors

Horse/Cart retain travel across vanilla surface-only exterior water. This is an explicit compatibility policy, not proof of modeled depth or permission to descend underwater. MOVE-014's representation and safe water-entry rules remain applicable; exact mounted surface support/shape observations need fixtures.

No mounted underwater travel in depth-enabled water initially. Ordinary shore entry requiring swimming needs safe dismount first; if unavailable, block voluntary entry rather than create an invisible surface. Forced falls, rising/moving water and invalid restored contexts need explicit checked transition/recovery without fall immunity or arbitrary teleport. Mods may supply mounted swimming and different water compatibility.

Commit Foot with successful building/dungeon entry after destination on-foot placement validation. Cancelled/rejected entry leaves mounted mode outside. Exiting remains Foot, with no automatic remount. Interior mounting restrictions must be represented by explicit location policy consistent with these entry rules; exact supported location inventory remains LOC integration.

### Ships

Vanilla owned ship is a static offshore destination. Ownership-gated boarding teleports there and records validated return context; disembarking returns through placement/readiness rules. No directly controlled sailing or added travel-time simulation is introduced. MAGIC/transport effects cannot bypass required geometry/readiness.

ECON/LOC own ship ownership and destination/interior data. Boarding/access and ship behavior are moddable through declared contracts; alternate moving/sailing behavior requires its own movement/content/save implementation, not an assumed capability of a teleport flag. Validate return context and required terrain/content before commitment; no source random-marker fallback is approved automatically.

### Ownership, pause and restoration

Prevent voluntary sale/removal of the currently ridden transport until dismounted, with an explanation. Script/mod invalidation uses explicit safe dismount/recovery rather than deleting mounted state midair. This ownership-change policy is moddable. Exact sale/transfer transaction and invalidation ordering remain ITEM/ECON integration.

Pause preserves mode/state and suspends gameplay-linked transport movement/audio under CORE/AV rules. Native saves retain selected transport and ship return context. Restore ownership, geometry and shape before movement without replaying mount/board/cost/travel. Missing required definitions or invalid return context invoke explicit placement/compatibility recovery.

## Relevant formulas and parameters

Reference Horse/Cart speed and horse impulse are listed above. Verify Godot scale and collision compatibility rather than assuming identical numerical pace. Numeric domains, maximums, mounted shapes, camera timing and optional mod resource values remain validated dependencies. No feed/horse-health/sailing formula is selected.

## Required data

Current Foot/Horse/Cart mode; owned transport identities; last successful selection; eligibility/rejection reason; target shape/support; motion/history; validated location/water policy; ship ownership/destination/return context; lifecycle and owned transition state. Mod lifecycle resources require their own versioned definitions and durable identities.

## Inputs, outputs and events

Inputs: toggle/explicit selection, ownership changes, support/clearance, water/location entry, jump, ship boarding/return and pause/restore. Outputs: validated committed mode/shape, target speed, one-time jump activity, transport presentation and checked placement/recovery. APIs/signals remain unselected. A rejected mode request is not a committed mount or cost event.

## Cross-system interactions

MOVE-001/002 bindings, MOVE-003 view, MOVE-004 authority, MOVE-005 speed conventions, MOVE-006 shapes, MOVE-008 platform transport context, MOVE-009/010 jumps/falls and MOVE-013–015 mode/water semantics. ITEM/ECON own ownership/storage, LOC/WORLD ships/interiors/geometry, CHAR activity/health, CORE placement/pause, SAVE restoration and MOD/DATA/RULE supported policies. Fast travel, wagon inventory and mounted combat remain separate owners.

## Edge cases and failure conditions

Test both items owned, removed selection, low ceilings, failed interior entry, jump under obstruction, mounted surface-water travel and depth-enabled shores. Forced entry into unsupported deep water cannot receive silent immunity or broad water prohibition. Selling an active mount cannot orphan mode state. Returning from a ship with changed terrain requires explicit contextual recovery, not blind coordinate restoration. Duplicate callbacks cannot replay mounting/audio/cost or jump practice.

## Configuration and balancing options

Access, lifecycle requirements, speed/jump rules, ownership changes, compatibility and ship boarding support explicit validated mod contracts. Vanilla retains inventory access, no separate animal resources, surface-water travel, cart no-jump and static-ship teleport. Exact provider precedence, data schemas and optional new mechanics require owner contracts; no unrestricted callback stacking or whole-system implementation is approved.

## Save/load considerations

Persist mode/selection, stable ownership references and ship return context with necessary physical state. Restore geometry and validated shape before enabling controls. Rebuild presentation without replayed travel or costs. Missing mount/mod/return definitions require compatibility recovery; do not silently choose another mount or teleport destination. Exact schema and migration remain SAVE/ITEM/LOC dependencies.

## Technical constraints

Target: Godot 4.7.2. Separate requests, ownership, geometry validation, committed mode and optional presentation. Coordinate shape/physics changes and validated teleport completion; engine scene callbacks alone cannot establish safe commitment. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Vanilla inventory access needs no simulated nearby animal/resources; validated mod access/lifecycle alternatives have supported integration contracts.
2. Quick toggle and explicit choices preserve remembered successful selection; unavailable requests explain and preserve current mode.
3. Mount/dismount validate full shape/support and cannot erase falls or bypass ceilings; prohibited specialized states reject requests.
4. Mounted speeds/proportional controls and horse impulse follow approved baselines; Cart cannot jump and Run/Sneak add no bonus.
5. Horse jumps charge/award once; mounted falls affect player without separate horse health; riding alone grants no Running practice.
6. Vanilla surface-only overworld water remains traversable mounted; depth-enabled swim-required entry needs safe dismount or blocked voluntary entry.
7. Interior success commits Foot, failure preserves exterior mount and exit does not auto-remount.
8. Vanilla ship boarding teleports to static owned destination with validated return; no new sailing/travel simulation is required.
9. Active transport sale/removal is blocked until dismount; script invalidation uses declared safe recovery.
10. Pause/restore preserve valid state without replayed mounting/boarding/cost/travel; invalid required data uses explicit recovery.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-004–006/008–015, CHAR-020 and relevant CORE placement/pause rules. No direct contradiction identified. Mounted surface-only water is explicitly retained; depth-enabled underwater restriction is narrower. Horse impulse excludes rider bonuses while approved jump activity remains once-only. Ship teleport remains baseline with readiness safety, not mandatory simulated travel. Additional lifecycle mod capabilities are requirements for explicit extension contracts, not vanilla systems or preapproved formulas.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: shape/camera values and motion transfer, riding fatigue classification, forced depth-water recovery, interior location policy, speed domains/caps/modifier schemas, ship/return identity and recovery, ownership transaction integration, mod lifecycle APIs/resources and native/physics/content fixtures. These do not waive vanilla water travel, explicit rejection or supported customization.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-016-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
