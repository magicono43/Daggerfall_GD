# IMP-012 increment 2 — human review

**2026-11-24 human results: all eight checks PASS.** The user reported: “I pass all 8 entries”. This records the human checklist results; the special steep-ramp list remains unqualified.

The final actual-launch smoke passed fifteen assertions
over sixty live frames; no automated run records a human PASS. Increment-1 and
IMP-011/013/016 acceptances remain intact; parent IMP-012/M2 remain open.

From the repository root, using PowerShell 7:

```powershell
& "C:\Users\Kirk\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "C:\Godot\Projects\Daggerfall_GD\main_project\tools\review_ground.ps1" -ClassicSource "C:\Games\Daggerfall\arena2"
```

Execution-policy selection is process-scoped. The launcher builds/verifies a fresh
isolated project before opening the interactive course, waits for the actual
engine, and preserves stdout/stderr and exit failures. Its preparation delay is
development verification, not shipped game startup performance. Keep the course
focused for gameplay; actual focus loss correctly suspends it. Escape opens stock
Pause/Controls. Close the engine after review; the active build expires then.

The same command with `-SmokeTest` qualifies actual entry, live physics/input and a
rendered frame. It never implies a human play PASS. Storage is inside the copied
project's permitted `tests/.runs/` boundary. Compacted evidence roots are not
runnable builds; always rebuild with the launcher.

Record PASS/FAIL for these checks:

1. WASD/look, Shift Run, Alt Sneak and middle-mouse Autorun retain accepted
   behavior. Run wins simultaneous Sneak; diagonal input gains no speed. Run into
   the north wall, then move sideways against it: collision blocks penetration,
   allows wall sliding and does not award Running practice while stationary.
2. Left Ctrl toggles actual crouch once. Walk, Run and Sneak slow immediately on
   crouch commitment, while the camera follows smoothly. Sneak alone does not
   crouch. The readout distinguishes actual/desired posture and pending stand.
3. Enter the orange roof at x=-6, z=-6 while crouched (underside 1.20 m). Request
   standing: actual crouch remains. Leave the roof and verify automatic standing.
   Renewed crouch cancels the pending request. Repeat near the thin off-centre
   orange overhang at x=-12, z=-4; centre clearance alone cannot permit standing.
4. Pause → Settings → Controls: change Crouch independently to Hold and Apply.
   Holding crouches; release under the low roof requests standing without forcing
   it. Return to Toggle if preferred. Run/Sneak preferences stay independent.
5. Walk up and down the blue stairs at x=6 (0.17 m rises). Physical travel is
   immediate; camera response is gentle in both directions, with no extra bob or
   pause catch-up. The red 0.26 m obstacle at x=12 remains blocked under repeated
   forward/diagonal attempts (up bound 0.25 m, down bound 0.18 m).
6. The gold 30° ramp at x=-10, z=-11 is walkable; total surface speed stays at the
   selected gait. The 55° ramp at x=10 is blocked uphill, including diagonal
   attempts. No automatic downhill propulsion or slide mechanic is enabled.
   The machine fixture separately qualifies genuine stable steep support.
7. The green 0.64 m passage at x=0, z=-11 permits the 0.60 m diameter capsule;
   the 0.58 m passage at z=-16 blocks it. Crouching retains radius and cannot
   bypass a passage that is too narrow. Watch low roofs/walls during camera
   transitions: shortening/snapping may protect clearance, without turning aim.
8. Pause or change focus during a posture/stair transition, wait, then resume.
   Pose/camera freeze with no catch-up; Toggle selection survives. Autorun stays
   cancelled. Use Escape and close the engine when finished.

Known limitations: entry/LOC readiness/TIME/traits/restrictions are controlled;
input/view/body/collision/CHAR/DATA/RULE/Controls are real. Exhaustion reaches a
hold because real automatic recovery handoffs are missing from this course.
Accepted CHAR already implements collapse/safe-hour logic with controlled
suppliers; Escape is not a fatigue cure, and this review does not add rest or fill
fatigue. The finite 4096-receipt limit still stops safely; retirement is not solved
or assigned here. No jump, gravity, fall damage, moving support, collision damage,
AV bob, native SAVE or full story integration is delivered by this increment.

The user selected a reviewed list for special steep dungeon ramps. Candidate
geometry has been investigated, but the actual required-route list remains
unqualified; ordinary slope limits apply until reviewed entries pass real-corpus
qualification. Controller/changed-host IME human checks retain their accepted
deferral to later M2. Named real-provider, later-increment and SAVE gates remain.

## Recorded human results — 2026-11-24

1. PASS — user reported all eight entries passed.
2. PASS — user reported all eight entries passed.
3. PASS — user reported all eight entries passed.
4. PASS — user reported all eight entries passed.
5. PASS — user reported all eight entries passed.
6. PASS — user reported all eight entries passed.
7. PASS — user reported all eight entries passed.
8. PASS — user reported all eight entries passed.
