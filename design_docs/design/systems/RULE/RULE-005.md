# RULE-005 — Derived attributes

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Translate resolved attributes into shared numeric modifiers and capacities, while keeping action resolution and permanent progression under their owning systems.

## Intended player experience

Attribute changes have predictable effects on current capabilities, with inspectable explanations and consistent rounding. Temporary bonuses do not rewrite earned health or reroll prepared rewards. Loading restores capabilities without duplicating bonuses.

## Confirmed requirements

RULE-005-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm seven vanilla formulas, mathematical floor, live/permanent input ownership, separation from consuming rules, recomputation, supported extended inputs, validated customization, DFU-style healing, inspectable presentation and source-based restoration.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#DamageModifier`, `MaxEncumbrance`, `SpellPoints`, `MagicResist`, `ToHitModifier`, `HitPointsModifier` and `HealingRateModifier` implement the seven formulas below using floor and expose replacement hooks.
- `HealingRateModifier` comments that original Daggerfall appears to adjust negative healing modifiers by +1, and explicitly does not recreate that behavior. The comment is evidence of DFU's intention, not independently verified DOS behavior.
- `Game/Entities/DaggerfallEntity.cs` exposes live-derived modifier properties. `GetRawMaxMagicka` derives player magicka from live Intelligence/career multiplier, while enemy raw magicka is stored separately. Its carrying-capacity path also applies effects beyond the strength helper.
- `FormulaHelper#CalculateHitPointsPerLevelUp` uses permanent Endurance; `CalculateHealthRecoveryRate` combines a healing modifier with other inputs and a final minimum. `CalculateStatsToHit` uses live attacker/target Luck and Agility differences with integer division, rather than simply adding the displayed agility helper.
- `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#UpdatePlayerValues` presents derived character values, including carrying capacity from working live Strength.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full consumer coverage, runtime behavior and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Vanilla formulas and rounding

| Derived value | Formula | Intended input |
| --- | --- | --- |
| Damage modifier | floor((S−50)/5) | Live Strength S |
| Strength-based carrying capacity | floor(1.5×S) | Live Strength S |
| Base player magicka | floor(I×M) | Live Intelligence I; resolved career multiplier M |
| Magic-resistance modifier | floor(W/10) | Live Willpower W |
| Agility to-hit modifier | floor(A/10)−5 | Live Agility A |
| Health-growth Endurance modifier | floor(E/10)−5 | Permanent Endurance E at reward preparation |
| Healing Endurance modifier | floor(E/10)−5 | Live Endurance E |

Use mathematical floor, including negative results; do not substitute truncation toward zero. Strength 49 gives damage modifier −1, Strength 50 gives 0. Agility/Endurance 49 give −1, 50 give 0; Willpower 49 gives 4. Strength 51 gives capacity 76. For example, Intelligence 51 and multiplier 1.5 give base magicka 76.

Retain these as the vanilla baseline, with validated customization below. Healing uses the stated formula without the original-game negative-modifier adjustment described in DFU's comment. Recovery owners choose final healing rates and minimums.

### Inputs and consumer ownership

CHAR-011 resolves permanent/live attributes and their supported bounds. Apply these formulas to valid resolved inputs, including zero and approved values above 100, without another hidden attribute clamp. At zero, damage modifier is −10, agility/Endurance modifiers −5, and the vanilla capacity/magicka/resistance formulas yield zero for valid nonnegative multipliers. Negative modifiers are legitimate inputs to consuming rules, not invalid state by themselves.

Current gameplay capabilities use live attributes. Earned health growth uses captured permanent Endurance under CHAR-015. Temporary Endurance never retroactively changes awarded health or an already prepared reward. This feature does not assign an additional live-Endurance bonus to current maximum health.

These helpers are not complete action formulas. COMBAT defines how damage and agility participate; MAGIC defines resistance interpretation; recovery defines final healing; ITEM/MOVE define encumbrance consequences and capacity effects. Do not automatically treat resistance as a standalone chance, add agility twice, turn negative healing modifiers into damage, or infer a final damage minimum here. Carrying-capacity units/display conversions remain the ITEM/MOVE contract, consistently shared with UI.

Base player magicka is distinct from final effective maximum after owner-approved modifiers. CHAR-018 owns those modifiers and vital reconciliation. The player-derived rule is not automatically imposed on enemies with different approved models.

### Updates and presentation

Recompute affected values when valid attribute values, career multiplier or relevant source state changes. Source addition/removal and cap changes must yield consistent updated capabilities without replaying source effects, rewards or random draws. Exact caching/event mechanisms remain engineering choices.

Maximum magicka increases leave current magicka unchanged; decreases clamp current only if above the new effective maximum, following CHAR-018. This is not a refill/heal operation. Fresh initialization follows CHAR-017; restore is not fresh initialization.

Player presentation uses the same calculations and resolved inputs as gameplay. Provide inspectable explanations of contributing attributes, multiplier and relevant formula/source customization. Distinguish permanent/current context and modifiers from final action chances or recovery rates. A prospective permanent-Endurance growth modifier is not a promise to alter an already prepared health reward. Exact UI layout remains UI scope; inspections do not mutate state.

### Validation and customization

Permit validated data overrides for explicitly declared formula parameters and explicit replacement hooks under RULE-004. Concrete supported parameters, hook IDs, versioned signatures and output domains must be established before implementation. Do not infer a generic formula language, unrestricted expression execution or arbitrary extra attributes from this permission.

