**User acceptance, 2026-11-26:** "Good work, I accept what you have done in increment 2". Increment 2 is accepted. Individual numbered human-test outcomes were not reported and are not inferred. Later increments, parent IMP-015 and integration/milestone gates remain open. Earlier pending-acceptance wording below is historical.

# IMP-015 increment 2 — Race and Career human review

Human results and acceptance are **pending**. This launcher uses production
race/gender, preset, questionnaire and custom-career mechanics. Later stages use
explicitly assigned review providers. It cannot qualify actual biography/affinity,
starting rolls, portrait selection, native SAVE, grants or playable entry.

Run from installed PowerShell 7:

```powershell
& "C:\Users\Kirk\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\powershell\pwsh.exe" -NoProfile -ExecutionPolicy Bypass -File "C:\Godot\Projects\Daggerfall_GD\main_project\tools\review_creation_career.ps1" -ClassicSource "C:\Games\Daggerfall\arena2"
```

The launcher builds/qualifies a disposable review, then opens it. No administrator
or persistent execution-policy change is needed. `-SmokeTest` performs automated
review smoke only; it does not record human results. The prominent label must say
**real race/career · assigned later stages · no playable entry or grants**.

1. **Race map and confirmation.** Select home provinces on the original map;
   accessible province buttons provide the same eight races. Unsupported map areas
   must not choose a race. Confirm original description and accurate benefits.
   No and Escape permit reselection without accepting the candidate. Yes opens
   Male/Female selection. Narration should stop on cancellation/navigation; missing
   optional narration is not a blocker. No racial attribute/gender modifiers are
   promised, and effective transformations are not creation choices.
2. **Presets.** Choose the direct route. All eighteen classes and Custom must be
   available. Inspect a magic and a martial class: description, actual skill tiers,
   equipment restrictions, special traits, spell-point multiplier, HP and advancement
   must be readable. No returns to the list; Yes accepts that career. Higher
   advancement means more practice, not multiplied rewards or guaranteed HP gains.
3. **Class questionnaire.** Restart and choose the questionnaire route. Start
   deliberately, answer all ten, move backward/forward and replace answers. The
   question set/order and recorded answers must remain unchanged on revisits.
   Incomplete answers cannot advance to an accepted recommendation. After ten,
   Next shows the actual suggested class and mechanics for Yes/No. No opens the
   class list including Custom. These are class questions, not biography questions.
4. **Custom chassis and name.** Choose Custom, then Open custom career. Starts
   are eight 50s, total 400; limits are 10–75. Redistribute and observe actual
   remaining budget. Temporary imbalance is editable but cannot complete. Try a
   nonblank Unicode class name, apply with Use name, Enter or Next, and verify retention.
   Whitespace alone cannot complete. No hidden pool-reset shortcut may bypass totals.
   Unapplied text must survive opening/closing a nested editor. If the installed
   font lacks a character (for example CJK under bundled English), the notice and
   read-only `?` preview must explain it while retaining the exact Unicode value;
   arbitrary Unicode glyph coverage is not claimed.
5. **Skills.** Assign exactly 3 Primary, 3 Major and 6 Minor. A chosen skill is
   unavailable in another slot. Replace a slot: the old skill becomes available,
   with no automatic swap. Incomplete/duplicate assignments cannot complete.
6. **Traits, HP and dagger.** Open Advantages/Disadvantages. Inspect subtype
   options and displayed costs; selecting a picker row alone must not charge it.
   Add, remove and cancel. Try matching Immunity/Weakness, Expertise/Forbidden
   Weaponry or Bonus to Hit/Phobia: the conflicting new option must be rejected
   with the old selection retained. Try a magery variant replacement without first
   removing its incumbent. Limits are seven per list. Change HP around 8 and
   inspect contributions, difficulty, advancement and dagger. Invalid difficulty
   remains editable and visible but cannot complete. Removal clears charges/state.
7. **Reputation.** Edit Merchants, Commoners, Scholars, Nobility and Underworld.
   Each supports −10..10 and the final sum must be zero. Imbalance is visible and
   blocks Next even from the nested panel; returning to the career cannot bypass it.
   Reputation changes must not alter difficulty or advancement.
8. **Retention and isolation.** Back/Next through compatible earlier selections.
   Custom name, attributes, skills, traits, HP and reputation remain. Switch to
   a preset and return to Custom before summary: the retained custom work returns,
   and the preset does not inherit custom traits. No possessions, spells, actor,
   faction changes or quests appear while editing.
9. **Explicit later-stage boundary and summary.** To reach review, choose the
   conspicuously assigned biography, portrait and allocation inputs; these do not
   prove real later mechanics or custom biography affinity. Inspect the summary's
   actual birth identity/career and assigned later facts. Only name, face,
   attributes, skills and reflexes have direct editors. Upstream edits require
   Restart, including after sequential Back. Begin Game reaches the real unavailable
   entry response; repeated Begin/Retry cannot create a live character or grants.
10. **Discard, input and presentation.** Restart/Exit discard immediately; ordinary
    New Game remains separate and stops at missing later providers. Escape during
    a pending race confirmation cancels that candidate; otherwise ordinary exit
    behavior remains. Held/repeated Confirm must not skip pages or revive discarded
    controls. Verify Tab/Shift+Tab, visible focus, resizing/scrolling and readable
    long text. If available, test physical controller Confirm/Back/directional focus.
    Report unavailable hardware checks, clipping, duplicate baked labels, incorrect
    hit regions or narration that outlives its candidate. Final comprehensive art
    acceptance remains increment 4.

Report numbered **PASS / FAIL / unavailable** results. Acceptance of increment 2
is a separate user decision. Parent IMP-015, increments 3–4, IMP-036, cinematics,
runtime effect/stacking integrations, native SAVE and M2/M3 remain open.
