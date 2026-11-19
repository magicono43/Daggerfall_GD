# RULE feature catalog

Static analysis of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Paths are relative to Assets/Scripts and symbols follow #. Complexity estimates review scope. Confidence rates the static trace.

## RULE-001 — Percentile checks

- **Parent subsystem** — Randomness
- **Purpose** — Resolve probability thresholds.
- **Existing implementation** — Dice100 draws 1–100 for Roll. Success and failure compare independent draws from 0–99 with the threshold using < and >=.
- **Source** — `Game/Utility/Dice100.cs#SuccessRoll`
- **Inputs and outputs** — Threshold → result
- **Dependencies** — COMBAT, MAGIC, NPC
- **Edge cases and interactions** — Out-of-range chances saturate. Two calls consume two rolls.
- **Design questions** — Which checks need to expose the roll?
- **Complexity** — Small
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-001-A01).

### My Intended Specification

See the [approved RULE-001 specification](../../design/systems/RULE/RULE-001.md). Exact integer percentages, one draw per check, isolated gameplay randomness and fresh randomness after successful load are approved; retained outcomes remain fixed.

## RULE-002 — Classic seeded sequence

- **Parent subsystem** — Randomness
- **Purpose** — Reproduce historic sequences.
- **Existing implementation** — DFRandom advances a static linear congruential state, yields 15 bits, and uses modulo for inclusive and exclusive range helpers.
- **Source** — `API/DFRandom.cs#rand`, `API/DFRandom.cs#SaveSeed`, `API/DFRandom.cs#RestoreSeed`
- **Inputs and outputs** — Seed and range → draw and advanced state
- **Dependencies** — DATA, LOC, CHAR
- **Edge cases and interactions** — An empty exclusive range divides by zero. The saved seed uses a single slot.
- **Design questions** — Which outputs need classic sequence parity?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-002-A01).

### My Intended Specification

See the [approved RULE-002 specification](../../design/systems/RULE/RULE-002.md). Classic compatibility is explicitly designated per feature, with operation-owned state, explicit seeds, validated classic range mapping and persistent assigned results. Consumer-specific parity and engineering dependencies remain open.

## RULE-003 — Shared state and reseeding

- **Parent subsystem** — Randomness
- **Purpose** — Identify cross-feature random coupling.
- **Existing implementation** — BonusPool reseeds Unity RNG from frame count. HP gains reseed DFRandom from rendered frame count. Quest parsing seeds Unity RNG from a separate System.Random instance.
- **Source** — `Game/Formulas/FormulaHelper.cs#BonusPool`, `Game/Formulas/FormulaHelper.cs#CalculateHitPointsPerLevelUp`, `Game/Questing/QuestMachine.cs#ParseQuest`
- **Inputs and outputs** — Frame counts or internal seed → updated RNG state
- **Dependencies** — CHAR, QUEST, SAVE
- **Edge cases and interactions** — Same-frame calls can repeat. Reproducibility after load needs runtime checks.
- **Design questions** — Which rolls should be isolated or replayable?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-003-A01).

### My Intended Specification

See the [approved RULE-003 specification](../../design/systems/RULE/RULE-003.md). Purpose-separated streams advance without per-call reseeding, persist through ordinary transitions and initialize afresh after successful loads. Saved facts and resolved retry results remain retained; diagnostics and candidate loads are isolated.

## RULE-004 — Formula override priority

- **Parent subsystem** — Extensibility
- **Purpose** — Select a mod formula.
- **Existing implementation** — Registration stores a named delegate. Strictly higher LoadPriority replaces a prior delegate. Invocation removes a type mismatch, logs it and falls back.
- **Source** — `Game/Formulas/FormulaHelper.cs#RegisterOverride`, `Game/Formulas/FormulaHelper.cs#TryGetOverride`
- **Inputs and outputs** — Name, provider and delegate → callback selection
- **Dependencies** — MOD
- **Edge cases and interactions** — Equal priority keeps the first. Some formulas have no hook.
- **Design questions** — How should conflicts and invalid signatures surface?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-004-A01).

### My Intended Specification

See the [approved RULE-004 specification](../../design/systems/RULE/RULE-004.md). Explicit hooks validate before selection; the last valid replacement in resolved mod order wins. Invalid contributions require explicit recovery, registrations lock for the run, and runtime failures do not automatically invoke fallback providers.

