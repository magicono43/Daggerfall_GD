# DATA-010 — Item and magic-item templates

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

**2026-11-21 standing clarification:** `PROJECT-DATA-D01` in
[GAMEPLAY_DECISIONS.md](../../GAMEPLAY_DECISIONS.md) permits original or DFU data,
sensible corrections and documented combinations chosen for consistency and
modding. Exact original-value parity is not required. Historical reference-only
wording below does not prohibit adopting suitable DFU content within an authorized
task. Preserve provenance, validation, identities and override precedence.

## Gameplay purpose

Supply validated reusable item and magic-item definitions with stable identity, source mappings and required references for creation, lookup and restoration. Keep imported content separate from item-instance state and domain gameplay rules.

## Intended player experience

Supported classic and validated added items resolve consistently. Renaming or replacing textures does not create a new item identity. Required missing data or behavior produces explicit failure rather than a blank/generic item. Existing saved items are not silently discarded or reset when content changes.

## Confirmed requirements

DATA-010-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish stable domain template IDs/classic mappings; separate templates/instances; supported classic baseline with owner-defined rules; required reference validation; data-only additions and explicit special-behavior providers; and explicit saved-item compatibility/migration outcomes.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `API/ItemsFile.cs#ItemTemplate` includes index/name, base weight, hit points, capacity/target, base price, enchantment points, rarity, variants, flags and world/player texture references. It also has DFU extension fields such as repairability and encumbrance flags. Field presence is not approval of every target rule.
- `ItemsFile.cs#MagicItemTemplate` includes index/name/type, base-item group/index, legacy enchantments, uses, artifact value and material. Classic item/magic-item readers coexist with packaged template loading; their equivalence is not established by that coexistence.
- `Game/Items/ItemHelper.cs#LoadItemTemplates` deserializes a Resources JSON list and merges mod contributions matched by item index. Its comment identifies the data as exported from FALL.EXE. `LoadMagicItemTemplates` loads another list and derives artifact subsets; it does not use the same merge call in that method.
- `ItemHelper#GetItemTemplate` uses classic group/index mappings and custom index handling. Some invalid requests log and return an empty template, which is not the intended required-lookup contract here.
- `RegisterCustomItem` associates custom template indexes with groups and optional C# types, registering class names with `Game/Items/ItemCollection.cs` for deserialization. Definition identity, executable registration and restoration therefore intersect in DFU.
- `LoadBookIDNameMapping` loads packaged book mappings and can discover replacements. Book identity/title/content interpretation remains a separate content concern; this feature does not approve the full book-distribution algorithm.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Packaged-versus-classic data equivalence, all item consumer rules and modified-installation provenance have not been verified. Source remains unchanged.

## Detailed rules and behaviors

### Identity and resolution

Use stable, domain-scoped IDs for item and magic-item templates, with explicit classic index/group mappings. Mod additions must not depend on list positions or uncoordinated numeric ranges. Names and texture changes alone preserve identity. Item-template and magic-item-template domains remain distinguishable even if legacy numbers overlap.

Apply DATA-003's logical source identity, declared add/replace/patch operations, deterministic precedence, provenance and whole-contribution rejection. Duplicate IDs and ambiguous classic mappings are invalid; explicit supported replacement retains the targeted identity. Before normal main-menu entry, validate required resolved definitions/references and publish a coherent set. Repeated pre-menu rebuilds must not accumulate old patches or stale lookup/artifact indexes.

The shared DATA-003 resolver policy is intended behavior, not a claim DFU currently patches both template lists identically. Concrete schemas must define the supported operations for each template domain. Active configuration locks and external-file restart rules remain DATA-001–003 requirements.

### Definitions and instance state

Preserve supported classic template fields and magic-item definitions as the initial baseline with explicit validated overrides. Keep reusable templates separate from each item's quantity, condition, ownership and other mutable state. Definition lookup does not itself create, equip, transfer or enchant an instance.

ITEM/MAGIC determine which fields are copied at creation, derived during use or saved explicitly. Changing a template does not automatically authorize rewriting existing items. Exact balance values, material arithmetic, pricing, equip rules, enchantment behavior, artifact uniqueness and loot distribution remain ITEM/MAGIC/ECON and other owner contracts. Importing rarity or artifact type does not by itself approve a distribution or uniqueness rule.

