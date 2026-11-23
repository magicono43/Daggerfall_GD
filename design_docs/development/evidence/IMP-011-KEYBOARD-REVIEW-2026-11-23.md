# IMP-011 increment 1 — keyboard review follow-up — 2026-11-23

## Explicit user acceptance — 2026-11-23

The user stated: **"I accept what you have done in increment 1"**, then requested
a handoff prompt for another agent to start increment 2. Increment 1 is complete
and user-accepted for its delivered scope, including the clarified check-5 UI
cancellation behavior. Physical controller and changed-host IME qualifications
remain explicitly deferred and untested until later M2. Acceptance closes no
later real-provider gate, parent IMP-011/M2 or increment-3 scope.

The [increment-2 handoff](../handoffs/IMP-011-INCREMENT-2-PROMPT.txt) is prepared
for issuance in another chat. No increment-2 implementation begins in this chat.
The acceptance-pending statements below record the earlier state and are now
historical. Changes remain uncommitted at preparation; a commit is not a
prerequisite to preserving/reusing the accepted implementation.

## Human results and check-5 clarification

The user reports **PASS for checks 1, 2, 3, 4, 6 and 7** on
`imp011-keyboard-review-v1`. Check 5 was reported **partial PASS**: E was blocked
while loading, but Space selected the focused Cancel button and ended preflight
before the five-second timer. The original report is preserved verbatim in
substance; it is not relabeled as an unqualified user-reported PASS.

This is expected UI behavior under CORE-016, not a gameplay-input failure.
Suspension blocks gameplay intent while the focused UI remains usable. Stock
preflight exposes Cancel and native Button confirmation accepts Space. The
checklist incorrectly implied all Space input must be ignored for five seconds;
it is corrected to distinguish UI confirmation from gameplay delivery.

The actual human log contains **16 cancellable loading-preflight intervals**,
including five full waits of about five seconds and several early cancellations.
All 16 have **zero delivered gameplay edges while preflight was pending**.
E being blocked agrees with the user report. The event log alone does not identify
which physical key caused each cancellation; that attribution comes from the
user's observation and source/engine-path verification.

Two additional maintained rendered assertions exercise the observed path:
Space confirms focused Cancel without any gameplay fallthrough, then a fresh
Space tap delivers exactly one Jump start/release. They pass without changing
production behavior. Current action qualification becomes **119 headless / 124
rendered**. Keyboard/mouse/focus manual gates are satisfied with the clarified
check-5 expectation; no further human repetition is required. **Increment 1 is
ready for explicit user acceptance, which has not yet been declared.** Controller
and IME physical qualifications remain user-deferred to later M2 and untested.

Human launch identity: `review-a5e7fd3429a0459b9e0dac34e4f22a76`. Its complete
76-file launch directory is hash-verified under the package's `human-evidence/`,
alongside BUILD-used.json and instructions-used.md. `human-results.json` preserves
the reported outcomes, scope, preflight interval observations and recovery hashes.
No production code changed in response to this observation; only the checklist,
maintained regression/qualification and evidence/status records changed.

Independent final action reruns pass **119 headless / 124 rendered**:
`verification-headless-5bb6ed644f2c4c59811788674e45c770` and
`verification-rendered-944b260e2e5940fa836d50f81e992ae8`. Commands remain
`verify_headless.ps1` / `verify_rendered.ps1 -Suite action-input -Fixture action-input-v1`.
The additional rendered assertions verify the actual focused Cancel path and
fresh subsequent Jump, rather than bypassing UI. The earlier production-matching
session/UI regressions remain applicable; no unrelated suites were repeated.

The human engine exited before cleanup. All human launch files and the used
build/instructions were archived before removing the now-inactive review project.
The final automated launch copies were also compacted. See the cleanup guide and
package's human-build-cleanup.json, cancel-handoff-verification.json and
human-results.json. No full build is retained merely for awaiting acceptance.

## User scope and disposition at package preparation (historical)

The user is able to review keyboard/mouse and focus behavior and explicitly
directed that physical controller and IME checks remain manually untested until
later M2. This defers those physical qualifications; it does not count them as
passed. They do not block current increment-1 acceptance. Keyboard/mouse/focus
human results and explicit user acceptance remain pending. Increments 2/3 are
unstarted; parent IMP-011/M2 and later real-provider gates remain open.

The [original increment evidence](IMP-011-increment-1-2026-11-22.md) retains the
earlier implementation, verification and source scopes. This follow-up preserves
that work and records the review package and two corrections found while preparing
physical input review. Work remains uncommitted at base `f6319af`.

## Production corrections and maintained coverage

1. The rendered review fixture's blank-space right-mouse tap delivered no Attack
   edges. The hit-test chain was VBoxContainer PASS → ScrollContainer PASS →
   MarginContainer PASS → full-window Startup Control STOP. Headless delivery
   alone did not expose this GUI behavior. StartupShell now uses root PASS and
   decorative background IGNORE; real controls retain their click consumption.
   The maintained action suite now drives actual engine mouse events over blank
   stock space, clicks the real Pause button, checks no gameplay activation, and
   returns via reserved Escape. Before: blank RMB 0 starts/0 releases. After:
   one start/one release through production physics delivery.
2. A final independent input hold could expire without another UI state change,
   leaving a previously focused Pause button armed after gameplay became eligible.
   SessionShell now observes CORE gate changes through the existing coalesced
   render scheduler. The action fixture waits for blocked UI focus, releases the
   last independent hold, and asserts gameplay resumes with GUI focus unarmed.
   It does not release another requester's hold or use a test-only focus clear.

