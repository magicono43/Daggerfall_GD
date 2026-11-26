# Project disk usage audit — 2026-11-26

**Follow-up completed:** [Storage maintenance](PROJECT-STORAGE-MAINTENANCE-2026-11-26.md)
reclaimed 4.03 GiB of allocated space and added automatic post-review compaction.
The figures below describe the original pre-cleanup audit, not current usage.

Read-only audit requested while the user retested character creation.
Start: **15:59:45 EST (UTC−05:00)**. No files were deleted, moved, compressed in
place or deduplicated. No production code, launcher, settings or retention policy
was changed. Only this report and ignored audit scripts/results were added.

## Findings

The repository occupies **11,020,089,419 logical bytes (10.26 GiB)**.
Windows reports **11,224,146,064 bytes (10.45 GiB)** of unique file allocation
within this workspace. **83% of logical size is `.runs`**. Everything outside
`.runs`, including tools, native dependencies, classic/reference data and Git,
totals about **1.75 GiB**. Source-code growth is not the main issue.

| Location | Logical size | Interpretation |
|---|---:|---|
| `main_project/tests/.runs/` | **8.51 GiB** | Verification/review copies and retained evidence |
| `main_project/tools/` | 702 MiB | Almost entirely pinned toolchains/downloads |
| `base_data_files/` | 513 MiB | Protected classic source data |
| `main_project/native/` | 335 MiB | Native runtime and build caches |
| `reference_material/` | 114 MiB | Protected reference sources |
| Everything else | 127 MiB | Content, scripts, docs, Git and Godot caches |

The successful scan covered **150,662 files**, with **zero access/allocation
errors and zero reparse points traversed**. Seventy hardlinked paths were found;
only 2,520 allocation bytes were duplicate links within the scanned workspace.
Most repeated large runtime files are real copies rather than shared storage.

## Why `.runs` keeps growing

### Closed human-review builds are left runnable

There are **16 retained complete project copies** (about 3.24 GiB including
their evidence), rather than an evidence-only baseline:

| Classification at scan time | Roots | Root size | Project payload excluding `project/tests/.runs/` |
|---|---:|---:|---:|
| Closed human reviews | **13** | 2,832,509,110 bytes | **2,709,234,583 bytes (2.52 GiB)** |
| Active-marked review | 1 | 226,325,779 bytes | 209,507,186 bytes |
| Failed run / explicit review exception | 2 | 422,861,768 bytes | 411,695,455 bytes |

The closed roots include previous ground movement, calendar and creation reviews.
Review launchers create a fresh verified build, open it, and rename the active
marker to a closed marker on exit. They do **not** perform post-review compaction.
For example, `main_project/tools/review_creation.ps1` lines 57–58 close the marker
without compacting the project. `review_ground.ps1`, `review_calendar.ps1`,
`review_scheduler.ps1` and `review_activity.ps1` have the same retention gap.

Subsequent task cleanup repeatedly protects earlier/other-task review roots.
That is conservative for an individual deletion, but without a repository-wide
follow-up it becomes a permanent backlog. Recent cleanup successfully removed
many gigabytes from newly owned runs while this older baseline remained.

The 2.52-GiB figure is a **candidate payload estimate, not a deletion manifest**.
Before compaction, qualify activity and provenance, archive unique source/inputs,
preserve reviewed captures and reports, and allow for the retained archive size.
Do not delete the 13 entire run folders. Their exact names are in `details.json`.

The active-marked root was
`verification-rendered-a586a98a015c4d43a45d5cababa9c13d`. A Godot process was
running during the audit. Its marker became closed after the main scan; it was
still protected throughout. `imp011-view-review-2026-11-23-final` has an explicit
outstanding review purpose and BUILD expiry **2026-11-30**. The remaining failed
ground run needs failure-evidence review before any cleanup decision.

### Evidence is retained in bulky and repeated forms

Selected `.runs` extension totals (categories do not overlap):

| Type | Logical bytes | Size |
|---|---:|---:|
| JSON reports, fixtures and cleanup journals | 3,267,368,476 | **3.04 GiB** |
| DLLs and SoundFont banks | 2,771,759,120 | **2.58 GiB** |
| ZIP/GZIP archives | 1,797,419,201 | **1.67 GiB** |
| WAV files | 435,601,774 | 415 MiB |
| PNG captures | 241,833,030 | 231 MiB |

These sizes must not be added to the full-project candidate estimate: binaries,
fixtures and captures already occur inside those projects. Other formats account
for the remaining roughly 0.58 GiB. The inventory includes loose `.runs` files as
well as **1,927 nonempty run/audit roots**.

