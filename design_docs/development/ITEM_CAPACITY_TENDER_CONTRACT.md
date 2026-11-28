# ITEM capacity and tender v1

IMP-017 increment 3 extends the existing CORE-owned ITEM authority with
`capacity` and `money` collaborators. All possessions, including coins and
letters, remain in `_possessions`; collection indexes contain references.
Targeted qualification and open gates are recorded in the
[increment-3 execution evidence](evidence/IMP-017-increment-3-2026-11-27.md).
User acceptance and native persistence remain open.

## Publication and numeric boundaries

`item.capacity-tender:profiles` uses ordinary DATA/MOD add/replace/patch and
captured loose overrides. Provider keys and supported intake/quote/valuation
contracts are declared before preparation through
`StartupProviderBoundary.declare_item_money_provider`. Duplicate, unsupported,
late and missing declarations reject. Publication locks configuration for the run.

Profiles explicitly name accounting, capacity, template weight/exemption, wagon
access, denominations, money algorithm/gold mapping, letters and valuation rates.
Every record carries provenance. Vanilla publishes gold only, 1 gold accounting
unit per gold-formula unit and 2.5 g per coin. Regional rates, additional coins,
letter weights and physical-wagon settings in tests are controlled examples.
No bank balances, issuance service, live merchant owner or world simulation is
introduced. The sole adopted template exemption in the currently constructible
subset is `dfu-item-131`, verified against the pinned DFU template's actual
`hasNoEncumbrance` flag. Its source hash/record/license are retained in DATA.

Weights enter capacity accounting in integer billionths of kg (`nanokg`), with
the existing construction/material calculation completed first. Existing
construction and semantic intake now retain exact `weight_nanokg` from their
calculated microkg result; the legacy kg field remains presentation-compatible.
Legacy microkg records recover that declared boundary, rejecting a positive value
that would disappear. Monetary records retain exact `weight_nanokg` too.
Baseline quantum is 2,500,000 nanokg
(1/400 kg). Finer profiles must divide 1,000,000,000 exactly. Conversion rounds
nearest-even per effective unit, before quantity multiplication and aggregation;
positive-to-zero conversion rejects. True zero and explicit exemption remain
distinct. Transfers do not re-round retained physical weights. Loads/capacities
use one selected quantum throughout a storage plan. Display precision must
distinguish its quantum. Nonnegative integer arithmetic is bounded by
9,007,199,254,740,991; checked sum/product overflow rejects. Integral JSON numeric
values are accepted only within that exact range; fractions/nonfinite values fail.

## Storage, capacity and wagon context

Collection requester contexts may additionally declare `capacity`:
`{kind, actor, profile, access, wagon, exit}`. `kind` is `carried` or `wagon`.
The other fields are explicit stable references/profile keys. Legacy unbound
collection contexts retain their prior contracts. Capacity-bound contexts have
one storage collection. The actual CHAR narrow `capacity_projection` returns
selected live capacity in kg with actor/content/revision and formula provenance;
it does not copy the actor's retained history. The baseline remains
floor(live Strength × 3/2). ITEM never reimplements that formula.

The bound provider's pure `item_capacity_context(request)` returns
`{ok, revision, modifiers, wagon}`. Modifiers are unique `{source, kg}` signed
integer contributions, rebuilt from source facts rather than accumulated.
The checked effective result must be nonnegative; zero is valid.
Real equipment/MAGIC contributions remain pending; controlled additional
contributions exercise this interface. Equipment references and wallet summaries
are not additional possessions and add no weight. Wagon storage is separate;
bank balances have no physical ITEM entry.

The wagon snapshot has exactly `owned`, `available`, `valid_exit`, `reach_mm`,
`feet_mm`, `anchor_mm`, `location_mm`, `wagon`, `exit`, `context_id`, `context`.
Positions are three integer millimetre coordinates in the same local frame.
Distance is Euclidean from the actor feet reference point to the stable original
exit anchor. The 5,000 mm boundary is **inclusive**: [3000,4000,0] passes;
[3001,4000,0] fails. This engineering equality choice is documented rather than
claimed as original-executable parity. Baseline exterior access needs ownership
and availability; interiors deny unless the selected profile explicitly allows
them. Dungeon access also requires the original valid exit and range.
`physical-reach-v1` additionally requires current location/reach/availability.
Missing/unavailable spatial facts reject, never return empty replacement storage.
Storage access performs no exit; MOVE-022 Access wagon / Leave dungeon / Cancel
remain distinct, with full interaction and real WORLD/LOC ownership pending.

