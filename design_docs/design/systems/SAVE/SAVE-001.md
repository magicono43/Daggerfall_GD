# SAVE-001 — Save path and slot enumeration

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Players can find the intended character and save, tell an unavailable save from an empty list, and return to a predictable set of saves when reopening the picker in the same storage mode.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs` uses an existing configured native save directory or creates a `Saves` directory in persistent storage. `EnumerateSaveFolders` scans immediate children with the `SAVE` prefix and an integer suffix and requires a save-info file. `EnumerateSaveInfo` logs exceptions reading metadata. `EnumerateCharacterSaves` groups by character name. `FindSaveFolderByNames` matches the character and save names, and `FindMostRecentSave` uses the recorded real-world timestamp. Discovery can succeed with an unusable gameplay payload. These are static findings. See the [SAVE architecture review](../../../analysis/architecture/SAVE_ARCHITECTURE_REVIEW.md).

## Confirmed requirements

- **SAVE-001-D01.** Refresh on picker open and following a successful in-game save, rename, or delete. External changes appear on reopen or explicit refresh. Revalidate an actionable target before use and require reselection if it changed or disappeared.
- **SAVE-001-D02.** Keep recognized native slots with recoverable identity visible when unavailable, with a reason when known. Report unidentified candidates through storage diagnostics and omit them from the character list.
- [CORE-001](../CORE/CORE-001.md) selects the launch storage root and governs standard, portable, and development storage, exclusive use, and storage recovery. [CORE-013](../CORE/CORE-013.md) defines native saves and authoritative preflight. [UI-010](../UI/UI-010.md) defines grouping, sorting, defaults, selection recovery, and missing screenshot behavior. [CORE-018](../CORE/CORE-018.md) scopes a designated quicksave to the current stable character.

## Detailed rules and behaviors

1. Discover this project's native saves in the save area of the active CORE-001 root. A change of root follows CORE-001 launch rules. The catalog uses stable character, slot, and generation identity. Character and slot names serve as labels, so duplicate names cannot merge characters or redirect operations.
2. Read sufficient catalog information to list and classify recognized entries. A recognized slot with a missing payload or a known unsupported format is unavailable. An unreadable label uses the available metadata and preserves the listing when identity can still be established. A missing or unreadable screenshot leaves availability to the payload and compatibility checks. The picker can browse entries before authoritative load preflight.
3. Refresh when opening Save or Load, on explicit refresh, and after confirmed completion of operations that change the visible catalog. Publish a refreshed view tied to the active root and picker scope. Keep a selection actionable only while its character, slot, and generation still match. Before load or overwrite, verify the selected target and generation. Reject stale targets and refresh so a fresh selection is possible.
4. Supply committed timestamps for UI-010 newest-first sorting and title-screen default group selection. Unknown dates sort after dated entries. Stable identity breaks ties. Quickload resolves the designated current-character slot through CORE-018. Ordering or refresh never submits an operation or selects a replacement target for a pending request.

## Parameters, required data, and configuration

No gameplay formulas or balance parameters apply. Use the launch storage context, stable character, slot, and generation identities, available display labels, committed timestamp when known, preview status, and availability with a reason when known. Storage mode is configured through CORE-001. Discovery uses the agreed refresh triggers.

## Inputs, outputs, and events

Inputs include the active storage context, picker-open and explicit refresh requests, successful save, rename, and delete outcomes, and target revalidation requests. Outputs include a scoped catalog result with slot identities, metadata, availability and known reasons, or a storage or index failure. Target validation reports whether the requested generation still matches. UI-010 owns picker feedback and selection.

## Cross-system interactions

CORE-001 supplies the active root and storage failure policy. SAVE-002 supplies metadata and preview contracts. SAVE-003 supplies rename and delete outcomes. UI-010 consumes the catalog and uses a placeholder for missing imagery. CORE-007 and CORE-013 coordinate load and preflight. CORE-018 uses the designated quicksave independently of picker ordering.

## Edge cases and failure conditions

- An unreadable root or failed scan reports an index error with Retry or Back through UI-010. A successful scan with no recognized slots reports an empty catalog. Runtime storage failure retains the session and active root under CORE-001.
- A damaged candidate whose stable slot identity cannot be established goes to storage diagnostics. Recognized entries use recoverable identity and known reasons when required content is unavailable.
- A removed or replaced save invalidates its selection. Rename, duplicate labels, row reordering, and tied timestamps cannot redirect a request.
- Missing optional preview data does not prevent loading. Required payload failures found during preflight preserve the current session under CORE-013.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Keep catalog and picker state outside gameplay snapshots. Catalog discovery uses native identification and available metadata. Required payload validation takes place under authoritative preflight before session replacement. Preserve distinct slot and generation identity across catalog refreshes and validate the generation before acting on a prior selection.

## Acceptance criteria

1. Standard, portable, and development launches enumerate native saves in the save area under their respective CORE-001 roots. A root read failure is distinguishable from a successful empty scan.
2. Two characters with the same display name appear as distinct groups. Dated slots appear newest first with stable ties and unknown dates follow dated entries. Title entry follows UI-010.
3. A recognized slot missing required data stays visible as unavailable. A candidate without recoverable identity appears in diagnostics. A missing screenshot uses a placeholder and preserves an otherwise eligible slot.
4. Opening or explicitly refreshing a picker reflects external changes. A successful save, rename, or delete refreshes the open picker. A stale target cannot load or receive a confirmed overwrite.
5. Catalog refresh cannot reroute a quickload, bypass native preflight, or trigger an operation.

## Outstanding questions and approval

The native recognition marker, metadata schema, slot publication and recovery format, and quicksave retention policy remain decisions for the relevant SAVE features. See [SAVE-001-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-001-interview-decisions).
