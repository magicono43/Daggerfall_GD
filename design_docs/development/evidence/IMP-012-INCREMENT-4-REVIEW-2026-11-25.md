# IMP-012 increment 4 playable review

**Human result — PASS, 2026-11-25:** The user reported “1-7: Pass” and explicitly
accepted increment 4 and parent IMP-012 as complete. All seven numbered checks
below are user-reported PASS. See [acceptance](IMP-012-ACCEPTANCE-2026-11-25.md).
Earlier pending language below is the machine-delivery checkpoint; automated
smoke's `human_pass=false` is not a later human result. M2 and named joint gates
remain open.

Human results and explicit acceptance: **pending**. This course exercises real
SessionShell input, the one MOVE capsule, resolved DATA/RULE, actual view/Controls,
CHAR activity/health/death and classic PCM playback. Entry, LOC surface/mechanism,
TIME, traits, restrictions and prevention directories are controlled providers.
It does not qualify real classic action execution, specialized movement, native
SAVE or the parent IMP-012/M2 milestone.

Machine launch qualification: **PASS**, 18 smoke assertions, with `human_pass=false`.
The maintained rendered selection and Windows debug/release exports also passed;
see [execution evidence](IMP-012-increment-4-2026-11-25.md). Course and unobscured
Quit captures were inspected. All seven human results below remain pending.

## Launch

Paste this command into Windows PowerShell. It invokes installed PowerShell 7
with a process-only policy bypass; administrator access and a permanent policy
change are unnecessary. Preparation runs the maintained rendered suite before
opening the course. It normally takes several minutes. Use other windows during
preparation, then focus the course after it opens.

```powershell
& "C:\Users\Kirk\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "C:\Godot\Projects\Daggerfall_GD\main_project\tools\review_ground.ps1" -Platforms -ClassicSource "C:\Games\Daggerfall\arena2"
```

The course starts on an 8 × 8 m platform, top 0.50 m above the floor, under an
orange roof whose underside is 2.50 m high. Use WASD, mouse look, Space Jump,
left Ctrl toggle Crouch, left Shift hold Run and left Alt hold Sneak. Escape
opens the stock menu. Mechanism command buttons appear on the right while that
menu is open: choose a command, then Resume. Commands are stationary, east/west
at 0.5 m/s, turn at 30 degrees/s, raise/lower at 0.25 m/s. Authored trajectory
endpoints bound the course; the mechanism does not automatically stop for you.

Settings → Controls contains independent gait bob, mounted bob, landing camera
and movement-audio percentages. Zero means Off. Mounted behavior is an automated
controlled-context interface check; this on-foot course contains no mount.
Missing classic optional audio is diagnosed silence; hearing a device output
remains a human check. Default landing camera is Off.

## Numbered checks

1. **Carry and facing.** Choose Ride east and Resume without walking. The
   platform carries you; voluntary distance, footsteps and Running practice stay
   unchanged. Try west, then turn. The capsule stays upright, facing follows the
   turn, and mouse/keyboard look remains usable without snapping back. Pause
   stops the mechanism; Resume produces no catch-up leap.
2. **Relative movement and detachment.** Walk/Run/Sneak while riding and turning.
   Jump while moving, walk off, and reboard a stationary platform. Departure
   inherits current point velocity once and no old attachment pulls you back.
   A 0.50 m edge can be an ordinary downward step. Raise it slightly to observe
   an actual walk-off fall. Stair/jump feel tuning remains deferred.
3. **Push and escape.** Walk onto the ground east of the platform, choose Ride
   east, then Resume. Its side should push you along a clear route. Walk away
   sideways to escape. Passive pushing alone produces no footsteps or Running
   practice; normal elapsed-time fatigue still applies. A blocked unsupported
   route may enter an explicit recovery hold rather than tunnel through a wall.
4. **Forced posture and lethal hazard.** Stand on the stationary platform and
   choose Raise. Before the standing body loses clearance, it crouches while
   retaining desired standing. Choose Lower before it becomes trapped: standing
   returns only with clearance. Repeat after deliberately crouching; lowering
   preserves that choice. Leaving the platform sideways is the escape route.
   Remaining trapped through continued compression is intentionally lethal via
   CHAR. Perform that destructive course check last or relaunch afterward.
5. **Audio and independent Off settings.** Hear distance-based on-foot steps
   while walking; pushing/carrying and walking against a wall remain silent.
   Set gait bob to 0: camera bob stops while steps remain available. Set audio
   to 0: steps mute without changing motion, costs or practice. Apply nonzero
   values again, close/reopen Controls and verify effective settings. These
   review settings use isolated disposable storage, not your normal profile.
6. **Actual camera and aim.** Enable modest gait bob, look at a fixed course
   edge, and walk. Motion is positional, with no rotational bob/roll. Cursor
   mode (the configured Cursor Mode action shown in Controls) eases bob neutral
   while eligible walking audio continues. Behind the starting platform, beyond
   the orange roof, six blue 0.50 m steps reach a 3 m feedback-drop platform.
   Walk up normally and off a side with landing camera Off, then
   enabled; posture/stair baselines remain present and camera treatment does
   not change the capsule, facing or targeting origin. Default landing camera
   Off should remain comfortable. Record any geometry clipping.
7. **Normal menus and Quit.** Pause and open Controls; course diagnostics should
   hide behind the stock menu. Return, Resume and walk again. Choose normal
   Quit, check its unobscured consent prompt, cancel once, then quit normally.
   On the lethal check, death presentation and menus must remain coherent and
   health/death must not repeat. Closing the review records closure, not PASS.

Report each number as PASS or describe the observed failure, including the
mechanism command, posture and setting values. Automated playback and launch
checks cannot establish device audibility, comfort or explicit user acceptance.
