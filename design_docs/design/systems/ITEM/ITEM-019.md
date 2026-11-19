# ITEM-019 — Identification and item display

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Represent item discovery independently of actual mechanics and expose consistent knowledge-aware item presentation.

## Intended player experience

Players distinguish observable possessions from hidden properties, keep discoveries when recovering the same item, and know what an appraisal will reveal. Inspection, sorting and retries cannot leak secrets or alter the item itself.

## Confirmed requirements

- **ITEM-019-D01:** Knowledge is separate from actual contents/mechanics. Identification reveals declared information without changing material, powers, condition, charges, ownership or price formulas. Hidden properties retain approved function.
- **ITEM-019-D02:** Support per-property knowledge, not exclusively a single identified flag. Profiles declare ordinary inspection/Identify/use/quest disclosure. Simple fully-identified state supported; Identify does not automatically reveal every mod curse/secret.
- **ITEM-019-D03:** Names/tooltips/icons/enchantment indicators/action lists/rejections share knowledge-aware presentation. Other display paths/sorting cannot disclose hidden properties. Technical diagnostics separate from player knowledge.
- **ITEM-019-D04:** Ordinary inspection shows observable type/appearance/style/quantity/effective weight and applicable condition/fuel. Magical identity/exact hidden effects/curses/secrets need declared discovery. Material visibility profile-defined, not universal color inference.
- **ITEM-019-D05:** Character knowledge refers to particular item and survives drop/storage/reacquisition. Transfers do not automatically teach other actors; one identified item does not identify all template copies. Explicit labels/shared knowledge/familiarity mod policies supported.
- **ITEM-019-D06:** Baseline merchant identification is immediate/guaranteed within declared ordinary disclosure scope, with RULE-023 fee. Show scope/price and coordinate payment/knowledge without temporary ownership transfer. Secrets may need other services/discovery.
- **ITEM-019-D07:** Split preserves the character's valid knowledge of separated units, not unrelated copies. Merge preserves knowledge without revealing unknown properties; incompatible states remain separate unless supported representation preserves them safely.
- **ITEM-019-D08:** Discoveries reference learned property/version. Authorized changes preserve unrelated knowledge but do not identify new hidden properties automatically. Observed use reveals only declared justifiable information, not all formulas/powers/curses.
- **ITEM-019-D09:** Persist character/item/property knowledge and identification completion facts. No load forgetting valid discoveries/new-secret reveal/recharge/repeated rolls. Changed/missing properties require explicit compatibility; ordinary service rejection preserves payment/knowledge.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Items/DaggerfallUnityItem.cs#IdentifyItem` sets identified flag; `GetIsIdentified` treats nonenchanted items as identified.
- `Game/Items/ItemHelper.cs#ResolveItemName`, `ResolveItemLongName` use generic template names when unidentified and specialized material/book/artifact naming when identified. `GetInventoryImage` and `GetItemInfo` resolve category/appearance data.
- `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#ShowInfoPopup` and inventory/hover paths present item information; individual reference paths do not establish a complete knowledge-safe contract.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; source unchanged.

## Existing approved constraints

MAGIC-027 owns magical Identify batch selection/cost/chance/retry and durable knowledge updates; RULE-023 owns service fees. ITEM-001–018 preserve state/identity/knowledge, compatible stacking, curse discovery, explicit actions and unidentified consumable use. Presentation cannot activate powers or invent disclosures. Identification does not reprice/rewrite actual item state merely because more properties are known.

## Detailed rules and behaviors

### Knowledge and item reality

Keep actual item contents/mechanics independent of observer knowledge. Identification updates only declared knowledge; it does not repair, recharge, replace powers/material, change custody or alter pricing formulas. Hidden properties function through their approved owner rules, not through whether UI names them.

Support property-level knowledge keyed to stable character/item/property identity and compatibility version. Simple full-identification profiles remain valid when their scope is explicit; a single boolean cannot automatically classify every custom secret as known. Profiles declare inspection, Identify, use and quest disclosure separately, including unknown, observed and fully disclosed information as supported. No universal number of knowledge tiers is selected.

### Inspection and shared display

Ordinary inspection exposes observable type, appearance/style, quantity, effective weight and applicable condition/fuel. Material visibility is a declared profile rule rather than universal color inference. Magical identity, exact hidden powers, curses and secrets require their discovery policies. Names/icons may show the visible object without claiming its hidden identity.

