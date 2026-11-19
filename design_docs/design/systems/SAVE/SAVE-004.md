# SAVE-004 — Save gating and quicksave

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Players can save during ordinary play, including dangerous encounters, when the saved state can be restored faithfully. Quicksave provides a one-action checkpoint. A mod can retain a numbered history of quicksaves for players who want to revisit older checkpoints.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#QuickSave`, `GameManager.cs#Update`, and `DaggerfallPauseOptionsWindow.cs` consult registered save restrictions. `RappelMotor.cs` registers one during rappelling. The public `Save` method checks readiness and loading state but does not consult the predicates. Quicksave calls the same save path using a reserved label and the current character's name.

## Confirmed requirements

- **SAVE-004-D01.** Use one eligibility policy for manual save and quicksave. Allow combat, hostile proximity, airborne movement and swimming when the state is supported and restorable. Use settled simulation boundaries. Reject during loading, death return, world transitions, or unfinished activities without approved save-and-resume support.
- **SAVE-004-D02.** Default to one visible quicksave per character. Replace it on successful publication and preserve it if the replacement fails. Support a moddable policy that creates a new permanent numbered slot on each successful quicksave.

## Detailed rules and behaviors

1. All save entry points use SAVE admission and the same mandatory checks before snapshot capture. Require a ready living session, a supported restore state, a settled capture boundary, and an available target and storage context. Surface the applicable reason on rejection. Reject conflicting work as busy under CORE-018 and CORE-007. A later save requires fresh input.
2. Eligibility is based on the state owners' ability to capture and resume the current state. Combat, nearby hostiles, airborne movement and swimming alone do not block a save. Loading, death return and world transitions block admission. An ongoing activity can be captured only at an approved boundary with supported committed state and required resume data. Revalidate if the session or relevant state changes between input and capture.
3. Under the default policy, the first successful quicksave creates the current character's designated quicksave slot. Later successful quicksaves publish a new generation in that slot. On failure, preserve the prior committed generation and designation. Manual save and rename do not acquire a quicksave designation through their display labels.
4. Under the moddable append policy, each successful quicksave publishes a distinct slot with the next increasing number for that character. Start numbering at 1 for a new sequence. Advance only on successful publication and preserve the sequence across launches and deletion of earlier entries. Numbering is independent of display names. Keep earlier slots available for ordinary browsing and explicit deletion, with no automatic pruning by this policy.
5. In append mode, designate the newest successfully published quicksave for the current character. Older quicksaves remain manual load choices. Deleting the designated target gives the existing missing-target behavior until another quicksave commits. A failed quicksave leaves the prior designation and numbering intact.
6. Apply the validated retention policy for the current session. If policy changes between sessions, retain existing slots. Switching to append creates a distinct slot on the next success. Switching to default replaces the designated slot on the next success, or creates one if the designated slot is missing. Earlier retained slots stay available for browsing and deliberate deletion.

## Parameters, required data, and configuration

No gameplay formulas apply. Default policy is one designated quicksave per stable character. The optional mod policy appends a numbered slot per success. Required data includes session and stable character identity, operation and owner readiness, the current designation and expected generation, selected retention policy, and durable numbering state for append mode. Exact numbering and designation storage representation belongs to the native save pipeline.

## Inputs, outputs, and events

Inputs include manual save or quicksave requests, current session and input context, target identity where applicable, owner eligibility, validated policy, and publication result. Outputs distinguish rejection with a reason, accepted work, committed save identity, and write failure. Report success and refresh the catalog after commit.

## Cross-system interactions

[CORE-018](../CORE/CORE-018.md) owns quick input, conflict rejection, feedback and stable quickload selection. [CORE-013](../CORE/CORE-013.md) and state owners define restorable conditions. [CORE-017](../CORE/CORE-017.md) owns simulation scheduling. [SAVE-001](SAVE-001.md) owns catalog refresh, [SAVE-002](SAVE-002.md) supplies metadata and preview, and [SAVE-003](SAVE-003.md) governs rename and explicit deletion. CORE-001 handles runtime storage failure. Future MOD and SAVE specifications define policy validation and save publication mechanics.

## Edge cases and failure conditions

- If a session changes or an unsupported operation begins before capture, reject without writing or redirecting the target.
- Concurrent or repeated quick requests cannot claim the same number, publish twice, or bypass admission.
- A failed write, including interruption before commitment, leaves the previous usable quicksave and append sequence intact. An optional thumbnail failure follows SAVE-002.
- Duplicate labels or a rename cannot redirect quickload. Deleting an older append slot leaves the current designation intact. Deleting the designated slot does not promote an older slot.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Publish slot changes, quicksave designation and numbering coherently across retry or interruption. Use state-owner capture and resume contracts. The safe capture boundary must preserve required committed gameplay state. The exact cadence phase and owner-specific resume data remain follow-on SAVE decisions.

## Acceptance criteria

1. Manual save and quicksave enforce the same mandatory gate. Supported combat, airborne and swimming states can save at a settled boundary. Invalid lifecycle or unsupported activity states give a reason.
2. In default mode, a successful quicksave updates one visible target per character. A failed replacement leaves the previous target usable and gives failure feedback.
3. In append mode, three successful quicksaves create three distinct numbered slots. Failed attempts, earlier-slot deletion and restart preserve the next number. Quickload targets the latest designated slot for that character.
4. Changing policy preserves existing saves. Rename and duplicate labels cannot redirect quickload. Deleting the designated slot produces the approved missing-target behavior.
5. Conflicting operations cannot publish duplicate writes, skip mandatory validation, queue an unintended save, or report success before commit.

## Outstanding questions and approval

The save pipeline and owner specifications still define exact capture boundaries, cadence phase persistence and supported in-progress activities. MOD and SAVE own the configuration schema and publication mechanics. See [SAVE-004-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-004-interview-decisions).
