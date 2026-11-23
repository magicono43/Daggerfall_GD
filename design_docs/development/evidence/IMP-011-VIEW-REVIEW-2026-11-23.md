# IMP-011 increment-3 keyboard/mouse review

Status: **Checks 1–6 PASS; increment 3 and IMP-011 explicitly user-accepted and complete on 2026-11-23.**
Increments 1 and 2 remain explicitly user-accepted on 2026-11-23. Physical
controller and changed-host IME qualification remain user-deferred to later M2.

The disposable package is `main_project/tests/.runs/imp011-view-review-2026-11-23-final/`.
Its `BUILD.json` identifies verified source/build scope. `Launch.ps1` starts a new
isolated review storage root; `Launch.ps1 -ResumeLast` reopens the most recent root
to check persisted preferences. Run in PowerShell from the repository root:

```powershell
& ./main_project/tests/.runs/imp011-view-review-2026-11-23-final/Launch.ps1
```

This is the stock application/session/input/settings/view path with a controlled
CORE provider and four colored direction markers. It supplies no locomotion,
interaction, combat or SAVE effects. W/A/S/D do not move the camera in this fixture.
Use Quit or the normal window close path to exit. Escape opens Pause; choose
Settings, then Controls. Preferences are near the bottom of the scrolling editor.

1. **Direct view and Center.** Move the mouse and turn repeatedly through all four
   colored walls. Look fully up/down, then move back slightly: response should
   reverse immediately, without an overshoot delay. Home immediately levels pitch
   and preserves yaw. No roll or automatic leveling should occur. Right-mouse
   attack intent must still allow looking; it has no attack effect in this fixture.
2. **Keyboard and priority.** Right/Left arrows turn; Insert/Delete look up/down.
   Opposing directions cancel. Mouse motion wins over held keyboard look; releasing
   the look keys stops their input. Verify brief mouse movements do not repeat.
3. **Staged response preferences.** Pause → Settings → Controls. Change Mouse X/Y
   independently and inversion, then Cancel: effective response stays unchanged.
   Reopen, change and Apply: response changes. Enable Mouse Smoothing and adjust
   its time in seconds; larger time responds more slowly. Home must stop its tail.
   Turn smoothing off: direct response returns. Keyboard look rate and its separate
   smoothing controls should likewise apply. Controller fields can be inspected,
   but do not count them as physical controller qualification.
4. **Gameplay cursor and HUD.** Enter toggles to a visible centered cursor. Moving
   it must preserve facing. Click the actual Pause button: Pause opens. Automated
   coverage checks that this click delivers no world intent; this fixture has no
   world activation effect to inspect visually. Escape returns to cursor gameplay with
   the cursor centered again. Enter returns to captured look without turning
   toward the pointer or producing a recapture jump.
5. **Handoffs and focus.** With smoothing enabled, move briefly and immediately
   open Pause: no delayed turning. Return and check that no tail resumes. Repeat
   while holding a mouse button and while holding keyboard look. Alt-Tab away and
   back, both with Pause open and in gameplay cursor mode. An open menu must keep
   the cursor, and return must not turn. Automated edge checks cover unintended
   click/attack delivery, which has no gameplay effect to inspect in this fixture.
   Release and press held inputs freshly when testing a new discrete action.
6. **Persistence.** Apply a distinctive sensitivity and quit. Relaunch using
   `-ResumeLast`: the editor and actual response should retain that preference.
   Cancel a different draft, quit and reopen again: only the applied preference
   should remain. Injected disk-failure/UNSAVED/retry checks are automated; no
   filesystem manipulation is needed for this human review.

Report each check PASS/FAIL with any observed behavior. Formal increment
acceptance is separate from these results. No accepted increment-1/2 checklist
needs repetition absent a concrete regression.

Retention: keep the review build for these outstanding checks until results or
**2026-11-30**, then reassess. Before compacting, preserve and hash-check all
`project/tests/.runs/review-*` user state, settings, logs and results plus the
reviewed BUILD/launcher identity. No ordinary user storage or installed tool is
part of cleanup. The package is reproducible from maintained source using
`prepare_view_review.ps1 -VerifiedRun <passing view-cursor run>`.

## Human results — 2026-11-23

The user explicitly reports **1 PASS, 2 PASS, 3 PASS, 4 PASS, 5 PASS, 6 PASS**.
This satisfies the agreed new keyboard/mouse view/cursor review. Together with
automated evidence, increment 3 is ready for explicit acceptance; reporting these
results does not itself supply that acceptance or close IMP-011/M2/provider gates.

The user also notes that the bottom-left diagnostic text remains visible while
paused and in Controls. Source inspection confirms that `tests/view_review.gd`
adds this mouse-ignoring Label directly to the shell, outside the stock panel/HUD,
and updates it throughout the review loop without a menu visibility condition.
It is a review-only orientation/cursor readout, not the production gameplay HUD.
Its continued visibility is expected from this fixture and does not indicate that
gameplay remains eligible while a menu owns input. No production behavior change
is requested or made for this observation. Preserve it as a review note.

Physical controller/changed-host IME qualification remains deferred to later M2.
The build/state is retained pending safe evidence preservation and compaction;
no running review session or human input is removed by recording these results.

## Explicit acceptance and next handoff — 2026-11-23

The user explicitly stated: "I accept what you have done in increment 3 and deem
IMP-011 completed". **Increment 3 and IMP-011 are complete and user-accepted.**
All six new keyboard/mouse view/cursor checks are user-reported PASS. This
supersedes earlier acceptance-pending and parent-IMP-011-open statements.
Physical controller/changed-host IME qualification remains explicitly deferred to
later M2. Named real locomotion/activation/COMBAT/AV/SAVE joint checks and M2 remain
open; task acceptance does not claim those providers delivered.

At the user's request, the IMP-061 increment-1 assembly prompt is prepared at
`design_docs/development/handoffs/IMP-061-INCREMENT-1-PROMPT.txt`. Issuing it in the
destination chat authorizes that increment only; no IMP-061 implementation starts
here. Accepted implementation remains uncommitted at preparation (HEAD cff2df7).
Preserve the latest tree. The reviewed diagnostic overlay remains fixture-only.
