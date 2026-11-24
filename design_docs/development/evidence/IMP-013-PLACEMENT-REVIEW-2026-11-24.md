# IMP-013 increment 3 — placement review

User acceptance is pending. These are diagnostic captures from the independent
rendered normal-composition fixture on Godot 4.7.2 / Windows D3D12. Lifecycle and
access services are controlled; DATA/LOC/MOVE, Jolt queries and actor commitment
are real. They do not show a completed ordinary gameplay transition or native SAVE.

Green shows the full radius **0.30 m**, height **1.80 m** capsule. Gold shows the
unchanged source anchor/facing and exact bound exit aperture. Diagnostic overlays
draw through geometry so the complete shape and bindings stay visible. Numerical
Jolt assertions, rather than overlay occlusion, establish clearance/support.

## Exact classic placement

Home-east source anchor `[4.8,0,-1.6]` becomes actor centre
`[4.8,0.91,-1.29]`. The explicit 0.31 m lateral aperture fitting is anchor
conversion, retained separately from recovery. Candidate 0 is exact after that
declared conversion; no source marker or geometry is moved.

![Home-east full capsule and original anchor](../../../main_project/tests/.runs/verification-rendered-2459ce5c1e14451baeba09e9db80ad1a/project/tests/.runs/scenario-1/location-placement-home-east.png)

## Corrected placement

The authored raised-marker fixture has source sole anchor `[4.8,0.075,-1.6]`.
It keeps the same declared interior/door side and original marker identity.

| Candidate | Requested actor centre, metres | Checked outcome |
| --- | --- | --- |
| 0, exact | `[4.8,0.985,-1.29]` | Missing support within profile depth |
| 1, up 0.025 m | `[4.8,1.010,-1.29]` | Missing support |
| 2, down 0.025 m | `[4.8,0.960,-1.29]` | Full volume, support and correction sweep pass |

The corrected displacement is `[0,-0.025,0] m`, within the 0.60 m declared bound.
Exhausting the same profile with no correction candidates returns checked failure.
Initially overlapping wall/ceiling/occupant poses and blocked routes fail safely;
this profile does not certify penetration-escape correction.

![Corrected capsule, source anchor, intended interior side and candidate 2](../../../main_project/tests/.runs/verification-rendered-2459ce5c1e14451baeba09e9db80ad1a/project/tests/.runs/scenario-1/location-placement-corrected.png)

## Courtyard entry and actual rear exit

The courtyard alias retains selected exterior plane41, but lands at original
marker00271 beside actual exit00203. The actor centre is `[-1.91,0.91,8]`.
The maintained commit sequence then selects the rear exit and commits outside
plane46, preserving that canonical return through the bounded correction. A
second sequence enters at front plane36 and also leaves through actual rear
plane46; leaving does not use the last entrance. There is no third interior exit.

![Courtyard alias at the rear landing and actual rear exit](../../../main_project/tests/.runs/verification-rendered-2459ce5c1e14451baeba09e9db80ad1a/project/tests/.runs/scenario-1/location-placement-tavern-courtyard.png)

## Reviewing the evidence

Inspect the capsule/anchor distinction, full height/width, indicated interior side
and explicit exit IDs above. The corrected-pose table supplies both the exact
requested centre and corrected centre; the tiny vertical correction is not
exaggerated in the capture. The final suite also directly asserts the actual
CharacterBody/Jolt transform, shape registration in the active space and stock
camera facing, independently from MOVE's returned state.

Reproduce via the normal verification entry point:

```powershell
./main_project/tools/verify_rendered.ps1 -Suite location-assembly -Fixture location-assembly-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
```

Use [execution evidence](IMP-013-increment-3-2026-11-24.md) and its machine audit
for exact final checks/build identities, remaining integration gates and cleanup.
The disposable runnable copies can be removed while these captures/reports remain
at their original paths. Agent inspection of these images is visual QA, not the
user's acceptance or ordinary gameplay/milestone qualification.
