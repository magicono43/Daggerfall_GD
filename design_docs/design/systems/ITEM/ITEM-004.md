# ITEM-004 — Magic item and consumable construction

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Construct items carrying enchantments, potion contents, recipe references or stored souls while preserving actual contents, stable identity and explicit grant/compatibility outcomes.

## Intended player experience

Supported magical possessions retain their actual contents and resources through saving and content changes. Explicit requests yield the requested valid item; random rewards do not reroll on retry. Invalid construction produces clear recovery without substitute items, duplicate rewards or lost payment.

## Confirmed requirements

- **ITEM-004-D01:** Construction does not cast spells, consume ingredients, trigger equip/use effects or award rewards. Crafting/purchase operations separately authorize costs and grants through their owners.
- **ITEM-004-D02:** Preserve actual selected enchantments, spell payloads, potion contents and stored soul data alongside stable definition references and compatibility versions. Changed recipes/templates cannot silently replace existing contents. Compatible changes need explicit owner policy; incompatible changes require migration or failure.
- **ITEM-004-D03:** Explicit construction honors requested supported definition, contents and quantity. Random generation uses declared owner-selected pools and retained results, not automatically every registered recipe/magic item. Explicit classic-only and expanded pools are supported.
- **ITEM-004-D04:** Explicit profiles define condition, separate charges or other approved resources and initial amounts. Generation cannot universally replace physical durability with template uses. Classic profiles may explicitly use shared condition under MAGIC-016.
- **ITEM-004-D05:** Generated base value is separate from enchantment capacity, crafting cost and merchant quotes; each follows owner-approved calculations. DFU's enchantment-cost sum and 5000 + SoulPts remain candidates for separately reviewed value profiles, not adopted universal rules.
- **ITEM-004-D06:** Validate recipe identity, required effects/providers, supported contents and quantity before publication. Unknown recipes fail explicitly. Recipe items record knowledge/instructions; constructing or reading them does not itself brew potions or grant ingredients. Detailed learning/brewing rules remain separate features.
- **ITEM-004-D07:** Authorized loot/content profiles may generate a container holding one explicitly selected valid compatible soul, preserving actual soul data without simulating death/capture or awarding kill/capture rewards. MAGIC-027 live capture remains binding. Random generation selects a validated eligible pool instead of repeatedly drawing invalid creatures.
- **ITEM-004-D08:** Explicit ingredients honor supported definition/quantity. Random ingredients use declared eligible groups/pools, without assumed equal group probability or automatic inclusion of mod additions. Unsupported/empty pools fail without substitution.
- **ITEM-004-D09:** Validate enchanted base-item compatibility, power payloads, required providers and resource profiles before grant. Generation differences from player-enchanting eligibility/capacity must be explicitly declared, never silent bypasses. Ordinary baseline excludes enchanted arrows; custom enchanted ammo requires an explicit compatible COMBAT-008 profile.
- **ITEM-004-D10:** Actual contents remain separate from player knowledge. Generation profiles explicitly set initial identification state. Construction/inspection cannot automatically reveal hidden powers or change them; detailed identification remains ITEM/MAGIC-owned.
- **ITEM-004-D11:** Ordinary regular-magic-item pools exclude artifacts. Artifact creation needs an explicitly authorized profile applying approved artifact behavior and declared uniqueness/quest restrictions. Template registration alone grants no loot eligibility or universal uniqueness rule.
- **ITEM-004-D12:** Retain resolved contents, quantity, resources and operation progress until grant or recovery resolves. Retries cannot reroll, duplicate items or charge twice. Save coherent state or explicitly supported pending progress; otherwise explain temporary restriction. Load cannot activate powers, capture another soul or refill spent resources.

