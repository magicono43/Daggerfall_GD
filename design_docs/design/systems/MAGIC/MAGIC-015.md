# MAGIC-015 — Enchantment creation and capacity

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Compose eligible item powers/drawbacks within explicit capacity and dependency rules, then commit payment and one item's enchantment state without changing unrelated properties or replaying triggers.

## Intended player experience

Players see powers, drawback credits, forced requirements, occupied capacity and price before confirming. Default creation uses an eligible unequipped unenchanted item, ten entries and material-based capacity. Drafts persist without changing items. Mods can change supported limits, pricing/eligibility and composition or safely add re-enchanting profiles. Created spell-bearing items retain their actual selected contents.

## Confirmed requirements

MAGIC-015-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm capacity/drawback accounting, dependency visibility/ownership, stable once-only creation, baseline boundaries/eligibility/limits, persistent drafts, separate price/capacity, custom payloads, shared forced entries, equipped-item policy and native item preservation. The complete specification is approved under MAGIC-015-A01.

RULE-018 capacity/cost purposes and MAGIC-001 explicit crafting eligibility remain binding. ITEM owns identity/condition/access, ECON service price/access and MAGIC-016 triggers/ongoing enchantment resources. Family-specific power/cost inventories are not automatically approved.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete power/forced-set/runtime failure fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/`.

- `UserInterfaceWindows/DaggerfallItemMakerWindow.cs#EnumerateEnchantments` queries item-maker-eligible effect templates and separates positive-cost powers from nonpositive side effects. GetTotalEnchantmentCost combines both lists; GetTotalGoldCost uses power-list gold cost×10.
- `SortForcedEnchantments` resolves required entries and associates a parent hash. Forced entries participate in ten-entry checks; parent removal removes related forced entries. Hash association is not a required native dependency identity scheme.
- `EnchantButton_OnMouseClick` checks selected item, entries, funds and capacity, deducts gold, splits one stacked unit, sets enchantments/renames, then clears draft. Checked all-or-nothing failure is not established by this path.
- `AddFilteredItem` excludes already enchanted items/potions along with further category rules. Complete eligible-item inventory requires ITEM/content review.
- `Formulas/FormulaHelper.cs#GetItemEnchantmentPower` supplies base/material capacity under the separately approved RULE-018 model.

## Detailed rules and behaviors

### Eligible item and draft

Default accepts only eligible unenchanted unequipped items. An equipped selection fails without automatically unequipping or otherwise changing equipment. ITEM/service owners define supported categories, ownership/quest restrictions and current access; crafting-list presence is not authorization.

Explicit mod profiles may add/re-enchant/replace existing powers or enchant while equipped. Each must define capacity accounting, old-effect cleanup, new activation, condition/charges and source identity. No silent overwrite, free repair/recharge or duplicate activation is permitted. Exact alternative profile schemas remain owner design, not universal permission to modify any artifact/item.

Draft retains exact item reference, selected powers/drawbacks/parameters/name and dependency state through subwindows, service exit/reopen and native saves without reservation/modification. Revalidate on return and flag unavailable items rather than selecting another same-name/template item. Confirm discarding a nonempty draft. Keep original name unless valid replacement supplied; name is not item identity.

### Power selection and dependencies

Only explicitly crafting-eligible supported enchantments are attachable. Validate effect/item compatibility, allowed parameters, duplicate/conflict rules and provider support. Default powers consume capacity; declared drawbacks supply capacity credit. Duplicate drawbacks cannot be stacked for unlimited credit unless a complete explicit validated rule genuinely supports distinct entries.

Required forced powers/drawbacks are visible before confirmation and linked to stable parent selection identities. They cannot be independently removed while required. Removing a parent removes only its dependencies; preserve entries still required by another parent.

A compatible shared forced entry counts once toward slots/cost/credit while retaining all dependency links. Incompatible required parameters fail validation rather than silently merge. Intentionally separate forced instances need explicit policy. Missing dependencies/cycles fail with explanation; no partial forced set can become a valid enchantment.

Default limit ten total actual entries, including forced powers/drawbacks. Validated moddable limit must be supported by editor, validation, costs, execution and saved item data without truncation. Dependency links do not themselves consume extra entry slots beyond the actual counted entries.

### Capacity, credits and price

Use RULE-018 capacity P=base+floor(base×material modifier) with its validated item/material domains and moddable policies. Capacity remains distinct from current condition, charges and occupied points. Zero capacity is valid item data, but default creation requires P>0.

