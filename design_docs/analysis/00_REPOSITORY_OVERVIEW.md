# Repository overview

## Snapshot identity

The analyzed directory is `daggerfall-unity-1.1.1-cve-2025`. `Assets/Scripts/VersionInfo.cs` declares Daggerfall Unity **1.1.1 Release** and Tools for Unity **1.9.2**. The local directory has no Git metadata and `git rev-parse HEAD` could not resolve a commit. The folder suffix is a local label. Its patch provenance is unknown.

For a local identity check, the SHA-256 of `Assets/Scripts/VersionInfo.cs` is `4c39e46bc10eb8ea96511a16fc0096466ef16059989512fafe9350782b77e166`. This identifies the version file. `ProjectSettings/ProjectVersion.txt` separately identifies Unity **2019.4.40f1**, editor revision `ffc62b691db5`.

## Project organization

| Location | Responsibility and representative anchors |
| --- | --- |
| `ProjectSettings/`, `Assets/Scenes/` | `EditorBuildSettings.asset` enables `DaggerfallUnityStartup.unity` followed by `DaggerfallUnityGame.unity`. `BasicScene.unity` also exists. |
| `Assets/Scripts/` | Top-level application, settings, content facade and media readers. `Game/` contains gameplay, managers, rules, UI and serialization. |
| `Assets/Scripts/API/` | Classic binary/text format readers and structures, including `MapsFile`, `BlocksFile`, `DFLocation`, and classic save records in `Save/`. |
| `Assets/Scripts/Internal/`, `Terrain/`, `Utility/` | Scene components and world objects, exterior streaming and terrain, content lookup and block layout helpers. |
| `Assets/Game/Addons/`, `Assets/Scripts/Editor/` | Mod support, compiler, console and world authoring add-ons, plus Unity inspection/export tools. |
| `Assets/Prefabs/`, `Assets/Resources/`, `Assets/AddressableAssetsData/`, `Assets/Localization/` | Unity-authored assets, resource loading and localization configuration. |
| `Assets/StreamingAssets/` | Runtime content inputs, including quests, tables, factions, text, BIOGs, books, sound fonts and replacement/mod directories. |
| `Packages/` | Manifest and package dependencies. Embedded Post Processing includes runtime, editor and corresponding test assembly definitions. |

The inspected tree has no project-owned `.asmdef` under `Assets/`. Unity's default runtime and editor script assemblies are therefore the expected game-code partition, with editor-folder conventions applying. This is inferred from the layout. Assembly outputs were not inspected. Precompiled plug-ins include `Assets/Resources/FullSerializer - Unity.dll`, `Assets/Resources/INIFileParser.dll` and `Assets/Game/Addons/CSharpCompiler/Plugins/mcs.dll`. The manifest lists Addressables, Localization, Burst, Jobs, Collections, Test Framework, UGUI and TextMesh Pro among its dependencies.

## Architecture observed

- **Scene components and shared access.** `Assets/Scripts/Game/GameManager.cs` caches services and discovers objects through component, name and tag lookup. `Game/Entities/DaggerfallEntityBehaviour.cs` connects scene behavior to the entity classes in `Game/Entities/`.
- **Content readers and adapters.** `Assets/Scripts/DaggerfallUnity.cs` sets up ARENA2 access. `Utility/ContentReader.cs` exposes location and block queries. Layout and terrain code construct Unity objects from the resulting records.
- **Event and registry seams.** `Game/Utility/StartGameBehaviour.cs` exposes startup events. Effect templates, quest actions, custom activations and serializable objects have separate registration paths.
- **Versioned persistence and UI stack.** `Game/Serialization/SerializableGameObject.cs` contains the save contract and data records. `Game/UserInterface/UserInterfaceManager.cs` manages windows and messages, and feature windows also execute gameplay operations.

See [the catalog](01_MASTER_SYSTEMS_CATALOG.md) for ownership boundaries and [the dependency overview](02_INITIAL_DEPENDENCY_OVERVIEW.md) for representative runtime paths.
