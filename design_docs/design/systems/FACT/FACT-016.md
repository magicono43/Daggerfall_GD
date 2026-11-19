# FACT-016 — Temple deity benefits and blessings

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-016-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-016-interview-decisions).

## Gameplay purpose and intended experience

Temple membership grants privileges specific to the deity. Local services depend on the temple the player visits. Akatosh, Kynareth, and Stendarr can grant benefits away from the temple. Stock donations are ceremonial and acknowledge the offering. Mods may attach gameplay effects.

## Confirmed requirements

- Scope healing, cure discounts, and other temple services to the exact deity and authorized provider. Preserve DFU's stock Akatosh travel, Kynareth breath, and Stendarr death prevention formulas as moddable policies that can apply away from the temple.
- If a mod allows multiple deity memberships, distinct benefits can coexist. Competing benefits use explicit priority. Stacking requires an explicit authored rule. Stendarr follows CHAR-023's once-per-source, once-per-lethal-event evaluation and stop-on-success rules.
- Keep stock donations ceremonial. Allow mods to add effects through validated policies. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-016-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Guilds/Temple.cs` maps factions to deities and uses deity-specific tables for free healing, library access, potions and spells. `ReducedCureCost` applies Arkay's rank discount. `FastTravel`, `DeepBreath`, and `AvoidDeath` define the three benefits that apply away from a temple. `GuildManager.cs` iterates memberships for these queries. `Temple.Blessing` calls `Game/Formulas/FormulaHelper.cs#CalculateTempleBlessing`, which returns a constant 1. The blessing branch shows deity-specific text and logs the indicated benefit without applying its stat, skill or legal standing change.

## Detailed rules and formulas

1. Resolve the exact deity, authorized provider, applicable membership set, and committed rank through FACT-009/011/014. Use deity-specific service tables for access and healing. Health and attribute restoration go through their owners. A member of another temple receives the requested temple's valid nonmember service context.
2. For Arkay's eligible cure discount at stock rank `r` and nonnegative base quote `x`, use `floor(x * floor(256 * (10 - r) / 10) / 256)`. ECON and the cure owner validate and settle the final terms, including any owner minimum or expressly free cure. Recheck eligibility and require renewed acceptance if the final price changes under RULE-021.
3. Stock Akatosh travel scales eligible duration by `(95 - r) / 100`, truncating the result in the travel owner's applicable unit. Stock Kynareth breath scales eligible duration by `(10 + r) / 10`, truncating in the breath owner's applicable unit. TIME and the movement or breath owner enforce their duration domains and apply the result once per authorized operation.
4. For a qualifying active Stendarr membership, evaluate one uniform integer draw from 0 through 49 for each applicable lethal event. It succeeds when the draw is less than committed rank. A submerged player is ineligible. Rank 0 gives 0% and stock rank 9 gives 18%. CHAR-023 owns lethal event identity, deterministic source ordering, survival health and the stop-on-success rule.
5. An authorized stock donation commits payment and presents ceremonial acknowledgment. It grants no gameplay modifier or standing change. A mod may explicitly define a blessing effect. Its owner validates the target and terms and applies the effect through the appropriate gameplay system. The offer discloses any gameplay effect and its conditions before commitment.

## Approved integration defaults

- Distinct benefits can operate together. For competing eligible modifiers, select by a declared deterministic priority and report a configuration conflict when that policy cannot distinguish required contenders. An authored stacking policy defines order and limits. Death prevention always uses CHAR-023 source ordering and stops after the first success.
- Settle a modded donation effect with the authorized donation through the payment and effect owners. Repeated confirmation and recovery reuse the settled outcome. Any repeat blessing has an explicit effect-owner merge policy. A modded blessing that cannot fulfill required terms does not settle as a successful stock donation.
- Stock Stendarr prevention uses no added charge or cooldown. A mod may declare one under CHAR-023. Present prevention feedback after the survival outcome commits.

## Required data, inputs, outputs, and events

Use stable deity, membership, provider, service, benefit, donation, and operation identities, committed rank, deity service tables, donation terms, and the applicable activity context. Stendarr requires lethal event identity and submersion state. Outputs include an entitlement or denial, adjusted duration or quote, ceremonial acknowledgment or declared effect outcome, and a prevention candidate result. Owning systems publish committed changes.

## Cross-system interactions

FACT-009/011/014 supply exact membership, rank and service authorization. FACT-015 supplies common benefit scoping. ECON owns payment and quotes. CHAR and MAGIC own healing and supported blessing effects. LAW owns any explicitly authored legal effect. TIME and movement own travel and breath. CHAR-023 owns prevention and death commitment. DATA and MOD validate deity policies and SAVE restores retained state.

## Edge cases and failure conditions

- An Arkay member visiting another deity uses that provider's terms. A benefit declared to apply away from the temple needs no temple visit.
- A submerged lethal event receives no stock Stendarr draw. Duplicate lethal callbacks cannot roll again. Another prevention source can succeed first under CHAR-023.
- A stock donation still receives ceremonial feedback when no gameplay effect is configured. An unavailable required mod effect yields explicit service failure or recovery.
- Missing or incompatible deity context produces explicit unavailability. Validate mod ranks and duration factors against the consuming owner's domain.

## Configuration and balancing

Validated policies may configure deity service gates, discount factors, travel and breath factors, prevention eligibility and chance, effect costs, and priority or stacking. Stock donations stay ceremonial. Modded donations can declare supported effects, requirements, duration, and repeat rules.

## Save/load considerations

Restore deity membership and rank before entitlement queries resume. Persist settled donation and supported effect outcomes through their owners. Restore active mod effects under their effect contracts. Loading does not replay donations, healing, or prevention. CHAR-023 governs unresolved death evaluation and save eligibility.

## Technical constraints and consistency review

Keep benefit queries separate from fulfillment and random settlement. Preserve FACT-009 deity isolation, FACT-014 access revalidation, FACT-015 benefit scope, RULE-021 price acceptance, and CHAR-023 prevention ordering and survival commitment. The complete deity table and runtime unit boundaries still require verification.

## Acceptance criteria

1. Temple access and healing use the exact deity and applicable rank. Arkay's cure discount appears only through its authorized context and revalidates before payment.
2. At stock rank 5, an eligible Akatosh duration of 100 units becomes 90 and Kynareth breath of 100 units becomes 150, subject to owner bounds. Modded memberships can supply distinct benefits without implicitly stacking competing ones.
3. Stendarr rank 5 succeeds on draws 0 through 4 when eligible, never rolls while submerged, and cannot reroll the same lethal event.
4. A stock donation gives acknowledgment with no gameplay change beyond payment. An authorized modded donation can apply its disclosed effect once and retain it through save and reload under its owner's rules.

## Outstanding questions

Complete stock deity table verification, duration units and rounding fixtures, and mod effect schemas remain integration details.
