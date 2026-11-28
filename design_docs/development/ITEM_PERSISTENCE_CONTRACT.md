# ITEM persistence participant v1

IMP-017 increment 4 implements `core.items.persistence`. SAVE still owns file
transport, generation integrity, slots and multi-owner orchestration (IMP-022).
CORE owns replacement, gating, cleanup and Session Restored (IMP-023). A successful
ITEM publication alone establishes none of those complete-service gates.

## Durable payload

`item-state-v1` contains compatibility, explicit physical/identity units, all three
canonical uint64 decimal high-water counters, exclusive custody/context
declarations, authoritative source clock and original wagon/context identities,
possessions, containers, construction/generation/collection/monetary operation
records, committed quote claims, collection serial and typed references. Capture
is isolated and requires the composed coordinator, ready scope and settled ITEM
boundary. All currently supported custodians are included regardless of access.
Each possession occurs once; container membership and identity order are rebuilt.
No restacking or positive-intake admission occurs during hydration.

The participant accepts at most 32 nesting levels, 4,000,000 visited values,
65,536 entries per container, 1,024-character keys and 65,536-character strings.
Quantities remain 1..2,147,483,647; physical/accounting integers use the existing
exact 0..9,007,199,254,740,991 domain. Persistent IDs/counters use canonical
decimal strings through 18,446,744,073,709,551,615, with zero only as an unused
counter sentinel. These are explicit technical bounds, not new vanilla stack caps.

Runtime Objects authorize requests. Durable operation keys use the CORE-validated
exclusive `custody:context:request` claim. Scope fields in participant envelopes
are normalized on capture and explicitly rebound to the replacement session.
Neither engine Object IDs nor WeakRefs, capabilities, callbacks, UI selections,
uncommitted tender plans or derived capacity caches are durable authority.

Monetary records retain actual denomination quantities and each letter's identity,
issuer, face unit, remaining face, provider/version, weight and provenance.
Committed tender records retain exact quote/debit/delivery/change facts and the
outstanding ECON acknowledgment. `econ-ack-v1` marks restored settlement receipts;
`recover_money` only calls the current authorized ECON acknowledgment participant.
It never invokes payment preparation, debit, delivery, issuance or RNG. Old UI
acceptance cannot resume a restored operation. ECON must retain its own durable
idempotency result under the stable quote/operation identity.
Providers must explicitly declare `recovery-v1` before pending acknowledgment
capture/restore is supported. The controlled fixture persists ECON facts separately
and loses a response after credit commitment; recovery cannot repeat that credit.

Incomplete generation and collection technical recovery without a delivered
continuation owner explicitly prevent capture/restore. They are not omitted or
reported as completed. Complete/partial terminal collection outcomes and retired
construction outcomes remain retained. Live equipment/effect/service/quest/light
semantics are not introduced: required references must be typed and linked by an
explicit participant, and unavailable required owners fail readiness.

## Preflight and publication

`prepare(coordinator, core_ticket, payload)` is permitted only during the exact
CORE load preflight. It validates bounded plain typed data, v1 schema, exact locked
DATA compatibility, canonical IDs/counters including retired receipt claims,
uniqueness, custody, physical quantities, instrument representation and references
without changing the source or outgoing store. No legacy migration is registered;
unsupported versions and required definition/provider differences require an
explicit future migration. No fallback item or money conversion exists.

`publish(coordinator, core_ticket, candidate, links)` requires the matching
operation generation, current coordinator, content ticket and replacement scope,
and CORE's initializing phase. Candidate records register before references;
membership/order are rebuilt off to the side. Current providers must explicitly
rebind exactly the saved custody/capacity declarations. The required participant
reports restored clock, linked references and reconstructed sources through
`item_restore_links`. The original clock and wagon/context identities are checked
again. Publication is one callback-free replacement after all required checks.
Failure consumes the candidate without partially replacing ITEM; CORE coordinates
other participants' cleanup. Duplicate, stale and reentrant publication rejects.
CORE's load-only `bind_item_restore_participants` composes the replacement
requesters before hydration, and final admission checks the exact declared services
and ITEM publication ticket. Required real CHAR capacity projections and current
provider modifiers must be valid before ITEM publication. Precision and aggregate
load overflow are checked independently of ordinary intake capacity admission.

Compatibility includes selected RULE contracts/providers/versions and monetary
provider capabilities. DATA hashes resolved values, identities, field winners and
contributor provenance. Absolute staging roots and attempt-specific omission tokens
are excluded from durable compatibility; package/file/version identity remains.

CHAR's own reconstruction remains authoritative for saved current pools and
source-derived limits. ITEM rebuilds its indexes/caches from actual records and
does not replay equip/use/grants or contribute a second copy of modifiers. Current
access remains a query against the original storage and provider context; lack of
access never means an empty inventory. Overweight storage is preserved.

The controlled persistence suite uses actual CORE/ITEM/CHAR/DATA/RULE interfaces
and a disposable transport, with controlled SAVE, ECON and link participants.
Production slots, complete-room phased restore, live owner links and M2 remain
separate gates. Execution evidence records exact qualified scope and limitations.
