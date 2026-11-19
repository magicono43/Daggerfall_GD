# DATA feature catalog

Baseline is the local Daggerfall Unity 1.1.1 Release snapshot. See [repository overview](../00_REPOSITORY_OVERVIEW.md) and [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). DATA owns content sourcing, record interpretation, localization and conversion. Feature owners retain gameplay rules, world construction, save restoration and playback.

Paths are relative to `Assets/Scripts/`. The symbol after `#` is a source anchor. Implementation statements describe static observations. Edge cases distinguish visible branches from fixture and runtime questions. Complexity estimates review scope. Confidence rates the source trace.

## DATA-001 — Classic installation discovery

- **Parent subsystem** — Source selection
- **Purpose** — Resolve the classic data root.
- **Existing implementation** — Checks the editor path in editor builds, then probes the configured location and runtime fallbacks under Application.dataPath and StreamingAssets/GameFiles. DFValidator inspects the candidate folder. Readiness and validation are separate flags.
- **Source** — `DaggerfallUnity.cs#SetupArena2Path`, `API/DFValidator.cs#ValidateArena2Folder`
- **Inputs and outputs** — Settings.MyDaggerfallPath, runtime directories and source event → Arena2Path and validation flag.
- **Dependencies** — CORE-004, CORE-003
- **Edge cases and interactions** — An existing candidate can stop probing before validation, so an invalid earlier folder can mask a later valid one. Inspect candidate layout and required/optional file sets on fixtures.
- **Design questions** — Which data sources should be accepted, and when should fallback continue?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-001-A01. Documented technical/content dependencies remain open.

### My Intended Specification

[DATA-001 — Approved specification v1](../../design/systems/DATA/DATA-001.md). Basic required-file/readability and lightweight structural validation; modified data accepted; videos optional. Exact manifest and format checks remain documented dependencies.

## DATA-002 — Classic reader initialization and access

- **Parent subsystem** — Source selection
- **Purpose** — Expose classic records to consumers through a common facade.
- **Existing implementation** — SetupContentReaders creates a ContentReader even without a validated root. The facade initializes format readers, typically with read-only memory access. FileProxy also supports disk or byte-backed access.
- **Source** — `DaggerfallUnity.cs#SetupContentReaders`, `Utility/ContentReader.cs#SetupReaders`, `API/FileProxy.cs#Load`, `API/BsaFile.cs`
- **Inputs and outputs** — Root, binary file or bytes → reader objects and decoded record access.
- **Dependencies** — CORE, WORLD, LOC, AV
- **Edge cases and interactions** — Facade readiness alone does not establish that the backing archives loaded. Verify refresh behavior on a path change and malformed file handling by format.
- **Design questions** — Which readers must be ready before gameplay, and how should failed readers report errors?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-002-A01. Documented technical dependencies remain open.

### My Intended Specification

[DATA-002 — Approved specification v1](../../design/systems/DATA/DATA-002.md). Required readers/basic indexes initialize before the main menu; records decode on demand with differentiated failures. Application-lifetime reuse, read-only sources and restart after external edits. Exact reader inventory and format contracts remain dependencies.

## DATA-003 — Loose text and mod data resolution

- **Parent subsystem** — Source selection
- **Purpose** — Resolve optional definitions and patches.
- **Existing implementation** — TryRead checks a loose StreamingAssets path first and then asks ModManager for the basename. ReadAll collects loose files and then mod assets. Typed reads delegate to SaveLoadManager deserialization. Merge is a separate record-patching operation.
- **Source** — `Utility/AssetInjection/TextAssetReader.cs#TryRead`, `Utility/AssetInjection/TextAssetReader.cs#ReadAll`, `Utility/AssetInjection/TextAssetReader.cs#Merge`
- **Inputs and outputs** — Relative path or directory, optional extension and enabled mods → text, typed object or merged records.
- **Dependencies** — MOD, SAVE, ITEM, MAGIC
- **Edge cases and interactions** — Single lookup drops the directory for mod lookup. Directory enumeration is a distinct path. Collision, ordering and invalid patch behavior need per-caller checks.
- **Design questions** — What should identify a patch, and how should conflicts be reported?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-003-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-003 — Approved specification v1](../../design/systems/DATA/DATA-003.md). Domain/path identity, deterministic later-source precedence, explicit replace/add/patch semantics and whole-contribution rejection. Editable pre-menu mod configuration locks on actual main-menu entry. Per-type schemas, MOD lifecycle and configuration UI integration remain dependencies.

