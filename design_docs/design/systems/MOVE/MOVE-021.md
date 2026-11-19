# MOVE-021 — Interior doors, mechanisms and fixtures

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Operate interior doors, linked mechanisms, ladders and bookshelves deliberately, without duplicate actions or narrow passages caused by open door collision. Preserve authored mechanisms with explicit repeat/save contracts and support modded door policies.

## Confirmed requirements

MOVE-021-D01–D10 in [the decision log](../../GAMEPLAY_DECISIONS.md) record interviews and explicit door-collision clarifications. Moving/open ordinary doors are nonblocking, superseding the initially proposed universally solid closing behavior. Safe closed-collision restoration is approved subject to revision after representative edge-case testing. “Animated/action door” here distinguishes moving door objects from static entrance transition markers.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths below are relative to reference `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/PlayerActivate.cs#ActivateActionDoor` checks reach, handles Lock/Open hooks, routes locked Steal to picking and otherwise toggles. `ActivateLaddersAndShelves` dispatches ladder climb or book reading at ordinary reach.
- `Internal/DaggerfallActionDoor.cs#ToggleDoor` ignores moving-door toggles. `AttemptLockpicking` rejects the same recorded failed skill, excludes magically held locks, clears lock and toggles on success. Target uses strictly greater retry eligibility instead.
- Door fields include opening duration/angle and `IsTriggerWhenOpen`. Source collider configuration and each authored case require runtime verification; the target nonblocking policy is explicitly selected by the user, not claimed universal source behavior.
- `Internal/DaggerfallAction.cs#Receive` routes authored triggers to linked motion, text, teleport, lock/open, spell/damage and other actions. These supported source families do not prove every chain's runtime behavior or authorize copying arbitrary dispatch order.

## Detailed rules and behaviors

### Door intent and locks

Unlocked stationary doors toggle open/closed. Locked ordinary activation reports the lock; Steal requests eligible picking. Info only describes; bashing and Lock/Open effects require explicit action contracts under MOVE-018/019 and MAGIC. Requests during motion are ignored, not queued for later toggle. Policies support validated modding.

Use RULE-009 interior probability with explicit lock difficulty/current claimed level/live skill. After failure persist failed live skill per door; retry requires strictly greater live Lockpicking. Blocked attempts consume no roll/practice. Ordinary picking cannot defeat magically held locks. Exact magically held eligibility and bypasses belong to MAGIC.

Successful picking clears the lock and requests opening. Unlock persists until an explicit lock action/effect changes it; failed opening or presentation cannot repeat the attempt, roll or practice. Genuine attempt accounting and retained outcomes use CHAR/RULE contracts. No bash probability or spell duration is selected here.

### Blocking versus targeting

Vanilla ordinary doors are nonblocking during motion and when open. They do not obstruct player movement or later projectiles, avoiding effectively narrowed original doorways. Retain separate interaction targetability for closing/bashing. A nonblocking open door is not automatically transparent to all activation queries: its targetability versus objects behind it requires explicit interaction masks/ownership under MOVE-018. It cannot block projectile travel merely because activation can hit it.

An unobstructed fully closed door blocks normally. Restore blocking collision only once player/other solid occupants do not overlap. Wait safely rather than crush, teleport or push them. Keep this pending collision state coherent with visual/logical open/closed and interaction state; exact visual waiting/reversal policy requires testing, not an invented timer.

The user explicitly permits later revision if intentional doorway occupation or other edge cases cause awkward behavior. Test that case before claiming final collision policy suitability; material gameplay changes return for explicit review. Do not silently enable crush damage as a workaround.

Door blocking/target/projectile policies are moddable. Explicit crush-enabled mechanisms retain MOVE-008's separate validated hazard policy; nonblocking ordinary doors cannot become lethal merely by touching the player. Concrete projectile types and masks remain COMBAT/physics integration, not a projectile implementation task now.

### Authored mechanisms and chains

Preserve validated original links/effects with a propagated authorized trigger identity. Door/attached-action composition can be intentional but cannot execute twice through door-specific and generic routing. MOVE-018 primary consumption and checked quest notifications remain authoritative.

Each mechanism declares one-shot, repeatable or busy/retrigger behavior. Reject unsupported busy triggers rather than silently queueing. Validate/bound linked cycles so malformed chains cannot run indefinitely or repeatedly apply effects. Preserve intentional timed/repeating mechanisms through explicit schedules. Exact link order, accepted trigger types, repeat scope and failure boundary come from the authored contract and LOC content fixtures.

Required gameplay action failures enter explicit owner recovery without default replay after partial effects. A trigger identity must deduplicate accidental delivery without suppressing intentional later activations or scheduled repetitions. No generic rollback of arbitrary action chains is promised.

### Ladders and bookshelves

Grab/Talk may activate supported ladders or bookshelf reading; Info only describes. Validated mod fixture mappings are supported. Ladder traversal requires full collision-safe route and supported destination; it cannot teleport through ceilings/obstructions. LOC/MOVE placement own exact traversal/shape rules.

Bookshelf reading uses ITEM/content/UI contracts and cannot silently transfer book ownership. Reading, inventory acquisition and quest effects remain distinct. Deferred UI/placement revalidates stable intent under MOVE-018; missing required data cannot substitute unrelated content or targets.

### Pause and native restoration

