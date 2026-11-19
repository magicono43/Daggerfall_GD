# TIME-001 — Calendar and classic time conversion

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-15 with “I approve”. See TIME-001-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Give the world a consistent date and time that players can use to plan around deadlines, holidays and services. The base game opens on the classic date. Localized dates, season labels and weekday names agree wherever the player sees them. Native loading resumes at the same in-world instant.

## Confirmed requirements

TIME-001-D01 through D05 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm the classic start, month-based base seasons, monthly weekday reset, mod overrides for those three settings, fixed calendar units, exact native millisecond persistence and checked classic minute conversion.

## Daggerfall Unity reference

Local DFU 1.1.1 Release snapshot, static inspection. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits. Source paths below are relative to `Assets/Scripts/`.

- `Utility/DaggerfallDateTime.cs` uses `RaiseTime` to carry fractional seconds through larger units. `GetDayName` uses the zero-based day of the month modulo seven. `GetSeasonValue` groups months into four seasons.
- `SetClassicGameStartTime` decodes `523530` classic minutes. `Game/Utility/StartGameBehaviour.cs` applies it for new characters. `ToSeconds` discards fractional seconds, and `Game/Serialization/SaveLoadManager.cs#RestoreDateTimeData` restores whole seconds.
- `ToClassicDaggerfallTime` and `FromClassicDaggerfallTime` use an offset of `12,566,016,000` seconds from year zero. The source decode multiplies the `uint` minute value by 60 before adding the wide offset. The approved conversion uses checked wide arithmetic throughout so high minute values decode correctly.

## Calendar rules and parameters

- Use nonnegative integer game milliseconds from year 0, month 1, day 1 at 00:00:00.000. Calendar dates expose months 1–12, days 1–30, hours 0–23, minutes and seconds 0–59, and milliseconds 0–999. Day of year is `30 × (month − 1) + day` and ranges from 1 to 360. Each day has `86,400,000` ms.
- Encode a valid date as `((360 × year + 30 × (month − 1) + day − 1) × 86,400,000) + hour × 3,600,000 + minute × 60,000 + second × 1,000 + millisecond`. Decode by integer quotient and remainder. Use checked signed 64-bit storage and arithmetic. Localized names and era labels are presentation data.
- Initialize both standard start paths at **13:30:00.000 on 4 Morning Star, 3E 405** after resolving any active start override. Initialize dependent elapsed-time tracking at that instant.
- The default weekday index is `(day − 1) mod 7`, with Sundas at index zero. At the end of each month, the next date returns to Sundas. Provide a configurable continuous-cycle alternative with an explicit weekday anchor. Schedules that need continuous seven-day recurrence can use elapsed time or the continuous weekday rule when that rule is active.
- Base season starts are month 12 day 1 for winter, month 3 day 1 for spring, month 6 day 1 for summer, and month 9 day 1 for fall. Each season begins at midnight and runs until the next declared start, wrapping across year end. Mods can supply distinct valid day-of-year starts for the four seasons. Calendar structure and timestamp epoch are fixed.

## Classic conversion

Let `E = 12,566,016,000,000` native milliseconds, corresponding to year 404, month 1, day 1 at midnight. Decode an unsigned 32-bit classic minute value `m` as `E + 60,000 × m`. Encode a native instant `t` as `floor((t − E) / 60,000)` after checking that `t ≥ E` and the result fits the classic range `0…4,294,967,295`. The final representable minute includes its full sub-minute interval. Decoding an encoded instant returns the start of that minute. Conversion is a pure query for reference values and fixtures. Classic and DFU save import stay outside current scope under CORE-013.

## Required data, configuration, inputs and outputs

- Required data include the native timestamp, base start date, resolved start override if present, weekday rule and any anchor, four season start dates and localized calendar labels. DATA-003 controls validation, contribution precedence, provenance and locking of resolved definitions.
- Inputs are a candidate date, native timestamp, classic minute value, or resolved calendar definition. Outputs are a validated timestamp, derived calendar fields and context, a classic minute value, or an explicit validation/range failure. Reading or converting a date has no clock side effects. Initialization and restoration establish an instant. Advance notifications and boundary processing belong to TIME-002–004.

## Interactions and native save/load

- [CORE-011](../CORE/CORE-011.md) consumes the initial time and aligns player tracking. [CORE-012](../CORE/CORE-012.md) keeps immediate startup presentation from advancing it. [CORE-013](../CORE/CORE-013.md) governs native load preflight and publication.
- [RULE-028](../RULE/RULE-028.md) uses valid days 1–360 for region-aware holidays. [RULE-024](../RULE/RULE-024.md) counts consecutive calendar-day slots for rentals. [QUEST-010](../QUEST/QUEST-010.md) consumes committed instants for exact deadlines. [LAW-015](../LAW/LAW-015.md) retains its approved owner-specific rules for elapsed prison time. Season consumers read resolved season context. Daylight, lunar rules, weather and clock pacing remain with their respective feature owners.
- Persist and restore the exact native millisecond timestamp. Derive display fields from the restored timestamp and compatible resolved definitions. A changed start override applies to new characters. Restore has zero elapsed time and produces no time-advance boundary effects. If a changed calendar definition affects existing save semantics, use the validated compatibility or migration path owned by SAVE and DATA. Keep already committed absolute deadlines and accepted terms consistent with their owner specifications.

## Edge cases and technical constraints

Reject invalid date fields, duplicate season boundaries, a missing required weekday anchor, negative native instants and arithmetic overflow through explicit failures. Reject invalid calendar contributions through DATA-003. Midnight after day 30 rolls to the first of the next month, and midnight after month 12 rolls to day 1 of the next year. The monthly weekday reset may repeat or skip named weekdays around rollover relative to a continuous cycle. A schedule anchored to an absolute deadline uses the exact timestamp even when a display rounds to a coarser unit. TIME-002 owns accumulation of advance requests below one native millisecond so repeated small advances can be handled consistently.

## Acceptance criteria

1. Both standard start paths yield the base opening instant, equivalent to classic minute `523530`. A valid start override changes the new-game instant. Existing native saves restore their recorded instant after a start-only override.
2. One millisecond past the last instant of a month or year reaches the first instant of the next month or year. Day-of-year values 356–360 resolve as valid dates. Invalid dates and overflowing encodes fail explicitly.
3. Every base month begins on Sundas. The continuous override advances one weekday across the same month and year boundaries. Base and overridden seasons change at midnight on their declared dates, including schedules that wrap year end.
4. Classic minute zero maps to the classic epoch. The maximum unsigned 32-bit value round-trips. Instants before the classic epoch or at the first minute beyond the maximum fail on export. Export/reimport within range drops only the sub-minute portion.
5. A native time ending in a nonzero millisecond restores exactly. Restore and presentation queries deliver no elapsed-time effects. A quest deadline can compare the exact committed timestamp across midnight.

## Consistency review and open dependencies

The specification matches the approved startup, native-save, holiday, rental, quest deadline and prison timing rules linked above. The TIME-AR-01 and GAD-05 proposals cover ownership of advances and dispatch ordering beyond this calendar contract. Remaining integration details are the DATA schema and compatibility metadata, SAVE migration policy for changed calendar definitions, localization assets and supported mod schedule consumers.
