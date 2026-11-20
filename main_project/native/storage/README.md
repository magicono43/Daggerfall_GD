# IMP-001 Windows storage adapter

Target: Windows x86-64, Godot **4.7.2.stable.official.ed1daf0bf**.
Game policy, settings, logger, recovery UI and fixtures are GDScript. This C++
GDExtension supplies per-user discovery, a process-held root lease, filesystem
identity and safe same-volume replacement. No third-party C++ runtime DLL is
required. Other platforms deliberately fail closed until an adapter is verified.

## Rebuild

The machine's Visual Studio installation did not contain usable compiler/SDK
files. The task uses the portable **Zig 0.13.0** C++ compiler and its bundled
Windows SDK/MinGW support, without installing or changing system software.
There is no godot-cpp dependency. The official Godot C ABI is used directly.

1. Download [Zig 0.13.0 for Windows x86-64](https://ziglang.org/download/0.13.0/zig-windows-x86_64-0.13.0.zip).
2. Verify ZIP SHA-256 `d859994725ef9402381e557c60bb57497215682e355204d754ee3df75ee3c158`.
3. Extract into `main_project/tools/.toolchain/` (ignored), retaining the
   `zig-windows-x86_64-0.13.0` directory.
4. From the repository root run `./main_project/tools/build_storage.ps1`.
   An alternate executable location can be supplied with `-Zig` (version checked).
5. Open/import `main_project/project.godot` in Godot 4.7.2 before launching, or
   run the task-local verification command, which imports the project itself.

DLL/PDB/import-library outputs and compiler caches are ignored. A clean checkout
requires this build; compiled machine artifacts are intentionally not committed.
Zig is MIT-licensed; bundled compiler libraries retain their upstream licenses
inside the extracted toolchain. The compiler is build-only, not a game runtime.

## Pinned ABI and provenance

- Vendored header: [Godot 4.5-stable `gdextension_interface.h`](https://github.com/godotengine/godot/blob/4.5-stable/core/extension/gdextension_interface.h), SHA-256
  `a40ac4fca0f526910bd0e6afc6da6c169f50801c84d4e29c4ce2891cadc7b550`.
  This stable C ABI is compatible with the tested 4.7.2 engine. The manifest's
  minimum is 4.5; the project's acceptance target remains 4.7.2.
- Godot header MIT license is retained in the header and `vendor/GODOT_LICENSE.txt`.
- ABI bindings are deliberately limited to one RefCounted class and one
  string-only vararg method. On Windows x86-64, String/StringName opaque storage
  occupies one aligned 8-byte pointer. No Variant memory layout is assumed.

## Semantics and limits

IMP-005 increment 1 adds read-only `inspect`: `GetFileAttributesW` classifies
missing/file/directory/reparse-point paths; ordinary files are checked with
`GetFileInformationByHandle` for hard links. Reparse points and multiply linked
files return `link`; access failures retain Windows errors. MOD owns discovery,
containment decisions and recovery. The same pinned build/ABI/dependencies apply.

`WindowsStorageLease.invoke(operation, source, destination)` returns a tagged
string (`ok|...`, `in_use|...`, `io|...`). The GDScript adapter converts it to
checked results with operation, path and diagnostic details.

- `per_user`: Windows `SHGetFolderPathW(CSIDL_LOCAL_APPDATA)`; GDScript appends
  the provisional game directory name or its separate development name.
- `acquire`: `CreateFileW(OPEN_ALWAYS)` on `.storage-lease`, with no sharing;
  `GetFinalPathNameByHandleW` resolves the held directory identity. Retain the
  RefCounted instance for all persistent consumers. `release`, destruction,
  normal exit and process termination close the kernel handle. File presence
  is never used as exclusion. Verified aliases: case, dot paths and junctions.
- `replace`: flush the staged file with `FlushFileBuffers`, then
  `MoveFileExW(REPLACE_EXISTING | WRITE_THROUGH)`. Staging is adjacent to its
  target. A failed replacement never triggers deletion/truncation fallback.

Settings stage, recovery-copy and backup operations are separate commits. There
is no claim of a multi-file atomic transaction or universal power-loss survival.
Task-local process-kill checks cover interruption before backup and active-file
replacement. Physical drive removal/power cuts and other filesystems remain
unverified. Locking acceptance covers the local Windows filesystem, not network
share semantics. See the task's execution evidence for actual results.
