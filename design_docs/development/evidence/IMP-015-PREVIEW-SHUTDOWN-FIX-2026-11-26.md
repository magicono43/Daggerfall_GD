# IMP-015 — Interactive preview shutdown leak

Started November 26, 2026 at 11:47:07 PM EST. The user approved the current
picker/audio appearance and reported an exception after closing its interactive
preview. Parent/increment and milestone acceptance gates are unchanged.

## Evidence and cause

User run `verification-rendered-ee82b92c3c6b47e385f82177c0bb69e4` exited with
Godot diagnostics: **23 ObjectDB objects leaked, 10 resources still in use**.
The launcher's diagnostic check correctly rejected it; it was not a false alarm.
Its original failed report, stdout/stderr and reviewed captures remain evidence.

An owned verbose reproduction against that preserved copied project, using
automatic engine exit after 120 frames, reproduced the same counts. The inventory
includes **two GDScriptFunctionState instances**, RefCounted objects and ten
GDScript resources: creation_draft, creation_art, creation_navigation,
creation_career_view, creation_starting_view, creation_biography_view,
creation_identity_view, creation_view, creation_picker_preview and
creation_popup_preview. Retained logs: `close-before.stdout.log` and
`close-before.stderr.log` in that root.

Interactive setup helpers suspended indefinitely in `while true: await
process_frame`. Their coroutine stacks retained local creation-view/helper
references until engine shutdown, leaving reference-counted objects/resources
alive during ObjectDB cleanup. Automated SmokeTest returned normally, so earlier
interaction checks did not cover this lifecycle branch. This is preview-harness
lifetime retention; no runtime memory-growth measurement is claimed from an
exit-only report.

## Correction and maintained coverage

Focused interactive helpers now return their prepared preview-state result.
The startup fixture runner recognizes the existing popup-preview interactive
mode as initialization only and returns without quitting the scene tree. The
normal window/event handlers continue, with the setup coroutine stack released.
Ordinary production startup and other fixtures retain their previous paths.
The strict diagnostic/leak checks remain in force.

New `-CloseTest` exercises the interactive branch, then delivers the window-close
notification through the production shell handler. It uses verbose logs, an owned
timeout and the same strict diagnostic check; it is exclusive with SmokeTest.
Source fingerprints include the startup fixture runner. Launcher exceptions now
include a short diagnostic excerpt and log path.

```powershell
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File 'C:/Godot/Projects/Daggerfall_GD/main_project/tools/preview_creation_gender.ps1' -ClassPicker -CloseTest
```

Normal interactive use remains the same command without `-CloseTest`. No warning
is suppressed and no assertion is weakened. Full suites/exports remain deferred
under the presentation-polish workflow. Changes remain uncommitted.

## Verification

Corrected interactive CloseTest:
`verification-rendered-ff0bdc9142e3402d9db623051a27ad76`, 29 setup checks passed
and normal production window-close handling exited successfully. Independent log
scan found **zero** leaked-object/resource-in-use/Leaked-instance diagnostics.
Its copied build/cache was compacted (214,890,336 bytes removed). This tests the
interactive setup branch that SmokeTest did not previously exercise.

Unchanged interaction SmokeTest:
`verification-rendered-604423a9850449ebbdf479acf528131a`, all 72 checks passed;
copied build/cache compacted (214,890,334 bytes removed). The original failing
user run was also compacted after verified source archiving and inactivity
checks (209,788,273 copied-project bytes removed). Its failed status, original
child evidence, verbose reproduction and source hashes are preserved in the
DEVELOPMENT-COMPACTION receipt. `git diff --check` passed.
