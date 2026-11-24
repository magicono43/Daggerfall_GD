# Formula dispatch — IMP-006 increment 3

## IMP-016 production actor contracts

`StartupProviderBoundary` declares all actor hooks before preparation. DATA's
`actor.baseline:policy#player` publishes permanent bounds, attribute caps and the
career multiplier table through shipped → MOD → captured loose publication. No
second registry, post-lock declaration or expression language exists.

`actor-rational-v1` reflects exactly `(Dictionary) -> int`, standard unbound
RefCounted method, no defaults/varargs. Input has exactly `value` (integer ±1e9),
`numerator` (integer 0..1e6), `denominator` (integer 1..1e6). Ratios are exact;
decimal career multipliers cannot silently use the fixture integer signature.
CHAR supplies 1/1 except for magicka. Inputs are detached before calling. Output
is integer ±1e15, with CHAR compatibility checks for positive health, nonnegative
capacity/base magicka and vital maxima ≤1e9. All built-in products fit int64;
division corrects negative remainders to implement mathematical floor.

| Hook | Built-in | Input context |
| --- | --- | --- |
| char.damage | floor((value−50)/5) | live Strength |
| char.capacity | floor(3×value/2) | live Strength; final encumbrance stays ITEM/MOVE |
| char.magicka | floor(value×numerator/denominator) | live Intelligence, career ratio |
| char.resistance | floor(value/10) | live Willpower; not resistance chance |
| char.agility | floor(value/10)−5 | live Agility; not complete attack resolution |
| char.growth | floor(value/10)−5 | permanent Endurance; prospective only |
| char.healing | floor(value/10)−5 | live Endurance; not complete recovery |
| char.initial-health | 25+value | career HP-per-level, ordinary level 1 |

Callbacks are pure/synchronous and receive no owners, RNG or session objects.
The existing registry selects one provider in checked MOD order, locks it with
DATA at actual menu entry, monitors runtime errors and rechecks CORE/owner context
after calling. Errors/invalid results/retired callbacks never fall back. Built-in
objects are retained for application lifetime: Callables do not retain RefCounted
receivers. Projections expose per-hook contracts and locked provider provenance.

`replace_stage` repairs one provider's whole staged contribution before lock. It
invalidates candidates/omissions; duplicate ordinary staging still fails. Invalid
hook selection returns before expensive DATA preparation, preserving any prior
valid DATA candidate. Valid requests still rebuild clean DATA under exact-ticket
commit checks. No published candidate is edited or reused without validation.

CORE's narrow `actor_formula_valid` admission recognizes only composed CHAR,
these hooks, a safe current scope and exact baseline/initialization ticket. It
grants no RNG or full-entry readiness. Ready sessions use ordinary declared
formula service bindings. CHAR checks its own operation/content around callbacks.
Retirement/failure preserves consistent state; CORE controls milestones/holds.
See the [CHAR schema](../char/README.md), actor provenance and independent
`tests/actor_state_observation.json`. IMP-050/051 executable admission remains open.

The initial bounded interface is `integer-formula-v1`; IMP-016 adds the focused
`actor-rational-v1` contracts below in the same registry. RULE owns declarations,
validation, selection, checked invocation and provenance; MOD owns selected package
identity, eligibility and resolved order; CORE owns menu publication and current
session/owner admission. DATA retains its existing schema/publication authority.
No executable package code is loaded by this interface.

## Initial hook contract

Only isolated fixtures declare `fixture.integer`. The ordinary application now
declares the eight approved actor helpers below, without complete action rules.
`declare_integer_hook(id, builtin)` declares a replacement hook using this exact
contract before contributions are staged. Stable IDs reuse the MOD ID validator.

| Property | Contract for fixture.integer |
| --- | --- |
| Input | One signed integer in -1000..1000; no fractional conversion |
| Output | One signed integer in -1000000..1000000 |
| Semantics | One whole pure calculation replacement; no additive composition |
| Built-in | x * 2 (input 7 -> 14) |
| Controlled A / B | x + 100 / x + 200 (7 -> 107 / 207) |
| Allowed mutations | No gameplay/state mutations; fixture call counters are diagnostic instrumentation |
| Randomness | None; no RNG/source/session objects are passed to callbacks |
| Timing | Synchronous main-thread method, no await/deferred execution |
| Runtime failure | Stop the affected owner operation; gate its current session into CORE recovery; keep locked provider; no retry or fallback invocation |

