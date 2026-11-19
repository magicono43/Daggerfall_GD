# ITEM-003 — Material, armor and clothing construction

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Construct equipment from validated templates, material/category profiles and appearance selections without corrupting item identity or mutable state.

## Intended player experience

Equipment has consistent material properties and recognizable appearance. The same possession survives changing wearers and saving without rerolls, free repairs or compounded bonuses. Invalid construction produces truthful recovery instead of a different item.

## Confirmed requirements

- **ITEM-003-D01:** Separate mechanical material/category from visual variant, dye and body appearance. Cosmetic changes alone do not change damage, protection, weight, durability or value unless an explicit gameplay rule declares otherwise.
- **ITEM-003-D02:** Calculate material-adjusted properties from the validated base definition and selected material profile, not by repeatedly multiplying modified instance values. Rebuild/display cannot compound bonuses or repair an item. Later material changes require explicit transformation rules.
- **ITEM-003-D03:** Use classic weapon materials and leather/chain/plate armor categories as the initial baseline, with validated mod-added materials/categories supported. Property formulas and constants require separate review; this decision does not approve every DFU constant.
- **ITEM-003-D04:** Adopt DFU material-adjusted base value, weight and maximum-condition formulas/tables as the initial baseline with validated overrides. Steel gives 6× template value, approximately 1.25× weight with quarter-kilogram rounding and 1.5× maximum condition with integer truncation. Leather halves template weight; chain doubles template value. Merchant pricing and combat formulas remain separate.
- **ITEM-003-D05:** Ordinary new equipment starts at full condition. Authorized loot/starting-equipment/other generation profiles may explicitly request worn condition. Load, inspection and rebuilding existing items never refill condition.
- **ITEM-003-D06:** Construction receives intended wearer/body appearance explicitly rather than reading the current player. Appearance alone imposes no race/gender equip restriction; actual fit restrictions require explicit equipment rules.
- **ITEM-003-D07:** Supported DFU leather/chain/plate visual combinations form the initial baseline. Random variants are selected only from compatible combinations. Explicit invalid combinations report an error instead of silent clamping; declared default/random selection remains valid. Mods may add validated combinations.
- **ITEM-003-D08:** Weapon/armor default colors follow material; random clothing uses DFU's ten-color palette initially. Explicit supported colors may override defaults. Color alone does not change mechanical material and per-item changes cannot recolor other instances. Recoloring services, costs and availability remain separate decisions.
- **ITEM-003-D09:** Explicit arrow construction supplies quantity and supported arrow definition. Random loot may use a declared 1–20 quantity baseline. Classic ordinary arrows remain material-neutral; custom arrows may declare material-dependent behavior under approved ammo rules. Do not silently ignore requested material or unexpectedly randomize explicit quantity.
- **ITEM-003-D10:** Adapt displayed body appearance to the current wearer where supported, preserving identity, material, style, dye and condition. Missing required support yields an explicit unsupported result or separately approved presentation fallback. Actual equip restrictions remain binding.
- **ITEM-003-D11:** Use explicit generation context and owned randomness for template, variant, dye and quantity alongside RULE-026 material selection. Retain resolved results across retries/save; inspection/load cannot reroll. Loot/merchant owners define pools/distributions; construction does not automatically draw from all registrations.
- **ITEM-003-D12:** Validate the complete requested combination before grant. Missing material rules, required visuals or providers cannot publish a partial/default substitute. Failed construction cannot consume entitlement/payment without the owning operation retaining an explicit recovery obligation.

User confirmed each of four interviews with “1. Yes / 2. Yes / 3. Yes”. See [the decision log](../../GAMEPLAY_DECISIONS.md).

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Items/ItemBuilder.cs#CreateWeapon`, `ApplyWeaponMaterial`, `SetItemPropertiesByMaterial`: material-adjusted value/weight/maximum condition, initial full condition and material dye. Ordinary arrow construction ignores requested material and generates quantity 1–20. Weapon appearance adjustment reads player gender.
- `CreateArmor`, `ApplyArmorSettings`, `ApplyArmorMaterial`: explicit gender/race/material/variant inputs; leather halves weight, chain doubles value, plate applies weapon-material property tables.
- `CreateRandomClothing`: random template, dye and variant with gender group/race inputs. `SetRace` maps race to body morphology; `SetVariant` forces/clamps some armor variants by material family; invalid total-range requests return without changing the variant.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Reference code unchanged. Runtime/classic parity not established.

