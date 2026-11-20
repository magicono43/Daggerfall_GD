# Shared verification — IMP-003 / DEV-014

Use PowerShell 7 (verified host 7.6.9). Build the pinned native adapter first
(`../native/storage/README.md`). From the
repository root, independently invoke:

```powershell
./main_project/tools/verify_headless.ps1 -Suite m1 -Fixture m1-v1
./main_project/tools/verify_rendered.ps1 -Suite m1 -Fixture m1-v1
```

`m1` selects `qualification`, `startup`, and `session`. Select one with
`-Scenario session` or `-Suite session`; PowerShell also accepts an array such as
`-Scenario @('startup','session')`. Each scenario gets its own process, fresh
startup storage seam and engine APPDATA/LOCALAPPDATA roots. The process retains
the production native lease until normal shell disposal/process exit. Environment
values are restored in `finally`; reports are retained, never cleaned on exit.
The runner copies current game resources and the built native adapter into the
run's disposable `project/`, excluding prior evidence, toolchains and caches.
Import and launch use that copy's existing normal scene, isolating `.godot` as
well as engine user state. Scenario roots live inside that copy's `tests/.runs/`
to preserve the production fixture-path guard. Source code remains authoritative
in `main_project/`; the copy is retained evidence, not a second source project.
When `-Godot` names the Windows console launcher, its paired engine executable
is used directly when available; the report records the actual executable. This
keeps process/stream lifetime and timeout ownership with the engine itself.
Import has a 60-iteration bound in addition to the wall-time bound; scenario
result inventories and script-error checks still decide whether checks finished.
Invoke these commands sequentially. Concurrent Windows editor imports were not
reliable in qualification and are unsupported; timeouts remain incomplete.
Isolated caches/roots preserve evidence even for rejected overlapping attempts.

Qualification and deliberately unavailable scenarios:

```powershell
./main_project/tools/verify_headless.ps1 -Scenario qualification -Fixture m1-v1
./main_project/tools/verify_rendered.ps1 -Scenario qualification -Fixture m1-v1
./main_project/tools/verify_headless.ps1 -Scenario qualification -Fixture assert-fail-v1
./main_project/tools/verify_rendered.ps1 -Scenario qualification -Fixture assert-fail-v1
./main_project/tools/verify_headless.ps1 -Scenario native-failed-restore -Fixture m1-v1
./main_project/tools/verify_rendered.ps1 -Scenario native-failed-restore -Fixture m1-v1
./main_project/tools/qualify_verification.ps1
```

Exit codes are 0 passed, 1 assertion failure, 2 incomplete. `assert-fail-v1`
asserts expected integer 1 against actual 0. Its scenario result is **failed**;
only the separate qualification check expects that failure. The qualification
command checks both process exit codes and report contents for all six cases.
Unknown suites/scenarios/fixtures are required and incomplete, never skipped to
green. `native-failed-restore`, `enemy-placement-combat` (M2),
`quest-fault-retry` (M3), and rule/conversion vectors await real owner registration.
Controlled session preparation tests do not count as real native restore.

The commands accept `-Godot`, `-TimeoutSeconds` (default 120 per child), and
`-Seed`, `-Clock`, `-InputSequence`. Current M1 scenarios use bounded fixed
vectors, explicit eligible-time deltas and deliberate input batches inside the
adopted owner fixtures, and consume no RNG/game clock. Explicit overrides return
incomplete until a scenario implements those controls; they are never silently
accepted or applied as production defaults. Owner scenarios must document units,
input schema and supported overrides when registered. The harness qualification
does not implement a replacement RNG, time owner or gameplay dispatcher.

`tests/.runs/verification-<mode>-<guid>/report.json` identifies selected scenarios,
fixture, inputs, unique roots, engine version, native/project/source SHA-256s,
Git revision/dirty status, per-scenario engine exit and aggregate status. Its
`reproduction.command` and structured `arguments` reproduce the selection with
fresh storage. Nested owner results retain stable owner fixture identities and
all assertions; PNGs and logs are beside each scenario's fixture/result files.
The fixed v1 assertion inventories are checked to reject truncated results.
Missing/malformed reports, script errors, timeouts, crashes and wrong renderer
cannot pass. Timeout termination targets only the runner's child process tree.
Version/import/native prerequisites fail incomplete and retain their diagnostics.
No particular CI service is required; launch either entry script with `pwsh -File`
and consume its process exit and printed report path.