## DATA-004 — Regions, locations and map identity

- **Parent subsystem** — World definitions
- **Purpose** — Provide shared location identifiers and geographic lookup.
- **Existing implementation** — MapsFile reads regions and exposes coordinate conversions. ContentReader lazily builds a map index from the masked MapId, links location IDs to that index and exposes lookup by coordinates, region/name and quest location ID.
- **Source** — `API/MapsFile.cs#GetMapPixelID`, `API/MapsFile.cs#WorldCoordToMapPixel`, `Utility/ContentReader.cs#EnumerateMaps`, `Utility/ContentReader.cs#GetQuestLocation`
- **Inputs and outputs** — MAPS.BSA records, map coordinates, region/name or location ID → map summary or DFLocation.
- **Dependencies** — WORLD, LOC, QUEST, SAVE
- **Edge cases and interactions** — Dictionary collisions log an error. A TODO flags forgotten graveyards that start discovered in classic and require additional handling beyond the summary flag.
- **Design questions** — Which identifiers must remain stable across renamed or replaced locations?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-004-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-004 — Approved specification v1](../../design/systems/DATA/DATA-004.md). Stable IDs and classic mappings; one location per pixel initially, with future extension left open; validated geography overrides; separate character discovery and authored defaults; explicit conflict/missing-reference failure. ID, coordinate, discovery and save-compatibility contracts remain dependencies.

## DATA-005 — Exterior and dungeon block records

- **Parent subsystem** — World definitions
- **Purpose** — Provide the structural records used to assemble locations.
- **Existing implementation** — BlocksFile resolves archive names and returns typed DFBlock data. ContentReader rejects unknown block types. RMBLayout and RDBLayout are assembly consumers.
- **Source** — `API/BlocksFile.cs#GetBlock`, `API/DFBlock.cs`, `Utility/ContentReader.cs#GetBlock`, `Utility/RMBLayout.cs`, `Utility/RDBLayout.cs`
- **Inputs and outputs** — BLOCKS.BSA and block name/index → typed exterior or dungeon block records.
- **Dependencies** — LOC, WORLD, QUEST, MOD
- **Edge cases and interactions** — Unknown blocks fail lookup. Markers, action chains and placement depend on record contents and runtime assembly. Compare representative blocks.
- **Design questions** — Which block properties and IDs must survive import?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-005-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-005 — Approved specification v1](../../design/systems/DATA/DATA-005.md). Supported classic structural fidelity, scoped definition/placement/record identity, independent live state, purpose-specific markers, validated action links and explicit required-block failure. Format coverage, conversion fixtures and save/quest compatibility remain dependencies.

## DATA-006 — Terrain and climate data

- **Parent subsystem** — World definitions
- **Purpose** — Supply map-scale samples and climate inputs.
- **Existing implementation** — WoodsFile exposes height and larger map-data samples. MapsFile supplies climate settings. Terrain samplers and texturing use these inputs to construct runtime terrain.
- **Source** — `API/WoodsFile.cs#GetHeightMapValue`, `API/WoodsFile.cs#GetLargeMapData`, `API/MapsFile.cs#GetWorldClimateSettings`, `Terrain/DefaultTerrainSampler.cs`, `Terrain/TerrainTexturing.cs`
- **Inputs and outputs** — Classic geography and climate codes → sample and climate data used for terrain and visuals.
- **Dependencies** — WORLD, TIME, AV
- **Edge cases and interactions** — Coastlines, map edges and coordinate orientation need fixture checks. Unity terrain construction belongs to WORLD.
- **Design questions** — Which classic samples should be preserved and where may terrain generation interpolate?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-006-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-006 — Approved specification v1](../../design/systems/DATA/DATA-006.md). Classic source baseline, WORLD-owned generation, shared climate definitions, data-defined extensible world bounds, explicit edge sampling and complete validated mod extensions. Coordinate/coverage schemas, consumer expansion support and save compatibility remain dependencies.