## Existing approved constraints

DATA-010 requires stable templates/material references, validated compatibility and explicit failure instead of default material substitution. ITEM-001 preserves instance identity/state; ITEM-002 requires validated special behavior and shared authoritative operations. RULE-026 owns random material selection and retained results, not equipment property construction. Combat formulas and eligibility remain approved RULE/COMBAT owner contracts.

## Detailed rules and behaviors

### Definition, material and instance

Use stable validated template/material/category identities under DATA-010 and ITEM-001. Initial content supports classic weapon materials and leather/chain/plate categories. Added materials/categories require complete applicable property, combat, appearance and provider mappings, not only a new selector entry. Do not infer mechanics from color, texture or numeric enum order.

Derive properties from validated base definitions and selected profiles exactly once for construction. Recalculation must not compound prior multipliers, refill condition or overwrite unrelated instance state. Existing-item changes follow explicit transformation/compatibility rules under ITEM-001; construction is not a repair, crafting or transmutation permission.

Ordinary newly constructed equipment starts at maximum condition. Authorized generation may explicitly request worn condition within valid item bounds. Do not refill existing items during inspection, restoration or resource reconstruction. Detailed wear/break/repair remains ITEM-013/014 and relevant combat/magic owner work.

### Appearance, variants and wearers

Mechanical material/category and presentation are distinct. Material supplies the default weapon/armor color; supported explicit colors may override it without changing mechanics unless a declared gameplay rule says otherwise. Per-item visual changes cannot mutate shared resources and recolor unrelated items.

Use explicit intended wearer/body context, never an implicit current-player lookup. Display may adapt to a new current wearer while retaining style, dye, material, condition and item identity. Body presentation alone grants no race/gender eligibility restriction. Required unsupported presentation fails explicitly unless a separately approved fallback applies; no generic fallback is approved here.

Initial supported classic mappings use Argonian, Elf (Dark/High/Wood Elf), Human (Breton/Nord/Redguard) and Khajiit morphology with supported gender-specific resources. These are source compatibility mappings, not a universal limit on body profiles or permission to default an unknown race to Human. Content schemas must validate supported combinations.

Initial armor style mappings follow the supported DFU combinations below. Numbers are classic adapter variant references, not required native IDs:

| Piece | Leather | Chain | Plate |
| --- | --- | --- | --- |
| Cuirass | 0 | 4 | 1–3 |
| Greaves | 0–1 | 6 | 2–5 |
| Left/right pauldron | 0 | 4 | 1–3 |
| Gauntlets | 0 | 1 | 1 |
| Boots | 0 | 1–2 | 1–2 |

Helms use supported template variants; remaining pieces use validated template mappings. An explicit invalid variant/combination reports failure rather than copying DFU's silent return/clamping. A declared default/random selector is valid and resolves only among compatible variants. Source random-construction defaults do not establish a universal target distribution; caller policies declare selection under D11. Chain2 is a legacy reference requiring explicit adapter interpretation, not a separately approved new category/property profile.

Random clothing initially supports Blue, Grey, Red, Dark Brown, Purple, Light Brown, White, Aquamarine, Yellow and Green. Owner-selected pools/distributions and supported explicit overrides govern selection. Dye service availability, price and player interaction are outside scope.

### Explicit and random construction

Explicit requests supply supported template, material/category, appearance selections and quantity where relevant. Default/random choices are declared rather than hidden behind arbitrary invalid values. Random requests carry generation purpose/context and use owned RULE-003 randomness; material draws follow approved RULE-026. Retain resolved selections through retries and save/load without rerolling from current level, registration order or changed definitions.

