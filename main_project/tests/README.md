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