User confirmed each of four interviews with “1. Yes / 2. Yes / 3. Yes”. See [the decision log](../../GAMEPLAY_DECISIONS.md).

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Items/ItemBuilder.cs#CreateRegularMagicItem`: selects a regular magic template and base item, excludes arrows from its random weapon path, copies legacy enchantments/name, sets maximum/current condition from template uses and computes value from enchantment costs.
- `CreatePotion`: constructs a potion with recipe key/stack count. `CreateRandomPotion` selects among registered recipes but does not forward its stackSize argument. `CreateRandomClassicPotion` uses classic recipe keys. `CreateRandomRecipe` constructs a recipe item with selected recipe key/quantity.
- `CreateRandomlyFilledSoulTrap`: draws creature types from Rat through Lamia, rejecting Horse_Invalid and ordinary Dragonling; sets trapped soul and value 5000 + SoulPts.
- `CreateRandomIngredient`: selects an ingredient group/template, with null for unsupported explicit groups.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/classic-parity verification; reference source unchanged.

## Existing approved constraints

DATA-010 requires stable definitions, provider/reference validation and explicit compatibility. ITEM-001 owns identity/custody, ITEM-002 provider state/commit/recovery, ITEM-003 equipment base construction/material/appearance. MAGIC-015 owns enchantment composition/capacity and retained payloads; MAGIC-016 owns item power resources/triggers. MAGIC-027 owns live soul capture and utility creation; MAGIC-030 owns artifact-specific behavior. Construction cannot replace those contracts or adopt all reference constants implicitly.

## Detailed rules and behaviors

### Construction and contents

Use stable item/magic-template, recipe, power, soul and provider references with explicit compatibility versions. Preserve actual selected enchantments/spell payloads, potion contents and stored soul data, not only an index into a mutable list. This does not require copying every shared definition into every save; owner schemas must retain sufficient gameplay content and compatibility evidence.

Constructing/preparing an item does not activate it, cast spells, consume ingredients, equip it, award rewards or publish a grant. Authorized crafting/purchase/loot operations separately settle owner costs and custody. Base equipment follows ITEM-003; instance identity and custom behavior follow ITEM-001/002.

Explicit requests honor validated definition, contents and quantity. Random requests use declared eligible owner pools, explicit context and owned RULE-003 randomness, retaining results across retries. Classic-only and expanded pools are distinct supported choices; registration alone does not authorize inclusion. Empty/unsupported pools fail without substitution. A construction retry is not fresh reward generation.

### Magic items and artifacts

Validate base-item/power compatibility, retained payloads, providers and resources before granting. MAGIC-015 governs enchantment composition/capacity where applicable; generation profiles explicitly declare any permitted differences from player crafting rather than silently bypassing it. Ordinary enchanted-arrow exclusion is baseline; custom enchanted ammunition requires a compatible explicit profile under COMBAT-008 and MAGIC item-power contracts.

Profiles explicitly select condition, separate charges or another approved resource and its initialization. Do not universally overwrite ITEM-003 physical maximum condition with a magic template's uses. Classic shared-condition profiles are permitted only when explicitly defined under MAGIC-016. Initial amounts and subsequent expenditure/recharge follow the owning profile, not inspection or restore.

Artifacts are excluded from ordinary regular-magic pools. Explicit authorized artifact profiles apply MAGIC-030 or other approved behavior and declared quest/uniqueness restrictions. Neither template registration nor this feature establishes universal artifact uniqueness, unrestricted copying or a new artifact distribution.

### Potions, recipe items and ingredients

Validate recipe identity, supported contents, required effects/providers and quantity before publication. Unknown or incompatible recipes fail; do not create blank/useless substitute potions. Explicit and random potion construction preserve the requested valid quantity, correcting the reference random constructor's ignored quantity argument.

Recipe items carry explicit knowledge/instruction references, distinct from consumable contents. Creating/reading a recipe cannot itself brew a potion or grant ingredients. Learning, readable content, brewing requirements and consumption remain owner contracts. A changed recipe cannot silently replace existing potion contents or recipe-item state; recipe text/version compatibility must be declared by its owner.

Explicit ingredient construction honors supported identity and quantity. Random generation uses declared groups/pools/distributions, without assuming equal probability for every group or inclusion of all added content. This feature does not approve ingredient effects, brewing yields or alchemical discovery rules.

### Stored souls

