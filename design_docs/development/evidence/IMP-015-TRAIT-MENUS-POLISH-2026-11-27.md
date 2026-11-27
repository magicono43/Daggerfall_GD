# IMP-015 — Advantage and disadvantage menu polish

Started November 27, 2026 at **10:00:13 AM EST**, using fast-ui-polish.
User authorized the classic trait windows, nested category/variant pickers,
silent add/remove/conflict behavior, dagger trails, default seven-per-side limits,
and moddable limits/conflict rules. Existing live effect/runtime gates remain open.

## Reference and presentation

Read-only pinned DFU `CreateCharSpecialAdvantageWindow.cs` supplies window geometry,
label spacing (8 native pixels, 6 between paired lines), twelve-row picker behavior,
FONT0002 usage, category/target presentation and incompatibility evidence.
`CUST01I0.IMG` is the original disadvantage window and `CUST02I0.IMG` its advantage
header overlay. Both resolve through the normal media replacement owner; originals
remain external, read-only and fingerprinted. FONT0002 uses the existing bounded
classic font decoder with explicit source provenance. Existing DFU MIT scrollbar
resources retain their license; no DFU executable/source or classic asset is copied
into the authored repository.

`creation_traits.gd` renders over the custom sheet, so accepted owner difficulty
changes reuse the existing one-second dagger afterimages. Add and Exit buttons
have DFU's normal UI feedback; picker selection/confirmation, applying a complete
trait and removing a trait have no additional click sound. Single clicks select
picker rows; double clicks/keyboard confirmation activate them. One click on
either selected-trait line removes it. Escape closes the active picker or trait
window, without leaving the custom creator or enforcing completion rules.

The shared picker keeps its existing nine-row defaults; this caller explicitly
requests twelve rows at the smaller font size. The selected-trait region scrolls
if a mod raises limits above the original window capacity.

## Rule ownership and mods

Existing baseline limits and conflict group data already match DFU's seven-item
caps, enemy bonus/phobia, expertise/forbidden weapon and all six pairings between
immunity/resistance/low tolerance/critical weakness for matching targets. Existing
singletons are increased magery and each powered-magery category. The DATA
validator formerly hardcoded these group/singleton fields; it now accepts bounded
authored groups and boolean singleton choices, preserving supported identities,
effect targets/sides and complete policy/witness validation. CHAR applies singleton
checks symmetrically. See `scripts/char/CREATION_CAREER.md` for override semantics.
No new trait effect, cost balance, runtime stacking or persistence format is added.

## Focused verification

- Independent Godot 4.7.2 headless owner/policy check: **264 passed**. Covers every
  DFU pair/target in both orders, allowed different targets, all duplicate IDs,
  baseline singletons, conflict/singleton overrides, invalid groups, both baseline
  caps and expanded mod limits. Maintained fixture: `tests/creation_trait_rules.gd`;
  compact result: `tests/.runs/trait-rules-2026-11-27/result.json`.
- Real-provider rendered preview: **59 passed**, root
  `tests/.runs/verification-rendered-2c131c081dcc47d7bc4eef6d6452bb2d`. Includes stock
  startup, direct Custom entry, source/font resolution, both windows, twelve-row
  pickers, single-click selection, variant cancellation, actual owner edits,
  silent rejection/removal, dagger movement/trails, seven selections per side and
  Escape/Back. Inspected primary picker, selected trait and seven-disadvantage
  captures. Classic source hashes unchanged; no unexpected diagnostics.

Interactive launcher: `tools/preview_creation_gender.ps1 -Traits`, or
`-Disadvantages` for that window. `-SmokeTest` exercises both; `-CloseTest` checks
shutdown with a secondary picker open. Broader creator regressions and Windows
exports remain deferred to the presentation checkpoint; no human acceptance inferred.
Changes are uncommitted. Shutdown/cleanup completion is recorded below.

- Live secondary-picker shutdown: **34 passed**, root
  `tests/.runs/verification-rendered-0d7b5a2507bc4bcd853d137ee5ae9e97`. No unexpected
  diagnostics or leaked ObjectDB/resources. Original source hashes unchanged.
- Both successful preview copies compacted automatically: **429,930,490 bytes**
  removed, preserving reviewed PNGs, logs, reports and verified executed-source
  archives. No failed development roots were created in this pass.
- `git diff --check` passed. Full exports/broad regressions were not run.

Completed at **10:07:30 AM EST** on November 27, 2026 (about seven minutes).
