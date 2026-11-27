# IMP-015 — Custom-class main sheet, skills and advancement dagger

Started November 27, 2026 at 12:05:46 AM EST from the user's committed baseline.
Scope is the main custom sheet, skill list selection and advancement afterimage.
Existing advantage/disadvantage/reputation/details submenus are retained for
later presentation work. Parent/increment, entry/SAVE and milestone gates remain
unchanged. No class rules or authoritative draft schemas are redesigned.

## Source and presentation

Pinned DFU `CreateCharCustomClass.cs` supplies the CUST00I0 main layout, CUST08I0
24×9 dagger, twelve skill button rectangles, HP arrows and submenu/Exit regions.
`StatsRollout.cs` and `UpDownSpinner.cs` supply the selected-attribute spinner and
CHAR02I1.IMG (15×20), now an explicit optional classic image/media target
`creation.stat-spinner`. Index-zero transparency is applied to the spinner as
well as the existing dagger. Original assets stay external/read-only; the normal
media resolver, source provenance, palette and mod replacement precedence apply.

`creation_custom_sheet.gd` layers native-sized bitmap labels, transparent real
buttons and a name LineEdit over the existing replaceable main-sheet art. The
ordinary development Use name action remains outside the native sheet. Main
attribute values/pool and HP values come from the existing owner evaluation;
attribute arrows use configured bounds, and HP arrows retain the owner HP-cost
formula. The native Exit region submits the existing next request and cannot
bypass incomplete/invalid class checks. Other submenu handlers remain intact.

Skill slots open the shared classic list picker, sorted by localized label.
Single click changes local selection; double click or Enter sends the existing
custom owner edit. Already assigned skills are excluded across all twelve slots,
except the current slot's own choice, preserving the approved uniqueness rule.
Escape dismisses the picker without a draft edit. Slot buttons have the original
click feedback; picker selection/activation remains silent. Pending name text
survives repaint/submenu navigation, with whole-field locale-font recovery for
unsupported bitmap glyphs; Unicode remains in the stored candidate.

## Dagger afterimage

DFU uses `daggerTrailLingerTime = 1.0f` and linearly decreasing alpha based on
`Time.unscaledDeltaTime`. It leaves stationary snapshots at updated positions,
rather than sliding the dagger between values. Neutral position is (220,115),
with positive/negative offsets 37/41 native pixels and visual clamps 46..186.
The recreation maps the existing owner difficulty against published policy
bounds, preserving baseline geometry without embedding policy values in CHAR.

`creation_difficulty_dagger.gd` draws recent snapshots with a one-second real-time
linear fade, independent of gameplay time. UI-only timestamps/positions survive
normal sheet repaint; no SAVE/RNG/owner fact is added. Expired snapshots stop
processing; nodes are owned by the sheet and disappear with it. No suspended
preview coroutine or persistent animation task is introduced.

## Focused review

```powershell
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File 'C:/Godot/Projects/Daggerfall_GD/main_project/tools/preview_creation_gender.ps1' -CustomSheet
```

The focused stock-provider route enters through race, gender, class method and
Custom in the list, which opens the sheet directly. Add `-SmokeTest`
for maintained real-input checks and blank/picker/selected/dagger captures; use
`-CloseTest` for the interactive lifecycle branch and production close handler.
Prepared-source fingerprints include the new scripts; original freshness checks
include CUST00I0, CUST08I0 and CHAR02I1. Maintained broader career controls are
updated for native arrows and skill-picker activation. Broad suites/exports are
deferred to the combined presentation checkpoint. Human visual acceptance is
pending and changes are uncommitted.

## Verification result

Completed November 27 at **12:18:32 AM EST**, about thirteen minutes.

- Final focused SmokeTest `verification-rendered-e5a7f97a4fac4ee1927d1fc4978ceb45`:
  **45 checks passed**, including actual mouse/keyboard skill selection and
  cancellation, alphabetical order, cross-tier duplicate exclusion, name Enter,
  HP/attribute edits, incomplete Exit rejection, native hit-region sizing and
  one-second trail expiry/processing stop. Blank, picker, selected-skills and
  visible afterimage captures were inspected. Copied build/cache compacted:
  214,902,404 bytes removed.
- Final interactive CloseTest `verification-rendered-9cc0806fb91f4a51b4516f1fe9c4a083`:
  **27 setup checks passed**, then production window-close handling completed
  with no leaked-object/resource-in-use diagnostics. Its copied build/cache was
  compacted: 214,902,404 bytes removed.
- Development roots `3731475828c04a3e84e7847a747e52ce` and
  `ee2470ed391d436381a7557a59a1e2d4` retain their actual failed status. The first
  caught a helper constant shadowing Godot's Popup native class; renamed to
  ClassicPopup. The second caught a stock hidden-label minimum expanding skill
  buttons to nine pixels; the final bitmap font and focus margins restore the
  required eight pixels. Verified source archives, original logs and captures
  are retained; understood inactive copied projects were removed (209,800,497
  and 209,800,523 bytes), with development cleanup receipts.
- `git diff --check` passed. Updated broader career fixtures are not claimed as
  run; broad suites/exports and human visual acceptance remain as described.

## Follow-up — direct Custom entry

User requested removal of the extra Open custom career step. A successful stock
navigation action entering Custom now reuses the retained custom candidate, or
prepares its normal initial candidate through the existing validated navigation
edit. Initialization does not run during rendering. The old start button is
removed. Focused coverage checks immediate sheet availability, absence of the
extra button, and returning through the class list without losing custom edits.
The ordinary preview command above is unchanged.

