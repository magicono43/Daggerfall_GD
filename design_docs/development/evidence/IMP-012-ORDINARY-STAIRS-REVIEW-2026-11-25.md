**Acceptance update, 2026-11-25:** The user approved the improved angled/wall-adjacent stair behavior and explicitly accepted increment 2. See [acceptance](IMP-012-INCREMENT-2-ACCEPTANCE-2026-11-25.md). Earlier pending wording below records the preceding checkpoint; later integrations remain open.

# IMP-012 ordinary stairs — human follow-up

The ordinary automatic step allowance is now 0.50 m upward and downward. The
original three ramp review results remain recorded; this follow-up checks the
grey staircase and its return transition after the new tuning/contact fixes.
The user reports that the ramp and straight stair travel work. They also report
sticking when ascending at an angle and rapid ground/air-handoff indication while
hugging the stair walls in either direction. This review is **not passed**;
diagonal/wall contact follow-up is in progress. Overall increment acceptance is
not inferred.

**Contact-fix follow-up:** See [contact execution evidence](IMP-012-stair-contacts-2026-11-25.md).
The corrected build requires a new check of diagonal and wall-adjacent travel;
the report above remains the result for the previous build.

Paste this command into the existing PowerShell window. It uses the installed
PowerShell 7 runtime with process-only policy bypass; no administrator access or
saved execution-policy change is needed.

```powershell
& 'C:\Users\Kirk\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe' -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\Godot\Projects\Daggerfall_GD\main_project\tools\review_ground.ps1' -ConnectorPlacements 'block-0917/record-00028'"
```

Preparation runs the maintained rendered checks, then opens only the original
source-block window. WASD moves; mouse looks; left Ctrl toggles Crouch; left Shift
holds Run; left Alt holds Sneak; Escape opens Pause/Controls.

| Check | Expected | Result |
| --- | --- | --- |
| 1. Standing Walk | Ascend the orange ramp and the grey staircase through its upper treads; turn or move backward and return to the lower ramp landing. No jumping, sticking, unexpected support-loss hold or capsule penetration. | Partial: straight travel works; angled ascent sticks and wall-adjacent travel flashes the handoff indication. |
| 2. Other gaits/posture | Repeat with Run and Sneak, then crouched Walk/Run/Sneak. Ordinary stairs work at the respective gait speeds; standing/crouching remains deliberate. | Pending |
| 3. Clearance and camera | Side walls/roof remain solid; the camera stays inside clear geometry while stepping up/down and changing posture. | Pending |

For the contact-fix recheck, include both sides of the staircase:

1. Walk up at an angle using W+A / W+D, or look diagonally and hold W. Continue
   forward when reaching the wall; the wall should block sideways motion while
   allowing travel along the stairs. Repeat downhill with pressure into the wall.
2. Hug each wall going up and down. There should be no false falling/handoff
   indication or rapid switching to the held/menu presentation on these treads.
3. Repeat with Run and Crouch, and optionally Sneak. Solid walls and camera
   clearance remain required. Straight travel must continue to work.

The upper adjoining passage can contain static original geometry; mechanisms
remain inactive in this review. Larger obstacles/drops outside the 0.50 m ground
allowance still retain their jump/climb/air owners. This change does not implement
the later air/fall increment or make its support-loss hold resumable.

For optional generic-course inspection, replace the final placement argument with
`-ConnectorModels 0`. Its blue stairs are ordinary steps; the red 0.80 m obstacle
must remain blocked to normal walking. Full boundary rejection is also automated.

See [implementation and verification](IMP-012-ordinary-stairs-2026-11-25.md).