Existing `verify_startup.ps1` and `verify_session.ps1` remain compatible local
invocations. The shared runner adopts their underlying GDScript fixtures through
the same normal startup scene, without calling their wrappers or duplicating
owner behavior. Prefer the shared entry points for routine gates. The separate
`verify_storage_processes.ps1` and `verify_startup_export.ps1` remain required for
native process/alias/interruption or exported startup changes respectively; they
cover different boundaries and are not full shared-suite exports.

## Retained owner fixture documentation

## IMP-005 increment 1 — discovery and selection

Build the unchanged pinned toolchain with `./main_project/tools/build_storage.ps1`
first. Sequential Windows commands from the repository root:

```powershell
./main_project/tools/verify_headless.ps1 -Scenario mods -Fixture mods-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_rendered.ps1 -Scenario mods -Fixture mods-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration debug -ClassicSource C:/Games/Daggerfall/arena2 -ModDiscovery
./main_project/tools/verify_startup_export.ps1 -Configuration release -ClassicSource C:/Games/Daggerfall/arena2 -ModDiscovery
```

`-Suite mods` also selects the scenario. The original `m1` selection/inventories
are preserved. The explicit available classic source is required; omission is
incomplete/exit 2. It uses the existing source READ guards and before/after hashes.
The new native `inspect` operation requires rebuilding the existing DLL; no new
library/runtime or compiler pin is introduced. Import script errors now stop the
shared runner before attempting scenarios.

Fixed first-process inventories: **119 headless / 136 rendered**, plus **8**
fresh-launch assertions in a separate engine process using the same disposable
storage. Reports retain both terminal results and process exits. Restore verifies
saved selection, fresh editable configuration, persisted duplicate decisions,
discarded unsaved drafts/run omissions and a newly installed disabled ID.
No player storage or installed classic data is a writable fixture.

`mods-v1` generates `fixture.a` folder 1.0.0; `fixture.b` ZIP 1.0.0 with declared
dependency on A and data/executable capability metadata; and A-copy versions
1.0.0/1.1.0/1.2.0 for duplicate-set transitions. `fixture.fresh` is installed just
before the fresh process. Malformed, wrapped, escaping, normalized-collision,
symlink, linked-folder/hard-link, invalid-field, invalid-UTF-8/BOM/oversize and
Windows exclusively locked ZIP vectors are generated independently. Root-is-file,
missing-root, standard/portable/explicit fallback, damaged/unfinished stores and
failed stage/replacement tests use real CORE-selected disposable storage leases.

Rendered cases focus and scroll stock buttons, inject Enter press/release across
frames, and exercise rescan, profile create/rename/duplicate/enable/save, canceled
and confirmed deletion, duplicate skip and root Retry/run-empty recovery.
Text entry and dialog response signals are controlled. Root recovery presents
the stock view bound to a separately CORE-selected leased fixture root. PNGs
`mods-selection`, `mods-profile`, `mods-duplicate`, `mods-skip` and
`mods-root-recovery` are retained for visual inspection. This is scripted rendered
verification, not a human keyboard/folder-navigation playtest or ACL experiment.

Real classic DATA readers now pass through the delivered dependency planner to
the stock unavailable definition-publication gate; no controlled downstream
success provider is installed in this scenario. No sort preview or actual
main-menu publication/lock is asserted by this increment-1 scenario: planning
checks have their own increment-2 selection below, and publication remains gated.
SAVE compatibility, executable activation
and exported asset-reference semantics retain their later real-owner gates.
See the [package/profile contract](../scripts/mod/README.md).

## IMP-005 increment 2 — dependency planning

User accepted increment 1 and authorized increment 2 on 2026-11-20. Run these
commands sequentially; retain the existing Godot/native build pins:

```powershell
./main_project/tools/verify_headless.ps1 -Scenario planning -Fixture planning-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_rendered.ps1 -Scenario planning -Fixture planning-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration debug -ClassicSource C:/Games/Daggerfall/arena2 -DependencyPlanning
./main_project/tools/verify_startup_export.ps1 -Configuration release -ClassicSource C:/Games/Daggerfall/arena2 -DependencyPlanning
```

