# RULE-010 — Theft

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Compute distinct pickpocket-success and shoplifting-detection probabilities with moddable formulas, limits and burden. Separate calculation from theft eligibility, loot and legal consequences.

## Intended player experience

Live skill, supported target context and the evaluated basket determine clearly labelled risk. Qualitative feedback is the default, with optional exact percentages. Inspection cannot initiate theft; mods can rebalance either model without silently reversing success/detection meaning.

## Confirmed requirements

RULE-010-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve separate moddable models, independent moddable limits, live skill/actual level, explicit target context, moddable weight/count burden, labelled feedback and one result per authorized check. Interaction/loot/legal policies remain owner-reviewed.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculatePickpocketingChance` computes live Pickpocket plus 5×(player Level−enemy Level) when EnemyEntity exists, otherwise skill alone; clamps to 5–95. This is success probability.
- `CalculateShopliftingChance` computes 100−live Pickpocket+shop quality+weightAndNumItems, clamped to 5–95. This is detection probability. Both helpers expose overrides.
- `Game/PlayerActivate.cs#Pickpocket` tallies practice, checks success, then separately checks whether gold is found and draws an amount. Failure can trigger crime/guards or enemy hostility. These observed outcomes are not automatically approved here.
- `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#DoSteal` supplies truncated basket weight plus basketItems.Count and treats a failed detection roll as undetected success. `DaggerfallInventoryWindow.cs#AttemptPrivatePropertyTheft` uses its theftBasket with separate consequence timing.
- `Game/Items/ItemCollection.cs#Count` counts entries; `GetNumItems` includes stack quantities. `GetWeight` sums stackCount×EffectiveUnitWeightInKg and documents kilograms and a classic arrow exception. Full item weight/exemption semantics require owner verification.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full transfer/detection ordering, runtime stack behavior and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Pickpocket success

Use live Pickpocket S and actual claimed player level L. For an explicitly supported enemy-level target with valid level T, vanilla raw success chance is Cp=S+5×(L−T). Other explicitly supported targets use skill-only Cp=S. Missing required target data fails rather than selecting an easier model. An accidental null/stale reference is not a valid townsperson.

Earned/unclaimed levels do not substitute for L. Valid temporary skill bonuses/penalties apply under CHAR-011 without another hidden skill clamp. Target eligibility and any target-level mapping remain NPC/MOVE owner contracts.

### Shoplifting detection and burden

Vanilla raw detection chance is Cd=100−S+Q+B, with validated shop quality Q and burden B. Greater quality/burden increases detection risk under this baseline; do not silently invert the quality term based on an assumed interpretation of quality.

Baseline B=trunc(W)+N, where W is nonnegative total evaluated weight and N counts collection entries/stacks rather than units within stacks. Sum weight before truncation toward zero, rather than truncating each item's weight separately. N is authoritative basket count, not UI row count or total player inventory.

Weight/count coefficients and count policy are moddable. ITEM/ECON must define authoritative basket construction, evaluation timing, weight units/inclusions, supported alternative count policies and stack normalization. The source's arrow exception is reference evidence, not automatic approval of a universal exemption. Entry counting can make stack splitting/merging change risk; do not silently switch to unit counting or claim the formula prevents manipulation. Establish a consistent basket for preview and action before implementation.

### Modding and limits

Both models support validated coefficients/offsets and explicit RULE-004 replacement hooks. Enemy-level pickpocket baseline coefficients for skill/player level/target level/offset are (1,5,−5,0); skill-only defaults to skill coefficient 1 and offset 0. Shoplifting defaults to offset 100, skill coefficient −1, quality coefficient +1 and weight/count coefficients +1. Target applicability remains explicit rather than treating absent levels as zero.

Configure pickpocket and shoplifting limits independently, vanilla 5–95 each. Valid integer-percent bounds satisfy 0<=minimum<=maximum<=100; equal bounds and endpoint guarantees are valid. Limits constrain eligible checks rather than authorize blocked actions.

Concrete coefficient domains, fractional conversion and raw-versus-final hook output/limit semantics must be declared before use. RULE-001 requires integer percentages without an implicit fractional rounding policy. DATA-003/RULE-004 govern preflight validation, provenance, locked provider selection and explicit failures. No arbitrary data-expression interpreter or silent vanilla fallback is approved.

### Resolution and consequences

After owner authorization, capture coherent current target/shop/basket/character inputs and resolve one RULE-001 result using an explicitly owned RULE-003 source. True pickpocket success means that success check passed; true shoplifting detection means detection occurred. Use the same result's complement when needed, never another draw to inspect failure/undetected status.

Eligible guaranteed checks consume one logical draw. Blocked/invalid requests and inspections consume none. Technical retries retain resolved results without duplicating consequences. Declare theft/loot stream purposes under RULE-003; do not borrow combat/presentation randomness implicitly.

Owners define transfer, loot, practice, witnesses, crime, guards and hostility. A failed pickpocket check is not universally declared detected by this review, nor is undetected shoplifting automatically legally consequence-free. Success need not yield valuable loot. Separate loot generation requires its own approved rules and is not an extra detection check by implication.

### Feedback

Use qualitative risk by default with an optional exact percentage. Explicitly label pickpocket success versus shoplifting detection. If showing undetected probability instead, take the complement and label it accordingly.

