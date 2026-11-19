# MAGIC-011 — Spellbook and spell offers

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Maintain learned spell knowledge separately from innate/item powers, present usable and blocked entries, and acquire offered spells through checked once-only purchase operations.

## Intended player experience

Players organize and inspect spells without accidentally casting. Ordinary learned access requires a spellbook item by default, with a moddable on/off requirement. Losing it blocks access without erasing knowledge. Costs/restrictions and service prices are distinguishable; duplicate purchase cannot waste gold by default. Mods can extend offers, duplicate policies and UI sorting/display while preserving source authority.

## Confirmed requirements

MAGIC-011-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm source distinctions, moddable default spellbook requirement, stable purchase intent, duplicate handling, forgetting, organization/display extensibility, blocked visibility, explicit offers and native persistence. The complete specification is approved under MAGIC-011-A01.

MAGIC-001/002 and DATA-011 supply stable supported definitions; MAGIC-003/004 own readiness/cast/history; RULE-018 cost quotes; CORE-013 and prior MAGIC save contracts preserve compatibility. Individual merchant prices, stock and faction access are not selected here.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete service inventory/runtime transaction behavior unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/`.

- `Entities/DaggerfallEntity.cs#GetSpells`, `SwapSpells`, `SortSpellsAlpha`, `SortSpellsPointCost`, `AddSpell` and `DeleteSpell` expose a mutable ordered spell list. AddSpell appends without a duplicate check in that method; sorting uses names or calculated costs.
- `UserInterfaceWindows/DaggerfallSpellBookWindow.cs#PopulateSpellsList` calculates current cost and desaturates insufficient-magicka entries; lycanthropy receives special cost display. Selection details and deliberate use are separate handlers; use sends settings to SetReadySpell and closes to HUD.
- Deletion confirms an index and protects special vampire/lycanthropy entries. Purchase checks possession of a spellbook and gold, prompts, then `ConfirmTrade_OnButtonClick` recomputes price, deducts gold and appends the currently indexed offered spell. Stable retained quote/selection and all-or-nothing learning are not established by that path.
- `MagicAndEffects/EntityEffectBroker.cs#RegisterCustomSpellBundleOffer` rejects duplicate offer keys; custom offers declare usage such as sale or held/used/striking enchantment. Runtime registration does not itself prove every service offers the spell.
- Manager recast checks possession of the spellbook item. Target learned/innate/item rules below are explicit design choices rather than an assertion every DFU route shares one gate.

## Detailed rules and behaviors

### Knowledge, entries and source access

Keep learned spells, innate abilities and item-provided casts as distinct authoritative sources. A unified UI may list them together, but listing is not learning. Item casting requires the declared item/source and its owner rules; innate abilities follow grant/condition rules. Neither gains unrestricted ordinary recast/purchase/delete semantics merely by sharing an interface.

Use stable spell and learned-entry identity, with explicit custom settings/source context where needed. Names/localization/list position do not define identity. Learned custom definitions remain distinct where IDs differ, even with identical names. Definition compatibility and source authorization must validate before use.

Default ordinary learned selection for use, recast and purchase require possession of a spellbook item. Expose validated enabled/disabled mod policy, default enabled. Losing the item restricts access without deleting knowledge. Innate/item powers use their own rules. This approves a requirement toggle, not an arbitrary live mod-plan edit or blanket exception for missing content.

Do not infer from this gate a new interruption of an already released spell. Active-cast required-source checks follow MAGIC-004 and explicit source dependencies; exact spellbook access checks between readiness and commitment need owner integration consistent with those contracts.

### Browsing and deliberate use

Temporarily unusable learned entries remain visible and inspectable with clear reasons, including missing spellbook, silence, insufficient magicka or unavailable required source. Missing/incompatible required effect definitions remain content/save recovery, not a harmless grey entry permitting silent loss.

Display current caster-context casting cost and affordability from RULE-018/MAGIC-003. Distinguish quote from release-time payment; inspecting does not freeze a discount. Cost exemptions and silence permissions use explicit source data rather than spell-name/tag guesses.

Highlighting, sorting, filtering and inspecting never cast, ready, spend resources, roll effects or grant practice. Deliberate use submits stable selected intent through MAGIC-003 and its configured per-target/per-spell automatic behavior. Failed readiness preserves prior selection per that feature; UI must report truthful outcome rather than declaring a successful cast merely because the window closed.

### Duplicates and forgetting

