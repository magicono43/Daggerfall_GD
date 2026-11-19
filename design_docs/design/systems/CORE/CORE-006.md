# CORE-006 — Applying runtime preferences

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Apply validated preferences predictably, show when changes take effect and keep recreated consumers consistent with effective runtime settings.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Classify every setting as live, next session/location, or application restart required. Show timing in settings UI. Individual features define their settings' classifications.
- Use Apply/Cancel. Edits are staged; Apply activates eligible changes and saves accepted preferences through CORE-003. Cancel discards unapplied edits. Clearly mark restart-required changes as pending.
- Apply current effective preferences when consumers such as cameras, HUDs and controllers are recreated. Reapplication of the same values is safe; explicitly handle enable/disable and reverse changes without leaving earlier values active.

Second interview, confirmed by the user on 2026-11-05:

- Test resolution/fullscreen changes before saving. Offer Keep Changes/Revert with a 15-second timeout restoring the previous working mode.
- On application failure, revert the affected setting group to previous working values and explain failure. Independent groups may succeed; explicitly identify partial success. If safe reversion fails, follow CORE-005 recovery.
- If persistence fails after successful application, retain active in-memory changes, show Applied, not saved and offer retry per CORE-003. Show next-session/location and restart changes separately as pending. Saved does not mean currently active.

Third interview, confirmed by the user on 2026-11-05:

- Deferred changes apply only at the boundary declared by their owner. Do not force reload/restart automatically. Show pending changes, offer restart where applicable and allow continued play with current effective values.
- Disable unsupported hardware/platform options with an explanation. If saved preferences become unsupported, retain requested values, use owner-declared supported fallbacks and show effective values. Without a safe fallback use established failure rules.
- Cancel discards only edits since the last Apply attempt. Do not undo successfully applied groups, including active but unsaved changes. Retain unsaved warnings/retry; show failed groups as rejected rather than accepted.

Fourth interview, confirmed by the user on 2026-11-05:

- Display-test confirmation runs for 15 seconds of real time even while gameplay is paused or the window loses focus. Revert unless explicitly confirmed; never confirm automatically.
- If a saved display mode fails at startup, try a conservative windowed fallback defined by the display system, retain the requested preference and explain the fallback. If no usable display can be established, stop initialization with an actionable error. Exact fallback resolution belongs to display specification.
- Interdependent settings form one group applied at a boundary safe for every member. A group containing a restart-required member waits for restart. Independent settings may apply live. Show actual group timing before Apply.

## Inherited approved requirements

