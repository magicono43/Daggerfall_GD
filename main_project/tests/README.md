# IMP-001 task-local verification

These fixtures exercise the normal `startup.tscn` entry and its production owner
requests. They are not the IMP-003 shared verification harness. Build the native
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
validator or package implementation. The default production boundary reports
IMP-004/005 unavailable and cannot reach menu readiness without real providers.
No classic assets are read or modified by these fixtures.

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
IMP-005 MOD/DATA results and integrate these cases into IMP-003. Later owners must
exercise actual SAVE/MOD writable consumers, session lifetimes, preference
application/rollback and display confirmation. No real-provider milestone gate is
closed by these controlled fixtures.
