# MOVE-026 — Building and dungeon doorway traversal

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Move between exterior, building and dungeon contexts with correct door mapping, safe placement and one committed outcome. Loading cannot leak gameplay, consume game time or duplicate consequences. Multiple/modded entrances and exits remain supported.

## Confirmed requirements

MOVE-026-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, including explicitly moddable multi-door mapping. MOVE-020 access, MOVE-016 transport and CORE suspension/readiness/restoration remain binding. MOVE-027 owns detailed placement correction.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths relative to reference `Assets/Scripts/`:

- `Game/PlayerEnterExit.cs#TransitionInterior`, `TransitionExterior`, `TransitionDungeonInterior` and `TransitionDungeonExterior` have separate entry/exit paths, switch world parents/place player and publish notifications. Exit fade paths use coroutines.
- `RaiseOnPreTransitionEvent`, success helpers and `RaiseOnFailedTransition` expose attempt/outcome notifications; exact ordering differs by path and requires fixtures.
- `Respawner` and `RestorePositionHelper` reconstruct context using saved door/location data and readiness flags. Their fallback/index assumptions do not establish the target recovery policy or stable multi-door mapping.

Static inspection only; no source changes/runtime verification. Source coroutines, fade timing and fallback teleports are not automatically approved architecture.

## Detailed rules and behaviors

### Request and validation

Each doorway operation has stable identity and explicit preparing, committed-success or failed outcome. Validate original door, destination identity, required content and placement before publishing success. Pre-transition notifications cannot mark entry, dismount, grant rewards or act as proof that a destination exists.

Stable entrance/exit links determine destination and relevant return doorway. Support multiple entrances/exits and validated custom mappings through moddable definitions, not a fixed first-door schema. Missing/incompatible links use explicit recovery rather than random unrelated entrances. DATA/LOC/WORLD define supported keys, mappings and original-content adapters.

MOVE-020 commit-time access checks remain mandatory; opening a greeting or beginning preparation does not grant lasting permission. Rejected/cancelled requests do not enter. Already completed independent picking/casting retains its own consequences.

### Ownership, readiness and presentation

Acquire an owned transition suspension reason and show brief fade/loading while destination geometry and required systems become ready. Consume doorway input so it cannot act in the new context. Release only this operation's reason; other pause/modal/focus/readiness gates remain effective.

Readiness has checked completion and bounded failure handling, not arbitrary delay alone. Exact wait budgets/fade duration and required-system inventory remain CORE/WORLD/LOC/AV contracts. Ordinary traversal advances no simulated travel time; real loading/fade duration adds no spell/fatigue/calendar debt. Authored time-advancing transitions require explicit TIME semantics.

### Pose and commitment

Use validated destination pose/facing; clear transient movement impulses and reset camera interpolation. Scene-placement displacement is not a physical fall. Do not use this as a generic fall-clear permission for arbitrary input cancellation; MOVE-027 defines bounded correction/history policy.

Persistent effects remain active under owner rules. Validate transport/posture compatibility before commitment; successful interior entry commits Foot under MOVE-016, while failed entry preserves exterior mount state. Effects/pose readiness cannot be replaced by a fade finishing.

Committed entry/exit carries stable outcome identity for quest/discovery/legal/location work. Required gameplay reactions have checked owner contracts. Optional presentation failure cannot repeat transition/rewards; a declared failed-attempt response cannot masquerade as entry. Exact commit/required-reaction boundaries need domain integration rather than generic rollback promises.

### Concurrency and failure

Allow one active doorway transition per player. Repeated clicks cannot queue extra operations or duplicate outcomes. Competing teleport/load requests explicitly reject, defer or supersede under CORE/MAGIC/SAVE rules; stale completions cannot publish over newer operations. Exact priorities remain owner contracts.

Before commitment, failure retains original valid context where still available. If destructive reconstruction already invalidated it, keep gameplay suspended and offer explicit recovery. Never silently teleport elsewhere or resume partial geometry. No universal streamed-world rollback is promised. MOVE-027/CORE define bounded contextual corrections and recovery choices.

### Save availability and native load

Block saves while unresolved, with clear reason. Release only owned save restriction after a valid committed destination or recovered original context, respecting other restrictions. Cleanup cannot advertise saveability in a partial/failed world.

