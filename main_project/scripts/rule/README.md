# RULE numeric interfaces — IMP-006 increment 1

`pcg32.gd.create(initstate, initseq)` takes exactly four little-endian unsigned
16-bit limbs for each unsigned 64-bit input. Invalid limbs return null. Use
`unsigned64.gd.from_int` for signed bit patterns or `from_bytes` for little-endian
bytes. Constructors are not initialized sources; use the checked factories.
`raw()` returns `{ok, value}` (unsigned 32-bit integer in Godot's signed 64-bit
integer). `bounded(b)` accepts integer 1..4294967295 and returns `{ok, value,
raw_requests}`. Failed input validation draws nothing. `raw_count` excludes the
two initialization transitions; `logical_count` counts successful bounded draws.
Callers observe these counters; they must not modify source internals.

Unsigned PCG arithmetic uses four 16-bit limbs: each multiplication column fits
within 64 signed bits, carry is explicit, and high limbs are discarded. Logical
shifts never shift negative signed values. XSH-RR truncates before rotating.
The two initialization transitions match the PCG reference. No global RNG exists.

`seed_derivation.gd.derive(material, purpose)` accepts exactly 32 PackedByteArray
bytes and one of combat/progression/loot/quest; it returns checked seed limbs and
a fresh independent source. Uppercase/unknown purposes fail. `material_from_os()`
uses Godot OS.get_entropy, the OS-backed cryptographic entropy
boundary, and fails if it does not produce exactly 32 bytes. There is no fallback.
Fixtures pass explicit material. This increment does not call it during CORE
session entry or load; lifecycle publication is increment 2.

`random_mapping.gd.percentile(integer_chance, explicit_random_source)` returns
original/effective chance, inclusive roll 1..100, success and complementary failure.
Both observations reuse that value. It accepts the declared random_source.gd
interface, checks raw and bounded values, and returns explicit errors. Sources
are trusted in-process objects, not sandboxed executable providers. Classic is
intentionally not a percentile source. Gameplay owners authorize checks and retain
results; this module applies no consequences and supplies no universal history.

`classic_random.gd.create(seed)` requires integer 0..4294967295 including zero.
Each operation has its own private source. `range_value(a,b,inclusive=false)` uses
signed 32-bit endpoints and positive signed 32-bit width (1..2147483647). Invalid,
reversed, empty and overflowing widths reject before drawing. Inclusive singleton
ranges draw once. Every valid range uses exactly one raw draw and classic remainder
mapping. Raw values are 0..32767; wider ranges do not cover every position. Use
`range_value(0,max)` for DFU's one-argument exclusive form.

The retained low 32 bits are mathematically sufficient: reduction modulo 2^32
commutes with recurrence multiplication/addition; higher state bits cannot affect
bits 16..30 now or on later transitions. The product plus increment stays below
signed 64-bit maximum. Verified against local DFU numeric source, not original DOS.
No SaveSeed/RestoreSeed global or public checkpoint/save format is introduced.

PCG adaptation: Melissa O'Neill's pcg-c-basic pcg_basic.c, Apache 2.0, inspected
2026-11-20. Reference multiplier 6364136223846793005, XSH-RR shifts 18/27/59;
`PCG_LICENSE.txt` carries the license. DFU DFRandom source SHA-256
`7f2a7a7e54168b254c6da18db55de66e1e4df2e84c3e7058c712c5eddfd5047b`, local
1.1.1 release snapshot (exact Git commit unavailable), MIT in `DFU_LICENSE.txt`.
License texts are included in Windows export. No new library/native adapter.

Numeric fixture `IMP-006-numeric-v1`, scenario `randomness`, selection fixture
`randomness-v1`, runs through the shared production scene. Fixed 108 assertions.
Additional JSON vectors were independently calculated using Python arbitrary
precision masking and hashlib on 2026-11-20, after reproducing published 42/54
outputs; they include bytes 00..1f, all-ff material and unsigned seed boundaries.
These are data fixtures, not runtime RNG implementations. Every numeric expected
and actual value and logical/raw draw count is retained by the shared report.
No clock or input is used. Seed/clock/input overrides remain explicitly incomplete;
this fixed multi-seed suite cannot reinterpret a scalar seed as its fixture material.
Session ownership, successful-load preparation, retained-result integration and
formula dispatch remain gated increments 2/3; no later owner gate closes here.

## Session lifetime — IMP-006 increment 2

IMP-015 increment 2 uses an independent CHAR creation-operation source **before**
there is a gameplay session: see [creation generation](../char/CREATION_CAREER.md).
It reuses the reviewed PCG/seed derivation and retains the assigned question set.
It never acquires/activates a session stream or changes the four-purpose contract
below. The user chose DFU collision-advance sampling on 2026-11-26; validation and
navigation do not draw. Original/Unity RNG sequence equivalence is not claimed.

CORE's `SessionLifecycle` owns `randomness` (`session_randomness.gd`, interface
`session-rng-v1`). The earlier increment-1-only notes above retain their delivery
scope; the normal CORE path now initializes sources. `Core.new()` uses the accepted
OS entropy boundary. The optional constructor material-provider Callable is an
explicit trusted fixture seam, fixed at construction, returning `{ok, material}`
for a copied CORE ticket and entry mode. Wrong/short/missing material fails without
fallback. This is not a player seed setting or a configuration refresh mechanism.

