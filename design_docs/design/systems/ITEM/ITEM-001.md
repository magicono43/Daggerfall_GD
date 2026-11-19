# ITEM-001 — Template and instance identity

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Distinguish reusable item types from individual possessions so equipment, quest links, effects and persistence refer to the correct item.

## Intended player experience

The same possession remains recognizable through ordinary play and saving. Transfers, modifications and stacking do not duplicate items, lose their special state or redirect actions to a different possession. Content incompatibility produces explicit recovery rather than silent replacement.

## Confirmed requirements

- **ITEM-001-D01:** An individual item retains its identity through transfers, dropping/pickup, equipping, repairs, identification, enchanting and save/load. Genuinely new copies receive new identities.
- **ITEM-001-D02:** Interchangeable items use one identity per stack. A partial split creates a new identity; a merge retains the destination identity. Stack eligibility and preservation of special properties remain ITEM-005 review concerns.
- **ITEM-001-D03:** Each transformation explicitly defines identity behavior. Modifications to the same object preserve identity; consumption followed by creation produces a new identity. No unrestricted template-reset rule is adopted.
- **ITEM-001-D04:** Two distinct restored items claiming the same identity cause an explicit compatibility failure before gameplay entry. Do not silently renumber items and risk redirecting equipment, quest or effect references.
- **ITEM-001-D05:** Destroyed, consumed and merged-away identities are retired without reuse within that saved game's history. Stale requests fail safely. Successful merges report the surviving destination identity to callers.
- **ITEM-001-D06:** Content updates require explicit compatibility decisions for existing items. Changed templates cannot automatically reset condition, enchantments, quest links or other saved instance state. Compatible definition changes apply only where the owning feature permits; incompatible changes require migration or explicit failure. No universal snapshot policy is selected.

- **ITEM-001-D07:** Each live item/stack has exactly one authoritative location or custody. Equipment may reference an inventory item without creating another copy. Transfers preserve identity and avoid loss or duplicate ownership on failure.
- **ITEM-001-D08:** A partial split leaves existing references attached to the original stack. References to merged-away stacks do not silently redirect. A requesting system may deliberately adopt the reported destination identity after validation. Items with references that cannot safely survive merging remain separate under ITEM-005.
- **ITEM-001-D09:** Loading or branching a save preserves saved identities. Pending operations also validate active game/session context; old callbacks cannot modify a newly loaded session merely because item IDs match. Separate save branches need no global item registry.

The user confirmed each of three interviews with “1. Yes / 2. Yes / 3. Yes”. See [the decision log](../../GAMEPLAY_DECISIONS.md).

## Existing Daggerfall Unity behavior — reference only

Sources below are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Items/ItemBuilder.cs#CreateItem` constructs from group/template mappings; `ItemHelper.cs#LoadItemTemplates` loads packaged templates.
- `Game/Items/DaggerfallUnityItem.cs` constructors allocate new UIDs for new items and copies; the serialized-data constructor restores saved identity. `Clone` uses the copying constructor. `SetItem` resets template-based data while retaining UID.
- `Game/Items/ItemCollection.cs#Contains` supports UID membership. `SplitStack` returns the existing item for a full split and creates a new item for a partial split. `AddItem` merges quantity into an existing matching stack; duplicate UID rejection occurs on its nonmerge path. `DeserializeItems` restores without stacking.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; source unchanged.

## Existing approved constraints and dependencies

- DATA-010 requires stable domain-scoped template IDs/classic mappings, separate mutable instance state, validated required providers and explicit saved-item compatibility handling. Names or appearance do not define identity. Retaining a template ID alone does not prove compatibility.
- COMBAT-008 requires stable ammo identity/provenance and per-shot payloads. Stack identity does not remove these obligations or mandate persistent IDs for every interchangeable unit.
- MAGIC source-owned effects and artifact operations must continue to identify the correct source without duplicate activation or cleanup of another source.
- ITEM-005 owns detailed stack eligibility; ITEM-002 owns custom behavior; ITEM-025/SAVE own integrated restoration. Architecture proposals in ITEM-AR-01 remain proposals except where separately confirmed.

