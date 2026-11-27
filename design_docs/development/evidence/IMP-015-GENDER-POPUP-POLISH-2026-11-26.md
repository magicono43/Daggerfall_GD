# IMP-015 — Gender popup presentation iteration

Started November 26, 2026 at 9:32:27 PM EST from clean user commit `b276cf3`.
The user approved the preceding race popup's appearance and requested the
Non-SDF gender screenshot direction, then added button click feedback.
This iteration leaves parent/increment acceptance and milestone gates pending.

## Implemented scope

- Reuse the race popup's SPOP parchment, yellow FONT0003 bitmap lettering and
  static sprites. Gender uses BUTTONS.RCI records 6/7 (Male/Female), matching
  the pinned DFU DaggerfallMessageBox button enum. The short prompt/button group
  is centered on the stock Tamriel map, supplied by the replaceable gender step
  art binding. Development controls retain their ordinary font.
- Both gender choices use the existing owner edit and navigation requests and
  advance immediately on success; redundant Next is hidden. Back retains the
  chosen gender. The maintained career interaction fixture follows this route.
- Shared race/gender popup activation plays the classic button click, ordinal
  360, identified by pinned DFU `Assets/Scripts/SoundClips.cs` ButtonClick.
  Follow-up correction: DFU's enum is an archive ordinal; the initial numeric
  selector incorrectly selected record ID 360. Use explicit `{"ordinal":360}`
  as existing movement/death audio does. The focused fixture now asserts the
  decoded provenance ordinal, in addition to playback submission. User reported
  the initial clip sounded like Hard Fall; its audibility was not identity proof.
  Corrected focused run `verification-rendered-068bcefc1fbd4dcbba252d6fe5385cba`
  passed all 28 checks, including ordinal 360; copied build/cache compacted.
  User approved the gender UI appearance/operation before this audio correction.
  Optional `creation.dialog.click` uses the existing media replacement resolver
  and audio instance helper; missing audio does not block selection. A host-owned
  player survives the page handoff and is released when creation art is disposed.
  Disabled, busy, obsolete and retired inputs are guarded before playback.
  No movement-audio preference is repurposed for interface feedback.
- Original external assets and reference sources remain read-only. Existing
  provenance and media override precedence apply; no original binary is added.

## Focused verification and review

### Follow-up: uninterrupted race narration

User confirmed the corrected click sound and requested race narration play to
completion, including overlapping selections. Started November 26 at 10:03:01 PM
EST. Each selection now creates an independent host-owned one-shot, removes it
on natural completion, and frees its player. Race No/Yes, nested cancellation,
new selections and page changes no longer stop preceding narration. Closing or
restarting creation still stops and frees all retained players. This supersedes
the initial race pass's stop-on-No behavior; visuals and owner choices are unchanged.
The focused fixture checks overlap, playback after No/Yes and page handoff,
natural completion/player release, and exit cleanup through actual controls.
Broader regressions/exports remain deferred to the combined presentation checkpoint.
Completed at 10:05:20 PM EST. Focused rendered run
`verification-rendered-6dd4127b0c9e40c5af03ce513822d365` passed all 33 checks,
including natural completion, overlapping players and exit cleanup. Copied
build/cache compacted (214,857,292 bytes removed); compact evidence retained.
Diff whitespace check passed; physical audibility remains user review.

`tools/preview_creation_gender.ps1` directly launches a stock-provider rendered
preview in disposable storage. It checks current copied source fingerprints,
imports with the pinned engine, rejects script diagnostics, checks external
source freshness and compacts its owned copied build after engine exit.
It does not invoke full creation qualification or Windows exports.

The smoke path uses actual race Yes/No, Male activation, focused Female Enter,
Back and an obsolete callback. Assertions cover map/font/prompt/sprite size,
state commitment/retention, immediate navigation and one audio playback submission
per current popup activation. It checks a nonempty decoded click stream; physical
audibility and the user's visual acceptance remain human review.

Run interactively from any folder using PowerShell:

```powershell
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -ExecutionPolicy Bypass -File 'C:/Godot/Projects/Daggerfall_GD/main_project/tools/preview_creation_gender.ps1'
```

Add `-SmokeTest` for the focused automated route. The preview starts at gender
after confirming Nord through the real race controls, and does not enter gameplay.
Broader creation regressions and exports are deferred to the approved combined
presentation checkpoint under fast-ui-polish. No physical controller testing or
full creation qualification is claimed. Changes remain uncommitted.

Completed November 26 at 9:50:16 PM EST (about 18 minutes, including the new
direct preview launcher and added audio request). Final focused run:
`main_project/tests/.runs/verification-rendered-97b08e6428874438a2d85b2fa88f934d`,
27 checks passed on Godot 4.7.2; current gender capture visually inspected.
The owned copied project/cache was compacted, removing 214,855,990 bytes while
retaining reports, logs, source archive and reviewed captures. Earlier iteration
roots were also compacted. `git diff --check` passed before this evidence update.