`-Suite planning` is also supported. Original M1/classic/mods selections and
fixed inventories remain registered. `-DependencyPlanning` and `-ModDiscovery`
are separate export selections; do not combine them. Explicit real source input
is required. Each invocation uses disposable CORE storage, process-held leases,
engine/project isolation and retained structured reports. Classic READ guards
and before/after hashes cover both first and fresh engine processes. Seed/clock/
input overrides remain unsupported/incomplete; this fixture uses fixed vectors.

Fixed inventories: **87 headless / 101 rendered**, plus **8** checks in an
independent fresh engine process on the same disposable storage. The fixture
generates A (`plan.a`) and C (`plan.c`) folders and B (`plan.b`) ZIP, rewrites
manifest declarations/versions and explicitly rescans. Profiles are created through
MOD requests. Covers provider-first chains, missing/disabled/incompatible required
providers, explicit enablement and newly exposed prerequisites, inclusive lower/
exclusive upper bounds, prereleases/build metadata/large decimal versions,
inactive optional relationships and warnings, presence-only constraints, stable
sort/dismissal/acceptance and stale/repeated tickets, required/self/multiple cycles,
optional cycle suppression, changed source-declaration bindings and revision-bound
contribution/hook admission. No package code or future domain schema is executed.

The first process leaves a saved cycle with an explicitly suppressed optional
edge, then makes unsaved selection/run-skip changes. The second process restores
saved enablement, discards run choices, revalidates the cycle and remains editable
in real dependency recovery. Neither process claims actual menu publication.

Rendered tests focus/scroll stock buttons, inject Enter press/release across
frames and retain `planning-preview.png`, `planning-cycle.png` and
`planning-suppressed.png` for visual inspection. Preview dismissal and acceptance,
explicit provider enablement, optional suppression and Validate and Continue use
the normal pre-menu UI. A valid real plan still stops at the unavailable DATA
publication provider while classic reader identity is retained. No controlled
downstream success is installed. Hook/contribution tests exercise admission
interfaces only; actual DATA/executable integrations remain with later owners.

## IMP-005 increment 3 — real definition publication

The user accepted increment 2 and authorized this increment on 2026-11-20.
From the repository root, run the independent commands sequentially:

```powershell
./main_project/tools/verify_headless.ps1 -Scenario publication -Fixture publication-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_rendered.ps1 -Scenario publication -Fixture publication-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration debug -ClassicSource C:/Games/Daggerfall/arena2 -DefinitionPublication
./main_project/tools/verify_startup_export.ps1 -Configuration release -ClassicSource C:/Games/Daggerfall/arena2 -DefinitionPublication
```

`-Suite publication` also selects it. Each export invocation selects one of
`-ModDiscovery`, `-DependencyPlanning`, `-DefinitionPublication`. No engine/native
pin, compiler or runtime changed. Existing scenario selections/inventories remain.
Required source/fixture/control unavailability remains incomplete, never skipped.

Fixed inventories: **111 headless / 117 rendered**, plus **8** fresh-process
assertions per mode. Fixtures register trusted `fixture.records` and add-only
`fixture.limited` schemas before classic preparation. A real required ARCH3D BSA
declaration participates in the composed classic manifest. These schemas are
bounded verification content, not IMP-007–010 production domains. Real CORE,
MOD discovery/planning, DATA definition publication and classic readers use the
normal startup/menu route; no successful DATA/menu result is replaced by a mock.
CHAR/WORLD preparation and CORE load-entry preparation are controlled only for
the named post-publication session-lifetime checks, not real SAVE compatibility.

Generated `pub.a` folder and `pub.b` ZIP declare real contribution paths, versions,
capabilities and dependency order. Adapter-declared shipped fixtures, mod add/
replace/patch files and active-root Overrides verify deterministic precedence,
same-basename and same-local-ID separation, GAD-01 origin retention, field winners,
list/nested/null rules, whole-contribution late rejection, explicit omission and
remaining reference validation. Missing/unreadable/invalid/ambiguous paths,
unsupported operations/executable capabilities, stale candidates/omissions,
clean repeated builds and suppressed integration DATA admission are covered.
All writable fixtures live in fresh leased disposable CORE storage, with isolated
engine/project copies and retained reports. Source READ guards/hashes cover
both engine processes; no player Mods/profile or classic data is changed.

