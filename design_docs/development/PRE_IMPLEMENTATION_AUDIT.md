# Final pre-implementation readiness audit

Reviewed 2026-11-18 against the 64 implementation cards, the approved gameplay specifications and decision log, the 12 architecture approvals, and the roadmap and dependency ledger. This is a static planning audit. Runtime behaviors and acceptance checks remain unverified.

## Overall readiness

**No task is ready to dispatch.** The first implementation candidate is IMP-001 after its storage and settings handoff and acceptance fixtures are specified. The architecture policies are settled and the milestone sequence remains viable with the integration gaps below resolved.

| Planning status | Count | Meaning |
| --- | ---: | --- |
| READY | 0 | A coding agent can implement and verify the defined scope under resolved contracts. |
| BLOCKED | 16 | The task boundary is workable, and an identified design, interface or feasibility decision must be resolved first. |
| NEEDS REVISION | 48 | The card needs a scope, prerequisite, responsibility or acceptance rewrite. Some cards also have unresolved design choices. |

All 64 are currently **not dispatchable**. A future READY task can still wait for implementation prerequisites, fixtures and explicit authorization. An unfinished upstream implementation by itself leaves planning status unaffected.

## Feature coverage and responsibility

- **432 of 432 approved features have one primary owner**, with a matching gameplay approval record on each assigned card. There are zero orphan IDs and zero duplicate primary assignments. This measures traceability. Feature-level acceptance is incomplete where a card defers behavior or offers a representative test without naming the matching live integration.
- **Five exclusions match the decisions.** CORE-009, DEV-007 and DEV-008 are deferred. CORE-014 and SAVE-018 are outside current scope. CORE-013 governs native load.
- The work missing from the plan is chiefly separately executable work within existing scope. The minimum M3 economy initializer, staged action-door and equipped-effect restore checks, later quest verb coverage and exported mod verification all need concrete owner handoffs. Most can be scoped within existing cards or under child tasks. Track each staged feature against its live completion check.
- Shared responsibilities need one producer. IMP-001 owns one launch logger for CORE-002 and DEV-001. IMP-002 owns the UI-003 registry and IMP-051 supplies authorized providers. IMP-028/030/038 own quest recovery facts, journal presentation and persistence. IMP-053 consumes those facts for inspection. IMP-056 contains localization import and package authoring, both using shared runtime validators.
- See the [gameplay decisions](../design/GAMEPLAY_DECISIONS.md), [approved architecture](../analysis/architecture/ARCHITECTURAL_DECISIONS.md#approved-decisions), and [backlog](TASK_BACKLOG.md).

## Prioritized findings and corrections

| Priority and finding | Affected IMPs | Correction and evidence |
| --- | --- | --- |
| P0 — First handoff and test harness need concrete contracts | 001–005 | Specify launch context, root and settings outcomes, isolated fixture storage and provider results. Exercise exclusive root access, portable fallback, logging-only failure, corrupt settings recovery and failed settings publication. Select the independently callable local runner and prove an incomplete/failed check with reproducible output. Actual reader validation and package publication close the shell at M1. |
| P1 — First encounter needs a joint acceptance path | 012, 013, 019–021, 024 | Removed IMP-020 as a prerequisite for player melee development against a controlled actor fixture. IMP-021 still waits for both combat and NPC. Require a live trace from actor placement through damage, death, corpse and item transfer. Verify a simulation marker crossed on a skipped render frame, and duplicate callback rejection. |
| P1 — Local restore touches later domain owners | 018, 022–024, 038, 042, 058 | IMP-022 owns bundle publication and slot catalog. IMP-023 owns exact-generation preflight and gated live replacement with the M2 participant set. IMP-024 supports room presentation and the rendered preview check. IMP-042 closes active door/action relinking and NPC open/bash with IMP-020. IMP-038 and IMP-058 close real quest/world and effect payloads. Inject a preflight rejection and a failure after replacement begins as distinct cases. |
| P1 — Fresh start needs real economy initialization ahead of the full banking task | 015, 031, 032, 035–038, 045, 062 | CORE-012 requires initial account/property and regional/weather state before control. IMP-045 delivers full banking in M4. Give the minimum account/property initialization its own M3-verifiable economy increment and gate IMP-036 on it, or revise the milestone. Settle exact starting grants, visible popup sequence and exterior tutorial adaptation against owner sources. |
| P1 — Rebuild may duplicate durable state | 016–018, 023, 034, 038, 058 | Declare one authoritative writer per durable record. ITEM restores inventory and slots, MAGIC restores timed effects and reconciles held sources, CHAR rebuilds approved derived values, and SAVE orders the work. Pin a fixture with equipped gear and an active incumbent. Assert no double modifier, stale reference or fresh-start grant on load. |
| P1 — Quest fixture and grammar coverage are earlier than live provider coverage | 028–031, 036, 038, 051, 053 | Pin the M3 quest and its enabled verbs. Name the owner and planned closure for each later M4/M5 verb. Verify a retained committed award plus pending item across fault, retry and reload. Include bounded NPC death acknowledgment and an explicit failure outcome. |
| P1 — Exported executable feasibility can cause package contract rework | 005, 028, 050, 051 | Assess exported runtime candidates during registration design. Use data-only publication in M1. Require restricted capability isolation, trusted approval binding and verified activation cleanup before enabling executable consumers. Escalate a specific capability tradeoff if the approved behavior cannot be met. |
| P2 — Owned ship transport crosses title, visit and storage | 039–040, 045–046, 049, 059–060 | Added IMP-060 as a full-delivery prerequisite of IMP-040. Ordinary motors can be prepared against their own fixtures. Verify live entitlement, rejected resale with a pending visit or possessions aboard, and return context on restore. |
| P2 — Authoring and inspection have different prerequisites | 005, 007, 051, 054–056 | Removed IMP-054 as a required predecessor of localization and package authoring. Both use shared runtime validation. Retain separate inspection/export checks for assets and location previews. |
| P2 — Feature families are too broad for a single agent handoff | 002, 007–009, 015–016, 022–023, 028–031, 034–035, 037–047, 051–052, 054–058, 060, 064 | Split along runnable producer or workflow boundaries. Examples include save publication vs live restore, parser vs ordered execution vs resource binding, training vs magical service settlement, and locale import vs package authoring. Preserve parent acceptance and update downstream dependencies when splitting. |
| P2 — Acceptance often lacks a fixture, oracle or failure boundary | See per-task table | Replace generic acceptance for dispatch scope with named inputs, owner-approved expected state/results, exact order/counts or tolerances where applicable, and a specified production entry point. Record where each acceptance criterion runs and which conditions require rendered or manual verification. |

P0 gates initial dispatch. P1 gates a milestone or production boundary. P2 must be resolved before the affected scope is assigned or accepted. Proposed task splits preserve the approved gameplay and architectural scope.

## Architecture and integration review

| Approved policy | Application and remaining verification |
| --- | --- |
| GAD-01 identity | IMP-010/017/022/023/029/055 need definition keys, branch-local durable IDs, scoped layout records and approved remapping. Pin allocation state and duplicate/missing-reference fixtures. |
| GAD-02 ownership | IMP-002 composes owners. IMP-016/017/028/037 own domain facts, and IMP-022/023/038 coordinate owner-defined persistence. Specify one writer per fact at restore and settlement boundaries. |
| GAD-03 session gates | IMP-002/011/022/023 need operation and requester scoping, stale-callback rejection, busy and cancellation results, and capture/publication distinction. |
| GAD-04 native generations | IMP-022/023/038/051 publish owner payloads inside the one approved bundle. Corrected ambiguous sidecar wording. Select encoding and prove commit interruption recovery. |
| GAD-05 calendar | IMP-014 and its consumers need chronological and same-instant fixtures, equivalent bulk processing and interruption with a committed endpoint. |
| GAD-06 randomness | IMP-006 owns explicit sources; IMP-016/019/021/028/049 consume them. Verify retained assignments and fresh unresolved gameplay draws after successful load. |
| GAD-07 placement | IMP-010/013/025/057/061 need common coordinate and readiness contracts. IMP-023 waits on actual geometry before testing placement. Terrain rebase and collision acceptance spans IMP-025/057. |
| GAD-08 settlement | IMP-017/031/037/045/046/059/060 need exact accepted terms, admission checks, ordinary rejection with unchanged state, and scoped recovery receipts. |
| GAD-09 combat | IMP-019/020/029/041/047 need an owner phase trace, attribution, duplicate defense and committed-work retention. |
| GAD-10 content | IMP-005 now explicitly tests the lock for the whole application run. IMP-050/051 own the later executable path. IMP-055/056 consume the same validators as runtime. |
| GAD-11 presentation | IMP-019/020/024/035 need authored timeline, cue and cinematic outcome tests, including skipped, stale and duplicate callbacks. |
| GAD-12 verification | IMP-003 owns the harness. M2 encounter and failed restore, then M3 quest fault/retry, run via production interfaces with isolated storage. Add focused formula and conversion checks alongside the owners and run rendered checks independently. |

The register policies are compatible with the intended implementation. The gaps concern task boundaries, specific owner contracts and acceptance evidence. The audit found no material conflict requiring a change to approved gameplay or architecture.

## Milestone playability

| Milestone | Playability | Required evidence |
| --- | --- | --- |
| M1 | Technical checkpoint | Startup/recovery shell, real validated data-only content and independently callable suites. |
| M2 | Playable room through a development fixture | Production entry, movement, melee, loot, save and reload. Failed restore preserves the live session. Separate rendered timing and preview checks. |
| M3 | Player-facing start and quest loop | Approved creation and both opening routes, real initial owner state, settlement/site traversal, supported quest and reward, save/reload and fault/retry. The startup economy increment and opening sequence remain gating gaps. |
| M4 | Broader playable loops | Add real progression, traversal, magic, law and economic providers, plus travel and their supported persistence and interruption paths. Close earlier deferred provider checks. |
| M5 | Exported release candidate | Demonstrate permitted mod execution, save compatibility and tools under approved conditional scope. Validate shared authoring/runtime invariants. |

## Verified implementation order

Each group represents a dependency wave within the milestone. Entries are IMP suffixes. Within-wave concurrency depends on compatible interfaces, fixtures and ownership. The order reflects the corrected direct graph. Joint checks still gate milestone completion.

- **M1** — 001 → 002, 003 → 004, 006 → 005 → 007, 008, 009, 010
- **M2** — 011, 014, 016, 017, 024, 061 → 013, 015, 018, 022 → 012 → 019, 020 → 021 → 023
- **M3** — 025, 028, 032, 033 → 027, 035, 057, 058, 062 → 026, 034, 037 → 029 → 030 → 031 → 038 → 036
- **M4** — 039, 041, 042 → 043, 047, 049, 064 → 063 → 044, 045 → 048, 060 → 040 → 046, 059
- **M5** — 050, 052, 054 → 051, 053 → 055, 056

The graph has **217 prerequisite edges, no cycles and no dependency from a later milestone into an earlier one**. The order is topological. Recompute after any task split or move of the early economy work. [Dependency graph](DEPENDENCY_GRAPH.md)

## Recommended first implementation task

**IMP-001 — Storage, settings and startup recovery.** Define the launch inputs and root result, settings validation/publication and failure contract, and the isolated startup fixtures. Its revised acceptance covers standard/portable selection, exclusive access, explicit fallback, settings recovery, and log rotation. When ready and authorized, implement that bounded slice and open IMP-002 and IMP-003 in parallel after its delivery. [IMP-001](tasks/IMP-001.md)

## Per-task disposition

All tasks are currently not dispatchable. The planning status records the first reason to withhold each task.

| IMP | Planning readiness | Required action |
| --- | --- | --- |
| [IMP-001](tasks/IMP-001.md) | BLOCKED | Select the settings recovery/publication details and storage-provider seam. Release the storage and setup-shell slice first. |
| [IMP-002](tasks/IMP-002.md) | NEEDS REVISION | Separate session gate deliverables from the full UI registry, menus and native restore consumers. Specify request and hold lifetimes by consumer. |
| [IMP-003](tasks/IMP-003.md) | BLOCKED | Choose the local runner, isolated storage strategy, test exit outcomes and first reproducible failure fixture. |
| [IMP-004](tasks/IMP-004.md) | BLOCKED | Select the supported installation/reader inventory and pin valid, missing and malformed source fixtures. |
| [IMP-005](tasks/IMP-005.md) | NEEDS REVISION | Define shell and resolver outputs, registration readiness and the data-only entry scope. Assert run-long publication across character changes. |
| [IMP-006](tasks/IMP-006.md) | BLOCKED | Select the nonclassic RNG/seed contract and reference vectors. Stage live mod overrides with IMP-051. |
| [IMP-007](tasks/IMP-007.md) | NEEDS REVISION | Separate text/locale lookup from fonts and the authoring round trip. Name sample locale tables, invalid-token and missing-glyph outcomes. |
| [IMP-008](tasks/IMP-008.md) | NEEDS REVISION | Scope independent mesh, texture and media adapter checks. Specify cache/source behavior where MOD-006/008 integrate. |
| [IMP-009](tasks/IMP-009.md) | NEEDS REVISION | Split six content families into runnable increments with expected decoded records and required-reference failures. |
| [IMP-010](tasks/IMP-010.md) | BLOCKED | Pin classic layout/terrain fixture records, versioned layout keys and conversion inputs under GAD-01/07. |
| [IMP-011](tasks/IMP-011.md) | BLOCKED | Set the action-delivery seam, device arbitration fixtures and reproducible render/physics timing inputs. |
| [IMP-012](tasks/IMP-012.md) | NEEDS REVISION | Separate baseline motor and initial collision from moving platforms, fall consequences and movement feedback. Map each to a geometry fixture. |
| [IMP-013](tasks/IMP-013.md) | NEEDS REVISION | Separate local layout assembly and transition orchestration from MOVE placement validation. Bind required entrance geometry and scoped results. |
| [IMP-014](tasks/IMP-014.md) | BLOCKED | Define the test scheduler budget, initial consumers and simultaneous/interruption vectors under approved calendar semantics. |
| [IMP-015](tasks/IMP-015.md) | NEEDS REVISION | Separate preset and custom creation, deterministic rolls/allocation, and presentation increments. Identify the output consumed by IMP-036. |
| [IMP-016](tasks/IMP-016.md) | NEEDS REVISION | Separate baseline/derived stats and pools from activity collapse, death flow and display. Link handoff outcomes to combat, FACT and CORE. |
| [IMP-017](tasks/IMP-017.md) | BLOCKED | Define typed ID allocation and saved counter representation, collection admission and the exact restore validation fixture. |
| [IMP-018](tasks/IMP-018.md) | NEEDS REVISION | Stage stock equipment and slot/condition tests first. Assign held-source reconciliation to joint ITEM/MAGIC acceptance with IMP-034/058. |
| [IMP-019](tasks/IMP-019.md) | NEEDS REVISION | Specify a route-specific player melee phase trace and frame-skip/duplicate-marker checks. Use an actor fixture, then jointly verify with IMP-020. |
| [IMP-020](tasks/IMP-020.md) | NEEDS REVISION | Deliver placement, pursuit and melee for an open room first. Bind live door behavior to IMP-042 and separate later spell/stealth consumers. |
| [IMP-021](tasks/IMP-021.md) | NEEDS REVISION | Distinguish ordinary corpse/loot transfer from reserved quest items and death acknowledgment. Give the latter a live check in IMP-029. |
| [IMP-022](tasks/IMP-022.md) | NEEDS REVISION | Separate envelope/publication fault checks, participant projections and slot UI operations. State the actual generation/catalog invariant and fault cuts. |
| [IMP-023](tasks/IMP-023.md) | NEEDS REVISION | Split candidate preflight from world restore and late cleanup. Identify initial object records and carry door/action state to IMP-042. |
| [IMP-024](tasks/IMP-024.md) | BLOCKED | Specify representative room assets and HUD/preview presentation fixtures and expected visual outcomes. |
| [IMP-025](tasks/IMP-025.md) | NEEDS REVISION | Define what initial world/residency work can verify before real terrain arrives. Name the joint rebase and cell-transition check with IMP-057. |
| [IMP-026](tasks/IMP-026.md) | NEEDS REVISION | Separate exterior/dungeon discovery, map projection and world-object restoration. Specify re-entry and missing reference fixtures. |
| [IMP-027](tasks/IMP-027.md) | NEEDS REVISION | Scope civilian pool/identity versus placed service actors and property containers; assign stability and routing checks. |
| [IMP-028](tasks/IMP-028.md) | NEEDS REVISION | Separate grammar/registry validation from ordered execution and recovery. Assign journal/trace and persisted fault verification to peers. |
| [IMP-029](tasks/IMP-029.md) | NEEDS REVISION | Break resource binding into site/marker, actor/foe and item/custody increments. Specify bounded death acknowledgment outcomes. |
| [IMP-030](tasks/IMP-030.md) | NEEDS REVISION | Separate normal talk/topic projections, social offer identity and journal/author-facing recovery. Link guild offers to IMP-031. |
| [IMP-031](tasks/IMP-031.md) | NEEDS REVISION | Name M3 verbs and follow-on providers. Split offer eligibility, durable reward entries and later action families with specific failure checks. |
| [IMP-032](tasks/IMP-032.md) | NEEDS REVISION | Separate standing normalization and queries from membership/rank entry points and restore, with fixtures for each. |
| [IMP-033](tasks/IMP-033.md) | BLOCKED | Specify cast admission and commitment, distinct spell and projectile attribution inputs, and the minimal first-spell profile. |
| [IMP-034](tasks/IMP-034.md) | NEEDS REVISION | Split effect families and item-source/passive integration. State ordering and cleanup or save checks for each family. |
| [IMP-035](tasks/IMP-035.md) | NEEDS REVISION | Separate weather/lighting and ambient audio from cinematic outcomes. Define which cinematic cues startup actually consumes. |
| [IMP-036](tasks/IMP-036.md) | BLOCKED | Resolve the material owner/content choices for initial grants, minimum economy state, visible opening order and exterior tutorial adaptation. |
| [IMP-037](tasks/IMP-037.md) | NEEDS REVISION | Scope initial merchant settlement and ledger inputs. Specify exact accepted quote, tender, stock and custody invariants with recovery. |
| [IMP-038](tasks/IMP-038.md) | NEEDS REVISION | Identify per-owner state/versions and required link order inside the approved generation bundle. Add concrete quest fault/claim restore checks. |
| [IMP-039](tasks/IMP-039.md) | NEEDS REVISION | Split practice/leveling and allocation from rest and threat interruption. Specify threshold and clock fixtures and separate save/resume cases. |
| [IMP-040](tasks/IMP-040.md) | NEEDS REVISION | Separate climb/water/recall increments from owned transport. Set the shared ship visit/entitlement test with IMP-060. |
| [IMP-041](tasks/IMP-041.md) | NEEDS REVISION | Separate player ammunition and projectile lifetime from enemy ranged/spell intent. Add post-release save, obstruction and duplicate-impact checks. |
| [IMP-042](tasks/IMP-042.md) | NEEDS REVISION | Separate doors and locks, trigger chains and moving geometry/traps. Jointly verify enemy bashing and saved action relinking. |
| [IMP-043](tasks/IMP-043.md) | NEEDS REVISION | Partition incident sources and charge processing. Assign lending-default integration to IMP-045 and arrest/guards to IMP-063. |
| [IMP-044](tasks/IMP-044.md) | NEEDS REVISION | Split court decisions, custody advance and release/restoration. Identify actor, jurisdiction, interruption and placement fixtures. |
| [IMP-045](tasks/IMP-045.md) | NEEDS REVISION | Separate baseline regional account projection from instruments, loans/default and later property/service payloads. Name the M3 startup consumer. |
| [IMP-046](tasks/IMP-046.md) | NEEDS REVISION | Split repair/identify, training and magical service routes. Bind each to its quote, fulfillment and retry checks. |
| [IMP-047](tasks/IMP-047.md) | NEEDS REVISION | Separate potion/spell crafting from enchantment creation and COMBAT-011 hit ordering. Link equipment and cost owners. |
| [IMP-048](tasks/IMP-048.md) | BLOCKED | Specify the curse/transform ordering, controlled-time fixtures and restore representations before implementing these lifecycles. |
| [IMP-049](tasks/IMP-049.md) | BLOCKED | Pin encounter eligibility, seeded placement boundaries and the committed rest/travel threat handoff. |
| [IMP-050](tasks/IMP-050.md) | BLOCKED | Choose and prove an enforceable restricted runtime and trusted activation boundary on supported exports. |
| [IMP-051](tasks/IMP-051.md) | NEEDS REVISION | Split data contributors, domain registrations and mod save compatibility. Give UI replacement and data-only provider behavior explicit coverage. |
| [IMP-052](tasks/IMP-052.md) | NEEDS REVISION | Separate environment reports, console policy, screenshot and actor-control increments. Include package-qualified registration as a joint check. |
| [IMP-053](tasks/IMP-053.md) | NEEDS REVISION | Define trace/inspection fields and expected isolation and reuse of QUEST-023 facts, including which existing reports are durable. |
| [IMP-054](tasks/IMP-054.md) | NEEDS REVISION | Split media/reference export from world preview. Identify supported formats, disclosed losses and an expected round-trip result per format. |
| [IMP-055](tasks/IMP-055.md) | NEEDS REVISION | Separate exterior block editor, world authoring and variant/compatibility validation. Define the matching runtime validator requirements. |
| [IMP-056](tasks/IMP-056.md) | NEEDS REVISION | Split translation tooling from package authoring while reusing runtime validation and respecting launch feasibility clauses. |
| [IMP-057](tasks/IMP-057.md) | NEEDS REVISION | Separate height/tile jobs from safe seam/corner publication, cancellation and rebase checks. Pin existing and stale geometry fixtures. |
| [IMP-058](tasks/IMP-058.md) | NEEDS REVISION | Separate defense/bundle outcomes from lifetime and restored incumbents, with supported same-instant ordering and derived-state checks. |
| [IMP-059](tasks/IMP-059.md) | NEEDS REVISION | Specify route, quote, charge/arrival and interrupted-trip outcomes. Clarify the dependency on property and travel threat context. |
| [IMP-060](tasks/IMP-060.md) | NEEDS REVISION | Split property deeds, lodging and ship entitlement. Assign boarding and visit restore jointly with IMP-040 and provider records with IMP-045. |
| [IMP-061](tasks/IMP-061.md) | BLOCKED | Pin classic dungeon, entry and connector records and the relationship among versioned layout, water context and exit placement. |
| [IMP-062](tasks/IMP-062.md) | BLOCKED | Choose the authoritative political and propagation fixture, expected simultaneous boundary outcomes and regional projections. |
| [IMP-063](tasks/IMP-063.md) | NEEDS REVISION | Separate guard placement/pursuit from warrant effects and arrest handoff. Verify only committed arrest crosses into court. |
| [IMP-064](tasks/IMP-064.md) | NEEDS REVISION | Split books/maps, light/detection, soul/object utilities and pacification. Define owner entry points and supported persistence for each. |

## Corrections applied and approval boundary

Updated all 64 card statuses and the backlog. Clarified early storage tests, the run-long package lock, live enemy and door acceptance, owner payloads in the native bundle, ship entitlement and the packaging validator handoff. Synchronized prerequisite changes across cards and graph. Further decisions on opening content and exported scripting feasibility should be reviewed as concrete options. This audit makes no gameplay or architecture changes.
