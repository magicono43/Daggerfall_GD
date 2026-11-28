# ITEM construction and identity v1

**Increment-3 extension, 2026-11-27:** The same CORE-created authority now owns
capacity and typed monetary collaborators under the
[capacity/tender contract](ITEM_CAPACITY_TENDER_CONTRACT.md). Construction retains
the selected material result as exact `weight_nanokg` (microkg ×1,000), alongside
the existing kg projection. Monetary definitions/grants use their own actual
contracts; structural gold records and generic semantic copy do not mint funds.
The historical construction-only and pending-capacity text below records the
earlier increment scopes, not current controlled-provider qualification.

**Increment-2 extension, 2026-11-27:** The [collections contract](ITEM_COLLECTIONS_CONTRACT.md)
extends this accepted baseline with container identities, checked admission and
collection operations. Ordinary construction now carries explicit per-unit state;
mod-enabled equipment quantities preserve their declared identity category.
Current custody is validated after admission. Ordinary authorized copies become
fresh initial-custody grants awaiting admission; raw retirement cannot bypass
collection removal. Semantic-state helpers fail rather than substitute equipment
behavior. The historical increment-1-only statements below describe its accepted
scope, not the current collection delivery. Native SAVE and live owners remain pending.

IMP-017 increment 1 implements ITEM-001/003 and the construction portion of
RULE-026. This is a construction service, not a playable inventory. Collections,
equipment, combat, settlement and native SAVE support remain pending.

## Composition and authority

`StartupProviderBoundary` declares five `item-formula-v1` RULE hooks and the stock
shell registers `item.construction` alongside the accepted item/spell reader.
DATA publishes both through the existing MOD plan and actual CORE menu commit.
Failed menu entry publishes neither definitions nor formulas. Run locking,
package identity, replacement/patch precedence and captured loose overrides are
the existing DATA/MOD contracts; construction creates no second registry.

CORE creates `core.items` and retires it with its session. The stock session shell
supplies the application definition registry. A mode provider must explicitly
include `items.service_binding()` and ready requester services with
`item_contexts` in its readiness inventory. This binds ITEM's five formula hooks
and the owned `loot` stream through the existing CORE/RULE consumer interfaces.
There is no stock gameplay requester, live starting grant or all-template pool.

Each requester context is exactly `{id,custody,pool,worn,copy}`. IDs and custody
are stable keys, pool is a nonempty unique list of supported construction profile
keys, and the flags are booleans. CORE admits the actual ready requester Object;
ITEM retains a weak binding. Duplicate initial custody/context authorities fail.
These authorizations expire with the session. A source ID or possession ID alone
does not authorize access. Initial custody is `{owner: custody, context: id}`;
no container insertion, transfer, capacity admission or settlement is implied.

## Identities and requests

Base `record.definition` is DATA's originating definition identity, including
domain/package/local key. `profile`, `material`, `category`, `style`, `dye` and
`body` are stable keys in the locked construction domain and its declared maps.
Persistent identity is separately `{category: item|stack, number: decimal}`.
Construction request IDs are requester/context-scoped and session is an explicit
revocable CORE scope. Neither display names nor engine Object IDs become item IDs.
Object IDs only index weak requester bindings and transient request receipts.

The allocator supports **1..18446744073709551615**, independently for `item` and
`stack`. Zero is an invalid identity and the initial high-water sentinel. Its
decimal parser accepts canonical ASCII decimal strings only: no sign, whitespace,
leading zero, exponent, decimal point or numeric Variant. Allocation increments
decimal digits without float/int conversion. The maximum is allocated once;
subsequent requests return `identity_exhausted`. Invalid seeded state fails
explicitly, including in release builds. Allocated IDs are never released, even
when the caller does not publish them. Retirement needs no identity alias or
ever-growing tombstone list. The allocator's constructor/high-water projection
is a seam for later split/restore work, not an implemented native restore API.

`construct(owner, request)` accepts `session`, `context`, stable `request`,
`profile`, explicit `body`, `category`, positive `quantity`, optional compatible
`material`, `style` (or the declared `default` token), supported `dye`, and
authorized `condition`. Unknown fields and unsupported combinations fail.
Defaults use the profile/category/material dye and the lexically first supported
style key. No invalid explicit style is clamped. Neutral clothing/ammo reject
any material field. Ordinary equipment quantity is exactly one; arrows use a
stack identity and explicit quantity. Ordinary construction starts full;
explicit worn condition requires context authorization and 0..maximum bounds.

