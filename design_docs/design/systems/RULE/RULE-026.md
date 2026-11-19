# RULE-026 — Material weighting

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Select generated materials through an explicit level-adjusted baseline or validated alternative policy, preserving authored probability semantics and assigned item identity.

## Intended player experience

Generation level biases material quality without rerolling items on inspection/loading. Armor category and plate material are distinct decisions. Mods can change distributions/add materials, with tooling showing actual probabilities rather than misleading normalized legacy entries.

## Confirmed requirements

RULE-026-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve exact moddable legacy selection/boundaries, explicit generation level, armor 69/20/11 and plate-only draw, complete table validation, retained results and isolated distribution inspection.

RULE-003 supplies purpose-owned randomness/retries; RULE-004/DATA-003 validated locked policies. ITEM/content owners supply material/template compatibility and resulting properties; this feature selects materials rather than defines their damage/value/capacity.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#RandomMaterial` uses level−10 multiplied by 4 below zero or 2 otherwise, adds uniform 0–255, clamps 0–256 and traverses ItemBuilder.materialsByModifier with strict entry<remaining comparison/subtraction.
- `Game/Items/ItemBuilder.cs#materialsByModifier` is {64,128,10,21,13,8,5,3,2,5}, in classic weapon material order iron through daedric.
- `RandomArmorMaterial` draws 1–100: 1–69 leather, 70–89 chain, 90–100 plate. Plate invokes RandomMaterial then uses numeric armor offset 0x0200. Both helpers expose overrides.
- `ItemBuilder` invokes the helpers during weapon/armor generation; material weight/value/condition settings live separately. Complete caller level adjustment and template routing remain verification dependencies.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete generation/content runtime and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Generation context and ownership

Require an explicit valid generation level L and purpose/operation context. Normally use actual claimed player level, not highest earned/unclaimed target; supported encounter/loot contexts can explicitly supply another level. Do not silently read a global player or replace missing level with zero/default.

Use owned loot/item-generation randomness under RULE-003. Retain selected category/material when generation resolves. Queries, scene reconstruction, loading and technical retries cannot reroll the result. This does not mandate deterministic world loot by seed; explicit classic generation, if adopted by another owner, remains RULE-002 scope.

ITEM must define valid template/material combinations and apply properties through its own rules. An unsupported mapping fails before publishing an item; it cannot silently select iron or retry until a material fits. Any conditional filtering/reselection policy requires an explicit validated alternative distribution so tooling/gameplay agree.

### Legacy selector

Compute level offset A=4×(L−10) when L<10, otherwise A=2×(L−10). Obtain one unbiased uniform integer R in 0..255; adjusted value X=clamp(R+A,0,256).

Starting at first ordered table entry i, while entry[i]<remaining X, subtract entry[i] and advance i. Stop when entry[i]>=remaining and return its mapped stable material ID. Preserve the strict comparison, initial zero and upper endpoint; do not replace this with ordinary cumulative weighted sampling.

Vanilla entries are iron 64, steel 128, silver 10, elven 21, dwarven 13, mithril 8, adamantium 5, ebony 3, orcish 2 and daedric 5. These entries sum to 259 but are not normalized weights over 259 outcomes. At level 10, iron receives adjusted 0–64 inclusive (65 of 256 raw draws), steel 65–192 (128 draws), and later reachable intervals follow exact traversal. Saturation at other levels changes masses, including endpoint piles.

Validate safe level offset/intermediates, ordered IDs, supported integer entries and complete mapping for every reachable X in 0–256. Nonnegative entries may only be accepted where traversal semantics/termination are explicitly validated; zero does not universally mean excluded because X=0 can select the first zero entry. Do not promise ordinary weight semantics for this mode. Table exhaustion, invalid IDs or unsafe arithmetic is a configuration error, not random fallback.

### Armor category

Vanilla category selection uses uniform integer 1–100: leather for 1–69, chain 70–89, plate 90–100. Thus probabilities are 69/20/11, not a rounded 70/20/10 assumption. Category chances/policy are independently moddable through explicit validated distribution contracts.

Draw category first. Only plate proceeds to its declared material selector; leather/chain consume no unused plate draw. Retain both results through retry. Map plate material via stable supported IDs/adapters rather than assuming every new material has a valid numeric 0x0200 counterpart.

### Alternative policies and modding

Both baseline selectors support validated parameters/tables and explicit RULE-004 hooks, including added materials. Alternative conventional weighted selection must declare its distinct sampling semantics, supported nonnegative weights/positive total, output mappings and draw/result contract. Do not normalize legacy entries silently or claim identical seeded/output distributions.

Concrete supported level/material/range domains and hooks require schema contracts before use. DATA-003 locks configuration/provenance; RULE-004 validates identity/signature/winner and runtime failure without automatic fallback. Added materials require complete ITEM/COMBAT/value/capacity adapters where relevant, not merely a selector table entry.

