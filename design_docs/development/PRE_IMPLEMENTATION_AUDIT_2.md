# Second pre-implementation readiness audit

Reviewed 2026-11-18 after the user reviewed all 64 IMP cards and approved their delivery breakdowns and intervening policy choices.

## Assessment

**All 64 tasks are planning READY.** No additional gameplay or cross-system architectural decision blocks the defined implementation scopes. IMP-001 is the first implementation candidate, subject to explicit implementation authorization and the target development environment. Later tasks also wait for their actual prerequisites.

This is a static documentation assessment. No recreation code, engine export, gameplay or acceptance suite was executed. READY means the card's behavior, owner handoff, verification approach and staged integration are sufficiently defined to begin its implementation. Concrete API names, fixture record selections, dependency versions, measured parameters and platform verification remain implementation deliverables where explicitly assigned.

The [first audit](PRE_IMPLEMENTATION_AUDIT.md) remains historical. Current statuses appear in [the backlog](TASK_BACKLOG.md) and [implementation readiness](IMPLEMENTATION_READINESS.md).

## Verified scope and consistency

| Audit question | Result |
| --- | --- |
| Approved feature coverage | All 432 approved feature IDs have a primary owner and matching approval record. |
| Missing or duplicate primary assignments | Zero. Shared integrations retain their single authoritative owners. |
| Excluded records | CORE-009, DEV-007 and DEV-008 remain deferred. CORE-014 and SAVE-018 remain outside current scope. |
| Task status | 64 READY. No BLOCKED or NEEDS REVISION cards remain after this review. |
| Prerequisites | All referenced IMPs exist. Cards and direct graph agree on 217 edges. |
| Cycles/order | Acyclic, with no prerequisite in a later milestone than its dependent. |
| Acceptance structure | Every card contains acceptance, automated and manual verification. Revised scenarios identify committed outcomes, rejection/retry behavior and real integration owners. |
| Architecture | All 12 GAD policies are approved and reflected by the current card handoffs and supporting contracts. |
| Documentation links | Local Markdown destinations and referenced headings in the current development set resolve. |
| Runtime evidence | Pending implementation. Documented tests are acceptance requirements. |

## Resolution of the first audit

| Original concern | Current resolution |
| --- | --- |
| Startup and storage handoff | IMP-001 defines selected root, process lease, settings outcomes and setup-provider routing. Windows first and future platform adapter boundaries are approved. Minimum recreation project/bootstrap is explicitly assigned to IMP-001. |
| Verification entry points | IMP-003 defines independent headless/rendered commands, disposable storage and reproducible pass/fail/incomplete results. M2/M3 retain the three production integration scenarios. |
| Oversized cards | User-approved increments and distinct checks now exist within the broad cards. Implement increments separately and keep the parent's named integration assertions open until actual providers pass. |
| First encounter | IMP-019/020 can develop against controlled owner inputs, with actual encounter closure before M2 and loot retrieval in IMP-021. |
| Restore participant ownership | IMP-023 orders exact-generation preflight, reconstruction, linking and completion. IMP-038/058/051 close actual quest/world, effect and mod payloads. Each domain writes its own facts. |
| M3 economy initialization | User approved the minimum ECON initializer in IMP-037. IMP-036 already depends on IMP-037. IMP-045 extends the same state without reinitialization. |
| Starting content | Class grants, conditional lighting items, immediate queue, exterior tutorial adaptation and owner initialization are approved in the startup content review. |
| Quest actions and recovery | IMP-028/029/030/031 define ordered execution, resource/custody, choices and initial M3 action set. Later verbs close with named providers. IMP-029 explicitly requires bounded pending acknowledgment and an exhaustion recovery fixture. |
| Exported executable capability | Luau restricted scripts and consent-gated GDScript trusted packages are approved. IMP-050 owns exported capability/activation evidence. IMP-051 integrates actual owner extensions. |
| Ship entitlement | IMP-040 depends on IMP-060. Both name actual visit, title, custody and concurrent-sale checks. |
| Shared tooling and state | Launch logging has one owner; inspection consumes quest facts; localization/package tools share runtime validators. |
| Generic scenarios | Revised cards specify observable state, identity, counts, no-duplicate behavior and the fixture family or source-defined oracle. Numerical values already selected remain in linked specs/contracts. |

