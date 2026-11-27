# IMP-015 increment 4 — Human presentation review

Human results and explicit acceptance are pending. This review uses production
providers for every creation choice. It assigns no name, face, reflex, biography,
career or allocation. Playable entry remains unavailable under IMP-036; no live
actors, possessions, spells, quests or rewards are created by the wizard.

From `C:\Godot\Projects\Daggerfall_GD`, run this in a PowerShell terminal:

```powershell
& "C:\Users\Kirk\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File ".\main_project\tools\review_creation_presentation.ps1"
```

The launcher first qualifies a disposable rendered build, then opens the labelled
review window. Interactive questions remain stock English. The ordinary window
close/Quit handlers work. After closing, allow the launcher to preserve evidence
and compact its copied build. Changes remain uncommitted for GitHub Desktop review.

1. **Overall presentation and preset route.** Choose a province, read/decline or
   accept its description, select gender and try the questionnaire/direct preset
   branches. Assess original art, parchment, readable controls, focus and flow
   against the DFU presentation you want. Report visual changes even if mechanics pass.
2. **Custom career.** Restart and create a custom career. Use the real attribute,
   tier, advantage/disadvantage and advancement editors. Check that the compact
   screen and nested controls remain usable. Complete a legal class and continue.
3. **Biography and history.** Try manual and automatic answers. Read the history,
   revisit answers and press Escape from biography: it should return to method
   selection with partial answers retained. Hold Escape briefly; it must not fall
   through into Pause or discard the draft. Questions should be English.
4. **Names and typing/paste.** Try surrounding spaces, punctuation, accents and
   combining marks. For a simple boundary, paste 31 letters, then 32. The latter
   must stay correctable without replacing the accepted name. A pasted line break
   must be rejected without silently joining two names. Markup such as `[b]Name`
   must remain literal. Unsupported glyphs may have a diagnostic/read-only preview;
   accepted Unicode must remain unchanged.
5. **Random names.** Click Random repeatedly, edit a suggestion and revisit the
   page. Only deliberate Random presses should generate names. Confirm that
   biography/history and allocations do not regenerate. Different suggestions
   are not guaranteed on every click; repeat names are valid.
6. **Portraits.** The first face requires an explicit Previous/Next choice.
   Browse the ten compatible faces in both directions and check wraparound.
   Revisit the page and later edit the face from summary; the chosen face should
   remain visible and selected. Restart to try other race/gender sets.
7. **Starting allocations.** Exercise attribute Reroll, Save Roll and Load Roll,
   allocate every point, then complete the three skill pools. Revisit and refund
   a point: completion should block until it is reassigned. Merely navigating
   must not reroll or create a second reward.
8. **Reflexes.** Confirm fresh Average, try all five settings and inspect the
   resolved combat/practice explanation. Return to the page and edit from summary.
   The selection should persist; it must not imply increased player movement,
   guaranteed hits or immediate permanent skill gains.
9. **Final review.** Review the actual name, portrait, reflexes, career, history,
   attributes and skills. Direct editors must be exactly name, face, attributes,
   skills and reflexes. Race/career/biography changes require Restart. Exact hidden
   biography rewards should remain hidden. Editing the name must preserve history.
10. **Introductory clips and honest handoff.** On summary, turn introductory
    videos off and choose Begin Game: entry must report unavailable while retaining
    choices. Retry retains the original submitted intent; editing now requires
    Restart. Restart and complete another character with videos enabled, then
    review their order and skip each with a fresh press. Holding a skip must not
    skip the next clip or activate another screen. The sequence ends with the same
    truthful unavailable-entry result; it must never claim gameplay has started.
11. **Window size and navigation.** Resize to 800×600 and 640×480. Check that art
    and controls fit horizontally and that scrolling reaches longer material.
    Back/Restart/Exit should remain above the artwork. Try keyboard focus and, if
    available, a physical controller. Report device-specific results separately.
12. **IME and discard.** If you use a physical IME, verify that Enter commits
    composition, then a separate press submits; IME Escape must not abandon the
    wizard. Otherwise report IME as unavailable, not PASS. Restart/Exit discard the
    unfinished character immediately; re-entry starts fresh with Average and no
    generated name or portrait.

Please report results for **1–12**, any presentation/feel changes, and physical
IME/controller checks as performed or unavailable. When satisfied, explicitly
accept **IMP-015 increment 4**. Passing this review does not automatically accept
parent IMP-015, IMP-036, native SAVE or a milestone.
