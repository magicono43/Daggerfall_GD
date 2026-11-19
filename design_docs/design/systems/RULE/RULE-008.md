# RULE-008 — Recovery rates

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Calculate eligible hourly rest recovery for health, fatigue and magicka using explicit current inputs, restrictions and source-compatible rounding. Rest scheduling and authoritative pool changes remain with their owners.

## Intended player experience

Recovery follows character capabilities and the approved Rapid Healing environment rules. Players can inspect why a rate applies or recovery is blocked, and distinguish a nominal hourly gain from the amount actually restored. Full or zero-capacity pools never manufacture recovery, and rest cannot bypass an explicit prohibition through a minimum-one rule.

## Confirmed requirements

RULE-008-D01–D03 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm integer-division order for health, prohibition precedence over minimum recovery, and inspectable calculated/blocked/actual amounts.

CHAR-021 already approves hourly formulas, live-input reevaluation, Rapid Healing's +60/+100 terms and environment classification, eligible modes, completed-hour settlement, Medical practice and until-healed termination. CHAR-018 owns maxima, saturating mutations and consequence-free restoration. RULE-005 owns the Endurance healing modifier. These decisions remain binding rather than reopened here.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateHealthRecoveryRate` reads live Medical/live Endurance, effective player maximum health, career RapidHealing flags, day state and interior state. It adds 60 to Medical, or 100 when Rapid Healing applies, then returns at least one health.
- In that expression, adjusted Medical × maximum health / 1000 uses integer arithmetic before the outer floor. Division truncates toward zero. The intended safe recreation does not adopt the short narrowing used when the source adds to its Medical local.
- `CalculateFatigueRecoveryRate` returns max(1,maxFatigue/8) with integer division. `CalculateSpellPointRecoveryRate` returns zero for NoRegenSpellPoints, otherwise max(1,maxMagicka/8).
- The helpers expose formula overrides. `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#TickVitals` applies recovery and tallies Medical; loitering does not call this recovery path in the inspected flow.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete runtime boundary/restriction behavior and DOS equivalence remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Current inputs and Rapid Healing

For each committed eligible recovery tick, obtain then-current validated live Medical M, live Endurance E, effective maximum health H, maximum fatigue F and effective maximum magicka K. Use current career Rapid Healing context and explicit owner-provided recovery prohibitions. Do not capture rates only once at rest start.

Normal Medical addition A is 60. Applicable Rapid Healing replaces A with 100, rather than adding another 100 or multiplying the whole result. General/Always applies everywhere. Light applies during daytime outdoors. Darkness applies otherwise, including buildings/dungeons during daytime and outdoors at night. This is the approved context classification, not measured scene brightness; lamps do not automatically change it. Validated alternate environment policies require their focused owner's contract under CHAR-021.

### Health arithmetic

Compute Endurance modifier m=floor(E/10)−5 under RULE-005. Compute Medical contribution b=trunc((M+A)×H/1000), truncating division toward zero. Nominal permitted health recovery is Rh=max(1,m+b).

Maintain the division before addition; do not replace it with floor of the full rational sum for negative Medical contributions. Use supported safe intermediate arithmetic without short narrowing or wrap. Negative live Medical remains valid under CHAR-011 within supported domains; do not silently clamp it before this formula. Minimum recovery is not permission to accept malformed or overflowing inputs.

### Fatigue, magicka and prohibitions

Nominal permitted fatigue recovery is Rf=max(1,floor(F/8)); nominal permitted magicka recovery is Rm=max(1,floor(K/8)). Valid maxima are nonnegative integers, so floor matches the source integer division here. Fatigue is in authoritative internal units, not display units; do not multiply the rate by CHAR-018's precision factor a second time.

An explicit applicable prohibition sets that pool's eligible rate to zero, overriding the minimum-one rule. NoRegenSpellPoints prohibits ordinary rest magicka regeneration. It does not automatically prohibit potions, spells or other sources: those require their own approved contracts. Other effect/transformation/rest restrictions come from their owners; this feature does not invent a new universal restriction or stacking precedence.

Distinguish an explicit valid prohibition from missing required rule/context. Missing context is an error requiring recovery, not a silently blocked or permitted rate. Rates are nonnegative healing/recovery amounts, never damage.

### Application and cadence

CHAR-021 applies recovery only after completed eligible timed/until-healed rest hours by default. Loitering and unfinished hours grant no default recovery. This helper does not advance time, settle interruptions, award Medical practice or choose encounter order. CHAR-021 retains +1 raw Medical per committed recovery hour, including capped gains, and TIME defines consistent boundary ordering.

For a valid current amount C, maximum X and eligible hourly rate R, actual amount restored is D=min(R,X−C); new amount is C+D through CHAR-018's authoritative operation. The formula assumes a valid reconciled pair 0<=C<=X; invalid pairs require validation/recovery rather than accidental negative recovery. At full or zero capacity, D=0 even if the nominal rate is 1. No breath reset, generic full-vitals refill or simultaneous ordinary fatigue drain is introduced.

Until-healed uses CHAR-021's recoverability rules. Prohibited magicka is not a reason to rest forever. Other unrecoverable missing pools require explanation/termination under that owner. A nominal rate alone is not proof that rest is permitted or that a missing pool can recover.

### Explanations and queries

Provide an inspectable breakdown of the nominal formula result, applicable restriction/reason and actual amount restored after capacity limits. Include relevant Medical/Endurance/maximum/context inputs and distinguish hourly rates from committed gains. A future tick estimate may change if inputs/context change; do not present it as a guaranteed total over an entire rest.

Display/diagnostic queries use the same resolved formulas as gameplay without advancing time, awarding practice, drawing randomness or applying recovery. Exact placement, precision and historical tick-detail retention remain UI/DEV dependencies; no mandatory popup per tick is introduced.

