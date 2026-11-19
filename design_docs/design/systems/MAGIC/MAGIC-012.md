# MAGIC-012 — Spellmaking

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Compose supported custom spells through an editable persistent draft and commit a named learned spell with checked once-only payment.

## Intended player experience

Players choose effects, parameters, order, target and element with understandable costs/conflicts. Draft edits never silently change targeting or execute magic. Creation can precede casting affordability. Drafts survive leaving the service and native loading; deliberate confirmation is required to pay and learn. Limits, parameter schemas and supported composition behavior are moddable.

## Confirmed requirements

MAGIC-012-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm composition/compatibility/order, supported bounded controls, conflict retention, separate previews, name/identity, persistent drafts and once-only creation. The complete specification is approved under MAGIC-012-A01.

MAGIC-001 crafting eligibility, MAGIC-002/006 complete supported authored-order effects, RULE-018 cost rules and MAGIC-011 knowledge/spellbook/duplicate rules remain binding. This feature does not approve every effect's crafting eligibility or ECON's service pricing/access.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime service/mod/failure fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/UserInterfaceWindows/`.

- `DaggerfallSpellMakerWindow.cs` has maxEffectsPerSpell=3 with one selectedTarget/selectedElement and spellmaking-filtered effect pickers. AddAndEditSlot opens per-entry settings.
- `UpdateAllowedButtons` intersects allowed target flags but unions element flags starting with Magic, and can select the first allowed target/element when prior selection becomes invalid. Target instead validates every entry and preserves conflicting player intent.
- `UpdateCosts` delegates to FormulaHelper.CalculateTotalEffectCosts. `BuyButton_OnMouseClick` requires spellbook, active effects, enough gold and a name; deducts gold, builds settings and adds learned spell. Stable captured confirmation/atomic failure is not established by that path.
- `DaggerfallEffectSettingsEditorWindow.cs` sets duration base/increase 1–60, chance base/increase 1–100, magnitude base/increase endpoints 1–100, and per-level divisors 1–20. Controls are enabled according to component support. These are crafting UI ranges, not universal imported-data validity limits.

## Detailed rules and behaviors

### Draft and composition

Maintain an editable draft separate from learned knowledge and active effects. Default composition has one to three active effects, one shared target and one shared element. An empty draft may exist for editing/zero quote but cannot be purchased/cast as a valid spell. Validated mod limits/composition profiles may extend this with complete UI, cost and execution support; no hidden three-slot serialization assumption may truncate added effects.

Only explicitly spellmaking-eligible effects are selectable under MAGIC-001; runtime support alone does not imply crafting access. Add/edit/remove/reorder entries while preserving authored order and settings. Repeated effects are allowed only where declared crafting rules permit; display duplicate/stacking restrictions. Repetition is not a universal guarantee of stacking under MAGIC-009.

Every entry must support the selected target and element. Validate the whole composition, not DFU's union-based element availability. Explicit mod profiles may declare supported alternative interpretations, but cannot silently drop effects or substitute a different spell.

If an edit invalidates target/element or another required constraint, retain the chosen values and explain the conflict. Block purchase until corrected; show valid alternatives without silently choosing one. Temporary invalid drafts are not usable definitions. Removing an entry does not implicitly reorder surviving entries or reset their parameters.

### Parameters, bounds and previews

Expose only components supported by each effect. Initial verified DFU crafting ranges where supported:

| Parameter | Initial crafting range |
| --- | --- |
| Duration base / increase | 1–60 |
| Chance base / increase | 1–100 |
| Magnitude base min/max and increase min/max | 1–100 |
| Supported per-level divisors | 1–20 |

Use explicit validated moddable bounds/defaults and effect-specific constraints. Exact initial default values require inventory verification; ranges alone do not establish defaults. Reject invalid divisors, reversed magnitude endpoints, unsupported components and unsafe arithmetic rather than silently repair. Crafted-editor bounds are distinct from valid imported spell domains; a valid imported zero does not automatically authorize a zero crafting control or vice versa.

Show current casting-cost and creation-price previews as separate concepts. RULE-018 calculates supported cost bases; ECON/service owners supply final price. Previews use explicit current player context, not hidden missing-caster defaults. They do not roll magnitudes/chances, apply effects, spend resources or grant practice. Invalid draft cannot display a false purchasable zero-price success; identify invalidity distinctly from an empty draft quote.

Permit buying a valid spell whose casting cost exceeds current magicka, provided creation price and service eligibility are satisfied. Casting affordability is not learning eligibility. Current quotes do not freeze a discount or bypass release-time checks.

### Naming, icons and identity

Require a nonblank player name. Duplicate display names are allowed; exact supported length/text normalization remains UI/data validation. Names/localization/list positions are not identity. Assign a distinct stable custom-spell identity at successful creation; draft/request identity is separate and cannot accidentally grant knowledge.

Icons are cosmetic; approved generic fallback may handle missing optional art without invalidating supported gameplay. No implicit effect/target change follows an icon choice. Exact icon inventory/UI is presentation scope.

### Draft persistence and reset

Retain unfinished draft through effect/name/icon subwindows, service exit/reopen and native saves. Draft persistence spends no gold and learns nothing. On return revalidate service access, providers, composition and price before enabling confirmation. A draft is not a reservation for old prices/stock/access.

Explicit New/Discard confirms clearing a nonempty draft. Exact reset UI and scope/multiple-draft capacity remain design dependencies; no silent loss on merely leaving a subwindow/service. Restored drafts never auto-purchase, ready or cast. Missing/incompatible content follows supported draft migration/recovery rather than publishing a reduced learned spell.

### Confirmation and creation commitment

Capture exact draft revision: ordered effects/settings, target, element, name, icon, service identity and price. Revalidate full supported composition, access, source references, funds and MAGIC-011's moddable spellbook possession requirement. It is enabled by default; disabling it does not grant unavailable service access or unsupported effects.

Changes to draft or price require renewed confirmation. Stable confirmation identity cannot depend on current list rows or mutable editor selection. Commit payment and one learned custom spell together through checked owner operations. Failure preserves gold, learned knowledge and editable draft; duplicate callback/retry cannot create another spell or charge again.

If unexpected partial mutation occurs, retain same-operation committed facts and use explicit recovery, not blind creation/refund retry. Exact commit preparation/receipts are implementation scope, not approval of a universal transaction framework. Report success only when learning/payment are complete.

Separately confirmed later creations may receive distinct custom IDs even with matching names/settings under MAGIC-011 duplicate policy. A redelivered confirmation is not a later intentional creation. Successful draft reset/history behavior must make that distinction explicit without silently deleting an unresolved operation.

## Relevant formulas and parameters

Initial max active entries=3, shared target/element; validated mod profile can override supported composition. Parameter range table defines crafting baseline, not runtime evaluation. RULE-018 owns cost arithmetic; ECON owns final creation price. No new coefficient, skill/level gate, creation-time duration, experience reward or price multiplier is introduced. Cost-to-practice options in MAGIC-004 concern eligible release, not mere drafting/creation.

## Required data

Draft/request identity and revision; ordered stable effect IDs/settings; supported crafting constraints/component bounds/defaults; target/element; name/icon; current cost and service price/access; validation reasons; retained confirmation; created custom identity/knowledge result and payment completion; saved draft/provenance/compatibility. Exact schemas and price-purpose/version representation remain dependencies.

## Inputs, outputs and events

Inputs: service access, add/edit/remove/reorder/name/icon/target/element, preview, New/Discard, confirm creation, current funds/quote/content and native restore. Outputs: retained valid/invalid draft with explanations, pure quotes, captured confirmation, one learned custom spell/payment or explicit unchanged-state failure/recovery. Concrete APIs/signals remain unselected; editing notifications cannot cast or learn.

## Cross-system interactions

MAGIC-001 supplies spellmaking eligibility/providers; MAGIC-002/005/006/009 supply supported targeting/order/admission/stack restrictions. MAGIC-011 owns learned entries, duplicate policy and spellbook toggle; MAGIC-003/004 execute created spells later. RULE-018 supplies validated quotes; ECON/services own price/access/funds; ITEM supplies book possession; DATA/MOD validate profile/bound overrides. UI provides scalable editor/conflict display, SAVE/CORE-013 draft/custom-state compatibility. Active-effect persistence MAGIC-010 is separate from authoring draft.

## Edge cases and failure conditions

- Mod raises effect count: preserve all entries through editing, quotes, identity/save and execution; no three-slot truncation.
- New effect conflicts with element: retain choice, report conflict, block creation; no automatic self-target substitution.
- Repeated ordered effect: preserve when eligible, show family stacking constraints rather than deduplicate silently.
- Invalid endpoints/divisor: explicit correction required, no silent repair or free success quote.
- Price/funds/access change during confirmation: revalidate; changed price/draft re-confirm, failure keeps draft/gold/knowledge.
- Missing book with enabled policy: no creation, draft survives. Toggle off does not bypass service/content rules.
- Save/reopen invalidates provider: retain supported recovery, no partial spell acquisition or automatic purchase.
- Duplicate confirmation versus deliberate second creation: one operation commits once; later confirmed new operation gets its own identity.

## Configuration and balancing options

Validated max-effect/composition profiles, per-effect craftability/duplicate restrictions, supported numeric bounds/defaults and UI editing/display are moddable. Existing spellbook requirement toggle applies. Exact profile APIs, override precedence, safe maximum support and alternative element semantics require explicit owner validation. Service balance/eligibility remains separate. No global new skill requirement, randomized creation failure or auto-cast-on-creation is approved.

## Save/load considerations

Native saves preserve unfinished draft revision/order/settings/name/icon without learning/payment replay. Created spells persist distinct custom identities/settings through MAGIC-011 compatibility rules. Restore never auto-purchases/casts or refreshes existing effects. Required provider/profile changes use explicit compatibility/migration/recovery; runtime complete-spell validation cannot be bypassed because data was previously authored.

Pending confirmation/partial creation is saved only with supported coherent intent/commit facts; otherwise safe SAVE admission must explain delay/rejection rather than record replayable payment. Exact draft schema, multiple-service scope and migration remain dependencies. Classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. Separate draft from learned definition, validation/quote from resource mutation, and stable requests from mutable UI rows. Editor must support approved mod limits without fixed-three-slot assumptions. Safe numeric domains, explicit provider metadata and once-only owner operations are required; exact architecture/serialization/API remains technical work. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Default ≤3 effects/shared target/element and supported mod profiles validate without truncation.
2. Crafting eligibility/duplicates/order and per-entry target/element constraints are preserved; incompatible drafts retain intent and cannot purchase.
3. Supported parameter controls follow verified ranges/validated overrides, rejecting invalid arithmetic/endpoints without silent repair.
4. Quotes are pure and distinguish current casting cost from creation price; casting unaffordability alone does not block paid learning.
5. Nonblank names/duplicate labels/cosmetic icons obey stable identity; one custom ID is assigned per committed creation.
6. Draft survives navigation/exit/native restore, revalidates on return and clears only through explicit confirmed New/Discard where nonempty.
7. Confirmation captures exact revision/price/service; changed intent/quote requires consent; failed operation preserves draft/gold/knowledge and duplicate delivery never charges/learns twice.
8. Spellbook toggle/source/service rules and native custom-definition compatibility remain intact; no restore purchase/cast or partial unsupported spell.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-001–004/006/009/011, DATA-011 and RULE-018 boundaries plus MAGIC-012-D01–D09. No direct contradiction identified. Authored ordering/repetition requires declared crafting eligibility rather than universal stacking. Every entry supports selected target/element, strengthening source UI validation consistently with complete conversion. Learning does not require cast affordability, while actual casting retains current-cost checks. Distinct custom identity and confirmation deduplication preserve MAGIC-011 duplicates policy. Persistent invalid drafts are not usable reduced definitions. Service pricing and family craftability remain open owner contracts.

## Outstanding questions

No further blocking spellmaking player-policy choice is identified. Before implementation is complete: inventory effect-specific craftability/default settings/duplicate constraints; define supported mod composition/bound schemas, safe UI limits and exact service price/access; specify names/icons, draft scope/reset after success, coherent confirmation/payment recovery and native draft/custom migrations. These dependencies cannot authorize silent retargeting, parameter repair, draft loss, partial spell publication or repeated payment/learning.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-012-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented effect/default inventories, mod composition schemas, service pricing/access, draft scope and native creation/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
