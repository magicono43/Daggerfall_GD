# DATA-012 — Quest script and table sources

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Supply identifiable, validated quest scripts, selection lists and shared tables to QUEST and other consumers. Preserve source provenance, explicit overrides and truthful failure without conflating source discovery with quest acceptance or execution.

## Intended player experience

Validated quest packs contribute intended content without accidental filename replacement or duplicate-list weighting. Unsupported executable content is identified before being offered as usable. Loading changed content does not silently restart quests, erase progress or repeat rewards.

## Confirmed requirements

DATA-012-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm stable domain IDs/classic mappings and explicit add/replace semantics; DATA/QUEST ownership boundaries and side-effect-free reads/validation; differentiated source failures and required validation; controlled list duplicates; unsupported-command rejection; and explicit save compatibility for active and durable quest records.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Questing/QuestMachine.cs#GetQuestSourceText` and `GetTableSourceText` read loose files under the corresponding StreamingAssets directories, adding a .txt extension when absent. Missing files log and return empty arrays. These helpers alone do not establish a complete mod resolution policy.
- `QuestMachine` initializes shared tables for variables/messages, places, sounds, items, factions, foes, diseases and spells. A source comment notes tables are not exclusively quest-owned.
- `Game/Questing/QuestListsManager.cs#DiscoverQuestPackLists` recursively discovers loose list files and registers contributed mod lists. `LoadQuestLists` loads classic/DFU lists and discovered/registered lists. Entries carry quest source/name, group, membership/requirement and one-time/adult flags.
- `QuestListsManager#LoadQuest` checks a loose path before asking ModManager for a quest asset by filename, then parses it. List discovery, list loading and script loading are separate paths with differing context.
- The existing QUEST architecture review traces parser action matching that can log and ignore unmatched lines. This is reference behavior, not the intended unsupported-command policy. Full parser compatibility and command inventory remain QUEST work.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Pack ordering across complete installations, localization coverage and representative runtime scripts were not tested. Source remains unchanged.

## Detailed rules and behaviors

### Identity and source resolution

Use stable, domain-scoped IDs for quest definitions, lists and shared tables, with explicit classic-name mappings. Distinguish a definition from a running quest instance. Display names, filenames and list positions alone must not determine durable identity. New quests and explicit replacements are distinct operations; unrelated pack resources must not accidentally replace one another solely through matching basenames.

Apply DATA-003's logical domain/path identity, package provenance, declared add/replace/patch semantics, deterministic precedence and whole-contribution rejection. A package deliberately targeting an existing logical resource uses the declared replacement/patch contract. Duplicate-ID additions and ambiguous legacy references remain invalid rather than implicit overrides.

Per-type owners must define supported list/table operations and record keys. This feature does not approve arbitrary line-level script merging, deep merging of executable code or a universal table schema. A text file being readable is not proof the resolved script/table is usable.

Resolve candidate contributions during DATA-003's editable pre-menu configuration stage and retain its lock after actual main-menu entry. Rebuild sources, provenance and validation results coherently when candidate order/enabled mods change. External edits and active source changes retain approved restart rules; reading an active quest must not silently adopt unvalidated changed code.

### Ownership and validation

DATA owns source resolution, provenance and delivery. QUEST owns script grammar, semantic validation, eligibility, selection and execution. Shared tables may also require domain-owner reference checks. Reading or validating sources must not start quests, grant rewards, select randomized live resources or mark one-time acceptance.

Differentiate missing, unreadable, empty and malformed/unsupported sources. Empty data is not automatically valid or invalid for every type: the declared schema determines whether emptiness is permitted, and its result remains distinct from a missing file. Required referenced scripts/tables must validate before publication as usable, with QUEST supplying grammar/semantic checks and relevant owners validating required references.

Unrecognized executable commands fail validation rather than being ignored. Comments and explicitly supported optional constructs remain valid. Custom commands require registered QUEST/MOD support before validation succeeds. Exact registration, grammar disambiguation, safe validation interfaces and executable-provider lifecycle remain owner dependencies.

