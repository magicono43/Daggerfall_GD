# SAVE-005 — Load selection and quickload confirmation

**Approval status — Approved, finalized from Draft v2.** The user approved Draft v2 on 2026-11-17 with “I approve”.

## Gameplay purpose and intended player experience

Players can load the selected save or quickly return to the current character's designated quicksave. The game checks that exact save before replacing the session and explains supported recovery consequences before applying them.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/GameManager.cs#Update` checks for a quicksave by character name, then calls `SaveLoadManager.cs#PromptQuickLoadGame`. The shared `PromptLoadGame` helper asks whether to continue on a detected mod mismatch. The key-based `Load` method starts a coroutine and posts a loaded message at initiation. The shortcut gives no feedback when the named quicksave is absent.

## Confirmed interview decisions

- **SAVE-005-D01.** Check the selected save first. Keep preflight mandatory. Allow a mod to suppress the living-session discard prompt for manual loads and quickloads.
- **SAVE-005-D02.** Disclose the consequences of supported recovery before applying it. Disclosure alone is sufficient for recovery. Routine disposable-cache rebuilding needs no notice.

## Detailed rules and behaviors

1. Manual load captures the selected native save generation. Quickload captures the current character's designated slot and generation under SAVE-004. If there is no designated target, give brief missing-quicksave feedback. A changed or missing generation invalidates the operation and requires a fresh selection or quickload invocation. Use stable identities throughout.
2. Run cancellable preflight before showing a discard confirmation. Prepare consistent input and validate required format, records, dependencies and supported migration or recovery. A failure or cancellation preserves any current session. A required-data or dependency failure blocks loading and explains the available recovery.
3. After successful preflight, ask for discard confirmation when replacing a living session by default. Identify the selected save and explain the loss of current progress. A validated mod policy may suppress the prompt independently for manual loads and quickloads. Title-screen loads have no living session to discard.
4. Disclose any owner-approved recovery with player-visible consequences before replacement. Include it in the discard prompt when one is shown. When there is no prompt, present the disclosure in the cancellable load flow before proceeding. Recovery itself requires no separate affirmative response. Keep the disclosure available and allow cancellation before replacement. Routine rebuilding of disposable caches proceeds automatically.
5. Before replacement, ensure the prepared input still corresponds to the captured generation and the active request. Apply CORE-007 admission, cancellation and recovery rules. Publish success only after required restoration and readiness under CORE-013.

## Parameters, required data, and configuration

No gameplay formulas apply. Required data includes request identity, manual or quickload origin, session identity and living status, selected character, slot and generation, validated confirmation policy, prepared save input, and recovery disclosures. The default prompts for both load origins before discarding a living session. The mod policy controls the prompt independently for each origin. Exact disclosure presentation and duration remain UI design choices.

## Inputs, outputs, and events

Inputs include a native-load request, selected or designated target, preflight result, recovery notices, consent where required, cancellation, and restore completion. Outputs include busy or missing-target feedback, validation errors, confirmation or informational disclosure, phase updates, and one terminal operation outcome. CORE-013 publishes Session Restored when ready.

## Cross-system interactions

[SAVE-001](SAVE-001.md) supplies catalog identities and stale selection rules. [SAVE-004](SAVE-004.md) owns quicksave designation. [UI-010](../UI/UI-010.md) owns picker recovery. [CORE-005](../CORE/CORE-005.md) owns safe cleanup. [CORE-007](../CORE/CORE-007.md), [CORE-013](../CORE/CORE-013.md), and [CORE-018](../CORE/CORE-018.md) apply the approved native-load confirmation policy. UI-010 delegates load confirmation to CORE.

## Edge cases and failure conditions

- If a quicksave is unavailable or changes while preparing or confirming the load, preserve the active session and report the issue. Older quicksaves are available only through a fresh manual selection.
- If optional recovery is supported and the mod suppresses the discard prompt, still present applicable recovery consequences before replacement. Canceling from this phase preserves the session.
- A failed preflight or declined discard confirmation returns to the originating interface. The picker retains selection only if it still matches.
- Conflicting requests follow CORE-007 busy and duplicate handling. After the destructive boundary, failures use approved cleanup and recovery.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Mod policy cannot bypass preflight, required dependency checks, recovery disclosure, or target binding. Load request and prompt state are transient. Persist mod configuration through the appropriate configuration owner. Load performs no automatic save.

## Acceptance criteria

1. An invalid manual load or quickload reports the problem before any discard prompt and preserves the current session under every prompt policy.
2. Valid manual loads and quickloads from a living session prompt after preflight by default. A validated mod can suppress the prompt for manual loads, quickloads, or both.
3. A clean title-screen load proceeds after preflight. A supported recovery with player-visible consequences is disclosed before replacement and requires no separate recovery acknowledgement. Missing required dependencies block loading.
4. Cancellation during preflight or disclosure leaves the current session intact. Changed targets cannot redirect requests. Completion feedback follows actual readiness.

## Outstanding questions and approval

The mod policy schema and exact disclosure presentation remain follow-on design choices. See [SAVE-005-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-005-interview-decisions).
