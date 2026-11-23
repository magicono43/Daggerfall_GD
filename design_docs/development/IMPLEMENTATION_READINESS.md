# Implementation readiness

**IMP-011 complete and user-accepted, 2026-11-23:** The user explicitly accepted increment 3 and deemed IMP-011 completed after all six new human view checks passed. All three increments are accepted. Deferred physical controller/IME qualification, M2 and named real-provider joint checks remain open. At the user's request, the [IMP-061 increment-1 assembly prompt](handoffs/IMP-061-INCREMENT-1-PROMPT.txt) is prepared for another chat; issuing it authorizes that increment only, and preparation starts no implementation. IMP-008/010 documented prerequisites are accepted. Earlier IMP-011-open/acceptance-pending statements below are historical.

**IMP-011 increment 3 human review passed, 2026-11-23:** All six view/cursor keyboard/mouse checks are user-reported PASS. Increment 3 is ready for explicit acceptance; acceptance is not inferred. The menu-visible diagnostic readout is review-fixture-only. See [human results](evidence/IMP-011-VIEW-REVIEW-2026-11-23.md). Parent/provider gates and deferred physical qualifications remain open. Earlier human-review-pending statements below are historical.

**IMP-011 increment 3 implemented and automatically verified, 2026-11-23:** The issued destination prompt authorizes view/cursor work only. The production Camera3D/view owner, cursor handoffs, independent response settings, checked rays and scoped placement/gesture interfaces are implemented. See [execution evidence](evidence/IMP-011-increment-3-2026-11-23.md) for exact verification/source scopes and [new human review](evidence/IMP-011-VIEW-REVIEW-2026-11-23.md), which remains unperformed. Increments 1/2 remain explicitly user-accepted; physical controller/IME qualification remains user-deferred to later M2. Parent IMP-011/M2 and named real-provider gates remain open. Earlier unstarted/authorization-pending statements below are historical.

**IMP-011 increment 2 user-accepted, 2026-11-23:** The user explicitly stated, "I accept what you have done in increment 2", after all six keyboard/mouse editor checks passed. Increment 2 is accepted. At the user's request, the [increment-3 implementation prompt](handoffs/IMP-011-INCREMENT-3-PROMPT.txt) is prepared for another chat; preparing it starts no increment-3 implementation here. The destination prompt authorizes view/cursor work only when issued there. Preserve the latest tree and any uncommitted delivered work. Physical controller/IME qualification remains user-deferred to later M2; parent IMP-011/M2 and real-provider integrations remain open. Earlier increment-2 acceptance-pending statements below are historical.

**IMP-011 increment 2 human review passed, 2026-11-23:** The user reports PASS for all six keyboard/mouse binding-editor checks, including staged Cancel, effective HUD remapping, explicit conflict/reset handling, clear/capture/focus recovery and relaunch persistence. The automated and agreed human checks are satisfied; increment 2 is ready for acceptance, with formal acceptance not inferred from check results alone. See [human evidence](evidence/IMP-011-BINDING-REVIEW-2026-11-23.md). The inactive review payload is compacted after preserving human state/logs and build identity. Controller/IME physical qualification remains user-deferred to later M2. Parent IMP-011/M2 and real-provider gates remain open; increment 3 is not dispatched. Earlier human-review-pending statements below are historical.

**IMP-011 increment 2 implemented, 2026-11-23:** The current chat authorizes binding configuration only. Application-wide staged controls, explicit conflicts/reset/clear/capture, coherent effective application, independent persistence/retry, compatible recovery and stock controls UI are implemented and automatically verified. See [execution evidence](evidence/IMP-011-increment-2-2026-11-23.md) and the [keyboard/mouse review checklist](evidence/IMP-011-BINDING-REVIEW-2026-11-23.md). Engineering is ready for user review; no editor human PASS or increment-2 acceptance is inferred. Increment 1 remains user-accepted. Physical controller/IME qualification stays user-deferred to later M2; IMP-011/M2, real-provider integrations and increment 3 remain open. Earlier unstarted/authorization-pending statements below are historical.

