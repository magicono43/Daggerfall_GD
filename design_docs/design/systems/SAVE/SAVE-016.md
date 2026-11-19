# SAVE-016 — Post-load cleanup and completion

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

The game reports a successful load once the saved session is ready. The player sees the restored world and supported interface without an incomplete frame or carryover from the action that initiated loading. Failed loads follow an explicit recovery path.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#LoadGame` removes orphaned quest items, restores mod data, clamps legal reputation, clears `loadInProgress`, requests a fade from black, and raises `OnLoad`. Mod payload failures are reported individually. Subscribers include weather, automap, effect and HUD handlers. The load entry displays a loaded message at initiation, and earlier missing-component exits can bypass the normal busy-flag clear.

## Confirmed requirements inherited from approved specifications

- [CORE-013](../CORE/CORE-013.md) requires committed readiness before reveal and one Session Restored notification. Release only load-owned suspension and consume stale load-trigger input.
- [CORE-007](../CORE/CORE-007.md) requires one terminal outcome and consistent operation cleanup, subject to independent readiness and recovery gates.
- [CORE-005](../CORE/CORE-005.md) owns safe scope cleanup and recovery. [CORE-015](../CORE/CORE-015.md) governs state visibility and observer handling.
- [SAVE-005](SAVE-005.md) and [SAVE-007](SAVE-007.md) require validated recovery and disclosure before replacement when applicable.

## Detailed rules and behaviors

1. Complete required owner reconciliation before publishing success. This includes validated player and local state, correct placement, required references and activities, compatible mod state, and rebuilt derived gameplay and supported interface state. Owner rules determine required dependencies and when they are ready.
2. Resolve quest-item custody and legal state through their owners. Apply only validated migration, recovery, or lifecycle rules. Missing required quest links and invalid required legal data require explicit handling. Load completion has no general permission to delete an orphaned item or clamp an invalid saved value.
3. Prepare coherent reveal, clear stale action input, and publish one Session Restored notification for the active request after required state is committed. Report loaded only on success. Release load-owned suspension while retaining independent gates, including supported restored modals. No simulation or gameplay input sees an incomplete session.
4. Required work participates in the readiness flow and reports its outcome before completion. Completion observers consume committed state. An optional observer failure receives diagnostics and does not rerun the load or block other observers under CORE-015.
5. On failure or accepted cancellation, settle the active operation once and clear its busy state. Before replacement, preserve the old session and restore the eligible origin scope. After replacement, use CORE-005/007/013 cleanup and independent recovery UI. Unsafe cleanup retains its separate entry gate. Retry starts from fresh validation.

## Parameters, required data, and configuration

No new gameplay formulas or configuration apply. Required data includes the request, session, and generation identities, required owner readiness results, applicable scope and suspension state, input handoff, and terminal result and cleanup status.

## Inputs, outputs, and events

Inputs include owner restoration and readiness results, recovery dispositions, presentation and input handoff readiness, and cleanup results. Outputs include committed readiness, one Session Restored notification on success, one terminal result per admitted request, and scoped feedback or recovery. Phase notices cannot publish terminal success.

## Cross-system interactions

CORE coordinates lifetime, handoff, and operation outcomes. QUEST, ITEM, LAW, MOD and other owners reconcile authoritative records. TIME, WORLD, LOC, MOVE, UI and AV supply their required readiness and presentation results. [SAVE-010](SAVE-010.md) through [SAVE-015](SAVE-015.md) establish dependencies for reconstruction.

## Edge cases and failure conditions

- A required owner that fails after placement keeps gameplay gated and enters safe recovery. No loaded message appears.
- An active restored modal can retain suspension after successful load. Consumed load input cannot trigger an immediate action in the replacement session.
- A late or duplicate result cannot publish completion twice or clear another operation's gate.
- Optional presentation unavailable under approved policy can use its fallback. Required validation cannot be delegated to a success subscriber.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Operation state, subscriptions, and pending input are transient. Use request-scoped outcomes and committed state visibility; maintain cleanup gates independently of busy state. Preserve the selected source save on disk during load.

## Acceptance criteria

1. A delayed required owner keeps gameplay suspended and suppresses success until it reports readiness.
2. A successful load emits Session Restored and a terminal success once, with committed state visible. Stale input is consumed and independent suspension remains effective.
3. Failures before and after replacement follow their approved recovery paths and clear operation busy state. Unsafe cleanup still blocks additional entry.
4. Reconciliation preserves required quest items and legal facts under owner rules. Optional observer failure cannot replay completion or turn a successful restore into partial gameplay.

## Outstanding questions and approval

Concrete owner readiness interfaces, observer APIs, and verification fixtures remain follow-on work. See [SAVE-016-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-016-review-decision).
