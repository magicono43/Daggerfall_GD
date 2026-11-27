# IMP-015 — Classic list picker, class confirmation and biography choice

Started November 26, 2026 at 11:08:33 PM EST. The user requested this visual
iteration with fast-ui-polish and six DFU screenshots. Parent/increment acceptance,
entry/SAVE and named integration/milestone gates are unchanged.

## Presentation and input

`scripts/ui/classic_list_picker.gd` is reusable presentation with separate local
selection and activation signals. It uses the external original PICK00I0.IMG
(200×128), the established FONT0003 bitmap/optional creation-popup font override,
nine eight-pixel rows and a proportional Godot scrollbar styled to the classic
thumb. Original image supplies the frame, parchment, gold track and arrow art.
Arrow controls, wheel, thumb drag and keyboard navigation use real controls.
Whole-list locale font recovery and clipping retain readable modded labels.

Pinned DFU evidence: DaggerfallListPickerWindow.cs gives list (26,27,138,72),
up/down buttons (179,10,9,9)/(179,108,9,9), and scrollbar (181,23,5,82).
DaggerfallUI.cs supplies normal RGB (243,239,44), hovered (255,130,40), selected
(162,36,12), and selected/hovered (254,56,18). VerticalScrollBar.cs documents
the proportional thumb. The initial pass used a simple gray bordered thumb;
the follow-up below replaces it with the original sliced DFU artwork while
retaining Godot's native scrolling behavior.

Single click changes only presentation selection. Double left click or Enter
activates the selected row. Owner class commitment still requires Yes. No retains
highlight and scroll; Custom activation uses the existing validated career route.
The stock class page retains the Tamriel map behind the picker and confirmation.
Class confirmation reuses the classic parchment/Yes/No popup and original source
description; development mechanics annotations are removed from that dialog.
Questionnaire suggestions use the same confirmation; declining still opens the
direct list. Generation/context, busy, active and summary guards remain in place.

The existing two-choice texture presenter also renders biography method using
BUTN02I0.IMG (184×168), automatic rectangle (8,41,167,54), manual rectangle
(8,113,167,46), from pinned CreateCharChooseBio.cs. Both choices edit through
existing owner APIs and advance. The redundant Next is hidden on these pages.
No biography generation rules or authoritative class data change.

Both new images are explicit optional classic reader entries and registered
media targets `creation.list-picker` and `creation.biography-method`, preserving
normal MOD replacement precedence/provenance. Originals and references remain
read-only; no original binary is added. Existing ART_PAL.COL supplies the palette.

## Focused review

From any PowerShell folder:

```powershell
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File 'C:/Godot/Projects/Daggerfall_GD/main_project/tools/preview_creation_gender.ps1' -ClassPicker
```

Add `-SmokeTest` for the maintained focused route. This boots real stock providers
in disposable storage and enters via race, gender and class method controls.
It captures ordinary/selected/hovered states, confirmation and biography method,
and exercises mouse/keyboard handlers, No/Yes, retention, obsolete activation and
Custom. Source-copy fingerprints include the new scripts and source freshness
includes PICK00I0.IMG/BUTN02I0.IMG. Maintained broader career fixtures are updated
for double-click activation and the semantic Yes/No labels.

Full creation regressions and Windows exports remain deferred to the approved
combined presentation checkpoint. User visual acceptance and physical-device
testing are not inferred from automated input. Changes remain uncommitted.

## Result

Focused run `verification-rendered-6f95845f68894dfca65e7ef4172c6096` passed all
57 checks on Godot 4.7.2. This includes actual wheel input, scrollbar thumb drag,
Up/Down/End/Enter, single/double mouse clicks, uncommitted selections, retained
row/scroll after No, Yes commitment, obsolete activation rejection and both
biography methods. Current picker/hover, confirmation and biography screenshots
were visually reviewed, including the final confirmation capture. The copied
build/cache was compacted, removing 214,879,060 bytes.

The first iteration `verification-rendered-d8c50a53ca744925ba006237ecc9ca87`
correctly failed two assertions: invisible biography labels expanded button
widths beyond the original hit regions. Setting bitmap-sized hidden text and
clipping corrected it. Its report remains failed; source archive hashes were
verified and its closed disposable project was removed (209,776,150 bytes),
preserving original logs/results/captures and a development cleanup receipt.
The gray scrollbar was also reset to native width after applying its styles,
avoiding inherited stock minimum-size expansion; final native size is asserted.
`git diff --check` passed. Broader suites/exports remain deferred as above.
Completed at 11:17:20 PM EST, about nine minutes after the recorded start.

## Follow-up — picker audio and original scrollbar thumb

Started November 26 at 11:29:15 PM EST. User clarified that picker selection and
double-click/Enter activation **do not** make UI click sounds. These intents are
now silent; existing Yes/No and method-button feedback is retained. The focused
fixture explicitly counts zero UI-click submissions for mouse selection,
double-click activation and keyboard activation, including Custom.

Pinned `CreateCharClassSelect.cs` identifies `SoundClips.SelectClassDrums`,
archive ordinal **374**, played when a preset's confirmation opens. AV registers
optional replaceable `creation.class-drums`; the career view starts a separate
one-shot only on current preset activation, with normal creator cleanup and
natural completion. It does not replay on repaint or for Custom. No does not
interrupt it. The explicit ordinal selector avoids confusing a record ID with
an archive position. Original unsigned-PCM decoding and native 0-dB gain are
retained, without normalization or arbitrary attenuation. DFU's class path also
passes Settings.SoundVolume as an explicit one-shot scale, whereas the race path
uses its DaggerfallAudioSource wrapper; perceived relative loudness can therefore
depend on DFU's audio settings. Physical loudness matching remains user review.

Unmodified pinned DFU Resources/VScrollThumbTop, Body and Bottom PNGs (5×1 each)
are copied under `content/ui/classic/`, alongside upstream MIT license and source
SHA-256 provenance. AV combines these into an in-memory 5×3 atlas, registered as
replaceable `creation.scrollbar-thumb`. StyleBoxTexture keeps one native pixel
for the top/bottom slices and stretches the original body. This restores the
dark edge and muted center missing from the generic gray rectangle. Source files
and license are included in preview-copy freshness checks. Reference files remain
read-only; no external original game binary is added.

The first follow-up run `verification-rendered-9de8628df54b4e5fb2e4f1c3681c675c`
passed 72 checks and was compacted (214,890,194 bytes removed), but preceded the
user's correction of point 1 and is superseded for picker sound expectations.
Final verification below uses the clarified silent-selection behavior. Broad
regressions/exports remain deferred to the combined presentation checkpoint.

Final follow-up run `verification-rendered-8119b43c57304b46ab43f9701ebbe2f2`
passed all **72 focused checks**, including silent selection/activation, drums
ordinal 374 and single submission, uninterrupted drums after No, stale-callback
silence and Custom exclusion, original thumb atlas/style and retained wheel/drag
behavior. Authentic current captures were visually inspected. Copied build/cache
compacted (214,889,889 bytes removed); compact reports/logs/captures retained.
Completed at **11:35:01 PM EST**, about six minutes. Physical relative loudness
remains user review; changes are uncommitted.