## Detailed rules and behaviors

### Definitions and individual items

Resolve reusable definitions through DATA-010's stable domain IDs and explicit classic mappings. Keep template identity, item instance identity, quest-resource identity and operation/session identity distinguishable. Names, textures, list positions and runtime object handles are not substitutes for stable item identity. A type lookup does not create a possession.

Creation or a genuine copy allocates a fresh instance identity. Ordinary modifications and movement preserve it under D01. A transformation must declare whether it modifies the existing object or consumes it and creates another; retaining identity does not authorize resetting unrelated state or replaying effects. Artifact uniqueness, copy eligibility and copied payload rules remain their owners' policies.

### Stacks and reference lifetime

One interchangeable stack has one identity. Partial split retains the original identity on the remainder and creates a fresh identity for the separated quantity; moving the full stack preserves its identity. A permitted merge retains the destination identity and retires the source identity. Quantity/property preservation and eligibility remain ITEM-005/006 integration requirements, including quests, expiry, enchantments and provenance.

Return the surviving identity after merge so callers can validate and deliberately update their own references. Never install a universal silent alias from the retired source to the destination. Existing references stay with the original on split; items whose bindings cannot safely support merging remain separate. A quantity operation must still validate current quantity/access rather than assuming identity proves availability.

Destroying or consuming an item retires its identity. Retired identities are not reused within the saved game's history; stale requests fail safely. A committed projectile or timed effect may retain historical source identity under its approved lifecycle, without resurrecting the item or requiring that historical reference to resolve as a live possession.

### Ownership and scoped operations

Each live item/stack has one authoritative custody/location. Equipment can reference an inventory-owned item; UI selections and previews are references, not additional custody. Repair and other supported custody follow their own access rules. No exhaustive custody schema is selected here.

Transfers preserve identity and report truthful outcomes without item loss or duplicate ownership on failure. Exact commit/recovery machinery remains an integration contract; this does not require a generalized transaction framework. A stable identity alone does not grant access: operations validate current ownership, eligibility and active context.

Preserve IDs across native save/load and save branches. Pending work must also validate session context so an earlier session's completion cannot mutate a restored item with a matching ID. Separate branches can retain the same historical IDs without a global registry; cross-branch item import is not approved by this feature.

## Relevant formulas and parameters

No gameplay balance formula, stack limit, numeric ID width or allocation algorithm is selected. Identity allocation must satisfy fresh-copy creation, retirement and restore/branch rules without collisions. Exact persistence of allocator state or equivalent nonreuse evidence is a technical dependency; an ever-growing tombstone list is not mandated.

## Required data

Stable template ID and relevant classic mappings; item/stack identity; authoritative custody; owner-defined mutable state; quest/effect/provider references where applicable; source/configuration compatibility metadata; active session/operation context for pending work; sufficient allocation/retirement information for nonreuse. Split/merge outcomes identify surviving/new/retired items as applicable. Exact serialization and event schemas remain open.

## Inputs, outputs and events

Inputs: validated definition/creation requests, owner-authorized copy/modification/transformation, split/merge/transfer/consumption and native restore records. Outputs: created or retained identity, checked ownership/quantity outcomes, surviving merge identity and explicit stale/missing/duplicate/incompatible results. Committed notifications describe completed changes; observers cannot repeat creation, transfers or effects. Concrete APIs/signals and operation receipts remain implementation design dependencies.

## Edge cases and failure conditions