Publication/menu/profile failure injections preserve committed profiles, pending
edits and unpublished DATA, and cannot lock the run. Reentrant mutation/preparation/
Continue reject during the reserved menu transaction. Separate CORE contexts
verify Save and Continue versus Continue for This Run. The actual menu publishes
the exact validated state, advances profile history only in that transaction and
locks configuration. Two controlled characters plus a controlled CORE load entry
retain plan/definition/reader identities through title return. Locked Setup does
not unlock. Fresh-process checks restore saved state, drop run-only enablement,
remain editable, and adopt a previously edited loose override only after restart.

Rendered stock buttons receive focused Enter press/release across frames. Retained
PNGs show `publication-rejection`, `publication-unsaved` and the actual
`publication-main-menu`; agent visual inspection checks readable paths, recovery
choices and title entry. This is scripted rendered verification, not a human
playtest or real character/save restore. No executable mod runs. Normal builds
without real domain adapters still report unavailable instead of successful empty
definitions. SAVE-017 and later schemas/executable providers remain open, and
bounded publication success does not mark all of M1 complete.

See the [publication contract](../scripts/data/DEFINITION_PUBLICATION.md).

## IMP-004 classic-source registration

Run sequentially from the repository root, with the real source supplied locally:

```powershell
pwsh -NoProfile -File ./main_project/tools/verify_headless.ps1 -Scenario classic -Fixture classic-v1 -ClassicSource C:/Games/Daggerfall
pwsh -NoProfile -File ./main_project/tools/verify_rendered.ps1 -Scenario classic -Fixture classic-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration debug -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration release -ClassicSource C:/Games/Daggerfall/arena2
```

`-Suite classic` also selects this scenario. `m1` retains the original three
scenarios and `m1-v1` fixture; run the additional `classic-v1` scenario explicitly.
There is no machine-specific source default. ARENA2 and its immediate parent are
accepted; the runner records the invocation and actual selected root separately.
A missing/unavailable real fixture produces incomplete/exit 2, never a skipped
pass. Seed/clock/input overrides remain unsupported/incomplete: this fixture uses
fixed filesystem/owner inputs and no game RNG or clock.

The fixed terminal inventory is **97 headless / 100 rendered** assertions. Reports
retain source-file hashes before/after, raw record ordinal and stored identity,
payload SHA-256/offset/length, supported directory types, counts as observations,
validation timing, source build hashes and production storage/process identity.
Counts, hashes and original payload values are evidence, not validation rules.
Windows parent-process READ handles sharing only READ deny source write opens
during the engine check. Required-source access succeeds under that restriction;
the production reader opens exclusively `FileAccess.READ`. A separate disposable
valid BSA is locked with `FileShare.None` to exercise an actual unreadable file.
Source guards and the unreadable lock are disposed in `finally`.

Fixtures are generated only inside the isolated run: numeric/named and duplicate
indexes; zero/changed populations; extra unrelated files; missing/empty/truncated/
unsupported sources; out-of-bounds extents; validation-to-initialization mutation;
repeated cleanup/retry; post-initialization disappearance/length changes. They
exercise unpublished access, differentiated failures, stale publication tickets,
undeclared enabled capabilities, canceled/invalid selections, initial and later
settings-write failure, and pending-until-restart reader retention. CORE's delivered
lifecycle checks two controlled character/menu transitions against real DATA
reader identity. CHAR/WORLD preparation remains explicitly controlled.

Rendered checks use the real setup FileDialog's `dir_selected` signal for invalid
and supported sources across frame boundaries, and capture combined mandatory
setup failures and valid-DATA/stock-package recovery. This is scripted UI and
agent visual inspection, not a human Windows folder-navigation playtest.
Stock IMP-005 rejection is asserted before an explicitly test-only package-success
provider is installed for settings/lifetime interface cases. No controlled result
counts as a real MOD/DATA M1 publication pass. See the
[manifest/access contract](../scripts/data/README.md) and
[execution evidence](../../design_docs/development/evidence/IMP-004-2026-11-19.md).

The export wrapper retains its existing startup smoke mode without `-ClassicSource`.
With that argument it runs the same complete classic scenario independently in
headless and rendered exported processes, checks terminal inventories/script
errors/source hashes, and retains results. Export/import now use a disposable
project copy as well as isolated game/engine roots. Windows native storage code
and build pins remain unchanged; process qualification is still separate.

## IMP-002 session and input gates

After building the existing native storage adapter, independently run from the
repository root:

```powershell
./main_project/tools/verify_session.ps1 -Mode headless
./main_project/tools/verify_session.ps1 -Mode rendered
```

These use the normal startup scene and explicitly selected controlled providers.
Each run creates fresh game and engine roots under `tests/.runs/session-*`, with
JSON assertion/build/input evidence and separate rendered PNGs. The runner fails
on a missing report or any failed assertion. It restores APPDATA/LOCALAPPDATA.
The suite covers busy/cancel/replacement/unsafe-cleanup, obsolete callbacks,
independent holds, modal/response identity, notification reentrancy, cadence
interruption and normal title/pause/settings/prompt/exit-recovery controls.

Rendered buttons receive deliberate Enter press/release through Godot input;
headless buttons emit their production pressed signal. Text drafts and simulation
deltas are controlled directly. This is not real character/restore/playback/input
provider qualification or physical IME/controller testing. IMP-003 adopts these
fixtures through the shared commands above.
The fixture's 0.1-second cadence and two-consumer work allowance are not defaults.
The final shutdown write-failure case intentionally retains its injection until
report publication/test exit; it does not claim a successful orderly save exit.
See [IMP-002 evidence](../../design_docs/development/evidence/IMP-002-2026-11-19.md).

## IMP-001 startup

These fixtures exercise the normal `startup.tscn` entry and its production owner
requests and are now adopted by the IMP-003 shared runner. Build the native
adapter first; see `../native/storage/README.md`.

From the repository root, on Windows with Godot 4.7.2:

```powershell
./main_project/tools/verify_startup.ps1 -Mode headless
./main_project/tools/verify_startup.ps1 -Mode rendered
./main_project/tools/verify_storage_processes.ps1
./main_project/tools/verify_startup_export.ps1 -Configuration debug
./main_project/tools/verify_startup_export.ps1 -Configuration release
```

`-Godot` overrides the executable location. Export verification accepts
`-Templates` for an installed 4.7.2 template directory. Commands import the project
as needed, preserve the invoking shell's environment, allocate fresh roots under
`tests/.runs/`, redirect engine per-user state there, retain JSON/console evidence,
and return failure when the result is absent or failed. Do not run import/export
commands concurrently against one project cache. Outputs and exports are ignored.