Changed production files are `main_project/scripts/startup/startup_shell.gd` and
`main_project/scripts/session/session_shell.gd`. Maintained coverage/qualification
updates are `tests/action_input_cases.gd`, `tests/action_input_inventory.json` and
`tools/verify.ps1` under `main_project/`. Counts increase to 119 headless / 122
rendered with frozen assertion names. No settings format, binding editor,
camera/cursor policy, native dependency or gameplay provider is added.

Gate updates reuse the existing deferred/coalesced renderer. Input stays with
MOVE, lifecycle/eligibility with CORE, and actual widget handling with UI. These
flags/subscriptions introduce no whole-catalog query or publication rebuild.
The prior complete-composition timings remain historical measurements; this
follow-up does not claim a new all-adapter performance benchmark or export run.

## Disposable review package

Location: `main_project/tests/.runs/imp011-keyboard-review-2026-11-23/`.
Double-click `Launch review.cmd`; instructions/checklist are in `README.md`.
This is an engine-launched Godot 4.7.2 review copy, not a Windows export or room.

The package snapshots the current game and uses actual production capture,
delivery, CORE gates, window stack and stock Pause/Resume. Its explicit
fixture-only controlled startup/session providers support loading preflight and
session retirement without implementing SAVE/CHAR/WORLD. It observes edges and
cancellation, displays counts, and writes per-launch `input-events.jsonl` plus
`review-summary.json`. No input implementation is replaced.

The only copy-specific changes are an explicit fixture entry, an observer script,
and **E → Attack** as a second contributor alongside stock right mouse. They are
recorded with canonical/review hashes in BUILD.json. This enables overlap review
without implementing staged bindings. Review controls have no keyboard focus;
the fixture does not clear stock GUI focus to make an input test pass.

Each launch gets its own checked fixture sandbox under the copied project's
`tests/.runs/review-*/` plus isolated engine APPDATA/LOCALAPPDATA. No classic data
or ordinary user storage is used. The launcher preserves security policy and
uses the installed official Godot 4.7.2 executable. Human launches are visible;
owned import/smoke children are bounded and checked.

The checklist covers brief/repeated taps, RMB/E overlap, pause handoff, physical
Alt-Tab and ups while unfocused, loading cancellation, independent-hold ownership
and optional session replacement. Human PASS/FAIL must be reported separately.
Physical controller and IME testing are deliberately excluded at the user's
request and remain explicit later-M2 qualifications.

## Verification and retention

Independent maintained action and session commands are rerun against these fixes.
The package also has separate headless/rendered 11-check smoke selections using
the actual engine event path and controlled CORE operations. Smoke is fixture
verification, not physical/human acceptance. Failed pre-fix rendered smoke logs
and hit-test diagnostics remain distinct from passing results. Exact final run
identities, results and retention are recorded below before handoff.

| Final selection | Result | Root under `main_project/tests/.runs/` |
| --- | --- | --- |
| Action input headless | **119/119 passed** | `verification-headless-eb84b3840dc14cea973ac6a0eece23b6` |
| Action input rendered | **122/122 passed** | `verification-rendered-5d7633744dbe4a398ff35ace0cf1e7cd` |
| Session/UI headless | **263/263 passed** | `verification-headless-fa9b16a1d0bb49979d35dd3009fa5f6d` |
| Session/UI rendered | **264/264 passed** | `verification-rendered-f8fa107a85234bd699dd68e36155ef53` |
| Package smoke headless | **11/11 passed** | Review package `project/tests/.runs/review-73c8e971549a4abe847cd29f60922c6e` |
| Package smoke rendered | **11/11 passed** | Review package `project/tests/.runs/review-cc9498b99cdc43e5af40a3a8ad2e4653` |

Commands: independent `verify_headless.ps1` / `verify_rendered.ps1` with
`-Suite action-input -Fixture action-input-v1`, then separately
`-Suite session -Fixture m1-v1`. Package checks use its `Launch.ps1 -Smoke
-Headless` and separate `Launch.ps1 -Smoke`. Official Godot is
`4.7.2.stable.official.ed1daf0bf`. Final package logs contain no script/resource
leak diagnostics; the existing certificate-store diagnostic retains its previous
classification. The rendered review frame was inspected for readable controls
and counts without clipping. No human result is inferred.

`BUILD.json` verifies identical production input/CORE/UI runtime files, the
explicit copied fixture-entry and E-binding exceptions, native hashes and the
observer hash. `automated-runs.json` retains all eight standalone run identities,
counts/statuses and report hashes, including intermediate passing selections.
All reference/classic data, installed tools and ordinary player storage remain
unchanged. `git diff --check` passed; no commit or branch change was made.

One full disposable review project/cache is retained for the concrete outstanding
human checks. Expiry: remove reproducible payload after results or review by
**2026-11-30**. Preserve every human launch's input log, summary and user-created
evidence before removing the project. Standalone automated verification copies
are compacted once their owned children exit. No reference/classic data,
installed tools or earlier unique human state is a deletion target.

Cleanup removed eight inactive standalone verification copies: **9,926 files /
1,663,806,210 logical bytes**, preserving **46** checked report/log/capture hashes.
Their evidence is in each root's `evidence/scenario-1`; root reports remain.
Exact cleanup is recorded at
`main_project/tests/.runs/imp011-increment1-2026-11-22/keyboard-review-cleanup.json`.

Final measured `.runs` retention is **2,067,115,127 bytes (about 1.93 GiB)**,
below the 2 GiB review trigger, without following reparse points. The active
review package is **214,625,857 bytes**, retained for the requested human checks.
Its `retention.json` records the exception/expiry and untested deferrals. Earlier
human state and failed package smoke diagnostics were preserved. Remove only
reproducible payload after results, keeping future human logs/summary as unique
evidence. This retention does not imply any current manual PASS.