Default learning of an already-known stable spell ID returns already-known without new entry or charge. Purchase revalidation checks this before commitment, including changes while confirmation is open. Explicit validated mod duplicate policies are supported with declared identity/entry behavior; no automatic name-based collapse.

Ordinary learned spells support confirmed forgetting. Retain exact selected identity through the prompt and revalidate that the entry remains deletable. Innate/item entries are not deleted as learned knowledge; explicitly protected grants remain protected under their owning grant rules. Individual protection inventories remain owner/content work.

Successful forgetting cancels that entry's uncast readiness and invalidates its matching recast history, without erasing an unrelated selected spell/history. Already released effects/projectiles remain governed by their own lifetime. Relearning uses normal acquisition/eligibility; forgetting does not refund purchase gold or grant a free replacement. Actual-cast mutation admission and same-ID regrant races need explicit lifecycle integration, not silent retargeting by index.

### Organization and UI moddability

Provide persistent manual ordering plus name and current-cost sorting. Selection attaches to stable entry identity across reordering, filtering and list updates. Sort does not mutate definition identity or substitute another spell into a pending purchase/delete/use intent. Current-cost sorting samples declared current values coherently; exact tie/order/update behavior is UI scope.

Additional sorting, filtering and list display options must be moddable through validated UI integration. Source categories, effect schools and other supported metadata can be exposed where schemas permit; no specific extra layout/filter inventory is selected. UI extensions cannot change knowledge, source authorization or cast authority as a side effect of rendering.

Manual knowledge order is character state. Sort/display preferences use the appropriate UI preference scope, separate from learned content; exact account/character scope remains UI/SAVE design. Switching views must not destroy stored manual order or stable entry identity.

### Service offers and purchase commitment

Separate registered/runtime-supported spells from explicit offers for sale or other service usage. Each service resolves supported offer eligibility; validated mod additions/overrides follow DATA-003 identity/provenance/order rules. Duplicate accidental offer additions are not automatically replacements. Registration alone does not authorize purchase, enchantment use or learning.

Show purchase price separately from casting cost. ECON/services own stock, faction access, merchant pricing/funds and individual availability. No universal price multiplier or stock-refresh schedule is adopted from source here.

Capture exact offered spell/variant/settings context, offer/service identity and quoted price for confirmation. Revalidate current service/offer eligibility, complete supported definition, spellbook policy, funds and duplicate state before committing. List sorting/current selection cannot replace the captured intent. A changed quote requires renewed confirmation; stale/invalid offer produces clear failure without charging/learning another spell.

Commit payment and learning once as a checked owner operation. Failure leaves gold and learned knowledge unchanged. Duplicate confirmations/retries cannot charge or teach twice. Technical partial mutation requires explicit same-operation recovery and cannot silently report complete success; prepare validation before mutation rather than relying on blind refund/retry. Exact operation receipts/boundaries are implementation dependencies, not a universal transaction framework requirement.

## Relevant formulas and parameters

RULE-018 supplies current casting-cost quote; ECON supplies a separately named service price. No new sale multiplier, book capacity, learning limit, spell count cap or duplicate fee is selected. Default spellbook requirement enabled; default duplicate known-ID acquisition is a no-op/already-known result without charge. Mod duplicate policy must explicitly describe alternate entry/charge semantics.

## Required data

Stable learned entry/spell/custom definition/settings; origin/grant protection/source dependencies; manual order; current cost and blocked reasons; service/offer identity, usage/eligibility, price quote and request identity; duplicate policy/provenance; pending confirmation/recovery state where supported; UI preference data in declared scope. Exact schema, offer context versioning and protected-grant inventory remain dependencies.

## Inputs, outputs and events

Inputs: browse/inspect/sort/filter/manual move, deliberate use/recast, learn/grant, forget confirmation, service quote/purchase confirmation, source access changes and restore. Outputs: stable presentation/selection, readiness request/result, learned/already-known/forgotten outcome, one committed purchase or clear unchanged-state failure, preserved source distinctions and truthful blocked reasons. APIs/signals unselected. UI selection notification is not acquisition or cast commitment.

## Cross-system interactions

MAGIC-001/002 and DATA-011 validate definitions/providers/identity. MAGIC-003/004 own ready/cast/history and free/silence policies; MAGIC-010 derives active-effect HUD independently of learned list membership. MAGIC-012 owns crafted custom definitions. ITEM supplies spellbook possession/item power authority; innate/CHAR/transformation owners grants/protections. ECON/services own price/stock/access and checked payment; DATA/MOD resolve offers/policies. UI supplies pure views/extensions. SAVE/CORE-013 preserve native state/compatibility without grant replay.