The main scene accepts `-- --startup-fixture=<absolute JSON file>`. Its `sandbox`
must be a child of `res://tests/.runs/` (the executable's `tests/.runs/` in exports).
Fixtures use separate `executable/` and `user/` directories. The ordinary player
directory is never used. Process fixtures terminate only their own child handles.
In regular editor runs, storage defaults to the separate provisional
`Daggerfall GD Development` per-user directory. `--use-player-storage` is the
explicit development opt-in to player storage, still requiring the same lease.

`controlled_startup_provider.gd` returns bounded success/failure results for
classic source, package publication and menu creation. It is not a classic-data
validator or package implementation. The default production boundary now supplies
real IMP-004 DATA validation/readers; IMP-005 publication remains unavailable and
cannot reach menu readiness without its real provider. These retained controlled
startup fixtures do not read classic assets; the separate classic scenario does.

Rendered checks save recovery PNGs and drive mouse events through Retry, explicit
fallback, Settings/Setup, staged editing, Apply and Cancel. Inspect PNGs for layout;
passing owner assertions alone do not establish visual quality. Required directory
I/O failure uses a file at the directory path, avoiding ACL changes on any player
profile. Additional I/O seams inject named failures and process interruption at
specific publication boundaries. Logger cap fixtures use a reduced byte budget
through the same production algorithm and separately assert the 200 MiB constant.

INI uses Godot's UTF-8 ConfigFile dialect, with quoted strings, booleans and integer
format version 1. Unknown defined entries are retained but never applied; comments
and whitespace need not be retained. As in ConfigFile, `null` denotes an omitted
entry. There is no prior format to migrate yet: unsupported integer versions
require explicit preservation/reset. Malformed/missing version metadata follows
damaged-input recovery. Owner declarations in this slice support live, next-launch
and restart timing; future session/location/display consumers require their own
contracts and integration rather than silently acquiring guessed behavior.

The synthetic corrupt INIs intentionally produce parser diagnostics in the engine
console. The game logger redacts their input contents. The sandbox may also report
an unavailable Windows root-certificate store before game startup; this task does
not use networking. Neither diagnostic is counted as a failed fixture assertion.

Still required at M1: run the same startup routes with real IMP-004 DATA and
IMP-005 MOD/DATA results. IMP-003 adoption is delivered. Later owners must
exercise actual SAVE/MOD writable consumers, session lifetimes, preference
application/rollback and display confirmation. No real-provider milestone gate is
closed by these controlled fixtures.

## IMP-006 increment 1 — numeric sources

```powershell
./main_project/tools/verify_headless.ps1 -Scenario randomness -Fixture randomness-v1
```

`-Suite randomness` selects the same scenario. `IMP-006-numeric-v1` has a fixed
108-assertion terminal inventory, identical in headless/rendered mode; no UI or
frame behavior is added. Pure numeric vectors require no separate rendered UI.
The source interface and exact fixed material/seed inputs are documented in
`../scripts/rule/README.md`; additional unsigned/material vectors are pinned in
`randomness_vectors.json`. Structured arrays/dictionaries use recursive value comparison, retaining numeric
equality for 9 and 9.0 and preserving the expected/actual evidence.
Build manifests now also hash JSON vectors and license text inputs.

The fixture uses explicit material (zero, bytes 00..1f and all ff), PCG 42/54 and
unsigned seed endpoints, classic seeds 0/1/4294967295, controlled rejection raw
0/95/96/199, and exhaustive percentile boundary checks. No clock or input is used.
Scalar `-Seed`, `-Clock` and `-InputSequence` overrides remain incomplete rather
than replacing these fixed multi-seed vectors. OS entropy is checked for successful
32-byte delivery, never for uniqueness; missing/short material follows the same
explicit failure validator with no fallback. No player/session source is touched.
Classic RNG is separate from scenario `classic`, which still verifies DATA readers.
Session/load retention and formula hooks remain unavailable until increments 2/3.

Windows numeric exports use the existing wrapper with an explicit owner selection:

```powershell
./main_project/tools/verify_startup_export.ps1 -Configuration debug -Randomness
./main_project/tools/verify_startup_export.ps1 -Configuration release -Randomness
```

Each independently exports the copied project and runs the fixed 108 assertions
in headless and rendered executables, preserving export/storage/native pins.
The export includes both attribution licenses and pinned JSON numeric vectors.

## IMP-006 increment 2 — session isolation and retained outcomes

```powershell
./main_project/tools/verify_headless.ps1 -Scenario randomness-session -Fixture randomness-session-v1
./main_project/tools/verify_rendered.ps1 -Scenario randomness-session -Fixture randomness-session-v1
./main_project/tools/verify_startup_export.ps1 -Configuration debug -RandomnessSession
./main_project/tools/verify_startup_export.ps1 -Configuration release -RandomnessSession
```

`-Suite randomness-session` is equivalent. Fixed inventories are 115 headless /
116 rendered plus **15** assertions in a second engine process, using the same
disposable leased storage. Missing/truncated second-process results cannot pass.
No real classic source is required. The original `classic` scenario remains DATA
reader verification; `randomness` retains its accepted 108 numeric assertions.

Owner fixtures are `IMP-006-session-v1`, `IMP-006-session-restore-v1` and controlled
`retained-owner-v1`. New/load requests use actual CORE lifecycle/ticket/readiness
interfaces and accepted production RNGs. Explicit material is 32 zero bytes or
32 ff bytes, including deliberate repeated identical load material. Interleaving
27 combat raw requests with six raw requests each for progression/loot/quest
matches pinned purpose vectors. The queued entropy seam also forces missing
material and reentrant cancellation without touching a surviving source.

The stock New Game/Pause/Settings/Apply/Resume/Return to Title paths use CORE's
normal OS entropy acquisition. Reports retain both stock initialization materials,
exact operation/session contexts, every draw count and expected/actual check.
Rendered mode uses deliberate Enter press/release across real frames and retains
`rng-session.png`. Inspection, local preview sources, ordinary preference changes,
pause frames and controlled scene-object replacement leave live state intact.
Owners still authorize draws and obey simulation/approved UI activity eligibility.

A controlled owner snapshots assigned text, pending results and separate applied/
acknowledged flags into `retained-owner.json`, exclusively inside the disposable
fixture root. The second process restores those facts through a controlled mode
provider and real CORE successful-load handoff. This is fixture transport, **not**
a production save format, real CHAR/WORLD restore or SAVE-017 compatibility.
Actual native restore remains an unavailable required scenario when selected.

Scalar seed/clock/input overrides remain explicitly incomplete for this fixed
multi-material suite. It uses no game clock. The established M1 session fixtures
now exercise default CORE entropy initialization but consume no gameplay draws;
deterministic numeric/session assertions use the dedicated fixed-material suites.
The shared `assertion_values.ps1` handles empty JSON objects as well as nested
arrays and numeric equality, and is reused by shared/export runners. Existing
pass/fail/incomplete qualification and inventories remain unchanged.

## IMP-006 increment 3 — formula selection and invocation

```powershell
./main_project/tools/verify_headless.ps1 -Scenario formula -Fixture formula-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_rendered.ps1 -Scenario formula -Fixture formula-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_headless.ps1 -Scenario formula-fault -Fixture formula-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_rendered.ps1 -Scenario formula-fault -Fixture formula-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/qualify_formula_errors.ps1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration debug -Formula -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration release -Formula -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration debug -FormulaFault -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration release -FormulaFault -ClassicSource C:/Games/Daggerfall/arena2
```

`-Suite formula` / `-Suite formula-fault` select the same scenarios. Owner fixtures
are `IMP-006-formula-v1` (**82 headless / 84 rendered**) and
`IMP-006-formula-fault-v1` (**18** in each mode/build). The original inventories
and qualification pass/fail/missing scenarios remain unchanged. Source guards and
before/after hashes retain read-only classic data access. No executable package
code is activated: selected MOD IDs/order/version/integration eligibility and DATA
publication are real, while the hook, methods and session consumers are controlled.

[FORMULA_DISPATCH.md](../scripts/rule/FORMULA_DISPATCH.md) declares exact hook bounds,
known outputs, metadata checks, whole-provider omission, actual menu locking,
captured owner-operation binding, runtime recovery and engine limitations.
Pure hooks consume no gameplay RNG; CORE fixture sessions explicitly use 32 zero
material bytes. Hook input 7 gives built-in 14 and replacement B 207; replacement
A's declared calculation is 107 and selection after explicit B omission is checked.
Invalid input 1001 is rejected before invocation. An explicit returned 1000001
produces `invalid_result` without engine errors; an execution error returning a
valid-looking 0 produces `callback_error` and applies no value. Scalar seed/clock/
input overrides remain incomplete for these fixed multi-case fixtures.

There is no GDScript try/catch mechanism here. A scoped Logger checks actual engine
errors around one invocation and never suppresses console diagnostics. Some VM
access checks compile out of release templates. The fault fixture therefore uses
an always-observable native JSON parse failure; editor/debug additionally abort
on access to the failed result. The original Dictionary-only release test remained
incomplete and is not proof of release VM error detection. Silent within-domain
semantic mistakes cannot be detected by this mechanism and are not claimed covered.

The fault gate verifies the exact parser diagnostic/source/line in every build,
and its paired script abort in debug builds. All other script errors, import
errors, unmatched/missing/additional diagnostics, crashes and truncated inventories
remain incomplete. `formula-extra-error-v1`, selected only with `formula-fault`,
adds an error outside invocation and must return incomplete/exit 2 even though the
owner assertions finish. The qualification command launches both modes with
normal/extra-error fixtures and checks actual exits and error/report inventories.
For the release native-only path, the deliberate negative export selection is:

```powershell
./main_project/tools/verify_startup_export.ps1 -Configuration release -FormulaFault -FormulaExtraError -ClassicSource C:/Games/Daggerfall/arena2
```

It is expected **incomplete/exit 2**, never a passing export. Its nested owner
result still has 18 successful assertions; the extra unscoped native error is why
it cannot qualify. Final evidence records a direct PowerShell child exit and
observed diagnostic counts. No generic allow-errors flag exists.

Rendered setup drives the real omission button with focus, scrolling and Enter
press/release and retains `formula-recovery.png` and `formula-menu.png`. Formula
lock/selection survives actual CORE controlled return, new character and load;
these are not native CHAR/WORLD/SAVE restore or executable-mod acceptance.

## IMP-007 increment 1 — catalog lookup and CSV patches

From the repository root, invoke sequentially with Godot 4.7.2 and the existing
built Windows storage adapter:

```powershell
./main_project/tools/verify_headless.ps1 -Scenario text -Fixture text-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_rendered.ps1 -Scenario text -Fixture text-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration debug -TextCatalog -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration release -TextCatalog -ClassicSource C:/Games/Daggerfall/arena2
```

`-Suite text` is equivalent. `IMP-007-catalog-v1` freezes `text-catalog-v1`,
`text-csv-v1`, `text-token-v1`, with **121 headless / 127 rendered** assertions.
Explicit available classic source is required for actual production startup/menu
integration; no TEXT.RSC bytes are read in this increment. Unsupported seed/clock/
input overrides, missing input/results, script errors and unfinished inventories
remain incomplete. Existing diagnostic qualification is unchanged.

The fixture uses leased disposable roots and real MOD discovery/order, CSV DATA
candidates, source omission/rebuild and CORE actual menu entry. It tests English,
synthetic exact `zz-Test`, non-English base retention, reordered/missing/blank/
malformed references, optional/essential fallback, complete UTF-8/CSV parsing,
whole-file rejection, source/row provenance, two ordered packages and final loose
override, read projection copies and run locks. Live CORE/RULE sources use 32 zero
material bytes and a controlled owner with one retained quest result: lookup
leaves its nonzero counts and unapplied facts unchanged. This is not real QUEST,
CHAR, reward delivery, SAVE or macro integration.

Rendered output captures asset-independent recovery, scrolled Quit, and the actual
committed menu. Inspect those images in addition to assertions. Export runs test
the bundled raw CSV through PCK FileAccess and the matching terminal inventories.
Font roles, Unicode shaping, pending-choice locale switching, TEXT.RSC decoding and
authoring codec/import/mod preferences retain later increment gates. Synthetic
catalog presence does not advertise a supported language.

See [the concrete contract](../scripts/data/TEXT_CATALOGS.md) and
[execution evidence](../../design_docs/development/evidence/IMP-007-increment-1-2026-11-20.md).

## IMP-007 increment 2 — structured classic text

Invoke independently and sequentially from the repository root:

```powershell
./main_project/tools/verify_headless.ps1 -Scenario structured-text -Fixture structured-text-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_rendered.ps1 -Scenario structured-text -Fixture structured-text-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration debug -StructuredText -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration release -StructuredText -ClassicSource C:/Games/Daggerfall/arena2
```

`-Suite structured-text` is equivalent. `IMP-007-structured-v1` freezes reader
`text-rsc-v1` and binary profile `classic-controls-v1`, retaining `text-token-v1`.
Fixed terminal inventories: **284 headless / 294 rendered**. They include all
121/127 original catalog assertions through the actual five-source production
composition. The original `text` / `text-v1` scenario and `-TextCatalog` exports
retain exactly **121/127**, with their original four-source scope.

Explicit available classic input is required. Only this enabled text scenario
adds TEXT.RSC to the wrapper's Windows READ-only sharing guards and before/after
hashes. Missing input, seed/clock/input overrides, missing/truncated reports,
unexpected engine/script diagnostics and unsupported explicit controls do not
count as passing records. Existing narrow formula-error qualification is unchanged.

Checks cover real records 25/11/1200/1201, explicit key mappings and required
control signatures, source byte/token positions, meaningful spaces/literal escapes,
line/page/input/font/position/layout controls, exact binary structural codec bytes,
empty authored variants, malformed/unsupported records and directory extents,
source loss before initialization and after publication, cleanup/retry/interruption,
stale tickets, active-source retention and restart-only replacement. Separate
controlled gameplay owners use real CORE/RULE handles: text inspection/refresh and
isolated literal sample expansion consume zero draws or mutations. MOD dependency
order, CSV omission/rebuild and actual CORE menu locking remain real integrations.

Rendered fixtures retain recovery, scrolled Quit, committed menu and
`structured-sample.png`. Inspect saved PNGs. The sample is a fixture inspector
showing a one-pass explicit literal `%gii` substitution and an input-position
marker. It neither submits an answer nor implements a general gameplay renderer.
Fonts/live switching, production macro expansion (IMP-030), editable translation
codec/import (increment 4/IMP-056), book edition anchors and real gameplay/SAVE
providers retain their named gates. See [the concrete contract](../scripts/data/STRUCTURED_TEXT.md)
and [execution evidence](../../design_docs/development/evidence/IMP-007-increment-2-2026-11-20.md).