## RULE-005 — Derived attributes

- **Parent subsystem** — Character math
- **Purpose** — Translate attributes to modifiers.
- **Existing implementation** — Shared helpers map strength to damage and encumbrance, intelligence to spell points, willpower to resistance, agility to hit and endurance to HP and healing.
- **Source** — `Game/Formulas/FormulaHelper.cs#DamageModifier`, `Game/Formulas/FormulaHelper.cs#MaxEncumbrance`, `Game/Formulas/FormulaHelper.cs#SpellPoints`, `Game/Formulas/FormulaHelper.cs#MagicResist`, `Game/Formulas/FormulaHelper.cs#ToHitModifier`, `Game/Formulas/FormulaHelper.cs#HitPointsModifier`, `Game/Formulas/FormulaHelper.cs#HealingRateModifier`
- **Inputs and outputs** — Attribute and optional multiplier → derived value
- **Dependencies** — CHAR-011, ITEM, COMBAT, MAGIC
- **Edge cases and interactions** — Callers choose live or permanent values. Check rounding at breakpoints.
- **Design questions** — Which derived values should respond to temporary changes?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-005-A01).

### My Intended Specification

See the [approved RULE-005 specification](../../design/systems/RULE/RULE-005.md). Seven baseline formulas retain mathematical floor, explicit live/permanent inputs, validated customization and source-based reconstruction. Consuming systems own final action semantics; retained health rewards remain fixed.

## RULE-006 — Health growth and bonus pool

- **Parent subsystem** — Character math
- **Purpose** — Compute level rewards.
- **Existing implementation** — Initial max health is 25 plus career HP per level, with gain rolls for additional levels. A gain rolls half through full career HP, adds permanent endurance modifier and floors at one. Bonus pool rolls 4–6.
- **Source** — `Game/Formulas/FormulaHelper.cs#RollMaxHealth`, `Game/Formulas/FormulaHelper.cs#CalculateHitPointsPerLevelUp`, `Game/Formulas/FormulaHelper.cs#BonusPool`
- **Inputs and outputs** — Career, level, endurance and RNG → HP or points
- **Dependencies** — CHAR-015, RULE-003
- **Edge cases and interactions** — Each repeated gain can reseed from the same frame.
- **Design questions** — Which rewards should be rolled or fixed?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-006-A01).

### My Intended Specification

See the [approved RULE-006 specification](../../design/systems/RULE/RULE-006.md). Initial health and retained ordinary reward formulas follow approved CHAR rules, with independent pool-first/health-second progression draws, singleton-range draw consumption and captured-Endurance explanations. Earned health and prepared rewards remain fixed across restoration.

## RULE-007 — Skill threshold and level conversion

- **Parent subsystem** — Character math
- **Purpose** — Turn growth into eligibility inputs.
- **Existing implementation** — Skill-use threshold floors skill times skill and career multipliers times 1.04 to the level power times 2/5, plus one. Default level divides current minus baseline plus 28 by 15.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateSkillUsesForAdvancement`, `Game/Formulas/FormulaHelper.cs#CalculatePlayerLevel`
- **Inputs and outputs** — Permanent skill, multipliers and skill sums → threshold or level
- **Dependencies** — CHAR-013, CHAR-014
- **Edge cases and interactions** — Level uses integer division before Floor. Sheet progress uses a separate expression.
- **Design questions** — Should displayed progress use the same override as eligibility?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-007-A01).

### My Intended Specification

See the [approved RULE-007 specification](../../design/systems/RULE/RULE-007.md). Skill requirements use captured actual level and yield vanilla T=1 at zero skill. Approved advancement/eligibility formulas use shared gameplay/display calculations, mathematical floor and preserved baseline/backlog; inspectable requirements do not add raw counters to the ordinary character sheet.

## RULE-008 — Recovery rates