Appearance references do not determine gameplay identity or behavior by inference. Book mappings and localized titles must retain explicit content references where used, with detailed readable-content behavior owned by the relevant DATA/ITEM/text features.

### Validation and lookup

Validate required base-item, material and enchantment references before publishing definitions. Require supported interpretation of the referenced types and parameters, not merely a matching raw number. Reject malformed or unsupported required data under DATA-002/003 recovery. Exact per-domain field ranges and requiredness remain schema/owner contracts rather than arbitrary positivity checks.

Valid no-enchantment records and zero-valued fields are permitted where the schema allows them. A legitimately empty optional field must remain distinguishable from missing required data. Required lookup failure returns explicit not-found, unavailable or malformed/unsupported context rather than a successful empty template. Do not synthesize a generic item, default material or different enchantment to hide failure.

Optional presentation fallback requires an explicitly approved owner policy, consistent with DATA-007; it cannot disguise missing required gameplay definitions. CORE-012's missing-required-grant failure remains binding, while a legitimately absent grant remains valid under its rules.

### Added items and behavior providers

Allow data-only additions where existing supported behavior is sufficient. Special behavior must explicitly reference a registered, validated provider. Missing required providers fail rather than silently treating the item as generic. Exact behavior-provider identity, compatibility validation, registration and executable lifecycle remain MOD/ITEM contracts; no C# class-name save convention or arbitrary executable-data format is adopted here.

Pre-menu mod data rebuild follows DATA-003 without promising that already-running executable providers can be unloaded. DATA validates provider references against the supported registry contract, while MOD/ITEM must establish safe activation and configuration behavior before integrated support is complete.

### Changed definitions and compatibility

SAVE/ITEM/MAGIC validate saved items when templates are changed or removed. Retaining a template ID alone is insufficient evidence of compatibility. Unsupported changes require a defined migration or explicit failure outcome. Do not match by name, silently discard items, or reset condition/enchantments to make restoration succeed.

The same principle applies to missing required behavior providers during restoration. Source/configuration identity and per-instance state must be available to the owning compatibility checks. This feature does not choose template snapshots, dynamic rebalance of existing instances, migration algorithms or a universal item serialization format.

## Relevant formulas and parameters

No new weight units, price formulas, material multipliers, rarity thresholds, durability limits, enchantment costs, artifact counts or ID ranges are approved. Classic source units/fields must be interpreted explicitly in adapters; final supported schemas and balance remain owner decisions. Zero/no-effect validity follows the declared schema rather than an assumed universal minimum.

## Required data

Stable item/magic-template IDs and classic group/index mappings; supported base fields; explicit material, base-item, enchantment and appearance references; optional behavior-provider key; names/localization/content references; source/package provenance; validation outcomes; derived indexes such as artifact subsets where required. Mutable instance data remains ITEM/MAGIC-owned. Complete schemas, field provenance and provider contracts remain dependencies.

## Inputs, outputs and events

Inputs: packaged/classic-adapted definitions as supported, mod/loose contributions, template/legacy-key requests, reference/provider validation and owner compatibility requests. Outputs: validated templates/mappings, provenance and explicit missing/unavailable/invalid/unsupported results. These are conceptual contracts, not concrete APIs/signals. Successful lookup is not an item-created, equipped, granted or enchanted event.

## Cross-system interactions

- DATA-001/002 retain source access, required readiness and differentiated failures. Packaged templates need explicit provenance rather than an assumption that edits to FALL.EXE automatically affect them.
- DATA-003 supplies declared operations, pre-menu rebuild/validation and run-long lock. DATA-007 appearance separation and DATA-008 biography effect references remain consistent.
- ITEM owns creation, inventory/equipment, ownership, condition and instance semantics. MAGIC owns enchantment interpretation and required spell/effect references. ECON owns pricing/service formulas; loot and artifact owners define distribution/uniqueness.
- CORE-012 applies required startup grants through owners without duplicating rewards. DATA lookup neither awards items nor bypasses grant validation.
- MOD/ITEM own special-behavior registration, identity and code lifecycle. SAVE/ITEM/MAGIC own restored-instance validation and migration. UI/AV own presentation and approved fallbacks.

