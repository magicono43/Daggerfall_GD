# CORE-003 — Settings initialization and recovery

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose

Initialize usable preferences and recover from missing, invalid or damaged settings while preserving valid player choices.

## Intended player experience

First launch works without a settings warning. Valid preferences survive updates. Recovery affects only what cannot safely be retained and explains the result once. Installation or persistence failures are actionable rather than silently discarding preferences.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Create a missing settings file from packaged defaults and continue without a warning. This is normal first-launch behavior.
- For an invalid individual setting in an otherwise readable file, replace only that setting with its declared default. Preserve valid preferences and show one recovery summary. Out-of-range numeric values use the declared default rather than clamping to the nearest bound.
- For unreadable or structurally damaged settings, preserve the damaged file, try a validated backup, and use packaged defaults if no usable backup exists. Show a recovery summary identifying the source used. Do not immediately overwrite the damaged file as part of recovery.

Second interview, confirmed by the user on 2026-11-05:

- Keep one previous settings version that passed full validation and was successfully persisted. Replace that backup only when a different validated version is successfully saved. Parsing alone must not replace it.
- Across game updates, preserve valid existing preferences, add new settings with defaults and explicitly migrate renamed or changed settings. Preserve unknown keys without applying them rather than deleting possible preferences from another version.
- Write and validate a temporary file before replacing the active settings file. Preserve the previous valid version if publication fails. Startup write failures follow CORE-001 and block gameplay entry with recovery options. During gameplay, keep current preferences in memory, warn that they were not saved and allow retry without switching roots.

Third interview, confirmed by the user on 2026-11-05:

- Keep one separate recovery copy of damaged input. Replace an older recovery copy only after safely preserving the new one. Recovery copies are distinct from validated backups.
- If required preservation or backup update fails, stop the settings replacement and report failure. At startup offer Retry or Quit; during gameplay retain in-memory preferences and allow retry. Do not proceed without agreed recovery protection.
- Detect settings from a newer unsupported format version and leave them unchanged. Explain incompatibility and offer Quit or explicit reset to this build's defaults, after preserving the newer file.

Fourth interview, confirmed by the user on 2026-11-05:

- Use human-readable settings.ini with an explicit settings-format version. Exact backup and recovery filenames may remain implementation details.
- After successful recovery, show one non-blocking summary identifying settings reset to defaults and whether backup or defaults were used. Normal first launch and adding new default settings during an upgrade remain quiet. If recovery cannot be safely persisted, show the blocking failure screen instead.
- Missing, unreadable or invalid packaged defaults are an installation error. Explain the problem and block gameplay entry. Do not invent fallback values or overwrite existing user settings. Packaged defaults must pass validation.

Fifth interview, confirmed by the user on 2026-11-05:

- When restoring from a validated backup, preserve it while publishing the recovered active file. Never replace it with damaged input. If both user files are unusable, preserve the damaged active file, publish validated defaults and establish a validated backup from those defaults.
- Validate related settings together. If individually valid values form an incompatible combination, reset only the conflicting group to its declared compatible defaults and include it in the recovery summary.
- For an older settings format with no supported migration, leave it unchanged, explain incompatibility and offer Quit or explicit reset to current defaults after preserving the original. Do not guess a translation.

## Inherited approved requirements

[CORE-001](CORE-001.md): settings follow the selected storage root; required settings-storage failures block startup. Development storage is separate by default and a root permits only one running instance. No automatic root switching or migration.

