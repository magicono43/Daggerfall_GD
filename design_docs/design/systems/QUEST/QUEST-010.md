# QUEST-010 — Quest clocks and deadlines

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-010-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-010-interview-decisions).

## Gameplay purpose and intended player experience

Make quest deadlines predictable across ordinary play, rest, travel and jail. The journal shows visible deadlines and time remaining. A missed deadline can lead to an authored consequence such as a late delivery, reduced reward or different objective. The author can also make expiry terminal.

## Confirmed requirements

- Running clocks count committed in-world time, including travel, rest and jail. Pauses and real time outside the game leave them unchanged. At the exact deadline, expiry takes precedence over an uncommitted on-time hand-in. Process an expiry crossed by a time jump once before the player can act again.
- Evaluate availability windows at the destination time. Recurring events use an authored catch-up policy. Default to one catch-up execution, with options to skip missed occurrences or replay them in order within a defined limit.
- Calculate travel-derived durations once at clock start from the authored route, estimate, multiplier and minimum allowance. Preserve that deadline through route changes and reload. Show due time and a live countdown for visible deadlines. Authors can hide internal timers.
- Let quest authors choose alternative outcomes after expiry, including outcomes that keep the quest playable.

See QUEST-010-D01–D04 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-010-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Clock.cs#Tick` subtracts sampled world-time elapsed from a running clock and triggers a task at zero or below. It disables the finished clock and clamps the remaining duration to zero. `StartTimer` and `StopTimer` resume or suspend unfinished clocks. The resource supports fixed, random and travel-derived durations, and saves its last time sample and remaining duration. `Actions/DailyFrom.cs#CheckTrigger` checks the sampled hour and minute against its window. A jump can skip the entire window. These findings come from static inspection.

## Detailed rules and behaviors

1. A clock has an explicit start. It can be tied to quest activation or an authored command. A fixed duration uses the validated authored value. A random duration is resolved once per fresh clock run through its owned random source. A travel-derived duration uses the authored route and the TIME estimate at clock start. Later route changes do not recalculate a running deadline.
2. Use the authoritative committed world time. A running clock expires when `now >= due`. Reconcile a time advance before permitting the player to act on stale timing state. An on-time hand-in committed before the cutoff stands. An uncommitted on-time hand-in at or after the cutoff must revalidate and can use a late route if the quest permits it.
3. Publish expiry once per clock run and route it to the authored task or branch. Expiry closes the on-time path. The author can declare terminal failure or an alternative such as late delivery, a changed reward, or a replacement objective. Apply effects through the appropriate owner. A stopped unfinished clock retains its remaining duration. Resuming uses that duration from the resume time. Expired clocks require an explicit new run to become active again.
4. Evaluate availability windows against current world time, including after a jump. Skipping a window does not create a visit or interaction inside it. Recurrence uses separate scheduled occurrence IDs. A committed advance crosses occurrences where `previous < scheduled time <= current`. A forward jump with multiple due occurrences uses the selected catch-up policy. An occurrence due exactly at the destination time is processed as on schedule.
5. The default catch-up policy coalesces missed occurrences into one execution using the latest missed occurrence's identity. Skip mode marks missed occurrences handled without executing them. Bounded replay processes the earliest missed occurrences in chronological order up to the declared limit. Mark overflow skipped with a diagnostic. Process an occurrence due exactly at the destination separately from missed occurrences. Any supported unfinished action retains its committed progress under QUEST-009.
6. A visible running deadline shows the due date and time and a live countdown. At expiry show the applicable outcome or updated objective. A stopped deadline shows its paused status and retained duration. Internal timers can be hidden. Presentation reads clock state without advancing the clock or triggering effects.

## Formulas and parameters