Pause freezes door/mechanism motion and gameplay-linked chain timers. Save lock/opening progress, mechanism state and necessary chain completion/timer context. Restore after geometry readiness without firing links, repeating damage/rolls/practice or treating restoration as a fresh activation.

Actions not safely restorable in flight must declare a save restriction and clear reason, released only by their owner when eligible. LOC/SAVE must establish supported action-state inventory, commit boundaries and required payloads. No blanket promise to serialize every arbitrary source action or mod callback is made.

## Relevant formulas and parameters

Interior picking uses RULE-009, not a second independent chance. Retry requires S_current>S_failed. Door duration/angle, collision transition tolerance, chain budgets and repeating intervals require validated authored parameters; no numeric defaults are selected. Open/moving nonblocking and occupancy-safe closed restoration are explicit policies independent of these constants.

## Required data

Stable door/mechanism/fixture identities, lock/magical state and failed skill; actual animation progress/target state; blocking/projectile/interaction policy and pending restoration; occupants; trigger/link identity, repeat/busy policy, checked completion and timers; supported save contract. Exact schemas/masks and ownership remain engineering dependencies.

## Inputs, outputs and events

Inputs: authorized mode/action, spell/bash/pick result, collision occupancy, authored trigger/schedule, pause and native restore. Outputs: checked lock/motion request/result, collision/target state, bounded chain execution, reading/traversal operation and explicit save restriction/recovery. API names remain unselected. Motion/presentation callbacks cannot replay primary effects.

## Cross-system interactions

MOVE-018/019 dispatch/modes; RULE-009 picking; CHAR practice/skills; MAGIC locks/effects; MOVE-004/006 shape/physics; MOVE-008 crush policy; MOVE-026/027 placement; LOC/DATA authored links; ITEM books; QUEST checked reactions; COMBAT projectile/bash; AV/UI presentation; CORE/SAVE readiness/pause/state and MOD validated overrides.

## Edge cases and failure conditions

Test blocked closing, intentional doorway standing, NPC occupancy, toggles mid-swing, open-door projectile passage and bashing/closing targetability. Never publish blocking collision around an occupant. Visual fully-closed-but-nonblocking ambiguity must be assessed rather than concealed as complete behavior.

Failed picks at lower skill cannot bypass retry. Magically held/explicitly relocked doors need owner rules. Duplicate door/action dispatch cannot trigger a chain twice. Intentional cycles need bounded schedules, not an indiscriminate visited-node rule that destroys authored repeats. Restore must not resume partially committed damage as fresh work. Missing required links/book/destination data invoke recovery.

## Configuration and balancing options

Door activation, retry eligibility, blocking/projectile/target policy and validated fixture mappings are moddable. Authored repeat/schedule rules retain explicit semantics. No universal crush, implicit busy queue, book ownership transfer or Info action fallback is introduced. Added mod effects/resources require their owner contracts, not arbitrary callback stacking.

## Save/load considerations

Version door lock/failure/animation/collision-pending state and mechanism/chain completion/timers as required. Validate geometry and occupants before restoring blocking state. Preserve resolved outcomes without re-executing links or practice. Unsupported in-flight actions expose save restriction instead of silently losing state. Exact save transaction boundary and mod compatibility remain SAVE/LOC dependencies.

## Technical constraints

Target: Godot 4.7.2. Separate physical blocking, projectile collision, interaction picking and logical/visual state. Coordinate motion/occupancy checks and bounded checked action execution. Concrete masks, tween APIs, link schedulers and save formats remain engineering choices requiring fixtures. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Stationary unlocked toggle/locked reporting, explicit picking/bash/spell and Info safety follow approved dispatch; moving requests do not queue.
2. Interior retry requires increased live skill, persists and does not roll/practice when blocked; magical locks reject ordinary picking.
3. Successful pick unlocks/requests opening once; later failure cannot replay it.
4. Ordinary moving/open doors block neither player nor projectiles but remain closing/bash targets.
5. Closed collision returns only when unoccupied, without crush/teleport/push; doorway-blocking edge cases are tested and policy revised only explicitly if needed.
6. Door/action composition executes intentional chains once, preserving explicit one-shot/repeat/busy and bounded schedule semantics.
7. Ladders require safe route/destination; bookshelf reading grants no implicit ownership; Info only describes.
8. Pause freezes motion/timers; restore resumes validated state without firing links/repeating effects. Unsupported in-flight saves have explicit restrictions.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-004/006/008/018–020, RULE-009 and CORE pause/restoration contracts. No direct contradiction identified. Door nonblocking policy is explicit user qualification, while action-chain hazards remain separately classified. Targetability does not imply projectile blocking. Greater-skill retry matches exterior policy intentionally. Pending closed-collision state and authored chain serialization remain engineering contracts, with edge-case review expressly required.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: closed-wait visual/logical behavior and occupancy tests, masks/target ownership, authored door/link inventory and repeat budgets, bash/MAGIC contracts, ladder traversal, fixture content, native action support/restrictions and representative projectile/physics/save fixtures. User explicitly allows revisiting collision policy if tests reveal awkward doorway behavior.

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under MOVE-021-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented collision-testing, engineering and cross-owner dependencies remain open, including possible explicit revision after doorway-occupation testing. Approval does not initiate implementation, coding tasks or another feature review.
