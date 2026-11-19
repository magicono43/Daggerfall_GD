# DATA-003 — Loose text and mod data resolution

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Resolve authored text definitions and data patches consistently when shipped content, mods and explicit loose overrides overlap. Support intentional customization while preventing unnoticed invalid or partially applied definitions from changing gameplay rules.

## Intended player experience

Arrange and enable mods within the application before entering the actual game main menu, without repeatedly restarting to adjust data load order. Continue validates the chosen configuration. Valid overrides work without interrupting play; invalid contributions identify their source and require a deliberate recovery choice. The configuration stays stable once the main menu is entered.

## Confirmed requirements

DATA-003-D01–D11 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm domain/path identity with package provenance; shipped defaults → resolved enabled-mod order → explicit loose override priority; per-type replace/add/patch operations; ordinary override diagnostics without blocking popups; whole-contribution rejection with explicit recovery; field and list patch semantics; deterministic within-source ordering; add/patch ID checks; editable pre-menu configuration; and a run-long lock after actual main-menu entry. D10–D11 clarify D09 and replace the proposed blanket restart requirement for pre-menu mod data changes.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Utility/AssetInjection/TextAssetReader.cs#TryRead` reads a loose StreamingAssets relative path first, then asks ModManager for only its basename. Distinct relative paths can therefore submit the same mod lookup. Typed reads delegate deserialization to SaveLoadManager.
- `TextAssetReader#ReadAll` gathers loose files and then mod assets. This method does not explicitly sort loose-file enumeration and returns content strings without source provenance.
- `TextAssetReader#Merge` iterates enabled contributing mods, parses entries, optionally finds an existing record through a caller predicate, and deserializes over that record or a new instance. Successful entries replace or append individually. It does not establish whole-file atomic rejection.
- `Game/Items/ItemHelper.cs#LoadItemTemplates` matches patches by item index; `Game/MagicAndEffects/EntityEffectBroker.cs#RebuildClassicSpellsDict` matches spell records by index. These illustrate existing domain identity, not a universal required schema.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; no runtime or mod-combination tests performed. The source remains unchanged. Other DFU resolution paths may have different policies; this feature does not claim this helper controls every source.

## Detailed rules and behaviors

### Identity, provenance and precedence

Identify a logical resource by domain and relative path. Retain contributing package identity separately, allowing multiple packages to deliberately target the same logical resource. Same basenames in different directories remain distinct. Record identifiers used for entry operations remain domain-scoped stable IDs; preserve compatible intended IDs rather than automatically renumbering them.

Apply shipped defaults first, enabled mods in MOD's resolved load order next, and the explicit loose override folder last. Later sources win where their declared operation permits overriding the same resource or field. An add-ID collision remains invalid rather than being silently converted to replacement. This does not permit silently selecting another classic installation or modifying original files.

Within a source, sort contributing files by normalized relative path and preserve declared entry order inside each file. Later applicable patches win on the same field. Exact normalization, case handling and duplicate normalized-path rejection/handling must be specified before implementation; enumeration order must not determine gameplay.

For ordinary valid overrides, retain contributing-source and winning-source diagnostics without a blocking popup. Field patches may have different winning sources for different fields; provenance must reflect the declared operation rather than imply a single whole-file winner always exists. Exact diagnostic UI remains deferred.

### Declared content operations

Each content type declares its supported operations and schema: replace a whole resource, add entries, or patch existing records by stable ID. It must not infer patch versus replacement solely from an accidental filename collision.

- Whole-resource replacement uses the later valid replacement under the declared order.
- Add requires an unused record ID. A collision is invalid and requires an explicitly supported replacement/other operation.
- Patch requires an existing target ID. A missing target is invalid; patching does not implicitly add a new record.
- Omitted patch fields retain previous values; supplied fields replace values. Later patches win for the same field.
- Lists replace as a whole unless the content type explicitly supports list merging. Deletion requires an explicit supported operation.

Per-type owners must define schemas, references, null semantics, nested-field behavior, list-merge behavior if supported, and any record-replacement/deletion operation. This specification does not invent one universal deep-merge or deletion schema.

### Validation and rejection

Resolve contributions into a candidate definition set and validate before publishing it for normal use. Reject an invalid file or patch as a whole; no partial application survives from that rejected contribution. Validate remaining cross-record and cross-contribution references so individually valid entries do not publish an invalid combined result.

