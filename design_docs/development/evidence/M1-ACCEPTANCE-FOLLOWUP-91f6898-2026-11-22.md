# M1 acceptance follow-up — 2026-11-22

## Decision

**M1 is user-accepted, 2026-11-22.** The user explicitly stated: “In that case, I
accept M1”. Acceptance covers the audited M1 deliverables at remediation commit
`91f68988926ab7a3380a3f251e72ccf81c48f567`, the completed manual acceptance checks
and the tested Microsoft Japanese IME configuration. Later real-provider gates
and untested IME/platform configurations remain at their documented scope.
This acceptance starts no new implementation task.

Independent review of
`91f68988926ab7a3380a3f251e72ccf81c48f567` supports closing the three original
engineering findings. No new verified implementation defect was found in the
reviewed scope. This audit implements no production fixes and authorizes no next
task. The user subsequently reported PASS for all requested manual checks on
`91f6898 / m1-human-review-v1`, with everything behaving as expected. This closes
the outstanding human gates; the subsequent explicit declaration above records
formal milestone acceptance.

Baseline: [original audit](M1-INTEGRATION-AUDIT-2026-11-22.md) and
[remediation evidence](M1-AUDIT-REMEDIATION-2026-11-22.md). Historical failures and
acceptance records remain intact. HEAD was the requested commit and the worktree
was clean before this audit. Only audit documentation and ignored review outputs
are added by the follow-up.

## Findings disposition

| Original finding | Independent verification | Disposition |
| --- | --- | --- |
| A01 — stock cinematic setting falsely reports success | Traced the actual stock button through `select_skip`, live settings acceptance and truthful message selection. Session tests cover effective/accepted/disk values, reopening, rejection, unsaved acceptance and reversal; fresh-process composition reload checks persisted policy. | Closed: engineering verification and user-reported packaged UI/relaunch PASS. |
| A02 — repeated full publication copies and expensive faction child query | Scoped adapter reference declarations, detached public projections, candidate ownership transfer, same-stack automatic commitment and ticket-specific faction indexes reviewed with callers. Regressions exercise invalid declarations, mutation isolation, rejected publication and index freshness. Full composition and startup recovery pass. | Targeted changes verified. Residual synchronous startup/memory cost remains measured, without an approved numerical budget or evidence of a leak. |
| A03 — no maintained complete M1 adapter gate | `m1` selects the real ten-adapter composition in both modes; inventory qualification and unavailable-input selections independently checked. Windows PCK checks exercise this composition and fresh-process reloads. | Maintained engineering gate verified. Controlled later-owner providers do not close deferred real-provider obligations. |

The DATA registry retains authority over definitions and derived indexes; CORE
still owns startup/session lifetime. Public values remain detached. The direct
candidate transfer is internal, clears the candidate after commitment and does
not expose mutable owner state. Automatic reuse stays within the immediate
synchronous preparation/commit path; interactive Continue retains revalidation.
No gameplay decision, platform boundary, baseline data, library or approved mod
language changes were introduced by the remediation or this audit. No supported
new duplication/coupling defect was found.

## Independent validation

Fresh selections ran sequentially in disposable copies using official Godot
4.7.2 (`ed1daf0bf`) and classic input `C:/Games/Daggerfall/arena2`.
Commands and identities are retained in the machine-readable follow-up evidence.
Headless and rendered commands were independent; native timing runs were not run
concurrently with diagnostic engine loads.

| Suite | Headless checks | Rendered checks |
| --- | ---: | ---: |
| m1: qualification / startup / session / full composition | 2 / 84 / 263 / 33 | 3 / 92 / 264 / 34 |
| publication | 111 | 117 |
| faction-quest-inputs | 132 | 134 |
| variant-inputs | 497 | 503 |
| actor-inputs | 236 | 238 |
| item-spell-inputs | 160 | 162 |
| locale-fonts | 419 | 441 |
| translation-preferences | 149 | 164 |
| replacements | 168 | 173 |
| native | 344 | 374 |
| formula | 82 | 84 |