Authorized generation can create a compatible container with one selected valid soul while retaining actual soul data. This is generation, not simulated death/capture: it cannot award kill/capture rewards, mutate a creature or invoke live-capture prevention. MAGIC-027 governs actual capture and MAGIC/ITEM owners define soul/container compatibility and use.

Random generated souls use a validated eligible pool, not an unbounded retry loop through invalid types. Required unavailable soul data fails explicitly. One generated soul is not cloned into multiple containers through retries or grants. The source Rat–Lamia pool/exclusions and 5000 + SoulPts value are reference facts, not universally approved target policies.

### Knowledge and settlement

Actual contents and player knowledge remain separate. Generation profiles declare initial identification state. Construction or inspection is not authorization to reveal hidden powers, reroll contents or identify an item. Detailed identification/display rules remain ITEM/MAGIC-owned.

Validate required data before grant. Missing contents/providers or unsupported combinations cannot publish a partial generic substitute. Preserve resolved contents, quantity, initial resources and completed operation phases until grant or recovery settles. Coordinate payment/entitlement/custody through owners so failure cannot silently lose rewards or duplicate charges/items. Retried callbacks cannot repeat completed facts. Exact receipt/staging APIs remain open; no general transaction framework is mandated.

## Relevant formulas and parameters

No new universal base-value formula, crafting price, enchantment capacity, initial charge/condition amount, potion potency, ingredient yield, soul strength or random distribution is approved here. Generated base value, capacity, crafting cost and merchant quote are separate owner calculations. DFU's enchantment-cost sum and 5000 + SoulPts remain unadopted candidate value profiles. Classic shared-condition uses require an explicit profile before support is claimed. Existing approved MAGIC/RULE formulas remain binding in their scope.

## Required data

Stable item/base/magic-template, recipe, power, provider, soul and container references; compatibility/state versions; actual retained contents and resource state; quantity and identification state; generation purpose/pool/context and resolved results; artifact authorization/restrictions where applicable; custody/item/session/operation identity; grant/payment/entitlement and recovery facts. Exact payload and serialization schemas remain integration work.

## Inputs, outputs and events

Inputs: owner-authorized explicit/random construction requests, validated definitions/content/resource profiles, quantities/knowledge state, compatible container/soul data and grant context. Outputs: validated prepared items, retained selections, committed owner grant outcomes or explicit invalid/unavailable/incompatible/recovery results. Preparation is not a use/equip/capture/reward event. Notifications describe completed facts and cannot independently repeat mutations. Concrete APIs/signals remain unselected.

## Cross-system interactions

- DATA-010 and MOD validate definitions/providers and content resolution; stable identity alone does not prove compatibility.
- ITEM-001/002 provide identity, custody, provider state, shared validation and recovery. ITEM-003 constructs equipment bases; ITEM-005/006 must preserve relevant contents/knowledge/resources when allowing stack/copy operations; ITEM-025 integrates restoration.
- MAGIC-015/016 own composition/capacity, actual powers, costs, source lifecycle and resource behavior. MAGIC-027 owns live capture and utility creation; MAGIC-030 owns special artifacts. No generation event substitutes for those actions.
- RULE-003/026 retain owned random selections/material results. Loot/ECON/QUEST/starting-equipment owners authorize pools, prices, grants and restrictions. Identification/readable-content/brewing owners determine their detailed behaviors.
- CORE-013/SAVE coordinate coherent restore, pending-operation support and explicit compatibility recovery.

## Edge cases and failure conditions

- Unknown recipe, missing power/provider or incompatible container: explicit failure before grant, not default contents.
- Requested potion/ingredient quantity: retain valid quantity across explicit/random paths; invalid bounds require schema-defined failure.
- Empty random pool or artifact-only entries in a regular pool: fail invalid generation policy rather than substituting or looping indefinitely.
- Mixed/unsupported resource profile: cannot silently replace durability or invent charges.
- Changed recipe/template/provider: compatible change only under explicit owner policy; otherwise migration/failure, no silent reset.
- Unidentified item: inspection does not reveal or change actual powers.
- Partial grant/settlement failure or repeated callback: retain completed facts and recover without duplicate item, charge or soul.
- Stored generated soul: no fake death/capture event or reward.