**IMP-011 increment 1 user-accepted, 2026-11-23:** The user explicitly stated, "I accept what you have done in increment 1", and requested an increment-2 implementation prompt for another chat. The [handoff](handoffs/IMP-011-INCREMENT-2-PROMPT.txt) is prepared; no increment-2 implementation starts here. Controller/IME physical qualification remains user-deferred and untested until later M2. Parent IMP-011/M2 and real-provider gates remain open; increment 3 is not dispatched. Earlier acceptance-pending statements below are historical. See [acceptance evidence](evidence/IMP-011-KEYBOARD-REVIEW-2026-11-23.md).

**IMP-011 human review, 2026-11-23:** The user reports PASS for keyboard/mouse/focus checks 1–4, 6 and 7. Check 5's partial report is resolved as expected Space activation of focused Cancel, with zero gameplay edges in all 16 logged preflight intervals and new maintained UI-handoff coverage. Manual gates for the agreed increment-1 scope are satisfied; explicit user acceptance remains pending. Controller/IME physical qualification remains user-deferred and untested until later M2. See [human results](evidence/IMP-011-KEYBOARD-REVIEW-2026-11-23.md). No increment 2/3 or later task starts.

**IMP-011 manual-review scope, 2026-11-23:** The user explicitly defers physical controller and changed-host IME qualification until later M2; they remain untested and tracked, rather than increment-1 acceptance blockers. Keyboard/mouse/focus human review and explicit acceptance remain pending. A disposable review package and a rendered mouse-routing correction are recorded in [the review follow-up](evidence/IMP-011-KEYBOARD-REVIEW-2026-11-23.md). Increments 2/3 are unstarted.

**IMP-011 increment 1, 2026-11-22:** The current prompt authorizes logical delivery after accepted IMP-002/003 and M1. Production implementation and 117/118 headless/rendered action assertions are delivered; see [execution evidence](evidence/IMP-011-increment-1-2026-11-22.md) for final regression results and open physical checks. Awaiting user review; parent IMP-011 and M2 remain open, and increments 2/3 are not started. No later real-provider gate or downstream edge is closed. Earlier prerequisite/authorization waits for this increment are historical.

**M1 user-accepted, 2026-11-22:** The user explicitly stated, “In that case, I accept M1”. This accepts the audited M1 deliverables at `91f6898`, with the independent automated follow-up and all named human checks passed, including the tested Microsoft Japanese IME configuration. M1 is complete and accepted. Later real-provider checkpoints and untested IME/platform configurations remain in their documented scope. This acceptance starts no new implementation task. See [acceptance evidence](evidence/M1-ACCEPTANCE-FOLLOWUP-91f6898-2026-11-22.md). Earlier pending/readiness statements below are historical.

**Physical IME follow-up, 2026-11-22:** The user reports PASS on `91f6898 / m1-ime-review-v1` with Microsoft Japanese IME for candidate/hiragana Enter handling, separate single submission, Escape composition cancellation, Backspace, focus switching and English/glyph/candidate display. No unexpected behavior was reported. The tested local configuration is qualified; other IMEs/Windows configurations and later gameplay input-provider gates remain unqualified. M1 remains ready for acceptance. See [follow-up audit](evidence/M1-ACCEPTANCE-FOLLOWUP-91f6898-2026-11-22.md).

**M1 acceptance gates satisfied, 2026-11-22:** The user reports PASS on `91f6898 / m1-human-review-v1` for ordinary cold startup, folder-picker cancellation/invalid-source retry, keyboard navigation, remembered source, cinematic Apply/reopen/relaunch persistence, and blocked-root explicit fallback with marker retention. Together with independent automated verification, M1 is ready for acceptance; no verified blocking defect remains. Physical IME support remains unqualified and later real-provider gates remain open. Formal milestone acceptance and starting another task are separate. See [follow-up audit](evidence/M1-ACCEPTANCE-FOLLOWUP-91f6898-2026-11-22.md).

**Independent M1 acceptance follow-up, 2026-11-22:** Review of remediation commit `91f6898` verifies the original engineering fixes with fresh headless/rendered regressions and Windows debug/release exports. No new verified implementation defect was found. The user has not performed the required human checks; M1 remains open pending packaged startup/recovery, keyboard operation and cinematic preference reopen/relaunch results. See [follow-up audit](evidence/M1-ACCEPTANCE-FOLLOWUP-91f6898-2026-11-22.md). No next task starts.

