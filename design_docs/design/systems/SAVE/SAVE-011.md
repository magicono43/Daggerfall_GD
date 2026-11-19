# SAVE-011 — Reset and early contextual restore

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

An unavailable save leaves the current game intact. A successful load builds the destination with its saved time, location, and applicable ownership and access state, so the player arrives in the correct world.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#LoadGame` clears death presentation, pending input, quest state, scene cache, and player state before reading several files and checking required components. It raises the start-load event after decoding core save data and finding the serializable player. It restores the date for season selection, applies saved interior world compensation, restores or clears discovery, and supplies building context, house ownership, and memberships before rebuilding the interior. It applies faction data early for later consumers.

## Confirmed requirements inherited from approved specifications

- [SAVE-005](SAVE-005.md), [CORE-007](../CORE/CORE-007.md), and [CORE-013](../CORE/CORE-013.md) require successful preflight and applicable disclosure and consent before destructive replacement. Cancellation remains available until that boundary.
- [CORE-005](../CORE/CORE-005.md) and [CORE-010](../CORE/CORE-010.md) govern safe teardown and a clean replacement scope. Native restoration preserves saved facts and follows its own entry path.
- [TIME-018](../TIME/TIME-018.md) and [LOC-020](../LOC/LOC-020.md) require saved time, retained weather, and applicable layout context before dependent gameplay and presentation initialize.

## Detailed rules and behaviors

1. Prepare a consistent validated generation under SAVE-005 and SAVE-007. Resolve detectable required prerequisites and prepare owner migrations and applicable recovery. Keep the current session intact while preflight and any consent are pending. Use CORE-007 suspension and cancellation rules.
2. Commit replacement only for the accepted request and prepared generation after applicable disclosure and consent. Retire the previous scope through CORE-005. Clear old movement and queued input, death presentation, transient scene and UI state, and owner bindings through their owning scopes. Keep application storage and preferences under CORE. Reject late work from retired scopes.
3. Construct a clean native-restore baseline under CORE-010. Keep gameplay suspended. Supply the exact saved clock and retained weather, stable world and location identity, applicable layout and visit, and saved geographic and placement context before dependent work runs. Resolve world alignment through the WORLD and MOVE contracts.
4. Restore or make available the authoritative facts needed by the destination builder before it consumes them. These include applicable building and access context, property and membership state, faction context, and saved discovery for dependent consumers. Use the owners' validated records. A missing required fact uses explicit migration or failure. An absence supported by that format uses its declared semantics.
5. Pass prepared context to placement and binding under SAVE-012 and subsequent restore phases. Early readiness authorizes dependent reconstruction. Publish Session Restored only after the full CORE-013 readiness boundary. Restoring context produces no fresh discovery, grant, quest-start, time advancement, or weather-change consequence merely from reconstruction.

## Parameters, required data, and configuration

No gameplay formulas or new settings apply. Required data includes operation and session identity, selected committed generation, validation and consent results, saved clock and retained weather, world and location context, and required owner facts for the destination. Exact field layouts use the native schema.

## Inputs, outputs, and events

Inputs include validated prepared save data, authorization and cancellation outcomes, teardown results, and owner context results. Outputs include an intact-session preflight outcome, a clean replacement scope with early context ready for its dependent phases, or an actionable failure. Any phase notification is tied to the active load request.

## Cross-system interactions

CORE coordinates admission, teardown, and suspension. SAVE validates and supplies prepared records. WORLD and LOC resolve geography, layout, and versioned placement context. TIME restores clock and weather. FACT, ECON, and the applicable discovery and access owners provide their required early state. [SAVE-010](SAVE-010.md) applies the corresponding player reconstruction rules.

## Edge cases and failure conditions

- Missing required data detected during preflight leaves the current session intact. Once replacement starts, a required failure invokes safe cleanup and independent recovery under CORE-005/007/013.
- A former session's discovery, ownership, membership, or weather cannot fill gaps in the loaded data. Missing required context receives explicit handling.
- A destination that needs saved access or layout context waits for it. An exterior load does not inherit an interior alignment value from the retiring scope.
- Retry uses a fresh operation and validated prepared generation. Stale phase notifications cannot expose a partially restored session.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Keep restored authoritative facts separate from transient scope state. Express the early context as dependencies for destination readiness. Use SAVE-008 stable identities and SAVE-007 compatibility rules. Native load preserves the source generation and performs no automatic save.

## Acceptance criteria

1. A failed or canceled preflight leaves the current session intact. Destructive replacement starts only after approved preflight and applicable disclosure and consent.
2. An interior load supplies saved time, location, layout, and required access or ownership inputs before their consumers run. Exterior loading derives its own world context.
3. A second load cannot inherit stale discovery, memberships, input, or owner callbacks from the previous session. Context rebuilding grants no new gameplay credit or elapsed time.
4. Early context readiness permits dependent reconstruction while gameplay remains suspended. A late required failure enters approved recovery and never reports successful restoration.

## Outstanding questions and approval

Exact owner fields, dependency declarations, and the placement readiness handshake remain follow-on work. The player-facing replacement policy is inherited from approved specifications. See [SAVE-011-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-011-review-decision).