Names, info popups, tooltips, inventory images/indicators, action lists, sorting and rejection text use consistent observer-aware presentation. Hidden properties cannot leak through an enchantment animation, sort order, alternate name or action availability. Technical diagnostics may retain precise authoritative data separately from in-game knowledge. Query/hover/refresh is pure and cannot grant identification, execute powers or change armor/value state.

Known appraisal/trade quotes remain governed by their owners; this feature does not change RULE-021 pricing to hide an actual item value. Exact hidden-property economic signals and permissible quote disclosures need explicit owner policy rather than invented price masking. Displaying a quote is not automatic identification.

### Ownership, movement and unit knowledge

Discoveries belong to the character about the particular item, surviving storage/drop/reacquisition of the same identity. Transfer does not automatically teach another actor. Identifying one copy does not identify every template instance. Explicit labels/shared knowledge/familiar-item recognition profiles may differ through supported rules; item-intrinsic facts such as a label remain distinct from observer knowledge.

Partial split propagates the character's valid knowledge of those separated units while retaining ITEM-001 identity/reference behavior. This is not template-wide learning or fresh-copy recognition. ITEM-005 merging must preserve knowledge without revealing unknown properties; incompatible states remain separate unless a complete supported representation retains them. A retired source cannot remain a live knowledge alias granting undiscovered contents of a destination. Exact lineage/reference migration must preserve these semantics.

Authorized property changes preserve unrelated valid knowledge. New/replaced hidden properties are not automatically identified because the old item was fully known. Discoveries reference the learned property/version and compatibility rules; changing display name/locale alone does not erase knowledge. Explicit observed use reveals only declared justified outcomes, not every hidden formula/power/cure. ITEM-011 curse-resistance feedback and ITEM-017 unidentified use remain binding.

### Magical Identify and merchant appraisal

MAGIC-027 governs magical Identify: selection-first deferred batch accounting, carried-access defaults, per-item retained chance outcomes and genuine paid retry. Already-known/empty selections incur no Identify charge/roll under that contract. This feature supplies disclosure/knowledge updates, not a new chance or payment formula.

Baseline merchant identification is immediate and guaranteed within its declared ordinary-property scope. Show scope and RULE-023 price before acceptance; special secrets may require different supported discovery/service. Revalidate item/access, unresolved disclosure scope, payment acceptance and current quote at commitment. Do not transfer item ownership merely to stage selection.

Coordinate payment and durable knowledge update so ordinary rejection leaves both unchanged. A real partial technical commitment retains exact facts and explicit recovery, never double charge or fresh random result. Scope containing no discoverable eligible information must be handled explicitly rather than selling an undisclosed empty benefit; concrete repeat-service admission follows owner policy. Material quote/scope changes require renewed acceptance under established payment rules.

### Discovery events and recovery

Authorized use/quest/identification requests carry stable actor/item/property/provider/session/operation context. Duplicate callbacks do not reveal again for rewards, reroll outcomes or charge twice. Actual knowledge updates publish committed facts; observers cannot execute the identification again. Missing required definitions/providers produce explicit failure/recovery rather than treating the item as generic/fully identified. No general transaction framework is mandated.

## Relevant formulas and parameters

No new identification chance, property-disclosure tier count, hidden-price formula or familiarity threshold is approved. Merchant fee follows RULE-023: eligible baseline identification is free under applicable Witches Festival policy; otherwise trunc(25×valid base value/256), then declared guild reduction, preserving zero with no ordinary purchase minimum or extra bargaining. MAGIC-027 retains its separate batch costs/chances/retry. Exact disclosure inventories remain owner profiles.

## Required data

Stable character/item/property/work/provider/session identities; actual versus known property/version state; observation/disclosure provenance and compatibility; observable presentation fields and known-action/rejection rules; split/merge knowledge lineage; identification scope/quote/retained roll and payment/update phase facts. Exact schemas and knowledge storage/indexing remain dependencies.

## Inputs, outputs and events

Inputs: pure observer-aware info query, authorized inspection/use/quest disclosure, merchant/magic identification result, property change, split/merge and native restore. Outputs: knowledge-safe name/image/info/actions, durable scoped discoveries or explicit rejected/recovery outcomes. Queries/previews are not identification/effect/repair events. Concrete APIs/signals remain unselected.

## Cross-system interactions