## Architecture and responsibility findings

The revised contracts consistently separate CORE lifecycle, DATA definitions, MOVE physical state, CHAR actor/vital state, ITEM custody, MAGIC effects, QUEST runtime facts, FACT politics, LAW legal state and ECON settlement. UI/AV consume projections and classified results. SAVE coordinates owner records inside the approved generation bundle.

GAD-01's branch-local typed identity is reflected in IMP-017's decimal-string 64-bit counter representation. GAD-03's requester-owned gates remain binding at entry/load. GAD-04's bundle/catalog protocol is defined in IMP-022. GAD-05/06 clock and RNG rules are reflected in IMP-014 and the randomness contract. GAD-07/09/11 geometry, combat and presentation contracts retain scoped readiness and simulation-based commitment. GAD-08/10/12 settlement, publication and verification contracts retain explicit outcomes and staged provider checks.

Controlled providers are implementation fixtures. They cannot validate production content whose required real behavior is missing. Each corresponding live integration remains a parent or milestone acceptance obligation. Source-adapter readiness does not imply full grammar, effect, service or script runtime readiness.

## Remaining implementation work and capability gates

After this audit, the user confirmed GDScript for the main game/UI/tools and C++ GDExtensions for native adapters on 2026-11-18. This closes the language clarification subsequently recorded during AGENTS.md preparation. IMP-001 and the root instructions reflect the selection.

- **Bootstrap and entry.** Create the minimal Godot 4.7.2 recreation project under IMP-001, then deliver session composition and test commands. Original DFU remains a reference.
- **Concrete engineering data.** Record parser schemas, selected source records, expected decoded values, parameter profiles and actual APIs with each implementation increment. The approved rules and source-derived formulas are the oracle. If a choice changes behavior or cannot satisfy an approved rule, bring the specific conflict for review.
- **Windows durability.** Prove process-held root exclusion and settings/save publication recovery with two-process and interrupted-operation fixtures. A documented protocol alone is insufficient acceptance evidence.
- **Media/export dependencies.** Pin actual FluidSynth/FFmpeg/Luau builds and distribution metadata, default SoundFont provenance and capability profiles. Run the approved Windows export matrices. Backend selection is settled; actual compatibility remains an acceptance gate.
- **Staged integration.** Track criterion closure for fixture-only paths when real providers arrive, including door/equipment/effect restore, quest rewards and fault retry, property/travel and executable extensions.
- **Environment and execution.** Verify the installed Godot target and build prerequisites before running implementation work. Authorization is pending. No network download or dependency installation was performed in this planning review.

These are assigned implementation and verification obligations. The audit established no additional unowned task or policy question.

## Milestone assessment

M1 supplies an operational recovery shell, validated data-only content and reproducible test commands. It is the technical foundation. M2 delivers the approved development-fixture loop of movement, melee, loot and native save/restore. M3 adds actual character creation, starting grants/opening content, settlement/site exploration and quest/reward/restore. Its economy initializer now has an explicit owner and dependency. M4 extends that playable loop with alternate movement, conditions, services, legal/economic activity and travel. M5 supplies exported extensions and authoring validation, preserving approved feasibility clauses.

A milestone is accepted through actual integrated behavior and required test results. Passing a controlled-provider fixture does not close its live counterpart.

## Verified implementation order

Each group is a dependency wave within its milestone. Entries are IMP suffixes. Tasks within a wave may proceed concurrently after compatible shared interfaces and fixtures exist. Live collaboration checks still gate the milestone.