## DATA-007 — Flat and encounter definition lookup

- **Parent subsystem** — World definitions
- **Purpose** — Resolve classic object and monster records for downstream placement.
- **Existing implementation** — ContentReader initializes FlatsFile, MonsterFile and PaintFile. FlatsFile maps archive/record pairs to flat IDs and provides flat record lookup. These are data sources distinct from AI and placement rules.
- **Source** — `Utility/ContentReader.cs#SetupReaders`, `API/FlatsFile.cs#GetFlatData`, `API/FlatsFile.cs#GetFlatID`, `API/MonsterFile.cs`, `API/PaintFile.cs`
- **Inputs and outputs** — Classic files and flat or monster identifiers → definition records.
- **Dependencies** — LOC, NPC, AV
- **Edge cases and interactions** — Full consumer coverage and how code-defined enemy properties supplement classic records remain open.
- **Design questions** — Which original object fields are needed for placement or behavior?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-007-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-007 — Approved specification v1](../../design/systems/DATA/DATA-007.md). Stable domain IDs and classic mappings, explicit appearance/gameplay links, owner-separated behavior and truthful required/optional failures. Consumer coverage, enemy-property provenance, metadata schemas and compatibility remain dependencies.

## DATA-008 — Class and biography data

- **Parent subsystem** — Game definitions
- **Purpose** — Provide source definitions used in character creation.
- **Existing implementation** — ClassFile loads career data from file or BinaryReader. BiogFile uses the character document for biography handling, exposes skill effects and applies effects to the player through the startup flow.
- **Source** — `API/ClassFile.cs#Load`, `API/DFCareer.cs`, `API/BiogFile.cs#ApplyEffects`, `API/BiogFile.cs#GetSkillEffects`, `Game/Utility/StartGameBehaviour.cs#StartNewCharacter`
- **Inputs and outputs** — Career data, biography content and character selections → career/biography data and effect inputs.
- **Dependencies** — CHAR, CORE-012, UI
- **Edge cases and interactions** — Custom career affinity and biography sources need a fixture trace. Rule balancing is CHAR scope.
- **Design questions** — Which creation options should be authored as data, and which biography effects require stable IDs?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-008-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-008 — Approved specification v1](../../design/systems/DATA/DATA-008.md). Stable class/biography/choice IDs, validated effect inputs, owner-applied consequences, isolated previews and explicit CHAR-owned biography selection. Effect schemas, balance/random policies, narrative and save contracts remain dependencies.

## DATA-009 — Faction source records

- **Parent subsystem** — Game definitions
- **Purpose** — Load the base faction definitions and support extensions.
- **Existing implementation** — ContentReader uses StreamingAssets/Factions/FACTION.TXT. FactionFile exposes ID/name lookup, custom faction registration and classic save merging/relinking.
- **Source** — `Utility/ContentReader.cs#GetFactionFilePath`, `API/FactionFile.cs#RegisterCustomFaction`, `API/FactionFile.cs#Merge`, `API/FactionFile.cs#RelinkChildren`
- **Inputs and outputs** — Packaged faction definitions, custom registrations and classic saved data → faction records and links.
- **Dependencies** — FACT, NPC, QUEST, SAVE, MOD
- **Edge cases and interactions** — Exact packaged differences from original data and ID collision handling across enabled mods need comparison.
- **Design questions** — Which faction IDs and relationships are authoritative across content packs?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-009-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-009 — Approved specification v1](../../design/systems/DATA/DATA-009.md). Stable faction IDs, separate definitions/live state, validated parent hierarchy, directional relationships and explicit reference/compatibility failures. Baseline/schema verification, FACT rules and save contracts remain dependencies.

## DATA-010 — Item and magic-item templates