Loot/merchant/starting-equipment owners choose their candidate pools, distributions and authorized generation level. Registration does not automatically make every added item eligible everywhere. Inspection and diagnostic previews do not advance live generation randomness.

Explicit arrows provide definition and quantity. Classic ordinary arrows are material-neutral; requests cannot silently discard an incompatible material selection. A declared random-loot profile may generate 1–20 arrows inclusively. Custom material-bearing arrows require explicit compatible ammo/property behavior under COMBAT-008. Source arrow condition zero is reference behavior, not approval of a universal ammo durability rule.

### Validation and publication

Validate required template, material/category, variant/body/color, quantity and behavior-provider requirements before granting an item. Required missing/unsupported inputs fail rather than constructing a partial/default substitute. Optional presentation fallback requires an independently approved policy consistent with DATA contracts.

Construction/grant and payment/entitlement settlement must retain truthful outcomes. Failure cannot silently lose entitlement/payment or duplicate a grant on retry; the owning operation retains explicit recovery obligations for already committed facts. ITEM-001 custody and ITEM-002 commitment/provider contracts apply. Exact staging/receipt APIs remain open; no general transaction framework is mandated.

## Relevant formulas and parameters

For ordinary weapon and plate construction, let V, W and C be validated template base value, weight in kg and maximum condition. Material profiles use the following approved DFU baseline:

| Material | Value factor | Weight coefficient q | Condition coefficient c |
| --- | ---: | ---: | ---: |
| Iron | 3 | 4 | 4 |
| Steel | 6 | 5 | 6 |
| Silver | 12 | 4 | 6 |
| Elven | 24 | 4 | 8 |
| Dwarven | 48 | 3 | 12 |
| Mithril | 96 | 4 | 16 |
| Adamantium | 192 | 4 | 20 |
| Ebony | 384 | 2 | 24 |
| Orcish | 768 | 4 | 28 |
| Daedric | 1536 | 5 | 32 |

- Base item value = V × value factor; this is not the merchant quote.
- Weight = roundToNearestEven(truncate(W × 4) × q / 4) / 4 kg, preserving DFU's quarter-kg conversion and nearest-even midpoint rounding. For supported nonnegative values, truncation is floor. Do not substitute simple continuous multiplication.
- Maximum condition = truncate(C × c / 4), matching integer division for supported baseline values.
- Leather: weight W/2, unchanged base value and maximum condition. Chain: base value 2V, unchanged base weight and maximum condition. Plate uses the table above.
- Ordinary new current condition = computed maximum; explicit worn-generation profiles supply valid current condition without implicitly selecting a damage percentage policy.

Validated overrides may replace declared profiles/formulas. Numeric domains, overflow handling, source unit conversion and profile compatibility must be specified before implementation; no silent wrap or invalid partial grant. Combat damage/protection, enchantment capacity and merchant pricing remain separately approved owner contracts.

## Required data

Stable template/material/category IDs and classic mappings; base properties and formula/profile versions; supported piece/material/style/body/color combinations; explicit generation context/pools and retained resolved results; quantity/current/max condition; item identity/custody and custom provider state; source/configuration compatibility and pending grant/payment recovery facts. Concrete schemas remain dependencies.

## Inputs, outputs and events

Inputs: authorized explicit or random construction request, validated definitions/profiles, intended body context, declared defaults, worn-state/quantity and owner grant context. Outputs: validated equipment with retained identity/properties/selections, explicit unsupported/invalid outcomes or retained partial-operation recovery. Publication notifications report committed item/grant facts; preview or calculation alone is not an item grant, equip or repair event. Concrete APIs/signals remain unselected.

## Cross-system interactions

DATA-010 and DATA-022 provide validated definitions/resource references and visual instance isolation. ITEM-001/002 provide identity, custody, provider state and recovery. RULE-003/026 own randomness/material selection; RULE/COMBAT own material-dependent accuracy/damage/protection and ammo behavior. CHAR supplies explicit wearer context; equip owners validate actual restrictions. ECON/loot/starting-equipment owners choose pools, prices, grants and settlement. MAGIC owns enchanted payloads and costs; construction cannot replay its triggers. CORE/SAVE coordinate coherent restore and failure admission.