Preflight validation must be side-effect-free. It establishes the statically checkable contract, not a guarantee that all future runtime resources are available or every execution path succeeds. QUEST must define deferred runtime checks and truthful failure where values depend on the current character/world. No arbitrary random draws or resource allocation during validation may be mistaken for committed quest generation.

Invalid contributions follow DATA-003's whole-contribution rejection and explicit recovery. Continuing without a contribution requires a valid remaining configuration; required startup content cannot simply be relabeled optional to bypass failure. DATA-002 required source/index gates remain binding. A failed script must not publish as an empty successful quest.

### Lists and selection metadata

Reject duplicate entries for the same quest within one selection list unless QUEST explicitly defines a supported weighting or variant mechanism. Allow deliberate inclusion in different lists. Exact entry identity and variant representation must be documented; source duplication is not implicit weighting.

DATA delivers list metadata and references. QUEST/FACT and other owners decide eligibility, selection probabilities, one-time interpretation, adult-content behavior and offer routing. Inclusion in multiple lists does not itself authorize multiple rewards or repeated one-time acceptance. Combined-pool deduplication/weighting remains a QUEST contract rather than an invented global rule here.

Startup-list membership does not by itself make every quest mandatory. CORE-012/QUEST define startup registration, requiredness, ordering and immediate presentation. Validation must preserve those distinctions without running startup content.

### Changed content and saves

SAVE/QUEST validate compatibility of changed definitions with active quests and persistent one-time/completion records. Keeping a quest ID does not establish compatibility when task/resource structures or semantics change. Require explicit supported migration or a failure outcome; do not silently restart a quest, lose progress, clear acceptance history or grant rewards again.

Legacy names map explicitly to definitions where supported; missing/ambiguous mappings are failures rather than name guessing or filename substitution. Exact task/resource identity, source version/snapshot handling and migration schema remain SAVE/QUEST dependencies. This feature does not approve classic/DFU save import or prescribe every saved quest representation.

## Relevant formulas and parameters

No quest weights, eligibility thresholds, selection RNG, deadline formulas, reward quantities or list size limits are approved here. Duplicate handling is structural unless QUEST explicitly approves a weighting/variant schema. Existing classic/DFU list fields are content/schema evidence, not automatic approval of every gameplay rule.

## Required data

Stable quest/list/table IDs and explicit classic-name mappings; logical paths/package identity; source text and provenance; list entries and supported metadata; table schemas and domain references; supported command registry context; source/semantic validation results; compatibility identity where owners require it. Running task/resource state and persistent acceptance/completion remain QUEST/SAVE-owned. Complete schemas and required/optional classifications remain dependencies.

## Inputs, outputs and events

Inputs: shipped and mod/loose scripts/lists/tables, candidate configuration, source queries and owner validation outcomes. Outputs: resolved validated source/metadata with provenance or explicit missing/unreadable/empty/invalid/unsupported results. These are conceptual contracts, not concrete APIs/signals. Source-ready is not quest-started, accepted, completed or rewarded; those committed outcomes remain QUEST-owned.

## Cross-system interactions

- DATA-001/002 retain source/readiness/failure contracts. DATA-003 supplies precedence, contribution atomicity and pre-menu lock.
- DATA-004/005 provide location/marker identities; DATA-007–011 provide actor, class, faction, item and spell references where quest tables use them. Ambiguous legacy spell references require DATA-011 context rather than arbitrary collision selection.
- QUEST owns grammar/semantics, instantiation, selection, task/resource execution and runtime failure. FACT supplies faction/guild eligibility inputs under its own rules. MOD/QUEST own command providers and package dependencies.
- CORE-012 retains required opening initialization and optional tutorial bypass, ordered startup/presentation and duplicate protection. DATA validation does not execute those flows.
- UI/text owners handle presentation/localization without changing quest identity or assuming a translated script is mechanically equivalent. SAVE/QUEST restore active and durable history under CORE-013 compatibility/recovery.

## Edge cases and failure conditions

