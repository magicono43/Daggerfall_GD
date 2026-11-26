# CHAR lethal events — IMP-016 increment 4

IMP-012 increment 4 uses this same resolver for retained grounded compression.
MOVE settles physical activity, attests only its exact retained health request
under the existing MOVE vital binding, and acknowledges prevention through CHAR.
A prevented player retains collision recovery until the original mechanism
provider qualifies a new safe proposal; no immunity or health write is added.
See [the MOVE contract](../move/PLATFORMS_FEEDBACK.md).

`core.actors` remains the only CHAR authority. `lethal_events.gd` is its helper,
with retained facts in the actor record, not a second actor store. Ordinary
lethal health intake and classified CHAR-022 exhaustion call this same resolver.
Nonlethal intake retains the accepted `applied-vital-v1` contract unchanged.

## Admission and results

Ordinary callers submit the complete strict `vital-intake-v1` request through
their existing CORE vital binding and `vital_operation_current` admission.
Lethal exhaustion uses CHAR's internal caller `char-exhaustion` and stable
`exhaustion-<transition>` identity, preserving the original episode attribution.
New events require current session/content/actor revision, positive health and
available revision/retention space. Same caller/event with changed intent fails.
Technical duplicate lookup precedes actor-revision freshness, but still requires
the original current CORE consumer lifetime. Retired scopes cannot query or
continue a replacement actor. Reentrant mutations return busy.

Admission retains a `lethal-retention-v1` event, increments the actor revision and
installs this actor's simulation/input/save hold before any foreign callback.
Only one unresolved lethal event per actor is admitted. Reconciliation and new
ordinary activity/vital mutations wait for settlement. Existing receipts remain
immutable and independently acknowledgeable; revision space for lethal commitment
is reserved. No private retry queue or eviction permits identity reuse.
Acknowledging an older prevented event cannot spend the revision reserved for
another pending lethal settlement; already-acknowledged lookup consumes none.

`lethal-outcome-v1` is the explicit lethal extension, rather than pretending the
old rejected `unavailable` result was an applied vital receipt. It carries the
original session/actor/caller/event/attribution, requested amount, before/effective
maximum, saturating damage `applied` and unapplied `remainder`, separately reported
prevention `restored`, coherent final `after`, phase/reason and continuation flag.
The debit and restoration commit together: an intermediate zero is never exposed
as death. For example, 100 damage against 31 health with default successful
prevention reports applied 31, remainder 69, restored 3 and final health 3.
The result distinguishes the two actual pool operations rather than reporting a
prevention refill as unrequested damage or hiding the original debit.

Phases are `sources`, `evaluation`, `prevented` and `dead`. Pending results are
`ok:false` with a source/evaluation/consumption-required reason. They do not
authorize downstream continuation. A retained final result cannot be altered by
acknowledgment or caller mutation. Only prevented events acknowledge; dead and
pending events cannot continue ordinary caller phases. Ordinary and exhaustion
receipt indexes remain separate and point-addressable.
Pending public outcomes report `applied=0`, full requested `remainder`, unchanged
`after` and zero `restored`. The private retained result seed describes the
eventual debit for checked settlement; it is not a committed pool change.

## Required prevention-owner interface

A ready session service declares `death_prevention:<stable-id>` with owner
FACT/MAGIC/ITEM/CHAR. CORE binds the actual Object and lifetime. The current
focused composition supports one required source-directory owner; an absent
binding stays pending. This owner must supply the complete eligible set for its
qualified composition and must not substitute an empty set for an unavailable
required underlying owner. Real combined FACT/MAGIC/ITEM composition is not
qualified by the controlled directory fixture.

The three idempotent owner methods receive detached context containing the
original event, step, captured catalog/source and retained decision:

| Method | Complete successful response |
| --- | --- |
| `lethal_sources(context)` | `{ok:true,provider,revision,sources:[{id,revision,priority}]}` |
| `lethal_evaluate(context)` | `{ok:true,source,revision,success,receipt:{...}}` |
| `lethal_consume(context)` | `{ok:true,source,revision,receipt:{...}}` |

Catalog/source revisions are strict integers 1..1e9; priority is -1e6..1e6.
At most 64 uniquely identified sources occur in a catalog. Only a successfully
validated ready empty catalog establishes no eligible prevention. Catalog
enumeration order is irrelevant: lower effective priority sorts first, followed
by stable source identity. Checked DATA priority overrides apply before sorting.

Eligibility, chance/rank, charge/cooldown state and revision checks belong to
the benefit owner. Evaluation is once per event/source, including when a callback
has committed a draw but cannot return a valid result. The owner must retain that
decision under the supplied identity and return it on technical retry. CHAR
retains every valid decision before another callback. It stops on success and
requests only that source's success settlement. No failed-attempt cost policy is
enabled by this interface; owners requiring one remain unavailable until an
explicit supported rule/receipt contract exists.

Consumption is idempotent under event/source/decision identity. A lost response
after consumption leaves CHAR pending with its decision retained; retry asks only
for the same unfinished settlement receipt. It cannot reroll, refund a committed
prefix or invent survival/death. Malformed or unavailable required results remain
pending. Owner callbacks use their declared existing session RNG purpose; CHAR
creates no stream and owns no universal Stendarr chance formula.

