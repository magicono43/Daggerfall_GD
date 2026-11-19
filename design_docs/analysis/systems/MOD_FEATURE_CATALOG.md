# MOD feature catalog

Static analysis of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Source paths are relative to `Assets/`, with symbols after `#`. Confidence rates the sampled trace.

## MOD-001 — Bundle discovery and editor virtual mods

- **Parent subsystem** — Loading
- **Purpose** — Find packages for the current runtime.
- **Existing implementation** — Manager recursively scans ModDirectory for the mod extension and loads AssetBundles from disk. The editor debug path separately discovers manifests for virtual mods without building bundles.
- **Source** — `Game/Addons/ModSupport/ModManager.cs#LoadModAssetBundle`, `Game/Addons/ModSupport/Mod.cs`, `Game/Addons/ModSupport/ModTypes.cs`
- **Inputs and outputs** — Directories, packages and editor mode → discovered mods
- **Dependencies** — CORE, DATA, Unity AssetBundle
- **Edge cases and interactions** — Verify incompatible bundles, missing metadata and editor/build differences.
- **Design questions** — Which package formats and discovery roots should be supported?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v3 on 2026-11-17.

### My Intended Specification

[MOD-001 — Mod package discovery](../../design/systems/MOD/MOD-001.md)

## MOD-002 — Enabled mods and load priority

- **Parent subsystem** — Loading
- **Purpose** — Select the active mod set.
- **Existing implementation** — Manager persists enabled state and priority and sorts by LoadPriority. Initialization unloads disabled packages and compiles source for remaining mods.
- **Source** — `Game/Addons/ModSupport/ModManager.cs#Init`, `Game/Addons/ModSupport/ModLoaderInterfaceWindow.cs`
- **Inputs and outputs** — Discovered packages and user selection → active ordered set
- **Dependencies** — CORE, UI, SAVE
- **Edge cases and interactions** — Check new packages, duplicate identities and configuration from older installs.
- **Design questions** — How should enablement and order follow a save or profile?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v2 on 2026-11-17.

### My Intended Specification

[MOD-002 — Enabled mods and load priority](../../design/systems/MOD/MOD-002.md)

## MOD-003 — Dependency validation and auto-sort

- **Parent subsystem** — Loading
- **Purpose** — Expose missing prerequisites and order problems.
- **Existing implementation** — Manager checks missing and disabled dependencies, optionality, peer/order rules and minimum versions. AutoSortMods topologically orders non-peer relationships and logs exceptions.
- **Source** — `Game/Addons/ModSupport/ModManager.cs#CheckModDependencies`, `Game/Addons/ModSupport/ModManager.cs#AutoSortMods`, `Game/Addons/ModSupport/ModTypes.cs`
- **Inputs and outputs** — Manifests and enabled order → diagnostics or sorted priorities
- **Dependencies** — UI, CORE
- **Edge cases and interactions** — Verify cycles, peer optionality and whether UI permits launch after warnings.
- **Design questions** — Which dependency failures should block loading?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17.

### My Intended Specification

[MOD-003 — Dependency validation and auto-sort](../../design/systems/MOD/MOD-003.md)

## MOD-004 — Compiled and source script loading

- **Parent subsystem** — Scripting
- **Purpose** — Make mod code available to the game.
- **Existing implementation** — Mod exposes source-to-assembly compilation and type lookup. ModManager forwards source to the compiler. The repository contains a CSharpCompiler add-on.
- **Source** — `Game/Addons/ModSupport/Mod.cs#CompileSourceToAssemblies`, `Game/Addons/ModSupport/Mod.cs#GetCompiledType`, `Game/Addons/ModSupport/ModManager.cs#CompileFromSourceAssets`
- **Inputs and outputs** — Source and packaged script assets → assembly and discoverable types
- **Dependencies** — CORE, DEV
- **Edge cases and interactions** — Inspect platform support, references and failure behavior with actual packages. No sandbox behavior was verified.
- **Design questions** — Which scripting formats and runtime capabilities should be offered?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17.

### My Intended Specification

[MOD-004 — Compiled and source script loading](../../design/systems/MOD/MOD-004.md)

## MOD-005 — State-based entry points