## Relevant formulas and parameters

- A=60 normally; A=100 for applicable Rapid Healing.
- m=floor(E/10)−5; b=trunc((M+A)×H/1000).
- Rh=max(1,m+b); Rf=max(1,floor(F/8)); Rm=max(1,floor(K/8)).
- Eligible rate for a prohibited pool is 0, otherwise its permitted nominal rate.
- D=min(R,X−C), for validated 0<=C<=X.

Example: E=50, M=40 and H=100 give health recovery 10 normally or 14 with applicable Rapid Healing. F=640 gives 80 fatigue internal units per hour. K=7 gives nominal magicka recovery 1 unless prohibited; K=0 still restores nothing after saturation.

Negative-Medical rounding fixture: E=60, M=−61, A=60 and H=100 give b=trunc(−0.1)=0, m=1 and Rh=1. At E=70 the same inputs give Rh=2; flooring the rational contribution instead would incorrectly give 1. Use valid extended live-skill domains and safe arithmetic for this case.

## Required data

Live Medical/Endurance; validated effective maxima and current pools for application; career Rapid Healing/NoRegenSpellPoints state; explicit day/interior or approved alternate environment context; applicable restrictions with reasons; resolved formula parameters/provenance; and owner-managed recovery tick identity. Concrete schemas, hook contracts and tick-history representation remain dependencies.

## Inputs, outputs and events

Inputs: explicit current validated character/environment/restriction context and authorized recovery tick application. Outputs: nominal/eligible rates, reasons and actual committed deltas, or explicit error. Pure rate queries do not mutate pools. CHAR-021/018 own tick commitment, practice and notifications; concrete API/event names are unselected.

## Cross-system interactions

CHAR-011 supplies live values, RULE-005 Endurance modifier, CHAR-018 valid maxima/pool mutations and CHAR-021 rest scheduling/settlement/practice. CORE-019 owns rest eligibility/interruption; TIME and environment owners supply context/boundary ordering. MAGIC and transformation owners provide explicit restrictions. RULE-004 governs supported hook validation/selection/runtime failure; DATA-003 governs validated configuration/locking. SAVE restores pools/activity before deriving rates; UI/DEV observe consistent explanations.

## Edge cases and failure conditions

- Negative Medical uses source-compatible truncation without short overflow; zero/extended valid inputs follow supported domains.
- Prohibition overrides minimum one; full/zero-capacity pools have actual gain zero without fake depletion/recovery events.
- Inside daylight counts as Darkness by default; cosmetic lights do not silently alter it.
- Expiring effects, maximum changes and dawn/dusk require current tick inputs under declared TIME ordering rather than render timing.
- Queries, duplicate tick callbacks and load reconstruction cannot award a second recovery/practice tick.
- Invalid inputs, missing required environment/restriction context or failed callbacks require explicit owner recovery. Do not substitute vanilla, unlimited recovery or a false zero-rate success.

## Configuration and balancing options

Retain CHAR-021's supported validated rate/cadence/mode/partial/environment overrides. Formula parameter/hook schemas must declare input/output domains, units, rounding and restriction responsibilities under DATA-003/RULE-004. No new arbitrary rule interpreter, continuous passive-regeneration feature, brightness threshold or universal prohibition on unrelated healing sources is approved. Changing a rate cannot silently change committed past recovery.

## Save/load considerations

Save authoritative pools and required rest/source state under CHAR-018/021. Rebuild derived rates and restriction/environment context before any supported continuation. Loading does not refill, replay completed ticks/practice or advance wall-clock recovery. Supported partial-hour restoration follows CHAR-021/TIME/SAVE; a calculated rate does not authorize applying a partial tick. Invalid/missing required saved state uses explicit migration/recovery rather than silent full recovery or activity abandonment.

## Technical constraints

Target: Godot 4.7.2. Separate pure rate calculations, context resolution, cadence and authoritative mutations. Implement explicit safe truncation/floor operations and units; avoid engine-global context reads inside numeric helpers where resolved inputs suffice. Exact numeric widths, APIs, batching and serialization remain engineering dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Permitted rates match the stated formulas with correct division order, including negative Medical fixtures and extended supported values without wrap.
2. Rapid Healing replaces 60 with 100 only under approved classification, including indoor daylight Darkness.
3. Applicable prohibitions yield zero despite minimum recovery; NoRegenSpellPoints affects ordinary rest regeneration without automatically defining other sources.
4. Actual restoration saturates correctly, distinguishing nominal/eligible/committed amounts for full and zero-capacity pools.
5. Each committed eligible hour uses current coherent inputs under TIME/CHAR-021 ordering; queries/loading/duplicate callbacks cannot create recovery or practice.
6. Player explanations use shared resolved values and show blocking reasons without claiming estimated future gains are guaranteed.
7. Invalid inputs/context/overrides trigger explicit recovery without silent fallback, overflow or fabricated permission.
8. Restore rebuilds rates while preserving pools/rest obligations and committed ticks without refill, replay or wall-clock catch-up.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this design interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-011/018/021, CORE-019 and RULE-004/005. Source-compatible truncation refines CHAR-021's accepted integer baseline, while RULE-005's Endurance modifier retains mathematical floor. Restrictions precede minimum recovery and saturation, preserving zero/full pools. Rest cadence/practice/interruption and environment coverage remain CHAR-021's approved policies. This feature does not authorize new restriction sources or change committed recovery.

## Outstanding questions and approval

No blocking gameplay policy question remains for these rate calculations. Before implementation: finalize numeric/parameter/hook domains, complete restriction-owner contracts, environment/TIME boundary integration, coherent tick/delta reporting and resumable SAVE handling. These cannot waive division order, explicit prohibition precedence, current-input evaluation or saturation.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-008-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
