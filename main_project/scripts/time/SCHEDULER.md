# Chronological due work — IMP-014 increment 2

The [increment-3 range policy extension](ACTIVITY_POLICIES.md) qualifies explicit
controlled activity policies alongside this accepted chronological fallback.
Statements below excluding bulk/holidays describe increment 2's delivered scope.

`calendar_clock.gd` remains the sole timestamp/fraction writer. Its `due_work.gd`
helper retains one in-memory operation through bounded passes. CORE owns all
gates. Owners retain domain mutations, indexed timing and assigned outcomes.
This is controlled scheduler qualification, not real QUEST/MAGIC/rest/travel/
prison policies, equivalent bulk activity processing, holidays or native SAVE.

## Admission and lifetime

The existing bound CORE ordinary source and authorized calendar activities are
the only requesters. `SessionLifecycle.advance_calendar_request(actual_owner,
request)` exposes the activity path. The five-field increment-1 duration request
remains supported. A seven-field request adds `start` and `endpoint`; both must
be nonnegative native int64 values, endpoint must exceed start, their difference
must equal duration, and a new request's start must equal the current timestamp.
Runtime bools/floats do not qualify as integers. Activity authorization still
uses the actual current session provider, monitored callback and captured intent.

Admission retains session, actual requester, immutable request identity/reason,
original start, requested target/duration, calculated final fraction and current
committed endpoint. Competing requests return busy; none is queued. Repeated
requests return retained progress/results. Changed intent under an identity
rejects. Each continuation ticket is exactly `{session,operation,pass}` with
integer identities. The actual initiating owner or bound CORE ordinary producer
may continue it. Duplicate passes return their original result, including after
completion. Retirement clears operations, receipts, declarations and callbacks;
old tickets cannot affect a replacement session. The DATA Object identity and
constant-cost publication ticket are pinned with the session policy.

Normal ordinary retries retain their six packed int64 facts. Scheduler ordinary
terminals add eight packed numeric metadata facts to reconstruct the richer
outcome, rather than deep per-frame request/result Dictionary histories. Actual
multi-pass operations retain pass receipts for current-session duplicate-delivery
guarantees. No durable receipt compaction or long-session SAVE promise is made.

## Owner declarations and checked calls

A ready session service with `calendar_due_work:true` supplies an actual provider
and exactly `calendar_schedule:{id,version,after,interacts}`. IDs use the existing
stable handle validator; version is a positive int64; dependency/interaction
arrays contain unique other declared IDs. A string alone has no authority.
Bindings are fixed at CORE's initializing boundary. Missing bindings, cycles and
interacting owners without transitive declared precedence reject activation.
The validated topological order uses lexical owner IDs for independent ties.
Transitive precedence is cached once for that declaration revision. There is no
live declaration replacement; change requires a new session composition.

Providers implement:

* `calendar_schedule_current(session,version)->bool`: pure exact-scope and
  declaration freshness check.
* `calendar_next_due(packet)->Dictionary`: pure indexed next lookup. Packet
  contains session/operation, original start, requested endpoint, committed
  endpoint, reason, interruption flag and that owner's acknowledged cursor.
  Return `{kind:"none"}` or exactly
  `{kind:"due",timestamp,occurrence,revision}`. Occurrence is a nonempty bounded
  stable string, revision a nonnegative integer. Return the earliest applicable
  instant strictly after original start and at or before requested endpoint,
  never before the committed endpoint or already acknowledged cursor. Owner
  indexes handle cancellation/new rules and must not charge pre-creation time.
* `calendar_due_current(packet)->{kind:"current",revision}`: pure occurrence
  freshness check before committing its timestamp. Dispatch includes owner,
  stable occurrence, due timestamp and expected revision.
* `calendar_apply_due(packet)`: validates the expected scope/operation/occurrence/
  revision again at mutation intake, retains its assigned result and returns
  `{kind:"completed"|"interrupted",session,operation,owner,timestamp,occurrence,revision}`.
  TIME checks every echoed receipt identity and numeric type. Owners own changes and
  any RNG. An invalid/failed/ambiguous result is never assumed non-mutating.
* `calendar_due_outcome(original_dispatch)`: recovery-only pure reconciliation
  lookup. Return the exact retained completed/interrupted outcome, or matching
  `{kind:"not-applied",session,operation,owner,timestamp,occurrence,revision,retry_authorized:true}` only after
  establishing that retry cannot duplicate a mutation. Unknown remains failed.

Callbacks use the existing scoped engine-error monitor, strict result checks
and detached packets. Silent within-domain errors that a release VM does not
report cannot be detected by this mechanism; the existing RULE limitations
remain. Diagnostics never invoke a mutator to inspect its result.

## Chronology, budgets and recovery

The default processing budget is **64 work units per pass**, configurable to a
positive integer up to 1,000,000; the fixture uses one. One unit performs either
one owner next-index query, one selected dispatch (bounded owner selection,
freshness check, at most one mutator/ack), one reconciliation lookup, or final
endpoint handoff. Every unit is bounded by the fixed declaration count and the
owner's bounded indexed-call contract. Wall time and gameplay RNG do not order
or count work. Only one next projection per owner is retained, never all hours
or occurrences to a distant target. Pure structural next/count/filter queries
are O(1) in interval length in `calendar_crossings.gd`.