All 22 selections passed. Counts describe fixture assertions, not code coverage
percentages. Fresh-process reload assertions passed: full composition 12/13,
publication 8/8, variants 21/21, locale/fonts 10/10, translation/preferences 10/10,
replacements 10/10 and native 11/11 (headless/rendered respectively). Recorded
before/after classic-source samples were unchanged. The original VP9 timing failure remains a failed historical attempt;
these green native reruns establish no decoder root cause or decoder fix.

Complete-composition inventory qualification passed 40 checks. Debug and release
Windows exports each passed headless and rendered startup/composition/reload
checks. Additional harness qualification results are in the accompanying JSON.
No unavailable required check is counted as passing.

Harness qualification matched all six expected exit/status classifications
(pass `0/passed`, deliberate assertion `1/failed`, unavailable `2/incomplete`,
in each mode). Missing ClassicSource in `m1` and a wrong composition fixture each
returned `2/incomplete` in both modes with no failed leaf assertions; these four
negative selections are qualification evidence, not passing gameplay checks.

Observed full-composition headless automatic startup was 17.10 seconds with one
preparation, about 1.78 GB static and 1.79 GB peak tracked memory in its fresh
reload process. Rendered interactive valid-source selection was 17.04 seconds;
that process observed 1.81 GB static and 2.36 GB peak after multiple rejected and
successful selections. These are different lifecycle observations, not a matched
memory benchmark. The original approximately 48-second publication and 0.95-second
child-query measurements motivated specific fixes; startup remains synchronous.
The remaining cost warrants observation on target hardware, not a speculative
new acceptance defect or an invented performance threshold.

## Manual acceptance results — user report, 2026-11-22

Build: `91f6898 / m1-human-review-v1`. The user reports:

- Ordinary cold startup, picker cancellation, invalid-source/retry, keyboard
  navigation and remembered source: **PASS**.
- Cinematic Apply, reopen and full relaunch persistence: **PASS**.
- Blocked portable root, explicit fallback and marker retained on relaunch:
  **PASS**.
- No unexpected behavior reported: “everything seem to work as expected by those
  parameters.” The error/unexpected-behavior template entry was also marked Pass.

These are human-reported observations, separate from automated fixture evidence.
No new executable checks or production changes were needed to record them.
There are **no remaining verified defects or mandatory human gates preventing
M1 acceptance** within the audited scope. The original checklist follows for
traceability; items 1 and 2 are now satisfied by the above report.

1. **Acceptance gate: human packaged startup/recovery.** Cold start with disposable
   storage, exercise the actual folder picker, cancel, invalid source and retry,
   valid-source menu entry, keyboard navigation and remembered source. Exercise
   blocked portable-root recovery and explicit fallback without silently changing
   the portable marker. This includes IMP-001's disposable unwritable-root recovery
   requirement using a real blocked-directory I/O fixture; it does not claim an
   NTFS ACL test.
2. **Acceptance gate: human stock cinematic preference.** Apply a different skip
   policy, confirm truthful accepted/effective state, reopen and quit/relaunch to
   confirm persistence. Automated state assertions do not replace human operation.
3. **Conditional support limitation: other IMEs/Windows configurations.** The
   Microsoft Japanese IME check below has now passed for the tested local
   configuration. Other configurations remain unqualified; English is still
   the only offered game locale.

Ready-to-run instructions and disposable launchers are in
`main_project/tests/.runs/m1-followup-91f6898-2026-11-22/manual-review/README.md`.
The review package is derived from the verified commit with an explicitly marked
temporary fixture exposing the actual stock control without character creation.
Its storage failure inputs keep fallback inside disposable review storage.
Review-fixture selftests establish the fixture works, not human acceptance.

Previous user audio listening acceptance remains valid. Real window/input owner
replacement, room/collision/spatial audio, gameplay SAVE/thumbnail/failed restore,
character/opening and quest fault/retry checks remain at their named M2–M5
provider gates. They are not new M1 implementation defects. Settings disk/relaunch
behavior applicable to M1 is covered; a gameplay save system is not claimed.

