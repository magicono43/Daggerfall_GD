# Activity and exhaustion — IMP-016 increment 3

`core.actors` remains the sole CHAR authority. `activity_owner.gd` is its
implementation helper: actor facts, clocks, receipts and episodes live in the
same actor record. It owns no physical pose, collider, global clock or second
session. MOVE placement is unchanged. The stock entry provider still lacks real
locomotion, TIME, threat, trait/condition, prevention/death and native SAVE
integrations. Controlled providers qualify the following interfaces only.

## Admission and data publication

`actors.activity_intake(owners, request)` accepts the exact twelve-field
`actor-activity-v1` request: schema, session, actor, caller, operation, content,
revision, kind, context, clock, providers, source. All identities use the bounded
handle grammar; runtime integers exclude booleans/floats. Source is exactly
{source,cause,component}. Kinds are segment, jump, climb-check, rappel-complete,
breath and exhaustion. Unknown fields, malformed clocks/context, stale scope,
content/revision, changed identity intent and exhausted retention fail closed.

CORE's existing readiness service declarations can include
`actor_activity:{id,roles}`. Role/domain qualification is motion/MOVE,
interval+time/TIME, traits/CHAR or MAGIC, threat/NPC or COMBAT, recovery/CHAR or
MAGIC, resolution+lethal/CHAR. Actual provider Objects are weakly bound to the
current session; string labels alone grant no authority. Each supplied role has
exactly {id,revision} and its actual Object in `owners`. The trusted synchronous
`activity_current(detached_request)->bool` attests freshness, actual committed
intent and source context. VM errors, stale/retired/reentrant callbacks and
missing required methods are failures, not guessed context. Reentrant CHAR
mutation is rejected. Required event effects that need CHAR mutation must settle
between continuation requests, rather than reenter a synchronous CHAR callback.

The existing actor-baseline DATA adapter publishes required typed resources
`policy`, `activity` and `recovery`. Shipped -> checked MOD -> captured loose
precedence, provenance and actual menu locking remain in force. Definitions
accept integral JSON numbers; only after validation are they converted to runtime
integers. Activity rates/priority, Athleticism ratios, jump cost, practice cap,
Running cadence, recovery coefficients, breath recovery and supported outcome
selection are replaceable. Recovery outcomes are `safe-hour` or `lethal` for
safe/swimming/threat contexts (swimming takes precedence over threat). Default
selection remains safe-hour/lethal/lethal. Unsupported executable outcomes or
non-hour recovery durations reject rather than invent proportional treatment.

Published rates fit 0..1,000,000, jump cost and practice cap 0..1,000,000,000,
Athleticism numerators 0..1000 and denominators 1..1000. Per-activity practice
amounts are 0..1000 and Running cadence is 1..1,000,000,000 simulated microseconds.
Recovery terms fit 0..1,000,000; divisors are 1..1,000,000,000; minimum/Medical
amounts fit 0..1,000,000,000. Breath recovery is 1..1,000,000 reserve units/second
with a 0..1,000,000,000 simulated-microsecond delay. Checked intermediate/output
bounds can still reject an incompatible selected formula or duration combination
without publication of an actor mutation.

Focused pure hooks `char.activity-rate`, `char.recovery-health` and
`char.recovery-pool` use `activity-formula-v1` through the existing RULE registry.
They are declared before preparation, have strict hook-specific input envelopes,
checked wide integer intermediates and bounded results. The selected provider
must succeed; there is no fallback, expression engine, second registry or loader.
The accepted actor-rational hooks retain their original contract.

## Ordinary activity and clocks

Non-exhaustion context is exactly {motion,argonian,event,success,breath}. Motion
has the eight strict booleans documented in `activity_math.gd`. `argonian` means
checked effective inherited/suppressed eligibility from the trait owner, never a
display-name comparison. Breath is {holding,breathable}; these cannot both be true.
Event identities belong to actual qualifying MOVE operations. Held Run, requested
gait and displacement alone cannot certify voluntary collision-limited movement.

Clock is exactly {domain,interval,start_game,end_game,start_sim,end_sim,game_unit,
simulation_unit,numerator,denominator,ownership}. Domain is eligible-activity;
units are game-microsecond and simulated-microsecond. Interval equals operation.
One bound interval caller owns the actor's ordered cursor. Starts must exactly
match retained ends in both domains; overlaps, gaps and competing owners reject.
Ordinary duration mapping is checked as game_delta*denominator ==
simulation_delta*numerator. The trusted TIME producer attests that mapping and
eligible duration; the nominal ordinary mapping is 12/1 under TIME-002. CHAR
never measures UI/wall time. Instants fit 0..9e15; each ordinary segment duration
fits 0..1e9 microseconds and ratios 1..1e6. Producers retain and partition longer
committed progress under stable identities. Legacy millisecond baselines beyond
the compatible microsecond domain require explicit migration.