- **Parent subsystem** — Game definitions
- **Purpose** — Supply base definitions for item creation and naming.
- **Existing implementation** — ItemHelper deserializes Resources text assets into item and magic-item template lists and loads a book mapping. It exposes template lookup and custom item registration by template index.
- **Source** — `Game/Items/ItemHelper.cs#LoadItemTemplates`, `Game/Items/ItemHelper.cs#LoadMagicItemTemplates`, `Game/Items/ItemHelper.cs#RegisterCustomItem`, `API/ItemsFile.cs`, `API/MagicItemsFile.cs`
- **Inputs and outputs** — Packaged template resources, mappings and template indices → runtime item definitions.
- **Dependencies** — ITEM, MAGIC, MOD, SAVE
- **Edge cases and interactions** — Classic readers exist alongside packaged templates. Check provenance and index compatibility before treating their contents as equivalent.
- **Design questions** — How should template identity and extension coexist with saved items?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-010-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-010 — Approved specification v1](../../design/systems/DATA/DATA-010.md). Stable template IDs/classic mappings, separate instance state, validated references, explicit special-behavior providers and saved-item compatibility. Schemas, provenance, balance/provider and save contracts remain dependencies.

## DATA-011 — Classic spell records and patches

- **Parent subsystem** — Game definitions
- **Purpose** — Provide stable spell records for lookup and conversion.
- **Existing implementation** — The broker reads classic spell records from ARENA2, merges SpellRecords.json by index, builds a dictionary and skips later duplicate indices. Conversion into an effect bundle is a distinct broker operation.
- **Source** — `Utility/DaggerfallSpellReader.cs#ReadSpellsFile`, `Game/MagicAndEffects/EntityEffectBroker.cs#RebuildClassicSpellsDict`, `Game/MagicAndEffects/EntityEffectBroker.cs#ClassicSpellRecordDataToEffectBundleSettings`
- **Inputs and outputs** — Classic spell records and patches → indexed standard spells and convertible settings.
- **Dependencies** — MAGIC, MOD, DATA-003
- **Edge cases and interactions** — Source comments identify Holy Touch and Holy Word as a duplicate-ID case. Compare actual archive and patch ordering.
- **Design questions** — How should classic ID collisions and unmapped effects be represented?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-011-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-011 — Approved specification v1](../../design/systems/DATA/DATA-011.md). Stable spell IDs, preserved/disambiguated classic collisions, complete active-effect conversion and conditional approved baseline corrections before overrides. Mapping/schema, individual correction, MAGIC and save contracts remain dependencies.

## DATA-012 — Quest script and table sources

- **Parent subsystem** — Game definitions
- **Purpose** — Supply authored scripts, lists and symbol inputs to the quest runtime.
- **Existing implementation** — QuestMachine exposes source lookup for quest scripts and tables. QuestListsManager discovers quest-pack lists and loads the lists used for selection. Shipped inputs include QuestList-Classic.txt, QuestList-DFU.txt and Quests-*.txt.
- **Source** — `Game/Questing/QuestMachine.cs#GetQuestSourceText`, `Game/Questing/QuestMachine.cs#GetTableSourceText`, `Game/Questing/QuestListsManager.cs#DiscoverQuestPackLists`, `Game/Questing/QuestListsManager.cs#LoadQuestLists`
- **Inputs and outputs** — Quest name, table name, packaged inputs and packs → source lines and candidate lists.
- **Dependencies** — QUEST, FACT, MOD
- **Edge cases and interactions** — Verify duplicate quest names, pack ordering and localized script coverage. Selection and execution belong to QUEST.
- **Design questions** — What distinguishes a new quest from an override of an existing one?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-012-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-012 — Approved specification v1](../../design/systems/DATA/DATA-012.md). Stable quest/list/table IDs, explicit resolution and source failures, side-effect-free QUEST validation, controlled list duplicates and active/history save compatibility. Schemas, grammar/provider, selection and restoration contracts remain dependencies.

## DATA-013 — Localized string lookup and fallback

