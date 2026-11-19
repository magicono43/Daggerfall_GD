# RULE-018 — Spell costs and enchantment capacity

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Calculate effect/spell cost bases, classic enchanted-item spell costs and material-dependent enchantment capacity through distinct validated models. Keep quotes separate from resource commitment.

## Intended player experience

Spell settings, school skill and targeting determine explainable casting costs. Valid non-scaling effects have explicit costs rather than accidental free behavior. Items have understandable material capacity independent of condition/charges. Previews match the rules used at commitment without spending resources.

## Confirmed requirements

RULE-018-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve moddable separate models, explicit empty/invalid handling, nonnegative skill reduction, staged rounding, forced-minimum mode, safe capacity domains, fixed-cost effects, classic-item mappings and shared breakdown/commit separation.

CHAR-011 supplies live skills and CHAR-018 owns magicka spending. DATA-011 owns validated effect definitions; DATA-003/RULE-004 own configuration/hook validation and explicit failure recovery. MAGIC/ITEM/ECON own eligibility and atomic actions.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateEffectCosts` totals supported duration/chance/magnitude gold components and computes integer gold×(110−live school skill)/400. Magnitude ranges use integer midpoint. No supported components invokes MakeEffectCosts(60,100,160) with settings 1/1/1 as a fallback valuation.
- `GetEffectComponentCosts` computes trunc(offset+CostA×starting+CostB×trunc(increase/perLevel)), with integer division in the inspected inputs. `CalculateTotalEffectCosts` sums active entries, applies target multipliers then enforces spell-point minimum 5 or forced-minimum mode. Null/empty arrays return zero; blank slots are skipped, missing templates return zero and a nonempty blank array can still receive the floor.
- `ApplyTargetCostMultiplier` uses self/touch ×1, single ranged ×1.5, area caster ×2 and area ranged ×2.5, truncating each total after multiplication.
- `CalculateCastingCost` uses classic type/subtype/settings/coefficient tables, up to three classic slots, reference skill 50 for item enchanting or live mapped player skill otherwise, target-range scaling and minimum 5. `GetSpellEnchantPtCost` returns 10×that cost for a matching record, otherwise zero.
- `GetItemEnchantmentPower` returns base template points+floor(base×material modifier). Weapon/armor material tables include iron −25%, silver/adamantium +75%, elven/mithril +25%, dwarven +50%, ebony +100%, orcish +150%, daedric +200%; steel and basic armor use zero modifier. Source comments describe armor progression as uncertain relative to classic.
- `CalculateCasterLevel` returns caster Level or 1 when absent; exact exceptional caster-level semantics require MAGIC context, not a universal null default.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete coefficient provenance, classic parity and runtime crafting/casting behavior remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Valid drafts and context

An explicitly empty spell draft has zero quote but is uncastable. Blank slots are inactive; a nonempty array containing no active effects is not a valid spell merely because a minimum applies. Unknown/missing active effect IDs, unsupported settings, malformed records or required caster/item/target context fail explicitly rather than contribute zero.

Supply explicit caster context and resolved live effect-school skill. Do not silently price an NPC/preview using the current player because context is absent. MAGIC must define any context-free author quote or explicit default caster/level; source null-as-player/level-one behavior is not automatic target permission.

### Effect and spell totals

For each supported duration/chance/magnitude component, retain baseline component cost g=trunc(O+A×starting+B×trunc(increase/perLevel)). Validate supported settings and positive divisors before arithmetic. Magnitude base/plus use their integer averaged endpoints rather than random rolls. Preserve truncation stages and safe intermediate arithmetic rather than rounding only the final spell.

Sum a valid effect's component gold basis G. For valid effects with no scalable components, use an explicit fixed-cost definition retaining the inspected DFU-equivalent baseline; the exact resolved amount/coefficient mapping must be fixture-verified before implementation. Do not turn absence of components into missing content or infer a free cost.

Effect casting basis C=trunc(G×max(0,110−S)/400), S=live school skill. Negative/above-100 valid skills follow supported domains; no extra global skill clamp is introduced. The nonnegative reduction factor prevents extended skill from generating negative costs/refunds. Skill reduction curve/coefficient parameters are moddable.

Sum per-effect G/C, then multiply each sum by its target multiplier and truncate toward zero. Defaults: self/touch 1, ranged single 1.5, area caster 2, ranged area 2.5. Finally apply configured spell-point minimum M, vanilla 5. Gold basis is not subject to that casting floor and is not automatically the final merchant/crafting price; ECON supplies later pricing rules.

### Special minimum mode

An explicit owner-authorized mode sets casting cost to configured M, leaving gold basis unchanged. Eligibility is moddable under supported MAGIC contracts. Reflection/absorption valuation uses normal cost rather than automatically inheriting this discount. Cost purpose must therefore be explicit; a single unlabelled discounted cache cannot serve every consumer.

### Classic enchanted-item costs

Keep classic-record coefficient/settings mappings separate from entity-cast effect-template costs. Baseline item-enchanting reference school skill is 50; alternate supported non-item purposes use explicit mapped caster skill. Apply the approved nonnegative skill-reduction safety to skill-dependent calculations rather than permit negative costs.

Retain source stage order: per-classic-effect settings cost and skill factor, sum valid classic slots, target range multiplier, configured floor. Baseline range modifiers 2/2/3/4/5 followed by division/shift by 2 correspond to ×1/1/1.5/2/2.5 on nonnegative totals. Preserve integer rounding; do not substitute the modern effect total as an assumed equivalent.

Spell enchantment-point basis is 10×classic casting cost, moddable. Source tables/reference skill/mappings/floors are moddable through explicit schemas/hooks. Unsupported IDs/type/subtype/settings or missing spell records fail, not zero-price successes. Added effects require supported mappings/cost contracts instead of guessed classic array indices; classic slot limits are an adapter property, not an automatic universal limit on new spells.

### Item capacity

Capacity P=base+floor(base×material modifier). Validate nonnegative supported base, finite modifier and nonnegative safe final P; zero is valid. Weapons/armor use explicit validated material mappings. Other categories use declared base capacity unless an explicit item policy applies scaling. Unknown required material IDs fail rather than silently use steel/default.

Vanilla weapon modifiers: iron −0.25; steel 0; silver/adamantium +0.75; elven/mithril +0.25; dwarven +0.5; ebony +1; orcish +1.5; daedric +2. Armor baseline uses that progression, with leather/chain/steel variants at zero. Complete stable material/variant mapping and capacity bases must be verified under ITEM/DATA before use.

Capacity, current condition, remaining charge/resource and occupied enchantment points are separate quantities. This calculation does not refill, repair, apply enchantments or authorize over-cap crafting. ITEM/MAGIC must define usage composition, drawbacks, eligibility and item changes explicitly. Material tables and category policies remain moddable.

### Quotes, customization and commitment

Provide inspectable breakdowns of effect settings/costs, school reduction, target multiplier, floor/special mode, classic-item purpose and capacity/usage inputs. Quote/query calculations are deterministic and draw no randomness or resources. Revalidate current caster/item/settings/policies before commitment; changed inputs require owner-controlled updated quote/authorization, not spending a stale amount.

MAGIC/ITEM/ECON own atomic spend/cast/craft/purchase and failed-action costs; this feature does not define them. Explicit RULE-004 hooks must identify calculation purpose/stage/input/output domains and cannot secretly mutate pools or execute effects during pricing. DATA-003 lock/recovery applies; negative/nonfinite/overflowing costs or unsupported coefficients/divisors fail rather than silently become vanilla values.

## Relevant formulas and parameters

- Component g=trunc(O+A×starting+B×trunc(increase/perLevel)).
- Effect G=sum supported component costs or explicit no-component fixed cost.
- Effect C=trunc(G×max(0,110−S)/400).
- Spell cost=max(M,trunc(target multiplier×sum C)), or forced M for authorized special casting purpose; M=5 baseline.
- Gold basis=trunc(target multiplier×sum G).
- Classic spell enchantment points=10×classic casting cost; reference enchanting skill=50.
- Capacity=base+floor(base×material modifier).

Example: effect G=100,S=50 gives C=15; ranged-single multiplier makes 22 after truncation. S=110 or above gives zero effect basis but a valid ordinary spell still costs baseline minimum 5. Item base 101 with iron modifier −0.25 gives 101+floor(−25.25)=75, not 76.

## Required data

Stable effect/school/target/item/material identities; validated settings/coefficient mappings; explicit caster/quote purpose/live skill; target multipliers/minimum/special eligibility; classic records/reference context; base capacity/material policy/usage; resolved provenance and committed-action identity. Concrete schemas/cache versioning remain dependencies.

## Inputs, outputs and events

Inputs: validated effect draft/record, explicit caster/target/purpose and item/configuration queries. Outputs: gold/casting/enchantment-point/capacity bases and explanations, uncastable-empty result or explicit failure. Queries do not claim crafting success or spend resources. Owner events follow coherent commitment; APIs/signals remain unselected.

## Cross-system interactions

MAGIC owns spell validation/casting/maker/reflection/absorption purposes; ITEM owns templates/materials/condition/usage; ECON final prices/payment. CHAR-011 supplies live skill and CHAR-018 authoritative magicka spending. DATA-011/003 resolve effects/locked definitions; RULE-004 validates hooks. CORE/SAVE gate context/restoration, UI/DEV share quotes without mutation.

## Edge cases and failure conditions

- Empty drafts differ from unknown effects and blank-slot pseudo-spells; only legitimate active effects participate in valid totals.
- Zero divisors, malformed ranges, unknown target types/materials and overflow fail before a quote is published.
- High skill cannot create negative cost/refunds; permitted zero configured costs remain subject to owner eligibility and final configured floor.
- Missing classic records cannot become zero enchantment points; fixed-cost non-scaling effects require explicit definitions.
- Quote refresh does not cast, spend, repair, refill or reroll effects. Conflicting provider/runtime failures use explicit recovery without silent fallback.

## Configuration and balancing options

Support validated component/fixed costs, skill reduction, target multipliers, minimum/special mode, classic coefficients/reference/mapping and base/material capacity policies through explicit schemas/hooks. Keep separate valuation purposes and numeric units. No universal merchant markup, arbitrary effect interpreter, free-spell eligibility or automatic enchantment drawback capacity is introduced.

## Save/load considerations

Save authoritative spell/item/settings/definition context and owner resource/usage state; derive quotes/capacity from valid restored inputs. Saved costs are not extra capacity or resource grants. Required definition changes use explicit compatibility/migration rather than zero pricing or reinterpreting established items silently. Pending cast/crafting transactions and quote acceptance persistence remain owner/SAVE contracts; restore cannot repeat spending or enchantment application.

## Technical constraints

Target: Godot 4.7.2. Use safe declared integer/fractional arithmetic and stage-specific truncation/floor, explicit contexts and pure quotes. Verify classic mappings/coefficient and zero-component fixtures before claiming compatibility. Interfaces/numeric widths/cache/serialization remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Staged component/effect/target/floor calculations match fixtures without replacing them with final-only rounding or random magnitude selection.
2. Empty drafts are zero/uncastable; missing active definitions/unsupported records fail instead of pricing zero.
3. Extended school skill uses nonnegative reduction and cannot produce refunds; special mode sets only casting minimum and does not leak into reflection/absorption valuation.
4. Valid no-component effects have explicit moddable fixed costs; classic-item models retain explicit reference/mapping/range/point conversion behavior.
5. Capacity matches signed floor/material tables, permits valid zero and rejects unsupported/negative/nonfinite/overflowing results; condition/charges remain distinct.
6. Modded parameters/hooks validate purpose/stage/domains and use explicit recovery. Shared breakdowns spend nothing and current inputs are revalidated before owner commitment.
7. Restore derives valid quotes/state without duplicate spend/craft/effect/refill or silent definition reinterpretation.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-011/018, DATA-003/011 and RULE-004. Live skills have explicit consumer safety instead of global clamping; atomic spending remains CHAR/MAGIC-owned. Empty/invalid distinction preserves explicit data recovery. Separate normal/special/item purposes avoid accidental discounted valuations. Numeric algorithms do not approve spellmaker eligibility, item drawback rules or final economy pricing automatically.

## Outstanding questions and approval

No blocking shared-cost policy question remains. Before implementation: verify all coefficient/fixed-cost/classic fixtures, supported numeric/mod schemas, caster/effective-level and purpose adapters, material/usage policies, special-mode eligibility, quote/commit and SAVE integration. These cannot waive distinct models, nonnegative costs, empty/invalid handling, rounding order or explicit capacity domains.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-018-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented cost-mapping, numeric-domain and MAGIC/ITEM/ECON integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