**M1 audit remediation, 2026-11-22: engineering findings addressed; manual acceptance open.** The [follow-up evidence](evidence/M1-AUDIT-REMEDIATION-2026-11-22.md) records the corrected stock preference handoff, measured publication/query optimizations and maintained complete-composition gate. Independent headless/rendered regressions, qualification and Windows debug/release all-adapter PCK exports pass. Original timing failure and tolerances are preserved. M1 remains not ready pending applicable packaged startup/recovery and human input/preference checks. Accepted IMP-001–010 prerequisites remain accepted; no M2 implementation or new task starts.

**Original M1 integration audit, 2026-11-22: acceptance remains open.** The [audit](evidence/M1-INTEGRATION-AUDIT-2026-11-22.md) records fresh integration/project validation and distinguishes a verified P2 cinematic-preference defect from measured costs, coverage gaps and a non-reproduced timing observation. Ordinary all-adapter publication passed in editor probes and Windows PCK launches. Correct the defect, close applicable manual checks, and disposition the performance/coverage follow-ups before extending those paths. Accepted IMP-001–010 prerequisites remain delivered; planning READY and prerequisite clearance do not authorize the next task or certify M2 gameplay/SAVE.

**IMP-010 task user-accepted, 2026-11-22:** The user confirmed: "I also accept IMP-010 itself". IMP-010 is complete and accepted for its documented DATA scope: geographic records (`3b9e4bd`), layouts (`e324d54`) and variants (`c4d50e7`). Its DATA deliverable is an accepted prerequisite for dependent work; remaining prerequisites and task-specific real-provider joint checks still apply. WORLD/LOC/MOVE/QUEST/SAVE/CORE-opening integrations and M1 remain open. This acceptance authorizes no new task. Earlier statements leaving parent IMP-010 open are historical. See [task record](tasks/IMP-010.md) and [evidence](evidence/IMP-010-increment-3-2026-11-22.md).

**IMP-010 increment 3 user-accepted, 2026-11-22:** The user accepted the DATA variants implementation committed at `c4d50e7` (`Implementation Task 010, Part 3 Completed, 11-22-2026`): "I accept what you have done in increment 3." See [increment-3 evidence](evidence/IMP-010-increment-3-2026-11-22.md). All three assigned DATA increments are now accepted. Parent IMP-010, real WORLD/LOC/MOVE/QUEST/SAVE/CORE-opening integrations and M1 remain open; acceptance starts no further implementation and closes no named real-provider gate. Earlier pending-acceptance notes are historical.

**IMP-010 increment 3 implemented and verified, 2026-11-22:** DATA variant definitions, explicit scoped proposals and revision/scoped structural mapping checks are delivered. Independent 497/503 checks, 21-check fresh-process selections, Windows debug/release PCK exports and the named regressions pass; see [increment-3 evidence](evidence/IMP-010-increment-3-2026-11-22.md). Awaiting user acceptance. Increments 1/2 and the sole listed prerequisite IMP-005 remain accepted. Parent IMP-010, real WORLD/LOC/MOVE/QUEST/SAVE/CORE-opening integrations and M1 remain open; no prerequisite edge closes here. Earlier handoff and pending-acceptance notes below are historical.

**IMP-010 increment 2 accepted / increment-3 handoff, 2026-11-22:** The user accepted layouts at `e324d54` and requested a prompt for another chat. The [increment-3 prompt](handoffs/IMP-010-INCREMENT-3-PROMPT.txt) authorizes DATA variant definitions and scoped resolution when issued. Preparing it starts no increment-3 implementation. Increment 1 remains accepted; real WORLD/LOC/MOVE/QUEST/SAVE/CORE-opening, parent IMP-010 and M1 gates remain open. Earlier acceptance-pending notes below are historical.

**IMP-010 increment 2 implemented and verified, 2026-11-22:** Layout structures, explicit identities, scoped references and checked handoffs are delivered, including the user-authorized TEXTURE.210 decoder extension. Independent 369/372 layout checks, 15-check restarts, Windows debug/release exports and named regressions pass. See [increment-2 execution evidence](evidence/IMP-010-increment-2-2026-11-22.md). Awaiting user acceptance. Increment 1 remains accepted; variants, parent IMP-010 and named real-owner/M1 gates remain open. Earlier handoff statements below are historical.