- Two packages contain the same basename at unrelated logical identities: no accidental replacement. Intentional override follows explicit DATA-003 targeting.
- Required source absent/unreadable, or empty where schema requires content: report the actual failure; do not return successful empty quest data.
- One executable line is unsupported: fail validation rather than publish the remaining script as complete. Supported comments/optional syntax remain permitted.
- List repeats a quest: reject unless supported weighting/variant semantics explicitly allow it. Appearance in separate lists remains permitted with combined selection policy owned by QUEST.
- A contribution references missing faction/item/spell/location content: required reference validation fails with source context rather than silently dropping the entry.
- Static validation succeeds but runtime world binding later fails: QUEST reports its runtime failure; DATA does not promise universal execution success or automatically select a replacement quest.
- Repeated candidate rebuilds: do not accumulate registrations, stale sources or duplicated list entries. Validation must not mark one-time quests accepted.
- Changed/removed active definition or history reference: explicit compatibility/migration or failure, without progress loss, silent restart or repeated rewards.

## Configuration and balancing options

Validated pack additions/replacements and supported list/table operations follow declared schemas. No ignore-unknown-command mode or automatic invalid-script skipping is approved. Quest selection, eligibility and balancing settings remain QUEST/FACT/domain decisions. Supported runtime mod settings do not unlock the active definition plan.

## Save/load considerations

Persist stable definition references and owner-defined active quest/history state. Source catalogs and derived candidate lists are reusable content rather than character acceptance records. Loading does not rerun fresh startup quests or clear one-time/completion history to accommodate changed content. SAVE/QUEST must define source/task/resource versions, snapshots if needed and explicit migrations; same ID alone does not certify compatibility.

## Technical constraints

Target engine: Godot 4.7.2. Separate source resolution, side-effect-free grammar/reference validation, quest instantiation and execution. Keep inputs read-only and validation publication coherent. Do not rely on basename-only mod lookup, filesystem enumeration order or logged-and-ignored executable lines as authority. Concrete parser/registry/schema, localization compatibility and source/cache representation remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Stable domain IDs and classic mappings distinguish new quests from explicit replacements without accidental basename collisions.
2. Resolution follows DATA-003 ordering/atomicity/provenance and pre-menu lock; repeated rebuilds do not retain stale or duplicated sources.
3. Reads/validation never start quests, grant rewards or mark one-time acceptance. QUEST owns grammar, semantic validation, selection and execution.
4. Missing, unreadable, empty and malformed/unsupported results remain distinguishable; required sources/references validate before usable publication.
5. Unknown executable commands fail; comments and explicitly supported optional syntax remain valid. Custom commands require registered support.
6. Same-list duplicate quests fail absent an explicitly supported weighting/variant mechanism; deliberate inclusion in different lists is allowed.
7. Required startup content and optional tutorial behavior retain CORE-012 policies rather than treating every listed startup quest as mandatory.
8. Active quest and persistent one-time/completion compatibility require explicit validation/migration or failure, without silent restart, progress loss or repeated rewards.
9. Validation does not claim all runtime bindings will succeed. Actual failures remain owner-controlled; original sources remain unchanged.
10. Representative pack collision, missing/empty/invalid command, duplicate-list, side-effect isolation and changed-save fixtures verify these contracts before implementation is complete.

These are future verification criteria. No implementation, original-data fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–011 and approved CORE startup/load contracts, especially CORE-012/013. No contradiction identified. Required validation strengthens source usability without executing quests or assuming future runtime binding success. List duplicate rejection does not invent selection probabilities. DATA-003's explicit recovery retains required opening content and optional tutorial policy. Stable spell/faction/location references remain governed by their domain mappings and ambiguity checks.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: complete source/table/list schemas; stable/classic mapping conventions; supported per-type operations; QUEST grammar/semantic validation and side-effect-free custom command interfaces; static versus runtime reference checks; combined-pool duplicate/weighting policy; localization/source compatibility; provider lifecycle; startup registration integration; SAVE source/task/resource/history compatibility/migrations and representative fixtures. These deferrals do not waive explicit failures, duplicate controls or history preservation.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-012-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including source schemas, QUEST validation/provider rules, selection behavior and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.
