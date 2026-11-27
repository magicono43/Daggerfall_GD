# IMP-015 — Custom-class completion warnings

Started November 27, 2026 at **9:00:23 AM EST** using fast-ui-polish. User supplied
missing-name/missing-skills DFU screenshots and requested the other invalid Exit
states. Existing CHAR completion rules, parent/increment and milestone gates
are unchanged. This pass presents owner-rejected completion outcomes.

## Source evidence and precedence

Pinned `CreateCharCustomClass.cs` checks four categories in order: empty name,
unfilled skills, undistributed attribute points and difficulty outside limits.
Read-only inspection of the indexed external TEXT.RSC identified the strings:

| Record | Presentation category |
| --- | --- |
| 301 | Name your character class before exiting. |
| 300 | Three primary, three major, and six minor skills must be selected before exiting. |
| 302 | Attribute arrow must equal zero before exiting. |
| 306 | Advancement dagger cannot be in the red; adjust advantages/disadvantages. |

The first two use the user's pictured wording. The latter two retain the source
wording in code. Existing project reputation-balance rejection also receives
its existing clear warning (source message 303). Original files remain read-only;
no source table/schema/publication change or binary asset copy is introduced.

## Implementation

`creation_custom_messages.gd` reads the current owner's evaluation errors and
remaining-point values **after** navigation rejects completion. It selects the
first category in DFU's order; it cannot grant readiness or change validation.
Whitespace-only names retain the existing stricter nonblank rule. Unknown or
additional owner errors retain their own explanation as fallback. Normal
creation text-catalog keys allow localized/replaced messages.

The existing parchment no-button notice presents the message over the sheet.
Click anywhere or Escape dismisses it without leaving the creator or changing
the candidate. Underlying controls, repeat gestures and toolbar Back respect
the modal; the debug error-list label is replaced by the popup. Native Exit
retains the standard click feedback. Visible pending name text still commits
through the normal owner edit before completion is checked.

## Focused review

```powershell
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File 'C:/Godot/Projects/Daggerfall_GD/main_project/tools/preview_creation_gender.ps1' -CustomExit
```

Click native Exit on the blank sheet, dismiss the warning, enter a name and try
again. `-SmokeTest` seeds isolated candidates through normal owner requests and
uses the real Exit/dismiss controls for each category, conflicting-error order,
candidate retention, pending-name commit and successful completion. This is
controlled candidate preparation, not a claim that every skill was entered by
hand in this fixture. `-CloseTest` closes the interactive branch with a live
class warning. Existing general custom-sheet and broader career fixtures are
updated to dismiss the new notice before their subsequent interactions.

Full suites/exports remain deferred to the combined presentation checkpoint.
Human visual acceptance is pending; changes remain uncommitted.

## Verification result

Completed **9:09:41 AM EST**, about nine minutes.

- Focused SmokeTest `verification-rendered-11ab3c0867a643c9880054110ef94e81`:
  **65 checks passed**, including warning precedence, all four original categories,
  reputation, whitespace-name handling, pending visible name, rejection retention
  and valid Exit advancement. Missing-name/skills captures were visually inspected.
  Executed product-source hashes independently still match the final code.
- Final interactive CloseTest `verification-rendered-50ebfbc8e7ac4b86b53077c628d3acc6`:
  **32 checks passed**, with a live custom completion warning, normal window-close
  handling and no leaked-object/resource-in-use diagnostics. The fixture's base
  was simplified to the shared mouse helper after the SmokeTest; scenario bodies
  and product code were unchanged, and this final fixture was freshly compiled.
- Both copied builds/caches were compacted (214,938,346 and 214,938,403 bytes
  removed), retaining source archives, reports/logs and reviewed captures.
- `git diff --check` passed. Updated broader custom-sheet/career fixtures are not
  claimed as run; broad suites/exports and human acceptance remain deferred/pending.
