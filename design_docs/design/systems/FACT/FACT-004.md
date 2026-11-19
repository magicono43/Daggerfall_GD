# FACT-004 — Reputation normalization and legal boundary

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-004-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-004-interview-decisions).

## Gameplay purpose and intended player experience

Faction favor and hostility gradually fade as game time passes. A long trip produces the same standing as shorter advances over the same dates when no intervening changes occur. Authored exceptions let a faction retain standing indefinitely, and serving a sentence skips faction normalization during the sentence advance.

## Confirmed requirements

- Eligible positive and negative faction standing moves one point toward zero every 112 game days. Each faction may explicitly opt out. Authored starting values still apply at character creation. See FACT-004-D01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-004-interview-decisions).
- Process each boundary after the start through the destination of a committed time advance exactly once. Rest and travel count. Skip faction normalization for the prison sentence advance and discard those occurrences. LAW owns corresponding legal rules. See FACT-004-D02.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Entities/PlayerEntity.cs#Update` scans elapsed minutes and calls `NormalizeReputations` at multiples of 161,280 minutes. Its interval includes the starting minute and excludes the destination minute. The normalization routine clamps regional legal standings to −100 through +100 and moves the 62 regional values one point toward zero. It also moves every nonzero stored faction standing one point toward zero with a direct change. `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#UpdatePrisonScreen` sets a suppression flag before advancing sentence time. The player update honors that flag for both kinds of standing.

## Detailed rules and formulas

1. Use global world calendar boundaries every 112 game days, anchored to the world calendar's time origin. The schedule is shared across factions and characters. For a committed forward advance from `previous` to `current`, a boundary `b` is due when `previous < b <= current`. A new or restored character starts from its committed world-time position.
2. For each due eligible boundary, move each opted-in faction standing one point toward zero using a direct FACT-002 change. The rule is `next = currentStanding - sign(currentStanding)`, with `sign(0) = 0`. Stop at zero. An authored starting value sets the initial standing and does not change the normalization target.
3. Process boundaries in chronological order with other authorized standing effects. A span with no intervening observable work can calculate the same final value directly using `sign(s) * max(abs(s) - n, 0)`, where `n` is the count of eligible boundaries. Preserve per-boundary behavior where other work observes or changes standing.
4. A LAW-authorized prison sentence time advance marks its covered boundaries handled for faction normalization without changing standing. Resume at the next boundary crossed by an eligible advance. Rest, travel, and other ordinary committed game-time advances use the normal rule. Paused wall time supplies no game-time advance.

## Integration rules

- TIME supplies committed advance identity, endpoints, and cause. Process each boundary once in the active character timeline. A duplicate delivery, unchanged clock, or backward adjustment cannot apply a step or reverse an earlier change. Restoring a coherent snapshot restores its own progress.
- Preserve chronological order with intervening consequences. For work scheduled at the exact same boundary, use the documented TIME dispatch order. The cross-system order at a shared timestamp remains a TIME integration dependency.
- Use FACT-002 change outcomes for committed changes. A faction already at zero or opted out emits no standing change. Normalization creates no quest reward, legal penalty, or propagated change.

## Required data, inputs, outputs, and events

Use stable character and faction IDs, current standing, faction normalization eligibility, the calendar origin and period, and durable progress through committed boundaries. Inputs include a committed world-time advance, endpoints, and cause. Outputs include applied or skipped boundary progress and FACT-002 results for changed factions. TIME supplies the advance and LAW identifies the sentence advance.

## Cross-system interactions

TIME owns the game clock and dispatch. DATA-009 supplies definitions and the authored opt-out. FACT-002 owns standing changes and notifications. FACT-003 owns propagation of separately authorized effects. LAW owns jurisdictional legal standing and its recovery schedule, penalties, warrants, and sentence rules. NPC and QUEST read the resulting committed standing. QUEST-010 owns its separate recurrence and catch-up policies. CORE-016 governs pause, and SAVE restores clock and standing progress.

## Edge cases and failure conditions

- An advance landing exactly on a boundary processes it. An advance starting at that boundary does not process it again.
- A faction at −2 reaches 0 after two eligible boundaries. Further boundaries leave it neutral. An opted-out faction keeps its standing.
- A prison advance can skip multiple boundaries. An ordinary advance after release processes only new due boundaries.
- Missing required faction definitions or incompatible saved state follow DATA and SAVE recovery. Avoid replaying a partly recorded advance against already-normalized standing.

## Configuration and balancing

The shared period is 112 game days, the step is one integer point, and the target is zero. Faction content can explicitly disable normalization. Repeated long travel can soften negative standing and erode positive standing by the same calendar rule. Legal recovery balance is owned by LAW.

## Save/load considerations

Save current faction standing with sufficient time progress to resume exactly once, including skipped sentence boundaries. Restore a coherent committed clock and standing state before dependent gameplay resumes. Loading alone creates no elapsed game time.

## Technical constraints and consistency review

Calculate crossed calendar boundaries without scanning every elapsed minute. Keep processing independent of real-time frame cadence. The rules preserve FACT-002 standing semantics, FACT-003 propagation scope, DATA-009 separation of authored defaults and mutable standing, and CORE-016 pause behavior. QUEST-010's recurrence policy remains scoped to quest events.

## Acceptance criteria

1. One eligible boundary changes +2 to +1 and −2 to −1. Additional boundaries reach zero and never cross it. An opted-out faction stays unchanged.
2. A trip landing on a boundary applies one step. A following trip starting there applies no second step for it. Equivalent split and combined advances agree when no other standing changes intervene.
3. A prison sentence crossing several boundaries applies no faction steps. Release and reload preserve the skipped progress. The next ordinary due boundary applies normally.
4. Duplicate delivery and load preserve already settled progress. Paused wall time and backward adjustment create no new normalization.
5. Normalization changes only eligible faction standing, with no relationship propagation. Any regional legal changes come through LAW.

## Outstanding questions

TIME owns ordering with other work at a shared timestamp. LAW owns the separate legal normalization policy, and SAVE owns the exact persistence schema.
