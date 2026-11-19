# Analysis progress

Repository reconnaissance is complete for the local Daggerfall Unity 1.1.1 snapshot. The [repository overview](00_REPOSITORY_OVERVIEW.md) records the version evidence and unresolved Git provenance. The [master catalog](01_MASTER_SYSTEMS_CATALOG.md) defines 21 stable top-level IDs. The [dependency overview](02_INITIAL_DEPENDENCY_OVERVIEW.md) records sampled interactions and external evidence requirements.

## Recommended order for deeper analysis

| Order | Systems | Questions to resolve |
| --- | --- | --- |
| 1 | CORE, DATA, RULE | Map boot and service lifetimes, identify authoritative records and content keys, and separate deterministic rules from Unity and random-state dependencies. |
| 2 | WORLD, LOC, MOVE | Trace streaming coordinates and origin changes, transition and reconstruction sequences, marker identity, physics settings and activation priority. |
| 3 | CHAR, ITEM | Trace character initialization, skill tally and level timing, inventory identity, equip transitions and classic data-driven templates. |
| 4 | COMBAT, MAGIC, NPC | Follow representative attack, cast, effect and death sequences. Resolve timing and ordering, AI state, encounter generation and dialogue integration. |
| 5 | TIME, FACT, LAW, ECON | Trace elapsed time during rest, travel and prison, regional legal state, membership/reputation changes, prices, services, deeds and loan deadlines. |
| 6 | QUEST | Inventory quest grammar and action coverage. Trace an authored story quest and a selected repeatable quest through site selection, dialogue, journal and completion. |
| 7 | SAVE, MOD | Trace save schema evolution, restore order, object IDs, legacy import and mod data/override precedence. Record persistence fields as each earlier system is analyzed. |
| 8 | UI, AV, DEV | Consolidate window ownership and gameplay side effects, inspect scene and asset wiring, and inventory available diagnostics and test coverage. Inspect relevant UI entry points in earlier passes. |

## Coverage limits

- Findings come from a directory and file inventory and targeted static inspection. Subsystems are discovery-level groups. Individual mechanics, full quest and effect inventories, and every call site remain open.
- Runtime behavior, scene and prefab bindings, exact classic content coverage, mod permutations and save compatibility have yet to be verified. No Unity execution or test runs were performed in this pass.
- The package test assembly definitions and project diagnostics are identified. Gameplay test coverage and external CI remain unverified.
- Exact source commit and the provenance of the directory's CVE label remain unknown. The observed Unity editor revision identifies the engine build.

This phase ends with reconnaissance. The order above is a proposed sequence for a later review.

## Detailed decomposition