Default creation requires at least one power. Let W be total power point cost and D the total nonnegative declared drawback credit after dependency/deduplication validation. Raw net N=W−D; occupied capacity O=max(0,N). Require O≤P. Excess negative net grants no gold refund, banked points or capacity transfer. Retain raw costs/credits for explanation rather than discarding negative-net provenance.

Eligibility/credit rules may be explicitly modded. Invalid/overflowing arithmetic or unsupported mappings fail rather than clamping malformed data into a valid draft. Occupancy floor is the approved accounting rule, not generic repair of invalid costs. Conflicts/slots remain mandatory even if credits make O=0.

Display W, D, raw net, O, P and final service price separately. Credit does not automatically discount gold. Retain power-based pricing as the baseline service model subject to ECON verification; source×10 coefficient is evidence pending service model verification, not an independently approved universal price formula here. Validated alternative service models supported.

All quotes are deterministic/pure: no charges, souls, gold, RNG, practice or activation. Specific soul-related selections/material requirements need declared owner validation; this draft does not invent soul capture/consumption rules.

### Spell-bearing powers

Retain validated custom/mod spell bundles with explicit trigger and power context, not only classic indexes. Every required effect/settings/provider must be supported. Distinguish attached payload settings from live trigger instances and item resources. Creation previews do not cast powers.

Existing created items cannot silently change when source offers/spells are edited. Preserve resolved settings/provenance and compatibility under DATA/MAGIC save rules. MAGIC-016 defines triggers, condition/charge costs and source snapshot/live inputs; this feature validates attachment eligibility and durable chosen payload. No fixed classic three-effect layout is assumed for supported custom bundles.

### Confirmation and commitment

Capture exact item unit, draft revision, powers/drawbacks/dependencies, name, service and quote. Revalidate eligibility/access, unequipped/default-unenchanted rule, capacity, conflicts, slot count, providers and funds before mutation. Changed quote/draft requires renewed confirmation; list sorting cannot substitute another item/power.

Commit payment and modification once through checked owner operations. Only one unit is enchanted from a stack, preserving legitimate identity lineage under ITEM's split contract without assigning the whole stack enchanted contents. Preserve selected item's identity/unrelated condition/ownership/quest data; do not silently repair, refill or reset unrelated resources. Initialize only new enchantment state under declared rules.

Preparation failure leaves gold/item unchanged and editable draft available. Duplicate confirmation cannot charge, split, create or activate twice. Unexpected partial mutation requires explicit same-operation retained recovery, not blind refund/retry or duplicate item copies. Exact operation receipts/ordering remain implementation scope, not a mandatory generic transaction framework.

Creation success is not automatically a use/strike/break trigger. Explicit equipped-profile activation coordinates cleanup and new capability contribution once, coherently under MAGIC-009/CHAR-011/018 with no transient modifier/capacity loss or charge refresh exploit.

## Relevant formulas and parameters

P=base+floor(base×material modifier) under RULE-018; N=W−D; O=max(0,N). Default P>0, at least one power, O≤P, entry count≤10 including forced entries. Shared compatible forced entry counted once. No new charge/condition formula, crafting reward, universal service price coefficient or material table is selected. Safe validated mod models may change declared eligibility/credit/limits explicitly.

## Required data

Exact item/unit and split lineage; draft/request revision; stable power/drawback/parameter IDs; forced dependency graph/shared-entry ownership; costs/credits/capacity/material policy; item/service eligibility; retained spell payload and power/trigger context; name/quote/funds; committed payment/item/source changes and recovery facts; persisted profile/provider compatibility. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: select/edit/remove power/drawback/item/name, dependency expansion, quote, discard/confirmation, source validity and native restore. Outputs: retained valid/invalid draft with breakdown, one modified item/payment or unchanged failure, explicit partial recovery and optional presentation. Concrete APIs/signals unselected. UI/creation notification cannot independently trigger powers or duplicate payment.

## Cross-system interactions

RULE-018 supplies capacity/valuation purposes; MAGIC-001 provider/craftability, MAGIC-009 source cleanup and MAGIC-016 triggers/resources. ITEM owns unit/split/access/condition/ownership, CHAR live contributions/vital reconciliation; ECON service access/price/payment. DATA/MOD validate profiles/dependencies/overrides. UI scalable draft/breakdown remains pure. SAVE/CORE-013 preserve resolved item enchantments/drafts and compatibility without creation replay.

