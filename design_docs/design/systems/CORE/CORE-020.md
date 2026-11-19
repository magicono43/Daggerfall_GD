# CORE-020 — Encounter coordination hooks

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Coordinate truthful encounter/actor notifications and scoped queries/mutations without confusing restored actors, pending spawns, removal and death.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Distinguish encounter activation from individual actor availability. Include session/location context and origin such as new encounter, authored placement or restoration so reconstruction is not mistaken for a fresh encounter.
- Queries declare area/location and relevant hostility/alliance/pacification filters and pending-spawn inclusion. Existing-actor and pending-spawn counts remain separate rather than silently combined.
- Bulk clear, pending-spawn cancellation and hostility changes are explicit owner-validated requests with scope/purpose. Removal is not automatically death; clearing actors does not implicitly cancel spawners. QUEST/LAW/NPC own consequences and may not be bypassed by global mutation.

Second interview, confirmed by the user on 2026-11-05:

- Actor availability follows required identity/ownership/registration. Encounter activation notification follows committed owner activation, not spawn attempt. Essential rest interruption/quest bookkeeping is checked owner work, not dependent solely on optional listeners.
- Capture explicit bulk target set at acceptance and revalidate each before mutation. Later-spawned actors are not silently included; use another request or an explicitly defined ongoing policy.
- Return affected/skipped/failed targets with reasons. Quest/legal owners decide acceptable partial completion. Never claim universal success or blindly replay completed changes; required failure follows owner recovery.

Third interview, confirmed by the user on 2026-11-05:

- Identify bulk operations and completed target changes so redelivery cannot repeat consequences. Ended-scope requests cannot affect replacements. Intentional retry revalidates unresolved targets rather than replaying completed ones.
- Restored actors notify availability with restoration origin, without fresh encounter activation or replayed encounter rewards. Optional observer failure diagnoses without rollback or blocking others under CORE-015; required restore/bookkeeping remains checked owner work.
- Hostility changes respect allegiance, pacification and quest/legal ownership. Broad hostility cannot automatically turn allies hostile or erase authoritative pacification. Exceptions require explicit supported responsible-owner operations; NPC/MAGIC/QUEST/LAW define them.

## Inherited requirements

