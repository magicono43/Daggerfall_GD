# IMP-015 bonus allocation, reflexes and overview polish

User-requested presentation pass, started 2026-11-27 at 1:17:04 PM EST.
Uses the repository fast-ui-polish workflow. Human presentation acceptance,
parent IMP-015 and real character entry under IMP-036 remain open.

## Implementation and source evidence

Bonus attributes and skills now use native CHAR02I0/CHAR03I0 screens, original
CHAR02I1/CHAR03I1 spinners, the existing non-SDF font and transparent semantic
hit controls. Values with positive allocated points turn green, reverting to
yellow when allocation returns to zero. Attribute selection and each skill
tier retain independent spinner positions. Held arrows repeat every 150 ms,
matching the user's custom-creator cadence; release, pointer exit, focus loss,
navigation, discard and submission stop the gesture.

Initial rolls are generated on an accepted navigation request into the page,
never during rendering. Retained rolls are reused. Reroll, Save Roll and Load
Roll retain existing owner operations and sealed generation provenance. Native
OK retains completeness validation. Derived values still come from CHAR's
attribute-preview interface; no new balance formulas are introduced.

DFU StatsRollout.cs uses SoundClips.DiceRoll, ordinal **300** in SoundClips.cs.
The new replaceable `creation.dice-roll` media target resolves through ordinary
media precedence. Each accepted roll starts a host-owned one-shot player that
frees itself on completion, so rapid rerolls overlap and page repaint cannot
interrupt them. Existing UI-click playback is reused for deliberate controls.

Reflex selection uses CHAR05I0 and CHAR05I1 highlight rows, with the reference
parchment explanation and native choice/OK rectangles. Overview uses CHAR04I0,
both allocation rollouts, name input, native face controls, reflex picker and
Restart/OK. Detailed review/history remains reachable outside the original art.
Inline overview changes enter the existing permitted summary editor, submit
the same owner/provider request, then return to overview. Incomplete point
redistribution remains visible but blocks final capture. Name composition,
stale contexts, summary restrictions and submitted-state guards remain active.
The existing CORE handoff is retained; this is not new real-entry qualification.

Reference geometry: DFU CreateCharAddBonusStats.cs, StatsRollout.cs,
SkillsRollout.cs, LeftRightSpinner.cs, CreateCharReflexSelect.cs, ReflexPicker.cs
and CreateCharSummary.cs in the pinned read-only DFU source. Original game
art/audio stay external and read-only; no library or source asset is copied
into recreation code. Classic-access gains two explicitly named optional IMG
entries, rather than widening filesystem access. Existing codec/license and
media provenance contracts apply.

## Focused verification

Maintained `creation_final_pages_preview.gd` exercises the real preset → automatic
biography → Name → face → attributes → skills → reflexes → overview route.
It checks dice submission/overlap, hold input, green values, Save/Load restoration,
owner allocation completion, overview redistribution rejection/recovery, name,
face and reflex edits, valid capture and no premature live actors.
Full creator regressions and debug/release exports are deferred to the next
combined checkpoint. No physical audio-device listening or human visual
acceptance is inferred from playback submission/rendered checks.

## Focused review

Use PowerShell 7:

```powershell
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File 'C:/Godot/Projects/Daggerfall_GD/main_project/tools/preview_creation_gender.ps1' -FinalPages
```

Add `-FinalPage skills`, `-FinalPage reflexes` or `-FinalPage summary` for a later
screen. Preparation uses real production requests and disposes its copied build
after the review engine exits. Add `-SmokeTest` for focused machine checks.

## Final results and retention

Completed **1:40:43 PM EST**, elapsed **23 minutes 39 seconds**.
Final focused plus existing identity owner/UI run
`verification-rendered-04d2fc46fefc4cbf8293fd3223318f44` passed **672 checks**.
Native overview, bonus attributes/skills and reflex screenshots are retained at
`main_project/tests/.runs/verification-rendered-04d2fc46fefc4cbf8293fd3223318f44/project/tests/.runs/preview/storage/`.
The final source differs from that run only by removing a trailing blank line;
subsequent shutdown runs used the tidied source.

Shutdown runs `verification-rendered-54345b6b73d84b82be5460b9cf555103`
(attributes, **21 checks**) and
`verification-rendered-b5150e02d4504ff6a8e3444a81ed5c56`
(overview, **42 checks**) passed without resource-leak diagnostics.
Known certificate-store and verbose hardware RGB conversion diagnostics retain
existing handling; no warnings or assertions were suppressed for this work.

Earlier development runs retain their real status. One caught an optional
attribute-label lookup; two caught obsolete test expectations about name overflow
and a CJK glyph in the installed fallback font. The final test checks Unicode
retention, fallback selection and the existing unsupported-glyph diagnostic,
without claiming that an unavailable CJK glyph is installed.
Maintained identity/biography UI helpers and scenario inventory now reflect
native confirmations and automatic initial-roll generation. The specialized
biography fixture and full suite remain deferred rather than counted as passing.

All six successful copies automatically compacted. The three exact closed failed
roots (cfae5a24dd8c4742a6781e3ddf1d40d8, 426a83da8381401cb5d12fe8c6f5054f,
87526eb39b144b67b6dcb997d7fce945) were archived and compacted with containment,
reparse, inactivity and source-archive checks: **629,761,605 bytes removed**.
Original failed reports, logs, captures and verified source archives remain.
No unrelated historical roots or external sources were changed. Final
`git diff --check` passed; all authored changes remain uncommitted.
