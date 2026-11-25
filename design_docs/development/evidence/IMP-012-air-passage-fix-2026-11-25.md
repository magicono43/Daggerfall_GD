# IMP-012 increment 3 — human-found narrow-passage contact

**Accepted, 2026-11-25:** The user deemed increment 3 complete following all human checks passing; stair-jump feel tuning is deferred. See [acceptance](IMP-012-INCREMENT-3-ACCEPTANCE-2026-11-25.md). Earlier pending statements below describe historical checkpoints.


**Later human retest:** The user reports all steps PASS, including passage/Resume/Quit and checks 4–7. See [human results](IMP-012-INCREMENT-3-REVIEW-2026-11-25.md). Earlier pending statements below record the machine-delivery checkpoint. The additional tall-stair jump feel observation did not require a runtime change; formal increment acceptance remains separate.

Human checks **1–3 passed** on 2026-11-25. An additional jump into the 0.58 m
green passage entered an unrecoverable menu. The user clarified that the Quit
confirmation appeared but **Discard and Quit** did not close the program; Task
Manager was needed. Checks 4–7, passage/Quit retesting and acceptance remain pending.

## Reproduction and final correction

Protected human run: `verification-rendered-00e9af5caf3349acb8366778c82f1cc7`.
Its Player.log records air-contact owner recovery at 19:32:22 UTC; stderr contains
no engine exception. The launcher's exit-1 exception followed the forced close.
A separate copy of its three logs and SHA-256 manifest is retained at that root.

The automated route uses the same course, resolved Jump, SessionShell capsule and
real CHAR. It reproduced recovery near (-0.000001, 0.972055, -14.92628). Handling
two corner contacts independently could project motion back into the previously
contacted wall. Repeated slides retained tiny sideways/forward velocity, ultimately
reaching a short cast with no usable normal. MOVE retained flight debt and failed
closed; normal course collision should not have entered that recovery path.

The final change projects both residual displacement and velocity against the
witnessed contact planes within each swept air substep. When a new projection
would enter an earlier plane, their cross product supplies the shared crease.
At the narrow passage this removes blocked horizontal motion exactly while
preserving free vertical descent. Further planes must also admit the projection.
The bounded list contains at most four actual contacts; no timer or normal cache
survives the substep. Gravity still advances and floor support/landing still
require their real existing witnesses. Ground motion is unchanged.

No shape, collision margin, passage width, DATA tuning, damage formula, flight
history, owner gate or receipt semantics was weakened. There is no invented
normal, manual teleport, fatigue reset, debt erasure or special case for green
walls. The original air sweep remains intact. `_air_slide` is the only added
physical helper; its dot/cross tolerances are numerical, not gameplay tuning.

Maintained `air_contact_cases.gd` follows actual input through the course and checks
obstruction, landing, repeated 30/60/120 Hz pinch contacts, full capsule clearance,
walking away and stock recovery Quit through the preferences boundary. It is
included in both fixed inventories and exports: **928 headless / 929 rendered**,
plus 10 fresh-process checks per mode. The 32 new assertions were not weakened.

The review-only readout now hides whenever a menu or hold is visible. Rendered
review smoke checks pause and Quit-consent visibility and retains `review-quit.png`.

## Quit investigation

The stock recovery consent handler and teardown through failed preference saving
pass. A separate rendered probe restored the original defective physical code,
reproduced the original hold, injected actual GUI mouse clicks on Discard and
Quit, and reached **process exit 0**: phase `ready`, empty session, media shutdown
started. That probe has resource-leak warnings from its interrupted disposable
fixture coroutine; it is exit-path evidence, not leak-free qualification.
A separate failure to exit after Discard was not reproduced. The user must still
retest it; the collision correction and unobscured menu do not establish human
Quit acceptance.

## Development attempts and exclusions