Callbacks are standard unbound methods on application-owned RefCounted providers.
Reflection must report exactly one TYPE_INT argument, TYPE_INT return, no default
arguments, no varargs and no bound/unbound argument transformations. Reflection
validates the signature without executing a callback. It does not prove arbitrary
code purity or synchronous behavior; these are trusted provider obligations.
Actual executable admission/sandboxing/lifecycle remains IMP-050/051.

## Staging, eligibility and explicit recovery

`stage(provider_id, expected_version, entries, integration="")` stages a trusted
contribution. Each entry is `{hook, contract:"integer-formula-v1", callback}`.
Staging is explicitly unvalidated, not a successful provider admission. These
Callables are supplied by application code/controlled fixtures, never read or
executed from package files. Repeated staging does not replace an earlier entry:
same-provider/same-hook duplicates block preflight even with identical methods.

`prepare(mods)` starts a clean candidate with a fresh ticket. It revalidates the
real MOD plan and calls MOD's `formula_provider` for each contribution. The ID
must be the selected enabled package with the expected exact version in resolved
order. Optional integration keys must be eligible for hooks through MOD's existing
integration contract. Missing, disabled, stale-version or ineligible providers,
unknown hook IDs, bad signatures, duplicate registrations and empty contributions
are blocking errors with provider/hook context. A contribution is not silently
filtered because a later provider could otherwise win.

Only after all registrations validate does selection walk **resolved MOD order**;
the last registered replacement in that order wins. Arrival order is irrelevant.
No eligible replacement selects the declared built-in at preflight. That normal
default selection is distinct from a forbidden fallback after runtime failure.
Failed candidates expose issues and no winners; no normal invocation is possible.
Candidate/active projections strip all Callables and provider Objects.

The explicit recovery unit is the provider's **whole formula-hook contribution**,
including all entries/staging calls, not one bad callback and not its whole package.
`omit(provider,ticket,mods)` requires the current failed candidate and exact MOD /
registration input. It clears the candidate. The next prepare revalidates package
dependencies, remaining registrations and definitions and rebuilds clean winners /
provenance. MOD revision/input or new staging invalidates omission choices. An
invalid dependency plan discards obsolete formula candidates. Omission does not
activate/disable executable code or bypass required capabilities/references.

The existing setup UI reports formula provider/hook errors and offers explicit
whole-contribution omission. Valid conflicts/defaults do not create blocking
popups. Users can instead repair/reconfigure and rebuild through normal setup.

## Actual main-menu publication

`StartupProviderBoundary` owns the registry for the application. Its normal
`prepare_content` prepares formula declarations against MOD before DATA validation;
both must succeed. CORE's existing menu transaction reserves the exact DATA and
formula tickets plus MOD mutation admission before calling menu readiness or
persisting profile/history. Menu or persistence failure releases both reservations
and publishes neither. Reentrant stage/prepare/omission/Continue requests cannot
replace a reserved candidate. After successful persistence, only non-fallible
assignment steps remain: publish DATA and formulas, lock MOD, mark actual menu
entry. No callback or fallible I/O is added after the durable profile step.

Returning to title/setup, changing character, loading and ordinary preferences
cannot change declarations, registrations, selected providers or provenance.
Only application disposal clears the registry. The lock includes an empty hook
set; later gameplay owners cannot add production hooks after entering the menu.
`active()` is a detached projection, including the latest failure for diagnostics.
It never invokes a callback. This is not a global gameplay history or SAVE schema.

## Current-session/operation binding

The composed `SessionShell` binds CORE to its application's registry. Readiness
services can explicitly declare `formula_hooks` for a session-lifetime consumer
Object implementing pure `formula_operation_current(operation: Dictionary) -> bool`.
CORE requires each hook to be published in that application; duplicate/invalid
bindings and unavailable hooks reject readiness before gameplay. A declaration
never grants UI/AV or an arbitrary caller implicit gameplay authority.

