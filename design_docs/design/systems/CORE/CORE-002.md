# CORE-002 — Startup log retention

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose

Preserve local diagnostics for startup failures, crashes and troubleshooting across launches.

## Intended player experience

Logging runs locally without interrupting normal play. Players have current and previous launch diagnostics for troubleshooting. If logging stops, a single non-blocking warning explains the loss of file diagnostics while gameplay remains available.

## Confirmed requirements

Confirmed in the first CORE-002 interview on 2026-11-05:

- Retain the current launch and one previous launch.
- Limit each file to 200 MiB (209,715,200 bytes). Do not add files beyond the agreed launch-retention count. Stop appending at the limit, reserving space for a clear log-limit-reached message. Later errors can therefore be lost.
- Record game version/build, launch time, operating system, selected storage mode and enabled mod identifiers/versions. Available metadata is recorded immediately, with the mod list added after discovery as described below.
- Logs remain local. Exclude save contents, credentials and deliberate collection of the operating-system username.

Confirmed in the second CORE-002 interview on 2026-11-05:

- Flush after every message. This reduces buffered loss on crash but increases disk activity and does not guarantee survival of power failure.
- When the cap is reached, write the reserved final limit message and show one non-blocking player warning that file logging has stopped for this launch. Continue gameplay without repeated warnings.
- If preserving the previous log fails, preserve existing files, disable file logging for the launch and show the CORE-001 warning. Do not overwrite existing diagnostics merely to start a new log. Recovery must avoid further destructive changes; multi-step rotation is not assumed to be automatically reversible.

Confirmed in the third CORE-002 interview on 2026-11-05:

- Use Player.log and Player-prev.log. Use readable text with a timestamp and severity for each message, including stack traces for exceptions.
- In file logs, replace the user-home path prefix with <user-home>. Exclude credentials and save contents from diagnostic messages. On-screen storage errors may show the actual failed path for troubleshooting.
- Record available startup metadata immediately. Add enabled mod IDs/versions once mod discovery finishes. Until established, clearly label the mod list as not yet established so early failures do not imply that no mods were enabled.

Confirmed in the fourth CORE-002 interview on 2026-11-05:

- Include informational messages, warnings, errors and exceptions by default. Verbose/debug tracing is disabled in normal releases. Keep repeated messages individually; no initial suppression policy is included.
- If a message exceeds remaining capacity, truncate it to fit and mark the truncation, then write the reserved limit message and stop file logging. Count encoded bytes, including metadata and line endings, within the 200 MiB cap.
- On runtime write/flush failure, disable file logging for the remainder of the launch, retain whatever data was written and show one non-blocking warning. Continue gameplay without repeated retries or root switching. Attempt logging again next launch.

## Inherited approved requirements