**IMP-010 increment 1 accepted / increment-2 handoff, 2026-11-22:** The user
accepted geographic records at `3b9e4bd`. The [layout prompt](handoffs/IMP-010-INCREMENT-2-PROMPT.txt)
is prepared for another chat and authorizes increment 2 only when issued. No
layout/variant implementation starts here; parent IMP-010 and real-owner/physics/
SAVE/M1 gates remain open. Earlier pending-acceptance notes below are historical.

**IMP-010 increment 1 implemented/verified, 2026-11-22:** Geographic records await
user acceptance. See [execution evidence](evidence/IMP-010-increment-1-2026-11-22.md).
The sole prerequisite IMP-005 is accepted. Parent IMP-010, layouts/variants and
real-owner/physics/SAVE/M1 gates remain open. Earlier handoff-only notes are historical.

**IMP-009 reader delivery accepted / IMP-010 handoff, 2026-11-22:** The user
accepted increment 3, committed at `b33fa5a` (`Implementation Task 009, Part 3
Completed, 11-22-2026`). All three assigned IMP-009 reader increments are now
complete and user-accepted (`f9779c4`, `7e9947f`, `b33fa5a`). No additional reader
implementation or rerun is required merely to record acceptance. Named real-owner,
SAVE/CORE-012 and M1 integration/feature acceptance gates remain open; acceptance
does not certify gameplay usability or close those deferred checks. See
[evidence](evidence/IMP-009-increment-3-2026-11-22.md).
IMP-010's sole listed prerequisite, IMP-005, is already accepted. Its
[increment-1 prompt](handoffs/IMP-010-INCREMENT-1-PROMPT.txt) authorizes geographic
records only when issued to the receiving agent. Preparing this handoff starts
no IMP-010 implementation here. Layouts and variants retain later review gates.
Earlier review-pending and handoff-only statements below are historical.

**IMP-009 increment 3 execution, 2026-11-21–22:** The user issued the faction/quest
handoff. DATA-009/012 source adapters, explicit complete DFU profile, package/loose
resolution and checked validation handoffs are delivered for user review; the
132/134 source suites, affected regressions and Windows debug/release exports
passed. See [increment-3 evidence](evidence/IMP-009-increment-3-2026-11-22.md).
IMP-005 remains the accepted prerequisite; increments 1/2 remain accepted at
`f9779c4` / `7e9947f`. Real FACT/QUEST/SAVE/CORE-012, parent IMP-009 and M1 gates
remain open. This delivery starts no gameplay owner, migration or other IMP.
Earlier handoff-only and review-pending notes below are historical.

**2026-11-21 increment 2 accepted / increment 3 handoff:** The user explicitly
accepted increment 2 and requested a copy/paste prompt for another chat. The
accepted implementation is committed at `7e9947f` (`Implementation Task 009,
Part 2 Completed, 11-21-2026`). See [increment-2 evidence](evidence/IMP-009-increment-2-2026-11-21.md)
and the [increment-3 prompt](handoffs/IMP-009-INCREMENT-3-PROMPT.txt). Issuing that
prompt authorizes DATA-009/012 faction/quest input adapters only; preparing it
starts no increment-3 implementation here. IMP-005 remains the accepted listed
prerequisite. Standing PROJECT-DATA-D01 permits suitable original/DFU data and
routine corrections, prioritizing coherent modding support over exact vanilla
parity. Preserve uncommitted policy and handoff edits. Real-owner/SAVE, parent
IMP-009 and M1 gates remain open; earlier increment-2 review-pending notes below
are historical.

**IMP-009 increment 2 execution, 2026-11-21:** The issued prompt authorized only
DATA-010/011 items/spells. The user separately authorized an explicitly identified
DFU packaged item baseline and clarified consistency rather than exact original
parity. Structural adapters, contextual spell identities, complete checked owner
probes and DATA/MOD/CORE integration are delivered for review; verification and
source coverage are recorded in [increment-2 evidence](evidence/IMP-009-increment-2-2026-11-21.md).
Real ITEM/MAGIC/SAVE, increment 3, parent IMP-009 and M1 gates remain open. No
faction/quest reader or downstream gameplay implementation starts here. Earlier
increment-2 handoff-only statements below are historical.