Preview and gameplay share resolved formulas/configuration/basket. Recompute before authorization if relevant context changed; previews are current estimates rather than guarantees. Blocked requests explain restrictions. Inspection does not roll, tally practice, generate loot, transfer items or initiate theft/crime. Qualitative mappings, setting persistence/layout and diagnostic detail retention remain UI/owner dependencies.

## Relevant formulas and parameters

- Cp=S+5×(L−T) for supported enemy-level targets; Cp=S for supported skill-only targets.
- B=trunc(total W)+entry count N.
- Cd=100−S+Q+B.
- Clamp each raw value to its independently resolved bounds; vanilla 5–95.
- A RULE-001 draw R in 1–100 passes the labelled check when R<=its final chance.

Example: S=40,L=5,T=3 gives 50% pickpocket success; skill-only gives 40%. S=40,Q=10,W=2.8,N=3 gives B=5 and 75% detection, hence 25% undetected for that check. It does not establish transfer or later legal consequences.

## Required data

Stable actor/target/context identity; explicit target model and required levels; live Pickpocket; shop quality; authoritative basket/total weight/count policy; validated coefficients/limits/provider provenance; eligibility and result polarity; owned source and retained attempt/application identity. Concrete schemas and basket canonicalization remain dependencies.

## Inputs, outputs and events

Inputs: validated queries and owner-authorized checks under locked configuration. Outputs: labelled raw/final probabilities, feedback/restrictions, one identified result or explicit error. The helper does not transfer loot, set crime, make enemies hostile or award practice. Concrete API/event names remain unselected; committed outcomes belong to owners.

## Cross-system interactions

MOVE-024/NPC own targeting/eligibility; ECON/ITEM own baskets/transfers; LAW-003/004 own legal outcomes/enforcement. CHAR-011 supplies live skill and CHAR-012 accepts owner-approved practice. RULE-001/003 supply check/source semantics; RULE-004/DATA-003 validate hooks/configuration. UI/DEV share resolved risk; CORE/SAVE gate readiness and restore without replay.

## Edge cases and failure conditions

- Valid negative/above-100 skill reaches supported formulas; missing identities/context cannot become zero/easier targets.
- Empty/unsupported baskets require owner eligibility decisions, not an automatic minimum-chance attempt.
- Split stacks, quantities, zero-weight items and fractional totals require declared basket/count rules. Preview and transfer cannot silently evaluate different baskets.
- Invalid limits, nonfinite/overflowing arithmetic and callback failures require explicit recovery without reroll/fallback or partial unexplained transfer.
- Duplicate delivery, refresh and restoration cannot repeat loot, transfer, practice or enforcement for a retained result.

## Configuration and balancing options

Support separate model coefficients/offsets, bounds, burden coefficients/count policies and explicit hooks within validated contracts. Preserve declared polarity/integer interfaces. No new witness formula, loot table, item-value term, mandatory stealth contribution, retry cooldown or universal crime rule is introduced.

## Save/load considerations

Derive probabilities from restored valid actor/target/basket/configuration state. Preserve authoritative inventory/legal facts and required retained attempts/results; cached chances are not extra authority. Successful loads allow fresh future unresolved checks under RULE-003 without replaying completed consequences. Transfer/detection ordering, interrupted transactions and attempt-restriction persistence remain ITEM/ECON/LAW/SAVE contracts, not permission for silent replay/omission.

## Technical constraints

Target: Godot 4.7.2. Separate pure burden/probability, eligibility, resolution and effects. Keep polarity explicit and arithmetic safe. Numeric conversions, stable baskets, interfaces and serialization remain engineering dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Vanilla formulas match their labelled polarity with live skill/actual level and explicit target routing; missing enemy data does not select skill-only.
2. Baseline burden truncates total weight once and counts entries/stacks, with validated independent coefficient/count-policy customization.
3. Independently modded formulas/bounds support valid 0/100/equal limits; unsafe definitions/hooks fail explicitly.
4. Each authorized check uses one RULE-001 result/complement; blocked/inspection paths consume no draws or practice.
5. Qualitative/default and optional exact feedback use gameplay's basket/rules, identify polarity and refresh after relevant changes.
6. Loot/legal effects remain owner-controlled and exactly-once without inferred guaranteed loot or automatic guards/hostility.
7. Restore preserves retained/committed facts without replay while allowing fresh future unresolved checks.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this design interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-011/012, RULE-001/003/004 and DATA-003. Feature limits coexist with general percentages; eligibility remains separate. RULE-009's similar customization/feedback does not imply identical output meanings. LAW/ECON/ITEM/NPC/MOVE policies remain unapproved here. Stack-count manipulation is an explicit basket integration dependency rather than an invented anti-exploit requirement.

## Outstanding questions and approval

No blocking gameplay policy question remains for these models. Before implementation: define coefficient/conversion/hook domains, target adapters, weight units/inclusions, count schemas/stack normalization, source purposes, UI settings/mappings and transfer/detection/save ordering. Loot, practice, witnesses, guards, hostility and retries need their own reviews. These cannot waive both-model moddability, explicit polarity, independent limits or coherent basket evaluation.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-010-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and interaction-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