CORE-005/015 require scoped lifetimes and committed truthful notifications; CORE-007/013 restoration must not trigger new-character rewards. CORE-019 threat/spawner eligibility and rest interruption are purpose-specific, not inferred from actor availability alone. CORE-016/017 simulation gates and checked authoritative work remain distinct from observer notification. CORE-009 is deferred and CORE-014 outside scope.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/GameManager.cs`, RaiseOnEncounterEvent/RaiseOnEnemySpawnEvent expose encounter and instantiated-actor notifications; HowManyEnemiesOfType may combine active actors and pending spawners. ClearEnemies destroys active enemy and spawner objects; MakeEnemiesHostile sets active enemy motors hostile.

Callers include Questing/Actions/Enemies, CreateFoe, Utility/FoeSpawner, dungeon actions/doors, player interaction/entity and court cleanup. Rest subscribes to OnEncounter. GameObjectHelper/RDBLayout emit actor notifications; Serialization/SerializableStateManager also emits them during reconstruction. This establishes the need to distinguish origin; it does not approve original broad mutation scope.

Baseline: local DFU 1.1.1 Release; exact commit unavailable per repository overview. Static inspection only; source remains unchanged. Exact encounter selection/spawn/consequence rules remain owner scope.

## Detailed notification rules

Encounter activation and actor availability are distinct owner-committed facts. Actor creation attempts, failed placement and allocated but unregistered objects do not announce availability. Establish required actor identity, ownership and registry binding before notifying. Encounter owners commit their activation conditions before publishing activation; this feature does not define selection/placement/odds or promise all possible encounter actors exist simultaneously.

Notifications carry originating session/location, relevant actor/encounter identity and creation origin (new encounter, authored placement, restoration or another explicitly declared source). Restored actor availability is legitimate but does not mean a fresh encounter, new rewards or new-character grants. Other reconstruction/streaming categories require owner definitions so recreating a presentation object is not automatically a new gameplay occurrence.

Essential rest interruption, quest registration and other authoritative consequences are explicit checked owner operations with ordering defined by the encounter owner; they cannot rely solely on optional event listeners succeeding. State is committed before observer notification, with CORE-015-consistent visibility/batch rules. Optional listener failures diagnose and allow other observers without rolling back committed state. Scope-owned subscriptions disconnect safely; stale callback context cannot mutate a replacement session.

## Detailed query and mutation rules

Queries declare purpose, area/location and filters for actor type, hostility, alliance/pacification and pending inclusion. Report existing actors and pending spawns separately; do not equate one spawner with one living enemy implicitly. NPC/encounter owners define active/resident eligibility, dead/despawning handling and count units. Potential spawns are not automatically threats under CORE-019. The query's snapshot is an observation, not permanent permission to mutate.

Bulk requests identify operation, purpose, origin scope and intended action. Clearing actors, canceling pending spawns and changing hostility are separate actions, even when one owner explicitly coordinates several. Capture target identities at acceptance; revalidate current existence/scope/authority before each change. Newly arriving actors are excluded unless a separately defined ongoing policy explicitly handles them. No unbounded global registry traversal may accidentally affect unloaded or unrelated locations.

Removal/despawn is not death: do not automatically grant kill rewards, loot, quest completion or crime consequences. The responsible NPC/QUEST/LAW/COMBAT owner defines and commits the requested outcome. Removing a scene actor also does not itself specify whether its persistent record is removed; that is an owner decision. Canceling a spawner requires explicit intent and encounter-owner validation, not merely clearing nearby actors.

Hostility change is validated against current allegiance, authoritative effects and quest/legal restrictions. Generic mutation cannot silently override player-allied status, pacification or another owner's protected state. An authorized exception requires a separately defined supported operation and correct consequence ordering; this document approves no particular override. Revalidate if state changed after target capture.

Return structured affected/skipped/failed target results with reasons. Empty target sets and vanished/ineligible targets are explicit outcomes, not claimed successful changes. A quest/court action decides whether partial completion is acceptable and invokes its own recovery for required failure. No universal atomic rollback or all-or-nothing bulk transaction is promised. Preserve completed mutation records for supported redelivery lifetime so duplicate requests cannot repeat consequences. Retry unresolved targets with fresh validation; an uncertain partially committed target needs owner reconciliation, not blind replay.

Scope end invalidates unfinished work and registrations. A retry from an ended context cannot bind reused object handles to new actors. Operation/result provenance must distinguish replacement actors and intentional new commands from repeated delivery. Exact ID retention and durable receipt requirements remain SAVE/owner scope, not a universal cross-process ledger approved here.

## Relevant formulas and parameters

No encounter probabilities, spawn distances, enemy limits or balance values are approved. Existing-actor and pending-spawn counts use separately defined units; an existence query need not scan for a total but must preserve meaning. Bulk target membership is captured at acceptance and may shrink through revalidation, not grow silently. Exact registry scope and performance strategy remain owner contracts.

## Required data

Session/location/area context; stable actor/encounter/pending-spawn identities; origin and ownership; query purpose/filters/count units; bulk operation identity/action/purpose/captured targets; validation authority; affected/skipped/failed outcomes and completed-target records. Notification data includes committed state/context needed by observers, not unrestricted save payloads. Scene handles alone are insufficient durable identity.

## Inputs, outputs and events

Inputs: owner encounter activation/actor readiness, explicit queries, authorized bulk requests, current target validation and retries/scope changes. Outputs: distinct committed activation/availability notifications, scoped separate query results and per-target mutation outcomes. APIs/signals remain deferred. Requests, attempts and partial results must not be mislabeled committed universal success. Diagnostics follow CORE-002 privacy/failure policies.

## Cross-system interactions

NPC owns actor lifetime/hostility and registries with WORLD/LOC residency; COMBAT owns actual death/damage; MAGIC owns authoritative pacification effects. QUEST/LAW request scoped consequences and decide required/partial acceptability. Encounter owners choose activation/spawn/cancellation; CORE-019/TIME use checked threat/encounter information for rest without relying solely on events. SAVE/CORE-013 restoration marks origin and rebuilds bindings without fresh encounter rewards. CORE-005/015 scope/notification safety and CORE-016/017 eligibility remain in force. MOD later defines supported extension authority rather than inheriting unrestricted global mutation.

## Edge cases and failure conditions

- A restored enemy is available without a fresh encounter. Unloaded/reloaded presentation objects must not duplicate gameplay rewards or quest starts.
- A pending spawn is not a living actor; disabled/exhausted eligibility remains owner-defined. Separate counts prevent false guard/enemy totals based on raw spawner count.
- Captured targets can disappear or change hostility/scope before mutation. Revalidate and report skipped/failed results instead of acting on stale handles.
- Later-spawned actors are not included automatically. Clear actors does not silently cancel remaining spawners or enforce a future no-enemies policy.
- Partial completion can be valid for one caller and unacceptable for another. Required owner recovery must not replay already completed consequences or claim all targets changed.
- Redelivery and partial target failure require enough accounting to prevent duplicate effects. Uncertain target mutation cannot be assumed rolled back.
- Broad hostility cannot bypass ally/pacification protection. Explicit override mechanics and lawful/quest consequences remain separate specifications.
- Optional observer failure does not undo commit; required bookkeeping failure cannot be hidden as an optional listener warning.
- Scope teardown prevents stale work crossing characters/locations. Query/snapshot results are not authorization across scope changes.

No kill-reward, loot, crime, mass-hostility or encounter-frequency balance policy is introduced by coordination hooks.

## Configuration and balancing options

Owners define scopes, filter defaults, active/pending count semantics, permitted mutation purposes, partial-result policy and authorized overrides. This feature does not expose a player-facing global enemy-clear command or unrestricted mod API. Optimization/indexing can wait for performance evidence; explicit correctness/scope contracts apply regardless of storage strategy.

## Save/load considerations

SAVE reconstructs persistent actors/encounters with restoration origin and no fresh activation/reward replay. Persistent removal/cancellation/hostility consequences belong to domain projections, not just deleting scene nodes. Raw notification subscriptions/query results and scene handles are transient. Owners must define which ongoing bulk operations require save eligibility restrictions or durable receipts; no general resume-mid-operation guarantee exists here. Native-load support remains this Godot implementation only.

## Technical constraints

Target engine: Godot 4.7.2. Use explicit owner requests and scoped identity rather than copying global Unity object destruction/events. Registry availability must reflect committed identity/ownership; bulk iteration must tolerate target changes without silently growing scope. Isolate optional observer failures and check authoritative work results. Exact APIs, registry indexes, origin enum, result schema and deduplication persistence are implementation/owner dependencies.

## Acceptance criteria

1. Actor availability follows required identity/ownership/registration; encounter activation follows owner commit, not a spawn attempt.
2. Notifications include relevant originating scope/identities/origin. Restore availability does not emit fresh encounter activation or replay rewards.
3. Essential rest/quest bookkeeping uses checked owner operations; optional observer failure diagnoses without rollback/blocking other listeners. Scope teardown removes stale listeners.
4. Queries declare area/purpose/filters and distinguish existing actor from pending-spawn totals/units, without implicit global/unloaded scope.
5. Clear actors, cancel pending spawns and change hostility require explicit validated purpose/scope. Removal is not automatically death or persistent-record deletion.
6. Bulk targets are captured at acceptance and revalidated before mutation; later arrivals are not added silently. Invalid/vanished targets produce explicit outcomes.
7. Results identify affected/skipped/failed targets/reasons. Owners decide acceptable partial completion/recovery; universal success/rollback is not fabricated.
8. Redelivery does not repeat completed consequences. Intentional retry validates unresolved targets and reconciles uncertain partial commits under owner policy.
9. Hostility respects alliance/pacification/quest/legal authority; overrides require separately supported responsible-owner operations.
10. Ended-scope requests/callbacks cannot affect replacement actors. Restoration and persistent consequences follow SAVE/domain contracts without raw scene-handle identity assumptions.

These are future verification criteria. No implementation/runtime tests have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001–008, CORE-010–013 and CORE-015–019 v1, CORE-009 deferral, CORE-014 exclusion, decision log, CORE catalog and CORE architecture review. All nine interview decisions are represented. No conflict identified: restore origin protects native-load semantics, rest interruption remains checked purpose-specific work, notification observer failure differs from authoritative failure and scoped requests follow lifecycle safety. Exact encounter/quest/legal effects remain owner scope.

## Outstanding questions and approval

No further blocking coordination-policy choice is currently identified. Owners must define active/resident/pending count semantics, exact query scopes, permitted removal/hostility effects, override authority, partial commit/reconciliation, lifetime of duplicate records and any save-durable receipts. Encounter selection/placement/probability and concrete MOD APIs remain separate. These dependencies do not waive notification or mutation criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-020. This document is finalized v1. Approval reference: CORE-020-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented query/count semantics, domain consequences, override authority and other owner-contract dependencies remain open. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
