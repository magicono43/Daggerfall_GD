# Architectural decisions

Cross-system decisions originating in Prompt_4, reviewed on 2026-11-05. The proposed decisions table retains the original review and evidence. The approved decisions section records later selections and governs their scope. Individual system proposals retain their own statuses.

## Approved decisions

### GAD-01 — Identity and lifetime

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to the three identity choices.

1. A definition key consists of the domain, originating package and stable local record key. Additions use the adding package's namespace. Explicit replacements preserve the target key and track the replacing provider separately. Classic numeric IDs resolve through domain-specific mappings.
2. Persistent instances use typed IDs allocated from saved increasing counters per category within a native save branch. Restoring an earlier save restores that branch's counter state. Separate branches can allocate the same typed ID after divergence. Preserve the nonreuse guarantee for retired IDs within each branch. Restore validates duplicate claims before entry. A separate session identifier invalidates stale requests, callbacks and transient scene handles.
3. A persistent layout record is addressed by its placed layout and stable record key. Variant and revision are compatibility context. If restoration needs to remap a reference, require an explicit mapping validated by the owning system. Required references that cannot resolve follow the approved load recovery flow.

Serialization encoding, ID width, concrete registry interfaces and provider-specific compatibility schemas remain follow-on contract work. Relevant approved specifications include [DATA-004](../../design/systems/DATA/DATA-004.md), [ITEM-001](../../design/systems/ITEM/ITEM-001.md), [SAVE-008](../../design/systems/SAVE/SAVE-008.md) and [DEV-012](../../design/systems/DEV/DEV-012.md).

### GAD-02 — Authoritative state ownership

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to the ownership, session composition and persistence choices.

1. Each authoritative piece of state has a single domain owner. CHAR owns health and base stats, ITEM owns inventory and equipment, QUEST owns quest progress, and ECON owns bank accounts and debts. Other systems use stable references, read-only projections and validated owner requests.
2. CORE creates, composes and tears down each session. Domains call each other through the relevant owner interfaces. UI presents projections and submits player requests. Cross-owner outcome and settlement ordering remains with the corresponding architecture decisions.
3. SAVE coordinates capture and restore. Each owner defines and validates its durable records. Derived state designated for reconstruction is rebuilt from authoritative inputs before gameplay resumes.

The [system boundary proposal](PROPOSED_SYSTEM_BOUNDARIES.md) illustrates the policy. Its detailed interfaces, remaining field allocations and operation ordering require their own review.

### GAD-03 — Session operations and eligibility

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to the operation lifecycle, independent gates and save capture choices.

1. CORE tracks each accepted session change through cancellable preflight, replacement and initialization. Conflicting requests receive an immediate busy result. Each accepted operation emits exactly one terminal outcome. Work must match the active operation and session scope before applying changes. Preflight failure or cancellation preserves the live session. Failure after replacement begins enters safe cleanup and recovery.
2. Track simulation, gameplay input and presentation separately. Holds are scoped to the requester and session. Each requester releases its own holds. Required initialization must complete before play can resume, subject to remaining holds.
3. Manual save and quicksave share an eligibility policy and capture at a settled simulation boundary. Quicksave can release its capture hold after handing off an isolated snapshot. Publication uses that snapshot, rejects conflicting slot work and reports success at commit.

The native save format and publication mechanism remain under GAD-04. See [CORE-007](../../design/systems/CORE/CORE-007.md), [CORE-016](../../design/systems/CORE/CORE-016.md), [SAVE-004](../../design/systems/SAVE/SAVE-004.md) and [SAVE-006](../../design/systems/SAVE/SAVE-006.md) for governing behavior.

### GAD-04 — Native save publication and restore

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to the bundle, exact-generation preflight and phased restore choices.

1. Stage one complete, versioned bundle per save generation. Include slot metadata, separately versioned owner and mod payloads, and the optional generation-matched preview. The catalog, quicksave designation and numbering resolve to the same committed state. Verify interruption recovery on supported storage platforms before selecting the exact publication mechanism.
2. Preflight the exact generation later used for restore. Validate required payloads, supported migrations, dependencies and references available before world reconstruction. Reject while preserving the current session on preflight failure. Apply owner-approved optional recovery. Preserve the last committed generation on failed overwrite and retire it after successful replacement.
3. Restore early context, reconstruct and register durable objects, resolve references and placement against ready geometry, then rebuild derived state and supported UI. Publish one Session Restored outcome after required work succeeds. Use GAD-03 recovery for failure after replacement begins.