- **Parent subsystem** — Language and text
- **Purpose** — Resolve player-facing text by collection and key.
- **Existing implementation** — TextManager tries the runtime collection, then the default collection. The reversion overload can use a caller-provided literal. Unresolved keys can produce an error string or throw.
- **Source** — `Game/TextManager.cs#GetLocalizedText`, `Game/TextManager.cs#GetLocalizedTextWithReversion`, `Localization/LocalizationEnums.cs`
- **Inputs and outputs** — Collection, key, locale configuration and optional literal → resolved string or failure.
- **Dependencies** — UI, NPC, ITEM, MAGIC, Unity Localization
- **Edge cases and interactions** — Actual locale catalogs and initialization timing require asset/runtime verification. RSC provider has its own fallback in DATA-015.
- **Design questions** — How should missing strings be surfaced to players and translators?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-013-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-013 — Approved specification v1](../../design/systems/DATA/DATA-013.md). Stable text keys, selected/base/source fallback, independent essential labels, explicit blank/format handling and side-effect-free live language selection. Catalog, token/font, settings/refresh and history contracts remain dependencies.

## DATA-014 — CSV string table patches

- **Parent subsystem** — Language and text
- **Purpose** — Support loose text corrections and additions.
- **Existing implementation** — The table postprocessor loads rows using the collection name. It replaces existing StringTable values by key or adds new entries. Other LocalizationTable types are ignored.
- **Source** — `Game/StringTablePatcher.cs#PostprocessTable`, `Game/StringTableCSVParser.cs#Load`
- **Inputs and outputs** — StringTable and StreamingAssets/Text CSV rows → patched table.
- **Dependencies** — MOD, UI, Unity Localization, DATA-013
- **Edge cases and interactions** — Confirm that the shipped settings attach the postprocessor, and test duplicate keys, malformed rows and locale scope.
- **Design questions** — Should patch files target a locale, a collection or both?
- **Complexity** — Small
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-014-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-014 — Approved specification v1](../../design/systems/DATA/DATA-014.md). Explicit collection/locale add/replace patches, deterministic precedence, UTF-8 CSV support, whole-file structural rejection and separate text-usability fallback. Schema/normalization, token validation and integration fixtures remain dependencies.

## DATA-015 — Classic text records and formatting tokens

- **Parent subsystem** — Language and text
- **Purpose** — Expose classic-format messages to UI and dialogue.
- **Existing implementation** — Numeric RSC lookup tries localized text converted into tokens, then lazily opens TEXT.RSC and decodes the numeric record. String IDs only attempt localization. Random variants split subrecords and use classic or Unity random selection depending on the flag.
- **Source** — `Utility/TextProvider.cs#GetRSCTokens`, `Utility/TextProvider.cs#GetRandomTokens`, `API/TextFile.cs#ReadTokens`, `Utility/FallbackTextProvider.cs`
- **Inputs and outputs** — Record ID, active RSC collection and random mode → formatted token stream.
- **Dependencies** — UI, NPC, QUEST, RULE, DATA-013
- **Edge cases and interactions** — Missing numeric records can return null. The variant selector assumes usable tokens and decrements the selected index for an empty stream. Test absent and empty records explicitly.
- **Design questions** — Which formatting controls and message variants must retain classic semantics?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-015-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-015 — Approved specification v1](../../design/systems/DATA/DATA-015.md). Structured classic messages, explicit source fallback, owner-controlled variant selection, unusable-token/empty-variant handling and separate interaction authority. Token/rendering, variant/RNG and save contracts remain dependencies.

## DATA-016 — Dynamic message and quest macros

