# CHAR-005 — Custom advantages and advancement tradeoffs

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Balance a custom class's health allowance and special benefits against drawbacks and skill-advancement requirements, while allowing separate initial social-reputation tradeoffs.

## Intended player experience

See the cost and consequences of each choice, experiment with temporarily invalid builds, and finish only when the complete custom class is legal. Mods may change declared balancing parameters without bypassing validation or silently repairing the player's choices.

## Confirmed requirements

CHAR-005-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm the vanilla HP/difficulty/multiplier baseline; original traits/costs/restrictions; reputation allocation; live numeric explanation; rejection of conflicting new traits; no additional race-based bans; seven-per-list default limits; scoped validated overrides; and final validation despite temporary invalid editing.

CHAR-004 owns the class name, attributes, tiers and retained draft. CHAR-001 owns restart/exit discard and final-summary restrictions. DATA-003/008 govern definition resolution, locking and validation. CHAR-002 retains birth-race abilities; their interaction with class traits remains explicit mechanics-owner scope.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/CreateCharCustomClass.cs`, HP handlers and `UpdateDifficulty`: HP default 8, limits 4–30; asymmetric HP point contribution; trait totals; advancement interpolation; animated dagger gauge. `ExitButton_OnMouseClick` rejects difficulty outside −12–40.
- `Game/UserInterfaceWindows/CreateCharSpecialAdvantageWindow.cs`, option arrays, `InitializeAdjustmentDict`, `CannotAddAdvantage`, `IsMatchingAdvPair`: available trait variants/costs and class-local duplicate/conflict checks. `maxItems` is seven per list. Increased Magery, Darkness-Powered Magery and Light-Powered Magery each have a one-variant limit within their respective category. `ParseCareerData` converts selected traits into career fields.
- `Game/UserInterfaceWindows/CreateCharReputationWindow.cs`: five adjustable groups, values derived in −10–10, and a zero-balance requirement on its explicit exit button. It writes adjustments into the parent draft while editing. Intended final validation must cover all navigation paths rather than rely on that button.
- `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs`, `CreateCharCustomClassWindow_OnClose`: transfers career/reputation into the character document.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Runtime trait effects, original help text and exhaustive cross-owner interactions remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### HP and advancement

Vanilla HP per level H defaults to 8 and is an integer within inclusive 4–30. This is the career's HP-per-level parameter, not a promise that every level grants exactly H health; actual health-gain resolution remains its character-progression rule.

Let H0 be the configured default. HP difficulty contribution P = H−H0 when H≥H0; otherwise P = −2(H0−H). Total D = P + sum(selected advantage/disadvantage costs). Vanilla legal D is −12–40. Each selected trait contributes once.

Vanilla advancement multiplier A = 0.3 + 2.7(D+12)/52. More costly builds generally require more practice for skill advancement through the progression owner's formula; this is not a direct multiplier of all experience rewards or health gains. Do not label A=1 as the default: vanilla H=8 with no traits has D=0 and A approximately 0.9231.

Allow temporary difficulty outside legal bounds during editing. Show the actual total and invalid status; do not clamp choices or pretend an invalid build is legal. Completion requires valid range and complete CHAR-004 validation.

### Traits and compatibility

Retain the source trait options and costs in the baseline table below, with maximum seven advantages and seven disadvantages. Count limits are independent from difficulty limits. Exact duplicate trait/variant entries are forbidden. Increased Magery, Darkness-Powered Magery and Light-Powered Magery each permit only one variant within that category.

Retain source class-local conflict pairs for matching targets: Bonus to Hit versus Phobia for the same enemy group; Expertise versus Forbidden Weaponry for the same weapon group; and any pair of Immunity, Resistance, Low Tolerance or Critical Weakness for the same effect type. Do not infer extra conflicts across different targets or between distinct environmental abilities merely from their names.

Reject a conflicting new selection and explain the conflict while preserving existing choices. Do not automatically remove/replace an incumbent. Removing a trait removes its cost and candidate effect completely; recompute career-derived state from current selections so stale flags or magery values cannot survive removal. Cancelling a subtype picker cannot leave a placeholder trait or charge.

Do not add birth-race-based selection bans. Source-permitted redundant racial/class combinations remain selectable. Their actual stacking, immunity/weakness precedence and effectiveness must be resolved explicitly by MAGIC/COMBAT/CHAR and other owners. Selection permission does not guarantee every disadvantage has equal practical impact on every race.

### Vanilla trait cost table

Costs below are difficulty points, not currency. General/darkness/light variants are distinct where listed.

| Advantages | Costs |
| --- | --- |
| Acute Hearing; Adrenaline Rush; Athleticism | +1; +4; +4 |
| Bonus to Hit: Animals / Daedra / Humanoid / Undead | +6 / +3 / +6 / +6 |
| Expertise: Axe, Blunt, Hand-to-Hand, Long Blade, Missile, Short Blade | +2 each |
| Immunity: Disease, Fire, Frost, Magic, Paralysis, Poison, Shock | +10 each |
| Increased Magery: 1× / 1.5× / 1.75× / 2× / 3× Intelligence in spell points | +2 / +4 / +6 / +8 / +10 |
| Rapid Healing: General / Darkness / Light | +4 / +3 / +2 |
| Regenerate Health: General / Darkness / Light / Immersed | +14 / +10 / +6 / +2 |
| Resistance: Disease, Fire, Frost, Magic, Paralysis, Poison, Shock | +5 each |
| Spell Absorption: General / Darkness / Light | +14 / +12 / +8 |

The inspected custom-career default without Increased Magery is 0.5× Intelligence in spell points. Runtime spell-point calculation remains MAGIC/CHAR-owned.

| Disadvantages | Costs |
| --- | --- |
| Critical Weakness: Disease, Fire, Frost, Magic, Paralysis, Poison, Shock | −14 each |
| Damage: Holy Places / Sunlight | −6 / −10 |
| Darkness-Powered Magery: Lower ability in daylight / Unable to use magic in daylight | −7 / −10 |
| Forbidden Armor: Chain / Leather / Plate | −2 / −1 / −5 |
| Forbidden Material: Adamantium / Daedric / Dwarven / Ebony / Elven | −5 / −2 / −7 / −5 / −9 |
| Forbidden Material: Iron / Mithril / Orcish / Silver / Steel | −1 / −6 / −3 / −6 / −10 |
| Forbidden Shield: Buckler, Kite, Round, Tower | −1 each |
| Forbidden Weaponry: Axe, Blunt, Hand-to-Hand, Long Blade, Missile, Short Blade | −2 each |
| Inability to Regenerate spell points | −14 |
| Light-Powered Magery: Lower ability in darkness / Unable to use magic in darkness | −10 / −14 |
| Low Tolerance: Disease, Fire, Frost, Magic, Paralysis, Poison, Shock | −5 each |
| Phobia: Animals, Daedra, Humanoid, Undead | −4 each |

Tables reflect the inspected option arrays and cost dictionary. Exact runtime meaning of terms such as light, darkness, holy places and regeneration belongs to the responsible mechanics specifications. They do not authorize implementing every effect from its label alone.

### Reputation

Provide Merchants, Commoners, Scholars, Nobility and Underworld adjustments. Vanilla starts each at zero, permits integer values −10–10 inclusive and requires their sum to be zero at class completion. Reputation is independent of D and A. Allow temporary imbalance and show it immediately; validate actual stored values on final completion, irrespective of nested-panel close route.

These are initial custom-class adjustments, not guaranteed final faction standings. Biography effects and later reputation systems apply under their own ordering/combination rules. Do not apply live reputation changes during editing.

### Presentation and draft lifetime

Show every selected trait's cost, the HP contribution, D, A and reputation balance as edits occur, alongside the dagger gauge. Explain that a higher A requires more practice for skill advancement. Show invalid states and conflict explanations without automatically correcting the build. Effect descriptions must match owner-approved behavior and distinguish unresolved stacking from guaranteed benefits.

Retain selections through ordinary backtracking under CHAR-004. Restart/exit discard them under CHAR-001 without discard confirmation. Editing and final custom-class acceptance update only the isolated draft; CORE-012 and mechanics owners apply live initialization once.

## Configuration and balancing options

Validated mods may override HP default/minimum/maximum, legal difficulty bounds, advancement endpoints, trait costs/supported definitions, advantage/disadvantage count limits, and reputation defaults/bounds/required total. DATA-003 precedence and configuration locking remain binding. This does not authorize arbitrary executable effects, unreviewed effect stacking or new reputation groups.

For configured difficulty endpoints L<U and multiplier endpoints a and b, use A = a + (b−a)(D−L)/(U−L). Retain HP slopes +1/−2 relative to configured H0; slope overrides are not approved. Require finite positive advancement endpoints with b≥a, valid ordered HP bounds containing H0, supported integer/count ranges and valid trait references/conflict definitions. Endpoint equality is permitted; equal difficulty bounds are invalid because interpolation would divide by zero.

Reputation bounds must be ordered, defaults in bounds and required sum between the sum of minima and sum of maxima. Validate actual final allocation against that sum. Configured count limits must be nonnegative supported integers. Required definitions/effects and reachable valid builds need owner/schema validation before the configuration is declared usable. Invalid contributions follow DATA recovery; do not silently clamp parameters, strip traits or substitute vanilla definitions.

## Required data

Resolved HP/difficulty/multiplier parameters; stable trait and target/variant IDs; costs, supported effects, duplicate/singleton/conflict rules and count limits; current selections; reputation group values/bounds/total; derived totals/validation results; and definition provenance. Display labels are not durable identity. Exact schema/compatibility representation remains DATA/owner scope.

## Inputs, outputs and events

Inputs: HP changes, trait add/remove/subtype selection, reputation edits, navigation, final acceptance and resolved content. Outputs: isolated career candidates, costs/totals/multiplier, actionable validation/conflict feedback and validated custom-career data. These are conceptual contracts, not approved API/signal names. No edit emits a live reward or reputation-grant event.

## Cross-system interactions

CHAR-004 combines these choices with chassis validation; CHAR-001/003 govern entry/navigation; CHAR-002 supplies birth-race traits without new selection bans. DATA-003/008 resolve supported definitions. Progression owns use of A and HP gains; MAGIC/COMBAT/MOVE/ITEM/CHAR own actual special effects and restrictions. FACT owns reputation consequences; CHAR-006 biography may add its own effects. CORE-007/011/012 validate entry and apply initialization without duplicates; UI presents truthful state; SAVE preserves completed custom-career state.

## Edge cases and failure conditions

- Exact limits are inclusive; out-of-range D, HP, trait counts, reputation or conflicting/duplicate traits block completion even if UI controls were bypassed.
- Trait removal/replacement must clear stale flags/costs; repeated callbacks cannot count a trait twice.
- A full list cannot accept another item solely because its net point cost is legal.
- Temporary invalid builds remain editable and visible; they are not silently clamped or published as completed careers.
- Race redundancy cannot create a new selection ban. Future stacking rules must account for low-impact drawbacks and potentially cheap powerful builds rather than assume selection legality guarantees balance.
- Numeric configuration errors, unsupported effects and impossible reputation budgets fail validated resolution instead of silently changing player choices.
- Reputation changes cannot affect advancement cost or live faction state during creation.

## Save/load considerations

Unfinished drafts are transient under CHAR-001. Completed character saves preserve selected career traits/parameters and required definition identity/version context, including resulting HP/A and applied initial reputation through owner contracts. Loading restores state without rerunning fresh grants or class reputation adjustments. Changed mod definitions require explicit SAVE/DATA compatibility policy rather than silently recomputing a saved career using new costs. Exact snapshot/migration representation remains deferred.

## Technical constraints

Target: Godot 4.7.2. Calculate/validate from authoritative current selections and resolved definitions, independently of widgets or nested-window exit handlers. Keep career definitions, draft state and live effects separate. Use stable IDs, safe arithmetic and finite-number validation. Concrete schemas, precision, event/API names and effect implementation remain owner engineering decisions. Reference source/content remain read-only.

## Acceptance criteria

1. Vanilla HP defaults/limits, asymmetric cost and −12–40 difficulty bounds match the approved formulas; A is 0.3 at −12 and 3.0 at 40.
2. Supported trait variants/costs match the baseline table. Seven-per-list limits, duplicates, singleton categories and matching-target conflicts are enforced from actual selections.
3. Conflicting new selections explain rejection and preserve incumbents. No added birth-race bans occur; runtime stacking uses separately approved rules.
4. Removal/cancelled subtype selection leaves no stale trait flags, costs or placeholder entries.
5. Reputation starts at zero, stays within −10–10 for valid completion and sums to zero independently of advancement.
6. Temporary invalid difficulty/reputation remains editable and clearly indicated; every final acceptance path validates the whole build with CHAR-004.
7. Costs, HP contribution, D, A and reputation balance update accurately alongside the gauge, with truthful advancement wording.
8. Valid mod overrides use configured linear interpolation and fixed HP slopes; invalid/unsupported/impossible configurations do not silently clamp or fall back.
9. Backtracking retains choices; Restart/exit clear them. Draft edits never mutate live players or duplicate startup effects.
10. Completed save/load preserves career semantics and does not reapply fresh reputation/grants or silently reinterpret the build under changed costs.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001–004, DATA-003/008 and relevant CORE-007/011/012 requirements. No direct contradiction identified. Whole-class validation closes nested-panel escape risks without prohibiting temporary experimentation. Attribute budget remains CHAR-004-owned. Trait selection permission does not resolve CHAR-002 racial stacking. Mod scope remains explicit and does not override locked content or permit arbitrary executable effects. Existing architectural proposals are not approved wholesale.

## Outstanding questions and approval

No further blocking builder-policy question is identified. Before implementation is complete: verify option/cost parsing and owner-effect fixtures; define all runtime trait meanings and racial/class stacking; validate mod schemas/numeric ranges/reachability; establish exact progression/HP and FACT application contracts; finalize UI wording and SAVE compatibility. These dependencies cannot waive actual-state validation or allow silent build changes.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-005-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented runtime-effect/stacking, schema, owner-contract and save-compatibility dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