**IMP-009 increment 1 accepted / increment 2 handoff, 2026-11-21:** The user
accepted increment 1, committed at `f9779c4`, and requested a copy/paste prompt
for another chat. See [accepted evidence](evidence/IMP-009-increment-1-biog-2026-11-21.md)
and the [increment-2 prompt](handoffs/IMP-009-INCREMENT-2-PROMPT.txt). Issuing the
prompt authorizes DATA-010/011 items/spells only; preparing it starts no implementation.
IMP-005 remains the accepted task prerequisite. No parent IMP-009, increment-3,
real ITEM/MAGIC/CHAR/NPC/SAVE, shared-feature or M1 gate is closed by this acceptance.
Earlier pending-acceptance and source-blocking notes are historical.


**BIOG correction authorized, 2026-11-21:** The user explicitly approved adopting
DFU's removal of the 12 observed standalone ampersand markers, without unrelated
biography changes. The correction is a source annotation, not an executable effect.
The complete selected installation now passes structural preparation/publication;
real-owner/semantic and M1 gates remain open. Increment 1 awaits final review;
parent IMP-009 and increments 2/3 are not complete. See
[BIOG/source qualification evidence](evidence/IMP-009-increment-1-biog-2026-11-21.md).
Earlier source-blocking notes are historical.


**Source-gate clarification, 2026-11-21:** The user clarified that duplicate flat
mappings must remain rejected without making the whole source file unavailable.
Known stock conflicts are now fingerprint-pinned diagnostic records, never
arbitrary winners. CLASS18 is preserved as City Watch source data with unresolved
skill interpretation, not rejected as a mandatory playable class. BIOG ampersand
interpretation remains blocking. See [follow-up evidence](evidence/IMP-009-increment-1-source-gates-2026-11-21.md).
Parent completion and real-owner/M1 gates remain open; earlier handoff notes are historical.


**IMP-009 increment 1 execution, 2026-11-21:** Actor/character structural readers
and existing DATA/MOD/CORE publication integration are implemented for review.
See [execution evidence](evidence/IMP-009-increment-1-2026-11-21.md). The selected
installation retains blocking flat ambiguity and unsupported class/BIOG inputs;
the user chose to leave the flat ambiguity blocking. Positive adapter/publication
checks use an explicit bounded compatible fixture. Real CHAR/NPC/effect, IMP-015/016,
SAVE and M1 gates remain open. No increment 2/3, parent completion or downstream
prerequisite acceptance is claimed. Earlier handoff preparation notes are historical.


**IMP-008 increment 3 accepted / IMP-009 handoff, 2026-11-21:** The user accepted
increment 3 (`7d88e99`); all three approved media implementation increments are
now delivered and user-accepted. See [accepted evidence](evidence/IMP-008-increment-3-2026-11-21.md).
The assigned implementation is complete; later real-owner/shared-feature/M1
checks remain open. IMP-009 requires accepted IMP-005, not those later media
integrations. Its [increment-1 prompt](handoffs/IMP-009-INCREMENT-1-PROMPT.txt)
starts only actor/character input readers when issued; no implementation starts
with this handoff preparation. Earlier pending-acceptance notes are historical.

**IMP-008 increment 3 execution, 2026-11-21:** The handoff was issued and native
MIDI/SF2/video implementation is Windows-verified and awaits user review. Independent
344/374 native inventories plus 11 reload checks, debug/release exports, DLL/PCK-bank
faults and all 54 audit selections pass. See [execution evidence](evidence/IMP-008-increment-3-2026-11-21.md).
User acceptance, parent/M1 and named real-owner integration gates remain open.

**IMP-008 increment 2 accepted / increment 3 handoff, 2026-11-21:** The user
explicitly accepted increment 2, committed at `09f6d2a`, and requested the
[increment-3 prompt](handoffs/IMP-008-INCREMENT-3-PROMPT.txt) for another chat.
See [acceptance evidence](evidence/IMP-008-increment-2-2026-11-20.md). Preparing
the prompt starts no implementation; issuing it authorizes increment 3 only.
Parent/shared-feature, unsupported-profile, native playback and real-owner/M1
gates remain open; no downstream prerequisite edge is automatically cleared.
The earlier execution and pending-acceptance notes below are historical.

