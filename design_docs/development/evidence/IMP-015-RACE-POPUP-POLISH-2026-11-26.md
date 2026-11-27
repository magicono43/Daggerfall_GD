# IMP-015 — First race-popup presentation pass

The user committed the functional baseline as `2d422bd` and requested a small
presentation iteration against the two supplied DFU screenshots. This implements
the **non-SDF classic font** direction for the race confirmation only. It does
not accept increment 4, close parent IMP-015 or change entry/SAVE/milestone gates.
Started 2026-11-26 **8:06:08 PM EST** with a clean working tree; changes are
uncommitted for review.

## Result and reusable boundary

- A centered, content-sized SPOP parchment popup overlays the existing race map.
  Original description text and hard breaks remain centered and literal. The
  extra development/ownership annotations are removed from this popup; debug
  Back/Restart/Exit controls retain the existing regular font.
- Actual `FONT0003.FNT` supplies the bitmap lettering. Yellow `(243,239,44)` and
  shadow `(93,77,12)` follow pinned DFU defaults. `BUTTONS.RCI` records **3/4**
  supply the static Yes/No sprites at their native **32×16** aspect, with normal
  Button labels retained for semantics, real handlers and visible keyboard focus.
  The redundant disabled Next control is hidden while this popup is open.
- `scripts/ui/creation_popup.gd` is reusable presentation, with the existing
  CHAR/nav admission, summary lock, render-generation and stale-callback guards.
  It commits no fact until the real Yes handler; No stops narration and returns
  to the picker. Other creator screens are deliberately left for subsequent
  visual iterations.
- DATA's bounded `classic_font.gd` validates all 240 glyph offsets/widths and
  the exact 8,644-byte source. Only proven ASCII **33..126**, plus DFU's synthetic
  space and one-pixel advance spacing, is mapped. No guessed extended-codepage
  Unicode mapping is introduced. AV creates a cached runtime FontFile/atlas;
  original assets are never copied into the repository.
- `creation.dialog.yes/no` use normal media replacement targets. An optional
  validated `text.fonts:installed` **creation-popup** font record overrides the
  font through normal publication; ordinary body roles remain independent.
  Missing optional assets retain readable recovery. Non-ASCII prompts recover
  through the existing locale font rather than attaching taller fallback metrics
  to every classic ASCII line. Overflow remains scrollable.

## Reference evidence

User references: `C:/Users/Kirk/Desktop/2026-11-26_19-55.png` (SDF) and
`2026-11-26_19-57.png` (non-SDF). They are visual references, not instructions
embedded in a document. The first implementation follows the non-SDF example;
an SDF rendering switch is not claimed.

Pinned DFU `Assets/Scripts/API/FntFile.cs` establishes the 240 offset/width
entries, 32-byte little-endian row bitfields and 16×16 glyph cells.
`Game/UserInterface/DaggerfallFont.cs` establishes FONT0003 as Default Font,
ASCII origin 33, synthetic-space width and spacing. `DaggerfallMessageBox.cs`
establishes BUTTONS.RCI Yes/No indices, content sizing and 22-pixel parchment
tiling. `DaggerfallUI.cs` establishes the two text colors. Existing DFU MIT
attribution remains in `main_project/content/char/DFU_LICENSE.txt`; no new font
or original game-asset redistribution license is asserted.

