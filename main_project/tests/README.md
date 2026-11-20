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