Bundle encoding and exact commit mechanism remain interface and platform work. See [SAVE-006](../../design/systems/SAVE/SAVE-006.md), [SAVE-017](../../design/systems/SAVE/SAVE-017.md) and [CORE-013](../../design/systems/CORE/CORE-013.md).

### GAD-05 — Game time and catch-up

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to calendar ownership, chronological settlement and owner catch-up policies.

1. TIME owns the native game-millisecond calendar, with calendar time, simulation steps and real-time UI pacing distinct. Report the reason and committed old/new instants for an advance. Restore sets the timestamp without replaying crossings. Backward advance requests fail validation.
2. A deadline falls within an advance when it is after the start and at or before the committed end. Settle chronological work at due instants. Use declared dependencies at the same instant and stable order for independent work. Reject dependency cycles. Quest expiry takes precedence over a pending hand-in at the cutoff.
3. Owners declare due-instant work, equivalent bulk work or approved coalescing or skip behavior. Interruption stops advancement at the actual interruption point, preserving committed effects. Recovery resumes outstanding work from that boundary.

Scheduling budget and owner-specific precedence remain interface work. See [TIME-002](../../design/systems/TIME/TIME-002.md) and [TIME-004](../../design/systems/TIME/TIME-004.md).

### GAD-06 — Random streams and retained outcomes

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to stream separation, persistence and fixture verification.

1. Start with purpose-specific session streams for combat, progression, loot and quest generation. Derive seeds independently. Presentation, previews and diagnostics use separate sources. Classic-compatible generation uses a versioned generator and explicit seed owned by each operation.
2. Initialize fresh gameplay streams after successful load. Persist assigned results, owner-designated retained pending outcomes and versioned inputs needed for exact reconstruction.
3. Give fixtures explicit seed control and reference vectors for isolation, classic compatibility and save/load behavior. Select the nonclassic algorithm and seed derivation during interface review, with reproducibility across supported platforms for deterministic fixtures.

See [RULE-002](../../design/systems/RULE/RULE-002.md) and [RULE-003](../../design/systems/RULE/RULE-003.md).

### GAD-07 — World coordinates and placement

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to ownership, coordinate conversion and placement readiness.

1. WORLD owns geographic position, residency and the active origin. LOC owns layout records and stable entrances and markers. MOVE owns local physics pose and validates placement. Indoors, WORLD reports the location anchor while MOVE tracks the actual interior pose.
2. Use versioned conversion from classic data to the local physics frame with subpixel geographic precision. Apply rebases coherently to preserve geographic position, fall history and support relationships. Determine numerical scale, precision and rebase thresholds using world-scale fixtures.
3. Report context resolution, geometry and collision readiness, and committed placement under the same request identity. Try exact pose first, followed by the bounded corrections allowed for that operation. CORE keeps gameplay gated until required placement and other entry prerequisites complete.

See [WORLD-001](../../design/systems/WORLD/WORLD-001.md), [WORLD-002](../../design/systems/WORLD/WORLD-002.md) and [MOVE-027](../../design/systems/MOVE/MOVE-027.md).

### GAD-08 — Payments, transfers and rewards

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to accepted terms, single settlement and durable receipts.

1. Bind confirmation to the accepted offer revision, stable item and destination identities, exact quantities, price and payment plan. Revalidate access, funds, stock and capacity at commitment. Changed terms require fresh confirmation.
2. Give an exchange one committed outcome. Purchase payment, stock depletion and delivery settle together. Ordinary validation failure leaves each intact. After a technical failure that crosses a mutation boundary, preserve committed facts and recover outstanding work only. Publish completion and award purchase practice once.
3. Persist receipts where recovery can resume across load. Give each authorized quest reward or consequence entry its own identity and settlement record. Preserve completed entries and retry eligible outstanding entries only. A legitimate authored repeat uses a new run identity.

Settlement interfaces, payload schemas and fault-injection fixtures remain contract work. See [ECON-004](../../design/systems/ECON/ECON-004.md) and [QUEST-019](../../design/systems/QUEST/QUEST-019.md).

### GAD-09 — Combat ordering and cross-system events

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to owner requests, attack phases and retained recovery outcomes.

