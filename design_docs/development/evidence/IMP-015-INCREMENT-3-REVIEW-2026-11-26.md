# IMP-015 increment 3 — Human review

**Completed, 2026-11-26:** The user reports "Also, 1-9 are PASS" and explicitly
accepts increment 3. See [acceptance](IMP-015-INCREMENT-3-ACCEPTANCE-2026-11-26.md).
The pending-result language below records the original review request.

Machine qualification and visual review are recorded separately in
[execution evidence](IMP-015-increment-3-2026-11-26.md). Human results and explicit
increment acceptance remain pending. This does not close parent IMP-015,
increment 4, IMP-036, native SAVE or M2/M3.

## Rebuild and launch

From the repository root in PowerShell 7:

```powershell
./main_project/tools/review_creation_biography.ps1
```

The launcher performs a fresh rendered creation verification before opening its
disposable interactive build. It can take several minutes. Close the engine when
finished; the build is reproducible and is not needed as permanent evidence.
For an automated opening smoke only, add `-SmokeTest`.

The visible label is **BIOGRAPHY AND ROLLS REVIEW**. Race/career, biography,
attributes and skills are real production providers. Only name, portrait and
reflexes are assigned increment-4 inputs. There is no playable entry or live grant.
Interactive review uses the stock English biography. The automated creation
suite separately replaces the first Mage question with long French/CJK text to
test wrapping, scrolling and font recovery. That override is not installed by
interactive review or normal New Game.

## Numbered checks

1. **Presentation and input.** Choose a race/gender, direct Mage and Manual
   biography. Begin questions. Confirm the classic biography panel, English
   questions/answers, scrolling and keyboard focus. Back/Restart/Exit creation
   should appear above the artwork. Resize the window and verify the outer scroll
   keeps navigation reachable. Optional-art failure must still offer usable controls.
2. **Manual biography and disclosure.** Answer several questions. Read effects
   before selection. Select Knowledge/a book where offered, switch away and back.
   Known rewards/changes remain described; exact random book/cover/variant/quantity
   must not be disclosed. Read history and selected answers, revise a choice, and
   confirm history/effects update without accumulating old bonuses. No biography
   reroll or template picker should appear.
3. **Automatic route and retention.** With some manual answers retained, go Back
   to biography method and choose Automatic. Use the remaining-answer action, or
   Generate biography for a fresh route. Review/edit its answers. Back/Next and
   revisiting Automatic retain the template and existing choices; a completed set
   must not regenerate.
   Escape from questions also returns to biography method selection, retaining
   answers. Holding Escape must not open Pause or discard the draft.
4. **Attributes and slot.** Complete biography. Enter an assigned-review name and
   accept its assigned portrait input. Roll starting attributes. Spend/refund
   points and check the seven derived previews. Save a partially allocated roll,
   reroll several times, then Load Roll. The original baselines, allocation and
   pool return together. The slot survives rerolls. Next must reject unspent points.
5. **Skills.** Allocate all attribute points and continue. Roll skills once.
   Inspect rolled baseline, allocation, biography adjustment and final values,
   including other skills. Spend/refund from three separate pools; all must be
   spent. Other skills have no allocation controls. No skill Reroll/Save/Load exists.
6. **Backtracking isolation.** Record several skill baselines/allocations. Go back
   and change a biography answer, then return. Baselines/allocations remain; only
   the biography contribution changes. An attribute reroll must also preserve skills
   and biography. Pool balances remain visible while scrolling.
7. **Summary and captured retry.** Finish skills and the assigned reflex input.
   Summary shows readable history and known effects without exact hidden rewards.
   Only name, portrait, attributes, skills and reflexes have direct editors.
   Refund a point in an allocation editor: completion must block until restored.
   Sequential Back cannot edit biography/career after summary without Restart.
   Begin Game must truthfully report unavailable entry; Retry preserves the same
   captured intent and cannot enter a playable world.
8. **Discard and fresh input.** Restart. Answers, rewards, rolls, allocations and
   saved slot are cleared. Exit and reopen to confirm another fresh draft. Holding
   Enter through a page handoff must not repeatedly select, reroll or spend points.
   Report any physical controller/IME observations separately; they are not assumed
   to pass from keyboard automation.
9. **Custom route.** Restart and build a legal custom career with twelve distinct
   3/3/6 skills. Complete automatic biography and both allocation stages. Confirm
   the same retention, disclosure, pool and summary rules. Custom affinity uses
   equal skill overlap and the approved classic tie order, not tier weighting.

Please return results as `1: Pass/Fail … 9: Pass/Fail`, describe any problems, and
state separately whether you **accept IMP-015 increment 3** or want changes.
Acceptance of increment 2 remains recorded; no individual manual results are
inferred from that earlier acceptance.