- **M1** — 001 → 002, 003 → 004, 006 → 005 → 007, 008, 009, 010
- **M2** — 011, 014, 016, 017, 024, 061 → 013, 015, 018, 022 → 012 → 019, 020 → 021 → 023
- **M3** — 025, 028, 032, 033 → 027, 035, 057, 058, 062 → 026, 034, 037 → 029 → 030 → 031 → 038 → 036
- **M4** — 039, 041, 042 → 043, 047, 049, 064 → 063 → 044, 045 → 048, 060 → 040 → 046, 059
- **M5** — 050, 052, 054 → 051, 053 → 055, 056

IMP numbering is a stable identifier rather than a dispatch order. For example, dungeon layout IMP-061 precedes location assembly IMP-013, and effect-engine IMP-058 precedes concrete families IMP-034.

## Recommended first task

Begin with [IMP-001](tasks/IMP-001.md), after explicit implementation authorization. Its root selection, settings/logging and independent recovery entry point provide the prerequisite for IMP-002 and IMP-003. Use isolated test storage from the first run. Record acceptance evidence and then release the two successors.

## Per-task planning and execution distinction

Every task below is planning READY. No prerequisite is claimed implemented. Execution requires authorization, a usable environment and delivered prerequisites. The table lists direct prerequisites only; staged live integration remains defined by each card.