Report invalid contributions visibly with source and reason. Require the player to fix/remove the contribution or explicitly choose to continue without it, only if the remaining content validates. Do not automatically skip invalid input or silently fall back to earlier content. Removing one contribution may reveal another candidate or break dependents; rebuild and revalidate before continuing. Explicit omission is allowed only when required content and dependency contracts remain satisfied. Required-reader/source failure retains DATA-001/002 recovery and cannot be bypassed by labeling it an optional patch.

Atomic rejection is the file/patch contribution boundary, not an approval to disable an entire mod silently. MOD owns package dependencies and executable behavior; where removing a data contribution leaves a mod's requirements unsatisfied, continuing without it must not publish that invalid combination.

### Pre-menu configuration and activation

Provide an in-application mod-configuration stage before actual game main-menu entry. Allow changes to enabled mods and their order in this stage. Keep those changes pending until Continue rebuilds and validates the resolved definitions. Failed validation retains configuration/recovery rather than entering the normal main menu. Pre-menu data reordering and enable/disable changes do not require restarting the application.

Entering the actual game main menu locks enabled-mod selection and order for the rest of the application run, including returning from gameplay and changing characters. Restart is required to enter the editable configuration stage again. Supported individual mod settings may change in-game under their own feature contracts; they do not implicitly authorize changing the locked definition-resolution plan.

External changes to classic files or loose overrides require application restart. No live override reload or continuous monitoring is approved. The explicit pre-menu mod-data rebuild is distinct from replacing active classic readers: DATA-001/002 and CORE-004 still require restart for classic-source changes. Keep package-specific candidate definitions separate from application classic-reader state and invalidate affected candidate definition caches during rebuild so old order results cannot leak into a new candidate.

Executable-mod registration, unloading, discovery/dependency resolution, and any additional activation/restart constraints are MOD-owned dependencies. DATA-003 authorizes rebuilding data contributions before main-menu entry; it does not promise unloading already-running mod code. Exact configuration-stage navigation/default presentation remains CORE/UI/MOD integration scope and must preserve approved startup preferences and mandatory recovery.

## Relevant formulas and parameters

No gameplay formulas or numerical balancing values apply. Deterministic precedence is shipped defaults → resolved enabled-mod order → explicit loose overrides; within-source order is normalized relative path then declared entry order. Later applicable values win subject to operation validation. No generic load timeout, maximum package count or fixed schema version is selected here.

## Required data

Logical domain/path keys; package/source identity; resolved enabled-mod order; pending versus locked configuration; explicit loose-override root; per-type schema and operation policy; stable entry IDs; candidate and published definitions; contribution/field provenance where relevant; validation failures and explicit omit choices for the current resolution attempt. Exact root location, schemas, normalization and persistence representation remain dependencies.

## Inputs, outputs and events

Inputs: shipped data, enabled mod contributions/order, loose overrides, queries/collection requests, configuration edits, Continue, validation results and explicit recovery choices. Outputs: validated resolved text/definitions and provenance, differentiated missing/unreadable/invalid results, rejected contributions and reasons, and candidate-validation/locked-configuration outcomes. These are conceptual contracts, not approved API or signal names. Failed resolution is not successful empty/default data.

## Cross-system interactions

- DATA-001/002 retain source validation, read-only classic access, required-reader readiness and failure categories. Data-plan rebuild does not live-switch classic sources.
- MOD supplies package identity, discovery, dependency-aware resolved order and code lifecycle contracts. This specification consumes the resolved order without choosing a dependency solver or executable sandbox.
- ITEM, MAGIC, QUEST, FACT and other content owners define their schemas, stable IDs, operations and reference validation. Localization and media features must explicitly adopt applicable policies rather than be assumed to use this generic helper.
- CORE/UI/MOD integrate the pre-menu configuration stage with approved setup/main-menu routing. CORE-003 supplies settings persistence where applicable; exact load-order persistence and omission-choice retention are not approved here.
- CORE-002 owns optional diagnostics and privacy filtering. Diagnostic provenance is independent of whether a log file can be written.
- SAVE owns compatibility with resolved definitions and missing-content recovery; a valid data plan is not proof a particular save can load.

## Edge cases and failure conditions

