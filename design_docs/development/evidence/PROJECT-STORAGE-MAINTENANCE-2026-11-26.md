# Project storage maintenance — 2026-11-26

Start: **16:13:53 EST (UTC−05:00)**. The user explicitly authorized the corrective
work recommended by the [disk audit](PROJECT-DISK-USAGE-2026-11-26.md).
Maintenance is complete and verified. All changes remain uncommitted.

## Implemented scope

`main_project/tools/run_artifacts.ps1` now supplies shared review compaction,
transparent JSON compression and verified immutable ZIP sharing. The creation,
calendar, scheduler, activity and ground launchers call it after successful owned
review processes exit. Ground waits for all requested model/source-placement
reviews before compacting their common project. Cleanup failure visibly defers
the build instead of being interpreted as a gameplay/review result.

`maintain_run_artifacts.ps1` supplies explicit closed-review roots, protected
roots, optional scoped evidence discovery and plan/apply modes. Unknown work
areas and full/active/explicitly protected builds are excluded from the global
evidence sweep. No elevated process query, new dependency, volume-wide setting,
security change or gameplay/native adapter change is required.

Before deletion, the shared compactor:

- Checks exact workspace/run containment, all ancestors/subtrees for reparse
  points, closed markers, passed preparation and original project/child bindings.
- Requires no engine/decoder process for bulk cleanup, or a successful exited
  owned child for the launcher's own root.
- Archives every unfamiliar source/input extension, image and older/custom
  binary; omits copied native/bank/tool bytes only when matching authoritative
  files still exist. Verifies nonempty ZIP entries by restored SHA-256.
- Records an exact payload plan; preserves original child evidence paths and
  hashes; removes copied project payload and known regenerated caches.

Large inactive JSON uses per-file NTFS compression with unchanged paths, file
lengths and SHA-256. Ordinary JSON readers remain usable. This avoids changing
historical report formats or migrating all their consumers. ZIP consolidation
uses matching byte hashes, same-file identity verification, rollback backups,
preserved paths and read-only shared archives. Every operation gets a receipt.

