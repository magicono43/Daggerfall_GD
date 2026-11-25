# IMP-012 steep corridor review — 2026-11-25

**Later stair-tuning follow-up:** The user authorized DFU-style ordinary stair
allowances after the results below. The earlier 0.25/0.18 m limits and check 7
describe the prior build. See the [new stair/return review](IMP-012-ORDINARY-STAIRS-REVIEW-2026-11-25.md)
for the 0.50 m up/down build; its human results remain pending.

Human review, 2026-11-25: **checks 1–5 PASS on all three design windows;
check 6 reports the orange source-block ramp works.** Check 7 records ordinary
stairs blocking ascent and a support-loss hold when returning from the first
stair toward the ramp. The earlier eight posture/surface checks remain PASS.
No overall increment, parent IMP-012, M2 or native SAVE acceptance is inferred.

The user confirmed the three corridor ramp designs should be traversable and
authorized implementation and placement verification. The 25 source records are
copies of those designs. This review offers both isolated original meshes and
their original surrounding block geometry.

All three design windows and the example source-block window passed automated
launch checks, including real movement and both postures. The initial view faces
along the incline. Human results are recorded separately below.

## Three designs

Run in **PowerShell 7 (`pwsh.exe`)**, not Windows PowerShell 5.1
(`powershell.exe`). Preparation runs the maintained rendered suite first. Close
each game window to open the next design; preparation is shared by all three.

```powershell
& C:/Godot/Projects/Daggerfall_GD/main_project/tools/review_ground.ps1 -ClassicSource C:/Games/Daggerfall/arena2 -ConnectorModels 61030,67027,67029
```

From an ordinary Windows PowerShell window with scripts disabled, this complete
command uses the installed Codex PowerShell 7 runtime and opens all four reviews.
`ExecutionPolicy Bypass` applies only to the launched process; saved policy is
unchanged and administrator access is unnecessary.

```powershell
& 'C:\Users\Kirk\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe' -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\Godot\Projects\Daggerfall_GD\main_project\tools\review_ground.ps1' -ConnectorModels 61030,67027,67029 -ConnectorPlacements 'block-0917/record-00028'"
```

The earlier `powershell.exe` command was incorrect: Windows PowerShell 5.1 can
return a null engine exit code after waiting, even when Godot prints the correct
version. The launcher now rejects that shell before preparation with an explicit
PowerShell 7 requirement. This is a launcher compatibility issue, not a failed
movement test; historical machine qualification used PowerShell 7.

The orange surface highlights the original approved floor; original collision is
unchanged. Grey walls/roof use original geometry. The blue upper landing is a
test addition. This uses real SessionShell input/view, MOVE capsule and CHAR;
entry, LOC readiness, TIME, traits and restrictions are controlled providers.
It does not install a normal-game entry or save bypass.

Controls: WASD, mouse look, left Ctrl Toggle Crouch, left Shift Hold Run, left Alt
Hold Sneak, middle mouse Autorun, Escape Pause/Controls. Walk up to the upper
landing, turn or move backward to descend, then repeat with the other gaits and
crouching. The display shows actual posture and target/actual surface speed.

| Check | Expected | Result |
| --- | --- | --- |
| 1. All three floors, uphill and downhill | Both directions work without jumping or an exceptional speed boost. | User-reported PASS, all three windows |
| 2. Standing Walk / Run / Sneak | Each gait works at its own normal speed; entry and exit do not stick. | User-reported PASS, all three windows |
| 3. Crouched Walk / Run / Sneak | Deliberate crouch keeps its normal speed and full collision; standing remains explicit. | User-reported PASS, all three windows |
| 4. Walls, roof and camera | Side walls block movement; the camera remains inside geometry through posture/ground transitions. | User-reported PASS, all three windows |
| 5. Pause and Controls | Pause freezes advancement; resume has no catch-up. Hold/Toggle settings continue to apply independently. | User-reported PASS, all three windows |

On this controlled actor, approximate target speeds in m/s are standing
Walk 4.430, Run 7.089, Sneak 2.190; crouched Walk 2.532, Run 3.544, Sneak 1.241.
Contact transitions can reduce performed speed. The exceptions do not raise the
gait target or authorize collision/posture shortcuts.

## Inspect a source placement

This example opens the ramp and surrounding model geometry from B0000009.RDB:

```powershell
& C:/Godot/Projects/Daggerfall_GD/main_project/tools/review_ground.ps1 -ClassicSource C:/Games/Daggerfall/arena2 -ConnectorPlacements 'block-0917/record-00028'
```

Any of the 25 block/record pairs in the [source list](IMP-012-STEEP-RAMP-LIST-2026-11-24.md)
can be selected. Multiple strings can be separated by commas. The whole block is
rigidly repositioned so the selected ramp is easy to inspect; its internal model
positions and rotations remain unchanged. This mode adds no blue landing or
artificial ground. Doors/mechanisms are static, and actors, water gameplay and
full assembled-location connections are outside this geometry inspection.

| Check | Expected | Result |
| --- | --- | --- |
| 6. Source block geometry | The selected original ramp and its adjoining pieces are identifiable and match the intended route. | User reports orange ramp works; no DFU parity inferred |
| 7. Neighbouring stairs | Ordinary staircase risers still follow ordinary step limits. Report any desired tuning change separately from the steep floor exception. | Ascent blocked beyond first lower stair; return toward ramp entered non-resumable hold. Boundary remains open. |

Human build: `verification-rendered-cc8b5f15a7814be586b3eae8dc2c719d`.
All four review windows have closed markers. The source-block engine log has no
detailed physical trace, so the precise losing-support contact is not independently
localized. The user's report is consistent with the known ordinary 0.30 m stair
boundary and the ground-only fixture's pending air/fall handoff. It is retained as
a boundary limitation, not silently counted as a successful full route or as a
verified fault on the reviewed ramp floor.

The source checks found 0.30 m stair risers in model 67025. Four ramp entrances
have a 0.30 m join into ordinary stairs: `block-0915/record-00007`,
`block-0916/record-00001`, `block-0917/record-00007`, and
`block-0918/record-00006`. The example upper exit joins the same staircase model;
the straight-ahead stationary capsule probe overlaps its next riser in both
postures. Those are retained physical obstacles, not extra ramp permissions.
The current ordinary limits remain 0.25 m up / 0.18 m down. Jump/air/fall work is
the later increment; large unsupported exits can hold this ground-only review.

If comparing against DFU, use the same block and model junction rather than
searching all copies manually. This review certifies neither DFU parity nor
complete quest/dungeon reachability. Record the model or block/record, direction,
posture/gait and observed issue when reporting feedback.

The launcher creates disposable storage under `main_project/tests/.runs/` and
protects a build only while its review window is active. Closed builds can be
compacted; rerunning the command rebuilds current code. No automatic human PASS
is recorded when a window closes.