The interval owner retains the performed segment's eligibility proof. CHAR can
settle already-incurred debt under a subsequently acquired pause or producer
continuation hold; it does not replace that proof with the current simulation
gate. The TIME owner must reject new claimed elapsed time while held. This also
allows a required producer to keep its own scoped simulation/input/save hold
through resource settlement, releasing only its own hold after completion. Dead,
zero-fatigue and unresolved-exhaustion activity remains unavailable. Loading or
retiring a scope cannot turn an old interval into a new one.

Ownership is ordinary, rest, training, travel or paused. Excluded owned intervals
advance the corresponding cursor without ordinary fatigue/practice. Paused
intervals have zero duration. Discrete jump/check/breath reports have zero elapsed
clock duration and independently deduplicate the MOVE producer/kind/event tuple.
Interval retry cannot repeat time or practice. Saved baselines prevent wall-clock
catch-up after load.

Default periodic rates are ordinary 11, climbing 22, moving Running 88, selected
Swimming 11 or qualifying failure 44, in internal-64 fatigue units/game minute.
Priority is climbing, moving Running, swimming, ordinary. These replace rather
than stack on ordinary cost. Athleticism selects ratios 1, 9/10 or 8/10; Improved
alone remains 1. Resolve/truncate the rate before integration. One game minute is
60,000,000 game microseconds; its shared numerator remainder survives activity or
trait changes. Jump adds resolved base 11 once, using saturating CHAR drain.

Raw Running practice uses accumulated actual voluntary, nonriding Running time,
default 250,000 simulated microseconds per +1. Passive carriage and stationary Run
add none. Unspent cadence survives ineligible segments. Jump grants +1 once;
qualifying climbing checks grant +1 including failures. MOVE-012 establishes the
rappel boundary: +1 only for a successfully completed ledge-to-wall transition,
none for failed/cancelled positioning or guaranteed grip callbacks. A depletion
inside a segment limits practice to its performed pre-depletion prefix. Subsequent
ordinary activity is gated; draining never overdrafts or makes an unpaid jump free.

Selected Swimming retains a check at the start of each eligible swimming minute,
carrying its minute remainder across frame/activity splitting. It uses bounded
live skill 0..100 and the existing progression stream and percentile mapper.
Endpoints still consume the mapper's declared draw: 0 fails and 100 succeeds.
Checks retain tick, chance, roll and result. Argonian eligibility removes only the
higher failure rate. Completed qualifying minutes grant +1 even on failure.
Queries, exact retries and reconstruction consume no draw. All external validation,
rate callbacks and capacity checks precede draws and local publication.

Practice saturates at the validated cap (default 20,000), retaining requested and
actual additions. A lower mod cap never erases earlier practice. No scaling,
permanent gains, consumption/reset, training or advancement checkpoint is added.

## Breath scheduling

The shared pure `breath_schedule.gd` handles entry and recovery. Fresh eligible
holding initializes reserve only through the activity owner. Swimming, holding
and breathable-space context are separate. Generic pool fill and collapse
recovery never touch breath. Default recovery is instant only in checked normal
breathing context. Supported gradual policy declares reserve units/second,
simulated-microsecond delay and retained millionth-unit remainder; reentry retains
reserve and cannot bypass the delay. Pause/load do not advance it or refill.

Positive-duration holding consumption and zero-reserve/zero-capacity entry are
explicitly unavailable: no approved consumption cadence, racial benefit, timer
conversion or drowning damage is invented. Legacy opaque initialized breath
policies require compatibility instead of silent reinterpretation. Maximum
reconciliation still clamps only an excess reserve.

## Exhaustion continuation

Exhaustion context is {transition,action}, with an empty clock. It consumes a
real retained living-character fatigue transition, not a UI callback or periodic
zero write. Actions are advance, resolve and qualified prevention-continuation.
One active episode per actor serializes genuine later transitions. Already-zero
legacy conditions remain gated without fabricating a transition/hour. Episode
admission, stop state, classification, elapsed progress, events, recovery,
Medical, lethal handoff and resolution are retained separately from the original
immutable intake outcome and transition.