- **Parent subsystem** — Character math
- **Purpose** — Compute hourly rest gains.
- **Existing implementation** — Health uses Medical, endurance, max HP and rapid-healing context. Fatigue and magicka use one eighth of maximum with a minimum of one. NoRegenSpellPoints returns zero.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateHealthRecoveryRate`, `Game/Formulas/FormulaHelper.cs#CalculateFatigueRecoveryRate`, `Game/Formulas/FormulaHelper.cs#CalculateSpellPointRecoveryRate`
- **Inputs and outputs** — Career, pools, skills and location/time → gains
- **Dependencies** — CHAR-021, CHAR-022, TIME
- **Edge cases and interactions** — Indoor daylight uses the non-outdoor-day branch.
- **Design questions** — How should regeneration restrictions interact with context?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-008-A01).

### My Intended Specification

See the [approved RULE-008 specification](../../design/systems/RULE/RULE-008.md). Approved hourly recovery retains source-compatible integer division, current live inputs and Rapid Healing context. Explicit prohibitions override minimum recovery; inspectable explanations distinguish nominal rates, restrictions and actual capped restoration.

## RULE-009 — Lockpicking

- **Parent subsystem** — Interaction checks
- **Purpose** — Compute door-specific chances.
- **Existing implementation** — Interior uses skill plus five times the level-minus-lock difference. Exterior uses skill minus five times lock value. Both clamp to 5–95.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateInteriorLockpickingChance`, `Game/Formulas/FormulaHelper.cs#CalculateExteriorLockpickingChance`
- **Inputs and outputs** — Skill, lock and optional level → chance
- **Dependencies** — MOVE, LOC, LAW
- **Edge cases and interactions** — The caller owns the actual roll comparator.
- **Design questions** — Should door types share one difficulty model?
- **Complexity** — Small
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-009-A01).

### My Intended Specification

See the [approved RULE-009 specification](../../design/systems/RULE/RULE-009.md). Separate interior/exterior formulas and their chance limits are independently moddable. Authorized attempts use actual claimed level/live skill and one percentile result; qualitative/default and optional exact feedback share gameplay calculations. Eligibility, retries and consequences remain owner-reviewed.

## RULE-010 — Theft

- **Parent subsystem** — Interaction checks
- **Purpose** — Compute success or detection chance.
- **Existing implementation** — Pickpocket uses live skill and optionally the enemy level difference. Shoplifting uses 100 minus Pickpocket plus quality and item burden. Both clamp to 5–95.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculatePickpocketingChance`, `Game/Formulas/FormulaHelper.cs#CalculateShopliftingChance`
- **Inputs and outputs** — Skill and target/shop data → success or detection chance
- **Dependencies** — LAW, ECON, NPC
- **Edge cases and interactions** — The output polarity differs between the two rules.
- **Design questions** — Which target and item properties affect risk?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-010-A01).

### My Intended Specification

See the [approved RULE-010 specification](../../design/systems/RULE/RULE-010.md). Separate pickpocket-success/shoplifting-detection models, limits and burden are moddable. Shared labelled feedback and one authorized percentile result preserve polarity; target/basket, loot and legal consequences remain owner-reviewed dependencies.

## RULE-011 — Stealth and climbing

- **Parent subsystem** — Interaction checks
- **Purpose** — Calculate movement checks.
- **Existing implementation** — Stealth shifts a product of classic-scaled distance and live skill. Climbing adds a Khajiit bonus, doubles enhanced skill, clamps skill and interpolates base chance toward 100 with a luck term.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateStealthChance`, `Game/Formulas/FormulaHelper.cs#CalculateClimbingChance`
- **Inputs and outputs** — Distance, skill, race, luck and effects → chance
- **Dependencies** — MOVE, NPC, MAGIC
- **Edge cases and interactions** — No shared final percentile clamp. Caller cadence needs inspection.
- **Design questions** — Which modifiers should be sampled at each check?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-011-A01).

### My Intended Specification

See the [approved RULE-011 specification](../../design/systems/RULE/RULE-011.md). Both formulas are moddable with explicit rounding, current live inputs, climbing modifier order/intermediate limits and final 0–100 probability handling. Inspectable explanations/optional percentages do not authorize extra checks; NPC/MOVE/MAGIC cadence and consequences remain owner-reviewed.

## RULE-012 — Attack eligibility and route