Native loading reconstructs authoritative saved location through SAVE/MOVE-027, not replayed doorway activation. Unfinished half-replaced world serialization is outside initial scope. Operation teardown invalidates stale callbacks and leaves valid required recovery gates intact.

## Relevant formulas and parameters

No gameplay formula/time cost is introduced. Ordinary elapsed transition game time=0. Pose/mapping validity and readiness determine release, not fade duration. Exact correction bounds, readiness limits, marker tolerances and presentation durations remain owner/tuning dependencies.

## Required data

Operation/session identity, source door/context and stable destination/return links; access snapshot/current validation; candidate pose/content/readiness; transport/posture/effect compatibility; commit/completion state; owned suspension/save restrictions and required reaction progress. Concrete schemas/API remain implementation work.

## Inputs, outputs and events

Inputs: eligible door action, target/access context, mapped content, preparation/placement results, competing requests and cancel/failure. Outputs: preparing result, checked committed success/failure, destination pose/context, once-only reactions and explicit recovery. API names unselected. Pre-event or presentation completion is not successful entry.

## Cross-system interactions

MOVE-018/019 input/intent, MOVE-020 access, MOVE-016 transport, MOVE-022 wagon exit, MOVE-027 placement; WORLD/LOC/DATA geometry/mappings, CORE scope/readiness/suspension, QUEST/LAW committed reactions, TIME explicit advancement, MAGIC effects/competing teleport, AV/UI fades, SAVE restrictions/restoration and MOD validated links.

## Edge cases and failure conditions

Test multiple entrances, destroyed source/target, expired access, missing marker/content, failed reconstruction, duplicate clicks, modal/focus overlap and superseded completion. Neither random fallback nor stale callbacks can overwrite valid context. Optional fade/audio failure cannot replay gameplay. No simulated time accrues from slow loading. Successful entry reactions must not repeat on native reconstruction.

## Configuration and balancing options

Doorway mapping and multiple custom entrances/exits are explicitly moddable. Validated presentation/readiness policy follows owner contracts; no player-controlled bypass of access/readiness or arbitrary fallback destination is introduced. Time-advancing authored travel remains separate from ordinary traversal.

## Save/load considerations

Persist committed stable location/door context and required world facts through SAVE, not raw pending callbacks/scene references. Unresolved doorway operation blocks saves. Restore committed world state without activation/reward/crime replay; required mapping incompatibility invokes explicit recovery. Exact migration and commit-safe save boundaries remain SAVE/LOC work.

## Technical constraints

Target: Godot 4.7.2. Separate request/preflight, preparation, pose validation, committed context and reactions/presentation. Use scope-safe operation identities and owner-held restrictions. Concrete async/scene-loading APIs and rollback availability remain engineering choices to verify. No implementation/coding tasks authorized.

## Acceptance criteria

1. Stable identified request validates door/content/mapped pose before committed success; pre-events grant no entry effects.
2. Multi-door/modded links preserve relevant mapping without first/random-door substitution.
3. Owned suspension/save restrictions protect unresolved preparation; other reasons remain effective after release.
4. Destination placement resets transient impulses/camera without a physical fall and validates effects/posture/transport.
5. Ordinary fade/load adds no simulation time or activity/effect debt.
6. One active transition/repeated input cannot duplicate operations; competing requests reject/defer/supersede explicitly and stale completion is ignored.
7. Precommit failure preserves valid source where possible; destructive failure retains suspension/explicit recovery without universal rollback promise.
8. Committed reactions execute once, optional presentation cannot replay; native load does not replay activation.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-016/018/020/022 and CORE pause/readiness/restoration. No direct contradiction identified. Successful-entry dismount is committed, not pre-event. Source retention is conditional rather than a rollback promise. Owned restrictions preserve other gates. Native reconstruction differs intentionally from a new crossing; mapping extensions remain validated content, not live provider changes.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: stable mapping schema/original fixtures, required readiness/reaction boundaries, pose/history transfer, competing operation priority, failure choices, fade tuning and native/supersession fixtures. These do not waive safe commitment, zero ordinary travel time or multi-door customization.

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under MOVE-026-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented mapping, readiness, placement, persistence and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