**IMP-008 increment 2 execution, 2026-11-20:** The user issued the increment-2
handoff, authorizing only non-native media replacement/export resolution,
resource ownership/cache and pre-menu Content Diagnostics. The implementation
and verification completed on 2026-11-21 are recorded in [execution evidence](evidence/IMP-008-increment-2-2026-11-20.md)
and the [concrete contract](../../main_project/scripts/data/MEDIA_REPLACEMENTS.md).
User review/acceptance remains pending. Native playback/increment 3 has not begun;
no parent/shared-feature/downstream prerequisite or real-owner/M1 gate clears.
The earlier handoff and acceptance notes below remain historical.

**IMP-008 increment 1 accepted / increment 2 handoff, 2026-11-20:** The user
explicitly accepted increment 1, committed at `0cd8d56`, and requested the
[increment-2 prompt](handoffs/IMP-008-INCREMENT-2-PROMPT.txt) for another chat.
See [acceptance evidence](evidence/IMP-008-increment-1-2026-11-20.md). Preparing the
prompt starts no implementation; issuing it authorizes increment 2 only.
Parent/shared-feature, unsupported-format, native playback and real-owner/M1
gates remain open; no downstream prerequisite edge is automatically cleared.

**IMP-008 increment 1 execution, 2026-11-20:** The user issued the prepared handoff
and explicitly authorized classic adapters only. The bounded supported inventory
is implemented (119 headless / 136 rendered media checks; debug/release media
exports pass); affected regression/export audit and harness qualification pass. See [execution evidence](evidence/IMP-008-increment-1-2026-11-20.md).
User acceptance remains pending. Replacement/cache/native playback and shared
feature/real-owner/M1 gates remain open; no downstream edge is cleared.

**IMP-007 increment 4 acceptance / IMP-008 handoff, 2026-11-20:** The user accepted
increment 4 (commit `4df2656`); all four IMP-007 delivery increments are user-accepted.
See [execution/acceptance evidence](evidence/IMP-007-increment-4-2026-11-20.md).
The [IMP-008 classic-adapter handoff](handoffs/IMP-008-INCREMENT-1-PROMPT.txt) was
prepared for another chat and authorizes its first increment only when issued by
the user. Preparing it starts no implementation here. IMP-008's accepted IMP-005
prerequisite remains unchanged. Parent shared-feature/real-owner/M1 gates remain
open; no dependent prerequisite edge is automatically cleared by this update.

**IMP-007 increment 3, 2026-11-20:** Explicitly authorized after increment-2
acceptance (`dae3a56`). Fonts and live locale presentation are implemented and
verified (419 headless / 441 rendered; 10 relaunch assertions per mode/build;
Windows debug/release exports and affected regressions pass). See [execution evidence](evidence/IMP-007-increment-3-2026-11-20.md).
The user accepted increment 3 on 2026-11-20; implementation is committed at
`849d125`. An [increment-4 handoff](handoffs/IMP-007-INCREMENT-4-PROMPT.txt)
was prepared for another chat; implementation begins only when the user issues
that request. No increment-4 implementation begins here. Parent IMP-007/M1,
IMP-030/056 and real-owner gates remain open. No dependent edge or other IMP is
cleared/begun. Earlier acceptance/handoff notes retain history.

**IMP-007 increment 2, 2026-11-20:** Explicitly authorized after increment-1
acceptance. Real required TEXT.RSC access, checked structured controls/variants,
explicit source mappings and pure read/selection boundaries are implemented and verified;
see [execution evidence](evidence/IMP-007-increment-2-2026-11-20.md).
The user accepted increment 2 on 2026-11-20; implementation is committed at `dae3a56`.
An [increment-3 handoff](handoffs/IMP-007-INCREMENT-3-PROMPT.txt) was prepared for another chat;
no increment-3 implementation begins here. Increment 4 retains its acceptance gate.
Parent IMP-007/M1 and later real-owner/IMP-030/056 gates remain open; no dependent
edge clears and no other IMP is started. Earlier handoff-only notes retain history.

**IMP-007 increment 1, 2026-11-20:** Explicitly authorized; production catalogs,
CSV patches, fallback/provenance and bundled essential labels implemented and
verified ([evidence](evidence/IMP-007-increment-1-2026-11-20.md)).
The user accepted increment 1 on 2026-11-20 and requested an
[increment-2 handoff](handoffs/IMP-007-INCREMENT-2-PROMPT.txt) for another chat.
No increment-2 implementation began here. Parent task/M1 and later
IMP-030/056/real-owner gates stay open; no dependent edge clears yet.