- **Parent subsystem** — Combat math
- **Purpose** — Choose the appropriate damage path.
- **Existing implementation** — An enemy can prefer stronger average natural damage over its weapon. Insufficient weapon material returns zero. Monster unarmed attacks loop through three slots and use reflex-dependent preliminary checks.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateAttackDamage`
- **Inputs and outputs** — Attacker, weapon, material and reflexes → route or zero
- **Dependencies** — COMBAT, NPC, ITEM
- **Edge cases and interactions** — Enemy weapon preference is an explicit DFU deviation. Monster checks mix RNGs.
- **Design questions** — When should an enemy choose its natural attack?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-012-A01).

### My Intended Specification

See the [approved RULE-012 specification](../../design/systems/RULE/RULE-012.md). Moddable enemy route selection precedes material eligibility with no automatic fallback. Unarmed material bypass is the moddable default; ordered active monster components resolve reflex gate, hit and damage, skipping inactive slots without draws. Subsequent combat details remain owner-reviewed.

## RULE-013 — Hit chance and body part

- **Parent subsystem** — Combat math
- **Purpose** — Resolve whether an attack hits.
- **Existing implementation** — Selects body part and combines armor, adrenaline, enchantment, stat, skill and other adjustments. Final chance clamps to 3–97 and uses Dice100.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateSuccessfulHit`, `Game/Formulas/FormulaHelper.cs#CalculateStruckBodyPart`, `Game/Formulas/FormulaHelper.cs#CalculateArmorToHit`
- **Inputs and outputs** — Participants, modifiers and body part → hit result
- **Dependencies** — COMBAT, CHAR, ITEM
- **Edge cases and interactions** — Null participants return false before override lookup.
- **Design questions** — Which defenses change accuracy versus damage?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-013-A01).

### My Intended Specification

See the [approved RULE-013 specification](../../design/systems/RULE/RULE-013.md). Moddable accuracy/body-part rules retain explicit arithmetic and ordered part/critical/hit draws. Critical damage mods must be supported using the same retained critical result, with multiplier/stage/rounding finalized under RULE-014. Previews remain nonrandom and conditional.

## RULE-014 — Damage amount and bonuses

- **Parent subsystem** — Combat math
- **Purpose** — Resolve amount after hit.
- **Existing implementation** — Weapon and unarmed routes roll damage with distinct helpers. The attack applies situational bonuses such as swing, proficiency and backstab. Final damage is nonnegative.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateWeaponAttackDamage`, `Game/Formulas/FormulaHelper.cs#CalculateHandToHandAttackDamage`, `Game/Formulas/FormulaHelper.cs#CalculateSwingModifiers`, `Game/Formulas/FormulaHelper.cs#CalculateBackstabDamage`
- **Inputs and outputs** — Hit, damage range and modifiers → amount
- **Dependencies** — COMBAT, CHAR, ITEM
- **Edge cases and interactions** — Backstab chance can tally skill. Verify modifier order by attack route.
- **Design questions** — Which bonuses should scale the roll versus add to it?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-014-A01).

### My Intended Specification

See the [approved RULE-014 specification](../../design/systems/RULE/RULE-014.md). Route-specific damage retains explicit ordering, moddable backstab/minimums and an optional retained-result critical multiplier after backstab. Mods can extend creature strengths/weaknesses by weapon type/material; component penalties cannot reduce earlier damage. Effect application remains owner-reviewed.

## RULE-015 — Timing and adjustment hooks

- **Parent subsystem** — Combat math
- **Purpose** — Expose shared attack timing and override seams.
- **Existing implementation** — Melee animation and bow cooldown use separate helpers. Weapon attack processing calls final hit and damage adjustment hooks.
- **Source** — `Game/Formulas/FormulaHelper.cs#GetMeleeWeaponAnimTime`, `Game/Formulas/FormulaHelper.cs#GetBowCooldownTime`, `Game/Formulas/FormulaHelper.cs#AdjustWeaponHitChanceMod`, `Game/Formulas/FormulaHelper.cs#AdjustWeaponAttackDamage`
- **Inputs and outputs** — Player, weapon and timing → timing or adjusted result
- **Dependencies** — COMBAT, MOD
- **Edge cases and interactions** — Default hit adjustment passes through. Caller animation timing remains open.
- **Design questions** — Should animation timing affect attack results?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-015-A01).

