# CHAR-001 — Creation flow and handoff

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Guide the player through building, reviewing and submitting a coherent new character before playable entry. This feature owns creation flow and handoff; individual choice mechanics remain CHAR-002–010 scope.

## Intended player experience

Follow the familiar Daggerfall creation sequence, move backward and forward without accidental rerolls, review the completed character, make permitted final edits and begin the game. Restart or leave creation immediately when desired, with the draft discarded and no confirmation prompt.

## Confirmed requirements

CHAR-001-D01–D08 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) establish the retained sequence/branches, sequential navigation, compatible-choice and random-outcome retention, complete discard on restart/exit without confirmation, limited summary edits, validated final review, and optional skippable introductory cinematics. D07 clarifies the initially broader summary-edit recommendation. The proposed upstream-change warning/correction flow was rejected.

Inherited approved constraints: CORE-007 captures submitted intent, validates before replacement and prevents duplicate entry; CORE-011 requires completed validated character data and safe placement; CORE-012 orders biography effects, grants and readiness without duplicate rewards. DATA-008 separates definitions and isolated candidate evaluation from live effects. DATA-001 makes videos optional. These approvals do not adopt all DFU implementation details or broader architecture proposals.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs`, `WizardStages`, window setters and close handlers: race → gender → class method and questionnaire/list/custom branches → biography method/questions → name → face → bonus attributes → bonus skills → reflexes → summary. The automatic biography route generates answers instead of asking them.
- The wizard copies selections into `Game/Player/CharacterDocument.cs`. Some panels are cached and others recreated. Attribute rolls are regenerated when the career reference changes; skill-roll retention uses `skillsNeedReroll`. Summary cancellation copies working allocations back to previous panels.
- `Game/UserInterfaceWindows/CreateCharSummary.cs`, `SetCharacterSheet`, `GetUpdatedCharacterDocument`, `OkButton_OnMouseClick`: permits edits to name, face, attributes, skills and reflexes; blocks completion with unallocated bonus points.
- `SummaryWindow_OnRestart` calls `SetRaceSelectWindow` using the existing wizard/document. This is not proof that every previous field is cleared. Intended full-draft restart is an explicit requirement rather than an assumption of source parity.
- `StartNewGame` passes the document to `StartGameBehaviour`; when videos are enabled it queues `ANIM0000.VID`, `ANIM0011.VID`, `DAG2.VID`. The last completion callback invokes `TriggerGame`, setting the NewCharacter start method. Otherwise it triggers immediately.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; no runtime creation/cinematic tests were performed. Source remains unchanged.

## Detailed rules and behaviors

### Creation sequence and navigation

Retain the sequence and branches described above initially. Class questionnaire scoring, custom-class legality, biography selection/answers, race/gender rules, name/appearance validation, allocations and reflex effects remain their respective feature specifications. Retaining a branch does not approve every underlying formula or content value.

Support sequential Back/Next navigation. Preserve compatible choices and existing random outcomes when merely revisiting a section. Deliberate reroll eligibility and the handling of regenerated values under a substantive choice change belong to the relevant choice feature; navigation alone is not a reroll action. Do not accumulate biography rewards or mutate the live player while editing a draft.

### Summary and final editing

Show all creation choices and their known starting effects. Provide direct edit access for name, face, attributes, skills and reflexes only. From the summary, changing race, gender, class or biography requires Restart; do not offer arbitrary earlier-section jumps or the rejected upstream-change warning/correction workflow.

Provide one Begin Game action. Identify invalid or incomplete sections and prevent submission until corrected under their owner rules. Do not silently fill missing required data from developer defaults. Hidden/random biography outcome disclosure remains CHAR-006 scope; the summary does not promise every hidden result or every eventual starting-grant quantity.

### Restart and exit

Restart clears the entire current creation draft and returns to the first step. Leaving creation discards that draft. Neither action asks for discard confirmation. Re-entering creation starts a fresh draft; there is no persistent unfinished-draft resumption. Clearing the draft includes selections, candidate effects/backstory, allocations and generated outcomes, not only visible fields. New defaults and rolls follow the relevant choice features when reached.

### Submission, cinematics and handoff

Begin Game captures the completed character intent so later UI state cannot alter it. Hand it to the CORE-007 new-character operation with validated required inputs, preserving operation identity, busy rejection, preflight cancellation and failure/recovery rules. Repeated activation or callbacks cannot create additional sessions or grant resources twice.

After Begin Game, play the three introductory videos in DFU order when enabled. Each is skippable. A missing or failed optional video must not prevent progress through the remaining sequence and into entry; disabled videos bypass the sequence. Do not add recurring missing-optional-video warnings. Video completion, skip or failure is presentation progress, not proof of playable-start success.

CORE retains control of the destructive boundary, cancellation availability, safe retry and actual entry completion. Cinematic presentation cannot bypass required validation, placement, grants or readiness, nor let stale callbacks start another character. Exact placement of media playback relative to internal preflight phases is an integration detail subject to these constraints.

## Relevant formulas and parameters

No new gameplay formulas or balance values are selected here. Flow order, five directly editable summary areas, three ordered optional videos and no navigation-triggered rerolls are the relevant parameters. Attribute/skill budgets, roll distributions, biography outcomes and reflex scaling require their owner specifications.

## Required data

An isolated draft containing choice identities and candidate values, completion/validation results, generated outcomes and allocations needed to preserve navigation state; summary presentation data; video preference and ordered media references; captured submission data and operation context. Use DATA-008 stable definition/choice identities where applicable. Concrete schemas and API names remain implementation decisions.

## Inputs, outputs and events

Inputs: creation entry, step choices, Back/Next, permitted summary edits, Restart, exit, Begin Game, validation outcomes and video completion/skip/failure.

Outputs: updated isolated draft, section errors, cleared draft, captured new-character request and media progression. CORE publishes actual entry outcomes. These are conceptual contracts, not approved signal names.

## Cross-system interactions

CHAR-002–010 define individual creation choices and rules. UI presents navigation, summary, validation and controls. DATA-008 provides validated class/biography content and isolated evaluation inputs. CHAR and effect owners apply consequences under CORE-012, not during browsing. AV plays optional media. CORE-007 owns dispatch/capture/recovery, CORE-011 placement, CORE-012 grants/opening content and CORE-005 scope/readiness safety. ITEM/MAGIC/FACT and progression owners supply relevant starting-effect rules without duplicated application.

## Edge cases and failure conditions

- Back/Next or summary revisits must not reroll, lose compatible allocations or multiply candidate effects.
- Restart/exit must not leave cached choices or delayed callbacks able to repopulate a fresh draft.
- Missing required definitions or invalid allocations block submission with actionable section errors; no default-character substitution.
- Repeated Begin Game, video skip plus completion, and delayed media callbacks must not duplicate entry or rewards.
- Disabled, missing or failed videos must not strand the operation or enable gameplay early.
- Required-entry failure follows CORE-007 cleanup/retry, rather than resuming partial grants. Cancelled preflight preserves the intact session under CORE rules.
- Discard-without-confirmation applies to the creation draft; it does not waive CORE-007 consent before replacing a living active session.

## Configuration and balancing options

Respect the videos-enabled preference. No new player-facing flow mode, persistent draft-saving option or reroll policy is introduced. Later owner specifications define permitted balancing/configuration of individual choices.

## Save/load considerations

Do not persist unfinished drafts for later resumption. Completed gameplay saves use SAVE contracts and must not rerun fresh-character grants on load. Captured operation input retained for safe entry/retry is distinct from a resumable creation save. Existing saves and original content remain unchanged.

## Technical constraints

Target engine: Godot 4.7.2. Keep candidate state/evaluation separate from live player mutation; UI navigation must not be the authority for applying starting rewards. Preserve captured request identity and stale-work protection across asynchronous media/entry. Specific classes, widgets, random-stream APIs and document representation remain implementation choices. Do not modify the reference source.

## Acceptance criteria

1. The retained sequence and class/biography branches are available, subject to their owner rules.
2. Sequential navigation preserves compatible choices, allocations and existing random outcomes; a visit alone never rerolls.
3. Summary presents all choices and known starting effects, with direct editing restricted to name, face, attributes, skills and reflexes.
4. Changing race, gender, class or biography from summary requires Restart; no rejected dependency-warning flow is added.
5. Restart clears the entire draft and returns to race selection; exit discards it. Neither prompts for discard confirmation, and re-entry cannot resume the abandoned draft.
6. Incomplete/invalid data identifies affected sections and blocks Begin Game without silent defaults.
7. Begin Game captures intent. Duplicate submissions/callbacks cannot cause duplicate sessions or grants; candidate previews never mutate live player state.
8. Enabled videos play in the specified order and each is skippable. Disabled/missing/failed optional media cannot block safe entry or produce recurring missing-media warnings.
9. Cinematic completion cannot bypass CORE validation/readiness; failure, cancellation and retry preserve approved lifecycle constraints.
10. Loads do not invoke fresh-character rewards, and reference source/existing saves remain unchanged.

These are future verification criteria; no implementation or runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CORE-007, CORE-011, CORE-012, DATA-001 and DATA-008, with inherited CORE-005 lifecycle constraints. No direct contradiction identified. D07 resolves the initial broad summary-edit recommendation; D04 resolves discard-confirmation ambiguity. Draft discard does not replace living-session consent. Optional cinematic fallback does not excuse required gameplay-data failure. Biography preview/final semantics and startup grant ordering remain owner-controlled.

## Outstanding questions and approval

No further blocking flow-policy question is identified. Dependencies before implementation is complete: individual CHAR-002–010 rules and validation; substantive-choice change/reroll semantics where relevant to sequential navigation; exact summary effect disclosure; UI/input/media integration and transition ordering. These are not permission to invent unresolved mechanics or relax the approved navigation and safety requirements.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-001-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented individual-choice and integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