## Edge cases and failure conditions

- Spellbook lost: knowledge remains inspectable but restricted by enabled default gate; disabling policy does not grant unknown spells.
- Same ID acquired twice or learned during purchase prompt: default no new charge/entry; unrelated names/IDs not collapsed.
- Sort/filter while confirmation open: stable intent survives; never buy/delete the newly indexed row.
- Offer/price/source eligibility changes: revalidate; renewed quote confirmation or unchanged-state failure, not silent purchase substitution.
- Forget readied/last spell: clear only matching uncast/history context; released effects survive.
- Protected/innate/item entry forget attempt: refuse ordinary learned deletion; owner removal remains separate.
- UI mod renders/queries costs: no readying/casting/grants/RNG or source bypass.
- Native restore: keep knowledge/custom settings/order/protection, no automatic casting or refreshed item power.

## Configuration and balancing options

Validated mods can enable/disable spellbook possession requirement, declare duplicate policy and service offers/overrides, and extend sorting/filtering/display. Default requirement remains enabled. Exact selector precedence/API/schema and additional views are owner work. No automatic new stock, pricing formula, protection exception or innate-to-learned conversion is approved.

## Save/load considerations

Native saves preserve learned entry identity, custom settings, source distinction/grant protections and manual order. Restore without rerunning purchases/grants or generating duplicates, refreshing item powers or automatically using a selected entry. Revalidate required definition/provider compatibility under existing DATA-011/MAGIC-010/CORE-013 policies; same ID alone does not authorize rewriting saved custom parameters.

UI sort/display preferences remain scoped preference state, not knowledge/cast state. Pending purchase/forget prompts may be saved only with explicitly supported coherent intent/operation state; otherwise follow SAVE/CORE safe admission rather than replay transactions. Exact schemas/migrations and preference scope remain dependencies. Classic/DFU save import outside scope.

## Technical constraints

Target Godot v4.7.2. Separate list views from authoritative source-owned knowledge, stable requests from row indices, and quotes from resource commits. UI extensions stay pure and checked operations are once-only. Exact services, quote versioning, transaction recovery and native serialization remain implementation design. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Learned/innate/item sources remain distinct across unified presentation; listing cannot grant unrestricted casting/learning/deletion.
2. Enabled-default spellbook requirement restricts ordinary use/recast/purchase without knowledge loss; validated toggle works explicitly.
3. Highlight/sort/filter/inspect have no gameplay effects; deliberate use enters MAGIC-003 with stable identity/current quote and blocked reasons.
4. Default known-ID acquisition adds/charges nothing; different IDs remain distinct despite same name; explicit alternate duplicate policy is validated.
5. Confirmed forgetting respects source/protection, clears matching uncast/history only and does not undo released effects.
6. Manual order/name/current-cost views and moddable UI options preserve identity/manual state and pending intents.
7. Explicit service offer eligibility/usage is distinct from registration; price and casting cost are separately presented.
8. Purchase revalidates exact retained quote/offer/service; changed price needs consent, failure unchanged, duplicate confirmation commits once.
9. Native restoration preserves knowledge/custom settings/protection/order with no acquisition/cast/item refresh replay and safe required-content compatibility.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-001–004/010, DATA-003/011, RULE-018 and CORE-013 boundaries plus recorded MAGIC-011-D01–D09. No direct contradiction identified. Item requirement resolves MAGIC-004's open spellbook/recast access dependency while origin remains independent of no-cost/animation flags. Forgetting affects knowledge/uncast history rather than released lifetime. Pure UI views preserve automatic casting only for deliberate use. Current quote/service payment separation preserves explicit ownership; native restore does not grant duplicates. Broader architecture proposals remain recommendations beyond confirmed policies.

## Outstanding questions

No further blocking spellbook/offers player-policy choice is identified. Before implementation is complete: define service stock/eligibility/pricing contracts, grant protection and spellbook source-access inventory, duplicate override schema, quote/intent/commit recovery, active-cast forgetting/source races, custom entry versioning, UI extension APIs/ties/preference scope and pending-prompt save eligibility. These dependencies cannot authorize index-based intent substitution, hidden charges, source-to-knowledge conversion, UI-triggered casts or silent required-content loss.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-011-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented service/access inventories, quote/commit recovery, duplicate-policy schemas, UI extension/preferences and native-save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
