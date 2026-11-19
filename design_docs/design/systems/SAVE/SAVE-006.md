# SAVE-006 — Snapshot and multi-file writing

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

A save represents one coherent moment. Quicksave lets the player resume after capture while the game writes the snapshot. The game reports success when the save is committed. An interrupted overwrite preserves the previous committed save.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#SaveGame` builds core data and subsystem JSON, waits two frames for screenshot capture, then writes files sequentially through `WriteSaveFile`. Quest exceptions and mod data are collected after file writing starts. The write path has no visible slot-wide commit, so an interrupted overwrite can leave files from different save attempts.

## Confirmed requirements

- **SAVE-006-D01.** Discard the previous generation once its replacement commits. A failed replacement preserves the previous committed generation.
- **SAVE-006-D02.** Let gameplay resume after quicksave capture while the captured snapshot writes in the background. Report success at commitment. Keep manual-save progress and the picker responsive.

## Detailed rules and behaviors

1. Admit the request through SAVE-004. Bind it to the active storage root, originating session, stable character and slot, and expected generation where applicable. Revalidate eligibility and the target before capture.
2. Capture one settled simulation boundary. Collect the required authoritative state and generation metadata from the relevant owners as a consistent set. Preserve committed changes and the owner-approved state needed to resume supported activities. Reject capture if a required owner cannot provide a coherent snapshot. Finish the handoff to isolated snapshot data before releasing any simulation hold owned by capture.
3. After quicksave capture, release the capture hold and respect any independent pause reasons. Encode and stage from the captured data while gameplay can run. Manual-save progress remains responsive and follows the picker’s existing input and suspension scope. Later movement, transactions, calendar advancement, or mod callbacks cannot change the captured data.
4. Stage required records and validate the candidate generation before publication. Publish a single committed generation, including the catalog information and any applicable quicksave designation and numbering update. The authoritative catalog exposes the previous committed generation or the complete replacement. A first save with no committed generation stays out of the catalog until publication.
5. Reject or isolate competing operations under SAVE-004 and CORE-007. Recheck the expected target before committing. Retire and clean up the prior generation only after replacement commits. Cleanup failure leaves the new generation authoritative, with retryable cleanup and a diagnostic. Retired or staged data is excluded from active discovery. The append policy in SAVE-004 creates distinct slots that keep their own committed saves.
6. Apply owner-defined required and optional data policies. Failure to capture, encode, stage, or publish required data fails the save. Optional thumbnail failure follows SAVE-002. Any permitted optional record handling must use the current snapshot and its declared recovery policy. Data left over from an earlier generation cannot silently become part of the new one.
7. On successful commitment, refresh the catalog and deliver one success outcome. On failure before commitment, report the reason, release operation state, and keep the previous catalog and designation valid. If an interruption makes commitment uncertain, resolve the authoritative generation before reporting an outcome or accepting conflicting slot changes.

## Parameters, required data, and configuration

No gameplay formulas apply. An overwritten slot keeps zero recovery generations after successful cleanup. Required data includes the operation identity, target and expected generation, settled capture point, owner snapshots, required and optional record classifications, generation metadata, and commit outcome. Exact format, staging layout, and cleanup scheduling remain technical choices.

## Inputs, outputs, and events

Inputs include an admitted manual or quicksave request, owner capture results, optional preview, and staging and publication results. Outputs include capture and write progress, committed generation identity or actionable failure, catalog refresh after commitment, and cleanup diagnostics where applicable. Associate feedback with its originating operation and scope.

## Cross-system interactions

[SAVE-001](SAVE-001.md) consumes committed catalog state. [SAVE-002](SAVE-002.md) supplies metadata and generation-matched preview. [SAVE-003](SAVE-003.md) coordinates rename and deletion with publication. [SAVE-004](SAVE-004.md) owns eligibility and quicksave policy. [CORE-001](../CORE/CORE-001.md) owns the active root and storage recovery. [CORE-007](../CORE/CORE-007.md) coordinates session-changing work. [CORE-017](../CORE/CORE-017.md) supplies simulation boundaries. Gameplay and mod owners supply authoritative records and approved resume semantics.

## Edge cases and failure conditions

- Disk-full, permission, encode, or required-owner errors before commit preserve the previous slot or leave a first-save target unpublished.
- Interruption during staging, commitment, or old-generation cleanup must resolve to a whole committed generation on reopen. Staged data and retired generations cannot appear as loadable slots.
- Gameplay can advance while a quicksave is pending. Loading the resulting save restores the captured moment. Rejection, pending progress, and final success remain distinct.
- An optional screenshot failure uses the placeholder. Competing loads, deletes, or writes cannot retarget or resurrect a pending save operation.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Respect the runtime owners of scene and render access during capture. Background work uses isolated data. The publication protocol must demonstrate interruption recovery on each supported storage platform. A single bundle or a staged set of files can satisfy the requirement. Load validates the selected committed generation under SAVE-005 and CORE-013. The scheduling phase and exact activity resume data require explicit owner contracts.

## Acceptance criteria

1. A quicksave captured at a settled boundary writes while gameplay can proceed. State changes after capture are absent from the resulting save. Success appears only after commitment.
2. Injecting a failure at each required staging and publication step leaves a usable previous generation or an unpublished first attempt. Reopening after interruption exposes one complete committed generation.
3. Successful overwrite retires and cleans up the preceding generation. Cleanup failure is reported and can be retried without changing the active save.
4. A missing optional thumbnail does not fail an otherwise successful save. Optional data cannot be inherited accidentally from the overwritten generation.
5. Manual-save progress stays responsive, and conflicting operations cannot publish twice or act on a stale generation. A quicksave append updates slot, designation and numbering coherently.

## Outstanding questions and approval

Native record layout, publication mechanism, exact simulation cadence phase, owner-specific capture and resume contracts, and durability verification remain follow-on decisions. See [SAVE-006-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-006-interview-decisions).
