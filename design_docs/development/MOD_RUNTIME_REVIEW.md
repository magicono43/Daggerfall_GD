# Executable mod runtime review

Reviewed 2026-11-18 for IMP-050. The user explicitly approved Luau restricted scripting and GDScript trusted scripting on 2026-11-18. No runtime implementation or exported feasibility test has run.

## Approved selection

Use embedded **Luau** for restricted readable multi-file scripts, through a project-owned GDExtension adapter. Use **trusted GDScript source packages** for the initial trusted path, loaded only after executable-content consent. Keep native-library mod distribution as a separate future format decision under MOD-004.

Luau documents a sandbox with removed I/O facilities, host interrupts and allocator control. Its embedding API provides the required host boundary. A VM per package simplifies isolation and retirement. [Sandbox](https://luau.org/sandbox/), [C API](https://luau.org/api/)

GDScript exposes script compilation/loading through the engine's script resource machinery and has direct engine capabilities suitable for substantial trusted behavior changes. Feasibility with external multi-file packages and the exact Godot 4.7.2 export must be proven. [Engine implementation](https://github.com/godotengine/godot/blob/master/modules/gdscript/README.md), [Script API](https://docs.godotengine.org/en/latest/classes/class_script.html)

## Alternatives

| Candidate | Fit and cost |
| --- | --- |
| Luau restricted VM | Native embedding matches the existing media extension approach. Requires maintained host bindings, package module resolution and exported library builds. |
| MoonSharp restricted interpreter | Provides configurable sandbox facilities, but adds a managed runtime dependency if the game uses standard Godot. Host objects and permitted libraries still require explicit validation. |
| Trusted GDScript | Uses the engine runtime and can replace provider behavior through the project interfaces. Full trust must precede all code/resource loading that can run initialization. |
| Trusted C# assemblies | Viable candidate for a .NET build, but adds assembly/dependency/type-context concerns and does not itself constrain permissions. Choosing it would settle an additional engine/runtime dependency. |

MoonSharp's sandbox configuration is documented by its author. The current selection favors Luau plus GDScript to avoid making .NET a prerequisite solely for mod execution. [MoonSharp sandbox](https://www.moonsharp.org/sandbox.html)

## Restricted host contract

- Compile package source inside the host. Reject package-provided bytecode. Resolve modules within declared package/dependency exports; normalize and validate paths. The host reads package bytes and returns source to the VM.
- Expose value records, scoped opaque IDs and documented owner operations. Do not expose Godot Object/Node, engine singletons, arbitrary reflection, native loading, filesystem, network or process interfaces.
- Freeze safe globals and isolate each package environment. Enforce allocator and execution limits with explicit failure. Interrupt over-budget Lua work and charge host operations against bounded per-call work. No yield or interrupt may split an authoritative owner commit without its supported operation protocol.
- Declare replaceable provider interfaces alongside owners. Restricted scripts can implement supported whole behaviors through these interfaces. The boundary grants only their declared operations and validates arguments/results. Host callback capabilities are part of the sandbox surface.

Luau's documented isolation depends on the exposed host functions. VM selection alone does not certify the game's bridge. [Embedding limitations and controls](https://luau.org/sandbox/)

## Trusted activation and lifecycle

Inspect manifests and hash executable inputs before loading executable resources. Bind approval to stable package identity and a deterministic digest of source files and executable dependencies, paths and execution-affecting manifest settings. Revalidate the exact inputs at activation. Data-only changes preserve approval when executable identity is unchanged. New inputs require consent under MOD-004.

Trusted GDScript runs with game-process capabilities. Show that fact during consent. After consent, compile from the validated package snapshot and resolve dependencies under the selected plan. Register providers into the candidate registry. User-selected system replacement takes precedence through MOD-004's explicit conflict choice.

Use MOD-005's application/session scope lifecycle. Registrations and session resources have owners and disposable handles. Failed activation blocks readiness. Retry after verified cleanup; unsafe cleanup requires restart. No in-process rollback or full unloading guarantee is implied for arbitrary trusted side effects.

## Exported acceptance

1. Run a restricted multi-file ZIP and unpacked package in a Windows Godot 4.7.2 export. Replace an NPC decision provider and invoke a quest command through the owner interface. Record startup and first-use time for a representative large package.
2. Attempt filesystem, OS, network, native/object access, path escape, imported bytecode, unbounded allocation and infinite loop. Assert explicit rejection/bounded failure and no prohibited owner mutation. Exercise a bounded host callback separately.
3. Load a trusted package only after approval and demonstrate a substantial replacement, such as a combat admission/timing provider with changed behavior through the approved interface. Changing executable bytes after discovery must invalidate consent.
4. Decline approval and verify package remains installed/inactive, affected dependents are shown and a declared data-only mode requires explicit choice and revalidation.
5. Inject registration and session-entry failures, retire the scope and deliver stale callbacks. Verify cleanup/recovery and that unsafe cleanup blocks another activation.

Exact runtime revisions, quotas and build flags are pinned during dependency integration and reported by fixtures. Missing exported evidence is an implementation acceptance failure. If a selected runtime cannot meet the approved capability contract, report the concrete conflict before changing the architecture.