1. Use explicit owner requests for required gameplay changes. COMBAT coordinates the attack, CHAR applies health changes, ITEM applies equipment and ammunition changes, and MAGIC resolves effects. Required reactions run in declared phases and return outcomes. Presentation observes committed outcomes.
2. Track each attack, component and intended target with stable identity. Resolve in declared order and prevent duplicate contact or delivery from repeating a hit. Released projectiles retain their required offensive context. Read defender state at the specified impact phase and revalidate where earlier effects affect eligibility.
3. Retain committed outcomes and recover outstanding work only. Deferred handoffs such as quest acknowledgment of a foe's death expose pending and failure outcomes. Save at supported boundaries or persist sufficient owner state for safe recovery under the approved specifications.

The per-route phase tables, concrete request/result interfaces, and persistence schemas remain contract work. See [COMBAT-009](../../design/systems/COMBAT/COMBAT-009.md), [COMBAT-011](../../design/systems/COMBAT/COMBAT-011.md) and [COMBAT-020](../../design/systems/COMBAT/COMBAT-020.md).

### GAD-10 — Content and mod publication

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to the ownership, publication and implementation sequence choices.

1. MOD resolves package order and permitted registrations. DATA resolves definitions through declared add, replace and patch operations and retains source provenance. Domain owners specify supported schemas, operations and references.
2. Keep pending edits and candidate data separate from published content. Prepare permitted registrations before validating dependent definitions. Publish one validated configuration at main-menu entry. Required validation failure stays in configuration recovery. All character sessions in the run use the locked plan.
3. Deliver the data-only path first and verify ordering, patching, provenance and publication failure. Preserve the executable registration interface. Before enabling executable providers, verify approved trust, isolation and cleanup in an exported build.

The executable runtime and sandbox mechanism remain open. See [DATA-003](../../design/systems/DATA/DATA-003.md), [MOD-004](../../design/systems/MOD/MOD-004.md) and [MOD-005](../../design/systems/MOD/MOD-005.md).

### GAD-11 — Presentation and gameplay timing

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to presentation ownership, attack timing and cinematic outcomes.

1. UI owns focus and presentation, AV owns playback, and gameplay owners resolve outcomes. UI submits choices through owner requests, AV plays cues from committed outcomes, and CORE applies session-wide gates.
2. Capture the approved animation timing profile at attack admission. Eligible simulation detects crossing of the authored commitment marker even when rendering skips the visual frame. COMBAT revalidates and commits at most once, and rendering follows the same timeline.
3. AV reports one scoped Finished, Skipped, Failed or Cancelled result after releasing owned resources and overrides. The requester decides what that outcome permits. Late or duplicated callbacks cannot advance the flow again.

See [COMBAT-015](../../design/systems/COMBAT/COMBAT-015.md) and [AV-013](../../design/systems/AV/AV-013.md). The timing profile format and per-route integration interfaces remain contract work.

### GAD-12 — Verification architecture

**Approved on 2026-11-18.** The user answered “1. Yes”, “2. Yes”, and “3. Yes” to the production interfaces, reproducibility and verification sequence choices.

1. Run integration fixtures through production interfaces and assert committed owner state and outcomes. Control seed, clock, input, content and isolated storage where relevant.
2. Provide independently callable local headless and rendered suites. Record scenario, fixture, relevant inputs, engine/build and expected and actual outcomes. An unavailable required check leaves its gate incomplete. Run rendering and real frame-boundary checks separately.
3. Establish harness invocation, isolation and failure reporting in M1. Add failed-restore preservation and enemy placement/combat in M2, and quest fault/retry in M3. Add focused formula and classic conversion checks alongside their owners.

Runner, CI provider and fixture formats remain technical choices. The governing feature is [DEV-014](../../design/systems/DEV/DEV-014.md).

## Proposed decisions