Some individual failure result JSON files are about **118 MB**. Root verification
reports also embed the full child result (`verify.ps1:252`) while the original
child `result.json` is retained separately. Detailed cleanup journals themselves
have become substantial: the loose 2026-11-21 compaction plan is 25.75 MB, and
`imp014-increment3-audit/` retains about 185.54 MiB overall.

Three read-only, streamed gzip-level-6 trials produced:

| Evidence | Original | Compressed | Result |
|---|---:|---:|---|
| Large failure result, `7daf…` | 118,067,518 | 3,854,421 | Restored SHA-256 matches |
| Large failure result, `9fa7…` | 117,996,270 | 3,846,151 | Restored SHA-256 matches |
| 2026-11-21 compaction plan | 25,751,763 | 2,724,708 | Restored SHA-256 matches |
| **Total** | **261,815,551** | **10,425,280** | **251,390,271 bytes potential saving** |

No original was changed and no compressed replacement was installed. This proves
compression potential for these samples, not an extrapolated saving for every
JSON file. Archiving must preserve reader compatibility, source hashes and paths
or explicit archive references; replacing reports indiscriminately would break
existing audit/reproduction readers.

There are also **17 groups of byte-identical ZIP archives**. Keeping one physical
copy per group would avoid **147,542,923 bytes (140.71 MiB)** of duplicate
storage, subject to preserving references. The total source-archive footprint is
much larger than that confirmed duplicate subset; similar filenames alone do not
establish identity. Three sampled run copies of the 93,854,720-byte
`avcodec-62.dll` match the authoritative runtime DLL's SHA-256 exactly.

### Cache cleanup alone will not solve this

Cache-tagged paths and isolated engine state inside run roots total about
**161 MiB**, a small share of `.runs`. The two ordinary Godot cache folders
together are only about **6.7 MiB**. Native `.zig-cache` folders outside `.runs`
total about **188.5 MiB**. The main pinned toolchain is about 702 MiB and should
not be treated as abandoned verification output.

## Corrective work suggested by the audit

1. **Compact closed review builds globally**, after per-root activity/input checks,
   instead of permanently deferring them because another task created them.
   Preserve compact evidence and verified source snapshots. The measured closed
   project payload is the largest clearly identifiable first target.
2. **Add post-review compaction to the shared launcher lifecycle**, after its owned
   engine exits and after evidence preservation succeeds. Preserve active and
   explicitly justified review/debug exceptions with expiry and owner.
3. **Retain large JSON losslessly and avoid storing full results twice.** Use a
   compatible archive/reference reader and hash receipts; keep essential summary
   fields available without re-expanding entire definition graphs.
4. **Share identical source archives by verified identity**, preserving per-run
   references, instead of adding another full archive for each repeated check.
5. **Unify the maintenance trigger.** The default cleanup guide still says 2 GiB;
   the current AGENTS instructions say review above 8 GiB. Both are review triggers,
   not hard caps. Record a qualified action/deferred-owner list after review;
   repeatedly acknowledging the size does not address accumulated closed builds.

These are recommendations, not implemented tooling changes or cleanup approval
claims. This audit intentionally left the user's review and all original files
untouched. No gameplay suite was run for this metadata-only investigation.

## Evidence and limitations

The live scan ran approximately **16:02:36–16:03:12 EST**; review output and marker
files can change while the user tests. Logical bytes are file lengths. Allocation
uses Windows `FileStandardInfo.AllocationSize`, with same-file hardlinks deduplicated
within this repository where `FileIdInfo` is available. Directory/MFT overhead,
alternate streams, volume-level shared blocks and files outside the workspace are
not measured. Snapshot totals exclude audit files written after the scan.
The subsequent detail pass totals 9,144,734,620 bytes under `.runs`, versus the
initial 9,141,937,680-byte snapshot; audit output and live review state account
for the small intervening difference. Folder totals reconcile exactly to the
initial project total. Detail extension figures describe that subsequent pass.

Supporting read-only scripts and full inventories:
`main_project/tests/.runs/project-space-audit-2026-11-26/`:

- `scan.py`, `inventory.json`: complete folder/file/allocated-space inventory.
- `details.py`, `details.json`: closed-review candidates, extension totals, exact
  archive duplicates, sampled binary hashes and compression round-trip receipts.

Inventory SHA-256:
`6A22879634D295B298AB63956EDC56FC6203BF07E34FAB724A663B4F92C2E630`

Details SHA-256:
`EB7113F65B837567FFDA5A87516BBA7F0075FAED3F033889EF03A6A3CA8D1BEB`

Audit completed **16:09 EST (UTC−05:00)**. All pre-existing work remains intact;
the report is uncommitted for user review.