- **CORE — Runtime coordination** — Static decomposition complete. CORE-001 through CORE-008, CORE-010 through CORE-013 and CORE-015 through CORE-021 specifications finalized v1 with explicit user approval on 2026-11-05; CORE-009 is deferred by user decision until a clear purpose emerges; CORE-014 is outside current scope under the approved exclusion of DFU/classic save compatibility; All 21 CORE features have a recorded review disposition: 19 approved specifications, one deferred and one outside current scope. Documented owner/design/verification dependencies remain open. See [CORE-014 scope record](../design/systems/CORE/CORE-014.md). See [CORE feature catalog](systems/CORE_FEATURE_CATALOG.md), [approved CORE-001 specification](../design/systems/CORE/CORE-001.md), [approved CORE-002 specification](../design/systems/CORE/CORE-002.md), [approved CORE-003 specification](../design/systems/CORE/CORE-003.md), [approved CORE-004 specification](../design/systems/CORE/CORE-004.md), [approved CORE-005 specification](../design/systems/CORE/CORE-005.md), [approved CORE-006 specification](../design/systems/CORE/CORE-006.md), [approved CORE-007 specification](../design/systems/CORE/CORE-007.md), [approved CORE-008 specification](../design/systems/CORE/CORE-008.md), [approved CORE-010 specification](../design/systems/CORE/CORE-010.md), [approved CORE-011 specification](../design/systems/CORE/CORE-011.md), [approved CORE-012 specification](../design/systems/CORE/CORE-012.md), [approved CORE-013 specification](../design/systems/CORE/CORE-013.md), [approved CORE-015 specification](../design/systems/CORE/CORE-015.md), [approved CORE-016 specification](../design/systems/CORE/CORE-016.md), [approved CORE-017 specification](../design/systems/CORE/CORE-017.md), [approved CORE-018 specification](../design/systems/CORE/CORE-018.md), [approved CORE-019 specification](../design/systems/CORE/CORE-019.md), [approved CORE-020 specification](../design/systems/CORE/CORE-020.md) and [approved CORE-021 specification](../design/systems/CORE/CORE-021.md). Implementation has not begun.
- **Next review steps** — Review startup and session entry first, then pause, state and input sequencing. Verify scene bindings and test native/classic load failure paths before making design decisions. Runtime execution and classic save fixture validation remain open.
- **DATA — Content and localization** — Static decomposition complete. All 24 features are unreviewed for design. See [DATA feature catalog](systems/DATA_FEATURE_CATALOG.md).
- **DATA review priority** — Verify source selection and override precedence, then review stable record keys and localization fallback. Original archives, effective mod combinations, serialized localization settings and runtime asset conversion remain open.
- **CHAR — Character and progression** — Static decomposition complete. All 23 features are unreviewed for design. See [CHAR feature catalog](systems/CHAR_FEATURE_CATALOG.md).
- **CHAR review priority** — Walk preset and custom creation, then trace use tallies, training and level rewards. Verify classic template data, cap and timing boundaries, save restoration, and survival interactions in play.
- **RULE — Shared formulas and randomness** — Static decomposition complete. All 28 feature specifications, RULE-001–028, are approved — finalized v1 (2026-11-06). Documented engineering, cross-owner and verification dependencies remain open; no implementation is authorized. See [RULE feature catalog](systems/RULE_FEATURE_CATALOG.md).
- **RULE review priority** — Trace shared RNG state and formula override priority, then check thresholds, attack mutations and saving throws. Original-game equivalence and runtime sequences remain open.
- **MOVE — Player movement and interaction** — Static decomposition complete. All 27 specifications, MOVE-001–027, are approved — finalized v1 (MOVE-001–005 on 2026-11-06; MOVE-006–017 on 2026-11-07; MOVE-018–027 on 2026-11-08). Documented connector-identification, mechanism-testing, tuning, engineering and cross-owner dependencies remain open; no implementation is authorized. See [MOVE feature catalog](systems/MOVE_FEATURE_CATALOG.md), [approved MOVE-001 specification](../design/systems/MOVE/MOVE-001.md), [approved MOVE-002 specification](../design/systems/MOVE/MOVE-002.md), [approved MOVE-003 specification](../design/systems/MOVE/MOVE-003.md), [approved MOVE-004 specification](../design/systems/MOVE/MOVE-004.md), [approved MOVE-005 specification](../design/systems/MOVE/MOVE-005.md), [approved MOVE-006 specification](../design/systems/MOVE/MOVE-006.md), [approved MOVE-007 specification](../design/systems/MOVE/MOVE-007.md), [approved MOVE-008 specification](../design/systems/MOVE/MOVE-008.md), [approved MOVE-009 specification](../design/systems/MOVE/MOVE-009.md), [approved MOVE-010 specification](../design/systems/MOVE/MOVE-010.md), [approved MOVE-011 specification](../design/systems/MOVE/MOVE-011.md), [approved MOVE-012 specification](../design/systems/MOVE/MOVE-012.md), [approved MOVE-013 specification](../design/systems/MOVE/MOVE-013.md), [approved MOVE-014 specification](../design/systems/MOVE/MOVE-014.md), [approved MOVE-015 specification](../design/systems/MOVE/MOVE-015.md), [approved MOVE-016 specification](../design/systems/MOVE/MOVE-016.md), [approved MOVE-017 specification](../design/systems/MOVE/MOVE-017.md), [approved MOVE-018 specification](../design/systems/MOVE/MOVE-018.md), [approved MOVE-019 specification](../design/systems/MOVE/MOVE-019.md), [approved MOVE-020 specification](../design/systems/MOVE/MOVE-020.md), [approved MOVE-021 specification](../design/systems/MOVE/MOVE-021.md), [approved MOVE-022 specification](../design/systems/MOVE/MOVE-022.md), [approved MOVE-023 specification](../design/systems/MOVE/MOVE-023.md), [approved MOVE-024 specification](../design/systems/MOVE/MOVE-024.md), [approved MOVE-025 specification](../design/systems/MOVE/MOVE-025.md), [approved MOVE-026 specification](../design/systems/MOVE/MOVE-026.md) and [approved MOVE-027 specification](../design/systems/MOVE/MOVE-027.md).
- **MOVE review priority** — Trace input and motor handoffs, then validate geometry, water, activation dispatch and placement fixtures. Runtime physics and serialized component settings remain open.
- **COMBAT — Combat and damage** — Static decomposition complete. All 21 features are unreviewed for design. See [COMBAT feature catalog](systems/COMBAT_FEATURE_CATALOG.md).
- **COMBAT review priority** — Trace player melee and bow attacks, then enemy commitment and quest-bound death. Verify projectile state, damage ordering and prefab/physics behavior in play.
- **MAGIC — Magic and effects** — Static decomposition complete. All 30 features are unreviewed for design. See [MAGIC feature catalog](systems/MAGIC_FEATURE_CATALOG.md).
- **MAGIC review priority** — Trace casting, defenses and elapsed time through save/reload, then test crafting, illness and transformation. Individual effect fidelity and unsupported classic records remain open.
- **ITEM — Items and equipment** — Static decomposition complete. All 25 features are unreviewed for design. See [ITEM feature catalog](systems/ITEM_FEATURE_CATALOG.md).
- **ITEM review priority** — Trace item identity through stacking, transfer, equip and restore. Then check wear, consumption and world-container ownership. Classic records and runtime fixtures remain open.
- **NPC — Population, AI and dialogue** — Static decomposition complete. All 24 features are unreviewed for design. See [NPC feature catalog](systems/NPC_FEATURE_CATALOG.md).
- **NPC review priority** — Trace pooled and placed actor identities, enemy detection and pursuit, then verify rumor and quest dialogue across save/reload. Runtime geometry and classic content fidelity remain open.
- **QUEST — Quest execution and selection** — Static decomposition complete. All 23 features are unreviewed for design. See [QUEST feature catalog](systems/QUEST_FEATURE_CATALOG.md).
- **QUEST review priority** — Trace a story quest and a repeatable offer through selection, triggers, site binding and restore. Full action grammar coverage and original-game parity remain open.
- **FACT — Factions, guilds and reputation** — Static decomposition complete. All 18 features are unreviewed for design. See [FACT feature catalog](systems/FACT_FEATURE_CATALOG.md).
- **FACT review priority** — Test reputation propagation, membership and the rank gate, then trace deity and guild benefits, politics and save restoration. Classic content and per-guild runtime behavior remain open.
- **LAW — Crime and legal response** — Static decomposition complete. All 16 features are unreviewed for design. See [LAW feature catalog](systems/LAW_FEATURE_CATALOG.md).
- **LAW review priority** — Trace charges and standing through guard response, rejected surrender, trial and release. Verify banishment, classic saves and runtime court ordering.
- **ECON — Economy and services** — Static decomposition complete. All 19 features are unreviewed for design. See [ECON feature catalog](systems/ECON_FEATURE_CATALOG.md).
- **ECON review priority** — Trace trade settlement and credit, then regional debt, deeds and rentals across save/reload. Specialized service rules and original-game parity remain open.
- **WORLD — Overworld streaming and exploration** — Static decomposition complete. All 18 features are unreviewed for design. See [WORLD feature catalog](systems/WORLD_FEATURE_CATALOG.md).
- **WORLD review priority** — Verify map-pixel crossings, rebase and teleport, then terrain seams, location bounds and discovery through save/reload.
- **LOC — Locations, interiors and dungeons** — Static decomposition complete. All 20 features are unreviewed for design. See [LOC feature catalog](systems/LOC_FEATURE_CATALOG.md).
- **LOC review priority** — Trace an exterior and interior, then a dungeon with water, linked actions and quest markers. Verify local state and map discovery after reload.
- **TIME — Time, environment and travel** — Static decomposition complete. All 18 features are unreviewed for design. See [TIME feature catalog](systems/TIME_FEATURE_CATALOG.md).
- **TIME review priority** — Verify clock jumps and dependent catch-up, then trace interrupted rest, travel cost and arrival, and restored weather.
- **UI — Interface and player-facing flows** — Static decomposition complete. All 21 features are unreviewed for design. See [UI feature catalog](systems/UI_FEATURE_CATALOG.md).
- **UI review priority** — Test nested windows and message ordering, then trace major entry and cancellation paths with controller, localization and scaling fixtures.
- **AV — Rendering, audio and presentation** — Static decomposition complete. All 13 features are unreviewed for design. See [AV feature catalog](systems/AV_FEATURE_CATALOG.md).
- **AV review priority** — Verify retro composition, scene lighting and ambience transitions, MIDI/replacement playback and cinematic completion.
- **SAVE — Saving, loading and persistence** — Static decomposition complete. All 18 features are unreviewed for design. See [SAVE feature catalog](systems/SAVE_FEATURE_CATALOG.md).
- **SAVE review priority** — Verify scene reconstruction and object registration, then exercise partial writes, corrupt sidecars and classic/mod compatibility.
- **MOD — Modding and extensibility** — Static decomposition complete. All 16 features are unreviewed for design. See [MOD feature catalog](systems/MOD_FEATURE_CATALOG.md).
- **MOD review priority** — Verify dependency ordering, conflicts across extension registries, lifecycle callbacks and save behavior with representative packages.
- **DEV — Diagnostics, authoring and tests** — Static decomposition complete. All 14 features are unreviewed for design. See [DEV feature catalog](systems/DEV_FEATURE_CATALOG.md).
- **DEV review priority** — Verify startup and quest diagnostics, an enemy fixture, world export and package test discovery. Gameplay automation and external CI remain unverified.