[CORE-002](CORE-002.md): local diagnostics exclude credentials and save contents and filter user-home prefixes. File logging failure permits play with a warning; settings persistence must not depend on logging success.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/SettingsManager.cs`: ReadSettingsFile loads packaged defaults, creates a missing user file, tries backup after a read/parse exception and then recreates defaults if backup fails. It backs up parsed data before SyncIniData and typed-value access. SyncIniData adds missing sections/keys and removes unknown ones, then writes. Typed getters can fall back to zero, false, a minimum or a supplied color default. WriteSettingsFile catches write exceptions and logs failure without returning a result. Portable mode translates certain configured paths on load/save.

Source baseline: local DFU 1.1.1 Release; exact commit unavailable in the repository overview. Source remains unchanged. These observations do not establish intended behavior for the new game.

## Detailed initialization and recovery rules

Validate packaged defaults before modifying user settings. Parse and identify the user's format before applying it. For supported input, perform explicit migrations, add missing defaults, validate types/ranges and related groups, and preserve unknown keys without applying them. Unknown values are retained as opaque data, not treated as active preferences or silently reinterpreted.

Missing settings initialize quietly from defaults. Readable settings recover individual invalid values/groups without discarding unrelated valid choices. Structurally damaged or unreadable settings use the validated backup, then defaults if needed, while preserving damaged active input before replacing it. An inability to read/preserve input does not authorize overwriting it: block startup with Retry/Quit if the required preservation cannot complete.

Unsupported older/newer format versions require an explicit reset choice; do not bypass that choice by silently loading another file. Reset preserves the original in the separate recovery copy before publishing defaults. A failed preservation leaves the original intact and reports failure.

Normal successful changes keep one previous fully validated, persisted version as the backup. Merely loading/parsing or saving identical settings does not advance backup history. Recovery never promotes damaged input into that backup. Restoring backup retains that backup; defaults recovery establishes a validated default backup. A new first-launch installation has no previous user revision; its initial active data is validated defaults. Exact staging and first-launch backup initialization mechanics are implementation details, subject to the recovery rules.

Write and validate temporary output before replacing active settings. All required preservation/backup operations must succeed before completing replacement. Report success only when the required publication completes. Preserve a previous valid version if publication fails; do not assume a multi-file operation is automatically atomic. Startup cannot enter gameplay until required settings persistence succeeds. Runtime persistence failure keeps current preferences in memory and supports explicit retry without root switching.

## Relevant formulas and parameters

No gameplay formulas apply. Validation uses declared types, permitted values/ranges and compatible group defaults. Invalid numeric values use the declared default, not clamping. Retention is one previous validated settings version plus one separate recovery copy; active settings and temporary publication files are distinct. There is no agreed settings-size cap or automatic retry interval.

## Required data

Packaged defaults; settings-format version; per-setting type/default/constraints; compatible-group rules; supported migrations; active recognized values; retained unknown keys; selected storage root; backup/recovery paths; validation/recovery results; persistence outcome and dirty in-memory state. Game version and settings-format version are distinct concepts. Settings IDs and actual preference inventories belong to their consuming features.

## Inputs, outputs and events

Inputs: selected storage context, packaged defaults, active/backup data, version/migration metadata, preference changes, filesystem results and explicit retry/reset/quit choices. Outputs: a validated in-memory preference set, safely published settings/backup/recovery data where required, recovery summary, or blocked startup/failure result. Conceptual outcomes distinguish initialized, recovered, incompatible, installation-error and persistence-failed states. API and event names are not selected here.

## Cross-system interactions

CORE-001 supplies root selection, exclusive use, startup storage recovery and development isolation. CORE-002 provides optional diagnostics under its privacy rules. CORE-003 must work even when file logging is disabled. UI presents recovery summaries and explicit incompatibility/reset choices. Setting owners supply defaults and validation contracts. CORE-006 governs when validated settings take effect, live application and restart requirements; this document does not approve new application behavior. SAVE owns character persistence; MOD owns mod-specific settings unless separately integrated through an approved contract.

## Edge cases and failure conditions

- Missing, unreadable or invalid packaged defaults block gameplay as an installation error without modifying user files or inventing defaults.
- An unreadable active file may also be impossible to copy. Preserve-before-replace still applies; failure stops replacement instead of destroying evidence.
- A readable file may contain invalid types, out-of-range numbers or incompatible groups. Repair only affected settings/groups. A structurally unparseable file follows whole-file recovery.
- A backup must fully validate for the current build before use. Parsing alone is insufficient. Unsupported migrations follow the explicit incompatibility policy.
- Unknown keys survive supported-file updates without affecting runtime behavior; preserving them does not imply support for the settings they describe.
- Full disk, permissions, drive removal, failed backup update or replacement failure must not be reported as successful persistence. Keep a usable previous version and report the appropriate startup/runtime failure.
- Preserve an older recovery copy until its replacement is safely recorded. Do not accumulate an unbounded archive. No preservation of every historical damaged backup is promised.
- Cross-file power-loss consistency must be validated during implementation; temporary writes alone do not establish a universal atomicity guarantee. Recovery must not promote incomplete or invalid output.
- Recovery summaries identify setting names/groups and source used; avoid logging raw file contents or unknown values that might contain private information.

## Configuration and balancing options

Human-readable settings.ini permits manual editing, subject to validation. Recovery, backup retention and version handling are fixed policies. Actual preference defaults/ranges remain feature-owned; this document sets no gameplay balance values. Custom storage paths and automatic migration between storage roots remain outside CORE-001 scope. Explicit settings-format migration is a different operation from moving data between roots.

## Save/load considerations

Application preferences are stored under the selected root independently of character saves. Loading a character does not restore historical application preferences or select a different root. Runtime settings-write failure retains in-memory values but does not guarantee they survive exit. This specification does not define character-specific gameplay options, mod save state or whether particular preferences require restart.

## Technical constraints

Project target: Godot 4.7.2. Implement the agreed behavior without depending on Unity's INI parser. Use one owner for validated settings and explicit persistence results. Respect CORE-001 exclusive use before mutation. Validate temporary serialized output and ensure required preservation precedes destructive replacement. Library, INI dialect, encoding, exact version numbers, migration implementation and backup/recovery filenames remain implementation details. Retention does not require preserving original whitespace/comments; this has not been specified.

## Acceptance criteria

1. Missing settings produce validated defaults and a persisted active settings.ini without a warning; invalid packaged defaults instead block startup without altering user files.
2. Invalid individual values, including out-of-range numbers, use declared defaults while unrelated valid values remain unchanged.
3. Incompatible groups reset only that group to declared compatible defaults and appear in the recovery summary.
4. Structurally damaged active input is preserved before replacement. A fully validated backup is used when available; otherwise validated defaults are published and a validated default backup established.
5. A backup restored into the active file remains usable as backup; damaged active data never replaces it. Ordinary changes retain one previous fully validated persisted revision; parse-only and identical-save operations do not advance history.
6. Recovery-copy replacement is bounded and does not destroy the older copy before preserving the new input safely.
7. Supported upgrades preserve valid preferences, add new defaults, explicitly migrate changed settings and retain unknown keys without applying them. Adding default settings alone is quiet.
8. Unsupported older/newer versions remain unchanged until explicit reset. UI explains incompatibility and offers Quit or reset after preservation; failed preservation prevents replacement.
9. Required writes validate temporary output before active replacement. Preservation/backup/publication failure reports failure and retains a previous valid version; startup offers Retry/Quit and blocks play where required. CORE-001 storage-root recovery remains available for root failures.
10. Runtime write failure retains in-memory preferences, warns that changes were not saved and permits retry without root switching.
11. Successful recovery produces one non-blocking summary naming resets and backup/default source. Unsafe persistence shows the blocking failure screen instead of a success summary.
12. Operation works with unavailable file logging, respects root isolation/exclusive use, does not dump sensitive settings data into logs and does not change preferences by loading a character save.

These are future validation criteria. No implementation or runtime tests were performed during this specification phase.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001 v1, CORE-002 v1, the decision log, CORE catalog and CORE architecture review. All 15 CORE-003 interview decisions are represented. No contradiction identified: settings-storage failures block startup, runtime persistence failures retain memory/retry, logging is optional and root changes are not automatic. Format migrations do not authorize cross-root migration. CORE-AR-01 remains Proposed beyond the specifically accepted feature policies.

## Outstanding questions and approval

No blocking player-policy question is currently identified. Deferred implementation details include INI dialect/encoding, migration version map, setting inventory and compatible-group definitions, backup/recovery filenames, crash-recovery publication mechanics and API signatures. Actual setting application is CORE-006 scope. These deferrals do not waive validation or preservation criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-003. This document is finalized v1. Approval reference: CORE-003-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented deferrals remain deferred. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