## Edge cases and failure conditions

- Drawbacks exceed powers: O=0, no transferable credit/refund; power/P/slot/conflict requirements remain.
- Zero-capacity valid item: default craft-ineligible, not corrupt data; explicit profile may differ.
- Two parents same forced entry: one entry/credit/cost with both links; incompatible parameters fail.
- Mod increases slots: no UI/save truncation; cycles/missing forced dependencies still invalid.
- Equipped/already enchanted item: default unchanged rejection; alternative profile must declare coherent effects/resources.
- Stack selected: one exact unit only, no entire-stack enchanting or identity duplication.
- Item/quote changes during prompt: revalidate/renew consent; no same-name substitution or stale-price spending.
- Offer spell changes after creation: retained item payload stable subject compatibility, not rewritten or recharged.
- Technical partial operation: explicit same-operation recovery, not free item, duplicated power or false success.

## Configuration and balancing options

Validated enchantment costs/credits, compatibility, entry limits, eligibility, re-enchant/equipped profiles, forced composition, service pricing and custom payloads are moddable. Exact API/precedence, category inventories and safe bounds remain design dependencies. Default remains stated vanilla-style service with explicit safety/boundary choices. Broad extension support does not approve arbitrary unavailable power, unlimited duplicate credit or live locked-plan changes.

## Save/load considerations

Persist exact draft/item reference and selections without modifying/reserving item. Restore revalidates access/providers/quote without automatic enchantment/payment. Created items preserve resolved powers/drawbacks/dependency/provenance/custom payloads and declared new state; load cannot rerun creation rewards, payment or initial triggers.

Compatibility uses stable IDs plus version/schema checks, not names alone. Pending creation saves only at coherent boundary or with supported once-only recovery facts; otherwise explain safe SAVE admission delay/rejection. Source-effect reconstruction follows MAGIC-009/010 without free refills. Exact split lineage, custom payload migration and profile save schemas remain dependencies. Classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. Stable dependency graph rather than parent hash identity alone; checked item unit/state rather than UI pointer authority; capacity and price separate. Preserve safe arithmetic, coherent owner mutations and scalable mod arrays. Exact graph validation, preparation/commit recovery, split handling and save/API architecture remain technical work. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Default eligible unequipped/unenchanted item, P>0, power present, O≤P and ten-entry rules validate with explicit moddable alternatives.
2. Drawbacks/duplicates/conflicts/shared forced requirements account correctly; cycles/missing/incompatible dependencies fail without partial creation.
3. Required entries visible/parent-linked, independently nonremovable, retained while any parent requires them and counted once when compatible.
4. Pure UI shows capacity and price breakdown without credit-to-gold assumption or resource/trigger mutation.
5. Exact retained confirmation revalidates draft/item/quote, renews consent on changes and commits one payment/one modified unit; failure unchanged.
6. Identity/unrelated properties preserved, no repair/refill/replayed trigger; explicit equipped profiles activate coherently once.
7. Custom retained spell payloads survive offer edits/compatible load without fixed-index truncation.
8. Drafts/native created state restore without automatic payment/creation/reward; partial recovery cannot duplicate items/effects.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved RULE-018, MAGIC-001/009/010 and DATA/CORE native compatibility boundaries plus MAGIC-015-D01–D12. No direct contradiction identified. Zero capacity stays valid arithmetic while creation imposes stricter eligibility. Negative net floor is explicit occupancy policy, not a gold refund or cost repair. Shared dependencies retain source ownership and coherent activation under CHAR rules. Trigger costs/execution remain MAGIC-016 rather than inferred from crafting. Individual cost/category/forced-set and service inventories remain unverified dependencies.

## Outstanding questions

No further blocking creation/capacity player-policy choice is identified. Before implementation is complete: inventory eligible items/powers/costs/conflicts/forced sets; verify service price model and capacity mapping; define new enchantment initialization and safe alternative profiles, item split lineage, graph/shared-removal schemas and custom payload context; integrate MAGIC-016 triggers and coherent native recovery/migrations. These dependencies cannot authorize silent resource reset, duplicate drawback credit, missing forced entries, stale quote payment or trigger replay.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: MAGIC-015-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented item/power/cost inventories, pricing, dependency schemas, item initialization/splitting, trigger integration and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