- **Parent subsystem** — Scripting
- **Purpose** — Run mod initialization at the intended phase.
- **Existing implementation** — Manager initializes and invokes loaders at Start, invokes Game loaders on first Game transition and then unsubscribes. It reflects static methods with InitParams and logs TargetInvocationException.
- **Source** — `Game/Addons/ModSupport/ModManager.cs#StateManager_OnStateChange`, `Game/Addons/ModSupport/ModManager.cs#InvokeModLoaders`, `Game/Addons/ModSupport/Mod.cs#FindModLoaders`, `Game/Addons/ModSupport/ModTypes.cs#Invoke`
- **Inputs and outputs** — State change and attributed method → callback and diagnostics
- **Dependencies** — CORE-015, DEV
- **Edge cases and interactions** — Verify multiple title transitions before Game and listener order. A callback failure can leave partial registration.
- **Design questions** — When should mods initialize, reset and release state?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17.

### My Intended Specification

[MOD-005 — State-based entry points](../../design/systems/MOD/MOD-005.md)

## MOD-006 — Asset lookup, cloning and caching

- **Parent subsystem** — Assets
- **Purpose** — Resolve requested objects across enabled packages.
- **Existing implementation** — TryGetAsset searches enabled mods in reverse order. Mod supports per-package lookup, clone options, bulk loading and bundle unload paths.
- **Source** — `Game/Addons/ModSupport/ModManager.cs#TryGetAsset`, `Game/Addons/ModSupport/Mod.cs#GetAsset`, `Game/Addons/ModSupport/Mod.cs#LoadAllAssetsFromBundle`, `Game/Addons/ModSupport/Mod.cs#UnloadAssetBundle`
- **Inputs and outputs** — Asset key, type, enabled order and clone flag → selected asset
- **Dependencies** — DATA, AV, Unity AssetBundle
- **Edge cases and interactions** — Verify collisions, type mismatch and object lifetime after unload.
- **Design questions** — Should callers receive shared or independent objects?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-006 — Asset lookup, cloning and caching](../../design/systems/MOD/MOD-006.md)

## MOD-007 — Loose text and record patches

- **Parent subsystem** — Assets
- **Purpose** — Supply text or structured data outside classic archives.
- **Existing implementation** — TextAssetReader checks loose StreamingAssets first for single reads, then mod lookup by basename. Bulk reads and record merges use separate paths.
- **Source** — `Scripts/Utility/AssetInjection/TextAssetReader.cs#TryRead`, `Scripts/Utility/AssetInjection/TextAssetReader.cs#ReadAll`, `Scripts/Utility/AssetInjection/TextAssetReader.cs#Merge`
- **Inputs and outputs** — Relative key and source content → loaded or patched records
- **Dependencies** — DATA-003, ITEM, MAGIC
- **Edge cases and interactions** — Single lookup and merge need separate precedence fixtures.
- **Design questions** — How should record conflicts be exposed?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-007 — Loose text and record patches](../../design/systems/MOD/MOD-007.md)

## MOD-008 — Visual and audio replacements

- **Parent subsystem** — Assets
- **Purpose** — Substitute presentation assets using original identifiers.
- **Existing implementation** — Replacement helpers accept model, flat, texture, sound, MIDI and movie keys. Different consumers use different import paths. Video window tries replacement before classic playback.
- **Source** — `Scripts/Utility/AssetInjection/MeshReplacement.cs#ImportCustomGameobject`, `Scripts/Utility/AssetInjection/TextureReplacement.cs#TryImportMaterial`, `Scripts/Utility/AssetInjection/SoundReplacement.cs#TryImportMidiSong`, `Scripts/Utility/AssetInjection/VideoReplacement.cs#TryImportMovie`
- **Inputs and outputs** — Classic key and replacement assets → alternate presentation
- **Dependencies** — DATA-021, DATA-022, DATA-023, AV-013
- **Edge cases and interactions** — Test invalid replacements, variant keys and cache refresh. No single precedence rule was established for all media.
- **Design questions** — Which keys should remain stable across rendering changes?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-008 — Visual and audio replacements](../../design/systems/MOD/MOD-008.md)

## MOD-009 — World replacements and variants