Scan the declared providers, choose earliest due time and stable dependency
order, then commit at most to that instant. After each mutation, discard stale
future projections and re-query owner indexes. No segment passes an unsettled
consequence. A newly returned same-instant predecessor of an already settled
dependent fails explicitly. Binding/dependency versions cannot change in flight.
Same-owner coincident occurrences are selected by its stable indexed cursor.
Already committed obligations use the retained original start/cursor, preserving
start-exclusive/end-inclusive semantics without losing unfinished work at start.

An interruption stops further chronology, re-plans with `interrupted:true` for
owner-approved post-interruption eligibility, and settles still-applicable work
at that instant. It returns actual = committed endpoint minus original start,
with no future occurrence applied. No real lethal/death owner is qualified here.

Before mutation, TIME records an uncertain dispatch. On failure it retains
earlier time/effects and the exact uncertain identity. Stock frames stop; explicit
`continue_pending(actual_owner,current_ticket)` invokes reconciliation before
any possible retry. Unknown outcomes keep the hold and failure. A matching
retained outcome acknowledges without invoking the mutator again. A checked
non-commit outcome permits one retry. Planning/declaration corruption that has
no mutation reconciliation path requires session replacement; it is not skipped
or silently repaired by a new provider.

## Fraction/backlog accounting and gates

CORE applies its intended rate and nanosecond quantization once before admission.
TIME applies calendar rate once, retaining original eligible ns and the exact
target/final fraction. Continuation never scales/re-admits that elapsed input.
Held frames contribute zero fresh duration; the final continuation frame also
contributes no physical delta. No wall-clock catch-up is introduced.

An ordinary chronological whole-ms boundary consumes the earlier fraction and
sets committed fraction to zero; the calculated final fraction stays in the
retained tail until completion. On failure/budget/pause the uncommitted tail is
retained. On interruption, `remaining_ms` and `target_fraction` explicitly report
the discarded tail; it is not silently requeued. An interruption before any
whole-time commitment leaves the initial fraction unchanged. Explicit durations
preserve ordinary fraction at every segment and ignore calendar rate. A
fraction-only ordinary update has no crossing or fabricated time transition.

TIME acquires the exact-session `time:settlement` hold on simulation/input/save
before processing. Continuation excludes only that hold and the initiating
activity's own exact-session reserved hold for new chronology. Pause/focus/load/
safety blockers still prevent a later timestamp. Already committed obligations
may finish while independently paused. Only a settled completed/interrupted
handoff releases TIME's hold. Budget/failure never transiently enables play.
Application-scoped same-named holds remain independent. Legacy two-argument
`SessionGates.blocked_except` behavior is unchanged.

The actual stock shell continues admitted work before checking ordinary
simulation eligibility. Pending/interrupted outcomes stop physical work without
fatal recovery. Genuine scheduler failures expose the retained reason and await
explicit reconciliation under TIME's hold; no automatic mutation replay occurs.
During a cancellable CORE preflight/session operation, the source waits without
calling the continuation or adding elapsed input. Cancellation resumes the
retained operation; replacement retires it. Busy CORE eligibility is not a fatal
calendar failure, and does not invalidate the outgoing session on cancellation.
Frame and retry handlers capture their original scope, so an owner-triggered
replacement cannot apply the old result/recovery message or physical delta to
the replacement session.
Ordinary no-scheduler failures retain the existing CORE required-service recovery.
For enabled scheduler profiles, accounting precedes consequential input and
physical gameplay never receives a partially reconciled frame. A composition
declaring real MOVE activity is rejected until the native TIME/MOVE/CHAR interval
bridge is qualified. The accepted controlled MOVE/CHAR microsecond providers,
movement/AV rates and independent slow cadence are unchanged.

## Queries, notification and restore boundary

Structural queries validate endpoints/filters, exclude start/include end and
return grouped coincident records once. A year rollover carries new hour,
midnight, new day/month/year. Named daylight/city-light context remains with
owners; no DFU reference lighting policy is installed. Queries mutate no time,
remainder, gate, owner or RNG.

Committed notifications contain actual chronological segments and `settled:false`
for scheduler progress. Query `settled` is false throughout an active operation.
The segment notification's operation is the session-unique scheduler serial as
a string; final request outcomes retain the caller's operation name and expose
that scheduler serial as integer `continuation.operation`. Correlate under the
session, rather than assuming caller operation names are unique across owners.
One read-only `settled` notification reports the terminal handoff; observer
failure/replacement cannot dispatch required work. Presentation uses committed
numeric context and must not advertise pending progress as ready world state.

The accepted seven-field `calendar-clock-state-v1` remains unchanged for the
no-required-work profile, including compatible start/rate overrides and zero-time
restore. All enabled scheduler profiles reject capture, and reject clock-only
restore during binding: no coherent owner-state capture/restore contract exists
yet. Clearing the old due-work boolean cannot qualify an in-progress snapshot.
No generic in-flight save reconstruction is provided.

## Verification

The accepted `calendar_inventory.json` is unchanged. The versioned additive
`scheduler_inventory.json` is required by DEV-014 and both Windows exports.
Controlled entry/owners are labelled. Review uses `tools/review_scheduler.ps1`;
automated smoke remains separate from human acceptance. Parent IMP-014, M2,
increment 3, real owners, physical interval integration and full SAVE remain open.