## Commitment, death and reconstruction

Successful prevention restores `min(maximum,max(minimum,floor(maximum*n/d)))`.
Maximum health must be positive. Defaults n/d=1/10, minimum=1. Products fit signed
int64 (maximum <=1e9, numerator <=1e6). Survival and its source receipt publish
before notification. A genuinely later event gets its own eligibility/evaluation;
no invulnerability interval is added. Zero fatigue and other pending episodes
remain independently gated after prevention.

No successful prevention commits health zero and one indexed death fact, then
passes the exact actor/event to `CORE.confirm_actor_death`. CORE checks both its
composed CHAR authority and the retained current death fact before marking the
session dead/not ready. UI cannot confirm death from a button or health display.
Ordinary damage/activity/reward producers must use their existing CORE lifetime
admission; death makes those bindings ineligible. Existing saves are untouched.

`actor-state-v4` adds the lethal ledger to an accepted v1/v2/v3 record, retaining
optional vital/activity fields. The ledger retains catalog, sorted sources,
cursor, decisions, source settlement receipts, policy/provenance, immutable result,
acknowledgment and active/dead indexes. Retention is 4,096 events per actor; actor
revisions remain 1..1e9. Complete schema/type, arithmetic, phase, source order and
index validation runs before reconstruction. Captured policy must match the
current locked definition. Portable provenance uses package/file/version, a
canonical SHA-256 of the resolved policy and field winners; expanded machine
roots and root-bound candidate omission tokens are not durable content identity.
StringName metadata keys
are normalized only at the trusted published-DATA capture boundary.

Accepted v1/v2/v3 records remain readable. An old v3 `lethal-unavailable` episode
retains its original unavailable request/result. A subsequent explicit owner
continuation adds `lethal.v4`, linked to the same exhaustion event. New v4 events
cannot be resolved by the old controlled prevention-continuation shortcut.
`exhaustion-outcome-v2` adds `schema`, `session`, `actor` and explicit `lethal_phase` to the retained seven-field
legacy result. New episodes distinguish `lethal-pending` from `dead`; neither
marks the historical fatigue obligation settled. Valid legacy seven-field
receipts remain unchanged. A prevented episode with already-positive fatigue
settles through the checked prevention receipt before its original vital receipt
can acknowledge; merely filling fatigue does not settle the episode.
Prevented zero-fatigue episodes stay incapacitated without another evaluation or
safe hour. Confirmed death retains unresolved fatigue and historical pending
counts; no old receipt is rewritten as settled. Unsupported/corrupt states fail.

Raw typed headers are checked before cross-ledger validation. The caller record is detached before any external source query; malformed nested ledgers fail before typed access.

Reconstruction does not evaluate, consume, fill, draw, emit death/collapse or
start presentation. Dead/pending diagnostic snapshots remain gated conditions;
they are not ordinary dead-session saves, native SAVE or persistent-ID support.

## Initial presentation and CORE return

The shell composes `death_presentation.gd` as a committed-death observer. Its
presentation delta progresses independently of gameplay rate/readiness. Default
fade is two seconds; return is three seconds total. There is no initial skip
action. CORE's dead readiness gates ordinary input/simulation/save throughout.

The MOVE view owner supplies a cosmetic camera lowering of up to 0.65 Godot
metres, ray-clipped with 0.05-metre surface clearance. It never changes physical
pose, facing or placement. These distances are project engineering defaults, not
a conversion of DFU movement constants. Missing/deleted camera cannot stop the
observer's clock. AV owns a separate death-only player; UI owns the black fade.
Cleanup restores/releases only these owned resources.

Default sound is `classic-ordinal-405`, DFU's default WoodElfMalePain1 physical
sound ordinal. AV requests that explicit ordinal through the existing classic
decoder, converts unsigned 8-bit mono 11025-Hz PCM to signed 16-bit playback and
releases its own stream on retirement. Missing sound is a cosmetic failure, not
a successful playback or a gameplay policy fallback. Race/form-specific voice
selection remains a named real AV/identity integration.

After the initial sequence, the observer retains originating-session return
intent. It waits through CORE busy/cleanup and submits a fresh current request
only while that same session remains dead. Retirement/replacement discards it.
After the unskippable initial interval, the fade/input cover yields to independent
busy/recovery UI. Initial physical holds transfer to AV's release fence rather
than leaking to movie skip or menu activation; cleanup preserves playback-owned
fences and releases each key on a genuine release. No old phase is written after
CORE's potentially synchronous retirement callback.
CORE owns teardown, original ANIM0012.VID once, menu recovery and skip fencing.
The stock provider invokes the existing real classic video capability using an
explicit optional ANIM0012.VID read from the already-published classic root.
The optional file is not a required startup manifest entry. Missing/failed
playback follows classified Failed bypass.
Controlled lifecycle fixtures qualify routing, not a fake successful movie.
Menu retry cannot replay initial presentation or the movie. No autosave, load,
save deletion, resurrection or developer bypass is introduced.
