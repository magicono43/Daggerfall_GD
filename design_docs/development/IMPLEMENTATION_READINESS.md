# Implementation readiness

**IMP-007 increment 2, 2026-11-20:** Explicitly authorized after increment-1
acceptance. Real required TEXT.RSC access, checked structured controls/variants,
explicit source mappings and pure read/selection boundaries are implemented and verified;
see [execution evidence](evidence/IMP-007-increment-2-2026-11-20.md).
Increment 2 awaits user acceptance and explicit continuation before increment 3.
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
