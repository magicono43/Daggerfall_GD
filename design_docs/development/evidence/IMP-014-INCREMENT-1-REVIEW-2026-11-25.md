# IMP-014 increment 1 — human review

**User-reported result, 2026-11-25: 1–6 PASS.** The user explicitly accepted
increment 1; see [acceptance](IMP-014-INCREMENT-1-ACCEPTANCE-2026-11-25.md).
The pending wording below is the original review handoff. Automated smoke remains
separate and its delivery-time `human_pass=false` is not rewritten.

Human success and acceptance are pending. Automated results do not mark these
checks passed. Entry/activity authorization is controlled; CORE, DATA publication,
the calendar owner, requester gates, clock snapshots and stock Quit are real.
This review supplies no playable movement course, real rest owner or native SAVE.

Run from PowerShell using the exact installed PowerShell 7 command:

```powershell
& "C:\Users\Kirk\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "C:\Godot\Projects\Daggerfall_GD\main_project\tools\review_calendar.ps1" -ClassicSource "C:\Games\Daggerfall\arena2"
```

Preparation rebuilds and verifies a disposable rendered project before opening
the review. No administrator access or permanent execution-policy change is
needed. Compacted builds are rebuilt through this launcher. Close the review
before cleanup; its active marker records that obligation.

1. Confirm the numeric readout shows year 405, month 1, day 4, initially near
   13:30, winter and weekday index 3. While focused and Running, game seconds
   progress at about twelve per real second. The controlled-provider label is
   visible and no time/rate gameplay setting was added.
2. Press **Pause / Resume**. The status becomes Suspended and timestamp/fraction
   stay fixed. Resume and confirm progression resumes without catching up for
   the paused duration. Stock Escape/Pause remains usable too.
3. While paused, use **Capture exact clock** and note the reported timestamp and
   fraction. **Controlled explicit +1 hour** must reject under this independent
   pause. Resume, then use the explicit-hour button: the clock gains one hour,
   with ordinary progression continuing around the operation.
4. Use **Restore captured clock**. It restores the captured timestamp/fraction
   exactly and leaves the review paused for comparison. Resume and confirm
   normal progression. **New character clock** returns to the resolved opening
   rather than the captured later instant. These are controlled owner payloads,
   not disk SAVE slots or story/grant qualification.
5. Switch focus away for several seconds and return. The clock resumes from the
   suspended instant without a large jump. An already-open Pause stays paused
   across focus changes.
6. Press **Quit**. Confirm the stock discard choice is visible and usable;
   **Keep Playing** cancels Quit without releasing Pause. Quit again and choose
   **Discard and Quit** to close normally. Report any overlapping/unreadable
   controls or unexpected time changes.

Report numbered results and any observations. Increments 2–3, parent IMP-014,
M2, real TIME/CHAR scheduler/activity integration and native SAVE remain open.