**Final IMP-006 acceptance, 2026-11-20:** The user confirmed increment 3 complete;
all three assigned increments are accepted ([evidence](evidence/IMP-006-increment-3-2026-11-20.md)).
IMP-014 now has all listed prerequisites delivered. IMP-016/017/032 clear their
IMP-006 edge and retain other prerequisites. IMP-007 was already cleared by
IMP-005. Its requested handoff prompt is preparation, not implementation
authorization. No next IMP is started; remaining real-owner/M1/executable/SAVE
gates and the documented release limits are unchanged. Earlier notes are historical.


**IMP-006 increment 3, 2026-11-20:** The user accepted increment 2 and authorized
the bounded formula registry. All three assigned increments are implemented and
verified; [increment-3 evidence](evidence/IMP-006-increment-3-2026-11-20.md) records
real MOD/DATA/CORE integration, controlled providers, checks and release limits.
Final IMP-006 acceptance is pending. No dependent edge clears and no next IMP is
started. Production hook/executable/SAVE and named M1 real-owner gates remain open.
Earlier increment handoffs below retain their recorded acceptance context.


**IMP-006 increment 2, 2026-11-20:** The user accepted increment 1 and authorized
increment 2. Session isolation/lifetime and controlled retained-result integration
are implemented and verified; see [execution evidence](evidence/IMP-006-increment-2-2026-11-20.md).
Increment 2 awaits user acceptance. Increment 3 is not started. IMP-006 remains
partially delivered; no dependent prerequisite edge or real-owner/M1 gate clears.
Earlier handoff notes below retain their original acceptance context.


**IMP-006 increment 1, 2026-11-20:** Numeric implementation verified;
awaits user acceptance; see [execution evidence](evidence/IMP-006-increment-1-2026-11-20.md).
The separate acceptance gates for lifecycle and formula dispatch remain binding.
IMP-006 is not fully delivered and no dependent prerequisite edge clears.
Earlier authorization/readiness statements below retain historical context.


