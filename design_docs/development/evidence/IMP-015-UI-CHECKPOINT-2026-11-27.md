# IMP-015 — Combined creator UI regression checkpoint

Started **November 27, 2026, 10:35:23 AM EST**. The user authorized the proposed
combined character-creator regression pass, concrete fixes, and cleanup of its
temporary builds while away. Initial working tree was clean at revision
`a2334e0629420ca3c40700aee22450eed9049b1e`. Godot 4.7.2 stable, Windows first.
This is the broader fast-ui-polish checkpoint after the approved small iterations;
it does not establish human acceptance, playable entry, live grants or milestones.

## Corrections

- The maintained career UI test still referenced the retired single `_audio`
  player. It now asserts the requested independent narration continues after
  cancelling a race confirmation. Runtime playback is unchanged.
- Its picker helper could press Enter (already confirming a row), then send a
  second confirmation to the retired control. It now performs one activation.
- After checking name commitment on rejected completion, the test now dismisses
  the newly added modal warning before attempting the trait-menu controls.
- The exact assertion inventory is synchronized with the reviewed current tests:
  moddable conflict checks, direct Custom entry, nested trait-picker behavior and
  the reputation balance warning. Exact inventory/uniqueness checks remain active.
- Broad creation/export source guards now include the recently used original
  FONT0002, method/picker/spinner and trait/reputation window assets when present.
- Closed-verification compaction now accepts an explicit UI-checkpoint receipt
  bound to authorization, source revision, exact root and report hash. Its old
  increment-4-only dirty-file requirement could not represent a clean committed
  checkpoint. Existing inactivity, containment, reparse, archive and retained-file
  checks remain required. Cleanup is limited to the explicit task-owned ledger.

## Verification

| Check | Assertions | Result/root |
| --- | ---: | --- |
| Full creator headless + fresh process | 3,982 + 8 | Passed: `verification-headless-721f9a35b7bf4a36930e8587d6bcf0f2` |
| Full creator rendered + fresh process | 4,020 + 8 | Passed: `verification-rendered-2cf5d3b2cfdd4246aa00d74f85bebfb3` |
| Class-method focused | 35 | Passed: `verification-rendered-9b56bf2296f54db58088a1a3503ad988` |
| Class-picker focused | 72 | Passed: `verification-rendered-de68547f33bb417e977fd1c3f5525bbb` |
| Custom-sheet focused | 65 | Passed: `verification-rendered-541dbec496e7406191e6d95a2ea3f2a3` |
| Reputation focused | 75 | Passed: `verification-rendered-c8a0588c27574c05a0135f79087de401` |
| Custom Exit warnings focused | 65 | Passed: `verification-rendered-0646ea66e5ac4c45b7b906c6595eac7f` |
| Help focused | 87 | Passed: `verification-rendered-58797f93a94b4161b8dbee6cddcb9174` |
| Traits focused | 59 | Passed: `verification-rendered-ae90720e7d5d4fd08453f6d99a5feafb` |
| Independent trait-policy rules | 264 | Passed: checkpoint `trait-rules.json` |
| Artifact-maintenance tooling | 56 | Passed: `artifact-maintenance-tests-ad300067bf914754beaca2129231e7ac/result.json` |
| Windows debug export: headless/rendered + fresh processes | 3,982 + 4,020 + 8 + 8 | Passed: `export-2524218370ba4b6ab5ac1d45169b04a2` |
| Windows release export: headless/rendered + fresh processes | 3,982 + 4,020 + 8 + 8 | Passed: `export-339b2cb253414271b0be1df144d85812` |
| Shutdown: live reputation warning | 38 | Passed: `verification-rendered-e917416a8b374435bca250c4af3f7a33` |
| Shutdown: live Help message | 34 | Passed: `verification-rendered-0568ecd7626a49829ac1fe67c88869b9` |
| Shutdown: live trait variant picker | 34 | Passed: `verification-rendered-77d861f5878a4d818b65b0eb52d16071` |

All roots are beneath `main_project/tests/.runs/`. The first two development
headless roots (`a001de716e1d46469f99141e79c59d5e`,
`e0aeae9335d34a4096fb9ab6e91680e6`) stopped after the stale helper errors above.
Their actual incomplete reports and diagnostics are retained, excluded from
passing totals. No failure is relabeled as passing.