| ID | Priority and decision point | Proposal and rationale | Alternatives, trade-offs and open choice | Evidence and affected systems |
| --- | --- | --- | --- | --- |
| [GAD-01](#gad-01--identity-and-lifetime) | Approved | Identity categories, allocation scope and remapping policy recorded above. | See approval for selected alternatives and remaining contract work. | DATA-AR-03, ITEM-AR-01, NPC-AR-01, LOC-AR-01, SAVE-AR-03. DATA, ITEM, NPC, QUEST, WORLD, LOC, SAVE, MOD. |
| [GAD-02](#gad-02--authoritative-state-ownership) | Approved | Single authority per state, CORE session composition, and domain-owned persistence projections. | See approval for scope and remaining contract work. | CHAR-AR-05, FACT-AR-01/02, ECON-AR-02, LAW-AR-01, MAGIC-AR-05. All gameplay domains. |
| [GAD-03](#gad-03--session-operations-and-eligibility) | Approved | Single session-change lifecycle, requester-owned gates and settled save capture. | See approval for scope and the GAD-04 handoff. | CORE-AR-03/04, UI-AR-01, MOVE-AR-05, WORLD-AR-01, SAVE-AR-02. CORE, UI, SAVE, WORLD, LOC, MOVE, TIME, LAW. |
| [GAD-04](#gad-04--native-save-publication-and-restore) | Approved | One versioned bundle per generation, exact-generation preflight and gated phased restore. | Encoding and exact commit mechanism remain open. | SAVE-AR-01 through SAVE-AR-04, QUEST-AR-05, MOD-AR-05. All durable owners. |
| [GAD-05](#gad-05--game-time-and-catch-up) | Approved | TIME-owned calendar, chronological due work and owner-declared catch-up. | Scheduling budget and owner-specific precedence remain open. | TIME-AR-01/03/04, FACT-AR-02, MAGIC-AR-03. TIME, CHAR, MAGIC, QUEST, NPC, FACT, ECON, LAW, WORLD, AV. |
| [GAD-06](#gad-06--random-streams-and-retained-outcomes) | Approved | Purpose-specific streams, fresh gameplay draws on load and retained assigned outcomes. | Select nonclassic algorithm and seed derivation during interface review. | RULE-AR-01, DATA-AR-04, WORLD-AR-03, AV-AR-03, QUEST-AR-01. RULE and random consumers. |
| [GAD-07](#gad-07--world-coordinates-and-placement) | Approved | Coordinate and placement ownership, versioned conversion, request-scoped readiness and bounded placement. | Scale, numerical precision and thresholds require fixtures. | WORLD-AR-01/02, LOC-AR-01/04, MOVE-AR-02/05, DATA-AR-06. WORLD, LOC, MOVE, NPC, QUEST, SAVE. |
| [GAD-08](#gad-08--payments-transfers-and-rewards) | Approved | Accepted terms, one settlement outcome, and durable receipts for work that can resume across load. | Concrete settlement interfaces, schemas and fixtures remain open. | ITEM-AR-02/03, ECON-AR-01/02, CHAR-AR-03/04, MAGIC-AR-04, LAW-AR-04. ITEM, ECON, CHAR, MAGIC, LAW, QUEST, UI. |
| [GAD-09](#gad-09--combat-ordering-and-cross-system-events) | Approved | Explicit owner requests, ordered attack resolution, stable attribution and recovery of outstanding work. | Route-specific phase tables and interfaces remain open. | RULE-AR-04, COMBAT-AR-01 through COMBAT-AR-05, MAGIC-AR-02, QUEST-AR-02, UI-AR-01. COMBAT, MAGIC, CHAR, ITEM, QUEST, LAW, NPC, AV. |
| [GAD-10](#gad-10--content-and-mod-publication) | Approved | MOD package planning, DATA definition resolution and run-long configuration lock. Deliver data-only first. | Executable runtime and sandbox mechanism remain open. | DATA-AR-01/02, MOD-AR-01 through MOD-AR-05. DATA, MOD, all definition consumers, SAVE. |
| [GAD-11](#gad-11--presentation-and-gameplay-timing) | Approved | UI/AV ownership, simulation-driven authored markers and scoped cinematic completion. | Timing profile format and route integration remain open. | UI-AR-01 through UI-AR-04, AV-AR-01 through AV-AR-05. UI, AV, CORE, COMBAT, MAGIC, MOVE, DATA. |
| [GAD-12](#gad-12--verification-architecture) | Approved | Production fixtures, independent suites, reproducible outcomes and staged integration coverage. | Runner, CI provider and fixture formats remain open. | DEV-AR-01 through DEV-AR-04, SAVE-AR-01/02, WORLD-AR-02. DEV and all owners. |

## Approval and reconsideration

An approval should record the decision ID, selected alternative, scope, date and user approval reference. Superseding a decision should preserve its history and name affected contracts. An individual system proposal linked above remains Proposed until its scope is explicitly accepted. The conceptual contracts in [proposed boundaries](PROPOSED_SYSTEM_BOUNDARIES.md) illustrate these proposals.

Detailed native schema versions, numeric ID width, RNG algorithm for new simulation, exact tick frequencies, job strategy, rendering backend and executable mod sandbox are open choices. The review does not infer approval from technical necessity. The dependency consequences are in [detailed dependencies](../04_DETAILED_DEPENDENCIES.md).
