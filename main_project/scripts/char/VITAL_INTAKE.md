# Vital intake — IMP-016 increment 2

Increment 3 extends current continuation through the [activity/exhaustion
contract](ACTIVITY.md). The increment-2 applied outcome, transition and historical
pending_count remain immutable. V3 retains separate checked episode settlement,
resolved count and indexed operation/transition links. A formerly pending intake
can acknowledge only after its own episode resolves; other pending episodes and
zero conditions continue to hold. `vital_projection.pending_outcomes` reports
current unresolved work. The increment-2-only unavailable statements below
describe the accepted earlier boundary; they do not override this extension.
The shared CHAR-023 lethal boundary still rejects unchanged until increment 4.

`core.actors.vital_intake(consumer, request)` is the production CHAR mutation
boundary. It never derives formulas, resolves modifier sources, moves an actor,
draws randomness or performs COMBAT/MAGIC gameplay. The current CORE mode owner
declares trusted session services with a stable `vital_intake` consumer handle.
CORE admits only COMBAT, MAGIC, ITEM and CHAR owners implementing
`vital_operation_current(detached_request) -> bool`. Runtime weak Object bindings
attest the actual composed consumer; Object IDs and constructor labels are not
persistent identities. UI, DATA, MOVE and observer callbacks have no intake grant.
The stock provider still cannot enter a real game. Controlled consumers qualify
this interface without delivering those future owners.

The eligibility predicate is synchronous and read-only. CHAR monitors native/VM
errors through the existing scoped callback logger, checks a strict boolean
result and rechecks scope after the call. Failure returns technical_failure or
stale without publishing. It cannot trigger fallback or a hidden retry.

The exact twelve-field request is:

```json
{"schema":"vital-intake-v1","session":"session-1","actor":"player",
 "caller":"magic-intake","operation":"cast-1-payment","content":1,
 "revision":1,"action":"spend","pool":"magicka","unit":"points",
 "amount":5,"attribution":{"source":"spell-source","cause":"payment",
 "component":"release-1"}}
```

All IDs follow the existing bounded stable handle grammar. Attribution requires
exactly source/cause/component handles; the trusted requester owns the validity
of its source context. Session and actor handles remain the accepted scope-local
baseline identities. GAD-01 persistent branch-counter allocation and native SAVE
remain gates. Content is the actual published application ticket. Raw types and
complete schemas validate before conversion. Integers are 0..1e9; revisions
1..1e9. Booleans, fractions, nonfinite numbers, negative amounts, unknown fields,
unsupported units and exhaustion fail unchanged. Addition intermediates are at
most 2e9 and subtraction at least -1e9, safely inside signed int64; saturation
does not hide arithmetic overflow. No numeric-policy or executable hook is added.

| Consumer | Eligible operations |
| --- | --- |
| COMBAT | health damage |
| MAGIC | spend, damage, drain, heal, recover on supported pools |
| ITEM | heal, recover, fill on supported pools |
| CHAR | spend, drain, recover, fill on supported pools |

Health/magicka units are `points`; fatigue uses `internal-64`, with no implicit
conversion. Spend is all-or-nothing and may reach exactly zero. Damage/drain
saturates at zero. Heal/recover saturates at current maximum. Fill has amount
exactly zero as an explicit capacity-fill command, rather than a quantity; its
actual gain is reported separately. Breath and all activity operations are
unsupported. Eligibility is a trusted owner request contract, not permission for
UI fill, revival, free casting, partial payment or training exceptions.

## Commitment, retention and continuation

The returned `applied-vital-v1` reports session/actor/caller/operation, action,
pool/unit, requested, before/after/maximum, absolute applied change, remainder,
new revision, attribution, phase/kind, transition_pending and
continuation_allowed. For quantity operations remainder is requested minus actual
application; for fill it is unfilled capacity. Insufficient spend is `ok:false`,
`kind:insufficient`, `phase:rejected`, applied zero. A valid zero application is
`ok:true`. Consumers must check the outcome rather than infer it from a pool
snapshot. Numeric resolved physical damage and separately attributed magical
damage remain distinct from CHAR actual health loss. There is no kill flag.

Invalid/stale/busy/ineligible/unavailable/overflow failures have `ok:false` and a
reason, and publish no receipt or pool change. Lethal health intake is currently
**unavailable and rejected unchanged**: CHAR-023 prevention/death ownership is
increment 4. This includes an otherwise sufficient exact health spend. No staged
lethal state, provisional terminal zero, survival choice or prevention roll is
invented. Existing reconstructed zero health rejects every intake, including
healing/fill. A future qualified lethal attempt requires fresh operation identity
and current revision; unavailable intake is not successful damage/payment.

