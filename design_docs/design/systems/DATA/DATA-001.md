# DATA-001 — Classic installation discovery

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Resolve a usable external original Daggerfall ARENA2 directory before normal startup continues. Establish a basic content prerequisite for world, gameplay and media consumers without requiring an unmodified DOS installation.

## Intended player experience

Choose original data once, see the resolved folder, and reach the main menu on subsequent launches when it remains usable. Compatible externally modified classic files are accepted. Missing or clearly invalid required data produces a useful combined failure report rather than a succession of individual errors.

## Confirmed requirements

The two interviews establish DATA-001-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md): mostly basic startup validation; acceptance of modified original data; optional videos; an explicit required-filename list rather than a texture-count-only test; missing/readability/empty-file and lightweight archive header/index checks; combined failure reporting without recurring warnings for absent optional videos.

Inherited approved CORE-004 requirements: external ARENA2 is required; accept ARENA2 itself or its immediate parent; use remembered or explicitly selected folders only; validate each launch; persist successful selection safely; main-menu source changes activate only after application restart. CORE-001/003 storage/settings recovery remains binding. CORE-008 permits missing/failed death-video playback to bypass directly to the menu.

## Existing Daggerfall Unity behavior — reference only

Static source anchors below are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `DaggerfallUnity.cs#SetupArena2Path`: raises a source-selection event, checks the editor path in editor builds, then probes settings and runtime fallback locations. Discovery can stop on an existing candidate before it validates, masking a later valid candidate. Readiness and validation are separate flags.
- `API/DFValidator.cs#ValidateArena2Folder`: checks at least 472 `TEXTURE.???` files and presence of `ARCH3D.BSA`, `BLOCKS.BSA`, `MAPS.BSA`, `DAGGER.SND`, and `WOODS.WLD`. It does not validate file contents. Unity Resources may satisfy missing major archives. Video validity uses at least 17 VID files or a Resources probe for `ANIM0011.VID`, but videos are optional unless explicitly required by the caller.
- `Utility/ContentReader.cs#SetupReaders`: constructs format readers separately from discovery. A facade ready flag does not establish successful decoding of all required data.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable because the source snapshot has no Git metadata, as recorded in [the repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source remains unchanged. No classic-data fixtures or runtime behavior were tested here. These observations do not adopt Unity fallback sources, automatic discovery, or exact original counts as intended requirements.

## Detailed rules and behaviors

### Source resolution and activation

Resolve the remembered location on every launch, or validate an explicitly selected candidate. Accept the selected ARENA2 directory or its immediate ARENA2 child, without recursive or drive-wide search. Show the resolved directory. Do not silently substitute another installation or aggregate files from multiple installations.

The external directory is read-only input; write permission is not required. Do not copy, repair or modify original files. An invalid candidate or canceled folder picker leaves committed selection unchanged. CORE-003 owns safe path persistence. First setup can activate successfully validated and persisted content; a later main-menu source change stays pending until restart, leaving the current source active. No in-session source switching is authorized.

### Basic validation

Use an explicit required-file manifest derived from the recreation's actual content dependencies. Check each required filename rather than using the total texture count as proof of completeness. Additional files and modified contents are allowed.

Reject required files that are missing, unreadable or empty. Apply lightweight, format-specific checks for clearly invalid archive headers and index bounds. Bounds are checked against the actual file and supported format, not original installation sizes or record totals. Do not require original checksums, original byte lengths, original record counts or original content values. Do not decode every record or perform a complete integrity scan at startup.

A passing check means the directory satisfies these basic prerequisites at the time checked. It does not certify every asset, modded record, gameplay relationship or save compatibility. Reader initialization and actual record decoding remain distinct operations owned by DATA-002 and the relevant consumers.

### Failures and optional videos

Collect all detected required-data failures into one report, identifying affected file/path and reason. If the directory cannot be enumerated or accessed, report that root failure without pretending every individual file was inspected. Present Choose Folder, Retry and Quit through CORE-004/UI recovery independent of ARENA2 assets. Required-data failure blocks the normal startup main menu.

Videos are optional for startup. Missing optional videos do not cause recurring startup warnings. Playback features own missing/unplayable-media handling; CORE-008's death-video bypass remains binding. Optional media absence must not be relabeled as required-data failure.

## Relevant formulas and parameters

No gameplay formulas or numerical balance parameters apply. The required-file manifest and format-specific lightweight validation rules define pass/fail. DFU's 472-texture and 17-video counts are reference observations, not approved validation thresholds for the recreation.

## Required data

Remembered path and absolute/executable-relative interpretation; resolved ARENA2 directory; candidate versus active/pending selection; required-file manifest; format-specific header/index validation rules; per-file validation outcomes and failure reasons. The exact manifest and binary checks must be documented and verified before implementation is considered complete; this draft does not claim DFU's short validator list covers all consumers.

## Inputs, outputs and events

Inputs: startup settings, explicit folder selection, retry/cancel, filesystem availability and basic file-format metadata. Outputs: resolved root, basic-validation pass/failure with combined details, and candidate acceptance/rejection for CORE routing/persistence. Activation and reader readiness are separate outcomes. These are conceptual contracts, not approved API or signal names.

## Cross-system interactions

- CORE-001 separates writable application storage from external content. CORE-002 owns optional diagnostics and privacy filtering; file logging failure does not change validation success.
- CORE-003 stores the accepted path. CORE-004 owns setup, launch eligibility and source-change restart behavior. CORE-006/021 retain preference and setup navigation rules.
- DATA-002 owns reader initialization. Other DATA features and gameplay/AV consumers establish their actual required inputs and handle later decoding failures through their owner contracts.
- UI supplies independent selection/error presentation. AV and individual playback features own optional media failures. SAVE owns compatibility and restoration rules; selecting a valid folder does not prove a save is compatible.

## Edge cases and failure conditions

- Moved, disconnected, inaccessible or empty required data fails basic validation and returns to approved recovery; no alternative installation is silently selected.
- A folder with enough textures but a missing required filename fails. Extra files and supported changes to sizes, record populations or values do not alone fail validation.
- An altered archive with a clearly invalid header or out-of-bounds index fails even if its filename exists. A structurally acceptable modification may still fail later decoding; startup success is not a universal guarantee.
- Data can disappear or change after validation. Actual read/initialization failures must remain failures rather than relying on a stale success flag. Detailed runtime recovery belongs to reader/session/consumer specifications and is not newly invented here.
- Successful candidate validation followed by failed path persistence is not completed setup. Retain the current active source and CORE-003 recovery requirements.
- A pending source that fails on restart enters mandatory setup rather than reverting silently to another installation.

## Configuration and balancing options

No player-facing strictness toggle, checksum whitelist or full-scan mode is approved. Compatible modified data is supported by the normal basic policy. There are no gameplay balance changes in this feature; modified content can change gameplay under its consumers' rules.

## Save/load considerations

Content location is an application setting, not character-save state. In portable mode, paths inside the portable installation are executable-relative; external paths remain absolute. Loads do not change the content source or activate a pending switch. Validation results are transient and must not replace launch revalidation. Save/content identity or migration rules remain SAVE/DATA dependencies.

## Technical constraints

Target engine: Godot 4.7.2. Preserve read-only external input and independent startup/error UI. Separate path resolution, basic validation, persistence, activation and reader initialization so one success cannot falsely establish the others. Use supported-format checks that accept modified content without trusting invalid offsets. Concrete schemas, APIs, filename normalization and decoder implementation are deferred; no general architecture proposal is approved wholesale.

## Acceptance criteria

1. ARENA2 or its immediate parent resolves to the displayed directory; no recursive search, drive scan or silent alternate-source fallback occurs.
2. Every launch rechecks the remembered directory against the explicit required-filename manifest and basic validation rules.
3. Missing, unreadable and empty required files fail. Clearly invalid supported archive headers/index bounds fail without requiring full record decoding.
4. Extra files and structurally compatible modified data pass without original checksums, fixed original file sizes, record counts or content values.
5. Required-data failures appear together with affected file/path and reason. Unavailable directories report the root failure truthfully. Choose Folder / Retry / Quit works without classic assets.
6. Required-data failure blocks the normal startup menu; canceled/invalid candidates preserve committed selection.
7. Missing optional videos neither block startup nor produce recurring startup warnings. Missing death media follows CORE-008 bypass.
8. Validation and successful persistence precede accepted setup. Later source changes retain the active source until restart; the next launch validates the new path.
9. Read-only content directories are supported; validation does not modify original files.
10. Basic validation is distinguished from reader readiness, successful decoding and save compatibility. Later failures are not reported as success because startup checks passed.

These are future verification criteria. No implementation or runtime tests have been performed during specification.

## Consistency review

Reviewed against approved CORE-001–006 source/storage/settings contracts, CORE-008 optional death-video handling, CORE-021 setup/restart navigation, the gameplay decision log, DATA feature catalog and DATA architecture review. No contradiction identified. This feature supplies the agreed validation policy while retaining CORE-004's explicit-path, persistence and restart requirements. DATA architecture proposals remain proposals. No coding tasks or implementation are authorized by this draft.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Technical/content dependencies remain: enumerate the exact required-file manifest from intended consumers; specify each supported format's lightweight header/index checks; verify representative original and externally modified fixtures; define platform filename/case normalization and ambiguous-folder handling; resolve later reader/runtime failure recovery and save/content compatibility under their owners. These deferrals must not be mistaken for completed validation design or waived acceptance criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-001-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). The documented required-file manifest, format checks and other owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
