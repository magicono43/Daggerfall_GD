# ITEM collections v1

IMP-017 increment 2 extends the CORE-composed ITEM construction authority.
`core.items.collections` is its owned collaborator. The only possession store
remains `construction_owner._possessions`; membership indexes hold references,
not independently mutable item copies. This is an owner service and DEV
diagnostic, not a playable inventory or native SAVE participant.

## Readiness, access and identity

Existing five-field construction requester contexts remain valid. Collection
requesters add a sixth field `collections: {provider, types}`. CORE admits the
actual ready session requester, whose weak binding expires with the session.
The provider key is an explicit versioned semantic contract key; `types` is a
unique list of published type keys with that provider. A requester implements:

| Method | Contract |
| --- | --- |
| `collection_now()` | Absolute native game milliseconds, integer 0..2^53−1; TIME adapter in a future real composition |
| `collection_revision()` | Nonnegative integer 0..2^53−1; changes whenever staged access/admission/state authorization changes |
| `collection_intake(request)` | Pure semantic grant preparation; explicit `{ok, properties}` with complete per-unit physical properties, no default substitution |
| `collection_state(request)` | Pure preflight for the named semantic type, retained contents, bindings and action; explicit `{ok, kind/reason}` |
| `collection_admit(plan)` | Pure combined admission against detached complete before/after entries for each affected collection; explicit `{ok, kind/reason}` |

Callbacks may reject; they perform no equipment, LAW, QUEST, MAGIC, settlement
or item-use effects. Such an operation needs its actual owner's coordinated
interface. No implicit unequip, effect removal, legalization or quest transition
is supplied. Equipped mutation fails with `required_equipment_transition`.
Unavailable required semantic providers fail. Controlled providers qualify
these preflight interfaces, not the corresponding gameplay integrations.
Responses must be plain detached data with a boolean `ok`; failures require a
stable `kind`, and an optional reason must be text. Malformed responses become
`provider_failure`. Partial batches skip only the declared ordinary exclusion
kinds; all other failures stop with retained technical recovery facts.

Collection creation allocates `{category: container, number: decimal}` from the
same branch allocator as item/stack identities, with independent per-category
high-water counters. The complete unsigned range is 1..18446744073709551615;
zero remains invalid. Decimal comparison uses digit count then equal-length
ASCII order, never floats. Category order is ASCII ascending, then numeric
component. That is also the retrieval and automatic-survivor order.

Collection access requires a current requester binding for its custody/context.
One requester may bind multiple explicit contexts. A destination can use another
of those contexts; successful custody becomes its owner/context/container tuple.
Possession IDs, query results and detached projections grant no mutation rights.
Insertion admits initial construction custody directly; it is not a second
grant or a copied possession. `insert` cannot extract from a different collection.

## DATA and RULE

`item.collections:policies` publishes through normal DATA/MOD add/replace/patch,
captured loose precedence and actual menu commitment. It is registered with
construction's full ordinary adapter composition. Baseline category policies
are project-authored from approved RULE-025, with provenance in each record.
No source file, reference implementation or classic data is modified.

Type records declare schema, provenance, eligibility, cap, semantic provider,
representation, contents schema, instance restriction overrides and state rule.
Template policy records use `template-<stable-profile-key>`, name their construction
profile and type, and explicitly replace both eligibility and cap. Missing or
conflicting references fail DATA validation. Type defaults permit ingredients,
potions, books, gold, arrows and oil; equipment defaults deny. Pending special
type providers are explicit, not structural records promoted to live contents.

The selected `item.eligible` hook uses `item-formula-v1`, Dictionary→integer 0/1.
Input has exactly `default`, nullable `template`, `restrictions`, and four typed
instance flags: equipped, quest, enchanted, summoned_nonarrow. Template allow
and deny both replace the category result; instance restrictions apply last.
Output validation prevents a hook from bypassing an undeclared restriction.
Selected failure has no fallback. Results expose layers, reason and provenance.
Queries allocate/draw/mutate nothing. Eligibility is not pair compatibility,
access authorization, cap admission or permission to use an item.

`homogeneous-per-unit-v1` state has exactly these fields:

| Field | Meaning |
| --- | --- |
| `representation` | The declared homogeneous per-unit representation |
| `contents` | Complete declared key/text/integer/boolean or key-set payload fields |
| `knowledge` | Stable-key → boolean facts, per unit |
| `resources` | Stable-key → nonnegative integer, **per unit**, not a shared stack pool |
| `provenance`, `bindings` | Stable-key → string source/owner references |
| `expiry` | Absolute native game milliseconds; 0 means no expiry, summoned requires nonzero |
| `equipped`, `quest`, `enchanted`, `summoned` | Explicit booleans, never inferred from display names |

`exact-per-unit-v1` compares all these facts. `set-content-v1` additionally
declares `key-set` fields as unique unordered stable keys (maximum 256); only
their detached comparison keys are sorted. Different sets remain different.
This provides a complete supported type-aware compatibility extension without
discarding information. Text payloads are limited to 16,384 characters;
content/resource integers to 0..2147483647. Unknown/missing required fields fail.
Stack-wide pools and heterogeneous units have no allocator/selector in v1 and
reject explicitly. Splits retain per-unit resources, so Q units with R charges
each still have Q×R charges across both results. No refill/reroll occurs.

Compatibility explicitly includes definition, profile, type/kind, category,
material, persistent style/dye, condition/max condition, per-unit value/weight
and semantic state. It excludes possession identity, custody, revisions, receipts,
wearer body and derived visual mapping. Both sides must be eligible. Summoned
versus ordinary, differing expiry, contents, knowledge, charges and provenance
remain separate. No generic whole-projection comparison is used.