[CORE-001](CORE-001.md) places logs under the selected root, permits play with a warning when file logging is unavailable, separates development storage by default, and enforces one running instance per root. Logging does not authorize switching roots or altering gameplay persistence.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/DaggerfallUnityApplication.cs`, SubsystemInit, InitLog and LogHandler: the previous Player.log replaces Player-prev.log before a fresh Player.log is created. The writer auto-flushes each write. Rotation exceptions are written into the new log if it opens; new-file creation is outside that catch. Source baseline is the local 1.1.1 Release snapshot; exact commit is unavailable as recorded in the repository overview. The source remains unchanged.

## Relevant formulas and parameters

Per-file cap C = 200 × 1024 × 1024 = 209,715,200 bytes. With two retained files, retained log content is bounded by 400 MiB (419,430,400 bytes), excluding filesystem overhead. New output must fit within C after accounting for the reserved final marker and any truncation marker. When even the whole truncation notice cannot fit, emit only the reserved final limit notice. Metadata, exception traces, timestamps and line endings count toward the limit. Exact encoding and marker text remain implementation details; calculations must use the actual encoded output after privacy filtering.

There are no gameplay balance formulas. Repeated errors can consume the cap quickly; stopping at the cap intentionally sacrifices later diagnostics.

## Required data

Selected root and exclusive-use readiness from CORE-001; current/previous file paths; byte count and reserved marker size; active/disabled/capped status; whether a warning has already been presented; launch metadata and mod-list readiness; message timestamp, severity, text and optional exception trace. These are application-session data, not character state.

## Detailed lifecycle and failure behavior

Use the selected root and acquire its CORE-001 exclusive-use protection before modifying logs. On a successful new launch-log setup, preserve the last current log as Player-prev.log, replacing the older retained launch, then create Player.log for this launch. On the first launch, no previous file is required. Do not rotate on character creation, save loading or scene changes.

The preservation-failure rule requires avoiding destructive truncation of the existing current log. If preservation fails, stop further rotation changes and disable file logging. Rotation is not assumed to be an atomic multi-file transaction; preservation of every historical file across power loss is not guaranteed by the agreed rules. A missing new current log must not cause deletion of the sole surviving previous log just to initialize logging.

If initial creation/opening fails, apply CORE-001's non-blocking logging-failure warning and continue without file logging. If startup fails before the root is usable or before this logger can start, this feature cannot promise a file record of that failure. Startup recovery UI remains CORE-001's responsibility.

At the size cap, record the limit notice within the cap when writing remains possible, then disable file output for the launch. A disk/write failure may prevent even the final notice; never retry recursively through the failed file logger. Preserve readable partial diagnostics without claiming that an unsuccessful write/flush succeeded. Logging becoming unavailable never authorizes gameplay root switching.

## Inputs, outputs and events

Inputs: resolved storage context, launch metadata, diagnostic messages, mod-discovery result, filesystem outcomes and process shutdown. Outputs: current/previous local text logs, updated logging availability and one non-blocking warning when logging stops or cannot start. Conceptual notifications distinguish active, capped and failed logging. API names and event signatures are not selected here. If UI is not yet ready, present the warning when it becomes available without blocking bootstrap or duplicating warnings.

## Cross-system interactions

CORE-001 owns root choice, development isolation and exclusive use. CORE bootstrap starts logging once storage is ready. DEV/game subsystems supply severity-tagged diagnostics. MOD supplies enabled IDs/versions after discovery; until then the log states that the list is not yet established. UI presents failure/cap warnings independently of the file logger. Log failures do not determine SAVE operation success. This feature specifies local files, not remote telemetry or automatic uploading.

## Edge cases, privacy and failure conditions

- Full disk, read-only files, permission changes, drive removal or file locks can prevent rotation, creation, writes or flushes; follow the failure policies above.
- Crashes may leave partial messages. Per-message flushing reduces buffered loss but does not guarantee physical-disk durability or survival of power failure.
- Handle oversized multiline exception messages and multibyte text without exceeding the cap or producing invalid encoded text. Truncation/limit notices also count toward it.
- Apply privacy filtering to metadata, message text and traces before byte accounting. Home-prefix substitution is not a guarantee that arbitrary third-party text contains no other personal information. Credentials and save contents must not deliberately be logged; untrusted mod-provided diagnostics require attention to these rules.
- Do not write logging-failure warnings back through the failed logger in a retry loop. Repeated messages otherwise remain individual entries, as confirmed.
- Startup failure before mod discovery must leave an explicit not-yet-established mod-list status rather than implying an empty list.
- Separate roots can log independently. Same-root competing writers are prohibited by CORE-001.

## Configuration and balancing options

Initial policy is fixed: two retained launch files, 200 MiB each, per-message flush, informational-and-higher output and no repeated-message suppression. No player-facing retention/size tuning, debug-toggle UI or remote reporting is specified. Debug facilities beyond the release default can be designed separately. No gameplay balance effects apply.

## Save/load considerations

Logs are independent of character saves. Saving/loading does not rotate logs, reset their cap, restore logging after a failure or persist logger state inside a save. Save outcomes may generate diagnostics subject to privacy rules. File-logging success must not be used as evidence that a game save succeeded.

## Technical constraints

Target project engine is Godot 4.7.2; reproduce the agreed behavior without requiring DFU's Unity handler. Keep all output under the approved root. File initialization must respect exclusive-use protection and existing diagnostics. Bound encoded output and avoid recursive failure reporting. Specific Godot logging APIs, encoding, timestamp syntax/timezone and rotation mechanism are deferred implementation details. This phase does not select a logging library or implement code.

## Acceptance criteria

1. Two successive successful launches produce Player.log for the current launch and Player-prev.log for the preceding one; a later launch replaces the older retained history without extra retained launch files.
2. Neither generated file exceeds 209,715,200 bytes. Metadata, line endings, multibyte text and notices count toward this limit.
3. A message too large for remaining space is truncated with an indication when space permits; the reserved final notice is written and file logging stops. UI gives one non-blocking warning and gameplay continues.
4. Successful message output is flushed after each message. Exceptions include traces; ordinary entries include timestamp and severity. Default release output includes info/warnings/errors/exceptions and excludes verbose/debug output. Repeated messages remain distinct.
5. Available launch metadata is written immediately. The mod list is explicitly pending until discovery provides enabled IDs/versions; an early failure does not falsely report no mods.
6. File output substitutes the user-home prefix and excludes credentials/save contents. On-screen path diagnostics may retain the actual failed path.
7. Preservation failure does not truncate the existing current log to create a new one. File logging disables and warns while gameplay remains available. Initial open/create failure similarly remains non-blocking.
8. Runtime write/flush failure preserves existing written data, disables file logging for the launch and gives one non-blocking warning without repeated retries or root switching. Next launch attempts normal setup again.
9. Save/load and scene changes neither rotate files nor reset the cap/disabled state. Storage roots and development isolation comply with CORE-001.
10. Recovery/warning presentation works without a functioning file logger. A forced crash does not imply a guarantee that the latest flushed bytes survived power loss.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001 v1, the decision log, CORE catalog and CORE architecture review. No contradiction identified: root choice, isolated development data, exclusive use and non-blocking logging failure are preserved. CORE-001's retry for failed game saves is distinct from disabling failed file logging for the rest of a launch. CORE-AR-01 remains Proposed outside the specifically accepted feature rules. All 12 CORE-002 interview decisions are represented.

## Outstanding questions and approval

No remaining player-policy question is identified as blocking draft review. Deferred details are encoding, timestamp format/timezone, exact warning/notice wording, API signatures and rotation implementation. Rotation failure/crash testing must validate the stated preservation rules; full multi-file power-loss atomicity has not been promised.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-002. This document is finalized v1. Approval reference: CORE-002-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented deferrals remain deferred. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