Complete validation/calculation precedes allocation/publication. Success retains
the request and detached committed outcome. Exact retry returns that outcome;
changed inputs with the same request identity return `request_conflict`.
Retirement of a committed result cannot make its construction request regrant it.
There are no paid grants or consumed entitlements in this increment.

`copy_possession` needs explicit copy permission and matching custody/pool. It
copies the whole supported state to a fresh identity and retains a retry receipt.
`modify` supports body/style/dye changes only, preserving identity, condition,
mechanics and unrelated state. An unchanged request leaves revision unchanged.
Material transformations, repair, effects and template reset are unavailable.
`recalculate` is a pure reconstruction from original DATA properties and returns
the retained condition and other state; it neither repairs nor replaces the item.
`retire_identity` retires an entry in initial construction custody, returning the
retired ID without reuse. It is not collection removal, consumption or transfer.
Missing/retired IDs do not redirect to a survivor. Ended-session calls reject.

`preview`, definition lookup, `inspect`, counters and generation projections
allocate no possession and consume no RNG. Public results are detached; mutating
one cannot alter definitions, an instance, another copy or retained decisions.

## DATA schema, numeric domains and appearance

`item.construction:profiles` uses `item-construction-v1` and ordinary JSON
`add/replace/patch` envelopes. Every record has schema, kind and provenance.

| Kind | Required semantic fields |
| --- | --- |
| policy | bodies, dyes, dye_adapters, clothing_dyes, categories, selector, generation |
| material | builtin.properties-v1 provider, value/weight/condition coefficients, dye, pending_consumers |
| template | accepted base template key, type, identity category, compatible materials, bodies, dyes, default_dye, category→style→resource-variant maps, visual provider/record/body archives |

Supported types are weapon, armor, clothing and ordinary neutral ammo. Coefficients
are integral 1..1,000,000. Base value and condition are nonnegative integers up
to 1e9, subject also to the accepted base reader's narrower fields. Base kilograms
are nonnegative multiples of 0.000002 kg up to 1000 kg. RULE receives weight in
millionths of a kilogram, making half-weight exact in the supported domain.
Quantity is 1..2147483647; there is no gameplay stack cap or aggregate quantity
arithmetic here. Formula outputs are nonnegative integers up to 1e15, with
selector-specific index bounds. Arithmetic intermediates remain within signed
64-bit integers. Nonfinite, fractional or unsafe inputs reject; identities never
use these floating-point JSON numeric checks.

The shipped 10-material coefficients are ITEM-003's exact approved table. Weapon
and plate value are V×factor. Weight is
`nearest_even(truncate(W*4)*q/4)/4 kg`, using integer quotient/remainder midpoint
handling; maximum condition is `truncate(C*c/4)`. Leather uses W/2 and chain 2V.
All calculations start from the original base definition. Value is not a merchant
quote; weight is per unit and does not establish carry/wagon admission.

The 106 template profiles reference the accepted 288-template packaged baseline:
11 armor, 18 non-arrow weapons, one arrow and 76 clothing definitions. Classic
zero-variant templates have one explicit base-style mapping, rather than an
invalid random 0..-1 range. Cuirass/greaves/pauldrons/gauntlets/boots use ITEM-003's
specific leather/chain/plate style inventories; helms and shields use their
template mappings. Native style keys may be descriptive and map independently
to classic variant numbers. Added materials require explicit per-template
compatibility, complete property/dye mappings and the supported provider.

Bodies explicitly map Argonian/Elf/Human/Khajiit morphology and supported male or
female source appearances. Armor uses base archive 249 male / 245 female plus
morphology offset 0/1/2/3. Female weapons use 233 instead of 234. Clothing uses
its source gender group and explicit morphology archive. Arrow appearance is
the world icon at TEXTURE.207 record 16, not a nonexistent paperdoll archive 0.
No unknown body defaults to Human; no body projection establishes equip fit.

`classic-item-appearance-v1` requires a declared archive and source record plus
variant. DATA checks **every distinct supported source tuple** through the actual
read-only classic image reader during each preparation, deduplicated within that
candidate. It retains neither pixels nor handles. Missing resources/providers
fail preparation rather than publishing partial appearances. The explicit 19-file
reader inventory is in `item_construction.gd::sources`; adding an unsupported
archive requires an early supported provider declaration, not directory discovery.
Constructor/query paths read only bounded profile/material/policy/base records.