CORE-003 owns validation, safe publication and settings-write recovery; runtime write failure retains in-memory preferences, warns and permits retry. CORE-005 requires explicit consumers and readiness validation, rejects stale-scope work and does not let readiness override other suspension requirements. CORE-004 requires restart for changing an established ARENA2 source and retains the old source until then. CORE-001/002 storage and logging policies remain in force.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/Utility/StartGameBehaviour.cs`, ApplyStartSettings applies display, camera/input, controller, effects, background execution, VSync/cap, textures, HUD, weapon, sneak and terrain settings. Some updates require scene objects; the handedness branch only sets flipping for value 1, and the target frame rate branch only assigns when VSync is disabled and the cap is at least 30. DeployCoreGameEffectSettings applies selected effect groups. `Assets/Scripts/Game/GameManager.cs`, UpdateShadowResolution/UpdateShadowDistance apply shadow options using settings and location context.

Baseline: local DFU 1.1.1 Release; exact commit unavailable per repository overview. These are static observations, not demonstrated runtime failures. Source remains unchanged. No DFU option inventory or default is adopted implicitly.

## Detailed application workflow

Maintain distinct staged edits, accepted in-memory preferences, last successfully persisted preferences and effective runtime values. Pending status describes accepted values not yet effective; unsaved status describes accepted values not yet persisted. A value may be both pending and unsaved. Unsupported requested values remain visible alongside their effective fallback.

Apply validates staged values/groups using CORE-003 and the owners' capability/application contracts. For eligible live groups, apply and establish success before treating them as accepted. Failed groups revert to their previous working values and remain rejected; independent successful groups may be accepted. Deferred groups are accepted as pending for their declared safe boundary rather than applied early. Persist the accepted preference set through CORE-003; never persist rejected candidates as accepted changes. Reopening settings or Cancel must not silently revert accepted runtime changes or clear unsaved state.

Cancel discards only unapplied staged edits since the last Apply attempt. It is not an undo of successful Apply. A persistence retry saves the accepted set without requiring another live reapplication or making pending changes effective prematurely. Failed candidates must remain clearly distinguished from the accepted values whether UI keeps them visible or removes them from the editor.

Display mode changes use a temporary test before acceptance/persistence. Keep Changes explicitly accepts the tested mode; Revert or expiration restores the prior working mode and leaves the rejected test out of accepted settings. The 15-second deadline uses real elapsed time independently of simulation pause/focus. A crash before acceptance must not persist the unconfirmed mode. A runtime driver/platform failure during reversion follows CORE-005 safe recovery rather than claiming rollback succeeded.

On startup and consumer recreation, apply the currently effective values, not merely the newest saved/pending request. Activate deferred requests only at their declared next-session/location or application restart boundary, after validating the required scope. Owner-defined interdependent groups must share a compatible activation boundary; do not guess that an arbitrary scene recreation satisfies a session/location requirement. Readiness does not itself override suspension rules.

At application restart, previously persisted deferred preferences become eligible for activation under their owners' validation rules. Unsaved preferences are not guaranteed to survive process exit; a restart offer must not imply they were persisted. CORE-004 separately requires successful content-path persistence before offering a source-change restart. Unsupported options use declared fallbacks while retaining requests; structural invalidity still follows CORE-003 recovery rather than being mislabeled as hardware incompatibility.

## Relevant formulas and parameters

Display confirmation deadline = test start time + 15 seconds of real elapsed time. No confirmation by the deadline means revert. Simulation time scale, pause and focus do not extend the deadline. Exact clock API and countdown presentation are implementation details.

Every setting declares activation timing and an owning feature; next session versus next location must be specified precisely. Effective group timing must satisfy all member constraints, with restart-required groups waiting for restart. There are no universal gameplay balance values, frame limits, field-of-view defaults or fallback resolutions approved here.

## Required data

Setting ID, owning feature, validated default/range, capability requirements, activation boundary, compatible group membership and fallback contract. Runtime state includes staged/accepted/persisted/effective values, pending/unsaved/rejected results, consumer scope identity and per-group application outcome. Display testing additionally needs prior working mode, candidate mode, real-time deadline and confirmation state.

## Inputs, outputs and events

Inputs: validated settings, staged edits, Apply/Cancel, Keep Changes/Revert, timeout, capability checks, consumer readiness/recreation, boundary changes, application and persistence results. Outputs: accepted or rejected group results, effective runtime values, pending/unsaved status, safely persisted preferences and actionable recovery UI. Conceptual notifications distinguish requested, applied, deferred, reverted, failed and persisted outcomes; API/signal names remain deferred. Observers must not mistake an attempted write/application for success.

## Cross-system interactions

CORE-003 validates values/groups, performs migrations and safely persists accepted preferences. CORE-005 binds consumers and protects their lifetimes/readiness; failures to restore safe operation use its recovery rules. CORE-004's ARENA2 source stays restart-required and its save-before-restart rule remains unchanged. UI owns staged editing and truthful outcome presentation. AV/display, MOVE/input, WORLD and other owners implement application/fallback and define activation timing. CORE-001 storage-root changes remain launch-only. CORE-002 logging follows its privacy, cap and failure rules and is not a prerequisite for application success.

## Edge cases and failure conditions

- A value can be saved but pending, active but unsaved, or requested but unsupported. UI must not collapse these states into a generic success label.
- Related settings cannot be split into an incompatible partially active group. Independent groups may succeed even if another group fails.
- Display timeout, focus loss or simulation pause cannot implicitly accept an unreadable mode. Failed restoration requires recovery; no unconfirmed candidate is written as the accepted display setting.
- A platform may accept a mode request without producing a usable display. The display owner must define how success/fallback is established; this specification makes no API-level guarantee.
- If no display can render error UI, initialization still fails rather than reporting success. An available diagnostic mechanism must convey the actionable error; exact platform mechanism remains display scope.
- Missing required consumers use CORE-005 failure handling. An absent consumer belonging to a future valid scope does not justify silently discarding its effective settings; bind/apply them when that scope is created.
- Late work from an old consumer/session must not apply changes to a replacement. Reapplication must handle both directions, including clearing earlier caps/flags where the owning feature requires it.
- Persistence failure retains accepted memory and retry, but does not promise survival across quit/restart. Startup persistence failures still block entry under CORE-003.
- Unsupported saved requests remain retained and visibly distinct from the effective fallback; unsupported UI controls are disabled with an explanation. Without a declared safe fallback, use failure/recovery rules.

No numerical balance policy is selected. The main player risks are unreadable display changes, misleading save/active labels and incompatible partial application.

## Configuration and balancing options

This feature governs how preferences apply, not which DFU settings must exist. Individual feature specifications define inventories, defaults, ranges, supported options, group membership and activation timing. The fixed display-test timeout is 15 seconds. Apply/Cancel, explicit display confirmation, no forced reload/restart and truthful pending/unsaved labels are required policies rather than optional tuning.

## Save/load considerations

Persist accepted application preferences via settings.ini under CORE-003, independently of character saves. Character loading must not roll application preferences back to a historical save state. Consumer reconstruction uses effective preferences; it must not activate a restart-required pending request. Runtime pending/unsaved status is not stored as a scene handle or callback in character saves. Requests intentionally saved for next launch survive through settings persistence; failed writes do not.

## Technical constraints

Project target: Godot 4.7.2. Implementation can use native engine facilities but must not copy Unity-specific APIs by assumption. Separate validation/persistence from runtime application, report per-group outcomes and avoid whole-game rollback promises. Use a real-time display deadline, explicit consumer bindings and scope-safe work. Application routines must safely reapply the same values and reset the reverse state. Concrete engine APIs, supported-mode detection and rollback mechanisms remain implementation details to validate.

## Acceptance criteria

1. Each setting/group declares and displays actual activation timing before Apply. Unclassified options are not silently assumed live.
2. Editing stages values; Cancel discards unapplied edits. Apply accepts successful eligible groups and defers eligible pending groups without applying them early.
3. Display resolution/fullscreen tests are not saved before explicit Keep Changes. Revert or 15 real-time seconds without confirmation restores the previous working mode, including while paused/unfocused.
4. Failed application restores the affected group's prior working state and reports rejection; independent successes are labeled partial success. Failed safe restoration invokes CORE-005 recovery.
5. Accepted changes are persisted through CORE-003. Failed persistence retains accepted in-memory changes, visibly distinguishes Applied, not saved and allows retry; startup failures retain CORE-003 blocking policy.
6. Pending next-session/location and restart changes are labeled separately from persistence status, activate only at declared boundaries and never force reload/restart automatically.
7. Cancel after Apply does not undo successful groups or clear unsaved accepted changes; rejected groups never appear accepted. Persistence retry does not prematurely activate deferred values.
8. Unsupported controls are disabled with explanation. Unsupported saved requests are retained, effective declared fallbacks are shown and absent safe fallback invokes established failure rules.
9. A failed startup display request uses the display owner's conservative windowed fallback without silently overwriting the requested preference. No usable display means failed initialization with an actionable error.
10. Related groups activate together at a boundary safe for all members; restart-required members defer the whole interdependent group to restart. Independent settings can apply live.
11. Recreated consumers receive effective values. Reapplication is safe, handles enable/disable and reverse changes, rejects stale work and does not override other suspension requirements.
12. CORE-004 source changes remain save-before-restart and restart-only; application preferences are not restored from character saves. Logging failure alone does not prevent preference application.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001 through CORE-005 v1, the decision log, CORE catalog and CORE architecture review. All 12 interview decisions are represented. No conflict identified: validation/persistence remains CORE-003-owned, scope safety follows CORE-005, source changes retain CORE-004's restart contract, and storage/logging policies remain intact. Unsupported valid preferences are distinct from invalid values repaired by CORE-003. Broader architecture proposals and individual setting defaults remain unapproved unless separately accepted.

## Outstanding questions and approval

No blocking player-policy choice is currently identified. Feature owners must define concrete settings, defaults/ranges, safe boundaries, capability/fallback contracts, groups and application/rollback behavior. Display scope must define supported modes, conservative fallback resolution and error reporting when no display can render. APIs, clock choice, UI wording and serialized format details remain deferred; these deferrals do not waive acceptance criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-006. This document is finalized v1. Approval reference: CORE-006-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented deferrals remain deferred. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