The full suite exercises real production providers/normal controls and independent
owner fixtures, including retained choices, preset/questionnaire/custom routes,
biography, starting allocations, identity/presentation, stale callbacks, CORE
handoff rejection and fresh-process preferences. Synthetic input is not physical
controller/IME testing or human sound/visual approval. The known Windows
certificate-store diagnostic remains allowed by the existing diagnostics policy.

Rendered checkpoint measurements: complete current composition preparation
37,501,931 microseconds; career preparation 34,307 microseconds; identity preparation
95,400 microseconds. One thousand portrait queries: 5,991 microseconds. Revisit
checks created no additional decodes/textures. These are observations, not new
performance budgets or claims about completed gameplay.

Exact owned-root ledger and machine audit live at
`main_project/tests/.runs/imp015-ui-checkpoint-2026-11-27/`.

The seven focused menu runs total **458 selected assertions**, including stock
startup checks repeated in each isolated process. They are not 458 unique tests.
All seven automatically compacted their copied builds. The first batch compaction
also removed **854,380,838 bytes** across the four full/development verification
roots, with zero deferred targets. Original child paths, source archives and
actual development statuses survive. A local wrapper initially checked
`LASTEXITCODE` for a PowerShell helper that reports via invocation status; the
wrapper was corrected, and the completed cleanup journal verified independently.

Changed-file map: `tests/creation_career_cases.gd`,
`tests/creation_inventory.json`, `tests/tools/run_artifacts_cases.ps1`,
`tools/creation_fixture.ps1`, `tools/run_artifacts.ps1`, the task's evidence link
and this report, plus `RUN_ARTIFACT_CLEANUP.md`. No game runtime/owner implementation or source balance data has
changed in this checkpoint.

## Final audit and cleanup

**24,938 selected assertions across 24 results passed.** Counts include repeated
checks in independent editor/export/fresh processes, not unique assertions.
The two stopped development runs remain incomplete and excluded from this total.
No game-code changes were needed. Current trait and General Help captures were
inspected, alongside the full-flow trait capture.

The independent audit checked **4,378 source-hash comparisons**, explicitly
recording the later cleanup-tool/test revisions separately qualified by the
56-check maintenance suite. No runtime/creator-fixture source drift remains.
It reverified every entry in **16 executed-source archives** and the hashes of
**2,529 retained evidence files**. Classic before/after samples match. No
unexpected errors or leaked ObjectDB/resources were found. Verbose shutdown
logging emitted three RGB8-to-RGBA8 hardware conversion warnings per run for
the three five-pixel scrollbar slices. Godot performs this supported-format
conversion automatically; these nine reviewed warnings are recorded separately
in the audit and do not indicate lost resources.

Compaction removed **27,362 files / 4,069,466,558 logical bytes** of understood
reproducible copied projects, exports, native copies and caches. All sixteen
task-owned full builds are gone. Verified source ZIPs, typed inputs, reports,
logs and reviewed captures remain at their original child evidence paths.
Export-template junctions were unlinked without following/changing installed
targets. Earlier unknown/human-review roots and all external originals remain
protected. Exact receipts, source versions and hashes are in the linked task
ledger, `audit.json`, each root's compaction receipt and the storage journal.

Final read-only retention sample: **8,912,565,756 logical bytes / 117,289 files**
(8.30 GiB), excluding reparse targets, with zero inaccessible/deferred directories.
The 8-GiB threshold was reviewed. The largest remaining roots are older scopes
outside this task's explicit ledger, including prior rendered review roots and
`imp011-view-review-2026-11-23-final`; they remain protected. This is logical
length accounting, not deduplicated/allocated-storage accounting. Exact largest
roots and skipped reparse paths are recorded in checkpoint `retention.json`.
No current-task full project or export is retained for hypothetical future review;
the maintained focused launchers rebuild from current source.

All requested checkpoint checks are complete; no broad creator/export check is
deferred from this pass. Human visual/audio/controller/IME observations and the
already-open live-entry/milestone obligations remain separate. Changes are left
uncommitted for the user.

Completed **November 27, 2026 at 11:17:16 AM EST** — elapsed **41 minutes,
53 seconds**. `git diff --check` passed; no Godot/Startup/FFmpeg process remains.