- **Parent subsystem** — Language and text
- **Purpose** — Fill authored text with current world and quest context.
- **Existing implementation** — MacroHelper expands tokens using handlers and context providers, including multiline handlers. QuestMacroHelper expands quest message or string symbols using quest resources and can reveal dialogue links during message expansion.
- **Source** — `Utility/MacroHelper.cs#ExpandMacros`, `Utility/MacroHelper.cs#GetValue`, `Utility/IMacroContextProvider.cs`, `Utility/QuestMacroHelper.cs#ExpandQuestMessage`, `Utility/QuestMacroHelper.cs#ExpandQuestString`
- **Inputs and outputs** — Tokens or text, context provider and quest resource state → rendered text and optional link visibility.
- **Dependencies** — NPC, QUEST, UI, FACT, DATA-015
- **Edge cases and interactions** — Exact behavior of unresolved symbols and ordering across generic and quest-specific expansion needs representative scripts and missing-context fixtures.
- **Design questions** — How should translators and authors see available context variables and missing substitutions?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-016-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-016 — Approved specification v1](../../design/systems/DATA/DATA-016.md). Explicit scoped context, pure expansion, retained generated values, declared macro registry, safe multiline/literal/nested handling and owner-committed reveals. Context/provider, grammar/RNG, reveal and save contracts remain dependencies.

## DATA-017 — Name-bank selection

- **Parent subsystem** — Language and text
- **Purpose** — Generate names using race, region or caller context.
- **Existing implementation** — NameHelper exposes gender- and bank-based first-name and surname generation. MacroHelper selects banks and supplies name substitutions. MapsFile exposes a region-to-bank helper.
- **Source** — `Game/Utility/NameHelper.cs#FullName`, `Game/Utility/NameHelper.cs#FirstName`, `Game/Utility/NameHelper.cs#Surname`, `Utility/MacroHelper.cs#GetNameBank`, `API/MapsFile.cs#GetNameBankOfRegion`
- **Inputs and outputs** — Bank, gender or region context → generated name components.
- **Dependencies** — CHAR, NPC, QUEST, RULE
- **Edge cases and interactions** — Name-bank provenance, seeding and repeatability across consumers require additional inspection.
- **Design questions** — Should generated names remain stable across saves and locales?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-017-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-017 — Approved specification v1](../../design/systems/DATA/DATA-017.md). Extensible validated banks/mappings, owned generation and isolated previews, stable persistent names across saves/locales/bank edits. Pattern/mapping, RNG, presentation and versioned persistence contracts remain dependencies.

## DATA-018 — Readable book sourcing

- **Parent subsystem** — Language and text
- **Purpose** — Select a readable book edition and its metadata.
- **Existing implementation** — LocalizedBook tries a localized book first, then classic. Its existence check looks for the suffixed localized asset in mods or the loose text book directory. ItemHelper maps book IDs to filenames.
- **Source** — `Game/LocalizedBook.cs#OpenBookFile`, `Game/LocalizedBook.cs#OpenLocalizedBookFile`, `Game/LocalizedBook.cs#OpenClassicBookFile`, `API/BookFile.cs`, `Utility/AssetInjection/BookReplacement.cs#TryImportBook`
- **Inputs and outputs** — Book ID or filename, localized files and classic records → book content and layout inputs.
- **Dependencies** — ITEM, UI, MOD, DATA-010
- **Edge cases and interactions** — The localized existence check is narrower than opening a book. Check malformed local editions and compare pagination/formatting against originals.
- **Design questions** — Which edition should win, and what metadata should stay attached across translations?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-018-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-018 — Approved specification v1](../../design/systems/DATA/DATA-018.md). Stable work/edition identity, complete-edition fallback, separate gameplay metadata, validated layout, item-preserving failures and anchor-based position. Schema/rendering, reading-effect and bookmark/save contracts remain dependencies.

## DATA-019 — Locale fonts and glyph coverage

- **Parent subsystem** — Language and text
- **Purpose** — Associate a font variant with locale and font role.
- **Existing implementation** — TextManager registers and looks up localized DaggerfallFont instances keyed by locale and font name. The project includes font assets and an original font reader.
- **Source** — `Game/TextManager.cs#RegisterLocalizedFont`, `Game/TextManager.cs#GetLocalizedFont`, `Game/UserInterface/DaggerfallFont.cs`, `API/FntFile.cs`
- **Inputs and outputs** — Locale, font role and registered assets → localized font selection.
- **Dependencies** — UI, AV, Unity Localization
- **Edge cases and interactions** — Font fallback, unsupported glyphs, wrapping and mixed-language display need rendered samples.
- **Design questions** — What scripts and formatting should the text renderer support?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-019-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-019 — Approved specification v1](../../design/systems/DATA/DATA-019.md). Extensible locale/role fonts, declared glyph fallback, verified Unicode/script support, actual-font reflow and independent readable recovery. Resource/coverage, layout/settings and rendered fixture contracts remain dependencies.

