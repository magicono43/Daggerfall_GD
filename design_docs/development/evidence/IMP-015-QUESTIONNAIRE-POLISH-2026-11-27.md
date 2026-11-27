# IMP-015 ten-question class presentation — 2026-11-27

User-requested fast-ui-polish pass. Started **4:30:35 PM EST**. Original class
selection/scoring and immutable draft boundaries remain authoritative; no live
character, reward or milestone acceptance is established by this visual work.

## Implementation

The class-method choice initializes the retained ten questions immediately.
The CHGN00I0 sky is followed by a native scroll at (0,120), with black bitmap
text, preserved source line breaks and a/b/c answer markers. Question/answer text
uses the existing FONT0003 path with no shadow. Holding either 16-pixel end moves
the clipped text and cycles sixteen original GFX frames. Mouse wheel and a/b/c
keyboard input are supported. Scrolling is bounded and stops on release, pointer
exit, focus loss or retirement. Held scrolling uses 60 native pixels/second,
independent of frame rate; DFU increments one pixel per rendered update.

Accepted answers invoke the existing CHAR edit, then play the matching original
CEL at its native position and timing. Input is locked against additional answers
during that animation. Palette slots 160/128/192 map to Rogue/Mage/Warrior, with
blue intensity 8 + 24 × current category score. Scores are recomputed from the
accepted answers, so revision does not accumulate obsolete weights. A replacement
mask is independent of the background image. Shader output is checked against
actual rendered pixel intensities, rather than assuming a color-space mapping.

Ignite uses the original `SoundClips.Ignite = 16` archive ordinal through the normal
audio resolver and existing host-owned one-shot lifetime. After animation, the
next question appears automatically. After question ten, the existing owner
recommendation opens the ordinary class confirmation. The result remains
uncommitted until Yes; No opens the full class picker including Custom. Previous/
Next question and explicit direct selection remain available as regular review
controls outside the art, preserving approved answer-revision functionality.
Back/review does not draw a new question set or grant a class.

## Formats, provenance and replacements

Read-only DFU evidence: CreateCharClassQuestions.cs, GfxFile.cs, FlcFile.cs,
FLCPlayer.cs and SoundClips.cs in the pinned reference tree. Recreation code is
GDScript and a canvas shader; no new runtime library or native adapter is added.
The existing FFmpeg native playback contract is not widened.

`creation_questionnaire_images.gd` handles only the bounded optional questionnaire
profile: eight 320×80 frames per GFX, and AF12 8-bit CEL with COLOR_256, BYTE_RUN,
DELTA_FLC and ignored postage-stamp chunks. Bounds, run progress, row extents,
frame/chunk extents, opcode counts and supported encodings are checked. CEL ring
frames are excluded from the displayed strip. Alpha follows DFU's RGB (0,0,10)
rule. These checks do not certify arbitrary FLI/FLC variants or general video.

Classic access permits only the two named scroll files, the three named CELs,
and the existing background through the active published source. Original files
remain external/read-only. New logical media targets use ordinary override
precedence:

- `creation.questionnaire.scroll`: a 320×1280 strip of sixteen 320×80 frames.
- `creation.questionnaire.rogue`, `.mage`, `.warrior`: vertical strips with frame
  height 119, at most 128 frames. Baselines have 10/15/15 frames and 71 ms/frame.
  Baseline timing is read from CEL; replacement strips use the baseline cadence
  if their media provenance supplies no timing. Native x positions are 1/79/110.
- `creation.questionnaire.mask`: 320×200 RGB category flags (Rogue/Mage/Warrior)
  plus alpha; a skin changing constellation geometry can replace the mask too.
- `creation.questionnaire.ignite`: optional audio.

Missing optional decoration does not block the question/answer owner. Images are
decoded and realized on demand, then cached by the existing application media
owner. Animation changes AtlasTexture regions; it does not re-decode frames or
rebuild the content catalog. All question identities, answer-category mappings,
retained outcomes, class-result mapping and content locking remain unchanged.

## Verification scope

Separate headless codec commands compare all pixels of all displayed CEL frames
with golden hashes from the already pinned FFmpeg executable. The golden fixture
records source hashes, normalized RGBA hashes, frame counts and delay. Transparency
normalization only clears alpha for RGB (0,0,10). No original media bytes are
committed. Malformed header, count, extent, RLE and truncated-row cases are also
checked. The FFmpeg tool is verification-only and introduces no new dependency.

Rendered checks use production requests and actual held mouse input, mouse answer
selection and keyboard a/b/c. They cover animation lockout, Ignite submissions,
held scroll/release, palette levels, revision, ten-question completion, both
confirmation routes, cancellation, stale callbacks and no premature actor creation.
Broader creator suites and Windows exports remain deferred to the combined polish
checkpoint. Human visual/audio acceptance is not inferred from these results.

## Reproduction

```powershell
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File 'C:/Godot/Projects/Daggerfall_GD/main_project/tools/preview_creation_gender.ps1' -Questionnaire
```

Add `-SmokeTest` for separate headless codec and rendered interaction checks, or
`-CloseTest` to close through production shutdown with an animation active.
Reports and captures retain their original `.runs` paths after compaction.

## Final results and cleanup

Completed **4:53:12 PM EST**, elapsed **22 minutes 37 seconds**.
Final run `verification-rendered-ac20076f32324320857354a5d4c75d7d` passed
**39 independent headless codec checks and 55 rendered interaction checks**.
The latter samples actual framebuffer pixels to verify native blue intensities
8 and 32. All three CEL strips match independent FFmpeg RGBA golden hashes across
every displayed frame. This does not imply physical-device listening or human
approval. Captures are retained under that root's
`project/tests/.runs/preview/storage/`, including class-questionnaire-initial.png,
class-questionnaire-scrolled.png, class-questionnaire-trail.png,
class-questionnaire-brighter.png and class-questionnaire-confirmation.png.

Production shutdown with an animation active passed **27 checks** in
`verification-rendered-ed0e0821ea3242999b300ef43ab1c252`, with no resource-leak
diagnostics. Earlier successful development runs retain their exact 45/45/53
rendered results. The initial failed import remains failed; it caught a missing
explicit Vector2 annotation before any review engine was launched.

All five successful copied builds automatically compacted. The exact inactive
failed root `verification-rendered-13a4f7de5318421d8634cf212bdd660e` was archived
and compacted after process/path/reparse/source checks, removing **209,950,649
copied-project bytes**; its disposable engine-local/roaming caches were also
removed with receipts. Failed logs and source evidence survive. Temporary raw
FFmpeg frames were removed; source/output hashes, executable identity, command
and normalized golden hashes remain in
`tests/.runs/questionnaire-codec-reference-2026-11-27/reference-receipt.json`.
No historical unrelated roots, original classic files or reference source were
changed. Final `git diff --check` passed. Changes remain uncommitted; broad
creator regressions and exports remain deferred to the combined checkpoint.