### My Intended Specification

See the [approved RULE-015 specification](../../design/systems/RULE/RULE-015.md). Moddable melee-frame/bow-cooldown formulas have separate positive minima and captured attack timing. Eligible elapsed time excludes pauses/loading; adjustment hooks default pass-through at approved accuracy/damage stages. COMBAT/AV phases and persistence remain owner-reviewed.

## RULE-016 — Physical-hit mutations

- **Parent subsystem** — Combat math
- **Purpose** — Apply secondary hit outcomes.
- **Existing implementation** — The attack can consume poison on positive damage, invoke monster effects, damage equipment and dispatch the Ring of Namira payload.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateAttackDamage`, `Game/Formulas/FormulaHelper.cs#DamageEquipment`, `Game/Formulas/FormulaHelper.cs#OnMonsterHit`, `Game/Formulas/FormulaHelper.cs#InflictPoison`, `Game/Formulas/FormulaHelper.cs#InflictDisease`
- **Inputs and outputs** — Attack and damage → wear, status or payload callback
- **Dependencies** — COMBAT, ITEM, MAGIC
- **Edge cases and interactions** — Check zero damage and non-enemy attacker context for the ring callback.
- **Design questions** — Which consequences require actual health loss?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-016-A01).

### My Intended Specification

See the [approved RULE-016 specification](../../design/systems/RULE/RULE-016.md). Explicit owner phases use positive resolved-damage triggers, coherent poison settlement, shield-or-armor wear and safe reactive contracts. Creature-effect activation frequency is configurable; critical multipliers do not duplicate effects. Detailed composition and owner integration remain dependencies.

## RULE-017 — Saving throws

- **Parent subsystem** — Magic math
- **Purpose** — Scale incoming effects.
- **Existing implementation** — Granted elemental resistance checks first. Race, tolerances, biography and caller modifier combine before an early immunity check. Otherwise MagicResist is added, chance clamps to 5–95, and margin can reduce damage or duration.
- **Source** — `Game/Formulas/FormulaHelper.cs#SavingThrow`, `Game/Formulas/FormulaHelper.cs#ModifyEffectAmount`, `Game/Formulas/FormulaHelper.cs#GetEffectFlags`, `Game/Formulas/FormulaHelper.cs#GetElementType`
- **Inputs and outputs** — Effect and target → retained payload percentage
- **Dependencies** — MAGIC, CHAR, COMBAT
- **Edge cases and interactions** — Combining tolerance flags is an explicit DFU deviation. Verify compound flag and margin boundaries.
- **Design questions** — When should a save cancel versus scale an effect?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-017-A01).

### My Intended Specification

See the [approved RULE-017 specification](../../design/systems/RULE/RULE-017.md). Moddable ordered resistance preserves pre-Willpower immunity and retained-payload scaling, with one retained save per application. Numeric scaling has no implicit minimum; binary-effect interpretation and MAGIC/SAVE mappings remain explicit owner contracts.

## RULE-018 — Spell costs and enchantment capacity

- **Parent subsystem** — Magic math
- **Purpose** — Compute magic resource inputs.
- **Existing implementation** — Populated effect costs sum and receive a target multiplier. Nonempty arrays enforce a five-point casting floor. Separate helpers handle classic spell records and material-dependent enchantment power.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateTotalEffectCosts`, `Game/Formulas/FormulaHelper.cs#CalculateEffectCosts`, `Game/Formulas/FormulaHelper.cs#CalculateCastingCost`, `Game/Formulas/FormulaHelper.cs#GetSpellEnchantPtCost`, `Game/Formulas/FormulaHelper.cs#GetItemEnchantmentPower`, `Game/Formulas/FormulaHelper.cs#CalculateCasterLevel`
- **Inputs and outputs** — Effects, caster, target, classic record or item → cost, capacity or effective level
- **Dependencies** — MAGIC, ITEM, DATA-011
- **Edge cases and interactions** — Empty arrays return zero before flooring. Classic coefficient and caster scaling need fixtures.
- **Design questions** — Should purchase cost and casting cost share inputs?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-018-A01).

### My Intended Specification

