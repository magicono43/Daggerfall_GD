# Calendar and clock — IMP-014 increment 1

TIME's `calendar_clock.gd`, composed as `SessionLifecycle.calendar`, is the only
native calendar writer. `calendar.gd` supplies pure checked integer conversion.
Numeric structure is fixed: year zero/month one/day one midnight, twelve 30-day
months, 24-hour days, signed-64-bit nonnegative whole game milliseconds.
The supported timestamp range is 0 through 9,223,372,036,854,775,807 inclusive;
the last year is partial. Encoding checks the year product before adding the
within-year offset. Decoding uses integer quotients/remainders, never floating
timestamps. Runtime numeric inputs exclude booleans and floats. Day of year is
1..360. Localized month/day/season labels and eras cannot change numeric time.

## DATA and provenance

`time.calendar:policy/world` (`calendar-clock-v1`) joins normal application
registration, shipped → enabled MOD → captured loose resolution, field/provider
provenance, candidate validation, actual menu commitment and run-long locking.
Only this policy resource/record is supported. Fixed structure/epoch are absent
from its override schema. JSON integral date/anchor/season fields normalize to
runtime integers only after validation. The opening, weekday rule/explicit
anchor, distinct four season day-of-year boundaries, and rate are replaceable.

Base opening: year 405/month 1/day 4 at 13:30:00.000, native
12,597,427,800,000 ms, classic minute 523530. Both captured interior/exterior
start choices share initialization. Month-start weekday index zero is Sundas;
the default resets each month. Continuous mode explicitly declares absolute
`anchor_day` (epoch day zero) and its weekday `index` 0..6. Season queries select
the most recent boundary around the 360-day ring; arbitrary distinct boundaries
and year wrap work without ordering assumptions.

The shipped policy records approved TIME decisions and pinned DFU static
reference provenance. Constants/behavior are project-authorized; no original
executable parity is claimed and no reference file was changed. The integer
implementation is project-authored; no DFU source was copied. The existing DFU
MIT notice is in `../rule/DFU_LICENSE.txt`. No new library/toolchain is added.
Existing text catalogs do not expose a composed calendar-label presentation
owner; the review therefore labels numeric fields explicitly. Holiday tables,
notices, clan assignment, weather, lighting and rental owners remain downstream.

Malformed candidates use DATA's existing recovery: no partial publication,
explicit correction/omission/rebuild before menu, and restart to change captured
loose intake. A locked publication cannot be rebuilt or live replaced. TIME
retains a small validated policy per initialized session, not a catalog copy or
per-frame content preparation.

## Precision and ordinary accounting

Calendar rate supports 0.000001..1,000,000 inclusive at six decimal places.
It is stored as integer millionths (`rate_units`); default 12,000,000 means 12×.
Unsupported precision/ranges fail explicitly. There is no player rate setting.

CORE's integer `calendar_interval(actual_source, eligible_ns)` accepts accounted
eligible simulation nanoseconds **after** CORE intended simulation rate.
`advance_calendar_frame(actual_source, seconds)` is the stock physics boundary:
it validates real frame duration and intended rate, applies intended rate once,
and quantizes once to the nearest eligible nanosecond. Positive inputs below
half a nanosecond reject explicitly. Equivalence is exact for the same accounted
integer nanosecond duration; arbitrary floating frame partitions can differ by
their disclosed nanosecond quantization. This is elapsed-input precision, never
a floating representation of the calendar epoch.

TIME multiplies nanoseconds by rate millionths and divides by 10^12 to obtain
whole game milliseconds. The retained integer fraction is 0..10^12−1 units of
10^−12 game milliseconds. Small intervals accumulate without rounding away
progress. Checked quotient/remainder decomposition handles products that exceed
int64 without constructing that product. Timestamp and fraction remain separate,
so a full-range epoch is never multiplied into a microsecond counter.

The actual startup-shell physics handler delivers input, accounts the calendar
once through CORE, then calls the existing MOVE coordinator. A required calendar
failure reaches CORE recovery before physical work; an in-flight clock operation
cannot reenter the physical handler. Ordinary pause remains a normal suspension.
The old asset-independent session UI fixture deliberately replaces DATA with a
non-DATA provider and leaves this unavailable calendar dependency explicit; it
does not qualify real TIME. The calendar selection uses actual publication.
TIME never feeds
movement, combat, AV/UI pacing or slow-consumer cadence. MOVE/CHAR's accepted
controlled interval proofs remain independent game/simulation-microsecond
activity accounting. They neither advance this calendar nor constitute native
timestamp or real TIME/CHAR scheduler qualification. The maintained ground
regression runs all accepted movement checks with `calendar-rate-3` as well.

CORE captures exact interval intent, session, source generation, unique interval
and eligibility generation. Changed payloads, superseded uncommitted tickets,
obsolete scope/source, malformed elapsed values, reentrancy and overflowing
endpoints fail without commitment. Valid committed retries return retained
results. Gate changes invalidate uncommitted captures. Pauses, nested holds,
focus loss, startup, initialization and load add no ordinary duration. Resume
uses the next eligible interval with the pre-pause fraction; no wall gap enters.

