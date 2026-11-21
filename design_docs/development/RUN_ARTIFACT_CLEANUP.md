# Verification run artifact cleanup

## Default retention policy

**Keep compact evidence, not test builds.** At the end of verification, remove
disposable copied projects, exported executables/PCKs, copied native DLLs/banks,
import/compile caches and isolated runtime state. A reference to `report.json`,
a capture, or a run directory does **not** justify retaining the entire build.
Keep necessary reports, logs, fixture/build identities, reproduction commands,
and reviewed captures at their existing paths when practical. Reports may describe
an executed build that has since been removed; record this explicitly rather than
keeping its executable indefinitely. Rebuild using the authoritative source and
pinned dependencies when another implementation task needs a runnable project.

Default to **zero completed full builds retained**. An exception needs a specific
active debugging/review purpose, an owner/task, and an expiry condition; remove it
when that condition ends. Do not retain one full build per suite, task, platform,
configuration or historical pass merely for possible future usefulness. Pending
acceptance normally requires its reports/captures, not all duplicated binaries.
Preserve unique inputs and material unresolved failure evidence; preserve a whole
failure workspace only when the failure cannot be reproduced from compact inputs.

Review total `.runs` retention above **2 GiB** and identify the largest consumers.
This is a maintenance trigger, not permission to discard required evidence or a
runtime limit. Prefer sub-GiB evidence retention. If required captures exceed the
trigger, document why and remove redundant captures/build copies. Check size
after large export/native suites and before task handoff; do not let multiple
implementation tasks silently accumulate tens of GiB.

`main_project/tests/.runs/` is ignored disposable verification storage. The
authoritative implementation, fixtures, native dependency pins and runners live
outside it. Shared verification and export runners create fresh GUID-named roots
and exclude earlier `.runs` directories when copying resources. Deleting an old
run does not remove a prerequisite implementation, but can destroy review evidence
or one-off authoring work. Do not delete the entire directory indiscriminately.

Before cleanup, agents should:

1. Inspect Git status and the affected verification scripts. Confirm generated
   runs are outputs rather than inputs to the task being continued.
2. Check running engine, decoder, authoring and verification processes, including
   their command lines where available. Preserve active roots. If activity cannot
   be determined, defer deleting potentially active roots.
3. Inventory files, counts and logical sizes without following symbolic links or
   junctions. Search source, evidence and audit references to identify the actual
   artifacts to preserve. Directory references protect their necessary evidence,
   not every executable, dependency copy or cache beneath them.
4. Retain hand-authored work areas, unknown directory types, non-reproducible
   inputs, unresolved failure evidence, human-reviewed captures, and outstanding
   acceptance evidence. Age, failure status or a GUID alone is insufficient.
5. Remove understood inactive build payloads even within referenced runs. Preserve
   compact evidence at its existing paths, and record which runnable builds were
   removed. Preserve custom authoring code/unique inputs separately from its copied
   engine/runtime. Do not delete authoritative fixtures outside `.runs`.
6. Save an exact deletion manifest and retention reasons before deletion. Resolve
   and validate every absolute target as a strict descendant of the intended
   `.runs` directory inside this workspace. Reject traversal through reparse
   points. A disposable junction may be unlinked without recursion after recording
   and validating its target; never delete that target. Use native PowerShell
   `Remove-Item -LiteralPath` for Windows deletion, without shell-built paths.
7. Record actual deletions, failures, logical bytes removed and retained evidence.
   Verify protected roots remain, source files are unchanged, and Git diff checks
   pass. Do not rerun gameplay suites solely for deletion of unused outputs.

Prefer cleanup at a completed verification boundary. Routine output cleanup
within user-authorized work does not require repeated confirmation; deletion of
unique inputs or migration/removal of required evidence needs an explicit scope
decision. Never include reference material, classic data, native toolchains,
downloaded dependencies, source fixtures or production user storage in this task.

## 2026-11-21 first pass (superseded retention policy)

The user authorized identifying and removing unnecessary run artifacts after
IMP-008 increment 3 verification. This cleanup conservatively retains complete
referenced runs, aggregate audits, custom work areas, and their report references.
Only unreferenced roots produced by known verification runners are eligible.
Loose files directly inside `.runs` are retained because several are one-off
authoring/provenance tools. No gameplay or verification source changes are needed.

The local ignored inventory and deletion journal are
`main_project/tests/.runs/cleanup-plan-2026-11-21.json` and
`main_project/tests/.runs/cleanup-result-2026-11-21.json`. They record exact root
names, retention reasons, counts and logical sizes. They are local maintenance
records, not a replacement for the task's committed execution evidence.

Completed result: removed **214 obsolete generated roots / 42,231 files /
6,413,529,096 logical bytes (5.973 GiB)** with zero deletion failures. All
**659 retained roots** remain. This is logical file size, not a claim of exact
physical free-space gain. The IMP-008 increment 3 aggregate still contains all
54 successful selections, and the native debug/release exports, listening
captures and final headless/rendered evidence remain available. The earlier
visually reviewed VP8/Vorbis capture root
`main_project/tests/.runs/verification-rendered-4d06225a878341f1a4fb743eed0d42cc/`
is also explicitly retained from the review history.

No active Godot, FFmpeg, authoring or verification process was present before
deletion. Every target was validated as a direct child of the workspace run root;
the recursive preflight found no reparse points in deletion targets. Post-cleanup
checks confirmed every planned deletion absent, every protected root present,
and `git diff --check` passing. Only this guide, its test README link and the
AGENTS.md maintenance instruction change in Git. No implementation files,
fixtures, dependency/toolchain directories, classic sources or committed evidence
were removed. Gameplay suites were not rerun for this output-only cleanup.

The first pass was too conservative: keeping whole referenced builds left about
58 GiB. The user explicitly requested a second, more aggressive pass. The default
policy above replaces that first-pass whole-directory retention approach.

## 2026-11-21 evidence-only compaction

The second pass removed **234,959 additional files / 61,029,399,426 logical bytes
(56.84 GiB)** from the referenced runs as well as disposable authoring environments.
Copied projects, exported executables/PCKs, native DLLs and large SoundFonts,
import/compile caches, generated raw-frame inputs and isolated test state were
removed. Custom authoring scripts and compact reports/logs/captures were retained.

The final inventory measured **921,641,126 bytes (0.86 GiB)** including cleanup
manifests; the verification JSON added afterward is negligible. No completed test
build executable, DLL or PCK remains. **54,561 preserved files** passed SHA-256
comparison with the pre-deletion inventory. All 54 successful IMP-008 increment 3
audit selections and the reviewed PNG/WAV captures remain at their original paths.
These directories are now evidence archives, not runnable builds. To run tests,
recreate an isolated project/export through the authoritative verification tools;
do not assume an old probe or export directory can still be launched.

The process safely unlinked **243 disposable junctions/symlinks** without following
them. Installed Godot export templates remain available. Authoritative project,
storage/media adapter, runtime manifest and default-bank hashes are unchanged.
One sandbox denial on the disposable `vorbis-authoring` package cache was recovered
with the required filesystem access; the journal preserves that failure and its
successful recovery. No deletion failures remain. `git diff --check` passed;
gameplay suites were not rerun because only unused generated payloads were removed.

Exact local manifests and verification are recorded in:

- `main_project/tests/.runs/compaction-plan-2026-11-21.json`
- `main_project/tests/.runs/compaction-result-2026-11-21.json`
- `main_project/tests/.runs/compaction-verification-2026-11-21.json`

Future agents should apply the default evidence-only policy above after large
verification batches rather than repeat the first pass's whole-build retention.
