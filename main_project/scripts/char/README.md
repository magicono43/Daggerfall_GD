# CHAR actor owner — IMP-016 increments 1–2

Increment 2 adds the [vital intake and retained-outcome contract](VITAL_INTAKE.md)
through this same authority. Its versioned v2 records extend the accepted v1
baseline without changing progression receipts, formula inputs or MOVE ownership.
The following sections retain increment 1's baseline choices. Gameplay pool
changes must use the focused intake contract rather than construction/restore.

`core.actors` is the single composed `actor_state.gd` authority. The normal shell
binds the application's published DATA registry to it. CHAR creates no Node,
CharacterBody, collision shape, physical pose, calendar or RNG. MOVE retains its
accepted physical authority. Stock character/restore entry remains unavailable.

## Requests and lifetime

`fresh(scope, original_core_ticket, captured, initialized_clock, source_bindings)`
accepts a complete `captured-actor-v1` player result in CORE's gated baseline or
initialization phase. The capture has exactly schema, actor, level, career,
identity, choices, attributes, skills, policy and initialization. Actor identity
uses the existing stable ID grammar. Ordinary supported level is integer 1.
Identity retains explicit nonempty name/race/gender/portrait/reflexes/biography/
creation_receipt strings; choices retain template, answers, outcomes and
custom_career. These external creation facts are supplied by the trusted creation
owner, not generated or semantically certified by CHAR. The controlled capture
fixture does not qualify real creation, biography effects or grants. Initialization
requires the explicit `{skills_finalized:true, grants:"external-owner-pending"}`
receipt. Missing fields fail, including missing fields whose legitimate value is
zero or an empty retained collection.
Actor identity, clock metadata and initialization/source status markers are checked
in their declared types before use; identity is never stringified into validity,
and integer truthiness cannot stand in for a checked boolean owner receipt.

Actor strings at this boundary are explicit scope-local baseline handles, distinct
from DATA definition identities. They do not certify GAD-01 persistent instance
allocation. Creation/native SAVE must supply and validate branch-counter typed IDs,
nonreuse and duplicate claims before enabling durable references or native entry;
the in-memory baseline handle is not a replacement persistent-ID architecture.

The only supported progression policy is
`{schema:"captured-progression-policy-v1",mode:"vanilla-ranked-v1"}`. Initial S0
uses all three Primary, top two Major, top Minor permanent skills, after captured
initial changes. Actual/earned levels are 1, raw practice is explicitly zero for
every supported skill, training is `{state:"never"}`, pending/retained collections
are explicitly empty. Clock input is `{provider,unit:"game-millisecond",instant}`;
instant is integer 0..9e15. Both advancement and activity baseline retain this
initialized clock. No production TIME provider is delivered; the fixture labels
its controlled clock. No advancement, training or reward draws occur.

Construction resolves career HP/multiplier and each required source once, calls
the selected published RULE providers, then atomically publishes. Positive base
health uses `char.initial-health` (baseline 25 + HP-per-level), without Endurance
bonus or higher-level loops. Health/fatigue/magicka fill only after derivation.
Breath is `{state:"uninitialized",reserve:null,policy:"activity-owner-pending"}`,
with a derived maximum and no generic fill. Same capture/clock/binding retry
returns its retained construction receipt without rebuilding or refilling.

`reconcile(scope,ticket,actor,expected_revision,content_ticket)` resolves only the
actor's retained required provider bindings. READY-session calls require an empty
CORE ticket and the ordinary CORE-validated formula service binding. Gated entry
uses its exact original ticket. Unknown actor/session, obsolete revision/content,
concurrent operations and callback retirement fail explicitly. `service_binding`
declares this owner and its complete formula-hook list; it certifies a baseline
only. Mode owners still declare all required entry services truthfully.

`projection(scope,actor)` returns a detached record, live/raw/cap breakdown,
source inputs, formula/provider provenance, limits, units and pending conditions.
Attribute breakdowns retain base caps separately from effective caps; resolved
career HP, exact multiplier and career/numeric-policy publication provenance are
retained in the derived projection. Actor revisions fit 1..1e9. Changed-source
updates at the limit fail explicitly without wrapping or publishing an out-of-domain
record; unchanged duplicate delivery remains idempotent.
Queries copy only that actor, never the DATA catalog; they call no providers or
formulas and consume no draws. Caller mutation cannot affect the actor/template
or another instance. CORE retirement removes only actors/bindings/receipts in the
retired scope. Disposal clears retained owner state and breaks DATA references.

## Numeric policy and resolved sources