Ordinary receipts retain six packed int64 values rather than per-frame request/result Dictionary copies. Results reconstruct exactly on retry. Receipts are retained for current-session retry guarantees and discarded on
retirement. Their count/memory cost is measured at 10,000 accounted frames;
unbounded-duration/session receipt compaction is not qualified here. A recreated
ordinary source receives a new generation and cannot reuse the old source's
captured intervals. Optional observers can disconnect/recreate without replay.

## Explicit segments and future scheduler

Ready services declare `calendar_activity:<stable id>` with an actual current
provider implementing `calendar_activity_current(detached_request)->bool`.
CORE binds these only at the initializing/readiness boundary. An explicit request
is exactly `{session,owner,operation,reason,duration_ms}`; duration is a positive
whole game-millisecond integer. Trusted provider authorization is checked under
exclusive clock admission, followed by strict boolean-result and scope/gate/unchanged-intent revalidation. The shared scoped callback-error monitor detects reported engine errors; the existing release-VM limitations in RULE still apply.
Another owner or reentrant operation gets busy during admission/commitment.

Each supported request is one atomic chronological segment with no enabled
required due work. It commits once, returns requested/actual duration and scoped
old/new instants, and retains its result. An owner submits later segments only
after its own independent reconciliation. Explicit duration ignores ordinary
rate and preserves the fraction. Only the declared activity's own simulation
hold may be excluded: providers acquire/release `activity_hold_owner(id)`
(`time-activity:<id>`) under the current session. That reserved namespace cannot
alias CORE focus, shutdown, operations or UI windows, even when an activity ID
is `focus`. The exclusion also requires that hold to belong to the current
session; an application-scoped hold is never treated as that activity hold.
Focus, load or unrelated holds still block it. TIME
releases no holds and never enables ordinary simulation.

`calendar_due_work:true` in any enabled service inhibits ordinary and explicit
advance with `kind:deferred`, `scheduler_ready:false`, and no commitment; it also
prevents a settled snapshot claim. Current supported fixtures declare no required
due work. An undeclared real owner is not qualified by omission. Increment 2 must
replace this admission gate with chronological scheduling/reconciliation before
such owners are enabled. A/B/C ordering, work budgets, interruptions within a
segment, boundary delivery and bulk processing are deliberately absent. Segment
completion certifies only the admitted no-required-work profile, not world
settlement, real rest/travel/prison or MAGIC/QUEST policies.

Committed notifications carry read-only detached scope/operation, reason,
old/new timestamps and actual elapsed milliseconds. Fraction-only updates retain
their result but emit no fabricated whole-time transition. Observers perform no
required work; reentrancy cannot create another time commitment. Queries, policy
resolution, initialization and restoration consume no gameplay RNG.

## Initialization and owner snapshots

Clock preflight validates complete compatible load payloads before replacement;
failure preserves the live session. CORE initializes TIME during the gated
baseline **before** dependent entry providers, exposing the exact origin via
`query()`. New characters use the resolved opening and zero fraction. Load uses
the recorded timestamp/fraction and emits no advancement or crossing.

`capture_snapshot()` requires the current safe, settled, gated session, no
session operation, no save blocker and no required due work. The seven-field
`calendar-clock-state-v1` payload contains schema, exact integer timestamp and
fraction, fraction scale, canonical semantic compatibility hash, rate units and
settled flag. Missing/extra fields, booleans, incompatible semantics and
in-progress state reject before publication. This Dictionary is an owner payload;
encode integers losslessly (the fixture can use Godot binary values), not through
floating timestamp JSON conversions. Native SAVE coordination is not delivered.

Compatibility pins fixed numeric semantics plus canonical weekday/season rules.
A start-only or rate-only override remains compatible: restored time/fraction and
existing absolute deadlines remain unchanged; future ordinary time uses the
resolved current rate. Changed weekday/season semantics require a future
validated DATA/SAVE migration instead of a silent reinterpretation. No pending
activity/segment/receipt is persisted; only settled boundaries are supported.
Cross-session native SAVE, durable owner-operation reconciliation, real physical
placement and milestone acceptance remain their existing joint gates.

Pure classic conversion uses E=12,566,016,000,000 ms and unsigned minute
0..4,294,967,295. The last representable minute ends at
270,264,053,759,999 ms; the first invalid minute starts one millisecond later.
Export discards only sub-minute precision. This is reference conversion, not
classic/DFU save import.

## Verification and review

DEV-014 selects `-Suite calendar-clock -Fixture calendar-clock-v1 -ClassicSource
C:/Games/Daggerfall/arena2` independently in headless/rendered modes. The versioned
`tests/calendar_inventory.json` must match complete unique check identities.
Windows exports select `-CalendarClock`. The complete stock adapter composition
is used for the primary application; additional isolated real DATA/MOD apps
qualify overrides/recovery. Entry and activity authorization are controlled,
explicitly separate from real TIME, CORE and DATA implementation.

`tools/review_calendar.ps1` rebuilds through the maintained rendered runner and
opens a review-only overlay in the real shell. Its controlled activity label and
numeric display cannot be mistaken for full gameplay/SAVE qualification. Human
checks and acceptance remain separate from automated smoke success.