Reject malformed/nonfinite multipliers, unsupported input/output domains and arithmetic overflow. Domains must be compatible with CHAR-011/018 and each consumer, including extended attributes. No silent integer narrowing, wrap, hidden vanilla fallback or automatic clamp may disguise an invalid definition. An allowed negative modifier differs from an invalid negative capacity/maximum; supported multiplier/capacity domains must respect vital/capacity owners' nonnegative limits.

DATA-003 controls invalid-definition recovery and locked configuration. RULE-004 validates/selects hooks and handles runtime callback failures without automatic fallback. Ordinary valid derived queries are deterministic and side-effect-free; they consume no randomness and cannot grant progression or reapply equipment/effects.

## Required data

Stable attribute identities and resolved live/permanent values; validated career magicka multiplier; supported formula parameters/provider provenance; explicit numeric domains/rounding; active source context needed for final capacities; and captured reward inputs/results under CHAR-015. Concrete schemas, cache representation and hook inventory remain dependencies.

## Inputs, outputs and events

Inputs: validated resolved attribute/multiplier values, approved formula configuration and relevant source changes. Outputs: integer modifier/base capacity or explicit validation/runtime failure. Owners publish consistent updated capabilities through their declared operations. No API/event names are selected, and recomputation does not emit earned rewards or duplicate depletion events by itself.

## Cross-system interactions

CHAR-011 owns attribute resolution; CHAR-015/006/008 retain progression/creation results; CHAR-017/018 own initialization, restore and vital limits. ITEM/MOVE own effective encumbrance and consequences. COMBAT/MAGIC/recovery owners consume modifiers once through their full rules. RULE-004 supplies explicit hook validation/selection/recovery; DATA-003 supplies definition resolution/locking. SAVE rebuilds derived state from authoritative inputs; UI/DEV expose consistent explanations. CORE gates restoration/readiness and rejects stale work.

## Edge cases and failure conditions

- Check negative-floor boundaries and increments such as 49→50; do not accidentally change unrelated combat integer-division rules.
- Zero/above-100 valid attributes reach supported formulas without duplicate clamping. Invalid/unknown identities are errors, not successful zero values.
- Removed buffs/cap sources recompute from surviving sources without erasing permanent values or applying old caches as bonuses.
- A capacity reduction may leave inventory overweight; disposal, transfer restrictions and movement behavior remain ITEM/MOVE decisions, not automatic item deletion here.
- Saved prepared growth rewards keep captured results even when current Endurance or formula definitions differ; incompatible content follows explicit SAVE recovery.
- Malformed/overflowing overrides fail under DATA/RULE-004 contracts rather than publishing partial capabilities or rerunning fallback effects.

## Configuration and balancing options

Vanilla constants/formulas are the baseline. Supported parameters and explicit hooks allow validated customization within compatible numeric and consumer domains. No universal minimum damage, healing floor, resistance percentage cap, enemy magicka conversion or retroactive health recalculation is introduced. Changing existing content cannot silently migrate earned rewards.

## Save/load considerations

Restore authoritative permanent values, career settings and valid modifier sources, then rebuild derived capabilities before gameplay readiness. Saved derived caches cannot become additional modifier sources; validate/replace caches as engineering data rather than authoritative permanent state. Preserve current pools under CHAR-017/018 and previously awarded health/prepared reward rolls under CHAR-015. Restoration must not reroll, refill, replay rewards or duplicate source application. Invalid saved inputs/configuration require explicit SAVE migration/recovery instead of silent repair.

## Technical constraints

Target: Godot 4.7.2. Use explicit inputs, safe arithmetic and documented floor behavior; preserve supported fractional multipliers accurately at integer boundaries. Concrete numeric representation remains engineering scope. Separate pure derived calculations from owner-controlled changes/notifications. No game implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. All seven vanilla formulas match the table, including zero, 49/50 boundaries, supported extended attributes and fractional multiplier floor cases.
2. Live changes update current capabilities; permanent captured Endurance governs earned growth without retroactively changing health or prepared rewards.
3. Damage/to-hit/healing penalties remain valid; consumers apply their own final bounds/semantics without duplicate modifiers.
4. Attribute/source/multiplier changes recompute consistently without effect/reward replay or random draws. Magicka maximum changes obey CHAR-018 without refilling.
5. Player explanations use gameplay's resolved calculations and distinguish modifiers/base capacities from final chances/rates.
6. Valid customization follows DATA-003/RULE-004; nonfinite, unsupported or overflowing inputs/results fail explicitly without wrap, silent clamp or vanilla fallback.
7. Save/load reconstructs derived state from authoritative inputs without duplicate bonuses, changed retained rewards or unintended pool filling.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this design interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-011/015/017/018, DATA-003 and RULE-004. Live/permanent distinctions, retained rewards, non-refilling maximum changes, validated configuration and runtime recovery remain binding. This specification approves the seven helper baselines, not complete combat/resistance/recovery/encumbrance behavior. Existing DFU consumer calls do not automatically approve additional mechanics.

## Outstanding questions and approval

No blocking gameplay policy question remains for these helper formulas. Before implementation: complete consumer/input audit, numeric/multiplier domains and rounding representation, parameter/hook schemas, carrying-capacity units/effect integration, coherent updates/UI explanations and SAVE reconstruction contracts. Full action formulas remain their owners' reviews. These dependencies cannot waive the confirmed floor behavior, attribute ownership, source-based restore or retained-reward rules.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-005-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