Direct-entry SmokeTest `verification-rendered-682689604d9c4a609696ad5bfcab765c`
passed **48 checks**, including first entry and leaving/reopening through the
class list with all custom edits retained. Initialization is scoped to the real
career provider so assigned qualification providers keep their existing contract.
Final-code CloseTest `verification-rendered-6b5c0f1ed0424469a3238bdedffcbe5d`
passed **28 checks** and closed without leak diagnostics. Authentic direct-entry
capture was inspected. Both copied builds were compacted (214,903,547 and
214,903,591 bytes removed); compact evidence is retained. Whitespace checks
passed. Broader verification stays deferred; changes remain uncommitted.

## Follow-up — held HP arrows, pointer focus and attribute centering

User requested repeat while holding HP arrows, no yellow outline after mouse
clicks, and more centered attribute values. Started November 27 at 1:22 AM EST.

`creation_hp_repeat.gd` retains one admitted mouse gesture across sheet repaints,
using weak view references and a host-owned node released by creator clear/exit.
It performs an immediate validated HP edit then repeats every **300 ms**, matching
the pinned UpDownSpinner default interval. The pinned custom-class HP handlers
themselves use ordinary click events; this is the user-requested held behavior,
using the existing DFU spinner cadence rather than claiming an exact HP-handler
implementation match. Current owner context and configured HP bounds are checked
on each tick. Release, pointer exit, focus loss, busy state, another page, a modal
or creator retirement stop the gesture; idle processing is disabled. Input-event
coordinates are used rather than querying the OS cursor during a held gesture.

Native sheet buttons suppress the focus rectangle for mouse input and retain a
visible focus indicator for keyboard navigation. The mode survives repaint.
StatsRollout's number panel spans native x=8..42 (34 pixels); the earlier 26-pixel
area biased numbers left. Values now center across that source width at y=33+22n,
and the attribute hit regions start at x=7 rather than x=0. Glyphs remain aligned
to the top of their natural Godot label line box.

The focused fixture includes a real held-mouse interval across multiple owner
edits/repaints, release/pointer-exit stopping, a configured maximum, keyboard
activation/focus, and source attribute width/position checks. The existing preview
command is unchanged. Broader suites/exports remain deferred.

Final follow-up SmokeTest `verification-rendered-3a8cd658770d47d381e9e8d3d5e6bead`
passed **58 checks**. The corrected attribute/no-mouse-outline capture was
visually inspected. CloseTest `verification-rendered-b4819b1ded124dbba73c04c30a37e83a`
passed **31 checks**, including clean shutdown with the repeat handler owned by
the creator; no leaked-object/resource-in-use diagnostics. Their copied builds
were compacted (214,911,323 and 214,911,322 bytes removed).

Development run `72900f7d7ddf48f188fad822f291c34c` retains its failed report.
It exposed the need to track actual input-event coordinates across redraws
instead of querying the OS cursor in the repeat loop. The attribute check was
also corrected to assert the source panel width independently of Godot's
fallback-aware Label minimum line height; top-aligned glyph positioning remains
at the source coordinate. Its executed source archive/logs/captures were retained
and verified; 209,807,660 copied-project bytes removed with a cleanup receipt.
`git diff --check` passed. Changes remain uncommitted.

## Follow-up — shared attribute hold and faster cadence

November 27, 8:00 AM EST: user confirmed that held HP repetition is an intentional
convenience beyond their observed DFU behavior, and requested holding the
attribute arrows too with a shorter 0.2/0.15-second delay. Both now use **150 ms**.
The existing held-gesture handler accepts an optional captured attribute ID;
HP remains its default target. Attribute gestures use the selected attribute's
published limits and stop if selection changes, preserving validated owner edits
and the existing release, pointer, focus, modal, retirement and disposal guards.
No second timer/animation or new owner state is introduced.

Focused coverage holds both attribute directions across redraws, checks release,
selected-attribute lower-bound clamping and no unintended HP edits, and retains
all existing HP and sheet checks. The ordinary preview command is unchanged.
Broader suites/exports remain deferred; no fresh lifecycle machinery is added.

Focused run `verification-rendered-5cce286965a2402b9c264f82b19d69ec` passed all
**63 checks**, with no shutdown leak diagnostics. Both attribute directions,
150-ms behavior across redraws, release, selected-attribute minimum, unrelated
HP retention, and existing HP limits/pointer exit checks passed. Copied build/cache
compacted (214,914,540 bytes removed); reports/logs/captures retained. Whitespace
checks passed. The existing shared-handler lifecycle is preserved; a separate
interactive CloseTest was not repeated for this extension. Changes are uncommitted.

### Attribute-selector feedback

User requested UI-click feedback when selecting an attribute to move the spinner.
The existing guarded attribute-button callback now submits the shared click once
before repainting. Focused coverage checks one playback submission and the new
selected-attribute index through actual mouse input. Other click/hold behavior
and broader verification cadence are unchanged.

Focused run `verification-rendered-fdd7c0cf6c1d423b8049456118a2f969` passed
**65 checks**, including that sound/focus assertion and existing hold/limit tests,
with no leak diagnostics. Copied build/cache compacted (214,914,888 bytes removed);
compact evidence retained. Whitespace check passed; changes are uncommitted.
