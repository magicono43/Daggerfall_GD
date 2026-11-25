# IMP-012 increment 1 — review

**Accepted, 2026-11-24:** All eight human checks passed and the user explicitly
accepted increment 1. See [acceptance](IMP-012-INCREMENT-1-ACCEPTANCE-2026-11-24.md).
Earlier acceptance-pending wording below is historical; named later integrations
remain open.

Ground Walk/Run/Sneak now moves the existing capsule against real collision and
reports actual movement to the real CHAR owner. Controls supports independent
Hold/Toggle Run and Sneak; Autorun has the specified cancellation rules.
Moddable checked gait data, pure hooks, source factors and explicit restrictions
remain replaceable. No full story entry, posture/air/platform or SAVE completion
is claimed. All changes are left uncommitted for GitHub Desktop review.

## Run the human review

From the repository root:

```powershell
& ./main_project/tools/review_ground.ps1 -ClassicSource C:/Games/Daggerfall/arena2
```

The script rebuilds/verifies a disposable project through DEV-014 before opening
the review. It never launches a compacted archive. Storage and engine preferences
are isolated. It starts Run/Sneak at the accepted Hold defaults through actual
Controls. Its title panel is hidden only in this review during eligible play;
Pause/stock Controls returns for menus/holds. The readout is diagnostic, not a
replacement HUD or authority. Close the engine when finished. No human PASS is
generated automatically.

Preparation usually takes 1–2 minutes; the interactive course opens only after
verification passes. Other windows may be used during preparation. Automated
capture boundaries restore a controlled focused state through the stock focus
handler, releasing only its own hold. Actual focus loss still pauses/cancels
Autorun in the interactive human review and ordinary game.

If Windows blocks scripts, launch PowerShell 7 with `-NoProfile -ExecutionPolicy
Bypass -File` followed by the quoted absolute path to `review_ground.ps1` and
the `-ClassicSource` argument. That execution-policy selection applies only to
the child process. No saved execution-policy change is required. A preparation
failure prints its report path and does not open an unqualified review.

This delay belongs to the development launcher: it copies/imports a disposable
project and runs automated verification before launching the course. Shipped
startup will not run this test sequence. Real content publication/loading still
has a cost; final-game startup performance is not established by this launcher.
Interactive storage lives beneath the copied project's `tests/.runs/` boundary.
The launcher waits for the actual engine executable and reports a nonzero exit
as a launch failure, with retained stdout/stderr paths.

For engineering verification, `review_ground.ps1 -SmokeTest` runs the same
preparation and actual review entry, checks live physics/input and a rendered
course frame, then exits automatically. That flag is never a human play PASS;
omit it for the interactive checklist below.

The course uses a real floor/capsule and north blocking wall, 80×80 engine metres,
with 2 m white spacing marks. Entry/LOC readiness, TIME/traits/restrictions are
controlled; input, view, physical body, collision, CHAR and settings owners are
real normal composition. Earlier accepted physical-controller/IME deferrals stand.

Record PASS/FAIL and any observations for these manual checks:

1. Walk with WASD and look around. Forward/back/sideways agree; diagonal movement
   gains no speed. The camera follows the same body and turns movement direction.
2. Hold left Shift to Run and left Alt to Sneak. Run wins when both are held;
   releasing Run permits held Sneak again. Sneak does not crouch.
3. Run into the north wall. Actual travel stops while the Run target remains
   visible. After any already-performed partial interval settles, blocked holding
   adds no Running practice. Back away without penetration or teleportation.
4. Pause → Settings → Controls: choose independent Run/Sneak Toggle modes and
   Apply. Verify one press toggles once; Run clears Sneak. Return to Hold if desired.
5. Middle mouse toggles Autorun. Backward or retoggle cancels it. Pause or focus
   loss cancels it; resuming requires deliberate reactivation. Saved modes stay put.
6. Pause while moving, wait, then resume. No accumulated jump in position occurs.
   Toggle gait remains selected; eligible held directions/holds follow input rules.
7. Continue longer than the former 68-second prototype limit. Activity is now
   retained by elapsed/context segments; no per-frame receipt exhaustion occurs.
8. Review stock Controls Apply/Cancel/Retry feedback and course visibility at the
   intended desktop size. Report a visibility/control issue rather than accepting
   an automated screenshot as a human PASS.

Injected controller tests qualify software paths only. Real device/IME checks
remain deferred as the user requested. Later step/slope/ceiling/platform/drop
checks are not counted as passed in this flat-ground increment.

## Machine evidence and remaining gates

### Human results — 2026-11-24

The user reported PASS for checks 1–7 in this chat: movement/view, Hold gaits,
wall collision, Toggle controls, Autorun cancellation, pause/resume and continued
activity beyond the former 68-second prototype limit. These are user-reported
human results, separate from automated qualification. Exact review build identity
was not supplied with this report. The user subsequently reported PASS for check
8 (stock Controls feedback and desktop visibility), completing all eight human
checks. Explicit increment acceptance remains separate.

The earlier observed exhaustion hold remains a known course integration
limitation; these passes do not establish exhaustion recovery or unlimited
activity retention. Physical controller/IME deferrals and named real-provider
obligations remain unchanged. No explicit increment acceptance is inferred.

See [execution evidence](IMP-012-increment-1-2026-11-24.md) and its raw audit for
independent headless/rendered commands, Windows exports, exact inventories,
performance/preparation counters, captures and cleanup. Explicit acceptance,
increments 2–4, parent IMP-012, M2 and named real-provider/native SAVE joint checks
remain open.