The ten clothing dyes are Blue/Grey/Red/Dark Brown/Purple/Light Brown/White/
Aquamarine/Yellow/Green. `classic-dye-v1` mappings use DFU's declared dye codes:
clothing 0..9; Iron 15, Steel 16, Silver/Unchanged 18, Elven..Daedric 19..25.
Leather/chain retain their source texture color with unchanged code 18. Codes
10..14 and 17 are unsupported. Dyes and their mappings/defaults are replaceable;
per-item appearance projections include a detached dye adapter. This delivery
qualifies appearance selection/source references and diagnostic isolation, not a
new paperdoll UI or renderer/shader implementation.

DFU's historical Chain2 (0x0103) is not a new native category. Its shared chain
style interpretation is covered by the chain style inventory. The construction
API accepts the stable `chain` category and applies approved 2V chain properties;
it does not accept or guess raw saved Chain2 material semantics. Raw legacy save
conversion and any explicit compatibility migration remain future work.

## Generation, selectors and RULE overrides

`generate` requires exactly session/context/request/body/level. Level is integral
-1,000,000..1,000,000; caller context authorizes the explicit pool. No global
player lookup, loot policy, restock rule or starting grant is introduced.

DATA declares uniform template/style/dye choices and inclusive random ammo bounds
(baseline 1..20). Single-option choices use no random draw. The owned source is
CORE's session `loot` purpose. Decision order is template → armor category →
material only for a material-bearing category/weapon → style → clothing dye →
ammo quantity. Baseline armor is precisely 69/20/11 and only plate draws a
material. Every raw resolved draw and mapped decision is retained before the
next fallible step. A technical retry resumes unresolved work; no rejection
sampling, category redraw, quantity redraw or duplicate grant occurs. Unsupported
selected mappings fail with retained decisions, never an iron/default substitute.

The baseline material selector uses raw 0..255, pivot 10, slopes 4 below / 2 above,
clamp 0..256 and strict `entry < remaining` traversal of
64/128/10/21/13/8/5/3/2/5. Its entries are not normalized weights. Ordered unique
material IDs, nonnegative bounded entries, complete endpoint coverage and category
chances totaling 100 are validated. Zero entries are supported with the actual
strict traversal semantics; a first zero can still select X=0. Pivot/slopes are
integers 0..1000; table/key arrays are bounded to 1024 entries. Alternative
conventional distributions must be explicit replacement providers within the
declared raw-domain contract; unsupported sampling modes do not silently normalize.

Hooks are pure synchronous standard unbound RefCounted `(Dictionary)->int`
replacements: `item.value`, `item.weight`, `item.condition`, `item.material`,
`item.category`. Property inputs are exactly base/mode/coefficients; selector
inputs are exactly raw/level/policy. No source, owner Object, item or custody is
passed. MOD validates provider identity/order/signature before publication. One
winner executes; invalid output/callback/stale context stops the operation,
enters CORE service recovery and retains the selected provider without fallback.
Purity remains the trusted-provider contract, not a proof about arbitrary code.

`distribution` enumerates all 256 material raw inputs and 100 category inputs
through the **selected published hooks**, returning counts/denominators and an
explicit enumeration label. It neither allocates nor advances a live source.
Conditional armor mass is category count/100 × the plate material count/256.
This is isolated inspection, not tableEntry/sum or a claim about original RNG.

## Verification and deferred consumers

Use maintained DEV-014 suites `item-construction` / `item-construction-v1`, with
independent `verify_headless.ps1` and `verify_rendered.ps1` commands and explicit
classic source. The exact inventories live in `item_construction_inventory.json`.
The rendered case captures a diagnostic comparison of independently owned
appearance records; it does not claim physical-device gameplay testing.

The fixture requester supplies authorization and controlled session readiness;
DATA publication, ITEM ownership, selected RULE dispatch, source image validation,
CORE scopes and purpose-owned RNG are real. The adversarial category callback
deliberately suspends the live source after resolving plate to exercise partial
retry. A separate invalid output exercises required-service recovery.

Native capture/restore, pending-generation persistence, duplicate restored-ID
validation, branch counter restoration and migration are increment 4 / IMP-023.
Material registration leaves combat, equipment and SAVE consumers explicitly
pending. Collections/split/merge/removal are increment 2; capacity/tender are 3.
Live starting grants, loot, rewards and trade retain their named IMP gates.
The increment evidence owns the verification/deferred-check ledger.