The bound MOVE owner supplies a checked stop result and current swimming state.
The bound NPC/COMBAT provider supplies a purpose=exhaustion genuine-threat result.
Both are required; failed/missing/stale queries prove neither safety nor danger.
Surface swimming counts. Generic rest vetoes, arbitrary actor proximity and
hidden names/locations/counts do not enter this interface or diagnostic feedback.

Safe collapse requests one protected game hour from the same bound TIME interval
owner. The stable external key is actor/transition/safe-hour, with explicit game
unit, absolute start/end, requested duration and retained absolute elapsed amount.
TIME owns actual advancement and aggregation of required ordered QUEST, MAGIC,
WORLD event outcomes. Its scoped result is {ok,revision,elapsed_usec,phase,events};
events is a checked settled prefix of three booleans. These attest real owner
receipts in a delivered TIME provider; fixture booleans do not deliver those
systems. TIME must retain its own completed progress even if CHAR receives an
invalid/failed response, so retry of the same key cannot advance again. CHAR
retains each valid absolute elapsed result once. Its cursor is a retained
observation of TIME progress, not another authoritative clock.

The contract's declared order is QUEST -> MAGIC -> WORLD for this narrow
protected activity. TIME must first settle chronological obligations within each
owner, with required boundaries before recovery. Other profiles may not silently
reuse it. Independent simulation holds prevent further forced advancement;
only this actor's CHAR vital hold is excluded. Required pending events keep
recovery/Medical unavailable. A settled time receipt is never called again merely
because the later recovery provider failed. Default interrupted hours earn no
recovery or Medical and cannot auto-resume; actual elapsed/events remain retained.

Completed eligible hours use then-current live Medical/Endurance/maxima and
checked Rapid Healing environment/restrictions through shared CHAR-021 hooks.
Health=max(minimum,floor(E/10)-5+trunc((M+K)*Hmax/divisor)); K defaults 60 or
applicable Rapid Healing 100. Pool recovery defaults to max(1,trunc(max/8)), with
explicit regeneration restrictions and capped actual gains. Pools and raw Medical
(+1 by default) commit together. No breath fill or advancement checkpoint occurs.

Positive fatigue after all required settlement resolves the episode. Remaining
zero (including a zero maximum) retains explained incapacitation without another
hour, minimum fatigue, automatic death or rescue. Recovery/fill alone cannot
resolve the episode. An explicit bound resolution owner must attest resolution
with positive fatigue after the required outcome is settled.

Danger/water calls the same unavailable CHAR-018/023 lethal boundary as ordinary
lethal intake. Health remains unchanged; no prevention roll, charge, death or
safe-hour fallback occurs. A qualified bound lethal owner can supply an explicit
prevention continuation under the original episode identity. Controlled results
qualify only that interface. Prevention leaving fatigue zero retains incapacitation
without another lethal request or safe hour; stock prevention/death remain increment 4.

## Retention, reconstruction and diagnostics

`actor-state-v3` extends accepted v2 with `activity-retention-v1`. The activity
state contains captured policy, both cursors, interval owner, fatigue/Running/
Swimming remainders, retained Swimming checks/tick, indexed receipts/events,
episodes/active episode, breath schedule, indexed settlement links and a checked
resolved count. Each ledger is bounded to 4,096 identities; revisions fit 1..1e9.
Exhaustion rejects before wrapping or eviction. Point writes, receipt/episode
lookups and acknowledgment use indexes and repeat no DATA/source preparation.

The v1/v2 forms remain readable. Unsupported/corrupt pending state or attempts to
erase existing retained state reject. V3 validation checks strict complete raw
schemas, identities, applied amounts, practice, transitions, saved time, settled
counts/indexes and independently recomputes interval arithmetic/remainders from
retained rate/check results. Reconstruction executes no activity, RNG, recovery,
notifications or hour. Same-application/scope checkpoints, including fresh-process
fixtures, are not native SAVE or GAD-01 persistent-ID qualification.

The original vital pending_count, transition and applied outcome remain immutable
history. A separate resolved count/index supplies current unresolved work.
`acknowledge_vital` accepts a formerly pending continuation only after its checked
episode resolves; it cannot release another unresolved transition's hold.
Notifications observe coherent committed state. Optional diagnostic/UI failures
cannot replay gameplay. `activity_projection` returns narrowly detached cursors,
remainders, practice and an indexed receipt/episode. `activity_diagnostics.gd` is
a read-only composed development surface, not UI-006 or an activity/time source.