- `due = start world time + resolved duration`.
- `remaining = max(0, due - current world time)` for a running clock.
- Travel-derived duration uses `duration = max(minimum allowance, route estimate × multiplier)`. Use consistent game-time units. The authored route, multiplier, allowance and applicable estimation policy are inputs. An unavailable required estimate uses explicit generation or clock-start failure.
- A resumed unfinished clock uses `due = resume world time + retained remaining duration`. Time spent stopped is excluded. Exact units, rounding and imported compatibility mappings remain integration decisions.

## Required data, inputs, outputs and events

Inputs include quest, clock and run IDs, committed world-time transition, start mode and time, fixed or random duration or travel parameters, visibility, and expiry branch. Recurrence additionally needs schedule, catch-up policy, replay limit where applicable and processed occurrence state. Outputs include clock state, one committed expiry, current window eligibility, scheduled occurrences or a classified failure. QUEST-009 consumes these outcomes through task triggers and owner operations.

## Cross-system interactions

TIME supplies committed game time, calendar transitions and travel estimates. CORE-012 keeps immediate opening presentation separate from future time advancement. CORE-019, travel and jail owners coordinate applicable time-advance boundaries. QUEST-008 supplies activation time, QUEST-009 owns trigger execution and effects, QUEST-011 owns terminal consequences, and QUEST-018 and UI present deadlines and objective changes. RULE-003 owns retained draws. QUEST-022 and SAVE coordinate restoration.

## Edge cases and failure conditions

- Travel, rest or jail crosses one or several deadlines. Reconcile due expiry before stale interaction can commit. Coordinate interruptible time-advance boundaries with TIME and the initiating owner.
- A jump ends after a daily contact window. The contact is unavailable even if a separate recurring event has a catch-up execution.
- The player reaches hand-in at the exact deadline. The on-time branch is closed. An authored late branch can remain available. Previously committed completion stands.
- Repeated time notification, redraw, or restore cannot recommit expiry or repeat already processed recurrence. An invalid backwards transition uses TIME recovery without restoring spent duration.
- Missing route context or an invalid duration fails explicitly. A presentation failure does not alter the deadline.

## Configuration and balancing

Authors configure duration mode, start and stop rules, route, multiplier, minimum allowance, expiry branch, visibility, recurrence and catch-up limit. Deadline ranges and route allowances are quest balance inputs. A reduced reward or alternate objective after expiry is authored content.

## Save/load considerations

Persist clock run identity, running or stopped state, the resolved duration and due time or retained remaining duration, expiry outcome, and recurrence progress or supported pending work. Restore coherently against saved world time. Loading does not add wall time, reroll duration, recalculate travel allowance or replay a committed expiry. Reconcile supported pending work before consequential interaction resumes.

## Technical constraints

Target Godot 4.7.2. Use authoritative world-time boundaries and stable clock and occurrence identities. Catch up through due boundaries with bounded work instead of iterating each missed second. Keep timer state, authored consequences and journal presentation distinct.

## Acceptance criteria

1. Travel, rest and jail advance running clocks. Paused or offline time and time spent with a clock stopped do not advance it.
2. Reaching or crossing the exact deadline processes expiry once before another on-time hand-in can commit. An authored late branch remains usable, and a quest configured for terminal failure can fail.
3. A skipped availability window is evaluated at destination time. Recurrence tests cover coalescing, skipping, bounded replay, overflow and a scheduled occurrence exactly at the destination.
4. A travel-derived deadline uses its resolved estimate and allowance across route changes and reload. Visible deadlines show the due time and countdown. Hidden timers stay out of the journal.
5. Save/load preserves unfinished clocks and processed occurrences without rerolls, duplicate effects or restoration of expired on-time eligibility.

## Compatibility review and outstanding questions

The specification follows QUEST-008 activation time, QUEST-009 run and effect retention, RULE-003 retained randomness, and CORE-012 and CORE-019 time boundaries. TIME integration for simultaneous expiry and recurring triggers, ordering of deadlines against travel or rest side effects, native window syntax, classic timer mapping and save schemas remain open.
