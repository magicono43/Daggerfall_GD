# IMP-011 increment 2 keyboard/mouse review

Human results, 2026-11-23: **checks 1-6 PASS**, explicitly reported by the user.
The agreed editor human checks are satisfied; increment 2 is ready for acceptance.
Formal increment acceptance is not inferred from check results. Automated/injected
checks remain separate. Physical
controller and changed-host IME qualification remain user-deferred to later M2.

The reviewed package metadata and preserved human evidence are at
`main_project/tests/.runs/imp011-binding-review-2026-11-23/`.
The inactive project/import payload has now been compacted; the following launch
instructions and checklist describe the reviewed build. Historical launch:
run `Launch.ps1` in PowerShell. After quitting, `Launch.ps1 -ResumeLast` reuses
that launch's disposable settings. Launching without the switch creates a fresh
root. No ordinary player settings or external classic data are used. The fixture
uses a controlled CORE readiness provider and the production input/settings/editor;
it supplies no room, movement, combat or camera. HUD visibility is observable in
the session shell; other unavailable action owners cannot demonstrate gameplay.

1. Confirm readable action selection, two keyboard/mouse and two controller slots,
   and the visible reserved recovery instructions. Scroll down to analog settings,
   Reset, Apply, Retry Save and Close. Keyboard focus should remain usable.
2. Select **Hud Toggle**, click its first keyboard slot, then press **E**. The
   opening click must not become the binding. Cancel/Close without applying;
   resume the session through Escape as needed. F7 still toggles the HUD label.
3. Reopen Controls through Pause → Settings → Controls. Capture E for Hud Toggle
   and Apply. Close Controls and other menus with Escape. A fresh E toggles the
   HUD once; F7 no longer does. A held assignment/Apply/close input must not cause
   an extra toggle on return. Release before checking a fresh press.
4. Reopen the editor, capture **W** for Hud Toggle and inspect the conflict with
   Forward. Cancel Assignment preserves the draft. Repeat and choose Replace:
   Forward's cleared slot must be visible on selecting Forward. Reset This Action
   on Forward must also require conflict resolution; cancel it. Reset All Controls
   is staged; Cancel/Close must preserve the effective E mapping from step 3.
5. Capture a slot and press Escape: capture ends without clearing or closing the
   controls screen. Clear is a separate staged operation. Apply a deliberate
   cleared Hud Toggle slot and confirm the unbound warning. Reset This Action,
   Apply, then confirm fresh F7 works again. Try a right Ctrl/Alt modifier or a
   modifier plus a mouse button; labels must show the chosen side. Alt-Tab during
   capture must cancel it without assigning an input.
6. Apply E for Hud Toggle again and adjust a deadzone. Quit through the stock Quit
   button and relaunch with `-ResumeLast`. The custom slot and deadzone should
   remain. The automated fixture separately checks failed writes, truthful unsaved
   feedback and Retry; do not alter filesystem permissions for this review.

Report PASS/FAIL by number, with the action/slot and observed result for failures.
No human PASS is inferred from fixture startup or automated capture checks.

Retention purpose: this outstanding review only. Review expiry **2026-11-30**, or
after results. Before removing reproducible project/import files, preserve all
`project/tests/.runs/review-*` settings, launch records and logs, plus human
screenshots/results. BUILD.json identifies the verified source and controlled seam.


## User results and closure - 2026-11-23

The user's response was: "1. Pass; 2. Pass; 3. Pass; 4. Pass; 5. Pass; 6. Pass".
This records successful keyboard/mouse editor visibility/navigation, staged Cancel,
effective remapping and fresh press, explicit conflict/reset choices, capture/clear/
modifier/focus recovery, and relaunch persistence according to the checklist above.
No additional human repetition is required for this agreed scope. Controller/IME
physical qualification remains deferred; no later gameplay integration is closed.

All human launch files, settings, logs and the reviewed BUILD/README/launcher
identity are preserved under the package's `human-evidence/`, with copy and
post-cleanup hashes in `human-build-cleanup.json`. `human-results.json` preserves
the user's reported outcomes. The review-only build retention need is fulfilled;
its reproducible project/import caches are removed. No authoritative source,
installed tool, external data or earlier unique human evidence was deleted.


Closure totals: 163 evidence files hash-verified; 1,368 reproducible files /
210,775,946 bytes removed. Measured `.runs` retention is 1,866,718,418 bytes
(about 1.74 GiB), below 2 GiB. `git diff --check` passes; changes remain uncommitted.


## Explicit user acceptance and next handoff - 2026-11-23

After reporting checks 1-6 PASS, the user explicitly stated: "I accept what you
have done in increment 2". **Increment 2 is user-accepted.** This supersedes the
formal-acceptance-pending statements above. The user requested an increment-3
implementation prompt for another chat; it is prepared at
`design_docs/development/handoffs/IMP-011-INCREMENT-3-PROMPT.txt`. Preparing that
prompt starts no view/cursor implementation in this chat. Accepted work remains
uncommitted at preparation; no commit or branch operation is performed. Physical
controller/IME deferrals and parent/real-provider gates retain their scope.
