# IMP-015 increment 1 — controlled human review

**IMP-015 increment 1 accepted / increment-2 handoff, 2026-11-26:** Following PASS for all seven human checks, the user explicitly states, "I accept what you have done in increment 1" and requests a copy/paste prompt for increment 2. Increment 1 is accepted. The increment-2 Race and Career prompt is prepared in design_docs/development/handoffs/IMP-015-INCREMENT-2-PROMPT.txt; preparing it starts no implementation here. It carries the preference for close classic artwork/layout where practical and clarification of ambiguous visual choices. Comprehensive presentation polish remains increment 4. Parent IMP-015, increments 2–4, IMP-036, cinematics, native SAVE and M2/M3 remain open. Earlier acceptance-pending statements below are historical.

**IMP-015 increment 1 human review passed, 2026-11-26:** The user reports "1-7: Pass" for all seven controlled review checks. Human review is satisfied; formal increment acceptance remains a separate decision. The user notes that presentation is functional rather than final product quality. Full visual polish remains future work; this report does not accept final presentation, dispatch another increment or close parent IMP-015, IMP-036, native SAVE or M2/M3. Earlier human-results-pending statements below are historical.

Human results and acceptance are **pending**. Automated smoke is separate.
This review uses the production shell, CHAR draft/navigation and CORE request,
with conspicuously labelled assigned providers. It cannot create a playable
character, qualify real race/career/biography rules or apply starting grants.

From PowerShell, run the exact installed PowerShell 7 command:

```powershell
& "C:\Users\Kirk\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "C:\Godot\Projects\Daggerfall_GD\main_project\tools\review_creation.ps1" -ClassicSource "C:\Games\Daggerfall\arena2"
```

The launcher rebuilds/qualifies an isolated review, then opens it. No administrator
or persistent execution-policy change is needed. Use `-SmokeTest` only for the
automated four-check review smoke; that does not record human acceptance.

1. **Artwork, title and input.** Confirm the current step title and prominent
   CONTROLLED CREATION REVIEW label. There is no separate progress indicator.
   The race map and subsequent creation backgrounds use crisp original interface
   art. Tab/Shift+Tab and Enter/Space expose a visible focus border. Shrink/resize
   the window and use scrolling; controls and errors remain readable. If a
   physical controller is available, verify its configured Confirm/Back and
   directional focus. Report unavailable controller checks explicitly.
2. **Preset route.** Select `breton`, `female`, `list`, `class-16`, `manual`, then
   the assigned biography. Type a name and choose **Use name**, then the assigned
   face, attributes and skills, and `average` reflexes. Choose Next at each step.
   Confirm the final summary shows the chosen identity, candidate biography
   effects and assigned allocation breakdowns. Unimplemented portrait/roll
   mechanics are explicitly marked; no artificial portrait or live actor appears.
3. **Branches and retention.** Use Back/Next and revisit summary editors. Chosen
   facts, assigned values and biography results stay unchanged. Restart and try
   `questionnaire` (assigned ten-question result) and `custom` (assigned career),
   plus the `automatic` biography route. These are assigned interface fixtures,
   not actual scoring/generation/custom-career legality. Check their titles,
   readable fallback dialogs and the appropriate questionnaire/custom artwork.
4. **Summary restrictions.** Only Name, Face, Attributes, Skills and Reflexes
   offer direct summary editors. Changing a name with Use name updates the same
   draft. Back follows the chosen sequential path. After final review, earlier
   race/gender/class/biography selections are read-only and explain Restart;
   repeated Back does not become an upstream-edit bypass.
5. **Discard and input lifetime.** Restart returns to race with no old choices
   and no confirmation. Exit immediately discards and returns to the title menu.
   New Game starts fresh. Holding/repeating Confirm must not skip pages or
   reactivate an exited view. Escape/Back exits creation without a discard prompt.
   The independent living-session replacement consent policy remains CORE-owned.
6. **Submission and retry.** On a completed controlled summary, Begin Game must
   show the stock unavailable-entry explanation. No gameplay session, HUD,
   possessions, spells or quests are created. Duplicate Begin Game stays the same
   attempt; explicit Retry Begin Game retries the captured input. It remains
   unavailable. No developer defaults silently fill a missing real provider.
7. **Normal entry distinction and quit.** Exit the controlled review, then choose
   ordinary New Game. Its draft is not labelled controlled. Normal rich mechanics
   remain unavailable at their provider boundary, with Back/Restart/Exit usable;
   ordinary entry cannot borrow assigned review providers. Quit/window-close
   works through the existing shell. Report visual clipping, misleading baked
   labels, focus loss or unreadable fallback/errors with the step name.

Report numbered PASS/FAIL/unavailable results. User acceptance of this increment
is a separate decision; parent IMP-015, increments 2–4, IMP-036 entry/grants,
creation cinematics, native SAVE and M2/M3 remain open.