Admission validates cumulative before/after loads, current CHAR/source/access
facts and revisions before callbacks, then repeats after staged callbacks.
Exact fills pass. Capacity loss retains contents; removal and genuine weightless
intake remain possible. Any positive intake while already overweight rejects,
even if another removal would yield a lower final load. No dropping/deletion or
movement penalty is added. Load totals are cached by the authoritative collection
revision and locked quantum; staged plans subtract old contributions before
adding new ones with checked arithmetic. Cache misses traverse member references,
without copying possessions or CHAR retention. Collection mutations invalidate
through revision advancement. Template weight lookups cache explicit absence as
well as overrides for the session's locked publication. Splitting already retained
contents within the same storage preserves weight and is not positive intake;
a same-storage fitting request is a validated no-op. Fitting queries require
collection authorization and revalidate provider revision, source access/state
and capacity after their pure admission callbacks.

`maximum_fitting` uses the actual source quantity, weight bound and the same
whole-plan nonweight admission. Its explicit `bounded_maximum_whole_v1` profile
searches descending for the maximum accepted whole quantity. Arbitrary admission
callbacks are not assumed monotonic; more than 65,536 candidates rejects with
`fitting_search_limit`, never reports a false maximum. `transfer_fitting` opts
into that profile; ordinary explicit quantities remain atomic.
`stable_whole_entries_v1` retains its previous whole-entry-only behavior.

## Physical instruments and tender participation

Requester contexts may declare `money: {profile, provider, coins, letters}`.
Complete provider methods are `money_revision()`, `money_intake(request)`,
`money_quote(request)` and `money_complete(outcome)`, all pure except completion
acknowledgment. Intake requires an explicit authorization response and current
revision/session. Coins are homogeneous stack possessions with a stable
denomination/profile, accounting unit, unit value and individual physical weight.
Letters allocate distinct item IDs and retain issuer, face unit, remaining face,
provider/version and independent physical weight. Generic homogeneous semantic
intake cannot construct these instruments. Generic copy, consume or partial split
cannot duplicate/debit finite credit. Authorized physical transfers use normal
collection custody and all-or-reject plans. Wallet counts/letter summaries are
read-only projections, never a second spendable store.

ECON supplies a quote containing exactly `id`, `revision`, `price`, `fees`, `unit`,
`region`, `institution`, `provider`, `coin_offer`, `tender`, `wagon`, `rates`,
`sources`, `recipient`, `destination`, `outputs`, `change`. Sources/recipient/
destination are typed stable container IDs. Outputs/change name exact existing
item IDs and whole quantities. `wagon` permits wagon sources only with current
access. Bank references cannot become physical sources. A controlled coordinator
qualifies this contract; live ECON settlement and its practice/stock obligations
remain IMP-037 gates.

The selected `bounded-exact-search-v1` profile names denomination order and a
search limit. It searches explicit count subsets, earlier denominations taking
larger counts first, and fails explicitly on exhaustion. It never falls back to
greedy/optimal selection. Gold-formula mapping is explicit. Coins fund the full
price/fees when sufficient; otherwise carried eligible letters are used in stable
numeric typed-ID order, then coins. Exact tender requires equality. Change tender
uses the explicit accepted `coin_offer`; its excess must equal supplied physical
change. No donation, invented change or automatic exchange is assumed.

Rates bind issuer/institution/region/face-unit/local-unit/provider with positive
integer numerator and denominator. `exact-lots-v1` consumes denominator face units
for numerator local units. It conserves exact rational lots with no fractional
residual to discard or reproduce. Unrepresentable tiny amounts require other
accepted funds or rejection. Unsupported/missing/conflicting rates reject; no
1:1 fallback exists. Queries, travel and repricing never alter face amount.

`prepare` returns the quote, exact plan, coin debit/change, face debits/local
credits, source and provider revisions and capacity/access facts. Confirmation
passes this complete accepted result to `commit`; changed material facts require
renewed acceptance. Full coin moves, face debit/retirement, goods and actual
change supply are staged together. ITEM rechecks quote/provider/capacity after
callbacks before callback-free owned commitment. Ordinary rejection mutates none.
Tender uses explicit no-stack output moves, preserving source remainders/new IDs
without merging an incoming payment into a separately quoted change supply.
An already committed provider/quote identity cannot be spent again by assigning
another ITEM request identity; exact original-request retries use their receipt.

After owned commitment, a scoped receipt is retained before ECON acknowledgment.
Failure returns exact committed facts plus `econ-acknowledgment`; retry attempts
only that outstanding acknowledgment. It cannot debit/deliver/issue twice. The
coordinator must acknowledge idempotently using the quote/operation identity.
Partial face spend preserves identity; exhaustion retires once. Receipts are
session-only. Increment 4/IMP-023 must capture actual facts rather than replaying
intake or payments; this contract establishes no native SAVE readiness.