- **Parent subsystem** — Assets
- **Purpose** — Alter locations, blocks or buildings.
- **Existing implementation** — WorldDataVariants has location, new-location, block and building selectors. World replacement and save paths consume separate variant data.
- **Source** — `Scripts/Utility/AssetInjection/WorldDataReplacement.cs`, `Scripts/Utility/AssetInjection/WorldDataVariants.cs#SetLocationVariant`, `Scripts/Utility/AssetInjection/WorldDataVariants.cs#SetBlockVariant`, `Scripts/Utility/AssetInjection/WorldDataVariants.cs#SetBuildingVariant`, `Scripts/Game/Serialization/SaveLoadManager.cs#LoadGame`
- **Inputs and outputs** — Location keys, block or building and variant → alternate layout inputs
- **Dependencies** — DATA-024, LOC, WORLD, SAVE
- **Edge cases and interactions** — Trace global versus location-specific keys and missing packs on load.
- **Design questions** — How should variant changes preserve existing world identity?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-009 — World replacements and variants](../../design/systems/MOD/MOD-009.md)

## MOD-010 — Formula and custom activation overrides

- **Parent subsystem** — Gameplay hooks
- **Purpose** — Alter calculations or object interactions.
- **Existing implementation** — Formula registration uses named delegates and priority resolution. Player activation can register model or flat keys with range and separately calls IPlayerActivable on the hit object.
- **Source** — `Scripts/Game/Formulas/FormulaHelper.cs#RegisterOverride`, `Scripts/Game/PlayerActivate.cs#RegisterCustomActivation`, `Scripts/Game/PlayerActivate.cs#Update`
- **Inputs and outputs** — Provider, key and delegate → overridden rule or activation callback
- **Dependencies** — RULE-004, MOVE-025
- **Edge cases and interactions** — Formula and activation rules differ. Inspect conflicts per registry.
- **Design questions** — Should overrides replace, compose or consume behavior?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-010 — Formula and custom activation overrides](../../design/systems/MOD/MOD-010.md)

## MOD-011 — Custom items, effects and spell offers

- **Parent subsystem** — Gameplay hooks
- **Purpose** — Extend item and magic content at runtime.
- **Existing implementation** — ItemHelper registers templates and use handlers. Effect broker registers templates with optional replacement and accepts custom spell offers by usage.
- **Source** — `Scripts/Game/Items/ItemHelper.cs#RegisterCustomItem`, `Scripts/Game/Items/ItemHelper.cs#RegisterItemUseHandler`, `Scripts/Game/MagicAndEffects/EntityEffectBroker.cs#RegisterEffectTemplate`, `Scripts/Game/MagicAndEffects/EntityEffectBroker.cs#RegisterCustomSpellBundleOffer`
- **Inputs and outputs** — Definitions and callbacks → constructible items, effects or offers
- **Dependencies** — ITEM-002, MAGIC-001, MAGIC-011, SAVE
- **Edge cases and interactions** — Verify ID collisions, missing keys and ordering relative to saved object reconstruction.
- **Design questions** — Which IDs should be scoped to the provider?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-011 — Custom items, effects and spell offers](../../design/systems/MOD/MOD-011.md)

## MOD-012 — Quest packs and custom verbs

- **Parent subsystem** — Gameplay hooks
- **Purpose** — Extend authored quest content and runtime actions.
- **Existing implementation** — QuestListsManager discovers packs and registers quest lists. QuestMachine accepts action templates for script parsing.
- **Source** — `Scripts/Game/Questing/QuestListsManager.cs#DiscoverQuestPackLists`, `Scripts/Game/Questing/QuestListsManager.cs#RegisterQuestList`, `Scripts/Game/Questing/QuestMachine.cs#RegisterAction`
- **Inputs and outputs** — Pack, list or action template → selectable or executable quest content
- **Dependencies** — QUEST-001, QUEST-006, SAVE
- **Edge cases and interactions** — Verify script collisions, ambiguous actions and save restore after removal.
- **Design questions** — Which quest extensions should remain data-only?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-012 — Quest packs and custom verbs](../../design/systems/MOD/MOD-012.md)

## MOD-013 — Factions, guild services and interface overrides

