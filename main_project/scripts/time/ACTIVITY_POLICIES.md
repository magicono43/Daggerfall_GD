# Activity policy qualification — IMP-014 increment 3

The accepted chronological scheduler remains the fallback. No real rest, travel,
prison, QUEST or MAGIC policy is installed by this increment. The controlled
affine owner proves the extension through `SessionLifecycle.advance_calendar_request`.
Its assigned increments contain no RNG. A different owner must qualify its own
random outcomes, observable effects, interruptions and eligibility; the affine
formula is not a generic gameplay or RNG optimization.

## Declarations and authority

An activity request may additionally contain `context`, a stable bounded ID
validated and captured with the original request. It identifies the activity
owner's explicit context, not a guessed geographical location. Its authorization
callback receives that exact context and reason. Existing five/seven-field
requests retain their behavior. Optional start/endpoint fields retain checked
native integer validation. Changed context is changed intent.

A bound schedule may add `activity_policy`, with exactly:

| Field | Contract |
| --- | --- |
| `mode` | `bulk`, `coalesced`, `skipped`, or `endpoint` |
| `proof` | Stable owner proof/contract identity; no authority by itself |
| `context`, `reasons` | Explicit applicable context and 1–64 distinct reasons |
| `first`, `period`, `count` | Native first instant, positive period, positive count; final recurrence must fit int64 |
| `revision` | Positive owner policy revision |
| `endpoint_effects` | Must be false in this qualified interface |
| `selection` | Mode-specific rule below |

The actual provider Object must implement the additional pure
`calendar_range_current(packet)`, mutating `calendar_apply_range(packet)` and pure
recovery `calendar_range_outcome(original_packet)` methods. The existing exact
session/declaration freshness callback also guards these calls. Range approval
must return exactly `{kind:"current",policy:original_policy}` with matching types.
For bulk only, `{kind:"chronological"}` declines equivalence and uses ordinary
chronology. A policy name or proof string cannot bypass the bound Object call.
Nonmatching activity context/reason always uses the chronological interface.

Fixed recurrence coverage is intentionally the qualified range format. Owners
with irregular, state-sensitive or random recurrence use chronological indexed
work until their distinct equivalence contract is established. Declaration changes
require a new session; domain state/eligibility changes still replan future work.

## Coverage, ordering and recovery

TIME computes native start-exclusive/end-inclusive coverage in O(1), including
first/last zero-based occurrence indices and count. No list, occurrence cap or
hidden occurrence loop is introduced. A zero-length pure coverage query returns
zero; invalid, reversed, bool/float or overflowing inputs fail. Arithmetic remains
integer and handles the final int64 instant without adding one beyond it.

Bulk selection is `all-equivalent`. It stops strictly before every other pending
chronological owner's next instant. At a coincident instant ordinary chronology
enforces declared dependency/stable ordering. After every mutation all future
projections are invalidated. Owner approval must decline a range containing an
unresolved internal eligibility/interruption opportunity; external dependencies
cannot be crossed by approval. An interrupted operation bounds ranges by its
actual committed endpoint. No physical interval or ordinary simulation is inferred.

Deferred policies run only after chronology establishes the actual completed or
interrupted destination, under TIME's existing settlement hold. They cannot
precede a chronological dependent or change the destination through this contract.
Deferred owners settle in the validated graph order. Their rules are:

* `coalesced` / `latest-missed-and-exact`: select the latest missed recurrence,
  then separately the exact destination recurrence when present (at most two).
* `skipped` / `exact-only`: suppress all missed occurrences permanently for the
  acknowledged range; select only an exact destination occurrence.
* `endpoint` / `destination-only`: acknowledge historical coverage without
  historical effects and refresh committed destination state once. No historical
  availability window counts as a visit. Named location/weather/light context
  remains with its owner.

The complete dispatch retains session, actual operation serial, requester ID,
original request context/reason/endpoints, owner, declaration/policy/content
revision, segment and exact coverage/selected identities. A `completed` receipt
must echo the entire packet with identical types. TIME records uncertainty before
mutating. Diagnostic/planning calls never invoke a mutator. Ambiguous outcomes
keep gates and require exact retained reconciliation. A matching `not-applied`
receipt with boolean `retry_authorized:true` permits retry of the **original**
packet, including its original segment; it does not allocate a replacement range.
Duplicate requests/passes retain accepted scheduler outcomes. Replacement retires
all current-session cursor/receipt state. No durable in-flight restore is offered.

One range approval plus at most one bounded owner mutator/ack constitutes a
scheduler work unit. Destination final handoff may share the last unit, just as
the existing no-due endpoint handoff does. Default budget remains 64; budget one
retains gates across passes. Existing independent pause/focus/loading, cancellable
CORE preflight, genuine recovery, source/retry scope safety and packed ordinary
receipt accounting remain unchanged. Range owners must implement bounded work;
the fixture's closed form performs no per-occurrence loop.

## Qualification and outstanding integrations

`tests/activity_policy_cases.gd` adds a separately versioned complete inventory to
the accepted calendar/scheduler inventories. It compares owner state, weighted
assigned effects, external observations, actual endpoint and exact fraction at
budgets one/64, split intervals, new same-instant rules and eligibility changes.
Internal interruption falls back to chronology. It exercises retained ambiguous
and noncommit recovery, holds/reentrancy/staleness/retirement, million-occurrence
and full-native-range processing, deferred exact/missed selection and no replay.

Real QUEST cutoff ordering (IMP-028), MAGIC (IMP-058), rest (IMP-039), travel
(IMP-059), prison (IMP-044), and native TIME/MOVE/CHAR partial-interval qualification
remain joint. Scheduler capture/clock-only restore still reject; supported
no-required-work restoration remains zero-effect. Parent IMP-014/M2 and human
acceptance are not closed by controlled proofs.