- Distinct saved items with one identity: fail compatibility validation before gameplay; never silently renumber. Multiple legitimate references to one item are not duplicate items.
- Retired/missing item selected by a delayed action: reject safely without acting on another item or silently following a merge.
- Failed transfer: preserve truthful custody without loss or duplication; coordinate any already committed owner effects through the applicable recovery contract.
- Split/merge with unsafe quest/effect/expiry bindings: keep separate under owner eligibility rules rather than dropping properties.
- Changed required definition/provider: migrate explicitly or fail; do not substitute a generic item or reset saved condition/enchantments/links.
- Old callback after load, including the same save: reject old session context even when item ID matches.
- Historical source retained by a released effect: apply its approved lifetime rules, independently of live-item lookup.

## Configuration and balancing options

Validated added templates and owner-approved transformations are supported through DATA/MOD contracts. Stack eligibility, balance fields and provider behavior remain their owning features. No configurable relaxation of identity uniqueness, stale-session protection or truthful compatibility handling is approved.

## Save/load considerations

Restore saved identities and state without stacking away distinct records, allocating replacement IDs, replaying item use/equip rewards or regenerating spent properties. Validate duplicate identities, required definitions/providers and owner references before gameplay admission under CORE-013. Changed content follows D06 and DATA-010, with explicit migration or failure for incompatibility. Preserve coherent custody and references; exact dangling-reference recovery remains SAVE/owner work and cannot silently bind a different item.

Retain enough allocation state or equivalent guarantees to avoid reusing retired IDs in the saved history. Loading an earlier save establishes its saved branch state, not a requirement for a registry shared by every branch. New session scope invalidates old pending callbacks. Supported partial-operation persistence and safe save boundaries remain SAVE/owner contracts.

## Technical constraints

Target Godot 4.7.2. Stable item identity must survive scene recreation without depending on engine instance handles or class names. Keep reusable definitions separate from mutable state. Existing ITEM architecture proposals remain proposed except for specifically confirmed behavior. Do not modify the reference source or begin implementation/coding tasks from this specification review.

## Acceptance criteria

1. New copies receive distinct identities; transfer, equip, repair, identification, enchanting and native reload preserve the original identity and applicable state.
2. Partial split preserves original references and creates a fresh separated-stack identity. Full-stack movement preserves identity; permitted merge retains/reports destination identity and retires source identity.
3. Unsafe referenced stacks cannot merge; stale references never silently redirect or act on a new item assigned a retired ID.
4. One authoritative custody exists per live item; equipment/UI references do not duplicate ownership. Failed transfers do not lose or duplicate items.
5. Transformations explicitly declare preserve-versus-consume/create semantics without unrelated state reset or replayed effects.
6. Duplicate restored identities cause explicit pre-gameplay compatibility failure; multiple valid references to one item remain valid.
7. Changed content applies only permitted compatible changes or explicit migration; unsupported definitions/providers fail without silent item substitution/state reset.
8. Native restore/branch preserves IDs without requiring a shared branch registry. Callbacks from an older session cannot mutate restored items with matching IDs.
9. Released projectile/effect historical provenance survives as required by its approved owner contract without resurrecting a retired source item.

## Contradiction review

Reviewed against DATA-010, COMBAT-008, MAGIC-016/027/030 and CORE-013's approved load/source contracts. No direct contradiction identified. Per-stack identity does not replace per-shot ammo provenance. Retirement does not cancel independently released effects. Authoritative custody permits equipment references and avoids MAGIC-027's prohibited temporary ownership transfer merely for Identify selection. Required provider failure follows DATA-010 rather than DFU's generic fallback. This review does not approve ITEM-005/025 or the broader architecture proposals.

## Outstanding questions

No further blocking player-policy choice is identified for this draft. Before implementation is complete: define ID/allocation/session schemas and nonreuse guarantees; custody/transfer outcomes and recovery; stack eligibility, reference and payload preservation; owner-specific transformation/copy policies; required provider/definition compatibility and migrations; native restore/reference validation and fixtures. These dependencies cannot waive confirmed identity, ownership or failure rules.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-001-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented allocation/session schemas, custody/transfer recovery, stack/reference preservation, transformation policies and native compatibility/migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