## DATA-020 — Translation table import and token round-trip

- **Parent subsystem** — Language and text
- **Purpose** — Convert classic records to editable localization entries.
- **Existing implementation** — The editor importer has copy operations for RSC, flats, locations, spells, items and factions with overwrite controls. Conversion helpers map classic RSC token streams to and from strings.
- **Source** — `Localization/DaggerfallStringTableImporter.cs#ConvertRSCTokensToString`, `Localization/DaggerfallStringTableImporter.cs#ConvertStringToRSCTokens`, `Localization/DaggerfallStringTableImporter.cs#CopyTextRSCToStringTable`
- **Inputs and outputs** — Source records, target table and overwrite flag → authored localization entries or runtime tokens.
- **Dependencies** — DEV, DATA-013, DATA-015, Unity Localization
- **Edge cases and interactions** — Explicit trimming exceptions indicate that whitespace can be meaningful. Verify markup round-trip and collisions before bulk import.
- **Design questions** — Which layout controls must remain visible and editable to translators?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-020-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-020 — Approved specification v1](../../design/systems/DATA/DATA-020.md). Supported structural round trips, escaped editable markup, previewed atomic imports, idempotent stable mappings and retained needs-review translations. Codec/schema, authoring persistence and rendered fixture contracts remain dependencies.

## DATA-021 — Classic meshes and model substitution

- **Parent subsystem** — Media conversion
- **Purpose** — Convert model records into geometry consumable by the world.
- **Existing implementation** — MeshReader resolves model IDs, caches model data, and produces Unity meshes. The injection layer can supply custom GameObjects for model or flat IDs.
- **Source** — `MeshReader.cs#GetModelData`, `MeshReader.cs#GetMesh`, `MeshReader.cs#ClearCache`, `API/Arch3dFile.cs`, `Utility/AssetInjection/MeshReplacement.cs#ImportCustomGameobject`
- **Inputs and outputs** — Model ID, classic mesh records and optional replacements → geometry or replacement object.
- **Dependencies** — AV, LOC, WORLD, MOD
- **Edge cases and interactions** — Compare model patches, scale, UVs and replacement behavior in automap and world assembly with fixtures.
- **Design questions** — What model identity and geometry properties must survive conversion?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-021-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-021 — Approved specification v1](../../design/systems/DATA/DATA-021.md). Verified classic conversion, stable resource versus placement identity, explicit visual/gameplay replacement boundaries, truthful replacement failure, compatible variants and source-aware caches. Conversion/representation, variant/cache and save contracts remain dependencies.

## DATA-022 — Textures, images and material variants

- **Parent subsystem** — Media conversion
- **Purpose** — Decode indexed imagery and resolve visual variants.
- **Existing implementation** — TextureReader creates textures from classic images and builds atlases/terrain arrays. MaterialReader resolves archive/record/frame materials, caches results and exposes climate changes. TextureReplacement offers replacement material and image imports.
- **Source** — `Utility/TextureReader.cs#CreateFromAPIImage`, `Utility/TextureReader.cs#GetTexture2DAtlas`, `MaterialReader.cs#GetMaterial`, `MaterialReader.cs#ChangeClimate`, `Utility/AssetInjection/TextureReplacement.cs#TryImportMaterial`, `API/TextureFile.cs`
- **Inputs and outputs** — Image/archive key, palette, alpha/frame options, climate and replacement assets → textures or materials.
- **Dependencies** — AV, WORLD, LOC, UI, ITEM, MOD
- **Edge cases and interactions** — Verify cache keys and precedence with dye, climate, transparency and animation combinations. Legacy image families use distinct readers.
- **Design questions** — Which variant dimensions and replacement keys should content authors control?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-022-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-022 — Approved specification v1](../../design/systems/DATA/DATA-022.md). Stable imagery/material identity, verified classic conversion, explicit variants/replacement scopes, required/optional failure rules and complete source-aware cache identity. Format/variant/animation, AV/provider and fixture contracts remain dependencies.