**All 12 register decisions are approved. The second audit confirms 64 READY, 0 BLOCKED and 0 NEEDS REVISION planning statuses.** Their implementation prerequisites still govern dispatch. Execution is tracked per task below; subsequent work requires authorization. The [second audit](PRE_IMPLEMENTATION_AUDIT_2.md) records the planning result; the [first audit](../archive/PRE_IMPLEMENTATION_AUDIT.md) retains the historical baseline. The [architecture register](../analysis/architecture/ARCHITECTURAL_DECISIONS.md#approved-decisions) governs cross-system policies and the [gameplay log](../design/GAMEPLAY_DECISIONS.md) governs approved behavior.

## Per-task review

Every [task card](TASK_BACKLOG.md) records planning and execution readiness separately, along with feature approvals, architecture references, direct prerequisites, interface decisions and acceptance scenarios. READY requires a verifiable task with resolved essentials. BLOCKED indicates a required design choice. NEEDS REVISION indicates a substantive defect in the handoff document. Execution also depends on completed implementation prerequisites, available fixtures and authorization.

| Check | Current result | Evidence needed to clear the gate |
| --- | --- | --- |
| Approved gameplay | Recorded for every assigned feature | Keep the approval IDs and review any conditional behavior or scope change against the owning specification. |
| Architecture decisions | GAD-01 through GAD-12 approved | Apply the linked decisions. Record any additional system-specific selection that materially affects the handoff. |
| Dependencies | Direct task edges identified and checked for cycles | Verify enabled runtime peers, fixture compatibility and prerequisite completion for the dispatch scope. |
| Interfaces | Owner, result, scope and failure handoffs defined on revised cards | Implement concrete APIs against these contracts and verify real consumers at named integration gates. |
| Acceptance | Observable scenarios identified on cards | Freeze applicable fixture inputs and exact expected outcomes, including tolerances, supported builds or data variants when relevant. |
| Verification | Automated and manual scenarios outlined | Name the production entry point, required fixture, and where evidence will be recorded. |
| Essential choices | Reviewed and selected within each approved task scope | Record concrete engineering parameters, dependency builds and fixture vectors alongside implementation. Escalate a material conflict with approved behavior. |

## Implementation sequence

**Final IMP-005 acceptance, 2026-11-20:** All three assigned increments are
user-accepted. IMP-007/008/009/010 are fully prerequisite-cleared; IMP-028/050 retain
their other prerequisites. IMP-006 already cleared IMP-003 and awaits explicit
implementation authorization. Providing an IMP-006 handoff prompt does not begin
that task. M1 and the documented later domain/executable/SAVE gates remain open.

**Execution update, 2026-11-20, increment 3:** IMP-005 increments 1/2 are accepted;
the authorized publication increment is implemented and independently checked
([evidence](evidence/IMP-005-increment-3-2026-11-20.md)). Its final acceptance remains
pending. Real candidate/publication/menu locks use bounded adapters, not invented
production schemas; M1 and later domain/executable/SAVE gates remain open. No
dependent prerequisite is marked delivered before final task acceptance.

**Execution update, 2026-11-20, increment 2:** IMP-005 increment 1 is user-accepted;
the separately authorized dependency planner is implemented
([evidence](evidence/IMP-005-increment-2-2026-11-20.md)). Increment 3 requires
another acceptance/continuation gate. Planning success is not DATA publication or
actual menu entry; M1 and full IMP-005 delivery remain open. No other task begins.

**Execution update, 2026-11-19:** The authorized IMP-001 startup increment is
complete; [execution evidence](evidence/IMP-001-2026-11-19.md) records the Windows
checks and open real-provider integrations. IMP-002's explicitly authorized
session/modal shell increment is now complete; its
[evidence](evidence/IMP-002-2026-11-19.md) records independent local suites and
remaining real-provider obligations. IMP-003's authorized shared verification
increment is complete ([evidence](evidence/IMP-003-2026-11-19.md)). IMP-004's
authorized Windows foundation reader increment is complete
([evidence](evidence/IMP-004-2026-11-19.md)). IMP-005, IMP-006 and IMP-011 now have
all listed prerequisites delivered and await authorization; IMP-022 still requires
IMP-017. Real package publication and later enabled adapters remain open.
No subsequent task was begun.

**Execution update, 2026-11-20:** IMP-005 increment 1 is authorized and implemented
([evidence](evidence/IMP-005-2026-11-20.md)); acceptance is pending. Discovery,
duplicate decisions and profiles are distinct from the still-unavailable planner
and DATA publication. Increment 2 requires acceptance/continuation authorization;
increment 3 retains its own gate. IMP-005's downstream edges and M1 remain open.

The user approved **GDScript for the main game, UI and tools**, with **C++ GDExtensions for native adapters**, on 2026-11-18. IMP-001 extended the existing Godot 4.7.2 project at `main_project/project.godot` with the startup entry point and storage/settings shell using this language split; project creation alone did not complete IMP-001. Luau restricted mods and trusted GDScript retain their separate approved runtime contracts.

1. IMP-001's minimum project entry and storage/settings shell is delivered using the approved Windows contract and isolated startup fixtures; retain its real-provider M1 checks.
2. IMP-002's session/modal shell and IMP-003's shared verification entry points are delivered after IMP-001; retain their named real-provider checks. Together these interfaces support real data/package preparation.
3. Follow the verified dependency waves in the second audit. Implement broad cards through their approved independently testable increments.
4. At M2, run the actual movement/combat/loot/save loop and the separate rendered timing/preview checks.
5. At M3, verify the approved opening queue/exterior tutorial, actual economy initialization, quest reward/fault retry and restore against real owners.
6. At M4/M5, close named later-provider assertions and required Windows exports. Preserve all approved conditional capability and authoring scope.

## Acceptance and execution gates

- All direct task edges are acyclic. Named staged joint checks remain required even where the providers develop separately.
- Approved schemas and formulas govern behavior. Pin actual source vectors, measured profiles, API representations and library builds with their implementation evidence.
- The cards' controlled-provider scenarios verify contracts. Milestones additionally require the actual enabled producers and consumers.
- Source-data availability, installed build tools and explicit authorization govern execution. Only IMP-001's recorded startup increment and exported startup checks are claimed complete; other implementations and exported capabilities retain their gates.
- If implementation reveals a material conflict with an approved gameplay or architecture contract, record the concrete conflict and resolve it before changing policy.