See the [approved RULE-018 specification](../../design/systems/RULE/RULE-018.md). Distinct moddable effect/spell/classic-item/capacity models preserve staged rounding, nonnegative skill reduction, explicit special/fixed costs and validated material capacity. Shared quotes spend nothing; MAGIC/ITEM/ECON own commitment and final eligibility/pricing.

## RULE-019 — Enemy properties and pacification

- **Parent subsystem** — Encounters
- **Purpose** — Provide shared enemy classification and scaling.
- **Existing implementation** — Helpers map group, language and weight. Separate rules calculate enemy-class max health and language-based pacification.
- **Source** — `Game/Formulas/FormulaHelper.cs#GetEnemyEntityEnemyGroup`, `Game/Formulas/FormulaHelper.cs#GetEnemyEntityLanguageSkill`, `Game/Formulas/FormulaHelper.cs#GetEnemyEntityWeightInClassicUnits`, `Game/Formulas/FormulaHelper.cs#RollEnemyClassMaxHealth`, `Game/Formulas/FormulaHelper.cs#CalculateEnemyPacification`
- **Inputs and outputs** — Enemy definition, level or player skill → classification, HP or pacification
- **Dependencies** — NPC, COMBAT, CHAR
- **Edge cases and interactions** — Verify custom IDs and fallback classification.
- **Design questions** — Which properties should be content definitions?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-019-A01).

### My Intended Specification

See the [approved RULE-019 specification](../../design/systems/RULE/RULE-019.md). Moddable explicit group/language/weight definitions distinguish intentional absence from missing data. Enemy-class health is assigned once and retained; pacification preserves live-input, 200-outcome precision. NPC eligibility and consequences remain owner-reviewed.

## RULE-020 — Ambient spawn checks

- **Parent subsystem** — Encounters
- **Purpose** — Roll by environment.
- **Existing implementation** — Zero means spawn. Location night and wilderness night roll 0–23, wilderness day 0–35. Dungeon rolls 0–35 only when enemy alert is active.
- **Source** — `Game/Formulas/FormulaHelper.cs#RollRandomSpawn_LocationNight`, `Game/Formulas/FormulaHelper.cs#RollRandomSpawn_WildernessDay`, `Game/Formulas/FormulaHelper.cs#RollRandomSpawn_WildernessNight`, `Game/Formulas/FormulaHelper.cs#RollRandomSpawn_Dungeon`
- **Inputs and outputs** — Environment, alert and RNG → spawn signal
- **Dependencies** — NPC, TIME, LOC
- **Edge cases and interactions** — Per-check odds depend on scheduling for encounter frequency.
- **Design questions** — Which contexts should share spawn odds?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-020-A01).

### My Intended Specification

See the [approved RULE-020 specification](../../design/systems/RULE/RULE-020.md). Independently moddable exact context odds and dungeon alert eligibility resolve one retained gate per opportunity. Gate success is separate from placement and committed activation; NPC/TIME scheduling and SAVE integration remain owner dependencies.

## RULE-021 — Trade price

- **Parent subsystem** — Economy math
- **Purpose** — Calculate purchase and resale amounts.
- **Existing implementation** — Base cost floors input and applies region and shop quality. Buy and sell use separate integer formulas with live Mercantile and Personality.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateCost`, `Game/Formulas/FormulaHelper.cs#CalculateTradePrice`, `Game/Formulas/FormulaHelper.cs#ApplyRegionalPriceAdjustment`
- **Inputs and outputs** — Value, shop, character and region → price
- **Dependencies** — ECON, CHAR, ITEM
- **Edge cases and interactions** — Base cost ignores condition in the default path. No current location bypasses regional adjustment.
- **Design questions** — Which price adjustments should players see?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-021-A01).

### My Intended Specification

See the [approved RULE-021 specification](../../design/systems/RULE/RULE-021.md). Moddable staged buy/sell pricing preserves fixed-point rounding, optional condition policies and independent minima. Merchant region is explicit; shared quotes revalidate and changed amounts require renewed acceptance. ECON owns atomic settlement.

## RULE-022 — Regional price changes

