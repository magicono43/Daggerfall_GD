# RULE-020 — Ambient spawn checks

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Resolve exact context-dependent random encounter gates for authorized ambient spawn opportunities, without conflating a passed check with successful spawning.

## Intended player experience

Ambient encounter risk varies by declared context and can be rebalanced by mods. Opportunities do not multiply through rendering or technical retries. Diagnostics explain checks separately from placement; per-check odds are not falsely presented as hourly encounter rates.

## Confirmed requirements

RULE-020-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve independently moddable exact probabilities/added contexts, moddable dungeon alert prerequisite, explicit gate results, rational boundary/draw rules, retained opportunity outcomes and separate diagnostics.

RULE-003 owns purpose-isolated sources/fresh future randomness and retained retries. RULE-004/DATA-003 own validated locked hooks/definitions. CORE-020 distinguishes spawn attempts, actors and committed encounter activation; NPC/TIME own actual scheduling and placement.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#RollRandomSpawn_LocationNight` and `RollRandomSpawn_WildernessNight` draw integers 0–23; `RollRandomSpawn_WildernessDay` draws 0–35. Zero signals spawn.
- `RollRandomSpawn_Dungeon` draws 0–35 only if player EnemyAlertActive, otherwise returns nonzero without a draw. Each helper exposes an override, and the dungeon override is checked before its built-in alert condition.
- `Game/Entities/PlayerEntity.cs#IntermittentEnemySpawn` separately checks time/suppression/location/interior conditions, selects a context, interprets the gate, chooses an enemy and creates a foe spawner. Its time expression and outer update cadence require further analysis before asserting hourly frequency.
- The inspected outside caller treats minutes 360–1080 inclusive as wilderness day and other times as night; dungeon checks are separately routed. These are caller facts, not newly approved universal TIME/environment definitions.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime opportunity frequency/placement and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Context and eligibility

NPC/TIME supply one explicit context and authorized opportunity identity with required current state. Baseline supported probability contexts are location-area night, wilderness day, wilderness night and dungeon. These are not instructions to check all four contexts on every update. Additional contexts require explicit definitions and routing/eligibility contracts.

Baseline dungeon gate requires active enemy alert; the prerequisite is moddable through supported definitions/hooks. A valid unalerted dungeon request is ineligible and draws nothing. Unknown/missing alert/location/time data is an explicit error, not assumed false/unalerted.

Eligibility and probability policy remain separate. A hook that changes odds cannot accidentally bypass alert, spawning suppression, caps or other owner prerequisites. Explicit supported eligibility overrides may change the declared alert rule; registration/validation must identify that scope under RULE-004. No default location-day, ordinary-building-interior or other absent-context probability is invented here.

### Exact random gate

Each eligible context uses validated integer numerator a and denominator b, with b>0 and 0<=a<=b within supported safe domains. Obtain one unbiased uniform integer R in inclusive 0..b−1; pass iff R<a. A failed roll is distinct from ineligibility and invalid state.

Baselines: location night 1/24; wilderness day 1/36; wilderness night 1/24; alerted dungeon 1/36. Preserve exact fractions rather than rounding to RULE-001 integer percentages. This is an explicit rational gate model alongside percentile checks. Use an owned NPC/encounter random purpose under RULE-003; initializing/checking this purpose cannot consume combat/presentation draws.

Eligible a=0 and a=b still consume one logical draw, including b=1. Ineligible requests consume none. Logical bounded draws may use multiple raw generator operations for unbiased range mapping. Probability queries consume no draws. Validate definitions/context before obtaining the draw.

### Opportunity/result lifecycle

Retain the resolved gate context/odds/roll/result for each owner-identified opportunity. Technical retries reuse it rather than draw again. Failed placement cannot restart the random gate until it succeeds. NPC explicitly defines whether placement is retried, abandoned or superseded by a genuinely new opportunity.

A passed gate is only permission to proceed to the next owner stage, not guaranteed actor construction or an encounter event. NPC owns enemy selection, number, location restrictions, spacing, pending/active caps and placement failure. TIME owns cadence, time advancement/rest/travel handling and catch-up. These policies must not be inferred from a 1/b probability.

Context can change before a pending placement commits. NPC revalidates placement eligibility and defines cancellation/continuation without silently changing a retained result to a new context or reroll. CORE gates current session validity; ended-session requests cannot spawn into a replacement session.

### Diagnostics and modding

Report context, eligibility reason, configured exact fraction, retained roll/result and later placement result as separate facts. Expose technical failure separately from a valid gate failure. Inspection/logging does not rerun the gate or create a new opportunity; no player popup per check is required.

Do not label the fraction as a per-hour encounter rate unless the owner schedule and eligibility define that interpretation. Even a passed gate may fail placement, and suppressed opportunities are not equivalent to failed random draws.