An endpoint-only witness correction passed baseline headless/rendered checks but
failed the new passage assertions under the independently published 2 m/s cap.
It and the failed cap run are excluded from final qualification. Per-overlap,
paired-point, explicit body-recovery and subdivided-route experiments did not
cover every state and were removed. An isolated physics harness using the real
course and `_air_sweep` exposed the contact-projection root cause; the final
crease projection lands at both 2 and 40 m/s caps in that probe.

One initial full-suite attempt had a duplicate local fixture variable name and
failed compilation before gameplay. Diagnostic-only copies also had indentation
and type-inference parse failures; none counts as a pass. The final independent
DEV-014 inventories, reloads and exports must pass on the final source bytes.
The earlier increment-3 audit qualifies its historical sources only.

## Final verification

All **six final serial commands passed**, with **7,526 selected assertions**.
Counts include repeated selections, export modes, relaunches and the 18-check
review smoke; they are not unique-behavior counts. All 25 current critical source
hashes match every final execution. Exact commands, reports, source archives and
hashes are in the [follow-up audit](IMP-012-air-passage-fix-2026-11-25.audit.json).
The Quit capture was visually inspected: consent and both buttons are readable,
and the diagnostics are hidden. No human/increment acceptance is inferred.

| Selection | Assertions | Result |
| --- | ---: | --- |
| ground-cap-2-headless | 938 | PASS |
| ground-headless | 938 | PASS |
| ground-rendered | 939 | PASS |
| ground-export-debug | 1877 | PASS |
| ground-export-release | 1877 | PASS |
| ground-review-smoke | 957 | PASS |

The 5,000-update baseline samples measured 6,440,685 us headless / 6,442,035 us
rendered, versus 6,410,916 / 6,462,978 us before this fix. The 1,000 capability
queries measured 15,954 / 15,775 us, versus 18,167 / 16,616 us, with retained
records unchanged at 146. These are observations, not budgets. The helper adds
no DATA publication or catalog lookup; planes are bounded per air substep.

## Remaining human work

Relaunch using the command in the [review checklist](IMP-012-INCREMENT-3-REVIEW-2026-11-25.md).
First retry jumping at the narrower green walls: they must block passage while
you land and remain able to walk away. Check Escape, Resume and **Quit → Discard
and Quit**. Then finish checks 4–7. Checks 1–3 retain the reported passes. Named
real-provider/native SAVE, exhaustion/retirement, increment-4, parent IMP-012 and
M2 gates remain open.

## Cleanup and review state

The qualified and superseded automatic builds were compacted after terminal
engine inactivity and exact containment/link checks. Two journals record removal
of **17,976 reproducible files / 2,971,069,403 logical bytes**, retaining **202**
child development/verification reports, logs and captures. Six final executed
source archives remain beside their reports, along with the superseded-source
archives, compilation-failure subset and original reproduction source. The audit
records journal/archive hashes and relocated evidence paths.

The original human-test build is the one deliberately retained full build for
before/after comparison, with expiry at corrected human retest or retention review
on **2026-11-26**. Its three preserved logs still match their original hashes.
No external classic data, reference material, installed template/tool, unique
human input or unrelated run was deleted. Changes remain uncommitted; no branch,
commit, remote or history was changed. Final Git whitespace validation passes.

Post-cleanup non-following retention scan: **4,950,387,773 bytes / 91,237 files**
(about 4.61 GiB), below 8 GiB. Retention above 2 GiB was reviewed as earlier
protected evidence plus the original human build with the expiry above; no new
automatic verification project/export/cache remains. End: **2026-11-25 15:30:43 EST**.

Closed human-review builds were compacted after this PASS report and ordinary
engine inactivity. Their executed source and **all recorded human storage files**
are retained in per-root source/storage ZIPs; each storage entry was hash-verified.
Cleanup journal `main_project/tests/.runs/dungeon-cleanup-3e771c790ced4c3585c1606e3cd04f16.json`
records 4,889 reproducible files / 650,341,597 bytes removed and 81 retained child
reports/logs/captures. The original failed-build retention condition has now ended;
its earlier full-build retention statements are historical. No game code changed.