- **Parent subsystem** — Economy math
- **Purpose** — Evolve price multipliers over time.
- **Existing implementation** — Initial factors span 750–1250. Updates compare faction power and current adjustment, roll price direction and clamp to 250–4000. Branches update price condition flags.
- **Source** — `Game/Formulas/FormulaHelper.cs#RandomizeInitialRegionalPrices`, `Game/Formulas/FormulaHelper.cs#UpdateRegionalPrices`
- **Inputs and outputs** — Faction power, region records, elapsed iterations and RNG → updated region state
- **Dependencies** — ECON, FACT, TIME
- **Edge cases and interactions** — Absent merchant faction skips updates. Test flag transitions and catch-up.
- **Design questions** — How should local prices react to factions and elapsed time?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-022-A01).

### My Intended Specification

See the [approved RULE-022 specification](../../design/systems/RULE/RULE-022.md). Moddable regional evolution uses explicit political inputs, exclusive price flags and day-major retained catch-up. Completed days publish coherently; affected trade commitments require current ready prices and renewed acceptance when quotes change. FACT/TIME/SAVE details remain dependencies.

## RULE-023 — Repair and identification

- **Parent subsystem** — Economy math
- **Purpose** — Quote item service costs and repair time.
- **Existing implementation** — Repair fee is zero at full condition and can be discounted by guild. Time scales with damage with a one-day minimum. Identification can be free at Witches Festival.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateItemRepairCost`, `Game/Formulas/FormulaHelper.cs#CalculateItemRepairTime`, `Game/Formulas/FormulaHelper.cs#CalculateItemIdentifyCost`
- **Inputs and outputs** — Value, condition, guild and calendar → fee or duration
- **Dependencies** — ECON, ITEM, FACT, TIME
- **Edge cases and interactions** — A direct full-condition time calculation still has its minimum.
- **Design questions** — Which services should vary by condition and affiliation?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-023-A01).

### My Intended Specification

See the [approved RULE-023 specification](../../design/systems/RULE/RULE-023.md). Moddable repair/identification formulas distinguish no service from valid free service, preserve raw-condition duration and explicit regional/guild/calendar context. Accepted repair prices/completion terms remain retained; batch and settlement details stay owner-reviewed.

## RULE-024 — Credit and other service formulas

- **Parent subsystem** — Economy math
- **Purpose** — Quote loan terms and service inputs.
- **Existing implementation** — Bank cap scales with level and default repayment adds ten percent. Room, blessing and Daedra cost/chance use separate helpers.
- **Source** — `Game/Formulas/FormulaHelper.cs#CalculateMaxBankLoan`, `Game/Formulas/FormulaHelper.cs#CalculateBankLoanRepayment`, `Game/Formulas/FormulaHelper.cs#CalculateRoomCost`, `Game/Formulas/FormulaHelper.cs#CalculateTempleBlessing`, `Game/Formulas/FormulaHelper.cs#CalculateDaedraSummoningCost`, `Game/Formulas/FormulaHelper.cs#CalculateDaedraSummoningChance`
- **Inputs and outputs** — Level, credit amount, duration, donation or reputation → terms or service result
- **Dependencies** — ECON, FACT, MAGIC
- **Edge cases and interactions** — Repayment ignores its region argument. Service-specific conditions need ECON traces.
- **Design questions** — Which rules should depend on time, reputation or level?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-024-A01).

### My Intended Specification

See the [approved RULE-024 specification](../../design/systems/RULE/RULE-024.md). Moddable loan/summoning baselines use safe explicit inputs, exact repayment rounding and valid free boundaries. Room pricing counts explicit calendar/free-day slots. Temple blessing remains explicitly deferred to FACT/MAGIC; service eligibility/settlement stay owner-reviewed.

## RULE-025 — Stack eligibility

- **Parent subsystem** — Item math
- **Purpose** — Classify items that may stack.
- **Existing implementation** — Defaults allow ingredients, potions, books, gold, arrows and oil. A true override allows more. False falls through.
- **Source** — `Game/Formulas/FormulaHelper.cs#IsItemStackable`, `Game/Items/ItemCollection.cs`
- **Inputs and outputs** — Item and optional override → eligibility
- **Dependencies** — ITEM, MOD
- **Edge cases and interactions** — Stack identity is a separate concern.
- **Design questions** — What must match before two items merge?
- **Complexity** — Small
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-025-A01).

### My Intended Specification