## Configuration and balancing options

Validated explicit/classic/expanded pools, content/provider mappings, declared resource profiles, identification defaults and artifact authorization are supported. Base value and generation/crafting eligibility differences require explicit owner profiles. No configurable silent downgrade, incompatible stack merge, arbitrary artifact inclusion or live-capture bypass is approved.

## Save/load considerations

Preserve actual contents, stable references/versions, soul data, quantity, spent resources, knowledge and item identity. Changed recipes/templates cannot rewrite possessions automatically. Unsupported required data needs explicit migration or failure under DATA-010/CORE-013; do not replace with generic items or reroll.

Persist coherent completed state or explicitly supported pending progress. Otherwise temporarily block saving with a clear reason until completion/cancellation/recovery reaches a supported boundary. Existing action-specific MAGIC/ITEM save restrictions remain binding. Preserve committed grant/settlement facts and retained random results. New session scope rejects old callbacks. Load cannot auto-activate, re-equip for rewards, capture souls, consume ingredients, duplicate grants, recharge or refill condition. Exact native schemas, migrations and pending-state recovery remain dependencies; classic/DFU import is outside this feature.

## Technical constraints

Target Godot 4.7.2. Separate reusable definitions, retained item payload/state, pure preparation, owner-authorized settlement and presentation. Use stable domain identities rather than enum/list positions or saved class names. Supported snapshots/providers require explicit compatibility; no universal snapshot implementation or generic crafting framework is mandated. No implementation/coding tasks authorized; reference source unchanged.

## Acceptance criteria

1. Construction alone causes no spells, ingredient consumption, equip/use effects, rewards or live capture.
2. Explicit supported definitions/contents/quantities are honored; random paths use declared pools and retain results across retries/load without automatic all-registration inclusion.
3. Actual magic/potion/soul contents persist alongside references/versions; changed definitions require owner-approved compatibility or migration/failure without silent replacement.
4. Magic-item resources follow explicit profiles; durability is not universally overwritten by uses. Base value, capacity, crafting price and merchant quote remain separate.
5. Unknown recipes/missing effects/providers fail before publication; recipe construction/reading cannot brew or grant ingredients.
6. Generated soul containers hold one valid compatible selected soul without kill/capture events or rewards. Invalid/empty soul pools fail without unbounded rejection loops.
7. Ingredient selection honors quantity and declared eligible pools; no unsupported substitution.
8. Enchantment generation validates compatibility and explicit capacity/eligibility differences; ordinary enchanted arrows excluded, custom ammo explicit.
9. Initial knowledge is profile-defined and separate from contents; ordinary regular pools exclude artifacts, explicit artifact generation enforces its declared restrictions.
10. Grant/recovery/save/load preserves completed facts without reroll, duplicate item/charge/soul, power activation or resource refill; unsupported pending saves explain temporary blocking.

## Contradiction review

Reviewed against approved ITEM-001–003, DATA-010 and MAGIC-015/016/027/030, with RULE-003/026 and CORE-013 boundaries. No direct contradiction identified. Retained contents does not mandate copying all definitions or bypass migration. Shared-condition profiles are explicit exceptions to ordinary base construction, not automatic resets. Generated souls are separate from live capture. Artifact authorization does not invent uniqueness. Action-specific save/cost contracts remain binding; generation differences from player enchanting require explicit approval/profile semantics rather than implicit bypass.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: concrete magic generation eligibility/capacity and value profiles; resource initialization/shared-condition rules; recipe/potion/ingredient/soul schemas and compatibility; declared pools/distributions; identification/artifact restrictions; stack/copy preservation; grant/settlement receipts and native migration/pending-save fixtures. Unapproved reference constants remain unapproved; a concrete profile cannot be claimed supported until required rules are resolved, with material gameplay choices returned for review.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-004-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented concrete generation/value/resource profiles, content/compatibility schemas, pools, identification/artifact restrictions, stack/copy preservation, grant recovery and native persistence dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