Construction now permits mod-enabled multiple quantities while preserving its
declared item/stack identity category. Existing identities are never retyped.
An authorized semantic `intake` is a narrow provider grant with explicit profile,
type, quantity and complete state. It creates a semantic record in initial
custody; it does not invoke potion/book/currency behavior or derive contents
from structural records. The provider must supply exactly value, weight_microkg,
condition, maximum_condition, material, style and dye. Numeric properties are
nonnegative integers up to 1e9, condition cannot exceed maximum, and weight is
converted from millionths of a kilogram. Missing properties reject before grant.
The record retains `contents-runtime`, `capacity`, `tender`, `save` consumers
pending; physical value is not a currency valuation or settlement contract.
Construction recalculation/appearance/copy helpers reject
semantic records instead of substituting equipment behavior. Ordinary admitted
copies remain fresh authorized grants in initial custody, awaiting admission.
Pure recalculation uses validated current possession access, including after a
cross-context transfer outside the destination's construction grant pool. It does
not expand that grant pool or copy permission. Foreign/obsolete custody still fails.

Semantic provider/version keys and supported state rules are declared through
`StartupProviderBoundary.declare_item_collection_semantics` before DATA source
preparation. Duplicate, malformed, unavailable or late declarations fail.
DATA rejects type records naming undeclared keys/rules. Fixed `pending.*` baseline
keys describe explicitly unavailable special integrations and cannot bind a live
requester; an actual provider needs its supported declaration and a mod-published
type selection. This is a narrow readiness inventory, not an executable loader
or a second eligibility-policy override registry. Current custom providers are
controlled DEV compositions; executable MOD activation remains its existing gate.

## Requests, planning and commitment

`execute(requester, request)` requires session, context, stable request and action.
Unknown fields fail. Create additionally names a unique collection name within
the context. Insert/transfer name ID, quantity, destination and mode; target mode
also names the single destination ID. Split/consume name ID and quantity.
Batch names source/destination, mode and explicit batch_mode. There is no
clear/replace/import/native restore endpoint.

Quantities are positive integers 1..2147483647. Cap 0 means no gameplay cap;
positive caps have the same integer bound. Uncapped overflow rejects rather than
spilling into another entry. Capped automatic insertion fills stable-ID compatible
entries then creates capped remainder entries. Target mode is all into that
destination or rejection. No-stack skips merges but respects caps. A technical
staging limit of 65,536 new entries bounds a single plan; `plan_too_large` rejects
unchanged. This is separate from gameplay stack caps/carry limits.

Plans hold detached touched records. Source reduction and every destination fill
or new entry are staged together. Both ends' complete admission runs first.
After callbacks, session, retained source state/expiry and provider revision are
revalidated. The scoped operation lock rejects provider reentry, including other
construction mutations. All fresh identities are preflighted together, then
allocated together. Exhaustion burns no prefix. The callback-free owned commit
publishes quantities, custody and membership together, then retains its receipt.
Results enumerate changed IDs, before/after counts, custody and new/surviving/
retired status. No retired-reference alias is installed.

Full moves preserve identity unless fully merged. Partial movement leaves the
original on its remainder and allocates separated identities only as required.
Standalone partial split creates a fresh separate same-collection entry; it
never immediately remerges. Full-count split, including an ineligible singleton,
returns the validated original unchanged. Valid same-collection movement is an
explicit no-op after request/access/state validation. Consumption accepts exactly
one unit; final-unit removal retires the identity. None invokes effect/payment/
projectile/reward/use hooks.

Atomic batch validates cumulative plans and commits all or none. The separate
`stable_whole_entries_v1` take-what-fits profile uses stable typed numeric identity,
whole source entries only, skips ordinary exclusions and stops on technical
failure. It does **not** partially move a final entry or optimize packing. Each
completed move persists. Results retain exact moves, remaining quantities and
failure/not-attempted reasons; retry returns retained progress, never repeats
completed moves. A new explicit request may recover remaining current entries.

Request identity is requester/context/session scoped. Conflicts with construction,
copy or retained generation reject. Successful/no-op/partial results are detached
and retained before caller reentry. Ordinary precommit rejection leaves both ends
unchanged. Scope retirement clears operations, indexes and weak authorization.
No native capture/restore/no-replay claim follows from these session receipts.

## Queries, performance and gates

`projection` returns detached collection/entry state. `query` accepts only profile,
type, quest/enchanted inclusion booleans and summoned_first. Ordinary selection
uses maintained numeric identity order and stops at the first valid match.
Summoned preference uses earliest absolute expiry then identity, before ordinary
fallback. Expired candidates are excluded without cleanup. Invalid filters,
unavailable collections, missing definitions/provider errors and no_match are
distinct. Commitment always revalidates a prior selection.

Locked policy lookups cache only per-profile/type DATA records for the session;
they do not copy the entire catalog or reuse a candidate across publication.
Membership order is owner-maintained; display sorting cannot choose survivors.
Admission projections deliberately cover each complete affected collection.

Maintained qualification is `item-collections` / `item-collections-v1`, through
independent `verify_headless.ps1` and `verify_rendered.ps1`. The rendered suite
shows actual owner transfer results using a simulated diagnostic control signal;
it is not physical-device or playable-inventory testing. See increment-2 evidence
for frozen inventories, measurements, source identities and remaining checks.
Increment 3 owns real carry/wagon/tender, increment 4/native SAVE actual durable
snapshots; live equipment/loot/quest/trade/starting grants retain their named gates.