ITEM-001–018 provide item identity/state/custody, knowledge-preserving stacking, curse/consumable discovery and explicit actions. MAGIC-027 owns Identify operation and MAGIC effects own actual hidden behaviors; RULE-023/ECON own service pricing/settlement. DATA/MOD validate property/disclosure providers, DATA-018 keeps locale/work changes separate from gameplay identity. UI/AV consume permitted presentation; SAVE/CORE preserve character knowledge and no-replay scope. Future appraisal/economic secrecy profiles require owner decisions.

## Edge cases and failure conditions

- Hidden enchantment/curse: no tooltip/icon/sort/action leak or automatic Identify-every-secret behavior.
- Same item reacquired versus another same-template copy: retain only appropriate character knowledge.
- Split/merge with unequal knowledge: preserve unit facts or keep separate, no knowledge laundering.
- New enchantment on a formerly known item: new hidden properties unresolved, unrelated knowledge retained.
- Use resistance/full-health/curse-removal feedback: only declared observations, not complete disclosure.
- Zero-fee service: valid eligibility still required, no forced minimum or free revelation beyond scope.
- Magical failed roll: approved cost/outcome retained, no technical reroll; merchant guarantee applies only its own scope.
- Missing property/provider or partial payment/update: explicit compatibility/recovery, no generic/full-known fallback.

## Configuration and balancing options

Validated property-level disclosure, material visibility, observation/use/quest rules, merchant scopes and explicit shared/label/familiarity knowledge profiles are supported. Simple full identification remains possible. No default curse reveal, template-wide recognition, price masking, new skill reward or universal metadata tier is introduced. Presentation customization cannot bypass observer knowledge.

## Save/load considerations

Save character/item/property knowledge with learned version/provenance and identification-operation completion/retained outcomes. Loading preserves valid discoveries without revealing changed/new secrets, repeating rolls/debits or resetting rewards. Missing/changed required properties need explicit compatibility/migration rather than silently forgetting everything or marking everything known.

Maintain movement/reacquisition and supported split/merge knowledge references coherently with ITEM identities. Native restore does not execute inspection/use/appraisal again. Pending save/recovery follows ITEM-002/015 and MAGIC-027/service contracts; unsupported boundaries explain restrictions. New session rejects old callbacks. Exact schemas/lineage retention/migration fixtures remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate actual item state, observer knowledge, disclosure operations and shared presentation. Native identities must not depend on display names, raw flags/class names or mutable UI positions. Stable property version compatibility and read-only presentation queries are required without mandating a particular database/framework. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Identification updates declared knowledge only; actual mechanics/condition/resources/custody/formulas unchanged.
2. Per-property and simple scoped-complete knowledge are supported without automatic curse/secret disclosure.
3. Observable inspection and profile-defined material visibility work consistently across names/icons/actions/sorting/rejections, with no hidden-data leaks or query mutations.
4. Character/item discoveries survive drop/storage/reacquisition, not automatic actor transfer/template-wide recognition.
5. Split knowledge follows separated units; merge cannot reveal unknown properties or discard meaningful knowledge.
6. Property changes preserve unrelated valid knowledge without automatically identifying new hidden state; observed use follows declared scope.
7. Merchant identification is immediate/guaranteed within quoted scope and RULE-023 fee; payment/knowledge settle coherently without ownership staging.
8. MAGIC-027 batch/chance/cost/retry semantics remain intact and retained outcomes cannot reroll through technical recovery.
9. Native restore preserves valid knowledge/completion facts with explicit changed-property compatibility and no replay, new-secret reveal or duplicate charge.

## Contradiction review

Reviewed against approved ITEM-001–018, MAGIC-027 and RULE-023. No direct contradiction identified. Character-scoped knowledge refines prior knowledge-preservation requirements; split propagation is legitimate unit lineage rather than template recognition. Property-aware discovery preserves prior curse/use secrecy. Merchant guarantee does not replace magical Identify chance. Presentation does not change approved economic formulas; concrete quote secrecy remains an explicit dependency. Actual effects/resources remain independent of what the observer knows.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: property/disclosure/version schemas and baseline visible/hidden inventories; actor/item knowledge lineage; identification service scopes/admission and quote visibility; economic signal policy; observer-safe presentation/reason fixtures; merchant/magic update receipts and native migrations. Concrete unresolved gameplay disclosure profiles require explicit owner decisions before support is claimed. These cannot waive per-property secrecy, valid knowledge retention or no-replay settlement.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-019-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented disclosure/version schemas, knowledge lineage, service scopes, quote/economic visibility policies, presentation fixtures, identification receipts and native migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