## Edge cases and failure conditions

- Template list reordered or name/texture changed: stable ID/classic mappings preserve identity; old array positions must not retarget references.
- Add duplicates an ID or legacy mapping becomes ambiguous: reject invalid contribution/configuration, allowing only explicit supported replacement.
- A magic template references a missing base item/material/enchantment: reject required unresolved data rather than creating an unenchanted/default item.
- Zero value or no enchantments is schema-valid: accept it without inventing a requirement for a positive value/effect.
- A custom item has no special behavior requirement: data-only addition is permitted. A required provider is missing/incompatible: explicit failure, not generic substitution.
- Pre-menu rebuild changes template contributors: derived indexes/provenance must reflect the new coherent candidate only.
- Existing saved item points at a changed/removed template/provider: run owner compatibility checks; no silent discard, name match or condition/enchantment reset.
- A required starting grant cannot resolve: retain CORE-012 failure. A legitimate no-grant class is not automatically invalid.

## Configuration and balancing options

Validated additions/replacements/patches follow supported schemas. No player-facing bypass for required references, automatic generic-item recovery or automatic saved-item rebalancing is approved. Supported runtime mod settings retain owner contracts without unlocking the definition plan. Gameplay balancing options remain with their owners.

## Save/load considerations

Persist stable definition references and owner-defined instance state, including required behavior identity where applicable. Template objects, reader handles and derived indexes are reusable content rather than mutable character-save objects. Loads do not change active content configuration or replay starting grants. SAVE/ITEM/MAGIC must define versioning, missing-content recovery and migrations explicitly; this specification neither copies DFU class-name serialization nor chooses a snapshot-versus-live-template policy.

## Technical constraints

Target engine: Godot 4.7.2. Separate parsing/validated definitions, behavior registration, instance mutation and persistence. Original inputs remain read-only. Publish coherent indexes and explicit errors rather than mutable-list positions or successful empty records as authority. Concrete registry, schema, provider API, serialization and cache details remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Stable item/magic-template IDs and explicit classic mappings survive list reordering, renaming and texture changes; mod additions avoid uncoordinated index ranges.
2. Supported classic fields/definitions remain the overridable baseline without implicitly approving balance, equipment, enchantment, artifact or distribution rules.
3. Templates remain separate from mutable instances. Template changes do not automatically rewrite existing items.
4. Duplicate IDs, ambiguous mappings and required unresolved base-item/material/enchantment references fail before coherent publication.
5. Required lookup failures are explicit, while schema-valid zero/no-enchantment records remain valid.
6. Data-only additions use supported behavior. Special items require validated providers; absent required behavior never silently becomes generic.
7. Saved-item template/provider changes require owner compatibility/migration or explicit failure, without silent substitution, discard or state reset.
8. Pre-menu rebuild/lock rules and CORE-012 grant readiness/duplicate protection remain intact; definition reads do not create/grant items.
9. Original sources remain unchanged. Representative original/modded/duplicate/missing-reference/provider and changed-save fixtures verify these contracts before implementation is complete.

These are future verification criteria. No implementation, original-data fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–009 and approved CORE lifecycle/start/load contracts, particularly CORE-012/013. No contradiction identified. Stable template identity follows existing domain identity rules without implying instance compatibility. DATA-003 replacement/precedence does not excuse invalid add collisions or references. Provider validation retains MOD code-lifecycle dependencies; required-grant failure and save restoration remain owner-controlled.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: packaged/classic provenance comparison; full template and legacy-enchantment schemas/mappings; valid ranges/zero/optional-field rules; supported per-domain operations; copy/derive/persist semantics; behavior-provider identity/activation; exact balance/distribution/artifact rules; book-reference boundaries; save versioning/compatibility/migrations and representative fixtures. These deferrals do not waive explicit reference validation or state-preserving failure rules.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-010-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including template schemas, provenance, balance rules, behavior-provider contracts and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.