The Windows API choices follow Microsoft's
[FSCTL_SET_COMPRESSION](https://learn.microsoft.com/en-us/windows/win32/api/winioctl/ni-winioctl-fsctl_set_compression)
and [GetCompressedFileSizeW](https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getcompressedfilesizew)
contracts. Measurements account for compressed allocation and duplicate hardlink
identities, rather than summing logical lengths and calling that reclaimed disk.

The default cleanup guide now agrees with AGENTS.md's **8-GiB review trigger**;
historical 2-GiB execution notes remain historical. Active/exception ownership
and expiry remain required; older closed runs are no longer a permanent exemption.

## Executed backlog compaction

The 13 closed review roots listed by the audit were all compacted, removing
**2,805,221,168 copied/cache bytes** before subtracting their newly retained source
archives. The batch had zero deferrals. Child results, typed inputs, logs and
captures retain their existing paths and verified bytes. Each root contains
`review-source.zip` and `REVIEW-COMPACTION.json`.

The following roots remain explicitly protected:

- Latest ongoing creation review `verification-rendered-a586a98a015c4d43a45d5cababa9c13d`:
  the user was retesting during the audit. `RETAIN-BUILD.json` records owner,
  purpose, rebuild command and review expiry no later than **2026-11-27**.
- Failed ground investigation `verification-rendered-ce9c10bf5cc348d0ad4e8708dcd4877d`:
  failure/unique evidence requires qualification before any full-build removal.
- `imp011-view-review-2026-11-23-final`: explicit outstanding review purpose,
  with BUILD expiry **2026-11-30**.

External classic/reference data, pinned toolchains, authoritative gameplay/native
files, unique inputs and unrelated user work remain untouched. The review/tool
and documentation changes described above are intentional.

## Verification

The maintained disposable boundary suite
`main_project/tests/tools/run_artifacts_cases.ps1` passes **47 checks**. It covers
unique-extension/image/custom-native preservation, original child paths/hashes,
cache removal, active/failed/foreign-root/live-child rejection, nonempty archive
recovery, reparse rejection, idempotence, NTFS compression with ordinary JSON
reads, byte-identical ZIP identity and actual plan/apply discovery/grouping.
All eight shared-helper/maintenance/review/test scripts parse without errors.

The completed final unit result is
`main_project/tests/.runs/artifact-maintenance-tests-b497738ed7d14ea7b37ef6e5af61af47/result.json`.
Test runtimes were removed after ownership/path checks, retaining compact results.
This is storage/tool verification, not new gameplay or human-acceptance evidence.

The creation review launcher was exercised end to end in
`verification-rendered-44bc77a23fc646499b59ad83fa2f7610`: **3,365 rendered creation
assertions and six opening smoke assertions pass**, with `human_pass=false`.
After its owned engine exited, automatic compaction removed 216,440,688 copied
bytes and retained its source archive, child results/logs/captures at the original
paths. This temporary verification build did not exist in the before sample;
its removal is not counted as pre-existing disk reclaimed.

The other four launcher integrations were parsed and their success/loop control
flow inspected; their gameplay suites were not rerun for artifact maintenance.
All use the same qualified compactor. No gameplay code or export adapter changed.

An independent Python integrity pass verifies **22,046 archive/file comparisons**
across 14 compacted roots: 20,185 restored source entries, 848 retained evidence
hashes, 238 matching authoritative reproducible files, 673 compressed-JSON
receipts, 64 shared archive paths/identities, 29 unchanged gameplay/data/test
source hashes, three unchanged native boundaries and six protected-project
file hashes. These are integrity comparisons, not additional gameplay tests.

Eight delivered tool/test sources were archived and stream-hash recovered in
`delivered-tools.zip` / `delivered-tools.json`. No runtime or full fixture was
retained solely to prove this maintenance.

## Space recovered

| Measurement | Before | After |
|---|---:|---:|
| Entire project, logical file lengths | 10.27 GiB | 7.77 GiB |
| Entire project, unique allocated storage | **10.46 GiB** | **6.43 GiB** |
| `.runs`, logical file lengths | 8.52 GiB | 6.02 GiB |
| `.runs`, allocated storage (deduplicated) | about 8.66 GiB | **4.63 GiB** |

**Net measured reclamation: 4,327,453,616 bytes (4.03 GiB)** of allocated file
storage. The exact project values are 11,227,178,088 before and 6,899,724,472 after.
Retained review source archives and new tool source files present during the scan
are included in the after sample, rather than subtracting gross deletion counts
and calling that a net gain. Subsequent compact audit writes are excluded.

The large-evidence batch compressed **665 JSON files**, saving 1,452,417,024
allocated bytes, and consolidated **64 ZIP paths**, saving 147,529,992 allocated
bytes. Both operations had zero deferrals. Per-review compression and the small
before-inventory compression have separate receipts. Paths, logical bytes and
hashes remain compatible with existing readers.

Windows Explorer's **Size** can remain larger than **Size on disk** because the
same logical evidence bytes remain readable through compression/shared archives.
Some folder-size tools also count each hardlink path separately; this audit
deduplicates shared file identities when reporting actual allocation.
The measurement uses Windows compressed storage sizes for compressed/sparse files
and file identities for hardlinks. Directory/MFT/alternate-stream and volume-wide
metadata overhead are excluded. Both inventory scans had zero access/allocation
errors and zero reparse points traversed. These are live samples; small subsequent
audit/report writes are not part of the sample.

Only the three explicitly protected full projects listed above remain. Current
`.runs` logical retention is below the aligned 8-GiB trigger. Retained history,
source snapshots, audio/captures and the active/exception builds account for its
remaining footprint; those are not silently discarded to meet a numerical cap.

Supporting local evidence lives under
`main_project/tests/.runs/storage-maintenance-2026-11-26/`.

Key receipts: `maintenance-612d3fcab3ce42eb8f23a02249273bfe.json` (13 reviews),
`maintenance-8fd731cff5634e0f8e86f571e0921af0.json` (JSON/ZIP batch),
`archive-link-*.json`, `before.json`, `after.json`, `before-compression.json`,
`launcher-smoke.json`, `integrity.json` and the delivered tool snapshot.

Final receipt SHA-256 values:

- Before inventory: `EAC8FA1630694F33AA6A7E407FCD876CFF8E3F53AE10D7AFF77EE5E72E3FF9DA`
- After inventory: `4D5CDEB82BFE917F8E95808678AAFB4E5B0C421BD65A59637FB5AAF07DB6E6B9`
- Integrity checks: `3460059FD8A783916DB422B017FE5B71A65DDC156DF89D27AB26B27009C93C25`

Completed **16:52 EST (UTC−05:00)**. `git diff --check` passes. No commit, push,
branch operation, game acceptance or milestone closure was performed.

**Later acceptance follow-up:** The user subsequently reports all nine human
creation checks PASS and accepts increment 3. That ends the temporary retention
of `verification-rendered-a586a98a015c4d43a45d5cababa9c13d`; the shared tool removed
another 216,440,687 copied/cache bytes before retained-archive overhead, with no
engine active. `acceptance-retirement.json` verifies its source and child evidence.
The before/after measurements and original integrity record above predate this
separate retirement. Only the failed ground and explicit view-review builds
remain protected from that original full-project inventory.