DATA's `actor.baseline:policy#player` (`actor-baseline-v1`) supplies exactly eight
attributes, all 35 named classic skills plus up to 256 total supported skills,
permanent bounds, attribute caps and exact career multiplier ratios. Defaults are
0..100 permanent bounds and cap 100. Overrides support permanent bounds within
0..1,000,000; base live caps within 0..1,000,000,000. Added stable skill identities
remain stored/live/queryable; they do not automatically become career progression
contributors. Extra attribute identities fail. Creation allocation limits and
other skill consumer contracts are not supplied by this policy.

Runtime numbers are strict Godot integers. All resolved raw/live skill totals and
raw attribute sums fit ±1e9; effective attribute caps fit 0..1e9. Captured/source/
reconstructed metadata additionally requires finite plain values, nesting ≤32
and at most 4096 entries per container; cycles fail instead of recursing without
bound. Unsupported opaque obligations fail explicitly rather than disappear.
Source contributions
are integers in ±1e9. At most 64 source owners ×256 contributions are accepted;
their largest intermediate sum is 16,384e9, safely inside signed int64, before
aggregate domain validation. Permanent assignments never silently clamp. Live
attributes clamp raw permanent-plus-values to 0..effective cap; live skills have
no global gameplay clamp. Nonfinite, fractional, unknown and overflowing input
fails before publication. The lowest health limiter must be at least 1.

Bindings are explicit `{id,provider}` pairs. Each trusted source owner implements
`resolve_actor_contributions(copied_operation)` returning exactly
`{ok:true,revision,contributions}`. Resolution is a synchronous snapshot request:
the trusted owner retains that revision for the issued operation, advances no
game time and performs no cross-owner gameplay mutations. CORE cancellation is
rechecked after callbacks. Eligibility/lifecycle changes require a new resolved
revision and reconciliation request, not mutation of CHAR's retained snapshot.
Every contribution is exactly
`{id,kind,target,value}`. Kinds: attribute/cap target an approved attribute; skill
targets a supported skill; magicka targets `magicka`; health-limiter targets
`health`. Source, contribution and target identities remain distinct. Required
missing/malformed owners, duplicate identities, changed same-revision content or
decreasing revisions fail coherently. Source/callback ordering is canonicalized.
An empty contribution list removes only that source's resolved contributions.
MAGIC/ITEM eligibility, stacking and lifecycle remain upstream owner obligations;
this is additive combination of their resolved results, not a universal stacker.

Source reconciliation recomputes from permanent values and every retained source,
including opposing/hidden capped amounts. Base health never changes. Effective
health is min(base health, each limiter); fatigue is (live Strength + live
Endurance)*64 internal units; magicka is max(0, selected base-magicka result +
resolved magicka modifiers); breath is floor(live Endurance/2). Each vital maximum
fits 0..1e9, with health positive. Increases preserve current amounts; decreases
clamp only an amount above the new maximum, including initialized breath reserve.
Source reconciliation performs no percentage preservation, free refill or
damage/healing/practice/death/collapse/reward/grant dispatch. It records and
notifies genuine depletion separately from outcome ownership under increment 2.

## Quiescent reconstruction

`reconstruct(scope,original_ticket,record,source_bindings)` accepts `actor-state-v1`
and the explicit [v2 retention extension](VITAL_INTAKE.md), only during CORE-gated
initialization. The baseline's sixteen required fields are schema,
actor, session, content, career, identity, choices, attributes, skills, base_health,
current, breath, progression, obligations, required_sources and revision. This is
an in-memory current-application owner boundary, not native SAVE restoration.
It deliberately requires the current scope/content identity; future SAVE owns
cross-application identity remapping and compatible migrations.

Progression requires actual_level, earned_target, s0, current_sum, practice,
last_advancement, activity_baseline, training, policy, pending, retained_outcomes,
progression_skills. Current sum must match permanent ranked skills; S0 and earned
target remain authoritative, including legitimate zero S0. Practice/timestamps/
never-versus-trained state and opaque plain-value pending/outcome/obligation
payloads survive. Unsupported policies or incomplete facts fail; no baseline
estimate, pending erasure, health-gain replay or fresh roll is permitted.

Required source receipts retain source revision and SHA-256 of sorted exact
contribution tuples. Reconstructed qualified sources must match these receipts;
actual equipment/effect authoritative lifecycle records belong to their owners.
Only derived values are rebuilt. Saved current health/fatigue/magicka must be
within qualified limits and are preserved, never filled. Invalid saved currents
require failure/migration. Breath supports the explicit uninitialized form or
`{state:"owner-pending",reserve,policy:Dictionary}`; the latter preserves activity
state without executing it. Other activity forms fail rather than disappear.

Pending rewards, zero vitals and activity obligations remain visible and gated.
Every projection says `entry_ready:false` and names missing integrations. No
Session Restored, full story entry, SAVE, progression, activity, UI-006 or death
readiness follows from a valid baseline. Later increments retain their approved
activity/collapse and death/UI responsibilities. Increment 2's intake qualification
does not close those real-owner or native SAVE gates.