## Edge cases and failure conditions

- Reapplying a profile cannot multiply value twice or refill worn condition.
- Material color override cannot turn an iron item into mechanically Daedric equipment.
- Unknown body or invalid explicit variant cannot silently become a different supported selection.
- Different wearer changes presentation only where supported, retaining state and actual equip restrictions.
- Failed required provider/visual/property mapping grants no partial substitute; already committed settlement retains recovery.
- Save/retry after random resolution reuses retained results, without duplicate grant or reroll.
- Explicit material-neutral ammo rejects unsupported material requests rather than ignoring them; custom ammo follows declared compatibility.

## Configuration and balancing options

Validated material/category additions and property overrides; supported appearance/style/color mappings; declared generation pools/distributions/defaults; explicit worn-condition profiles and random-loot quantities are supported. No universal auto-level stat scaling, fit restriction, repair-on-rebuild, crafting service or dye price is approved. Changed configuration follows DATA-003 locks and saved-item compatibility rather than automatically rebasing existing items.

## Save/load considerations

Preserve assigned material/category, style, dye, quantity, condition, item identity and owner-required resolved generation/recovery facts. Reconstruct presentation for the current wearer without modifying mechanics or replaying grants/equip/magic events. Derived property reconstruction follows approved compatibility; changing a template/profile cannot silently rebalance/reset an existing item. Retained IDs alone do not prove compatibility. Missing/incompatible required data needs migration or explicit CORE-013/SAVE recovery, not a default item or reroll. Exact snapshot-versus-derived field schemas and pending generation save boundaries remain integration dependencies.

## Technical constraints

Target Godot 4.7.2. Separate reusable definitions, calculation, owned generation, item state and presentation. Native IDs must not depend on legacy packed material numbers or texture archive arithmetic. Match approved rounding with explicit arithmetic and fixtures. No implementation or coding tasks authorized; reference source remains unchanged.

## Acceptance criteria

1. Baseline material tables, leather/chain rules and exact rounding produce expected properties from base definitions without repeated compounding.
2. New equipment defaults full; explicit valid worn generation works; load/inspection/rebuild never repairs existing items.
3. Cosmetic changes preserve mechanics and isolate instances; wearer changes preserve item identity/style/dye/condition and actual equip restrictions.
4. Explicit invalid material/body/style combinations report failure; declared defaults/random select supported combinations without silent clamping.
5. Validated added materials/categories include required property/combat/appearance/provider support before publication.
6. Random selections use explicit owner pools/context, preserve resolved results across retry/load and do not draw during inspection.
7. Explicit arrows retain requested valid quantity/definition; declared classic random profile supports inclusive 1–20; no ignored incompatible material input.
8. Failed construction cannot publish partial substitutes or silently consume payment/entitlement; retry/recovery cannot duplicate grants.
9. Native restore retains state and compatibility outcomes without reroll, silent rebalance or replayed item/effect events.

## Contradiction review

Reviewed against approved DATA-010, ITEM-001/002, RULE-026 and COMBAT-008, with DATA-022 visual isolation and CORE-013 restore constraints. No direct contradiction identified. Property tables do not replace combat or merchant formulas. RULE-026's category/material distributions remain binding where selected; construction does not select a new universal loot distribution. Visual wearer adaptation grants no equip eligibility. Classic material-neutral arrows coexist with explicitly supported custom ammo. No broader architecture proposal is approved wholesale.

## Outstanding questions

No further blocking player-policy choice identified. Before implementation is complete: validated material/property/numeric schemas and rounding fixtures; full piece/style/body resource inventory and defaults; Chain2 adapter interpretation; worn-state bounds; custom material/combat/ammo adapters; generation pool/distribution/operation schemas; grant/settlement recovery and native compatibility/migration schemas. Unsupported combinations must remain explicit until these dependencies are resolved.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-003-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented material/numeric schemas and fixtures, appearance inventories/defaults, Chain2 interpretation, worn-state bounds, custom adapters, generation/grant recovery and native compatibility/migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
