# SAVE-003 — Rename, deletion and backup

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Players can give a save a more useful name or deliberately remove it. The confirmation identifies the intended save even when several slots share a label. A rename preserves the saved moment and a confirmed deletion is permanent.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#Rename` rewrites the display label in save metadata. `DaggerfallUnitySaveGameWindow.cs` prompts for a rename or delete confirmation and resolves the slot by character and save name. `DeleteSaveFolder` removes known save files first. It attempts to remove an empty directory and uses `TryBackupDeletedSaveFolder` to move remaining files to a collision-free name under `DELETED` when the directory contains unexpected files or cannot be removed. That move occurs after known data is deleted and provides no complete-slot recovery guarantee.

## Confirmed requirements

- **SAVE-003-D01.** Allow duplicate slot names within a character and reject blank names. Rename only the display label and preserve slot identity, saved timestamp, thumbnail, and designated quicksave role.
- **SAVE-003-D02.** Permanently delete the selected slot after explicit confirmation identifying the target. Offer no in-game Recently Deleted or undo for this action.

## Detailed rules and behaviors

1. Bind rename and delete to the active storage root and selected stable character, slot, and generation. Revalidate the target before making a change. If it disappeared or the selected generation changed, stop, refresh, and require a fresh selection under SAVE-001. A duplicate label never redirects the operation.
2. Open rename with the current label. Reject empty or whitespace-only input with feedback. Accept duplicate labels. A submitted unchanged label leaves the slot as it was. A committed rename updates only the display label. Names are display data and do not determine paths.
3. Present delete confirmation identifying the character and slot label, plus the saved timestamp and available context when needed to distinguish duplicates. State that deletion is permanent. Cancel leaves the slot and current selection intact when the target is still valid. On confirmation, revalidate the captured target.
4. Delete the selected slot's owned records, including its retained generations and slot-owned previews and extension data. Protect unrelated data and files outside the selected slot and active root. Coordinate deletion with SAVE publication and target use so a pending write cannot republish a deleted generation. If the slot was the designated quicksave, its target becomes missing and quickload follows CORE-018.
5. Report success only after the operation commits. Refresh the picker after success. After delete, clear the stale actionable selection. Report a failure that occurs before deletion commits and keep the original slot usable where it was usable before. If physical cleanup fails after logical removal commits, keep the slot out of discovery, disclose the cleanup failure, and allow retry of cleanup. Remaining bytes do not constitute a recoverable save offered by the game.

## Parameters, required data, and configuration

No gameplay formulas or retention period apply. Required data includes active storage context, stable character, slot, and generation identity, current label, requested label or confirmation, available disambiguating metadata, and operation result. Exact label length and formatting limits remain to be specified with native slot naming. Apply the same eventual validation to new slot labels and rename.

## Inputs, outputs, and events

Inputs include a scoped target, proposed label or delete confirmation, cancellation, and SAVE operation state. Outputs distinguish committed rename or deletion, unchanged label, cancellation, stale target, busy, validation failure, and storage or cleanup failure. UI-010 refreshes from the catalog and handles feedback in the current picker scope.

## Cross-system interactions

[CORE-001](../CORE/CORE-001.md) owns root selection, exclusive use, and runtime storage failure handling. [SAVE-001](SAVE-001.md) owns catalog refresh and stable targets. [SAVE-002](SAVE-002.md) supplies preview metadata and preserves the association with the saved generation. [UI-010](../UI/UI-010.md) owns picker scope and selection. [CORE-018](../CORE/CORE-018.md) owns quickload behavior when the designated target is missing. [CORE-008](../CORE/CORE-008.md) preserves existing saves during death return.

## Edge cases and failure conditions

- Identical labels and timestamps still resolve to distinct stable slot identities. The confirmation stays bound to the row the player selected.
- If a load, overwrite, or other conflicting operation is using the slot, follow SAVE and CORE operation admission. Require fresh confirmation if the delete target changed.
- A missing thumbnail or an unavailable gameplay payload does not by itself prevent renaming or deleting a recognized slot. If a storage or format limitation makes the requested change unsafe, report the specific failure.
- Interruption and permission failures must leave a trustworthy catalog. An interrupted pre-commit delete preserves the previous record. Post-commit cleanup can be retried and must not make the slot reappear.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Rename preserves the gameplay payload, saved instant, preview association, and quicksave designation. Deleting a slot does not change a running gameplay session. Permanent deletion means removal from the game's save collection and cleanup of owned files. Filesystem forensic erasure and externally managed copies are outside this feature. Use the native publication and recovery mechanism to guarantee a recoverable operation boundary across interruption.

## Acceptance criteria

1. Renaming a slot to a label another slot already uses succeeds and preserves the original slot, saved time, thumbnail, and quicksave role. Blank labels are rejected.
2. Delete confirmation identifies the selected target and states that deletion is permanent. Cancel leaves the save intact. A changed or missing target requires fresh selection.
3. A successful delete removes the chosen slot and its owned records, leaves other slots intact, and refreshes the picker. The game offers no restore action.
4. Storage failure before commitment does not falsely report deletion or leave a partially removed save active. Cleanup failure after commitment is reported and the slot remains excluded from discovery.
5. Deleting the designated quicksave yields the approved missing-target behavior. Death return and active gameplay do not mutate saved files through this feature without a player management request.

## Outstanding questions and approval

Native label length and formatting limits, the storage mechanism for publication and cleanup retry, and the exact picker controls remain follow-on design or implementation choices. See [SAVE-003-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-003-interview-decisions).