Each context's odds and the dungeon prerequisite are independently moddable. Support validated added contexts and explicit RULE-004 calculation/eligibility hooks with declared contracts. Use stable context IDs/provenance and DATA-003 locking/recovery; unsupported context or malformed odds cannot silently select wilderness/default behavior. Exact schema, numeric limits and resolved hook output representations remain dependencies, not a generic rule interpreter.

## Relevant formulas and parameters

| Context | Baseline a/b |
| --- | --- |
| Location area at night | 1/24 |
| Wilderness by day | 1/36 |
| Wilderness at night | 1/24 |
| Dungeon with active alert | 1/36 |

Unalerted dungeon is ineligible by baseline, not a rolled 0/36 check. For eligible a/b, R~uniform integers [0,b−1], pass iff R<a. Thus 1/24≈4.1667% per eligible check and 1/36≈2.7778%, without integer-percent rounding. No hourly frequency or universal schedule is selected.

## Required data

Stable opportunity/session/context identity; validated eligibility/alert state; exact numerator/denominator and provider provenance; owned random source; retained draw/result; owner placement/activation state and reason. Concrete opportunity lifetime, scheduler state and persistence schemas remain NPC/TIME/SAVE dependencies.

## Inputs, outputs and events

Inputs: authorized opportunity with explicit context/current eligibility and locked definitions, or pure probability query. Outputs: passed, failed, ineligible with reason, or explicit error; resolved results include retained context/odds/roll. The gate itself creates no actor/spawner, grants no loot/practice and emits no encounter activation. NPC/CORE publish truthful committed activation separately.

## Cross-system interactions

NPC owns opportunities/selection/placement/caps; TIME scheduling/environment-time boundaries/catch-up; LOC/WORLD location context; alert owner supplies resolved state. CORE-005/015/016/017 gate lifecycle/simulation, CORE-019 threat/rest context and CORE-020 truthful actor/encounter notifications. RULE-003 sources/retries, RULE-004/DATA-003 validation/hooks and SAVE pending-state handling remain binding. UI/DEV inspect without mutation.

## Edge cases and failure conditions

- Zero/guaranteed valid fractions draw once; malformed fractions and missing required contexts fail before drawing.
- Pauses, rendering/UI refresh and duplicate updates cannot manufacture new opportunities or replay placement.
- Blocked alert/suppression/caps cannot be bypassed by odds=100%; explicit owner eligibility remains required.
- A successful gate followed by no legal placement is neither guaranteed encounter nor automatic permission for unbounded retries.
- Stale session/context requests, missing source and hook failures invoke explicit recovery rather than false no-spawn success or silent default fractions.

## Configuration and balancing options

Support independent rational context odds, added-context definitions and supported alert eligibility overrides. NPC/TIME independently define cadence, caps, density, enemy tables and placement; those are not hidden parameters of this gate. No automatic enemy-alert duration, respawn schedule, rare-loot rate or anti-save-scumming restriction is introduced.

## Save/load considerations

Persist owner-required scheduler/opportunity identity, retained gate results and pending/committed placement state when resumption is supported. Restore without rerolling an already retained opportunity or recreating committed actors/spawners. Future genuinely unresolved opportunities use fresh RULE-003 randomness. Whether pending opportunities resume/cancel and how missed time is handled need explicit NPC/TIME/SAVE contracts; loading alone is not a new free opportunity or wall-clock catch-up. Changed context definitions require compatibility/recovery rather than silent remapping.

## Technical constraints

Target: Godot 4.7.2. Use unbiased safe bounded integer draws, stable opportunity/context identity and explicit eligibility. Separate check, placement and activation. APIs/scheduler/schema remain engineering/owner dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Four baseline contexts produce exact fractions, with unalerted dungeon ineligible/no draw and no guessed probability for unsupported contexts.
2. Independently modded fractions/eligibility/added contexts validate safe domains and required routing; invalid definitions fail explicitly.
3. Each eligible opportunity resolves one logical bounded draw, including guarantees; queries/ineligible paths consume none.
4. Retried opportunities reuse results and failed placement cannot silently reroll; only owner-authorized new opportunities draw again.
5. Passed gates do not instantiate/announce actors; NPC placement and committed CORE-020 activation remain separate.
6. Diagnostics distinguish eligibility/odds/roll/gate/placement without false hourly-rate claims or per-check popups.
7. Restore/duplicate callbacks/stale sessions cannot replay gates/actors or create free catch-up opportunities.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed RULE-003/004, DATA-003 and CORE-020. Rational resolution preserves precision without changing RULE-001 percentile semantics. Retained gate results coexist with fresh future gameplay streams. Existing-actor/pending-spawn/encounter activation distinctions remain binding; source scheduling/dawn/dusk conditions are not approved automatically.

## Outstanding questions and approval

No blocking probability-gate policy question remains. Before implementation: define context/day-night routing, scheduler/opportunity identities, numeric/hook domains, source purposes, caps/placement retry/context-change handling and pending SAVE policy. These cannot waive exact odds, no ineligible draws, retained results or gate-versus-activation distinction.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-020-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented context, scheduling, placement and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
