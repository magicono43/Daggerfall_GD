# TIME-010 — Timed rest, heal-until and loiter

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-16 with “I approve”. See TIME-010-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended experience

Let the player choose how long to sleep, sleep until recoverable vitals are full, or wait in place. Show the time that actually passes and let the player stop. An interruption preserves committed time and recovery. Loitering can pass time where the player lacks permission to sleep.

## Confirmed requirements

[TIME-010-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm input and limits, loiter eligibility and lack of sleep rewards, moddable pacing, stop controls and the maximum default segment.

## Daggerfall Unity reference

Static inspection of the local DFU 1.1.1 Release snapshot. `Assets/Scripts/Game/UserInterfaceWindows/DaggerfallRestWindow.cs` distinguishes timed rest, full rest and loiter. `TickRest` advances in ten-minute chunks and explicitly ticks quests. Its completed-hour branch applies vitals to sleep modes and decrements timed rest or loiter counters. `IsPlayerFullyHealed` accepts missing magicka for `NoRegenSpellPoints`. `TimedRestPrompt_OnGotUserInput` caps timed sleep at 99 hours, and `Assets/Resources/defaults.ini.txt` sets `LoiterLimitInHours=3`. The rest window gates chunks with a real-time threshold and gives loiter the slower threshold. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Modes and input

| Mode | Base request | Completion and effects |
| --- | --- | --- |
| Timed sleep | 1–99 whole game hours | Finish at the requested endpoint unless interrupted. Full vitals alone do not finish it. Apply CHAR-021 recovery and Medical practice for completed eligible sleep hours. |
| Sleep until healed | No duration entry | Finish as soon as the CHAR-021 completion condition is satisfied. If already met, finish with zero elapsed time and no bed movement or recovery tick. If a required missing pool cannot recover, explain and stop under CHAR-021. |
| Loiter | 1–3 whole game hours | Wait at the current site. Finish at the requested endpoint unless interrupted. Apply eligible calendar and timed effects. Loiter supplies no sleep recovery, sleep ticks or recovery-tick Medical practice in the base game. |

For numeric modes, accept a supported positive whole number within the resolved limit. Zero spends no time, moves no actor and grants no rewards. Invalid input or a value over the limit yields clear feedback and no activity commitment. For `n` accepted hours, the requested elapsed duration is `n × 3,600,000` game milliseconds. Validate arithmetic and the endpoint before advancing. A maximum is per request and confers no permission to start another request without fresh checks.

## Admission and advancement

- Sleep uses TIME-009 site, permission, legal and bed rules. Evaluate the heal-until target before any bed movement. Loiter uses a separate eligibility purpose with current location readiness, threat and owner restrictions. Town streets and otherwise eligible inn interiors can allow loiter without a room rental. Loitering confers no room entitlement and carries no stock vagrancy. Active combat, pursuit and applicable owner vetoes block loiter. Base loiter leaves the player in place.
- Start one TIME-002 activity with the selected mode and applicable suspension ownership. Use TIME-004 to settle applicable consequences. Check relevant restrictions before advancing each segment. Ordinary gameplay time contributes zero while the activity owns advancement. Honor independent suspension such as focus loss or loading. Time spent in prompts or awaiting processing does not accumulate extra requested advancement.
- The default segment advances at most `600,000` game milliseconds. End it earlier at the requested endpoint, a due recovery tick, an applicable cutoff such as rental expiry, or any intervening due consequence requiring exact handling. Segment length is an upper bound on a request for progression. It does not round time or grant permission to pass unresolved consequences.
- Measure default recovery hours from committed sleep elapsed in the current request. Splitting an advance at a quest or effect deadline does not reset the partial hour. At a completed hour, apply the approved CHAR-021 tick when eligible. Partial hours do not grant a stock recovery tick or Medical practice and do not carry to a new request. Reevaluate heal-until as relevant pools or restrictions change, including after each committed recovery tick. TIME-011 defines final interruption and completion handling, including recovery precedence when a blocker and tick coincide.
- Present elapsed and remaining time where known, or the heal-until goal. Live pacing is short and loiter is slower than sleep by default. Pacing governs when to request the next segment. Neither real-time gaps nor late frames authorize extra elapsed time. Accept Stop in every active mode. Finish already committed work, prevent further advancement at the applicable boundary and report actual elapsed time. TIME-011 owns final feedback and checkpoint routing.

## Required data, inputs, outputs and events

Use session and activity identity, mode, configured limits and pacing, admitted context, start time, requested endpoint or heal-until goal, committed elapsed time, segment identity, partial recovery hour and settled recovery progress. Inputs include mode selection, duration, stop, current eligibility and owner event outcomes. Outputs include admitted or rejected activity, committed progress, recovery requests to CHAR, and completion, interruption or failure details for TIME-011. UI progress reads do not alter time or vitals. API and signal names remain implementation decisions.

## Cross-system interactions

- TIME-002/004 govern the advance, due events and recovery after a technical failure. TIME-009 owns sleep site checks. CORE-016/019 supply suspension, threats and vetoes. TIME-011 owns terminal settlement. CHAR-021 owns recovery and the heal-until predicate, CHAR-020 owns ordinary fatigue drain exclusions, and CHAR-012/013 own practice and advancement. RULE-008 supplies recovery formulas through CHAR where applicable.
- QUEST-010 and MAGIC-008 apply their approved elapsed rules through TIME-004. ECON-015 ends rental sleep at exact expiry. Applicable encounters or combat threats cannot be bypassed by loitering. Encounter odds and completion messaging remain with their feature owners.

## Configuration, edge cases and save/load

- Allow validated mod overrides for numeric limits, presentation pacing, segment limits and mode policies through DATA-003 and applicable owners. Keep exact owner boundaries even with a larger segment limit. Recovery policy overrides follow CHAR-021. Keep stock heal-until free of a generic timeout. Unrecoverable required pools and invalid required state produce truthful termination instead.
- Handle early expiry, lethal effects, user stop and new threats using the actual committed endpoint. A failed or duplicate segment cannot grant additional time, recovery or practice. A zero-time request at full vitals cannot award sleep benefits. No mode can clear a separate suspension or automatically restart after a blocker.
- Native saves use settled boundaries unless SAVE and the activity owner explicitly support saving an active rest or loiter. A supported active save includes mode, goal or requested endpoint, committed elapsed, applicable context and policy, partial-hour progress and settled tick identities. Restore revalidates eligibility, rebuilds UI pacing, and resumes without advancing for wall time or duplicating work. A new request after termination starts a new recovery hour.

## Acceptance criteria

1. Timed sleep accepts 1 and 99 hours, loiter accepts 1 and 3, and above-limit entries fail with clear feedback. Zero and invalid values cause no time, bed placement or rewards. Valid mod limits apply.
2. Full-vitals timed sleep can run its full duration. Heal-until already satisfied finishes at zero time. Prohibited magicka is excluded under CHAR-021, while another required unrecoverable deficit yields an explanation and stops.
3. An eligible player can loiter in town or in an inn without a rental. The player stays in place, due quest and effect events progress, and loiter supplies no vagrancy, sleep recovery or Medical practice. Active pursuit blocks entry.
4. The ordinary maximum segment is ten minutes. An exact cutoff inside it is honored, even when an older UI frame requested the full segment. Eligible full recovery hours are counted once across segment splits. Stopping after an unfinished hour does not bank or award that hour.
5. Loiter progresses more slowly than sleep in the base presentation. Stop, independent suspension, and a delayed frame cannot trigger further unauthorized advancement. A supported in-progress restore preserves elapsed and settled progress without replay.

## Consistency review and outstanding dependencies

The specification follows TIME-002/004 advance and settlement, TIME-009 site rules, CORE-016/019 gating, LAW-006 vagrancy, ECON-015 expiry, CHAR-021 recovery and MAGIC-008 and QUEST-010 elapsed rules. Exact pacing values, loiter-specific threat thresholds, shared-boundary recovery precedence, terminal checkpoint routing and support for active saves remain owner dependencies.