## Architecture evaluation

- **CORE — Runtime coordination** — Static architecture review complete for CORE-001 through CORE-021. See [CORE architecture review](architecture/CORE_ARCHITECTURE_REVIEW.md). CORE-AR-01 through CORE-AR-06 remain Proposed as full architecture proposals; explicit feature approvals do not approve every proposal wholesale. Feature review disposition is complete: 19 specifications approved, CORE-009 deferred and CORE-014 outside current scope. Documented owner/design/verification dependencies remain open; implementation has not begun.
- **CORE verification** — Exercise native/classic entry failures, overlapping pause and UI transitions, scene re-entry and lifecycle callbacks. Measure classic cadence and threat-query costs before tuning. Classic fixtures, runtime checks and mod compatibility remain open.

- **DATA — Content and localization** — Static architecture review complete for DATA-001 through DATA-024. See [DATA architecture review](architecture/DATA_ARCHITECTURE_REVIEW.md). DATA-AR-01 through DATA-AR-06 are Proposed.
- **DATA verification** — Test source precedence and provenance, stable references, localization round-trips and sequential save restoration of world variants. Classic archive fixtures, effective mod and locale combinations, startup timing and resource memory measurements remain open.

- **CHAR — Character and progression** — Static architecture review complete for CHAR-001 through CHAR-023. See [CHAR architecture review](architecture/CHAR_ARCHITECTURE_REVIEW.md). CHAR-AR-01 through CHAR-AR-06 are Proposed.
- **CHAR verification** — Exercise creation backtracking, practice thresholds, pending rewards, training settlement, legacy restores and survival sequencing. Runtime and classic parity checks remain open.