`invoke(hook,input,core,owner,scope,operation)` checks the application instance,
current ready/safe scope, bound consumer identity, stable CORE admission (not busy,
publishing or finishing), plain-value operation context and the owner's current
operation predicate before invocation. The callback receives only the integer.
It rechecks context after invocation before returning a usable value. Old scopes,
old owner operations, foreign registries, ended sessions and obsolete completions
cannot apply a value to another operation. CORE clears consumer bindings at
retirement and disposal. Domain owners still authorize legitimate attempts and
retain/apply results; RULE does not invent universal gameplay action IDs.

The controlled owner applies a returned value only on `ok=true` and ends its own
operation on success or failure. Runtime failure calls CORE's existing
`required_service_lost` recovery boundary, so a blind retry cannot invoke the
winner again. The owner must abandon/recover the failed operation and use safe
session teardown/application restart; there is no provider removal or automatic
roll/state rollback. Registry winners remain locked throughout recovery.

## Checked GDScript invocation and limitations

Godot 4.7.2 has no GDScript throw/try-catch facility. A genuine engine-raised
script error aborts the callback but may return a valid-looking default integer
**0** to Callable.call. Checking only the returned value would be incorrect.
The invoker therefore registers a scoped `Logger` observer around exactly one
synchronous call, removes it afterward, and checks captured non-warning engine
errors **before** validating the returned integer domain. Captured errors produce
`callback_error`; a successful call returning 1000001 produces `invalid_result`.
The result identifies selected hook/provider, session/operation and error metadata.
Diagnostics never call the selected method again, nor any earlier/built-in method.

Release exports compile out some VM access checks: a missing Dictionary key can
produce 0 without an emitted error. The monitor cannot detect silent within-domain
semantic mistakes. Supported providers must validate their own preconditions; this
interface does not promise arbitrary executable correctness. The fixture now uses
a failed native JSON parse (observable in all builds) followed by access to its
failed result. Editor/debug builds additionally demonstrate a real VM callback
abort; release builds separately verify checked native execution-error handling.
The original Dictionary-only release attempt stayed incomplete and is not counted
as a passing thrown-callback check.

The logger does not suppress console diagnostics. It conservatively observes
non-warning errors during the synchronous window, including a coincident engine
error; it is not an exception sandbox or attribution proof for arbitrary worker
threads. Callbacks must not yield/start asynchronous work. A returned non-integer
coroutine/object fails output validation; arbitrary late side effects/native
crashes cannot be undone/caught by this mechanism. Provider trust and executable
isolation remain later owner/runtime contracts. Crashes/timeouts/missing output
remain incomplete verification outcomes.

`formula-fault` deliberately triggers the native parser failure, then a real VM
callback abort in editor/debug builds. The shared/export harness matches the
complete captured parser diagnostic and native log site in every build, plus the
exact script diagnostic/function/res:// source/line in debug builds. The complete
fixed assertion inventory and build-mode evidence are required. Extra/unmatched
native parser or script diagnostics invalidate the run; all import errors and
unrelated script errors remain disallowed. `formula-extra-error-v1` emits another
native/parser and debug script error outside invocation; it remains incomplete /
exit 2. `qualify_formula_errors.ps1` checks editor child exits and report/error
counts; the release export's explicit `-FormulaExtraError` check verifies rejection
when the VM check is absent. This is not a generic allow-script-errors option.

## Verification boundaries

`formula-v1`: primary scenario `formula` has 82 headless / 84 rendered assertions;
`formula-fault` has 18 in either mode. Actual MOD folder discovery/selection,
dependency/order checks, classic readers, DATA adapters, menu/profile persistence
and application locks are used. Callables and gameplay owners are controlled
fixtures with pinned outputs; no package code or production formula is activated.
Session fixtures use explicit zero material and no gameplay RNG draws. The actual
classic source is required read-only. Seed/clock/input overrides remain explicitly
unsupported for the fixed fixture rather than silently ignored. Exact commands,
report/build identities and remaining real-owner gates are in IMP-006 evidence.