For an admitted operation, CHAR checks consumer/session/actor/content lifetime
before indexed receipt lookup. Exact redelivery returns the original detached
result before checking actor revision or current owner operation, since commit
itself advances revision. Changed intent under that caller/operation fails with
identity_conflict. Fresh attempts require a new operation ID and current revision
and owner eligibility. Retired/replacement scopes cannot retrieve or continue an
old result. Accepted insufficient outcomes are retained, so later recovery cannot
turn their redelivery into a debit. Attribution, requests and outcomes are copied.

All validation and the one synchronous owner eligibility callback precede the
commit. CHAR excludes reentrancy and rechecks lifetime after callback. Commitment
publishes the current/revision, receipt and any transition together, with no
foreign callback inside that boundary. `vital_committed` is a detached optional
observation after coherent publication. Observer failure/retirement cannot undo
the committed debit or authorize another one. No gameplay continuation runs from
the signal. A failed required consumer must retain its phase and earlier results.

The consumer pulls the retained result and continues its own declared ordered
phase only when `ok` and `continuation_allowed` are true. After its own work is
settled, `acknowledge_vital(consumer, original_request)` records acknowledgment;
duplicate acknowledgment is unchanged. Acknowledgment cannot acknowledge a
rejection or unresolved fatigue outcome. The consumer must make its continuation
idempotent under the same operation and retain its own receipt: acknowledgment
is not an atomic cross-domain transaction. A failure before acknowledgment leaves
the debit and original result intact for recovery. No automatic retries, refunds,
unbounded queue, full attacks/casts or consequence coordinator are introduced.
When a required multi-owner continuation is involved, its coordinator must acquire
its own scoped CORE simulation/input/save hold before intake, preserve it across
failure, and release only that hold after settled acknowledgment or safe scope
teardown. CHAR cannot infer whether an external delivery succeeded. The controlled
COMBAT consumer demonstrates retaining earlier physical/magical outcomes while
the unavailable lethal remainder and its own safety hold remain explicit.

## Depletion, maxima and records

Each positive-to-zero transition gets one increasing per-actor transition ID and
its original operation attribution or source-reconciliation receipts. Repeated
zero and zero-maximum assignment do not manufacture another transition. Recovery
above zero naturally rearms the next crossing. Source maximum decreases use the
same accounting; increases preserve current. Source changes do not become damage
or healing. Magicka crossings are retained notifications. Fatigue crossings are
explicitly owner-unavailable obligations, distinct from collapse. They retain
requester-owned CORE simulation/input/save holds until a later qualified outcome
owner resolves them or the scope retires. Recovery/fill does not silently erase
the obligation. Existing reconstructed zero health/fatigue also establishes the
hold without inventing a transition. Other CORE holds are never released by CHAR.
If the sole condition was a reconstructed zero-fatigue value and supported
recovery removes it, CHAR releases its own condition hold. A retained pending
transition continues to hold even after recovery. Staged lethal transition
records are unsupported and reject; legacy zero health remains visible and gated.

`vital_transition` emits a detached `vital-transition-v1` event after coherent
commit, carrying session, actor and transition ID plus the retained transition.
Source reconciliation and intake use this same notification. Redelivery and
reconstruction do not emit again. Observers validate the originating scope and
cannot authorize gameplay continuation; optional observer failure is not rollback.

The accepted sixteen-field actor-state-v1 remains readable. On first retained
mutation or source depletion CHAR publishes actor-state-v2, adding `vitals`:
`vital-retention-v1`, receipts indexed by caller then operation, receipt_count,
transitions, next_transition and pending_count. Progression retained_outcomes is
untouched. Retention is bounded to 4096 receipts and 4096 transitions per actor;
exhaustion fails rather than evicts identities or wraps counters. Acknowledgment
also checks revision exhaustion. No hidden pruning can turn old IDs into new work.

Quiescent reconstruction validates complete logical results, units, attribution,
matching request/revision/actor/session/content, counts, acknowledgment eligibility
and supported pending transitions. Existing retained state cannot be erased by
reconstructing an older record. Initialization/reconstruction emits no new damage,
healing, notifications, consequence or randomness. Unsupported lethal/activity
pending outcomes fail. These are same-application, same-scope in-memory owner
records, not native SAVE or cross-session identity migration.

`vital_projection(scope, actor)` returns only coherent currents/maxima/units,
revision/content and pending summary, without copying sources or receipt history.
`projection` retains the full detached owner record for diagnostic/checkpoint
review. Mutation and exact receipt lookup use owner indexes; neither scans other
actors/receipts nor repeats DATA/RULE/source preparation. Validation/reconstruction
of a whole record deliberately checks all of its retained data.
