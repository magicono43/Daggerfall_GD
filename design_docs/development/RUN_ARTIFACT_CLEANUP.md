# Verification run artifact cleanup

## 2026-11-22 IMP-009 increment 3

All owned source/regression/export commands returned before their payload cleanup.
Non-elevated activity checks found no Godot/Startup process before final cleanup;
no WMI/CIM or security-setting dependency was introduced. Exact checked targets,
deletion lists and preserved evidence hashes are in
`main_project/tests/.runs/imp009-increment3-cleanup-*.json`.

Removed 35,023 files / 6,564,977,592 logical bytes of copied projects, exports,
runtime roots and caches. Reports/logs/reviewed captures remain under each owned
root's `evidence/`; installed-template junctions were unlinked without recursion.
Eight large JSON reports/results were preserved in adjacent gzip archives after
decompressed SHA-256 verification, reducing 210,258,822 bytes to 5,534,269 bytes.
Original paths hold explicit archive pointers. See
`imp009-increment3-evidence-archives.json` and `imp009-increment3-retention.json`.

Total `.runs` retention measured 1,379,051,957 bytes (1.28 GiB), below the 2 GiB
review threshold, with zero completed full builds, EXE/DLL/PCK payloads or reparse
points. Source/reference/classic data, installed tools, unique inputs and earlier
acceptance evidence were protected. The [execution evidence](evidence/IMP-009-increment-3-2026-11-22.md)
and its audit identify the final verified sources/builds and remaining owner gates.

## 2026-11-21 IMP-009 increment 2

The increment-2 verification/export commands completed before cleanup. A normal
Get-Process check found no Godot/FFmpeg process; no elevated WMI/CIM dependency
was introduced. Exact manifests under `main_project/tests/.runs/` are
`imp009-increment2-cleanup-plan.json` and `imp009-increment2-cleanup-result.json`.
Removed 22,876 files / 5,747,966,876 logical bytes from reproducible payloads in
23 explicitly owned run roots. Preserved reports/logs/captures were relocated
under each root's `evidence/` with SHA-256 verification. Installed-template
junctions were unlinked without recursion, leaving their targets intact.

Thirty-two large JSON reports/results were additionally preserved byte-for-byte
in adjacent gzip archives after decompressed SHA-256 verification, reducing
659,205,033 bytes to 19,964,260 bytes. Their original JSON paths now contain
explicit archive pointers, not runnable terminal results. See
`imp009-increment2-evidence-archives.json` and `imp009-increment2-retention-final.json`.
No completed full build remains for this task. Prior acceptance evidence,
classic/reference sources, installed tools and authoritative files were protected.
The [execution evidence](evidence/IMP-009-increment-2-2026-11-21.md) and its final
audit identify the verified builds and readable summaries. Older records below
retain their historical cleanup outcomes.

## Default retention policy

### Standing authorization and permission prompts

The user authorizes routine cleanup of understood, inactive, reproducible
verification outputs under `main_project/tests/.runs/` as part of normal work.
This authorization persists across chats and batches. Agents should perform that
cleanup without asking the user for another task-level confirmation, while
preserving the evidence, inputs and protected roots required below. Removing
unique inputs or necessary evidence still requires a separate scope decision.

Use ordinary workspace permissions. Prefer reliable non-elevated activity checks
and the verification runner's owned-child lifetime evidence when available.
Do not make privileged WMI/CIM access a cleanup prerequisite when sufficient
activity evidence is already available. In the IMP-009 work, bundling
`Get-CimInstance Win32_Process` into each cleanup command caused repeated
execution-environment escalation requests; that is not a repository requirement
or a reason to ask for fresh cleanup authorization.

A terminal report alone does not prove that a build was never relaunched. Account
for active debugging/review use and any uncertainty about current activity. If a
target cannot safely be established as inactive, leave that target and report the
deferral; continue cleanup of other verified targets. Do not bypass a denied
operation, broaden deletion scope, or change host security settings to avoid an
approval. Host-enforced execution approvals remain separate from this standing
authorization and cannot be waived by repository instructions.

### Retained artifacts

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

## 2026-11-22 IMP-010 increment-1 compaction

The issued geographic-record increment completed its source/rendered/Windows
export checks and affected regressions. Its 27 inactive generated run roots
were compacted under standing authorization: 33,949 files /
5,939,147,332 logical bytes removed; 262 evidence files hash-verified.
Ten large verification/diagnostic JSON files were losslessly archived with verified
recovery hashes and readable pointers. Zero completed full builds from this
increment remain, with no deletion failures. Installed junction targets and
protected existing inputs/evidence remain. The measured final run retention is
approximately 1.30 GiB. Exact manifests are `tests/.runs/geography-cleanup-2026-11-22.json`
and `tests/.runs/geography-archive-result.json` under `main_project/`; see the
[execution evidence](evidence/IMP-010-increment-1-2026-11-22.md) and its versioned audit.