See the [approved RULE-025 specification](../../design/systems/RULE/RULE-025.md). Bidirectional moddable eligibility resolves category, template and instance restrictions explicitly. Pairwise compatibility remains separate; pure queries expose reasons and preserve unique state/quantities. Incompatible saved-policy changes require explicit ITEM/SAVE migration.

## RULE-026 — Material weighting

- **Parent subsystem** — Item math
- **Purpose** — Bias item quality by level.
- **Existing implementation** — Weapon material combines a 0–255 draw with a piecewise level adjustment, clamps to 0–256 and walks the ItemBuilder weights. Armor has a separate helper.
- **Source** — `Game/Formulas/FormulaHelper.cs#RandomMaterial`, `Game/Formulas/FormulaHelper.cs#RandomArmorMaterial`, `Game/Items/ItemBuilder.cs`
- **Inputs and outputs** — Level, weights and RNG → material
- **Dependencies** — ITEM, CHAR
- **Edge cases and interactions** — Verify boundaries and weighting across the two paths.
- **Design questions** — How strongly should item materials follow player level?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-026-A01).

### My Intended Specification

See the [approved RULE-026 specification](../../design/systems/RULE/RULE-026.md). Moddable selectors preserve explicit legacy boundaries or declared alternative weighting, caller-supplied level and category-first 69/20/11 armor selection. Assigned outcomes persist; isolated diagnostics report actual mapped probabilities. ITEM/SAVE adapters remain dependencies.

## RULE-027 — Seeded building names

- **Parent subsystem** — World lookups
- **Purpose** — Generate repeatable contextual names.
- **Existing implementation** — Seeds DFRandom and selects localized name parts by building type, with faction/location substitutions. House for sale uses a fixed label.
- **Source** — `Game/Formulas/FormulaHelper.cs#GenerateBuildingName`, `Utility/BuildingNames.cs`
- **Inputs and outputs** — Seed, building type, faction and text lists → name
- **Dependencies** — LOC, DATA-013, RULE-002
- **Edge cases and interactions** — List order and length affect repeatability. Fixed-label path also reseeds.
- **Design questions** — Which names must survive language and content changes?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-027-A01).

### My Intended Specification

See the [approved RULE-027 specification](../../design/systems/RULE/RULE-027.md). Private DFU-compatible generation uses explicit building context and moddable patterns/mappings. Retained name/components support compatible localization without reroll; state labels and quest renames do not silently replace identity. Fixtures and owner integration remain dependencies.

## RULE-028 — Regional holiday and clan mappings

- **Parent subsystem** — World lookups
- **Purpose** — Supply regional rule inputs.
- **Existing implementation** — Holiday lookup takes game time and region and feeds identification pricing. Vampire clan lookup maps region into transformation data.
- **Source** — `Game/Formulas/FormulaHelper.cs#GetHolidayId`, `Game/Formulas/FormulaHelper.cs#GetVampireClan`
- **Inputs and outputs** — Time and region → holiday ID or clan
- **Dependencies** — TIME, LOC, MAGIC, FACT
- **Edge cases and interactions** — Verify boundary dates and unsupported regions against fixtures.
- **Design questions** — Which regional mappings should come from content?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1, 2026-11-06 (RULE-028-A01).

### My Intended Specification

See the [approved RULE-028 specification](../../design/systems/RULE/RULE-028.md). Moddable stable holiday/clan mappings require explicit regional/calendar context. Holiday sets support overlaps and all valid dates; clan fallbacks are declared and assigned identities persist. Calendar/service-priority and transformation/SAVE integration remain dependencies.

## Classic provenance and next review steps

- DFRandom explicitly aims for classic-compatible sequences. Compare seeded draws and building names with original fixtures. The enemy weapon choice and mixed career tolerance calculation are explicitly documented DFU divergences. Classic equivalence for other constants and formulas remains unverified.
- Review shared RNG state and override priority first. Then exercise integer thresholds, combat mutations and saving-throw margins. Use representative spell records, economic inputs and localized naming lists to verify content-dependent outcomes.
- Scope separates attack eligibility, accuracy, damage and mutations, as well as transaction prices and regional price drift. Feature-local random decisions remain with their owners. The RNG caller inventory is sampled. Runtime and original-game comparisons remain open.
