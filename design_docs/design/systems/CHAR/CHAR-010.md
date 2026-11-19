# CHAR-010 — Reflex difficulty selection

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Choose one character-specific setting coupling combat pressure to the effectiveness of recorded skill practice. Preserve the intended tradeoff without suggesting that the setting changes player movement or input responsiveness.

## Intended player experience

Select among five familiar options, understand both combat and advancement effects, revise the choice in creation's final summary and retain it for the character thereafter. Navigation and loading do not silently change difficulty.

## Confirmed requirements

CHAR-010-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish five labels, Average default, retained summary-editable creation choice, coupled vanilla parameters, accurate explanation, post-creation lock, validated mod parameter overrides and explicit invalid-save failure.

Inherited CHAR-001 permits reflex edits in final summary and discards unfinished selections on Restart/exit. CORE-007 captures submitted intent and validates before replacement. DATA-003 locks the resolved mod configuration; SAVE restores character state through explicit compatibility policy. This specification does not approve an independent combat/progression slider or all surrounding combat/progression rules.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/EntityEnums.cs#PlayerReflexes`: VeryHigh=0, High=1, Average=2, Low=3, VeryLow=4.
- `Game/UserInterface/ReflexPicker.cs`: five choices, default Average. `CreateCharReflexSelect.cs` displays explanatory text; wizard close handlers and `CreateCharSummary.cs` transfer/edit the choice through CharacterDocument.
- `Game/Entities/PlayerEntity.cs#AssignCharacter` assigns reflexes. `RaiseSkills` computes fixed-point scaled use tallies before comparing with skill advancement requirements.
- `Game/EnemyAttack.cs#ResetMeleeTimer` draws an integer 1500–3000, adjusts for player level and reflexes, clamps at zero and divides by 980. Its comment distinguishes DFU's player-reflex behavior from an apparent classic-data indexing error; the intended baseline here is the inspected DFU behavior.
- `Game/Formulas/FormulaHelper.cs`, monster damage branch, tests a reflex-dependent probability for an attack component before normal successful-hit/damage checks. It is not the complete attack accuracy formula.
- `Game/Serialization/SerializablePlayer.cs` stores/restores the reflex value; intended invalid-value validation is explicit rather than inferred from that assignment.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Full combat branch reachability, timer cadence and runtime effects remain owner verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Selection and lifetime

Offer Very High, High, Average, Low and Very Low, defaulting a fresh creation draft to Average. Preserve the selected option through navigation. Permit changes on the reflex screen and final summary under CHAR-001. Completion requires a supported valid selection; Average is a fresh-draft default, not an invalid-data recovery substitute.

Capture the selected value with completed character intent under CORE-007. Keep it fixed after creation initially, with no ordinary gameplay/settings control to switch it. Restart/exit clear the unfinished draft. Do not use a global last-selected difficulty in place of the loaded character's own choice.

### Coupled vanilla effects

| Option | Pre-division melee-timer adjustment | Monster attack-component chance | Effective skill-practice multiplier |
| --- | ---: | ---: | ---: |
| Very High | −900 | 70% | 1.25 |
| High | −450 | 60% | 1.125 |
| Average | 0 | 50% | 1.0 |
| Low | +450 | 40% | 0.875 |
| Very Low | +900 | 30% | 0.75 |

All three parameters follow the same selected option. Higher vanilla reflexes shorten relevant enemy melee timers, increase the inspected monster component gate and increase the effective use tally for advancement. Do not apply these as universal attack-speed multipliers, final hit chances or extra permanent skill gains.

Combat owns timer reset/consumption, the applicable attack branches and subsequent hit/damage checks. Progression owns when checks occur, thresholds, mastery limits and tally reset. This feature supplies the selected parameters and required baseline arithmetic without preapproving those entire systems. Do not automatically extend the gate to weapon, ranged or spell attacks outside its verified owner scope.

### Explanation

Before confirmation, explain both combat pressure and skill-practice consequences, using the resolved parameters rather than stale vanilla wording when modded. Explain that a higher vanilla setting requires quicker reactions in combat and makes recorded practice count more toward skill advancement. It does not increase player movement speed, input response or award skills immediately.

Distinguish the monster component gate from final hit probability, and the timer adjustment from total attack interval. Creation selection itself does not consume randomness, create practice or apply combat damage. Exact presentation/help layout remains UI scope.

## Relevant formulas and parameters

For vanilla enum index r=0..4:

- Timer adjustment t=450(r−2).
- Component gate p=50−10(r−2) percent.
- Practice multiplier m=1−(r−2)/8.
- Effective practice = floor(nonnegative recorded uses × m). Source fixed-point arithmetic is `(uses * (65536 - ((r-2) << 13))) >> 16`; implement with safe arithmetic while preserving the nonnegative result/rounding.

Source timer reference: `max(0, U[1500,3000] - 50*(player_level-10) + t) / 980`, with inclusive integer uniform random draw and resulting floating-time timer. The selected adjustment must be integrated once into the owner-approved timer rule; this reference does not authorize changing all combat timing. The component gate precedes ordinary hit/damage eligibility, including a positive minimum damage check in the inspected branch.

Practice scaling is evaluated for advancement comparison, not repeatedly compounded into stored tallies. For example, 8 uses count as 10/9/8/7/6 across the five vanilla options. Full tally/threshold semantics remain CHAR-013 and related progression contracts.