## Evidence and retention

Raw commands, summaries, logs, source/build identities and cleanup manifests are
under `main_project/tests/.runs/m1-followup-91f6898-2026-11-22/`. Per-wrapper reports
retain their original paths or explicit archive pointers. Completed disposable
runtime copies are compacted after their owned children exit, preserving hashed
reports/captures and unlinking template junctions without following them.
One review build was retained for the concrete outstanding human checks. Those
results are now reported; the build is eligible for routine cleanup after checking
activity and protecting unique user evidence. It has not been deleted in this
documentation update. Retention review remains due on 2026-11-29.
Unique user-created review state/evidence must be protected during later cleanup.

Final cleanup compacted 34 completed runtime roots and removed 7,815,611,468
logical bytes while preserving hash-verified evidence. Twelve large JSON reports
have lossless gzip archives and explicit SHA-256 recovery pointers. Final total
`.runs` retention was 2,150,124,285 logical bytes without following reparse points,
slightly above 2 GiB. This was reviewed: one concrete human-review build is the
intentional active exception; no other completed full build from this audit is
retained. Private import/export engine caches were removed after fixture children
exited. See `retention-final.json` and per-root `followup-cleanup.json` manifests.

The reported results satisfy the named gates. M1 is ready for acceptance with
the tested Microsoft Japanese IME configuration qualified and later real-provider
gates retained. Other IMEs/Windows configurations remain unqualified.
No further implementation fix is justified by a verified defect from this
follow-up. Formal user acceptance is now recorded above; authorization of any next
implementation task remains separate.

## Optional physical IME qualification preparation

At the user's request, a separate `m1-ime-review-v1` package now exposes the
unchanged stock text prompt, owner/window stack and stock Escape dispatch through
an application-scoped audit fixture. Instructions and launcher are under
`main_project/tests/.runs/m1-ime-review-2026-11-22/README.md`. A rendered fixture
smoke check passed (one explicit ASCII submit, one owner response and prompt
closure); its capture was inspected. Physical Windows/Japanese IME results were
pending at preparation time and are now recorded below. The fixture smoke alone
does not qualify an IME or add a Japanese game locale. No production code fixes
were made.

The first fixture import caught a type-inference error in the audit subclass;
the fixture was corrected and rerun. Initial failed logs remain separate from
the successful smoke evidence. Completed copied project/import caches were
removed after owned children exited. The review build is retained until human
results, with retention review on 2026-11-29. Existing human-review state was
preserved. See the new package's `BUILD.json` and `cleanup.json` for hashes,
scope, retained outputs and the above-2-GiB retention review.

## Physical IME human results — 2026-11-22

The user reports **PASS** on `91f6898 / m1-ime-review-v1` with Microsoft Japanese
IME for Notepad composition, candidate/hiragana acceptance without prompt submit,
separate Enter submitting once, Escape canceling composition before the prompt,
Backspace and focus switching without unintended responses, and English text
plus glyph/candidate display. The unexpected-behavior entry was `0`, interpreted
as no unexpected behavior/responses, not zero intentional submissions. Windows
version and compatibility mode were not supplied; no value is inferred.

The available owner-response log was preserved separately as
`main_project/tests/.runs/m1-ime-review-2026-11-22/human-ime-responses.json` with a
verified SHA-256 recorded in `human-results.json` and the accompanying audit JSON.
It contains four intentional response entries (two submit, two cancel), each
recording no active IME composition at callback time. This supplements the human
report; it does not independently prove every physical key sequence or the English
trial. No unexpected response is reported and no verified defect was identified.

**The tested local Microsoft Japanese IME configuration and stock prompt are now
qualified. M1 remains ready for acceptance.** This does not certify other IMEs,
add a Japanese game locale or close later gameplay input-provider gates. The
review build is now eligible for activity-checked routine cleanup; unique human
logs/state are protected. No build deletion or production fix was performed in
this result-recording update.