- **RULE — Shared formulas and randomness** — Static architecture review complete for RULE-001 through RULE-028. See [RULE architecture review](architecture/RULE_ARCHITECTURE_REVIEW.md). RULE-AR-01 through RULE-AR-05 are Proposed.
- **RULE verification** — Verify random sequences and override priority, then exercise attack effect order, resistance scaling, economy catch-up and classic naming. Runtime and classic parity checks remain open.

- **MOVE — Player movement and interaction** — Static architecture review complete for MOVE-001 through MOVE-027. See [MOVE architecture review](architecture/MOVE_ARCHITECTURE_REVIEW.md). MOVE-AR-01 through MOVE-AR-05 are Proposed.
- **MOVE verification** — Exercise action delivery, alternate motor handoffs, platform and fall behavior, activation priority and placement failures. Physics fixtures, profiling and classic parity checks remain open.

- **COMBAT — Combat and damage** — Static architecture review complete for COMBAT-001 through COMBAT-021. See [COMBAT architecture review](architecture/COMBAT_ARCHITECTURE_REVIEW.md). COMBAT-AR-01 through COMBAT-AR-05 are Proposed.
- **COMBAT verification** — Exercise commitment and interruption, projectile attribution and target deduplication, hit effect ordering, surrender, and quest-linked corpse persistence. Runtime, profiling and classic parity checks remain open.