## DATA-023 — Sound, music and video inputs

- **Parent subsystem** — Media conversion
- **Purpose** — Resolve media from classic and supplied assets.
- **Existing implementation** — SoundReader looks up and caches playable clips from sound records by ID or index. The project has Songs resources and song-player code. Separate injection helpers try replacement sound, MIDI/song and movie assets.
- **Source** — `SoundReader.cs#GetAudioClip`, `API/SndFile.cs`, `Internal/DaggerfallSongPlayer.cs`, `Utility/AssetInjection/SoundReplacement.cs#TryImportMidiSong`, `Utility/AssetInjection/VideoReplacement.cs#TryImportMovie`, `API/VidFile.cs`
- **Inputs and outputs** — Media IDs/names, classic files, packaged media and replacements → audio clips, song data or movie player inputs.
- **Dependencies** — AV, UI, MOD
- **Edge cases and interactions** — Codec coverage, sound-font selection, replacement precedence and classic movie support need fixtures. Playback scheduling belongs to AV.
- **Design questions** — Which media formats and fallback behaviors are required for reference parity?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-023-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-023 — Approved specification v1](../../design/systems/DATA/DATA-023.md). Stable media identity, explicit verified formats, separate playback authority, owner-declared failure policies and source-aware reusable resources. Approved optional-video/death bypass remains intact; AV/platform, synthesis and save contracts remain dependencies.

## DATA-024 — World-data replacement and variants

- **Parent subsystem** — World definitions
- **Purpose** — Expose alternate records to world assembly.
- **Existing implementation** — The asset-injection world-data layer handles replacement and variation data separately from classic map and block readers. SaveLoadManager restores saved world variation data before player-position reconstruction.
- **Source** — `Utility/AssetInjection/WorldDataReplacement.cs`, `Utility/AssetInjection/WorldDataVariants.cs`, `Game/Serialization/SaveLoadManager.cs#LoadGame`
- **Inputs and outputs** — Replacement assets, variant data and saved variation state → alternate world data used during assembly.
- **Dependencies** — WORLD, LOC, MOD, SAVE, DATA-004, DATA-005
- **Edge cases and interactions** — Trace keys and precedence per data type. Persistent marker identity and behavior when a pack disappears remain open.
- **Design questions** — How should a save identify and recover a changed or unavailable world variant?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-05; approval DATA-024-A01. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

[DATA-024 — Approved specification v1](../../design/systems/DATA/DATA-024.md). Separate installed definitions/session selections, explicit scoped identity, restore-before-reconstruction, validated runtime transitions and explicit baseline reset. Scope/schema, transition/cache and save compatibility contracts remain dependencies.

## Classic inheritance and review sequence

- Classic archives supply geographic records, blocks, formatted text, models and spell data. Reader schemas and conversions establish how DFU interprets those files. They do not establish the actual record values, completeness across classic editions, or whether original execution used the same rules.
- DFU layers include packaged templates and quest lists, Unity Localization collections, CSV patches, asset conversion, and mod or loose-file resolution. Compare packaged tables with classic inputs before assigning provenance to individual records.
- Start with DATA-001 through DATA-003. Test a valid install, a missing install, an earlier invalid candidate and conflicting loose/mod inputs. Then review world, item and spell identities with fixtures. Review localization next with a missing key, a patched key, a formatted RSC record, a macro and a book.
- Confirm serialized localization settings, Addressables tables and font wiring. Sample legacy media families and replacement combinations with AV and MOD. Run world variant and quest-location fixtures with LOC, QUEST and SAVE.
- Scope check separated record identity, block decoding, terrain data and world replacements. Localized string lookup, classic token fallback, macros, font selection and translation import each have distinct review entries. Classic save format and restoration remain under SAVE and CORE-014.