| Task | Planning | Direct implementation prerequisites |
| --- | --- | --- |
| [IMP-001](tasks/IMP-001.md) | READY | None |
| [IMP-002](tasks/IMP-002.md) | READY | [IMP-001](tasks/IMP-001.md) |
| [IMP-003](tasks/IMP-003.md) | READY | [IMP-001](tasks/IMP-001.md) |
| [IMP-004](tasks/IMP-004.md) | READY | [IMP-001](tasks/IMP-001.md), [IMP-003](tasks/IMP-003.md) |
| [IMP-005](tasks/IMP-005.md) | READY | [IMP-002](tasks/IMP-002.md), [IMP-004](tasks/IMP-004.md) |
| [IMP-006](tasks/IMP-006.md) | READY | [IMP-003](tasks/IMP-003.md) |
| [IMP-007](tasks/IMP-007.md) | READY | [IMP-005](tasks/IMP-005.md) |
| [IMP-008](tasks/IMP-008.md) | READY | [IMP-005](tasks/IMP-005.md) |
| [IMP-009](tasks/IMP-009.md) | READY | [IMP-005](tasks/IMP-005.md) |
| [IMP-010](tasks/IMP-010.md) | READY | [IMP-005](tasks/IMP-005.md) |
| [IMP-011](tasks/IMP-011.md) | READY | [IMP-002](tasks/IMP-002.md), [IMP-003](tasks/IMP-003.md) |
| [IMP-012](tasks/IMP-012.md) | READY | [IMP-011](tasks/IMP-011.md), [IMP-013](tasks/IMP-013.md), [IMP-016](tasks/IMP-016.md) |
| [IMP-013](tasks/IMP-013.md) | READY | [IMP-002](tasks/IMP-002.md), [IMP-008](tasks/IMP-008.md), [IMP-010](tasks/IMP-010.md), [IMP-061](tasks/IMP-061.md) |
| [IMP-014](tasks/IMP-014.md) | READY | [IMP-002](tasks/IMP-002.md), [IMP-006](tasks/IMP-006.md) |
| [IMP-015](tasks/IMP-015.md) | READY | [IMP-007](tasks/IMP-007.md), [IMP-009](tasks/IMP-009.md), [IMP-016](tasks/IMP-016.md) |
| [IMP-016](tasks/IMP-016.md) | READY | [IMP-006](tasks/IMP-006.md), [IMP-009](tasks/IMP-009.md) |
| [IMP-017](tasks/IMP-017.md) | READY | [IMP-006](tasks/IMP-006.md), [IMP-009](tasks/IMP-009.md) |
| [IMP-018](tasks/IMP-018.md) | READY | [IMP-016](tasks/IMP-016.md), [IMP-017](tasks/IMP-017.md) |
| [IMP-019](tasks/IMP-019.md) | READY | [IMP-011](tasks/IMP-011.md), [IMP-012](tasks/IMP-012.md), [IMP-018](tasks/IMP-018.md) |
| [IMP-020](tasks/IMP-020.md) | READY | [IMP-012](tasks/IMP-012.md), [IMP-014](tasks/IMP-014.md), [IMP-016](tasks/IMP-016.md), [IMP-018](tasks/IMP-018.md) |
| [IMP-021](tasks/IMP-021.md) | READY | [IMP-013](tasks/IMP-013.md), [IMP-017](tasks/IMP-017.md), [IMP-019](tasks/IMP-019.md), [IMP-020](tasks/IMP-020.md) |
| [IMP-022](tasks/IMP-022.md) | READY | [IMP-002](tasks/IMP-002.md), [IMP-003](tasks/IMP-003.md), [IMP-017](tasks/IMP-017.md) |
| [IMP-023](tasks/IMP-023.md) | READY | [IMP-013](tasks/IMP-013.md), [IMP-019](tasks/IMP-019.md), [IMP-021](tasks/IMP-021.md), [IMP-022](tasks/IMP-022.md), [IMP-024](tasks/IMP-024.md) |
| [IMP-024](tasks/IMP-024.md) | READY | [IMP-002](tasks/IMP-002.md), [IMP-007](tasks/IMP-007.md), [IMP-008](tasks/IMP-008.md) |
| [IMP-025](tasks/IMP-025.md) | READY | [IMP-010](tasks/IMP-010.md), [IMP-012](tasks/IMP-012.md), [IMP-013](tasks/IMP-013.md), [IMP-020](tasks/IMP-020.md), [IMP-024](tasks/IMP-024.md) |
| [IMP-026](tasks/IMP-026.md) | READY | [IMP-023](tasks/IMP-023.md), [IMP-025](tasks/IMP-025.md), [IMP-057](tasks/IMP-057.md) |
| [IMP-027](tasks/IMP-027.md) | READY | [IMP-007](tasks/IMP-007.md), [IMP-013](tasks/IMP-013.md), [IMP-025](tasks/IMP-025.md) |
| [IMP-028](tasks/IMP-028.md) | READY | [IMP-005](tasks/IMP-005.md), [IMP-009](tasks/IMP-009.md), [IMP-014](tasks/IMP-014.md) |
| [IMP-029](tasks/IMP-029.md) | READY | [IMP-021](tasks/IMP-021.md), [IMP-026](tasks/IMP-026.md), [IMP-027](tasks/IMP-027.md), [IMP-028](tasks/IMP-028.md) |
| [IMP-030](tasks/IMP-030.md) | READY | [IMP-007](tasks/IMP-007.md), [IMP-027](tasks/IMP-027.md), [IMP-029](tasks/IMP-029.md), [IMP-032](tasks/IMP-032.md) |
| [IMP-031](tasks/IMP-031.md) | READY | [IMP-029](tasks/IMP-029.md), [IMP-030](tasks/IMP-030.md), [IMP-032](tasks/IMP-032.md), [IMP-037](tasks/IMP-037.md) |
| [IMP-032](tasks/IMP-032.md) | READY | [IMP-006](tasks/IMP-006.md), [IMP-009](tasks/IMP-009.md), [IMP-014](tasks/IMP-014.md), [IMP-016](tasks/IMP-016.md) |
| [IMP-033](tasks/IMP-033.md) | READY | [IMP-007](tasks/IMP-007.md), [IMP-014](tasks/IMP-014.md), [IMP-018](tasks/IMP-018.md), [IMP-019](tasks/IMP-019.md) |
| [IMP-034](tasks/IMP-034.md) | READY | [IMP-033](tasks/IMP-033.md), [IMP-058](tasks/IMP-058.md) |
| [IMP-035](tasks/IMP-035.md) | READY | [IMP-008](tasks/IMP-008.md), [IMP-014](tasks/IMP-014.md), [IMP-024](tasks/IMP-024.md), [IMP-025](tasks/IMP-025.md) |
| [IMP-036](tasks/IMP-036.md) | READY | [IMP-015](tasks/IMP-015.md), [IMP-023](tasks/IMP-023.md), [IMP-029](tasks/IMP-029.md), [IMP-030](tasks/IMP-030.md), [IMP-032](tasks/IMP-032.md), [IMP-033](tasks/IMP-033.md), [IMP-035](tasks/IMP-035.md), [IMP-037](tasks/IMP-037.md), [IMP-038](tasks/IMP-038.md), [IMP-058](tasks/IMP-058.md), [IMP-062](tasks/IMP-062.md) |
| [IMP-037](tasks/IMP-037.md) | READY | [IMP-017](tasks/IMP-017.md), [IMP-027](tasks/IMP-027.md), [IMP-032](tasks/IMP-032.md), [IMP-062](tasks/IMP-062.md) |
| [IMP-038](tasks/IMP-038.md) | READY | [IMP-023](tasks/IMP-023.md), [IMP-026](tasks/IMP-026.md), [IMP-029](tasks/IMP-029.md), [IMP-030](tasks/IMP-030.md), [IMP-031](tasks/IMP-031.md), [IMP-032](tasks/IMP-032.md) |
| [IMP-039](tasks/IMP-039.md) | READY | [IMP-014](tasks/IMP-014.md), [IMP-019](tasks/IMP-019.md), [IMP-023](tasks/IMP-023.md), [IMP-033](tasks/IMP-033.md), [IMP-058](tasks/IMP-058.md) |
| [IMP-040](tasks/IMP-040.md) | READY | [IMP-012](tasks/IMP-012.md), [IMP-025](tasks/IMP-025.md), [IMP-033](tasks/IMP-033.md), [IMP-060](tasks/IMP-060.md) |
| [IMP-041](tasks/IMP-041.md) | READY | [IMP-019](tasks/IMP-019.md), [IMP-020](tasks/IMP-020.md), [IMP-033](tasks/IMP-033.md), [IMP-058](tasks/IMP-058.md) |
| [IMP-042](tasks/IMP-042.md) | READY | [IMP-013](tasks/IMP-013.md), [IMP-019](tasks/IMP-019.md), [IMP-023](tasks/IMP-023.md), [IMP-033](tasks/IMP-033.md), [IMP-058](tasks/IMP-058.md) |
| [IMP-043](tasks/IMP-043.md) | READY | [IMP-019](tasks/IMP-019.md), [IMP-020](tasks/IMP-020.md), [IMP-027](tasks/IMP-027.md), [IMP-032](tasks/IMP-032.md), [IMP-037](tasks/IMP-037.md), [IMP-042](tasks/IMP-042.md) |
| [IMP-044](tasks/IMP-044.md) | READY | [IMP-023](tasks/IMP-023.md), [IMP-039](tasks/IMP-039.md), [IMP-043](tasks/IMP-043.md), [IMP-063](tasks/IMP-063.md) |
| [IMP-045](tasks/IMP-045.md) | READY | [IMP-014](tasks/IMP-014.md), [IMP-023](tasks/IMP-023.md), [IMP-037](tasks/IMP-037.md), [IMP-043](tasks/IMP-043.md), [IMP-063](tasks/IMP-063.md) |
| [IMP-046](tasks/IMP-046.md) | READY | [IMP-034](tasks/IMP-034.md), [IMP-037](tasks/IMP-037.md), [IMP-039](tasks/IMP-039.md), [IMP-040](tasks/IMP-040.md), [IMP-045](tasks/IMP-045.md), [IMP-047](tasks/IMP-047.md), [IMP-060](tasks/IMP-060.md) |
| [IMP-047](tasks/IMP-047.md) | READY | [IMP-033](tasks/IMP-033.md), [IMP-034](tasks/IMP-034.md), [IMP-042](tasks/IMP-042.md) |
| [IMP-048](tasks/IMP-048.md) | READY | [IMP-034](tasks/IMP-034.md), [IMP-039](tasks/IMP-039.md), [IMP-044](tasks/IMP-044.md), [IMP-058](tasks/IMP-058.md) |
| [IMP-049](tasks/IMP-049.md) | READY | [IMP-014](tasks/IMP-014.md), [IMP-020](tasks/IMP-020.md), [IMP-025](tasks/IMP-025.md), [IMP-039](tasks/IMP-039.md) |
| [IMP-050](tasks/IMP-050.md) | READY | [IMP-005](tasks/IMP-005.md), [IMP-028](tasks/IMP-028.md) |
| [IMP-051](tasks/IMP-051.md) | READY | [IMP-023](tasks/IMP-023.md), [IMP-031](tasks/IMP-031.md), [IMP-034](tasks/IMP-034.md), [IMP-042](tasks/IMP-042.md), [IMP-044](tasks/IMP-044.md), [IMP-046](tasks/IMP-046.md), [IMP-047](tasks/IMP-047.md), [IMP-050](tasks/IMP-050.md), [IMP-059](tasks/IMP-059.md), [IMP-060](tasks/IMP-060.md), [IMP-064](tasks/IMP-064.md) |
| [IMP-052](tasks/IMP-052.md) | READY | [IMP-002](tasks/IMP-002.md), [IMP-019](tasks/IMP-019.md), [IMP-020](tasks/IMP-020.md), [IMP-024](tasks/IMP-024.md), [IMP-026](tasks/IMP-026.md), [IMP-032](tasks/IMP-032.md) |
| [IMP-053](tasks/IMP-053.md) | READY | [IMP-028](tasks/IMP-028.md), [IMP-038](tasks/IMP-038.md), [IMP-052](tasks/IMP-052.md) |
| [IMP-054](tasks/IMP-054.md) | READY | [IMP-008](tasks/IMP-008.md), [IMP-013](tasks/IMP-013.md), [IMP-025](tasks/IMP-025.md) |
| [IMP-055](tasks/IMP-055.md) | READY | [IMP-026](tasks/IMP-026.md), [IMP-051](tasks/IMP-051.md), [IMP-054](tasks/IMP-054.md), [IMP-057](tasks/IMP-057.md) |
| [IMP-056](tasks/IMP-056.md) | READY | [IMP-007](tasks/IMP-007.md), [IMP-051](tasks/IMP-051.md) |
| [IMP-057](tasks/IMP-057.md) | READY | [IMP-025](tasks/IMP-025.md) |
| [IMP-058](tasks/IMP-058.md) | READY | [IMP-023](tasks/IMP-023.md), [IMP-033](tasks/IMP-033.md) |
| [IMP-059](tasks/IMP-059.md) | READY | [IMP-025](tasks/IMP-025.md), [IMP-035](tasks/IMP-035.md), [IMP-039](tasks/IMP-039.md), [IMP-040](tasks/IMP-040.md), [IMP-045](tasks/IMP-045.md), [IMP-049](tasks/IMP-049.md) |
| [IMP-060](tasks/IMP-060.md) | READY | [IMP-026](tasks/IMP-026.md), [IMP-037](tasks/IMP-037.md), [IMP-039](tasks/IMP-039.md), [IMP-045](tasks/IMP-045.md) |
| [IMP-061](tasks/IMP-061.md) | READY | [IMP-008](tasks/IMP-008.md), [IMP-010](tasks/IMP-010.md) |
| [IMP-062](tasks/IMP-062.md) | READY | [IMP-014](tasks/IMP-014.md), [IMP-032](tasks/IMP-032.md) |
| [IMP-063](tasks/IMP-063.md) | READY | [IMP-043](tasks/IMP-043.md) |
| [IMP-064](tasks/IMP-064.md) | READY | [IMP-033](tasks/IMP-033.md), [IMP-034](tasks/IMP-034.md), [IMP-042](tasks/IMP-042.md) |