- **MAGIC — Magic and effects** — Static architecture review complete for MAGIC-001 through MAGIC-030. See [MAGIC architecture review](architecture/MAGIC_ARCHITECTURE_REVIEW.md). MAGIC-AR-01 through MAGIC-AR-05 are Proposed.
- **MAGIC verification** — Exercise cast commitment, defense scope, round catch-up, effect restoration, crafting settlement and transformation cleanup. Runtime, profiling and classic parity checks remain open.

- **ITEM — Items and equipment** — Static architecture review complete for ITEM-001 through ITEM-025. See [ITEM architecture review](architecture/ITEM_ARCHITECTURE_REVIEW.md). ITEM-AR-01 through ITEM-AR-05 are Proposed.
- **ITEM verification** — Exercise stack/transfer identity, duplicate unequip dispatch, repair timing, item-use precedence and provenance through save/load. Runtime, profiling and classic parity checks remain open.

- **NPC — Population, AI and dialogue** — Static architecture review complete for NPC-001 through NPC-024. See [NPC architecture review](architecture/NPC_ARCHITECTURE_REVIEW.md). NPC-AR-01 through NPC-AR-05 are Proposed.
- **NPC verification** — Exercise pool lifecycle, stable actor references, perception and navigation, questor selection and dialogue restoration. Runtime, profiling and classic parity checks remain open.

- **QUEST — Quest execution and selection** — Static architecture review complete for QUEST-001 through QUEST-023. See [QUEST architecture review](architecture/QUEST_ARCHITECTURE_REVIEW.md). QUEST-AR-01 through QUEST-AR-05 are Proposed.
- **QUEST verification** — Exercise offer validation, scheduled starts, task ordering, resource binding and fault recovery through save/load. Runtime, profiling and classic parity checks remain open.

- **FACT — Factions, guilds and reputation** — Static architecture review complete for FACT-001 through FACT-018. See [FACT architecture review](architecture/FACT_ARCHITECTURE_REVIEW.md). FACT-AR-01 through FACT-AR-05 are Proposed.
- **FACT verification** — Exercise propagation, alliance capacity, political catch-up, rank gates, service benefits and membership restoration. Runtime, profiling and classic parity checks remain open.

- **LAW — Crime and legal response** — Static architecture review complete for LAW-001 through LAW-016. See [LAW architecture review](architecture/LAW_ARCHITECTURE_REVIEW.md). LAW-AR-01 through LAW-AR-04 are Proposed.
- **LAW verification** — Exercise crime suppression and standing, delayed pursuit, surrender rejection, severe punishment reachability, sentence release and legal state restoration. Runtime, profiling and classic parity checks remain open.

- **ECON — Economy and services** — Static architecture review complete for ECON-001 through ECON-019. See [ECON architecture review](architecture/ECON_ARCHITECTURE_REVIEW.md). ECON-AR-01 through ECON-AR-04 are Proposed.
- **ECON verification** — Exercise quote changes, partial settlement, direct bank input boundaries, loan deadlines, deed and rental ownership, and service restoration. Runtime, profiling and classic parity checks remain open.

- **WORLD — Overworld streaming and exploration** — Static architecture review complete for WORLD-001 through WORLD-018. See [WORLD architecture review](architecture/WORLD_ARCHITECTURE_REVIEW.md). WORLD-AR-01 through WORLD-AR-05 are Proposed.
- **WORLD verification** — Exercise rebase and arrival ordering, tile reuse and cleanup, terrain seams, location events and discovery restoration. Runtime, profiling and classic parity checks remain open.