- Two packages target the same logical resource: use declared operation/order, retaining provenance. Identical basenames in separate logical directories do not collide.
- Two additions reuse one ID, or a patch targets no existing record: reject the invalid contribution as a whole. Later-source precedence does not excuse the invalid operation.
- An early entry succeeds but a later entry in the same contribution fails: none of that contribution's mutations publish.
- Explicitly skipping a patch reveals an older value or breaks a dependency: rebuild/revalidate the remainder before offering successful continuation.
- An optional query has no contribution: report absence distinctly from a malformed file; the consuming feature decides whether absence is permitted.
- Repeated pre-menu edits/rebuilds must not accumulate old patches, stale provenance or duplicate entries. Resolve from the appropriate clean base, not already patched results.
- Returning from gameplay to the main menu does not unlock mod order or enabled-mod changes. Supported in-game settings do not override the lock.
- External files change after reading: no coherent live snapshot is promised; actual failures remain failures and restart is required for supported adoption of edits.

## Configuration and balancing options

Players may change order/enabled mods before entry and deliberately omit an invalid contribution only when the remaining configuration is valid. There is no approved switch for silent skipping, arbitrary strictness or changing precedence during gameplay. Content changes can alter balance, but balance formulas and permitted values remain domain-owned.

## Save/load considerations

Resolved definitions and provenance are application content, separate from mutable character state. Loading a character cannot change the locked mod order or activate external edits. SAVE/MOD must define saved package/content identity and compatibility checks. Pending order persistence, omission-choice lifetime across restart, and replay of earlier configurations remain explicitly deferred; no automatic migration or permanent mod disablement is inferred.

## Technical constraints

Target engine: Godot 4.7.2. Keep deterministic resolution, schema validation, contribution staging and provenance separate from gameplay mutation and executable-mod activation. Do not rely on filesystem enumeration order, basename-only lookup or SaveLoadManager coupling to establish content semantics. Original source data remains unchanged. Concrete parser, normalized-key representation, error/result APIs and UI resources remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Logical domain/path identity distinguishes same-basename resources in different directories and retains package provenance.
2. Resolution follows shipped defaults, resolved enabled-mod order, then explicit loose overrides, with deterministic within-source file/entry order.
3. Per-type replace/add/patch semantics are explicit. Later applicable values win; add collisions and missing patch targets fail.
4. Omitted fields retain values, supplied fields replace them, and lists replace unless a declared list-merge policy applies. Deletion requires an explicit supported operation.
5. Valid overrides cause no blocking popup; contributing/winning sources remain diagnosable, including field-level patch winners where relevant.
6. Invalid contributions publish no partial changes. Visible source/reason and explicit recovery precede any continuation without the contribution; remaining required content and dependencies validate.
7. Pre-menu enable/disable and order edits remain pending until Continue rebuilds/validates, without application restart for these data changes. Failure retains configuration.
8. Rebuilding repeatedly does not retain previous candidate mutations or stale provenance. Actual main-menu entry locks mod selection/order for the rest of the run.
9. Returns from gameplay do not unlock configuration. Restart is required for locked-plan changes and external classic/loose edits; supported individual settings retain owner-defined runtime behavior.
10. Classic-reader/source restart rules, required startup gates and optional-media policies remain intact. Executable-mod lifecycle limits are resolved under MOD before claiming complete integrated support.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved DATA-001/002, CORE-004 startup/source activation, CORE-005 application/session ownership, CORE-006 preference application, and the recorded DATA-003 decisions. No direct contradiction identified. Pre-menu data rebuild is an explicit user-approved exception to a proposed blanket restart rule for mod order, not an exception to approved classic-source restart rules. Returning to the actual main menu remains locked. Configuration-stage navigation and executable activation are documented cross-owner dependencies, not assumed completed interfaces. Existing source architecture recommendations remain proposals.

## Outstanding questions and approval

No further blocking player-policy choice is identified for DATA-003's resolution behavior. Dependencies before implementation is complete: per-type schemas/operations and reference checks; normalized path/case rules and ambiguous-key handling; explicit loose-root location; MOD discovery/order/dependency and executable activation contracts; CORE/UI configuration-stage integration; settings persistence and omission-choice retention; SAVE compatibility. These deferrals do not waive deterministic resolution, explicit invalid-data recovery or the approved configuration lock.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-003-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including content schemas, executable-mod lifecycle and configuration UI integration. Approval does not initiate implementation, coding tasks or another feature review.
