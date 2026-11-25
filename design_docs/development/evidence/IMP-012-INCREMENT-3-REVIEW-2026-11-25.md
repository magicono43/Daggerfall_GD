# IMP-012 increment 3 — playable air and landing review

**Accepted, 2026-11-25:** The user deemed increment 3 complete following all human checks passing; stair-jump feel tuning is deferred. See [acceptance](IMP-012-INCREMENT-3-ACCEPTANCE-2026-11-25.md). Earlier pending statements below describe historical checkpoints.


Human review is pending. Machine success does not accept this increment, parent
IMP-012 or M2. Increments 1–2 and IMP-011/013/016 retain their recorded acceptance.

Run this exact command from Windows PowerShell, including when script execution
is restricted. It invokes the installed PowerShell 7 with process-only bypass;
no administrator or permanent policy change is needed:

```powershell
& 'C:\Users\Kirk\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe' -NoProfile -ExecutionPolicy Bypass -File 'C:\Godot\Projects\Daggerfall_GD\main_project\tools\review_ground.ps1' -ClassicSource 'C:\Games\Daggerfall\arena2'
```

The launcher rebuilds and verifies a fresh rendered project, then opens the
interactive course. Preparation may take several minutes. Its isolated storage
does not change your real game/settings. Close the game to finish the review.
The launcher records engine errors and closes its active-build marker. Rebuild
through this command rather than trying to launch a compacted evidence archive.

This course uses real resolved input, SessionShell, view, swept capsule, DATA/RULE,
CHAR fatigue/practice/health and CORE. Entry, collision-course readiness, TIME,
traits/restrictions and the empty death-prevention directory are controlled
providers. No real MAGIC, swimming/climbing/levitation motor, moving platform,
story entry or native SAVE is certified by this review.

WASD moves, Space jumps, left Ctrl toggles crouch, left Shift holds Run, left Alt
holds Sneak, and Escape opens the normal menu. The readout reports actual mode,
vertical velocity, health, Jumping practice and the last committed landing's
distance, damage and independent hard-feedback eligibility. Broader AV landing
cues remain increment 4; the readout is review presentation, not damage authority.

1. **Fresh press and hold.** On the open starting floor, tap Space: one normal
   jump should rise about 0.56 m at this fixture's Jumping=10. Hold Space through
   landing and keep holding: no second jump. Release and press again to jump.
   Jumping practice should increase once for each actual jump.
2. **Rejected airborne press.** During a jump, release and tap Space again before
   touching down. It must not create a second impulse or a new jump on landing.
   Holding Shift while stationary must not become extra jump momentum/practice.
3. **Takeoff momentum and view.** Walk or run forward, jump, then release movement
   or request another direction/turn your view. Ordinary flight should retain its
   existing horizontal momentum until collision/landing. New ground gait requests
   apply when grounded. Vanilla adds no camera-forward boost or ordinary steering.
4. **Crouch and ceiling.** Compare standing and actually crouched takeoffs in open
   space; crouched impulse is 80%, so its apex is about 0.36 m. Toggle posture in
   flight: feet remain continuous, without a second boost. The orange jump roof
   near X=-18, Z=-5 has underside Y=2.10 m. Jump beneath it while standing: ascent
   should stop against the real ceiling and then descend, without a downward kick.
5. **Pause in flight.** Jump in open space and open Escape midair. Observe the
   frozen scene/readout; wait a few seconds, then resume. Motion should continue
   from the retained velocity, without menu-time catch-up or a fresh jump charge.
   Repeat during the measured drop in check 6 if useful.
6. **Measured landing.** Go to the labelled blue staircase at X=20, Z≈12. Walk
   north up twelve ordinary 0.50 m rises to the six-metre platform, then walk off
   its north edge. It must enter flight and land on the main floor. Expect about
   six reference metres and **5 HP** of damage once; small collision-gap differences
   are displayed in the measured distance. Repeated standing contacts must not
   repeat damage. A jump from the top includes its additional actual apex.
