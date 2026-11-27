# IMP-015 — Custom-class reputation submenu

Started November 27, 2026 at **8:27:16 AM EST** using fast-ui-polish. The user
requested the original empty/changed reputation screen, unbalanced Exit warning,
click feedback and Escape returning to the custom sheet. Parent/increment and
milestone acceptance gates are unchanged; other custom submenus remain intact.

## Source and implementation

Pinned DFU `CreateCharReputationWindow.cs` supplies `CUST03I0.IMG` (168×189),
bar interaction y=24..128, midpoint y=76, green/red x=3+33n, five-pixel widths,
50-pixel maximum heights and the native Exit/value-label positions. Colors are
RGB float (0.388,0.549,0.223) and (0.580,0.031,0). Original click rounding is
retained: integer distance from midpoint rounds up only at remainder four of five,
then becomes reputation units. Default range is ±10; UI mapping scales/clamps to
the published group limits rather than embedding those limits in the owner.

The bounded classic reader admits the optional image with ART_PAL.COL. AV
registers replaceable `creation.reputation` through the existing media resolver,
preserving provenance and mod precedence. Originals/references remain read-only;
no original binary is copied into the repository. `creation_reputation.gd`
layers real controls and green/red bars over that source image and the native
custom sheet. DATA/CHAR's stable `commoners` identity occupies DFU's Peasants
column; all five group identities remain unchanged.

Clicking a column level edits the existing custom candidate through validated
UI/navigation/CHAR interfaces and submits one shared UI click. No live faction
standing changes or new owner facts are introduced. Up/Down/Home/End support
keyboard adjustment. Captured generation/context, busy/summary checks and weak
bar-control references reject retired callbacks without effects or diagnostics.

Remaining points come from the configured reputation total minus the five draft
values. The native Exit stays in the submenu and opens the original-text
parchment warning when the balance is nonzero. The shared classic popup supports
a no-button notice dismissed by clicking anywhere or keyboard activation.
Escape dismisses a warning first. As corrected in the follow-up below, Escape,
Exit and toolbar Back share the same balance check: unbalanced values keep the
menu open and show the warning; balanced values return to the custom sheet.
The existing final custom-class validation also reports/rejects imbalance.
The underlying native sheet controls and redundant Next are blocked
while the submenu is open.

## Focused preview

```powershell
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File 'C:/Godot/Projects/Daggerfall_GD/main_project/tools/preview_creation_gender.ps1' -Reputation
```

Add `-SmokeTest` for real graph-click values 10/-5/3/-10/2, balanced/unbalanced
Exit, warning click/Escape, retained values, stale callbacks, keyboard controls
and toolbar Back. `-CloseTest` uses the interactive initialization branch and
closes with a live warning to verify modal shutdown. The preview enters through
actual race, gender, class-list Custom and main-sheet Reputation controls, with
disposable storage. Source hashes cover the component/fixture and external image.
The broader career fixture now drives graph input instead of the removed
reputation SpinBox; it is updated but not claimed as run here.

Broader regressions/Windows exports remain deferred to the combined presentation
checkpoint. Human appearance/physical audibility acceptance is not automated.
Changes remain uncommitted.

## Verification result

Completed at **8:41:15 AM EST**, about fourteen minutes.

- Focused rendered SmokeTest `verification-rendered-6861b6ccc97e44acb4462a606130145a`
  passed **70 checks**, including actual click mapping/feedback, source bar
  colors and extents, balance enforcement, warning click/Escape, retained draft
  values, stale callbacks, keyboard adjustments and safe toolbar Back. Final
  balanced/unbalanced captures were visually inspected. Copied build/cache
  compacted: 214,928,992 bytes removed.
- Interactive CloseTest `verification-rendered-f9cd4f0b8d16465e99a4e9d57f1c8ce3`
  passed **38 checks** and exited through the normal close handler with a live
  reputation warning and no leaked-object/resource-in-use diagnostics. Its copied
  build/cache was compacted: 214,928,992 bytes removed.
- Development roots `7cdff9eb7e0a4a13a01c9c4072a4ab13` and
  `3711d7d9bb8f4594ad2f0746ad5dcf96` retain their actual failed status. The first
  caught a freed Node capture in a deliberately retained bar callback; a guarded
  WeakRef removes the stale reference. The second caught a strict inferred
  Variant warning for weakref(); an explicit WeakRef annotation corrected it.
  Verified executed-source archives, logs and captures remain; 209,826,337 and
  209,827,367 copied-project bytes were removed with cleanup receipts.
- `git diff --check` passed. Broader suites/exports and human appearance approval
  remain deferred/pending as above.

## Follow-up — prevent Escape/Back balance bypass

User found that the initial generic cancel path allowed Escape to close an
unbalanced reputation menu. That interpretation was incorrect. All three UI
close paths now call a shared request_close helper that reads the current draft
and configured total. None can bypass the menu balance rule. Escape still
dismisses a warning first, and balanced Escape returns only to the custom sheet.
The focused fixture now asserts repeated Escape and toolbar Back cannot exit an
unbalanced menu, while balanced Escape/Exit/Back succeed. Broader verification
remains deferred; the normal preview command and presentation are unchanged.

Focused run `verification-rendered-e91a236972eb41dc8c46f90f5052d09e` passed
**75 checks**, including the Escape/Back regression, with no leak diagnostics.
Copied build/cache compacted (214,930,522 bytes removed); compact evidence is
retained. Whitespace check passed. Changes remain uncommitted.