## Configuration and balancing options

Validated mods may override each option's timer adjustment, component probability and practice multiplier. Retain the five stable option identities and one coupled selection. Require probability in inclusive 0–100, finite positive practice multiplier and supported finite timer adjustment/numeric ranges. Validate compatibility with combat/progression owners and safe arithmetic. Missing required option data or invalid parameters fail DATA validation rather than silently clamp, substitute Average or retain only some parameters.

Modded values need not be inferred from enum arithmetic; use the resolved option definition. Do not assume vanilla monotonic effects when overrides differ; descriptions must accurately explain actual behavior. No extra options, independent controls, runtime parameter reload or player-selectable progression/combat split are introduced. DATA-003 precedence, explicit recovery and configuration locking remain binding.

## Required data

Stable option IDs and classic index mapping; selected draft/character option; resolved timer/gate/practice parameters and provenance; truthful localized explanation; validation result and owner compatibility/version context. Concrete schema and parameter snapshot/version representation remain DATA/SAVE dependencies.

## Inputs, outputs and events

Inputs: fresh creation, reflex choice, summary edits, navigation, completed submission, resolved definitions and save restoration. Outputs: retained candidate/committed option, parameter queries, accurate explanation or actionable invalid-data result. These are conceptual contracts, not approved API/signal names. No selection/restore event should grant skill practice or reset unrelated combat state.

## Cross-system interactions

CHAR-001 owns flow/summary/discard. COMBAT/EnemyAttack and damage-rule owners consume timer/gate parameters. CHAR-013 and related progression/RULE owners consume practice scaling alongside class advancement rules from CHAR-005; the two modifiers are not interchangeable. UI presents truthful effects. DATA-003 resolves locked mod parameters. CORE-007 captures/validates intent, CORE-011/012 coordinate entry and SAVE restores selected identity without silent defaulting.

## Edge cases and failure conditions

- Invalid/out-of-range classic enum values cannot reach array indexing or parameter queries as valid options.
- Selecting Very High does not speed player controls or guarantee hits; no misleading universal difficulty claim.
- Negative timer intermediates use the owner-approved zero floor; nonfinite/overflowing mod values fail rather than wrap.
- Practice scaling must not compound into stored uses or multiply bonuses repeatedly when screens reopen.
- Fixed selection prevents swapping around combat/check boundaries; no hidden summary control remains active after entry.
- Modded probabilities at 0/100 remain valid, subject to explicit owner semantics; positive practice multipliers still require safe supported numeric limits.
- Loaded characters retain their own selection. Missing/invalid identity or required option data causes explicit validation failure, not Average substitution.

## Save/load considerations

Persist the committed stable reflex selection/classic mapping as character state. Loading restores it before dependent combat/progression work begins and does not grant practice or reselect from defaults. Invalid/unsupported selections fail validation with actionable error; only an explicit SAVE migration/recovery policy may replace them.

Changed mod parameter definitions require explicit SAVE/DATA compatibility decisions about preserving versus adopting parameter versions. This specification does not silently choose either behavior. Unfinished choices remain transient under CHAR-001; captured new-character intent remains stable through safe entry retry.

## Technical constraints

Target: Godot 4.7.2. Keep option identity, resolved parameters, UI and consumers separate. Use safe arithmetic with explicit practice rounding and validation before dependent simulation. Do not rely solely on enum order, localized labels or widget defaults to resolve state. Exact RNG/timer implementation, schemas and API names remain owner engineering choices. Reference source/content remain read-only.

## Acceptance criteria

1. Fresh drafts default to Average; all five labels and summary editing work, preserving choice through navigation.
2. Each vanilla option supplies exactly the table's coupled timer/gate/practice parameters; consumers apply them once in their approved scope.
3. Positive tally scaling rounds down as specified; 8 uses map to 10/9/8/7/6 without altering stored practice merely by comparison.
4. Explanation covers both effects and distinguishes component chance/timer contribution from final accuracy/interval and player input speed.
5. Selection stays fixed after creation; each loaded character uses its own persisted value.
6. Valid mod overrides resolve per option with truthful descriptions and one coupled setting. Invalid/missing/nonfinite/out-of-domain parameters fail rather than silently clamp or substitute.
7. Invalid saved selection produces actionable validation failure, with no Average fallback outside explicit migration/recovery.
8. Creation/restore/navigation cannot grant practice, duplicate scaling or prematurely activate simulation. Restart/exit discard unfinished selection under CHAR-001.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001/005/008/009, DATA-003 and relevant CORE-007/011/012 constraints. No direct contradiction identified. Post-creation lock does not remove approved summary editing. Practice scaling is separate from initial skill generation and custom-career advancement cost. Mod overrides do not unlock runtime content changes or authorize extra independent controls. Combat/progression branch coverage remains explicit owner verification rather than inferred universal effects.

## Outstanding questions and approval

No further blocking selection-policy question is identified. Before implementation is complete: verify complete combat consumers and timing/component scope; finalize progression tally/threshold contracts; establish supported mod ranges/arithmetic validation; verify original help text and accurate replacement wording; define SAVE compatibility for changed parameter versions. These dependencies cannot waive fixed selection, truthful explanation or explicit invalid-save failure.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-010-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented combat/progression scope, mod-schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
