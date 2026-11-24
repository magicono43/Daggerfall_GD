# IMP-016 increment 3 — review, 2026-11-24

This review covers the composed CHAR activity/collapse implementation. Final
qualification results are recorded in the [execution evidence](IMP-016-increment-3-2026-11-24.md)
and accompanying machine audit. Increment-3 user acceptance, increment 4, parent
IMP-016, M2 and named real-owner/native SAVE gates remain open.

## Behavior to review

| Scenario | Retained owner result |
| --- | --- |
| Standing with Run held | Ordinary rate 11; no Running practice |
| Actual voluntary Running, including mixed passive displacement | Rate 88; +1 raw Running per 0.25 eligible simulated seconds |
| Riding | No Running practice; fatigue follows explicit committed classification |
| Repeated actual jump/check/rappel callbacks | One charge/award per qualified identity; failed climbing checks award, failed/cancelled rappel positioning does not |
| Selected Swimming at skill 0/100 | Failure/success guaranteed by bounded check; rate 44/11 and +1 per completed selected minute |
| Effective Argonian context | Ordinary Swimming cost even after failure; normal cost/practice/check retention still applies |
| Safe collapse | Exactly one protected hour, ordered required-event settlement, capped recovery and +1 raw Medical |
| Completed hour: health 25, fatigue 0, magicka 81 | Actual post-recovery pools 27, 1160, 93 |
| Half-hour interruption or incomplete required events | Retain actual elapsed time; no unearned recovery/Medical |
| Zero maximum/recovery restriction | Retain incapacitation; no loop, minimum fatigue or automatic death |
| Fill after an unresolved episode | Pool changes do not resolve the episode; explicit checked owner resolution remains required |
| Swimming or genuine exhaustion-purpose threat | Normal lethal-owner handoff remains unavailable, with unchanged health and no safe-hour fallback |
| Controlled prevention leaving fatigue zero | Retain incapacitation without repeating lethal request/hour |
| Save/checkpoint reconstruction | Preserve current values, debt, checks, receipts and phases; no refill, reroll or replay |

All values are default data, with checked DATA/MOD/loose precedence. The per-
activity practice amounts, cap/cadence, rates/factors, recovery coefficients and
supported outcome choices are replaceable. No permanent advancement, training,
reward allocation, full rest UI or executable MOD runtime is added.

## Integration defects caught during review

The independent formula comparison fixture needed the three new activity hooks
declared in its scratch registry. Its full winner-map comparison remains intact;
the fix qualifies arrival-order behavior against the complete new composition.

Provider results now explicitly validate boolean status and operation revision
types. Numeric truth values or fractional revisions cannot authorize threat
classification or release an incapacitated episode. Required-event and episode
phase validation also prevents saved pending work from being presented as settled.

A new maintained counterexample captures eligible performed motion, acquires a
later producer-owned simulation/input/save hold, then asks CHAR to settle it.
The original current-gate check returned unavailable, leaving the expected drain
and practice unapplied. A disposable copy of the original production owner was
run with the new case; its sole failing assertion was `[false,-1,0]` versus
expected `[true,17,4]`. The corrected intake uses the TIME owner's retained
eligibility proof: owed work can settle while the later hold remains, and newly
claimed time under that hold is rejected. Exact retry cannot charge again.
Before/after source/fixture hashes and raw evidence are retained in `.runs`.

## Visual inspection

The production `activity_diagnostics.gd` surface reads the same composed owner.
The reviewed pending capture shows fatigue 0, phase `time-pending`, 30 committed
game minutes, one unresolved transition and Medical 0. The resolved capture shows
health 27, fatigue 1160, magicka 93, phase `resolved`, 60 committed game minutes,
zero unresolved transitions and Medical 1. The opaque diagnostic panel keeps
these facts readable over the actual shell. It is read-only and does not claim
UI-006, real MOVE/TIME/NPC production or a full story entry.

The final [pending capture](../../../main_project/tests/.runs/verification-rendered-78df01c1d74842d288bc7f1a960bdd32/evidence/project/scenario-1/activity-collapse-pending.png)
and [resolved capture](../../../main_project/tests/.runs/verification-rendered-78df01c1d74842d288bc7f1a960bdd32/evidence/project/scenario-1/activity-collapse-resolved.png)
were visually inspected. All ten final commands passed: **5,163 assertions**,
including 1,036 fresh-process assertions and both Windows export configurations
in headless/rendered modes. Exact commands, per-selection counts, performance
observations and source/build hashes are in the execution evidence and
[machine audit](IMP-016-increment-3-2026-11-24.audit.json).

## Remaining gates and observed limitation

Real committed locomotion/check producers, TIME catch-up/required-event owners,
effective trait/restriction providers, purpose-specific threats and prevention/
death remain named integrations. Supported breath entry/recovery is separate
from explicitly unavailable consumption/drowning cadences. Same-application/
scope checkpoints do not establish native SAVE or GAD-01 persistent identities.

One rendered process exited with native status `0xC0000374` during startup,
after its Intel UHD 630 D3D12 banner and before fixture storage/assertions. The
unchanged command retry passed. No cause was established and no renderer,
driver, security setting or toolchain was changed. The failed report remains
failed/incomplete and is excluded from passing totals.

Changes remain uncommitted for the user's GitHub Desktop review.