- **Parent subsystem** — Gameplay hooks
- **Purpose** — Add actors' organizational behavior and UI routes.
- **Existing implementation** — FactionFile supports custom factions. GuildManager registers group-specific types. Services registers callbacks, while UIWindowFactory supports type replacement.
- **Source** — `Scripts/API/FactionFile.cs#RegisterCustomFaction`, `Scripts/Game/Guilds/GuildManager.cs#RegisterCustomGuild`, `Scripts/Game/Guilds/Services.cs#RegisterGuildService`, `Scripts/Game/UserInterfaceWindows/UIWindowFactory.cs#RegisterCustomUIWindow`
- **Inputs and outputs** — Faction IDs, guild groups, callbacks and window types → extension registrations
- **Dependencies** — FACT-009, FACT-014, UI-003
- **Edge cases and interactions** — Direct construction may bypass factory overrides. Audit key collisions and initialization order by API.
- **Design questions** — Which extension points should expose provider conflicts?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-013 — Factions, guild services and interface overrides](../../design/systems/MOD/MOD-013.md)

## MOD-014 — Mod settings and localization

- **Parent subsystem** — Configuration
- **Purpose** — Expose mod-owned preferences and strings.
- **Existing implementation** — Mod loads settings and offers localization lookup. ModSettings exposes typed getters and section deserialization. Dedicated UI and preset picker are present.
- **Source** — `Game/Addons/ModSupport/Mod.cs#LoadSettings`, `Game/Addons/ModSupport/Mod.cs#Localize`, `Game/Addons/ModSupport/ModSettings/ModSettings.cs#GetValue`, `Game/Addons/ModSupport/ModSettings/ModSettingsWindow.cs`, `Game/Addons/ModSupport/ModSettings/PresetPicker.cs`
- **Inputs and outputs** — Schema, saved values and locale → effective settings and labels
- **Dependencies** — UI, DATA, CORE-001
- **Edge cases and interactions** — Check malformed values, schema changes, default and preset precedence.
- **Design questions** — Which mod settings can change while a session is running?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-014 — Mod settings and localization](../../design/systems/MOD/MOD-014.md)

## MOD-015 — Mod save interface

- **Parent subsystem** — Persistence
- **Purpose** — Preserve mod-owned game state.
- **Existing implementation** — IHasModSaveData defines typed save integration. Native load reads separate per-mod files or initializes new state, then invokes mod restore with per-mod failure handling.
- **Source** — `Game/Addons/ModSupport/ModTypes.cs#IHasModSaveData`, `Scripts/Game/Serialization/SaveLoadManager.cs#GetModDataFilename`, `Scripts/Game/Serialization/SaveLoadManager.cs#LoadGame`
- **Inputs and outputs** — Mod identity, payload and type → restored mod state
- **Dependencies** — SAVE-017, CORE
- **Edge cases and interactions** — Verify removed mods, renames, version mismatches and resaving.
- **Design questions** — Which missing mod data should affect load eligibility?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-015 — Mod save interface](../../design/systems/MOD/MOD-015.md)

## MOD-016 — Package and manifest authoring

- **Parent subsystem** — Authoring
- **Purpose** — Build mod artifacts and declare their metadata.
- **Existing implementation** — Editor tools include mod creation, assembly building, dependency editing and settings editing. The create window reads mod info files.
- **Source** — `Game/Addons/ModSupport/Editor/CreateModEditorWindow.cs#ReadModInfoFile`, `Game/Addons/ModSupport/Editor/ModAssemblyBuilder.cs`, `Game/Addons/ModSupport/Editor/ModDependenciesEditorWindow.cs`, `Game/Addons/ModSupport/ModSettings/Editor/ModSettingsEditorWindow.cs`
- **Inputs and outputs** — Source assets, manifest and target → authoring or packaging output
- **Dependencies** — DEV, DATA, Unity Editor
- **Edge cases and interactions** — Build targets, asset import and actual artifact compatibility remain unverified.
- **Design questions** — What should authors validate before packaging?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-18.

### My Intended Specification

[MOD-016 — Package and manifest authoring](../../design/systems/MOD/MOD-016.md)

## Classic provenance and next review steps

The package loader, Unity bundles, lifecycle callbacks and registries are DFU mechanisms. Replacement content can target identifiers or formats inherited from classic data. Validate those identities with actual archives and representative mods.

Review package ordering and dependency failures first, then test conflicting asset and formula overrides and follow Start/Game callbacks through a load. Include a missing mod or changed save schema and one location variant. Coverage samples extension APIs. Runtime package compatibility, complete hook inventories and authored asset behavior remain open.