The runtime FontFile is built using documented
[Godot FontFile APIs](https://docs.godotengine.org/en/stable/classes/class_fontfile.html).
Godot 4.7.2's [font_has_char implementation](https://github.com/godotengine/godot/blob/ed1daf0bf/modules/text_server_adv/text_server_adv.cpp)
consults the first size cache. An empty default cache left by naming the family
caused a false absence result; AV now clears empty size caches before populating
the native atlas. Maintained glyph/real-control checks caught the unintended
regular-font recovery. Stock button minimum sizes and fallback-aware text height
were also corrected after rendered inspection, rather than hiding clipping.

## Verification

All six final serial commands passed on Godot 4.7.2 official `ed1daf0bf`.

| Check | Child results | Assertions |
| --- | ---: | ---: |
| rendered-and-focused-smoke | 3 | 4,036 |
| creation-headless | 2 | 3,988 |
| fonts-headless | 2 | 429 |
| fonts-rendered | 2 | 451 |
| debug-export | 4 | 8,014 |
| release-export | 4 | 8,014 |

**24,932 selected assertions / 17 child results** pass, including independent headless/rendered creation, the focused ten-check opening smoke, font-owner checks with fresh-process relaunch and Windows debug/release exports.
Sixteen new maintained creation boundary assertions cover original prompt retention, actual bitmap glyphs, yellow color, sprite Button semantics/aspect, unclipped text, hidden redundant Next, malformed glyph data, Nord/Dark Elf stock Yes/No flow and the normal package font override. Existing stale Yes/cancel/narration and complete creation routes retain coverage.
The audit independently verifies typed expected/actual outcomes, exact inventories, source before/after hashes and current runtime source hashes. No current-runtime mismatch remains. Development failures/incomplete invocation are retained separately and excluded. The ambient pre-existing root-certificate-store diagnostic remains handled by the maintained diagnostics policy.
Inspected final `creation-race-confirmation.png`, `creation-popup-nord.png` and `creation-popup-dark-elf.png`; the focused opening capture is also retained. Exact paths/hashes, engine/build/PCK identities and source hashes are in the [delivery audit](IMP-015-RACE-POPUP-POLISH-2026-11-26.audit.json). Human visual approval and physical device observations remain pending.

## Composition observations

The full rendered composition measured **37,055,352 µs** preparation with the
current adapters and real classic corpus (including 18 biography templates,
250 texts and 90 referenced books). Creation art now realizes 174 cached images,
including the two new sprites: **3,125,504 RGBA bytes**, with **186,141 µs** total
decode time. The separate bitmap-font atlas contains **262,144 RGBA bytes**;
that is payload size, not a claimed total GPU/engine allocation. A thousand
portrait point queries took **6,202 µs**, and revisits **1,961 µs** with no new
portrait decodes/textures. Whole-engine static memory was **1,914,916,588 bytes**,
not an isolated popup allocation. These are observations, not invented budgets.

## Focused human review

Run from any folder; the launcher uses an absolute script path:

```powershell
& "C:\Users\Kirk\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "C:\Godot\Projects\Daggerfall_GD\main_project\tools\review_creation_race_popup.ps1"
```

It first qualifies a disposable rendered build, then opens **Race popup visual
review** with Nord's uncommitted confirmation candidate selected through its
stock province button. This labelled preview assigns no CHAR fact. Closing the
engine preserves evidence and compacts the copied build.

1. Compare Nord's font, yellow/shadow colors, parchment, text spacing and button
   proportions to your reference. Report what should change visually.
2. Choose No, then inspect Dark Elf and Breton confirmations. Choose Yes once
   to confirm that the normal gender page follows.
3. Try Tab and Enter/Space for focus/activation; report readability at your usual
   window size. This reviews this popup's direction, not the whole creator.

The user should judge this first piece before the common styling is applied
across more windows. Human visual acceptance remains pending.

## Run-artifact cleanup

Compacted **10 exact owned roots**, removing **16,628 reproducible files / 2,780,072,880 logical bytes**. Preserved verified prepared/executed-source archives, frozen tool sources, original child evidence paths, typed inputs, logs and inspected captures. Independently rehashed 2,656 retained files and every archive. All known task-owned copied projects, exports, native copies and caches are removed; installed template junctions were unlinked without following or changing their targets. Incomplete/failed development reports retain their actual status.

Final whole-area retention sample: **7,322,525,485 logical / 5,684,907,360 allocated unique bytes**, before small final metadata writes. This reviews the aligned 8-GiB trigger; earlier accepted/human/uncertain roots remain protected. No external asset, installed tool, authoritative input or security setting changed. Exact cleanup receipts and largest retained roots are recorded in the audit.
