# TIME-003 — Calendar boundary events

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-15 with “I approve”. See TIME-003-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Make scheduled calendar changes reliable across ordinary play and explicit time advances. After rest or travel, the player sees lighting and date information appropriate to the time and place of arrival. Scheduled gameplay rules can account for relevant crossings during the advance according to their approved policies.

## Confirmed requirements

[TIME-003-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm start-exclusive, end-inclusive crossing detection, a single record for coincident markers, and presentation derived from the destination state after jumps and loads.

## Daggerfall Unity reference

In the local DFU 1.1.1 Release snapshot, `Assets/Scripts/Internal/WorldTime.cs#RaiseEvents` compares sampled hour, day, month and year fields and raises matching change callbacks. Named-hour callbacks require the sampled destination hour to match the configured hour and differ from the prior sampled hour. A jump from 05:30 to 07:30 therefore skips the dawn callback. `Assets/Scripts/Utility/DaggerfallDateTime.cs` defines dawn at 06:00, dusk at 18:00, midday at 12:00, midnight at 00:00, city lights off at 08:00 and on at 17:00. These are reference values. Daylight and city-light behavior is governed by its feature owner. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Detailed rules and parameters

- For a committed forward interval from `a` to `b`, a crossing exists exactly when `a < t ≤ b`, where `t` is the boundary timestamp in native game milliseconds. A zero-length interval has no crossings. A reversed interval is invalid for advance processing. A proposed destination beyond an interrupted advance creates no crossings in the uncommitted portion.
- Structural markers are new hour, new day, new month and new year. Under TIME-001, a game hour is `3,600,000` ms, a day is `86,400,000` ms, a month is `30 × day`, and a year is `360 × day`. For interval `I` aligned to the native epoch, crossing count is `floor(b / I) − floor(a / I)`. The next crossing after `a` is at the next multiple of `I` if representable.
- Named markers include midnight, midday, dawn, dusk and city-light transitions. Midnight is the start of a calendar day and midday is 12:00. Daylight and city-light owners supply the applicable resolved schedule and context. Where a marker depends on location or another owner context, use the context defined for that crossing or segment. An arrival context alone cannot establish what happened at prior locations.
- Group coincident markers into one record at `t`. Year rollover at midnight can carry midnight, new hour, new day, new month and new year. A consumer selecting multiple markers receives the record once for that timestamp and can read all matched markers. Different owner rules can independently act on the same record. Marker order carries no gameplay priority.
- Provide requested crossings in chronological order. Support filtering, next-crossing lookup or counting where equivalent so long advances need not materialize one record per crossed hour. Required gameplay work follows TIME-004 and the relevant owner rules. A query can identify the next required boundary for planning a TIME-002 segment. Planning alone produces no committed notifications or gameplay effects.

## Data, inputs, outputs and events

Inputs are the TIME-001 calendar, committed TIME-002 endpoints and reason, relevant operation/segment identity, selected marker types, and validated schedule/context for applicable named markers. Outputs are timestamped records with a set of marker types and their applicable context, a crossing count or next timestamp where supported, and an explicit validation failure for invalid input. Use the native timestamp for comparison and localized calendar data for display. Keep emitted records associated with their committed session and segment so stale notifications cannot affect a replacement session.

## Cross-system interactions

- TIME-001 owns calendar math. TIME-002 owns commitment, interruption and actual elapsed time. TIME-004 owns gameplay dispatch order, catch-up policy coordination and required consequence handling. QUEST-010 retains exact expiry and recurrence semantics. MAGIC-008 retains chronological effect timing and interruption rules.
- UI and AV refresh from current committed date/time and applicable world/location context. At the end of a jump or after restore, derive the visible state directly from the destination. If context is still loading, refresh when its owner supplies it before presenting the ready destination. Ordinary play may animate transitions through AV. A visual refresh never triggers historical gameplay effects.
- Configuration of named daylight and city-light schedules is owned by the relevant feature. Structural hour, day, month and year intervals follow the fixed TIME-001 calendar. Any supported mod schedule contributions use validated resolved definitions. Public event APIs and mod callback mechanisms remain implementation decisions.

## Edge cases, save/load and technical constraints

- Reject invalid endpoints and guard calculations near the supported timestamp limit. A boundary exactly at the starting instant is excluded even when adjacent advances share that endpoint. Mid-month, month-end and year-end queries use the same rule. Named markers can coincide with each other or with structural markers.
- Derive crossings from committed time and the applicable schedule. Native restore refreshes current presentation without enumerating the interval from a prior session or firing events at a saved instant on a boundary. Pending gameplay work for a resumable advance follows the TIME-002/004 and SAVE contracts. Supported resume must distinguish already settled consequences from work still due.
- Avoid unbounded work for a long jump. Preserve complete crossing semantics for owners that need them, with equivalent queries or bounded processing where applicable. Consumer ordering, retry durability and failure recovery for gameplay effects are TIME-004/SAVE dependencies.

## Acceptance criteria

1. An advance from 05:30 to 07:30 under the DFU reference schedule reports 06:00 dawn once. An advance ending at 06:00 includes it. A subsequent advance starting at 06:00 excludes it.
2. A 24-hour jump ending at the same hour accounts for 24 hourly crossings and one day crossing. A long prison interval can count structural boundaries without broadcasting each occurrence to presentation observers.
3. Crossing into a new year at midnight yields one record containing midnight, new hour, new day, new month and new year. A consumer selecting both new day and new year sees one record at that timestamp.
4. After an interruption, no boundary beyond the committed endpoint is delivered as crossed. A zero-length advance yields no crossings and a reversed query fails explicitly.
5. Fast travel across multiple named transitions refreshes destination presentation using destination time and context. Loading a save exactly at midnight presents the saved date without replaying midnight gameplay effects.

## Consistency review and outstanding questions

The specification follows approved TIME-001 calendar units, TIME-002 commitment and restore rules, QUEST-010 endpoint semantics and MAGIC-008 chronological processing. It preserves owner-specific selection of replay, coalescing and skipping. Open integration details include schedule context for route segments and local transitions, ordered dispatch and recovery in TIME-004, and the supported native resume boundary.