7. **Accepted surfaces and recovery boundary.** Revisit the blue 0.17 m stairs,
   low orange crouch roof and ordinary wall contacts. They should retain accepted
   behavior, with genuine drops now falling normally. The red 0.80 m obstacle
   remains above the ordinary automatic-step limit. Exhaustion still requires the
   separately documented real recovery integration; its hold is not a normal pause.

Health is real in the disposable course. Repeated six-metre drops can eventually
be lethal; CHAR's death handoff uses the explicitly controlled empty prevention
directory. Restart the course for fresh health when repeating review checks.

Report check numbers and observations. Native SAVE, real Slow Fall/protection
providers, actual platform carriage/point-motion composition, full assembled
locations and increment-4 feedback/crushing remain separate named integrations.

## Human results, 2026-11-25

The user reports checks **1–3 PASS**. Checks 4–7 remain pending. During an
additional jump into the narrower green parallel-wall passage, the game entered
an unrecoverable menu state; Quit did not complete and Task Manager was needed.
The human run's Player.log records `Air collision contact requires owner recovery;
motion history retained.` at 19:32:22 UTC. The launcher exit-1 exception followed
the forced close. Run identity: `verification-rendered-00e9af5caf3349acb8366778c82f1cc7`.
This report is a defect, not increment acceptance. The human run is protected
while investigation and evidence preservation are active.

The user clarified that Quit's confirmation did appear, but **Discard and Quit**
did not close the application. Final shutdown (including media release and actual
process exit) requires separate investigation beyond the consent/teardown check.

## Retest after the narrow-passage correction

Use the same launch command above to rebuild the corrected course. First retry
jumping against the narrower green passage near X=0, Z=-16. It should block entry
at this baseline jump height while allowing you to land and walk away. Repeat a
few times, then verify Escape → Resume and **Quit → Discard and Quit**. The review
readout now hides during menus so it cannot cover the confirmation controls.

Checks 1–3 remain reported PASS. Complete checks 4–7 after this defect retest.
Report passage, Resume and Quit results separately. If Discard still fails to
close, report the menu text/phase shown after clicking it; the final exit symptom
was not reproduced in the rendered actual-click probe. The original human build
is retained for comparison until the corrected passage/Quit retest or a retention
review on 2026-11-26; its unique evidence is protected.

## Human retest results, 2026-11-25

The user reports **all requested steps PASS**, including the corrected passage,
Resume/Quit retest and checks 4–7. All seven review checks are now human-reported
PASS. This records check results, not separate formal increment acceptance.
Earlier pending/failure text is historical; the earlier defect remains documented.

The user additionally reports intermittent brief sticking when jumping forward up
the tall fall-test staircase. A focused physics observation reproduces takeoff-
position dependence: at 0.35 m from the first riser, forward motion stops after
0.0125 s and landing occurs after about 0.477 s; at 0.55–1.50 m, the probe reaches
the first tread after about 0.32 s. All six samples land without contact recovery.
This probe uses the actual course and current MOVE sweep/slide helpers, not a
full input/CHAR integration qualification; its exact script/log are retained at
`main_project/tests/.runs/imp012-stair-jump-observation/`.

The course has 0.50 m risers and 1 m treads, near the baseline jump's roughly
0.56 m apex. Riser contact constrains ordinary retained air momentum; holding
forward cannot add ordinary air steering. Ground movement resumes after landing.
This is a recorded feel observation, not another reproduced pause/recovery lock.
No movement policy, collision margin or jump/stair assistance was changed.
Record time: 2026-11-25 15:51:47 EST.

Closed human-review builds were compacted after this PASS report and ordinary
engine inactivity. Their executed source and **all recorded human storage files**
are retained in per-root source/storage ZIPs; each storage entry was hash-verified.
Cleanup journal `main_project/tests/.runs/dungeon-cleanup-3e771c790ced4c3585c1606e3cd04f16.json`
records 4,889 reproducible files / 650,341,597 bytes removed and 81 retained child
reports/logs/captures. The original failed-build retention condition has now ended;
its earlier full-build retention statements are historical. No game code changed.