### Inspection

Provide isolated tooling/diagnostics for resulting material probabilities at chosen supported levels/context. Legacy exact probabilities can be derived by enumerating its 256 raw values through the declared mapping; conditional armor totals combine category probabilities with plate mapping.

Do not label tableEntry/sum as a legacy probability. Diagnostic simulations use isolated sources and cannot advance live loot/combat randomness. Queries do not create items or reroll assigned materials. Tool/UI presentation and supported output format remain engineering scope.

## Relevant formulas and parameters

- A=4×(L−10) below 10; A=2×(L−10) otherwise.
- R~uniform integers [0,255]; X=clamp(R+A,0,256).
- Legacy traversal uses strict entry<remaining, then subtract/advance.
- Vanilla table {64,128,10,21,13,8,5,3,2,5}; armor category 69/20/11.

At L=1 offset −36 places 37 raw values at X=0; all raw values yielding X<=64 select iron, giving 101/256 iron probability. At L=10 no offset: iron 65/256, steel 128/256. X=256 must still map safely even though the raw draw's maximum is 255. Higher level can saturate many raw draws to the same final endpoint; this is intentional baseline behavior.

## Required data

Explicit generation level/purpose/operation; stable ordered material/category IDs and legacy/alternative mode; validated table/offset/clamp/distribution parameters; template compatibility mappings/provenance; owned source and retained category/material. Concrete schemas/operation identity remain dependencies.

## Inputs, outputs and events

Inputs: valid owner-authorized generation request or pure distribution query. Outputs: selected/retained category/material, distribution explanation or explicit error. This helper does not add inventory, price items or award practice. ITEM owns item creation/commit/events; APIs/signals are unselected.

## Cross-system interactions

ITEM/content own templates/material mappings/properties; CHAR supplies actual level when that context is chosen; NPC/loot owners authorize explicit alternate levels. RULE-003 owns sources/retries, RULE-004/DATA-003 validated policies, RULE-012/014/018 material consumers. CORE/SAVE preserve assigned item identity; UI/DEV inspect without draws.

## Edge cases and failure conditions

- Boundary equality/zero/256 must follow legacy traversal, not ordinary weighted assumptions.
- Unsupported levels/huge offsets/table gaps fail safely without wrapping/index overflow or iron fallback.
- Leather/chain skip plate selection; partial retry cannot reselect category after plate failure.
- Item constraints cannot silently induce rejection sampling or change probabilities without an explicit declared policy.
- Missing added-material armor/value/effect adapters block invalid generation rather than publish a partly valid item.

## Configuration and balancing options

Support level pivot/slopes/draw/clamp/table policies and armor category/plate-selector policies through explicit valid schemas/hooks; exact exposed fields remain dependencies. Conventional alternatives and added materials are supported with declared semantics. No new automatic item-level stat scaling, enchantment probability, enemy equipment policy or merchant restock rule is introduced.

## Save/load considerations

Persist assigned material/category and owner-required item/partial-generation facts. Restore without rerolling from current player level or changed table. New generation uses current valid locked policy; incompatible added IDs/definitions need explicit migration/recovery. A retained result is not permission to reconstruct a different material through a changed numeric enum order. Future unresolved randomness remains fresh under RULE-003.

## Technical constraints

Target: Godot 4.7.2. Use safe integer arithmetic/unbiased bounded draws and stable IDs. Separate sampling mode, validation, compatibility and item commit. Numeric domains/interfaces/schema remain engineering dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Legacy mapping preserves raw range, piecewise offsets, clamp endpoints and strict equality traversal at representative levels.
2. All reachable 0–256 values resolve safely for valid tables; malformed definitions/unsupported IDs fail without fallback.
3. Armor baseline is exactly 69/20/11, with category-first and plate-only material draws/retained retry results.
4. Both selectors support validated mod policies/materials with explicit alternative semantics and compatible item mappings.
5. Assigned material survives load/query/definition-order changes without reroll or silent reinterpretation.
6. Isolated probability tooling reflects actual mapping, including level shifts/saturation, without live draws or normalized-legacy mislabelling.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed RULE-003/004/012/014/018 and DATA-003. Owned nonclassic generation does not imply classic RNG parity. Material selection remains separate from eligibility/damage/capacity and assigned outcomes remain saved facts. Exact legacy table semantics deliberately differ from conventional weights; supported alternatives must be named rather than silently substituted.

## Outstanding questions and approval

No blocking material-selection policy question remains. Before implementation: complete generation-level caller audit, numeric/table/hook schemas, stable material/category mappings and ITEM compatibility/property adapters, source/result identity, diagnostic format and SAVE migrations. These cannot waive exact legacy boundaries, both-selector moddability or retained generation results.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-026-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented ITEM/content/numeric and generation/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