The normal ordering is:

1. Admit CORE's existing new/load operation and suspend live source access.
2. Independently prepare all four candidate sources under the exact operation
   ticket. This happens before the mode provider's prepare; entropy failure leaves
   any surviving session intact and does not invoke the restore provider.
3. CORE retains the outgoing session during cancellable preflight/confirmation.
   Candidate sources cannot be acquired or drawn. Cancel/failure discards them.
4. At replacement, revoke outgoing handles before retirement subscribers and
   provider cleanup. Baseline/readiness owners restore retained facts while the
   replacement stays gated. Candidate sources remain unavailable to gameplay.
5. After real readiness/binding validation, validate the new consumer declarations,
   activate all four sources together and then publish ready/restored. Readiness
   observers see initialized sources. Duplicate/stale completions cannot activate.

`core.randomness.source(scope, consumer_object, purpose)` returns a checked handle.
The provider's readiness service inventory must explicitly list `random_purposes`
(e.g. `["progression"]`) on a ready session-lifetime owner. No declaration means
no source capability. Unknown/duplicate purposes, malformed declarations and
location-lifetime consumers reject readiness. Consumer identity is the actual
provider Object, held weakly, not a caller-supplied owner name. UI/AV/inspection
objects cannot obtain sources merely by naming a gameplay purpose. This is a
trusted in-process interface, not executable-mod sandboxing or hook registration.

Each handle rechecks consumer identity, purpose, scope, session epoch, CORE
readiness/safety, disposal and lifecycle-operation suspension on **every** raw or
bounded request. Held references cannot follow a later session. A successful
bounded request increments the underlying stream's logical count once, preserving
increment-1 rejection semantics; percentile uses the same handle interface.
Handle counters count deliveries through that handle; `snapshot().sources` reports
the actual stream counters across all of its consumers/handles.

Source availability does not authorize an attempt. Domain owners still check
simulation eligibility (or their specifically approved UI-driven generation rule),
choose ordering and retain/apply results. Pause holds preserve the sources rather
than reseeding; this participant does not invent a global ban on owner-authorized
UI generation while paused. Nothing here starts a simulation loop. Owners sharing
a purpose must establish their approved synchronous draw order; there is no
callback race ordering, per-actor stream subdivision or automatic draw rollback.

Pauses, menu layers, preferences and ordinary scene/location work do not invoke
source preparation/activation. Sources stay in the application-composed CORE
session owner. Actual WORLD/LOC transitions must retain that owner; the controlled
fixture's scene-object replacement is not a real world streaming qualification.
Title return, character replacement, death/shutdown retirement and application
disposal revoke sources. A failed post-replacement restore cannot expose its
candidate; it follows CORE's existing cleanup/recovery policy without promising
that an already retired outgoing session survives.

`snapshot()` is a detached value projection: contract, epoch, scope, preparation
context, material hex and per-purpose raw/logical counts; no source, callback or
provider reference is exposed. Inspection and mutation of the returned copy do
not draw or reseed. Captured material supports local DEV reproduction. It is not
ordinary SAVE RNG continuation state, a global gameplay log or a save schema.
Seeded diagnostic/preview generation uses separately derived isolated sources.

Retained-result verification uses `tests/controlled_random_owner.gd`, fixture
`retained-owner-v1`. This controlled owner defines legitimate reward attempts,
retains each resolved percentile, commits its fixture balance/application once,
and acknowledges delivery separately. Before-commit interruption applies nothing;
after-commit interruption retains the applied flag; retries reuse the result and
cannot repeat consequences. Fixture-only snapshot/restore retains assigned text,
pending resolutions and applied/acknowledged flags across successful load and a
fresh engine process, even when the fixture's default name changes. RULE contains
no universal retained-action registry. Actual CHAR/ITEM/QUEST/SAVE owners must
implement their own facts, identity, retention, settlement and compatibility.

Scenario `randomness-session`, fixture `randomness-session-v1`, has fixed 115
headless / 116 rendered assertions plus 15 fresh-process restoration assertions.
The controlled CORE factory uses zero and all-ff material; interleaved gameplay
vectors are compared with the pinned purpose vectors. The actual stock UI CORE
uses OS entropy; reports capture that material and assert initialization/counter
boundaries, never uniqueness or changed rolls. Fixed multi-material inputs do not
accept scalar seed/clock/input overrides. Increment 3 formula dispatch remains
behind separate user acceptance and authorization.

## Formula dispatch — IMP-006 increment 3

The application-owned `formula_registry.gd` now supplies the bounded pure integer
replacement interface and checked invocation. See [FORMULA_DISPATCH.md](FORMULA_DISPATCH.md)
for exact inputs/outputs, signatures, MOD eligibility/order, explicit omission,
menu reservation/lock, CORE/owner context, recovery and engine-error limitations.
Only the isolated fixture declares `fixture.integer`; no production gameplay hook
inventory or executable provider activation is introduced. Increments 1/2 remain
accepted and their numeric/session contracts are unchanged.