- **LOC — Locations, interiors and dungeons** — Static architecture review complete for LOC-001 through LOC-020. See [LOC architecture review](architecture/LOC_ARCHITECTURE_REVIEW.md). LOC-AR-01 through LOC-AR-04 are Proposed.
- **LOC verification** — Exercise layout reconstruction, marker matching, action chains, mid-motion restoration and automap identity. Runtime, profiling and classic parity checks remain open.

- **TIME — Time, environment and travel** — Static architecture review complete for TIME-001 through TIME-018. See [TIME architecture review](architecture/TIME_ARCHITECTURE_REVIEW.md). TIME-AR-01 through TIME-AR-04 are Proposed.
- **TIME verification** — Exercise calendar boundary crossings, catch-up order, weather restore, rest interruption and travel settlement/arrival. Runtime, profiling and classic parity checks remain open.

- **UI — Interface and player-facing flows** — Static architecture review complete for UI-001 through UI-021. See [UI architecture review](architecture/UI_ARCHITECTURE_REVIEW.md). UI-AR-01 through UI-AR-04 are Proposed.
- **UI verification** — Exercise modal and focus lifecycle, queue overflow, replacement contracts and owner outcomes across major flows. Runtime, profiling and classic parity checks remain open.

- **AV — Rendering, audio and presentation** — Static architecture review complete for AV-001 through AV-013. See [AV architecture review](architecture/AV_ARCHITECTURE_REVIEW.md). AV-AR-01 through AV-AR-05 are Proposed.
- **AV verification** — Exercise composition and environment transitions, action cue timing, MIDI/clip fallback and cinematic teardown. Runtime, profiling and classic parity checks remain open.

- **SAVE — Saving, loading and persistence** — Static architecture review complete for SAVE-001 through SAVE-018. See [SAVE architecture review](architecture/SAVE_ARCHITECTURE_REVIEW.md). SAVE-AR-01 through SAVE-AR-04 are Proposed.
- **SAVE verification** — Exercise interrupted publication, operation overlap, restore failures and readiness, object identity, mod payload recovery and classic import. Runtime, profiling and classic parity checks remain open.

- **MOD — Modding and extensibility** — Static architecture review complete for MOD-001 through MOD-016. See [MOD architecture review](architecture/MOD_ARCHITECTURE_REVIEW.md). MOD-AR-01 through MOD-AR-05 are Proposed.
- **MOD verification** — Exercise dependency ordering, entry-point failures, registry conflicts, asset lifetime and missing or renamed save providers. Runtime, profiling and compatibility fixtures remain open.

- **DEV — Diagnostics, authoring and tests** — Static architecture review complete for DEV-001 through DEV-014. See [DEV architecture review](architecture/DEV_ARCHITECTURE_REVIEW.md). DEV-AR-01 through DEV-AR-04 are Proposed.
- **DEV verification** — Exercise diagnostic fallback, command conflicts, fixture isolation and editor export round trips. Runtime, editor and gameplay test coverage verification remain open.

## Cross-system architecture analysis

- **Prompt_4** — Static synthesis complete across the 21 catalogs and architecture reviews. See [global review](architecture/GLOBAL_ARCHITECTURE_REVIEW.md), [proposed boundaries](architecture/PROPOSED_SYSTEM_BOUNDARIES.md), [decision register](architecture/ARCHITECTURAL_DECISIONS.md) and [detailed dependencies](04_DETAILED_DEPENDENCIES.md).
- **Decision status** — The subsequent roadmap review approved GAD-01 through GAD-12 on 2026-11-18. See the [approved decisions](architecture/ARCHITECTURAL_DECISIONS.md#approved-decisions) and [remaining implementation gates](../development/IMPLEMENTATION_READINESS.md). Independent system proposals retain their recorded scope and status.
- **Coverage** — Typed dependency graphs, persistent ownership, identity/lifecycle, communication, restore sequencing, risks and conditional concurrent development domains are documented. Runtime traces, classic fixtures, mod combinations and performance remain open. Implementation task generation has not begun.
