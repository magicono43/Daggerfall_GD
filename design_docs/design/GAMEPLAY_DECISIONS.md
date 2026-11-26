# Gameplay and feature decisions

Individual decisions can be confirmed before a complete feature specification is approved.

## Standing project data policy

- **PROJECT-DATA-D03 — 2026-11-23 — Vanilla motion axes do not block structural import.**
  The user requested resolution of the remaining axis rejection and stated that
  vanilla dungeon blocks should not be rejected. Out-of-enum axis bytes in
  otherwise structurally valid classic model actions are retained alongside their
  recognized action/required links, with separate pending interpretation metadata.
  Record DFU's TRP rotation/13 NegativeX/magnitude-400 special case and generic
  zero-motion default; do not infer a universal bitmask or execute unqualified
  behavior. All 187 pinned RDB blocks must pass structural decoding. This supersedes
  D02's axis rejection requirement only; malformed data, resources, required links
  and authored-action validation remain checked. RDI auxiliary data is not RDB
  geometry. Gameplay-owner, placement and SAVE readiness remain separate.

- **PROJECT-DATA-D02 — 2026-11-23 — Unknown classic actions remain metadata.**
  During IMP-061 increment3, the user authorized: "Extend DATA to retain the
  unknown action as non-executing metadata with gameplay readiness pending" and
  requested consistent treatment of unknown vanilla actions and an AGENTS.md
  update. Preserve their raw code, parameters, target address and provenance;
  omit executable dispatch/outgoing edges without discarding their records or
  inventing behavior. Known actions, malformed-source checks, unsupported required
  axes, resources and required bindings retain their validation. Unknown-action
  owner state remains explicitly pending. This is a structural import policy,
  not approval to execute unknown authored mod actions or claim SAVE/gameplay
  readiness. The same user authorized a documented DFU north-facing opening
  baseline; original executable facing is not claimed verified. Prior source
  rejection evidence remains historical, superseded by this authorized policy.
  D03 supersedes the original unsupported-axis rejection requirement.

- **PROJECT-DATA-D01 — 2026-11-21 — User-authorized source/correction discretion.**
  The user clarified that DFU data and corrections are allowed and agents should
  use whichever source makes the most sense, keeping related content reasonably
  consistent where possible. Modding is the highest overall priority; exact vanilla
  values and bug-for-bug fidelity are not required, since data will be changed or
  replaced through mods. Original data, DFU packaged data/corrections and documented
  combinations are valid baseline choices. Agents may adopt sensible routine
  data/compatibility corrections within an authorized task without requesting
  separate approval solely because they differ from vanilla or originate in DFU.
  Record source/license provenance, rationale, consistency checks and intentional
  differences. Preserve stable identity, validation, explicit correction matching
  and later mod/loose override precedence. This supersedes older blanket
  reference-only restrictions and individual-approval requirements for routine
  source/correction choices, including DATA-011-D05's earlier approval wording.
  Explicitly approved gameplay/architecture, task scope, owner readiness and
  save/state safeguards still apply; material conflicts require clarification.
  This records standing guidance and changes no runtime data by itself.

  User: “the modding aspect is the most important overall” and “use whichever
  data source makes sense to.” See the standing policy in repository AGENTS.md.

## DEV-014 decisions

- **DEV-014-D01 — 2026-11-18.** Start with failed restore preservation, enemy placement and combat, and quest fault/retry scenarios. Add focused formula and classic conversion checks as those owners implement behavior. The user answered “1. Yes”.
- **DEV-014-D02 — 2026-11-18.** Run headless checks on proposed changes and rendered checks separately. Use isolated test storage and controlled seed, clock and input where relevant. The user explicitly requested a separate rendered run.
- **DEV-014-A01 — 2026-11-18.** The user approved [DEV-014 Draft v1](systems/DEV/DEV-014.md) with “I approve”, including independent suite execution, isolated fixtures and reporting with reproduction details. The specification is finalized as v1.

## DEV-013 decisions

- **DEV-013-D01 — 2026-11-18.** Use a graphical import preview grouped by locale and collection, showing new keys, changed source text, conflicts and validation errors. Apply selected changes and preserve existing translations by default. The user answered “1. Yes”.
- **DEV-013-D02 — 2026-11-18.** Report localization issues by key, locale and source where available. Block packaging for loader-rejected contributions and warn for missing translations with approved fallback. The user answered “2. Yes”.
- **DEV-013-A01 — 2026-11-18.** The user approved [DEV-013 Draft v1](systems/DEV/DEV-013.md) with “I approve”, including preview refresh and shared graphical and command-line validation rules. The specification is finalized as v1.

## DEV-012 decisions

- **DEV-012-D01 — 2026-11-18.** Support exterior block arrangement in existing settlements and object, entrance, marker and action-link editing in existing interiors and dungeons. Support reusable and placement-specific variants. The user answered “1. Yes”.
- **DEV-012-D02 — 2026-11-18.** Preserve retained record IDs, flag known dependent references and block exports with broken required links. Require a validated mapping to claim compatibility for changed persistent records. Otherwise a valid variant can publish as incompatible with affected saves under existing recovery. The user answered “2. Yes”.
- **DEV-012-D03 — 2026-11-18.** Include creation of entirely new locations and terrain shaping for those locations and their approaches. The user confirmed “Both”.
- **DEV-012-A01 — 2026-11-18.** The user approved [DEV-012 Draft v1](systems/DEV/DEV-012.md) with “I approve”, including the isolated workspace and export validation rules. The specification is finalized as v1.

## DEV-011 decisions

- **DEV-011-D01 — 2026-11-18.** Create native exterior blocks or edit copies of supported classic blocks. Support adding, moving and removing buildings and scenery, ground tile editing and reusable object groups. Interior and whole-settlement editing have separate workflows. The user answered “1. Yes”.
- **DEV-011-D02 — 2026-11-18.** Allow unfinished drafts. Check required assets, stable IDs and door/building links before playable export. Check required routes and entrances with settlement and terrain context. Report missing context and preserve the runtime validation gate. The user answered “2. Yes”.
- **DEV-011-A01 — 2026-11-18.** The user approved [DEV-011 Draft v1](systems/DEV/DEV-011.md) with “I approve”, including the workspace, stable identity, group import and export validation rules. The specification is finalized as v1.

## DEV-010 decisions

- **DEV-010-D01 — 2026-11-18.** Provide searchable 3D previews of settlement exteriors, interiors and dungeons, including nearby exterior terrain. Selection shows stable identity, source and transform. Show placement and connection warnings from existing validators when available. The user answered “1. Yes”.
- **DEV-010-D02 — 2026-11-18.** Keep inspection read-only and provide optional block boundary, entrance and collision overlays. Persistent edits belong to later block and world authoring review. The user answered “2. Yes”.
- **DEV-010-A01 — 2026-11-18.** The user approved [DEV-010 Draft v1](systems/DEV/DEV-010.md) with “I approve”, including the independent preview camera, selection focus and partial-preview diagnostics. Dungeon previews use the resolved layout. The specification is finalized as v1.

## DEV-009 decisions

- **DEV-009-D01 — 2026-11-18.** Add a 3D model viewer to the initial content tooling so authors can find and inspect game models visually. The user requested this in addition to the proposed source inspection scope.
- **DEV-009-D02 — 2026-11-18.** Write editable exports to a chosen workspace and validate supported exports against the game's loaders. Unedited reimport preserves the fields and behavior represented by the supported schema. Inspection previews may omit details when clearly labeled. The user answered “2. Yes”.
- **DEV-009-D03 — 2026-11-18.** Support mesh and texture export where feasible. The user said “also export meshes and textures, if possible.”
- **DEV-009-D04 — 2026-11-18.** Exclude byte-exact classic record exports from initial scope. The user clarified “Keep it out of the initial scope.”
- **DEV-009-A01 — 2026-11-18.** The user approved [DEV-009 Draft v1](systems/DEV/DEV-009.md) with “I approve”, including supported static mesh and PNG texture exports, advance disclosure of conversion losses and confirmation before replacing files. The specification is finalized as v1.

## DEV-008 decision

- **DEV-008-D01 — 2026-11-18.** Defer [DEV-008](systems/DEV/DEV-008.md) until there is a concrete need to inspect a classic save record or investigate a behavior. The user confirmed with “Yes defer this”.

## DEV-007 decision

- **DEV-007-D01 — 2026-11-18.** Defer [DEV-007](systems/DEV/DEV-007.md) until a concrete standalone preview or worldless testing need is identified. Preserve the CORE-009 deferral. The user confirmed that deferring makes sense.

## DEV-006 decisions

- **DEV-006-D01 — 2026-11-18.** Use ad hoc test arenas and the normal enemy setup path. A dedicated arena builder or separate `SetupDemoEnemy`-style fixture is outside the intended DEV-006 scope.
- **DEV-006-D02 — 2026-11-18.** Add a developer console command to spawn any registered enemy NPC in any ready gameplay session. Spawned enemies follow ordinary combat, loot and save rules. The user confirmed live-session spawning with “1. Yes”.
- **DEV-006-D03 — 2026-11-18.** Spawn one enemy at the aimed point within a short range. Apply the archetype's normal placement rules. Reject an obstructed or unsuitable placement with a reason and leave the scene unchanged. The user answered “2. Yes”.
- **DEV-006-D04 — 2026-11-18.** Provide explicit enemy AI on, off and status controls for the aimed enemy and for the full current session, including newly spawned enemies. Clear overrides on session end or successful save load. Damage, knockback and death remain available. The user confirmed both proposals with “1. Yes” and “2. Yes”.
- **DEV-006-A01 — 2026-11-18.** The user approved [DEV-006 Draft v1](systems/DEV/DEV-006.md) with “I approve”, including its spawn targeting and overlapping AI suppression rules. The specification is finalized as v1.

## DEV-005 decisions

- **DEV-005-D01 — 2026-11-18.** Capture the displayed game view with its visible HUD and other UI. Let the player toggle the gameplay HUD for a less obstructed screenshot. The user accepted the full-view capture proposal and requested the HUD toggle.
- **DEV-005-D02 — 2026-11-18.** Use lossless PNG, default to `Screenshots` under the active root, preserve existing captures under timestamp collisions and report success or failure. The user agreed and expressed interest in an editable output folder. See DEV-005-A01 for the approved override.
- **DEV-005-A01 — 2026-11-18.** The user approved [DEV-005 Draft v1](systems/DEV/DEV-005.md) with “I approve”, including the separate rebindable HUD shortcut, saved manual screenshot folder override and failure behavior. The specification is finalized as v1.

## DEV-004 decisions

- **DEV-004-D01 — 2026-11-18.** Open a searchable in-game quest inspector through the developer console. Inspect the current session read-only. Limit quest launches and other state-changing test controls to the approved isolated in-world test workflow. The user answered “1. Yes”.
- **DEV-004-D02 — 2026-11-18.** Keep a bounded detailed quest trace for the current application run and support explicit local export from the debugger. Preserve the separate durable recovery policy from QUEST-023. The user answered “2. Yes”.
- **DEV-004-A01 — 2026-11-18.** The user approved [DEV-004 Draft v1](systems/DEV/DEV-004.md) with “I approve”, including the 1,000-entry and 4 MiB bounds per run, eviction and sanitized local export behavior. The specification is finalized as v1.

## DEV-003 decisions

- **DEV-003-D01 — 2026-11-18.** Make the runtime console available to everyone by default. Provide a saved application-wide setting, enabled by default, that disables console access until reenabled in Settings. The user confirmed the setting with “1. Yes”.
- **DEV-003-D02 — 2026-11-18.** Let players use commands, including state-changing commands. See D07 for the initial list and the approved specification for command eligibility.
- **DEV-003-D03 — 2026-11-18.** Changes to normally saved game state persist through ordinary saves. Temporary debug modes end with the session. The user answered “2. Yes” to the persistence proposal. See D05 for the save marker decision.
- **DEV-003-D04 — 2026-11-18.** Opening the console pauses the world by default under the existing UI pause rules and gives the console exclusive input focus. Provide a setting for live console use while the world is eligible to run. The user answered “3. Yes” and requested the option to use the console while the game is unpaused.
- **DEV-003-D05 — 2026-11-18.** Saves show no badge or other identifying marker for console command use.
- **DEV-003-D06 — 2026-11-18.** Enabled mods can register commands qualified by mod ID. Reject conflicting registrations with diagnostics. The user answered “2. Yes”.
- **DEV-003-D07 — 2026-11-18.** The initial built-ins include help, session and player inspection, automap reveal, teleport to a validated destination, adding items, changing stats and setting guild rank. The user accepted both the proposed list and the additional examples.
- **DEV-003-A01 — 2026-11-18.** The user approved [DEV-003 Draft v1](systems/DEV/DEV-003.md) with “I approve”, including its operational rules. The specification is finalized as v1.

## DEV-002 decisions

- **DEV-002-D01 — 2026-11-18.** Generate the environment report on demand from startup recovery and normal settings. Present a preview before local export. The user answered “1. Yes”.
- **DEV-002-D02 — 2026-11-18.** Use an explicit list covering game build, OS, CPU/GPU and graphics backend, language, storage mode, selected troubleshooting settings, classic-data validation results, and discovered mod IDs, versions and order. Mark unavailable sections when setup is incomplete. Exclude absolute paths, usernames, device identifiers, credentials, save contents and recursive file listings. The user answered “2. Yes”.
- **DEV-002-A01 — 2026-11-18.** The user approved [DEV-002 Draft v1](systems/DEV/DEV-002.md) with “I approve”, including the export and failure behavior. The specification is finalized as v1.

## DEV-001 decisions

- **DEV-001-D01 — 2026-11-18.** Use approved CORE-002 v1 as the governing specification for startup log retention. The user accepted the recommendation to reference CORE-002 in [DEV-001](systems/DEV/DEV-001.md) with “Yes that sounds like a good idea.”
- **DEV-001-A01 — 2026-11-18.** The user approved DEV-001 Draft v1 with “I approve”. The specification is finalized as v1.

## MOD-016 interview decisions

- **MOD-016-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-016 specification](systems/MOD/MOD-016.md) is finalized as v1, including graphical and command-line tooling as launch targets subject to feasibility, manual packaging, and explicit workspace file inclusion.
- **MOD-016-D01 — 2026-11-18.** Target both graphical and command-line validation and packaging tools at launch, if feasible. Keep manual ZIP creation and unpacked testing supported.
- **MOD-016-D02 — 2026-11-18.** Allow explicit inclusion of files from author-designated workspace folders. Copy included files into the package. Shared assets meant to be installed once follow MOD-001's dependency and export model.

## MOD-015 interview decisions

- **MOD-015-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-015 specification](systems/MOD/MOD-015.md) is finalized as v1, including one save registration per package at launch with room for future expansion, and direct and chained payload migrations during preflight.
- **MOD-015-D01 — 2026-11-18.** Support one save registration per package at launch, with room to increase that limit in a future revision. Mods can organize their payload internally.
- **MOD-015-D02 — 2026-11-18.** Support direct and chained mod payload migrations during preflight. Validate the prepared result before replacing the session and preserve the source generation.

## MOD-014 interview decisions

- **MOD-014-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-014 specification](systems/MOD/MOD-014.md) is finalized as v1, including shared per-root mod preferences, staged presets and confirmed staged resets.
- **MOD-014-D01 — 2026-11-18.** Store one set of preferences per stable mod ID per storage root, shared across profiles.
- **MOD-014-D02 — 2026-11-18.** Selecting a preset stages its declared edits, shows changed values and activation timing, and preserves omitted values. Apply validates and accepts changes. Cancel discards unapplied edits.
- **MOD-014-D03 — 2026-11-18.** Give every mod with editable settings a Reset to Defaults action and ask for confirmation after it is selected.
- **MOD-014-D04 — 2026-11-18.** A confirmed reset stages the selected mod's editable defaults for review and Apply. Canceling the confirmation preserves staged edits. Canceling the unapplied reset follows CORE-006.

## MOD-013 interview decisions

- **MOD-013-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-013 specification](systems/MOD/MOD-013.md) is finalized as v1, including package-scoped identities, cross-package guild services, and conflict handling for window and whole-system replacements.
- **MOD-013-D01 — 2026-11-18.** Scope new faction, guild and service IDs to their creator packages. Allow explicit cross-package service mappings through declared dependencies. Preserve the approved guild access and transaction checks on all routes.
- **MOD-013-D02 — 2026-11-18.** Resolve individual window replacements by UI-003 load order and show providers and the winner in diagnostics. Report incompatible targeted edits during validation. Competing whole-system replacements retain MOD-004's explicit provider choice.

## MOD-012 interview decisions

- **MOD-012-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-012 specification](systems/MOD/MOD-012.md) is finalized as v1, including data-only quest packs, declared custom command dependencies, and isolated in-game testing through normal offers and validated direct starts.
- **MOD-012-D01 — 2026-11-18.** Allow data-only packs to add quests, dialogue and eligible quest-list entries using built-in commands or commands supplied by declared dependencies. Pack-owned executable content is needed only when the pack provides new scripted behavior.
- **MOD-012-D02 — 2026-11-18.** Provide an in-game author tool to select a quest by stable ID in an isolated test session. Support the normal offer path and a direct start that validates required resources and bindings. Distinguish validation, world setup and execution failures.

## MOD-011 interview decisions

- **MOD-011-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-011 specification](systems/MOD/MOD-011.md) is finalized as v1, including provider-scoped identities and dependency-validated cross-package spell offers.
- **MOD-011-D01 — 2026-11-18.** Identify new items, effects and offers by content type, creator package ID and stable local key. Allow explicit cross-package patch or replacement targets under approved domain rules.
- **MOD-011-D02 — 2026-11-18.** Allow one mod to offer a spell supplied by another through a declared dependency and a specific eligible service. An unavailable spell blocks validation of a required offer. An explicitly optional offer remains inactive.

## MOD-010 interview decisions

- **MOD-010-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-010 specification](systems/MOD/MOD-010.md) is finalized as v1, including whole-system provider choice, individual hook precedence, and required-hook validation.
- **MOD-010-D01 — 2026-11-18.** Preserve explicit player choice for competing whole-system replacements under MOD-004 and resolved load-order precedence for individual replacement hooks under RULE-004 and MOVE-025.
- **MOD-010-D02 — 2026-11-18.** Whole-system replacement providers declare which existing hooks they support. Show hooks that the selected provider does not support as inactive in pre-menu diagnostics. An enabled mod's explicit requirement for an unavailable hook blocks Continue pending resolution.

## MOD-009 interview decisions

- **MOD-009-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-009 specification](systems/MOD/MOD-009.md) is finalized as v1, including reusable defaults, placement-specific selections, explicit mapping and conflict recovery, and saved variant compatibility.
- **MOD-009-D01 — 2026-11-18.** Support reusable world variant defaults and explicit placement-specific selections. A valid specific selection wins at its placement. Other placements retain their applicable defaults.
- **MOD-009-D02 — 2026-11-18.** When a broader layout replacement removes a narrower target, report the affected target and both contributing sources. Accept an explicit compatible author-supplied mapping after validation. Otherwise block the affected operation pending resolution.

## MOD-008 interview decisions

- **MOD-008-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-008 specification](systems/MOD/MOD-008.md) is finalized as v1, including explicit media replacement mappings, package-level controls and Content Diagnostics.
- **MOD-008-D01 — 2026-11-18.** Require explicit replacement mappings. Accept stable logical IDs or supported classic identifiers as targets and resolve equivalent identifiers to the same logical asset. Allow supported mod-added logical targets.
- **MOD-008-D02 — 2026-11-18.** Show contributing and winning replacements in Content Diagnostics. Use package-level enablement for routine control at initial release. Preserve explicit invalid-contribution recovery.

## MOD-007 interview decisions

- **MOD-007-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-007 specification](systems/MOD/MOD-007.md) is finalized as v1, including root-wide loose overrides and pre-menu content diagnostics with field-level provenance.
- **MOD-007-D01 — 2026-11-18.** Use one `Overrides` folder alongside `Mods` in the selected storage root. It applies across that root's profiles after the enabled mods. External edits require restart under DATA-003.
- **MOD-007-D02 — 2026-11-18.** Provide an on-demand pre-menu Content Diagnostics view showing contributing and winning sources, including field-level provenance for record patches. Ordinary valid overlaps stay quiet. Invalid patches follow DATA-003 recovery.

## MOD-006 interview decisions

- **MOD-006-A01 — 2026-11-18.** The user approved Draft v1 with “I approve”. The [MOD-006 specification](systems/MOD/MOD-006.md) is finalized as v1, including provider-specific export lookup, approved override precedence and shared read-only assets with independent resources for local edits.
- **MOD-006-D01 — 2026-11-17.** Resolve an explicit exported asset reference to the selected provider package ID and asset key. Report a missing or wrong-type export through applicable validation. Requests for logical game assets follow the approved override order.
- **MOD-006-D02 — 2026-11-17.** Share read-only asset data by default. Give callers independent instances or editable resources for local mutations while retaining shared immutable resources where possible.

## MOD-005 interview decisions

- **MOD-005-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [MOD-005 specification](systems/MOD/MOD-005.md) is finalized as v1, including application and character session scopes, distinct readiness milestones, verified cleanup and explicit optional fallback.
- **MOD-005-D01 — 2026-11-17.** Register application-wide mod behavior during pre-menu activation after any required consent. Set up separate character-specific mod state and listeners for each new or loaded session and clean them up at session end.
- **MOD-005-D02 — 2026-11-17.** Block the affected activation step on failure and identify the mod and phase. Offer retry or configuration changes when cleanup is verified and the configuration is still editable. Require restart before another activation attempt when safe cleanup cannot be established. Preserve CORE recovery rules.
- **MOD-005-D03 — 2026-11-17.** Prepare character-specific mod state before notifying mods of readiness. Restore required mod payloads before restored-session readiness. Distinguish the existing new-session and restored-session milestones so mods can bind effects to the appropriate operation.
- **MOD-005-D04 — 2026-11-17.** Offer explicit continuation with a failed optional capability disabled when its author declares a fallback, cleanup is verified and dependency and save checks still pass. Required failures retain blocking recovery.

## MOD-004 interview decisions

- **MOD-004-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [MOD-004 specification](systems/MOD/MOD-004.md) is finalized as v1, including restricted source scripts, opt-in trusted code with deep gameplay access, renewed approval for executable changes and explicit selection of competing replacement providers.
- **MOD-004-D01 — 2026-11-17.** Target both documented, replaceable gameplay systems and explicitly opt-in trusted code for the initial release. Plan the replacement interfaces and trust boundary from the start so authors can build substantial gameplay changes without relying on individual new hooks for every change. Script language, plugin format and trust workflow remain open.
- **MOD-004-D02 — 2026-11-17.** Support readable, multi-file source scripts in ZIP and unpacked packages for the initial restricted scripting path. Use representative large scripted mods to measure startup and first-use cost. Revisit precompiled distribution if profiling shows a meaningful benefit. The trusted plugin format is a separate decision.
- **MOD-004-D03 — 2026-11-17.** Renew player approval whenever a trusted package's executable content changes, including changes without a new ID or version. Changes confined to non-executable content preserve approval when the executable content is identical.
- **MOD-004-D04 — 2026-11-17.** Require deep gameplay access for the initial trusted path. Leave native-library support open as a delivery format. Evaluate trusted scripting in an exported build with a substantial gameplay overhaul. Consider native libraries if a concrete SDK or measured performance need warrants them.
- **MOD-004-D05 — 2026-11-17.** Declining trusted code leaves the package installed and inactive for the run. Show affected dependents. Offer a data-only mode only when the author declares one, and validate that mode before activation.
- **MOD-004-D06 — 2026-11-17.** Surface competing gameplay system replacements before main-menu entry and have the player explicitly choose the provider. Keep both packages active only if the resulting configuration validates. The user's “Yes” was interpreted as agreement with the recommended explicit choice.

## MOD-003 interview decisions

- **MOD-003-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [MOD-003 specification](systems/MOD/MOD-003.md) is finalized as v1, including required and optional dependency handling, explicit auto-sort preview and application, cycle recovery and version bounds.
- **MOD-003-D01 — 2026-11-17.** Block Continue when an enabled mod's required provider is missing, disabled or incompatible. Show the requesting mod, provider and reason. Let the player resolve the prerequisite or disable the dependent. Offer explicit enablement when a required provider is installed, compatible and disabled.
- **MOD-003-D02 — 2026-11-17.** Preview auto-sort and require explicit application. Place ordered prerequisites before dependents while preserving the player's relative order wherever possible. Interpret the user's “Yes” as agreement with the recommended preview.
- **MOD-003-D03 — 2026-11-17.** A missing or disabled optional provider permits Continue. An enabled incompatible optional provider produces a warning and leaves that integration inactive while both mods may run. An enabled compatible optional provider participates in any declared ordering requirement.
- **MOD-003-D04 — 2026-11-17.** Default active dependencies to provider-first order. Allow authors to explicitly declare presence-only dependencies, which still check provider availability and compatibility but impose no load-order requirement.
- **MOD-003-D05 — 2026-11-17.** Block Continue on circular ordering and show the full loop. Offer explicit run-only suppression of a participating optional integration and revalidate the result.
- **MOD-003-D06 — 2026-11-17.** Support a minimum inclusive provider version and an optional exclusive upper bound for dependency compatibility.

## MOD-002 interview decisions

- **MOD-002-A01 — 2026-11-17.** The user approved Draft v2 with “I approve”. The [MOD-002 specification](systems/MOD/MOD-002.md) is finalized as v2, including named profiles, disabled-by-default discovery, missing-mod recovery and the choice to save edits or use them for one run.
- **MOD-002-D01 — 2026-11-17.** Use named profiles within each storage root, with a ready-to-use Default profile. Profiles store mod enablement and load order over the shared installed library. Choose the profile before main-menu entry and validate it before locking the run's active configuration.
- **MOD-002-D02 — 2026-11-17.** Newly discovered package IDs start disabled until the player explicitly enables them. Launch discovery and Rescan Mods show newly available packages without automatically enabling them.
- **MOD-002-D03 — 2026-11-17.** Preserve an enabled but unavailable package's identity and position in its profile. Show it as missing and let the player explicitly skip it for the run if the remaining selection validates, or remove it from the profile permanently. Restore the saved intent when the same ID returns.
- **MOD-002-D04 — 2026-11-17.** Provide explicit Save Profile for unfinished configurations, including those with unresolved dependencies. Continue still validates the selected setup before main-menu entry.
- **MOD-002-D05 — 2026-11-17.** Provide Create, Rename, Duplicate and Delete, with confirmation before deletion. Preselect the last successfully used profile within the current root, falling back to Default when unavailable.
- **MOD-002-D06 — 2026-11-17.** When Continue has unsaved edits, offer Save and Continue or Continue for This Run. Both require validation. The run-only choice leaves the saved profile intact.

## MOD-001 interview decisions

- **MOD-001-A01 — 2026-11-17.** The user approved Draft v3 with “I approve”. The [MOD-001 specification](systems/MOD/MOD-001.md) is finalized as v3, including ZIP and folder discovery, pre-menu recovery and rescans, and asset sharing through declared dependencies and explicit exports.
- **MOD-001-D01 — 2026-11-17.** Discover both packaged archives and unpacked mod folders in normal play. The user chose “Both formats in normal play.” Exact archive encoding and manifest schema remain open.
- **MOD-001-D02 — 2026-11-17.** Discover installed mods from one `Mods` folder under the storage root selected for the run. Standard and portable modes each expose their own mod library. The user answered “Yes” to the proposed layout.
- **MOD-001-D03 — 2026-11-17.** When multiple discovered copies claim one stable package ID, show their paths and require an explicit choice of one eligible copy or skipping the mod.
- **MOD-001-D04 — 2026-11-17.** Show unreadable packages and invalid manifests with their paths and reasons. Allow the player to continue with the remaining selection when it passes dependency validation. Save compatibility checks still apply.
- **MOD-001-D05 — 2026-11-17.** Support ZIP as the initial archive format. The user said “.zip is good enough to support for now.” Unpacked folders remain an approved package form under D01.
- **MOD-001-D06 — 2026-11-17.** Recursively discover packages through author and category folders under `Mods`. Stop at unpacked package boundaries, including folders with invalid manifests, and skip directory links during discovery. Folder grouping is organizational and carries no load priority.
- **MOD-001-D07 — 2026-11-17.** Require a root-level `mod.json` for both ZIP and unpacked packages, with stable package ID, display name and version. Explain the required location when a ZIP places the manifest under a wrapper folder.
- **MOD-001-D08 — 2026-11-17.** Provide a manual Rescan Mods action before main-menu entry. Refresh the discovered list after installs, repairs and removals without restarting. DATA-003's main-menu lock still applies.
- **MOD-001-D09 — 2026-11-17.** Remember explicit duplicate choices across launches while the eligible copies for that ID retain the same paths, IDs and versions. Require a fresh choice if the eligible copies change and a duplicate remains.
- **MOD-001-D10 — 2026-11-17.** Treat a missing `Mods` directory as an empty library. For an existing unreadable root, identify the path and offer Retry, Continue without mods for this run, or Quit. Approved save compatibility rules still apply.
- **MOD-001-D11 — 2026-11-17.** Require `manifest_version`, `id`, `name` and `version` in `mod.json`. The manifest format version and the mod release version are separate fields.
- **MOD-001-D12 — 2026-11-17.** Share one installed copy of assets through declared package dependencies and explicit exports from a dedicated asset pack or an existing mod. References use provider package ID and exported asset key. Keep installed package files within their package boundary. Defer local author-workspace links to the authoring workflow.

## SAVE-017 interview decisions

- **SAVE-017-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-017 specification](systems/SAVE/SAVE-017.md) is finalized as v1, including disclosed omission of eligible unavailable mod data on successful resave and declared initialization for newly added mods.
- **SAVE-017-D01 — 2026-11-17.** Omit eligible unavailable mod data on the next successful save made after loading without that mod. Loading itself preserves the source save.
- **SAVE-017-D02 — 2026-11-17.** Allow newly added mods to initialize when no prior payload exists and the mod declares support for joining an existing game.

## SAVE-016 review decision

- **SAVE-016-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-016 specification](systems/SAVE/SAVE-016.md) is finalized as v1, including owner reconciliation before completion, exactly one Session Restored notification on success, and operation cleanup that preserves independent readiness and recovery gates.

## SAVE-015 review decision

- **SAVE-015-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-015 specification](systems/SAVE/SAVE-015.md) is finalized as v1, including validation of required subsystem state, rebuilding disposable map data, and disclosed recovery for eligible inactive map records.

## SAVE-014 review decision

- **SAVE-014-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-014 specification](systems/SAVE/SAVE-014.md) is finalized as v1, including stable authored bindings, authorized reconstruction of runtime instances, and preservation of defeat, quest claims, and item custody.

## SAVE-013 review decision

- **SAVE-013-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-013 specification](systems/SAVE/SAVE-013.md) is finalized as v1, including restoration of supported door and mechanism progress, supporting state before dependent placement, and preservation of committed effects.

## SAVE-012 review decision

- **SAVE-012-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-012 specification](systems/SAVE/SAVE-012.md) is finalized as v1, including explicit destination readiness, required object registration and supporting state before contextual placement, and gameplay suspension through full restoration.

## SAVE-011 review decision

- **SAVE-011-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-011 specification](systems/SAVE/SAVE-011.md) is finalized as v1, including preserving the current session through preflight and establishing saved clock, weather, location, and applicable access context before dependent reconstruction.

## SAVE-010 review decision

- **SAVE-010-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-010 specification](systems/SAVE/SAVE-010.md) is finalized as v1, including custody-first restoration, exact equipment and effect-source links, and rebuilding derived contributions before reconciling current vitals.

## SAVE-009 interview decisions

- **SAVE-009-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-009 specification](systems/SAVE/SAVE-009.md) is finalized as v1, including same-map-pixel door retention and moddable reset rules by context and state kind.
- **SAVE-009-D01 — 2026-11-17.** Preserve ordinary interior door position and lock state across revisits within the same map pixel. Expire eligible ordinary door state on a committed crossing to a different pixel, subject to approved owner rules.
- **SAVE-009-D02 — 2026-11-17.** Support validated mod retention and reset policies by location context and kind of state, subject to approved custody and quest protections.

## SAVE-008 interview decisions

- **SAVE-008-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-008 specification](systems/SAVE/SAVE-008.md) is finalized as v1, including durable identities, explicit migration, and required identity validation.
- **SAVE-008-D01 — 2026-11-17.** Use stable scoped placement IDs and durable instance IDs for persistent objects created during play. Carry saved state forward through a matching identity or an explicit migration.
- **SAVE-008-D02 — 2026-11-17.** Block save or load for ambiguous or unresolved required identity. Allow optional omission only under approved owner recovery, with disclosure of player-visible consequences.

## SAVE-007 interview decisions

- **SAVE-007-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-007 specification](systems/SAVE/SAVE-007.md) is finalized as v1, including native save compatibility from stable release 1.0 onward, preflight migrations that preserve the source save, and independently versioned mod payloads.
- **SAVE-007-D01 — 2026-11-17.** Support valid native saves from all stable public releases starting with 1.0. Support pre-release saves when compatibility is explicitly announced.
- **SAVE-007-D02 — 2026-11-17.** Use one top-level base-game save-format version, with owners responsible for their migrations. Version mod payloads independently.

## SAVE-006 interview decisions

- **SAVE-006-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-006 specification](systems/SAVE/SAVE-006.md) is finalized as v1, including coherent snapshot publication, background quicksave writes after capture, and removal of the prior generation after a successful replacement.
- **SAVE-006-D01 — 2026-11-17.** Preserve the previous committed generation if an overwrite fails. Discard it once the replacement commits.
- **SAVE-006-D02 — 2026-11-17.** Resume gameplay after quicksave capture while the captured snapshot writes in the background. Keep manual-save progress responsive and report success after commitment.

## SAVE-005 interview decisions

- **SAVE-005-A01 — 2026-11-17.** The user approved Draft v2 with “I approve”. The [SAVE-005 specification](systems/SAVE/SAVE-005.md) is finalized, and CORE-007, CORE-013, and CORE-018 were amended to reflect its native-load confirmation policy.
- **SAVE-005-D01 — 2026-11-17.** Run mandatory preflight before discard confirmation. Support independent mod control of the discard prompt for manual loads and quickloads while retaining validation.
- **SAVE-005-D02 — 2026-11-17.** Disclosure is sufficient for owner-approved recovery. Routine disposable-cache rebuilding requires no prompt.

## SAVE-004 interview decisions

- **SAVE-004-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-004 specification](systems/SAVE/SAVE-004.md) is finalized as v1, including shared save eligibility, safe replacement of the designated quicksave, and a mod policy that retains numbered quicksave slots.
- **SAVE-004-D01 — 2026-11-17.** Apply the same save eligibility to manual save and quicksave at settled boundaries. Permit combat, hostile proximity, airborne movement and swimming where restorable. Reject loading, death return, transitions and unsupported unfinished activities.
- **SAVE-004-D02 — 2026-11-17.** Default to one visible quicksave per character with safe replacement. Support a mod policy that appends a permanent, incrementally numbered slot on each successful quicksave.

## SAVE-003 interview decisions

- **SAVE-003-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-003 specification](systems/SAVE/SAVE-003.md) is finalized as v1, including reporting and retrying post-commit cleanup failures while keeping the deleted slot out of the picker.
- **SAVE-003-D01 — 2026-11-17.** Allow duplicate slot names within a character and reject blank names. Rename changes the display label while preserving slot identity, saved timestamp, thumbnail, and designated quicksave role.
- **SAVE-003-D02 — 2026-11-17.** Permanently delete a selected slot following explicit confirmation. The user chose permanent deletion instead of an in-game Recently Deleted feature.

## SAVE-002 interview decisions

- **SAVE-002-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-002 specification](systems/SAVE/SAVE-002.md) is finalized as v1.
- **SAVE-002-D01 — 2026-11-17.** Use a world-only thumbnail from the accepted save state, excluding menus, HUD, and transient overlays. Use the placeholder if matching capture is unavailable and allow the save to succeed.
- **SAVE-002-D02 — 2026-11-17.** Show the slot and character names, local real-world save date and time, saved in-game date and time, and the contextual location known to the player when available. Provide technical version details for diagnostics and compatibility messages.

## SAVE-001 interview decisions

- **SAVE-001-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [SAVE-001 specification](systems/SAVE/SAVE-001.md) is finalized as v1.
- **SAVE-001-D01 — 2026-11-17.** Refresh the native catalog on picker open, explicit refresh, and successful in-game save, rename, or delete. Revalidate actionable targets and require reselection when a selected generation changed or disappeared.
- **SAVE-001-D02 — 2026-11-17.** Keep recognized unavailable native slots with recoverable identity visible, with reasons when known. Route unidentified native-save candidates to storage diagnostics.

## AV-013 interview decisions

- **AV-013-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [AV-013 specification](systems/AV/AV-013.md) is finalized as v1, including configurable any-button skip, once-only classified outcomes after cleanup, classic VID support, WebM and MP4 format targets pending verification, and validated mod playback policies.
- **AV-013-D01 — 2026-11-17.** Default eligible cinematics to deliberate any-button skip. Make skip behavior configurable and moddable within requesting-owner rules. Report Finished, Skipped, Failed or Cancelled once per attempt and let the requester decide continuation.
- **AV-013-D02 — 2026-11-17.** Support original VID playback and multiple validated modern replacement formats. Fit video without cropping and honor its authored display aspect. Allow validated mod skip and ambience profiles within the requesting owner's rules.

## AV-012 interview decisions

- **AV-012-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [AV-012 specification](systems/AV/AV-012.md) is finalized as v1, including stock MIDI synthesis, independent recorded playback, selectable SF2 banks applied at the next MIDI request, crossfades and explicit recovery.
- **AV-012-D01 — 2026-11-17.** Use runtime MIDI synthesis with a validated default SoundFont for the stock soundtrack. Support validated mod MIDI, SF2 SoundFonts, and recorded WAV and Ogg Vorbis subject to platform verification. Recorded playback is independent of MIDI initialization. Both paths expose track endings and support AV-011 crossfades.
- **AV-012-D02 — 2026-11-17.** Let players select a validated mod SoundFont. Report an unavailable optional saved bank and use the validated default. Apply explicit content recovery to invalid selected banks or song replacements and AV-011 recovery to playback failure.

## AV-011 interview decisions

- **AV-011-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [AV-011 specification](systems/AV/AV-011.md) is finalized as v1, including classic context playlists and track selection, moddable transitions, deferred outdoor switches, optional music recovery and reselection from restored context on load.
- **AV-011-D01 — 2026-11-17.** Use classic context playlists. Crossfade promptly on entry to a distinct musical setting. Defer ordinary outdoor weather and day/night playlist changes until the current track ends, then use the latest eligible context. Location changes within the same effective playlist and midnight preserve current playback. Make switch policies and fades moddable.
- **AV-011-D02 — 2026-11-17.** Use DFU's stock track-selection behavior when selecting from a playlist, including daily tavern rotation, dungeon-derived selection, Mages Guild random selection and day-seeded selection elsewhere. Make track pools and selection policies moddable.

## AV-010 interview decisions

- **AV-010-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [AV-010 specification](systems/AV/AV-010.md) is finalized as v1, including moddable ambient layers and spot cues, continuity for unchanged loops, lightning accessibility, and scoped cinematic requests that use the lowest active gain and restore ambience from current context.
- **AV-010-D01 — 2026-11-17.** Use classic clips and recognizable context defaults. Support moddable location, weather, time and authored-area layers with configurable fades, priorities and coexistence. Crossfade changed layers and continue unchanged layers.
- **AV-010-D02 — 2026-11-17.** Use moddable timing and placement for spot effects with presentation-only randomness and no missed-cue backlog. Cinematics suppress world ambience by default, with authored keep or duck options, and resume from current context. Weather lightning respects Flashing Effects while thunder remains independently audible.

## AV-009 interview decisions

- **AV-009-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [AV-009 specification](systems/AV/AV-009.md) is finalized as v1, including stock cue routing, distance-only falloff by default, opt-in moddable muffling, distance-only recovery for unavailable optional obstruction data and independent gameplay hearing.
- **AV-009-D01 — 2026-11-17.** Route world cues and impacts to their source or contact positions, menu and explicit interface alerts to non-spatial playback, and the player's own footsteps, swings and casts to listener-relative playback by default. Allow validated mod routing and falloff overrides.
- **AV-009-D02 — 2026-11-17.** Default world playback to distance falloff alone. Provide opt-in wall and closed-door muffling with smooth transitions. Mods can tune or disable muffling per cue. Audible presentation remains independent of authoritative gameplay hearing.

## AV-008 interview decisions

- **AV-008-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [AV-008 specification](systems/AV/AV-008.md) is finalized as v1, including classic defaults, independently adjustable blood and flashing effects, validated mod cues, authoritative outcome binding and playback priorities.
- **AV-008-D01 — 2026-11-17.** Provide a Blood Effects toggle and Flashing Effects settings that reduce or disable rapid flashes. Default to normal blood and flashing effects. Reduced modes retain a steady cue where provided. Sound remains separately adjustable. Make blood, impact, footsteps and related cues moddable.
- **AV-008-D02 — 2026-11-17.** Default to classic sprites and sounds. Accept validated mod sprites, 3D meshes, particles, lights and clips at authoritative flight, contact or movement outcomes. Under playback contention prioritize distinct impacts, hard landings and water entry over repeated footsteps and decorative particles.

## AV-007 interview decisions

- **AV-007-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [AV-007 specification](systems/AV/AV-007.md) is finalized as v1, including classic sprite defaults, validated sprite and animated 3D replacements, configurable sway, authoritative action timing, world-facing composition and optional-art recovery.
- **AV-007-D01 — 2026-11-17.** Use classic first-person sprites by default, matched to hand, weapon, material, direction and applicable form. Support compatible mod sprite sequences, authored hand placements and dedicated hand art. Align visible strike and release with authoritative gameplay phases.
- **AV-007-D02 — 2026-11-17.** For unavailable optional art, use a declared compatible fallback or omit the affected visual and log the failure. The action retains approved timing and validation. Invalid selected replacements and missing required assets follow approved content recovery.
- **AV-007-D03 — 2026-11-17.** Support mod-authored 3D replacements for first-person sprites, with smoothly sampled animation and configurable movement sway. These presentation options retain gameplay timing and action ownership.

## AV-006 interview decisions

- **AV-006-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [AV-006 specification](systems/AV/AV-006.md) is finalized as v1, including classic source palettes, optional world color effects with default sky inclusion when active, opt-in post-processing, validated mod extensions and optional effect recovery.
- **AV-006-D01 — 2026-11-17.** Preserve classic artwork source palettes. Offer Off, Posterization and Palette Mapping for the rendered world at both display and retro resolutions, defaulting to Off. Apply the selected color effect before HUD composition and allow independent sky inclusion. Make the effect and palette moddable.
- **AV-006-D02 — 2026-11-17.** Offer independently configurable, opt-in dithering, bloom, vignette, depth of field and motion blur. Support validated mod palettes, presets and effects with declared inputs and ordering. Bypass failed optional effects with diagnostics while keeping the display usable.

## AV-005 interview decisions

- **AV-005-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [AV-005 specification](systems/AV/AV-005.md) is finalized as v1, including selectable retro resolutions, independent HUD pixelation and UI sizing, 4:3 and 16:10 framing, integer scaling with nearest-neighbor fit recovery, and validated mod presets.
- **AV-005-D01 — 2026-11-17.** Default retro rendering to Off. Offer 320×200 and 640×400 world rendering with separate optional gameplay HUD pixelation. Keep menus at display resolution and preserve independent UI sizing.
- **AV-005-D02 — 2026-11-17.** Default retro framing to 4:3 and offer 16:10 square-pixel framing. Fit the selected frame without cropping and use nearest-neighbor scaling. Offer integer scaling and accept validated mod resolution and framing presets.

## AV-004 interview decisions

- **AV-004-A01 — 2026-11-17.** The user approved Draft v1 with “I approve”. The [AV-004 specification](systems/AV/AV-004.md) is finalized as v1, including moddable atmosphere precedence, stable view immersion, blending back to current conditions on surfacing, and gameplay visibility owned by the relevant systems.
- **AV-004-D01 — 2026-11-16.** Use exterior weather fog outdoors, local fog in enclosed areas and an underwater profile over the applicable local atmosphere when the view is immersed in depth-enabled water. Blend toward the current atmosphere on surfacing. Use committed water context to avoid false or repeated transitions from cosmetic camera bob and continuous pool seams. Make atmosphere colors, densities, light attenuation and blend settings moddable.
- **AV-004-D02 — 2026-11-16.** Rendered fog, darkness and underwater tint are presentation values. Gameplay rules for detection or targeting use explicit inputs from the responsible gameplay owners.

## AV-003 interview decisions

- **AV-003-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [AV-003 specification](systems/AV/AV-003.md) is finalized as v1, including classic sky imagery and schedule-relative progression, stock frame-zero weather skies at night, validated mod overrides and providers, and stable generated star patterns.
- **AV-003-D01 — 2026-11-16.** Default to classic imagery and faster sky progression near dawn and dusk, mapped to the active daylight schedule. Mods can replace imagery, tune progression and supply a compatible custom sky provider.
- **AV-003-D02 — 2026-11-16.** Preserve DFU's stock weather-sky frame-zero behavior at night for supported inclement weather, with the clear-night sky and stars suppressed there. Allow validated mods to override night weather behavior and associated sky settings.

## AV-002 interview decisions

- **AV-002-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [AV-002 specification](systems/AV/AV-002.md) is finalized as v1, including stock cadence, stable decorative phases, moddable profiles, batched and independent rendering, and permission to start a new decorative clock epoch on native load.
- **AV-002-D01 — 2026-11-16.** Use the verified stock batch rates of 5 fps for animal scenery and 12 fps for light scenery. Derive independent decorative phases from stable placement offsets and a shared presentation clock. Allow skipped offscreen updates and evaluation at the current phase on return. Validated mods can declare timing, synchronized groups and intentional static replacements.
- **AV-002-D02 — 2026-11-16.** Batch compatible scenery where practical and support independent rendering for special sorting, custom materials and individual visual control. Gameplay interactions and timing stay with their owners.

## AV-001 interview decisions

- **AV-001-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [AV-001 specification](systems/AV/AV-001.md) is finalized as v1, including the Classic default, moddable Enhanced and additional presets, live context updates, optional decoration recovery and Classic fallback for unavailable saved presets.
- **AV-001-D01 — 2026-11-16.** Stock world models default to crisp classic textures with nearest-neighbor filtering and authored emission where applicable.
- **AV-001-D02 — 2026-11-16.** Visible surfaces update when the context for a supported variant changes, including day/night and fog window styles and seasonal surfaces. The user answered “Yes” to the second interview question.
- **AV-001-D03 — 2026-11-16.** Offer a player-selectable Enhanced preset with smoother filtering and compatible authored normal maps where available. Make presets and model/material presentation moddable through validated definitions. The user confirmed Enhanced and explicitly requested moddability.
- **AV-001-D04 — 2026-11-16.** An explicitly optional decoration with unavailable geometry or material and no authored fallback may be omitted with a diagnostic. Required resources and invalid selected replacements follow approved recovery rules. The user confirmed the optional omission proposal.

## TIME-018 interview decisions

- **TIME-018-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [TIME-018 specification](systems/TIME/TIME-018.md) is finalized as v1, including applying compatible weather changes at the next unresolved selection and announcing readiness through the restore outcome.
- **TIME-018-D01 — 2026-11-16.** Restore exact clock and retained weather before deriving local presentation and gameplay exposure. Reveal the fully restored environment. Rebuilding it emits no simulated dawn, weather change or hazard tick.
- **TIME-018-D02 — 2026-11-16.** Preserve compatible active weather and its end time through definition changes. Allow explicit migration and declared optional visual fallback. Unsupported required weather data fails preflight where detectable and preserves the current session.
- **TIME-018-D03 — 2026-11-16.** Use settled save boundaries by default. For explicitly supported active saves, restore committed time, weather and work position and reconcile required unfinished work before control. Load contributes zero elapsed time and does not replay settled consequences.

## TIME-017 interview decisions

- **TIME-017-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [TIME-017 specification](systems/TIME/TIME-017.md) is finalized as v1, including exact ship and visit identity, safe correction at the original return pose, and explicit recovery when ordinary return is unavailable.
- **TIME-017-D01 — 2026-11-16.** Try the recorded return position first, then an explicitly authorized safe fallback in the same departure location. If neither succeeds, retain the aboard visit and explain recovery. Mods may provide alternate checked return points.
- **TIME-017-D02 — 2026-11-16.** Fast travel from aboard uses the validated boarding location as route origin. Keep the visit and return record until authorized ashore placement commits. Preserve them if the player remains aboard after failure. Apply origin access checks.
- **TIME-017-D03 — 2026-11-16.** Preserve exact ship interior and exterior state and possessions independently of the visit. Native saves aboard retain the active visit and return anchor. Support modded ship profiles and safe recovery that preserves belongings if entitlement or content becomes invalid.

## TIME-016 interview decisions

- **TIME-016-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [TIME-016 specification](systems/TIME/TIME-016.md) is finalized as v1, including one base land mode per trip, renewed confirmation for mode changes and checked modded mounted arrival.
- **TIME-016-D01 — 2026-11-16.** An owned horse or cart can benefit fast travel when reachable departure and land-route context permit its use, even if immediate local mounting is unavailable. Support validated mod access and route requirements.
- **TIME-016-D02 — 2026-11-16.** Base fast travel selects horse, then cart, then foot among eligible options. Disclose the selection and requote material changes before departure. Local riding preference remains independent. Mods can change selection or offer explicit choices.
- **TIME-016-D03 — 2026-11-16.** Base fast travel arrives on foot and preserves remembered local selection. Mods can allow mounted arrival through validated placement.

## TIME-015 interview decisions

- **TIME-015-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [TIME-015 specification](systems/TIME/TIME-015.md) is finalized as v1, including staged destination preparation, cautious refill only on successful living arrival, and settled save boundaries by default.
- **TIME-015-D01 — 2026-11-16.** Base cautious travel refills health, fatigue and eligible magicka once after a successful living arrival. Mods can change or disable recovery. Use the quoted route endpoint by default. Optional arrival waits must be quoted and have valid elapsed-time and exposure context.
- **TIME-015-D02 — 2026-11-16.** Preserve committed fare, time and effects on gameplay interruption, with no automatic refund. Use an authorized interruption placement or the applicable death or transformation flow. Technical placement failure retains progress for checked retry, fallback or explicit recovery without repeating payment or time.
- **TIME-015-D03 — 2026-11-16.** Announce arrival once after route settlement, valid placement and destination readiness, and eligible completion effects. Route successful travel through CHAR-013. Skip ordinary ambient encounter catch-up in stock simulated travel and support authored events and moddable travel policies.

## TIME-014 interview decisions

- **TIME-014-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [TIME-014 specification](systems/TIME/TIME-014.md) is finalized as v1, including ceiling-based 24-hour fare units, virtual lodging slots with per-region waivers, and renewed confirmation when material terms change.
- **TIME-014-D01 — 2026-11-16.** Keep moddable 5-gold inn and 25-gold ship fare increments. Use timed route land and sea durations and the lodging regions for charges and applicable waivers. Inn fees require carried coin. Ship fare accepts eligible carried coin or credit.
- **TIME-014-D02 — 2026-11-16.** Block invalid routes or destinations, insufficient eligible funds and applicable restrictions. Confirm player-known disease or poison, disclose foreseeable sunlight exposure where established, and keep hidden conditions undisclosed. Departure policies are moddable, including an approved protective equipment exception for daylight travel.
- **TIME-014-D03 — 2026-11-16.** Disclose duration, charges, waivers and eligible tender. Revalidate material quote terms, warnings, authorization and payment at commitment. Require fresh confirmation for material changes. Failed payment leaves funds and travel state intact.

## TIME-013 interview decisions

- **TIME-013-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [TIME-013 specification](systems/TIME/TIME-013.md) is finalized as v1, including direct traversal when valid, least-estimated-time fallback, zero intercell time for same-cell estimates, and cumulative reckless rounding.
- **TIME-013-D01 — 2026-11-16.** Keep DFU terrain, horse/cart, camping and cautious/reckless modifiers as moddable baseline data. Use an endpoint-correct grid route. Support modded timing and route policies and let quest scripts choose authored estimation assumptions for travel-derived deadlines.
- **TIME-013-D02 — 2026-11-16.** With ship travel disabled, use a valid land detour when one exists and return unavailable otherwise.
- **TIME-013-D03 — 2026-11-16.** Return an ordered timed route with terrain, travel mode and authoritative exposure context where required. Derive total duration and ocean extent from the same route and allow quest timers to consume the total.

## TIME-012 interview decisions

- **TIME-012-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [TIME-012 specification](systems/TIME/TIME-012.md) is finalized as v1, including prefix and near-match fallback, authorized journal selection through manual filters, and transient unconfirmed previews by default.
- **TIME-012-D01 — 2026-11-16.** Require an active exact-location grant for destination selection. Partial clues show only authorized precision. Keep hidden sites out of search and map pins. Use approved moddable WORLD-014 discovery rules.
- **TIME-012-D02 — 2026-11-16.** Keep base name search scoped to the open region. Match localized names and supported aliases, prioritize exact matches, retain distinct same-name sites and use visible filters consistently. Support modded search behavior, scope and travel UI.
- **TIME-012-D03 — 2026-11-16.** Map, search and authorized journal shortcuts select the same stable site identity and open a preview. Travel requires separate confirmation and revalidation of the active exact grant.

## TIME-011 interview decisions

- **TIME-011-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [TIME-011 specification](systems/TIME/TIME-011.md) is finalized as v1, including one eligible item-effect reroll after seven completed elapsed hours in a single qualifying sleep and settlement of an already committed eligible hour on a concurrent Stop.
- **TIME-011-D01 — 2026-11-16.** Settle due gameplay events and recheck eligibility before a coincident sleep recovery tick. Preserve committed elapsed time and earlier recovery. If sleep is ineligible at the boundary, do not award the tick.
- **TIME-011-D02 — 2026-11-16.** Request one CHAR-013 checkpoint at settlement of positive-elapsed living-character sleep, including voluntary stops and interruptions. Preserve the strict default interval. Exclude loiter, zero-time attempts and death by default. Support validated mod routing consistent with CHAR-013.
- **TIME-011-D03 — 2026-11-16.** Publish one settled outcome and show one primary player-facing reason with urgent consequences taking priority. Retain the base long-sleep item-effect reroll. Support modded rest-end behavior, interruption reasons and localized messages.

## TIME-010 interview decisions

- **TIME-010-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [TIME-010 specification](systems/TIME/TIME-010.md) is finalized as v1, including zero-time heal-until completion before bed placement, recovery-hour accounting across splits within the same sleep request, and settled save boundaries unless active saves are supported.
- **TIME-010-D01 — 2026-11-16.** Use whole-hour input and moddable base limits of 1–99 hours for timed sleep and 1–3 for loiter. Zero spends no time and causes no bed movement. Timed sleep can continue at full vitals. Heal-until finishes immediately if its goal is already met.
- **TIME-010-D02 — 2026-11-16.** Allow loiter where otherwise eligible even if sleep is forbidden. Advance applicable timed gameplay without bed placement, sleep recovery or Medical practice. Apply separate threat and activity restrictions, including active combat and pursuit.
- **TIME-010-D03 — 2026-11-16.** Use short moddable pacing with loiter slower than sleep by default and a stop control in every mode. Use a maximum default advance segment of ten game minutes, split earlier at relevant exact gameplay boundaries.

## TIME-009 interview decisions

- **TIME-009-A01 — 2026-11-16.** The user approved Draft v1 with “I approve”. The [TIME-009 specification](systems/TIME/TIME-009.md) is finalized as v1, including stopping rental sleep at exact expiry and requiring a fresh request to use another permission.
- **TIME-009-D01 — 2026-11-16.** Allow sleep at suitable wilderness and dungeon sites when safety checks pass. Town buildings require ownership, active rental or explicit guild or guest privilege. Restricted outdoor town camping follows LAW-006. Support moddable sites, exceptions and restrictions.
- **TIME-009-D02 — 2026-11-16.** Move the player to the assigned rental bed when sleep starts if placement is safe and access is authorized. Use only an explicitly authorized fallback in the same lodging. Permit sleep in place where ownership or guild privileges and site rules allow it.
- **TIME-009-D03 — 2026-11-16.** An eligible but untriggered spawner does not block sleep solely by proximity. Process relevant encounters at their applicable boundary and stop before another segment when the encounter makes rest ineligible.

## TIME-008 interview decisions

- **TIME-008-A01 — 2026-11-15.** The user approved Draft v1 with “I approve”. The [TIME-008 specification](systems/TIME/TIME-008.md) is finalized as v1, including serial notices for overlaps, per-character/holiday/date suppression across native saves and recovery of unseen eligibility after load.
- **TIME-008-D01 — 2026-11-15.** Check holiday notices at eligible settlement arrival, including ready fast-travel destinations, and when the game day changes while the player is already in an eligible location. A holiday skipped entirely by a time jump gets no notice. Triggers, eligible locations and holiday notice eligibility are moddable.
- **TIME-008-D02 — 2026-11-15.** Use a one-time classic-style initial notice for each applicable holiday in the base game. Expose holiday data and notice hooks for mods, including mods that add a nonblocking HUD notice.
- **TIME-008-D03 — 2026-11-15.** Keep the initial notice as the base game's holiday presentation. Mods may add other displays such as a holiday list in the date display or journal.

## TIME-007 interview decisions

- **TIME-007-A01 — 2026-11-15.** The user approved Draft v1 with “I approve”. The [TIME-007 specification](systems/TIME/TIME-007.md) is finalized as v1, including schedule override precedence and custody exposure based on authoritative shelter context.
- **TIME-007-D01 — 2026-11-15.** Base daytime is 06:00 inclusive to 18:00 exclusive. Base city lights are on from 17:00 inclusive to 08:00 exclusive across midnight. Mods may define regional and seasonal schedules.
- **TIME-007-D02 — 2026-11-15.** Exposed outdoor areas count as gameplay sunlight during daytime regardless of ordinary rendered shade or weather. Enclosed interiors and explicitly authored shelter block exposure. An exterior view or lighting effect alone does not expose an actor.
- **TIME-007-D03 — 2026-11-15.** Smooth ordinary visual lighting while resolving gameplay exposure and city-light schedule changes at exact boundaries. Establish destination lighting before reveal after travel, covered transitions and load. Local artificial light does not confer daylight.

## TIME-006 interview decisions

- **TIME-006-A01 — 2026-11-15.** The user approved Draft v1 with “I approve”. The [TIME-006 specification](systems/TIME/TIME-006.md) is finalized as v1, including opt-in exterior cues indoors, fallback for unavailable optional views, and rebuilding transient presentation on native load.
- **TIME-006-D01 — 2026-11-15.** Enclosed interiors use local fog and lighting and suppress outdoor precipitation by default. Apply current outdoor weather on exit. Support practical mod opt-ins for exterior weather cues such as rain on a roof, distant thunder, or views outside, with localized exposure in authored open spaces.
- **TIME-006-D02 — 2026-11-15.** Use short moddable blends for live outdoor changes and seamless crossings. Apply destination weather before reveal for covered transitions, fast travel and native load. Retarget overlapping blends from the state currently presented.
- **TIME-006-D03 — 2026-11-15.** Publish committed weather and location context before notifying consumers. Visual and audio blends have independent timing. Gameplay takes effect at the owning system's defined time and is independent of graphics settings.

## TIME-005 interview decisions

- **TIME-005-A01 — 2026-11-15.** The user approved Draft v1 with “I approve”. The [TIME-005 specification](systems/TIME/TIME-005.md) is finalized as v1, including the shared climate-array mapping, variable schedules starting at the new character's committed start time, and uniform sampling within configured duration ranges.
- **TIME-005-D01 — 2026-11-15.** Retain DFU climate mappings and seasonal weather weights as the base data. Support validated mod overrides, mod weather profiles and added weather types. Weights are nonnegative with a positive total, and zero-weight entries cannot be drawn.
- **TIME-005-D02 — 2026-11-15.** Share base weather by climate group. Travel and revisits read the group's retained result rather than drawing again.
- **TIME-005-D03 — 2026-11-15.** In the base game, select one retained result per climate group and calendar day using the active season. Preserve the result across native load and resolve the destination day directly when no approved gameplay rule needs skipped weather. Mods can define more dynamic schedules, including weather lasting a variable number of game hours.
- **TIME-005-D04 — 2026-11-15.** Mod weather types use stable IDs eligible for seasonal tables and can link to presentation profiles. Gameplay effects use approved hooks owned by the affected systems.
- **TIME-005-D05 — 2026-11-15.** Mod schedules can set duration ranges in game hours per weather type. Retain the selected type and end time across travel and native load. Use the season at each transition for the next selection. Optimize intervening changes only when equivalent to processing them.

## TIME-004 interview decisions

- **TIME-004-A01 — 2026-11-15.** The user approved Draft v1 with “I approve”. The [TIME-004 specification](systems/TIME/TIME-004.md) is finalized as v1, including owner-defined ordering for recurrence that can change the advance endpoint and reconciliation of ambiguous mutation outcomes before retry.
- **TIME-004-D01 — 2026-11-15.** TIME coordinates catch-up. Owners declare their timing policies. Process order-sensitive consequences chronologically. Allow equivalent bulk processing and owner-approved coalescing or skipping.
- **TIME-004-D02 — 2026-11-15.** Apply explicit gameplay dependencies at coincident instants and use stable ordering for independent work. Interacting rules require documented owner precedence.
- **TIME-004-D03 — 2026-11-15.** Keep required work gated through bounded processing passes. Stop applicable advances at the actual interrupting instant. Preserve completed consequences and resume unfinished work after recoverable failure without repeating commitments.

## TIME-003 interview decisions

- **TIME-003-A01 — 2026-11-15.** The user approved Draft v1 with “I approve”. The [TIME-003 specification](systems/TIME/TIME-003.md) is finalized as v1, including context-aware named markers, filtered chronological crossing queries and presentation refresh when destination context is ready.
- **TIME-003-D01 — 2026-11-15.** Recognize each boundary in `previous < boundary ≤ current`. Make crossings available as needed without broadcasting every crossing to every consumer.
- **TIME-003-D02 — 2026-11-15.** Group all coincident markers into one timestamped record. Consumers select relevant markers. TIME-004 governs ordering of gameplay consequences at the same instant.
- **TIME-003-D03 — 2026-11-15.** Refresh presentation from destination state after jumps and native loads. Ordinary play may animate visible transitions. Restore produces no advance effects, and gameplay consumers use their approved catch-up rules.

## TIME-002 interview decisions

- **TIME-002-A01 — 2026-11-15.** The user approved Draft v1 with “I approve”. The [TIME-002 specification](systems/TIME/TIME-002.md) is finalized as v1, including whole-millisecond explicit durations, preservation of the ordinary fractional remainder during explicit advances, and exclusive clock ownership for an admitted activity.
- **TIME-002-D01 — 2026-11-15.** Default ordinary calendar advancement to 12 game seconds per eligible simulation second. Apply the multiplier to calendar time and allow validated mod data to override it. Provide no dedicated in-game calendar rate setting.
- **TIME-002-D02 — 2026-11-15.** Route advances through one TIME-owned operation. Explicit advances require an authorized activity, a reason and a duration. An activity can advance under its own suspension but cannot bypass independent suspension. Reject competing activity requests and prevent duplicate commitment on retry. Report the actual elapsed time after interruption.
- **TIME-002-D03 — 2026-11-15.** Carry the remainder below one game millisecond across eligible updates and native save/load. The authoritative timestamp remains in whole game milliseconds. Suspended time adds zero.

## TIME-001 interview decisions

- **TIME-001-A01 — 2026-11-15.** The user approved Draft v1 with “I approve”. The [TIME-001 specification](systems/TIME/TIME-001.md) is finalized as v1, including the year-zero epoch, checked signed 64-bit native timestamp, and anchored continuous weekday override.
- **TIME-001-D01 — 2026-11-15.** Keep the base start at 13:30 on 4 Morning Star, 3E 405 and DFU's month-based season boundaries. Mods may override the opening date and season boundaries.
- **TIME-001-D02 — 2026-11-15.** Keep DFU's monthly weekday reset as the default, with Sundas on the first of each month. Allow mods to change the weekday rule.
- **TIME-001-D03 — 2026-11-15.** Use an authoritative integer timestamp in game milliseconds and preserve that precision across native save and load.
- **TIME-001-D04 — 2026-11-15.** Fix the calendar at 24-hour days and twelve 30-day months. Allow season boundaries to be configured to the day.
- **TIME-001-D05 — 2026-11-15.** Provide checked two-way conversion for classic minute values as reference data and verification. Decode to the start of the minute, discard sub-minute precision on encoding, and explicitly reject out-of-range values. Native saves retain milliseconds. Classic save import remains outside the current scope.

## LOC-020 interview decisions

- **LOC-020-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-020 specification](systems/LOC/LOC-020.md) is finalized as v1.
- **LOC-020-D01 — 2026-11-14.** Save resolved layout and visit identity and durable owner state using stable scoped IDs. Rebuild scene objects and derived views.
- **LOC-020-D02 — 2026-11-14.** Preflight required compatibility where detectable. Use validated migration or explicit recovery. Retain eligible map-only records inactive with disclosure.
- **LOC-020-D03 — 2026-11-14.** Gate play until local state and pose agree. Restore supporting mechanisms and quest claims before dependent placement. Resume supported actions without replay and preserve visit and reset eligibility.

The user answered “Yes” to each recommendation.

## LOC-019 interview decisions

- **LOC-019-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-019 specification](systems/LOC/LOC-019.md) is finalized as v1.
- **LOC-019-D01 — 2026-11-14.** Support notes on discovered dungeon and building-interior geometry. Use stable anchors and preserve text when an incompatible edit hides the pin.
- **LOC-019-D02 — 2026-11-14.** Learn directed links only from successful authored teleport traversal. Show links on demand subject to endpoint disclosure.
- **LOC-019-D03 — 2026-11-14.** Preserve compatible links while the dungeon is remembered. Evict links with discovered geometry and keep notes under LOC-018.

The user answered “Yes” to each recommendation.

## LOC-018 interview decisions

- **LOC-018-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-018 specification](systems/LOC/LOC-018.md) is finalized as v1.
- **LOC-018-D01 — 2026-11-14.** Discover occupied segments and bounded nearby geometry in direct sight during exploration. Respect solid occlusion.
- **LOC-018-D02 — 2026-11-14.** Retain earned discovery and start fresh visit highlights on stock reentry. Restore highlights on native load inside. Support non-color cues and moddable carryover.
- **LOC-018-D03 — 2026-11-14.** Use scoped segment IDs and validated compatibility or mappings. New or unmatched geometry starts hidden.
- **LOC-018-D04 — 2026-11-14.** Default to five remembered dungeon maps with a configurable cap and unlimited option. Evict least recently visited, update on revisit and persist recency order.
- **LOC-018-D05 — 2026-11-14.** Preserve notes through geometry eviction and hide them until their locations are rediscovered. Quest progress and independently authorized marks follow their owners.

## LOC-017 interview decisions

- **LOC-017-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-017 specification](systems/LOC/LOC-017.md) is finalized as v1.
- **LOC-017-D01 — 2026-11-14.** The user reaffirmed MOVE-021's nonblocking ordinary doors during opening and closing. Retain occupancy-safe closed blocking and leave blocked-closure presentation open.
- **LOC-017-D02 — 2026-11-14.** Preserve door state and failed-pick history across save/load within a visit. Restore ordinary authored defaults and clear failed-pick history on stock dungeon reset, subject to quest and mod policies.
- **LOC-017-D03 — 2026-11-14.** Support authored first-use actions that defer opening. Recheck later attempts. Other links use LOC-015 timing and NPC activation cannot consume a player-only prompt.

## LOC-016 interview decisions

- **LOC-016-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-016 specification](systems/LOC/LOC-016.md) is finalized as v1.
- **LOC-016-D01 — 2026-11-14.** Support reusable motion, puzzle, teleport, spell, damage and drain actions with authored targets and conditions and validated site rules.
- **LOC-016-D02 — 2026-11-14.** Ordinary obstructed mechanisms stop and wait under declared policy. MOVE-008 governs carriage, pushing and explicit crush hazards. Endpoint completion requires arrival.
- **LOC-016-D03 — 2026-11-14.** Validate and commit effects through their owners once per occurrence. Author puzzle retries and penalties explicitly. Restore supported progress and reset ordinary mechanisms on successful reentry while preserving quest outcomes.

The user answered “Yes” to each recommendation.

## LOC-015 interview decisions

- **LOC-015-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-015 specification](systems/LOC/LOC-015.md) is finalized as v1.
- **LOC-015-D01 — 2026-11-14.** Validate external trigger types. Allow authorized links to activate enabled downstream actions and propagate activation identity to deduplicate effects.
- **LOC-015-D02 — 2026-11-14.** Declare link timing. Native links default to source success and may explicitly fire at activation or completion. Preserve verified classic timing and conditions.
- **LOC-015-D03 — 2026-11-14.** Reject unsupported busy triggers. Bound authored waits and loops. Fail missing required links during preparation and stop unavailable required paths at runtime without replaying committed effects.

The user answered “Yes” to each recommendation.

## LOC-014 interview decisions

- **LOC-014-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-014 specification](systems/LOC/LOC-014.md) is finalized as v1.
- **LOC-014-D01 — 2026-11-14.** Use block-placement-scoped IDs, verified classic roles and explicit shared roles and capacity.
- **LOC-014-D02 — 2026-11-14.** Refresh generated ordinary treasure and restore fixed ordinary contents on successful reset. Preserve outstanding quest items and custody and retain prior acquisitions.
- **LOC-014-D03 — 2026-11-14.** Use eligible authored alternatives or authorized quest fallback for blocked placements. Retain settled results. Required failure uses owner recovery and optional treasure stays absent.

The user answered “Yes” to each recommendation.

## LOC-013 interview decisions

- **LOC-013-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-013 specification](systems/LOC/LOC-013.md) is finalized as v1.
- **LOC-013-D01 — 2026-11-14.** Preserve fixed authored types and verified classic random selection by default. Support alternate profiles and retain settled assignments across retries and reloads.
- **LOC-013-D02 — 2026-11-14.** Default to a fresh dungeon after committed departure and successful reentry, including departure by teleport. Mod the reset policy. Refresh ordinary enemies, loot and mechanisms and delete ordinary player drops. Load inside preserves the visit.
- **LOC-013-D03 — 2026-11-14.** Preserve quest assignments and progress. Return living quest enemies to their assigned spawn, preserve defeat, and keep still-required items recoverable.
- **LOC-013-D04 — 2026-11-14.** Validate assigned enemy placement and use only eligible authored alternatives. Required failures block preparation. Optional slots can remain empty.


## LOC-012 interview decisions

- **LOC-012-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-012 specification](systems/LOC/LOC-012.md) is finalized as v1.
- **LOC-012-D01 — 2026-11-14.** Convert verified classic heights into depth-enabled water areas with validated extents. Allow native bounded volumes spanning blocks and resolve environmental data independently of arrival selection.
- **LOC-012-D02 — 2026-11-14.** Treat connected equal-height water as continuous. Preserve differing surfaces and require validated resolution for conflicting volumes. Preserve breath across seams and restoration and require genuine gameplay entry for splash feedback.
- **LOC-012-D03 — 2026-11-14.** Use explicit spatial special areas with declared uses. Import verified classic castle and treasure-room coverage and support modded areas across blocks or restricted to one floor. Resolve committed membership for owner-specific effects.

The user answered “Yes” to each of the three interview recommendations.

## LOC-011 interview decisions

- **LOC-011-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-011 specification](systems/LOC/LOC-011.md) is finalized as v1.
- **LOC-011-D01 — 2026-11-14.** Scope stable marker IDs to placed dungeon blocks. Explicitly bind doorway, general and opening arrivals. Allow declared shared or distinct landings.
- **LOC-011-D02 — 2026-11-14.** Verify classic marker roles and placement. Require validated mapping overrides or explicit failure for unresolved required routes. Verify the original Privateer's Hold deep-cave pose and facing.
- **LOC-011-D03 — 2026-11-14.** Restrict ordered authored backups to general routes under WORLD-003. Named doorway and opening placements retain their target and allow only permitted local corrections. Native load restores the saved pose under its own rules.

The user answered “Yes” to each of the three interview recommendations.

## LOC-010 interview decisions

- **LOC-010-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-010 specification](systems/LOC/LOC-010.md) is finalized as v1.
- **LOC-010-D01 — 2026-11-14.** Use verified classic palettes as the baseline. Support fixed authored story palettes and validated deliberate site overrides.
- **LOC-010-D02 — 2026-11-14.** Offer opt-in variation for eligible dungeons based on their own climate and stable dungeon-specific seed. Preserve results under the same configuration and isolate visual randomness.
- **LOC-010-D03 — 2026-11-14.** Support whole-palette and per-slot overrides. Inherit unspecified slots from the resolved baseline and apply DATA-022 recovery to invalid selected overrides or missing required assets.

The user answered “Yes” to each of the three interview recommendations.

## LOC-009 interview decisions

- **LOC-009-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-009 specification](systems/LOC/LOC-009.md) is finalized as v1.
- **LOC-009-D01 — 2026-11-14.** Preserve classic grid placements. Support snapped and freely positioned, rotated native pieces. Validate intended traversable connections.
- **LOC-009-D02 — 2026-11-14.** Preserve intentional door pairs. Suppress duplicates only through verified classic import rules or explicit authored relationships. Validate affected references and fail required blocked passages with unresolved conflicts.
- **LOC-009-D03 — 2026-11-14.** Require the full gameplay-critical dungeon before entry commits. Allow staged block assembly and safe deferred decoration.

The user answered “Yes” to each of the three interview recommendations.

## LOC-008 interview decisions

- **LOC-008-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-008 specification](systems/LOC/LOC-008.md) is finalized as v1.
- **LOC-008-D01 — 2026-11-14.** Use explicit authored fixture roles. Import verified classic model and building-context roles and allow validated mod overrides.
- **LOC-008-D02 — 2026-11-14.** Use stable interior-scoped fixture IDs. Compatible edits can preserve identity and contents. Reused layouts have independent state. Removal or replacement with durable contents requires explicit disposition.
- **LOC-008-D03 — 2026-11-14.** Property acquisition changes designated fixtures only. Eligible player storage has no automatic household restock. Existing contents use approved disposition rules and decorative and reading roles persist unless explicitly changed.

The user answered “Yes” to each of the three interview recommendations.

## LOC-007 interview decisions

- **LOC-007-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-007 specification](systems/LOC/LOC-007.md) is finalized as v1.
- **LOC-007-D01 — 2026-11-14.** Use stable interior-scoped placements, explicit actor assignments and validated authored alternatives. Required placement failure follows LOC-005. Optional occupants stay absent when placement is unavailable.
- **LOC-007-D02 — 2026-11-14.** Reevaluate occupants individually when authored conditions change. Defer routine visible changes and changes during active interaction. Apply current ECON service eligibility immediately.
- **LOC-007-D03 — 2026-11-14.** Require explicit quest substitution and original occupant disposition. Allow one active occupant per placement and require separate authorized provider binding for service continuity.

The user answered “Yes” to each of the three interview recommendations.

## LOC-006 interview decisions

- **LOC-006-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-006 specification](systems/LOC/LOC-006.md) is finalized as v1.
- **LOC-006-D01 — 2026-11-14.** Use stable interior-scoped markers with explicit roles and allow declared multiple roles. Each usable exit links to its intended exterior doorway.
- **LOC-006-D02 — 2026-11-14.** Resolve classic links in content preparation using verified source geometry. Verify rest-as-entry usage. Require a validated override or explicit failure for missing or ambiguous matches.
- **LOC-006-D03 — 2026-11-14.** Preserve the selected binding when blocked. Apply MOVE-027 local correction and approved recovery. ECON and LAW retain their own selection and failure rules.

The user answered “Yes” to each of the three interview recommendations.

## LOC-005 interview decisions

- **LOC-005-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-005 specification](systems/LOC/LOC-005.md) is finalized as v1.
- **LOC-005-D01 — 2026-11-14.** Use explicit building-scoped interior IDs. Entrances to the same interior share owner-held state. Separate interiors can reuse layout templates and retain independent state.
- **LOC-005-D02 — 2026-11-14.** Prepare the layout, required collision, entrance binding and required gameplay records and owner state before handoff to MOVE. Allow safe deferred decoration. Discard partial preparation on required failure and follow approved transition recovery.
- **LOC-005-D03 — 2026-11-14.** Derive automap data from the same resolved layout and variant as gameplay. Allow readability simplification and apply discovery rules while preserving spatial alignment.

The user answered “Yes” to each of the three interview recommendations.

## LOC-004 interview decisions

- **LOC-004-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-004 specification](systems/LOC/LOC-004.md) is finalized as v1.
- **LOC-004-D01 — 2026-11-14.** Classic scheduled gates default to 06:00–18:00. Support moddable per-gate schedules and fixed open or closed states. Resolve schedule from current game time after streaming, loading or time skips.
- **LOC-004-D02 — 2026-11-14.** Defer physical closure while the opening is occupied. Apply scheduled access restrictions at closing time to routes that require gate access.
- **LOC-004-D03 — 2026-11-14.** Use stable settlement-scoped markers with explicit roles and gate dependencies. Allow eligible authored outside approaches on general routes. Revalidate gate access and placement before commitment and fail explicitly when candidates are exhausted.

The user answered “Yes” to each of the three interview recommendations.

## LOC-003 interview decisions

- **LOC-003-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-003 specification](systems/LOC/LOC-003.md) is finalized as v1.
- **LOC-003-D01 — 2026-11-14.** Use stable building-scoped entrance IDs and validated destination and return links. Compatible edits can preserve identity. Replacements use new IDs and explicit migration where continuity is intended.
- **LOC-003-D02 — 2026-11-14.** Use explicit collider bindings or authored hit regions. Require validated selection for overlapping regions. An ambiguous live hit produces no door action.
- **LOC-003-D03 — 2026-11-14.** Derive classic hit regions from verified metadata where possible and allow explicit mod bindings and overrides. Validate required alignment and reachability. A required unbound entrance fails preparation through approved recovery.

The user answered “Yes” to each of the three interview recommendations.

## LOC-002 interview decisions

- **LOC-002-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-002 specification](systems/LOC/LOC-002.md) is finalized as v1.
- **LOC-002-D01 — 2026-11-14.** Use persistent location-scoped building identity. Compatible edits within a location can retain identity. A replacement or cross-location move gets a new scoped identity and can use explicit migration. Validate dependent references independently.
- **LOC-002-D02 — 2026-11-14.** Return validated building records and deterministic type and faction candidates. Requesting systems own eligibility and selection.
- **LOC-002-D03 — 2026-11-14.** Reject ambiguous duplicates within one location, identify both contributing records and follow approved content recovery. Allow validated overrides.

The user answered “Yes” to each of the three interview recommendations.

## LOC-001 interview decisions

- **LOC-001-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [LOC-001 specification](systems/LOC/LOC-001.md) is finalized as v1.
- **LOC-001-D01 — 2026-11-14.** Preserve supported classic placements. Support snapped blocks and free placement with rotation in native layouts.
- **LOC-001-D02 — 2026-11-14.** Allow shared boundaries. Require explicit authored selection for intentional overlaps where a consumer needs one settlement. Reject ambiguous overlaps during validation.
- **LOC-001-D03 — 2026-11-14.** Support authored terrain shaping for streets and entrances. Validate required routes and doors before the affected area becomes playable.

The user answered “Yes” to each of the three interview recommendations.

## WORLD-018 interview decisions

- **WORLD-018-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-018 specification](systems/WORLD/WORLD-018.md) is finalized as v1, including read-only discovery capture, required-reference preflight, disclosed inactive retention of map-only records, and independent validation of discovery and placement when sites move.
- **WORLD-018-D01 — 2026-11-14.** Capture committed discoveries, applicable temporary grants and labels without mutating live state. Rebuild derived map and streaming views and reconstruct the origin from saved authoritative position and context.
- **WORLD-018-D02 — 2026-11-14.** Require validated migration for missing required references and reject unresolved required preflight failures without replacing the current session. Allow disclosed inactive retention of map-only records with later validated reactivation.
- **WORLD-018-D03 — 2026-11-14.** Retain earned knowledge for a validated move of the same site and show its current authorized position. Validate player pose and quest binding independently. Support explicit mod migrations.

## WORLD-017 interview decisions

- **WORLD-017-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-017 specification](systems/WORLD/WORLD-017.md) is finalized as v1, including current validation at gameplay commitment and moddable freshness, scope, eligibility, classification and disclosure.
- **WORLD-017-D01 — 2026-11-14.** Allow periodic passive observations and require current validation for gameplay commitments. Make freshness profiles moddable.
- **WORLD-017-D02 — 2026-11-14.** Query live eligible subjects under explicit feature scopes. Preserve valid coverage across seams and stock detection scope restrictions. Make scope and eligibility moddable.
- **WORLD-017-D03 — 2026-11-14.** Owners validate classifications and govern sensing, presentation and targeting. WORLD supplies proximity facts. Support modded classifications and disclosure policies under the relevant owner rules.

## WORLD-016 interview decisions

- **WORLD-016-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-016 specification](systems/WORLD/WORLD-016.md) is finalized as v1, including shared discovery permissions across detail views, stable settlement selection, distinct player and entrance markers, and label priorities.
- **WORLD-016-D01 — 2026-11-14.** Use basic and detailed exterior views with the same discovery permissions. Detailed views can add authorized geometry and landmarks.
- **WORLD-016-D02 — 2026-11-14.** Open on the committed settlement, including from its interiors. Allow explicit selection of other known settlements in the same or another pixel. Indicate when the player is elsewhere and distinguish a known indoor entrance from the player arrow.
- **WORLD-016-D03 — 2026-11-14.** Prioritize selected buildings and authorized quest marks, declutter at lower zoom and allow full authorized label inspection. Preserve WORLD-015 precedence and support mod symbols and detail layers under the same permissions.

## WORLD-015 interview decisions

- **WORLD-015-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-015 specification](systems/WORLD/WORLD-015.md) is finalized as v1, including authorized building discovery, durable player labels, and independent lockpick history under MOVE-020.
- **WORLD-015-D01 — 2026-11-14.** Eligible successful entry, deliberate exterior inspection and explicitly permanent sources grant exact building discovery. Proximity and compass hints leave exact knowledge unchanged. Hidden and modded buildings can use explicit eligibility.
- **WORLD-015-D02 — 2026-11-14.** Separate authored names, quest aliases and player labels. Prefer the player label on visible marks and preserve it dormant when hidden. Quest cleanup preserves independently earned discovery.
- **WORLD-015-D03 — 2026-11-14.** MOVE-020 owns failed lockpick history independently of discovery and naming. A lock attempt reveals map knowledge only through a separate authorized trigger.

## WORLD-014 interview decisions

- **WORLD-014-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-014 specification](systems/WORLD/WORLD-014.md) is finalized as v1, including eligible settlement discovery, retained random reveal selection and explicit discovery rules for sites added to existing characters.
- **WORLD-014-D01 — 2026-11-14.** Eligible entry grants permanent exact discovery for ordinary settlements. Hidden sites use authorized reveal rules. Proximity, streaming and load alone grant no discovery. Mods can define entry eligibility and precision.
- **WORLD-014-D02 — 2026-11-14.** Stock random reveals select uniformly from authorized sites in the declared area without a current exact mark. Partial clues remain eligible. Retain selection on retry, report exhaustion and allow modded pools and weights.
- **WORLD-014-D03 — 2026-11-14.** Apply authored defaults at character creation. Sites added through supported content changes to an existing character require normal discovery or an explicit supported reveal grant.

## WORLD-013 interview decisions

- **WORLD-013-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-013 specification](systems/WORLD/WORLD-013.md) is finalized as v1, including authored presence footprints, optional policy areas, ordered boundary reactions, and discovery eligibility based on committed entry.
- **WORLD-013-D01 — 2026-11-14.** Use authored settlement footprints for ordinary presence and optional authored areas for separate law, discovery and ambient policies. Allow modded footprints and areas.
- **WORLD-013-D02 — 2026-11-14.** Record direct town changes as one committed transition with old and new memberships. Run ordered exit reactions before entry reactions. Preserve town presence across nested building entry.
- **WORLD-013-D03 — 2026-11-14.** Entry supplies a discovery input. Eligible settlements can be discovered on entry, while hidden sites may require other authorization. Committed teleport can count by endpoints. Native load restores presence without entry.

## WORLD-012 interview decisions

- **WORLD-012-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-012 specification](systems/WORLD/WORLD-012.md) is finalized as v1, including coherent geographic context updates, footprint-based location resolution, and validated moddable boundaries and associations.
- **WORLD-012-D01 — 2026-11-14.** Publish one committed geographic context update carrying previous and current context and changed fields.
- **WORLD-012-D02 — 2026-11-14.** Resolve exterior location by committed position and validated footprints, with explicit selection for overlaps requiring one answer. Report no location between footprints. Indoors use the committed location and WORLD-001 anchor.
- **WORLD-012-D03 — 2026-11-14.** Distinguish valid absence from missing required data. Publish stable geographic identities and associations for owner interpretation. Support validated modded boundaries and associations.

## WORLD-011 interview decisions

- **WORLD-011-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-011 specification](systems/WORLD/WORLD-011.md) is finalized as v1, including stable stock placement, moddable plant placement behavior and authored clearances, and readiness for gameplay-bearing vegetation.
- **WORLD-011-D01 — 2026-11-14.** Use deterministic world-coordinate nature placement. Stock seasons preserve placement and change appearance. Mods may add plants and add or alter placement behavior, including seasonal eligibility and placement.
- **WORLD-011-D02 — 2026-11-14.** Use moddable climate, terrain and water eligibility and density rules with authored clearances across all applicable footprints. Protect stock routes and keep stock land vegetation clear of water. Support suitable modded shoreline and aquatic vegetation.
- **WORLD-011-D03 — 2026-11-14.** Generated vegetation is decorative by default. Explicit gameplay vegetation follows its owner and required readiness rules. Representation swaps preserve placement and gameplay state.

## WORLD-010 interview decisions

- **WORLD-010-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-010 specification](systems/WORLD/WORLD-010.md) is finalized as v1, including stable gameplay surface IDs, water contact based on geometry, deterministic moddable transitions, and independent appearance and surface overrides.
- **WORLD-010-D01 — 2026-11-14.** Use stable terrain surface IDs independent of cosmetic textures. Allow explicit mod surface behavior under MOVE-007. Water contact and submersion use actual water geometry and actor context.
- **WORLD-010-D02 — 2026-11-14.** Use deterministic seam-consistent visual transitions, including direct water-to-grass and water-to-stone where appropriate. Support moddable transition rules.
- **WORLD-010-D03 — 2026-11-14.** Allow independent appearance and gameplay surface edits for authored location and feature footprints. Conflicting edits need explicit resolution consistent with WORLD-008.

## WORLD-009 interview decisions

- **WORLD-009-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-009 specification](systems/WORLD/WORLD-009.md) is finalized as v1, including readiness by area and seam, coherent terrain replacement, and recovery for persistent failures in required coverage.
- **WORLD-009-D01 — 2026-11-14.** Publish terrain readiness by area and seam. Cell interiors may be ready independently. Crossings require compatible active collision on touched edges and corners.
- **WORLD-009-D02 — 2026-11-14.** Retain compatible playable terrain during rebuild and switch affected surfaces and collision together at a safe simulation boundary. Use the WORLD-004 hold if existing coverage becomes invalid.
- **WORLD-009-D03 — 2026-11-14.** Cancel obsolete jobs where practical and validate results before installation. Allow safe compatible cache reuse. Rebuild current mismatches from resolved inputs and gate persistent failures, with recovery for required coverage.

## WORLD-008 interview decisions

- **WORLD-008-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-008 specification](systems/WORLD/WORLD-008.md) is finalized as v1, including deterministic stock terrain, moddable geography and detail, footprint-based edits, and stock shoreline and approach constraints.
- **WORLD-008-D01 — 2026-11-14.** Preserve broad stock geography from classic samples with deterministic world-coordinate terrain detail. Mods can supply altered geography, height inputs and detail.
- **WORLD-008-D02 — 2026-11-14.** Support authored terrain footprints and blend margins for locations and independent features, including multiple edits in a pixel. Conflicting edits require explicit composition or override.
- **WORLD-008-D03 — 2026-11-14.** Constrain stock detail at shorelines, entrances and authored approaches. Permit intentional reshaping through validated mod overrides.

## WORLD-007 interview decisions

- **WORLD-007-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-007 specification](systems/WORLD/WORLD-007.md) is finalized as v1, including game-time retention of outdoor drops, owner-defined object lifetimes and scopes, and safe retirement of durable instances.
- **WORLD-007-D01 — 2026-11-14.** Ordinary outdoor player drops survive streaming and native save/load until the tunable game-time cleanup rule expires them. Honor quest and other explicit protections.
- **WORLD-007-D02 — 2026-11-14.** Object owners declare lifetime and scope. Retain durable and quest records for reconstruction. Short-lived objects follow their owner rules. Allow mod-authored policies for standalone exterior objects.
- **WORLD-007-D03 — 2026-11-14.** Secure durable state before retiring the live instance. Defer failed retirement while safe and use existing recovery if safe continuation cannot be established.

## WORLD-006 interview decisions

- **WORLD-006-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-006 specification](systems/WORLD/WORLD-006.md) is finalized as v1, including activation by ready area, independent record and live-resource readiness, durable state across streaming, and modded locations and standalone features sharing a map pixel.
- **WORLD-006-D01 — 2026-11-14.** Activate exterior areas as their collision, interactions and required gameplay content become ready. Use WORLD-004 holds at unfinished boundaries.
- **WORLD-006-D02 — 2026-11-14.** Resolve validated stable location and building records independently of live readiness. Doors, actors and usable navigation require their own ready dependencies.
- **WORLD-006-D03 — 2026-11-14.** Rebuild exteriors from authored content and owner-held durable state. Close affected live interactions on unload. Residency changes alone trigger no discovery, quest progress or resets.
- **WORLD-006-D04 — 2026-11-14.** Allow multiple independently identified exterior locations in a map pixel without a fixed per-pixel count cap. Allow separately placeable objects and large terrain features that do not count as locations. Support mod authoring for both. This supersedes DATA-004-D03 and the pixel occupancy restriction in DATA-004-D04.

## WORLD-005 interview decisions

- **WORLD-005-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-005 specification](systems/WORLD/WORLD-005.md) is finalized as v1, including the configurable square terrain window, bounded inactive cache, and capacity priorities that protect required gameplay coverage.
- **WORLD-005-D01 — 2026-11-14.** Start with a configurable square terrain window centered on the player. Required gameplay coverage takes precedence. Set the default distance through world-scale, visibility and performance testing.
- **WORLD-005-D02 — 2026-11-14.** Retain recently departed cells in a bounded inactive cache. Keep required collision active for valid movement, arrival and projectile paths. Clear old bindings on slot reuse and validate the new cell and seams before gameplay.
- **WORLD-005-D03 — 2026-11-14.** Reclaim inactive cache first under capacity pressure, then reduce optional distant coverage. Use WORLD-004's safe hold and recovery for required shortages.

## WORLD-004 interview decisions

- **WORLD-004-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-004 specification](systems/WORLD/WORLD-004.md) is finalized as v1, including the revisable immediate-area readiness gate, safe streaming holds and prioritization of current demand.
- **WORLD-004-D01 — 2026-11-14.** Gate control on collision and gameplay-critical content for placement and the immediate playable area. Optional scenery may finish later. Keep this readiness policy open to future change if deemed necessary.
- **WORLD-004-D02 — 2026-11-14.** Prefetch during normal movement. Hold at the last safe position with loading feedback before entering unready space, preserve movement state and use explicit recovery for required-content failure.
- **WORLD-004-D03 — 2026-11-14.** Prioritize the latest required area and reuse relevant work. Safe caching of obsolete work is allowed, while obsolete results cannot activate content or mark a superseded destination ready. Preserve geographic events for actual movement.

## WORLD-003 interview decisions

- **WORLD-003-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-003 specification](systems/WORLD/WORLD-003.md) is finalized as v1, including route-defined arrival intent, bounded fallback rules and one committed outcome for ready and streamed destinations.
- **WORLD-003-D01 — 2026-11-14.** Routes declare arrival intent. Exact coordinates, Recall anchors and named doors resolve to their specified targets. General location routes use an authored default or explicitly select by approach.
- **WORLD-003-D02 — 2026-11-14.** Only general location routes may use ordered authored backups within the same destination and access constraints. Specific targets permit bounded local correction and otherwise report unavailability.
- **WORLD-003-D03 — 2026-11-14.** Ready and streamed destinations share one arrival contract. Ready destinations may complete immediately after validation. Streamed destinations remain pending through geometry, placement and context readiness and publish one committed outcome.

## WORLD-002 interview decisions

- **WORLD-002-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-002 specification](systems/WORLD/WORLD-002.md) is finalized as v1, including distance-based shifts, coherent physics-boundary commits, and safe deferral or recovery.
- **WORLD-002-D01 — 2026-11-14.** Trigger origin shifts using separate configurable horizontal and vertical distance thresholds. Choose values through world-scale and physics testing. Map pixel changes independently update geography and streaming.
- **WORLD-002-D02 — 2026-11-14.** Commit one coherent origin shift at a physics boundary for the entire active simulation space. Gameplay queries resume on the committed frame, and presentation caches may rebuild before the next visible frame.
- **WORLD-002-D03 — 2026-11-14.** Defer if a required system cannot apply a shift and the intact current frame remains within a verified safe range. Suspend affected simulation and use existing recovery when continuation cannot be established as safe.

## WORLD-001 interview decisions

- **WORLD-001-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [WORLD-001 specification](systems/WORLD/WORLD-001.md) is finalized as v1, including coherent outdoor position synchronization, stable indoor geography, committed exit publication and restoration without replaying crossing consequences.
- **WORLD-001-D01 — 2026-11-14.** MOVE owns the local physics pose. WORLD computes and owns continuous outdoor geographic position from that pose and an explicit origin. Derive map pixel from geographic position.
- **WORLD-001-D02 — 2026-11-14.** Use the current location's geographic anchor inside buildings and dungeons. Track interior pose and the entry-door return reference separately. Publish actual exit geography after successful exit, including when it lies in a different map pixel or region.

## ECON-019 interview decisions

- **ECON-019-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-019 specification](systems/ECON/ECON-019.md) is finalized as v1, including preflight validation for required economic state, disclosed recovery for display-only history, and coherent save and recovery boundaries.
- **ECON-019-D01 — 2026-11-14.** Missing dependencies for required economic state need a validated migration or declared recovery from the owning system. Otherwise reject load during preflight, preserve the current session and identify the problem.
- **ECON-019-D02 — 2026-11-14.** Allow disclosed, owner-defined recovery for unreadable closed history used only for display. Facts needed for eligibility, obligations, default or reward history, or replay prevention remain required.
- **ECON-019-D03 — 2026-11-14.** Defer ordinary saves during unsettled economic mutations until a coherent boundary. An approved owner may save supported recovery state with exact committed facts and unfinished work. Active loans, rentals and repair jobs remain eligible at coherent boundaries.

## ECON-018 interview decisions

- **ECON-018-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-018 specification](systems/ECON/ECON-018.md) is finalized as v1, including free instantaneous guild teleportation, retained daily coven selection, moddable summoning rules, and retained payment and results for admitted attempts.
- **ECON-018-D01 — 2026-11-14.** Stock guild teleportation is free and adds no game travel time. Confirm the destination and revalidate provider access and arrival readiness. Mods can vary fare, destinations and elapsed time.
- **ECON-018-D02 — 2026-11-14.** Preserve stock summoning dates, Glenmoril's Hircine default, retained daily selection at other covens, applicable weather bonuses, and Sheogorath substitution at 5% normally and 15% in storms. Make these policies moddable.
- **ECON-018-D03 — 2026-11-14.** The confirmed summoning fee buys an attempt and is retained after a failed roll. Preserve eligible failed-coven hostile spawns and the once-per-Daedra quest offer. Technical retry resumes the original attempt without another charge or roll.

## ECON-017 interview decisions

- **ECON-017-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-017 specification](systems/ECON/ECON-017.md) is finalized as v1, including per-opening potion stock, skill-linked spell prices, checked spell learning, and zero stock spell purchase practice with a moddable award policy.
- **ECON-017-D01 — 2026-11-14.** Preserve DFU's stock potion restock on each new opening of the purchase service. Mods can change pools, quantities and refresh cadence, including retained daily stock.
- **ECON-017-D02 — 2026-11-14.** Stock spell price uses four times current spell-point cost, applicable Witches Festival reduction in the provider's region, then buy bargaining. Make pricing moddable.
- **ECON-017-D03 — 2026-11-14.** Keep DFU's stock spell purchase rule of no Mercantile practice. Mods can award practice using the committed price and currency unit. Physical magic goods follow ECON-004.

## ECON-016 interview decisions

- **ECON-016-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-016 specification](systems/ECON/ECON-016.md) is finalized as v1, including stock temple nonmember access, full tender and confirmed ceremonial donations, moddable disease treatment pricing and holiday relief, and treatment for eligible incubating transformations.
- **ECON-016-D01 — 2026-11-14.** Use full eligible carried gold and credit for training, donations and paid disease treatment. Preserve provider-specific access, including stock temple nonmember access. Confirm positive donations with exact amount and recipient. Stock donations are ceremonial. Mods can change tender and attach disclosed effects.
- **ECON-016-D02 — 2026-11-14.** Keep the moddable 250-gold treatment base per eligible infection, followed by the applicable Arkay discount, shop adjustment, holiday adjustment and bargaining. South Winds Prayer and the two Harvest holidays waive the fee. North Winds Festival halves the price before bargaining. Confirm free and paid treatments. Explain when no eligible condition needs treatment.
- **ECON-016-D03 — 2026-11-14.** Stock temple treatment can cure incubating vampirism or lycanthropy while its owner permits. Count each eligible infection once. Established transformations use their separate cure rules.

## ECON-015 interview decisions

- **ECON-015-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-015 specification](systems/ECON/ECON-015.md) is finalized as v1, including rolling rental days, confirmed paid and free bookings, inn-wide persistence for player drops during an active rental, and rest interruption at exact expiry.
- **ECON-015-D01 — 2026-11-14.** Rent in 24-game-hour increments from booking or the existing expiry. Keep the assigned bed on extension and cap the booking horizon at exactly 350 game days. Price the added stay from its start date.
- **ECON-015-D02 — 2026-11-14.** Apply the DFU bargaining adjustment to the nonfree base fee and accept eligible carried gold and credit. Confirm paid and free bookings. Validate a stable usable bed before charging and revalidate the same bed for extensions. Make the stock policies moddable.
- **ECON-015-D03 — 2026-11-14.** Stock rentals grant rest at the assigned bed and protect player-dropped items anywhere in that inn across transitions. At expiry, those items lose rental persistence protection and follow ordinary cleanup rules. Make these policies moddable.
- **ECON-015-D04 — 2026-11-14.** Stop ongoing rental rest at exact expiry and explain why. A subsequent rental rest requires a new valid booking.

## ECON-014 interview decisions

- **ECON-014-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-014 specification](systems/ECON/ECON-014.md) is finalized as v1, including one stock ship per player, port-town purchases, resale at authorized banks, DFU pricing and safeguards for ship visits and possessions.
- **ECON-014-D01 — 2026-11-14.** Allow one stock ship per player. Buy at port-town banks and sell at any authorized bank. Make ownership limits and branch rules moddable.
- **ECON-014-D02 — 2026-11-14.** Keep the two stock prices of 100,000 and 200,000 gold and 85% resale rounded down. Purchases draw eligible carried funds first, then the purchase branch's local account. Credit resale proceeds to the selling branch's local account. Make these rules moddable.
- **ECON-014-D03 — 2026-11-14.** Block sale while the player is aboard, while boarding or return is pending, or while stored or dropped player possessions remain aboard. Mods may offer explicit relocation of belongings.

## ECON-013 interview decisions

- **ECON-013-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-013 specification](systems/ECON/ECON-013.md) is finalized as v1, including regional ownership limits, retained monthly listings, DFU deed pricing, shared reward allocation checks and protection for player possessions during sale.
- **ECON-013-D01 — 2026-11-14.** Allow one stock house per region. Buy and sell through a bank in the property's settlement. Keep explicitly listed homes and a retained monthly selection of eligible ordinary residences. Make limits, listing cadence and transaction locations moddable.
- **ECON-013-D02 — 2026-11-14.** Keep DFU radius-based pricing and 85% resale rounded down. Purchases use eligible carried funds before the local balance. Sales credit that account. Allow modded prices and funding rules.
- **ECON-013-D03 — 2026-11-14.** Block stock sale until the player removes stored and dropped possessions. Buying grants the house and fixtures. Household loot and protected quest items follow their ownership rules. Mods may offer explicit relocation or storage.

## ECON-012 interview decisions

- **ECON-012-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-012 specification](systems/ECON/ECON-012.md) is finalized as v1, including moddable banking-record reminders, game-date overdue checks, and notices for the first overdue outcome and later funded collections.
- **ECON-012-D01 — 2026-11-14.** Keep moddable six-, three-, and one-month reminder thresholds. Coalesce thresholds crossed in one time jump into one current reminder per loan. If the jump ends overdue, report the settlement outcome.
- **ECON-012-D02 — 2026-11-14.** Check overdue loans on game-date changes by default, including after travel or waiting. Make the cadence moddable.
- **ECON-012-D03 — 2026-11-14.** Keep stock reminders out of the HUD. Retain banking records for collections and defaults, with one immediate notice for the first overdue outcome and for later automatic collections that move funds. Checks that neither move funds nor change status stay quiet after the first outcome. Make notification behavior moddable.

## ECON-011 interview decisions

- **ECON-011-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-011 specification](systems/ECON/ECON-011.md) is finalized as v1, including regional one-year loans, partial repayment through carried funds and the local account, and restored borrowing eligibility after full repayment of defaulted debt.
- **ECON-011-D01 — 2026-11-14.** Stock loans have a 100-gold minimum, a one-game-year term and one outstanding loan per region. Deposit the principal into the issuing region's account. Mods can vary the limits, term and borrowing scope.
- **ECON-011-D02 — 2026-11-14.** Allow partial manual repayment at the issuing region's bank using eligible carried funds first and the local account for the remainder. Cap the requested amount at outstanding debt before checking affordability and show the exact split before confirmation.
- **ECON-011-D03 — 2026-11-14.** Restore stock borrowing eligibility after full repayment of a defaulted loan. Retain default history and leave standing penalties to ordinary recovery. Mods can restrict future borrowing based on default history.

## ECON-010 interview decisions

- **ECON-010-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-010 specification](systems/ECON/ECON-010.md) is finalized as v1, including the stock 100-gold issuance minimum and 1% commission, fee-free face-value redemption across regions, confirmed Deposit All, and moddable issuance and redemption policies.
- **ECON-010-D01 — 2026-11-14.** Stock issuance has a 100-gold minimum face value and a 1% commission rounded down to whole gold. Show face value, fee and total debit. Charge only if the letter can be delivered. Mods can change minimums, fees and rounding.
- **ECON-010-D02 — 2026-11-14.** Any authorized stock bank can redeem eligible stock letters fee-free at their remaining face value into its local account. Mods can vary issuer acceptance and rates by institution or region.
- **ECON-010-D03 — 2026-11-14.** Stock redemption uses Deposit All with confirmation showing eligible letters and total credit. Mods can offer selected-letter and partial-face redemption.

## ECON-009 interview decisions

- **ECON-009-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-009 specification](systems/ECON/ECON-009.md) is finalized as v1, including local fee-free coin transfers, carried-first deposits with eligible wagon funds, and capacity-checked carried withdrawals with moddable account access and destinations.
- **ECON-009-D01 — 2026-11-14.** Stock bank branches share one player account within their region. Coin deposits and withdrawals are local and fee-free. Mods can authorize cross-region access, shared banking networks or fees.
- **ECON-009-D02 — 2026-11-14.** Deposit carried coin first and draw the remainder from an eligible wagon. Show the source breakdown and revalidate wagon access before settlement.
- **ECON-009-D03 — 2026-11-14.** Stock withdrawals deliver only to carried inventory. Show the current maximum and let the player revise an amount that cannot fit. An explicit accessible wagon destination is a mod option.

## ECON-008 interview decisions

- **ECON-008-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-008 specification](systems/ECON/ECON-008.md) is finalized as v1, including whole-batch settlement, stock per-stack pricing, moddable per-unit pricing, and value-aware practice policies for completed paid or free orders.
- **ECON-008-D01 — 2026-11-14.** Settle the full identification batch under one confirmation using carried gold and eligible carried credit. Flag invalid entries before payment or disclosure. Materially changed fees, scope or tender require renewed acceptance.
- **ECON-008-D02 — 2026-11-14.** Charge once for a whole compatible stack with shared appraisable properties and knowledge. Appraise distinct eligible entries separately. Mods can select per-unit pricing.
- **ECON-008-D03 — 2026-11-14.** Award one Mercantile point per completed identification order, including eligible free orders. Already-known scope earns no award. Modded practice policies can use the committed fee and currency unit.

## ECON-007 interview decisions

- **ECON-007-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-007 specification](systems/ECON/ECON-007.md) is finalized as v1, including whole-batch settlement, independent timed jobs, the moddable stock Instant Repairs option, checked collection and cancellation, and one stock Mercantile practice point per settled order.
- **ECON-007-D01 — 2026-11-14.** Stock repair submissions use one confirmation and full settlement for the batch with carried gold and eligible credit. Timed jobs retain independent per-item schedules. Invalid lines return to the editable selection without charges.
- **ECON-007-D02 — 2026-11-14.** Timed repair is the default. Include a stock, moddable Instant Repairs option that quotes immediate restoration and settles payment and repair together without leaving the item in ongoing service custody.
- **ECON-007-D03 — 2026-11-14.** Award one Mercantile practice point when a repair order settles, including an eligible free order. Later completion, collection and cancellation award no additional practice. Modded awards can use the committed fee and currency unit.

## ECON-006 interview decisions

- **ECON-006-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-006 specification](systems/ECON/ECON-006.md) is finalized as v1, including moddable confirmation, full basket validation before one detection check, source stack counting, and trade window closure after detection or successful delivery.
- **ECON-006-D01 — 2026-11-14.** Stock open-shop Steal requires confirmation with labelled detection risk. Mods can change confirmation behavior.
- **ECON-006-D02 — 2026-11-14.** Count each distinct selected source stack once and weigh only the selected units. Validate the whole basket before rolling. Flag stale lines and let the player edit their selection.
- **ECON-006-D03 — 2026-11-14.** Close the trade window after detection or successful theft delivery. Blocked attempts retain the basket for correction.

## ECON-005 interview decisions

- **ECON-005-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-005 specification](systems/ECON/ECON-005.md) is finalized as v1, including capacity-checked coin or credit payout, renewed acceptance for changed terms, and moddable Mercantile practice for completed sales including zero-gold sales.
- **ECON-005-D01 — 2026-11-14.** Automatically pay the full sale value in carried gold if it fits, otherwise issue one admissible carried letter of credit for the full amount. Show the form before acceptance and reconfirm changes. If both delivery plans fail, return to the basket. Mods may offer manual choice, split payouts or other authorized destinations.
- **ECON-005-D02 — 2026-11-14.** Allow eligible zero-gold sales after explicit confirmation of zero proceeds. Transfer the goods without a payout instrument and award ordinary sale practice. Make the practice policy moddable.
- **ECON-005-D03 — 2026-11-14.** Stock sales award one Mercantile practice point per completed basket, including coin, credit and zero proceeds. Modded award policies receive the committed basket value and currency unit.

## ECON-004 interview decisions

- **ECON-004-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-004 specification](systems/ECON/ECON-004.md) is finalized as v1, including full tender and delivery validation, post-commit purchase publication, and moddable Mercantile practice with access to the committed basket value.
- **ECON-004-D01 — 2026-11-14.** Ordinary purchases accept carried gold and eligible carried letters of credit under ITEM-009's spending order. Mods may change accepted forms and explicitly authorize additional funding sources.
- **ECON-004-D02 — 2026-11-14.** Deliver to carried inventory by default. Mods may offer an explicit accessible wagon destination. If full delivery fails capacity checks, return to the basket with a reason.
- **ECON-004-D03 — 2026-11-14.** Award one stock Mercantile practice point per successfully committed paid basket. A modded practice policy can read the committed basket value and use it to calculate the award.

## ECON-003 interview decisions

- **ECON-003-A01 — 2026-11-14.** The user approved Draft v1 with “I approve”. The [ECON-003 specification](systems/ECON/ECON-003.md) is finalized as v1, including editable cancellation, invalid line review, renewed acceptance for changed prices and session-only baskets.
- **ECON-003-D01 — 2026-11-14.** No or Back from confirmation returns to the editable basket. Clear or leaving trade discards it. Selections record item identities and quantities, with ownership and spendable stock changing at settlement.
- **ECON-003-D02 — 2026-11-14.** If a line becomes invalid, return to the basket and flag that line for review. The player chooses any removal or quantity adjustment.
- **ECON-003-D03 — 2026-11-14.** Baskets and their confirmations are session-only. Restore inventory, stock and completed transactions through their authoritative owners.

## ECON-002 interview decisions

- **ECON-002-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [ECON-002 specification](systems/ECON/ECON-002.md) is finalized as v1, including moddable shop-type acceptance, settlement revalidation, retained daily guild magic stock with shared depletion, and stock buyback disabled with support for modded buyback policies.
- **ECON-002-D01 — 2026-11-13.** Keep DFU shop-type item groups and enchanted-only magic resale as moddable defaults. Recheck eligibility at settlement. Mods can add shop types with their own accepted items or no purchases from the player.
- **ECON-002-D02 — 2026-11-13.** Give each declared guild magic stock source retained daily stock and persistent depletion. Routes exposing the same items share quantities. Refresh cadence is moddable.
- **ECON-002-D03 — 2026-11-13.** Stock shops offer no buyback. Provide policy and stock handling that let mods add buyback or resale.

## ECON-001 interview decisions

- **ECON-001-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [ECON-001 specification](systems/ECON/ECON-001.md) is finalized as v1, including independent shelf stock, authorized shelf purchases without a present merchant, merchant-mediated selling, separate guild hall access and service gates, and moddable routes and schedules.
- **ECON-001-D01 — 2026-11-13.** In the stock game, buy from individual shop shelves with independently generated inventories and sell to the merchant. Mods can change how players access those services, including presenting all stock and trade actions in one menu.
- **ECON-001-D02 — 2026-11-13.** Preserve DFU's guild-specific after-hours access defaults. Qualifying for a service grants no anytime hall entry. Where after-hours access is valid, a rank-qualified service remains available through its authorized provider subject to its own eligibility checks. Guild access and service-hour policies are moddable. The local snapshot grants anytime hall access at rank 6 in both the Mages Guild and Fighters Guild.
- **ECON-001-D03 — 2026-11-13.** Stock shelves can sell while the shop is currently open and authorized, even if the owner NPC is absent or unavailable. Mods can require a provider or change the purchase route.

## LAW-016 interview decisions

- **LAW-016-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-016 specification](systems/LAW/LAW-016.md) is finalized as v1, including the stock save restriction through safe release, retained pursuit and dispatch state, denied saves without queued retries, and migration protection for closed cases with unfinished required effects.
- **LAW-016-D01 — 2026-11-13.** Block stock manual saves, quicksaves and autosaves from unresolved surrender or arrest handoff through court, prison and safe release. Normal eligibility resumes after release.
- **LAW-016-D02 — 2026-11-13.** At eligible saves during active enforcement, preserve episode identity, refusal state, existing responders, and valid pending dispatch with its remaining active delay. Restore and resume unfinished work at its normal trigger.
- **LAW-016-D03 — 2026-11-13.** Require validated migration for missing definitions behind enforceable legal state. If migration is unavailable, explain the load failure and preserve the current session. Closed historical records may be retained as inactive history with explicit notice.

## LAW-015 interview decisions

- **LAW-015-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-015 specification](systems/LAW/LAW-015.md) is finalized as v1, including sentence and release time handling, outcome-specific vital effects, safe return placement and recovery without repeating settled effects.
- **LAW-015-D01 — 2026-11-13.** Use a skippable countdown and commit the full prison term through TIME once. Calendar deadlines, rentals and timed effects follow their owner clock rules. Ambient encounters, periodic pursuit and standing normalization skip the sentence interval.
- **LAW-015-D02 — 2026-11-13.** After a positive prison term, add four game hours and refill vitals. Fine-only, acquittal and guild rescue release add no time and preserve vitals. Banishment refills vitals and adds no time. These defaults are moddable subject to their outcome owners.
- **LAW-015-D03 — 2026-11-13.** Use a validated jail exit or town gate in the sentencing jurisdiction with a safe local fallback. Close the resolved case and eligible companions, end the case-scoped response and preserve unrelated actors and legal obligations. Failed placement retains settled work for recovery.

## LAW-014 interview decisions

- **LAW-014-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-014 specification](systems/LAW/LAW-014.md) is finalized as v1, including persistent regional banishment, safe local release, one stock pursuit check per region, pardon handling, and authored execution through CHAR with an explicit continuation when death is prevented.
- **LAW-014-D01 — 2026-11-13.** Stock regional banishment persists until explicit pardon or removal. Entry and remaining in the region are possible and expose the player to LAW-008 pursuit. Travel, reload and standing recovery preserve the restriction. Mods can add expiry, entry restrictions or shared enforcement.
- **LAW-014-D02 — 2026-11-13.** Banishment resolves the case, preserves the regional restriction, releases at a validated local exit and refills vitals. Stock release grants no LAW-010 sentence recovery. Modded profiles may change placement and release effects.
- **LAW-014-D03 — 2026-11-13.** Execution is unavailable in stock court. Explicit authored severe outcomes may invoke the approved character death flow. An imported DFU execution flag remains historical data and triggers no punishment on load.

## LAW-013 interview decisions

- **LAW-013-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-013 specification](systems/LAW/LAW-013.md) is finalized as v1, including plea modifiers before affordability, retained defense outcomes, acquittal disposition, sentence recovery, displayed acquittal chances, tender revalidation and settlement of zero-fine, zero-day guilty outcomes.
- **LAW-013-D01 — 2026-11-13.** Stock Guilty halves the retained ordinary fine and prison days, rounding down, before LAW-011 affordability conversion. Use the same final collection rules for either guilty outcome. Severe punishment is unchanged by the stock plea. Make plea adjustments moddable.
- **LAW-013-D02 — 2026-11-13.** Keep DFU Debate/Etiquette and Lie/Streetwise, the acquittal formula, one practice point for the chosen defense, and the second fine roll on ordinary conviction. Use case-captured pre-penalty standing and live skill and Personality at defense commitment. Retain results through retries and make the formula, practice and fine modifiers moddable.
- **LAW-013-D03 — 2026-11-13.** Acquittal closes the case and eligible companion charges, preserves current vitals, and imposes no fine, prison or standing change. Ordinary guilty outcomes qualify for one LAW-010 recovery after full sentence settlement, including fine-only sentences. Make these outcomes moddable through their owners.

## LAW-012 interview decisions

- **LAW-012-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-012 specification](systems/LAW/LAW-012.md) is finalized as v1, including automatic pre-plea rescue, charge disposition, preserved vitals, validated return placement, and configurable precedence for custom guild policies.
- **LAW-012-D01 — 2026-11-13.** Keep DFU's exact stock guild and charge eligibility lists and rank odds. Allow authored and modded policies, including custom guilds.
- **LAW-012-D02 — 2026-11-13.** Resolve one automatic rescue check before the plea, after the base punishment is calculated. Successful rescue takes effect automatically and bypasses ordinary and severe outcomes. Retain the result across retries. The user confirmed automatic acceptance with Draft v1 approval.
- **LAW-012-D03 — 2026-11-13.** Close the case and eligible companion charges under LAW-001. Stock rescue preserves current vitals and imposes no fine, prison, banishment or sentence recovery. Make rescue behavior moddable for custom guilds and other authored policies.

## LAW-011 interview decisions

- **LAW-011-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-011 specification](systems/LAW/LAW-011.md) is finalized as v1. Approval confirms the calculation, unpaid-fine conversion and pre-plea disclosure interpretations presented for review.
- **LAW-011-D01 — 2026-11-13.** Use the moddable DFU offense tables, severity odds and random allocation of 40 gold or three prison days per unit. Only negative standing increases ordinary penalties. Capture standing before the case's own penalty.
- **LAW-011-D02 — 2026-11-13.** Cap the fine at payable eligible funds and add one prison day per full 40 gold unpaid. Conversion is moddable. Final tender uses ITEM-009.
- **LAW-011-D03 — 2026-11-13.** Before the plea, show the selected charge, ordinary penalty ranges and whether severe punishment is possible. Resolve the exact base result once and retain it internally through retries.

## LAW-010 interview decisions

- **LAW-010-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-010 specification](systems/LAW/LAW-010.md) is finalized as v1, including penalties on guilty outcomes, partial recovery based on actual loss, calendar boundaries aligned with FACT-004, direct local faction recovery, and recovery of pending effects when a required faction mapping is missing.
- **LAW-010-D01 — 2026-11-13.** Apply the DFU offense loss once on a committed guilty plea or conviction. Stock uses the charge court resolves and routes half the listed loss, rounded down, through FACT-003 to the local people faction. Mods can define multi-charge aggregation.
- **LAW-010-D02 — 2026-11-13.** At sentence completion, recover half the actual legal loss for the case, rounded down, minus one and floored at zero. Recover half that legal recovery in the local people faction, rounded down and capped at its direct loss for the case. Make recovery moddable.
- **LAW-010-D03 — 2026-11-13.** Stock legal standing moves one point toward zero every 112 game days. Rest and travel count. Skip prison sentence time without catch-up. Clamp committed changes to −100 through +100. Schedule, step, bounds and regional exceptions are moddable. Warrants, charges and banishment retain their own lifecycle rules.

## LAW-009 interview decisions

- **LAW-009-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-009 specification](systems/LAW/LAW-009.md) is finalized as v1, including surrender thresholds, episode-scoped offer suppression, safe indoor and outdoor return placement, explicit spell policy, and retained-hit recovery when authorization expires or handoff fails.
- **LAW-009-D01 — 2026-11-13.** Authorized voluntary surrender accepts for a living player. Forced surrender uses enforcing-jurisdiction legal standing: 0% below −20, 50% from −20 through 0, and 100% above 0. Regional and modded policies can change the thresholds or disable either route. Showing the offer applies no standing penalty.
- **LAW-009-D02 — 2026-11-13.** Refusal or legitimate rejection suppresses further ordinary offers while the same local pursuit remains active, including brief loss of contact and changes in responding guards. A new authorized episode can offer again after LAW ends the prior pursuit.
- **LAW-009-D03 — 2026-11-13.** Prepare a safe return location in the arrest jurisdiction before committing court handoff. Indoor arrests default to a validated nearby exterior point, with authored alternatives. Technical preparation failure retains the arrest and hit for recovery. Only committed arrest changes health and discards the hit.

## LAW-008 interview decisions

- **LAW-008-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-008 specification](systems/LAW/LAW-008.md) is finalized as v1, including automatic Criminal Conspiracy filing, one pursuit opportunity when both checks pass in the same minute, watch and civilian recognition responses, issuing-jurisdiction authority, and destination-only stock fast-travel enforcement.
- **LAW-008-D01 — 2026-11-13.** Retain DFU-style automatic Criminal Conspiracy filing on a successful periodic pursuit check. Stock checks are 5% per eligible game minute for regional legal standing below −10 and 10% for banishment. Make the odds, trigger and charge policy moddable. Apply LAW-001 charge retention and selection.
- **LAW-008-D02 — 2026-11-13.** An eligible watch NPC who identifies the player can activate an immediate response. An eligible civilian who identifies and reports the player starts a moddable 5–10 active-second delay. Leaving the response area cancels the pending local dispatch while the underlying warrant or banishment remains enforceable.
- **LAW-008-D03 — 2026-11-13.** Stock pursuit eligibility resumes at the fast-travel destination, with route minutes skipped. Mods can enable route interception. The user confirmed this interpretation by approving Draft v1 after the approval request called out the travel rule.

## LAW-007 interview decisions

- **LAW-007-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-007 specification](systems/LAW/LAW-007.md) is finalized as v1, including a uniform stock batch size of two to five, admission at a responder count of five or fewer, active-response reuse, separately authorized reinforcements, safe partial deployment and placement recovery.
- **LAW-007-D01 — 2026-11-13.** Activate eligible nearby watch first. Use valid entrances or off-screen positions with an approach route for reinforcements. Civilian positions can guide placement while preserving the civilian and clear space. Placement is moddable.
- **LAW-007-D02 — 2026-11-13.** Use the looser DFU-style batch threshold with a stock response target of two to five. Existing responders count toward the threshold, and an admitted batch can exceed it. Response size, threshold and reinforcement rules are moddable.
- **LAW-007-D03 — 2026-11-13.** Deploy responders who can safely join and end the immediate request when no valid placement or route remains. Charges stay open for later enforcement. Stock dungeons exclude immediate city-watch deployment, with authored or regional exceptions.

## LAW-006 interview decisions

- **LAW-006-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-006 specification](systems/LAW/LAW-006.md) is finalized as v1, including camping warnings and enforcement interruption, overdue account collection, once-per-loan standing penalties independent of charge suppression, and recovery safeguards.
- **LAW-006-D01 — 2026-11-13.** Warn by default before restricted outdoor town sleep. Canceling has no legal consequence. Proceeding can file Vagrancy and request immediate authorized guards. Enforcement interrupts rest when it engages. Disabling warnings preserves the legal effect of the explicit rest action. Ordinary waiting and denied indoor rest carry no stock Vagrancy charge. Regional restrictions and response are moddable.
- **LAW-006-D02 — 2026-11-13.** Permit repayment through the exact due time. On the first eligible overdue check, collect available funds from the loan region's account up to the debt owed, then mark default if debt remains. Later eligible checks can collect newly available funds. Collection timing and sources are moddable.
- **LAW-006-D03 — 2026-11-13.** Apply −10 regional legal standing and −5 local people-faction reputation once per defaulted loan. Remaining debt stays payable. Default creates no active charge or immediate guard request. Later repayment leaves the standing changes to ordinary recovery. Mods can change the penalties or scale them by outstanding balance.

## LAW-005 interview decisions

- **LAW-005-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-005 specification](systems/LAW/LAW-005.md) is finalized as v1, including stock Assault and Murder filing, retention of a prior Assault charge after a qualifying later death, immediate authorized guard response, and self-defense evaluation at the causal action for delayed harm.
- **LAW-005-D01 — 2026-11-13.** Qualifying unauthorized hostile contact with a protected civilian or guard can establish Assault even at zero damage. A whiff or benign spell does not. Murder requires confirmed unlawful death attributable to the player, including eligible harmful spells or poison.
- **LAW-005-D02 — 2026-11-13.** Qualifying violence is immediately detected by default where local law applies. Detection and guard response are moddable.
- **LAW-005-D03 — 2026-11-13.** Self-defense applies when the victim initiated unlawful aggression and still poses a threat. Lawful guard pursuit and retaliation provoked by the player do not qualify. Regional policy is moddable.

## LAW-004 interview decisions

- **LAW-004-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-004 specification](systems/LAW/LAW-004.md) is finalized as v1, including household filing and guild credit on qualifying settled theft, one qualifying closed-shelf deed per source interaction, stock practice awards, inspection and interaction-end settlement rules, and recovery safeguards.
- **LAW-004-D01 — 2026-11-13.** Open-shop Steal checks a validated basket once before transfer. Detection blocks the transfer, files Theft where permitted and requests guards where authorized. An undetected committed theft earns one qualifying guild point. Response is moddable.
- **LAW-004-D02 — 2026-11-13.** Batch household theft detection for protected goods still taken when the interaction ends. Returning untouched goods to the source before settlement removes them from the basket. Using, consuming or moving the goods elsewhere settles theft before that action. Detection preserves completed transfers and uses separate recovery rules.
- **LAW-004-D03 — 2026-11-13.** Closed or unauthorized shop shelves have no stock random detection check. Make detection moddable and use committed quantities, including partial stacks, for guild credit. LAW-002 handles any entry offense separately.

## LAW-003 interview decisions

- **LAW-003-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-003 specification](systems/LAW/LAW-003.md) is finalized as v1, covering civilian detection and enforcement, declared enemy hostility, recruitment credit from committed theft, and recovery safeguards. The specification records remaining integration decisions.
- **LAW-003-D01 — 2026-11-13.** A detected townsperson failure immediately files Pickpocketing and requests guards where authorized. Filing and response policies are moddable. Unavailable guards do not invalidate a filed charge.
- **LAW-003-D02 — 2026-11-13.** Stock enemy failure invokes target and declared response-group hostility. A formal charge requires an explicit authored or modded rule.
- **LAW-003-D03 — 2026-11-13.** Award one stock Thieves Guild point on committed qualifying gold credit. Empty success and failure earn zero. Mods may count qualifying committed item theft once per deed.

## LAW-002 interview decisions

- **LAW-002-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-002 specification](systems/LAW/LAW-002.md) is finalized as v1. It covers offense classification, detection timing and odds, separate filing of established attempt and completion charges, and integration safeguards. The specification records the remaining access-link and other integration decisions.
- **LAW-002-D01 — 2026-11-13.** An unauthorized bash, pick or Open spell used to defeat a lock qualifies as attempted breaking and entering, even if it fails or entry never happens. Unauthorized crossing as part of that break-in qualifies as breaking and entering. Unauthorized crossing through an already open or unlocked route qualifies as trespass. Ordinary locked-door activation carries no charge. Filing depends on detection.
- **LAW-002-D02 — 2026-11-13.** Use DFU-style detection by default, with moddable odds and behavior.
- **LAW-002-D03 — 2026-11-13.** When both offenses are established and chargeable, retain separate attempted and completed breaking-and-entering charges. Stock court selects the worst eligible charge under LAW-001. Mods can use both charges.
- **LAW-002-D04 — 2026-11-13.** Use a moddable 10% detection chance when a failed bash against an unauthorized lock resolves and when an unauthorized bash-assisted break-in successfully enters. Greetings do not gate either check.
- **LAW-002-D05 — 2026-11-13.** Stock picking, Open and ordinary unlocked-route trespass report offense facts without a random guard check. Mods and authored locations can enable detection for these routes. Authored interior hostility can operate separately.

## LAW-001 interview decisions

- **LAW-001-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [LAW-001 specification](systems/LAW/LAW-001.md) is finalized as v1. It covers multiple charges, stock court selection and companion-charge disposition, jurisdictional retention, suppression, regional policy and persistence safeguards. The specification records the remaining LAW integration and content decisions.
- **LAW-001-D01 — 2026-11-13.** Track multiple charges. By default, court proceeds on the most serious eligible charge. Mods can replace the selection policy, including by bringing every eligible charge to court.
- **LAW-001-D02 — 2026-11-13.** Existing warrants or banishment may authorize pursuit in beast form when the applicable rule establishes the player's identity. Preserve existing charges and make the pursuit policy moddable.
- **LAW-001-D03 — 2026-11-13.** Scripted charges use ordinary LAW checks by default. Support an explicit authored exception to charge suppression, with moddable policy where possible.
- **LAW-001-D04 — 2026-11-13.** By default, unresolved charges remain in the filing jurisdiction after escape or travel. Departure can end immediate pursuit, and return can expose the player to enforcement again. Make this policy moddable.
- **LAW-001-D05 — 2026-11-13.** By default, lock the selected court charges at successful arrest commitment. Charges filed before commitment can affect selection. Make arrest and charge selection policy moddable, including regional policies with different charging rules or no surrender. This reaffirms D01.
- **LAW-001-D06 — 2026-11-13.** Once court resolves the case, close other eligible charges from that enforcement episode by default and retain their history. Charges from other episodes or jurisdictions remain open. Mods can change this disposition.
- **LAW-001-D07 — 2026-11-13.** Use an explicit moddable severity ranking with regional overrides. The earliest filed charge wins a severity tie.

## FACT-018 interview decisions

- **FACT-018-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-018 specification](systems/FACT/FACT-018.md) is finalized as v1, including validation of both membership sets, explicit recovery before reactivation, and initialization of new definitions only through a declared compatibility policy.
- **FACT-018-D01 — 2026-11-13.** Block unresolved required definitions or obligations absent a validated migration. Allow disclosed, accepted inactive recovery for explicitly optional memberships without outstanding obligations, preserving identity and history without benefits. User confirmed question 1 with “Yes”.
- **FACT-018-D02 — 2026-11-13.** Validate native state before replacement. Restore faction and membership progress and rebuild derived lookups and entitlements. Resume only unfinished work at its normal trigger without replaying gameplay effects during load. User confirmed question 2 with “Yes”.

## FACT-017 interview decisions

- **FACT-017-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-017 specification](systems/FACT/FACT-017.md) is finalized as v1, including durable claim history across rejoining and property sale, retained house selection during technical retry, and explicit rules for stacking waivers.
- **FACT-017-D01 — 2026-11-13.** Offer an explicit current-rank armor claim with three to six retained choices. Consume it only on delivery and grant no retroactive skipped-rank claims. User confirmed question 1 with “Yes”.
- **FACT-017-D02 — 2026-11-13.** Allow one rank 9 house claim per character and order, requiring no existing house and an eligible local property. Keep the claim open when none is available. Apply stock lodging and ship waivers automatically and recheck before commitment. User confirmed question 2 with “Yes”.

## FACT-016 interview decisions

- **FACT-016-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-016 specification](systems/FACT/FACT-016.md) is finalized as v1, including ceremonial stock donations, explicit priority for competing benefits, one settlement per modded donation, and no stock charge or cooldown for Stendarr prevention.
- **FACT-016-D01 — 2026-11-13.** Scope temple services to the exact deity and provider. Preserve moddable stock Akatosh travel, Kynareth breath, and Stendarr prevention away from temples. Allow distinct benefits to coexist and require explicit priority or authored stacking for competing benefits. User confirmed question 1 with “Yes”.
- **FACT-016-D02 — 2026-11-13.** Keep stock donations ceremonial and allow mods to attach effects. The user explicitly chose ceremonial stock donations.

## FACT-015 interview decisions

- **FACT-015-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-015 specification](systems/FACT/FACT-015.md) is finalized as v1, including fixing the quest gold bonus when the payable amount first settles, applying automatic magicka refill once per authorized service entry, and leaving minimum repair charges to the repair owner.
- **FACT-015-D01 — 2026-11-13.** Scope stock hall, rest, training and recharge benefits to the exact guild and authorized provider. Preserve service hours and rest safety. Allow explicit mod extensions to partner providers or locations. User confirmed question 1 with “Yes”.
- **FACT-015-D02 — 2026-11-13.** Preserve Fighters Guild rank-based repair and eligible generated gold adjustments. Show and revalidate repair discounts, settle quest adjustments once, and require an explicit rule for stacking. User confirmed question 2 with “Yes”.

## FACT-014 interview decisions

- **FACT-014-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-014 specification](systems/FACT/FACT-014.md) is finalized as v1, including variant override precedence, explicit unavailability for missing required routes, and consistent discovery and access checks across menus, shortcuts, and custom handlers.
- **FACT-014-D01 — 2026-11-13.** Show ordinary services offered by the representative with a reason when locked. Allow stock and modded services to explicitly hide their existence. User confirmed question 1 with “Yes”.
- **FACT-014-D02 — 2026-11-13.** Preserve moddable stock membership and actual-rank gates with custom guild and variant overrides. Revalidate exact access on opening and before commitment across menus, shortcuts, and custom callbacks. Require renewed acceptance for changed prices. User confirmed question 2 with “Yes”.

## FACT-013 interview decisions

- **FACT-013-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-013 specification](systems/FACT/FACT-013.md) is finalized as v1, including variant precedence for level substitution, standing lookup when required by a gate, and revalidation without a replacement draw.
- **FACT-013-D01 — 2026-11-13.** Preserve stock level substitution for eligible Mages Guild and knightly order rank checks. Make the policy moddable per guild or variant and allow actual-rank offer requirements. User confirmed question 1 with “Yes”.
- **FACT-013-D02 — 2026-11-13.** Support authored membership, rank, committed standing, and recorded outcome requirements. Resolve eligibility and consequence faction roles separately, revalidate at acceptance, and retain authorized faction binding once accepted. User confirmed question 2 with “Yes”.

## FACT-012 interview decisions

- **FACT-012-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-012 specification](systems/FACT/FACT-012.md) is finalized as v1, including separate recruitment progress per applicable membership set, one stock opportunity per guild and set, and retry on readiness changes or authorized recovery.
- **FACT-012-D01 — 2026-11-13.** Keep stock point weights, thresholds, and the three-day delay. Count qualifying successful deeds once and make deed types, weights, thresholds, and delay moddable. Failed theft and starting a theft attempt do not count. User confirmed question 1 with “Yes”.
- **FACT-012-D02 — 2026-11-13.** Deliver due contact at the next eligible outdoor opportunity, including after travel. Keep technical activation failures pending and grant membership once on authorized success. Stock refusal or failure closes recruitment, with explicit mod retry policies supported. User confirmed question 2 with “Yes”.

## FACT-011 interview decisions

- **FACT-011-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-011 specification](systems/FACT/FACT-011.md) is finalized as v1, including moddable rank requirements, review intervals, and expulsion or retention rules for stock and custom guilds.
- **FACT-011-D01 — 2026-11-13.** Use stock guild visit reviews after 28 days from joining or the last change, with DFU thresholds and multi-rank changes. The user approved on condition that rank requirements be moddable, especially for custom guilds.
- **FACT-011-D02 — 2026-11-13.** Stock ordinary failure at rank zero causes expulsion, while the Thieves Guild and Dark Brotherhood retain rank zero. The user approved on condition that expulsion rules be moddable.

## FACT-010 interview decisions

- **FACT-010-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-010 specification](systems/FACT/FACT-010.md) is finalized as v1, including confirmation-time revalidation, no stock rejoin cooldown, closing uncommitted prompts on reload, and protecting later memberships from old resignation requests.
- **FACT-010-D01 — 2026-11-13.** Preserve DFU ordinary admission thresholds as stock defaults with validated guild-specific policies. Revalidate at confirmation. Preserve rank and dates for an existing exact membership. Require separate resignation for a conflicting variant. User confirmed question 1 with “Yes”.
- **FACT-010-D02 — 2026-11-13.** Allow confirmed resignation through an authorized provider. End future member access while preserving standing and existing quest obligations under their owner rules. Require fresh eligibility for rank-zero rejoining and support authored exceptions such as cooldowns. User confirmed question 2 with “Yes”.

## FACT-009 interview decisions

- **FACT-009-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-009 specification](systems/FACT/FACT-009.md) is finalized as v1, including stock variant limits, exact provider resolution, separate ordinary and vampire membership sets where applicable, and legacy mapping through the import adapter.
- **FACT-009-D01 — 2026-11-13.** Limit stock membership to one deity and one knightly order per applicable set. Let validated mod policies allow multiple variants with independent membership and rank. User confirmed question 1 with “Yes”.
- **FACT-009-D02 — 2026-11-13.** Resolve the provider's exact guild and variant in the applicable membership set. Return the requested provider's nonmember context when the valid membership is absent. Missing or ambiguous required mappings make the interaction unavailable. User confirmed question 2 with “Yes”.

## FACT-008 interview decisions

- **FACT-008-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-008 specification](systems/FACT/FACT-008.md) is finalized as v1, including condition phase defaults and market recovery using retained political inputs before dependent political work resumes.
- **FACT-008-D01 — 2026-11-13.** Support DFU regional condition families and expose notable starts and ends through rumors and notices. Require an explicit owner rule for service restrictions or quest consequences. User confirmed question 1 with “Yes”.
- **FACT-008-D02 — 2026-11-13.** Run due politics against the last published price bands before the daily market step. Price with committed merchant and provincial power and feed the newly published bands to later political updates. User confirmed question 2 with “Yes”.

## FACT-007 interview decisions

- **FACT-007-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-007 specification](systems/FACT/FACT-007.md) is finalized as v1, including the stock power drift and succession formulas, war phases, a 95% battle opportunity for ongoing wars per due update, victory above twice opposing remaining effective strength, and no automatic winner power bonus.
- **FACT-007-D01 — 2026-11-13.** Run seven-day power and 38-day diplomacy and war updates at every crossed boundary, power first on ties. Keep power in 1–100 and ruler bonuses in 20–70. Evaluate each active war once per due update, subtract losses on both sides, and compare remaining effective strengths. User confirmed question 1 with “Yes”.
- **FACT-007-D02 — 2026-11-13.** Expose ruler succession, war declarations, and war outcomes through regional rumors and notices. Expose routine power changes only through explicit content. Let quests check current or recorded political facts and preserve accepted obligations unless an authored response applies. User confirmed question 2 with “Yes”.

## FACT-006 interview decisions

- **FACT-006-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-006 specification](systems/FACT/FACT-006.md) is finalized as v1. Approval includes rejecting native self-links and same-direction ally and enemy conflicts, treating repeated satisfied transitions as no-ops, and counting distinct shared allies and enemies for native political calculations.
- **FACT-006-D01 — 2026-11-13.** Preserve authored and imported one-way links. Commit ordinary simulated alliances and rivalries reciprocally, with no change if either endpoint lacks capacity. Keep ordered DFU slots where required and allow native policy limits. User confirmed question 1 with “Yes”.
- **FACT-006-D02 — 2026-11-13.** Track reciprocal war explicitly. Use bordering province rivalries for stock eligibility. Protect wartime hostility from ordinary expiry. At peace preserve independent rivalry and remove war-only hostility, with DFU-style removal of both enemy links available for compatibility. User confirmed question 2 with “Yes”.

## FACT-005 interview decisions

- **FACT-005-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-005 specification](systems/FACT/FACT-005.md) is finalized as v1. Approval includes separate opening and greeting lookups, explicit reaction predicates for quests, reconstruction of live modifiers without duplication, and distinct handling of optional absence and broken required references.
- **FACT-005-D01 — 2026-11-13.** Preserve DFU's opening reaction lookup using the first qualifying faction or root. Keep FACT-001's organization lookup separate for faction greetings. User confirmed question 1 with “Yes”.
- **FACT-005-D02 — 2026-11-13.** Ordinary quest reputation gates use committed standing. An explicit authored reaction condition can use the current impression. Rebuild live modifiers from restored effects without duplicate application. User confirmed question 2 with “Yes”.

## FACT-004 interview decisions

- **FACT-004-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-004 specification](systems/FACT/FACT-004.md) is finalized as v1. Approval includes processing each eligible boundary once, preserving skipped prison boundaries, and applying no extra steps on duplicate time updates, backward adjustments, or load.
- **FACT-004-D01 — 2026-11-13.** Move eligible positive and negative faction standing one point toward zero every 112 game days. Allow an explicit faction opt-out and keep authored starting values at character creation. User confirmed question 1 with “Yes”.
- **FACT-004-D02 — 2026-11-13.** Count each boundary after the start through the destination exactly once. Skip faction normalization during the prison sentence advance without catch-up. LAW owns the corresponding legal rules. User confirmed question 2 with “Yes”.

## FACT-003 interview decisions

- **FACT-003-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-003 specification](systems/FACT/FACT-003.md) is finalized as v1. Approval includes validating required routes before committing, notifying observers once per faction whose final standing changes, and retaining settled quest outcomes for retries.
- **FACT-003-D01 — 2026-11-13.** Default new and modded effects to direct standing and let authors explicitly select propagation. Preserve propagation intent and special routes for supported imported DFU effects. User confirmed question 1 with “Yes”.
- **FACT-003-D02 — 2026-11-13.** Preserve DFU write order and clamp each compatibility write. Sum signed contributions and clamp once per faction for new propagation policies. User confirmed question 2 with “Yes”.

## FACT-002 interview decisions

- **FACT-002-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-002 specification](systems/FACT/FACT-002.md) is finalized as v1, including capped standing, explicit missing-faction results, and settlement of valid zero-change quest consequences.
- **FACT-002-D01 — 2026-11-13.** Use shared integer standing from −100 through +100, with 0 as neutral. Initialize new characters from validated faction defaults and keep saved values for existing characters. User confirmed question 1 with “Yes”.
- **FACT-002-D02 — 2026-11-13.** Use signed changes for ordinary gameplay and absolute sets for explicitly authorized systems. Report previous value, new value, and actual change. Settle valid zero-change writes and notify standing observers only for a stored value change. User confirmed question 2 with “Yes”.

## FACT-001 interview decisions

- **FACT-001-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [FACT-001 specification](systems/FACT/FACT-001.md) is finalized as v1, including exactly one binding for each required regional role and DFU-style dialogue organization resolution using the nearest qualifying Group, Province, or Temple, with the root as fallback.
- **FACT-001-D01 — 2026-11-13.** Preserve DFU placed NPC faction defaults for classic imports. Let new and modded NPCs declare a faction, inherit an authorized building or regional role, or be unaffiliated. A broken explicit reference fails. User confirmed question 1 with “Yes”.
- **FACT-001-D02 — 2026-11-13.** Resolve the actor's faction and parent organization separately. Dialogue uses the organization where its rules call for it. Quests and services use the explicitly authorized faction. User confirmed question 2 with “Yes”.

## QUEST-023 interview decisions

- **QUEST-023-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [QUEST-023 specification](systems/QUEST/QUEST-023.md) is finalized as v1, including retained notice state, grouped fault reports and bounded, exportable traces independent of durable recovery records.
- **QUEST-023-D01 — 2026-11-13.** Show one technical recovery notice and persistent journal status with reason and supported actions. Keep authored failure distinct and surface pre-offer failures when they block progress or require action. User confirmed question 1 with “Yes”.
- **QUEST-023-D02 — 2026-11-13.** Provide searchable quest inspection, source and outcome tracing, and launch by quest ID in isolated in-world testing. User confirmed question 2 with “Yes”.
- **QUEST-023-D03 — 2026-11-13.** Persist the fault summary and recovery state. Keep bounded detailed traces with optional export and aggregate repeat reports. User confirmed question 3 with “Yes”.

## QUEST-022 interview decisions

- **QUEST-022-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [QUEST-022 specification](systems/QUEST/QUEST-022.md) is finalized as v1, including provenance for inactive optional records, session readiness before task dispatch, and session scope revalidation for deferred saves.
- **QUEST-022-D01 — 2026-11-13.** Require compatible versioned definitions and commands or validated migrations. Block incompatible required state and allow disclosed optional inactive recovery only when obligations can be preserved safely. User confirmed question 1 with “Yes”.
- **QUEST-022-D02 — 2026-11-13.** Rebuild authoritative state and required logical links before tasks run. Valid unloaded targets attach later. Removed targets require compatible mapping or explicit recovery. User confirmed question 2 with “Yes”.
- **QUEST-022-D03 — 2026-11-13.** Retain supported pending operations and committed progress. Resume only outstanding work and explain deferral when a coherent save must wait for a safe boundary. User confirmed question 3 with “Yes”.

## QUEST-021 interview decisions

- **QUEST-021-A01 — 2026-11-13.** The user approved Draft v1 with “I approve”. The [QUEST-021 specification](systems/QUEST/QUEST-021.md) is finalized as v1, including a broader repertoire of owner-supported operations, explicit exceptions and operation outcomes, and once-only training grants.
- **QUEST-021-D01 — 2026-11-13.** Support weather and cast checks, teleportation, scripted crime and training, and a broader repertoire of owner-supported quest operations. User confirmed question 1 and requested more options.
- **QUEST-021-D02 — 2026-11-13.** Require explicit owner-supported exceptions identifying which ordinary prerequisite changes. User confirmed question 2 with “Yes”.
- **QUEST-021-D03 — 2026-11-13.** Wait for the required owner outcome, use authored alternatives or recovery for failure, and commit training from a declared choice or trigger. User confirmed question 3 with “Yes”.

## QUEST-020 interview decisions

- **QUEST-020-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-020 specification](systems/QUEST/QUEST-020.md) is finalized as v1, including typed per-character flags, explicit repeatable-quest outcome selection, retention of linked outcomes through continuation, and validation of dynamic links before admission.
- **QUEST-020-D01 — 2026-11-12.** Allow committed outcomes and declared package-scoped story flags as quest dependencies. Keep local task state private and preserve mapped legacy globals. User confirmed question 1 with “Yes”.
- **QUEST-020-D02 — 2026-11-12.** Support independent follow-ups and linked children with authored continuation or authorized cancellation when the parent ends. Technical faults use recovery. User confirmed question 2 with “Yes”.
- **QUEST-020-D03 — 2026-11-12.** Reject circular waits and ungated automatic start loops. Permit authored repeats with fresh triggers or cooldowns, retain retry outcomes and respect one-time eligibility. User confirmed question 3 with “Yes”.

## QUEST-019 interview decisions

- **QUEST-019-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-019 specification](systems/QUEST/QUEST-019.md) is finalized as v1, including ordered reward bundles, independent commit records, and authorized claims for undelivered items.
- **QUEST-019-D01 — 2026-11-12.** Support multiple rewards in one quest branch, including multiple items and gold, with explicit costs, standing changes and guild membership effects. User confirmed question 1 and explicitly requested multiple rewards.
- **QUEST-019-D02 — 2026-11-12.** Declare standing targets and preserve supported legacy current-region behavior where needed. User confirmed question 2 with “Yes”.
- **QUEST-019-D03 — 2026-11-12.** Preserve exact undelivered items for authorized claim. Required delivery gates finalization, and authored claims may continue after the quest. Retry and reload retain settled effects. User confirmed question 3 with “Yes”.

## QUEST-018 interview decisions

- **QUEST-018-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-018 specification](systems/QUEST/QUEST-018.md) is finalized as v1, including enqueue order for independent prompt ties, once-per-quest presentation receipts after all required pages are shown, and committed update order for journal timestamp ties.
- **QUEST-018-D01 — 2026-11-12.** Queue blocking prompts in authored order, support passive notices and acknowledgments, and allow choice dismissal through authored cancellation or deferral. User confirmed question 1 with “Yes”.
- **QUEST-018-D02 — 2026-11-12.** Show current objectives and chronological earned updates, keep undisclosed branches hidden, and preserve outcome history. User confirmed question 2 with “Yes”.
- **QUEST-018-D03 — 2026-11-12.** Record once-per-quest display after successful presentation. Commit choices once after revalidation and restore supported prompts with stable variant and choice IDs. User confirmed question 3 with “Yes”.

## QUEST-017 interview decisions

- **QUEST-017-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-017 specification](systems/QUEST/QUEST-017.md) is finalized as v1, including committed outcome order for milestone ties and preservation of combat and loot outcomes independently of quest credit.
- **QUEST-017-D01 — 2026-11-12.** Retain deaths after quest binding, including before objective activation. Count each qualifying bound actor once and support authored milestone gates. User confirmed question 1 with “Yes”.
- **QUEST-017-D02 — 2026-11-12.** Support any confirmed death and player-credit conditions using combat attribution. Removal, escape and unloading do not count. User confirmed question 2 with “Yes”.
- **QUEST-017-D03 — 2026-11-12.** Retain the death and actual corpse link while needed. Settle required original drops before loot access and route later grants to the same corpse. Missing remains use authored alternatives or required recovery. User confirmed question 3 with “Yes”.

## QUEST-016 interview decisions

- **QUEST-016-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-016 specification](systems/QUEST/QUEST-016.md) is finalized as v1, including fresh review of stale selections, all-or-nothing full hand-ins across stacks, and qualification limited to the currently bound item for unique roles.
- **QUEST-016-D01 — 2026-11-12.** Default possession checks to carried and equipped items. Allow explicitly authored accessible wagon or storage scope. Keep checks read-only and revalidate at delivery. User confirmed question 1 with “Yes”.
- **QUEST-016-D02 — 2026-11-12.** Require the exact instance for linked objectives. Let players review and select qualifying ordinary units. Default to full delivery with authored partial delivery, and prevent duplicate transfer or consumption. User confirmed question 2 with “Yes”.
- **QUEST-016-D03 — 2026-11-12.** Distinguish recoverable custody from confirmed loss. Support authored recovery, replacement, alternate objectives or failure, and preserve unresolved items under ITEM-023. User confirmed question 3 with “Yes”.

## QUEST-015 interview decisions

- **QUEST-015-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-015 specification](systems/QUEST/QUEST-015.md) is finalized as v1, including validation of occupant disposition and required service bindings before replacement, and independent tracking of scoped quest restrictions.
- **QUEST-015-D01 — 2026-11-12.** Support explicit existing, selected, generated and replacement actor roles. Retain selected identity and declare original occupant and service disposition for replacement. User confirmed question 1 with “Yes”.
- **QUEST-015-D02 — 2026-11-12.** Scope reservations to the required interaction and use QUEST-009 choice routing for ambiguous competition. User confirmed question 2 with “Yes”.
- **QUEST-015-D03 — 2026-11-12.** Separate physical presence from dialogue availability. Retain unloaded bindings and use authored wait, alternatives or failure for genuine unavailability. Require explicit substitution and authorized disclosure updates. User confirmed question 3 with “Yes”.

## QUEST-014 interview decisions

- **QUEST-014-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-014 specification](systems/QUEST/QUEST-014.md) is finalized as v1, including nested containment, endpoint-based travel checks, and preservation of independent discoveries when temporary quest marks are removed.
- **QUEST-014-D01 — 2026-11-12.** Use authored destination scopes or type selectors. Any valid entrance qualifies unless the objective requires a particular entrance. User confirmed question 1 with “Yes”.
- **QUEST-014-D02 — 2026-11-12.** Separate presence, entry and exit. Require committed boundary crossings for entry and exit, including qualifying fast travel and teleportation. Reload and failed movement do not create entry. User confirmed question 2 with “Yes”.
- **QUEST-014-D03 — 2026-11-12.** Support hidden destinations and authored disclosure ranging from hints to exact marks. Commit reveals once and preserve earned discoveries by default, with explicitly temporary marks eligible for cleanup. User confirmed question 3 with “Yes”.

## QUEST-013 interview decisions

- **QUEST-013-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-013 specification](systems/QUEST/QUEST-013.md) is finalized as v1, including bounded markerless area placement and exclusive enemy-slot replacement that preserves resolved defeat and custody state.
- **QUEST-013-D01 — 2026-11-12.** Try the authored marker first, then explicitly permitted alternatives within the declared area. Default to one claim per marker with authored capacity or sharing. User confirmed question 1 with “Yes”.
- **QUEST-013-D02 — 2026-11-12.** Secure and validate new placement before releasing the old binding. Preserve resource identity and avoid duplicate appearances. User confirmed question 2 with “Yes”.
- **QUEST-013-D03 — 2026-11-12.** Persist stable scoped links, defer scene attachment while unloaded and use explicit mappings or recovery for incompatible layouts. User confirmed question 3 with “Yes”.
- **QUEST-013-D04 — 2026-11-12.** Support markerless objectives in custom or generic sites, including authored replacement of a dungeon enemy with a quest enemy.

## QUEST-012 interview decisions

- **QUEST-012-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-012 specification](systems/QUEST/QUEST-012.md) is finalized as v1, including uniform native random selection, a distinct search-limit outcome, and provisional claim revalidation before publication.
- **QUEST-012-D01 — 2026-11-12.** Use the authorized selection origin. Default NPC-local selection to the issuing settlement and remote selection to another location in the issuing region. Support explicit cross-region quests, stable fixed destinations, and retained settled selections. User confirmed question 1 and emphasized destinations outside the acquisition region.
- **QUEST-012-D02 — 2026-11-12.** Use explicit ordered fallback tiers. Preserve supported DFU fallback behavior where mapped. User confirmed question 2 with “Yes”.
- **QUEST-012-D03 — 2026-11-12.** Allow site sharing by default while honoring explicit exclusivity and required placement capacity. Exact marker conflicts belong to QUEST-013. User confirmed question 3 with “Yes”.

## QUEST-011 interview decisions

- **QUEST-011-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-011 specification](systems/QUEST/QUEST-011.md) is finalized as v1, including closing ordinary objectives during finalization, retaining a compact runtime record where needed, and preserving committed outcomes when cleanup faults.
- **QUEST-011-D01 — 2026-11-12.** Retain final status, authored summary and earned journal entries after runtime cleanup. Follow-up greetings and rumors retain their own policies. User confirmed question 1 with “Yes”.
- **QUEST-011-D02 — 2026-11-12.** Finish required authored closing work before committing one outcome. Retire active interactions and resume only outstanding owner cleanup. Preserve supported imported ending delays where needed. User confirmed question 2 with “Yes”.
- **QUEST-011-D03 — 2026-11-12.** Suspend technically faulted quests, preserve committed progress and resume through supported recovery. Permit ordinary abandonment where authorized and retain protected story quests for recovery. User confirmed question 3 with “Yes”.

## QUEST-010 interview decisions

- **QUEST-010-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-010 specification](systems/QUEST/QUEST-010.md) is finalized as v1, including authored late outcomes, the travel duration formula, stopped-clock display and recurring catch-up rules for missed occurrences, overflow and exact landing.
- **QUEST-010-D01 — 2026-11-12.** Use committed in-world time including travel, rest and jail. Expiry wins over uncommitted on-time hand-in at the exact deadline. Reconcile crossed expiry once before further player action. User confirmed question 1 with “Yes”.
- **QUEST-010-D02 — 2026-11-12.** Evaluate daily availability at destination time. Default recurring events to one catch-up execution, with authored skip and bounded chronological replay options. User confirmed question 2 with “Yes”.
- **QUEST-010-D03 — 2026-11-12.** Resolve travel-based duration once at clock start from route, estimate, multiplier and minimum allowance. Preserve it across route changes and load. Show due time and countdown for visible deadlines and allow hidden clocks. User confirmed question 3 with “Yes”.
- **QUEST-010-D04 — 2026-11-12.** Let authors define alternative outcomes for missed deadlines, including branches that keep the quest playable.

## QUEST-009 interview decisions

- **QUEST-009-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-009 specification](systems/QUEST/QUEST-009.md) is finalized as v1, including the initially false baseline for native rising-edge triggers, retained interaction claims across interruptions, and no competing task dispatch when the player closes the choice without selecting one.
- **QUEST-009-D01 — 2026-11-12.** Preserve supported DFU authored ordering, always-on trigger behavior and the post-action `PersistUntil` stop check for imports. Declare trigger modes explicitly for native quests. User confirmed question 1 with “Yes”.
- **QUEST-009-D02 — 2026-11-12.** Give the first eligible consuming task the authorized interaction, allow explicit observers, and offer a choice when competing quests have no clear owner. User confirmed question 2 with “Yes”.
- **QUEST-009-D03 — 2026-11-12.** Allow authored reset, a fresh qualifying event or declared recurrence to start another run. Persist trigger state and committed effects across duplicate delivery, interruption and load. User confirmed question 3 with “Yes”.

## QUEST-008 interview decisions

- **QUEST-008-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-008 specification](systems/QUEST/QUEST-008.md) is finalized as v1, including a fixed queue batch at phase entry, independent ready requests proceeding past readiness waits, and quest age measured from committed activation.
- **QUEST-008-D01 — 2026-11-12.** Capture and revalidate explicit giver and faction context. Commit active quest state, required logical bindings and applicable one-time history before notification. Support valid unloaded bindings and authored giverless starts. User confirmed question 1 with “Yes”.
- **QUEST-008-D02 — 2026-11-12.** Drain scheduled starts in request order at the next eligible quest tick before active updates. Starts requested by tasks wait for the next eligible tick. Immediate starts outside task processing can commit before the next eligible update. User confirmed question 2 with “Yes”.
- **QUEST-008-D03 — 2026-11-12.** Persist supported pending starts with stable identity and original context. Revalidate at activation, support declared readiness waits, preserve one-time eligibility on failure and reuse recorded outcomes on duplicate delivery. User confirmed question 3 with “Yes”.

## QUEST-007 interview decisions

- **QUEST-007-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-007 specification](systems/QUEST/QUEST-007.md) is finalized as v1, including stable quest-scoped message and variant IDs, historical journal facts with readable fallback, and author previews with supplied or fixture context.
- **QUEST-007-D01 — 2026-11-12.** Allow natural rephrasing and placeholder reordering while preserving required details, choice IDs and bound resources. Fall back for an unusable message or missing selected variant. User confirmed question 1 with “Yes”.
- **QUEST-007-D02 — 2026-11-12.** Retranslate journal entries with compatible templates and historical facts. Show retained readable text when retranslation is unavailable. User confirmed question 2 with “Yes”.
- **QUEST-007-D03 — 2026-11-12.** Extend author testing with locale previews, fallback and placeholder or variant diagnostics, and intended dialogue reveals. User confirmed question 3 with “Yes”.

## QUEST-006 interview decisions

- **QUEST-006-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-006 specification](systems/QUEST/QUEST-006.md) is finalized as v1, including positive whole-number quantities, mixed qualifying variants for generic objectives, and separate quantity checks and hand-in operations.
- **QUEST-006-D01 — 2026-11-12.** Allow package-qualified command additions in the initial contract. Use explicit native command IDs and report unresolved legacy ambiguity. User confirmed question 1 with “Yes”.
- **QUEST-006-D02 — 2026-11-12.** Require typed arguments and references, a declared condition or operation role, side-effect-free validation, owner-routed gameplay changes, and command/provider diagnostics. User confirmed question 2 with “Yes”.
- **QUEST-006-D03 — 2026-11-12.** Save stable command identity and compatibility versions. Use a compatible provider or explicit migration, otherwise apply SAVE recovery. User confirmed question 3 with “Yes”.
- **QUEST-006-D04 — 2026-11-12.** Support exact and generic item quantity objectives, multiple valid solutions, and authored failure where qualifying items cannot be obtained in the quest instance.

## QUEST-005 interview decisions

- **QUEST-005-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-005 specification](systems/QUEST/QUEST-005.md) is finalized as v1, including preservation of meaningful source order and testing specific modded quests in the game world through shared validation and runtime paths with isolated gameplay changes.
- **QUEST-005-D01 — 2026-11-12.** Support DFU quest text import and a versioned native format using the same validated definition model. User confirmed question 1 with “Yes”.
- **QUEST-005-D02 — 2026-11-12.** Block malformed declarations, conflicting IDs, and missing or mistyped required references. Require explicit optional behavior and report independent errors with source context where practical. User confirmed question 2 with “Yes”.
- **QUEST-005-D03 — 2026-11-12.** Validate declarations and fixed references up front. Resolve world-dependent choices at generation. Keep metadata inspection free of gameplay randomness and independent of usability certification. User confirmed question 3 with “Yes”.
- **QUEST-005-D04 — 2026-11-12.** Make it easy to debug and test specific modded quests in the actual game environment. An external tool or a workflow within the modding system are possible.

## QUEST-004 interview decisions

- **QUEST-004-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-004 specification](systems/QUEST/QUEST-004.md) is finalized as v1, including definition-level one-time policy, duplicate startup definition rejection, deterministic ordering of independent entries and requiredness handling for blocked dependencies.
- **QUEST-004-D01 — 2026-11-12.** Consume a one-time quest per character and stable definition ID when acceptance and activation commit successfully. Decline, closure and failed activation do not consume it. Later completion, failure and abandonment preserve consumption. User confirmed question 1 with “Yes”.
- **QUEST-004-D02 — 2026-11-12.** Successful automatic activation uses the same one-time history. Failed automatic starts and repeatable quests do not consume one-time eligibility. User confirmed question 2 with “Yes”.
- **QUEST-004-D03 — 2026-11-12.** Support stable startup registrations, declared dependencies and deterministic ordering. Additional registrations default to optional and may explicitly be required, with required failures using CORE safe-entry recovery. User confirmed question 3 with “Yes”.

## QUEST-003 interview decisions

- **QUEST-003-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-003 specification](systems/QUEST/QUEST-003.md) is finalized as v1, including inclusive signed reputation bounds, explicit player choice before substitution after a picker failure, and retained request outcomes across duplicate calls.
- **QUEST-003-D01 — 2026-11-12.** Preserve stock social level-or-reputation checks and giver restrictions through explicit moddable requirements. Use the dedicated mature quest content setting. User confirmed question 1 with “Yes”.
- **QUEST-003-D02 — 2026-11-12.** Default to one random offer from the distinct eligible pool. Allow mods to change selection and presentation for debugging or authored use. User confirmed question 2 with this extension.
- **QUEST-003-D03 — 2026-11-12.** Default to bounded fallback for recoverable world-dependent generation failures before settlement and before effects commit. Allow mods to change the policy, including a single-attempt option. User confirmed question 3 with this extension.
- **QUEST-003-D04 — 2026-11-12.** Allow negative reputation requirements to support quests for characters in bad standing, such as redemption work.

## QUEST-002 interview decisions

- **QUEST-002-A01 — 2026-11-12.** The user approved Draft v1 with “I approve”. The [QUEST-002 specification](systems/QUEST/QUEST-002.md) is finalized as v1, including uniform selection across distinct eligible quests and revalidation at consequential choice.
- **QUEST-002-D01 — 2026-11-12.** Preserve DFU stock guild eligibility with typed rank and reputation requirements, the zero-requirement nonmember exception, Holy Order general and deity-specific work, and authorized level substitution. User confirmed question 1 with “Yes”.
- **QUEST-002-D02 — 2026-11-12.** Default to random assignment. Offer an optional picker limited to eligible quests, with general guidance when no work qualifies. User confirmed question 2 with “Yes”.
- **QUEST-002-D03 — 2026-11-12.** Use a dedicated mature quest content setting independent of visual nudity. User confirmed question 3 with “Yes”.

## QUEST-001 interview decisions

- **QUEST-001-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [QUEST-001 specification](systems/QUEST/QUEST-001.md) is finalized as v1, including list-scoped entry IDs and per-entry eligibility checks before pool deduplication.
- **QUEST-001-D01 — 2026-11-11.** Support explicit additions, patches, and removals by stable entry ID, plus whole-list replacement. User confirmed question 1 with “Yes”.
- **QUEST-001-D02 — 2026-11-11.** Give each eligible quest one chance in the combined pool when applicable lists overlap. User confirmed question 2 with “Yes”.

## NPC-024 interview decisions

- **NPC-024-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-024 specification](systems/NPC/NPC-024.md) is finalized as v1, including dependency-ordered restoration, provenance for inactive optional records, and feedback and recovery for deferred saves.
- **NPC-024-D01 — 2026-11-11.** Missing required actors need explicit migration or supported recovery, otherwise load fails with an explanation. Optional unresolved records can be retained for possible recovery. Valid unloaded actors retain their references until their area is ready.
- **NPC-024-D02 — 2026-11-11.** Restore approved AI history and remaining timers. Rebuild routes and current perception. An enemy can resume searching from a historical clue. Unfinished attacks follow the approved combat load rules.
- **NPC-024-D03 — 2026-11-11.** Save settled NPC outcomes and supported outstanding steps. If no coherent save boundary is available yet, defer the save until a safe point. Restore only outstanding work.

## NPC-023 interview decisions

- **NPC-023-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-023 specification](systems/NPC/NPC-023.md) is finalized as v1, including ordinary eligibility precedence, settlement-scoped work visits and successful presentation as the one-shot offer boundary.
- **NPC-023-D01 — 2026-11-11.** Bind ordinary personal work to the stable actor ID. Explicitly authored organization or establishment offers can use authorized providers and remain with their owner when staff change.
- **NPC-023-D02 — 2026-11-11.** Keep moddable 25% ordinary and castle eligibility checks with stable results during a settlement visit. Building transitions and reload preserve the pool. Leaving and returning to the settlement allows a fresh pool.
- **NPC-023-D03 — 2026-11-11.** Default to a DFU-style one-shot offer. Quests and mods can explicitly let players defer a choice and return to the same pending offer.

## NPC-022 interview decisions

- **NPC-022-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-022 specification](systems/NPC/NPC-022.md) is finalized as v1, including successful presentation as the commit boundary for clue reveals and greeting consumption, and committed outcome order for timestamp ties.
- **NPC-022-D01 — 2026-11-11.** Authored quest events and clues shown to the player can unlock linked topics. Showing the clue unlocks it by default without a separate click. Mods can require acknowledgment or explicit activation.
- **NPC-022-D02 — 2026-11-11.** Retire active quest topics and clues when their quest or offer ends. Preserve legitimate journal entries and discoveries subject to explicit temporary-record rules. Mods can keep selected topics askable.
- **NPC-022-D03 — 2026-11-11.** Show an authored success or failure greeting once on the next eligible conversation. If multiple outcomes are pending for a questor, show the latest first and retain older ones for later conversations. Mods can change repetition, expiry and follow-up presentation.

## NPC-021 interview decisions

- **NPC-021-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-021 specification](systems/NPC/NPC-021.md) is finalized as v1, including stock 75% flagged-faction suppression for applicable spoken rumors, stable first-eligible board ordering, and a no-news response when a settled rumor becomes ineligible during dialogue.
- **NPC-021-D01 — 2026-11-11.** Default spoken rumor weights are 50 per eligible quest entry and 1 per eligible ambient entry. Weights and channel, region, faction and quest eligibility are moddable.
- **NPC-021-D02 — 2026-11-11.** Keep a board notice stable until expiry, withdrawal or an authorized replacement. Mods can enable scheduled rotation.
- **NPC-021-D03 — 2026-11-11.** Permit repeats across genuine conversations. Within a conversation, reuse the settled news answer subject to NPC-019's allowance. Repeats give no additional discovery or quest progress.

## NPC-020 interview decisions

- **NPC-020-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-020 specification](systems/NPC/NPC-020.md) is finalized as v1, including retained outcomes across indoor and outdoor changes, random stock selection over eligible regional service records, and subject-scoped map discovery.
- **NPC-020-D01 — 2026-11-11.** Default to a moddable 35% exact local map mark chance for eligible outdoor building hints, directions indoors, and an already-here answer when appropriate. Quest disclosure can explicitly require a hint or authorize an exact mark.
- **NPC-020-D02 — 2026-11-11.** Retain a speaker's hint-versus-mark result for the same subject while relevant facts stay the same. Another knowledgeable speaker may provide a better answer.
- **NPC-020-D03 — 2026-11-11.** Use a matching settlement for ordinary regional service directions. Support moddable regional selection, including choosing the closest eligible settlement. Draft approval confirmed DFU-style random regional selection and settlement-level disclosure by default, with exact pins from local answers or explicit disclosure policy.

## NPC-019 interview decisions

- **NPC-019-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-019 specification](systems/NPC/NPC-019.md) is finalized as v1, including retention of the original knowledge draw during reevaluation and preservation of the ordinary answer allowance when an exempt answer is given.
- **NPC-019-D01 — 2026-11-11.** Use moddable DFU-style topic categories with general questions, relevant local subjects and quest-authorized subjects. Visible questions can receive unknown answers. Disambiguate duplicate names with context.
- **NPC-019-D02 — 2026-11-11.** Use DFU question and group knowledge tables with stable knowledge per actor and topic across conversations and reload. Relevant world or quest changes can change knowledge. Knowledge policy is moddable.
- **NPC-019-D03 — 2026-11-11.** Default to one useful Tell Me About or rumor answer per conversation, shared between those categories, with applicable exceptions including spymasters and same-building knowledge. Unknown or unhelpful answers do not consume it. Reset on a genuine new conversation. The limit and exceptions are moddable.

## NPC-018 interview decisions

- **NPC-018-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-018 specification](systems/NPC/NPC-018.md) is finalized as v1, including one retained skill roll per linked tone per conversation, stable actor-specific response thresholds, and practice for each eligible option, including permitted repeat questions.
- **NPC-018-D01 — 2026-11-11.** Keep moddable DFU-style reputation-based reception and separate Personality, Etiquette and Streetwise answer reactions. An authored quest greeting takes priority after admission, and an explicit quest exception may admit dialogue despite ordinary refusal.
- **NPC-018-D02 — 2026-11-11.** Retain temporary refusal by actor until a relevant reputation or quest change or one game day passes. Persistent low-reputation refusal continues while its predicate remains true.
- **NPC-018-D03 — 2026-11-11.** Award a moddable practice tally for each eligible dialogue option used in its skill-linked tone. Practice cadence and tone roll cadence are separate.

## NPC-017 interview decisions

- **NPC-017-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-017 specification](systems/NPC/NPC-017.md) is finalized as v1, including regional People faction context for ordinary wandering civilians and session and actor revalidation before consequential choices.
- **NPC-017-D01 — 2026-11-11.** Reset question count, selection and answer allowance on a new conversation. Retain actor knowledge and applicable refusal state by actor across intervening conversations. NPC-018 owns refusal recovery.
- **NPC-017-D02 — 2026-11-11.** Validate reach and obstruction on entry. Ordinary dialogue pauses gameplay by default, with mod support for non-pausing dialogue. Hold wandering speakers during dialogue, tolerate small positional changes and end when the actor or context becomes invalid.
- **NPC-017-D03 — 2026-11-11.** Load ordinary gameplay without reopening ordinary dialogue. Preserve durable quest choices, learned facts and committed practice.

## NPC-016 interview decisions

- **NPC-016-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-016 specification](systems/NPC/NPC-016.md) is finalized as v1, including stock self-heal and self-buff eligibility, uniform selection within viable spell categories, and release-time ally obstruction checks.
- **NPC-016-D01 — 2026-11-11.** Prefer a viable bow, then a viable ranged spell, then eligible close-range action or repositioning. An unsuccessful start roll does not try another attack in the same opportunity. Preferences are moddable.
- **NPC-016-D02 — 2026-11-11.** Check affordability and useful applicability for stock ranged, touch and close-area spells. Skip spells with no remaining useful effect. Include purposeful self-healing and self-buffing in stock AI, interpreting the user's “Yes” as answering the direct question about stock self-casts.
- **NPC-016-D03 — 2026-11-11.** Withhold shots when a visible ally blocks the predicted path. Enhanced Combat AI can use bounded lead from valid observations. Released shots can hit allies under approved delivery rules. Aim and risk policies are moddable.

## NPC-015 interview decisions

- **NPC-015-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-015 specification](systems/NPC/NPC-015.md) is finalized as v1, including retained tactical choices through technical retry, movement step revalidation and fresh maneuver selection on reload.
- **NPC-015-D01 — 2026-11-11.** Enhanced Combat AI is on by default. Use DFU-style enhanced melee positioning and support moddable tactics. Classic close-and-face positioning applies with the setting off.
- **NPC-015-D02 — 2026-11-11.** Keep DFU-style moving swings. Attack profiles may hold voluntary movement or permit reduced movement. The behavior is moddable.
- **NPC-015-D03 — 2026-11-11.** Pause suspends the maneuver. Paralysis and knockback discard the voluntary maneuver. When movement returns, reassess from the actual position.

## NPC-014 interview decisions

- **NPC-014-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-014 specification](systems/NPC/NPC-014.md) is finalized as v1, including stock enhanced bashing independent of the prediction setting and safe clearance checks before changing traversal shape.
- **NPC-014-D01 — 2026-11-11.** Use DFU Enhanced Combat AI's pursuit-driven door bashing as the default behavior for stock enemies that can bash. Opening and bashing capabilities and behavior are moddable.
- **NPC-014-D02 — 2026-11-11.** Retry eligible bashes at the approved melee cadence while pursuing through a useful route. Default to no separate retry cap. Mods may impose one. When pursuit or door eligibility ends, detour or stop as appropriate.
- **NPC-014-D03 — 2026-11-11.** Keep DFU-style automatic temporary clearance adjustment for tall enemies. Make the behavior moddable so very large enemies can be stopped by small openings.

## NPC-013 interview decisions

- **NPC-013-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-013 specification](systems/NPC/NPC-013.md) is finalized as v1, including common ground checks across shorelines, route segment revalidation, and route reconstruction on load.
- **NPC-013-D01 — 2026-11-11.** Default to direct pursuit, bounded local detours, and waiting and retrying from reachable space. Use NPC-011's timeout after contact loss. Mods can supply more complex pathfinding.
- **NPC-013-D02 — 2026-11-11.** Default enemies have no breath mechanic. Nonaquatic ground enemies can walk along submerged floors without vertical swimming. Aquatic enemies stay in water by default. Mods can enable land movement for aquatic enemies, swimming for other enemies, wall climbing, breath mechanics and other supported movement capabilities.
- **NPC-013-D03 — 2026-11-11.** Use DFU-style physical traversability and unsafe-drop checks by default. Resolve hazard effects on contact. Allow mods to add hazard-aware route policies.

## NPC-012 interview decisions

- **NPC-012-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-012 specification](systems/NPC/NPC-012.md) is finalized as v1, including current ally membership, reciprocal proactive targeting restrictions and an ally-only exception for qualifying ally hostility.
- **NPC-012-D01 — 2026-11-11.** Successful language pacification lasts and covers the player and eligible player allies. Use the agreed qualifying hostile-action break rule. Player companions are a future mod use case, outside this feature's base gameplay scope.
- **NPC-012-D02 — 2026-11-11.** Resolve first-detection language pacification before a new attack or the observer's initial dungeon alert contribution. Success prevents that contribution and preserves alert from other observers.
- **NPC-012-D03 — 2026-11-11.** Default to success feedback naming the enemy and skill when the enemy is identifiable. Use generic success feedback otherwise and keep failures silent. Mods can disable or replace feedback.

## NPC-011 interview decisions

- **NPC-011-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-011 specification](systems/NPC/NPC-011.md) is finalized as v1, including accepted visual contact as the alert trigger, expiry after more than 480 game minutes, and retention of unexpired contributions across streaming and dungeon re-entry.
- **NPC-011-D01 — 2026-11-11.** Default to a moddable 12.5 active seconds of pursuit after last accepted contact. Search the last sighting or a newer approximate hearing clue. Preserve the fact of a prior player encounter for the enemy's lifetime, including reload, independently of location memory.
- **NPC-011-D02 — 2026-11-11.** Enhanced Combat AI enables DFU-style intercept prediction from consecutive accepted visual samples. Allow a brief bounded projection after loss of sight, then fall back to retained observations. Prediction is moddable.
- **NPC-011-D03 — 2026-11-11.** Track dungeon alert by contributing enemy within the area, with a moddable eight-game-hour decay. Defeating the final contributor clears alert immediately. Defeating one of several preserves the others' alert.

## NPC-010 interview decisions

- **NPC-010-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-010 specification](systems/NPC/NPC-010.md) is finalized as v1, including illusion rolls gated by a usable opportunity, fallback clue precision, and retention of check and practice windows on reload.
- **NPC-010-D01 — 2026-11-11.** Keep DFU-style Stealth checks by game minute, with checks below half speed on even minutes. At half speed or faster, prior encounter permits a Stealth-roll bypass when an eligible observation exists. Solid cover prevents the shortcut from tracking through a wall. Timing and speed thresholds are moddable.
- **NPC-010-D02 — 2026-11-11.** Keep DFU's nominal 62.5 ms illusion check interval by default, with moddable timing.
- **NPC-010-D03 — 2026-11-11.** Award one Stealth practice use per game minute across observers when an actual player Stealth roll resolves, regardless of outcome. Reused results, illusion-only checks and movement bypasses award no use. Amount and cadence are moddable.

## NPC-009 interview decisions

- **NPC-009-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-009 specification](systems/NPC/NPC-009.md) is finalized as v1, including timestamped hearing search areas and use of the effective sight range for the full sight check.
- **NPC-009-D01 — 2026-11-11.** Use DFU-style range and sight cone with a default 180-degree field of view. Geometry and closed solid doors occlude sight. Enemy sight range and cone are moddable.
- **NPC-009-D02 — 2026-11-11.** Ordinary hearing can maintain contact after sight is lost, can pass through ordinary doors, and is blocked by solid walls. Hearing gives an approximate location to investigate.
- **NPC-009-D03 — 2026-11-11.** Keep DFU's default hearing eligibility. Ordinary hearing, including loud actions, cannot acquire an undetected target. Mods can enable first detection by noise or add alternate senses with declared precision.

## NPC-008 interview decisions

- **NPC-008-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-008 specification](systems/NPC/NPC-008.md) is finalized as v1, including current-target preference on score ties, reciprocal response eligibility checks and reevaluation on infighting setting changes.
- **NPC-008-D01 — 2026-11-11.** Provide a player-facing enemy infighting setting, off by default. When enabled, use DFU-style eligibility between different teams, subject to actor and quest restrictions. The policy is moddable.
- **NPC-008-D02 — 2026-11-11.** Use DFU-style target scoring and periodic reassessment by default. Mods can change target selection behavior.
- **NPC-008-D03 — 2026-11-11.** An accepted hostile hit can prompt local investigation or retaliation. A hidden attacker supplies a clue and still has to be located through perception. A single friendly-fire hit does not automatically end an alliance or turn a team hostile. Retaliation is moddable.

## NPC-007 interview decisions

- **NPC-007-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-007 specification](systems/NPC/NPC-007.md) is finalized as v1, including capacity usage across streaming, final placement revalidation and count reconstruction on reload.
- **NPC-007-D01 — 2026-11-11.** Ambient placement uses a moddable distance band per context, valid space for the foe's movement type, body clearance, and a position outside the player's view or behind solid cover. During the resting presentation, allow placement in any direction while retaining distance, clearance and movement-space requirements.
- **NPC-007-D02 — 2026-11-11.** Try the authored marker first for scripted spawns. Use nearby fallback only when the script explicitly permits it within the same room or designated area. Report failure to the script owner if no valid position exists.
- **NPC-007-D03 — 2026-11-11.** Default to a moddable cap of three living ambient foes in the same encounter area, including offscreen foes. Suspend new ambient checks at capacity. Authored and quest foes follow their own limits.

## NPC-006 interview decisions

- **NPC-006-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-006 specification](systems/NPC/NPC-006.md) is finalized as v1, including a shared context snapshot, closure when no foe is eligible, stopping checks for the elapsed-time batch after request acceptance, and allowing rest to continue while placement is pending.
- **NPC-006-D01 — 2026-11-11.** Keep DFU's clustered schedule by default, with moddable timing. Process eligible minutes during play and supported rest or loitering. Suppressed time skips leave no backlog.
- **NPC-006-D02 — 2026-11-11.** Default contexts are location-area night, wilderness day or night, and alerted dungeon rest. Suppress checks while swimming or aboard ship. A passed gate selects one foe using the applicable stock table and DFU-style level selection. Tables and eligibility are moddable.
- **NPC-006-D03 — 2026-11-11.** Allow one pending ambient request per current area by default. Retry the same selected foe within a bounded placement budget while context remains valid. Discard exhausted or stale requests and wait for a new opportunity.

## NPC-005 interview decisions

- **NPC-005-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-005 specification](systems/NPC/NPC-005.md) is finalized as v1, including stock caster skill and magicka defaults, retained construction results, and distinct handling for missing required and optional entries.
- **NPC-005-D01 — 2026-11-11.** Default to authored monster levels, class enemies matched to player level at fresh creation, and an inclusive 3–6 level bonus for stock city watch combatants. Existing enemies retain their assigned level. Mods can define fixed levels, ranges or bounded scaling.
- **NPC-005-D02 — 2026-11-11.** Stock generated equipment uses player level as its starting input. Support moddable alternatives based on enemy level or fixed gear.
- **NPC-005-D03 — 2026-11-11.** Use DFU level-based baseline skills and stock spell lists or tiers with explicit archetype overrides. Initial reaction, team and spell list are independently configurable.

## NPC-004 interview decisions

- **NPC-004-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-004 specification](systems/NPC/NPC-004.md) is finalized as v1, including independent actor-owned services, explicit key migrations and recovery for unresolved bindings.
- **NPC-004-D01 — 2026-11-11.** Use a stable authored identity for each placed NPC across reload, reconstruction and deliberate relocation. Reused layouts have distinct occupants. Mods can explicitly move the existing person or replace them with a new identity.
- **NPC-004-D02 — 2026-11-11.** Personal facts and quest links follow the actor. Establishment stock and ongoing service obligations stay with the establishment by default. Explicitly authorized staff can provide the service. Support modded actor-owned services and stock for independent NPCs, including providers in inns or outdoors without faction affiliation. The storage mechanism remains an implementation choice.
- **NPC-004-D03 — 2026-11-11.** Explain temporary service unavailability for an approachable provider. Allow ordinary conversation when eligible. An absent provider leaves the service unavailable until an authorized provider is available.

## NPC-003 interview decisions

- **NPC-003-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-003 specification](systems/NPC/NPC-003.md) is finalized as v1, including reservation cleanup, world-position continuity through origin changes, and route reconstruction on reload.
- **NPC-003-D01 — 2026-11-11.** Default to DFU-style local wandering with a street preference, forward continuity and occasional turns. Movement pace and route preferences are moddable.
- **NPC-003-D02 — 2026-11-11.** Keep DFU's calm approach conditions with tunable distance and clear line of sight. Hold civilian movement during active dialogue.
- **NPC-003-D03 — 2026-11-11.** On blockage, try a nearby route and briefly wait and retry if the obstruction may move. Request routine retirement after persistent failure, subject to NPC-001 visibility and conversation rules.

## NPC-002 interview decisions

- **NPC-002-A01 — 2026-11-11.** The user approved Draft v1 with “I approve”. The [NPC-002 specification](systems/NPC/NPC-002.md) is finalized as v1, including duplicate display names, identity validation before publication and deferred generation when required profile data cannot resolve.
- **NPC-002-D01 — 2026-11-11.** Keep each ordinary outdoor civilian's identity stable while present. A replacement after ordinary retirement receives a fresh identity. Outstanding quest, incident and other durable references retain the original actor ID.
- **NPC-002-D02 — 2026-11-11.** Use regional names and regionally appropriate appearances, with moddable ancestry, gender, appearance and city watch weights. Default watch generation is 1 in 32 and male-only, with both settings moddable.
- **NPC-002-D03 — 2026-11-11.** If pickpocket rules impose an attempt limit, attach attempted state to the civilian identity and preserve it when that civilian is restored. A fresh civilian starts with fresh state, including when a scene object is reused. Pickpocket rules own the limit and any anti-farming policy.
- **NPC-002-D04 — 2026-11-11.** Restore pedestrians present at the save with the same actor IDs, names, appearances, roles and actor-specific interaction state. Retired pedestrians stay retired, with durable quest and incident references preserved.

## NPC-001 interview decisions

- **NPC-001-A01 — 2026-11-10.** The user approved Draft v1 with “I approve”. The [NPC-001 specification](systems/NPC/NPC-001.md) is finalized as v1, including one reserved vacancy per committed civilian death and deferred routine retirement at nightfall.
- **NPC-001-D01.** Ordinary outdoor civilian crowds are daytime-only by default. The schedule and nighttime population policy are moddable.
- **NPC-001-D02.** Routine population changes can occur behind the player or behind solid occlusion, with visible changes permitted beyond a tunable distance. Keep nearby civilians in clear view and civilians in active conversation through routine retirement.
- **NPC-001-D03.** A killed civilian's vacancy is eligible for refill by a different civilian after the player leaves and re-enters the settlement's outdoor population area or exits a building back onto its streets. The refill triggers are moddable. Waiting overnight or reloading alone preserves the vacancy.
- **NPC-001-D04.** Use DFU settlement-size scaling as the default crowd cap, with tunable caps and distances.

## ITEM-025 interview decisions

- **ITEM-025-A01 — 2026-11-10.** The user approved Draft v1 with “I approve”. The [ITEM-025 specification](systems/ITEM/ITEM-025.md) is finalized as v1. Exact snapshot coordination, migration schemas and owner recovery records remain open integration work.

- **ITEM-025-D01 — 2026-11-10.** Restore item records and custody, resolve equipment/light/quest/service bindings, then rebuild dependent protection and continuous effects with durable state preserved. User confirmed question 1.
- **ITEM-025-D02 — 2026-11-10.** Missing or conflicting required bindings need approved migration, owner recovery or load failure. Approved lifecycles may account for cleared bindings. Surviving items retain recorded custody. User confirmed question 2.
- **ITEM-025-D03 — 2026-11-10.** Validate migrated state before gameplay and preserve original save for retry. COMBAT-002 bow reconciliation applies within its approved scope. User confirmed question 3.
- **ITEM-025-D04 — 2026-11-10.** Save every supported custodian, including unloaded containers, corpses, dropped piles and repair services. Store one authoritative record per item and resolve equipment, light and quest references against it. User confirmed question 1 in the second interview.
- **ITEM-025-D05 — 2026-11-10.** Pending operations require owner-supported restoration of outstanding steps. Preserve completed facts against repeated charges, consumption or grants. Uncommitted UI selections follow existing rules. User confirmed question 2 in the second interview.
- **ITEM-025-D06 — 2026-11-10.** Rebuild armor, effective load and continuous contributions from restored records, bindings and modifiers. Preserve durable fuel and preparation. Do not replay equip, use or break. User confirmed question 3 in the second interview.

- **ITEM-025-D07 — 2026-11-10.** Capture coherent custody across collections or use owner-supported transfer progress with completed and outstanding steps. User confirmed question 1 in the third interview.
- **ITEM-025-D08 — 2026-11-10.** Reconcile overdue expiry and repair eligibility against restored game time before access. Apply approved completion rules once without offline progress. User confirmed question 2 in the third interview.
- **ITEM-025-D09 — 2026-11-10.** Explain player-visible corrections and unresolved access-limiting obligations. Use existing load failure when required state cannot be restored safely. User confirmed question 3 in the third interview.


## ITEM-024 interview decisions

- **ITEM-024-A01 — 2026-11-10.** The user approved Draft v1 with “I approve”. The [ITEM-024 specification](systems/ITEM/ITEM-024.md) is finalized as v1. Clock conversion, unloaded-custody reconciliation, compatible service profiles and native recovery records remain open integration decisions.

- **ITEM-024-D01 — 2026-11-10.** Items become unusable at the deadline across supported custody, including rest or travel crossing it. Unloaded containers reconcile before exposing contents. User confirmed question 1.
- **ITEM-024-D02 — 2026-11-10.** Voluntary drop, stash, gift and sale blocked by default. Explicit profiles can permit them while preserving the original deadline. User confirmed question 2.
- **ITEM-024-D03 — 2026-11-10.** Equipped expiry removes item and source contributions together, leaving slots empty. Preserve committed combat outcomes and independently released effects and apply approved interruption to unfinished work. User confirmed question 3.
- **ITEM-024-D04 — 2026-11-10.** Pending actions that still require the item recheck expiry at commitment. Expiry wins at equality and committed effects or released arrows follow approved rules. User confirmed question 1 in the second interview.
- **ITEM-024-D05 — 2026-11-10.** Permitted summoned stacks require compatible deadlines, provenance and state. Splitting preserves the original deadline on both results. User confirmed question 2 in the second interview.
- **ITEM-024-D06 — 2026-11-10.** Ordinary expiry removes the item without equipment Breaks payloads or a repairable remnant. Explicit alternate profiles respect quest protection and once-only settlement. User confirmed question 3 in the second interview.

- **ITEM-024-D07 — 2026-11-10.** Persist deadline and completed expiry steps. Reconcile overdue items before access and keep them unusable during recovery. Resume unfinished steps only. User confirmed question 1 in the third interview.
- **ITEM-024-D08 — 2026-11-10.** Quest hand-ins, repair and other service custody require explicit expiry handling. Preserve original deadline and committed obligations. User confirmed question 2 in the third interview.
- **ITEM-024-D09 — 2026-11-10.** Show summoned status and remaining lifetime subject to character knowledge. Give one notice per completed player-carried or equipped expiry removal without replay on load. User confirmed question 3 in the third interview.


## ITEM-023 interview decisions

- **ITEM-023-A01 — 2026-11-10.** The user approved Draft v1 with “I approve”. The [ITEM-023 specification](systems/ITEM/ITEM-023.md) is finalized as v1. Concrete quest disposition profiles, unloaded-custody resolution, and native hand-in and cleanup records remain open integration decisions.

- **ITEM-023-D01 — 2026-11-10.** Link physical items to stable quest instance/resource while preserving item identity and custody. Authorized moves preserve the link and check relevant quest permissions. User confirmed question 1.
- **ITEM-023-D02 — 2026-11-10.** Explicit permanent conversion acts on the existing item in place and ends quest restrictions and cleanup eligibility. Identity, custody, condition, enchantments and knowledge persist. User confirmed question 2.
- **ITEM-023-D03 — 2026-11-10.** Quest-end cleanup requires explicit item disposition. Unresolved quest/resource links preserve items in current custody for recovery, including unloaded containers. User confirmed question 3.
- **ITEM-023-D04 — 2026-11-10.** Linked items stay separate from ordinary stacks by default. Voluntary drop, sale, ordinary consumption and unrelated storage require explicit quest permission. Hand-ins and scripted moves use their declared rules. User confirmed question 1 in the second interview.
- **ITEM-023-D05 — 2026-11-10.** Hand-in validates exact item, quantity and destination. Lookup is read-only. Retain committed hand-in facts to prevent duplicate removal or advancement. User confirmed question 2 in the second interview.
- **ITEM-023-D06 — 2026-11-10.** Uncommitted actions revalidate quest state and disposition. Completed moves stand and pending work follows authoritative custody, including unloaded containers. User confirmed question 3 in the second interview.

- **ITEM-023-D07 — 2026-11-10.** Authorized committed use, drop and recovery report actual item and location once. Authored drop objectives distinguish qualifying placement from ordinary custody changes. User confirmed question 1 in the third interview.
- **ITEM-023-D08 — 2026-11-10.** Reclamation targets exact linked items under accepted disposition. Unrelated contents remain and container or corpse cleanup follows its own policy. User confirmed question 2 in the third interview.
- **ITEM-023-D09 — 2026-11-10.** Persist links, conversions and hand-in or cleanup progress. Reconcile after restoring custody and quest state, resume outstanding work only and protect unresolved items in current custody. User confirmed question 3 in the third interview.


## ITEM-022 interview decisions

- **ITEM-022-A01 — 2026-11-10.** The user approved Draft v1 with “I approve”. The [ITEM-022 specification](systems/ITEM/ITEM-022.md) is finalized as v1. Placement bounds, reset dispositions, LAW and QUEST handoff records, and native recovery records remain open integration decisions.

- **ITEM-022-D01 — 2026-11-10.** Opening authorizes permitted inspection only. Each take or deposit revalidates target identity, reach, access, ownership, quest restrictions and capacity. User confirmed question 1.
- **ITEM-022-D02 — 2026-11-10.** LAW/QUEST handoffs use committed item, quantity and provenance facts, including partial stacks. Rejected or cancelled transfers have no successful-take event. User confirmed question 2.
- **ITEM-022-D03 — 2026-11-10.** Cleanup follows container policy. Empty persistent storage remains accessible, corpses follow COMBAT-021, and disposable piles can disappear only when empty and free of active interaction or pending obligations. User confirmed question 3.
- **ITEM-022-D04 — 2026-11-10.** Drop confirmation validates reachable placement and commits the item into world custody with that placement. Failed placement retains the inventory item. Closing inventory only closes the interaction. User confirmed question 1 in the second interview.
- **ITEM-022-D05 — 2026-11-10.** Ordinary ground drops create a new pile. An explicit deposit onto an existing pile validates that exact pile's identity, access and admission. User confirmed question 2 in the second interview.
- **ITEM-022-D06 — 2026-11-10.** A pending transfer stays bound to its original target and needs a fresh interaction after loss of reach, unload or replacement. Completed transfers stand. User confirmed question 3 in the second interview.

- **ITEM-022-D07 — 2026-11-10.** Nonempty piles persist through ordinary unloads, revisits and saves. Explicit reset or cleanup requires content disposition compatible with protection and pending obligations. User confirmed question 1 in the third interview.
- **ITEM-022-D08 — 2026-11-10.** Direct pickup selects one item or stack. Exact amounts are all-or-nothing and explicit take-what-fits leaves the remainder. The arrow-only corpse shortcut retains maximum fitting pickup. User confirmed question 2 in the third interview.
- **ITEM-022-D09 — 2026-11-10.** Persist identity, placement, custody, contents and committed transfer facts. Uncommitted selections need fresh interaction after load. Preserve committed moves and pending LAW/QUEST follow-up. User confirmed question 3 in the third interview.


## ITEM-021 interview decisions

- **ITEM-021-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-021 Draft v1. The [specification](systems/ITEM/ITEM-021.md) is finalized v1, including governed stock provenance, persistent specific-property storage, retained daily refresh, baseline context-specific tables, merchant-owned sold items, transaction-safe refresh deferral, persistent depletion, checked publication and no-replay restoration. Documented stock/context fixtures, provenance/disposition, ownership changes, calendar/interaction boundaries, merchant profiles, receipts and native migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-021-D01 — 2026-11-10:** Generated stock distinct from player deposits/quest/persistent items; refresh only explicit policy stock, no whole clear. User: “1. Yes” to first interview.
- **ITEM-021-D02 — 2026-11-10:** Specific owned house/ship storage persistent/no auto stock-refresh; ownership changes explicit disposition. User: “2. Yes” to first interview.
- **ITEM-021-D03 — 2026-11-10:** Calendar-day initial shop/nonplayer-house refresh, one retained eligible-day result, lazy authorized access/no missed-day stock accumulation; moddable schedules/models. User: “3. Yes” to first interview.
- **ITEM-021-D04 — 2026-11-10:** DFU building/group/quality-rarity/furniture data baseline under native probability/construction, explicit context/validated pools, no automatic mod inclusion. User: “1. Yes” to second interview.
- **ITEM-021-D05 — 2026-11-10:** Sold items merchant-owned with declared refresh/disposal, distinct deposits/protected items; no promised buyback absent ECON policy. User: “2. Yes” to second interview.
- **ITEM-021-D06 — 2026-11-10:** Due refresh deferred during live selection/pending transaction; coherent boundary invalidates stale intents/requotes, no midnight target swap/committed purchase loss. User: “3. Yes” to second interview.
- **ITEM-021-D07 — 2026-11-10:** Purchase/theft depletion and empty results retained until authorized refresh; no reopen/cancel/mode refill, legal consequences/retained ownership unchanged. User: “1. Yes” to third interview.
- **ITEM-021-D08 — 2026-11-10:** Whole replacement validated before stock retirement/success marker; failure preserves contents/resolved results, notifications no generation/addition repeats. User: “2. Yes” to third interview.
- **ITEM-021-D09 — 2026-11-10:** Save container/property/provenance/contents/ownership/last success/deferred facts. No load new-container/same-refresh reroll; overdue same policy preserves deposits/protection. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-021.md) is approved and finalized v1 under ITEM-021-A01. No implementation/coding tasks authorized.

## ITEM-020 interview decisions

- **ITEM-020-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-020 Draft v1. The [specification](systems/ITEM/ITEM-020.md) is finalized v1, including explicit generation context, retained results, validated publication, independent halving category chances, declared scaling, supplemental/guaranteed stages, baseline matrices/mappings, bounded generation, ordered mod stages, capacity separation and no-replay persistence. Documented fixtures/schemas, source profiles, supplemental distributions, state/bounds, protected additions/overflow, publication recovery and native migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-020-D01 — 2026-11-10:** Explicit loot table/pools/level-scaling/appearance context, support player/location/enemy/fixed profiles; no implicit player for every source. User: “1. Yes” to first interview.
- **ITEM-020-D02 — 2026-11-10:** Stable generation retains contents across reopen/scene/retry; authorized new spawn/restock only. Isolated diagnostics/previews no live RNG changes. User: “2. Yes” to first interview.
- **ITEM-020-D03 — 2026-11-10:** Validate whole result before publication; existing/quest contents preserved absent explicit replacement/disposition. Required failures recovery, no partial/default/reroll. User: “3. Yes” to first interview.
- **ITEM-020-D04 — 2026-11-10:** Independent repeating category rolls halve chance per item; approved 0% never/100% always. Alternative count/weighted-pool profiles moddable. User: “1. Yes” to second interview.
- **ITEM-020-D05 — 2026-11-10:** Initial gold and C1/C2/P1/P2 chances scale by declared generation level, other chances unscaled; RULE-026 materials use that level, alternative/fixed profiles supported. User: “2. Yes” to second interview.
- **ITEM-020-D06 — 2026-11-10:** Explicit supplemental map/potion/recipe stages/chances/pools; guaranteed quest/authored additions distinct and retained, common validated publication. User: “3. Yes” to second interview.
- **ITEM-020-D07 — 2026-11-10:** DFU inspected matrix/dungeon mappings initial data, validated mods/native chances, no classic parity claim; other sources explicit profiles. User: “1. Yes” to third interview.
- **ITEM-020-D08 — 2026-11-10:** Raw scaled chance retained/halved; tested whole percent truncated and capped 100, zero stops no draw. 200→guaranteed,guaranteed,50%; finer alternatives explicit. User: “2. Yes” to third interview.
- **ITEM-020-D09 — 2026-11-10:** Finite pools/numeric/bounded generation validated; bound/provider failure recovery, no silent truncate/reroll. Legitimate empty generation durable valid result. User: “3. Yes” to third interview.
- **ITEM-020-D10 — 2026-11-10:** Declared ordered loot-changing stages pre-validation/publication; notifications completed facts/no repeated additions or rolls, later rewards separate operations. User: “1. Yes” to fourth interview.
- **ITEM-020-D11 — 2026-11-10:** Explicit quantity/wear/knowledge/contents via constructors. Player capacity limits acquisition, not world loot; actual destination overflow explicit recovery/no deletion. User: “2. Yes” to fourth interview.
- **ITEM-020-D12 — 2026-11-10:** Save generation/context/resolved contents including empty and completed additions/publication. No load level/table regeneration, missing/interrupted recovery retains results/no duplicate quest/fresh rolls. User: “3. Yes” to fourth interview.

The [specification](systems/ITEM/ITEM-020.md) is approved and finalized v1 under ITEM-020-A01. No implementation/coding tasks authorized.

## ITEM-019 interview decisions

- **ITEM-019-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-019 Draft v1. The [specification](systems/ITEM/ITEM-019.md) is finalized v1, including knowledge separate from mechanics, property-level discovery, consistent knowledge-safe display, observable inspection, character/item knowledge ownership, immediate scoped merchant identification, split/merge knowledge preservation, version-aware property changes and no-replay persistence. Documented disclosure/version schemas, knowledge lineage, service scopes, economic visibility, presentation fixtures, receipts and native migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-019-D01 — 2026-11-10:** Knowledge separate from actual contents/mechanics; declared disclosure no material/power/condition/charge/ownership/formula changes, hidden properties still function. User: “1. Yes” to first interview.
- **ITEM-019-D02 — 2026-11-10:** Per-property knowledge supported with declared inspection/Identify/use/quest disclosure; simple complete state allowed, no automatic every-curse/secret reveal. User: “2. Yes” to first interview.
- **ITEM-019-D03 — 2026-11-10:** Shared knowledge-safe naming/tooltips/icons/indicators/actions/rejections/sorting; technical diagnostics separate. User: “3. Yes” to first interview.
- **ITEM-019-D04 — 2026-11-10:** Observable type/style/quantity/effective weight/condition/fuel inspection; hidden identity/effects/curses/secrets discovery-gated. Material visibility profile-defined. User: “1. Yes” to second interview.
- **ITEM-019-D05 — 2026-11-10:** Per-character/particular-item knowledge survives drop/storage/reacquisition, no automatic actor transfer/template-wide identification. Explicit shared/label/familiarity mods supported. User: “2. Yes” to second interview.
- **ITEM-019-D06 — 2026-11-10:** Immediate guaranteed merchant ordinary-scope identification, RULE-023 fees, disclosed price/scope, coherent payment/knowledge no ownership staging. Secrets separate policy. User: “3. Yes” to second interview.
- **ITEM-019-D07 — 2026-11-10:** Split knowledge follows separated units, not unrelated copies; merge preserves without unknown-property disclosure, incompatible states separate unless safe supported representation. User: “1. Yes” to third interview.
- **ITEM-019-D08 — 2026-11-10:** Property/version-specific discovery, unrelated knowledge retained on change/new hidden properties not auto-known. Use only declared justified observation, not all formulas/powers/curses. User: “2. Yes” to third interview.
- **ITEM-019-D09 — 2026-11-10:** Persist character/item/property knowledge and completion; no restore forgetting valid facts/new-secret reveal/recharge/rerolls. Changed properties explicit compatibility, rejected service payment/knowledge unchanged. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-019.md) is approved and finalized v1 under ITEM-019-A01. No implementation/coding tasks authorized.

## ITEM-018 interview decisions

- **ITEM-018-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-018 Draft v1. The [specification](systems/ITEM/ITEM-018.md) is finalized v1, including active carried-light custody, separate fuel/exhaustion, partial refuelling, retained active-time burn progress, optional hand/placed/multiple-light profiles, actual-submersion extinguishing, explicit fuel targeting/container remainders, transfer extinguishing, presentation-only flicker, one-unit activation and no-replay persistence. Documented fuel/container schemas, clock bounds, environmental predicates, mod profiles, presentation values, receipts and native migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-018-D01 — 2026-11-10:** One carried active light per actor default; switching/dousing retains items/fuel, custody/access checked. Explicit mod multiple/placed lights supported. User: “1. Yes” to first interview.
- **ITEM-018-D02 — 2026-11-10:** Fuel/durability semantically separate despite classic condition adapter; empty lantern retained, ordinary torch/candle consumed at exhaustion default. No accidental equipment Breaks, moddable outcomes. User: “2. Yes” to first interview.
- **ITEM-018-D03 — 2026-11-10:** Partial compatible fuel transfer retains unused source, quantities validated. No excess discard/whole-bottle partial-fill cost absent explicit supported profile. User: “3. Yes” to first interview.
- **ITEM-018-D04 — 2026-11-10:** One fuel/20 active unpaused gameplay seconds; per-light fraction retained across toggle/switch/save. Wait/travel no burn absent profile; mod game-time clocks supported. User: “1. Yes” to second interview.
- **ITEM-018-D05 — 2026-11-10:** No vanilla hand-slot requirement; mod hand/slot rules through ITEM-010, no silent weapon displacement. User: “2. Yes” to second interview.
- **ITEM-018-D06 — 2026-11-10:** Actual submersion extinguishes ordinary flame retaining fuel/no auto-relight; explicit waterproof/magical exceptions. Actual light/water context, not swimming alone. User: “3. Yes” to second interview.
- **ITEM-018-D07 — 2026-11-10:** Explicit destination/source, deterministic declared shortcuts/no retarget; active compatible refuel no relight/progress reset. User: “1. Yes” to third interview.
- **ITEM-018-D08 — 2026-11-10:** Fuel remainder distinct from container count, partial container identity retained; split full stack via ITEM-006. Disposable empty unit consumed, reusable bottle profile explicit. User: “2. Yes” to third interview.
- **ITEM-018-D09 — 2026-11-10:** Checked custody transfer extinguishes active carried source, preserving fuel/fraction; no automatic world/recipient activation, placed-light profile explicit. User: “3. Yes” to third interview.
- **ITEM-018-D10 — 2026-11-10:** Explicit range/brightness/color/warnings; flicker presentation-only/no gameplay RNG or burn change; feedback no power/consumption replay. User: “1. Yes” to fourth interview.
- **ITEM-018-D11 — 2026-11-10:** Activate one unit via ITEM-006 split; individual fuel/fraction preserved, incompatible partials cannot merge/reset, failed activation unchanged. User: “2. Yes” to fourth interview.
- **ITEM-018-D12 — 2026-11-10:** Save active ID/fuel/fraction/profile; restore valid active source no ignition fee/refill with current custody/environment validation. No offline/duplicate/old-session burn; pending refuel supported boundaries. User: “3. Yes” to fourth interview.

The [specification](systems/ITEM/ITEM-018.md) is approved and finalized v1 under ITEM-018-A01. No implementation/coding tasks authorized.

## ITEM-017 interview decisions

- **ITEM-017-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-017 Draft v1. The [specification](systems/ITEM/ITEM-017.md) is finalized v1, including checked selected-unit potion use, explicit drug doses, reusable recipe actions, carried-source access, unidentified use, valid no-benefit consumption, recipe-access revalidation, declared delayed-consumption rules and no-replay persistence. Documented payload/unit schemas, drug profiles/fixtures, source access/knowledge policies, recipe integration, deferred commitment and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-017-D01 — 2026-11-10:** Shared checked MAGIC-014 potion action, selected unit once; technical invalidity preserves, valid no-benefit consumes; no whole-stack removal/current-recipe replacement. User: “1. Yes” to first interview.
- **ITEM-017-D02 — 2026-11-10:** One drug dose via stable explicit profile/eligibility/defenses/commit under MAGIC-020, no numeric offset or unsupported-content loss. No default addiction. User: “2. Yes” to first interview.
- **ITEM-017-D03 — 2026-11-10:** Read recipe shows known instructions/selects possessed accessible recipe in MAGIC-013; no consume/brew/ingredients/permanent knowledge, explicit mod alternatives. User: “3. Yes” to first interview.
- **ITEM-017-D04 — 2026-11-10:** Carried selected unit baseline; direct wagon/container use explicit access/ownership profile, open container no consumption permission. User: “1. Yes” to second interview.
- **ITEM-017-D05 — 2026-11-10:** Deliberate unidentified valid potion/drug use allowed, no prior disclosure/automatic full identification; explicit mod requirement/confirmation supported. User: “2. Yes” to second interview.
- **ITEM-017-D06 — 2026-11-10:** Valid drug dose consumes despite immunity/resistance/redundancy; blocked/missing content preserves, partial failure retains facts. Drug timing/defenses explicit, no potion-rule inference. User: “3. Yes” to second interview.
- **ITEM-017-D07 — 2026-11-10:** Lost recipe access removes possessed selection, not permitted knowledge; staging revalidates, explicit learned mods may use durable knowledge, reading grants none. User: “1. Yes” to third interview.
- **ITEM-017-D08 — 2026-11-10:** Mod delay/cooldown/confirmation consumption/interruption explicit, cosmetic animation no timing change; original selected unit revalidated, no same-name substitution. User: “2. Yes” to third interview.
- **ITEM-017-D09 — 2026-11-10:** Persist actual contents/potency/dose/knowledge/completed use facts. No restore refill/potency rewrite/re-exposure/recipe grant; supported pending rules and stale-session rejection. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-017.md) is approved and finalized v1 under ITEM-017-A01. No implementation/coding tasks authorized.

## ITEM-016 interview decisions

- **ITEM-016-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-016 Draft v1. The [specification](systems/ITEM/ITEM-016.md) is finalized v1, including reusable ordinary reading, success-only map consumption, physical spellbook access, retained map targeting, authorized reading context, character/work reading positions, bounded discovery knowledge, unavailable/interrupted reading and no-replay persistence. Documented readable profiles, interrupted-display rules, edition anchors, WORLD pools, notebook/consumption recovery, spellbook access and native migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-016-D01 — 2026-11-10:** Ordinary books reusable/unconsumed, no implicit skill/spell/reward grants; explicit supported content/approved quest-artifact exceptions. User: “1. Yes” to first interview.
- **ITEM-016-D02 — 2026-11-10:** Map consumes one only on valid new discovery committed; no eligible target/invalid/technical failure retains map. Discovery/notebook/consume no duplicates. User: “2. Yes” to first interview.
- **ITEM-016-D03 — 2026-11-10:** Spellbook item opens MAGIC-011 interface, not teaching/casting; multiple copies no duplicated knowledge, loss blocks required access without forgetting. User: “3. Yes” to first interview.
- **ITEM-016-D04 — 2026-11-10:** WORLD eligible undiscovered current-region pool baseline, retain map target on retry; explicit fixed/other-region/reusable mod profiles, no menu draw/reveal. User: “1. Yes” to second interview.
- **ITEM-016-D05 — 2026-11-10:** Authorized-access reading without artificial transfer, approved suspension/no automatic calendar cost; explicit mod time/access policies. User: “2. Yes” to second interview.
- **ITEM-016-D06 — 2026-11-10:** Per-character/work position shared across copies, DATA-018 verified anchors or start+notice; progress separate from ownership/rewards. User: “3. Yes” to second interview.
- **ITEM-016-D07 — 2026-11-10:** Stable location/name/map availability and one notebook entry; no interiors/quest completion/travel permission. Known fixed target no ordinary consumption, explicit alternate mod outcomes. User: “1. Yes” to third interview.
- **ITEM-016-D08 — 2026-11-10:** Missing/malformed required content unavailable without consumption/reward. Access loss blocks further item actions, retains last position; continued display explicit policy. Open/close no duplicate reward. User: “2. Yes” to third interview.
- **ITEM-016-D09 — 2026-11-10:** Save compatible anchors/discovery IDs/retained map outcomes/reward facts. No load rediscover/extra consume/duplicate note/spell-reward; supported save boundaries, no automatic reopen/confirm. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-016.md) is approved and finalized v1 under ITEM-016-A01. No implementation/coding tasks authorized.

## ITEM-015 interview decisions

- **ITEM-015-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-015 Draft v1. The [specification](systems/ITEM/ITEM-015.md) is finalized v1, including explicit/default actions, declared ordinary/enchantment composites, owned UI handoff, explicit quest outcomes, pure knowledge-safe queries, one pending operation per interaction, composite failure recovery and no-replay persistence. Documented action/default/visibility schemas, quest outcomes, composite commitment/recovery, UI pending ownership, per-action rules and native migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-015-D01 — 2026-11-10:** Explicit supported actions, Use declared default; no unhandled fallback style cycle/other activation. User: “1. Yes” to first interview.
- **ITEM-015-D02 — 2026-11-10:** Ordinary+enchanted behavior only explicit ordered composite; no automatic Used powers on read/style/light, approved artifacts binding. User: “2. Yes” to first interview.
- **ITEM-015-D03 — 2026-11-10:** Action declares stay/close/yield UI; close alone no gameplay commit/unrelated cancellation/new-window close. Explicit recovery, no alternate route on failure. User: “3. Yes” to first interview.
- **ITEM-015-D04 — 2026-11-10:** Declared default; ambiguous Use opens choice/requires explicit action, no registration-order pick. Explicit unavailable action no fallback. User: “1. Yes” to second interview.
- **ITEM-015-D05 — 2026-11-10:** Explicit quest consume/block/pending/permit continuation, message alone no routing meaning. Retried quest-use event once. User: “2. Yes” to second interview.
- **ITEM-015-D06 — 2026-11-10:** Pure knowledge-aware action queries; known blocked reasons allowed, no hidden-power reveal/spend/content generation/quest activation from menu. User: “3. Yes” to second interview.
- **ITEM-015-D07 — 2026-11-10:** One authoritative pending operation per interaction; duplicate no extra picker/commit. Conflict rejects or declared cancel/replace; window close no automatic refund/abandonment. User: “1. Yes” to third interview.
- **ITEM-015-D08 — 2026-11-10:** Composite required/optional steps and commit/failure rules explicit; retain earlier facts, no whole retry/rollback/fallback. Optional-failure continuation only supported policy. User: “2. Yes” to third interview.
- **ITEM-015-D09 — 2026-11-10:** Supported pending save retains action/item/provider/quest/phases; otherwise explained block. No load auto-confirm/quest repeat/reconsume/unsupported reopen, stale callbacks rejected; action-specific rules binding. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-015.md) is approved and finalized v1 under ITEM-015-A01. No implementation/coding tasks authorized.

## ITEM-014 interview decisions

- **ITEM-014-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-014 Draft v1. The [specification](systems/ITEM/ITEM-014.md) is finalized v1, including service custody, retained accepted terms, independent game-time schedules, agreed restoration scope, original-service collection, disclosed cancellation, indefinite ready storage, unavailable-service recovery, once-only completion, lifecycle compatibility and no-replay persistence. Documented service/job/custody/time schemas, eligibility compatibility, batch settlement, receipts, mod profiles, permanent-service recovery and native migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-014-D01 — 2026-11-10:** Original item enters explicit service custody on accepted job, identity/contents retained; no player use/equip/sale/transfer until authorized return. Quote selection not custody transfer. User: “1. Yes” to first interview.
- **ITEM-014-D02 — 2026-11-10:** Show eligibility/price/scope/completion; coordinate payment/custody/durable job, rejection unchanged. No silent accepted-term rewrite by later prices/new work. User: “2. Yes” to first interview.
- **ITEM-014-D03 — 2026-11-10:** Game-time progress including wait/travel independent of loaded scene; closed-game wall-clock no progress. Ready once at/after completion. User: “3. Yes” to first interview.
- **ITEM-014-D04 — 2026-11-10:** Ordinary repair restores agreed max with no max loss, preserves actual state, no separate charge refill. Explicit quoted mod partial/max-loss/recharge profiles supported. User: “1. Yes” to second interview.
- **ITEM-014-D05 — 2026-11-10:** Original stable service/location collection with current access/capacity. Failed pickup safely retains ready item, no repeat repair fee; alternate pickup/delivery explicit profiles. User: “2. Yes” to second interview.
- **ITEM-014-D06 — 2026-11-10:** Independent per-item RULE-023 baseline schedule, new work no old-job delay. Mod queue/shared workload quoted and prior accepted terms retained absent separate authorized changes. User: “3. Yes” to second interview.
- **ITEM-014-D07 — 2026-11-10:** Pre-completion cancellation returns submitted condition/no refund by default, disclosed acceptance/cancel terms. Explicit mod refund/partial-work profiles; return access/capacity checked. User: “1. Yes” to third interview.
- **ITEM-014-D08 — 2026-11-10:** Indefinite ready collection, no default storage fee/degradation/forfeiture; mod terms explicit/disclosed before acceptance. User: “2. Yes” to third interview.
- **ITEM-014-D09 — 2026-11-10:** Temporary closure preserves job; permanent missing service/location/provider explicit migration/recovery preserving possession/paid obligation, no silent deletion/replacement/alternate pickup. User: “3. Yes” to third interview.
- **ITEM-014-D10 — 2026-11-10:** Repair once at completion in service custody; collection only returns, no repair/equip/reactivation. Completion equality follows completed rules, not early cancellation. User: “1. Yes” to fourth interview.
- **ITEM-014-D11 — 2026-11-10:** Expiry/quest/curse/provider custody conflicts reject unless explicit compatible profile. No implicit expiry pause/curse removal/protection bypass. User: “2. Yes” to fourth interview.
- **ITEM-014-D12 — 2026-11-10:** Persist job/item/service/submitted condition/agreed scope-price-schedule-cancel/payment and progress. No restore reprice/restart/double repair/refund/return. Unsupported pending saves explained block, failures retain recovery. User: “3. Yes” to fourth interview.

The [specification](systems/ITEM/ITEM-014.md) is approved and finalized v1 under ITEM-014-A01. No implementation/coding tasks authorized.

## ITEM-013 interview decisions

- **ITEM-013-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-013 Draft v1. The [specification](systems/ITEM/ITEM-013.md) is finalized v1, including checked condition operations, once-only break episodes, ordinary equipment retention, default enchanted/artifact destruction with moddable exceptions, committed payload ordering, protected-item compatibility, repair boundaries, authoritative wear targeting, knowledge-safe feedback, maximum-condition changes and no-replay persistence. Documented durability/repairability/fate profiles, numeric/stack schemas, quest/curse compatibility, phase receipts/bounds, migrations and native recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-013-D01 — 2026-11-10:** Checked wear/repair/charge operations separate; negative wear no repair, wear cannot raise condition/excess clamps zero; non-durable profiles explicit. User: “1. Yes” to first interview.
- **ITEM-013-D02 — 2026-11-10:** First zero transition feedback/cleanup/declared Breaks once, repeated zero wear no repeat; authorized repair allows later genuine break. User: “2. Yes” to first interview.
- **ITEM-013-D03 — 2026-11-10:** Ordinary equipment retained broken/unequipped/unusable pending authorized repair; moddable explicit break fate profiles. User: “3. Yes, but make sure this is moddable, and perhaps by default artifacts disappear entirely when they break, which magic items in the vanilla game generally are destroyed when they run out of condition.” Artifact disappearance proposed; regular-magic/artifact exact defaults remain unresolved pending confirmation.
- **ITEM-013-D04 — 2026-11-10:** Regular enchanted/artifact zero-condition destruction default, explicit retention profiles supported. Separate charges destroy only if declared, not automatic physical break. User: “1. Yes” to second interview; resolves D03 default question.
- **ITEM-013-D05 — 2026-11-10:** Committed last-condition power finishes, then source cleanup/Breaks once, then destruction/retirement. Earlier ordinary melee wear retains COMBAT-011 no later broken-source strike powers. User: “2. Yes” to second interview.
- **ITEM-013-D06 — 2026-11-10:** Protected/quest item break compatibility explicit; generic artifact rule cannot silently delete required quest state. Unsupported conflict validation/recovery, no invented indestructibility/discard. User: “3. Yes” to second interview.
- **ITEM-013-D07 — 2026-11-10:** Profile-authorized ordinary repair; enchanted/artifact repair explicit, retention not permission. No destroyed-ID resurrection/spent-charge refill absent separate authority. User: “1. Yes” to third interview.
- **ITEM-013-D08 — 2026-11-10:** Actual item/custody/source/operation targeting; no replacement wear or owner-omission cleanup bypass. Explicit per-unit/stack-wide condition, unsupported special-stack wear rejects. User: “2. Yes” to third interview.
- **ITEM-013-D09 — 2026-11-10:** Knowledge-safe current/max/broken display, one concise break notice; no inspect wear/hidden-power disclosure. Configurable warnings mechanics-neutral. User: “3. Yes” to third interview.
- **ITEM-013-D10 — 2026-11-10:** Increased max no refill; supported decrease clamps. Zero max/removing durability explicit transformation/migration, no manufactured break. User: “1. Yes” to fourth interview.
- **ITEM-013-D11 — 2026-11-10:** New break after authorized restoration above zero and previous episode/recovery completion; no repair/retry guard reset/payload farming. User: “2. Yes” to fourth interview.
- **ITEM-013-D12 — 2026-11-10:** Persist condition/profile/episode/cleanup-payload-destruction phases. No load repair/replay/duplication; missing profiles/incomplete settlement explicit migration/recovery, unsupported pending saves explained block. User: “3. Yes” to fourth interview.

The [specification](systems/ITEM/ITEM-013.md) is approved and finalized v1 under ITEM-013-A01. No implementation/coding tasks authorized.

## ITEM-012 interview decisions

- **ITEM-012-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-012 Draft v1. The [specification](systems/ITEM/ITEM-012.md) is finalized v1, including source-owned protection, coherent equipment/power transitions, once-only source lifecycle, explicit coverage/composition, equipped-state updates without synthetic equip, passive activation independent of attack readiness, scoped suppression and no-replay reconstruction. Documented protection/composition profiles, contribution schemas, lifecycle ordering/recovery, conditional powers, suppression mappings and native migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-012-D01 — 2026-11-10:** Stable item-source protection derived from committed arrangement; repeated notifications/refresh no bonus accumulation, cleanup preserves other sources. Protection formulas separately governed. User: “1. Yes” to first interview.
- **ITEM-012-D02 — 2026-11-10:** Coherent bindings/armor/continuous-power transition before dependent gameplay. Admission rejection unchanged; actual partial technical commitment retains facts/recovery, not whole replay. User: “2. Yes” to first interview.
- **ITEM-012-D03 — 2026-11-10:** Genuine equip source-bound activation once; unequip/break/expiry/loss removes only source contributions. Released spells/projectiles retain lifetimes, refresh/load not equip, suppression retained. User: “3. Yes” to first interview.
- **ITEM-012-D04 — 2026-11-10:** Explicit body-part protection profiles for armor/shield/clothing and mods, no appearance/slot-name inference. Approved combat formulas binding, unresolved values require verification. User: “1. Yes” to second interview.
- **ITEM-012-D05 — 2026-11-10:** Explicit overlap composition armor/shield/magic; no multi-slot duplicate contribution or implicit additive/replacement/strongest policy. User: “2. Yes” to second interview.
- **ITEM-012-D06 — 2026-11-10:** Authorized equipped-state changes update affected contributions, no synthetic equip cycle/cooldown reset/suppression clearing/reward replay/recharge. User: “3. Yes” to second interview.
- **ITEM-012-D07 — 2026-11-10:** Ordinary protection/continuous equipped powers activate on commit, attack preparation separate. Drawn/selected/ready conditions explicit per power. User: “1. Yes” to third interview.
- **ITEM-012-D08 — 2026-11-10:** Source/power-scoped suppression; no unrelated protection/power removal absent approved policy. MAGIC-027 genuine-cycle reactivation, not refresh/load/property change. User: “2. Yes” to third interview.
- **ITEM-012-D09 — 2026-11-10:** Persist bindings/contribution/suppression/resources/phases; coherent pre-gameplay rebuild, no reroll/recharge/equip/break replay. Missing required source/provider migration/recovery, no silent omission. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-012.md) is approved and finalized v1 under ITEM-012-A01. No implementation/coding tasks authorized.

## ITEM-011 interview decisions

- **ITEM-011-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-011 Draft v1. The [specification](systems/ITEM/ITEM-011.md) is finalized v1, including shared authoritative eligibility, baseline broken/career restrictions, truthful knowledge-safe presentation, declared restriction-change semantics, required mod cursed-item support, stable custom-layout interaction, explicit forced-lifecycle compatibility and persistent restriction/provider state. Documented eligibility/override schemas, concrete curse/discovery/removal profiles, lifecycle compatibility, presentation/interaction and native migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-011-D01 — 2026-11-10:** Shared authoritative equip eligibility for UI/hotkeys/scripts/NPCs with explicit actor/item/context; special overrides declared/authorized. User: “1. Yes” to first interview.
- **ITEM-011-D02 — 2026-11-10:** Broken rejection and declared career shield/armor/proficiency/material restrictions baseline, validated mods/explicit added-type mappings. Appearance adds no race/gender restriction. User: “2. Yes” to first interview.
- **ITEM-011-D03 — 2026-11-10:** Show committed equipment/actionable reasons; selection/hover/refresh/indicators cannot mutate equip/powers/armor or disclose beyond identification rules. User: “3. Yes” to first interview.
- **ITEM-011-D04 — 2026-11-10:** Restriction declares future-equip-only vs required existing removal; no drop/delete, ITEM-010 coordinated inventory retention. Approved break/expiry/form rules binding. User: “1. Yes” to second interview.
- **ITEM-011-D05 — 2026-11-10:** Career prohibitions do not block unequip. Explicit supported curse/unequip policies with feedback/removal/recovery; user “2. Yes, but I would like cursed items like that to be something that mods could implement/add.” Required mod capability, no automatic vanilla cursed items.
- **ITEM-011-D06 — 2026-11-10:** Stable committed-layout item/slot UI resolution, custom/multi-slot inspect/select, occupied part identifies whole item. Stale selections cannot target replacement slot occupant. User: “3. Yes” to second interview.
- **ITEM-011-D07 — 2026-11-10:** Knowledge-safe feedback; failed removal may reveal resistance, not automatic hidden curse/power/cure identification. Declared discovery rules. User: “1. Yes” to third interview.
- **ITEM-011-D08 — 2026-11-10:** Curse profiles explicitly resolve break/expiry/form/quest interactions; generic veto no silent lifecycle override/destruction. Unsupported combinations validation failure/recovery. User: “2. Yes” to third interview.
- **ITEM-011-D09 — 2026-11-10:** Persist curse/restriction/provider state; delayed identity/eligibility/session revalidation. No load/refresh clearing/reapplication/preparation bypass; missing providers migration/recovery, not free removal. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-011.md) is approved and finalized v1 under ITEM-011-A01. No implementation/coding tasks authorized.

## ITEM-010 interview decisions

- **ITEM-010-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-010 Draft v1. The [specification](systems/ITEM/ITEM-010.md) is finalized v1, including complete equip planning, retained displaced possessions, stable slot selection, all-conflict displacement permission, type-aware one-unit equip, custom/multi-slot layouts, repeated-equip no-op, complete unequip and no-replay restoration. Documented slot/occupancy schemas, restrictions/conflict plans, split/admission, transition/recovery receipts, preparation provenance and native migration/reconciliation dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-010-D01 — 2026-11-10:** Validate complete slot/hand/split/displacement plan before mutation; rejection preserves equipment/quantity/powers/preparation, successful lifecycle transitions once. User: “1. Yes” to first interview.
- **ITEM-010-D02 — 2026-11-10:** Displaced items retained in actor inventory with identity/condition/contents/recovery; no silent drop/destroy/external transfer. Unsupported arrangement rejects unchanged. User: “2. Yes” to first interview.
- **ITEM-010-D03 — 2026-11-10:** Explicit compatible slot honored; auto paired first open then second, both occupied declared-first replacement only if permitted. Stable moddable slot ordering, not UI position. User: “3. Yes” to first interview.
- **ITEM-010-D04 — 2026-11-10:** Explicit allow/forbid displacement covers all affected slots/indirect hand conflicts. Player ordinary equip may replace, scripts declare intent. User: “1. Yes” to second interview.
- **ITEM-010-D05 — 2026-11-10:** Exactly one unit via type-aware split in actual actor inventory; unsupported equip/separation rejects before split. Ammo outside ordinary hand equip absent explicit supported profile. User: “2. Yes” to second interview.
- **ITEM-010-D06 — 2026-11-10:** Validated custom/multi-slot layouts with explicit compatibility/conflict/selection. COMBAT-002 baseline retained; extra hands/dual attacks/bash need compatible combat policies. User: “3. Yes” to second interview.
- **ITEM-010-D07 — 2026-11-10:** Valid repeated arrangement explicit no-op without split/delay/power/sound/reward; moving compatible slot genuine validated/timed change. User: “1. Yes” to third interview.
- **ITEM-010-D08 — 2026-11-10:** Unequip validates/releases all occupied slots once, retains inventory custody; owner restrictions/cleanup, rejection unchanged, no partial multi-slot equip. User: “2. Yes” to third interview.
- **ITEM-010-D09 — 2026-11-10:** Save stable bindings/layout/recovery; reconstruct occupancy/continuous powers without equip costs/rewards/sounds/initial selection. Invalid layouts explicit recovery, COMBAT-002 bow reconciliation retained. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-010.md) is approved and finalized v1 under ITEM-010-A01. No implementation/coding tasks authorized.

## ITEM-009 interview decisions

- **ITEM-009-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-009 Draft v1. The [specification](systems/ITEM/ITEM-009.md) is finalized v1, including distinct money forms, checked coin representation, full-payment validation, modded denominations/counts/weights, tender/change policies, baseline spending order, partially spendable letters, visible quotes, issuer/region/institution valuation, integer/rational rounding safeguards and no-replay settlement/persistence. Documented currency/unit mappings, tender/change algorithms, issuer valuation/rounding schemas, credit/service profiles, settlement recovery and native migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-009-D01 — 2026-11-10:** Coins/credit letters/bank balances distinct; payment declares forms/locations, available-funds display grants no universal interchange/access. User: “1. Yes” to first interview.
- **ITEM-009-D02 — 2026-11-10:** Carried coin balance and physical world/container stacks represent same currency with checked value-conserving pickup/drop/wagon conversion, value/weight counted once; credit letters distinct instances. User: “2. Yes” to first interview.
- **ITEM-009-D03 — 2026-11-10:** Ordinary payment full accepted amount validated before spend; insufficient rejects unchanged. Partial repayment/installments explicit ECON policy. User: “3. Yes” to first interview.
- **ITEM-009-D04 — 2026-11-10:** Required moddable denominations, possible copper/silver/gold/platinum. User added: “I'd like this currency system to allow for modding, say if somebody wanted to make smaller denominations than just gold coins, say copper, silver, gold, platinum, that sort of thing if it makes sense.” Ratios/weights/change/representation unresolved; examples do not enable extra vanilla coins automatically.
- **ITEM-009-D05 — 2026-11-10:** Gold-only vanilla; stable mod denomination IDs/positive integer smallest-unit values, explicit ratios and mapping from gold-priced formulas. No hard-coded 100 ratio/floating-point money. User: “1. Yes” to second interview.
- **ITEM-009-D06 — 2026-11-10:** Carried counts per denomination behind balance display, individual validated coin weights. Equal value need not equal weight; exchange explicit, no automatic relabel/weight reduction. User: “2. Yes” to second interview.
- **ITEM-009-D07 — 2026-11-10:** Explicit exact-tender or overpayment/change policies; full-plan change deliverability/capacity. No silent donation/invented supply/automatic conversion absent declared service permission. User: “3. Yes” to second interview.
- **ITEM-009-D08 — 2026-11-10:** Ordinary accepted carried coins if sufficient alone, otherwise carried credit then coins; wagon/bank explicit permission. Mod tender selection declared deterministic, sorting-independent. User: “1. Yes” to third interview.
- **ITEM-009-D09 — 2026-11-10:** Partially spendable letters retain identity; exhausted letters retire, stable-ID eligible selection; ECON owns issue/redeem/fee/acceptance. User confirmed “2. Yes” and requested mod letters distinguished by region/institution, e.g. Wayrest face value accepted differently in Sentinel vs Betony. Exact valuation/accounting unresolved, no rates or vanilla change inferred.
- **ITEM-009-D10 — 2026-11-10:** Show price/forms/change/fees/debit before confirmation; changed quote/material plan needs renewed acceptance. Cancel/reject no spend except explicitly approved earlier committed action cost. User: “3. Yes” to third interview.
- **ITEM-009-D11 — 2026-11-10:** Retain letter issuer/face unit/remaining face amount; acceptance/local settlement value separate. Travel/rate changes do not rewrite face amount. User: “1. Yes” to fourth interview.
- **ITEM-009-D12 — 2026-11-10:** Explicit integer/rational rates and declared rounding; show face consumed/local credit/fees/change. No value creation via repeated tiny-payment rounding; unsupported conversion rejects. User: “2. Yes” to fourth interview.
- **ITEM-009-D13 — 2026-11-10:** Supported issuer/receiving institution/region/context valuation, revalidated on commit with material-change reacceptance. Unknown issuer/unavailable valuation explicit reject/error, no assumed 1:1. User: “3. Yes” to fourth interview.
- **ITEM-009-D14 — 2026-11-10:** Vanilla coin 2.5 g baseline; validated denomination weights, letters independently weighted from face amount, nonphysical accounts no carried weight. User: “1. Yes” to fifth interview.
- **ITEM-009-D15 — 2026-11-10:** Validate full debit/output/change/capacity/recipient plan before commit; ordinary rejection unchanged. External partial commitment retains exact facts/recovery, retries no mint/duplicate letters/double charge. User: “2. Yes” to fifth interview.
- **ITEM-009-D16 — 2026-11-10:** Persist counts/letter identity/issuer/face/required valuation metadata/completed facts. Changed definitions/missing issuers explicit migration/recovery, no silent 1:1/discard/reissue/payment replay/old-session callback. User: “3. Yes” to fifth interview.

The [specification](systems/ITEM/ITEM-009.md) is approved and finalized v1 under ITEM-009-A01. No implementation/coding tasks authorized.

## ITEM-008 interview decisions

- **ITEM-008-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-008 Draft v1. The [specification](systems/ITEM/ITEM-008.md) is finalized v1, including checked weighted admission, overweight possession retention, weightless intake, 750 kg wagon baseline, Strength-based player capacity, single-count load, decimal weights/consistent precision, meaningful display, moddable physical-wagon access, dungeon/commit-time revalidation, fitting quantities and coherent persistence. Documented weight/gold schemas, modifier composition, accounting conversion/migration, spatial boundaries, physical-wagon lifecycle and native admission/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-008-D01 — 2026-11-10:** Positive-weight intake exceeding capacity rejects; capacity loss may leave overweight possessions without deletion/forced drop. MOVE-005 no-penalty vanilla movement retained. User: “1. Yes” to first interview.
- **ITEM-008-D02 — 2026-11-10:** Genuine zero-effective-weight intake allowed at/above weight capacity, other restrictions enforced; no-encumbrance explicit validated data. User: “2. Yes” to first interview.
- **ITEM-008-D03 — 2026-11-10:** Wagon 750 kg initial validated configurable baseline, contents separate from carried weight; access alone no movement/ownership change. User: “3. Yes” to first interview.
- **ITEM-008-D04 — 2026-11-10:** Base player capacity floor(live Strength×1.5) kg with validated overrides; source-owned CHAR/MAGIC bonuses, no duplicate recalculation contributions. User: “1. Yes” to second interview.
- **ITEM-008-D05 — 2026-11-10:** Carried/equipped effective weight×quantity counted once; physical balance-represented gold included, wagon/nonphysical financial balances excluded. ITEM-009 owns detailed representation. User: “2. Yes” to second interview.
- **ITEM-008-D06 — 2026-11-10:** Classic 2.5 g initial accounting baseline, defined nearest-even conversions/integer accounting, positive weight cannot silently round to weightless, genuine zero valid. Finer-denomination support required. User: “3. Yes, but it would be nice to support finer weight denominations, say 0.1, or 0.15, that kind of thing.” Example units/quantum/UI precision unresolved; no inferred unit adopted.
- **ITEM-008-D06 clarification — 2026-11-10:** User clarified “kg in this case.” Required examples are 0.1 kg/0.15 kg, exactly representable at baseline 2.5 g precision. Validated finer-precision profile support remains; no particular sub-gram quantum selected. Supersedes the unresolved-unit note above.
- **ITEM-008-D07 — 2026-11-10:** Accounting precision sufficient for configured content, consistent conversion of all participating weights/loads/capacities; no inconsistent per-transfer conversion. User: “2. Yes” to third interview.
- **ITEM-008-D08 — 2026-11-10:** Display sufficient decimal places for meaningful weights; admission uses authoritative values, not rounded UI text. User: “3. Yes” to third interview.
- **ITEM-008-D09 — 2026-11-10:** Baseline owned exterior wagon access without physical parking; ordinary interiors deny absent explicit supported interaction. Required moddability includes physical-wagon location/reach/availability models. User: “1. Yes, but support this being moddable, say if somebody wanted to make a mod that has a physical wagon, that sort of thing.” to fourth interview.
- **ITEM-008-D10 — 2026-11-10:** Dungeon exit access initial within 5 metres, configurable, cart/original exit/context revalidated; MOVE-022 Access/Leave/Cancel retained. User: “2. Yes” to fourth interview.
- **ITEM-008-D11 — 2026-11-10:** Revalidate wagon ownership/access at transfer commit; loss blocks further moves with feedback, no content loss/retarget/automatic movement. User: “3. Yes” to fourth interview.
- **ITEM-008-D12 — 2026-11-10:** Maximum whole fitting quantity/exact fills; explicit quantity all-or-nothing, explicit take-what-fits takes max and leaves remainder with feedback. User: “1. Yes” to fifth interview.
- **ITEM-008-D13 — 2026-11-10:** Current capacity/load at commit; capacity loss no deletion, overweight removal/weightless intake permitted under other rules, positive-weight intake blocked. Zero capacity valid, negative/malformed explicit failure. User: “2. Yes” to fifth interview.
- **ITEM-008-D14 — 2026-11-10:** Save authoritative contents/ownership/required modifiers; rebuild load/access without movement/duplicate bonuses. Physical-wagon persistent identity/location and missing-provider recovery required; unavailable storage not empty. User: “3. Yes” to fifth interview.

The [specification](systems/ITEM/ITEM-008.md) is approved and finalized v1 under ITEM-008-A01. No implementation/coding tasks authorized.

## ITEM-007 interview decisions

- **ITEM-007-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-007 Draft v1. The [specification](systems/ITEM/ITEM-007.md) is finalized v1, including checked single transfer, same-collection no-op, pure deterministic retrieval, explicit atomic/partial bulk modes, authorized copy/replacement, owner restrictions, distinct query failures and coherent no-replay persistence. Documented admission/lifecycle schemas, batch commitment/recovery, concrete partial-batch policies, query/error schemas, copy/replacement authorization/reference disposition and native persistence/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-007-D01 — 2026-11-10:** Single transfer validates source/access/quantity/full destination plan before commit; approved split/merge identities, rejection leaves both collections unchanged. User: “1. Yes” to first interview.
- **ITEM-007-D02 — 2026-11-10:** Valid same-collection transfer explicit no-op, no remove/merge/duplicate/reorder; separate reordering/consolidation. User: “2. Yes” to first interview.
- **ITEM-007-D03 — 2026-11-10:** Pure filtered retrieval with stable-ID selection, optional summoned-first shortest lifetime then stable ID. No query permission to consume/transfer; revalidate at commit, ammo-specific rules binding. User: “3. Yes” to first interview.
- **ITEM-007-D04 — 2026-11-10:** Explicit whole-batch all-or-nothing mode; separate deterministic take-what-fits mode reports exact moved/remaining items and reasons, no silent skipped-failure success. User: “1. Yes” to second interview.
- **ITEM-007-D05 — 2026-11-10:** Copy separate from transfer, authorized generation/debug/content only with fresh identities/type-aware handling; ordinary movement cannot clone items/resources/unique rewards. User: “2. Yes” to second interview.
- **ITEM-007-D06 — 2026-11-10:** Replacement/import privileged restore or explicitly authorized; validate whole replacement/reference cleanup before discard, failure preserves original. Imported references cannot duplicate authoritative ownership. User: “3. Yes” to second interview.
- **ITEM-007-D07 — 2026-11-10:** Both ends' access/capacity/quest/property/equipment/source-effect requirements validated by owners; no silent unequip/effect suppression/legalization. Required transitions explicitly authorized/coordinated. User: “1. Yes” to third interview.
- **ITEM-007-D08 — 2026-11-10:** No-match distinct from missing definitions/invalid filters/unavailable collections/provider failure. Queries exclude expired/invalid candidates without mutation; cleanup owner-controlled, errors not fake empty inventories. User: “2. Yes” to third interview.
- **ITEM-007-D09 — 2026-11-10:** Revalidate current item/custody/session at commit; retain completed facts against retry duplication. Coherent or supported pending saves, otherwise explained temporary block. No load replay/old-session callbacks. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-007.md) is approved and finalized v1 under ITEM-007-A01. No implementation or coding tasks authorized.

## ITEM-006 interview decisions

- **ITEM-006-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-006 Draft v1. The [specification](systems/ITEM/ITEM-006.md) is finalized v1, including same-collection/full-count split semantics, type-aware state preservation, whole-split validation, extraction versus consumption, once-only settlement, conserving shared-resource allocation, singleton handling, deterministic unit selection and coherent persistence. Documented split/allocation schemas, selection, admission/transfer staging, operation/recovery receipts, consumption/effect coordination and native persistence/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-006-D01 — 2026-11-10:** Standalone split creates separate same-collection entry; full count returns original without custody change. Transfer required for movement, no unowned result. User: “1. Yes” to first interview.
- **ITEM-006-D02 — 2026-11-10:** Type-aware split preserves actual contents/provider/condition/knowledge/dye/expiry/provenance; no accidental mutable sharing. Unsupported special-state split rejects unchanged, no generic copy. User: “2. Yes” to first interview.
- **ITEM-006-D03 — 2026-11-10:** Validate access/quantity/entry capacity/caps/state handling before reducing source. Failed result creation leaves original unchanged; explicit quantity/original/new identity results. User: “3. Yes” to first interview.
- **ITEM-006-D04 — 2026-11-10:** Consumption distinct from extraction; last-unit consumption retires, extraction preserves contents under split/transfer. Quantity removal alone invokes no spell/reward/use effect. User: “1. Yes” to second interview.
- **ITEM-006-D05 — 2026-11-10:** Owning action coordinates consumption/effect/projectile/payment/reward once; no repeated callback double-consume/grant. Pre-commit failure unchanged, partial failure retains facts/recovery under approved action rules. User: “2. Yes” to second interview.
- **ITEM-006-D06 — 2026-11-10:** No duplication of stack-wide finite charges/souls/unique entitlements. Explicit conserving allocation or split rejection; ordinary per-unit property retention distinct from multiplying limited resources. User: “3. Yes” to second interview.
- **ITEM-006-D07 — 2026-11-10:** Valid full-count/singleton requests return existing entry unchanged even when ineligible to stack; partial split needs supported representation. Return grants no use/transfer permission. User: “1. Yes” to third interview.
- **ITEM-006-D08 — 2026-11-10:** Interchangeable stacks need no unit selector; supported heterogeneous types use declared deterministic allocation/selection and honor supported explicit unit requests. No silent valuable-unit choice or reroll. User: “2. Yes” to third interview.
- **ITEM-006-D09 — 2026-11-10:** Coherent completed or explicitly supported pending saves, otherwise explained temporary blocking. Load preserves quantity/identity/allocation/completed effects without replay; stale-session callbacks cannot consume again; action-specific rules binding. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-006.md) is approved and finalized v1 under ITEM-006-A01. No implementation or coding tasks authorized.

## ITEM-005 interview decisions

- **ITEM-005-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-005 Draft v1. The [specification](systems/ITEM/ITEM-005.md) is finalized v1, including state-preserving compatibility, validation before mutation, explicit outcomes, uncapped default/configurable caps, stable destination order, cosmetic distinctions, all-or-nothing capped distribution, explicit-target/no-stack modes, quantity validity, preserved saved stacks and admission constraints. Documented compatibility/numeric/identity schemas, multi-destination receipts, whole-plan commitment/retry, admission/custody and native migration/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-005-D01 — 2026-11-10:** Both items eligible and relevant gameplay state/contents/knowledge/expiry/provenance compatible before merge. No averaging/discarding/destination-state replacement. Custom compatibility complete; unknown required state prevents merge. User: “1. Yes” to first interview.
- **ITEM-005-D02 — 2026-11-10:** Identity/custody/quantity/request validation before mutation. Self/repeated insertion cannot increase quantity; distinct objects claiming one identity fail explicitly. User: “2. Yes” to first interview.
- **ITEM-005-D03 — 2026-11-10:** Explicit separate-insert/merge/reject result with surviving identity/quantity changes. Failure preserves items/counts. No-stack supported without identity/ownership bypass. User: “3. Yes” to first interview.
- **ITEM-005-D04 — 2026-11-10:** No default gameplay cap; explicit type/template caps supported. Validated numeric quantity bounds; overflow rejects without mutation. User: “1. Yes” to second interview.
- **ITEM-005-D05 — 2026-11-10:** Automatic compatible destination selected deterministically by stable item identity; explicit target validated. Sorting cannot change surviving stack. User: “2. Yes” to second interview.
- **ITEM-005-D06 — 2026-11-10:** Persistent style/dye differences stay separate unless type explicitly preserves them within stack. Wearer-dependent rendering alone does not prevent compatibility. User: “3. Yes” to second interview.
- **ITEM-005-D07 — 2026-11-10:** Automatic capped insertion fills compatible stacks in stable-ID order then creates capped remainder stacks. Whole plan validated before mutation; inability rejects entire insertion. ITEM-001 split identities binding. User: “1. Yes” to third interview.
- **ITEM-005-D08 — 2026-11-10:** Explicit one-stack destination accepts entire requested quantity or rejects, no silent distribution. Automatic distribution separate request mode. User: “2. Yes” to third interview.
- **ITEM-005-D09 — 2026-11-10:** Restore distinct saved stacks without auto-merge. Changed caps/eligibility/compatibility need explicit migration/recovery preserving quantity/state; no silent truncation/discard/reinterpretation. User: “3. Yes” to third interview.
- **ITEM-005-D10 — 2026-11-10:** Positive whole quantities only; zero/negative/fractional/out-of-range/over-available reject unchanged. Last-unit consumption removes/retires stack, no live zero-count stacks; ITEM-006 details. User: “1. Yes” to fourth interview.
- **ITEM-005-D11 — 2026-11-10:** No-stack means no existing-entry merge, not cap bypass. Over-cap quantities become separate capped entries with whole-plan validation. User: “2. Yes” to fourth interview.
- **ITEM-005-D12 — 2026-11-10:** No weight/entry/access/custody bypass; transfer/grant owners validate planned admission. No implicit total weight/value compression; special container effects explicit elsewhere. User: “3. Yes” to fourth interview.

The [specification](systems/ITEM/ITEM-005.md) is approved and finalized v1 under ITEM-005-A01. No implementation or coding tasks authorized.

## ITEM-004 interview decisions

- **ITEM-004-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-004 Draft v1. The [specification](systems/ITEM/ITEM-004.md) is finalized v1, including construction without activation, retained actual contents, explicit/random pools and quantities, declared resource profiles, separated value/capacity/prices, recipe validation, generated souls, ingredient eligibility, enchanted-ammo boundaries, knowledge/artifact rules and grant/save recovery. Documented concrete generation/value/resource profiles, content/compatibility schemas, pools, identification/artifact restrictions, stack/copy preservation, grant recovery and native persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-004-D01 — 2026-11-10:** Construction does not cast/consume ingredients/trigger equip or use/reward; crafting/purchase owners separately authorize costs and grants. User: “1. Yes” to first interview.
- **ITEM-004-D02 — 2026-11-10:** Retain actual selected enchantments/spell payloads/potion contents/stored soul data plus stable references/compatibility versions. No silent replacement by changed recipe/template; compatible changes explicit owner policy, incompatible changes migration or failure. User: “2. Yes” to first interview.
- **ITEM-004-D03 — 2026-11-10:** Explicit supported definition/contents/quantity honored; random generation uses declared owner pools and retained results, not all registrations automatically. Explicit classic-only/expanded pools supported. User: “3. Yes” to first interview.
- **ITEM-004-D04 — 2026-11-10:** Explicit profiles define condition/separate charges/other approved resource and initialization; no universal durability overwrite by uses. Classic shared-condition profiles explicit under MAGIC-016. User: “1. Yes” to second interview.
- **ITEM-004-D05 — 2026-11-10:** Separate generated base value, capacity, crafting costs and merchant quotes with owner calculations. DFU enchantment sum and 5000+SoulPts are unadopted candidate value profiles. User: “2. Yes” to second interview.
- **ITEM-004-D06 — 2026-11-10:** Validate recipes/effects/providers/contents/quantities before publication; unknown recipes fail. Recipe construction/reading does not brew or grant ingredients; learning/brewing owner features separate. User: “3. Yes” to second interview.
- **ITEM-004-D07 — 2026-11-10:** Authorized generation may create one valid compatible stored soul without death/capture/rewards, preserving soul data; live capture remains MAGIC-027. Random souls use validated eligible pool, no invalid-creature rejection loop. User: “1. Yes” to third interview.
- **ITEM-004-D08 — 2026-11-10:** Explicit ingredient definition/quantity honored; random declared groups/pools, no implicit equal group probabilities/all-mod inclusion. Empty/unsupported pools fail without substitution. User: “2. Yes” to third interview.
- **ITEM-004-D09 — 2026-11-10:** Validate base/powers/providers/resources before magic-item grant; generation eligibility/capacity differences explicitly declared. Ordinary baseline excludes enchanted arrows; custom ammo needs explicit compatible COMBAT-008 profile. User: “3. Yes” to third interview.
- **ITEM-004-D10 — 2026-11-10:** Actual contents separate from knowledge; generation explicitly sets identification state. Construction/inspection cannot reveal/change hidden powers; detailed identification owner-defined. User: “1. Yes” to fourth interview.
- **ITEM-004-D11 — 2026-11-10:** Regular magic pools exclude artifacts; explicit authorized artifact profile enforces approved behavior and declared uniqueness/quest restrictions. Registration alone grants no loot eligibility/universal uniqueness. User: “2. Yes” to fourth interview.
- **ITEM-004-D12 — 2026-11-10:** Retain resolved contents/quantity/resources/progress until grant/recovery. No retry reroll/duplicate grant/double charge. Coherent or explicitly supported pending saves, otherwise explained temporary block. Load cannot activate/capture/refill. User: “3. Yes” to fourth interview.

The [specification](systems/ITEM/ITEM-004.md) is approved and finalized v1 under ITEM-004-A01. No implementation or coding tasks authorized.

## ITEM-003 interview decisions

- **ITEM-003-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-003 Draft v1. The [specification](systems/ITEM/ITEM-003.md) is finalized v1, including baseline material property tables/rounding, construction without compounding or free repair, explicit condition/body inputs, compatible variants/dyes, arrow quantity/material rules, wearer adaptation, retained owned generation and checked grant recovery. Documented material/numeric schemas and fixtures, appearance inventories/defaults, Chain2 interpretation, worn-state bounds, custom adapters, generation/grant recovery and native compatibility/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-003-D01 — 2026-11-10:** Separate mechanical material/category from visual variant/dye/body appearance; cosmetics alone cannot change damage/protection/weight/durability/value without declared gameplay rule. User: “1. Yes” to first interview.
- **ITEM-003-D02 — 2026-11-10:** Derive material properties from validated base/profile, not compounded instance multipliers. Display/rebuild cannot grant bonuses or repair; later material change needs explicit transformation rules. User: “2. Yes” to first interview.
- **ITEM-003-D03 — 2026-11-10:** Classic weapon materials and leather/chain/plate initial baseline; validated added materials/categories supported. Actual formulas/constants reviewed separately. User: “3. Yes” to first interview.
- **ITEM-003-D04 — 2026-11-10:** DFU base-value/weight/max-condition material tables/formulas initial baseline, validated overrides supported. Steel example 6× value/~1.25× quarter-kg-rounded weight/1.5× integer-truncated condition; leather half weight, chain double value. Merchant/combat formulas separate. User: “1. Yes” to second interview.
- **ITEM-003-D05 — 2026-11-10:** Ordinary new equipment full condition; authorized generation profiles may explicitly request worn condition. Load/inspection/rebuild never refill existing items. User: “2. Yes” to second interview.
- **ITEM-003-D06 — 2026-11-10:** Explicit intended wearer/body appearance input, no implicit current-player construction context. Appearance alone imposes no race/gender equip restriction; actual fit rules explicit and equipment-owned. User: “3. Yes” to second interview.
- **ITEM-003-D07 — 2026-11-10:** DFU compatible armor visual combinations baseline; random only among compatible variants. Explicit invalid combination errors rather than silent clamp; declared defaults/random valid, validated mod combinations supported. User: “1. Yes” to third interview.
- **ITEM-003-D08 — 2026-11-10:** Material-based weapon/armor default colors; DFU ten-color random clothing baseline; explicit supported overrides. Color mechanically separate and instance-isolated; recoloring service/cost/availability deferred. User: “2. Yes” to third interview.
- **ITEM-003-D09 — 2026-11-10:** Explicit arrows specify quantity/definition; random loot may use declared 1–20 baseline. Classic arrows material-neutral, custom material behavior explicit under ammo contracts. No silent ignored material/randomized explicit quantity. User: “3. Yes” to third interview.
- **ITEM-003-D10 — 2026-11-10:** Current-wearer appearance adaptation where supported retains identity/material/style/dye/condition. Missing required support explicit unsupported or separately approved fallback; actual equip restrictions binding. User: “1. Yes” to fourth interview.
- **ITEM-003-D11 — 2026-11-10:** Explicit generation context/owned RNG for template/variant/dye/quantity alongside RULE-026 materials. Retain resolved results across retry/save; no inspect/load rerolls. Loot/merchant owners define pools/distributions, no automatic all-registration pool. User: “2. Yes” to fourth interview.
- **ITEM-003-D12 — 2026-11-10:** Validate complete combination before grant; no partial/default substitute for missing material/visual/provider support. Failed construction cannot consume entitlement/payment without retained owner recovery obligation. User: “3. Yes” to fourth interview.

The [specification](systems/ITEM/ITEM-003.md) is approved and finalized v1 under ITEM-003-A01. No implementation or coding tasks authorized.

## ITEM-002 interview decisions

- **ITEM-002-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-002 Draft v1. The [specification](systems/ITEM/ITEM-002.md) is finalized v1, including stable behavior-provider keys, validated conflict/composition rules, explicit dispatch outcomes, quest/access validation, deferred revalidation, partial-commit recovery, versioned custom state, shared authoritative use and coherent pending-save boundaries. Documented provider/registry lifecycle, composition, quest arbitration, pending/commit/recovery, migration, caller permissions and native persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-002-D01 — 2026-11-10:** Allow data-only additions using supported existing behaviors; special items select validated providers by stable keys independent of programming class names. User: “1. Yes” to first interview.
- **ITEM-002-D02 — 2026-11-10:** One resolved authoritative use behavior per item; combinations explicitly declared/ordered. Competing registrations use validated replacement rules or conflict failure, never silent registration-timing precedence. User: “2. Yes” to first interview.
- **ITEM-002-D03 — 2026-11-10:** Explicit handled/not-applicable/blocked/failed outcomes. Only not applicable permits next declared behavior; blocked/failed actions cannot fall through into unintended built-in use/consumption/equipment. User: “3. Yes” to first interview.
- **ITEM-002-D04 — 2026-11-10:** Access/quest restrictions validated before custom execution; quest interception versus ordinary use explicitly declared per interaction, no ordering bypass. QUEST owns detailed responses. User: “1. Yes” to second interview.
- **ITEM-002-D05 — 2026-11-10:** Deferred picker/menu/confirmation owns a pending interaction and stops dispatch. Revalidate identity/custody/access/session/eligibility/resources at commitment; cancellation follows approved action-specific cost rules including retained committed magic costs. User: “2. Yes” to second interview.
- **ITEM-002-D06 — 2026-11-10:** Separate pre-mutation rejection from partial-commit failure. Retain completed effects/costs and explicit recovery; no blind retry/fallthrough/unsupported refunds. Providers declare commitment/recovery rules. User: “3. Yes” to second interview.
- **ITEM-002-D07 — 2026-11-10:** Versioned provider-owned custom item state preserves applicable charges/modes/cooldowns/resolved random properties; unsupported versions require migration or explicit failure, no silent reset. User: “1. Yes” to third interview.
- **ITEM-002-D08 — 2026-11-10:** Inventory/hotkey/controller/script use shares authoritative validation with explicit actor/item/context; preview/selection cannot activate. Caller-specific permissions declared. User: “2. Yes” to third interview.
- **ITEM-002-D09 — 2026-11-10:** Save at coherent boundaries; explicitly supported pending snapshots or explained temporary save block until completion/cancellation. Load cannot auto-confirm/double-spend/replay effects/accept old-session callbacks; approved action-specific save rules binding. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-002.md) is approved and finalized v1 under ITEM-002-A01. No implementation or coding tasks authorized.

## ITEM-001 interview decisions

- **ITEM-001-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize ITEM-001 Draft v1. The [specification](systems/ITEM/ITEM-001.md) is finalized v1, including stable item lifetime, stack split/merge identity, explicit transformation semantics, duplicate-ID failure, retired identities, content compatibility, authoritative custody, deliberate reference updates and session-safe restore/branches. Documented allocation/session, custody/transfer recovery, stack/reference, transformation and native compatibility/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **ITEM-001-D01 — 2026-11-10:** Preserve individual item identity through transfer, dropping/pickup, equipment, repair, identification, enchanting and save/load; genuinely new copies receive new identities. User: “1. Yes” to first interview.
- **ITEM-001-D02 — 2026-11-10:** One identity per interchangeable stack; partial split creates a new identity; merge retains destination identity. ITEM-005 retains detailed stack eligibility/property preservation. User: “2. Yes” to first interview.
- **ITEM-001-D03 — 2026-11-10:** Transformations explicitly declare identity behavior: same-object modifications preserve identity, consumption followed by creation produces new identity. No unrestricted DFU template-reset convention adopted. User: “3. Yes” to first interview.
- **ITEM-001-D04 — 2026-11-10:** Distinct restored items claiming one identity cause explicit compatibility failure before gameplay; no silent renumbering that could redirect equipment/quest/effect references. User: “1. Yes” to second interview.
- **ITEM-001-D05 — 2026-11-10:** Retire destroyed/consumed/merged-away identities without reuse within saved-game history. Stale requests fail safely; successful merge reports destination identity. User: “2. Yes” to second interview.
- **ITEM-001-D06 — 2026-11-10:** Template changes do not automatically reset saved condition/enchantments/quest links/other instance state. Owner-approved compatible changes may apply; incompatible changes require migration or explicit failure. DATA-010 remains binding; no universal snapshot policy chosen. User: “3. Yes” to second interview.

- **ITEM-001-D07 — 2026-11-10:** Each live item/stack has one authoritative custody/location; equipment can reference inventory without duplication. Transfers preserve identity without loss/duplicate ownership on failure. User: “1. Yes” to third interview.
- **ITEM-001-D08 — 2026-11-10:** Partial split retains existing references on original stack. Merged-away references do not silently redirect; callers may deliberately adopt reported destination after validation. Unsafe referenced items remain separate under ITEM-005. User: “2. Yes” to third interview.
- **ITEM-001-D09 — 2026-11-10:** Native load/save branches preserve identities; pending operations also validate active session context. Old callbacks cannot affect newly loaded items through matching IDs. No shared global branch registry required. User: “3. Yes” to third interview.

The [specification](systems/ITEM/ITEM-001.md) is approved and finalized v1 under ITEM-001-A01. No implementation or coding tasks authorized.

## MAGIC-030 interview decisions

- **MAGIC-030-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-030 Draft v1. The [specification](systems/MAGIC/MAGIC-030.md) is finalized v1, including source-owned career passives, environmental magery, individually reviewed Namira/Oghma/Mace/Masque/Razor/Rose/Skull/Wabbajack/Star profiles, explicit costs and lifecycle, mod-added artifacts and no-replay native persistence. Documented combat settlement, source/lifecycle, query/placement, content and migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-030-D01 — 2026-11-10:** Passive capabilities source-owned; rebuild cannot duplicate modifiers/periodic effects. Career/transformation/item provenance retained, mod passive profiles and explicit composition supported; no accidental duplicate shared-capability ticks. User: “1. Yes” to first interview.
- **MAGIC-030-D02 — 2026-11-10:** Career regen 1 health/four game minutes conditionally: Always; Darkness night or dungeon; Light daytime outside dungeon (including building); Water actual swimming. Amount/cadence/conditions moddable, actor-local context. User: “2. Yes” to first interview.
- **MAGIC-030-D03 — 2026-11-10:** Career sun/holy hazards use approved 12 health/four game minutes exposed; same vulnerability from career/vampire applies once by default. Explicit alternate stacking moddable; saved timing and approved protection/death owners. User: “3. Yes” to first interview.

- **MAGIC-030-D04 — 2026-11-10:** Light-Powered disadvantage night or anywhere indoors; Darkness-Powered disadvantage actual sunlight. Magical illumination no automatic override. Predicates/light-spell coupling moddable. User: “1. Yes” to second interview.
- **MAGIC-030-D05 — 2026-11-10:** Reduced power max-magicka modifier -floor(.33*raw max) for positive baseline, source-owned recomputation; falling capacity clamps, restored no refill. Factor/base/composition moddable. User: “2. Yes” to second interview.
- **MAGIC-030-D06 — 2026-11-10:** Unable-to-cast variant explicitly sets effective magicka capacity zero, not universal action prohibition or huge negative sentinel. Paid affordability normal, free/item/potion eligibility independent. Casting-block/preserved-magicka alternatives moddable. User: “3. Yes” to second interview.

- **MAGIC-030-D07 — 2026-11-10:** Namira retaliation from incoming physical D0: zero listed animal/Spriggan groups, floor(D0/2) Daedra, 2*D0 Undead, D0 otherwise. Explicit category/actor validation, moddable factors/triggers. Original incoming damage not reduced. User: “1. Yes” to third interview.
- **MAGIC-030-D08 — 2026-11-10:** Namira condition cost calculated retaliation amount, full available condition required. Last-condition valid activation completes then break once; zero retaliation no cost/damage. Partial/final-underfunded mod profiles supported. User: “2. Yes” to third interview.
- **MAGIC-030-D09 — 2026-11-10:** Once per qualifying incoming hit despite multiple copies; deterministic eligible source selection, only that source charged. Living wearer/no reflection-chain defaults retained, mod multi-source/bounded chains supported. Health/protection/death owner route without repeated weapon poison/wear/strikes. User: “3. Yes” to third interview.

- **MAGIC-030-D10 — 2026-11-10:** Oghma one valid book consumption and durable30-point entitlement commit together per CHAR-015. Failure retains book; UI failure cannot lose reward/consume another. User: “1. Yes” to fourth interview.
- **MAGIC-030-D11 — 2026-11-10:** Oghma joins existing reward order, no active allocation interruption/unsafe combat allocation, no actual level/ordinary HP grant. CHAR-015 caps/remainder confirmation/deferral retained; reward amount/eligibility moddable. User: “2. Yes” to fourth interview.
- **MAGIC-030-D12 — 2026-11-10:** Individually review remaining dedicated artifacts Azura Star/Molag Bal Mace/Clavicus Masque/Mehrunes Razor/Sanguine Rose/Skull/Wabbajack within030, preserving approved soul rules; explicit trigger/cost/target/persistence and mod-added artifact contracts. User: “3. Yes” to fourth interview.

- **MAGIC-030-D13 — 2026-11-10:** Mace positive-D0 strike, applicable magic save; target with magicka drains up to D0, otherwise Strength1–6. Gains bounded actual loss incl MAGIC-019 Strength floor; no duplicate drain save. Branches/amounts/defenses moddable. User: “1. Yes” to fifth interview.
- **MAGIC-030-D14 — 2026-11-10:** Mace explicit temporary source-owned magicka capacity/Strength cap exception permits over-normal transferred gains. Accumulate actual supported transfers; expire wielder bonuses12 game minutes without successful qualifying transfer. Expiry reconciles no refill/reversal victim drain. Lifetime/caps moddable. User: “2. Yes” to fifth interview.
- **MAGIC-030-D15 — 2026-11-10:** Mace accepted transfer costs D0 condition, full resource before mutation; resisted no special wear, ordinary wear separate. Valid last-condition completes before break. Missing required wielder state technical failure before victim drain. Cost/underfunded moddable. User: “3. Yes” to fifth interview.

- **MAGIC-030-D16 — 2026-11-10:** Equipped Masque grants trunc(live Personality/5) supported social-group reaction contribution, temporary source-owned not accumulating reputation. Recompute relevant changes/remove own only. Formula/groups/stacking moddable. User: “1. Yes” to sixth interview.
- **MAGIC-030-D17 — 2026-11-10:** Razor positive-D0 strike applicable magic save, permitted lethal attempt via protection/quest/death-prevention owners, no unconditional bypass/health setter. Eligibility/defenses/lethality moddable. User: “2. Yes” to sixth interview.
- **MAGIC-030-D18 — 2026-11-10:** Razor condition cost victim current health captured for accepted lethal attempt; full condition precommit. Resisted no special cost; later death prevention doesn't refund. Ordinary wear separate; explicit lethal payload not ambiguous additive damage. Costs/underfunded moddable. User: “3. Yes” to sixth interview.

- **MAGIC-030-D19 — 2026-11-10:** Rose requires non-allied enemy within12 reference units, creates one allied Daedroth for100 condition. Through-wall eligibility query, valid spawn placement; no enemy/technical spawn failure no special charge. Range/eligibility/type/quantity/cost moddable. User: “1. Yes” to seventh interview.
- **MAGIC-030-D20 — 2026-11-10:** Skull creates one allied actor of nearest non-allied enemy type within12 units for100 condition, deterministic distance ties. Copies type not unique identity/inventory/quest/rewards; selection/copied properties moddable with identity safety. User: “2. Yes” to seventh interview.
- **MAGIC-030-D21 — 2026-11-10:** Rose/Skull full condition precommit; prepare valid summon, creation/cost once, last-condition completes before break. No callback/load duplicate allies; postcommit source break/removal uses declared summon lifetime. User: “3. Yes” to seventh interview.

- **MAGIC-030-D22 — 2026-11-10:** Rose/Skull allies location-bound no default timer, persist same-location saves, end on caster location departure; no automatic door/Recall/travel following. Artifact removal doesn't dismiss. Lifetime/follow/dismiss/source alternatives moddable. User: “1. Yes” to eighth interview.
- **MAGIC-030-D23 — 2026-11-10:** Created allies no default loot/capturable soul/ordinary kill rewards/unique quest identity; retain combat and truthful action attribution. Inventory/souls/rewards explicit mod alternatives. User: “2. Yes” to eighth interview.
- **MAGIC-030-D24 — 2026-11-10:** Repeated valid paid uses can add allies, no invented one-summon cap. Mod active limits/replacement supported, each placement/payment independent; technical omission no charge, same-location restore no stat reroll. User: “3. Yes” to eighth interview.

- **MAGIC-030-D25 — 2026-11-10:** Wabbajack positive-D0 strike transforms eligible enemy into different monster from DFU pool, no additional magic save default. Quest-required protected absent supported outcome. Retain selected outcome, prevalidate form placement; eligibility/pool/defenses/costs moddable. User: “1. Yes” to ninth interview.
- **MAGIC-030-D26 — 2026-11-10:** Wabbajack carries absolute health deficit, Hnew=max(0,Mnew-deficit), lethal through death/prevention owners. Remaining physical strike resolves once against committed actor state, no lost/duplicate hit from scene replacement. User: “2. Yes” to ninth interview.
- **MAGIC-030-D27 — 2026-11-10:** Wabbajack same persistent encounter identity, once by default/no auto revert. Preserve authoritative inventory/ownership/attribution/applicable state via compatibility, no duplicate generated loot/original actor. No additional special condition wear, ordinary wear remains. Repeat/revert/cost alternatives moddable. User: “3. Yes” to ninth interview.

- **MAGIC-030-D28 — 2026-11-10:** Used Star releases stored soul, leaves reusable item empty, no creature/reward or extra special condition cost. Empty reports only, actual item revalidated. Release/cost/outcomes moddable. User: “1. Yes” to tenth interview.
- **MAGIC-030-D29 — 2026-11-10:** Star preserves MAGIC-027 shared one-soul/death capture arbitration and explicit equipped/container/stored-soul identities; load/equip/query cannot generate soul. Mod soul/container types same owners. User: “2. Yes” to tenth interview.
- **MAGIC-030-D30 — 2026-11-10:** Persist passive phase/artifact commits incl Oghma/Mace/summons/Wabbajack/souls without replay. Mod-added artifacts explicit trigger/cost/target/lifecycle contracts; required missing data migration/recovery, UI failure no repeat activation/cost/reward/RNG, partial operations retain checked recovery. User: “3. Yes” to tenth interview.

The complete [MAGIC-030 specification](systems/MAGIC/MAGIC-030.md) is **Approved — finalized v1** under MAGIC-030-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-029 interview decisions

- **MAGIC-029-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-029 Draft v1. The [specification](systems/MAGIC/MAGIC-029.md) is finalized v1, including elapsed infection milestones, condition/form separation, voluntary cooldown and lunar forcing, source-owned bonuses and form restrictions, no automatic healing, monthly urge, explicit crime/population policies, Hircine Ring exceptions, scoped cure and native persistence with mod-added transformation support. Documented action, transition, attribution, content and migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-029-D01 — 2026-11-10:** Curable infection then dedicated-cure established lycanthropy; infecting creature determines werewolf/wereboar. First accepted type retained, redundant exposure no reset/switch. Acquisition/types/windows moddable including new transformations. User: “1. Yes” to first interview.
- **MAGIC-029-D02 — 2026-11-10:** Warning at elapsed 24 game hours, establishment at 72, replacing source calendar-boundary/off-by-one timing. Initially hidden with diagnosis support, independent of video success. Establish in place without vampire absence/relocation. User: “2. Yes” to first interview.
- **MAGIC-029-D03 — 2026-11-10:** Persistent condition distinct from current form; preserve birth identity/independent abilities and CHAR-019 default compatibility/source cleanup. Mod forms/compatibility/reversion supported. Reversion removes form contributions, cure condition contributions. User: “3. Yes” to first interview.

- **MAGIC-029-D04 — 2026-11-10:** Voluntary beast entry once per elapsed 24 game hours, allowed at exact boundary, cooldown from successful voluntary entry; reversion allowed regardless. Explicitly replaces source strict comparison/both-direction timer. Eligibility/cooldown/timing moddable. User: “1. Yes” to second interview.
- **MAGIC-029-D05 — 2026-11-10:** Either full moon forces beast form at magic-round boundaries; brief voluntary reversion before next boundary retained. Forced entry bypasses voluntary cooldown. Full-moon end does not auto-revert absent explicit profile. Cadence/reversion moddable. User: “2. Yes” to second interview.
- **MAGIC-029-D06 — 2026-11-10:** No automatic healing/refill on acquisition/shapechange/reversion/cure. Remove only relevant infection/source contributions, preserve unrelated ailments/deficits. Replaces source broad acquisition cure and repeated full-health morph; explicit mod restoration supported. User: “3. Yes” to second interview.

- **MAGIC-029-D07 — 2026-11-10:** Both forms retain +40 STR/AGI/END/SPD; +30 Swimming/Running/Stealth/Critical Strike/Climbing/Hand-to-Hand/Jumping and disease immunity. Silver-or-better physical protection beast-only. Source-owned capped/moddable bonuses and type/form overrides. User: “1. Yes” to third interview.
- **MAGIC-029-D08 — 2026-11-10:** Beast entry unequips both hands, uses werecreature attack profile; other equipment retained unless explicit form rule. Preserve item identity/condition/ownership, no drop/destroy; no automatic hand re-equip on revert. Shape changes validated through MOVE, no teleport/geometry bypass. User: “2. Yes” to third interview.
- **MAGIC-029-D09 — 2026-11-10:** Beast blocks ordinary inventory/conversation actions including shortcuts, with clear feedback/mod action policies. Morph Self explicitly permitted reversion route subject normal casting contract. Selected inventory/dialogue/spell/item alternatives moddable. User: “3. Yes” to third interview.

- **MAGIC-029-D10 — 2026-11-10:** After one game month without qualifying innocent kill, max-health limiter reduces capacity by 24 per additional game day, minimum limiter 4. Source-owned CHAR-018 clamp/no-refill. Qualifying kill resets timer/removes limiter without heal. Interval/penalty/minimum/acts moddable. User: “1. Yes” to fourth interview.
- **MAGIC-029-D11 — 2026-11-10:** Default qualifying victims mobile civilians/city watch, kills in either form. Authoritative attributed death, not callback/corpse query. Innocent category separate LAW legality. Victims/nonlethal satiation alternatives moddable. User: “2. Yes” to fourth interview.
- **MAGIC-029-D12 — 2026-11-10:** Default beast actions do not create ordinary player crime charges, but retain truthful LAW/NPC/QUEST incidents via explicit moddable attribution. Existing crimes persist; no transform erase. Hostility/population separate. User: “3. Yes” to fourth interview.

- **MAGIC-029-D13 — 2026-11-10:** Equipped Hircine Ring bypasses voluntary cooldown, suppresses full-moon forcing and suspends urge max-health penalty. Does not reset kill time/cure; removal restores current elapsed restrictions/limiter without heal/retroactive damage. Exceptions independently moddable. User: “1. Yes” to fifth interview.
- **MAGIC-029-D14 — 2026-11-10:** Beast suppresses new ordinary civilian spawns, not existing actors or quest-required spawn policies. No despawn/persistent population erase. Perceived-form fear/hostility via NPC, not omniscience. Spawn/reaction policies moddable. User: “2. Yes” to fifth interview.
- **MAGIC-029-D15 — 2026-11-10:** Matching werewolf/wereboar positive-initial-damage hit acquisition exact 0.6%, default player level>=2, explicit ordinary disease immunity bypass. One retained exposure/hit; compatibility/first-type retained. Sources/recipients/chance/bypass moddable; new transformations declare own acquisition. User: “3. Yes” to fifth interview.

- **MAGIC-029-D16 — 2026-11-10:** Dedicated cure safely reverts humanoid/removes lycanthropy-owned grants/modifiers/restrictions/urge limiter, preserving birth identity/learned abilities/equipment/unrelated effects. No healing/artificial time. Explicit quest completion/cleanup; cure requirements/benefits moddable. User: “1. Yes” to sixth interview.
- **MAGIC-029-D17 — 2026-11-10:** Rest/travel processes infection/lunar forcing/cooldown/urge chronologically, stopping when form change needs player control/invalidates activity. Forcing retains declared round cadence, mod clocks MAGIC-008; pause/load zero progression. User: “2. Yes” to sixth interview.
- **MAGIC-029-D18 — 2026-11-10:** Persist infection/type/form/cooldown/kill time/limiter/completed transition-cure facts without replay/heal/reroll/re-unequip/satiation reset/fresh Ring activation. New mod forms/conditions use MAGIC-028 shared versioned contracts; missing definitions migration/recovery. User: “3. Yes” to sixth interview.

The complete [MAGIC-029 specification](systems/MAGIC/MAGIC-029.md) is **Approved — finalized v1** under MAGIC-029-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-028 interview decisions

- **MAGIC-028-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-028 Draft v1. The [specification](systems/MAGIC/MAGIC-028.md) is finalized v1, including elapsed infection milestones, retained clan, apparent-death cemetery awakening, scoped vampire grants/cleanup, feeding/hazards/travel/rest restrictions, dedicated cure and explicit quest policies, native persistence and mod-added transformation conditions/forms beyond vampirism and lycanthropy. Documented content, time/exposure, transition, attribution and migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-028-D01 — 2026-11-10:** Curable infection precedes established vampirism; ordinary Cure Disease eligible before transformation, dedicated cure after. Stages/windows/remedies moddable; ordinary dispel cannot silently remove established condition. User: “1. Yes” to first interview.
- **MAGIC-028-D02 — 2026-11-10:** Default clan assigned from infection-acquisition region and retained through travel/load. Mod selectors may use infecting vampire/location/quest/spell. User: “2. Yes” to first interview.
- **MAGIC-028-D03 — 2026-11-10:** Preserve CHAR-019 one-active-condition default, no silent replacement of vampirism/lycanthropy. Redundant infection does not reset timer/reroll clan. Explicit compatible-condition/reinfection/strain mod profiles supported. User: “3. Yes” to first interview.

- **MAGIC-028-D04 — 2026-11-10:** Explicit elapsed 72-game-hour infection, warning after 24 game hours, replacing source calendar-boundary/off-by-one timing. Rest/travel chronological, pause/load zero elapsed. Timing/presentation moddable. User: “1. Yes” to second interview.
- **MAGIC-028-D05 — 2026-11-10:** Default apparent-death transformation includes two-week absence and suitable cemetery awakening at night. Time/destination/presentation moddable. Prevalidate destination; missing required content explicit recovery, not unrelated fallback. Not ordinary death/resurrection. User: “2. Yes” to second interview.
- **MAGIC-028-D06 — 2026-11-10:** Initially hidden infection, warning dream not automatic exact name/countdown. Diagnosis/mod UI may reveal more. Gameplay transformation independent of video success; no lost condition/repeated time jump/relocation/grants. User: “3. Yes” to second interview.

- **MAGIC-028-D07 — 2026-11-10:** Baseline +20 all attributes except INT, +30 Jumping/Running/Stealth/Critical Strike/Climbing/Hand-to-Hand; Anthotis also +20 INT. Source-owned modifiers subject approved moddable caps. Disease/paralysis immunity and Silver-or-better physical material protection explicit; bonuses/protections/clans moddable. User: “1. Yes” to third interview.
- **MAGIC-028-D08 — 2026-11-10:** Common Levitate/Charm Mortal/Calm Humanoid and DFU clan spell assignments, source-owned vampire entitlements preserving independent learned access on cure. Grants/casting profiles moddable; no load duplicates/resets. User: “2. Yes” to third interview.
- **MAGIC-028-D09 — 2026-11-10:** Transformation removes incubating infection and establishes vampire state without broad CureAll. Preserve unrelated disease/poison/drain/current deficits unless explicit mod profile cures; no automatic vital refill per CHAR-019. Starts satiated; restoration alternatives moddable. User: “3. Yes” to third interview.

- **MAGIC-028-D10 — 2026-11-10:** Default combat feeding on qualifying physical weapon/unarmed hit, no kill/separate interaction required. Explicit moddable target/hit predicates; timer refresh only, no extra healing/drain. Bite/sleeping-target/blood-source alternatives supported. User: “1. Yes” to fourth interview.
- **MAGIC-028-D11 — 2026-11-10:** Satiation inclusive through 24 game hours since feeding; hunger prevents rest start, no default added starvation damage. Duration/restrictions/penalties moddable. Pause/load zero elapsed; authorized time advances age hunger. User: “2. Yes” to fourth interview.
- **MAGIC-028-D12 — 2026-11-10:** Sunlight/holy-place vulnerabilities default 12 health every four game minutes while exposed; damage/cadence/exposure/clan moddable. Actor's actual environment, saved phase, approved damage/protection/death owners; no renderer/visual dependency. User: “3. Yes” to fourth interview.

- **MAGIC-028-D13 — 2026-11-10:** Vampire/ancient-vampire qualifying positive-initial-damage physical hits default infection source, exact 0.6% per hit with retained exposure roll. Default player level>=2; recipients/source/chance/trigger moddable. Explicit special-infection bypass ordinary disease resistance/immunity, not condition compatibility. User: “1. Yes” to fifth interview.
- **MAGIC-028-D14 — 2026-11-10:** Ordinary fast travel blocked at daytime start; nighttime departure allowed but no sunlight immunity. Travel processes actual elapsed/exposure and stops applicable harm/transformation events. Protected-daytime/alternate travel policies moddable. User: “2. Yes” to fifth interview.
- **MAGIC-028-D15 — 2026-11-10:** Rest interrupted at satiation expiry; long advances stop at actual infection-transformation milestone. Completed elapsed/effects once only, no finish-before-transform or hungry rest continuation. Interruption policies moddable. User: “3. Yes” to fifth interview.

- **MAGIC-028-D16 — 2026-11-10:** Dedicated cure removes vampire-owned modifiers/protections/hunger restrictions/presentation/ability entitlements without vital refill or artificial cleanup time advance. Preserve birth identity, independent spells/unrelated effects and required previous-clan history. Cure requirements/benefits moddable. User: “1. Yes” to sixth interview.
- **MAGIC-028-D17 — 2026-11-10:** Explicit QUEST/FACT policies own vampire social/clan/cure consequences; no blanket membership/reputation reset or quest-prefix deletion. Each affected quest declares transition outcome; no invented TODO consequences. Offerings/eligibility/social reactions moddable. User: “2. Yes” to sixth interview.
- **MAGIC-028-D18 — 2026-11-10:** Persist infection milestones/clan/feed time/hazard phase/completed transformation-cure-quest work without replay/reset. Required missing clan/cemetery/ability data explicit migration/recovery. Versioned mod stages/clans and feeding/hazard/cure alternatives supported. User: “3. Yes” to sixth interview.
- **MAGIC-028-D19 — 2026-11-10:** Explicit cross-feature extension requirement: support mod-added transformation conditions/forms beyond vampirism and lycanthropy, with complete lifecycle, identity, grant, compatibility and persistence contracts, not only edits to built-in transformations. Carries forward CHAR-019 and must inform MAGIC-029. User: “I'd like transformations like this and Lycanthropy to be supported through modding so more and different ones can be added”.

The complete [MAGIC-028 specification](systems/MAGIC/MAGIC-028.md) is **Approved — finalized v1** under MAGIC-028-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-027 interview decisions

- **MAGIC-027-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-027 Draft v1. The [specification](systems/MAGIC/MAGIC-027.md) is finalized v1, including prepared Open/Lock, deferred-batch Identify, temporary Create Item, scoped Soul Trap claims and lethal prevention, selected-bundle dispelling with item suppression, quest-safe durable banishment, mod alternatives and native persistence. Documented cost allocation, item/source lifecycle, death arbitration, quest and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-027-D01 — 2026-11-10:** Open/Lock default paid casts prepare one-use later eligible-door interaction. Invalid interactions preserve preparation; genuine eligible attempts consume even on lock-operation failure. Mod direct-target/projectile/container alternatives supported through explicit adapters. User: “1. Yes” to first interview.
- **MAGIC-027-D02 — 2026-11-10:** Default Open unlocks difficulty <= caster level; Lock assigns caster-level difficulty to unlocked door, not strengthening/weakening an existing lock. Formulas and magical/quest-lock exceptions moddable; special-item exceptions pending. User: “2. Yes” to first interview.
- **MAGIC-027-D03 — 2026-11-10:** Open requests opening, Lock closing through approved door authority respecting obstruction/occupancy, without crushing/barrier bypass. Lock state, motion and entry distinct; no lawful access/legal suppression granted. User: “3. Yes” to first interview.

- **MAGIC-027-D04 — 2026-11-10:** Prepared Open/Lock persists until used/explicitly canceled without ordinary expiry; same-effect recasts do not accumulate charges. Lifetime/charge moddable. If both prepared, explicit operation choice, not both on one activation. User: “1. Yes” to second interview.
- **MAGIC-027-D05 — 2026-11-10:** Capture effective caster level at release for later door operation; waiting-time level/equipment changes do not alter power. Explicit activation-time mod power allowed. User: “2. Yes” to second interview.
- **MAGIC-027-D06 — 2026-11-10:** Explicit stable Open-item profiles: item-origin bypasses spell chance, normally not level; Skeleton Key also bypasses interior magical/level locks, exterior retains level check. Quest locks require explicit override. No texture-based identity; exceptions moddable. User: “3. Yes” to second interview.

- **MAGIC-027-D07 — 2026-11-10:** Identify explicit selection-first/pay-per-batch exception to ordinary release payment. Opening/canceling costs no Identify magicka; bundled other effects retain normal costs. Implement deferred debit directly, no temporary refund/magicka generation from free/item routes. User: “1. Yes” to third interview.
- **MAGIC-027-D08 — 2026-11-10:** One charge per nonempty eligible unidentified-item batch; independent item success rolls, failed results paid, success persists. Empty/already identified selections incur no charge/roll. Later paid retries allowed; batch size/cost/chance/retries moddable. User: “2. Yes” to third interview.
- **MAGIC-027-D09 — 2026-11-10:** Default Identify accesses eligible caster-inventory items, revalidated before debit/mutation. Knowledge only, no repair/recharge/duplication/ownership transfer. Custom property/rule support; wagon/container/remote access requires explicit policy. User: “3. Yes” to third interview.

- **MAGIC-027-D10 — 2026-11-10:** Create Item defaults temporary with item-owned lifetime independent of casting effect; transfer/drop/trade/save cannot reset/permanentize. Safe inventory/equipment expiry; permanent/alternate lifetime mod policies explicit. User: “1. Yes” to fourth interview.
- **MAGIC-027-D11 — 2026-11-10:** DFU equipment choices default, data-driven moddable choices/materials/quantities/custom properties. Add carried inventory without auto-equip; prepare item/validate destination before once-only insertion; no duplicate/substitute on technical failure. User: “2. Yes” to fourth interview.
- **MAGIC-027-D12 — 2026-11-10:** Create Item post-cast picker cancelable unlike source; committed cost retained, opening creates nothing, confirmation creates once. Lifetime starts at successful creation, paused picker does not age it. Summoned arrows preserve COMBAT-008 no recoverable impact item. User: “3. Yes” to fourth interview.

- **MAGIC-027-D13 — 2026-11-10:** Soul Trap timed eligible-monster mark, capture chance at lethal outcome not marking; applicable admission defenses remain separate. Enemy classes/civilians default ineligible; additional soul actors/properties/containers moddable. User: “1. Yes” to fifth interview.
- **MAGIC-027-D14 — 2026-11-10:** Successful capture roll without eligible empty container prevents lethal outcome, target 1 health, clear feedback. Alternate ordinary-death/no-capture behavior moddable. Genuine new lethal attempt can check again; duplicate callbacks/load/technical retries cannot reroll same attempt. User: “2. Yes” to fifth interview.
- **MAGIC-027-D15 — 2026-11-10:** Marking caster's accessible carried containers, empty Azura's Star before ordinary empty soul traps; one captured soul per death. Priority/capacity/access moddable; equipped Star automatic capture shares once-only death resolution. Missing caster/access explicit outcome, never implicit player-inventory fallback. User: “3. Yes” to fifth interview.

- **MAGIC-027-D16 — 2026-11-10:** Default Dispel Magic selects one eligible bundle affecting caster; paid on cancel/failure. Success removes bundle's surviving eligible effects through owners, not prior damage. Individual/multi/other-target alternatives moddable. User: “1. Yes” to sixth interview.
- **MAGIC-027-D17 — 2026-11-10:** Caster's own ordinary spells automatically dispelled; external eligible effects use dispel chance. Explicit saved provenance, no live-caster requirement; data-driven eligibility independent of HUD icon. Disease/poison/curses/permanent NPC relationships not automatically ordinary dispellable spells. User: “2. Yes” to sixth interview.
- **MAGIC-027-D18 — 2026-11-10:** Eligible item effects removable without destroying/disenchanting item. Suppress continuous contribution until declared reactivation, normally fresh unequip/equip; no rebuild/load return. Genuine later use/recast may create new effect. Eligibility/reactivation moddable. User: “3. Yes” to sixth interview.

- **MAGIC-027-D19 — 2026-11-10:** Undead/Daedra dispels are banishment, not ordinary death/damage: no corpse/loot/soul/ordinary kill credit. Durable banished state prevents same-actor load/revisit recreation. Explicit mod rewards/outcomes supported. User: “1. Yes” to seventh interview.
- **MAGIC-027-D20 — 2026-11-10:** Quest-required actors protected absent supported explicit quest banishment outcome; do not destroy required actor or fabricate kill. Quest progression/eligibility/exemptions moddable through owners. User: “2. Yes” to seventh interview.
- **MAGIC-027-D21 — 2026-11-10:** Default banishment nearby matching Undead/Daedra within 14 reference units through walls, independent per-eligible-actor chance; dedicated query independent of detection buffs. Range/obstruction/category/resistance moddable; ordinary spell defenses only when profile explicitly requires. User: “3. Yes” to seventh interview.

- **MAGIC-027-D22 — 2026-11-10:** Same-caster compatible Soul Trap marks extend; different-caster marks independent, stable application-order resolution. Failed roll permits next eligible mark, first capture claims one soul. Successful roll/no-container invokes 1-health outcome and stops lethal attempt. Arbitration moddable. User: “1. Yes” to eighth interview.
- **MAGIC-027-D23 — 2026-11-10:** Dead/genuinely unavailable caster's claim skipped, other eligible claims or ordinary death proceed. Unloaded but persistently accessible inventory not automatically unavailable; inventory owner determines access. Technical access failure requires recovery, not fake empty inventory. User: “2. Yes” to eighth interview.
- **MAGIC-027-D24 — 2026-11-10:** Native restore retains prepared Open/Lock, temporary-item lifetimes, Soul Trap marks and item-dispel suppression without replay. Save coherent completed state; unresolved utility pickers/partial commits temporarily block saves with clear reason. No preparation reroll, extra identification/item/soul or suppressed-power reactivation on load. Mod timers use MAGIC-008 clocks/migration. User: “3. Yes” to eighth interview.

The complete [MAGIC-027 specification](systems/MAGIC/MAGIC-027.md) is **Approved — finalized v1** under MAGIC-027-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-026 interview decisions

- **MAGIC-026-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-026 Draft v1. The [specification](systems/MAGIC/MAGIC-026.md) is finalized v1, including lasting per-caster nonhostility, binary Charm/Pacify admission, combat cancellation with committed consequences preserved, hostile-action breaks, Comprehend Languages encounter bonuses, once-only language attempts/practice and native persistence. Documented NPC relationship, attribution, mod-policy and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-026-D01 — 2026-11-10:** Default Charm/Pacify produce nonhostility, not follower control/disposition bonuses. Preserve Charm enemy-class and Pacify group distinctions. Mods may redefine eligibility and add timed calm, disposition, allegiance or commands through explicit NPC contracts. User: “1. Yes” to first interview.
- **MAGIC-026-D02 — 2026-11-10:** Successful Charm/Pacify nonhostility has no default duration; qualifying attack or explicit NPC event may restore hostility. Duration, break conditions and hostility scope moddable. Result persists independently of transient spell application; load cannot silently restore hostility. User: “2. Yes” to first interview.
- **MAGIC-026-D03 — 2026-11-10:** Comprehend Languages defaults to timed encounter-language pacification bonus, compatible recasts extend duration. Formula/uses moddable including dialogue translation/other language interactions; not permanent learned skill. User: “3. Yes” to first interview.

- **MAGIC-026-D04 — 2026-11-10:** Successful pacification cancels unfinished attacks against protected actor and prevents new ones, preserving committed costs/recovery/intervals, released projectiles and committed effects. No damage rewind or automatic ongoing-poison removal. User: “1. Yes” to second interview.
- **MAGIC-026-D05 — 2026-11-10:** Successfully applied hostile action by protected actor ends that actor's pacification protection; misses/fully resisted effects retain it. Qualifying physical hit or accepted hostile magic may restore hostility despite shield-prevented health loss. Rejected attempts/environmental damage do not qualify by default. Pacifying application cannot immediately break its own result. Break predicates moddable. User: “2. Yes” to second interview.
- **MAGIC-026-D06 — 2026-11-10:** Pacification changes nonhostility without follower conversion, crime forgiveness, faction/quest mutation or kill/defeat rewards. Explicit NPC/quest eligibility/hostility overrides and modded broader consequences supported through owners. User: “3. Yes” to second interview.

- **MAGIC-026-D07 — 2026-11-10:** Comprehend Languages applies score bonus at eligible encounter, no separate buff-cast success roll. Chance settings use captured casting power; RULE-019 resolves 200-outcome check (e.g. +20 score adds 10 percentage points before cap). Expiry removes bonus without undoing successful pacification. User: “1. Yes” to third interview.
- **MAGIC-026-D08 — 2026-11-10:** Default automatic language check once when enemy first detects player; casting/improving buff does not retry. Quest-controlled actors excluded unless explicitly permitted. Timing/retries/exclusions moddable; UI/load cannot create extra attempts. User: “2. Yes” to third interview.
- **MAGIC-026-D09 — 2026-11-10:** One compatible Comprehend Languages incumbent by default; extend duration retaining existing bonus, not additive repeated bonuses. Strongest/replacement/custom composition moddable. No permanent skill increase; practice only qualifying encounters/ordinary casting rules. User: “3. Yes” to third interview.

- **MAGIC-026-D10 — 2026-11-10:** Charm/Pacify use normal effect chance, spell defenses and applicable saving throws with binary outcome, no partial nonhostility. Wrong-category unaffected. Eligibility/immunity/resistance alternatives moddable. User: “1. Yes” to fourth interview.
- **MAGIC-026-D11 — 2026-11-10:** Default pacification protects caster, not everyone; target can fight unrelated enemies. Attacker's qualifying offense ends applicable protection while another caster's independent protection survives. Caster-group/global calm mod profiles supported. Explicit scope replaces reliance on single hostility flag. User: “2. Yes” to fourth interview.
- **MAGIC-026-D12 — 2026-11-10:** Persist pacification and completed language-attempt results as NPC state independently of original caster presence. Load/revisit cannot reroll, forget success or duplicate practice. Default encounter practice 3 on success; 1 on non-Etiquette/Streetwise failure, subject CHAR rules and moddable policies. Comprehend Languages itself grants no permanent skill. User: “3. Yes” to fourth interview.

The complete [MAGIC-026 specification](systems/MAGIC/MAGIC-026.md) is **Approved — finalized v1** under MAGIC-026-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-025 interview decisions

- **MAGIC-025-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-025 Draft v1. The [specification](systems/MAGIC/MAGIC-025.md) is finalized v1, including source-owned Normal/True concealment, offensive break rules, moddable perception composition/counters, current-world compass detection, explicit Life/Undead through-wall shader/silhouette extensions, independent illumination and safe native reconstruction. Documented perception cadence, offensive/source lifecycle, query/renderer, light tuning and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-025-D01 — 2026-11-10:** Preserve distinct Invisibility, Chameleon and Shadow families; Normal breaks on qualifying offensive actions, True survives those actions. Perception and break conditions moddable by effect/spell/actor. Exact nonphysical triggers remain under review; approved COMBAT-011 positive-initial-physical-damage trigger retained. User: “1. Yes” to first interview.
- **MAGIC-025-D02 — 2026-11-10:** Source-owned concealment; removing one contribution cannot erase surviving sources. Compatible recasts extend duration by default; different families coexist without implicit multiplicative protection. Explicit moddable composition remains to define. User: “2. Yes” to first interview.
- **MAGIC-025-D03 — 2026-11-10:** Detection and illumination independent of concealment. Detection supplies information without automatic dispel or guaranteed attack hit; light grants no implicit detection. Explicit mod connections supported. User: “3. Yes” to first interview.

- **MAGIC-025-D04 — 2026-11-10:** Default magical offensive break occurs on successfully applied hostile effect (damage/drain/control), not cast alone; missed/fully resisted effects do not qualify. Healing/buffs/movement/potions/ordinary interactions do not break by default. COMBAT-011 physical positive-D0 trigger retained. Triggers moddable. User: “1. Yes” to second interview.
- **MAGIC-025-D05 — 2026-11-10:** Default illusion-check priority Invisibility, otherwise Chameleon (8% pass), otherwise Shadow (4% pass); Chameleon wins coexistence with Shadow. Individual illusion-check probabilities, not overall detection probabilities. Normal/True differ in breakability by default. Strengths/composition/enemy-specific counters moddable. User: “2. Yes” to second interview.
- **MAGIC-025-D06 — 2026-11-10:** Concealment grants no collision bypass/damage immunity/projectile cancellation or automatic hostility/last-known-position erasure. NPC owns subsequent tracking; explicit mod alternatives supported. User: “3. Yes” to second interview.

- **MAGIC-025-D07 — 2026-11-10:** Default detection senses through walls within 14 reference units, showing compass direction without names/exact contents/effect details. Moddable range/obstruction/presentation; no room discovery, unlocking or through-wall attack targeting. User: “1. Yes” to third interview.
- **MAGIC-025-D08 — 2026-11-10:** Default categories follow inspected DFU: Enemy class/monster actors regardless of hostility; Magic actors with active magical effects; Treasure nonempty loot containers including corpse loot. Enchanted container contents not automatically Magic targets. Categories/eligibility moddable. User: “2. Yes” to third interview.
- **MAGIC-025-D09 — 2026-11-10:** Refresh current detection membership during eligible gameplay independently of magic-round duration; respond to movement/death/looting/effect loss. Configurable query cadence, deduplicated markers, load rebuild without casts or unloaded-location information. User: “3. Yes” to third interview.
- **MAGIC-025-D10 — 2026-11-10:** Explicitly support mods resembling Oblivion-style Detect Life/Detect Undead: custom life/undead eligibility and shader-based silhouettes or other representations visible through solid walls. Detection category/query and presentation must be independently extensible so compass UI is not mandatory. Exact renderer/API remains technical design; baseline compass behavior remains D07. User's additional request: “make it more easy to mod this detect feature ... where it presents it more as a shader based thing ... through solid walls”. This authorizes the mod capability, not new default detection spells.

- **MAGIC-025-D11 — 2026-11-10:** Default Light is following magical candle; compatible recasts extend duration, not brightness/candle count. Color/brightness/range/placement/appearance moddable; support actor-centered glow/world-placed light profiles. Example MageLight variants not required default spells. User: “1. Yes” to fourth interview.
- **MAGIC-025-D12 — 2026-11-10:** Illumination does not automatically break/cancel concealment. Explicit NPC lighting/perception rules may consume light; mods can make illumination reveal actors or change detection chances. User: “2. Yes” to fourth interview.
- **MAGIC-025-D13 — 2026-11-10:** Load/scene changes rebuild eligible source-owned concealment/detection displays/lights without duration reset or duplication. Ended sources remove their own outputs; no permanent shader highlight residue. Optional visual failure cannot change authoritative concealment/detection eligibility. User: “3. Yes” to fourth interview.

The complete [MAGIC-025 specification](systems/MAGIC/MAGIC-025.md) is **Approved — finalized v1** under MAGIC-025-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-024 interview decisions

- **MAGIC-024-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-024 Draft v1. The [specification](systems/MAGIC/MAGIC-024.md) is finalized v1, including one-use persistent anchors, moddable limits/restrictions/interaction, paid post-cast choice, validated cross-context arrival, retained anchor on failure, fresh movement placement, zero default journey time and coherent native persistence. Documented world/placement, operation commitment, mod profile and recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-024-D01 — 2026-11-10:** Default one anchor; setting a new anchor replaces the previous one; successful Recall consumes it. Moddable anchor limits and consumption support reusable/multiple named anchors. User: “1. Yes” to first interview.
- **MAGIC-024-D02 — 2026-11-10:** Default set/recall across exterior, building and dungeon contexts without added combat/distance restrictions. Mod restrictions may depend on location, actor state or spell. MOVE-027 destination validity remains required; no silent unrelated destination. User: “2. Yes” to first interview.
- **MAGIC-024-D03 — 2026-11-10:** Keep post-cast Anchor/Teleport choice; cancellation or Recall without an anchor does not refund magicka. Payment/interaction policy moddable. Technical loading failure policy remains unresolved. User: “3. Yes” to first interview.

- **MAGIC-024-D04 — 2026-11-10:** Consume anchor only after successful arrival. Blocked destination/technical loading failure retains anchor without automatic committed-cast refund. Preserve valid departure context where possible, otherwise suspended explicit recovery; no silent alternate destination. User: “1. Yes” to second interview.
- **MAGIC-024-D05 — 2026-11-10:** Anchor persists indefinitely through native saves, rest and travel until replacement/successful use. Mod expiry/invalidation supported. Stable location identity/pose required; changed/missing content reports unavailable rather than silent deletion or guessed replacement. User: “2. Yes” to second interview.
- **MAGIC-024-D06 — 2026-11-10:** Successful Recall establishes fresh movement placement without departure momentum/fall distance. Restore anchored position/facing; determine current destination ground/water/active-effect context. Ongoing effects retain remaining durations; anchor does not restore old health/breath/character snapshot. Explicit alternate mod movement handoffs supported. User: “3. Yes” to second interview.

- **MAGIC-024-D07 — 2026-11-10:** Replace old anchor only after successful new capture/validation; failure preserves old. Default fixed world/location pose, no implicit moving actor/platform attachment; explicit attached-anchor mod profiles supported. User: “1. Yes” to third interview.
- **MAGIC-024-D08 — 2026-11-10:** Recall adds no distance-based game-time travel. Normal casting timing remains; choice/loading suspend gameplay without effect advancement, resource restoration or travel encounters from wall time. Explicit timed-journey mod profiles supported. User: “2. Yes” to third interview.
- **MAGIC-024-D09 — 2026-11-10:** One active Recall interaction/arrival per actor; repeated input cannot duplicate arrival or anchor consumption. Unresolved choice/arrival temporarily blocks saving with clear reason. Native load restores coherent committed anchor state without reopening choice/recasting/replaying arrival. User: “3. Yes” to third interview.

The complete [MAGIC-024 specification](systems/MAGIC/MAGIC-024.md) is **Approved — finalized v1** under MAGIC-024-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-023 interview decisions

- **MAGIC-023-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-023 Draft v1. The [specification](systems/MAGIC/MAGIC-023.md) is finalized v1, including source-owned traversal capabilities, approved MOVE formulas/transitions, highest-speed levitation resolution, independent water effects, Water Breathing full-reserve transition with mod alternatives and safe native restoration. Documented capability/NPC adapters, movement-transition fixtures, speed/breath profiles and native recovery/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-023-D01 — 2026-11-10:** Traversal capabilities source-owned, compatible recasts extend duration, last valid contributor governs end. Rebuild cannot multiply speed/reset timers/erase others. User: “1. Yes” to first interview.
- **MAGIC-023-D02 — 2026-11-10:** Default levitation uses approved MOVE-013 profile, not implicit caster-level speed. Explicit moddable speed/potency and deterministic source combination; no automatic multiplication. User: “2. Yes” to first interview.
- **MAGIC-023-D03 — 2026-11-10:** Water Breathing defaults to refilling breath, explicitly rejecting proposed reserve-preserving default; alternate systems moddable. Exact refill timing to clarify against source and CHAR contracts. User: “3. I'd say keep it to default Daggerfall here and refill breath, just make it moddable to have different systems if desired.”

- **MAGIC-023-D04 — 2026-11-10:** Water Breathing protects for active lifetime and last-source end underwater leaves full ordinary breath reserve; reserve-preserving/gradual/custom mod alternatives supported. Load not extra activation/refill. Source PlayerEntity counter-reset then fresh-reserve implementation is reference, not required representation. User: “1. Yes” to second interview; resolves D03 timing.
- **MAGIC-023-D05 — 2026-11-10:** Water Walking/Breathing/Levitation independent; swimming-speed water walk/levitation do not grant breath. Explicit combined/mod surface-support profiles allowed under MOVE. User: “2. Yes” to second interview.
- **MAGIC-023-D06 — 2026-11-10:** Default enhanced Jumping/Climbing capability uses approved MOVE formulas, no implicit caster-level strength or duplicate flag stacking. Declared duration scaling/custom movement profiles supported. User: “3. Yes” to second interview.

- **MAGIC-023-D07 — 2026-11-10:** Multiple eligible levitation speed sources default highest speed, stable source-order ties, not add/multiply. Mod selection/composition supported; boolean Jump/Climb/Water Walking formula applied once. User: “1. Yes” to third interview.
- **MAGIC-023-D08 — 2026-11-10:** Last-source loss immediately selects valid MOVE state without free grace/teleport/auto replacement. Preserve levitation fall/swim and Slow Fall fresh segment rules, Water Breathing full-reserve exception, independent other protections. User: “2. Yes” to third interview.
- **MAGIC-023-D09 — 2026-11-10:** Save source/timing/actual movement+hazard context without impulse/fall reset/extra breath grant on restore. Configurable truthful expiry warnings cannot extend effect; required geometry/source failures safe recovery, no arbitrary relocation. User: “3. Yes” to third interview.

The complete [MAGIC-023 specification](systems/MAGIC/MAGIC-023.md) is **Approved — finalized v1** under MAGIC-023-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-022 interview decisions

- **MAGIC-022-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-022 Draft v1. The [specification](systems/MAGIC/MAGIC-022.md) is finalized v1, including source-owned statuses/protections, Free Action suppression/prevention, separate paralysis cure, silence scope, forced physics, moddable Shield accounting/recast, elemental cancellation and safe native restoration. Documented classification/power inventories, action masks, Shield intake/refill adapters, elemental composition, mod schemas and native transition/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-022-D01 — 2026-11-10:** Restrictions/protections derived from surviving source contributions; one removal cannot clear another's paralysis/silence/immunity. Compatible recasts use explicit extension/family policy. User: “1. Yes” to first interview.
- **MAGIC-022-D02 — 2026-11-10:** Free Action prevents new paralysis AND suppresses existing paralysis's restrictions without curing/removing it. Restrictions return if Free Action ends while paralysis remains. Cure Paralyzation removes all eligible active paralysis without ongoing immunity; combined mod effects supported. User: “2. Yes” plus explicit suppression clarification to first interview. This extends the initial prevention-only recommendation.
- **MAGIC-022-D03 — 2026-11-10:** Default silence blocks ordinary spell ready/release and deliberate item casting absent explicit bypass; potion drinking and continuous/automatic item effects retain prior defaults. No automatic dialogue mute, ongoing-effect stop or free-cast exception; broader mod policies explicit. User: “3. Yes” to first interview.

- **MAGIC-022-D04 — 2026-11-10:** Suppressed paralysis ages normally, no pause/refresh; cure can remove while suppressed. Explicit alternate mod suppression/timing supported. User: “1. Yes” to second interview.
- **MAGIC-022-D05 — 2026-11-10:** Free Action expiry immediately restores surviving paralysis restrictions/interruption rules without undoing commits. Gaining freedom never resumes canceled attack/auto-casts blocked spell; fresh input. User: “2. Yes” to second interview.
- **MAGIC-022-D06 — 2026-11-10:** Paralysis blocks voluntary locomotion/ordinary combat, not gravity/falling/external forces/hazards; no world pause/invulnerability. Mod action rules supported, potion allowance and mod casting exceptions preserved. User: “3. Yes” to second interview.

- **MAGIC-022-D07 — 2026-11-10:** Default Shield covers ordinary incoming health damage after applicable calculation/resistance before pool loss/lethal prevention, including physical/magic/fall. Mod type coverage supported; no fatigue/magicka/max change or implicit lethal-operation protection. User: “1. Yes” to third interview.
- **MAGIC-022-D08 — 2026-11-10:** Shield tracks starting/remaining capacity, spends absorbed amount, passes overflow, ends depleted/expired; retain absorption versus actual loss. No automatic pause/load refill. Explicit moddable capacity/depletion/refill alternatives requested. User: “2. Yes, but this behavior should be moddable”.
- **MAGIC-022-D09 — 2026-11-10:** Compatible Shield recast extends duration/top-ups to original starting capacity without automatic cap increase, explicit exception to duration-only extension. Mod stronger replacement/independent/alternative cap-refill ordering supported. User: “3. Yes” to third interview.

- **MAGIC-022-D10 — 2026-11-10:** Eligible surviving elemental chance contributions add by element, resolved clamp 0–100; supply RULE-017 initial cancellation then remaining stages on fail. Separate from MAGIC-007 Spell Resistance, no duplicate checks; composition moddable. User: “1. Yes” to fourth interview.
- **MAGIC-022-D11 — 2026-11-10:** Paralysis/silence on-cast chance then binary RULE-017 save, R=0 cancel/nonzero full duration, no default round escape. Mod duration scaling/escape/stack alternatives; explicit hard immunity exceptions, Free Action suppression distinct cure. User: “2. Yes” to fourth interview.
- **MAGIC-022-D12 — 2026-11-10:** Save contribution/suppressed paralysis lifetime/Shield starting+remaining/check state; rebuild without refill or interruption replay. Truthful effective/suppressed UI, fresh input/no canceled attack or blocked-cast replay; cleanup coherent across sources. User: “3. Yes” to fourth interview.

The complete [MAGIC-022 specification](systems/MAGIC/MAGIC-022.md) is **Approved — finalized v1** under MAGIC-022-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-021 interview decisions

- **MAGIC-021-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-021 Draft v1. The [specification](systems/MAGIC/MAGIC-021.md) is finalized v1, including extensible disease profiles, default player/level protection and day boundaries, binary exposure save, same-type redundancy, scoped cure/natural recovery, attribute repair, chronological progression, knowledge and safe native persistence. Documented classic profile fixtures, susceptibility/cure/diagnosis schemas, special infection windows, NPC/calendar integration and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-021-D01 — 2026-11-10:** Explicit disease profiles declare susceptibility/incubation/cadence/finite-or-until-cured lifetime/payload/cure eligibility, extensible beyond classic IDs. Transformation infection exceptions explicit, not automatic ordinary behavior. User: “1. Yes” to first interview.
- **MAGIC-021-D02 — 2026-11-10:** Default ordinary disease susceptibility player-only level≥2; validated mod NPC infection/level protection changes supported with complete lifecycle/persistence, not silent discard. User: “2. Yes” to first interview.
- **MAGIC-021-D03 — 2026-11-10:** Default shared calendar-day progression, first at next day boundary after infection. Explicit elapsed-hour/real-time incubation profiles supported; no assumed full 24-hour wait. User: “3. Yes” to first interview.

- **MAGIC-021-D04 — 2026-11-10:** Default one RULE-017 binary exposure save R=0 reject/nonzero full disease, no progression saves. Mod potency/duration/recurring alternatives supported; hard-immunity/special-infection exceptions separately declared. User: “1. Yes” to second interview.
- **MAGIC-021-D05 — 2026-11-10:** Default same-type re-exposure leaves existing disease unchanged; distinct types coexist. Mod severity/refresh/replace/independent policies supported without hidden incubation/duration reroll. User: “2. Yes” to second interview.
- **MAGIC-021-D06 — 2026-11-10:** Cure Disease clears all eligible ordinary diseases including incubation, removing owned remaining penalties not lost pools. Selective remedy/special-infection cure windows configurable; established transformations use own cure, not automatic ordinary removal. User: “3. Yes” to second interview.

- **MAGIC-021-D07 — 2026-11-10:** Finite ordinary disease ends after declared progression count and removes remaining owned penalties, no lost-pool refill. Until-cured continues; lasting-aftereffect mod profiles explicit. Distinct from poison residual default. User: “1. Yes” to third interview.
- **MAGIC-021-D08 — 2026-11-10:** MAGIC-018 repair reduces current disease penalties without altering incubation/duration or preventing future damage. Permanent/other-source values retained; ordinary drain floor not inherited. Attribute-zero consequences use explicit owners. User: “2. Yes” to third interview.
- **MAGIC-021-D09 — 2026-11-10:** Full authorized-time chronological events only within active lifetime, settling consequences/death/applicable interruption; no cap discard, duplicate generic progression or extra damage beyond natural recovery. User: “3. Yes” to third interview.

- **MAGIC-021-D10 — 2026-11-10:** Resolve candidate disease selection/random duration once per accepted infection and payload RNG once/progression event; retain retry/save outcomes. Redundant same type cannot reroll incumbent. Mod weights/formulas supported. User: “1. Yes” to fourth interview.
- **MAGIC-021-D11 — 2026-11-10:** Profile symptoms/diagnosis/knowledge govern name/duration/incubation disclosure; no automatic exact hidden infection reveal. Hidden UI still progresses; preview no infection rolls/hidden-state leakage. User: “2. Yes” to fourth interview.
- **MAGIC-021-D12 — 2026-11-10:** Save infection/source/incubation/progression/remaining events/penalty repair/completed cure-recovery state without reinfection/replay. Original actor absence does not end ordinary disease; supported migration/recovery, transformations separately owned not replayed infection. User: “3. Yes” to fourth interview.

The complete [MAGIC-021 specification](systems/MAGIC/MAGIC-021.md) is **Approved — finalized v1** under MAGIC-021-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-020 interview decisions

- **MAGIC-020-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-020 Draft v1. The [specification](systems/MAGIC/MAGIC-020.md) is finalized v1, including extensible poison profiles, explicit onset/tick boundaries, same-type redundancy, binary exposure save, residual penalty repair/cure-all, mixed drug completion, chronological time advancement and retained native state/knowledge. Documented classic profile fixtures, immunity/payload classifications, dose/antidote/knowledge schemas, scheduler integration and native recovery/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-020-D01 — 2026-11-10:** Explicit poison onset/active duration/cadence/payload/persistent-penalty profiles, extensible beyond classic enum. Verified classic content baseline, MAGIC-008 timing alternatives; exact ranges/values need fixtures. User: “1. Yes” to first interview.
- **MAGIC-020-D02 — 2026-11-10:** Default same-type accepted re-exposure ignored without onset reset/duration extension/additional instance; distinct types coexist. Mod dose/refresh/replace/independent policies supported. Valid redundant/resisted weapon attempt still uses RULE-016 coating settlement. User: “2. Yes” to first interview.
- **MAGIC-020-D03 — 2026-11-10:** Progression completion stops ticks but leaves tracked repairable attribute penalties. Cure removes selected poison and remaining owned penalties, no refill of lost pools. Repair alone does not stop active poison damaging again. Cure scope remains open. User: “3. Yes” to first interview.

- **MAGIC-020-D04 — 2026-11-10:** Default exposure one RULE-017 binary save: R=0 rejects, nonzero admits full profile without tick saves. Mod potency/duration/recurring alternatives supported. Explicit immunity composition; no universal level-one exclusion inferred from source. User: “1. Yes” to second interview.
- **MAGIC-020-D05 — 2026-11-10:** Ordinary Cure Poison removes all poison instances including waiting and completed residual penalties; mod antidotes may select type/family/dose. Cure source admission/chance remains applicable; unrelated disease/drain untouched. User: “2. Yes” to second interview.
- **MAGIC-020-D06 — 2026-11-10:** Drug-like profiles support benefits/harms; default positive attribute contributions removed at progression end, declared repairable penalties remain. Pool gains already committed not reversed; cure removes own remaining contributions. Completion moddable; addiction/withdrawal/permanent rewards need explicit extra profiles. User: “3. Yes” to second interview.

- **MAGIC-020-D07 — 2026-11-10:** Positive delay first payload at elapsed onset; zero-delay initial payload immediate. Active tick count includes first application; explicit moddable scheduling, classic mappings verified separately. User: “1. Yes” to third interview.
- **MAGIC-020-D08 — 2026-11-10:** Attribute healing repairs eligible poison penalties without stopping active progression; later damage may recur. Source separation preserves other poison/bonus state. Remove completed empty record when no residual contributions. User: “2. Yes” to third interview.
- **MAGIC-020-D09 — 2026-11-10:** Chronological authorized-time events settle damage/exhaustion/death/cure before continuation; no catch-up discard or generic+specialized duplicate ticks. Stop at actual applicable interruption under MAGIC-008. User: “3. Yes” to third interview.

- **MAGIC-020-D10 — 2026-11-10:** Resolve accepted instance onset/duration once; genuine tick payload RNG once/tick, retained retry/save. Redundant same-type exposure cannot reroll existing state; after cure new accepted exposure distinct. User: “1. Yes” to fourth interview.
- **MAGIC-020-D11 — 2026-11-10:** Profiles control symptoms/identification/HUD knowledge; delay does not reveal exact poison/countdown/hidden effects automatically. Appropriate DFU-style symptoms baseline, explicit diagnosis/mod disclosures. Hidden UI does not stop progression. User: “2. Yes” to fourth interview.
- **MAGIC-020-D12 — 2026-11-10:** Save lifecycle/onset/ticks/residuals/repair/source/completed tick-cure state, no exposure/damage replay. Caster absence not ordinary poison removal. Coating receipt separate; symptoms/ticks no default fresh practice/attack/crime semantics. Reaction owners explicit. User: “3. Yes” to fourth interview.

The complete [MAGIC-020 specification](systems/MAGIC/MAGIC-020.md) is **Approved — finalized v1** under MAGIC-020-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-019 interview decisions

- **MAGIC-019-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-019 Draft v1. The [specification](systems/MAGIC/MAGIC-019.md) is finalized v1, including persistent bounded source drain, actual-loss resource transfer, same-attribute repair, moddable conversion/optional links, receiver validity and paired once-only recovery/persistence. Documented variant inventories, source reconciliation/repair adapters, authoritative loss reporting, conversion/link profiles and paired native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-019-D01 — 2026-11-10:** Default attribute drain is source-owned damage persisting until explicit repair/removal, permanent values unchanged. Timed mod alternatives supported; MAGIC-018 repair eligibility applies. User: “1. Yes” to first interview.
- **MAGIC-019-D02 — 2026-11-10:** Default accumulated ordinary drain limited to max(0,permanent attribute−1), avoiding hidden healing debt. Other penalties can still reduce final live value. Moddable floors/limit policies supported. User: “2. Yes” to first interview.
- **MAGIC-019-D03 — 2026-11-10:** Default resource transfer restores no more than target authoritative actual pool loss and receiver capacity; explicit mod conversion ratios supported. Overkill/immunity/empty target cannot generate gain; excess discarded not banked. User: “3. Yes” to first interview.

- **MAGIC-019-D04 — 2026-11-10:** Attribute transfer defaults to target drain plus repair of receiver's same-attribute eligible damage, capped by actual newly added target drain. Healthy receiver gains no fortification/permanent points; target may still be drained. Validated mod alternate/custom behavior explicitly supported. User: “1. Yes, but as you mentioned, make it so mods can change this behavior if desired, or add their own behavior, etc.”
- **MAGIC-019-D05 — 2026-11-10:** Full receiver does not reduce target resource damage; discard unavailable recovery. Fatigue transfers account in authoritative internal units, no double×64/rounding gain. User: “2. Yes” to second interview.
- **MAGIC-019-D06 — 2026-11-10:** Linked penalty/bonus supported explicit mod profile, not added vanilla spell. Must declare range/lifetime/validity/conservation/paired cleanup. Source VampiricFortifyEffect is WIP/not used by effects per class comment, not verified baseline. User: “3. Yes” to second interview.

- **MAGIC-019-D07 — 2026-11-10:** Baseline transfer requires valid living receiver at application; reject before target mutation if unavailable. Explicit profiles may permit damage without recovery. Persistent ordinary drain does not require ongoing original caster. User: “1. Yes” to third interview.
- **MAGIC-019-D08 — 2026-11-10:** Repeated accepted drains add only actual permitted penalty, retaining per-source repair/attribution/removal. Captured magnitude/retained resistance; existing drain not rerolled. At limit zero added penalty/zero transfer repair; persistent drain does not redamage each round merely to stay alive. User: “2. Yes” to third interview.
- **MAGIC-019-D09 — 2026-11-10:** Retain authoritative settled target result then receiver gain once. Technical second-step failure recovers without redamaging/refunding settled consequence. Health prevention/death/fatigue exhaustion settle before gain; dead receiver not resurrected. User: “3. Yes” to third interview.

- **MAGIC-019-D10 — 2026-11-10:** Permanent attribute increase leaves existing drain unchanged; decrease exceeding supported drain limit explicitly reconciles excess tracked drain under documented source order. No hidden healing debt or automatic new damage on later increase. Alternative mod limits supported. User: “1. Yes” to fourth interview.
- **MAGIC-019-D11 — 2026-11-10:** Mod links validate endpoint identities/range/lifetime and coherently remove paired temporary contributions on end, preserving unrelated modifiers/permanent ownership/committed pool loss. Pause/location/missing-endpoint rules explicit. User: “2. Yes” to fourth interview.
- **MAGIC-019-D12 — 2026-11-10:** Native saves preserve drain/repair contributions, transfer receipts and supported endpoint/link state without target-loss/gain replay. Pending paired work requires coherent boundary/retained recovery; rebuild once, migration cannot silently change persistent/timed model or reset link lifetime. User: “3. Yes” to fourth interview.

The complete [MAGIC-019 specification](systems/MAGIC/MAGIC-019.md) is **Approved — finalized v1** under MAGIC-019-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-018 interview decisions

- **MAGIC-018-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-018 Draft v1. The [specification](systems/MAGIC/MAGIC-018.md) is finalized v1, including capped resource healing, persistent regeneration, source-owned fortification/moddable caps, explicit attribute-damage repair and disease repair/cure distinction, coherent capacity reconciliation and safe native restoration. Documented family/cap/repairability inventories, compatibility and source-repair adapters, disease progression/cure integration and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-018-D01 — 2026-11-10:** Ordinary healing restores selected current health/fatigue/magicka capped at effective maximum; no overheal/capacity change/confirmed-dead revival. Specialized mod effects require explicit owner-supported behavior. User: “1. Yes” to first interview.
- **MAGIC-018-D02 — 2026-11-10:** Default regeneration heals health immediately and per scheduled tick with fresh magnitude/captured caster power. Compatible recasts extend duration preserving phase without another initial heal; resource/magnitude/timing moddable. User: “2. Yes” to first interview.
- **MAGIC-018-D03 — 2026-11-10:** Fortification is temporary source-owned live attribute modifier, permanent values retained, magnitude resolved once not per rebuild. Cap increases require explicit cap contribution; cleanup recomputes remaining sources. Caps explicitly moddable under CHAR ownership/validation. User: “3. Yes, but make the caps moddable, which may have already been stated in CHAR”.

- **MAGIC-018-D04 — 2026-11-10:** Attribute healing repairs explicitly healable damage contributions without permanent growth/unrelated penalty removal or automatic cause cure. User conditionally agreed pending clarification of disease penalty repair/cure; disease eligibility is NOT yet confirmed. Source trace: HealEffect comment says disease damage not healed, but manager.HealAttribute iterates all negative effect modifiers and base HealAttributeDamage changes them; DiseaseEffect inherits it and stores daily penalties in those modifiers. Comment alone is insufficient evidence of exclusion.
- **MAGIC-018-D05 — 2026-11-10:** Allocate attribute-heal amount across eligible sources in stable oldest-application order, moddable selection; retain remaining source damage so expiry/removal cannot restore twice/erase another penalty. User: “2. Yes” to second interview.
- **MAGIC-018-D06 — 2026-11-10:** Derived capacity increases from fortified attributes leave current pools unchanged; decreases clamp only above new limits. Explicit restoration component required for refill; no apply/remove refill exploit. User: “3. Yes” to second interview.

- **MAGIC-018-D07 — 2026-11-10:** Confirmed after source clarification: ordinary disease-owned attribute penalties may be healed without curing disease; future disease progression can damage again. Cure removes only that disease's remaining penalties, preserving permanent/unrelated state, not restoring an old full-stat snapshot or refilling lost pools. Explicit moddable disease exceptions supported. Resolves D04's pending disease eligibility. User: “Yes”.

- **MAGIC-018-D08 — 2026-11-10:** Healing/regeneration baseline inclusive-range captured-level magnitude follows MAGIC-017; fortification resolves once. Validated mod formulas/fixed-per-tick alternatives supported; fatigue restore converts displayed to internal units once. User: “1. Yes” to third interview.
- **MAGIC-018-D09 — 2026-11-10:** Caster-only restoration self-save exemption retained. External restoration follows eligibility/retained RULE-017 save absent explicit source bypass; beneficial label not universal defense bypass. Regeneration reuses admission save by default; recurring checks explicit mod policy. User: “2. Yes” to third interview.
- **MAGIC-018-D10 — 2026-11-10:** Compatible same-attribute fortification defaults duration extension preserving resolved incumbent bonus/phase; source/power compatibility explicit. MAGIC-009 additive/strongest/refresh/replace alternatives supported. Cap-hidden contributions retained, not permanently lost. User: “3. Yes” to third interview.

- **MAGIC-018-D11 — 2026-11-10:** Excess healing discarded, not banked; regeneration ages/continues at full health with zero-gain ticks. Capacity reduction clamps excess current without refunding discarded healing. User: “1. Yes” to fourth interview.
- **MAGIC-018-D12 — 2026-11-10:** Default regeneration persists through ordinary damage/combat/full health; ends through expiry/declared dispel/cure/source/recipient rules. Break conditions moddable. Confirmed death stops normal healing, no resurrection; caster loss only matters with declared ongoing dependency. User: “2. Yes” to fourth interview.
- **MAGIC-018-D13 — 2026-11-10:** Preserve fortification power/repaired disease-drain state/regen phase/completed outcomes in saves without reheal/reroll. Report requested versus actual restoration; no default per-tick practice. Cleanup/cure preserves unrelated modifiers and coherently reconciles capacities. User: “3. Yes” to fourth interview.

The complete [MAGIC-018 specification](systems/MAGIC/MAGIC-018.md) is **Approved — finalized v1** under MAGIC-018-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-017 interview decisions

- **MAGIC-017-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-017 Draft v1. The [specification](systems/MAGIC/MAGIC-017.md) is finalized v1, including typed current-pool damage, retained per-tick magnitude, default retained resistance and moddable full-strength/recurring alternatives, explicit fatigue units, compatible duration extension, ordered consequences, stable attribution and safe native restoration. Documented family inventories, unit/intake adapters, extension compatibility, alternative defense policies, reaction/tick ordering and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-017-D01 — 2026-11-10:** Damage selected current health/fatigue/magicka pool without lowering maximum, saturating at zero; retain requested/resolved damage versus actual loss. Health prevention/death, fatigue exhaustion remain owners; zero magicka not death. User: “1. Yes” to first interview.
- **MAGIC-017-D02 — 2026-11-10:** Immediate magnitude once/application; ongoing fresh magnitude per genuine tick, retained against duplicate/retry, with captured caster inputs. Magnitude and recurring defense policies moddable; user explicitly wants supported land-once/no further saves throughout duration. Full-strength-after-admission interpretation remains to clarify, not assumed approved. User: “2. Yes, but make this moddable, so say if somebody wanted to make it so successfully landing means all 'ticks' go through without checking additional saving throws throughout the duration, if that makes sense.”
- **MAGIC-017-D03 — 2026-11-10:** Default ongoing initial/later ticks reuse admission-time RULE-017 retained percentage, no per-tick save. Explicit recurring-defense mod profiles require declared cadence/identity, no double mitigation. User: “3. Yes” to first interview.

- **MAGIC-017-D04 — 2026-11-10:** Explicit mod alternative admit-once/full-strength later ticks supported alongside default retained-percentage and declared recurring saves. Initial gate interpretation must be specified, not inferred from nonzero R. Resolves D02's full-strength ambiguity. User: “1. Yes” to second interview.
- **MAGIC-017-D05 — 2026-11-10:** Baseline magnitude uniform inclusive integer base range plus uniform inclusive increase range×floor(captured level/positive divisor), validated/moddable. Selected resistance once, retained results; valid zero unchanged, negative/invalid/divisor failure not healing/default. User: “2. Yes” to second interview.
- **MAGIC-017-D06 — 2026-11-10:** Fatigue magnitude in displayed fatigue points converted once to CHAR-018 internal units, baseline×64. Explicit moddable units; health/magicka own units, no double multiplier. User: “3. Yes” to second interview.

- **MAGIC-017-D07 — 2026-11-10:** Compatible ongoing damage defaults duration extension preserving incumbent power/resistance/phase, no additional initial hit, with MAGIC-009 provenance. Different element/source/save compatibility explicit; no silent inherited context. Independent/replacement mod alternatives supported. User: “1. Yes” to third interview.
- **MAGIC-017-D08 — 2026-11-10:** Health uses typed magical element/intake/prevention, not duplicate ordinary weapon armor/material/critical/backstab. Fatigue/magicka use own authoritative pool operations; hybrid components explicit. User: “2. Yes” to third interview.
- **MAGIC-017-D09 — 2026-11-10:** Nonhostile fatigue eligibility follows explicit spell/effect/quest protections, not universal nonhostile exemption. Preserve required quest behavior through explicit rules; reaction/crime/quest owners use truthful source attribution. User: “3. Yes” to third interview.

- **MAGIC-017-D10 — 2026-11-10:** Settle each tick/application prevention/death/exhaustion before next effect; reject later ordinary living-target damage after confirmed death. No bulk aggregation changing prevention opportunities; MAGIC-008 stops applicable time advances. User: “1. Yes” to fourth interview.
- **MAGIC-017-D11 — 2026-11-10:** Preserve original actor/item/spell attribution despite scene absence; distinguish actual loss/resisted/zero outcomes. No injury/blood for zero request. LAW/QUEST/NPC apply explicit attempt/hit/loss semantics, not automatically fresh crimes/casts each callback. User: “2. Yes” to fourth interview.
- **MAGIC-017-D12 — 2026-11-10:** Save power/resistance policy/results/source contributions/lifetime/phase without initial/completed tick replay. Completed recurring checks retained; future ticks may use fresh RNG. Dispel/expiry stops future damage without healing past loss; no default per-tick casting practice. User: “3. Yes” to fourth interview.

The complete [MAGIC-017 specification](systems/MAGIC/MAGIC-017.md) is **Approved — finalized v1** under MAGIC-017-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-016 interview decisions

- **MAGIC-016-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-016 Draft v1. The [specification](systems/MAGIC/MAGIC-016.md) is finalized v1, including explicit trigger contracts, no default caster magicka/practice/history changes, committed item costs, ordered/grouped powers, source-bound cleanup, bounded break handling, periodic/reroll profiles and safe native restoration. Documented power/wear inventories, grouped timing/targeting, item resource/cleanup contracts, mod schemas and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-016-D01 — 2026-11-10:** Powers explicitly declare trigger/source validity/recipient/timing/resource/cleanup, supporting custom payloads across applicable triggers. Names do not establish behavior; unsupported branches return explicit failure without silent resource consumption. User: “1. Yes” to first interview.
- **MAGIC-016-D02 — 2026-11-10:** Default activated item spells use no caster magicka; silence bypass separate explicit permission. Ordinary item use grants no spell practice/recast replacement; condition/charges separate resources. User: “2. Yes” to first interview.
- **MAGIC-016-D03 — 2026-11-10:** Wear/charges commit with actual trigger gameplay, not selection/readiness. Default uncast cancellation free; committed miss/resistance still pays item cost; technical prep failure preserves resources. Strike commitment follows COMBAT-011. User: “3. Yes” to first interview.

- **MAGIC-016-D04 — 2026-11-10:** Same-event powers execute stable explicit order with source/resource revalidation after each. Prior committed results retained if later fails; broken/exhausted source stops later unless declared profile exception. Multiple targeted powers need explicit grouped delivery, not ready-slot overwrite. User: “1. Yes” to second interview.
- **MAGIC-016-D05 — 2026-11-10:** Continuous equipped powers source-bound; separately triggered timed spells retain declared released lifetime. Unequip clears continuous contributions once without universally canceling released spells. Restore reconstructs without equip rewards/initial replay. User: “2. Yes” to second interview.
- **MAGIC-016-D06 — 2026-11-10:** Standard Used/Strikes wear ten condition points per committed power activation, moddable costs/separate-charge alternatives. Full resource required unless explicit final-underfunded-break profile. Other families declare own wear rules; condition/charges distinct. User: “3. Yes” to second interview.

- **MAGIC-016-D07 — 2026-11-10:** One deliberate use retains eligible power group; targeted powers share release aim with own targeting/admission/resource outcomes. Stable sequence, no ready overwrite. Pre-release cancellation free; later invalid power cannot undo earlier commits. Incompatible combinations need explicit profile or clear rejection. User: “1. Yes” to third interview.
- **MAGIC-016-D08 — 2026-11-10:** Power spending last valid condition completes committed payload, then continuous cleanup/declared once-only break event precede later powers. Remaining ordinary live-source powers stop. Break recursion bounded/no unlimited casts; COMBAT-011 earlier-wear break rules intact. User: “2. Yes” to third interview.
- **MAGIC-016-D09 — 2026-11-10:** Periodic/reroll profiles declare interval, ordinary/rest/travel advancement, wear, properties and retained RNG under MAGIC-008. No per-frame/loading wear; unrelated state survives. Re-equip cannot silently reset cooldown/recharge/reroll without explicit profile. Vanilla schedules need verification. User: “3. Yes” to third interview.

- **MAGIC-016-D10 — 2026-11-10:** Each power declares creation-fixed, activation/release-captured wielder or explicit live potency context. No silent player-stat fallback for NPCs; released payload capture/continuous source rules retained. Vanilla mappings need verification. User: “1. Yes” to fourth interview.
- **MAGIC-016-D11 — 2026-11-10:** Default deliberate Used powers obey silence; existing continuous and automatic strike/periodic powers continue unless profile requires speech. Independent moddable permissions; blocked activation spends no item resource. User: “2. Yes” to fourth interview.
- **MAGIC-016-D12 — 2026-11-10:** Native saves preserve resources/continuous contributions/cooldown/reroll progress/trigger outcomes; cancel unfinished manual wind-up without spend/auto-release, restore valid readiness with fresh input. Preserve committed recovery/delivery; reconstruct equip state without equip fees/break/reroll replay. Required missing source/provider uses recovery. User: “3. Yes” to fourth interview.

The complete [MAGIC-016 specification](systems/MAGIC/MAGIC-016.md) is **Approved — finalized v1** under MAGIC-016-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-015 interview decisions

- **MAGIC-015-A01 — 2026-11-10 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-015 Draft v1. The [specification](systems/MAGIC/MAGIC-015.md) is finalized v1, including capacity/drawback boundaries, shared forced dependencies, moddable limits/eligibility, persistent drafts, retained custom payloads and checked one-unit creation preserving unrelated item state. Documented item/power/cost inventories, pricing, dependency schemas, item initialization/splitting, trigger integration and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-015-D01 — 2026-11-10:** Default powers consume capacity and declared drawbacks reduce net usage, with validated moddable costs/limits/combinations. Duplicate/conflict validation prevents repeated drawback credit exploits. Negative usage/zero-capacity boundaries remain open. User: “1. Yes” to first interview.
- **MAGIC-015-D02 — 2026-11-10:** Show forced powers/drawbacks before confirmation, linked to parent and not independently removable while required. Parent removal clears only dependent contributions; shared requirements remain correctly accounted. Missing dependencies/cycles fail validation. User: “2. Yes” to first interview.
- **MAGIC-015-D03 — 2026-11-10:** Capture exact item unit/powers/drawbacks/name/quote; revalidate and commit payment+item modification once. One unit per stack; unrelated properties preserved. Preparation failure leaves gold/item unchanged; changed quote/draft needs renewed consent. User: “3. Yes” to first interview.

- **MAGIC-015-D04 — 2026-11-10:** Default requires positive item capacity, at least one power and max(0,net usage)≤capacity. Excess drawback credit grants no refund/transferable capacity; retain raw breakdown. Eligibility/credit rules moddable; zero-capacity item data remains valid but default craft-ineligible. User: “1. Yes” to second interview.
- **MAGIC-015-D05 — 2026-11-10:** Default service accepts eligible unenchanted items; re-enchant/add/replace only explicit mod profiles defining existing cleanup/capacity/charges/condition/source identity, not silent overwrite. User: “2. Yes” to second interview.
- **MAGIC-015-D06 — 2026-11-10:** Default total entry limit ten including powers/drawbacks/forced entries; validated moddable limit supported end-to-end without UI/save truncation or forced cap bypass. User: “3. Yes” to second interview.

- **MAGIC-015-D07 — 2026-11-10:** Persist exact-item draft/selections through subwindows/service exit/native saves without reservation/modification. Revalidate/flag unavailable reference without substitution; confirm discarding nonempty draft. Original name retained unless valid replacement supplied. User: “1. Yes” to third interview.
- **MAGIC-015-D08 — 2026-11-10:** Separate power costs/drawback credits/raw net/occupied capacity/item capacity/final service price. Drawback credit does not imply gold discount. Power-based pricing baseline subject ECON verification, moddable alternatives. Pure preview cannot spend gold/charges/souls/apply effects. User: “2. Yes” to third interview.
- **MAGIC-015-D09 — 2026-11-10:** Spell-bearing enchantments retain validated payload/explicit trigger+power context, supporting custom/mod bundles beyond classic indices. Existing items not silently rewritten by offer/spell edits. MAGIC-016 owns execution/costs; creation validates attachment eligibility. User: “3. Yes” to third interview.

- **MAGIC-015-D10 — 2026-11-10:** Compatible shared forced entry counts once for slots/cost/credit, retaining all parent dependencies; remove only when no remaining requirement. Incompatible parameters fail rather than merge; intentional distinct instances require explicit policy. User: “1. Yes” to fourth interview.
- **MAGIC-015-D11 — 2026-11-10:** Default item must be unequipped; equipped rejection leaves equipment unchanged. Mod equipped-item crafting supported only through explicit safe cleanup/activation without duplicated triggers/charge refresh/transient modifier loss. User: “2. Yes” to fourth interview.
- **MAGIC-015-D12 — 2026-11-10:** Preserve item identity/unrelated properties; initialize only declared new enchantment state and save resolved powers/drawbacks/dependencies/payloads. No silent repair/resource reset. Native load validates compatibility without creation/payment/reward/trigger replay; pending work needs coherent boundary or retained recovery. User: “3. Yes” to fourth interview.

The complete [MAGIC-015 specification](systems/MAGIC/MAGIC-015.md) is **Approved — finalized v1** under MAGIC-015-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-014 interview decisions

- **MAGIC-014-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-014 Draft v1. The [specification](systems/MAGIC/MAGIC-014.md) is finalized v1, including retained ordered bottle contents, separate defense permissions, checked one-unit consumption, permissive moddable drinking restrictions, immediate default timing, explicit potency policy and no default practice/history changes. Documented scaling/permission inventories, item/access and use-commit contracts, mod timing/restriction profiles and native persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-014-D01 — 2026-11-09:** Drink validated saved ordered bottle bundle with independent per-effect settings, not current-recipe regeneration. Existing dynamic contents survive recipe changes subject to compatibility. User: “1. Yes” to first interview.
- **MAGIC-014-D02 — 2026-11-09:** Default drinking bypasses on-cast chance/RULE-017 saves, obeys hard immunity absent explicit exception, and is outside spell absorption/reflection/Spell Resistance. Independent moddable permissions support unusual concoctions. User: “2. Yes” to first interview.
- **MAGIC-014-D03 — 2026-11-09:** Valid drink consumes exactly one selected bottle despite ordinary ineffectiveness (full resource/immunity/stack policy). Invalid content/technical preparation failure preserves bottle. Prepare/validate then once-only consumption+application; partial mutation needs explicit recovery, not blind refund/replay. User: “3. Yes” to first interview.

- **MAGIC-014-D04 — 2026-11-09:** Default drinking needs no book/magicka, works while silenced/climbing/paralyzed/underwater, rejects dead actor or inaccessible/prohibited item. Activity/use restrictions moddable, independent of casting restrictions; no implicit death/item-authorization bypass. User: “1. Yes, defaults should be Yes while climbing, Yes while paralyzed, and yes while underwater, but make all restrictions moddable as you said.”
- **MAGIC-014-D05 — 2026-11-09:** Default immediate use without spellcasting wind-up/recovery. Mod profiles may define drinking animation/delay/cooldown/limits, with explicit consumption/interruption point; cosmetics alone do not alter gameplay timing. User: “2. Yes” to second interview.
- **MAGIC-014-D06 — 2026-11-09:** Bottle/profile explicitly stores drinker-level-at-consumption versus creation-resolved potency policy. Supported DFU-style recipes default drinker-level scaling; dynamic alchemy may bake crafted potency. No later recipe substitution/double crafting bonuses. User: “3. Yes” to second interview.

- **MAGIC-014-D07 — 2026-11-09:** Default no magic-school practice/history change from drinking. Explicit mod potion-use progression supported through once-only owner-validated reporting; potion origin remains distinct from spellcasting. User: “1. Yes” to third interview.
- **MAGIC-014-D08 — 2026-11-09:** Inventory/quick-use share checked operation capturing exact bottle/payload, consuming one unit and rejecting duplicate same-request delivery. Different payload/potency policy/state not interchangeable by name; deliberate separate uses follow configured cooldown. User: “2. Yes” to third interview.
- **MAGIC-014-D09 — 2026-11-09:** Report committed drink even if no effective actor change; blocked/invalid use explains unchanged bottle outcome. Respect known information. Native restore never drinks again; preserve consumption/effects/cooldown/supported pending state coherently, otherwise explained safe-boundary recovery. User: “3. Yes” to third interview.

The complete [MAGIC-014 specification](systems/MAGIC/MAGIC-014.md) is **Approved — finalized v1** under MAGIC-014-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-013 interview decisions

- **MAGIC-013-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-013 Draft v1. The [specification](systems/MAGIC/MAGIC-013.md) is finalized v1, including stable recipe/multiset defaults, experimentation, valid unmatched consumption, mod-defined ingredient properties and dynamic shared-effect alchemy profiles, checked staging/output, knowledge/disclosure and retained attempt results. Documented recipe inventories, ingredient/profile schemas, item/destination and consumption contracts, knowledge/RNG policies and native persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-013-D01 — 2026-11-09:** Stable recipe IDs separate from ingredient combinations. Default order-independent multiset matching includes types/quantities; hash collisions cannot select another recipe. Ambiguities need explicit resolution, not registration order. User: “1. Yes” to first interview.
- **MAGIC-013-D02 — 2026-11-09:** Experimentation without possessed recipe allowed; possessed recipes provide ingredient-selection shortcut. Knowledge requirements moddable; permanent discovery remains open. User: “2. Yes” to first interview.
- **MAGIC-013-D03 — 2026-11-09:** Confirmed valid unmatched experiment consumes selected ingredients and yields no potion by default. Technical failures consume nothing. Validated mod failure outcomes supported, distinct from missing definitions/access/preparation failure. User: “3. Yes” to first interview.
- **MAGIC-013-D04 — 2026-11-09:** Alchemy extension must support Morrowind/Oblivion-like common-effect ingredient combination, mod-defined ingredient item parameters and dynamically composed/customizable potion effect arrangements rather than only predefined recipes. Default remains recipe-based; specific extension contracts/formulas remain interview work. User explicitly requested these capabilities after first interview.

- **MAGIC-013-D05 — 2026-11-09:** Support versioned namespaced mod ingredient properties (e.g. effects/potency/discovery/quality), validated references and declared defaults. Separate reusable definitions from profile-required per-item state. No fixed Morrowind/Oblivion property set mandated. User: “1. Yes” to second interview.
- **MAGIC-013-D06 — 2026-11-09:** Profiles control matching/shared effects, effect order/magnitude/duration/chance, output quantity and failure outcomes from declared ingredient/skill/equipment/environment inputs. Generated bottles retain resolved bundle/provenance; later content changes cannot silently rewrite them. No specific Morrowind/Oblivion formula is default. User: “2. Yes” to second interview.
- **MAGIC-013-D07 — 2026-11-09:** Station/service selects one explicit alchemy profile per captured attempt; recipe and dynamic systems may coexist without double processing. Mods may replace default or assign station profiles. Consumption/output once-only; previews do not craft/consume/advance gameplay RNG. User: “3. Yes” to second interview.

- **MAGIC-013-D08 — 2026-11-09:** Stage exact item identities/quantities without consumption until confirmation; revalidate inventory/wagon access and ownership/quest/item restrictions. Default unenchanted ingredients; explicit mod eligibility extensions allowed. User: “1. Yes” to third interview.
- **MAGIC-013-D09 — 2026-11-09:** Default success does not automatically grant permanent recipe knowledge; possessed recipe-item access remains baseline. Mods may define discovery/property learning/book requirements with separate saved character knowledge, without preview leakage of hidden effects. User: “2. Yes” to third interview.
- **MAGIC-013-D10 — 2026-11-09:** Prepare/validate output and destination before ingredient consumption; unacceptable output preserves inputs. Commit consumption/resolved result once. Legitimate profile failure consumes as declared; technical/access errors cannot grant free output or partially lose ingredients. User: “3. Yes” to third interview.

- **MAGIC-013-D11 — 2026-11-09:** Staged item selections persist through subwindows/service exit+reopen/native saves without moving/consuming original inventory. Revalidate/flag missing quantities without substitution; restore never auto-mixes. User: “1. Yes” to fourth interview.
- **MAGIC-013-D12 — 2026-11-09:** Valid default exact recipe succeeds deterministically. Alternate profiles may define skill/random potency/yield with once-resolved retained attempt results; partial retry cannot reroll. New attempts after load follow approved fresh RNG; previews never resolve actual attempt. User: “2. Yes” to fourth interview.
- **MAGIC-013-D13 — 2026-11-09:** Profiles declare known/estimated/unknown preview disclosure. Known recipes may reveal result; dynamic experimentation respects discovery. Show selected quantities/service charge before confirmation. Pricing/apparatus/progression rewards remain explicit profile/service-owner rules. User: “3. Yes” to fourth interview.

The complete [MAGIC-013 specification](systems/MAGIC/MAGIC-013.md) is **Approved — finalized v1** under MAGIC-013-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-012 interview decisions

- **MAGIC-012-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-012 Draft v1. The [specification](systems/MAGIC/MAGIC-012.md) is finalized v1, including moddable composition/parameter limits, ordered editing and explicit compatibility, retained conflicting intent, separate quotes, custom identity, persistent drafts and checked once-only creation. Documented effect/default inventories, mod composition schemas, service pricing/access, draft scope and native creation/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-012-D01 — 2026-11-09:** Default custom composition at most three effects with one shared target and element. Validated moddable limits/composition profiles supported with UI/cost/execution support beyond fixed three-slot assumptions. User: “1. Yes” to first interview.
- **MAGIC-012-D02 — 2026-11-09:** Each selected effect must support chosen target/element; incompatible combinations rejected without dropping/changing effects. Explicit supported mod interpretations may differ. User: “2. Yes” to first interview.
- **MAGIC-012-D03 — 2026-11-09:** Add/edit/remove/reorder entries; repeats allowed when declared crafting rules permit. Show duplicate/stacking restrictions; authored order retained without assumed universal stacking or duplicate prohibition. User: “3. Yes” to first interview.

- **MAGIC-012-D04 — 2026-11-09:** Expose only supported duration/chance/magnitude controls with explicit moddable bounds/defaults/divisors. Verified DFU crafting ranges initial baseline where supported, distinct from imported-data limits. Invalid parameters rejected without divisor repair/endpoint reversal. User: “1. Yes” to second interview.
- **MAGIC-012-D05 — 2026-11-09:** Incompatible add/edit retains selected target/element, explains conflict and blocks purchase until resolved. Offer alternatives without silently changing draft intent. User: “2. Yes” to second interview.
- **MAGIC-012-D06 — 2026-11-09:** Separate current casting-cost/creation-price previews. Valid spell may be purchased despite casting unaffordability if creation price affordable. Pure previews; commitment revalidates exact draft/quote/service access and MAGIC-011 spellbook policy. User: “3. Yes” to second interview.

- **MAGIC-012-D07 — 2026-11-09:** Require nonblank name; duplicate display names allowed. Assign distinct stable custom spell identity at committed creation. Icon cosmetic; approved fallback for missing optional art. User: “1. Yes” to third interview.
- **MAGIC-012-D08 — 2026-11-09:** Unfinished draft persists through subwindows/service exit+reopen/native save without spending/learning. Revalidate access/content/price on return; explicit New/Discard confirms clearing nonempty draft. Restored draft never auto-purchases/casts. User: “2. Yes” to third interview.
- **MAGIC-012-D09 — 2026-11-09:** Confirmation captures exact ordered effects/parameters/target/element/name/icon/price. Commit payment and one learned custom spell together; changed draft/quote needs renewed confirmation. Failure preserves gold/knowledge/editable draft; duplicate confirmation cannot duplicate creation/charge. Separately confirmed later creations may have distinct identities under duplicate policy. User: “3. Yes” to third interview.

The complete [MAGIC-012 specification](systems/MAGIC/MAGIC-012.md) is **Approved — finalized v1** under MAGIC-012-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-011 interview decisions

- **MAGIC-011-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-011 Draft v1. The [specification](systems/MAGIC/MAGIC-011.md) is finalized v1, including distinct learned/innate/item sources, moddable enabled-default spellbook requirement, stable once-only purchases, duplicate/forgetting rules, moddable sorting/display, explicit offers and native persistence. Documented service/access inventories, quote/commit recovery, duplicate-policy schemas, UI extension/preferences and native-save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-011-D01 — 2026-11-09:** Learned spells, innate abilities and item-provided casts retain distinct authoritative sources even if displayed together. Item/innate entries do not become unrestricted learned knowledge by listing. User: “1. Yes” to first interview.
- **MAGIC-011-D02 — 2026-11-09:** Default ordinary learned-spell selection, recast and purchase require possession of spellbook item. Requirement is moddable enabled/disabled, default vanilla enabled. Item loss restricts access without erasing knowledge; innate/item powers use own access rules. User: “2. Yes, just make it moddable to enable or not, but the vanilla behavior by default”.
- **MAGIC-011-D03 — 2026-11-09:** Purchase confirmation retains exact spell/service/quote; revalidate eligibility/funds/availability before once-only payment+learning. Changed quote needs renewed confirmation; failure leaves gold/knowledge unchanged. Sorting/repeated confirmation cannot change purchased spell or duplicate charges. User: “3. Yes” to first interview.

- **MAGIC-011-D04 — 2026-11-09:** Default repeated learning of known stable spell ID returns already-known, no duplicate entry/charge. Differently identified custom spells remain distinct despite same name. Explicit moddable duplicate policies supported; names never identity. User: “1. Yes” to second interview.
- **MAGIC-011-D05 — 2026-11-09:** Confirmed forgetting for ordinary learned spells; innate/item entries are not deleted as learned knowledge and protected grants retain protection. Forgetting cancels associated uncast readiness/invalidates recast entry without undoing released effects. Normal acquisition governs relearning. User: “2. Yes” to second interview.
- **MAGIC-011-D06 — 2026-11-09:** Persistent manual ordering, name/current-cost sorts, stable selection through list changes and current cost/blocked reasons. Highlight/sort/inspect never casts; deliberate use enters MAGIC-003. Additional sorting/display options moddable through UI integration without changing spell identity/authority. User: “3. Yes, and more options for sorting and displaying of the list should be moddable, but that's probably more a UI distinction”.

- **MAGIC-011-D07 — 2026-11-09:** Temporarily unusable learned entries remain visible/inspectable with clear reasons (spellbook/silence/magicka/source), not disappearing. Missing/incompatible required definitions follow content/save recovery, not temporary restriction disguise. User: “1. Yes” to third interview.
- **MAGIC-011-D08 — 2026-11-09:** Registration/runtime support is separate from explicit service offer eligibility; validated mod offer additions/overrides supported. Show purchase price separately from cast cost. Stock/faction/service/pricing rules remain ECON/service owners. User: “2. Yes” to third interview.
- **MAGIC-011-D09 — 2026-11-09:** Native saves preserve learned identities/custom settings/protections/source distinctions/manual order without acquisition/payment replay. Sort/display preferences use appropriate UI scope. Compatibility validated; no duplicate grants, item-power refresh or automatic selected-entry casting. User: “3. Yes” to third interview.

The complete [MAGIC-011 specification](systems/MAGIC/MAGIC-011.md) is **Approved — finalized v1** under MAGIC-011-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-010 interview decisions

- **MAGIC-010-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-010 Draft v1. The [specification](systems/MAGIC/MAGIC-010.md) is finalized v1, including authoritative effect restoration, declared source dependencies, versioned provider compatibility, coherent save/readiness boundaries and derived HUD grouping/details/overflow/warnings with cosmetic fallback. Documented provider schemas/migrations, source linking, restore ordering, coherent save boundaries and HUD presentation dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-010-D01 — 2026-11-09:** Restore resolved power, retained chance/save outcomes, contribution relationships and timing progress; rebuild derived modifiers without recasting/recalculating captured power from current caster stats. Explicit live dependencies remain live, including MAGIC-007 absorption scaling. User: “1. Yes” to first interview.
- **MAGIC-010-D02 — 2026-11-09:** Missing original caster does not end effect when saved power/attribution suffice. Required equipped-item/source loss uses explicit recovery; ongoing caster-access dependencies must be declared. User: “2. Yes” to first interview.
- **MAGIC-010-D03 — 2026-11-09:** Rebuild active-spell HUD/icons/details from authoritative restored effects, not UI objects or visibility-driven existence. Cosmetic missing icons may use generic fallback; required missing effect definitions use content recovery. User: “3. Yes” to first interview.

- **MAGIC-010-D04 — 2026-11-09:** HUD groups related effects by spell/source with inspectable surviving contribution details: source, lifetime and effective/suppressed state. Mixed components cannot be misrepresented by one universal expiry countdown. Suppressed entries may be omitted from compact row but remain in details. User: “1. Yes” to second interview.
- **MAGIC-010-D05 — 2026-11-09:** Compact overflow count/expandable list exposes additional active effects instead of silently truncating at fixed icon limit. UI capacity never caps gameplay. Explicit internal-bookkeeping presentation rules may hide those effects. User: “2. Yes” to second interview.
- **MAGIC-010-D06 — 2026-11-09:** Default nonblinking expiry warning; optional blink/moddable thresholds. Source-bound effects show dependency not fake countdown; timing units follow profile. Suppressed expiry alone cannot falsely warn active protection is ending. User: “3. Yes” to second interview.

- **MAGIC-010-D07 — 2026-11-09:** Providers declare versioned effect-state contracts/supported migrations; validate compatibility before current-session replacement. Same ID insufficient. Preserve MAGIC-008 migration-first/supported old-profile continuation and explicit required-support recovery, not effect dropping. User: “1. Yes” to third interview.
- **MAGIC-010-D08 — 2026-11-09:** Suspend gameplay through required actor/item linking, source validation and coherent modifier/vital/HUD rebuild. Not-yet-loaded reference stays unresolved, not falsely absent. Cosmetic icon fallback alone does not block readiness. User: “2. Yes” to third interview.
- **MAGIC-010-D09 — 2026-11-09:** Normally save at coherent effect boundaries; temporarily delay/reject with explanation if application/merge/removal cannot serialize safely. Supported partial snapshots retain once-only progress. Never silently omit unfinished work or save half-applied/replayable bonuses. User: “3. Yes” to third interview.

The complete [MAGIC-010 specification](systems/MAGIC/MAGIC-010.md) is **Approved — finalized v1** under MAGIC-010-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-009 interview decisions

- **MAGIC-009-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-009 Draft v1. The [specification](systems/MAGIC/MAGIC-009.md) is finalized v1, including explicit family stacking policies, retained source provenance, scoped cleanup, standard extension/refresh, checked replacement, aging strongest-only suppression, independent bundle removal and idempotent restoration. Documented family-default inventories, merge-provenance ownership, comparison/replacement policies, cleanup contracts and native persistence/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-009-D01 — 2026-11-09:** Each effect family declares matching/combination rules, supporting independent instances, duration extension, refresh, replacement and strongest-only through validated mod policies. No universal stacking rule; family baseline choices require verification/approval. User: “1. Yes” to first interview.
- **MAGIC-009-D02 — 2026-11-09:** Spell/potion/equipped-item contributions remain separately identifiable even for the same capability. Permitted merges retain provenance sufficient for correct removal/attribution; removing one source cannot erase another. User: “2. Yes” to first interview.
- **MAGIC-009-D03 — 2026-11-09:** Expiry/dispelling/valid source removal clears only affected contributions and coherently recomputes surviving capabilities/modifiers before gameplay continues. Repeated cleanup harmless; no repeated damage/grants/initial application. User: “3. Yes” to first interview.

- **MAGIC-009-D04 — 2026-11-09:** Standard duration extension preserves incumbent power/next-tick progress, adds accepted incoming lifetime only, with no extra initial application. Different timing profiles need explicit conversion before merge; power replacement/tick restart require declared alternative policy. User: “1. Yes” to second interview.
- **MAGIC-009-D05 — 2026-11-09:** Strongest-only retains weaker accepted contributions, aging while suppressed and becoming effective when stronger ends if still valid. Suppressed periodic payloads do not execute or accrue missed ticks. Alternatives require explicit policy. User: “2. Yes” to second interview.
- **MAGIC-009-D06 — 2026-11-09:** Held/equipped effects normally depend on valid active required source, independently of ordinary timed spells. Unequip/break removes only source contribution without restarting others. Timed cast source dependency must be declared; unrelated later unequipping does not end it. User: “3. Yes” to second interview.

- **MAGIC-009-D07 — 2026-11-09:** Standard refresh sets remaining lifetime=max(current,incoming), preserves incumbent power/next-tick progress, and grants no extra initial application. Alternative duration/phase reset must be explicit. User: “1. Yes” to third interview.
- **MAGIC-009-D08 — 2026-11-09:** Validate/admit incoming replacement before coherently removing old contribution, without transient bonus loss, resource refill or replayed grants. Policy explicitly defines replacement initial payload/tick phase; failed admission leaves old effect unchanged. User: “2. Yes” to third interview.
- **MAGIC-009-D09 — 2026-11-09:** Effects within a mixed bundle expire/remove independently, preserving other entries unless explicit rule selects entire bundle. Dispel/cure owners choose affected contributions; framework applies safe scoped removal. User: “3. Yes” to third interview.

- **MAGIC-009-D10 — 2026-11-09:** Each family declares strongest comparison; equal strength retains effective incumbent, otherwise stable application order breaks ties. Suppressed activation grants no new initial payload/tick-phase restart. User: “1. Yes” to fourth interview.
- **MAGIC-009-D11 — 2026-11-09:** Constant modifier/capability rebuilds are idempotent, without RNG, charge spending, practice, periodic damage or startup rewards. Recompute surviving contributions coherently before vital-limit reconciliation; no transient capacity loss/free refill. User: “2. Yes” to fourth interview.
- **MAGIC-009-D12 — 2026-11-09:** Native saves preserve contribution/source/suppression/resolved-power/lifetime/tick state and reconstruct same effective result without admission/initial replay. Different timing profiles follow MAGIC-008 migration/continuation, not silent cross-unit merging or suppressed-effect loss. User: “3. Yes” to fourth interview.

The complete [MAGIC-009 specification](systems/MAGIC/MAGIC-009.md) is **Approved — finalized v1** under MAGIC-009-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-008 interview decisions

- **MAGIC-008-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-008 Draft v1. The [specification](systems/MAGIC/MAGIC-008.md) is finalized v1, including shared-minute round defaults, moddable real-time timing models, full elapsed accounting, pause/explicit-advance separation, chronological interruptible scheduling and migration-first native-save compatibility with disclosed supported old-profile continuation. Documented scheduler/TIME coordination, event ordering, effect-family elapsed ownership, profile/mod APIs, cross-profile merging and native migration/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-008-D01 — 2026-11-09:** Default ordinary round effects use shared one-game-minute boundaries; explicit profiles may use other intervals. The broader round-based timing system must support validated mod replacement/alternative real-time behavior, not only an adjustable round length. Exact clock/duration/tick contracts remain interview work; default remains regular round-based. User: “1. Yes, but if possible I'd like this entire round-based system to be made moddable so say if a more 'real-time' system could be possible to implement, similar to the newer Elder Scrolls games, but by default it would use the regular round-based system.”
- **MAGIC-008-D02 — 2026-11-09:** Account for full authorized elapsed interval without silent fixed-cap discard. Equivalent bulk advancement only where proven safe; otherwise bounded sequential work retaining unfinished progress. User: “2. Yes” to first interview.
- **MAGIC-008-D03 — 2026-11-09:** Ordinary pause/focus loss advances effects by zero; explicit rest/travel/prison advances effects via declared elapsed operation. Report completion only after required processing, without load/paused-wall-time catch-up. User: “3. Yes” to first interview.

- **MAGIC-008-D04 — 2026-11-09:** Alternative profiles support eligible-gameplay seconds independent of calendar speed, frozen during pause/loading. No offline wall-clock progression. Rest/travel require explicit conversion/advancement for these profiles. User: “1. Yes” to second interview.
- **MAGIC-008-D05 — 2026-11-09:** Profiles independently specify duration units, tick interval, shared-boundary/application-relative scheduling, periodic versus continuously active lifetime. Immediate initial application remains default; changes require explicit effect policy. User: “2. Yes” to second interview.
- **MAGIC-008-D06 — 2026-11-09:** Timing model fixed for application run; native saves retain effect timing model/version, remaining duration and next-tick progress. Prefer supported migration/continuation when changing existing-save timing rules rather than explicit failure. Exact conversion and fallback recovery remain unresolved; no silent timer refresh/extra tick or guaranteed arbitrary conversion approved. User: “3. Yes, but something that is not an explicit failure would be preferred if changing the timing rules of an existing save.”

- **MAGIC-008-D07 — 2026-11-09:** Changed timing profiles provide explicit migration preserving remaining duration/next-tick progress under documented unit conversion, without replay/reset. No universal minute-to-second assumption. User: “1. Yes” to third interview.
- **MAGIC-008-D08 — 2026-11-09:** If safe migration unavailable, offer disclosed continuation with supported saved profiles for active effects and new profile for new applications. Resolve both into locked run configuration. If neither path supported, offer required-profile/configuration restoration; no silent effect deletion. User: “2. Yes” to third interview.
- **MAGIC-008-D09 — 2026-11-09:** Gameplay-second profile baseline for rest/travel is equivalent seconds using explicit normal calendar-to-gameplay rate fixed consistently for the operation; profiles may override conversion or freeze. Never use loading-screen wall time. User: “3. Yes” to third interview.

- **MAGIC-008-D10 — 2026-11-09:** Default N-round duration includes immediate initial application, at most N−1 later payload ticks, cleanup at boundary after final active round. One-round effect applies immediately and remains until next shared boundary. Alternative profiles explicitly define their own lifetime/tick accounting. User: “1. Yes” to fourth interview.
- **MAGIC-008-D11 — 2026-11-09:** Advance ticks/expirations/new effects chronologically with documented deterministic simultaneous-event order; no retroactive ticks for newly created effects. Bulk processing requires outcome equivalence, not callback-registration order. User: “2. Yes” to fourth interview.
- **MAGIC-008-D12 — 2026-11-09:** Stop requested time advance at effect-caused death or applicable owner-defined interruption, preserving completed consequences and reporting actual elapsed time. Rest/travel/prison owners define applicable interruptions; do not falsely report full requested completion. User: “3. Yes” to fourth interview.

The complete [MAGIC-008 specification](systems/MAGIC/MAGIC-008.md) is **Approved — finalized v1** under MAGIC-008-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-007 interview decisions

- **MAGIC-007-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-007 Draft v1. The [specification](systems/MAGIC/MAGIC-007.md) is finalized v1, including ordered per-effect defenses, independent finite reflection chains, direct return, separate bypass permissions, recipient-valued immediate absorption, shared original-caster refund budget and validated mod policies. Documented valuation/context fixtures, reflected metadata, source-policy schemas, stacking, bounded scheduling and native persistence/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-007-D01 — 2026-11-09:** Baseline per-effect defense order absorption → reflection → Spell Resistance, stopping that effect when a defense succeeds. Validated moddable ordering supported; defense stages precede on-cast chance/RULE-017 saves under MAGIC-006. User: “1. Yes” to first interview.
- **MAGIC-007-D02 — 2026-11-09:** Defenses resolve per effect/per recipient. Reflection returns only that effect, not the entire bundle; mixed outcomes cannot replay unrelated entries. User: “2. Yes” to first interview.
- **MAGIC-007-D03 — 2026-11-09:** Default one reflection per effect delivery chain, independently tracked for each original area recipient. Validated moddable finite limits supported. Reflected destination may absorb/resist; one recipient's reflection cannot disable another's defense. User: “3. Yes” to first interview.

- **MAGIC-007-D04 — 2026-11-09:** Initial absorption eligibility is Destruction-school spell effects, moddable by effect/school/source including explicit self-cast inclusion/exclusion. School baseline is not universal harmful-effect classification. User: “1. Yes” to second interview.
- **MAGIC-007-D05 — 2026-11-09:** Baseline absorption requires capacity for the effect's entire absorption value; insufficient capacity fails absorption and proceeds to next defense. Validated partial-refill/full-magicka absorption alternatives supported. User: “2. Yes” to second interview.
- **MAGIC-007-D06 — 2026-11-09:** Baseline absorption value is recipient-current-skill individual normal effect cost including target multiplier/configured minimum, with explicit moddable valuation. It is separate from actual caster expenditure/discounted payment. Self-generated caps remain unresolved. User: “3. Yes” to second interview.

- **MAGIC-007-D07 — 2026-11-09:** Total absorption refund to original caster from own cast, including reflected returns, is capped at actual cast magicka expenditure across all effects/return paths. Free casts refund zero to original caster. Cap independently moddable; other recipients use own valuation/capacity rules. User: “1. Yes” to third interview.
- **MAGIC-007-D08 — 2026-11-09:** Default reflection directly returns only intercepted effect to immediately preceding sender, without new projectile/explosion. Preserve original caster power/attribution separately from reflector. Missing/invalid return recipient dissipates effect; explicit mod profiles may use physical return projectiles. User: “2. Yes” to third interview.
- **MAGIC-007-D09 — 2026-11-09:** Absorption/reflection/Spell Resistance each have separate eligibility/bypass permission independent of chance/save/hard immunity. Baseline no reflection onto same sender/recipient; caster-only mode bypasses Spell Resistance. Free casting grants no defense bypass. Explicit validated mod exceptions supported. User: “3. Yes” to third interview.

- **MAGIC-007-D10 — 2026-11-09:** Effect-based absorption scales from defending recipient's current level; Reflection/Spell Resistance use power captured when defensive effects were applied. Explicit moddable scaling policies supported. Retain RULE-001 interception results; failed defense proceeds to next stage/admission. User: “1. Yes” to fourth interview.
- **MAGIC-007-D11 — 2026-11-09:** Baseline absorption sources: effect-based first, applicable career condition next, active persistent capability last, stopping at success. Moddable composition/order supported. Light/dark uses defender's actual environment/game time, not player location. Same-family effect merging remains MAGIC-009. User: “2. Yes” to fourth interview.
- **MAGIC-007-D12 — 2026-11-09:** Successful absorption cancels entry and restores magicka immediately before next authored effect. Recheck capacity/shared self-refund budget per entry. Budget below full value fails baseline absorption; partial/zero-refill interception needs explicit mod policy. User: “3. Yes” to fourth interview.

D07 resolves D06's self-generated cap question. The complete [MAGIC-007 specification](systems/MAGIC/MAGIC-007.md) is **Approved — finalized v1** under MAGIC-007-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-006 interview decisions

- **MAGIC-006-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-006 Draft v1. The [specification](systems/MAGIC/MAGIC-006.md) is finalized v1, including mutation-free pre-admission preparation, independent authored-order outcomes, retained on-cast chance/save results, separate bypass permissions, explicit chance scaling, caster-only effect-save exemption and immediate accepted-effect application. Documented defense integration, immunity/save interpretation inventories, tick/merge contracts, mod schemas and native persistence/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-006-D01 — 2026-11-09:** Initialization/admission checks have no gameplay side effects; startup, incumbent merging and initial application occur only after acceptance. Rejected effects cannot leave damage/bonuses/duration changes. Authorized random results may be retained without applying the effect. User: “1. Yes” to first interview.
- **MAGIC-006-D02 — 2026-11-09:** Apply independently accepted effects despite ordinary chance/eligibility/resistance failures of other entries. Missing providers/malformed definitions remain technical failures, not resistance or silent omission. User: “2. Yes” to first interview.
- **MAGIC-006-D03 — 2026-11-09:** Admit/apply in authored effect order; accepted earlier effects may change recipient state observed by later entries. Retain completed results to prevent reroll/reapplication on retry. User: “3. Yes” to first interview.

- **MAGIC-006-D04 — 2026-11-09:** Resolve on-cast chance once per effect/recipient application and retain/reuse through retry/restoration. Distinct recipients and repeated authored entries receive distinct checks; later ticks reroll only under explicit recurring-chance policy. User: “1. Yes” to second interview.
- **MAGIC-006-D05 — 2026-11-09:** After applicability and MAGIC-007 defense stages, evaluate on-cast chance before RULE-017 save; failed chance stops without saving-throw draw/start/merge. Accepted effects reuse one retained save across relevant fields. User: “2. Yes” to second interview.
- **MAGIC-006-D06 — 2026-11-09:** Chance, saving-throw and hard-immunity bypass exceptions require separate explicit permissions, not a generic bypass-everything flag. Potion/special-infection exceptions declare exactly which protection is bypassed. Absorption/reflection permissions remain MAGIC-007 review. User: “3. Yes” to second interview.

- **MAGIC-006-D07 — 2026-11-09:** Baseline on-cast chance is base+increase×floor(captured caster level/per-level divisor), resolved with RULE-001 clamped 0–100 percentile semantics and validated mod overrides. Invalid divisors fail; no implicit missing-caster level-one fallback. User: “1. Yes” to third interview.
- **MAGIC-006-D08 — 2026-11-09:** Ordinary caster-only mode bypasses effect-level saving throws, but not chance/applicability/hard immunity without separate permission. An own-caster ranged explosion is not caster-only. Absorption/reflection remain MAGIC-007. User: “2. Yes” to third interview.
- **MAGIC-006-D09 — 2026-11-09:** Newly accepted effects receive immediate initial application before processing next authored entry. Incumbent merging must not accidentally add another initial tick; effect-family merge behavior remains MAGIC-009. Duration/expiry/later cadence remain MAGIC-008/009. User: “3. Yes” to third interview.

The complete [MAGIC-006 specification](systems/MAGIC/MAGIC-006.md) is **Approved — finalized v1** under MAGIC-006-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-005 interview decisions

- **MAGIC-005-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-005 Draft v1. The [specification](systems/MAGIC/MAGIC-005.md) is finalized v1, including release-time aim, empty-space ranged/empty-area legality, potential touch eligibility, undivided area strength, explicit NPC aim, captured caster power, current recipient eligibility and nondisclosing feedback. Inherited COMBAT-014 contact, obstruction, deduplication and persistence remain binding. Documented geometry fixtures, aim/applicability/snapshot contracts, mod profiles, feedback and native-save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-005-D01 — 2026-11-09:** Ordinary player spells sample current aim at release, allowing changes during wind-up without initial-actor lock. Touch checks current forward contact; ranged launches along current aim. Explicit modded lock-on/homing profiles may differ. User: “1. Yes” to first interview.
- **MAGIC-005-D02 — 2026-11-09:** Ranged spells may release into empty space without an acquired actor; later miss/expiration is paid. Touch requires an eligible actor in reach at release. Near launch obstruction receives released impact rather than spawn-through. User: “2. Yes” to first interview.
- **MAGIC-005-D03 — 2026-11-09:** One-shot caster-centered area originates from caster position at release; empty area remains a valid paid cast without recipient-presence disclosure through rejection. Lingering profiles explicitly define anchored/moving origin. User: “3. Yes” to first interview.

- **MAGIC-005-D04 — 2026-11-09:** Touch accepts an actor when at least one effect is potentially applicable under declared eligibility. Actual immunity/resistance/chance remain admission checks; no preview rolls or hidden-immunity disclosure. Complete later resistance is a paid outcome; explicit ally/enemy exclusions still apply. User: “1. Yes” to second interview.
- **MAGIC-005-D05 — 2026-11-09:** Ordinary areas apply normal strength independently per eligible recipient, without target-count division or distance falloff. Explicit validated mod falloff/distribution profiles supported. User: “2. Yes” to second interview.
- **MAGIC-005-D06 — 2026-11-09:** NPCs supply explicit AI aim at release. Ordinary projectiles retain released trajectory rather than tracking later AI target changes; shared obstruction/contact rules apply. Prediction/error/lock-on/homing require explicit AI/spell profiles. User: “3. Yes” to second interview.

- **MAGIC-005-D07 — 2026-11-09:** Capture spell settings, caster level, relevant school skills and source-owned effect-power modifiers at release. Later caster changes cannot rewrite airborne power; target defenses remain current at application. Specialized ongoing-caster dependencies need explicit exceptions. User: “1. Yes” to third interview.
- **MAGIC-005-D08 — 2026-11-09:** Check relationship and living/dead recipient eligibility at application, not cast start. Changed eligibility does not refund/redirect released spell; independently eligible mixed-bundle effects may apply. Corpse targeting requires explicit support. User: “2. Yes” to third interview.
- **MAGIC-005-D09 — 2026-11-09:** Failed touch attempts explain ordinary contact/reach/declared restrictions without hidden resistance/immunity details or mandatory aim highlights. Mod indicators supported; previews cannot roll defenses, apply effects or disclose otherwise hidden actors. User: “3. Yes” to third interview.

The complete [MAGIC-005 specification](systems/MAGIC/MAGIC-005.md) is **Approved — finalized v1** under MAGIC-005-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-004 interview decisions

- **MAGIC-004-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-004 Draft v1. The [specification](systems/MAGIC/MAGIC-004.md) is finalized v1, including unpaid wind-up/release payment, recovery busy state, moddable interruptions/timing, cost-based practice support, origin-based recast history, native-load cancellation and checked delivery preparation. Documented timing profiles, delivery/recovery operations, mod/practice APIs, source/target contracts and native-save/projectile dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-004-D01 — 2026-11-09:** Casting has unpaid wind-up; recalculate current cost, validate eligibility and spend at release immediately before delivery. Pre-release interruption costs nothing; unaffordable release has no payment/effects. User: “1. Yes” to first interview.
- **MAGIC-004-D02 — 2026-11-09:** Actual casting starts with wind-up and remains busy through recovery. Reject new casting/readiness requests without queuing until recovery finishes. Animation-free timing remains to be decided. User: “2. Yes” to first interview.
- **MAGIC-004-D03 — 2026-11-09:** Failed release eligibility from silence, insufficient magicka or invalid target ends casting and retains the readied spell; fresh input required, no payment/practice/history update. Post-release interruption remains separate. User: “3. Yes” to first interview.

- **MAGIC-004-D04 — 2026-11-09:** Default death, paralysis, climbing entry or required-source loss cancels unfinished wind-up; ordinary damage alone does not. Before release, no payment/practice; retain selection only with valid source. After release, preserve committed costs/effects/projectiles; death follows authoritative session death handling. Casting restrictions/interruption behavior must be moddable, including permitting climbing casts. Exact supported exception scope remains to be resolved; no resurrection or missing-required-source permission inferred. User: “1. Yes, but this behavior would be nice to have moddable, so say you can be allowed to cast while climbing and such.”
- **MAGIC-004-D05 — 2026-11-09:** Ordinary pause freezes wind-up/recovery. Forced interruption after release retains remaining recovery rather than permitting an immediate new cast; released spells are not reversed. User: “2. Yes” to second interview.
- **MAGIC-004-D06 — 2026-11-09:** Player, NPC and animation-free casts use explicit moddable wind-up/recovery timings; hiding animation alone cannot shorten gameplay timing. Explicit abilities may have zero wind-up, with once-only release. Exact baseline durations and NPC timing profiles require verification. User: “3. Yes” to second interview.

- **MAGIC-004-D07 — 2026-11-09:** Validated rules independently control climbing/paralysis/damage start restrictions and in-progress interruption. Confirmed death and loss of required source remain mandatory pre-release stops; silence uses MAGIC-003's separate permission. Resolves D04's exception scope. User: “1. Yes” to third interview.
- **MAGIC-004-D08 — 2026-11-09:** Default ordinary player release grants one practice point per active effect's school, including repeated schools, regardless of later miss/resistance; rejected/interrupted pre-release casts grant none. Practice amount/eligibility moddable, explicitly supporting spell-cost-based gain and broad validated configuration. Item/innate effects need explicit practice eligibility; animation hiding alone cannot change eligibility. Exact cost basis/formula context remains to be decided. User: “2. Yes, and specify that moddable 'practice point' gain should allow for giving practice points based on the cost of the spell. I'd like it to be as moddable as possible, but make sure that is allowed atleast.”
- **MAGIC-004-D09 — 2026-11-09:** Successful ordinary player spell releases update last-spell history regardless of animation/magicka cost. Item/innate casts preserve it and cannot become unrestricted recasts. Recast re-enters normal readiness/eligibility. Miss/resistance after release counts; failed attempts do not change history. User: “3. Yes” to third interview.

- **MAGIC-004-D10 — 2026-11-09:** Mod practice rules receive calculated spell cost before payment exemptions and actual magicka spent, effect schools, spell/source identity and caster context. Support cost-based, per-effect or distinct-school policies returning nonnegative integer amounts applied once through CHAR-012. Resolves D08's practice context; exact formula API remains technical scope. User: “1. Yes” to fourth interview.
- **MAGIC-004-D11 — 2026-11-09:** Native load cancels unfinished wind-up without payment and restores valid spell readied with fresh input required. Preserve remaining post-release recovery and last-spell history; committed payment/practice/effects/projectiles are not replayed. Released projectile persistence remains its owner's contract. User: “2. Yes” to fourth interview.
- **MAGIC-004-D12 — 2026-11-09:** Prepare/validate required delivery before spending. Projectile-creation/self-effect-preparation failure has no payment/practice/history update. Once delivery commits, later miss/resistance/absorption is a normal paid outcome. Unexpected partial-mutation failure requires explicit recovery, not blind retry/refund duplicating effects. User: “3. Yes” to fourth interview.

D06 resolves D02's animation-free timing question; D07 resolves D04's exception scope; D10 resolves D08's practice context. The complete [MAGIC-004 specification](systems/MAGIC/MAGIC-004.md) is **Approved — finalized v1** under MAGIC-004-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-003 interview decisions

- **MAGIC-003-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-003 Draft v1. The [specification](systems/MAGIC/MAGIC-003.md) is finalized v1, including free preparation/cancellation, safe replacement, moddable casting policy across target types, current-cost checks, independent silence permissions, enemy/spell affordability modes and precedence, failed-attempt retention and safe uncast readiness restoration. Documented casting/payment boundaries, target/silence contracts, policy schemas/selectors, UI handoff and native-save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-003-D01 — 2026-11-09:** Readying checks affordability without spending or reserving magicka; recheck affordability when casting commits. Canceling preparation costs nothing. Fixed versus recalculated cost remains open. User: “1. Yes” to first interview.
- **MAGIC-003-D02 — 2026-11-09:** Failed selection/replacement due to validation or affordability preserves the previous readied spell with clear failure feedback. The retained spell still faces cast-time checks. User: “2. Yes” to first interview.
- **MAGIC-003-D03 — 2026-11-09:** Default valid self-targeted selection immediately requests casting; touch/ranged spells wait for activation. Automatic self-targeted casting behavior must be moddable, including requiring separate cast input if desired. Exact configuration mechanism/scope remains to be specified; this does not bypass eligibility, resource or input gates. User: “3. Yes, but it would be nice to be able to mod this behavior if desired somehow”.
- **MAGIC-003-D04 — 2026-11-09:** Clarifies/extends D03: automatic versus separate-input casting policy must be moddable for other spell target types as well, not only self-targeted spells. Default target behavior remains D03. Target validity, aiming and activation arbitration still apply; exact policy scope remains interview work. User: “I also meant the same for other spell target types, if desired.”
- **MAGIC-003-D05 — 2026-11-09:** Recalculate casting cost from current caster skills/modifiers at cast commitment and check affordability against that amount. Ready-time cost is a quote; UI reflects changes without another confirmation. User: “1. Yes” to second interview.
- **MAGIC-003-D06 — 2026-11-09:** Separate no-magicka-cost permission from silence bypass. Free spells still obey silence unless their source explicitly authorizes bypass; individual item/innate exceptions remain owner decisions. User: “2. Yes” to second interview.
- **MAGIC-003-D07 — 2026-11-09:** Ordinary NPC spells default to their own caster cost context and full-cost affordability, with moddable exceptions on an enemy basis or spell basis. Exact override precedence, allowed exception modes and debit behavior remain unresolved; no implicit player-skill fallback or unspecified overdraft is approved. User: “3. Yes, but make it possible to mod this on an enemy basis or even a spell basis, if that makes sense.”

- **MAGIC-003-D08 — 2026-11-09:** Automatic versus separate-input casting is configurable per target type with explicit per-spell override priority. Automatic touch/ranged casting attempts current aim under normal target checks; no automatic target acquisition or repeated retry after failure. User: “1. Yes” to third interview.
- **MAGIC-003-D09 — 2026-11-09:** Supported NPC affordability modes: full cost (default); requires positive magicka then deducts cost saturating at zero; and no magicka cost. Mode governs readiness and commitment checks, never independently bypasses silence. Positive-magicka mode is an explicit NPC exception to ordinary full-cost spending, not negative-resource permission. User: “2. Yes” to third interview.
- **MAGIC-003-D10 — 2026-11-09:** NPC affordability override precedence: enemy-specific particular-spell override → enemy-wide override → spell-wide override → full-cost default. Enemy overrides do not apply to player casting. User: “3. Yes” to third interview.

- **MAGIC-003-D11 — 2026-11-09:** Failed cast attempt due to silence, insufficient magicka or invalid target retains the readied spell with feedback, no resource spend/practice and no automatic retry; fresh cast input required, including after failed selection-triggered automatic attempt. User: “1. Yes” to fourth interview.
- **MAGIC-003-D12 — 2026-11-09:** Explicit cancellation clears all uncast ready flags and pending automatic attempts without cost. Readying requests during actual casting are rejected without queuing. Preserve COMBAT-001 weapon-drawing behavior; actual cast interruption belongs to MAGIC-004. User: “2. Yes” to fourth interview.
- **MAGIC-003-D13 — 2026-11-09:** Native saves preserve uncast readied spells; restore validates references, recalculates quote and requires fresh input without automatic cast. Insufficient magicka/silence may leave restored spell readied but blocked; required missing content uses load recovery. User: “3. Yes” to fourth interview.

D05 resolves D01's cost-policy question; D08–D10 resolve D03/D04/D07 policy scope, modes and precedence. The complete [MAGIC-003 specification](systems/MAGIC/MAGIC-003.md) is **Approved — finalized v1** under MAGIC-003-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-002 interview decisions

- **MAGIC-002-A01 — 2026-11-09 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-002 Draft v1. The [specification](systems/MAGIC/MAGIC-002.md) is finalized v1, including explicit classic target/element mappings, complete conversion, authored effect order/repetition, empty-spell rejection, component-aware parameter preservation, invalid-parameter failure and externally approved corrections. Documented mapping/validation fixtures, schemas, provider compatibility and migration dependencies remain open. Individual baseline corrections, including Free Action, still require separate verification and approval. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-002-D01 — 2026-11-09:** Retain classic target mappings 0=self, 1=touch, 2=single ranged, 3=area around caster, 4=area at range, and element mappings 0=fire, 1=cold, 2=poison, 3=shock, 4=magic as initial conversion rules. Reject unknown values and unsupported effect/target/element combinations rather than substitute. Detailed delivery/resistance remains owner scope. User: “1. Yes” to first interview.
- **MAGIC-002-D02 — 2026-11-09:** Preserve authored active-effect order and repeated effects during conversion; do not sort, merge or deduplicate. Runtime admission and stacking retain their owner rules. User: “2. Yes” to first interview.
- **MAGIC-002-D03 — 2026-11-09:** All-unused-slot records fail conversion as usable spells while raw source remains available for diagnostics. Valid effects without duration/chance/magnitude components still count as active effects. User: “3. Yes” to first interview.

- **MAGIC-002-D04 — 2026-11-09:** Copy authored duration/chance/magnitude values only for components supported by the effect; retain unused fields in raw source without gameplay influence. User: “1. Yes” to second interview.
- **MAGIC-002-D05 — 2026-11-09:** Invalid parameters fail conversion explicitly rather than silent repair, including zero divisors for supported scaling components. Zero magnitude/duration/chance remains legal where effect rules permit; zero alone is not corruption. User: “2. Yes” to second interview.
- **MAGIC-002-D06 — 2026-11-09:** Conversion consumes documented approved corrections applied before mod overrides, without hidden converter corrections. Individual corrections, including Free Action, remain unapproved pending separate verification/review, preserving DATA-011. User: “3. Yes” to second interview.

The complete [MAGIC-002 specification](systems/MAGIC/MAGIC-002.md) is **Approved — finalized v1** under MAGIC-002-A01. Documented owner dependencies remain open. No implementation authorized.

## MAGIC-001 interview decisions

- **MAGIC-001-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MAGIC-001 Draft v1. The [specification](systems/MAGIC/MAGIC-001.md) is finalized v1, including stable effect/variant identity, validated explicit replacement, separate crafting eligibility, run-long registry lock, missing-provider recovery and isolated mutable application state. Documented schemas, mapping/eligibility inventories, recipe conflict rules, executable-provider lifecycle and native compatibility/migration contracts remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MAGIC-001-D01 — 2026-11-08:** Every effect and separately referenceable variant has a stable domain-scoped ID independent of display name, implementation class and list position, with explicit classic mappings. User: “1. Yes” to first interview.
- **MAGIC-001-D02 — 2026-11-08:** Reject duplicate additions; permit explicitly declared replacements under resolved mod order. Validate the effect definition, classic mappings and recipe indexes together before publication, with recovery following existing content-validation rules. User: “2. Yes” to first interview.
- **MAGIC-001-D03 — 2026-11-08:** Separate runtime effect support from player crafting availability, with explicit eligibility per spellmaking, enchanting and potion-crafting service. Individual eligibility and player unlock requirements remain their respective feature reviews. User: “3. Yes” to first interview.

- **MAGIC-001-D04 — 2026-11-08:** Validate effect definitions/mappings before actual main-menu entry and keep them fixed for the application run, consistent with DATA-003. Actual applications retain mutable instance state; adding/replacing registered definitions after the lock requires restart. MOD owns executable activation details. User: “1. Yes” to second interview.
- **MAGIC-001-D05 — 2026-11-08:** Required spell/item/saved-effect references to unavailable effects report missing ID/provider and require recovery; no silent dropping or substitution. Restore provider or use explicitly supported migration, preserving existing complete-spell and save-compatibility requirements. User: “2. Yes” to second interview.
- **MAGIC-001-D06 — 2026-11-08:** Listing, crafting previews and definition validation have no gameplay side effects. Each actual application receives separate mutable state; inspection cannot consume resources, apply bonuses or advance timers, and actors cannot accidentally share duration/magnitude state. User: “3. Yes” to second interview.

The complete [MAGIC-001 specification](systems/MAGIC/MAGIC-001.md) is **Approved — finalized v1** under MAGIC-001-A01. Documented owner dependencies remain open. No implementation authorized.

## COMBAT-021 interview decisions

- **COMBAT-021-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-021 Draft v1. The [specification](systems/COMBAT/COMBAT-021.md) is finalized v1, including preserved inventory/ownership, once-only corpse transfer, bounded placement/support, cosmetic fallback, quest-end retention and explicit persistence/cleanup. Documented equipment/effect cleanup, identity/transfer/save boundaries, native placement/support profiles, cleanup/disposal/late-grant policies, metadata adapters and failure fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-021-D01 — 2026-11-08:** Corpse receives eligible carried/equipped items including quest rewards/recovered arrows with preserved identity/quantity/condition/enchantments/remaining effects. Equipment becomes unequipped; explicit ITEM/MAGIC expiry/nonrecoverability rules still govern. User: “1. Yes” to first interview.
- **COMBAT-021-D02 — 2026-11-08:** One stable prepared corpse identity per death, items move exactly once without simultaneously lootable actor/corpse copies. Failed creation/transfer preserves original items/pending obligation rather than deletion/fresh-copy retry. User: “2. Yes” to first interview.
- **COMBAT-021-D03 — 2026-11-08:** Place from death position with bounded collision-checked local supported-ground adjustment where appropriate, no wall/room crossing. Flying/swimming/unsupported/platform cases need explicit profiles; failure preserves pending loot instead of unrelated teleport. User: “3. Yes” to first interview.

- **COMBAT-021-D04 — 2026-11-08:** Corpse transfers existing resolved inventory without fresh random loot merely for death/restore/recreation. Explicit ITEM/mod death-generated loot may resolve once and retain outcome. User: “1. Yes” to second interview.
- **COMBAT-021-D05 — 2026-11-08:** Quest completion alone does not delete corpse/items; removal needs explicit quest/content cleanup policy. Protect ordinary/later items from source automatic quest-end destruction. User: “2. Yes” to second interview.
- **COMBAT-021-D06 — 2026-11-08:** Empty corpse remains nonblocking visual/interaction marker until explicit location/reset/cleanup policy; not immediate disappearance on loot. Lifetime/cleanup moddable; respect outstanding quest/transfer obligations. User: “3. Yes” to second interview.

- **COMBAT-021-D07 — 2026-11-08:** Corpse art uses validated creature/form/body-variant definitions, retaining applicable female-corpse override and mod variants. Art cannot alter loot/identity/death. User: “1. Yes” to third interview.
- **COMBAT-021-D08 — 2026-11-08:** Missing designated art with otherwise valid gameplay data uses generic nonblocking lootable remains marker; cosmetic failure alone cannot lose loot/block finalization. Required item/identity/placement failure still uses recovery. User: “2. Yes” to third interview.
- **COMBAT-021-D09 — 2026-11-08:** Valid moving-platform corpse attachment retains stable support-relative state where supported, including native restore. Support loss uses explicit local placement/recovery without geometry bypass/inventory-record loss. User: “3. Yes” to third interview.

- **COMBAT-021-D10 — 2026-11-08:** Unequip through checked ITEM/MAGIC cleanup once; preserve remaining properties without fresh strike/break payloads, charge refresh or summoned lifetime restart. Legitimate expiry/removal applies; retries cannot repeat effects. User: “1. Yes” to fourth interview.
- **COMBAT-021-D11 — 2026-11-08:** Preserve ownership/quest/legal metadata, not automatic player ownership/legal pickup. Looting uses approved MOVE-022/ITEM transfer admission; LAW/content owns exceptions, no capacity/restriction bypass from corpse readiness. User: “2. Yes” to fourth interview.

The complete [COMBAT-021 specification](systems/COMBAT/COMBAT-021.md) is approved — finalized v1 under COMBAT-021-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-020 interview decisions

- **COMBAT-020-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-020 Draft v1. The [specification](systems/COMBAT/COMBAT-020.md) is finalized v1, including immediate gameplay death, explicit quest synchronization, distinct corpse readiness, per-actor threat cleanup, late quest grants, bounded recovery and coherent pending-death saves. Documented quest work/order/recovery budgets, corpse association/transfer boundaries, late disposal handling, owner receipts, disclosure and native save fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-020-D01 — 2026-11-08:** Confirmed enemy death immediately stops ordinary AI/attacks/living-target eligibility while quest/corpse finalization may remain pending. No repeated killing or zero-health combat from delayed acknowledgment. User: “1. Yes” to first interview.
- **COMBAT-020-D02 — 2026-11-08:** Quest-linked death submits stable death fact and waits for explicit required-work outcome before corpse/inventory finalization. Required quest-item placement must complete or retain pending obligation; missing acknowledgment uses bounded explicit recovery, not invisible indefinite wait. User: “2. Yes” to first interview.
- **COMBAT-020-D03 — 2026-11-08:** Persist dead actor identity/outcome independently of active scene representation; cleanup/notifications complete once across retry/load, retaining quest/source/corpse obligations. User: “3. Yes” to first interview.

- **COMBAT-020-D04 — 2026-11-08:** Pending required quest/death work leaves actor definitively dead but corpse inventory unavailable until ready. Optional visuals can appear; safe ordinary gameplay may continue. Attempted interaction may report temporarily unavailable rather than expose incomplete loot. User: “1. Yes” to second interview.
- **COMBAT-020-D05 — 2026-11-08:** Distinguish Death Confirmed from Death Finalized/Corpse Ready. Attribution/quest death facts attach to confirmation; loot-ready notification waits successful finalization. Owner reward predicates remain separate and deduplicated. User: “2. Yes” to second interview.
- **COMBAT-020-D06 — 2026-11-08:** Immediately remove only dead actor's threat contribution; do not globally clear alert while other threats remain. Rest/exhaustion purpose-specific threat policies preserved; pending corpse not living threat. User: “3. Yes” to second interview.

- **COMBAT-020-D07 — 2026-11-08:** Applicable first-injury quest reaction precedes killed-foe reaction on same lethal hit without delaying authoritative death/re-enabling actor. Track required reaction obligations and no duplicate counts. User: “1. Yes” to third interview.
- **COMBAT-020-D08 — 2026-11-08:** Legitimate later quest item action may target associated ready corpse via retained actor/corpse association and exactly-once transfer identity. Original required work still gates initial readiness; late action cannot recreate corpse/revive actor. User: “2. Yes” to third interview.
- **COMBAT-020-D09 — 2026-11-08:** Retries reuse death/source/prepared corpse/loot identities; never resurrect/reroll loot/increment kill or reward again. Required quest/corpse failure remains explicit recovery, not new death. User: “3. Yes” to third interview.

- **COMBAT-020-D10 — 2026-11-08:** Native saves support confirmed-dead/pending quest-corpse finalization when progress/obligations captured coherently. Restore continues without death replay/incomplete loot. If operation not safely serializable, temporarily block save with explanation. User: “1. Yes” to fourth interview.
- **COMBAT-020-D11 — 2026-11-08:** Optional enemy-death text alert enabled by default, settings-configurable, once after successful finalization without hidden name/location disclosure. Missing text/audio never blocks death/corpse completion. User: “2. Yes” to fourth interview.

The complete [COMBAT-020 specification](systems/COMBAT/COMBAT-020.md) is approved — finalized v1 under COMBAT-020-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-019 interview decisions

- **COMBAT-019-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-019 Draft v1. The [specification](systems/COMBAT/COMBAT-019.md) is finalized v1, including owned surrender prompt, retained deferred hit, acceptance/refusal/episode suppression, forced surrender, success-only arrest health and unresolved-decision save restrictions. Documented LAW episode/acceptance/reputation schemas, numeric-mutation boundary, simultaneous-hit/source invalidation, court handoff, retained receipts and UI/teardown/save fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-019-D01 — 2026-11-08:** First qualifying positive physical guard hit in active enforcement episode requests LAW-authorized surrender offer before applying hit. Eligibility moddable; guard identity/contact alone not proof of arrest authorization. User: “1. Yes” to first interview.
- **COMBAT-019-D02 — 2026-11-08:** Prompt owns gameplay suspension, with one active surrender decision and no advancing other attacks. Release only own reason; other restrictions remain. User: “2. Yes” to first interview.
- **COMBAT-019-D03 — 2026-11-08:** Retain exact pending hit source/target/rolls/damage/phase context; defer its gameplay effects/costs until response. No mutable shared damage lookup/reroll/duplicate application. User: “3. Yes” to first interview. Exact preoffer numeric-versus-mutation boundary remains integration work.

- **COMBAT-019-D04 — 2026-11-08:** Only committed LAW arrest/handoff discards deferred hit damage/poison/wear/strikes/costs. Clicking Yes alone is insufficient; unrelated/earlier committed facts remain. User: “1. Yes” to second interview.
- **COMBAT-019-D05 — 2026-11-08:** Explicit No or completed LAW surrender rejection resolves retained hit once through normal phases, then resumes only when other gates permit. Technical arrest failure retains decision/operation for explicit recovery, not refusal fallback. User: “2. Yes” to second interview.
- **COMBAT-019-D06 — 2026-11-08:** Explicit refusal suppresses ordinary offers for rest of enforcement episode; later new episode may offer under LAW identity/reset policy. No permanent character-wide already-shown flag. User: “3. Yes” to second interview.

- **COMBAT-019-D07 — 2026-11-08:** After refusal, later guard hit with resolved original physical amount≥current player health requests LAW forced surrender before its mutations. Accepted arrest replaces hit; rejected hit proceeds through CHAR prevention/death. LAW owns chance/reputation applicability. User: “1. Yes” to third interview.
- **COMBAT-019-D08 — 2026-11-08:** Successfully committed voluntary/forced arrest sets living player health to 1. Rejection/technical failure does not alter health before ordinary damage; arrest health policy moddable. User: “2. Yes” to third interview.
- **COMBAT-019-D09 — 2026-11-08:** Ordinary prompt requires explicit Yes/No; Escape/window-close cannot silently decide. Context/session invalidation follows owner cancellation/recovery and cannot apply stale response to another character. User: “3. Yes” to third interview.

- **COMBAT-019-D10 — 2026-11-08:** Qualifying physical guard arrows share melee surrender rules using captured responsible guard identity, independent of later equipment/target. Spell-trigger surrender needs explicit LAW/MAGIC policy. User: “1. Yes” to fourth interview.
- **COMBAT-019-D11 — 2026-11-08:** Block ordinary saves while surrender decision/forced evaluation/arrest handoff unresolved, explain temporary restriction, preserve pending hit without replay/drop and leave existing saves unchanged. User: “2. Yes” to fourth interview.
- **COMBAT-019-D12 — 2026-11-08:** Legitimate LAW rejection after Yes also suppresses ordinary offers for current episode while later eligible forced-surrender checks remain. Technical failure is not completed refusal/rejection and retries cannot consume new chance. User: “3. Yes” to fourth interview. Extends D06/D07 ordinary/forced handling to completed rejection.

The complete [COMBAT-019 specification](systems/COMBAT/COMBAT-019.md) is approved — finalized v1 under COMBAT-019-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-018 interview decisions

- **COMBAT-018-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-018 Draft v1. The [specification](systems/COMBAT/COMBAT-018.md) is finalized v1, retaining moddable civilian contact-kill, explicit protection/source scope, identity-preserving guard activation and owner-governed incident classification/enforcement. Documented civilian/protection schemas, guard identity/state publication, death content, LAW/FACT/QUEST/racial contracts and native save/partial-failure fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-018-D01 — 2026-11-08:** Retain DFU-style ordinary mobile-civilian contact-kill shortcut as current default rather than replacing with ordinary health/accuracy damage profile. Make behavior explicitly moddable so alternate civilian damage/health rules are supported. User: “1. I'd say keep the default behavior for now, but definitely make this moddable.” to first interview. Exact attack/source/spell/protection scope requires follow-up; no automatic benign-spell death inferred.
- **COMBAT-018-D02 — 2026-11-08:** Report distinct attack-attempt/contact, actual injury and confirmed-kill facts with responsible actor/victim/operation identity to LAW. LAW owns assault/murder classification, detection/enforcement; combat does not automatically spawn guards/declare murder solely from contact. User: “2. Yes” to first interview.
- **COMBAT-018-D03 — 2026-11-08:** Peaceful guard entering combat retains identity/persistent state; pending damage applies once to same guard. Representation failure preserves guard and uses explicit recovery without deletion/duplicates/lost hit. User: “3. Yes” to first interview.

- **COMBAT-018-D04 — 2026-11-08:** Default shortcut applies to valid player melee/unarmed or player-arrow contact with ordinary mobile civilian, bypassing ordinary accuracy/damage rolls for that civilian. Exclude guards/combat actors/dead targets/interaction clicks; source/target eligibility moddable. User: “1. Yes” to second interview.
- **COMBAT-018-D05 — 2026-11-08:** Spells use explicit MAGIC eligibility/outcomes, not civilian contact-kill merely from touch. Harmful effects may kill through declared policies; benign spells do not become murder shortcut. User: “2. Yes” to second interview.
- **COMBAT-018-D06 — 2026-11-08:** Civilian shortcut grants no default weapon/Hand-to-Hand/Critical Strike practice, retaining prior approvals. Explicit racial contact/kill abilities receive actual settled result once; failed/duplicate death cannot trigger false feeding/kill. User: “3. Yes” to second interview.

- **COMBAT-018-D07 — 2026-11-08:** Explicit quest/content/mod profiles may exempt civilians from shortcut or supply death prevention; quest linkage alone grants no blanket protection. Default contact kill retained; confirmed death alone grants kill fact. User: “1. Yes” to third interview.
- **COMBAT-018-D08 — 2026-11-08:** Player shortcut does not automatically apply to nonplayer arrows/infighting/hazards; explicit NPC/content damage policies govern. Preserve true responsible source for legal/quest outcomes, never substitute player. User: “2. Yes” to third interview.
- **COMBAT-018-D09 — 2026-11-08:** Valid hostile player weapon/arrow contact activates peaceful guard combat representation before ordinary accuracy/damage, even if later miss/zero. Activation alone is not authoritative crime/duplicate spawn. Benign spell response remains explicit effect policy. User: “3. Yes” to third interview.

The complete [COMBAT-018 specification](systems/COMBAT/COMBAT-018.md) is approved — finalized v1 under COMBAT-018-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-017 interview decisions

- **COMBAT-017-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-017 Draft v1. The [specification](systems/COMBAT/COMBAT-017.md) is finalized v1, including finite moddable enemy ammunition, ranged admission/cadence, retained release intent, shared actual-recipient resolution and owner-governed attribution. Enemy supply is cross-referenced in COMBAT-008. Documented NPC loadouts/preferences, range/aim profiles, scheduling, generated supply, MAGIC recovery/actor adapters, mod schemas and save/partial-operation fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-017-D01 — 2026-11-08:** Enemy attacks against player/nonplayer use shared approved route/material/accuracy/damage/effect contracts with explicit actor policies, not divergent formulas. NPC owns infighting targeting/hostility. User: “1. Yes” to first interview.
- **COMBAT-017-D02 — 2026-11-08:** Ordinary enemy archers require/consume finite eligible inventory arrows; supply/eligibility/consumption rules explicitly moddable, including generated/unlimited policies. NPC/content owns starting supplies/empty behavior. User: “2. Yes, but definitely make this behavior and rules moddable.” to first interview.
- **COMBAT-017-D03 — 2026-11-08:** Aim at retained intended target's current valid position at release, with optional bounded predictive lead using actual projectile speed/valid movement. Released flight independent/nonhoming by default. Use real target posture geometry, not player-only crouch offset. User: “3. Yes” to first interview.

- **COMBAT-017-D04 — 2026-11-08:** Initial ranged start: distance>6 and <51.2 reference units, detected/clear sight and horizontal half-angle<22.5°, with moddable actor/weapon/spell profiles/native scale verification. Admission limits do not truncate released flight. User: “1. Yes” to second interview.
- **COMBAT-017-D05 — 2026-11-08:** Otherwise-eligible ranged opportunities: bow 1/32, ranged spell 1/40 per 0.0625 eligible seconds. Moddable, one active attack; do not automatically import melee interval/player bow cooldown. MAGIC owns spell affordability/recovery. User: “2. Yes” to second interview.
- **COMBAT-017-D06 — 2026-11-08:** Invalid/disappeared intended target or failed required sight/facing/range at release cancels without replacement/remembered-position shot. Explicit mod blind-fire/suppression policy may differ. Already released shots remain independent. User: “3. Yes” to second interview.

- **COMBAT-017-D07 — 2026-11-08:** Finite enemy supply reuses COMBAT-008 eligible inventory selection (summoned-first/shortest life/quest exclusion/stable ties), no draw reservation and release-time revalidation/consumption, including explicit multishot policies. Lost ammo cancels without phantom projectile/release award; do not import player fatigue cost. User: “1. Yes” to third interview.
- **COMBAT-017-D08 — 2026-11-08:** NPC AI selects one bow/spell intent before admission, not independent competing rolls creating two actions. Preference/unavailable-resource fallback is explicit moddable NPC policy, not callback order. User: “2. Yes” to third interview.
- **COMBAT-017-D09 — 2026-11-08:** Report original responsible actor/actual victim to NPC/LAW/QUEST; owners decide retaliation/allegiance/crime. Friendly fire does not directly provoke universal hostility or forced immediate target switch inside damage delivery. User: “3. Yes” to third interview.

The complete [COMBAT-017 specification](systems/COMBAT/COMBAT-017.md) is approved — finalized v1 under COMBAT-017-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-016 interview decisions

- **COMBAT-016-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-016 Draft v1. The [specification](systems/COMBAT/COMBAT-016.md) is finalized v1, including commitment-time contact, reach/facing, single-target body blocking, bounded prediction and explicit capability-driven door bashing through shared melee cadence. Enemy-specific door integration is cross-referenced in COMBAT-006. Documented native geometry, awareness/capability/prediction definitions, mod profiles, source adapters, door integration and save/recovery fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-016-D01 — 2026-11-08:** Recheck intended target's current contact position/reach/facing/solid obstruction at commitment; attack-start sight/range does not guarantee contact. Support valid close contact and moddable actor/weapon profiles. User: “1. Yes” to first interview.
- **COMBAT-016-D02 — 2026-11-08:** Baseline horizontal half-angles: start 22.5°, connect 35.156°. Remove unconditional ≤0.25-distance yaw bypass; close targets must still be in front/eligible. Mods may define broader/omnidirectional attacks. User: “2. Yes” to first interview.
- **COMBAT-016-D03 — 2026-11-08:** Door bash requires explicit selected door-target intent, never fallback from missed actor swing to remembered door. Retain/revalidate door identity; NPC AI owns choice and shared appropriate door rules exclude player-specific crime behavior. User: “3. Yes” to first interview.

- **COMBAT-016-D04 — 2026-11-08:** Baseline melee reach 2.25 reference units against player/other actors, measured to valid target contact and native-scale verified; actor/weapon overrides moddable. Do not retain optional shorter 1.5 AI-target initiation baseline. User: “1. Yes” to second interview.
- **COMBAT-016-D05 — 2026-11-08:** Ordinary enemy melee is single intended target by default; explicit mod/creature profiles may enable cleaves/sweeps with declared selection/order. Player default cleave unchanged. User: “2. Yes” to second interview.
- **COMBAT-016-D06 — 2026-11-08:** Allow bounded explicit prediction profile to initiate wind-up slightly before current reach; commitment still needs actual current reachable contact. Exact look-ahead/default margin is NPC tuning, not source frame-distance delta. User: “3. Yes” to second interview.

- **COMBAT-016-D07 — 2026-11-08:** Enemy door-bash selection requires explicit NPC/creature capability and current pursuit/behavior policy; not universal enemy ability. Capability/door eligibility moddable; assignments NPC/content-owned. User: “1. Yes” to third interview.
- **COMBAT-016-D08 — 2026-11-08:** Intended door open/moving at commitment skips bash without closing, interval reroll or actor substitution. This differs from deliberate player open-door strike. User: “2. Yes” to third interview.
- **COMBAT-016-D09 — 2026-11-08:** Eligible closed enemy door bash uses applicable COMBAT-006 lock chance/magical-hold rejection/persistent unlock-opening, authoritative noise and modded enemy policy, without automatic player crime/universal hostility. Later passage remains NPC/movement, not teleport/automatic transition. User: “3. Yes” to third interview.

- **COMBAT-016-D10 — 2026-11-08:** In baseline single-target enemy melee, interposing solid actor blocking all valid paths prevents intended hit without redirecting to blocker. Explicit cleave/friendly-fire profiles may differ. User: “1. Yes” to fourth interview.
- **COMBAT-016-D11 — 2026-11-08:** Deterministic reachable portion of valid target collider can qualify despite blocked center, within reach/facing. Solid floors/walls/closed doors block; thickness cannot extend reach. User: “2. Yes” to fourth interview.
- **COMBAT-016-D12 — 2026-11-08:** Enemy bash uses COMBAT-015 melee interval/Speed gate/captured timing/interruption, no separate bypass loop. Genuine start draws interval once; failed roll/changed door cannot reset into rapid attempts. Do not import player fatigue/practice costs. User: “3. Yes” to fourth interview.

The complete [COMBAT-016 specification](systems/COMBAT/COMBAT-016.md) is approved — finalized v1 under COMBAT-016-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-015 interview decisions

- **COMBAT-015-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-015 Draft v1. The [specification](systems/COMBAT/COMBAT-015.md) is finalized v1, including explicit lifecycle, retained target/timing, melee interval/opportunity cadence, restriction clocks and load cancellation with retained interval. Documented animation bounds, NPC initialization/admission/clock inventory, scheduling, contact/ranged integration, schemas and save/partial-operation fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-015-D01 — 2026-11-08:** Enemy attacks have explicit wind-up/commitment/recovery with one animation-synchronized gameplay marker robust to skipped/duplicate visual frames. NPC AI supplies intent; presentation cannot authorize extra hits. User: “1. Yes” to first interview.
- **COMBAT-015-D02 — 2026-11-08:** Death/paralysis/explicit attack-disable or interrupt cancels unfinished enemy work immediately without later resumption; retain completed hits/released projectiles. Ordinary pause freezes progress; knockback alone retains COMBAT-012 noninterrupting policy. User: “2. Yes” to first interview.
- **COMBAT-015-D03 — 2026-11-08:** Capture intended target identity at attack start; revalidate at commitment, never silently switch to current AI target mid-attack. COMBAT-016/017 define miss/cancel on invalid reach/target; AI may choose a new target for next attack. User: “3. Yes” to first interview.

- **COMBAT-015-D04 — 2026-11-08:** Initial melee interval T=max(0,U[1500,3000]−50×(player level−10)+approved reflex adjustment)/980 eligible seconds, parameters moddable. CHAR-010 coupling retained; not automatically bow/spell cooldown. User: “1. Yes” to second interview.
- **COMBAT-015-D05 — 2026-11-08:** Melee interval begins on actual admitted attack start, progresses alongside wind-up/animation. Next attack needs finished current attack and expired interval. Cancellation retains remaining timer without reroll/full restart. User: “2. Yes” to second interview.
- **COMBAT-015-D06 — 2026-11-08:** Otherwise eligible melee with expired timer uses DFU Speed-floor-8 opportunity check on 0.0625 eligible-second ticks, unbiased owned randomness/moddable parameters. Separate from accuracy/natural reflex gates; no rendered-stall attack burst. User: “3. Yes” to second interview.

- **COMBAT-015-D07 — 2026-11-08:** Capture enemy animation timing/profile from start-time Speed; later effects apply to future attacks. Initial model may retain permanent-Speed/floored-live-Speed pacing relationship with positive validated timing/moddable profiles. User: “1. Yes” to third interview.
- **COMBAT-015-D08 — 2026-11-08:** Paralysis/explicit AI or attack disable/pause/loading freeze remaining melee interval. Knockback alone advances interval but blocks new attack starts; canceled attacks do not resume on restriction removal. User: “2. Yes” to third interview.
- **COMBAT-015-D09 — 2026-11-08:** No valid target/action at opportunity leaves expired interval, without queueing intent or drawing new interval. Roll interval only on genuine admitted melee start; protect opportunity/interval operations separately from duplicate delivery. User: “3. Yes” to third interview.

- **COMBAT-015-D10 — 2026-11-08:** Active-weapon replacement/removal/breakage cancels unfinished enemy attack work, retaining committed outcomes/remaining melee interval without silent unarmed substitution. Independent released projectiles persist; new attacks may select proper RULE-012 route. User: “1. Yes” to fourth interview.
- **COMBAT-015-D11 — 2026-11-08:** Explicitly declared transformation/scripted incapacitation/action-blocking states prevent new attack starts. Cosmetic Hurt alone does not cancel progressing attack; ordinary animation playback is not universal attack lock. NPC/content profiles declare state eligibility. User: “2. Yes” to fourth interview.
- **COMBAT-015-D12 — 2026-11-08:** Native load cancels unfinished enemy wind-ups/unreleased remaining components, retains saved remaining melee interval/committed outcomes and requires fresh eligible AI decision/opportunity. No interval reroll or restored animation-flag hit. Released arrows/spells persist separately under COMBAT-009/014. User: “3. Yes” to fourth interview.

The complete [COMBAT-015 specification](systems/COMBAT/COMBAT-015.md) is approved — finalized v1 under COMBAT-015-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-014 interview decisions

- **COMBAT-014-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-014 Draft v1. The [specification](systems/COMBAT/COMBAT-014.md) is finalized v1, including multi-target area delivery deduplicated per actor, obstruction/eligibility/blocking policies, committed payload capture, modded lingering areas and same-location persistence. Documented MAGIC effect/stack definitions, contact/collision fixtures, query/ordering contracts, pulse/entry policies, recovery and native save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-014-D01 — 2026-11-08:** One spell impact delivers its bundle at most once per distinct actor, deduplicating colliders and direct-plus-area inclusion. Area spells still affect multiple valid actors within the particular spell's configured impact area/range; this is not a one-target cap. Explicit repeating pulses/multi-hit spells may declare separate delivery identities through mods. User: “1. Yes, but also remember that ‘area of effect’ spells exist and can apply an effect to multiple valid targets within the impact area of that particular spell/range.” to first interview.
- **COMBAT-014-D02 — 2026-11-08:** Ordinary touch targets one eligible forward actor within configured reach via unobstructed valid contact, including very close overlap. Solid walls/closed blocking doors prevent contact; exclude caster from ordinary touch. User: “2. Yes” to first interview.
- **COMBAT-014-D03 — 2026-11-08:** Ordinary area spells require clear path from area origin to valid target contact, not overlap through solid walls/closed doors. Obstruction policies moddable; intentionally differs from inspected overlap-only DFU. User: “3. Yes” to first interview.

- **COMBAT-014-D04 — 2026-11-08:** Default caster-centered area excludes caster; ranged explosion may affect caster inside valid blast. Explicit spell/mod overrides supported; self-target MAGIC mode separate. User: “1. Yes” to second interview.
- **COMBAT-014-D05 — 2026-11-08:** Ordinary area delivery considers allies/peaceful actors/civilians plus enemies, subject to each effect/spell's declared eligibility. Explicitly support moddable per-spell policies excluding allies/passive creatures or including them. MAGIC owns definitions; harmful/beneficial behavior is not inferred merely from area mode. User: “2. Yes, but make this a moddable behavior, but that might be more a ‘MAGIC’ spec. For example a spell being able to specifically not effect allies/passive creatures, and others being able to, etc.” to second interview.
- **COMBAT-014-D06 — 2026-11-08:** Ordinary ranged spell stops/delivers or explodes at first valid blocking actor/world contact even if contacted actor later resists all effects. Resistance does not permit pass-through. Collision eligibility/piercing/other delivery policies moddable. User: “3. Yes” to second interview.

- **COMBAT-014-D07 — 2026-11-08:** Capture committed delivery's spell definition/caster identity/relevant caster power; targets use current eligibility/resistance at application. Later caster buffs/death/spell changes cannot rewrite released payload. MAGIC owns field/formula contract. User: “1. Yes” to third interview.
- **COMBAT-014-D08 — 2026-11-08:** Ranged spells use checked spawn-offset paths and full traveled-segment nearest-blocker collision, with solid geometry priority at effective ties, spell-specific collision size and modded policies. Offset cannot bypass a wall; obstruction receives released impact. User: “2. Yes” to third interview.
- **COMBAT-014-D09 — 2026-11-08:** Impact area has no default gameplay recipient cap; deduplicate, nearest valid contact first/stable identity ties, revalidate each, freeze candidate set per impact. Technical overflow cannot silently omit recipients. User confirmed question 3 with D10 extension in third interview.
- **COMBAT-014-D10 — 2026-11-08:** Support modded spells creating lingering impact areas, explicitly not vanilla behavior. MAGIC owns definitions; later pulses/entry policies need declared delivery identity/lifetime/cadence rather than reusing one-shot candidate freeze as universal prohibition. User addition: “would be cool to be able to add modded spells that create a lingering area of sorts after impact, not vanilla behavior at all”.

- **COMBAT-014-D11 — 2026-11-08:** Lingering-area mods explicitly define duration/shape/radius, pulse interval or entry policy, caster/alliance eligibility and effect stack/refresh rules. Missing required policy fails validation instead of invented repeating/permanent behavior. User: “1. Yes” to fourth interview.
- **COMBAT-014-D12 — 2026-11-08:** Each pulse acquires/revalidates new recipients with at most one delivery per actor per pulse; actor may qualify on later pulses. MAGIC decides stack/refresh/replace/resistance. User: “2. Yes” to fourth interview.
- **COMBAT-014-D13 — 2026-11-08:** Released spell missiles/supported lingering areas persist in same-location native saves, freezing during pause/load and restoring remaining lifetime/pulse state without cast/cost/completed-delivery replay. Different-location exit discards delivery objects by default; applied lasting effects retain MAGIC lifecycle. User: “3. Yes” to fourth interview.

- **COMBAT-014-D14 — 2026-11-08:** Initial profile defaults: touch reach 3.0/acquisition radius 0.25; missile speed 25 reference units/second, collision radius 0.45/lifetime 8 eligible seconds; area radius 4.0. Per-spell/mod overrides supported; native scale verification required. Not a universal radius for every spell. User: “1. Yes” to fifth interview.
- **COMBAT-014-D15 — 2026-11-08:** Effect ally-exclusion does not itself permit missile pass-through; physical collision eligibility and effect applicability are distinct moddable policies. User: “2. Yes” to fifth interview.
- **COMBAT-014-D16 — 2026-11-08:** Ordinary resistance/ineligibility on one recipient/effect does not prevent other valid targets/independently applicable effects under MAGIC declared order. Technical failure retains completed deliveries for explicit recovery, not whole-area replay or false resistance. User: “3. Yes” to fifth interview.

The complete [COMBAT-014 specification](systems/COMBAT/COMBAT-014.md) is approved — finalized v1 under COMBAT-014-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-013 interview decisions

- **COMBAT-013-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-013 Draft v1. The [specification](systems/COMBAT/COMBAT-013.md) is finalized v1, including shared single-pass intake, ordered prevention/death settlement, retained source attribution, actual-loss injury feedback and optional player pain voices off by default. Documented adapters, ordering/accounting, suspension continuation, feedback settings/mappings, prevention recovery and save/projectile deduplication fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-013-D01 — 2026-11-08:** Enemy attacks/projectiles/magical damage/hazards share an explicit player-health intake contract with source/type/amount/operation identity. Sources retain eligibility/formulas; shared intake does not cause falls to trigger weapon poison/wear/practice. User: “1. Yes” to first interview.
- **COMBAT-013-D02 — 2026-11-08:** Ordinary player injury flash requires actual health loss from settled intake, not preapplication amount. Prevention/zero-loss may have separate owner-defined feedback. User: “2. Yes” to first interview.
- **COMBAT-013-D03 — 2026-11-08:** Incoming damage operations resolve once in explicit authoritative order, fully settling prevention/death before next. Reject remaining ordinary damage after confirmed death; successful prevention permits subsequent genuine hits if eligible, without new invulnerability window. User: “3. Yes” to first interview.

- **COMBAT-013-D04 — 2026-11-08:** Intake uses upstream resolved amount without rerunning accuracy/armor/resistance/damage formulas; CHAR prevention and explicit intake policy still apply. No accidental second mitigation. User: “1. Yes” to second interview.
- **COMBAT-013-D05 — 2026-11-08:** Valid zero amount yields no-loss result without injury flash/lethal-prevention checks. Negative/nonfinite/unsupported amount is validation failure, not healing or silent repair. Healing separate. User: “2. Yes” to second interview.
- **COMBAT-013-D06 — 2026-11-08:** New ordinary damage stops during pause/loading; already-committed unfinished work retains safe-continuation obligations. Reject old-session/already-dead callbacks; declared rest/travel/scripted simulation may authorize damage. Menu entry cannot generate fresh attack or erase committed hit. User: “3. Yes” to second interview.

- **COMBAT-013-D07 — 2026-11-08:** Player pain voices are an explicit settings option, OFF by default. When enabled, surviving injury uses race/form-appropriate optional audio with 40% chance and heavy classification actual health loss ≥ one-quarter effective max health, using presentation-only randomness. Source/type policies may suppress/replace to avoid duplicate landing/pain sounds. User: “1. Yes, but I'd keep this as a settings option, and have it off by default.” to third interview. This is player pain audio, not an unrequested change to NPC pain/death audio settings.
- **COMBAT-013-D08 — 2026-11-08:** Retain original responsible actor/item/projectile/hazard attribution after source disappears; valid committed damage does not require live scene source. Never redirect blame to another actor. Missing required resolution data fails explicitly; optional attribution absence is distinct. User: “2. Yes” to third interview.
- **COMBAT-013-D09 — 2026-11-08:** Health/prevention/death settlement is independent of missing/disabled flash/audio; flashes respect applicable visual/accessibility preferences. Feedback failure cannot replay damage or suppress death handoff. No new camera shake/forced movement/player knockback. User: “3. Yes” to third interview.

The complete [COMBAT-013 specification](systems/COMBAT/COMBAT-013.md) is approved — finalized v1 under COMBAT-013-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-012 interview decisions

- **COMBAT-012-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-012 Draft v1. The [specification](systems/COMBAT/COMBAT-012.md) is finalized v1, including settled-intake injury feedback, optional pain voices, delivered-physical weight-based knockback, bounded impulse combination, collision/action restrictions and persistent movement. Documented native strength/decay tuning, mass/direction/movement policies, feedback mappings, ordering, mod schemas and save/recovery fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-012-D01 — 2026-11-08:** Physical injury feedback (blood/pain) uses settled physical intake, requiring actual physical health loss by default; predicates are moddable. Miss/zero/prevention/separate magic have distinct applicable feedback rather than injury from an earlier estimate. User: “1. Yes” to first interview.
- **COMBAT-012-D02 — 2026-11-08:** Default physical knockback uses final enchantment-modified physical damage actually delivered to intake before health saturation, not original D0/actual loss/combined magic. Overkill can impart force; skipped intake or zero final physical amount gives none. User: “2. Yes” to first interview.
- **COMBAT-012-D03 — 2026-11-08:** Baseline attack knockback affects combat NPCs/enemies, not player unless explicit mod/separately approved effect enables it. Actor eligibility/resistance/immunity is moddable. User: “3. Yes” to first interview.

- **COMBAT-012-D04 — 2026-11-08:** Initial knockback retains DFU damage/target-weight relationship with bounded minimum/maximum strength and eligible-gameplay-time decay. Coefficients/resistance are moddable; converted defaults require Godot scale tests and invalid/zero weight cannot divide by zero. User: “1. Yes” to second interview.
- **COMBAT-012-D05 — 2026-11-08:** Stronger incoming impulse replaces remaining strength/direction; equal/weaker impulse leaves existing knockback unchanged. Combination policies are moddable; no additive baseline accumulation. User: “2. Yes” to second interview.
- **COMBAT-012-D06 — 2026-11-08:** Grounded targets use horizontal incoming-attack knockback; flying/swimming targets may use 3D displacement through their movement owner. Direction policies are moddable. No default upward launch for grounded actors; collision/mode restrictions remain binding. User: “3. Yes” to second interview.

- **COMBAT-012-D07 — 2026-11-08:** Knockback uses normal stop/slide collision without default extra wall damage/crushing/teleport/shoving actors aside. Modded collision damage may be explicit; ledge displacement may invoke ordinary movement-owned falls. User: “1. Yes” to third interview.
- **COMBAT-012-D08 — 2026-11-08:** Active knockback suppresses ordinary voluntary movement/new attack starts, but already-started attacks finish unless explicit stun/paralysis/interrupt policy cancels them. Hurt visuals alone cannot cancel gameplay. Stagger interruption/resistance is moddable. User: “2. Yes” to third interview.
- **COMBAT-012-D09 — 2026-11-08:** Optional pain voices for surviving eligible humanoid combat actors with actual physical health loss use 40% chance. Heavy injury iff actual physical loss ≥ one-quarter effective maximum health. Moddable; lethal outcomes use death feedback. Voice randomness isolated from gameplay. User: “3. Yes” to third interview.

- **COMBAT-012-D10 — 2026-11-08:** Lethal physical hits retain eligible blood/impact feedback but skip living-actor knockback/pain voices after confirmed death. Corpse/death displacement is separate moddable presentation policy. User: “1. Yes” to fourth interview.
- **COMBAT-012-D11 — 2026-11-08:** Accuracy miss/zero-damage contact uses declared target parry/deflection sound if supported, otherwise suitable miss/weapon sound; ineffective material retains distinct explanation. Feedback is moddable and does not introduce active-block mechanics. User: “2. Yes” to fourth interview.
- **COMBAT-012-D12 — 2026-11-08:** Pause freezes knockback; native saves preserve remaining authoritative movement state so load cannot erase displacement. Do not replay already-played blood/sounds/voices. Restore through movement/NPC ownership after geometry readiness. Exact schema remains SAVE integration. User: “3. Yes” to fourth interview.

The complete [COMBAT-012 specification](systems/COMBAT/COMBAT-012.md) is approved — finalized v1 under COMBAT-012-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-011 interview decisions

- **COMBAT-011-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-011 Draft v1. The [specification](systems/COMBAT/COMBAT-011.md) is finalized v1, including positive-physical strike eligibility, declared ordering/bases, live-source breakage versus captured arrow payloads, concealment/callback contracts and bounded reactive defaults. Confirmed extensions are cross-referenced in COMBAT-010 and RULE-016. Documented effect schemas, modifier domains, activation/charge policies, missing-source handling, racial/artifact contracts, reaction bounds and save/recovery fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-011-D01 — 2026-11-08:** Default weapon strike enchantments require positive resolved physical damage before health saturation, consistently for player/enemy. Triggers are moddable for contact/successful accuracy/zero-damage/actual-health-loss conditions; misses/material failures do not trigger by default. User: “1. Yes” to first interview.
- **COMBAT-011-D02 — 2026-11-08:** Account for separate magical damage distinctly from explicit pending-physical-damage modifiers, preserving damage types/resistance/attribution/trigger rules. User: “2. Yes” to first interview.
- **COMBAT-011-D03 — 2026-11-08:** Each eligible cleaved enemy receives its own strike-enchantment attempt, at most once per applicable attack component/target. Activation chance/cooldown/charge policy is moddable and must be explicitly supplied by ITEM/MAGIC, not inferred free or once-per-swing. User: “3. Yes” to first interview.

- **COMBAT-011-D04 — 2026-11-08:** Run weapon strike enchantments after existing poison/monster-payload and equipment-wear phases, before primary physical health damage, revalidating source/target under COMBAT-010. User: “1. Yes” to second interview.
- **COMBAT-011-D05 — 2026-11-08:** Poison, ordinary wear and default strike eligibility use original RULE-014 resolved physical amount. Later strike changes to pending physical damage do not undo/recompute/retrigger earlier phases. Retain original and modified amounts separately. User: “2. Yes” to second interview.
- **COMBAT-011-D06 — 2026-11-08:** Applicable strike enchantments execute explicit stable declared order; each declares original-physical versus current-modified damage basis. Missing required order/basis fails validation; no accidental registration-order semantics. User: “3. Yes” to second interview.

- **COMBAT-011-D07 — 2026-11-08:** If ordinary wear breaks/removes source weapon before strike phase, skip remaining source strike enchantments while retaining current target's committed physical outcome; later cleave targets remain canceled under COMBAT-004. Mods may define explicit break-trigger payloads. User: “1. Yes” to third interview. Already-released projectile snapshot interaction requires explicit reconciliation.
- **COMBAT-011-D08 — 2026-11-08:** Positive original resolved physical damage breaks attacker's ordinary break-on-hit concealment even if later strike modifier reduces pending damage to zero. Trigger is moddable; stronger/protected concealment remains MAGIC-owned. User: “2. Yes” to third interview.
- **COMBAT-011-D09 — 2026-11-08:** Gameplay weapon/racial callbacks declare trigger predicates and receive retained outcomes; observation notifications follow applicable result settlement. Notification alone cannot authorize second strike/duplicate effects. Racial abilities such as feeding use explicit owner-validated gameplay operations. User: “3. Yes” to third interview.

- **COMBAT-011-D10 — 2026-11-08:** Already-released arrows retain captured offensive strike payloads after source bow break/removal under COMBAT-009. Costs requiring original item charge/condition spend must explicitly define commitment/missing-source policy; never charge newly equipped bow. D07 live-source skip remains applicable to melee. User: “1. Yes” to fourth interview.
- **COMBAT-011-D11 — 2026-11-08:** Default reactive damage/reflection runs only when defender is alive and otherwise eligible after primary health/prevention settlement. Mods may explicitly support death-trigger retaliation. User: “2. Yes” to fourth interview.
- **COMBAT-011-D12 — 2026-11-08:** Reactive/reflected damage cannot trigger further reflection by default. Mods may enable explicitly bounded chains; retain origin/chain identity and never replay original poison/wear/strike phases by treating reaction as a new full weapon attack. User: “3. Yes” to fourth interview.

The complete [COMBAT-011 specification](systems/COMBAT/COMBAT-011.md) is approved — finalized v1 under COMBAT-011-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-010 interview decisions

- **COMBAT-010-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-010 Draft v1. The [specification](systems/COMBAT/COMBAT-010.md) is finalized v1, including structured outcomes, independent target resolution, sequential component settlement, death/prevention handling and explicit technical recovery. Component-settlement requirements are cross-referenced in RULE-016. Documented adapters, phase ordering/current-component breakage, validity/result schemas, effects integration, recovery scopes and save/prevention fixtures remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-010-D01 — 2026-11-08:** Physical resolution distinguishes invalid context, ineffective material, failed natural-component gate, accuracy miss, successful zero-damage hit and positive damage. Do not infer these outcomes from a scalar zero. User: “1. Yes” to first interview.
- **COMBAT-010-D02 — 2026-11-08:** Each cleaved target receives independent material/body-part/critical/hit/damage resolution. Default natural components share a body part within that target operation under RULE-013, not across different enemies. User: “2. Yes” to first interview.
- **COMBAT-010-D03 — 2026-11-08:** Ordered natural components stop when target dies/becomes invalid, retaining completed outcomes without retargeting. Ordinary gate failure/miss/zero damage continues to next active component; actual death/interruption stops it. User: “3. Yes” to first interview.

- **COMBAT-010-D04 — 2026-11-08:** Settle each natural component's applicable damage/effect/health phases before next component. Do not aggregate into one health mutation or apply displayed totals again. User: “1. Yes” to second interview.
- **COMBAT-010-D05 — 2026-11-08:** Subsequent melee/natural components read current valid stats/defenses/effects after prior settlement, retaining shared selected body part and resolved results. COMBAT-009 arrows retain captured-offense exception. User: “2. Yes” to second interview.
- **COMBAT-010-D06 — 2026-11-08:** Earlier-component reaction killing/paralyzing/otherwise invalidating attacker stops remaining unreleased melee/natural components without undoing completion. Already-released independent projectiles continue under COMBAT-009. Ordinary miss/zero damage does not interrupt. User: “3. Yes” to second interview.

- **COMBAT-010-D07 — 2026-11-08:** If earlier on-hit payload kills/invalidates defender before primary physical health damage, retain completed effects, skip remaining phases requiring living valid defender and stop later components. Retain resolved physical amount separately from actual physical health loss, possibly zero. User: “1. Yes” to third interview.
- **COMBAT-010-D08 — 2026-11-08:** If death prevention leaves defender alive/valid after earlier phase, revalidate/continue against resulting authoritative state rather than treating intermediate zero health as a completed kill. CHAR owns prevention. User: “2. Yes” to third interview.
- **COMBAT-010-D09 — 2026-11-08:** Malformed rule result, failed required hook or partial-application error stops affected operation for explicit recovery, retaining completed phases/random results without alternative formula fallback/reroll. Distinguish technical failure from ordinary miss/resistance/zero damage under RULE-004. User: “3. Yes” to third interview.

- **COMBAT-010-D10 — 2026-11-08:** Retain resolved physical damage, actual health lost and prevention/interruption outcomes separately, with per-component results. Overkill/prevention does not rewrite RULE-016 resolved-damage trigger/scaling basis. User: “1. Yes” to fourth interview.
- **COMBAT-010-D11 — 2026-11-08:** Practice, recovery, poison, wear and enchantments use explicit owner trigger rules rather than one universal hit flag. Contact-based practice/recovery can qualify on miss; default poison/wear require positive resolved physical damage. COMBAT-011 owns additional effect contracts. User: “2. Yes” to fourth interview.
- **COMBAT-010-D12 — 2026-11-08:** Ineffective material receives distinct nonmodal explanation, deduplicated once per attack across targets/components. Feedback is moddable; no new generic miss/zero-damage popup or damage-number display. User: “3. Yes” to fourth interview.

The complete [COMBAT-010 specification](systems/COMBAT/COMBAT-010.md) is approved — finalized v1 under COMBAT-010-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-009 interview decisions

- **COMBAT-009-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-009 Draft v1. The [specification](systems/COMBAT/COMBAT-009.md) is finalized v1, including captured offense/source attribution, actual-contact resolution, checked spawn offsets, swept collision, flight defaults and same-location in-flight persistence. The confirmed projectile snapshot exception is cross-referenced in RULE-013/014. Documented snapshot/hook adapters, absent-source mutations, collision/expiry fixtures, location/streaming boundaries, mod contracts and save/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-009-D01 — 2026-11-08:** Each released arrow retains firing actor, bow identity and relevant bow definition; later bow swaps, breakage/removal or other shots cannot rewrite its source or recall it. User: “1. Yes” to first interview.
- **COMBAT-009-D02 — 2026-11-08:** Resolve the eligible actor actually contacted, independent of current sensed target or hostility. Allies/bystanders may intercept; collision eligibility is moddable and legal/hostility consequences remain owner-governed. User: “2. Yes” to first interview.
- **COMBAT-009-D03 — 2026-11-08:** Default arrow stops at first blocking actor/world contact, including failed accuracy or zero damage. Mods may explicitly add piercing/ricochet/other flight policies, retaining COMBAT-008 recovery conservation. User: “3. Yes” to first interview.

- **COMBAT-009-D04 — 2026-11-08:** Capture offensive stats/modifiers at release; read current defender defenses at impact. Explicit projectile exception/refinement to usual RULE-013 live-input evaluation: later attacker buffs/debuffs/death do not rewrite airborne shots. Evaluate target-dependent bonuses for actual contacted target using captured source data. User: “1. Yes” to second interview.
- **COMBAT-009-D05 — 2026-11-08:** Check path from authoritative firing position to visual projectile-spawn offset so offset cannot bypass walls. Obstruction receives an immediate impact from the released shot, without release cancellation/ammo refund. User: “2. Yes” to second interview.
- **COMBAT-009-D06 — 2026-11-08:** Check full traveled segment each simulation step and choose nearest valid blocker rather than endpoint overlaps alone. Prevent thin-wall/actor tunneling; collision thickness is profile data requiring native verification. User: “3. Yes” to second interview.

- **COMBAT-009-D07 — 2026-11-08:** Ordinary arrows use straight non-homing gravity-free flight, initial speed 35 reference units/second and lifetime 8 eligible gameplay seconds. Speed/lifetime/gravity/homing are moddable. ArrowMissile.prefab verifies 35/8/no gravity, unlike missile class speed default 25. User: “1. Yes” to third interview.
- **COMBAT-009-D08 — 2026-11-08:** Ordinary arrows ignore firing actor's own colliders but can hit intervening allies/civilians/combat actors under explicit collision policies. Doors follow MOVE-021 effective blocking; ordinary open/moving doors do not block through interaction targetability alone. User: “2. Yes” to third interview.
- **COMBAT-009-D09 — 2026-11-08:** Native saves preserve in-flight arrows: position/flight state, remaining lifetime, captured source data and pending impact status. Restore without release costs/practice replay. Exact save boundaries/partial-impact recovery remain SAVE dependencies. User: “3. Yes” to third interview.

- **COMBAT-009-D10 — 2026-11-08:** At effectively tied travel-segment contacts, solid world geometry precedes actors, then stable object/actor identity breaks remaining ties. Native scale fixtures must validate tie tolerance. User: “1. Yes” to fourth interview.
- **COMBAT-009-D11 — 2026-11-08:** Ordinary arrows ignore other projectiles; explicit mod policies may add interception. Crossing volleys do not incidentally destroy one another or generate recovery. User: “2. Yes” to fourth interview.
- **COMBAT-009-D12 — 2026-11-08:** Leaving for a different interior/exterior location scope discards remaining in-flight arrows without refund/recovery. Ordinary pause freezes them; same-location streaming/origin rebase preserves them. Same-location native save/load retains D09 persistence. Session end clears runtime instances after saved state is secured. Off-location flight requires separate simulation policy. User: “3. Yes” to fourth interview.

- **COMBAT-009-D13 — 2026-11-08:** Released arrows continue with captured offense/attribution after shooter death/removal. Mutations requiring extant source actor/bow use stable identity and explicit owner rules; never mutate replacement actors or newly equipped bows. User: “1. Yes” to fifth interview.
- **COMBAT-009-D14 — 2026-11-08:** Contact selects actor, not damage body part. Retain RULE-013 probabilistic part selection; no default contact-height headshot. Mods may explicitly add aimed-location policies. User: “2. Yes” to fifth interview.
- **COMBAT-009-D15 — 2026-11-08:** Released summoned arrows follow captured projectile lifetime, independent of former inventory stack expiry. Remain nonrecoverable; explicit magical projectile policies may define other expiry. User: “3. Yes” to fifth interview.

The complete [COMBAT-009 specification](systems/COMBAT/COMBAT-009.md) is approved — finalized v1 under COMBAT-009-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-008 interview decisions

- **COMBAT-008-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-008 Draft v1. The [specification](systems/COMBAT/COMBAT-008.md) is finalized v1, including ammunition selection, custom arrow preservation, contact/corpse recovery, conservation and optional multishot policies. Its confirmed multishot extensions are cross-referenced in COMBAT-004/007. Documented ITEM/payload schemas, release/volley partial-failure boundaries, corpse transfer, enemy supply, mod contracts and projectile/save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-008-D01 — 2026-11-08:** Automatic ammunition selection prioritizes summoned arrows then ordinary arrows, excluding quest-marked arrows. Eligibility/priority are moddable. Readily support modded different arrow types through COMBAT/ITEM contracts; concrete definitions are ITEM-owned. User: “1. Yes, and a note that moddable different types of arrows would definitely be a thing that would be cool to support readily, but that might be more an ‘ITEM’ specs detail.” to first interview.
- **COMBAT-008-D02 — 2026-11-08:** A nonsummoned arrow contacting a valid combat actor becomes recoverable in that actor's inventory even if accuracy fails or damage is zero. Recovery conditions are moddable; summoned arrows leave no recoverable item. User: “2. Yes” to first interview.
- **COMBAT-008-D03 — 2026-11-08:** Arrows hitting scenery or expiring without actor contact are lost by default. Mods may support world-arrow recovery/pickups through explicit placement/persistence/ownership contracts. User: “3. Yes” to first interview.

- **COMBAT-008-D04 — 2026-11-08:** Recovered arrows preserve fired type and relevant persistent properties rather than becoming generic arrows. Explicit poison/enchantment charge consumption rules apply; recovery cannot restore spent properties. User: “1. Yes” to second interview.
- **COMBAT-008-D05 — 2026-11-08:** Successful release captures arrow definition, summoned status and relevant payload/recovery data per shot. Later inventory changes cannot change in-flight ammunition. User: “2. Yes” to second interview.
- **COMBAT-008-D06 — 2026-11-08:** Automatic summoned selection prefers shortest remaining lifetime, with stable item identity tie-break. Ordinary selection uses stable item identity within configured priority tier. Modded type priorities supported; no automatic best-damage selection. Manual ammo selector remains a separate UI/ITEM decision. User: “3. Yes” to second interview.

- **COMBAT-008-D07 — 2026-11-08:** Eligible arrow from lethal contact remains recoverable through the resulting corpse inventory exactly once. Coordinate death/inventory transfer to avoid loss or duplicate actor/corpse insertion. User: “1. Yes” to third interview.
- **COMBAT-008-D08 — 2026-11-08:** If contacted actor has no valid receiving/retaining inventory destination, arrow is lost by default, without world pickup or forced invalid insertion. Fallback policy is moddable. Technical transfer failure uses explicit owner recovery, not false ordinary ineligibility. User: “2. Yes” to third interview.
- **COMBAT-008-D09 — 2026-11-08:** Same contact-based recovery applies to enemy arrows hitting player/other combat actors, including zero-damage contact, excluding summoned shots. Enemy supply/consumption remains NPC/COMBAT owner scope; at most one recovered item per actual shot. User: “3. Yes” to third interview.

- **COMBAT-008-D10 — 2026-11-08:** Automatic player ammo selection uses carried inventory only, not wagon/nearby/companion inventories. Alternate supply policies are moddable; drawing performs no automatic external transfer. User: “1. Yes” to fourth interview.
- **COMBAT-008-D11 — 2026-11-08:** Baseline release consumes one ammo unit and yields at most one recovered unit per actual arrow, despite duplicate/multiple actor contacts. Piercing mods declare which contact receives the unit. Support explicit modded multi-unit/multishot/trishot policies; not restricted to one projectile per bow attack by architecture. User: “2. Yes, but also maybe allow for the use of more with moddable policies, say like a ‘multishot’ or ‘trishot’ sort of thing or something potentially.” to fourth interview. Volley ammo/cost/practice/failure semantics require follow-up.
- **COMBAT-008-D12 — 2026-11-08:** Validate ammo/projectile preparation before committing consumption, then retain one authoritative shot outcome shared by ammo/fatigue/practice/projectile activation. Partial technical failure retains completed facts for same-shot completion/reconciliation rather than automatic refund or replacement shot duplicating ammo/practice. User: “3. Yes” to fourth interview.

- **COMBAT-008-D13 — 2026-11-08:** Modded multishot normally consumes one eligible ammo unit per released arrow, captures each payload and permits at most one recovered unit per arrow. Magical extra projectiles/different consumption require explicit mod policies. User: “1. Yes” to fifth interview.
- **COMBAT-008-D14 — 2026-11-08:** One multishot bow attack has one attack-level fatigue charge and cooldown, with release practice per successfully released ammunition-bearing arrow. All three policies are moddable. Normal three-arrow volley grants +3 Archery/+3 Critical Strike. This explicitly extends COMBAT-004/007 single-arrow baseline to optional modded volleys without changing vanilla one-arrow behavior. User: “2. Yes” to fifth interview.
- **COMBAT-008-D15 — 2026-11-08:** Multishot start/release requires full configured ammo count; reject/cancel rather than silently downsize. Mods may explicitly allow partial volleys. Partial technical failure after some releases preserves completed arrows/consequences, never replaying whole volley. User: “3. Yes” to fifth interview.

- **COMBAT-008-D16 — 2026-11-08:** At release select again from currently eligible carried ammo under approved priority; actual type may differ from draw-start availability. Capture selected payload at release commitment, not availability check. Mods may require a chosen type explicitly. User: “1. Yes” to sixth interview.
- **COMBAT-008-D17 — 2026-11-08:** Existing corpses yield no recovered inventory arrow by default, like scenery; eligibility is moddable. A living actor killed by that same arrow retains D07 corpse-safe recovery. User: “2. Yes” to sixth interview.

The complete [COMBAT-008 specification](systems/COMBAT/COMBAT-008.md) is approved — finalized v1 under COMBAT-008-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-007 interview decisions

- **COMBAT-007-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-007 Draft v1. The [specification](systems/COMBAT/COMBAT-007.md) is finalized v1, including press-to-fire default, optional hold-and-release, early release, explicit cancellation/timeout, release-time aim and captured post-animation cooldown. Documented phase/marker verification, simultaneous input ordering, Activate arbitration, profile schemas, ammunition/projectile atomicity, near-wall origin and save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-007-D01 — 2026-11-08:** Offer press-to-fire and hold-and-release bow input settings, separate from melee modes, with press-to-fire as default. User: “1. Yes, but I'd say have press-to-fire as the default, atleast that's how it works in DOS Daggerfall, and is slightly more intuitive initially.” to first interview. User's classic comparison is context; DOS parity remains unverified.
- **COMBAT-007-D02 — 2026-11-08:** Both bow modes require fresh Attack press for each shot; no automatic held-button repetition. Inputs during attack/recovery expire without queuing. User: “2. Yes” to first interview.
- **COMBAT-007-D03 — 2026-11-08:** In hold-and-release mode, deliberate Attack release before full draw records intent to finish minimum draw and fire once. Do not implement default partial-strength shots or cancel quick taps. User: “3. Yes” to first interview. Input cancellation remains distinct from deliberate release under MOVE/COMBAT-001.

- **COMBAT-007-D04 — 2026-11-08:** In hold-and-release mode, fresh Activate cancels an uncommitted draw and consumes that input, preventing same-input interaction/talk/cast. Apply captured bow cooldown without arrow release or attack fatigue/ammunition. User: “1. Yes” to second interview.
- **COMBAT-007-D05 — 2026-11-08:** Automatically cancel after 10 eligible gameplay seconds held at full draw, excluding initial draw animation and pause time. Hold limit is moddable. User: “2. Yes” to second interview.
- **COMBAT-007-D06 — 2026-11-08:** Additional full-draw hold time grants no default damage/accuracy/projectile-speed bonus or penalty. Mods may define explicit charge effects through supported contracts. User: “3. Yes” to second interview.

- **COMBAT-007-D07 — 2026-11-08:** Activate cancellation closes once the firing sequence begins: immediately for press-to-fire, or on deliberate Attack release for hold-and-release (including early release before minimum draw). Early-release intent thereafter finishes minimum draw/fires and is not a player-held draw. Forced COMBAT-001 interruptions remain effective. User: “1. Yes” to third interview.
- **COMBAT-007-D08 — 2026-11-08:** Successful shot starts captured cooldown after firing animation completion; cancellation starts cooldown immediately. Firing animation and cooldown do not overlap by default. Pause/loading advances neither. User: “2. Yes” to third interview.
- **COMBAT-007-D09 — 2026-11-08:** Allow looking during draw/hold/firing; capture projectile aim from current resolved camera facing at actual release marker, not draw-start target locking. Exclude cosmetic bob and default cursor aim. Mods may explicitly alter aiming policy. COMBAT-009 owns projectile origin/near-wall collision. User: “3. Yes” to third interview.

- **COMBAT-007-D10 — 2026-11-08:** Bow attack start requires at least one eligible arrow; rejected no-ammunition request gives brief feedback without attack/cooldown. Later ammunition loss follows release-time cancellation/cooldown rules. COMBAT-008 owns eligibility/priority. User: “1. Yes” to fourth interview.
- **COMBAT-007-D11 — 2026-11-08:** Drawing neither consumes nor reserves an arrow; ammunition remains in inventory until successful release with fresh validation. User: “2. Yes” to fourth interview.
- **COMBAT-007-D12 — 2026-11-08:** Bow input mode may change during play. Existing attacks retain original mode/timing; clear pending input and require a fresh press for next shot. Cancel an unfinished player-held draw with captured cooldown on control-setting change; already progressing firing sequence continues. User: “3. Yes” to fourth interview.

- **COMBAT-007-D13 — 2026-11-08:** Initial bow profile retains 0.0625-second animation-step baseline independent of Speed. Draw/release timing and markers are moddable; exact total phase durations need animation-profile verification. Speed affects separate captured RULE-015 cooldown. User: “1. Yes” to fifth interview.
- **COMBAT-007-D14 — 2026-11-08:** Hide bow during cooldown, automatically revealing it afterward when still drawn and other gates permit. Reveal neither changes selected hand nor starts a shot. User: “2. Yes” to fifth interview.
- **COMBAT-007-D15 — 2026-11-08:** No-ammunition state retains stored drawn intent instead of automatically sheathing. Reject new shots with agreed feedback; adding ammo restores availability but still requires fresh attack input. User: “3. Yes” to fifth interview.

The complete [COMBAT-007 specification](systems/COMBAT/COMBAT-007.md) is approved — finalized v1 under COMBAT-007-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-006 interview decisions

- **COMBAT-006-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-006 Draft v1. The [specification](systems/COMBAT/COMBAT-006.md) is finalized v1, including deliberate bash/action composition, baseline bash formulas, persistent unlocks, separate exterior entry and authoritative noise/legal reporting. Documented lock/formula schemas, authored-link ordering, noise/detection/legal contracts, motion fixtures, partial-operation recovery and save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-006-D01 — 2026-11-08:** A deliberate door strike executes one explicit door-bash operation. Attached authored actions execute only through declared links/composition, not independently through every matching component. Preserve intentional links without duplicate door/action effects. User: “1. Yes” to first interview.
- **COMBAT-006-D02 — 2026-11-08:** A deliberate strike on a stationary open door requests closing; strikes during motion are ignored without queued toggles. The committed swing retains its fatigue cost. MOVE-021 collision/occupancy rules remain binding. User: “2. Yes” to first interview.
- **COMBAT-006-D03 — 2026-11-08:** Deliberate solid-scenery strikes provide appropriate impact feedback without default structural damage, weapon wear or skill practice. Material responses/effects are moddable. Default contact does not cancel the swing; optional COMBAT-005 modded wall-stop behavior remains available. User: “3. Yes” to first interview.

- **COMBAT-006-D04 — 2026-11-08:** Locked ordinary doors use moddable initial bash formulas: interior action door raw chance 20−lock value; exterior building entrance 25−lock value, with RULE-001 0–100 limits/percentile semantics. No baseline Strength/weapon-damage bonus. User: “1. Yes” to second interview.
- **COMBAT-006-D05 — 2026-11-08:** Deliberately bashing a stationary unlocked door requests opening without a success roll. Magically held closed doors resist ordinary bash, with eligibility moddable. Committed attack still drains fatigue and may produce bash feedback when magical holding prevents opening. User: “2. Yes” to second interview.
- **COMBAT-006-D06 — 2026-11-08:** Successful exterior bash unlocks the entrance but leaves the player outside; separate activation required for entry. Retain distinct bash/legal/entry consequences under MOVE-020. User: “3. Yes” to second interview.

- **COMBAT-006-D07 — 2026-11-08:** Each genuine new committed bash on an eligible locked door receives a fresh check without lockpicking's skill-improvement retry gate. Duplicate delivery retains the same outcome. Failure causes no cumulative lock weakening by default. User: “1. Yes” to third interview.
- **COMBAT-006-D08 — 2026-11-08:** Genuine door bashes report authoritative noise and applicable attempted/successful forced-opening incidents to NPC/LAW independently of audible sound settings/assets. LAW owns detection/crime/response; combat does not directly spawn guards or universally make enemies hostile. User: “2. Yes” to third interview.
- **COMBAT-006-D09 — 2026-11-08:** Door bashing adds no default weapon wear, structural damage or skill practice beyond COMBAT-004's once-per-swing fatigue. Mods may add durability, wear, bash practice or other explicit costs. User: “3. Yes” to third interview.

- **COMBAT-006-D10 — 2026-11-08:** Successful bash persistently clears ordinary lock until explicit relock/action/effect; interior doors request opening while exterior entrances leave player outside. Failed opening/entry/presentation cannot reroll completed bash. User: “1. Yes” to fourth interview.
- **COMBAT-006-D11 — 2026-11-08:** Deliberately targeted mechanisms accept only authored permitted Attack triggers, respecting one-shot/repeatable/busy contracts. One committed strike supplies one propagated trigger identity; unsupported/busy activation does not queue. User: “2. Yes” to fourth interview.
- **COMBAT-006-D12 — 2026-11-08:** Dungeon exits/other transition-only entrances without explicit bashable-door definition ignore bash effects and cannot automatically transition from a strike. Bashability is moddable; committed swing retains fatigue and applicable surface feedback, while entry/exit requires ordinary activation. User: “3. Yes” to fourth interview.

- **COMBAT-006-D13 — 2026-11-08:** Unarmed attacks, including selected shield-hand unarmed attacks, use the same ordinary bash chance as weapons. Source eligibility/formulas are moddable; an explicit modded shield bash may define its own policy. User: “1. Yes” to fifth interview.
- **COMBAT-006-D14 — 2026-11-08:** Read current lock/magical-hold state at commitment and resolve one success check only when needed. Unlocked, moving, magically held or non-bashable doors consume no success roll. Committed swing fatigue is independent of door admission. User: “2. Yes” to fifth interview.
- **COMBAT-006-D15 — 2026-11-08:** Ordinary bash success/failure uses door motion/appropriate impact feedback without a new per-bash popup or numeric-chance display. Required errors/recovery remain clear; ordinary feedback is moddable. Audio preferences cannot alter authoritative noise/legal incidents. User: “3. Yes” to fifth interview.

The complete [COMBAT-006 specification](systems/COMBAT/COMBAT-006.md) is approved — finalized v1 under COMBAT-006-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-005 interview decisions

- **COMBAT-005-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-005 Draft v1. The [specification](systems/COMBAT/COMBAT-005.md) is finalized v1, including forward-volume cleave, per-target obstruction, uncapped nearest-first targeting, enemy-first dispatch, deliberate civilian/environment contact and optional modded directional sweeps/wall stops. Documented geometry/contact fixtures, collider ownership, observation order, complete query processing, central dispatch, mod schemas, partial-operation recovery and save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-005-D01 — 2026-11-08:** Resolve melee targeting from current player position and resolved camera facing at attack commitment, not attack-start target locking. Cosmetic camera bob cannot redirect gameplay aim. User: “1. Yes” to first interview.
- **COMBAT-005-D02 — 2026-11-08:** Baseline cleave uses a modest forward volume rather than exact sprite-motion tracing, with moddable reach/width. Support mods defining different cleave profiles by weapon and attack direction, potentially enabling directional sweep behavior through explicit profiles. User: “2. Yes, but it would be nice to also potentially give mods that ability to allow each different direction have a different cleave profile depending on the weapon and such.” to first interview. Exact geometry/default dimensions and supported sweep timing remain unresolved.
- **COMBAT-005-D03 — 2026-11-08:** Each candidate requires an unobstructed path from attack origin to a valid contact point. Walls/closed doors block; enemies do not themselves block cleaving other nearby enemies. Test narrow openings so forgiving acquisition width cannot authorize strikes through solid barriers. User: “3. Yes” to first interview.

- **COMBAT-005-D04 — 2026-11-08:** Baseline forward reach 2.25 reference units and acquisition radius 0.25, as initial moddable balance values subject to Godot-scale testing. Collect multiple enemies; valid contact points remain within defined reach, without hidden extension from volume thickness. User: “1. Yes” to second interview.
- **COMBAT-005-D05 — 2026-11-08:** Resolve eligible enemies nearest valid contact first, breaking exact-distance ties by stable actor identity. Do not use physics-query enumeration order. User: “2. Yes” to second interview.
- **COMBAT-005-D06 — 2026-11-08:** Baseline cleave affects every distinct eligible enemy within unobstructed volume/reach without a separate gameplay cap. Mods may set a cap. Technical query overflow requires explicit handling, never silent omission. User: “3. Yes” to second interview.

- **COMBAT-005-D07 — 2026-11-08:** Include very close enemies overlapping forward attack volume at commitment when in front of origin with a valid unobstructed contact point. No cast-origin blind spot or behind-player strikes. User: “1. Yes” to third interview.
- **COMBAT-005-D08 — 2026-11-08:** Acquisition-volume contact with nearby solid geometry does not reject an otherwise clear thin path through bars/gaps to a valid target contact. Separate candidate acquisition from obstruction; never fall through solid walls. User: “2. Yes” to third interview.
- **COMBAT-005-D09 — 2026-11-08:** Melee obstruction follows effective door blocking state under MOVE-021: ordinary open/moving nonblocking doors do not block enemy strikes merely through interaction targetability; closed solid doors block. Door attack-blocking policy is moddable. User confirmed question 3 and added D10 in third interview.
- **COMBAT-005-D10 — 2026-11-08:** When a valid enemy lies within the attack's cleave range/view, exclude the door from that same attack's environmental cleave/bash/trigger handling. Purposeful door attacks without a valid enemy in range/view may attempt bash; attacking an enemy in a doorway must not repeatedly open/close/bash its door. User clarification to question 3, third interview. Exact valid-enemy gating and intentional door acquisition remain to be clarified; COMBAT-006 owns bash/action execution.

- **COMBAT-005-D11 — 2026-11-08:** Door suppression requires a reachable enemy passing volume/reach/obstruction checks. Later accuracy miss or zero damage does not restore door handling. Enemy behind a blocking closed door does not suppress bashing that door. User: “1. Yes” to fourth interview.
- **COMBAT-005-D12 — 2026-11-08:** With no eligible enemy contact, purposeful door attack requires the door as nearest relevant object on central attack aim ray within reach; edge-of-cleave proximity alone cannot trigger bash. COMBAT-006 owns bash/action outcome. User: “2. Yes” to fourth interview.
- **COMBAT-005-D13 — 2026-11-08:** Apply enemy-first priority and deliberate central aim to attack-triggered switches/mechanisms as well. No incidental environmental activation during reachable-enemy cleave. User: “3. Yes” to fourth interview.

- **COMBAT-005-D14 — 2026-11-08:** Reachable portions of valid combat colliders may qualify even when actor center is blocked; use defined deterministic contact checks, not random sampling, within reach and forward volume. User: “1. Yes” to fifth interview.
- **COMBAT-005-D15 — 2026-11-08:** Support optional modded weapon/range/cleave-arc obstruction policies that stop an attack early on wall contact, such as a greatsword in a cramped hallway. This is explicitly not default behavior. User addition to question 1, fifth interview. Sweep timing/order, commitment and cost semantics need explicit follow-up; do not undo already committed hits.
- **COMBAT-005-D16 — 2026-11-08:** Acquire candidate list and ordering once at commitment, revalidate each target before resolving against captured commitment origin/facing. Skip removed/dead/out-of-reach/newly obstructed targets; do not add newly arriving enemies to the same swing. User: “2. Yes” to fifth interview.
- **COMBAT-005-D17 — 2026-11-08:** Once enemy targeting was selected at commitment, no environmental fallback even if all enemy outcomes are later skipped/interrupted. User: “3. Yes” to fifth interview.

- **COMBAT-005-D18 — 2026-11-08:** Optional modded wall stop before commitment cancels without attack fatigue; after commitment retains once-per-attack fatigue and completed hits/practice while stopping remaining strikes. Mod declares sweep timing/collision order; preserve COMBAT-001/004 commitment semantics. User: “1. Yes” to sixth interview.
- **COMBAT-005-D19 — 2026-11-08:** Ordinary civilians are excluded from default enemy cleave but remain deliberately attackable through central aim when no reachable combat enemy takes priority. Damage/legal consequences remain their owners' rules; eligibility is moddable. User: “2. Yes” to sixth interview.
- **COMBAT-005-D20 — 2026-11-08:** Default melee uses resolved camera-forward aim even in gameplay cursor mode; cursor continues ordinary interaction targeting. HUD-consumed input cannot also start an attack. Mods may explicitly support cursor-directed combat. User: “3. Yes” to sixth interview.

The complete [COMBAT-005 specification](systems/COMBAT/COMBAT-005.md) is approved — finalized v1 under COMBAT-005-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-004 interview decisions

- **COMBAT-004-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-004 Draft v1. The [specification](systems/COMBAT/COMBAT-004.md) is finalized v1, including default moddable cleaving, once-per-swing fatigue, per-enemy contact practice, release-based bow practice and exhaustion consequence ordering. Documented cleave geometry/order, per-target effects/wear, release atomicity/recovery, marker schemas, exhaustion handoff, save boundaries and native verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-004-D01 — 2026-11-08:** Each attack has one explicit gameplay commitment marker synchronized with visible strike/arrow release, executed once even if rendering skips the frame. Mods may configure markers for different attack animations. User: “1. Yes” to first interview.
- **COMBAT-004-D02 — 2026-11-08:** Each committed melee swing or released bow shot drains 11 internal fatigue units by default, hit or miss; amount is moddable. This is 11/64 displayed fatigue unit, separate from ordinary activity drain. User: “2. Yes” to first interview.
- **COMBAT-004-D03 — 2026-11-08:** A committed melee attack reaching a valid enemy grants +1 relevant weapon skill, or Hand-to-Hand for unarmed, and +1 Critical Strike even on failed hit roll or zero resolved damage. Empty-air/environment strikes grant neither. Supported practice amounts and eligibility are moddable. User: “3. Yes” to first interview. Enemy contact is distinct from successful accuracy/damage resolution.

- **COMBAT-004-D04 — 2026-11-08:** Each successfully released arrow grants +1 Archery and +1 Critical Strike regardless of later contact; no second practice award at impact. Eligibility/amounts are moddable. Empty-space shooting is allowed practice at ammunition/fatigue cost. User: “1. Yes” to second interview.
- **COMBAT-004-D05 — 2026-11-08:** Attack fatigue is saturating drain, explicitly permitting commitment with less than the full 11-unit baseline available; drain reaches zero and invokes approved exhaustion policy. Already-zero fatigue remains subject to exhaustion restrictions. User: “2. Yes” to second interview. This is an explicit attack-owner exception to ordinary sufficient-resource spending under CHAR-018.
- **COMBAT-004-D06 — 2026-11-08:** Settle the committed strike/release and eligible practice before processing exhaustion consequences caused by that attack's fatigue drain. The exhausting attack still takes effect; resulting collapse/death can prevent later attacks. Practice is not lost solely because that same drain immediately causes death. User: “3. Yes” to second interview. CHAR-012 living-character eligibility is evaluated at the qualifying commitment, not bypassed for unrelated already-dead characters.

- **COMBAT-004-D07 — 2026-11-08:** Living combat actors qualify for melee contact practice even if peaceful/pacified or invulnerable; corpses, ordinary civilian NPCs, doors and scenery do not. Ordinary hostility/legal consequences still apply. Target eligibility is moddable. User: “1. Yes, but make this moddable if possible.” to third interview.
- **COMBAT-004-D08 — 2026-11-08:** Capture weapon/unarmed practice skill identity at attack start; later equipment/presentation changes cannot redirect its award. COMBAT-001 source-change cancellation remains binding. User: “2. Yes” to third interview.
- **COMBAT-004-D09 — 2026-11-08:** Genuine repeated qualifying attacks continue awarding practice without a new per-target cooldown or diminishing returns. Duplicate callbacks for the same attack grant nothing extra. Mods may explicitly change eligibility/cadence. User: “3. Yes” to third interview.

- **COMBAT-004-D10 — 2026-11-08:** Capture configured fatigue cost and practice policy at attack start alongside timing/skill identity. Evaluate actual target contact/eligibility at resolution; later settings/effect changes cannot rewrite captured configured costs/awards. User: “1. Yes” to fourth interview.
- **COMBAT-004-D11 — 2026-11-08:** Charge fatigue once and award each applicable skill once per attack even with multiple targets. Make cleaving nearby enemies with one melee swing the default intended behavior, not only a mod possibility; make cleave and award policies moddable, including explicit per-target practice policies. Multiple colliders/duplicate callbacks cannot multiply targets/attacks. User confirmed question 2 and explicitly requested default cleaving in fourth interview. COMBAT-005 owns concrete target acquisition/reach/obstruction rules, still unresolved. User reports DOS Daggerfall cleaving; classic parity is unverified and not the basis for invented fatigue rules.
- **COMBAT-004-D12 — 2026-11-08:** Missing/invalid ammunition at release cancels the shot without projectile, ammo consumption, fatigue or practice, retaining captured bow cooldown. Technical projectile creation failure uses explicit recovery, not false release success or duplicating retries/costs. User: “3. Yes” to fourth interview.

- **COMBAT-004-D13 — 2026-11-08:** Each eligible enemy reached by a cleaving attack grants its applicable practice/experience tally, with award policy moddable. This explicitly supersedes D11's once-per-attack practice limit; D11's once-per-swing fatigue charge remains. User: “1. I'd say make each enemy hit give the applicable ‘experience tally’ or practice award as you refer to it. But once again, make this moddable.” to fifth interview. Precise contact-versus-success meaning is to be confirmed against D03.
- **COMBAT-004-D14 — 2026-11-08:** Resolve hit/damage independently for each cleaved enemy; one miss/immunity/material failure does not automatically cancel other targets. Per-target effects/wear/order remain their owners' contracts. User: “2. Yes” to fifth interview.
- **COMBAT-004-D15 — 2026-11-08:** If active weapon breaks during cleave resolution, preserve that target's committed outcome but prevent remaining strikes from that attack under COMBAT-001. Target ordering matters and remains COMBAT-005 scope. User: “3. Yes” to fifth interview.

- **COMBAT-004-D16 — 2026-11-08:** Confirm D13's “enemy hit” means qualifying contact, retaining D03: each distinct eligible enemy reached grants +1 captured weapon/Hand-to-Hand and +1 Critical Strike even on failed accuracy or zero damage. User: “1. Yes” to sixth interview.
- **COMBAT-004-D17 — 2026-11-08:** Award each enemy at most once per attack despite multiple colliders/repeated contact, and only if its resolution is actually reached before interruption. Targets skipped after weapon break grant nothing. Genuine repeated swings remain separate practice opportunities. User: “2. Yes” to sixth interview.

The complete [COMBAT-004 specification](systems/COMBAT/COMBAT-004.md) is approved — finalized v1 under COMBAT-004-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-003 interview decisions

- **COMBAT-003-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-003 Draft v1. The [specification](systems/COMBAT/COMBAT-003.md) is finalized v1, including three melee input modes, net-displacement gestures, controller neutral qualification, equal automatic direction selection and explicit look/cancellation ownership. Documented sensitivity/normalization, angular/threshold tuning, device arbitration, unsupported-direction handling, mod schemas, admission/RNG ordering and native verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-003-D01 — 2026-11-08:** Offer gesture, press-once and hold-to-repeat melee modes in settings; gesture is the default. User: “1. Yes” to first interview.
- **COMBAT-003-D02 — 2026-11-08:** Each eligible fresh press in press-once mode starts at most one attack. Presses during active attack or recovery are discarded, not queued. User: “2. Yes” to first interview.
- **COMBAT-003-D03 — 2026-11-08:** Hold-to-repeat intentionally starts further melee attacks when each attack/recovery finishes while the eligible hold continues. Stop repetition on input cancellation, weapon/hand changes or blocking restrictions; require a fresh press afterward. User: “3. Yes” to first interview. Ordinary active attack/recovery is the repetition wait condition, not itself a disarming restriction. COMBAT-001 governs the disposition of already progressing attacks.

- **COMBAT-003-D04 — 2026-11-08:** Retain six baseline gesture directions: up, down, left, right, down-left and down-right; upward diagonals map to up. Mods may define additional directions with matching animations. User: “1. Yes” to second interview.
- **COMBAT-003-D05 — 2026-11-08:** Press-once/hold-to-repeat choose randomly with equal probability among distinct supported directions of the active weapon/form for each new attack. Do not retain DFU's extra upward weighting from eight-input remapping. User: “2. Yes” to second interview.
- **COMBAT-003-D06 — 2026-11-08:** While Attack is held, gesture mode allows repeated deliberate swings, each requiring a new gesture after the prior attack/recovery finishes. Discard motion during attack/recovery and consumed/leftover gesture motion; do not buffer it into another strike. User: “3. Yes” to second interview.

- **COMBAT-003-D07 — 2026-11-08:** Mouse gesture qualification and direction use net displacement rather than accumulated path length. Opposing motion cancels instead of accumulating qualifying travel. User: “1. Yes” to third interview.
- **COMBAT-003-D08 — 2026-11-08:** Expose mouse gesture sensitivity and recognition window separately from camera sensitivity, with a one-eligible-gameplay-second baseline recognition window and mod support. Exact sensitivity default requires Godot testing; DFU's 5%-of-longest-screen-dimension threshold remains reference only. User: “2. Yes” to third interview.
- **COMBAT-003-D09 — 2026-11-08:** In controller gesture mode, holding Attack reserves the look stick for swing direction, requiring return to neutral before each new swing. Outside gesture capture the stick resumes looking; captured motion cannot replay as camera movement. User: “3. Yes” to third interview.

- **COMBAT-003-D10 — 2026-11-08:** Gesture-mode Attack holds reserve mouse/look-stick motion throughout capture, including swing/recovery; discard attack-ineligible motion without camera rotation. Release restores looking without replay. Other attack modes permit looking. User: “1. Yes” to fourth interview.
- **COMBAT-003-D11 — 2026-11-08:** Unsupported requested gesture direction produces no attack rather than silent substitution. Mods may declare explicit direction mappings. User: “2. Yes” to fourth interview.
- **COMBAT-003-D12 — 2026-11-08:** Permit live session changes to attack mode/gesture settings; clear pending gestures/repetition, require fresh Attack input and preserve already-started attack timing/results. Bow-hand setting retains its separate no-session restriction. User: “3. Yes” to fourth interview.

- **COMBAT-003-D13 — 2026-11-08:** Controller gesture capture requires neutral before deflection can attack, including entry with the look stick already tilted. Activation and neutral thresholds are separately tunable. User: “1. Yes” to fifth interview.
- **COMBAT-003-D14 — 2026-11-08:** Automatic modes choose direction only for an accepted new attack, retaining the choice without callback rerolls. Rejected input and presentation refresh consume no direction roll; empty supported-direction list blocks as invalid configuration. User: “2. Yes” to fifth interview.
- **COMBAT-003-D15 — 2026-11-08:** Releasing Attack in melee gesture mode ends capture/clears unfinished motion without firing a swing. Melee mode selection does not alter bow draw/release, owned by COMBAT-007/008 under COMBAT-001. User: “3. Yes” to fifth interview.

The complete [COMBAT-003 specification](systems/COMBAT/COMBAT-003.md) is approved — finalized v1 under COMBAT-003-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-002 interview decisions

- **COMBAT-002-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-002 Draft v1. The [specification](systems/COMBAT/COMBAT-002.md) is finalized v1, including selectable shield-hand unarmed attacks, extensibility for modded dual wielding/shield bashing, no-session bow settings and item-preserving load reconciliation. Documented ITEM mutation/delay provenance, mod APIs/layout compatibility, ordering, presentation recovery and native save verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-002-D01 — 2026-11-08:** Baseline uses one selected attack hand, without automatic alternation or simultaneous dual attacks. Keep hand/attack-source contracts extensible so mods can implement dual wielding later without replacing an inherently single-hand-only combat model. No vanilla dual-wield behavior or exact mod API is selected. User: “1. Yes, but definitely make it possible or atleast easier to implement a dual-wield system later on with mods” to first interview.
- **COMBAT-002-D02 — 2026-11-08:** An empty selected hand enables unarmed attacks even when the other hand holds a weapon; do not automatically select the armed hand. User: “2. Yes” to first interview.
- **COMBAT-002-D03 — 2026-11-08:** A shield hand remains selectable and uses unarmed attacks by default, like an empty hand, rather than forcing the other hand. Make this behavior moddable and support modded shield-bashing attacks. User: “3. In this case, treat the shield hand as if it was unarmed, similar to switching to a hand without a weapon, that's how it works in Daggerfall atleast. But make this moddable and for shield-bashing type stuff to be possible with mods.” to first interview. This is the intended target rule; inspected DFU WeaponManager.UpdateHands/ToggleHand instead forces the right hand for a left shield. Classic Daggerfall parity is unverified.

- **COMBAT-002-D04 — 2026-11-08:** Shield equip initially selects the opposite weapon/unarmed hand, but does not continuously force that selection; a subsequent manual switch to the shield hand remains allowed under D03. User clarification: “if DFU switches to the weapon hand initially then sure, but you should still be able to switch manually to the shield hand if you want.” This refines D03 without removing shield-hand selection.
- **COMBAT-002-D05 — 2026-11-08:** Ignore hand switching during an active attack without queuing; require a fresh request afterward. User: “1. Yes” to second interview. COMBAT-001 cooldown/paralysis/climbing gates remain binding.
- **COMBAT-002-D06 — 2026-11-08:** Two-handed equipment excludes another equipped weapon/shield alongside it, while allowing selection of the other hand for unarmed attacks. Equipment restrictions are moddable. User: “2. Yes” to second interview.
- **COMBAT-002-D07 — 2026-11-08:** Selecting the shield hand for unarmed attacks retains the equipped shield's normal defensive benefits. Selection does not unequip/disable it. Mods may explicitly alter defense during shield-bash phases. User: “3. Yes” to second interview.

- **COMBAT-002-D08 — 2026-11-08:** Ordinary hand switching is immediate by default, respecting any destination-hand equipment delay already remaining. Mods may add switching delay. Switching an already-equipped choice is distinct from equipping a new item. User: “1. Yes” to third interview.
- **COMBAT-002-D09 — 2026-11-08:** Each hand's equipment delay progresses independently during eligible gameplay, even while unselected. Switching cannot reset/bypass it; pause/loading contributes no progress. User: “2. Yes” to third interview.
- **COMBAT-002-D10 — 2026-11-08:** Bows are two-handed by default. Provide an eventual settings-menu option for left-hand bows permitting another weapon, and make bow hand/equipment policy moddable as well. This is an explicit optional exception to D06's default two-handed exclusion. User: “3. Yes, but allow the left-hand bows option to be done in the eventual settings menu, but make it moddable as well if desired.” to third interview. Safe application of setting changes and any option-specific switching delay remain unresolved.

- **COMBAT-002-D11 — 2026-11-08:** Left-hand bow option retains immediate default hand switching; mods may add a switching delay. Do not automatically import DFU's option-specific switching penalty. User: “1. Yes” to fourth interview.
- **COMBAT-002-D12 — 2026-11-08:** Bow-hand setting may change only outside an active character/play session; exiting to a no-session menu is sufficient and a full application restart is not mandatory. It is not live-editable during an active game, including a paused one. User: “2. Yes, it should be one of the settings you need to exit the game or the play session to change, not one you can change while an active game is playing.” to fourth interview. Handling saves with equipment incompatible with the newly selected policy remains unresolved.
- **COMBAT-002-D13 — 2026-11-08:** Retain additive equipment-change delay: outgoing item's unequip duration plus incoming item's equip duration are added to the affected hand's remaining delay. Retain source baseline item-type durations and make them moddable. Ordinary switching between already-equipped hands adds no default cost. User: “3. Yes” to fourth interview. Exact transaction/admission boundaries remain ITEM integration dependencies.

- **COMBAT-002-D14 — 2026-11-08:** When saved equipment conflicts with the current bow-hand setting, automatically unequip items so restored equipment obeys the current setting rather than blocking load or overriding that setting. User: “1. In this case I'd say automatically unequip items so the current state reflects the current setting rules in place.” to fifth interview. Retained-item priority, destination, disclosure and delay effects need explicit follow-up; do not infer deletion or arbitrary substitution.
- **COMBAT-002-D15 — 2026-11-08:** Save selected hand and each hand's remaining equipment delay; restore without repeating equipment costs or shield-equip initial auto-selection. Rebuild presentation from restored equipment, retaining COMBAT-001 load-time attack cancellation. User: “2. Yes” to fifth interview. D14 reconciliation may need an explicit exception for moved/unequipped items.
- **COMBAT-002-D16 — 2026-11-08:** Baseline presents one active weapon/unarmed source matching selected attack source. Support explicit racial/form and modded presentations, including future dual-wield/shield-bash visuals. Visual-only changes cannot change attacking item, damage rules or shield defense; gameplay changes require explicit policies. User: “3. Yes” to fifth interview.

- **COMBAT-002-D17 — 2026-11-08:** On load conversion to two-handed bows, move equipped left bow to right slot and unequip conflicting weapon to player inventory. Reverse conversion moves bow left without auto-equipping another weapon. User: “1. Yes” to sixth interview.
- **COMBAT-002-D18 — 2026-11-08:** Compatibility adjustment preserves item identity/condition/enchantments/quest state, never drops/deletes items, and shows a brief adjustment notice after successful load. Unsafe inventory transfer uses explicit load recovery. User: “2. Yes” to sixth interview.
- **COMBAT-002-D19 — 2026-11-08:** Load reconciliation adds no new equipment delay, preserves existing remaining delays associated with items and moves bow delay with bow. Select bow's new hand when its slot changes. This explicitly qualifies ordinary saved-hand preservation under D15; no recovery bypass. User: “3. Yes” to sixth interview.

The complete [COMBAT-002 specification](systems/COMBAT/COMBAT-002.md) is approved — finalized v1 under COMBAT-002-A01. Documented owner dependencies remain open. No implementation is authorized.

## COMBAT-001 interview decisions

- **COMBAT-001-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize COMBAT-001 Draft v1. The [specification](systems/COMBAT/COMBAT-001.md) is finalized v1. Documented attack/casting boundaries, event ordering, equipment/hand admission, ammunition, spell/projectile persistence, save schema and native verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **COMBAT-001-D01 — 2026-11-08:** Ignore Ready Weapon during an active attack; do not queue drawing/sheathing. A fresh press is required afterward. User: “1. Yes” to first interview.
- **COMBAT-001-D02 — 2026-11-08:** Ready Weapon cancels an uncast readied spell and always draws the weapon, including when it was logically drawn beneath the spell. Interruption of casting already in progress remains unresolved. User: “2. Yes” to first interview.
- **COMBAT-001-D03 — 2026-11-08:** Paralysis or entering climbing cancels an active attack immediately. Preserve already committed hits and released projectiles; the canceled attack cannot deliver a later hit or resume afterward. Fatigue, ammunition and cooldown consequences remain unresolved. User: “3. Yes” to first interview.

- **COMBAT-001-D04 — 2026-11-08:** Cancellation before melee contact/attack commitment or arrow release consumes no attack fatigue or ammunition. Cancellation afterward retains committed costs. Cancellation itself grants no practice; COMBAT-004 owns practice eligibility. User: “1. Yes” to second interview. The exact melee commitment boundary remains COMBAT-004 scope; this decision does not require hitting a target to charge an otherwise committed swing.
- **COMBAT-001-D05 — 2026-11-08:** Every started bow attack incurs its captured cooldown when it finishes or is canceled, including cancellation before release. Cooldown advances only during eligible gameplay time under RULE-015/CORE contracts. User: “2. Yes” to second interview.
- **COMBAT-001-D06 — 2026-11-08:** Ignore Ready Weapon once actual casting begins; require a fresh press after casting finishes. Uncast readied spells remain cancelable under D02. Forced spell interruption belongs to MAGIC. User: “3. Yes” to second interview.

- **COMBAT-001-D07 — 2026-11-08:** When paralysis/climbing ends, restore weapon visibility/availability if previously drawn and other gates permit. Canceled attacks stay canceled; attacking requires fresh input. User: “1. Yes” to third interview.
- **COMBAT-001-D08 — 2026-11-08:** Block Ready Weapon and hand switching during bow cooldown without queuing requests. User: “2. Yes” to third interview.
- **COMBAT-001-D09 — 2026-11-08:** Ignore Ready Weapon and hand-switch requests while paralyzed or climbing; preserve stored readiness and selected hand. Require fresh requests after restrictions end. User: “3. Yes” to third interview.

- **COMBAT-001-D10 — 2026-11-08:** Removing, breaking or replacing the active weapon during an attack cancels that attack under the confirmed cost/cooldown rules, without attacking with its replacement. ITEM/COMBAT-002 own equipment-change admission. User: “1. Yes” to fourth interview.
- **COMBAT-001-D11 — 2026-11-08:** Ordinary gameplay suspension freezes attacks and cooldowns, resuming their progression with gameplay; opening a menu does not itself finish recovery or cancel an attack. User: “2. Yes” to fourth interview. MOVE-001 cancellation of unfinished physical input remains binding; handling a release-dependent held bow across context handoff needs explicit reconciliation.
- **COMBAT-001-D12 — 2026-11-08:** Loading a mid-attack save cancels the unfinished attack, retains committed costs/results and preserves remaining cooldown. A canceled bow attack begins its captured cooldown if not already in recovery. Require fresh attack input after load. Released-projectile persistence remains a separate COMBAT/SAVE decision. User: “3. Yes” to fourth interview.

- **COMBAT-001-D13 — 2026-11-08:** Cancel a bow awaiting deliberate player release when its input context is lost; apply captured cooldown without firing. This explicitly qualifies D11: already progressing swings/bow-release animations freeze and resume, while an unfinished physical hold cannot survive context cancellation as a release command. User: “1. Yes” to fifth interview.
- **COMBAT-001-D14 — 2026-11-08:** After casting finishes, previously drawn weapons automatically reappear when other gates permit, requiring fresh attack input. Preparing a spell hides weapons without changing stored readiness. User: “2. Yes” to fifth interview.
- **COMBAT-001-D15 — 2026-11-08:** Allow drawing/sheathing during equipment delay, preserving intent while attacks/weapon visibility remain blocked until the selected hand's delay completes. Other restrictions still take precedence. COMBAT-002/ITEM own durations and hand-switch details. User: “3. Yes” to fifth interview.

The complete [COMBAT-001 specification](systems/COMBAT/COMBAT-001.md) is approved — finalized v1 under COMBAT-001-A01. Documented owner dependencies remain open. No implementation is authorized.

## MOVE-027 interview decisions

- **MOVE-027-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-027 Draft v1. The [specification](systems/MOVE/MOVE-027.md) is finalized v1. Documented correction/search limits, mode/coordinate validation, moving geometry, disclosure, mod schemas, cleanup/save boundaries and native verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-027-D01 — 2026-11-08:** Distinguish fresh spawn, doorway/teleport arrival and native restore intents with location/pose/movement context/permitted corrections. Falling restore cannot silently become grounded spawn. User: “1. Yes” to first interview.
- **MOVE-027-D02 — 2026-11-08:** Bounded collision-checked immediate-area corrections may resolve small overlaps/nearby grounded footing; no wall/locked-barrier/room crossing. Exact limits require scale fixtures and validated mod contracts. User: “2. Yes” to first interview.
- **MOVE-027-D03 — 2026-11-08:** Explicit success/corrected success/failure with provenance; no ground hit distinct from valid hit. No valid permitted candidate retains suspension/CORE recovery, not unrelated/random fallback teleport. User: “3. Yes” to first interview.

- **MOVE-027-D04 — 2026-11-08:** Exact requested pose first, permitted local candidates in declared deterministic order. Full active shape/context validation, not downward ray alone. Random marker only when original request explicitly specifies random spawning. User: “1. Yes” to second interview.
- **MOVE-027-D05 — 2026-11-08:** Corrections preserve required velocity/fall/posture/water/effects and valid platform/climb context under owner contracts. Cannot erase consequences/invent support; fresh initialization only per declared intent. User: “2. Yes” to second interview.
- **MOVE-027-D06 — 2026-11-08:** Separate authoritative world/location from engine-local coordinates with versioned conversion. Origin rebase coherently updates histories/attachments without physical/fall change. Invalid conversion uses recovery, not guesses. User: “3. Yes” to second interview.

- **MOVE-027-D07 — 2026-11-08:** Validate current occupants/moving collision; blocked markers cannot disable solidity/shove actors automatically. Wait/retry must be bounded/owned, else explicit failure/recovery. User: “1. Yes” to third interview.
- **MOVE-027-D08 — 2026-11-08:** Log corrections with reason/bounded displacement; tiny valid corrections need no popup, meaningful recovery discloses change in recovery UI. Do not claim uncorrected restoration after substantive relocation. User: “2. Yes” to third interview.
- **MOVE-027-D09 — 2026-11-08:** Success requires coherent pose/shape/required movement-owner state. Surrounding load/entry readiness still gates input/simulation; unresolved placement blocks saves. Retry uses fresh identity after safe cleanup, not stale callbacks; other suspensions remain. User: “3. Yes” to third interview.

The complete [MOVE-027 specification](systems/MOVE/MOVE-027.md) is approved — finalized v1 under MOVE-027-A01. Documented owner dependencies remain open. No implementation is authorized.

## MOVE-026 interview decisions

- **MOVE-026-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-026 Draft v1. The [specification](systems/MOVE/MOVE-026.md) is finalized v1, including moddable multi-door mappings. Documented content/readiness, pose/history, concurrent operation, reaction/recovery, presentation and native verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-026-D01 — 2026-11-08:** Identified transition has preparing/committed success/failure outcomes. Validate original door/destination/content/placement before success. Pre-events cannot mark entry/grant rewards. User: “1. Yes” to first interview.
- **MOVE-026-D02 — 2026-11-08:** Owned transition suspension with brief fade/loading until geometry/required systems ready. Consume doorway input; release cannot override other reasons/modals. Fade timing remains tuning. User: “2. Yes” to first interview.
- **MOVE-026-D03 — 2026-11-08:** Precommit failure retains original valid context. Destructive reconstruction failure retains suspension/explicit recovery, no silent unrelated teleport/partial resume; no universal rollback promise. MOVE-027/CORE own corrections/recovery. User: “3. Yes” to first interview.

- **MOVE-026-D04 — 2026-11-08:** Stable entrance/exit mappings preserve relevant return doorway, not first/random unrelated door. Missing mapping uses recovery. User explicitly requires moddability including added multiple entrances/exits and custom mappings; no fixed one-door schema. User response to second interview item 1.
- **MOVE-026-D05 — 2026-11-08:** Door traversal uses validated destination pose/facing, clears transient impulses/resets camera interpolation; placement displacement is not physical fall. Persistent effects retain owner rules and transport/posture validate before commit. User: “2. Yes” to second interview.
- **MOVE-026-D06 — 2026-11-08:** One active doorway transition per player; repeated clicks cannot queue/duplicate events. Competing teleport/load has explicit reject/defer/supersede contract; stale completion cannot overwrite newer work. CORE/MAGIC/SAVE own priority. User: “3. Yes” to second interview.

- **MOVE-026-D07 — 2026-11-08:** Ordinary doorway traversal advances no simulated travel time; fade/load cannot consume effect/fatigue/calendar time. Authored time-advancing transition needs separate TIME contract. User: “1. Yes” to third interview.
- **MOVE-026-D08 — 2026-11-08:** Stable committed outcome identity drives checked quest/discovery/legal/location reactions. Optional presentation failure cannot repeat transition/rewards; declared failure response is not successful entry. User: “2. Yes” to third interview.
- **MOVE-026-D09 — 2026-11-08:** Block saving while unresolved with clear reason; release only owned restriction after valid destination/original-context recovery. Native load reconstructs through SAVE/MOVE-027, not replayed activation. User: “3. Yes” to third interview.

The complete [MOVE-026 specification](systems/MOVE/MOVE-026.md) is approved — finalized v1 under MOVE-026-A01. Documented owner dependencies remain open. No implementation is authorized.

## MOVE-025 interview decisions

- **MOVE-025-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-025 Draft v1. The [specification](systems/MOVE/MOVE-025.md) is finalized v1. Documented hook/scope identities, quest/mod priority, observers/recursion, provider activation safety, custom schemas and lifetime/failure verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-025-D01 — 2026-11-08:** Stable model/flat/content identity and explicit instance components, not display/node names, select handlers. Resolve collider to declared interaction owner. User: “1. Yes” to first interview.
- **MOVE-025-D02 — 2026-11-08:** Components/registrations share primary replacement or result-observation contract; no double primary effects. Instance-specific primary precedes broad content-type primary; quest overrides retain declared MOVE-018 routing. User: “2. Yes” to first interview.
- **MOVE-025-D03 — 2026-11-08:** Validated context includes stable target, mode/action, actor, hit position/distance and operation identity. Declare reach/modes, honor obstruction/context and explicit outcomes. Collider attachment alone grants no unrestricted activation. User: “3. Yes” to first interview.

- **MOVE-025-D04 — 2026-11-08:** Same-scope/key replacement winner is last valid provider in resolved enabled-mod order, with candidate/winner diagnostics. Validate before menu; provider set locked for application run. Invalid contributions require explicit recovery, not silent omission. User: “1. Yes” to second interview.
- **MOVE-025-D05 — 2026-11-08:** Application definitions separate from scoped instance bindings. Teardown invalidates components/callbacks/prompts; destroyed target cannot redirect to replacement. No live provider switching. User: “2. Yes” to second interview.
- **MOVE-025-D06 — 2026-11-08:** Primary errors/invalid results stop affected interaction into owner recovery without alternate/default retry. Effect-free Not applicable permits fallback. Optional observer failures cannot replay primary; required gameplay observation checked. User: “3. Yes” to second interview.

- **MOVE-025-D07 — 2026-11-08:** Separate pure preview query for description/availability/presentation; no activation call/random draws/quest-item mutations. Custom indicators remain Off by default under MOVE-018. User: “1. Yes” to third interview.
- **MOVE-025-D08 — 2026-11-08:** Observers use declared stable order once per registration/outcome; duplicate bindings cannot multiply effects. Recursive activation needs explicit bounded domain contract. Required quest reactions retain owner semantics. User: “2. Yes” to third interview.
- **MOVE-025-D09 — 2026-11-08:** Persist validated versioned provider/target custom state, not callbacks/engine objects. Deferred restore revalidates context/completion; missing required provider/state uses recovery. Unsupported in-flight actions declare save restriction; no arbitrary code serialization promise. User: “3. Yes” to third interview.

The complete [MOVE-025 specification](systems/MOVE/MOVE-025.md) is approved — finalized v1 under MOVE-025-A01. Documented owner dependencies remain open. No implementation is authorized.

## MOVE-024 interview decisions

- **MOVE-024-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-024 Draft v1. The [specification](systems/MOVE/MOVE-024.md) is finalized v1, including moddable practice. Documented target lifecycle, attempt/reward/practice/legal commitment, response groups, gold admission, mod/RNG schemas and native verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-024-D01 — 2026-11-08:** Initial targets mobile townspeople/humanoid enemy-class actors; one authorized attempt per persistent target regardless success. Ordinary creatures/static service NPCs excluded absent supported mod/quest rule. Blocked repeats consume no roll/practice. User: “1. Yes” to first interview.
- **MOVE-024-D02 — 2026-11-08:** After successful check, separate 67% gold-find chance then uniform 1–6 gold; otherwise nothing valuable. No victim inventory browsing/item stealing initially. Loot/eligibility moddable. User: “2. Yes” to first interview.
- **MOVE-024-D03 — 2026-11-08:** Moddable vanilla townsperson failure detection and target-hostility policies routed through LAW/NPC with explicit valid target. Missing target is not townsperson. Unrelated hostility needs declared response-group rule; LAW owns guards. User: “3. Yes” to first interview.

- **MOVE-024-D04 — 2026-11-08:** +1 raw Pickpocket practice per genuine authorized attempt including failure/empty success; invalid/range-blocked/repeated requests award none. Once-only attempt identity. User explicitly requires practice rules moddable. User response to second interview item 1.
- **MOVE-024-D05 — 2026-11-08:** Vanilla generated petty gold, not simulated purse deduction; no merchant/corpse inventory access. ITEM credit/capacity applies; failed credit retains resolved reward for recovery without reroll. Mods may supply victim-owned transfer. User: “2. Yes” to second interview.
- **MOVE-024-D06 — 2026-11-08:** Revalidate identity/eligibility/reach/obstruction before authorization; authorized attempt spent with retained outcomes despite later UI/technical failure. Rejected-before-authority requests spend none. Exact commit boundaries owner-defined. User: “3. Yes” to second interview.

- **MOVE-024-D07 — 2026-11-08:** Moddable reach 3.2 reference units, obstruction/live-target checks; corpses use loot. Steal grants no extended/through-wall reach. User: “1. Yes” to third interview.
- **MOVE-024-D08 — 2026-11-08:** Eligible enemy-class targets may already be hostile; success grants no pacification/concealment. Failure uses declared target/group response; mod restrictions supported. User: “2. Yes” to third interview.
- **MOVE-024-D09 — 2026-11-08:** Save target attempt and committed unresolved reward/reaction; reload/re-entry cannot refresh attempts. Genuinely new actors have distinct identity. Outcome feedback hides exact rolls by default; optional chance follows RULE-010. User: “3. Yes” to third interview.

The complete [MOVE-024 specification](systems/MOVE/MOVE-024.md) is approved — finalized v1 under MOVE-024-A01. Documented owner dependencies remain open. No implementation is authorized.

## MOVE-023 interview decisions

- **MOVE-023-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-023 Draft v1. The [specification](systems/MOVE/MOVE-023.md) is finalized v1. Documented capabilities/quest reservations, availability, board reach/refresh, domain transaction, mod schemas, native/UI and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-023-D01 — 2026-11-08:** Explicit actor capabilities/current location/faction select dialogue/services; Grab/Talk may share routing. Appearance cannot grant services; unsupported actions cannot become theft. Routing moddable. User: “1. Yes” to first interview.
- **MOVE-023-D02 — 2026-11-08:** Quest reservations/listeners declare replacement or observation, scope to intended actor and release with owning action. No faction-wide suppression merely from listener existence. Preserve necessary scripted exceptions via validated mappings. User: “2. Yes” to first interview.
- **MOVE-023-D03 — 2026-11-08:** Explicit board activation shows permitted local news/rumors without automatic quest acceptance/time advance/unrelated actions. Use actual board location; retain resolved message while UI open, no redraw rerolls. Info describes only; content/routing moddable. User: “3. Yes” to first interview.

- **MOVE-023-D04 — 2026-11-08:** Dialogue/services require valid available actor and supported action. Dead/removed/unavailable actors cannot open stale services. Hostility does not implicitly route to dialogue/theft; NPC/COMBAT/QUEST own exceptions. User: “1. Yes” to second interview.
- **MOVE-023-D05 — 2026-11-08:** Retain stable actor identity/context per interaction rather than mutable global last-clicked authority. Later clicks/redraw cannot redirect quest/service/dialogue effects. User: “2. Yes” to second interview.
- **MOVE-023-D06 — 2026-11-08:** Confirmed service consequences revalidate actor/access/location/service requirements. Invalid operations cancel with explanation without repeated costs/quest effects. ECON/FACT/NPC own service rules. User: “3. Yes” to second interview.

- **MOVE-023-D07 — 2026-11-08:** Board reopen uses owner refresh policy, not guaranteed permanent/fresh-random text. Reading cannot farm rewards/discoveries. NPC/QUEST/TIME own cadence/selection. User: “1. Yes” to third interview.
- **MOVE-023-D08 — 2026-11-08:** Valid no-news uses localized response; required missing actor/faction/service/quest data gives explicit unavailable/recovery, not fabricated service/alternate action. DATA governs optional fallback. User: “2. Yes” to third interview.
- **MOVE-023-D09 — 2026-11-08:** UI follows CORE; supported restore retains target/message/owner state and revalidates consequences. No rerolls/replayed purchases/rewards or ended-owner reservations. UI/SAVE own support inventory. User: “3. Yes” to third interview.

The complete [MOVE-023 specification](systems/MOVE/MOVE-023.md) is approved — finalized v1 under MOVE-023-A01. Documented owner dependencies remain open. No implementation is authorized.

## MOVE-022 interview decisions

- **MOVE-022-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-022 Draft v1. The [specification](systems/MOVE/MOVE-022.md) is finalized v1. Documented property legality, stock/randomness, capacity/transfer commitment, target lifecycle, wagon reach, restored UI and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-022-D01 — 2026-11-08:** Separate inspection/opening from transfer; opening does not transfer ownership. LAW explicitly defines any private-inspection legality/prompt; taking evaluates its own ownership/access. User: “1. Yes” to first interview.
- **MOVE-022-D02 — 2026-11-08:** Confirm eligible non-player household inspection; owned house/ship storage has no private-property warning. Confirmation revalidates original target/reach/permission/context; cancel transfers nothing. Prompt policy moddable. User: “2. Yes” to first interview.
- **MOVE-022-D03 — 2026-11-08:** Retain moddable arrow-only corpse auto-collection, obeying ITEM capacity/ownership. Failed transfer leaves items and explains; no weighted-capacity bypass/duplication. Info never collects. User: “3. Yes” to first interview.

- **MOVE-022-D04 — 2026-11-08:** Current open/authorized shop context routes to trade; closed/unauthorized shelf access requires explicit property/theft rules. Revalidate purchase/transfer, not stale entry-time open flag. Routing moddable. User: “1. Yes” to second interview.
- **MOVE-022-D05 — 2026-11-08:** ITEM/ECON own retained stocking/restocking. Info/hover/cancelled property prompts/UI reopening cannot reroll contents. Authorized access/restock prepares and publishes once. User: “2. Yes” to second interview.
- **MOVE-022-D06 — 2026-11-08:** Empty corpses give concise response but retain Info/valid quest targeting. Cleanup cannot disable unrelated targeting or permanently hide later legitimate contents; lifetime LOC/ITEM-owned. User: “3. Yes” to second interview.

- **MOVE-022-D07 — 2026-11-08:** Arrow-only shortcut collects maximum eligible fitting quantity, leaves remainder and reports partial/full-capacity result. No mixed-loot selection or ownership laundering; ITEM owns stack/weight rounding. User: “1. Yes” to third interview.
- **MOVE-022-D08 — 2026-11-08:** Optional owned-cart dungeon-exit prompt has Access wagon/Leave dungeon/Cancel. Wagon access does not exit; leave uses validated placement. Revalidate ownership/original exit; storage reach ITEM/LOC-owned. User: “2. Yes” to third interview.
- **MOVE-022-D09 — 2026-11-08:** Item moves commit once across source/destination; saves retain generated contents/ownership. UI close/load/retry cannot duplicate/reroll. Supported restored loot UI revalidates target; raw references/clicks transient. ITEM/SAVE own transaction boundaries. User: “3. Yes” to third interview.

The complete [MOVE-022 specification](systems/MOVE/MOVE-022.md) is approved — finalized v1 under MOVE-022-A01. Approved Info/dispatch, property and ITEM admission contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-021 interview decisions

- **MOVE-021-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-021 Draft v1. The [specification](systems/MOVE/MOVE-021.md) is finalized v1, including nonblocking moving/open doors with interaction targetability. Doorway-occupation behavior remains subject to testing and possible explicit revision. Documented collision/mask, action-chain, fixture, MAGIC/bash, persistence and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-021-D01 — 2026-11-08:** Stationary unlocked action doors toggle; locked report lock. Steal requests eligible picking; bash/Lock/Open use explicit contracts. Motion-time requests ignored without queued toggles. Policies moddable. User: “1. Yes” to first interview.
- **MOVE-021-D02 — 2026-11-08:** Preserve validated authored mechanism links/effects with propagated authorized trigger identity. Intentional door/action composition allowed without double generic/door execution. Authored contracts define order/repeatability. User: “2. Yes” to first interview.
- **MOVE-021-D03 — 2026-11-08:** Grab/Talk activate supported ladders/bookshelf reading; Info descriptions only. Ladder needs validated destination/collision-safe route; reading grants no ownership. ITEM/LOC own content/traversal. Validated mod mappings supported. User: “3. Yes” to first interview.

- **MOVE-021-D04 — 2026-11-08:** Interior retry requires live Lockpicking greater than recorded failed value, persisted per door; blocked attempts consume no roll/practice. Ordinary picks cannot defeat magically held locks. Eligibility moddable. User: “1. Yes” to second interview.
- **MOVE-021-D05 — 2026-11-08:** User qualifies obstruction recommendation: retain ordinary animated-door nonblocking collision during motion, with moddable alternatives. Do not impose universal solid moving-door behavior. Exact closed-state collision restoration needs clarification; crush-enabled mechanisms remain distinct. User called these moving static doors; target terminology distinguishes animated action doors from static entrance markers.
- **MOVE-021-D06 — 2026-11-08:** Declare one-shot/repeatable/busy retrigger policies; unsupported busy triggers rejected without implicit queue. Validate/bound linked cycles; intentional timed/repeating mechanisms use explicit schedules. User: “3. Yes” to second interview.

- **MOVE-021-D07 — 2026-11-08:** Open ordinary doors must not obstruct player movement or later projectiles, avoiding narrower passages, while remaining targetable for closing/bashing. Separate blocking versus interaction queries; policies moddable. User explicitly requests this behavior instead of answering closed-overlap proposal; safe closed collision restoration remains pending.
- **MOVE-021-D08 — 2026-11-08:** Successful interior pick clears lock and requests opening; retain unlocked until explicit lock action/effect. Failed opening/presentation cannot replay pick/practice. MAGIC owns Lock/Open eligibility/duration/source rules. User: “2. Yes” to third interview.
- **MOVE-021-D09 — 2026-11-08:** Pause freezes doors/mechanisms/gameplay chain timers. Save lock/opening progress, mechanism state and required chain completion/timers without firing links/repeating effects on restore. Unsupported in-flight restoration declares reasoned save restriction. LOC/SAVE own inventory. User: “3. Yes” to third interview.

- **MOVE-021-D10 — 2026-11-08:** Restore ordinary closed-door blocking only when player/solid occupants do not overlap, waiting safely without crush/teleport/push. Moving/open remain nonblocking; clear closed doorway blocks normally. User approves provisionally, explicitly requesting possible revision if intentional doorway occupation or other edge cases produce awkward behavior. Representative tests must evaluate this before implementation completion.

The complete [MOVE-021 specification](systems/MOVE/MOVE-021.md) is approved — finalized v1 under MOVE-021-A01. Approved dispatch, Info safety, lock probability and movement contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-020 interview decisions

- **MOVE-020-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-020 Draft v1. The [specification](systems/MOVE/MOVE-020.md) is finalized v1. Documented access/schedule/quest mappings, lock/relock scope, attempt/legal contracts, presentation, persistence and placement verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-020-D01 — 2026-11-08:** Evaluate physical locks, entry permission and public opening status separately. DFU-derived access policies become explicit moddable definitions; unlocked does not automatically mean lawful. Ownership/guild/quest exceptions declare precisely what they override. User: “1. Yes” to first interview.
- **MOVE-020-D02 — 2026-11-08:** Locked Grab/Talk reports lock and stops; Steal may request lockpicking; bash requires explicit attack/bash. Info remains informational. Open effect follows explicit MAGIC activation, not automatic casting permission from every click. User: “2. Yes” to first interview.
- **MOVE-020-D03 — 2026-11-08:** Revalidate target/access/opening status/readiness after prompts and before entry commitment. Failed/cancelled entry cannot publish inside/dismount/successful trespass. Completed pick/cast attempts retain their own consequences. User: “3. Yes” to first interview.

- **MOVE-020-D04 — 2026-11-08:** Replace broad active-quest residence unlock with explicit quest grants specifying unlock, permission or both. Preserve necessary vanilla quest access through validated mappings; theft targets cannot unlock accidentally. User: “1. Yes” to second interview.
- **MOVE-020-D05 — 2026-11-08:** Physically unlocked entrances permit entry despite absent permission, reporting unauthorized context to LAW. No universal confirmation prompt. LAW owns trespass qualification/detection/consequences. User: “2. Yes” to second interview.
- **MOVE-020-D06 — 2026-11-08:** Retain DFU-derived hours/daytime residence/guild/holiday policies as moddable baselines, with explicit ownership/authorized-quest precedence. Use target building region/current game time. TIME/ECON/FACT own exact rules; missing required data cannot silently grant public access. User: “3. Yes” to second interview.

- **MOVE-020-D07 — 2026-11-08:** Failed exterior picking records live Lockpicking per building; retry requires exceeding recorded failed value. Persist it; blocked attempts have no roll/practice. Retry policy moddable. User: “1. Yes” to third interview.
- **MOVE-020-D08 — 2026-11-08:** Exterior lock baseline floor(building quality/2), explicitly a DFU approximation, moddable with validated explicit difficulty overrides. RULE-009 exterior model supplies probability and difficulty explanation. User: “2. Yes” to third interview.
- **MOVE-020-D09 — 2026-11-08:** Report attempt, successful forced entry and unauthorized entry distinctly to LAW. Pick failure does not directly spawn guards here; bash noise/detection use explicit LAW rules independent of audible playback. User: “3. Yes” to third interview.

- **MOVE-020-D10 — 2026-11-08:** Successful pick/Open establishes explicit unlocked state persistent across re-entry/native saves until declared owner relock. Hours alone cannot erase it; scheduled relock requires explicit moddable policy. Unlock is not lawful permission. User: “1. Yes” to fourth interview.
- **MOVE-020-D11 — 2026-11-08:** Retain configurable eligible residence greetings/shop-quality presentation before entry, without access grants/extra attempts/trespass commitment. Close continues original revalidated entry; cancel/failure remains outside. Text/availability remain UI/ECON/LOC. User: “2. Yes” to fourth interview.

The complete [MOVE-020 specification](systems/MOVE/MOVE-020.md) is approved — finalized v1 under MOVE-020-A01. Approved interaction, mode, transport and CORE transition contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-019 interview decisions

- **MOVE-019-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-019 Draft v1. The [specification](systems/MOVE/MOVE-019.md) is finalized v1. Documented target mappings/disclosure, inspection distances, discovery/quest contracts, input/presentation, mod ordering and native verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-019-D01 — 2026-11-08:** Retain Grab/Talk/Info/Steal with rebindable direct selection and forward/back cycling. Fresh characters default Grab. Actual mode changes use concise notification/existing HUD indication, without target highlights. User: “1. Yes” to first interview.
- **MOVE-019-D02 — 2026-11-08:** Info cannot implicitly talk, steal, open containers, operate mechanisms or advance activation-triggered quests. It may reveal permitted descriptions and explicitly record discoveries such as building identity. Targets declare information behavior; unsupported targets harmless. User: “2. Yes” to first interview.
- **MOVE-019-D03 — 2026-11-08:** Explicit validated moddable per-target mode mappings. Grab/Talk may share NPC dialogue; Steal cannot silently become another criminal action and Info remains informational. LAW/later features own theft/access details. User: “3. Yes” to first interview.

- **MOVE-019-D04 — 2026-11-08:** Menus preserve selected mode; native saves restore it including Steal/HUD indication. Fresh characters start Grab. Load/menu close cannot activate mode action. User: “1. Yes” to second interview.
- **MOVE-019-D05 — 2026-11-08:** Visible building/NPC/enemy Info may exceed ordinary reach under explicit moddable inspection distance/solid obstruction checks. Descriptions cannot expose hidden inventory, undiscovered quest facts or private identity. Exact vanilla distance/permissions remain owners' decisions. User: “2. Yes” to second interview.
- **MOVE-019-D06 — 2026-11-08:** Capture mode at activation release; deferred prompts retain intended action. Later mode change cannot reinterpret confirmation as theft/another action; invalid new context cancels with explanation. User: “3. Yes” to second interview.

- **MOVE-019-D07 — 2026-11-08:** Cycle Steal→Grab→Info→Talk→Steal, reverse opposite. Fresh press changes once; selecting current mode is a no-op without repeat notification. User: “1. Yes” to third interview.
- **MOVE-019-D08 — 2026-11-08:** Explicit Info activation records only approved target discovery. Hover/mode selection/previews record none. Discovery notifications cannot trigger ordinary quest activation; quest discovery use requires explicit contract. User: “2. Yes” to third interview.
- **MOVE-019-D09 — 2026-11-08:** Concise localized target-specific Info, no automatic stat panels/hidden tooltips. Optional missing descriptions use declared generic text/silence; required identity failure uses owner recovery. Information/mode presentation moddable and respects accessibility. User: “3. Yes” to third interview.

The complete [MOVE-019 specification](systems/MOVE/MOVE-019.md) is approved — finalized v1 under MOVE-019-A01. Approved release-time dispatch, communication and CORE input/context contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-018 interview decisions

- **MOVE-018-A01 — 2026-11-08 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-018 Draft v1. The [specification](systems/MOVE/MOVE-018.md) is finalized v1. Documented targeting/handler precedence, notification/spell contracts, feedback inventory, deferred/save identity and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-018-D01 — 2026-11-07:** Activate on deliberate release, resolving target at release. Menu/focus/load/disconnect cancellation cannot count as release or activate a target; do not retain press-time target. User: “1. Yes” to first interview.
- **MOVE-018-D02 — 2026-11-07:** Select nearest eligible ray collision with solid obstruction blocking targets behind it. Never skip solid blockers just because farther target is interactive. Decorative nonblocking surfaces need validated classification. User: “2. Yes” to first interview.
- **MOVE-018-D03 — 2026-11-07:** Explicit Not applicable/Handled/Blocked/Deferred outcomes. Handled/Blocked/Deferred consume primary interaction; declared notifications may compose without competing primary effects. Exact quest/mod priority remains open. User: “3. Yes” to first interview.

- **MOVE-018-D04 — 2026-11-07:** Applicable explicit quest overrides precede ordinary built-ins. Quest observation is a separately declared notification, not automatic replacement; QUEST declares attempt versus successful-result timing. User: “1. Yes” to second interview.
- **MOVE-018-D05 — 2026-11-07:** Mods declare primary replacement or result observation. Resolve replacement conflicts through validated provider order/diagnostics, not all matches. Built-in fallback only on explicit Not applicable before effects, never after partial execution/error. User: “2. Yes” to second interview.
- **MOVE-018-D06 — 2026-11-07:** Deferred prompts retain stable target/action and revalidate existence/range/obstruction/access/context at confirmation. Invalid intent cancels with explanation, without retargeting/replaying prior effects. User: “3. Yes” to second interview.

- **MOVE-018-D07 — 2026-11-07:** Moddable category reach baselines: ordinary objects/doors/treasure 3.2, corpses 3.75, NPCs 6.4 reference units. Validate reach before primary execution/quest attempt notification. World conversion/Info reach remain owner work. User: “1. Yes” to third interview.
- **MOVE-018-D08 — 2026-11-07:** Non-touch ready spell owns activation; touch spell gets first refusal on eligible in-range entity, otherwise permitted environment actions may proceed. Never both cast/interact from one input. MAGIC owns spell eligibility. User: “2. Yes” to third interview.
- **MOVE-018-D09 — 2026-11-07:** User requests targeting/interaction communication be moddable and off by default depending on interaction type, rather than unconditional target indication. Proactive target indicators are therefore not enabled by default. Exact attempted-feedback default needs clarification; preview purity remains required and no gameplay mutation is authorized by a preview.

- **MOVE-018-D10 — 2026-11-08:** Retain existing interaction-specific attempted responses such as too-far/locked-door explanations, with no generic hover labels/highlights/new blocked popups. Mods may customize communication per interaction type. Clarifies D09. User: “1. Yes” to fourth interview.
- **MOVE-018-D11 — 2026-11-08:** Observers cannot repeat completed primary actions or create a second primary interaction from that activation. Required gameplay reactions need checked quest/domain contracts; optional UI/audio failure cannot replay primary action. User: “2. Yes” to fourth interview.

The complete [MOVE-018 specification](systems/MOVE/MOVE-018.md) is approved — finalized v1 under MOVE-018-A01. Approved input cancellation, view/cursor and CORE context contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-017 interview decisions

- **MOVE-017-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-017 Draft v1. The [specification](systems/MOVE/MOVE-017.md) is finalized v1. Documented camera/stride tuning, surface/cue priority, playback budgets/fallbacks, NPC noise integration and rendered/audio verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-017-D01 — 2026-11-07:** Separate intensity controls including Off for gait bob, mounted bob and landing camera feedback. Disabling them leaves footsteps/important landing/water sounds available. Stair smoothing and necessary posture-height changes are separate. User: “1. Yes” to first interview.
- **MOVE-017-D02 — 2026-11-07:** Footsteps follow actual voluntary supported travel with configurable gait stride lengths, not blocked held input/passive platform carriage. Swim strokes/mount sounds use their own movement context. User: “2. Yes” to first interview.
- **MOVE-017-D03 — 2026-11-07:** Validated surface/context audio mappings include stone/outdoor ground/snow/shallow water/swimming and modded categories. Audio cannot define traction/detection/gameplay. NPC hearing uses authoritative noise independently so muting cannot improve stealth. User: “3. Yes” to first interview.

- **MOVE-017-D04 — 2026-11-07:** Modest positional gait/mounted bob default, no rotational bob/roll; landing camera feedback defaults Off. Optional motion stays geometry-safe and cannot change authoritative aim/breathing/posture. Exact strengths require fixtures. User: “1. Yes” to second interview.
- **MOVE-017-D05 — 2026-11-07:** Resolved landing/water entry selects appropriate cue once without duplicated step/impact/splash for same event. Stationary swimming/hovering cannot loop movement sounds merely from mode state. Ambient water belongs to AV. User: “2. Yes” to second interview.
- **MOVE-017-D06 — 2026-11-07:** Pause gameplay-linked feedback; resume supported ongoing audio without replaying completed steps/impacts. Teleport/load resets offsets/distance baselines without bursts/old-location bob. Presentation phase need not be saved as character state. User: “3. Yes” to second interview.

- **MOVE-017-D07 — 2026-11-07:** Retain fractional stride progress but bound audible catch-up after stalls, skipping obsolete presentation cues rather than rapid backlog. Authoritative activity/NPC noise remain separate without silently dropped gameplay events. User: “1. Yes” to third interview.
- **MOVE-017-D08 — 2026-11-07:** Optional sounds use declared fallback or explicitly allowed silence with diagnostics; cannot block movement/suppress damage. Support validated mod mappings/strides/camera strengths; required assets retain owner recovery. User: “2. Yes” to third interview.
- **MOVE-017-D09 — 2026-11-07:** Actual-motion sounds continue in gameplay cursor mode while optional bob eases to neutral and stays suppressed for steady clicking. No movement pause/facing change; ordinary menus follow CORE pause. User: “3. Yes” to third interview.

The complete [MOVE-017 specification](systems/MOVE/MOVE-017.md) is approved — finalized v1 under MOVE-017-A01. Approved camera, stair, landing, water and transport contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-016 interview decisions

- **MOVE-016-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-016 Draft v1. The [specification](systems/MOVE/MOVE-016.md) is finalized v1, including vanilla mounted overworld surface-water travel, static owned-ship teleport boarding and explicit modding capabilities. Documented shape/motion, activity/water/location, ownership/ship, extension schemas, native restoration and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-016-D01 — 2026-11-07:** Vanilla horse/cart access uses inventory ownership without nearby simulated animal/parked vehicle, feed, horse-health or retrieval requirements. ITEM/ECON own ownership/storage. User explicitly requires this behavior to be moddable, including alternate access/requirements and supported additional mount lifecycle behavior; this does not enable those mechanics in vanilla or predefine their full contracts.
- **MOVE-016-D02 — 2026-11-07:** Rebindable quick mount plus explicit Horse/Cart UI choices. Quick mount uses last successfully selected owned transport, initially Horse then Cart. Unavailable requests explain and preserve current mode. User: “2. Yes” to first interview.
- **MOVE-016-D03 — 2026-11-07:** Mount only from valid supported on-foot movement with full mounted-shape clearance; dismount requires valid on-foot shape/support. Rejection preserves mode, without fall reset/ceiling bypass. Building/dungeon entry requires validated Foot transition. Water/levitation/air compatibility remains to resolve. User: “3. Yes” to first interview.

- **MOVE-016-D04 — 2026-11-07:** Moddable Horse speed=(live Speed+375)/39.5, Cart=(live Speed+250)/39.5. No ordinary Run/Sneak speed changes; retain proportional input/no diagonal bonus; verify scale. User: “1. Yes” to second interview.
- **MOVE-016-D05 — 2026-11-07:** Horse jump baseline 4.5*1.75, moddable and independent of rider Jumping/Athleticism bonuses; Cart cannot jump in vanilla. Fresh-press/ceiling/fall-history rules remain binding. Mounted fall consequences need explicit integration without invented horse health. User: “2. Yes” to second interview.
- **MOVE-016-D06 — 2026-11-07:** Prohibit mount/dismount while airborne, climbing, rappelling or levitating. Horse/Cart retain surface travel on vanilla surface-only exterior water; depth-enabled mounted underwater travel requires explicit policy. Compatibility moddable. User: “3. Yes” to second interview.

- **MOVE-016-D07 — 2026-11-07:** User generally accepts no initial mounted underwater travel in depth-enabled water: ordinary shore entry requires safe dismount or blocks voluntary swim-required entry; forced falls/moving-water cases require explicit recovery without immunity. User reiterates vanilla mounted overworld-water travel must remain allowed and moddable; this preserves D06 surface-only travel, not a blanket water prohibition. Mods may supply mounted swimming.
- **MOVE-016-D08 — 2026-11-07:** Commit Foot with successful building/dungeon entry after valid destination placement. Failed/cancelled entry leaves mounted mode outside; exiting remains Foot without automatic remount. User: “2. Yes” to third interview.
- **MOVE-016-D09 — 2026-11-07:** Vanilla owned ship is a static offshore destination reached by teleport boarding, retaining return context; no controlled sailing. User explicitly favors normal teleport behavior and requires moddable boarding/ship behavior. Apply existing readiness/placement safety without introducing a new mandatory travel simulation. Ownership/interior remain ECON/LOC contracts. User clarification to third interview.

- **MOVE-016-D10 — 2026-11-07:** Mounted falls damage player under MOVE-010 without separate vanilla horse health. Riding grants no Running practice; horse jumps use CHAR-020 ordinary jump cost/practice once. User: “1. Yes” to fourth interview.
- **MOVE-016-D11 — 2026-11-07:** Prevent voluntary sale/removal of currently ridden transport until dismounted, explaining why. Script/mod ownership invalidation uses explicit safe dismount/recovery, not midair state deletion. Policy moddable. User: “2. Yes” to fourth interview.
- **MOVE-016-D12 — 2026-11-07:** Save selected transport/ship return context; restore ownership, geometry and shape before movement without replayed mount/boarding/cost/travel. Pause preserves transport and suspends gameplay-linked movement/audio. Missing definitions/invalid return uses explicit placement recovery. User: “3. Yes” to fourth interview.

The complete [MOVE-016 specification](systems/MOVE/MOVE-016.md) is approved — finalized v1 under MOVE-016-A01. Approved movement, posture, water and activity contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-015 interview decisions

- **MOVE-015-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-015 Draft v1. The [specification](systems/MOVE/MOVE-015.md) is finalized v1, including the documented extended-skill implication of Water Walking's fixed Walk-speed replacement. Documented speed/shape tuning, shore/mode/force handoffs, MAGIC/mod schemas, native restoration and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-015-D01 — 2026-11-07:** Swim forward/back/sideways relative to horizontal facing, ignoring camera pitch for depth. Held Jump/Float Up ascends and Crouch/Float Down descends in depth-enabled water only; opposing vertical inputs cancel without ordinary jump/posture effects. User: “1. Yes” to first interview.
- **MOVE-015-D02 — 2026-11-07:** Moddable swim speed=ordinary standing Walk speed*(live Swimming/200+0.25). Run/Sneak do not alter swimming speed. Cap complete 3D direction magnitude and retain proportional analog input. User: “2. Yes” to first interview.
- **MOVE-015-D03 — 2026-11-07:** Neutral swimming holds depth without voluntary drift or vanilla weight-induced sinking. Surface ascent cannot launch into air; exit requires valid shore movement/climbing/levitation. External forces remain collision-resolved; mods may add buoyancy/sinking. User: “3. Yes” to first interview.

- **MOVE-015-D04 — 2026-11-07:** Vanilla Water Walking replaces ordinary Swimming multiplier with full ordinary standing Walk speed, without Run/Sneak bonus. Replacement rule moddable; MAGIC owns costs/duration. User: “1. Yes” to second interview.
- **MOVE-015-D05 — 2026-11-07:** Dedicated validated swim collision shape/eye position, not ordinary crouch. Coordinate entry/exit with clearance validation; exit cannot force standing through ceilings. Preserve desired land posture. Exact dimensions require world-scale fixtures. User: “2. Yes” to second interview.
- **MOVE-015-D06 — 2026-11-07:** Paralysis blocks voluntary swim controls but passive buoyancy remains active and external pushes work. No breath/exhaustion immunity. Support explicit mod buoyancy/paralysis interaction rules. User: “3. Yes” to second interview.

- **MOVE-015-D07 — 2026-11-07:** Live skill/Walk inputs and authorized effects update swim speed next eligible physics step. Explicit source-owned swim modifiers apply once; validate finite domains and moddable maximum selected through collision testing. User: “1. Yes” to third interview.
- **MOVE-015-D08 — 2026-11-07:** Entry requires release/fresh press before held Jump/Crouch becomes vertical swim input. Vertical controls are held regardless of land Crouch preference; ordinary directions may continue. User: “2. Yes” to third interview.
- **MOVE-015-D09 — 2026-11-07:** Pause preserves depth/context/physical state without movement/breath/fatigue progression. Restore validated water representation, swim shape, desired land posture and necessary motion/effects after geometry readiness without replayed splash/fatigue/practice. Missing required content uses explicit recovery. User: “3. Yes” to third interview.

The complete [MOVE-015 specification](systems/MOVE/MOVE-015.md) is approved — finalized v1 under MOVE-015-A01. Approved water representation, encumbrance, levitation and CHAR activity contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-014 interview decisions

- **MOVE-014-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-014 Draft v1. The [specification](systems/MOVE/MOVE-014.md) is finalized v1, including declared exterior water representations, vanilla speed-boost Water Walking and D08's explicit MOVE-010 safe-landing exception. Documented geometry, thresholds, effect/breath/mod schemas, restoration and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-014-D01 — 2026-11-07:** Distinguish body-water contact, swimming support and submerged breathing point. Wading need not imply swimming; surface swimming need not imply breath holding. Levitation can override movement while submersion still affects breathing. User: “1. Yes” to first interview.
- **MOVE-014-D02 — 2026-11-07:** Use validated water geometry/context consistently in dungeons/exteriors, not dungeon-only breathing or terrain-tile-only immersion. Floors/bridges/boats above water cannot induce swimming. Original-data conversion remains WORLD/LOC scope. User: “2. Yes” to first interview.
- **MOVE-014-D03 — 2026-11-07:** Configurable small entry/exit tolerances stabilize surface transitions. Physical breathing point reflects actual posture; cosmetic bob cannot repeatedly start/end breath holding. Exact thresholds require water/camera fixtures. User: “3. Yes” to first interview.

- **MOVE-014-D04 — 2026-11-07:** Valid solid footing permits wading below swimming-entry depth. Actual breathing-point submersion can require breath holding without swimming, including crouching in shallow water. Exact thresholds require tuning. User: “1. Yes” to second interview.
- **MOVE-014-D05 — 2026-11-07:** Validate sufficient unobstructed receiving depth before depth-based MOVE-010 protection. Mere surface contact before shallow-bottom/obstacle impact cannot erase fall history. Valid deep-water entry ends segment once. User: “2. Yes” to second interview. Surface-only exterior representation needs explicit separate policy.
- **MOVE-014-D06 — 2026-11-07:** User explicitly qualifies Water Walking recommendation: vanilla should boost swimming speed, not create a Morrowind-style walkable surface. Exact speed/effect semantics belong to MAGIC/MOVE-015; support modded alternate behavior, including surface support, via explicit contracts. No default surface-support/fall-protection effect is approved.
- **MOVE-014-D07 — 2026-11-07:** Vanilla exterior water may use a surface-swimming representation without actual modeled depth/submersion. Support mod-authored genuine exterior water depth and corresponding immersion. D02's consistent validated context must support both declared representations; do not require excavated/deep exterior water in vanilla or silently infer depth from a tile. This is target policy based on user clarification, not independent verification of every original terrain case.

- **MOVE-014-D08 — 2026-11-07:** Designated surface-only exterior swimming entry is a safe water landing despite abstract depth, explicitly amending MOVE-010. Floors/boats/intervening obstacles take precedence. User: “1. Yes” to third interview.
- **MOVE-014-D09 — 2026-11-07:** Definitions declare surface-only or depth-enabled water. Only depth-enabled water permits underwater descent/submersion; mods can supply exterior depth without dungeon-only logic. Surface-only crouch/bob cannot induce underwater breathing state. User: “2. Yes” to third interview.
- **MOVE-014-D10 — 2026-11-07:** Presentation follows committed water transitions once. Load, adjacent-definition crossings and tolerance oscillation cannot replay splashes/reset breath; CHAR-018 owns reserve/recovery. User: “3. Yes” to third interview.

The complete [MOVE-014 specification](systems/MOVE/MOVE-014.md) is approved — finalized v1 under MOVE-014-A01. D08 explicitly amends MOVE-010; other approved contracts remain binding and documented dependencies remain open. No implementation is authorized.

## MOVE-013 interview decisions

- **MOVE-013-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-013 Draft v1. The [specification](systems/MOVE/MOVE-013.md) is finalized v1. Documented MAGIC source/speed resolution, force/mode/water handoffs, tuning, mod cost/hooks, native restoration and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-013-D01 — 2026-11-07:** Camera-relative forward/back/sideways movement plus world-up/down. Jump/Crouch are contextual ascend/descend without ordinary jump/posture effects; opposing vertical input cancels. User: “1. Yes” to first interview.
- **MOVE-013-D02 — 2026-11-07:** Moddable baseline speed 4 reference units/second, independent of Speed/Running/gait toggles. Cap combined 3D intent magnitude without diagonal/up-forward bonus and retain proportional controller input; verify world scale. User: “2. Yes” to first interview.
- **MOVE-013-D03 — 2026-11-07:** Controlled hover suppresses ordinary gravity while levitation controls movement, with immediate voluntary response/no voluntary release drift. External pushes remain collision-resolved; no collision bypass/crush immunity. User: “3. Yes” to first interview.

- **MOVE-013-D04 — 2026-11-07:** Actual entry into hover cancels prior voluntary/falling momentum. Expiry starts unsupported fall with zero vertical velocity while retaining current horizontal travel velocity; valid ground/swimming support selects that mode instead. External-force transfers require explicit rules. User: “1. Yes” to second interview.
- **MOVE-013-D05 — 2026-11-07:** Paralysis blocks voluntary levitation control but active effect maintains hover and permits external pushes. Expiry resumes ordinary physics even while paralyzed. Explicit gravity-suppression exception under MOVE-004. User: “2. Yes” to second interview.
- **MOVE-013-D06 — 2026-11-07:** Levitation controls movement in water, including ascent out; actual submersion still governs breath/underwater effects. No water breathing or changed water surface. Expiry selects mode from validated water/support context; thresholds remain MOVE-014. User: “3. Yes” to second interview.

- **MOVE-013-D07 — 2026-11-07:** Retain current valid standing/crouched shape on levitation entry, without forced expansion. Ascend/descend do not change posture. Preserve desired posture for clearance-checked exit reconciliation; incompatible riding/other modes need explicit transitions. User: “1. Yes” to third interview.
- **MOVE-013-D08 — 2026-11-07:** Track valid levitation sources separately; ending one cannot disable remaining support. MAGIC declares speed resolution, not repeated multiplication or last-update wins. Exact stacking/duration remain MAGIC scope. User: “2. Yes” to third interview.
- **MOVE-013-D09 — 2026-11-07:** Levitation alone grants no Running/Jumping/Climbing practice or extra movement-specific fatigue rate. Continue applicable ordinary CHAR-020 baseline; MAGIC owns spell/sustained costs. Support validated modded speed/restriction/cost contracts. User: “3. Yes” to third interview.

- **MOVE-013-D10 — 2026-11-07:** Ascend/descend are held controls independent of ordinary Crouch Hold/Toggle preference. Require release/fresh press on levitation entry so previously held Jump/Crouch cannot cause unintended vertical movement. User: “1. Yes” to fourth interview.
- **MOVE-013-D11 — 2026-11-07:** Pause freezes levitation motion/gameplay-linked effect duration. Native restore validates effect sources, posture and needed motion after geometry readiness without recast, repeated cost or replayed entry cancellation. Hover requires restored authorization; missing required effect data uses explicit recovery. User: “2. Yes” to fourth interview.

The complete [MOVE-013 specification](systems/MOVE/MOVE-013.md) is approved — finalized v1 under MOVE-013-A01. Approved movement, fall-protection and CORE suspension contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-012 interview decisions

- **MOVE-012-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-012 Draft v1. The [specification](systems/MOVE/MOVE-012.md) is finalized v1. Documented ledge/route geometry, limits, motion handoffs, mode/retry integration, mod schemas, save/activity ownership and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-012-D01 — 2026-11-07:** Deliberately backing over an eligible ledge initiates wall-directed transition without separate Rappel input. Require reachable wall and full-body route; unsuitable backward edge departure remains falling. User: “1. Yes” to first interview.
- **MOVE-012-D02 — 2026-11-07:** Initial scope is ledge-to-wall attachment then MOVE-011 handoff. Exclude ceiling hanging and underside traversal chains; commented source paths are not complete feature evidence. User: “2. Yes” to first interview.
- **MOVE-012-D03 — 2026-11-07:** Transition uses collision-checked motion under MOVE-004 rather than unchecked curve-position assignment. Blockage stops attempted route without clipping/teleporting through lips/ceilings. Exact path/timing are moddable tuning. User: “3. Yes” to first interview.

- **MOVE-012-D04 — 2026-11-07:** Validated ledge transition guarantees initial grip only after actual wall contact and standing-shape clearance. No random draw; subsequent checks use MOVE-011. Positioning alone grants no fall protection. User: “1. Yes” to second interview.
- **MOVE-012-D05 — 2026-11-07:** Releasing Backward after entry does not cancel short positioning. Fresh Crouch aborts and is consumed; resume valid supported movement or fall from actual pose retaining existing history. Wall Jump exit is available after grip through MOVE-011. User: “2. Yes” to second interview.
- **MOVE-012-D06 — 2026-11-07:** Award one Climbing practice per successfully completed ledge-to-wall transition, none for failed/cancelled positioning. Distinct traversal award, not a rolled check; guaranteed grip adds no second award. No per-frame awards. CHAR-020 owns fatigue. User: “3. Yes” to second interview.

- **MOVE-012-D07 — 2026-11-07:** Active positioning uses CHAR-020 climbing fatigue, including later failed/cancelled attempts. No extra event fatigue charge; practice remains success-only. User: “1. Yes” to third interview.
- **MOVE-012-D08 — 2026-11-07:** Prevent saves during positioning with clear reason; release only this restriction after attachment/exit. Pause retains stage/progress without motion/fatigue advancement. Unfinished transition serialization is outside initial scope. User: “2. Yes” to third interview.
- **MOVE-012-D09 — 2026-11-07:** Validate moddable maximum transition duration/travel distance. Lost eligibility, blockage or exceeded bounds ends attempt into actual supported movement/fall without snapback, cleared history or immediate repeated failure. Re-entry requires renewed deliberate approach. User: “3. Yes” to third interview.

The complete [MOVE-012 specification](systems/MOVE/MOVE-012.md) is approved — finalized v1 under MOVE-012-A01. Approved climbing, fall protection, movement authority and CHAR activity contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-011 interview decisions

- **MOVE-011-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-011 Draft v1. The [specification](systems/MOVE/MOVE-011.md) is finalized v1. Documented geometry/cadence, speed/slip, wall-exit, water/mode integration, mod schemas, native/check restoration and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-011-D01 — 2026-11-07:** Automatic entry requires deliberate held Forward against eligible geometry for a configurable short delay; no separate Climb button initially. Airborne grabs require intent toward wall and successful check; contact alone cannot cancel falls. User: “1. Yes” to first interview.
- **MOVE-011-D02 — 2026-11-07:** Unified controls: Forward up, Backward down, Left/Right sideways, no directional input holds position. Support validated inside/outside corners with full-body clearance, without separate classic/advanced control modes. User: “2. Yes” to first interview.
- **MOVE-011-D03 — 2026-11-07:** Ordinary stationary solid environment geometry is eligible when shape/clearance supports climbing, without individually placed markers. Exclude enemies/currently moving mechanisms; support explicit validated surface exceptions/mod overrides. Wall-angle/contact criteria require geometry fixtures. User: “3. Yes” to first interview.

- **MOVE-011-D04 — 2026-11-07:** Retain moddable owner base chances start 70, continue 50, airborne grab 40, regain hold 20 before RULE-011 resolution. Nominal entry/continuation/slipping intervals approximately 0.77/0.82/0.27 eligible simulation seconds, not frames. User: “1. Yes” to second interview.
- **MOVE-011-D05 — 2026-11-07:** Secure stationary hold has no continuation checks but retains climbing fatigue. Failed continuation starts slipping; regain checks use slipping cadence. Releasing movement while slipping cannot restore grip automatically; require successful recovery or valid ground support. User: “2. Yes” to second interview.
- **MOVE-011-D06 — 2026-11-07:** Moddable climb speed baseline ordinary standing Walk speed/3, doubled by enhanced climbing. Run/Sneak cannot increase it; cap diagonal input and retain proportional controller control. User: “3. Yes” to second interview.

- **MOVE-011-D07 — 2026-11-07:** Fresh Crouch releases wall and is consumed without toggling posture. Fresh Jump performs a deliberate bounded moddable wall-exit push; exact impulse remains tuning. Neither exit permits immediate same-wall auto-grab until Forward is released and the player deliberately approaches again. User: “1. Yes” to third interview.
- **MOVE-011-D08 — 2026-11-07:** Ordinary wall climbing requires standing shape and full clearance before entry; no forced upright clipping. Preserve desired crouch for clearance-checked restoration after exit. Other specialized shapes require explicit rules. User: “2. Yes” to third interview.
- **MOVE-011-D09 — 2026-11-07:** Protect validated swimming-to-climbing water-exit transitions from skill failure blocking escape, without general underwater success override. Require wall contact, body clearance and valid exit route; exact detection remains integration work. User: “3. Yes” to third interview.

- **MOVE-011-D10 — 2026-11-07:** Failed eligible entry retries at entry cadence; airborne grabs use approximately 0.27 seconds. Genuine checks award CHAR-020 practice once including failures. Water-exit guaranteed bypass consumes no random draw and awards no check practice. No per-frame rerolls. User: “1. Yes” to fourth interview.
- **MOVE-011-D11 — 2026-11-07:** Automatic ledge top-out requires supported destination and full-body route. No teleport through lips/ceilings. Blocked route with valid grip remains attached; genuine support loss uses actual movement-state transition. User: “2. Yes” to fourth interview.
- **MOVE-011-D12 — 2026-11-07:** Pause preserves grip/slip and remaining timers. Native saves retain wall identity/contact context, grip/slip and timer phase; validate geometry before restore without fresh entry roll/repeated practice. Missing/incompatible wall uses placement recovery, not fabricated attachment. User: “3. Yes” to fourth interview.

The complete [MOVE-011 specification](systems/MOVE/MOVE-011.md) is approved — finalized v1 under MOVE-011-A01. Approved RULE-011 probability, CHAR activity and MOVE protection/authority contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-010 interview decisions

- **MOVE-010-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-010 Draft v1. The [specification](systems/MOVE/MOVE-010.md) is finalized v1. Documented scale/domains, landing stability, water/protection handoffs, placement, health/outcome persistence, mod hooks and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-010-D01 — 2026-11-07:** Retain moddable safe threshold 5 reference units and damage trunc(max(0,5*(d-5))). Hard-landing feedback above 2.5 units is independent of whether rounding yields actual health loss. Verify distances against Godot world scale. User: “1. Yes” to first interview.
- **MOVE-010-D02 — 2026-11-07:** Measure downward drop from highest actual foot position in the unprotected airborne segment, including jump apex, using world-space height invariant to origin shifts/collider resizing. This deliberately differs from takeoff-only tracking. User: “2. Yes” to first interview.
- **MOVE-010-D03 — 2026-11-07:** Resolve one authoritative landing outcome with independent health/feedback consumers. Missing/muted audio cannot suppress damage; repeated contacts cannot duplicate it. Pause/save/load preserve unresolved history without replaying resolved landings. User: “3. Yes” to first interview.

- **MOVE-010-D04 — 2026-11-07:** Active Slow Fall cancels accumulated damaging-fall distance; protected descent adds none and protected landings cause no fall damage. Expiry midair starts a new unprotected segment at that position. MAGIC owns descent speed. User: “1. Yes” to second interview.
- **MOVE-010-D05 — 2026-11-07:** Water protection requires actual entry into validated sufficiently deep swimmable water, ending damaging segment. Water beneath floors/boats or shallow/obstructed water does not grant blanket protection; actual landing surface applies. Depth criteria remain water-feature dependencies. User: “2. Yes” to second interview.
- **MOVE-010-D06 — 2026-11-07:** Successful supported climb/rappel grab or active levitation taking movement control ends the damaging-fall segment. Failed grabs/requests/casts alone do not. Loss of support starts a new unprotected segment at release. User: “3. Yes” to second interview.

- **MOVE-010-D07 — 2026-11-07:** Vanilla moving-platform landings use world-space drop formula without relative-impact-speed damage. Carriage alone is not a fall; support loss/recovery defines segment. Support explicit modded relative-impact rules. User: “1. Yes” to third interview.
- **MOVE-010-D08 — 2026-11-07:** No automatic vanilla armor/Jumping-skill/attribute reduction beyond approved protections. Support validated modded thresholds, formulas and protections. User: “2. Yes” to third interview.
- **MOVE-010-D09 — 2026-11-07:** Hard landings provide sound/optional visual feedback without added movement lock, stamina drain, injury or forced crouch. Respect camera/accessibility settings; feedback cannot change aim/collider. Stronger penalties need separate approval. User: “3. Yes” to third interview.

The complete [MOVE-010 specification](systems/MOVE/MOVE-010.md) is approved — finalized v1 under MOVE-010-A01. Approved movement, jump, suspension and health contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-009 interview decisions

- **MOVE-009-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-009 Draft v1. The [specification](systems/MOVE/MOVE-009.md) is finalized v1. Documented scale/caps, steering, platform sampling, specialized eligibility, Slow Fall, mod hooks, native flight/fall schemas and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-009-D01 — 2026-11-07:** Retain moddable on-foot jump impulse 4.5*(1+J/200+A+I+E), using live Jumping J; A=0.1 with Athleticism, I=0.1 only with Athleticism plus Improved Athleticism, E=0.6 with enhanced jumping. Actual crouch multiplies impulse by 0.8. Gravity baseline 20; verify world-scale traversal. User: “1. Yes” to first interview.
- **MOVE-009-D02 — 2026-11-07:** One jump per fresh press, requiring valid support and no blocking restriction. No held-repeat, coyote time or pre-landing jump buffer initially. Rejected airborne presses expire without waiting for landing. User: “2. Yes” to first interview.
- **MOVE-009-D03 — 2026-11-07:** Ordinary airborne movement retains horizontal takeoff momentum without steering; looking alone cannot redirect it. Enhanced jumping may enable directional air control through an explicit moddable rule; exact strength remains tuning. User: “3. Yes” to first interview.

- **MOVE-009-D04 — 2026-11-07:** Inherit platform support-point velocity once on jump/walk-off, including rotational point motion. Detach immediately; later platform motion cannot continue accelerating the player. Inheritance is configurable for mods. User: “1. Yes” to second interview.
- **MOVE-009-D05 — 2026-11-07:** Overhead obstruction cancels upward velocity, then gravity causes descent; do not reverse full upward velocity into a downward kick. Horizontal motion remains collision constrained. User: “2. Yes” to second interview.
- **MOVE-009-D06 — 2026-11-07:** Omit DFU's extra camera-forward jump boost in vanilla; preserve actual takeoff momentum instead. Support explicit modded jump-boost rules. User: “3. Yes” to second interview.

- **MOVE-009-D07 — 2026-11-07:** Snapshot skill/traits/effects/actual posture and calculate jump impulse once at successful takeoff. Later changes cannot recalculate that impulse; explicit airborne effects retain their own rules. Charge fatigue/award Jumping practice once for that successful jump. User: “1. Yes” to third interview.
- **MOVE-009-D08 — 2026-11-07:** Retain moddable restriction blocking ordinary jumping while Slow Fall is active. MAGIC/MOVE-010 own descent and fall-history protection, with frame-independent motion and explicit start/end transitions. User: “2. Yes” to third interview.
- **MOVE-009-D09 — 2026-11-07:** Use a validated moddable maximum downward speed, selected through world-scale/collision testing. It does not erase fall history or grant damage immunity; damage formula remains separate. User: “3. Yes” to third interview.

- **MOVE-009-D10 — 2026-11-07:** Enhanced jumping steers with bounded horizontal acceleration toward requested direction, not instantaneous velocity replacement. No unlimited speed or repeated platform-momentum amplification. Losing effect stops steering but retains existing momentum. Acceleration/speed bounds remain moddable tuning. User: “1. Yes” to fourth interview.
- **MOVE-009-D11 — 2026-11-07:** Validate supported skill/formula ranges and cap valid takeoff impulse at a finite positive moddable maximum. Malformed values follow approved recovery; cap requires traversal/collision testing. User: “2. Yes” to fourth interview.
- **MOVE-009-D12 — 2026-11-07:** Save actual velocity, airborne/jump state and takeoff gait; restore after geometry validation without reapplying impulse/platform inheritance or repeating fatigue/practice. Load-time Walk selection applies on grounded gait resumption and cannot rewrite saved flight. Fall history remains MOVE-010 scope. User: “3. Yes” to fourth interview.

The complete [MOVE-009 specification](systems/MOVE/MOVE-009.md) is approved — finalized v1 under MOVE-009-A01. Approved MOVE gait, posture, platform and CHAR activity contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-008 interview decisions

- **MOVE-008-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-008 Draft v1. The [specification](systems/MOVE/MOVE-008.md) is finalized v1. Elevator/mechanism exceptions remain subject to representative testing and possible explicit revision. Documented momentum, compression, specialized-mode, mod policy, persistence and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-008-D01 — 2026-11-07:** Supported players follow platform translation and horizontal rotation while remaining upright. Turning updates horizontal facing without added pitch/roll; voluntary movement remains relative to the platform. User: “1. Yes” to first interview.
- **MOVE-008-D02 — 2026-11-07:** Detach on jump, walking off or lost valid support; no lingering attachment may pull the player back. Platform velocity inheritance remains an explicit MOVE-009 decision. User: “2. Yes” to first interview.
- **MOVE-008-D03 — 2026-11-07:** Retain general forced-crouch then lethal-crushing baseline for qualifying moving mechanisms, based on actual compression rather than ordinary contact, with moddable rules. User qualified approval: some elevator/platform objects may pass through players and allow escape/reboarding; representative testing must establish exceptions and may require revisiting rules. This is reported uncertainty, not verified universal elevator behavior. Thresholds, exceptions and swimming/levitation handling remain unresolved.

- **MOVE-008-D04 — 2026-11-07:** Explicit mechanism policies declare carry/push/crush behavior with validated definition-scoped exceptions. Representative testing establishes baseline; no universal pass-through rule or model-name-only inference. User: “1. Yes” to second interview.
- **MOVE-008-D05 — 2026-11-07:** Moving objects push where collision permits escape. Forced crouch/lethal crushing require a crush-enabled mechanism actually compressing the player against another obstruction; ordinary contact, elevator support or brushing stationary ceilings cannot trigger it. User: “2. Yes” to second interview.
- **MOVE-008-D06 — 2026-11-07:** Forced crouch preserves prior desired posture. When compression clears, automatically fulfill desired standing only with full clearance; deliberate crouch remains crouch. All shape changes use movement coordination. User: “3. Yes” to second interview.

- **MOVE-008-D07 — 2026-11-07:** After attempting forced crouch, lethal crushing occurs when a crush-enabled mechanism continues compressing a grounded player and the validated crouched shape can no longer fit. No arbitrary grace timer or camera-probe-only kill threshold. Exact tolerances require testing. User: “1. Yes” to third interview.
- **MOVE-008-D08 — 2026-11-07:** Swimming/levitation have no blanket immunity to moving geometry. Their shape/movement rules govern push/escape; lethal compression requires an explicitly supported mode-specific rule, not automatic application of grounded crouch-kill logic. User: “2. Yes” to third interview.
- **MOVE-008-D09 — 2026-11-07:** Save stable mechanism identity and player-relative attachment context alongside authoritative platform state. Restore mechanism/geometry before validating support; do not replay travel/crush/damage. Missing/incompatible support uses placement recovery rather than unrelated attachment. Exact mechanism persistence remains LOC/SAVE scope. User: “3. Yes” to third interview.

The complete [MOVE-008 specification](systems/MOVE/MOVE-008.md) is approved — finalized v1 under MOVE-008-A01. Approved movement, posture, suspension and activity contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-007 interview decisions

- **MOVE-007-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-007 Draft v1. The [specification](systems/MOVE/MOVE-007.md) is finalized v1, retaining stable vanilla footing, gentle stair-camera motion and optional modded surface behavior. Reliable steep-connector identification remains unresolved; documented tuning, surface/mod contracts, persistence and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-007-D01 — 2026-11-07:** Automatically traverse small steps within a configured height when the full player shape has clearance along the route and at the destination; taller obstacles require other traversal. Exact height requires world-scale fixtures. Camera motion on ascending/descending stairs must avoid harsh repeated vertical bobbing. User agreed to first question with explicit stair-camera requirement.
- **MOVE-007-D02 — 2026-11-07:** Accept configurable maximum ordinary walkable slope and prevention of diagonal/step-based uphill bypasses, subject to resolving traversal of unusually steep original dungeon block/border connectors. User reports such connectors can form required steep routes and requests they be accounted for; differentiation policy remains unresolved. This report is intended design context, not independently verified geometry evidence.
- **MOVE-007-D03 — 2026-11-07:** Vanilla reproduces stable footing on surfaces that actually support the player, without automatic downhill sliding merely because a surface is steep. If geometry cannot physically provide support, ordinary falling remains applicable. Support mod-defined slope sliding behavior; do not enable the initially recommended forced-slide behavior in vanilla. User explicitly qualified agreement with this baseline and modding request. Exact support criteria and sliding extension contracts remain open.

- **MOVE-007-D04 — 2026-11-07:** Identify required steep dungeon connectors during content preparation and assign validated traversal exceptions; retain normal slope limits elsewhere. Reliable identification is an unresolved content-analysis/engineering dependency, not a proven detector. User: “1. Yes” with concern about differentiation and expectation that later analysis establish it.
- **MOVE-007-D05 — 2026-11-07:** Ordinary slope limit blocks uphill walking but does not force sliding while valid physical support exists. Leaving support causes ordinary falling. Mods may override sliding eligibility and motion parameters through explicit surface rules. User: “2. Yes” to second interview.
- **MOVE-007-D06 — 2026-11-07:** Smooth camera vertical response to automatic steps ascending/descending while collider immediately follows stairs. Bound smoothing against nearby geometry and reset on teleport/load. Add no extra rhythmic stair bob; optional walking head bob remains separate. User: “3. Yes” to second interview.

- **MOVE-007-D07 — 2026-11-07:** Grounded motion follows small downward steps within a configured distance, avoiding repeated stair falls. Larger drops become airborne. Ground following cannot pull jumping players down or bridge unsupported gaps. User: “1. Yes” to third interview.
- **MOVE-007-D08 — 2026-11-07:** Measure ordinary gait speed along the walkable surface, preventing extra total speed from slope vertical components. Connector exceptions permit traversal without speed bonuses. User: “2. Yes” to third interview.
- **MOVE-007-D09 — 2026-11-07:** Vanilla ordinary ground has consistent traction without introduced ice-like slipping/material slowdown. Support explicit modded surface traction, speed contributions and sliding under MOVE-004 authority and MOVE-005 modifier contracts. Water/specialized movement remain separate. User: “3. Yes” to third interview.
- **MOVE-007-D10 — 2026-11-24:** During authorized IMP-012 increment-2 implementation, the user selected an explicitly reviewed list of specific steep vanilla dungeon ramps instead of an automatic detector: “Yes, use a reviewed list in this case, since I don't think these would normally be a case outside the relatively small list of vanilla dungeon blocks.” This selects the identification approach; it does not approve unreviewed candidate faces. Read-only representative source evidence identifies 22 inclined model occurrences in Cyeghtan but does not establish which are required traversal surfaces. Qualify the actual list with placed face identities, collision, clearance, speed and ordinary-surface negative cases before enabling exceptions. No broad dungeon exemption is authorized. Same-day user-requested analysis now proposes three corridor floor faces (61030/1, 67027/6, 67029/6) in 25 exact block records after scanning all 187 RDB blocks. See the [source list review](../development/evidence/IMP-012-STEEP-RAMP-LIST-2026-11-24.md). This is a concrete engineering recommendation, not a further user approval or runtime qualification; no exception has been enabled.

- **MOVE-007-D11 — 2026-11-25 follow-up:** The user confirmed “for sure the 3 corridor ramps should function like this” and then authorized implementation/placement verification: “do what you need to do and I'll test it afterwards or verify the accuracy”. The reviewed source-floor policy now covers 61030/1, 67027/6 and 67029/6 at 25 guarded classic block records. Their physical source identities, placement clearances and ordinary-surface negatives are qualified through the [implementation evidence](../development/evidence/IMP-012-steep-connectors-2026-11-25.md); new human review remains pending. This authorizes the three designs and checking their copies, rather than declaring every assembled route accepted or relaxing neighbouring ordinary stair limits.

- **MOVE-007-D12 — 2026-11-25:** After comparing original staircase risers and the blocked 0.30 m source stairs, the user requested “follow DFU's example, could you change that?” Adopt a 0.50 m automatic step-up baseline, referencing DFU player prefab step offsets. Use independent 0.50 m downward ground following for ordinary stair descent; this downward number is a project interpretation for our ground controller, not a DFU parameter or original-executable measurement. Preserve full-capsule clearance, deliberate crouching, the ordinary slope limit and the reviewed steep-floor policy. Larger obstacles/drops retain their jump/climb/air gates. The earlier 0.25/0.18 m choices were project-authored tuning, not an approved content classification. See [execution evidence](../development/evidence/IMP-012-ordinary-stairs-2026-11-25.md); new human stair/return verification and overall increment acceptance remain separate.


The complete [MOVE-007 specification](systems/MOVE/MOVE-007.md) is approved — finalized v1 under MOVE-007-A01. Approved MOVE authority, gait and clearance contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-006 interview decisions

- **MOVE-006-A01 — 2026-11-07 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-006 Draft v1. The [specification](systems/MOVE/MOVE-006.md) is finalized v1. Documented shape/camera tuning, clearance queries, specialized-mode compatibility, restoration and physics/rendered verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-006-D01 — 2026-11-07:** Independently selectable Hold/Toggle crouching, separate from Run/Sneak preferences. Releasing Hold requests standing but cannot force it through an obstruction. User: “1. Yes” to first interview.
- **MOVE-006-D02 — 2026-11-07:** If the full standing collider cannot fit, remain crouched and retain the standing request; automatically stand when clearance is available. A new crouch request cancels the pending stand. User: “2. Yes” to first interview.
- **MOVE-006-D03 — 2026-11-07:** Commit collider and authoritative posture together in the coordinated physics step, preserving foot position; camera smoothly follows height. Crouched speed applies at posture commitment, independent of camera animation. Exact heights/duration require world-scale/clearance fixtures. User: “3. Yes” to first interview.

- **MOVE-006-D04 — 2026-11-07:** Allow airborne posture changes using the same clearance checks and foot-position preservation. They cannot add upward motion, reset a fall or change takeoff gait before landing under MOVE-005. User: “1. Yes” to second interview.
- **MOVE-006-D05 — 2026-11-07:** Menus/focus loss preserve actual posture and Toggle selection. Hold follows current eligible input on return; release requests clearance-checked standing. Posture/camera-height transitions pause with gameplay without catch-up. User: “2. Yes” to second interview.
- **MOVE-006-D06 — 2026-11-07:** Native saves retain actual posture and desired standing/crouching state, including blocked stand requests. Restore after geometry readiness with clearance validation; set camera directly to validated posture height without replaying old animation. Changed/incompatible geometry recovery remains placement/SAVE scope. User: “3. Yes” to second interview.

- **MOVE-006-D07 — 2026-11-07:** Require deliberate crouching for genuinely low passages. Small collision tolerances may assist traversal but cannot silently shrink standing shape enough to bypass crouch requirements. User: “1. Yes” to third interview.
- **MOVE-006-D08 — 2026-11-07:** Swimming/climbing/levitation/riding explicitly declare required shape and voluntary-crouch support. Shape changes go through MOVE-004 coordination, validating clearance before enlargement; no forced standing through ceilings. Detailed compatibility remains with those features. User: “2. Yes” to third interview.
- **MOVE-006-D09 — 2026-11-07:** Keep camera-height transitions inside safe geometry, shortening/snapping when needed to prevent seeing through walls/ceilings. Visual correction cannot move collider, change facing or reset falls. Exact heights/durations are configurable validated tuning. User: “3. Yes” to third interview.

The complete [MOVE-006 specification](systems/MOVE/MOVE-006.md) is approved — finalized v1 under MOVE-006-A01. Approved MOVE gait/arbitration and CORE input/suspension contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-005 interview decisions

- **MOVE-005-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-005 Draft v1. The [specification](systems/MOVE/MOVE-005.md) is finalized v1, including vanilla inventory-only encumbrance and support for optional modded encumbrance/sprint restrictions. Documented scale, limits, input/airborne integration, modifier/restriction, ITEM, mod resource/persistence and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-005-D01 — 2026-11-06:** Retain DFU ordinary on-foot formulas as initial moddable baselines: walk=(S+150-0.5*(100-max(S,30)))/39.5; run=((S+150)/39.5)*(1.35+R/200); sneak=walk/2-1/39.5, using live Speed S and live Running R. Verify physical traversal against chosen Godot world scale; divisor alone does not guarantee matching pace. User: “1. Yes” to first interview.
- **MOVE-005-D02 — 2026-11-06:** Independently selectable Hold/Toggle behavior for Run and Sneak. When both requested, Run wins and clears Sneak request. User: “2. Yes” to first interview.
- **MOVE-005-D03 — 2026-11-06:** Equal base forward/backward/sideways speed, with diagonal magnitude capped to prevent a bonus. Preserve proportional controller movement while running; do not force full stick strength. User: “3. Yes” to first interview.

- **MOVE-005-D04 — 2026-11-06:** Retain takeoff gait until landing. Airborne Run/Sneak requests may update but apply on landing, without instant airborne speed changes. Restrictions/explicit mode transitions remain immediate; air steering is MOVE-009 scope. User: “1. Yes” to second interview.
- **MOVE-005-D05 — 2026-11-06:** Rebindable Autorun toggles continuous forward intent plus Run request. Backward input or Autorun again cancels it. Menus, focus loss, loading and controller-disconnection recovery cancel autorun, requiring deliberate reactivation. Never change Hold/Toggle preferences as a side effect. User: “2. Yes” to second interview.
- **MOVE-005-D06 — 2026-11-06:** Separate source-owned Walk/Run/Sneak multipliers, each applied once to its gait baseline. Removal affects only that source; changes apply next eligible movement step. Multipliers must be finite and positive; immobilization uses explicit restrictions, not zero multipliers. User: “3. Yes” to second interview.

- **MOVE-005-D07 — 2026-11-06:** Actual non-swimming crouch uses moddable ordinary=(S+50)/39.5, run=ordinary*(1.35+R/200), sneak=ordinary/2-1/39.5. MOVE-006 owns posture/clearance; no swimming rule is selected. User: “1. Yes” to third interview.
- **MOVE-005-D08 — 2026-11-06:** Validate supported stat/formula ranges and enforce a finite positive configurable maximum resolved ordinary gait speed. Malformed configuration follows approved recovery; maximum bounds otherwise valid stacking. Exact cap requires world-scale/collision testing. User: “2. Yes” to third interview.
- **MOVE-005-D09 — 2026-11-06:** Ordinary menus preserve toggled Run/Sneak selections; Hold controls resume from current eligible input. Autorun cancels. Native loading clears Run/Sneak toggle selections and autorun, starting Walk; application preferences remain saved. User: “3. Yes” to third interview.

- **MOVE-005-D10 — 2026-11-06:** Vanilla encumbrance only restricts adding further weighted items to inventory; it introduces no movement penalty. ITEM owns exact admission/capacity rules. Support mod-defined encumbrance movement penalties/restrictions through explicit integration. User: “1. Yes” with clarification that vanilla only restricts adding weighted items and mods should support movement consequences.
- **MOVE-005-D11 — 2026-11-06:** Sneak is a slower gait independent of crouching; it does not automatically crouch, guarantee concealment or grant Stealth practice. NPC/CHAR determine those outcomes from actual context. User: “2. Yes” to fourth interview.
- **MOVE-005-D12 — 2026-11-06:** Vanilla running uses CHAR-020 fatigue/practice with no additional sprint meter, fixed sprint duration or automatic fatigue-based speed penalty. CHAR owns exhaustion/restrictions. Support optional mod-defined sprint eligibility/resource restrictions, including a sprint meter, without enabling them in vanilla. User: “3. Yes” with request to allow future sprint-meter or other restriction mods.

The complete [MOVE-005 specification](systems/MOVE/MOVE-005.md) is approved — finalized v1 under MOVE-005-A01. Approved MOVE input/arbitration and CHAR activity contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-004 interview decisions

- **MOVE-004-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-004 Draft v1. The [specification](systems/MOVE/MOVE-004.md) is finalized v1. Documented mode compatibility/precedence, transition history, activity attribution, placement, persistence and physics verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-004-D01 — 2026-11-06:** One coordinator selects active movement behavior each physics step. Specialist motors calculate movement but cannot independently move the player outside that coordinated sequence. User: “1. Yes” to first interview.
- **MOVE-004-D02 — 2026-11-06:** Keep posture, transport and restrictions separate from active movement mode; modes explicitly define supported combinations. Crouching is posture, riding transport, paralysis restriction. User: “2. Yes” to first interview.
- **MOVE-004-D03 — 2026-11-06:** Ordinary pause preserves velocity, platform attachment and fall tracking while simulation is suspended. Teleport/load placement uses explicit reset/restoration contracts. Inventory opening cannot erase a fall or grant fall immunity. User: “3. Yes” to first interview.

- **MOVE-004-D04 — 2026-11-06:** Select movement from validated conditions and explicit transition rules, not motor callback order. Unsupported combinations cannot silently run two motors or default to walking. Detailed swimming/levitation/climbing precedence remains with those features. User: “1. Yes” to second interview.
- **MOVE-004-D05 — 2026-11-06:** Separate loss of voluntary movement from physical suspension. Paralysis blocks player-driven movement but gravity, moving platforms and external forces continue unless the responsible effect explicitly says otherwise. Ordinary pause suspends simulation. User: “2. Yes” to second interview.
- **MOVE-004-D06 — 2026-11-06:** Mode handoffs explicitly transfer velocity, platform attachment and fall history, without duplicating jumps, landings, fatigue charges or practice awards. Whether swimming entry, climb grab or levitation cancels a fall remains with those features. User: “3. Yes” to second interview.

- **MOVE-004-D07 — 2026-11-06:** Report resolved mode and actual voluntary movement separately from platform carriage/external pushes, so CHAR does not infer Running from held input or passive carriage. CHAR-020 rates/eligibility remain unchanged. User: “1. Yes” to third interview.
- **MOVE-004-D08 — 2026-11-06:** Teleport/load placement holds release on required geometry/placement readiness rather than arbitrary delay. Holds have ownership and bounded failure/recovery paths; unready collision geometry cannot receive resumed gameplay. Exact checks belong to placement/world owners. User: “2. Yes” to third interview.
- **MOVE-004-D09 — 2026-11-06:** Loss of mode eligibility uses its declared exit transition. Missing required data/components with no valid transition stop unsafe movement and enter explained recovery; no silent teleport, walking fallback or collision bypass. Ordinary ledge departure transitions directly to airborne movement. User: “3. Yes” to third interview.

The complete [MOVE-004 specification](systems/MOVE/MOVE-004.md) is approved — finalized v1 under MOVE-004-A01. Approved CORE suspension and MOVE input contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-003 interview decisions

- **MOVE-003-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-003 Draft v1. The [specification](systems/MOVE/MOVE-003.md) is finalized v1. Documented camera/controller tuning, smoothing, cursor/HUD, aim/gesture and native-pose integration/verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-003-D01 — 2026-11-06:** Permit unrestricted horizontal turning and vertical look just short of +/-90 degrees; ordinary look input produces no camera roll. Exact vertical limit remains a tuning dependency. User: “1. Yes” to first interview.
- **MOVE-003-D02 — 2026-11-06:** Separate mouse/controller look sensitivity, with independently adjustable horizontal/vertical sensitivity and vertical inversion for each device. User: “2. Yes” to first interview.
- **MOVE-003-D03 — 2026-11-06:** Separate adjustable mouse/controller smoothing, fully disableable for both. Mouse smoothing defaults off; controller default strength requires testing. Smoothing must behave consistently across frame rates. User: “3. Yes” to first interview.

- **MOVE-003-D04 — 2026-11-06:** Retain a rebindable toggle between captured look and visible gameplay cursor. Cursor-mode mouse/stick cursor movement does not rotate view; activation targets cursor position. Captured look targets screen center. User: “1. Yes” to second interview.
- **MOVE-003-D05 — 2026-11-06:** Gameplay cursor mode permits movement and does not itself pause the world. HUD controls consume their clicks, preventing activation through them. Menus retain separate CORE pause rules. User: “2. Yes” to second interview.
- **MOVE-003-D06 — 2026-11-06:** Normal attacks allow looking unless a particular attack explicitly uses mouse-motion swing gestures. Reserve that motion for the gesture and stop pending camera smoothing immediately to prevent drift. COMBAT owns gesture-mode selection. User: “3. Yes” to second interview.

- **MOVE-003-D07 — 2026-11-06:** Enter gameplay cursor mode at screen center. Leaving preserves view direction without turning toward the cursor or recapture-motion jumps. Consume toggle input. User: “1. Yes” to third interview.
- **MOVE-003-D08 — 2026-11-06:** Clear pending look motion/smoothing drift on menu entry, focus loss, gameplay cursor entry and explicit facing changes such as teleport/load placement. Resume from actual current facing without stale input. User: “2. Yes” to third interview.
- **MOVE-003-D09 — 2026-11-06:** Activation/aim use the camera's actually shown facing, including chosen smoothing, rather than an unseen future look target. Presentation effects such as head bob cannot independently redirect gameplay aim. COMBAT retains spread/targeting ownership. User: “3. Yes” to third interview.

- **MOVE-003-D10 — 2026-11-06:** Retain rebindable keyboard turn-left/right and look-up/down with adjustable turning rate. Look priority is mouse, then held keyboard look, then controller; opposing keyboard look directions cancel. Do not combine sources for rotation boosts. User: “1. Yes” to fourth interview.
- **MOVE-003-D11 — 2026-11-06:** Ordinary menus temporarily own the cursor and preserve selected gameplay cursor mode on return. Native saves retain actual yaw/pitch, but loading returns to captured look only when gameplay is eligible. Cursor position/smoothing history are not saved. User: “2. Yes” to fourth interview.
- **MOVE-003-D12 — 2026-11-06:** No automatic view leveling during ordinary movement. Provide rebindable Center view, immediately leveling pitch while preserving yaw and clearing smoothing drift. User: “3. Yes” to fourth interview.

The complete [MOVE-003 specification](systems/MOVE/MOVE-003.md) is approved — finalized v1 under MOVE-003-A01. Approved MOVE-001/002 and CORE settings/input contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-002 interview decisions

- **MOVE-002-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-002 Draft v1. The [specification](systems/MOVE/MOVE-002.md) is finalized v1. Documented action/default inventories, modifier transitions, device/axis support, context validation, persistence and verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-002-D01 — 2026-11-06:** Provide two keyboard/mouse bindings and two controller-button bindings per discrete gameplay action, with separate analog movement/look axis assignments. Controller assignments do not displace keyboard/mouse bindings. User: “1. Yes” to first interview.
- **MOVE-002-D02 — 2026-11-06:** For input already assigned to another action in the same active context, show the conflict and offer Replace or Cancel; no silent reassignment. Mutually exclusive contexts may reuse input. User: “2. Yes” to first interview.
- **MOVE-002-D03 — 2026-11-06:** Allow deliberate unbound gameplay actions with a clear warning and preserve that choice across restarts. Retain an independent non-removable way to open the menu and recover/reset controls, preventing customization lockout. User: “3. Yes” to first interview.

- **MOVE-002-D04 — 2026-11-06:** Support single keys/buttons and one modifier plus a key or mouse button for keyboard/mouse. Initial controller bindings use single buttons, excluding controller button combinations. User: “1. Yes” to second interview.
- **MOVE-002-D05 — 2026-11-06:** Stage binding edits until Apply; Cancel discards pending edits. Apply validates and activates the complete set together. Assignment/apply input cannot subsequently trigger gameplay. Runtime persistence failures retain applied controls in memory, explain unsaved status and allow retry under CORE settings contracts. User: “2. Yes” to second interview.
- **MOVE-002-D06 — 2026-11-06:** Use one application-wide custom configuration shared across characters. Reset this action and Reset all controls are staged edits. Multiple named profiles and import/export are outside initial scope. User: “3. Yes” to second interview.

- **MOVE-002-D07 — 2026-11-06:** A modifier combination takes precedence over its plain key binding. Shift+E triggers only the combination; releasing Shift while E remains held cannot start plain E. Release the main key before either can start again. User: “1. Yes” to third interview.
- **MOVE-002-D08 — 2026-11-06:** Capture waits for the opening input to release. Escape/controller Back cancels capture; separate Clear binding deliberately unbinds a slot. Mouse motion/stick drift cannot become button bindings. Reserved recovery inputs remain visible. User: “2. Yes” to third interview.
- **MOVE-002-D09 — 2026-11-06:** Store gameplay keyboard bindings by physical key position and display current-layout labels. Text entry uses the active layout normally. User: “3. Yes” to third interview.

- **MOVE-002-D10 — 2026-11-06:** Controller UI actions, including Confirm/Back, are reassignable separately from gameplay bindings. Check conflicts within UI context and retain independent recovery controls. User: “1. Yes” to fourth interview.
- **MOVE-002-D11 — 2026-11-06:** Reserve keyboard Escape and controller Menu/Start for menu access/control recovery; neither is assignable to gameplay. Escape/controller Back cancels capture; Menu/Start exits capture to the controls screen. User: “2. Yes” to fourth interview.
- **MOVE-002-D12 — 2026-11-06:** Updates preserve existing bindings and deliberate unbound choices. Add a new action's default only if conflict-free; otherwise leave it unbound and show one notice identifying it. Never steal an existing assignment. User: “3. Yes” to fourth interview.

The complete [MOVE-002 specification](systems/MOVE/MOVE-002.md) is approved — finalized v1 under MOVE-002-A01. Approved MOVE-001 and CORE settings/input contracts remain binding; documented dependencies remain open. No implementation is authorized.

## MOVE-001 interview decisions

- **MOVE-001-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize MOVE-001 Draft v1. The [specification](systems/MOVE/MOVE-001.md) is finalized v1. Documented delivery/storage, device arbitration, deadzone tuning, UI, cancellation and persistence integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **MOVE-001-D01 — 2026-11-06:** Support keyboard/mouse and controller from the outset, with switching during play without restart. User: “1. Yes” to first interview.
- **MOVE-001-D02 — 2026-11-06:** Retain brief eligible discrete presses until the next appropriate gameplay update and deliver each once, including press/release between physics steps. Discard pending gameplay presses when menus, focus loss, loading or session changes invalidate their context. This does not introduce combat buffering across cooldowns. User: “2. Yes” to first interview.
- **MOVE-001-D03 — 2026-11-06:** Multiple inputs holding the same action form one logical action; a second overlapping input produces no additional start, and the action ends only after all contributing inputs release. User: “3. Yes” to first interview.

- **MOVE-001-D04 — 2026-11-06:** Opposing directions cancel on each movement axis, including across devices. User: “1. Yes” to second interview.
- **MOVE-001-D05 — 2026-11-06:** Keyboard movement takes priority whenever a direction key is held; otherwise use controller movement beyond its deadzone. Combined device input cannot increase movement speed. User: “2. Yes” to second interview. Interaction between cross-device cancellation and keyboard priority requires clarification.
- **MOVE-001-D06 — 2026-11-06:** Controller disconnection immediately clears its held inputs and cancels unfinished release-triggered actions rather than firing them. Pause if it was actively controlling gameplay and show a reconnect-or-use-keyboard prompt; reconnecting requires fresh discrete presses. User: “3. Yes” to second interview. Exact active-controller criterion remains to be clarified.

- **MOVE-001-D07 — 2026-11-06:** Clarifies D04/D05: keyboard priority takes precedence over cross-device cancellation. While any keyboard movement direction is held, use keyboard movement alone; opposing keyboard keys cancel and suppress stick movement while held. Controller movement applies when no keyboard movement direction is held. Keyboard Forward plus controller Backward therefore moves forward. User: “1. Yes” to third interview.
- **MOVE-001-D08 — 2026-11-06:** Menu entry, focus loss, loading and device disconnection cancel affected unfinished gameplay input rather than report a deliberate release. Input reports cancellation separately; the receiving owner defines charge/activity disposition without firing from cancellation. User: “2. Yes” to third interview.
- **MOVE-001-D09 — 2026-11-06:** Preserve separate eligible rapid taps in order and deliver each once at the next appropriate gameplay update. The receiving feature validates each at that update; rejected presses expire rather than waiting for cooldown. No attack queue across cooldowns is introduced. User: “3. Yes” to third interview.

- **MOVE-001-D10 — 2026-11-06:** Mouse movement takes priority over controller look for that update; do not add stick look to mouse look. Sensitivity/smoothing remain MOVE-003 scope. User: “1. Yes” to fourth interview.
- **MOVE-001-D11 — 2026-11-06:** Provide separately adjustable movement/look deadzones; inside each, input is neutral; outside, retain proportional analog control. Defaults/response curves require controller testing under MOVE-002/003. User: “2. Yes” to fourth interview.
- **MOVE-001-D12 — 2026-11-06:** Active controller means the last device to supply accepted gameplay input. Disconnecting an idle controller while keyboard/mouse is active does not pause. The disconnect prompt owns its suspension reason; explicit Continue after reconnection or choosing keyboard/mouse releases only that reason, requiring fresh discrete presses. User: “3. Yes” to fourth interview.

The complete [MOVE-001 specification](systems/MOVE/MOVE-001.md) is approved — finalized v1 under MOVE-001-A01. Existing CORE-016/017 contracts remain binding; documented dependencies remain open. No implementation is authorized.

## RULE-028 interview decisions

- **RULE-028-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-028 Draft v1. The [specification](systems/RULE/RULE-028.md) is finalized v1. Documented mapping fixtures, calendar/service-priority contracts, clan assignment/fallback schemas and MAGIC/FACT/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-028-D01 — 2026-11-06:** Retain inspected holiday dates/coverage and clan associations as moddable baseline definitions, supporting added regions/holidays/clans via stable IDs/validated references rather than fixed array indices. User: “1. Yes” to first interview.
- **RULE-028-D02 — 2026-11-06:** Require explicit relevant region/calendar date; no silent player-region/region-zero substitution. Valid no-holiday differs from missing required context. User: “2. Yes” to first interview.
- **RULE-028-D03 — 2026-11-06:** Replace unconditional Lyrezi fallback with explicit validated region/default policy; missing mappings fail absent configured fallback. Assigned vampire clans persist across travel/load; assignment timing remains MAGIC/FACT-owned. User: “3. Yes” to first interview.

- **RULE-028-D04 — 2026-11-06:** Return all applicable holidays in deterministic order; services explicitly define benefit applicability/combination. Single-holiday compatibility callers require declared priority rather than incidental definition order. User: “1. Yes” to second interview.
- **RULE-028-D05 — 2026-11-06:** Retain classic dates but support modded holidays on any valid calendar day, including 356–360, with TIME year rollover. Do not keep a blanket day-355 suppression. User: “2. Yes” to second interview.
- **RULE-028-D06 — 2026-11-06:** Clan mapping edits affect future assignments; retain existing identity/required definitions absent explicit migration. Travel/locale/load cannot change clans or replay grants; missing required definitions require recovery, not Lyrezi substitution. User: “3. Yes” to second interview.

The complete [RULE-028 specification](systems/RULE/RULE-028.md) is approved under RULE-028-A01. Calendar/service-priority and MAGIC/FACT/SAVE integration dependencies remain open. No implementation is authorized.

## RULE-027 interview decisions

- **RULE-027-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-027 Draft v1. The [specification](systems/RULE/RULE-027.md) is finalized v1. Documented type/faction/macro fixtures, recipe/localization schemas, assignment timing and LOC/FACT/QUEST/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-027-D01 — 2026-11-06:** Adopt operation-owned DFU-compatible seeded building-name generation, preserving supported part/macro draw order with moddable rules; no unverified DOS parity claim. User: “1. Yes” to first interview.
- **RULE-027-D02 — 2026-11-06:** Supply stable building/location/region/faction identities and explicit seed, using building region rather than current player region. Missing required mappings fail rather than wrong-culture fallback. User: “2. Yes” to first interview.
- **RULE-027-D03 — 2026-11-06:** Retain assigned name identity/components/proprietor values; explicit compatible rendering recipes may localize presentation without reroll/identity change. Literal/custom names remain retained text unless owner defines localization. User: “3. Yes” to first interview.

- **RULE-027-D04 — 2026-11-06:** Retain supported shop/tavern/bank/guild/temple/palace naming patterns as moddable defaults with explicit faction/display mappings, not incidental child order/localized city-name comparison. Added types may supply validated patterns/context. User: “1. Yes” to second interview.
- **RULE-027-D05 — 2026-11-06:** Explicit unnamed buildings are valid; missing required naming data is an error. House-for-sale labels are state presentation, not replacement assigned identity; quest renaming needs LOC/QUEST policy. User: “2. Yes” to second interview.
- **RULE-027-D06 — 2026-11-06:** Bank/pattern edits affect future assignments, preserving existing ones absent explicit migration/rename. Missing retained localization uses approved fallback/recovery, never reroll. Isolated previews cannot overwrite live names. User: “3. Yes” to second interview.

The complete [RULE-027 specification](systems/RULE/RULE-027.md) is approved under RULE-027-A01. Compatibility fixtures, rendering/mapping and LOC/QUEST/SAVE integration dependencies remain open. No implementation is authorized.

## RULE-026 interview decisions

- **RULE-026-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-026 Draft v1. The [specification](systems/RULE/RULE-026.md) is finalized v1. Documented generation-level audit, numeric/table/hook schemas, material/category adapters, diagnostics and SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-026-D01 — 2026-11-06:** Retain moddable level-adjusted 0–255 draw, piecewise offset, 0–256 clamp and exact strict table boundary algorithm. Support validated alternative policies/added materials without silently normalizing legacy table. User: “1. Yes” to first interview.
- **RULE-026-D02 — 2026-11-06:** Require explicit generation level/context, normally actual claimed player level with declared encounter/loot overrides. No silent earned-level/global lookup; retain generated material. User: “2. Yes” to first interview.
- **RULE-026-D03 — 2026-11-06:** Retain independently moddable armor split leather/chain/plate=69/20/11, plate using declared material selector. ITEM validates material/template compatibility; stable IDs replace implicit numeric plate offset. User: “3. Yes” to first interview.

- **RULE-026-D04 — 2026-11-06:** Legacy tables cover all reachable adjusted values 0–256 with valid ordered IDs/safe traversal. Conventional weighted alternatives are supported only with explicit semantics; invalid tables fail instead of iron fallback. User: “1. Yes” to second interview.
- **RULE-026-D05 — 2026-11-06:** Armor category draw precedes plate material draw, which occurs only for plate. Retries retain category/material results rather than reroll. User: “2. Yes” to second interview.
- **RULE-026-D06 — 2026-11-06:** Isolated tooling/diagnostics inspect actual mapped distributions at selected levels without live loot draws; do not normalize legacy table entries into misleading probabilities. User: “3. Yes” to second interview.

The complete [RULE-026 specification](systems/RULE/RULE-026.md) is approved under RULE-026-A01. ITEM/content/numeric and generation/SAVE integration dependencies remain open. No implementation is authorized.

## RULE-025 interview decisions

- **RULE-025-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-025 Draft v1. The [specification](systems/RULE/RULE-025.md) is finalized v1. Documented policy/reason/hook schemas, compatibility/state transitions, quantity/UID/limits and ITEM-005/SAVE migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-025-D01 — 2026-11-06:** Retain ingredients/potions/books/gold/arrows/oil stackable defaults with moddable per-template/type eligibility that can enable or disable, unlike DFU permission-only override. User: “1. Yes” to first interview.
- **RULE-025-D02 — 2026-11-06:** Retain equipped/quest/enchanted exclusions and summoned-arrow exception as moddable defaults. Alternative eligibility requires valid ITEM stacking contracts preserving charges/effects/identities. User: “2. Yes” to first interview.
- **RULE-025-D03 — 2026-11-06:** Separate eligibility from ITEM-005 instance compatibility. Summoned arrows cannot merge with ordinary/incompatible expiration/provenance; template equality alone is insufficient. User: “3. Yes” to first interview.

- **RULE-025-D04 — 2026-11-06:** Eligibility order is type/category defaults, explicit template overrides, then instance-state restrictions. Explicit supported mod contracts may replace restrictions; template permission alone cannot bypass them. Provider conflicts follow RULE-004/DATA-003. User: “1. Yes” to second interview.
- **RULE-025-D05 — 2026-11-06:** Preserve valid saved quantities; policy changes invalidating existing stacks require explicit ITEM/SAVE migration, never query-time silent deletion/merge/split. Limits/splitting/UIDs/quantity conservation remain ITEM-005. User: “2. Yes” to second interview.
- **RULE-025-D06 — 2026-11-06:** Provide inspectable eligible/ineligible reasons/provenance and separate invalid-definition errors. Queries are deterministic/mutation-free; eligibility alone authorizes no transfer/equip/use. User: “3. Yes” to second interview.

The complete [RULE-025 specification](systems/RULE/RULE-025.md) is approved under RULE-025-A01. ITEM-005 compatibility/quantity and SAVE migration dependencies remain open. No implementation is authorized.

## RULE-024 interview decisions

- **RULE-024-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-024 Draft v1. The [specification](systems/RULE/RULE-024.md) is finalized v1. Documented numeric/mod domains, service/calendar adapters, accepted-term/SAVE integration and explicit FACT/MAGIC temple-blessing deferral remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-024-D01 — 2026-11-06:** Retain moddable loan cap actual level×50,000, repayment principal+10%, summoning fee 200,000−1,000×summoner reputation and chance 30+Daedra reputation+bonus. Use safe explicit inputs and RULE-001; eligibility/deadlines/legal and failed-summon payment remain owners' rules. User: “1. Yes” to first interview.
- **RULE-024-D02 — 2026-11-06:** Retain moddable room rate 7 gold/day with explicit eligible free-holiday-day counting across year boundaries instead of narrow day-46 test. Free days survive bargaining/minima. User: “2. Yes” to first interview.
- **RULE-024-D03 — 2026-11-06:** Temple blessing helper is incomplete reference; defer real amount/duration/eligibility/effects to FACT/MAGIC rather than approve constant 1. Future supported formula should be moddable. User: “3. Yes” to first interview.

- **RULE-024-D04 — 2026-11-06:** Repayment=principal+trunc(principal×rate), default exact 10%, with positive principal/nonnegative valid rate. Regional variation requires explicit mod policy; no unsafe floating surprises. User: “1. Yes” to second interview.
- **RULE-024-D05 — 2026-11-06:** Valid negative computed summoning fee normalizes to zero; chance saturates 0–100 under RULE-001 with moddable limits. Free quote does not bypass eligibility; malformed/overflowing inputs fail. User: “2. Yes” to second interview.
- **RULE-024-D06 — 2026-11-06:** Rental n>=1 covers n consecutive calendar-day slots from declared rental date, charging only nonfree slots, including multiple eligible holidays/year crossings. Checkout/entitlement remain ECON/TIME policy. User: “3. Yes” to second interview.

The complete [RULE-024 specification](systems/RULE/RULE-024.md) is approved under RULE-024-A01. ECON/LAW/FACT/MAGIC/TIME integration and temple-blessing design remain open. No implementation is authorized.

## RULE-023 interview decisions

- **RULE-023-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-023 Draft v1. The [specification](systems/RULE/RULE-023.md) is finalized v1. Documented benefit/calendar adapters, numeric/hook domains, free-outcome provenance, batch/job and ECON/ITEM/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-023-D01 — 2026-11-06:** Retain distinct moddable repair fee/duration and identification formulas/order, guild/holiday policies and RULE-004 hooks. Default repair fee is damage-independent; support explicit modded condition-dependent fee. User: “1. Yes” to first interview.
- **RULE-023-D02 — 2026-11-06:** Full-condition repair/already-identified identification return no-service-needed without payment/new job. Full repair duration is zero, not the generic damaged-item minimum. User: “2. Yes” to first interview.
- **RULE-023-D03 — 2026-11-06:** Supply explicit merchant region/quality, valid item value/condition, guild benefit and calendar context. Intentional no benefit differs from missing data; RULE-021 context and RULE-022 readiness apply where regional pricing participates. User: “3. Yes” to first interview.

- **RULE-023-D04 — 2026-11-06:** Preserve explicit guild/holiday free service and identification fees rounding to zero without ordinary purchase minimum. Paid repairs follow bargaining/minimum; explicit free repair remains free. Zero fee does not bypass eligibility. User: “1. Yes” to second interview.
- **RULE-023-D05 — 2026-11-06:** Require maximum condition>0 and 0<=current<=maximum; duration uses raw missing condition units, default one-day damaged-item minimum moddable. Invalid condition fails rather than free/instant repair. User: “2. Yes” to second interview.
- **RULE-023-D06 — 2026-11-06:** Retain accepted repair price/scheduled completion terms against later price/guild/settings changes. New/changed quotes require renewed acceptance; batch workload changes need explicit ECON/ITEM policy, not hidden job rewrites. User: “3. Yes” to second interview.

The complete [RULE-023 specification](systems/RULE/RULE-023.md) is approved under RULE-023-A01. Guild/holiday, batch and ECON/ITEM/SAVE integration dependencies remain open. No implementation is authorized.

## RULE-022 interview decisions

- **RULE-022-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-022 Draft v1. The [specification](systems/RULE/RULE-022.md) is finalized v1. Documented political/mapping schemas, FACT/TIME boundary/feedback semantics, numeric/work limits, coherent daily settlement, quote readiness and SAVE migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-022-D01 — 2026-11-06:** Retain initial uniform 750–1250 thousandths and per-step political/price-feedback rise chance, 51/50 rise or 49/50 fall, bounds 250–4000 as moddable baselines/hooks. Use owned economy randomness. User: “1. Yes” to first interview.
- **RULE-022-D02 — 2026-11-06:** Derive mutually exclusive low/normal/high from committed multiplier, clearing contradictory flags; thresholds moddable. Default low<500, high>2000, equality normal. User: “2. Yes” to first interview.
- **RULE-022-D03 — 2026-11-06:** Require explicit merchant/regional-power mappings or declared alternative pricing policy. Added regions declare inputs; missing data/technical failure cannot silently skip a completed unchanged update. User: “3. Yes” to first interview.

- **RULE-022-D04 — 2026-11-06:** Update once per completed game-day boundary including elapsed rest/travel days; cadence moddable. Preserve stepwise evolution, bound catch-up work per pass and retain pending steps instead of approximating/dropping them. User: “1. Yes” to second interview.
- **RULE-022-D05 — 2026-11-06:** Catch-up is day-major across a declared stable region order, with each day's political inputs at explicit FACT/TIME boundary. This replaces DFU region-major catch-up; exact feedback timing remains joint owner contract. User: “2. Yes” to second interview.
- **RULE-022-D06 — 2026-11-06:** Save committed multipliers/completed boundaries/required pending progress; never rerandomize initialized regions on load. Added regions require explicit initialization/migration; retries retain daily rolls and future unresolved steps may use fresh RULE-003 economy sources. User: “3. Yes” to second interview.

- **RULE-022-D07 — 2026-11-06:** Rise score uses RULE-001 integer percentages/saturation and one draw including guarantees. Preserve separate toward-zero political/price-feedback division and truncate positive rise/fall multiplication before bounds. User: “1. Yes” to third interview.
- **RULE-022-D08 — 2026-11-06:** Publish completed day's multipliers/flags coherently. Required pending catch-up blocks affected new trade commitments from stale/partial prices; refresh quotes with renewed acceptance per RULE-021. Committed trades unchanged; failed definitions/flags cannot complete day. User: “2. Yes” to third interview.

The complete [RULE-022 specification](systems/RULE/RULE-022.md) is approved under RULE-022-A01. FACT/TIME political boundaries and ECON/SAVE integration dependencies remain open. No implementation is authorized.

## RULE-021 interview decisions

- **RULE-021-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-021 Draft v1. The [specification](systems/RULE/RULE-021.md) is finalized v1. Documented arithmetic/caller fixtures, domains, condition/hook schemas, merchant-region/service adapters and quote/settlement/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-021-D01 — 2026-11-06:** Retain staged base valuation and separate buy/sell fixed-point baselines as moddable, preserving integer division/shift rounding with validated region/quality/bargaining parameters and RULE-004 hooks. User: “1. Yes” to first interview.
- **RULE-021-D02 — 2026-11-06:** Default trade valuation ignores condition, with explicit supported modded condition-price policy. Repair is separate; a condition argument alone does not imply price adjustment. User: “2. Yes” to first interview.
- **RULE-021-D03 — 2026-11-06:** Use current live Mercantile/Personality with explicit extended-value handling and nonnegative final prices. Overflow/invalid context fail rather than reverse payments through negative prices. User: “3. Yes” to first interview.

- **RULE-021-D04 — 2026-11-06:** Eligible nonempty ordinary purchase minimum is 1 gold; resale may quote zero explicitly before confirmation. Minima independently moddable; free/gift policies separate and invalid/empty baskets incur no minimum charge. User: “1. Yes” to second interview.
- **RULE-021-D05 — 2026-11-06:** Supply explicit merchant-region context or explicitly authorized neutral multiplier 1.0. Missing required region fails rather than silently bypassing; remote merchants use declared context. User: “2. Yes” to second interview.
- **RULE-021-D06 — 2026-11-06:** Order is per-unit base valuation, quantity multiplication, basket sum, buy/sell bargaining, final minimum. Separate transactions can round differently; ECON owns stack/settlement and shared evaluated basket. User: “3. Yes” to second interview.

- **RULE-021-D07 — 2026-11-06:** Use supported live stats without hidden 100 caps, safe declared bargaining arithmetic, then normalize negative computed quote to zero before direction-specific minimum. Invalid definitions/overflow still fail; mod curves supported. User: “1. Yes” to third interview.
- **RULE-021-D08 — 2026-11-06:** Provide inspectable region/quality/bargaining/condition/minimum breakdowns and revalidate before settlement. Changed final amount requires new quote/renewed acceptance; inspection spends nothing/awards no Mercantile practice. User: “2. Yes” to third interview.

The complete [RULE-021 specification](systems/RULE/RULE-021.md) is approved under RULE-021-A01. Regional-state and ECON transaction integration dependencies remain open. No implementation is authorized.

## RULE-020 interview decisions

- **RULE-020-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-020 Draft v1. The [specification](systems/RULE/RULE-020.md) is finalized v1. Documented context routing, opportunity identities, numeric/hook domains, source purposes, placement/retry and NPC/TIME/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-020-D01 — 2026-11-06:** Retain independently moddable location-night 1/24, wilderness-day 1/36, wilderness-night 1/24 and alerted-dungeon 1/36 probabilities as exact rational odds, supporting explicit added contexts and RULE-004 hooks. User: “1. Yes” to first interview.
- **RULE-020-D02 — 2026-11-06:** Dungeon enemy-alert prerequisite remains baseline and moddable. Blocked gates consume no draw; missing required context is an error rather than assumed unalerted. User: “2. Yes” to first interview.
- **RULE-020-D03 — 2026-11-06:** Return explicit passed/failed/ineligible gate result rather than spawn directly. NPC/TIME own cadence/eligibility/selection/placement/caps; gate success is not actor/encounter activation. User: “3. Yes” to first interview.

- **RULE-020-D04 — 2026-11-06:** Use validated integer odds a/b, b>0 and 0<=a<=b, uniform roll 0..b−1, pass iff roll<a. Eligible 0/100% consumes one logical draw; ineligible consumes none. User: “1. Yes” to second interview.
- **RULE-020-D05 — 2026-11-06:** Retain one gate result per owner-identified opportunity through technical retries. Placement failure cannot silently reroll; NPC owns retry/abandon/new-opportunity policy. User: “2. Yes” to second interview.
- **RULE-020-D06 — 2026-11-06:** Diagnostics distinguish context/eligibility/exact per-check odds/retained roll/result from later placement outcome, without per-check player popups or unjustified hourly-rate labels. User: “3. Yes” to second interview.

The complete [RULE-020 specification](systems/RULE/RULE-020.md) is approved under RULE-020-A01. NPC/TIME scheduling/placement and persistence dependencies remain open. No implementation is authorized.

## RULE-019 interview decisions

- **RULE-019-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-019 Draft v1. The [specification](systems/RULE/RULE-019.md) is finalized v1. Documented mappings/weight adapters, numeric/hook domains, health construction, language-effect stacking and NPC/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-019-D01 — 2026-11-06:** Retain inspected enemy group/language/weight mappings as moddable definitions with explicit added-creature mappings and intentional no-group/no-language states distinct from missing required data. User: “1. Yes” to first interview.
- **RULE-019-D02 — 2026-11-06:** Retain moddable enemy-class health 10+sum of level independent inclusive 1..class-HP rolls, assigned once on creation and preserved across saves rather than rerolled on viewing/loading. Separate from player growth. User: “2. Yes” to first interview.
- **RULE-019-D03 — 2026-11-06:** Retain both pacification formula branches and uniform 200-outcome scale, with moddable coefficients, sheathed/drawn adjustment and effect contribution. Preserve half-percent precision; NPC authorizes attempts separately. User: “3. Yes” to first interview.

- **RULE-019-D04 — 2026-11-06:** Weight baseline is monster-defined base or humanoid 240 female/350 otherwise, plus trunc(total carried kg×4) classic units; all moddable with explicit units/mappings and supported alternate body definitions. User: “1. Yes” to second interview.
- **RULE-019-D05 — 2026-11-06:** Baseline enemy-class level and HP-per-level are supported integers>=1, validated before draws. Level-zero/alternative health requires explicit policy. Singleton ranges consume one logical draw per level. User: “2. Yes” to second interview.
- **RULE-019-D06 — 2026-11-06:** Clamp resolved pacification score to 0–200; draw one uniform integer 0–199 and succeed iff roll<score, including draws for guarantees. Preserve half-percent precision without integer-percent rounding or bypassing NPC eligibility. User: “3. Yes” to second interview.

The complete [RULE-019 specification](systems/RULE/RULE-019.md) is approved under RULE-019-A01. Mapping, numeric-domain and NPC/COMBAT/SAVE integration dependencies remain open. No implementation is authorized.

## RULE-018 interview decisions

- **RULE-018-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-018 Draft v1. The [specification](systems/RULE/RULE-018.md) is finalized v1. Documented coefficient/fixed-cost/classic fixtures, numeric/mod schemas, context/material adapters, quote/commit and SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-018-D01 — 2026-11-06:** Retain distinct effect/spell/classic-item/capacity cost models as moddable baselines, including component coefficients, target multipliers, casting minimum and material capacity tables, with supported RULE-004 hooks. Gold basis is not automatically final merchant price. User: “1. Yes” to first interview.
- **RULE-018-D02 — 2026-11-06:** Explicit empty drafts are zero-cost but uncastable. Unknown/missing required effects fail rather than cost zero; nonempty blank-slot arrays are not valid spells through the minimum floor. User: “2. Yes” to first interview.
- **RULE-018-D03 — 2026-11-06:** Use live school skill with baseline nonnegative reduction max(0,110−skill), preserving final configured spell minimum. Reduction curve is moddable; negative costs cannot grant magicka/money. User: “3. Yes” to first interview.

- **RULE-018-D04 — 2026-11-06:** Preserve staged rounding: supported component arithmetic, per-effect casting cost, sum, target multiplier, then final minimum. Magnitude uses integer average rather than a roll; do not round only once at end. User: “1. Yes” to second interview.
- **RULE-018-D05 — 2026-11-06:** Retain explicit owner-authorized forced-minimum casting mode with moddable eligibility, unchanged gold basis and normal reflection/absorption valuation rather than automatic discount inheritance. User: “2. Yes” to second interview.
- **RULE-018-D06 — 2026-11-06:** Capacity=base+floor(base×material modifier), with valid zero and explicit rejection of negative/nonfinite/overflowing capacity/unknown required materials. Other item categories use declared base unless explicit scaling policy applies. Durability/charges/capacity remain distinct. User: “3. Yes” to second interview.

- **RULE-018-D07 — 2026-11-06:** Valid effects with no scalable duration/chance/magnitude use explicit moddable fixed-cost definitions retaining DFU-equivalent baseline. No components does not mean missing definition/free effect. User: “1. Yes” to third interview.
- **RULE-018-D08 — 2026-11-06:** Retain moddable separate classic coefficient/mapping cost model, item-enchanting reference skill 50 and enchantment points=10×classic casting cost. Unsupported IDs/malformed records fail; new effects require declared mappings rather than guessed indices. User: “2. Yes” to third interview.
- **RULE-018-D09 — 2026-11-06:** Provide shared inspectable breakdowns of effects, skill reduction, targeting, minimum/special mode and capacity usage. Revalidate before commitment; previews spend nothing and MAGIC/ITEM/ECON own atomic operations. User: “3. Yes” to third interview.

The complete [RULE-018 specification](systems/RULE/RULE-018.md) is approved under RULE-018-A01. Cost mappings, numeric domains and MAGIC/ITEM/ECON integration dependencies remain open. No implementation is authorized.

## RULE-017 interview decisions

- **RULE-017-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-017 Draft v1. The [specification](systems/RULE/RULE-017.md) is finalized v1. Documented effect mappings, binary/scalable contracts, numeric/mod domains, application/tick identity and SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-017-D01 — 2026-11-06:** Retain cancellation/partial-scaling baseline with moddable parameters/hooks. Saving throw returns retained payload percentage, not success probability; exact successful-roll boundary can retain full payload. User: “1. Yes” to first interview.
- **RULE-017-D02 — 2026-11-06:** Retain moddable pre-Willpower immunity threshold: race/career/biography/caller score>=100 cancels before adding Willpower. Later baseline score clamps 5–95, so Willpower alone does not grant guaranteed immunity. User: “2. Yes” to first interview.
- **RULE-017-D03 — 2026-11-06:** Payload interpretation is explicit per effect. Numeric damage/duration may scale/truncate; binary effects require declared cancellation/application policy, not automatic partial statuses or extra rolls. User: “3. Yes” to first interview.

- **RULE-017-D04 — 2026-11-06:** Combine matching career tolerance kinds once each: Immune +50, Resistant +25, Low Tolerance −25, Critical Weakness −50, with moddable values/composition rather than automatic immunity dominance. User: “1. Yes” to second interview.
- **RULE-017-D05 — 2026-11-06:** Applicable granted magical elemental resistance makes an initial RULE-001 cancellation check using owner-resolved chance; success stops, failure proceeds to normal save. Owner stacking remains separate. User: “2. Yes” to second interview.
- **RULE-017-D06 — 2026-11-06:** Resolve and retain one percentage per effect application, shared by its numeric fields/diagnostics/technical retries. Separate spell effects may save separately; repeated-tick saves require explicit MAGIC policy. User: “3. Yes” to second interview.

- **RULE-017-D07 — 2026-11-06:** Baseline racial order is resistance +30, immunity sets score=100, low tolerance −25, critical weakness −50, then career/biography/caller adjustments. Values/composition are moddable; descriptions explain offsets to immunity before threshold. User: “1. Yes” to third interview.
- **RULE-017-D08 — 2026-11-06:** Numeric scaling uses safe trunc(original amount×retained percentage/100), no implicit minimum one. Owner-specific minima require explicit rules. Missing required effect/element context fails rather than silently bypassing saves. User: “2. Yes” to third interview.
- **RULE-017-D09 — 2026-11-06:** Provide inspectable cancellation/partial/full reasons, nonrandom previews and optional percentage details. Distinguish resistance chance from retained amount; diagnostics reuse retained rolls/margins. User: “3. Yes” to third interview.

The complete [RULE-017 specification](systems/RULE/RULE-017.md) is approved under RULE-017-A01. MAGIC mapping/binary-policy and integration dependencies remain open. No implementation is authorized.

## RULE-016 interview decisions

- **RULE-016-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-016 Draft v1. The [specification](systems/RULE/RULE-016.md) is finalized v1, including configurable creature-effect frequency. Documented phase aggregation, early-death handling, poison settlement, frequency semantics, artifact and SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-016-D01 — 2026-11-06:** Use explicit owner-controlled effect phases separate from mutation-free damage calculations/previews. COMBAT coordinates ITEM/MAGIC mutations; triggers/policies and supported hooks are moddable. User: “1. Yes” to first interview.
- **RULE-016-D02 — 2026-11-06:** Default weapon poison, monster on-hit effects and equipment wear require positive resolved physical damage before current-health saturation, not actual health loss. Misses/material failures/zero damage do not trigger by default; trigger policies are moddable. User: “2. Yes” to first interview.
- **RULE-016-D03 — 2026-11-06:** Consume poison coating once when an eligible positive-hit poison attempt settles, including immunity/resistance rejection. Invalid context/services or technical failure cannot silently consume it; attempt/consumption require coherent owner settlement. Policy is moddable. User: “3. Yes” to first interview.

- **RULE-016-D04 — 2026-11-06:** Baseline wear affects weapon and covering shield instead of selected-part armor; unarmed/natural attacks cause no baseline equipment wear. Routing is moddable and shield coverage explicit. User: “1. Yes” to second interview.
- **RULE-016-D05 — 2026-11-06:** Wear is trunc((10×resolved damage+50)/100), with independent 20% chance of one when zero, per affected item. Coefficients/chance are moddable. Critical/backstab may scale wear amount but never repeat application. User: “2. Yes” to second interview.
- **RULE-016-D06 — 2026-11-06:** Use explicit moddable creature-effect definitions with at-most-once effect attempts per eligible positive component; damage-scaled effects use final resolved component damage, not duplicated critical attempt counts. Probability/resistance/infection remain MAGIC/NPC contracts. User: “3. Yes, but it would be nice to also be able to change the frequency of those particular attacks, so every attack from a monster with an effect doesn't have to use that on every single attempt, if that makes sense.” Configurable per-effect activation frequency is explicitly required; detailed policies remain under discussion.

- **RULE-016-D07 — 2026-11-06:** Support per-creature/effect activation chance, cooldown and/or every-Nth eligible-hit controls with explicit combination semantics. Default qualifying units are positive-damage components; NPC special-attack selection before contact remains separate. User: “1. Yes” to third interview.
- **RULE-016-D08 — 2026-11-06:** Reactive artifacts have moddable trigger/attacker/scaling/source-item cost contracts. Ring of Namira defaults to positive resolved incoming damage with validated actual attacker/equipped source item. Exact factors remain MAGIC/ITEM review. User: “2. Yes” to third interview.
- **RULE-016-D09 — 2026-11-06:** Baseline phases are damage resolution→poison/monster payload settlement→equipment wear→primary health damage→reactive payloads. Use explicit live checks/exactly-once tracking and safe invalidation/recovery; reactive damage cannot recursively trigger itself without an explicit bounded rule. Supported phase changes must be explicit. User: “3. Yes” to third interview.

The complete [RULE-016 specification](systems/RULE/RULE-016.md) is approved under RULE-016-A01. Per-effect control semantics and COMBAT/ITEM/MAGIC integration dependencies remain open. No implementation is authorized.

## RULE-015 interview decisions

- **RULE-015-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-015 Draft v1. The [specification](systems/RULE/RULE-015.md) is finalized v1. Documented numeric/hook domains, attack/cooldown phases, elapsed adapters, scheduling and COMBAT/AV/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-015-D01 — 2026-11-06:** Retain melee-frame interval 3×(115−live Speed)/980 seconds and bow cooldown (10×(100−live Speed)+800)/980 seconds as moddable baselines, including supported weapon/handedness timing hooks. COMBAT/AV own commitment, frames and release. User: “1. Yes” to first interview.
- **RULE-015-D02 — 2026-11-06:** Enforce separate validated configurable positive minima for calculated melee frame intervals and bow cooldowns, preventing zero/negative durations at extended Speed. Vanilla minima remain to be chosen. User: “2. Yes” to first interview.
- **RULE-015-D03 — 2026-11-06:** Retain pass-through weapon accuracy/damage hooks at approved stages: accuracy before RULE-013 resolution and weapon damage before RULE-014 backstab/critical. Mods may use declared timing; vanilla gains no new timing-based bonus. User: “3. Yes” to first interview.

- **RULE-015-D04 — 2026-11-06:** Vanilla melee-frame minimum is 1/60 second and bow-cooldown minimum 0.1 second, separately moddable. They do not affect vanilla Speed 0–100 formulas or imply a 60 Hz simulation requirement. User: “1. Yes” to second interview.
- **RULE-015-D05 — 2026-11-06:** Capture live Speed, weapon context and timing parameters at attack start; retain frame interval/resulting cooldown for that attack. Later buffs/equipment changes do not rewrite its schedule. User: “2. Yes” to second interview.
- **RULE-015-D06 — 2026-11-06:** Attack elapsed time uses authorized gameplay time excluding pauses/loading, explicitly converted to milliseconds for timing hooks. Frame/UI/wall-clock delays do not improve results; exact bow phases remain COMBAT-owned. User: “3. Yes” to second interview.

The complete [RULE-015 specification](systems/RULE/RULE-015.md) is approved under RULE-015-A01. COMBAT/AV timing-phase and persistence integration dependencies remain open. No implementation is authorized.

## RULE-014 interview decisions

- **RULE-014-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-014 Draft v1. The [specification](systems/RULE/RULE-014.md) is finalized v1, including optional critical damage integration and mod-extensible creature weapon/material strengths and weaknesses. Documented adapters, numeric/hook domains, creature-policy composition, phased effects and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-014-D01 — 2026-11-06:** Retain route-specific baseline damage calculations/order with moddable parameters and explicit hooks; special-target rules such as skeletal-warrior edged/silver adjustments are explicit moddable policies. User: “1. Yes” to first interview.
- **RULE-014-D02 — 2026-11-06:** Successful hits may deal zero damage. Final minimum is moddable, default zero; misses/material blocks/invalid attacks remain distinct and receive no minimum wound. User: “2. Yes” to first interview.
- **RULE-014-D03 — 2026-11-06:** Enabled critical damage multiplies successful component's nonnegative damage after ordinary bonuses/backstab, rounds down, and uses a validated configurable multiplier with mod preset ×2. Vanilla remains accuracy-only. Backstab ×3 and critical ×2 compose to ×6, without repeated poison/enchantment/equipment applications. User: “3. Yes” to first interview.

- **RULE-014-D04 — 2026-11-06:** Baseline hand-to-hand endpoints are trunc(live skill/10)+1 and trunc(skill/5)+1, each limited to at least 1 before rolling, with moddable parameters. Later penalties may reduce final damage to zero. User: “1. Yes” to second interview.
- **RULE-014-D05 — 2026-11-06:** Owner-qualified backstab contributes live Backstabbing accuracy; after hit, a separate skill-percent check occurs only when skill>1 and successful damage multiplier is ×3. Threshold, bonus and multiplier are moddable; eligibility/practice remain owners' rules. User: “2. Yes” to second interview.
- **RULE-014-D06 — 2026-11-06:** Clamp each successful monster component nonnegative after ordinary modifiers and before critical multiplication/summing. A penalty cannot reduce earlier components' damage; missed components remain zero without positive minimum. This deliberately differs from DFU aggregate penalty behavior. User: “3. Yes” to second interview.

- **RULE-014-D07 — 2026-11-06:** Apply configured final minimum per successful hit/component after backstab/critical, then sum monster components. Vanilla minimum zero; failed gates/misses/ineffective material get no positive minimum. User: “1. Yes” to third interview.
- **RULE-014-D08 — 2026-11-06:** Preserve skeletal-warrior edged halving toward zero then silver doubling before Strength/material additions, using validated category tags and explicit policy factors/order. Mods must be able to add similar weapon-type/material strengths and weaknesses to more creatures. User: “2. Yes, and make it possible for mods to add more creatures to have similar strengths and weaknesses to specific weapon types and different materials.”
- **RULE-014-D09 — 2026-11-06:** Damage previews show ranges/conditional backstab/critical results without draws/effects. Resolved diagnostics show actual rolls/stages; inspection consumes no combat randomness/practice/hit effects. User: “3. Yes” to third interview.

The complete [RULE-014 specification](systems/RULE/RULE-014.md) is approved under RULE-014-A01. Creature-policy composition and combat/effect integration dependencies remain open. No implementation is authorized.

## RULE-013 interview decisions

- **RULE-013-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-013 Draft v1. The [specification](systems/RULE/RULE-013.md) is finalized v1, including required support for critical damage mods reusing retained critical results. Documented numeric/hook domains, armor/part adapters, phased state, RULE-014 multiplier/stage/rounding and SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-013-D01 — 2026-11-06:** Retain inspected accuracy baseline with moddable components/limits through validated parameters and RULE-004 hooks. Limits may lie within 0–100; invalid attacks/ineffective material remain separate from random misses. User: “1. Yes” to first interview.
- **RULE-013-D02 — 2026-11-06:** Retain weighted body-part baseline as a moddable table using stable IDs, nonnegative weights and positive total. Selection is probabilistic rather than automatically aimed from visual contact. User: “2. Yes” to first interview.
- **RULE-013-D03 — 2026-11-06:** Retain one body part per attack operation shared across monster components, with supported modded per-component selection. Select after route/material eligibility; inactive slots trigger no additional body-part draws. User: “3. Yes” to first interview.

- **RULE-013-D04 — 2026-11-06:** Retain separate live Critical Strike percentile check, adding trunc(skill/10) accuracy on success, with moddable parameters and one critical check per component reaching hit resolution. User: “1. Yes, but keep in mind a mod to make critical strike actually multiply damage not just accuracy will definitely be an early one, so make that possible.” Explicit support for a critical damage-multiplier extension is required; baseline remains accuracy-only and RULE-014 integration needs a declared contract.
- **RULE-013-D05 — 2026-11-06:** Preserve separate toward-zero integer divisions for Luck difference/10, Agility difference/10 and target Dodging/4 using safe arithmetic; do not also add RULE-005's displayed agility modifier. User: “2. Yes” to second interview.
- **RULE-013-D06 — 2026-11-06:** Adrenaline activates at current health<floor(effective max health/8); attacker bonus +5 or improved +8, defender qualification subtracts its amount. Threshold/bonuses are moddable; equality does not activate. User: “3. Yes” to second interview.

- **RULE-013-D07 — 2026-11-06:** Critical mods may replace accuracy benefit with damage multiplication or explicitly enable both, reusing the same retained critical result without a second roll. Damage benefit requires a subsequent hit; multiplier/stage/rounding require RULE-014 contract. User: “1. Yes” to third interview.
- **RULE-013-D08 — 2026-11-06:** Draw order is body part→critical→final hit. Monster shared part precedes component gates; each passed gate gets its own critical/hit checks. Modded per-component part selection occurs only after gate success. User: “2. Yes” to third interview.
- **RULE-013-D09 — 2026-11-06:** Accuracy previews use conditional no-critical/critical branches or clearly labelled estimates without drawing. Resolved diagnostics expose retained critical result/final chance; inspection never decides an attack. User: “3. Yes” to third interview.

The complete [RULE-013 specification](systems/RULE/RULE-013.md) is approved under RULE-013-A01. RULE-014 critical-damage integration and combat/equipment contracts remain open. No implementation is authorized.

## RULE-012 interview decisions

- **RULE-012-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-012 Draft v1. The [specification](systems/RULE/RULE-012.md) is finalized v1. Documented model/material adapters, hook domains, component/source ordering, hit/damage/effect boundaries, termination and SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-012-D01 — 2026-11-06:** Retain enemy preference for natural attacks when the first natural range has strictly greater unmodified integer average than weapon base damage; ties retain weapon. Make route-choice policy moddable. User: “1. Yes” to first interview.
- **RULE-012-D02 — 2026-11-06:** Retain selected-weapon minimum-material eligibility, with moddable target requirements and supported eligibility hook; failure is ineffective material rather than random miss. Unarmed attacks normally bypass this gate, with bypass behavior moddable as well. User: “2. Yes, and unarmed attacks normally bypass these, but I'd like that moddable as well” to first interview.
- **RULE-012-D03 — 2026-11-06:** Retain three ordered monster natural-attack slots as vanilla baseline, each with its own preliminary reflex gate and later hit check; support validated modded component lists with explicit ordering/draw/effect behavior rather than one combined hit roll. User: “3. Yes” to first interview.

- **RULE-012-D04 — 2026-11-06:** Choose route before material eligibility. A chosen ineffective weapon stops with that outcome, without automatic natural fallback/second attempt. Explicit mod selection policies may differ. User: “1. Yes” to second interview.
- **RULE-012-D05 — 2026-11-06:** Baseline average comparison uses floor((minimum+maximum)/2) on valid nonnegative ranges, first natural component only, without Strength/enchantments/armor/material adjustments. User: “2. Yes” to second interview.
- **RULE-012-D06 — 2026-11-06:** Absent vanilla components are explicitly inactive and skipped without draws. Active components require positive minimum damage and maximum>=minimum. This deliberately removes DFU preliminary draws for empty slots. User: “3. Yes” to second interview.

- **RULE-012-D07 — 2026-11-06:** Disabling unarmed/natural material bypass requires explicit material-equivalent data or an eligibility rule validated before play. Missing data cannot silently imply immunity or permission. User: “1. Yes” to third interview.
- **RULE-012-D08 — 2026-11-06:** Each active monster component resolves reflex gate first, hit check only after gate success, damage only after a hit. Use RULE-001 and owned combat randomness instead of classic remainder-biased gates. User: “2. Yes” to third interview.
- **RULE-012-D09 — 2026-11-06:** Gate failure or miss does not cancel later active components. Process declared order; COMBAT owns termination for death/invalid targets/interruption and exactly-once effects. Body-part/damage details remain RULE-013/014 scope. User: “3. Yes” to third interview.

The complete [RULE-012 specification](systems/RULE/RULE-012.md) is approved under RULE-012-A01. Hit/damage/effect and COMBAT/NPC/ITEM integration dependencies remain open. No implementation is authorized.

## RULE-011 interview decisions

- **RULE-011-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-011 Draft v1. The [specification](systems/RULE/RULE-011.md) is finalized v1. Documented numeric/hook domains, unit conversion, racial/effect resolution, NPC/MOVE cadence/source contracts, UI and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-011-D01 — 2026-11-06:** Retain both stealth/climbing formula baselines with validated parameter customization and explicit RULE-004 hooks. Preserve stealth distance quantization and climbing modifier order unless an approved override changes them. User: “1. Yes” to first interview.
- **RULE-011-D02 — 2026-11-06:** Keep climbing's intermediate effective-skill 5–95 limit distinct from final probability and make intermediate limits moddable. Final RULE-001 0–100 handling permits guarantees rather than another universal 95% ceiling. User: “2. Yes” to first interview.
- **RULE-011-D03 — 2026-11-06:** Sample current live hiding-actor Stealth, climber Climbing/Luck, distance and resolved racial/effect context at each authorized check. Resolve once/reuse results; inspection/rendering cannot create checks. User: “3. Yes” to first interview.

- **RULE-011-D04 — 2026-11-06:** Stealth baseline is 2×floor(trunc(distance/classic scale)×live Stealth/1024), preserving distance quantization/signed-shift behavior with safe arithmetic. RULE-001 saturates negative chances to zero. User: “1. Yes” to second interview.
- **RULE-011-D05 — 2026-11-06:** Baseline climbing Luck bonus remains 0–10, including valid above-100 Luck. Truncate final raw climbing chance toward zero before RULE-001 resolution. Luck parameters are moddable. User: “2. Yes” to second interview.
- **RULE-011-D06 — 2026-11-06:** Provide inspectable explanations/optional exact percentages labelled remaining hidden for this check or passing this climbing check, without mandatory per-check popups. Success neither grants invisibility nor overrides surface/movement restrictions. User: “3. Yes” to second interview.

The complete [RULE-011 specification](systems/RULE/RULE-011.md) is approved under RULE-011-A01. NPC/MOVE/MAGIC eligibility, cadence and consequences remain owner-reviewed dependencies. No implementation is authorized.

## RULE-010 interview decisions

- **RULE-010-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-010 Draft v1. The [specification](systems/RULE/RULE-010.md) is finalized v1. Documented numeric/hook domains, target/basket adapters, count policies, UI and interaction/legal/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-010-D01 — 2026-11-06:** Retain separate pickpocket-success and shoplifting-detection baseline models, both moddable through validated coefficients/offsets and explicit RULE-004 replacement hooks. Contracts explicitly identify success versus detection polarity. User: “1. Yes” to first interview.
- **RULE-010-D02 — 2026-11-06:** Retain independently moddable vanilla 5–95% limits, with validated limits anywhere within 0–100 and eligibility checked before rolling. User: “2. Yes” to first interview.
- **RULE-010-D03 — 2026-11-06:** Use live Pickpocket and actual claimed player level. Apply level difference only to targets explicitly supplying the model's enemy-level context; other supported targets use the skill-only baseline. Missing required data cannot silently select an easier model. User: “3. Yes” to first interview.

- **RULE-010-D04 — 2026-11-06:** Baseline burden is whole-number total weight plus collection-entry/stack count, not stacked-unit count. Weight/count coefficients and count policy are moddable; ITEM/ECON define a consistent evaluated basket, including splitting implications. User: “1. Yes” to second interview.
- **RULE-010-D05 — 2026-11-06:** Default qualitative risk and optional exact percentages explicitly identify pickpocket success or shoplifting detection. Inspection shares gameplay calculation without rolling, practice or initiating theft. User: “2. Yes” to second interview.
- **RULE-010-D06 — 2026-11-06:** Use one RULE-001 result per authorized success/detection check. Loot and legal consequences remain separate: success does not guarantee valuable loot; detection does not itself define witnesses/guards/hostility. User: “3. Yes” to second interview.

The complete [RULE-010 specification](systems/RULE/RULE-010.md) is approved under RULE-010-A01. Interaction, loot and legal consequences remain owner-reviewed dependencies. No implementation is authorized.

## RULE-009 interview decisions

- **RULE-009-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-009 Draft v1. The [specification](systems/RULE/RULE-009.md) is finalized v1. Documented numeric/hook domains, difficulty adapters, UI settings and interaction/SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-009-D01 — 2026-11-06:** Retain separate vanilla interior/exterior lockpicking formulas, but make both moddable. Vanilla interior chance is live Lockpicking+5×(actual level−lock value); exterior chance is live Lockpicking−5×lock value. User: “1. Yes, but make both moddable” to first interview.
- **RULE-009-D02 — 2026-11-06:** Retain vanilla eligible ordinary-lock chance limits 5–95%, but make those limits moddable. Unpickable/magically blocked doors remain eligibility restrictions rather than automatic minimum-chance attempts. User: “2. Yes, but make it moddable” to first interview.
- **RULE-009-D03 — 2026-11-06:** Use actual claimed player level and live Lockpicking. Earned/unclaimed levels do not count. Resolve one RULE-001 check only after owner authorization; retry eligibility, practice, unlocking and crime remain separately reviewed owner rules. User: “3. Yes” to first interview.

- **RULE-009-D04 — 2026-11-06:** Support validated per-formula data parameters for skill, level and lock-difficulty weights and constant offset, plus explicit RULE-004 replacement hooks for supported alternative models. No general formula interpreter is required. User: “1. Yes” to second interview.
- **RULE-009-D05 — 2026-11-06:** Configure interior/exterior chance limits independently within inclusive 0–100, requiring minimum<=maximum. Mods may permit guarantees without bypassing blocked-door eligibility. User: “2. Yes” to second interview.
- **RULE-009-D06 — 2026-11-06:** Default to qualitative descriptions derived from the resolved gameplay chance, with optional exact-percentage display. Inspection neither rolls nor awards practice; blocked doors explain restrictions rather than misleading chances. User: “3. Yes” to second interview.

The complete [RULE-009 specification](systems/RULE/RULE-009.md) is approved under RULE-009-A01. Interaction eligibility/consequence rules remain owner-reviewed dependencies. No implementation is authorized.


## RULE-008 interview decisions

- **RULE-008-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-008 Draft v1. The [specification](systems/RULE/RULE-008.md) is finalized v1. Documented numeric/hook domains, restriction contracts, environment/TIME integration, tick reporting and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-008-D01 — 2026-11-06:** Preserve source-compatible arithmetic: health rate=max(1, Endurance healing modifier+trunc((live Medical+addition)×effective max health/1000)), with division truncated toward zero before addition. Preserve safe arithmetic rather than short-integer overflow. User: “1. Yes” to first interview.
- **RULE-008-D02 — 2026-11-06:** Explicit applicable recovery prohibitions produce zero and override minimum-one recovery. NoRegenSpellPoints blocks ordinary rest magicka regeneration; other recovery sources require their own approved rules. User: “2. Yes” to first interview.
- **RULE-008-D03 — 2026-11-06:** Provide an inspectable distinction between calculated hourly amount, blocking reason and actual amount restored after capacity limits. Nominal minimum one does not imply recovery into full/zero-capacity pools. User: “3. Yes” to first interview.

The complete [RULE-008 specification](systems/RULE/RULE-008.md) is approved under RULE-008-A01. Approved CHAR-021 rest and CHAR-018 pool rules remain binding. No implementation is authorized.

## RULE-007 interview decisions

- **RULE-007-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-007 Draft v1. The [specification](systems/RULE/RULE-007.md) is finalized v1. Documented factor mappings, numeric domains, shared override/progress contracts, UI and CHAR/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-007-D01 — 2026-11-06:** Skill-requirement exponent uses actual claimed level captured at advancement-check start, not highest earned/unclaimed target. Pending rewards do not raise practice requirements before claim. User: “1. Yes” to first interview.
- **RULE-007-D02 — 2026-11-06:** Vanilla permanent skill zero yields threshold T=1, without a separate minimum requirement. Reflex scaling and approved checkpoint/mastery rules still apply. User: “2. Yes” to first interview.
- **RULE-007-D03 — 2026-11-06:** Provide an inspectable breakdown of skill requirement, relevant multipliers and raw practice needed, alongside shared next-level threshold information. Preserve CHAR-012's exclusion of raw counters from ordinary character-sheet view; exact placement remains UI scope. User: “3. Yes” to first interview.

The complete [RULE-007 specification](systems/RULE/RULE-007.md) is approved under RULE-007-A01. Approved CHAR-012/013/014 advancement and eligibility policies remain binding. No implementation is authorized.

## RULE-006 interview decisions

- **RULE-006-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-006 Draft v1. The [specification](systems/RULE/RULE-006.md) is finalized v1. Documented numeric/override domains, range adapter, preparation recovery, UI and atomic SAVE/commit integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-006-D01 — 2026-11-06:** Draw ordinary attribute pool and health independently from the progression source, without hidden high-pool/low-health coupling. Use stable preparation order: pool first, health second. User: “1. Yes” to first interview.
- **RULE-006-D02 — 2026-11-06:** Allocation presents prepared health gain and captured Endurance contribution, explaining that Endurance allocated now affects future rewards rather than this prepared gain. User: “2. Yes” to first interview.
- **RULE-006-D03 — 2026-11-06:** Valid singleton configured ranges still consume one logical draw per ordinary reward component. Invalid ranges fail validation before drawing. Artifact rewards do not acquire ordinary level-health draws. User: “3. Yes” to first interview.

The complete [RULE-006 specification](systems/RULE/RULE-006.md) is approved under RULE-006-A01. Existing approved CHAR-015/017 and RULE-003/005 requirements remain binding. No implementation is authorized.

## RULE-005 interview decisions

- **RULE-005-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-005 Draft v1. The [specification](systems/RULE/RULE-005.md) is finalized v1. Documented consumer/input audit, numeric domains, parameter/hook schemas, capacity integration, UI and SAVE reconstruction dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-005-D01 — 2026-11-06:** Retain the seven inspected DFU formulas as vanilla baseline: damage floor((Strength−50)/5), carrying capacity floor(1.5×Strength), base player magicka floor(Intelligence×career multiplier), resistance floor(Willpower/10), and agility to-hit/Endurance health-growth/Endurance healing modifiers floor(attribute/10)−5. Preserve mathematical floor, including negative results; validated customization remains available. User: “1. Yes” to first interview.
- **RULE-005-D02 — 2026-11-06:** Current capabilities use live attributes; earned health growth uses permanent Endurance. Temporary Strength affects damage/capacity, Intelligence magicka capacity, Willpower resistance and Endurance healing. Temporary Endurance does not rewrite previous health gains or improve an already prepared reward. User: “2. Yes” to first interview.
- **RULE-005-D03 — 2026-11-06:** Derived modifiers remain separate from consuming formulas. Resistance is not automatically a standalone percentage and agility's modifier is not automatically added to every attack. COMBAT/MAGIC/recovery owners define participation without double counting. User: “3. Yes” to first interview.

- **RULE-005-D04 — 2026-11-06:** Recompute affected derived values when valid attributes, career multiplier or modifier sources change, without replaying rewards/effects. Increased magicka capacity does not refill; decreases follow CHAR-018 current-pool clamping. User: “1. Yes” to second interview.
- **RULE-005-D05 — 2026-11-06:** Use valid resolved attributes including zero and approved above-100 values without another hidden 0–100 clamp. Negative damage/to-hit/healing modifiers remain valid consumer inputs; CHAR-011 owns attribute bounds. User: “2. Yes” to second interview.
- **RULE-005-D06 — 2026-11-06:** Permit validated overrides for declared formula parameters and explicit RULE-004 replacement hooks. Reject nonfinite multipliers, unsupported numeric ranges and overflowing results; malformed definitions do not silently become vanilla defaults. Exact parameter/hook contracts remain dependencies. User: “3. Yes” to second interview.

- **RULE-005-D07 — 2026-11-06:** Keep floor(Endurance/10)−5 for healing without reproducing the original-game negative-modifier quirk mentioned in DFU's comment. Recovery owns final rate/minimum. User: “1. Yes” to third interview.
- **RULE-005-D08 — 2026-11-06:** Player-facing derived values use gameplay's calculations with inspectable attribute/multiplier explanations and labels distinguishing modifiers from final chances/rates. Exact UI layout remains deferred. User: “2. Yes” to third interview.
- **RULE-005-D09 — 2026-11-06:** Rebuild derived values from restored attributes, career settings and valid modifier sources; saved derived totals are not extra bonuses. Awarded health and prepared reward rolls remain retained facts, not recalculated from current Endurance. User: “3. Yes” to third interview.

The complete [RULE-005 specification](systems/RULE/RULE-005.md) is approved under RULE-005-A01. No implementation is authorized.

## RULE-004 interview decisions

- **RULE-004-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-004 Draft v1. The [specification](systems/RULE/RULE-004.md) is finalized v1. Documented hook inventory/contracts, additive policies, executable activation/cleanup, dependency recovery and save compatibility remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-004-D01 — 2026-11-06:** Expose an explicit set of supported formula hooks with stable identifiers, expected inputs/output and declared replacement/additive semantics. This does not promise every internal calculation is overridable. User: “1. Yes” to first interview.
- **RULE-004-D02 — 2026-11-06:** Validate hook identity, provider and callback signature during registration/preflight before an invalid candidate can displace a valid provider. Errors identify the mod and hook rather than being deferred silently to gameplay. User: “2. Yes” to first interview.
- **RULE-004-D03 — 2026-11-06:** For replacement hooks, the last valid provider in resolved enabled-mod order wins. Preserve contributing/winning-provider diagnostics; intentional conflict resolution uses pre-lock mod ordering consistent with DATA-003. User: “3. Yes” to first interview.

- **RULE-004-D04 — 2026-11-06:** Invalid hook contributions block configuration completion with source/hook diagnostics. Permit explicit omission of the mod's formula-hook contribution or return to configuration, subject to dependency validation; no silent rule substitution. User: “1. Yes” to second interview.
- **RULE-004-D05 — 2026-11-06:** Reject same-mod duplicate registrations for the same replacement hook instead of choosing by incidental registration order. Multiple-provider behavior requires an explicit hook contract. User: “2. Yes” to second interview.
- **RULE-004-D06 — 2026-11-06:** Finalize registrations/winners before actual main-menu entry and lock them for the application run. Supported settings cannot silently replace providers; executable activation and safe pre-menu rebuild remain MOD-owned requirements. User: “3. Yes” to second interview.

- **RULE-004-D07 — 2026-11-06:** Every additive hook declares whether it selects one provider or combines multiple providers, including combination order and meaning. Permission extension, numeric addition and observation are distinct contracts. User: “1. Yes” to third interview.
- **RULE-004-D08 — 2026-11-06:** A selected callback exception or out-of-contract result stops the affected operation and invokes explicit owner recovery. Do not automatically call another provider or built-in fallback, because state/randomness may already have changed. User: “2. Yes” to third interview.
- **RULE-004-D09 — 2026-11-06:** Use built-in behavior when no replacement is registered, including after explicit omission and successful configuration revalidation. Valid conflicts/default selection use diagnostics without blocking popups; invalid contributions still require explicit recovery. User: “3. Yes” to third interview.

The complete [RULE-004 specification](systems/RULE/RULE-004.md) is approved under RULE-004-A01. No implementation is authorized.

## RULE-003 interview decisions

- **RULE-003-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-003 Draft v1. The [specification](systems/RULE/RULE-003.md) is finalized v1. Documented stream inventory, algorithms/seed allocation, ordering, retry-result and SAVE/lifecycle integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-003-D01 — 2026-11-06:** Separate gameplay random streams by declared purpose, including combat, progression, loot and quest generation, so unrelated purposes do not advance each other's sources. Exact stream inventory remains owner/engineering scope. User: “1. Yes” to first interview.
- **RULE-003-D02 — 2026-11-06:** Initialize each source at its declared session/operation boundary and let it advance normally throughout that lifetime; do not reseed per call, frame or action. Explicit deterministic generation starts from its approved seed. User: “2. Yes” to first interview.
- **RULE-003-D03 — 2026-11-06:** Initializing a source must not consume another purpose's draws. Seed allocation remains an engineering choice subject to purpose isolation and the approved fresh-load policy. User: “3. Yes” to first interview.

- **RULE-003-D04 — 2026-11-06:** Fresh initialization after successful load applies to all session gameplay streams, including combat, progression, loot and quest generation. Retain already generated loot, accepted quests, prepared rewards and other saved facts; only future unresolved outcomes use fresh randomness. User: “1. Yes” to second interview.
- **RULE-003-D05 — 2026-11-06:** Within a session, technical delivery/application retries reuse an already resolved random result without rerolling or duplicating consequences. Genuine new attempts remain owner-governed; successful loading still permits fresh unresolved attempts. User: “2. Yes” to second interview.
- **RULE-003-D06 — 2026-11-06:** Developer reproduction uses isolated seeded test sources. Ordinary inspection/logging never advances or reseeds live sources; ordinary saves need not reproduce the same gameplay sequence. User: “3. Yes” to second interview.

- **RULE-003-D07 — 2026-11-06:** Preserve session streams across pause, menus, location transitions and ordinary scene changes. New games and successful loads establish fresh session streams. User: “1. Yes” to third interview.
- **RULE-003-D08 — 2026-11-06:** Failed/cancelled loads leave a surviving session's streams untouched; fresh sources become active only when a successfully loaded session takes over. User: “2. Yes” to third interview.
- **RULE-003-D09 — 2026-11-06:** Ordinary settings changes and content/mod refreshes cannot silently reseed active streams. Preserve approved content locks; any future supported changes require an explicit lifecycle boundary. User: “3. Yes” to third interview.

The complete [RULE-003 specification](systems/RULE/RULE-003.md) is approved under RULE-003-A01. No implementation is authorized.

## RULE-002 interview decisions

- **RULE-002-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-002 Draft v1. The [specification](systems/RULE/RULE-002.md) is finalized v1. Documented numeric-domain, reference-vector, versioning, operation-lifecycle and consumer-specific compatibility dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-002-D01 — 2026-11-06:** Retain a classic compatibility generator for features that explicitly require DFU-compatible seeded results. User: “1. Yes” to first interview.
- **RULE-002-D02 — 2026-11-06:** Individual feature reviews designate exact classic-sequence uses. An existing DFU DFRandom call does not automatically approve classic behavior for the recreation. User: “2. Yes” to first interview.
- **RULE-002-D03 — 2026-11-06:** Each classic generation operation owns its random state, isolated from combat and other generation operations. Preserve repeatability within that operation without DFU's shared-state coupling. User: “3. Yes” to first interview.

- **RULE-002-D04 — 2026-11-06:** Preserve classic remainder-based range selection, including its bias and draw order, for valid supported ranges in explicitly designated compatibility uses. RULE-001 unbiased gameplay checks remain separate. User: “1. Yes” to second interview.
- **RULE-002-D05 — 2026-11-06:** Reject empty exclusive ranges, reversed bounds and unsupported numeric ranges explicitly before consuming a draw. Inclusive equal bounds remain valid, return that value and consume one draw. User: “2. Yes” to second interview.
- **RULE-002-D06 — 2026-11-06:** Verify known seeds and number sequences against the inspected local DFU source, then verify feature outputs when their owners adopt compatibility. Original DOS-game parity requires separate evidence. User: “3. Yes” to second interview.

- **RULE-002-D07 — 2026-11-06:** Require explicit unsigned 32-bit seeds, including zero, and cross-platform repeatability for identical seeds/draw order. Signed classic inputs require explicit compatibility conversion; missing seeds fail rather than silently using clock/frame counts. User: “1. Yes” to third interview.
- **RULE-002-D08 — 2026-11-06:** Retain assigned persistent results across saves/content updates. Reconstruction is acceptable only with retained algorithm/content versions sufficient to reproduce the same result; seed alone is insufficient after content changes. User: “2. Yes” to third interview.
- **RULE-002-D09 — 2026-11-06:** Preserve existing assigned results when generation rules/content change; affected reconstruction requires explicit version change or migration, preventing silent established-content changes. RULE-001 fresh gameplay randomness remains unchanged. User: “3. Yes” to third interview.

The complete [RULE-002 specification](systems/RULE/RULE-002.md) is approved under RULE-002-A01. No implementation is authorized.

## RULE-001 interview decisions

- **RULE-001-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize RULE-001 Draft v1. The [specification](systems/RULE/RULE-001.md) is finalized v1. Documented RNG adapter, stream/load initialization, diagnostics and owner-lifecycle dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **RULE-001-D01 — 2026-11-06:** Retain exact integer percentages, with guaranteed failure at 0% and guaranteed success at 100%. No universal 1–99% restriction; individual systems may impose their own limits. User: “1. Yes” to first interview.
- **RULE-001-D02 — 2026-11-06:** Computed chances below 0 or above 100 resolve as 0% or 100%. Diagnose invalid authored parameters separately rather than requiring every caller to normalize calculated chances. User: “2. Yes” to first interview.
- **RULE-001-D03 — 2026-11-06:** Resolve each check once and expose its success/failure and 1–100 roll to developer diagnostics. Ordinary player visibility belongs to the calling feature; no universal player-facing dice display is introduced. User: “3. Yes” to first interview. Whether guaranteed outcomes consume a draw remains unresolved.

- **RULE-001-D04 — 2026-11-06:** Every resolved percentile check consumes one draw, including guaranteed failure/success, so diagnostics always have a roll. User: “1. Yes” to second interview.
- **RULE-001-D05 — 2026-11-06:** Checks use an explicitly supplied gameplay random source isolated from presentation and previews. Exact stream divisions remain RULE-003 scope. User: “2. Yes” to second interview.
- **RULE-001-D06 — 2026-11-06:** Reject mandatory restoration of the prior gameplay random sequence. Reloading may produce fresh rolls, allowing deliberate reload-to-reroll play. User: “3. No, I'd prefer \"save scumming\" be an option if possible, if somebody wants to do that, feels more true to the \"random\" aspect there as well in my opinion.” Existing approved retained creation/progression outcomes remain fixed; fresh randomness is not permission to reroll those committed results. Exact load initialization policy remains under discussion.

- **RULE-001-D07 — 2026-11-06:** Initialize gameplay randomness afresh on every successful load, allowing repeated attempts from the same save. Coincidental repeated rolls remain valid; no different/better result is guaranteed. User: “1. Yes” to third interview.
- **RULE-001-D08 — 2026-11-06:** Independent checks are the shared baseline, without hidden pity bonuses, streak protection or forced success after failures. Individual features may explicitly define exceptions. User: “2. Yes” to third interview.
- **RULE-001-D09 — 2026-11-06:** Diagnostics expose original chance, effective 0–100 chance, 1–100 rolled number and result by observing the resolved check without another draw. User: “3. Yes” to third interview.

The complete [RULE-001 specification](systems/RULE/RULE-001.md) is approved under RULE-001-A01. D04 resolves D03's initially open guaranteed-draw question; D07 resolves D06's load-initialization policy. No implementation is authorized.

## CHAR-023 interview decisions

- **CHAR-023-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-023 Draft v1. The [specification](systems/CHAR/CHAR-023.md) is finalized v1. Documented benefit/AV/input, mod-schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-023-D01 — 2026-11-06:** Resolve owner-defined prevention once per lethal event before committing survival/death. Successful prevention restores max(1,floor(0.1×effective max health)), with validated mod parameters; exact Stendarr chance/eligibility remains FACT scope. User: “1. Yes” to first interview.
- **CHAR-023-D02 — 2026-11-06:** Default camera lowering/death audio, two-second fade and roughly three-second pre-return duration, with validated presentation overrides. Missing camera/audio/fade cannot block return. User: “2. Yes” to first interview.
- **CHAR-023-D03 — 2026-11-06:** Confirm death once after prevention fails; stop ordinary gameplay input/simulation and reject stale damage/practice/reward replay. Presentation is not authority for death. CORE-008 owns safe handoff. User: “3. Yes” to first interview.

- **CHAR-023-D04 — 2026-11-06:** Evaluate applicable prevention sources in explicit deterministic priority order, at most once each, stopping on success. Only successful source consumes success-related charge; failed-attempt costs require explicit owner rule. Allow validated mod priorities, no duplicate-callback rerolls. User: “1. Yes” to second interview.
- **CHAR-023-D05 — 2026-11-06:** Initial short death camera/fade sequence is unskippable, matching base experience. Following movie remains skippable under CORE-008. User: “I'd not skip the initial death camera fade sequence, since you can't in the base game, but you can skip the movie that plays afterwards atleast, it's not a very long sequence anyway.” Reject the proposed initial-sequence skip control.
- **CHAR-023-D06 — 2026-11-06:** Block ordinary saves during unresolved lethal evaluation and after confirmed death; existing saves remain untouched. No autosave/automatic reload. Developer diagnostics/recovery remain separate. User: “3. Yes” to second interview.

The complete [CHAR-023 specification](systems/CHAR/CHAR-023.md) is approved under CHAR-023-A01 above. No implementation is authorized.

## CHAR-022 interview decisions

- **CHAR-022-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-022 Draft v1. The [specification](systems/CHAR/CHAR-022.md) is finalized v1. Documented threat/activity/outcome, mod-schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-022-D01 — 2026-11-06:** Default exhaustion on safe land advances one collapse hour; nearby genuine threats or swimming trigger lethal health request through normal prevention/death rules. Swimming includes surface swimming. Allow validated mod-overridable outcomes. User: “1. Yes” to first interview.
- **CHAR-022-D02 — 2026-11-06:** Completed safe collapse uses CHAR-021 current recovery/restrictions, +1 raw Medical practice and no duplicate ordinary activity drain. No independent bypass of CHAR-013 advancement trigger rules. User: “2. Yes” to first interview.
- **CHAR-022-D03 — 2026-11-06:** Use exhaustion-purpose NPC/COMBAT genuine-threat query, not all rest vetoes as lethal classification. Purpose-specific CORE-019 approach and generic hidden-threat feedback apply. User: “3. Yes” to first interview.

- **CHAR-022-D04 — 2026-11-06:** Default safe-land collapse is a forced protected hour suspending ordinary controls, advancing time-dependent systems and settling once. Validated mod interruption/alternate-outcome policies allowed; protection does not silently cancel required quest/condition events. User: “1. Yes” to second interview.
- **CHAR-022-D05 — 2026-11-06:** One authoritative collapse operation per depletion episode, not a popup-visible guard. Duplicate/UI/save callbacks cannot add hours/rewards. Ordinary new episode requires recovery above zero followed by new depletion. User: “2. Yes” to second interview.
- **CHAR-022-D06 — 2026-11-06:** If completed recovery leaves fatigue zero, explain unresolved exhaustion and retain incapacitation rather than repeated skips, free fatigue or automatic death. Explicit mod/condition-owner recovery/alternate outcomes may resolve it; save/load preserves condition. User: “3. Yes” to second interview.

The complete [CHAR-022 specification](systems/CHAR/CHAR-022.md) is approved under CHAR-022-A01 above. No implementation is authorized.

## CHAR-021 interview decisions

- **CHAR-021-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-021 Draft v1. The [specification](systems/CHAR/CHAR-021.md) is finalized v1. Documented TIME/environment/schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-021-D01 — 2026-11-06:** Retain source health/hour formula using live Medical/Endurance and max health, base Medical term +60, source integer arithmetic and minimum 1; fatigue max(1,trunc(max fatigue/8)) internal units/hour; magicka max(1,trunc(max magicka/8)) unless regeneration forbidden. Allow validated parameters/restrictions. User: “1. Yes” to first interview.
- **CHAR-021-D02 — 2026-11-06:** Rapid Healing replaces +60 Medical term with +100 when applicable: General always, Light daytime outdoors, Darkness otherwise. Explicitly includes dungeon/building interiors as Darkness, making it broadly applicable during interior exploration. Allow mod-overridable environmental classification; more focused environment-feature ownership remains a dependency, rather than assuming measured light brightness. User: “Yes, but also a note that being inside a dungeon and inside a building is considered ‘Darkness’ as well ... Would like that aspect moddable as well somehow. But probably more related to another more focused feature.”
- **CHAR-021-D03 — 2026-11-06:** Timed/full rest recover after completed hours; loitering does not. +1 Medical raw practice per committed recovery hour. Allow validated cadence/mode overrides; partial recovery requires explicit policy. User: “3. Yes” to first interview.

- **CHAR-021-D04 — 2026-11-06:** Preserve completed committed recovery/practice on interruption. Default unfinished hour grants neither; stopping/restarting starts a fresh hour, no banking. Allow explicit mod proportional/retained-partial alternatives. User: “1. Yes” to second interview.
- **CHAR-021-D05 — 2026-11-06:** Until-healed completes when health/fatigue and all rest-recoverable pools are full, ignoring prohibited magicka regeneration. Other rules making missing pools unrecoverable produce explanation and stop rather than endless loop. User: “2. Yes” to second interview.
- **CHAR-021-D06 — 2026-11-06:** Recalculate each committed tick from current valid attributes/maxima/regeneration/environment. Advance time-dependent systems and honor CORE-019 at declared boundaries; no double ordinary activity drain. Exact boundary ordering remains TIME rest contract. User: “3. Yes” to second interview.

The complete [CHAR-021 specification](systems/CHAR/CHAR-021.md) is approved under CHAR-021-A01 above. No implementation is authorized.

## CHAR-020 interview decisions

- **CHAR-020-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-020 Draft v1. The [specification](systems/CHAR/CHAR-020.md) is finalized v1. Documented TIME/MOVE cadence/integration, mod-schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-020-D01 — 2026-11-06:** Retain internal fatigue costs: ordinary 11/min, climbing 22/min, moving running 88/min, swimming 11/min or 44 on failed Swimming check for non-Argonians; jump additional 11/event. Periodic precedence climbing→moving running→swimming→ordinary, replacing rather than stacking rates. Allow validated mod rates/priority rules. User: “1. Yes” to first interview.
- **CHAR-020-D02 — 2026-11-06:** Retain Athleticism ×0.9 or ×0.8 with Improved Athleticism plus class Athleticism, integer truncation and validated overrides. Improved Athleticism alone does not activate reduction under default rule. User: “2. Yes” to first interview.
- **CHAR-020-D03 — 2026-11-06:** Account for every eligible elapsed interval using actual activity context, not one charge on changed clock/final-state extrapolation. Rest/training/travel own simulated intervals to avoid duplicate ordinary drain. User: “3. Yes” to first interview.

- **CHAR-020-D04 — 2026-11-06:** Running grants +1 raw practice per 0.25 seconds qualifying simulated running, independent of frame rate, requiring movement and excluding riding; validated mod cadence. Deliberately exclude stationary run-input practice. User: “1. Yes” to second interview.
- **CHAR-020-D05 — 2026-11-06:** Charge jump cost/+1 Jumping once per actual jump, not repeated callbacks. Retain +1 Climbing per qualifying check including failure. Rappelling uses explicit MOVE-owned cadence rather than per-frame practice, with validated cadence overrides. User: “2. Yes” to second interview.
- **CHAR-020-D06 — 2026-11-06:** Selected swimming periodic activity grants +1 practice per eligible game-minute tick. Check live Swimming with explicitly bounded probability; non-Argonian failure selects higher cost, Argonian uses ordinary cost. Effective racial inheritance follows CHAR-019. User: “3. Yes” to second interview.

The complete [CHAR-020 specification](systems/CHAR/CHAR-020.md) is approved under CHAR-020-A01 above. No implementation is authorized.

## CHAR-019 interview decisions

- **CHAR-019-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-019 Draft v1. The [specification](systems/CHAR/CHAR-019.md) is finalized v1. Documented mechanics/entitlement/asset, MOD and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-019-D01 — 2026-11-06:** Preserve birth race/chosen portrait/gender separately from condition identity and current form. Lycanthropy condition and currently transformed beast form are distinct states. User: “1. Yes” to first interview.
- **CHAR-019-D02 — 2026-11-06:** Initial supported transformations are vampirism and werewolf/wereboar lycanthropy, with validated appearance/grant definitions and supported mod additions. This does not approve every source bonus/restriction/infection rule; MAGIC/QUEST retain their mechanics. User: “2. Yes” to first interview.
- **CHAR-019-D03 — 2026-11-06:** Ability grants are source-owned and idempotent on reapply/restore. Cure removes only that source entitlement, preserving independently learned/other granted copies. Spell behavior/casting costs remain MAGIC-owned. User: “3. Yes” to first interview.

- **CHAR-019-D04 — 2026-11-06:** Default permits one active racial transformation condition; reject incompatible second condition without silently replacing first. Allow validated mod compatibility/precedence rules; compatible conditions do not imply simultaneous physical forms. User: “1. Yes” to second interview.
- **CHAR-019-D05 — 2026-11-06:** Inherit birth-race traits unless explicitly replaced/suppressed by transformation definition. Declare changes separately from display-name changes; exact resistance/ability stacking remains mechanics-owner scope. User: “2. Yes” to second interview.
- **CHAR-019-D06 — 2026-11-06:** Validate required assets, abilities and owner prerequisites before transformation/cure. Missing required content blocks transition with explanation; do not leave partial grants/presentation. Vital maxima follow CHAR-018 and no automatic healing is authorized. User: “3. Yes” to second interview.

The complete [CHAR-019 specification](systems/CHAR/CHAR-019.md) is approved under CHAR-019-A01 above. No implementation is authorized.

## CHAR-018 interview decisions

- **CHAR-018-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-018 Draft v1. The [specification](systems/CHAR/CHAR-018.md) is finalized v1. Documented source/outcome/schema and SAVE/TIME dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-018-D01 — 2026-11-06:** Retain health/fatigue/magicka/breath pools and formulas: health stored base max reduced by lowest active health limiter; fatigue (live Strength+live Endurance)×64 internal units; magicka max(0,floor(live Intelligence×class multiplier)+active modifier); breath floor(live Endurance/2). Allow validated overrides for supported parameters; separate base/effective health max. User: “1. Yes” to first interview.
- **CHAR-018-D02 — 2026-11-06:** Maximum increase leaves current unchanged; decrease clamps current only if above new maximum. No percentage preservation/refill; consistent with CHAR-015. User: “2. Yes” to first interview.
- **CHAR-018-D03 — 2026-11-06:** Use authoritative pool operations with explicit units/source context for damage/healing/costs/restoration, not arbitrary field writes. CHAR-017 save reconstruction remains consequence-free; ordinary changes notify owners. User: “3. Yes” to first interview.

- **CHAR-018-D04 — 2026-11-06:** Depletion emits once for positive-to-zero transition, not repeated zero writes/existence at zero max magicka; recovery above zero rearms future depletion. Death prevention/collapse/drowning remain owners' rules. User: “1. Yes” to second interview.
- **CHAR-018-D05 — 2026-11-06:** Ordinary costs fail unchanged if insufficient resources; damage/drain saturates toward zero and healing/recovery at max. Exceptions require explicit owner approval rather than silent partial spending. User: “2. Yes” to second interview.
- **CHAR-018-D06 — 2026-11-06:** Breath activity initializes fresh reserve by default, preserves active reserve through save/load and ends on normal breathing; generic fill vitals affects health/fatigue/magicka, not active breath. Allow modded gradual breath refill in appropriate states rather than unconditional immediate full reserve. User: “Yes, but try to make it moddable so if somebody wanted to make breath gradually refill when in an appropriate state instead of always refilling to full immediately, they could.” Replenishment-state/entry interaction remains to be finalized.

- **CHAR-018-D07 — 2026-11-06:** Default breath replenishment is instant. Validated alternatives declare eligible recovery states/rate/delay; gradual mode retains inactive reserve and uses it on re-entry without hidden full refill. Persist reserve/recovery timing. User: “1. Yes” to third interview. Clarifies D06's fresh-reserve behavior for alternate policies.
- **CHAR-018-D08 — 2026-11-06:** Require positive base max health, health limiters ≥1 and nonnegative fatigue/magicka/breath maxima with safe arithmetic. Malformed definitions/invalid saved pools use explicit rejection/migration, not silent repair; normal gameplay damage/healing saturation remains approved. User: “2. Yes” to third interview.

The complete [CHAR-018 specification](systems/CHAR/CHAR-018.md) is approved under CHAR-018-A01 above. No implementation is authorized.

## CHAR-017 interview decisions

- **CHAR-017-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-017 Draft v1. The [specification](systems/CHAR/CHAR-017.md) is finalized v1. Documented schema/clock/vital, owner/UI and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-017-D01 — 2026-11-06:** Separate fresh-character initialization/native-save restoration, sharing validated contracts but never rerunning biography rewards, starting grants or initial rolls on load. DFU/classic compatibility remains outside scope under CORE-013. User: “1. Yes” to first interview.
- **CHAR-017-D02 — 2026-11-06:** Fresh ordinary character starts at level 1 with max health 25 + class HP per level; health/fatigue/magicka full after required initialization. Permit validated overrides for supported starting parameters; derived pool limits remain CHAR-018 scope. User: “2. Yes” to first interview.
- **CHAR-017-D03 — 2026-11-06:** Preserve authoritative identity/permanent values/progression baselines/counters/timestamps/policies/pending rewards; rebuild derived live modifiers, skill sums and UI from sources. Missing required data uses explicit migration/failure, not silent defaults/estimates. User: “3. Yes” to first interview.

- **CHAR-017-D04 — 2026-11-06:** Initialize/restore from clean session baseline with copied validated character-owned state, not shared mutable drafts. Prevent prior-character inventory/effects/practice/cooldowns/pending rewards leaking; preserve CORE teardown/readiness rules. User: “1. Yes” to second interview.
- **CHAR-017-D05 — 2026-11-06:** Reconstruction does not trigger new damage/death/collapse, practice, level rewards or purchase effects from assignment. Resume genuine saved conditions/obligations and required pending UI through owners after reconstruction. User: “2. Yes” to second interview.
- **CHAR-017-D06 — 2026-11-06:** Fresh last-advancement-check time equals initialized starting clock; training state is explicitly never trained, enabling immediate first purchase. Load preserves saved timestamps rather than setting now. User: “3. Yes” to second interview.

The complete [CHAR-017 specification](systems/CHAR/CHAR-017.md) is approved under CHAR-017-A01 above. No implementation is authorized.

## CHAR-016 interview decisions

- **CHAR-016-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-016 Draft v1. The [specification](systems/CHAR/CHAR-016.md) is finalized v1. Documented service/time/vital, MOD and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-016-D01 — 2026-11-06:** Retain raw practice uniform integer[10,20] × skill advancement factor, three game hours duration and fatigue equivalent to 180 minutes ordinary loss, with validated mod parameters. Default advancement does not force a training check; live mode processes credited practice under CHAR-013. User: “1. Yes” to first interview.
- **CHAR-016-D02 — 2026-11-06:** Retain character-wide 12-hour cooldown from training start, exactly 12 hours sufficient; inclusive permanent-skill trainer limit normally 50, with validated overrides. Temporary modifiers do not affect eligibility. User: “2. Yes” to first interview.
- **CHAR-016-D03 — 2026-11-06:** Retain default member price 100 × actual level/nonmember 400 × actual level. Guild/temple owners define access, skills and supported price/limit overrides. Quote specific skill/service; revalidate funds/access/eligibility before payment. Changed price requires fresh confirmation. User: “3. Yes” to first interview.

- **CHAR-016-D04 — 2026-11-06:** Validate payment/required inputs before acceptance; preflight cancellation/failure changes nothing. Accepted training executes one protected operation applying quoted payment/time/fatigue/practice once, with explicit post-start recovery. Allow modding the order of operations and what occurs during training. User: “Yes, but allow this order of operations and what occurs during to be modded.” Supported stage/effect/settlement contracts remain under discussion.
- **CHAR-016-D05 — 2026-11-06:** Permit paid training even when raw practice counter is full or near full. Reject the proposed full-counter refusal and near-cap purchase-warning requirement. User: “No, I'd say just let you train anyway, even if your ‘tally’ count is full at that time or near it.” CHAR-012 saturation remains applicable; training is not guaranteed to increase a skill.
- **CHAR-016-D06 — 2026-11-06:** Default requires sufficient fatigue to finish without exhaustion, protects the three-hour activity from combat interruption, advances time-dependent systems and avoids duplicate ordinary-fatigue charging. Permit modded event interruptions during the time skip. User: “Yes, but I'd like for the option to potentially mod it so maybe you could be interrupted by other events during that time-skip, or something of that sort.” Interruption settlement remains under discussion.

- **CHAR-016-D07 — 2026-11-06:** Default settlement charges price/starts cooldown at training start, advances three hours/applies one fatigue cost and credits practice on successful completion. Full-counter training pays all costs; practice saturates normally without automatic refund. User: “1. Yes” to third interview.
- **CHAR-016-D08 — 2026-11-06:** Allow declared training stages and supported activity/event hooks to change ordering/consequences, requiring explicit payment/cooldown/time/fatigue/practice policies. Repeated callbacks/save-load cannot charge or reward twice. User: “2. Yes” to third interview.
- **CHAR-016-D09 — 2026-11-06:** Interruptible definitions must declare payment/cooldown/partial-practice settlement. Initial interruption policy retains payment/cooldown, charges elapsed time/fatigue and grants no practice until completion. Validated refund/partial-practice alternatives are supported. User: “3. Yes” to third interview.

The complete [CHAR-016 specification](systems/CHAR/CHAR-016.md) is approved under CHAR-016-A01 above. No implementation is authorized.

## CHAR-015 interview decisions

- **CHAR-015-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-015 Draft v1. The [specification](systems/CHAR/CHAR-015.md) is finalized v1. Documented transaction/UI/vital, mod-schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-015-D01 — 2026-11-06:** Ordinary reward grants one actual level, uniform integer 4–6 attribute points and max(1, uniform integer[floor(class HP/2), class HP] + floor(pre-allocation permanent Endurance/10) −5) maximum-health growth. Allow validated overrides for supported reward parameters. User: “1. Yes” to first interview.
- **CHAR-015-D02 — 2026-11-06:** Prepare/retain random reward results once, allocate, then atomically commit level/health/attributes on confirmation. Reopening/loading cannot reroll; deliberately replaces DFU split commit. User: “2. Yes” to first interview.
- **CHAR-015-D03 — 2026-11-06:** Separate ordinary-level and artifact pending rewards; process one at a time without losing CHAR-014 backlog. Oghma baseline 30 attribute points/no level/no health with validated overrides. Item consumption and reward creation must succeed together. User: “3. Yes” to first interview.

- **CHAR-015-D04 — 2026-11-06:** Attribute points spend/refund one-for-one within reward starting permanent values and resolved caps. Require full spendable allocation; if all attributes reach caps, show unusable remainder and permit explicit confirmation discarding it, without conversion. User: “1. Yes” to second interview.
- **CHAR-015-D05 — 2026-11-06:** Reject ordinary reward deferral as vanilla policy. Once allocation is opened, require distribution/completion rather than returning to gameplay and applying later. User: “Maybe as a moddable option, but the vanilla game doesn't allow for it, so I'd say just require disturbing points and not allowing you to apply them at another time.” Optional mod-deferral scope remains to be confirmed. This does not waive retained outcomes or coherent save recovery.
- **CHAR-015-D06 — 2026-11-06:** Maximum-health gain leaves current health unchanged. Use pre-reward-allocation Endurance and do not retroactively recalculate earlier level health gains. User: “3. Yes” to second interview.

- **CHAR-015-D07 — 2026-11-06:** Support validated mod-only close/resume deferral, disabled by default. Retain partial allocation/rolled results and apply no benefits before confirmation. User: “1. Yes” to third interview.
- **CHAR-015-D08 — 2026-11-06:** Process rewards in acquisition order without interrupting an active reward. Ordinary levels are separate claims in level order; prepare each only when allocation begins so later rewards use permanent Endurance after prior commits. User: “2. Yes” to third interview.
- **CHAR-015-D09 — 2026-11-06:** Pending eligibility waits for character-sheet opening or safe claim action, not forced combat allocation. Once vanilla allocation starts, pause gameplay and block gameplay return until confirmation. User: “3. Yes” to third interview.

The complete [CHAR-015 specification](systems/CHAR/CHAR-015.md) is approved under CHAR-015-A01 above. No implementation is authorized.

## CHAR-014 interview decisions

- **CHAR-014-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-014 Draft v1. The [specification](systems/CHAR/CHAR-014.md) is finalized v1. Documented mod-schema, claim-integration and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-014-D01 — 2026-11-06:** Retain all Primary plus two highest Major plus highest Minor permanent skill values; recalculate rankings as skills change. Allow validated mod-configurable contribution rules. User: “1. Yes” to first interview.
- **CHAR-014-D02 — 2026-11-06:** Retain floor((current sum − starting sum + 28)/15), including early first eligibility, with baseline captured after all starting skill changes. Allow validated mod overrides for offset/points per level. Preserve baseline on load rather than silently estimate it. User: “2. Yes” to first interview.
- **CHAR-014-D03 — 2026-11-06:** Track eligible target level and explicit unclaimed-level count, preserving eligibility across multiple threshold crossings. CHAR-015 owns reward claiming. User: “3. Yes” to first interview.

- **CHAR-014-D04 — 2026-11-06:** Preserve actual and already-eligible levels after permanent skill reductions. Do not remove pending levels; further eligibility requires exceeding the previously earned target under the formula. User: “1. Yes” to second interview.
- **CHAR-014-D05 — 2026-11-06:** Reevaluate after committed permanent-skill changes, including default/live CHAR-013, and level claims. Temporary modifiers do not count. Other permanent grants count by default unless explicitly excluded by their owner; initialization/load reconstruction must not duplicate awards. User: “2. Yes” to second interview.
- **CHAR-014-D06 — 2026-11-06:** Gameplay/UI share resolved contribution/formula rules. Show actual level, pending count and progress toward next not-yet-earned level, without automatic combat interruption to open the sheet. Reward presentation remains CHAR-015 scope. User: “3. Yes” to second interview.

The complete [CHAR-014 specification](systems/CHAR/CHAR-014.md) is approved under CHAR-014-A01 above. No implementation is authorized.

## CHAR-013 interview decisions

- **CHAR-013-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-013 Draft v1. The [specification](systems/CHAR/CHAR-013.md) is finalized v1. Documented time/schema/numeric, batching/UI and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-013-D01 — 2026-11-06:** Default advancement checkpoints are rest/fast-travel completion, gated by strictly more than 360 game minutes since last eligible check. No continuous default advancement; interval supports validated mod overrides. Eligible checks update timestamp even with no gains. User: “1. Yes” to first interview. User's D03 additionally requires room for an optional future live mode; that extension does not silently replace the default.
- **CHAR-013-D02 — 2026-11-06:** Retain floor(permanent skill × skill multiplier × career multiplier × 1.04^level × 2/5 + 1), skill-specific/career parameters and CHAR-010 reflex scaling. Allow validated mod-configurable parameters with safe numeric checks. User: “2. Yes” to first interview.
- **CHAR-013-D03 — 2026-11-06:** Default remains at most one point per skill per eligible check and complete counter reset on threshold qualification, including cap/mastery-blocked gains. Preserve room for modded policies and possible expansion to live advancement without resting. User: “Yes, but allow this room for modding, or even expansion into a ‘live’ skill increase system, where resting is not needed for advancement.” Exact supported alternate policies/trigger timing remain under discussion.

- **CHAR-013-D04 — 2026-11-06:** Support optional live mode checking after accepted practice updates without rest/travel or six-hour gate. Select before character start and fix for that character. Reuse shared progression rules rather than a separate skill system. User: “1. Yes” to second interview.
- **CHAR-013-D05 — 2026-11-06:** Allow validated alternate maximum-gains-per-check, excess-practice carryover and blocked-gain consumption policies. Default stays one point/full reset. Define precise conversion from reflex-scaled thresholds to raw practice for carryover. User: “2. Yes” to second interview.
- **CHAR-013-D06 — 2026-11-06:** Retain default Primary mastery at 100 restricting this path for skills at 95 or above; allow validated changes/disabling. Simultaneous candidate handling must be explicit rather than accidental list order. User: “3. Yes” to second interview.

- **CHAR-013-D07 — 2026-11-06:** Determine mastery eligibility from check-start snapshot and commit resulting gains together. With no Primary mastered initially, multiple eligible skills/Primaries may advance to mastery in that check. Deliberately remove DFU processing-order dependence. User: “1. Yes” to third interview.
- **CHAR-013-D08 — 2026-11-06:** Carryover consumes ceil(required practice / reflex multiplier) raw uses per gained point, then recomputes threshold at the new permanent skill value for further gain attempts, bounded by a finite configured gain limit. Full-reset mode allows at most one gain per skill/check. User: “2. Yes” to third interview.
- **CHAR-013-D09 — 2026-11-06:** Publish skill-gain and Primary-mastery notifications after committed changes; coalesce live-mode messages. Save mode, relevant progression configuration and last-check time to prevent policy switches/repeated gains on load. Level eligibility remains CHAR-014 scope. User: “3. Yes” to third interview.

The complete [CHAR-013 specification](systems/CHAR/CHAR-013.md) is approved under CHAR-013-A01 above. No implementation is authorized.

## CHAR-012 interview decisions

- **CHAR-012-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-012 Draft v1. The [specification](systems/CHAR/CHAR-012.md) is finalized v1. Documented eligibility/cadence, advancement, deduplication and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-012-D01 — 2026-11-06:** Retain separate integer raw-practice counters per stable skill ID, initially zero, saturating at 20,000 with validated mod-configurable caps. Safe arithmetic must prevent overflow destroying practice. User: “1. Yes” to first interview.
- **CHAR-012-D02 — 2026-11-06:** Track unscaled practice separately from advancement. No reflex/class scaling or immediate skill increase on tally; apply relevant scaling/conversion during CHAR-013 checks. User: “2. Yes” to first interview.
- **CHAR-012-D03 — 2026-11-06:** Retain inspected DFU practice-source categories as baseline. Each owner defines qualifying actions, success/failure eligibility, amounts and cadence, with validated data overrides where supported. Do not impose universal successful-actions-only eligibility. User: “3. Yes” to first interview.

- **CHAR-012-D04 — 2026-11-06:** Ordinary practice reports accept nonnegative amounts only; deliberate deductions/resets use separate authorized progression operations, not negative skill-use reports. User: “1. Yes” to second interview.
- **CHAR-012-D05 — 2026-11-06:** Count each qualifying action/scheduled practice tick once despite repeated callbacks. Legitimate repeated actions count by owner cadence; no universal anti-grinding penalty is introduced. User: “2. Yes” to second interview.
- **CHAR-012-D06 — 2026-11-06:** Keep raw counters out of ordinary character-sheet display initially; provide developer diagnostics. Skill-increase notifications remain CHAR-013 scope. User: “3. Yes” to second interview.

- **CHAR-012-D07 — 2026-11-06:** Accept practice only for the current living character from valid gameplay or approved simulated activity such as training/time-advanced recovery. Ignore stale callbacks; reject practice from previews, loading, initialization or already-dead characters. Activity owners define paused/time-advanced qualification. User: “1. Yes” to third interview.
- **CHAR-012-D08 — 2026-11-06:** Save/restore counters exactly by stable skill ID without replaying practice events. Invalid/missing-required/over-cap data, including lowered mod caps, requires explicit migration/recovery rather than silent reset/truncation. Added skills begin at zero only through declared compatible migration. User: “2. Yes” to third interview.

The complete [CHAR-012 specification](systems/CHAR/CHAR-012.md) is approved under CHAR-012-A01 above. No implementation is authorized.

## CHAR-011 interview decisions

- **CHAR-011-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-011 Draft v1. The [specification](systems/CHAR/CHAR-011.md) is finalized v1. Documented consumer/schema/stacking/UI and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-011-D01 — 2026-11-06:** Retain distinct permanent/live attribute and skill values. Temporary modifiers never directly change permanent values; permanent rewards, damage and restoration use explicit owner-controlled operations. User: “1. Yes” to first interview.
- **CHAR-011-D02 — 2026-11-06:** Ordinary gameplay checks use live values by default; progression thresholds, mastery and earned-development calculations use permanent values unless an owner specification explicitly states otherwise. Document exceptions in owning features. User: “2. Yes” to first interview.
- **CHAR-011-D03 — 2026-11-06:** Live attributes use clamp(permanent + modifiers, 0, base cap + maximum modifiers), vanilla base cap 100, with validated mod-configurable caps. Require nonnegative valid effective cap and safe arithmetic. This does not automatically change separate CHAR-008 creation caps. User: “3. Yes” to first interview.

- **CHAR-011-D04 — 2026-11-06:** Retain unclamped live skills as permanent + modifiers, permitting temporary values below 0/above 100 within safe supported numeric ranges. Owning gameplay formulas explicitly define probability clamps/usable minima; CHAR-009 creation limits remain separate. User: “1. Yes” to second interview.
- **CHAR-011-D05 — 2026-11-06:** Track modifiers by owning source; expiration, unequipping/removal clears only that contribution and recomputes from valid remaining sources. MAGIC/ITEM retain effect eligibility/stacking authority; duplicate stacking is not automatically approved. User: “2. Yes” to second interview.
- **CHAR-011-D06 — 2026-11-06:** Character sheet shows live versus permanent values and an inspectable breakdown of active bonuses, penalties and effective attribute caps, beyond coloring alone. User: “3. Yes” to second interview.

- **CHAR-011-D07 — 2026-11-06:** Vanilla permanent attribute/skill bounds are 0–100, with validated mod-configurable bounds. Reject invalid mutations/saved values rather than silently clamp; reward/progression owners may explicitly limit awards under their own rules. Temporary live modifiers remain separate. User: “1. Yes” to third interview.
- **CHAR-011-D08 — 2026-11-06:** Save permanent values plus authoritative effect/equipment source state; reconstruct modifiers before gameplay resumes rather than reapply bonuses to saved live totals. Required missing sources/invalid references use explicit failure/migration policies. User: “2. Yes” to third interview.
- **CHAR-011-D09 — 2026-11-06:** Use stable attribute/skill IDs and validated bounds/modifier-target definitions, supporting CHAR-009 added skills. New attribute types require broader extension under CHAR-004 and are not introduced automatically here. User: “3. Yes” to third interview.

The complete [CHAR-011 specification](systems/CHAR/CHAR-011.md) is approved under CHAR-011-A01 above. No implementation is authorized.

## CHAR-010 interview decisions

- **CHAR-010-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-010 Draft v1. The [specification](systems/CHAR/CHAR-010.md) is finalized v1. Documented combat/progression scope, mod-schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-010-D01 — 2026-11-06:** Retain Very High, High, Average, Low and Very Low reflex options, default Average, final-summary editing and selection retention through navigation. User: “1. Yes” to first interview.
- **CHAR-010-D02 — 2026-11-06:** Retain coupled combat/progression effects as vanilla baseline. Very High→Very Low melee-timer pre-division adjustments: −900/−450/0/+450/+900; monster attack-component gates: 70/60/50/40/30 percent, distinct from final hit probability; effective practice multipliers: 1.25/1.125/1/0.875/0.75. User: “2. Yes” to first interview. Full combat timing/branch and progression integration remain owner contracts.
- **CHAR-010-D03 — 2026-11-06:** Explain both combat pressure and effective practice effects before confirmation; higher reflexes do not mean faster player movement or input response. User: “3. Yes” to first interview.

- **CHAR-010-D04 — 2026-11-06:** Keep reflex selection fixed after creation initially; final-summary editing remains available. Avoid switching around combat/advancement checks for combined benefits. User: “1. Yes” to second interview.
- **CHAR-010-D05 — 2026-11-06:** Allow validated mod overrides for each of the five options' melee-timer adjustment, monster attack-component chance and practice multiplier. Retain the five options and one coupled setting; require valid probabilities, finite positive practice multipliers and truthful updated descriptions. User: “2. Yes” to second interview.
- **CHAR-010-D06 — 2026-11-06:** Invalid/unsupported saved reflex selections fail validation with actionable error rather than silently substituting Average. Replacement requires explicit SAVE migration/recovery policy. User: “3. Yes” to second interview.

The complete [CHAR-010 specification](systems/CHAR/CHAR-010.md) is approved under CHAR-010-A01 above. No implementation is authorized.

## CHAR-009 interview decisions

- **CHAR-009-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-009 Draft v1. The [specification](systems/CHAR/CHAR-009.md) is finalized v1. Documented feasibility/schema, owner-integration and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-009-D01 — 2026-11-06:** Retain uniform integer starting ranges Primary 28–31, Major 18–21, Minor 13–16 and other skills 3–6. Allow validated mod overrides for those ranges; biography modifiers remain separate from rolled baseline. User: “1. Yes” to first interview.
- **CHAR-009-D02 — 2026-11-06:** Retain six allocation points per tier, no transfers between tiers, one point per increase, refunds only down to rolled baseline and mandatory full allocation. Allow validated mod overrides for each tier pool size. User: “2. Yes” to first interview.
- **CHAR-009-D03 — 2026-11-06:** Generate starting skills once for the compatible creation draft, retain through backtracking and biography-answer edits, and provide no dedicated skill-reroll controls. Biography edits recalculate effects without rerolling skills; Restart clears draft state. User: “3. Yes” to first interview.

- **CHAR-009-D04 — 2026-11-06:** Separately show rolled baseline, allocated points, biography adjustment and resulting starting value, including biography effects on other skills. Apply biography effects once during startup. User: “1. Yes” to second interview.
- **CHAR-009-D05 — 2026-11-06:** Enforce explicit vanilla starting-skill limits 0–100 after allocation and biography effects, with validated mod overrides. No silent clamping/point loss; incompatible biography/content combinations require correction. This deliberately adds authoritative limits beyond the inspected allocation control. User: “2. Yes” to second interview.
- **CHAR-009-D06 — 2026-11-06:** Permit validated added skills in generation/tier selection through stable IDs while keeping CHAR-004's fixed 3/3/6 counts. Added skills outside tiers use resolved other-skill rules. Every supported random outcome must leave sufficient legal capacity for full tier pools. User: “3. Yes” to second interview.

The complete [CHAR-009 specification](systems/CHAR/CHAR-009.md) is approved under CHAR-009-A01 above. No implementation is authorized.

## CHAR-008 interview decisions

- **CHAR-008-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-008 Draft v1. The [specification](systems/CHAR/CHAR-008.md) is finalized v1. Documented numeric/schema/RNG, preview and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-008-D01 — 2026-11-06:** Retain independent uniform integer 0–10 bonuses to each of eight class base attributes and a uniform 6–14 allocation pool. Allow validated mod overrides for bonus ranges, pool range and creation caps, checking compatibility with class bases. User: “1. Yes” to first interview.
- **CHAR-008-D02 — 2026-11-06:** Retain one-point attribute increases, refunds only down to rolled baseline, vanilla cap 100 and mandatory full allocation. Impossible mod configurations fail validation rather than discard points or silently alter values. User: “2. Yes” to first interview.
- **CHAR-008-D03 — 2026-11-06:** Retain unlimited deliberate Reroll and one temporary Save Roll/Load Roll slot storing rolled values, current allocation and remaining pool. Reroll replaces current roll/allocation; navigation does not reroll; Restart/exit clear the slot. User: “3. Yes” to first interview.

- **CHAR-008-D04 — 2026-11-06:** Retain the seven DFU derived previews, updating immediately on allocation, reroll and saved-roll load. Use gameplay owner rules and clearly label previews excluding later effects. User: “1. Yes” to second interview.
- **CHAR-008-D05 — 2026-11-06:** Save Roll replaces the temporary slot; Reroll preserves it; Load restores complete saved state without randomness. Disable empty Load and prevent restoring against different class bases/allocation rules. User: “2. Yes” to second interview.
- **CHAR-008-D06 — 2026-11-06:** Validate every possible configured roll against creation caps and sufficient remaining capacity for the maximum pool. Reject impossible configurations rather than selectively reroll, clamp or lose points; preserve uniform distributions. User: “3. Yes” to second interview.

The complete [CHAR-008 specification](systems/CHAR/CHAR-008.md) is approved under CHAR-008-A01 above. No implementation is authorized.

## CHAR-007 interview decisions

- **CHAR-007-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-007 Draft v1. The [specification](systems/CHAR/CHAR-007.md) is finalized v1. Documented Unicode/resource/UI and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-007-D01 — 2026-11-06:** Require a nonblank name after trimming surrounding whitespace; allow Unicode, spaces, punctuation and duplicate names. Name is display text separate from character/save identity. User: “1. Yes” to first interview.
- **CHAR-007-D02 — 2026-11-06:** Retain the Random name button using explicit race/gender mappings and supported classic patterns with validated mod overrides. Each deliberate click generates an editable suggestion; navigation preserves the current name. Follow DATA-017 isolated randomness/persistent assignment rules. User: “2. Yes” to first interview.
- **CHAR-007-D03 — 2026-11-06:** Retain Previous/Next portrait cycling with wraparound for supported race/gender portraits, initially the ten classic faces. Allow validated mod additions/replacements without hard-coding the count to ten. User: “3. Yes” to first interview.

- **CHAR-007-D04 — 2026-11-06:** Retain free character-sheet renaming during play under the same validation as creation, preserving identity, progress and saved biography history. User: “1. Yes” to second interview.
- **CHAR-007-D05 — 2026-11-06:** Limit ordinary portrait changes to creation and final summary initially; transformations remain CHAR-019 scope. User: “2. Yes” to second interview.
- **CHAR-007-D06 — 2026-11-06:** Failed random naming reports the problem and permits manual entry without another culture's bank substitution. Missing selected portrait requires explicit valid replacement before creation completion or character loading. Use stable portrait IDs so list reordering does not change the face. User: “3. Yes” to second interview. Load-time replacement is an explicit recovery exception to ordinary creation-only portrait changes, subject to CORE/SAVE preflight safety.

- **CHAR-007-D07 — 2026-11-06:** Limit names to 31 visible characters counted as Unicode grapheme clusters. Reject overlong input with an explanation rather than silently truncate; allow wrapping/scrolling in displays. User: “1. Yes” to third interview.
- **CHAR-007-D08 — 2026-11-06:** Retain explicit classic race-name mappings: corresponding banks for Breton, Redguard, Nord, Dark Elf, High Elf, Wood Elf and Khajiit; Imperial bank for Argonian. Allow validated mod overrides. Unknown/missing mappings fail explicitly rather than default to Breton. User: “2. Yes” to third interview.

The complete [CHAR-007 specification](systems/CHAR/CHAR-007.md) is approved under CHAR-007-A01 above. No implementation is authorized.

## CHAR-006 interview decisions

- **CHAR-006-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-006 Draft v1. The [specification](systems/CHAR/CHAR-006.md) is finalized v1. Documented effect/content/RNG, UI and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-006-D01 — 2026-11-06:** Retain manual biography answers and automatic generation. Automatic generation chooses one valid answer per question using the same effect/narrative rules as the manual route. User: “1. Yes” to first interview.
- **CHAR-006-D02 — 2026-11-06:** Retain random selection among valid biography templates for the selected class, preserving the selected template while navigating the current draft. No explicit player template picker is introduced. User: “2. Yes” to first interview.
- **CHAR-006-D03 — 2026-11-06:** Custom classes use greatest skill overlap with preset classes, counting all twelve selected skills equally regardless of tier. Resolve ties by explicit stable classic-class order rather than filesystem order. Missing/invalid required mappings produce an error, not silent unrelated-biography substitution. User: “3. Yes” to first interview. Exact classic-order mapping and content fixtures require verification.

- **CHAR-006-D04 — 2026-11-06:** Allow manual answer revision within the retained template. Rebuild candidate effects/backstory from current answers rather than accumulating bonuses. User: “1. Yes” to second interview.
- **CHAR-006-D05 — 2026-11-06:** Show each answer's known mechanical effects before selection, including skill/reputation/item outcomes where known. Identify genuinely random rewards without disclosing their eventual roll in advance. User: “2. Yes” to second interview.
- **CHAR-006-D06 — 2026-11-06:** After automatic generation show selected answers, backstory and known effects; allow manual editing. Navigation preserves generated answers and any already-resolved random outcomes. No separate reroll button initially. User: “3. Yes” to second interview.

- **CHAR-006-D07 — 2026-11-06:** Retain supported classic biography questions, answers and effect values initially, with validated mod additions/overrides. Unsupported commands require explicit owner review rather than silent ignoring. User: “1. Yes” to third interview.
- **CHAR-006-D08 — 2026-11-06:** Resolve and retain randomized reward outcomes the first time the corresponding answer is selected in a draft. Switching away/back restores that outcome without rerolling; intentionally random exact results remain hidden during creation. User: “2. Yes” to third interview.
- **CHAR-006-D09 — 2026-11-06:** Preserve completed answers, selected template and generated backstory with the character; make the backstory readable after creation. Loading restores them without regenerating rewards or rewriting history from changed definitions. User: “3. Yes” to third interview.

The complete [CHAR-006 specification](systems/CHAR/CHAR-006.md) is approved under CHAR-006-A01 above. No implementation is authorized.

## CHAR-005 interview decisions

- **CHAR-005-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-005 Draft v1. The [specification](systems/CHAR/CHAR-005.md) is finalized v1. Documented runtime-effect/stacking, schema, owner-contract and save-compatibility dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-005-D01 — 2026-11-06:** Retain vanilla HP-per-level default 8, limits 4–30; HP difficulty adjustment H−8 for H≥8, otherwise −2(8−H); total difficulty includes trait costs and must be within −12–40; advancement multiplier 0.3 + 2.7 × (D+12)/52. Allow validated mod overrides for HP defaults/limits, difficulty bounds and advancement endpoints. Invalid configurations fail validation rather than silently clamp. User: “1. Yes” to first interview.
- **CHAR-005-D02 — 2026-11-06:** Retain DFU trait options and point costs initially, including duplicate/conflict restrictions. Allow validated mod changes to costs and supported trait definitions; this does not authorize new executable effects or resolve racial interactions. User: “2. Yes” to first interview. Complete option/cost/conflict inventory remains a verification dependency.
- **CHAR-005-D03 — 2026-11-06:** Retain Merchants, Commoners, Scholars, Nobility and Underworld reputation adjustments, initially zero each, within −10–10 and summing to zero; independent of advancement difficulty. Allow validated mod-configurable defaults, bounds and required total. User: “3. Yes” to first interview.

- **CHAR-005-D04 — 2026-11-06:** Show each trait cost, HP contribution, total difficulty and advancement multiplier live alongside the dagger gauge. Explain that a higher multiplier means more practice is required for skill advancement. User: “1. Yes” to second interview.
- **CHAR-005-D05 — 2026-11-06:** Reject a conflicting new class-trait selection with an explanation; preserve existing choices rather than automatically remove/replace them. User: “2. Yes” to second interview.
- **CHAR-005-D06 — 2026-11-06:** Retain DFU class-selection restrictions without adding birth-race-based bans. Redundant racial/class combinations remain selectable where DFU permits them; actual stacking/precedence requires explicit mechanics-owner resolution. User: “3. Yes” to second interview.

- **CHAR-005-D07 — 2026-11-06:** Retain default maximum seven advantages and seven disadvantages, separately from the difficulty budget; allow validated mod-configurable count limits. User: “1. Yes” to third interview.
- **CHAR-005-D08 — 2026-11-06:** With modded difficulty bounds/endpoints, linearly interpolate between configured advancement endpoints; retain vanilla HP cost slopes +1 above default and −2 below default. Slope overrides are outside the approved scope. User: “2. Yes” to third interview.
- **CHAR-005-D09 — 2026-11-06:** Permit temporarily out-of-range difficulty and unbalanced reputation during editing. Show invalid state immediately and block custom-class completion until both are valid, irrespective of nested-panel close route; do not silently change choices. User: “3. Yes” to third interview.

The complete [CHAR-005 specification](systems/CHAR/CHAR-005.md) is approved under CHAR-005-A01 above. No implementation is authorized.

## CHAR-004 interview decisions

- **CHAR-004-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-004 Draft v1. The [specification](systems/CHAR/CHAR-004.md) is finalized v1. Documented CHAR-005/006, schema/UI and save-compatibility dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-004-D01 — 2026-11-06:** Default custom-class attributes start at 50 each across eight attributes; redistribute within 10–75 with required total 400. Validate actual total and exclude the hidden pool-clearing bypass. Preserve room for modability rather than hard-code these vanilla values as universal restrictions. User: “Yes, but make sure there is room for modability here as well.” Exact supported override scope/validation remains under discussion.
- **CHAR-004-D02 — 2026-11-06:** Require exactly 3 Primary, 3 Major and 6 Minor skills, with no duplicates across groups. Starting values and progression effects remain owner rules. User: “2. Yes” to first interview.
- **CHAR-004-D03 — 2026-11-06:** Require a nonblank custom-class name; allow spaces and Unicode text without requiring uniqueness against preset/other custom-class names. Internal identity remains separate from display name. User: “3. Yes” to first interview.

- **CHAR-004-D04 — 2026-11-06:** Mods may override attribute starting values, per-attribute minimums/maximums and required total through validated definitions. Vanilla defaults remain 50 each, 10–75 and total 400. Reject impossible configurations; new attribute types require a broader system extension. User: “1. Yes” to second interview. Resolves D01's override-scope question.
- **CHAR-004-D05 — 2026-11-06:** Already-assigned skills remain unavailable when changing another slot until replaced in their current slot; no automatic swapping. User: “2. Yes” to second interview.
- **CHAR-004-D06 — 2026-11-06:** Retain the custom-class draft during ordinary creation backtracking, including name, attributes, skills and CHAR-005 choices. Restart/exit discard everything under CHAR-001. User: “3. Yes” to second interview.

The complete [CHAR-004 specification](systems/CHAR/CHAR-004.md) is approved under CHAR-004-A01 above. No implementation is authorized.

## CHAR-003 interview decisions

- **CHAR-003-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-003 Draft v1. The [specification](systems/CHAR/CHAR-003.md) is finalized v1. Documented content-fixture, sampler, UI/media and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-003-D01 — 2026-11-06:** Retain direct preset selection, questionnaire and the Custom entry leading to CHAR-004/005. Initially retain the eighteen classic preset classes. User: “1. Yes” to first interview.
- **CHAR-003-D02 — 2026-11-06:** Retain ten distinct questions from the classic forty-question library, one-point Warrior/Rogue/Mage answer scoring and classic CLASSES.DAT result mapping as the baseline. User: “2. Yes” to first interview. Original content/table verification remains a dependency; this does not adopt incidental filesystem ordering or unverified parser behavior.
- **CHAR-003-D03 — 2026-11-06:** Retain Yes/No confirmation for directly selected and questionnaire-suggested classes. Rejecting a questionnaire suggestion opens the class list rather than automatically committing a class. User: “3. Yes” to first interview.

- **CHAR-003-D04 — 2026-11-06:** Before class confirmation, show the original description plus primary/major/minor skills, equipment restrictions, special advantages/disadvantages, hit points per level and advancement multiplier from the actual class definition. User: “1. Yes” to second interview.
- **CHAR-003-D05 — 2026-11-06:** Allow revisiting/changing questionnaire answers, retain the same ten questions and recalculate scores from current answers. Navigation alone does not reroll. User: “2. Yes” to second interview.
- **CHAR-003-D06 — 2026-11-06:** Missing/invalid required questions or result mappings produce a reported problem and explicit option to return to direct class selection. Never silently substitute a class. Invalid preset definitions remain unavailable until resolved. User: “3. Yes” to second interview. This route-level recovery does not bypass DATA-003 contribution validation/recovery or allow invalid required content to reach entry.

The complete [CHAR-003 specification](systems/CHAR/CHAR-003.md) is approved under CHAR-003-A01 above. No implementation is authorized.

## CHAR-002 interview decisions

- **CHAR-002-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-002 Draft v1. The [specification](systems/CHAR/CHAR-002.md) is finalized v1. Documented owner-resolution, resource and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-002-D01 — 2026-11-06:** Retain Breton, Redguard, Nord, Dark Elf, High Elf, Wood Elf, Khajiit and Argonian as the initial playable roster. Additional races remain a later content/extensibility decision. User: “1. Yes” to first interview.
- **CHAR-002-D02 — 2026-11-06:** Retain home-province map selection, race description, narration and Yes/No race confirmation. Narration failure allows selection to continue. Race confirmation is distinct from CHAR-001's rejected discard confirmations. User: “2. Yes” to first interview.
- **CHAR-002-D03 — 2026-11-06:** Retain Male/Female selection and race-specific face/body sets initially. Independent gender/body/appearance selection is not introduced by this decision. User: “3. Yes” to first interview.

- **CHAR-002-D04 — 2026-11-06:** Retain the verified DFU racial abilities presented in the second interview as the baseline: Breton magic resistance, Nord frost resistance, High Elf paralysis immunity, Dark Elf weapon bonuses, Redguard non-archery weapon bonuses, Wood Elf archery bonuses, Khajiit climbing bonus and Argonian breath/swimming-fatigue benefits. Detailed resolution and stacking remain relevant combat/magic/movement owner rules; do not introduce additional racial attribute adjustments here. User: “1. Yes”.
- **CHAR-002-D05 — 2026-11-06:** Alongside the original race description, show a concise accurate explanation of gameplay benefits before confirmation. Presentation must match implemented rules. User: “2. Yes” to second interview.
- **CHAR-002-D06 — 2026-11-06:** Preserve selected birth race separately from later transformations or magical race overrides. CHAR-019 defines replacement of effective abilities and appearance. User: “3. Yes” to second interview.

The complete [CHAR-002 specification](systems/CHAR/CHAR-002.md) is approved under CHAR-002-A01 above. No implementation is authorized.

## CHAR-001 interview decisions

- **CHAR-001-A01 — 2026-11-06 — Approved.** The user replied “I approve” to the explicit request to finalize CHAR-001 Draft v1. The [specification](systems/CHAR/CHAR-001.md) is finalized v1. Documented individual-choice and UI/media/entry integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

- **CHAR-001-D01 — 2026-11-05:** Retain the DFU creation sequence and branches initially: race, gender, class selection/questionnaire/custom class, biography, name, face, attributes, skills, reflexes, summary. Detailed step mechanics remain separate feature decisions. User: “1. I agree” to first interview.
- **CHAR-001-D02 — 2026-11-05:** Support sequential Back/Next and direct editing of earlier sections from the summary. Retain compatible choices; identify affected sections requiring review after upstream changes. Merely revisiting a section preserves random outcomes; deliberate reroll rules remain separate decisions. User: “2. I agree” to first interview.
- **CHAR-001-D03 — 2026-11-05:** Restart clears the entire draft; leaving character creation discards it. No persistent unfinished-draft resumption. User: “Restart should clear the entire draft, and leaving creating discard it.” Confirmation behavior remains to be clarified because this answer did not explicitly accept the proposed confirmation.

- **CHAR-001-D04 — 2026-11-06:** Restart and leaving creation discard the draft without a confirmation prompt. User: “1. No” to second interview. Resolves the confirmation question in D03.
- **CHAR-001-D05 — 2026-11-06:** Reject the proposed warning/affected-section correction flow for upstream race/class changes. User: “No, because this isn't really a thing that can happen in the regular sequence of character creation in Daggerfall.” Do not impose that proposed flow. Exact scope of direct summary editing under D02 remains to be clarified; this does not silently revoke D02 or authorize incompatible final data.
- **CHAR-001-D06 — 2026-11-06:** Summary shows all creation choices and their known starting effects, with editable section links and a single Begin Game action. Identify invalid/incomplete sections and block submission. Disclosure of hidden/random biography outcomes remains CHAR-006 scope. User: “3. I agree” to second interview. Which sections are directly editable remains the D02/D05 clarification.

- **CHAR-001-D07 — 2026-11-06:** Restrict direct summary edits to name, face, attributes, skills and reflexes. Changing race, gender, class or biography after reaching summary requires Restart. User: “1. Yes” to third interview. This clarifies and supersedes D02's broader summary-edit wording and resolves D05/D06's edit-scope question. Ordinary sequential navigation remains supported; do not add the rejected dependency-warning flow.
- **CHAR-001-D08 — 2026-11-06:** After Begin Game, retain DFU's three-video sequence when videos are enabled; allow each video to be skipped and continue safely if optional playback fails. User: “2. Yes” to third interview. DATA-001 optional-media requirements and CORE entry safety remain binding.

The complete [CHAR-001 specification](systems/CHAR/CHAR-001.md) is approved under CHAR-001-A01 above. Historical interview ambiguities are resolved by D04/D07 and the finalized specification. No implementation is authorized.

## DATA-024 interview decisions

- **DATA-024-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-024 Draft v1. The [specification](systems/DATA/DATA-024.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including scope schemas, transition/cache behavior and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-024-D04 — 2026-11-05:** WORLD/LOC may select already installed/validated variants during play through explicit transitions. Validate geometry, player placement, quest bindings and persistent object state before success; gate affected gameplay during reconstruction. Installed content remains locked. User: “1. I agree” to second interview.
- **DATA-024-D05 — 2026-11-05:** Separate DATA-003 definition precedence from selection scope. Explicit placement-specific selection overrides a declared location-wide/global default for that target. Incompatible overlaps fail rather than accidentally merge layouts; exact combinations remain WORLD/LOC-owned. User: “2. I agree” to second interview.
- **DATA-024-D06 — 2026-11-05:** Returning to baseline/default is an explicit validated operation accounting for saved objects, quests and placement like any layout transition. Missing selected content never implicitly clears selection. User: “3. I agree” to second interview.

- **DATA-024-D01 — 2026-11-05:** Separate installed replacement/variant definitions from session-selected world variants. DATA resolves validated definitions; WORLD/LOC own selection changes and SAVE persists required selections. New characters cannot inherit prior-character choices. User: “1. I agree” to first interview.
- **DATA-024-D02 — 2026-11-05:** Use stable variant IDs and explicit location/block-placement/building-record context under DATA-004/005. No last-queried-location dependency. Repeated placements select independently where declared scope permits. User: “2. I agree” to first interview.
- **DATA-024-D03 — 2026-11-05:** Validate/restore required saved variant selections before affected geometry construction, quest-resource binding and player placement. Missing/incompatible required variants require explicit migration or load failure, not silent alternate-layout continuation. User: “3. I agree” to first interview.

The complete DATA-024 specification is approved under DATA-024-A01 above. These decisions do not authorize implementation.

## DATA-023 interview decisions

- **DATA-023-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-023 Draft v1. The [specification](systems/DATA/DATA-023.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including AV/platform formats, synthesis, playback policies and save contracts. Approved optional-video and death-video bypass rules remain binding. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-023-D04 — 2026-11-05:** Absent replacement uses supported original media. Present invalid selected replacement follows DATA-003 explicit recovery rather than silent asset substitution. Approved playback-specific recovery, especially CORE-008 death-video bypass, takes precedence when playback fails. User: “1. I agree” to second interview.
- **DATA-023-D05 — 2026-11-05:** Requesting features declare media requiredness/failure policy. Silent continuation is allowed only by explicit optional-media policy; missing audio does not erase gameplay events or count as completed playback. Videos remain optional for startup under DATA-001. User: “2. I agree” to second interview.
- **DATA-023-D06 — 2026-11-05:** Share reusable decoded media separately from playback position/loop/instance state. Cache by source and relevant decoding/sound-font inputs. Streaming/full loading remain measured AV choices. Verify classic/replacement sound/MIDI/video timing, channels, synchronization, failures and independent instances. User: “3. I agree” to second interview.

- **DATA-023-D01 — 2026-11-05:** Use stable domain-scoped sound/music/video IDs with explicit classic ID/index/name mappings. Mod additions avoid filename collisions/classic index limits. Logical playback references resolve validated sources under DATA-003. User: “1. I agree” to first interview.
- **DATA-023-D02 — 2026-11-05:** DATA resolves sources and provides supported decoded data/decoder inputs. AV/UI own playback, volume, loops, scheduling, skipping and completion. Finding/loading media alone neither proves playback success nor advances quests. User: “2. I agree” to first interview.
- **DATA-023-D03 — 2026-11-05:** Supported classic media/timing metadata are the baseline with validated replacements. Explicitly declare codec/channel/sample-rate/synchronization and MIDI sound-font requirements. Unsupported input fails truthfully, not extension-only success. Exact formats require AV/platform verification. User: “3. I agree” to first interview.

The complete DATA-023 specification is approved under DATA-023-A01 above. These decisions do not authorize implementation.

## DATA-022 interview decisions

- **DATA-022-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-022 Draft v1. The [specification](systems/DATA/DATA-022.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including format schemas, variant/animation rules, AV/provider contracts and verification fixtures. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-022-D04 — 2026-11-05:** Absent replacement uses classic imagery; present invalid selected replacement uses DATA-003 explicit recovery rather than silent earlier-asset fallback. Missing required imagery fails affected preparation; optional presentation uses only approved owner fallback. User: “1. I agree” to second interview.
- **DATA-022-D05 — 2026-11-05:** Missing optional normal/emission maps may use declared material policy. Missing required frames/incompatible supplied maps fail. Static substitution for animated resources needs explicit support, not accidental single-frame freezing. User: “2. I agree” to second interview.
- **DATA-022-D06 — 2026-11-05:** Cache identity includes source and all result-changing palette/alpha/frame/dye/variant/conversion inputs. Verify orientation/color/transparency/animation/UV alignment and instance isolation. Filtering/compression/atlas strategy remain measured AV decisions. User: “3. I agree” to second interview.

- **DATA-022-D01 — 2026-11-05:** Use stable image/material IDs with explicit classic file/archive/record/frame mappings. Preserve supported palette, transparency, dimensions and animation structure as baseline; allow validated higher-resolution replacements beyond classic packed-key limits. User: “1. I agree” to first interview.
- **DATA-022-D02 — 2026-11-05:** Use explicit supported climate/season/dye/other visual selectors without changing underlying climate, item identity or gameplay state. Shared resources cannot let one item's dye recolor unrelated instances. Exact variant behavior remains owner-defined. User: “2. I agree” to first interview.
- **DATA-022-D03 — 2026-11-05:** Distinguish pixel replacements, optional material maps and whole-material replacements. Declare required inputs and compatible dimension/UV/frame relationships; no arbitrary inferred shader/gameplay behavior. Apply DATA-003 precedence and DATA-021 visual/gameplay boundaries. User: “3. I agree” to first interview.

The complete DATA-022 specification is approved under DATA-022-A01 above. These decisions do not authorize implementation.

## DATA-021 interview decisions

- **DATA-021-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-021 Draft v1. The [specification](systems/DATA/DATA-021.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including conversion fidelity, representation compatibility, variant/cache rules and save contracts. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-021-D04 — 2026-11-05:** Absent replacement uses classic geometry. Present but invalid selected replacement reports failure and uses DATA-003 explicit recovery, not silent fallback. Missing required geometry fails location preparation under DATA-005. User: “1. I agree” to second interview.
- **DATA-021-D05 — 2026-11-05:** Supported climate/season/other variants use explicit deterministic selection rules. World/collision/automap representations remain compatible for the same placed object; visual variants cannot silently move interactions or alter gameplay geometry. Exact variant rules remain owner-defined. User: “2. I agree” to second interview.
- **DATA-021-D06 — 2026-11-05:** Cache reusable geometry by stable model identity, resolved source and relevant conversion/variant inputs. Separate mutable instance state and invalidate affected pre-menu candidate caches. Memory/eviction are measured implementation choices; stale replacements must not survive source changes. User: “3. I agree” to second interview.

- **DATA-021-D01 — 2026-11-05:** Preserve supported classic geometry, scale/orientation, surface/material references and placement relationships as the baseline. Godot representation may differ; verify winding, normals, UVs and alignment rather than approximate appearance alone. User: “1. I agree” to first interview.
- **DATA-021-D02 — 2026-11-05:** Use stable model-resource IDs with explicit classic mappings, separate from DATA-005 placement/record identity. Appearance replacement does not create a new door/building/quest object; shared meshes do not share mutable instance state. User: “2. I agree” to first interview.
- **DATA-021-D03 — 2026-11-05:** Distinguish visual replacements from collision, interaction bounds, markers and action changes. Visual substitution preserves required gameplay contracts; gameplay-affecting changes need explicit supported definitions and owner validation rather than automatic imported-scene behavior. User: “3. I agree” to first interview.

The complete DATA-021 specification is approved under DATA-021-A01 above. These decisions do not authorize implementation.

## DATA-020 interview decisions

- **DATA-020-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-020 Draft v1. The [specification](systems/DATA/DATA-020.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including codec schemas, import persistence, review metadata and verification fixtures. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-020-D04 — 2026-11-05:** Match repeat imports by stable keys/explicit source mappings. Unchanged reimports make no changes/duplicates; rename/reorder cannot retarget translations silently. Ambiguous mappings need resolution. User: “1. I agree” to second interview.
- **DATA-020-D05 — 2026-11-05:** Retain translation text and mark needs review when source meaning/placeholders/required structure changes. Do not automatically overwrite/delete translations for changed/removed sources. Unusable translations retain DATA-013 validation/fallback. User: “2. I agree” to second interview.
- **DATA-020-D06 — 2026-11-05:** Verify structural round trips and rendered samples for whitespace, escapes, variants, input controls, multiline macros and supported scripts. Diagnose source/key/token location. Preview/validation does not generate names, consume gameplay randomness or execute quest actions. User: “3. I agree” to second interview.

- **DATA-020-D01 — 2026-11-05:** Supported source/editable/structured round trips preserve meaningful text, whitespace, formatting operands, variant boundaries and required interaction structure. Equivalent normalization is allowed; byte identity is unnecessary. Unsupported required tokens fail rather than disappear. User: “1. I agree” to first interview.
- **DATA-020-D02 — 2026-11-05:** Use documented human-editable markup with literal escaping and DATA-016 macro/required-placeholder validation. Editorial wrapping is distinguishable from displayed line breaks. User: “2. I agree” to first interview.
- **DATA-020-D03 — 2026-11-05:** Imports explicitly identify collection/locale/source mappings and preview additions/replacements/conflicts before bulk commit. Preserve existing translations unless replacement is selected; invalid imports publish no partial changes. Original files remain read-only. User: “3. I agree” to first interview.

The complete DATA-020 specification is approved under DATA-020-A01 above. These decisions do not authorize implementation.

## DATA-019 interview decisions

- **DATA-019-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-019 Draft v1. The [specification](systems/DATA/DATA-019.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including font-resource schemas, language coverage, layout/settings integration and rendered verification. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-019-D04 — 2026-11-05:** Exhausted ordinary glyph fallback displays a visible replacement marker with diagnostics, without silent omission/guessed transliteration. Essential prompts that cannot remain understandable use bundled readable text or recovery. User: “1. I agree” to second interview.
- **DATA-019-D05 — 2026-11-05:** Measure/wrap using actual primary/fallback fonts; reflow text/book pages while preserving option identity, focus and meaningful structure. Do not clip required instructions or shrink indefinitely to preserve classic boxes. User: “2. I agree” to second interview.
- **DATA-019-D06 — 2026-11-05:** Validate font assets, role mappings and fallback chains before publication, rejecting cycles. Live locale changes use validated resources; font-pack installation/replacement follows DATA-003 lock. Rendered checks cover mixed languages, long labels, required scripts and independent recovery controls. User: “3. I agree” to second interview.

- **DATA-019-D01 — 2026-11-05:** Use explicit locale/role mappings and stable font-resource references with validated mod overrides. Classic styling is the baseline where practical; added fonts are not limited to classic glyph counts or five font names. User: “1. I agree” to first interview.
- **DATA-019-D02 — 2026-11-05:** Use declared fallback-font chains supporting mixed-language text, including DATA-013 base-language fallback. Missing characters never silently disappear. Essential controls retain bundled readable presentation independent of ARENA2/optional font packs. User: “2. I agree” to first interview.
- **DATA-019-D03 — 2026-11-05:** Use Unicode-capable rendering supporting shaping, combining marks and right-to-left text when required by an offered language. Advertise language support only after required fonts/layout verify; no commitment to shipping every language initially. User: “3. I agree” to first interview.

The complete DATA-019 specification is approved under DATA-019-A01 above. These decisions do not authorize implementation.

## DATA-018 interview decisions

- **DATA-018-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-018 Draft v1. The [specification](systems/DATA/DATA-018.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including edition schemas, rendering, reading-effect triggers and bookmark/save contracts. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-018-D04 — 2026-11-05:** Validate required metadata, readable body and supported formatting before edition usability. Malformed editions invoke whole-edition fallback with diagnostics; existence alone is insufficient. Preserve supported original layout meaning, allowing UI repagination for language/display. User: “1. I agree” to second interview.
- **DATA-018-D05 — 2026-11-05:** Missing readable content produces explicit unavailable result while retaining inventory item. No silent deletion/substitution or successful-read outcome on failed opening. Owners distinguish failure for reading-triggered quest/skill effects. User: “2. I agree” to second interview.
- **DATA-018-D06 — 2026-11-05:** Retain reading position through stable chapter/section anchors where supported, not raw page number alone. Language/edition changes use verified corresponding anchors; without one, reopen at beginning with notice. Exact bookmark persistence remains UI/SAVE-owned. User: “3. I agree” to second interview.

- **DATA-018-D01 — 2026-11-05:** Stable book/work ID is separate from item instance, filename, title and localized edition. Translations normally share work identity; intentionally different books receive separate IDs. Preserve classic mappings and validated mod additions. User: “1. I agree” to first interview.
- **DATA-018-D02 — 2026-11-05:** Select a complete usable edition through DATA-013 language fallback, with explicitly mapped classic source fallback. Do not silently combine chapters across editions. Apply DATA-003 precedence within each declared edition target. User: “2. I agree” to first interview.
- **DATA-018-D03 — 2026-11-05:** Translations control supported title/author presentation, body and formatting; shared price/distribution/uniqueness/availability belong to ITEM/ECON/QUEST definitions. Language changes do not change value or loot eligibility. User: “3. I agree” to first interview.

The complete DATA-018 specification is approved under DATA-018-A01 above. These decisions do not authorize implementation.

## DATA-017 interview decisions

- **DATA-017-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-017 Draft v1. The [specification](systems/DATA/DATA-017.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including naming patterns/mappings, randomness, localized presentation and versioned persistence. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-017-D04 — 2026-11-05:** Validate required component sets, supported composition and mapping references before publication. Declared absent surnames are valid; accidentally empty required sets fail. Preserve authored Unicode/punctuation/spacing under pattern rules. User: “1. I agree” to second interview.
- **DATA-017-D05 — 2026-11-05:** Bank edits affect future generation, retaining names already assigned to persistent entities. Seed-based reconstruction must preserve results or sufficient versioned generation data so changed banks do not silently rename existing entities. User: “2. I agree” to second interview.
- **DATA-017-D06 — 2026-11-05:** Report bank/pattern/missing component or mapping on failure. Author previews use isolated test seeds/random sources without affecting gameplay generation. No cross-culture retry without declared fallback. User: “3. I agree” to second interview.

- **DATA-017-D01 — 2026-11-05:** Use stable extensible name-bank IDs and explicit race/region/caller-purpose mappings. Mods may add banks and supported naming patterns without extending a hard-coded classic enum. Missing mapping uses a declared fallback or failure, not automatic Breton selection. User: “1. I agree” to first interview.
- **DATA-017-D02 — 2026-11-05:** Retain generated names for owning persons/places/quest resources across saves/locales. Entity identity is separate; duplicate names are allowed. Localization changes presentation only through an explicit supported policy without generating a different identity. User: “2. I agree” to first interview.
- **DATA-017-D03 — 2026-11-05:** Supported classic name parts/composition are the overridable baseline; mappings/probabilities require owner review. Generation uses owned randomness or deterministic identity rules. Bank reads, display and language refresh do not reseed/consume shared gameplay randomness. User: “3. I agree” to first interview.

The complete DATA-017 specification is approved under DATA-017-A01 above. These decisions do not authorize implementation.

## DATA-016 interview decisions

- **DATA-016-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-016 Draft v1. The [specification](systems/DATA/DATA-016.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including context/provider schemas, macro grammar, randomness, reveal commits and save policies. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-016-D04 — 2026-11-05:** Unknown macros/missing required values make messages unusable under DATA-013/015 fallback. Optional values use only declared defaults/suppression. No silent raw macro codes or empty required instructions. User: “1. I agree” to second interview.
- **DATA-016-D05 — 2026-11-05:** Support multiple declared multiline substitutions while preserving token structure. Ordinary inserted values are literal, including percent signs/markup. Nested expansion needs explicit supported syntax and bounded evaluation rather than automatic recursion. User: “2. I agree” to second interview.
- **DATA-016-D06 — 2026-11-05:** Document a macro registry with symbol meaning, required context, output type and optional fallback. Validate templates/translations against it with message/symbol/requirement diagnostics. Custom macros require registration and the same side-effect-free contract. User: “3. I agree” to second interview.

- **DATA-016-D01 — 2026-11-05:** Expand macros from supplied scoped message/quest context, not whichever NPC/location/quest is globally current. Missing required context is explicit failure, not unrelated substitute data. User: “1. I agree” to first interview.
- **DATA-016-D02 — 2026-11-05:** Expansion is side-effect-free. QUEST/NPC explicitly commit intended dialogue-link reveals through separate owner operations; preview/validation/translation/rerender do not reveal information or repeat gameplay effects. User: “2. I agree” to first interview.
- **DATA-016-D03 — 2026-11-05:** Resolve repeated references consistently within a message and retain chosen/generated values for its lifetime. Language refresh does not regenerate identities or consume gameplay randomness. Generation uses owned randomness or deterministic identity rules rather than reseeding shared randomness. User: “3. I agree” to first interview.

The complete DATA-016 specification is approved under DATA-016-A01 above. These decisions do not authorize implementation.

## DATA-015 interview decisions

- **DATA-015-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-015 Draft v1. The [specification](systems/DATA/DATA-015.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including token/rendering support, variant identity and randomness, prompt recovery and save policies. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-015-D04 — 2026-11-05:** Malformed tokens or unsupported meaning/interaction controls make a message unusable and invoke approved fallback. Decorative degradation requires explicit UI approval; required page/input structure must not be silently dropped. User: “1. I agree” to second interview.
- **DATA-015-D05 — 2026-11-05:** Exclude accidentally empty variants from random selection with diagnostics. Intentional silence needs an explicit supported designation. No usable variants invokes message fallback, not neighboring-variant substitution or invalid indexing. User: “2. I agree” to second interview.
- **DATA-015-D06 — 2026-11-05:** UI/requesting owners retain choice/input identity and validation. Tokens present information without independently accepting choices, submitting input or deciding gameplay. Unrenderable essential interaction structure requires usable recovery rather than blank/misleading prompts. User: “3. I agree” to second interview.

- **DATA-015-D01 — 2026-11-05:** Preserve supported classic formatting/message boundaries structurally rather than flattening to plain text. Godot rendering may differ while preserving meaning, reading order and required interaction controls. User: “1. I agree” to first interview.
- **DATA-015-D02 — 2026-11-05:** Follow DATA-013 selected/base/explicit-source fallback. Explicit numeric classic mappings may supply TEXT.RSC source fallback; new string-keyed messages require declared fallback without guessing a numeric record. User: “2. I agree” to first interview.
- **DATA-015-D03 — 2026-11-05:** Expose authored variants separately from selection. Requesting owners choose a specific variant or random choice using an explicitly owned random source. Reading/validation/rerendering must not silently consume gameplay randomness or reroll messages. User: “3. I agree” to first interview.

The complete DATA-015 specification is approved under DATA-015-A01 above. These decisions do not authorize implementation.

## DATA-014 interview decisions

- **DATA-014-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-014 Draft v1. The [specification](systems/DATA/DATA-014.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including CSV schemas, normalization, token validation and integration fixtures. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-014-D04 — 2026-11-05:** Support UTF-8 CSV with documented header/schema, quoted commas, escaped quotes, multiline values and common Windows/Unix line endings. Preserve meaningful whitespace rather than indiscriminate trimming. User: “1. I agree” to second interview.
- **DATA-014-D05 — 2026-11-05:** Malformed CSV, invalid operations, duplicate targets or missing required targeting fields reject the whole file with file/row/reason diagnostics. No silent row skipping or partial publication; omission requires DATA-003 explicit recovery. User: “2. I agree” to second interview.
- **DATA-014-D06 — 2026-11-05:** Distinguish structural patch errors from text usability. A structurally valid patch with invalid placeholders/formatting marks its entry unusable and follows DATA-013 language fallback, without revealing an earlier same-language value it replaced. Diagnose source/key. User: “3. I agree” to second interview.

- **DATA-014-D01 — 2026-11-05:** Patches explicitly target collection/domain and locale, retaining package provenance. Base-language patches target that declared language explicitly; one locale's patch must not accidentally modify another table. User: “1. I agree” to first interview.
- **DATA-014-D02 — 2026-11-05:** Use explicit add/replace operations. Adding an existing target key or replacing a missing one is invalid. Blank values and optional suppression retain DATA-013 policy. User: “2. I agree” to first interview.
- **DATA-014-D03 — 2026-11-05:** Apply DATA-003 precedence: shipped content, enabled mods, then explicit loose overrides; later valid replacements win. Reject duplicate target keys within one CSV file; intentional successive replacements may use separately ordered contributions. User: “3. I agree” to first interview.

The complete DATA-014 specification is approved under DATA-014-A01 above. These decisions do not authorize implementation.

## DATA-013 interview decisions

- **DATA-013-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-013 Draft v1. The [specification](systems/DATA/DATA-013.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including catalog schemas, token/font support, settings integration, UI refresh and historical-text policies. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-013-D04 — 2026-11-05:** Allow settings-based language switching without restart among already loaded/validated language resources. Refresh ordinary UI without restarting quests, repeating rewards or changing pending choices. Installed language-pack/mod-order changes retain DATA-003 lock rules. User: “1. I agree” to second interview.
- **DATA-013-D05 — 2026-11-05:** Blank entries count as missing by default and use fallback. Intentional suppression requires explicit supported designation for optional text; essential control labels cannot be suppressed. User: “2. I agree” to second interview.
- **DATA-013-D06 — 2026-11-05:** Validate required placeholders/supported formatting before use. Invalid selected-language entries report diagnostics and continue through fallback rather than losing values/showing broken formatting. Translation cannot execute new gameplay commands; token/markup contracts remain DATA-015/016/UI-owned. User: “3. I agree” to second interview.

- **DATA-013-D01 — 2026-11-05:** Use stable text keys scoped by collection/domain, retaining package provenance for overrides. Wording/translation does not change gameplay or choice identity. Localization is presentation, not executable gameplay rules. User: “1. I agree” to first interview.
- **DATA-013-D02 — 2026-11-05:** Fallback order is selected language, declared content base language, then explicitly supplied source/caller fallback. Incomplete translations may mix languages; mods declare base language rather than being assumed English. User: “2. I agree” to first interview.
- **DATA-013-D03 — 2026-11-05:** Exhausted ordinary-text fallback shows a visible placeholder and missing-key diagnostics without repeated blocking popups. Essential startup/recovery controls have bundled usable labels independent of ARENA2/optional language packs. Missing text cannot turn failed/blocked operations into success. User: “3. I agree” to first interview.

The complete DATA-013 specification is approved under DATA-013-A01 above. These decisions do not authorize implementation.

## DATA-012 interview decisions

- **DATA-012-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-012 Draft v1. The [specification](systems/DATA/DATA-012.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including source schemas, QUEST validation/provider rules, selection behavior and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-012-D04 — 2026-11-05:** Reject duplicate entries for the same quest within one selection list unless QUEST explicitly defines supported weighting/variant semantics. Deliberate inclusion in different lists is allowed. User: “1. I agree” to second interview.
- **DATA-012-D05 — 2026-11-05:** Unrecognized executable commands fail validation rather than being ignored. Comments/explicitly supported optional constructs remain valid; custom commands require registered QUEST/MOD support before validation succeeds. User: “2. I agree” to second interview.
- **DATA-012-D06 — 2026-11-05:** SAVE/QUEST validate changed definitions against active quests and persistent one-time/completion records. Same ID does not prove task/resource compatibility; require explicit migration/failure rather than silent restart, progress loss or repeated rewards. User: “3. I agree” to second interview.

- **DATA-012-D01 — 2026-11-05:** Use stable domain-scoped IDs for quest definitions/lists/shared tables with explicit classic-name mappings. New quest addition and existing quest replacement are distinct; matching filenames alone must not accidentally replace unrelated pack content. Apply DATA-003 operations/precedence. User: “1. I agree” to first interview.
- **DATA-012-D02 — 2026-11-05:** DATA owns source resolution/provenance/delivery; QUEST owns grammar, semantic validation, eligibility, selection and execution. Reading/validation must not start quests, grant rewards or mark one-time acceptance. User: “2. I agree” to first interview.
- **DATA-012-D03 — 2026-11-05:** Distinguish missing, unreadable, empty and malformed/unsupported sources instead of successful empty results. Referenced required scripts/tables validate before usable publication, with QUEST grammar/reference checks. Invalid contributions follow DATA-003 explicit recovery. User: “3. I agree” to first interview.

The complete DATA-012 specification is approved under DATA-012-A01 above. These decisions do not authorize implementation.

## DATA-011 interview decisions

- **DATA-011-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-011 Draft v1. The [specification](systems/DATA/DATA-011.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including mapping schemas, individual classic correction approval, MAGIC rules and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-011-D04 — 2026-11-05:** Preserve colliding classic spell records as distinct stable IDs. A shared-index-only lookup reports ambiguity unless an explicit contextual mapping resolves it. Native quests/items/saves use stable IDs; insufficient legacy context requires review. User: “1. I agree” to second interview.
- **DATA-011-D05 — 2026-11-05:** Approved classic corrections are documented baseline patches before mod/loose overrides, conditional on expected faulty data to avoid changing externally modified spells accidentally. Later intentional overrides win. Individual corrections still require verification/approval; only the mechanism is approved here. User: “2. I agree” to second interview.
- **DATA-011-D06 — 2026-11-05:** SAVE/MAGIC validate compatibility of learned spells, enchanted-item references and active effects after changes. Same ID does not authorize replacing saved parameters or restarting effects. Unsupported changes require migration/failure rather than silent substitution or effect loss. User: “3. I agree” to second interview.

- **DATA-011-D01 — 2026-11-05:** Use stable spell IDs independent of names, list positions and classic byte-sized indexes, with explicit classic mappings and validated mod additions. Classic collisions require explicit disambiguation rather than silently discarding a spell. User: “1. I agree” to first interview.
- **DATA-011-D02 — 2026-11-05:** Reject runtime spell conversion if any authored active effect lacks a supported mapping; do not silently create a reduced/different spell. Unused classic slots remain valid. Optional icons/text may use separately approved presentation fallback. User: “2. I agree” to first interview.
- **DATA-011-D03 — 2026-11-05:** Supported classic spell fields form the overridable baseline. MAGIC owns costs, scaling, stacking, targeting and execution. DATA reading/conversion neither casts nor mutates shared source records. Known classic corrections must be explicit documented content rules rather than hidden converter mutations. User: “3. I agree” to first interview.

The complete DATA-011 specification is approved under DATA-011-A01 above. These decisions do not authorize implementation.

## DATA-010 interview decisions

- **DATA-010-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-010 Draft v1. The [specification](systems/DATA/DATA-010.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including template schemas, provenance, balance rules, behavior-provider contracts and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-010-D04 — 2026-11-05:** Reject duplicate IDs, ambiguous classic mappings and missing required base-item/material/enchantment references before definition publication. Required lookup failures are explicit rather than empty templates. Legitimate no-enchantment/zero values remain valid where the schema permits. User: “1. I agree” to second interview.
- **DATA-010-D05 — 2026-11-05:** Allow data-only item additions using existing supported behavior. Special behavior requires an explicit registered/validated provider; missing required providers fail rather than silently becoming generic items. Executable registration/lifecycle remain MOD/ITEM-owned. User: “2. I agree” to second interview.
- **DATA-010-D06 — 2026-11-05:** SAVE/ITEM/MAGIC explicitly validate saved-item compatibility after template changes/removal. Same template ID alone is insufficient; unsupported changes require defined migration or failure. No silent name substitution, item discard or condition/enchantment reset. User: “3. I agree” to second interview.

- **DATA-010-D01 — 2026-11-05:** Use stable domain-scoped item/magic-item template IDs with explicit classic index/group mappings. Mod additions do not depend on list positions or uncoordinated numeric ranges. Names/texture changes alone preserve identity. User: “1. I agree” to first interview.
- **DATA-010-D02 — 2026-11-05:** Separate reusable templates from instance quantity, condition, ownership and other mutable state. ITEM/MAGIC define copied/derived/persisted properties; template changes do not automatically authorize rewriting existing instances. User: “2. I agree” to first interview.
- **DATA-010-D03 — 2026-11-05:** Supported classic template fields and magic-item definitions form the initial baseline with validated overrides. Pricing, equipment rules, enchantment behavior, artifact uniqueness and loot distribution remain ITEM/MAGIC/ECON decisions. User: “3. I agree” to first interview.

The complete DATA-010 specification is approved under DATA-010-A01 above. These decisions do not authorize implementation.

## DATA-009 interview decisions

- **DATA-009-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-009 Draft v1. The [specification](systems/DATA/DATA-009.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including baseline/schema verification, FACT relationship rules and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-009-D04 — 2026-11-05:** Require valid parent references, permit explicit roots, and reject self-parenting/parent cycles. Derive child lists from validated parents without accumulating duplicates on repeated initialization. User: “1. I agree” to second interview.
- **DATA-009-D05 — 2026-11-05:** Preserve authored ally/enemy direction without automatic reciprocity. DATA validates targets; FACT defines reciprocity, relationship conflicts and effects. Relationship cycles are not inherently invalid like parent cycles. User: “2. I agree” to second interview.
- **DATA-009-D06 — 2026-11-05:** Reject duplicate faction IDs, ambiguous classic mappings and missing required faction references before definition publication, allowing explicit DATA-003 replacements. Removed factions referenced by older saves produce explicit compatibility failure for SAVE/FACT; no name matching or silent reputation reset. User: “3. I agree” to second interview.

- **DATA-009-D01 — 2026-11-05:** Use stable faction IDs with explicit classic-ID mappings. Duplicate/localized/renamed display names do not change identity; gameplay, quests and saves use IDs. Mods can add factions without relying on an uncoordinated shared numeric range. User: “1. I agree” to first interview.
- **DATA-009-D02 — 2026-11-05:** Separate authored faction definitions/starting defaults from character/session reputation, memberships, ranks and changing political state. FACT and relevant owners decide mutable fields and persist changes without modifying shared definitions. User: “2. I agree” to first interview.
- **DATA-009-D03 — 2026-11-05:** Supported classic faction metadata and authored relationships form the initial baseline with explicit validated overrides. Reputation propagation, alliances, guild eligibility, services and political simulation remain owner decisions rather than automatic data-format adoption. User: “3. I agree” to first interview.

The complete DATA-009 specification is approved under DATA-009-A01 above. These decisions do not authorize implementation.

## DATA-008 interview decisions

- **DATA-008-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-008 Draft v1. The [specification](systems/DATA/DATA-008.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including effect schemas, balance/randomization policies, biography selection, narrative and save contracts. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-008-D04 — 2026-11-05:** Custom-class biography selection is an explicit CHAR-owned rule returning a biography-set ID. DATA supports declared class/biography mappings without silently selecting the first classic class on no match. Retention of DFU skill-affinity selection remains a CHAR decision. User: “1. I agree” to second interview.
- **DATA-008-D05 — 2026-11-05:** Reject malformed commands, unsupported required effect types and missing required targets before character mutation. Apply DATA-003 whole-contribution rejection and CORE-012 required-effect failure rather than ignoring effects or partially applying an answer. User: “2. I agree” to second interview.
- **DATA-008-D06 — 2026-11-05:** Preview and final application use the same validated effect definitions and owner rules. Answer changes recompute a separate candidate result without accumulating rewards. Randomized preview/application behavior requires explicit CHAR policy; previews are not required to reveal every outcome. User: “3. I agree” to second interview.

- **DATA-008-D01 — 2026-11-05:** DATA decodes/validates class and biography definitions; CHAR and other effect owners calculate/apply consequences. Definition reads and answer previews must not mutate a live character. User: “1. I agree” to first interview.
- **DATA-008-D02 — 2026-11-05:** Use stable IDs for classes, biography sets, questions and answers, with explicit supported effect types/target IDs and classic mappings. Allow validated additions beyond classic filenames/fixed question counts. Reordering or translating questions preserves identity. User: “2. I agree” to first interview.
- **DATA-008-D03 — 2026-11-05:** Supported classic class fields, biography choices and effects form the initial content baseline with explicit validated overrides. Exact values, custom-class legality, stacking and balance remain domain-owner decisions, not importer approval. User: “3. I agree” to first interview.

The complete DATA-008 specification is approved under DATA-008-A01 above. These decisions do not authorize implementation.

## DATA-007 interview decisions

- **DATA-007-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-007 Draft v1. The [specification](systems/DATA/DATA-007.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including consumer coverage, enemy-property provenance, metadata schemas and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-007-D04 — 2026-11-05:** Distinguish optional presentation metadata from required gameplay data. Missing portraits may use an explicitly approved NPC/UI fallback; missing required monster definitions fail affected spawning/preparation. DATA reports failure rather than inventing stats, gender, faction or behavior. User: “1. I agree” to second interview.
- **DATA-007-D05 — 2026-11-05:** Reject ambiguous classic-ID mappings and duplicate definition IDs, allowing explicit replacements under DATA-003. Multiple gameplay definitions may explicitly share appearance provided legacy lookup remains unambiguous. User: “2. I agree” to second interview.
- **DATA-007-D06 — 2026-11-05:** Preserve or safely skip uninterpreted classic fields when supported behavior is unaffected. Required unsupported semantics fail explicitly. Document uncertainty rather than invent meanings for fields not understood by source readers. User: “3. I agree” to second interview.

- **DATA-007-D01 — 2026-11-05:** Preserve supported classic object/monster metadata and references as the baseline; NPC behavior, encounter selection, spawning, combat balance and painting-description generation remain owner responsibilities. Incomplete classic readers are not complete gameplay specifications. User: “1. I agree” to first interview.
- **DATA-007-D02 — 2026-11-05:** Use stable domain-scoped definition IDs with explicit mappings from classic archive/record pairs and monster identifiers. Mods may add definitions without classic flat-ID packing limits. Portrait/sprite changes alone do not change NPC/monster definition identity. User: “2. I agree” to first interview.
- **DATA-007-D03 — 2026-11-05:** Link appearance and gameplay definitions explicitly. Shared sprites do not imply shared behavior, faction, stats or live state; visual replacement and new creatures must not accidentally change unrelated gameplay. User: “3. I agree” to first interview.

The complete DATA-007 specification is approved under DATA-007-A01 above. These decisions do not authorize implementation.

## DATA-006 interview decisions

- **DATA-006-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-006 Draft v1. The [specification](systems/DATA/DATA-006.md) is finalized v1, including data-defined world bounds and validated mod expansion beyond classic dimensions. Documented technical and cross-owner dependencies remain open, including expansion schemas, coordinate verification, consumer support and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-006-D07 — 2026-11-05:** Terrain extensions must supply height data and valid climate assignments required by their consumers. Reject incomplete required areas rather than silently generating flat land or default climate. User: “1. I agree” to third interview.
- **DATA-006-D08 — 2026-11-05:** Terrain, climate, location placement and map/travel consumers share the loaded world's declared extent and coordinate convention. Classic dimensions must not independently restrict supported expanded areas. Exact expansion schema remains a technical dependency. User: “2. I agree” to third interview.
- **DATA-006-D09 — 2026-11-05:** Resolve terrain/map extensions during DATA-003's editable pre-menu configuration stage, then lock them with selected content at actual main-menu entry. Subsequent extent changes require application restart; old saves require compatibility validation. User: “3. I agree” to third interview.

- **DATA-006-D04 — 2026-11-05:** Geographic bounds come from the particularly loaded world instance's data, not hard-coded classic-world limits. Support mods adding/extending terrain and maps. Within those declared bounds, reject out-of-bounds geographic queries by default; provide explicitly clamped neighbor sampling for terrain interpolation rather than silently correcting destinations. User agreed to second interview item 1 with the explicit mod-extension clarification. World extent/schema and interaction with existing coordinate/identity contracts remain to be defined.
- **DATA-006-D05 — 2026-11-05:** Every used climate code requires a supported definition or explicit validated mapping. Unknown required codes fail rather than silently becoming temperate; mods may introduce codes through supported definitions. User: “2. I agree” to second interview.
- **DATA-006-D06 — 2026-11-05:** Share climate identity/definition among terrain, weather and presentation consumers, with each system owning its effects. DATA does not set weather probabilities, rendering or gameplay modifiers. User: “3. I agree” to second interview.

- **DATA-006-D01 — 2026-11-05:** Preserve classic source height samples and climate assignments as the baseline, allowing explicit validated overrides. This does not require DFU's exact procedural terrain output. User: “1. I agree” to first interview.
- **DATA-006-D02 — 2026-11-05:** WORLD's later specification may choose interpolation, small-scale detail, coastline treatment and location-ground fitting while respecting approved source geography and location placements. Retain source samples separately from generated heights. User: “2. I agree” to first interview.
- **DATA-006-D03 — 2026-11-05:** Climate is authored geographic data, separate from current weather, season and temporary visuals. TIME/weather and AV determine their effects without rewriting the underlying climate definition; explicit content overrides may change that definition. User: “3. I agree” to first interview.

The complete DATA-006 specification is approved under DATA-006-A01 above. These decisions do not authorize implementation.

## DATA-005 interview decisions

- **DATA-005-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-005 Draft v1. The [specification](systems/DATA/DATA-005.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including format coverage, marker/action interpretation, conversion fixtures and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-005-D07 — 2026-11-05:** Preserve marker types, placement and source identity explicitly. Consumers select by intended purpose and required location context rather than first-marker enumeration; CORE-011's special opening position remains binding. User: “1. I agree” to third interview.
- **DATA-005-D08 — 2026-11-05:** Unknown fields may remain uninterpreted when safely retained/skipped without changing supported behavior. Unsupported required block types or gameplay actions fail explicitly. Unused field differences alone must not reject a functioning modified block. User: “2. I agree” to third interview.
- **DATA-005-D09 — 2026-11-05:** Verify positions, rotations, scale and link targets against representative exterior/dungeon blocks, including repeated placements, interiors and quest/action markers, before declaring the importer complete. Approximate visual similarity alone is insufficient. Godot units and implementation remain deferred. User: “3. I agree” to third interview.

- **DATA-005-D04 — 2026-11-05:** Missing, malformed or unsupported blocks required by a location fail that location's preparation rather than leaving holes or substituting another block. Configuration-time failures retain DATA-002/003 recovery; record decoding may remain on demand. User: “1. I agree” to second interview.
- **DATA-005-D05 — 2026-11-05:** Preserve authored action links and validate targets within the format's permitted scope. Do not automatically remove cycles or repeated links, which may be intentional. LOC defines safe execution separately. Broken required links invalidate the affected block. User: “2. I agree” to second interview.
- **DATA-005-D06 — 2026-11-05:** Unchanged block identity does not prove replacement compatibility. Removed/changed records referenced by saves or quests require explicit mapping/migration or an incompatibility outcome under SAVE/LOC/QUEST. Do not guess matches by proximity or similar models. User: “3. I agree” to second interview.

- **DATA-005-D01 — 2026-11-05:** Preserve supported classic block placement, object references, building metadata, markers and action-link relationships as the baseline, allowing explicit validated overrides. Godot representation may differ; importing must not silently simplify gameplay-relevant content. User: “1. I agree” to first interview.
- **DATA-005-D02 — 2026-11-05:** Separate reusable authored block definitions from each placed instance's live state. Repeated uses share definitions but retain independent doors, enemies, loot and triggered actions under LOC and relevant gameplay ownership. User: “2. I agree” to first interview.
- **DATA-005-D03 — 2026-11-05:** Distinguish block definition identity, placement identity within a location, and record identity within that placement. Saves and quests use scoped references rather than scene handles or archive byte offsets alone. User: “3. I agree” to first interview.

The complete DATA-005 specification is approved under DATA-005-A01 above. These decisions do not authorize implementation.

## DATA-004 interview decisions

- **DATA-004-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-004 Draft v1. The [specification](systems/DATA/DATA-004.md) is finalized v1. Documented technical and cross-owner dependencies remain open, including ID mappings, coordinate rules, classic discovery defaults and save compatibility. One location per map pixel is approved initially; future multiple-location behavior requires separate design. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-004-D07 — 2026-11-05:** Preserve classic region membership, coordinates and location/dungeon classifications as the baseline, allowing explicit validated content overrides. Internal Godot coordinate conversion may differ if it resolves to intended places. User: “1. I agree” to third interview.
- **DATA-004-D08 — 2026-11-05:** Stable location references resolve to current authored position/region after a valid content change, preserving quest/discovery identity. This does not automatically relocate a saved player or establish saved-interior compatibility; SAVE/LOC validate those separately. User: “2. I agree” to third interview.
- **DATA-004-D09 — 2026-11-05:** Missing location IDs produce explicit failure without substitution by name or nearby pixel. Consumers own rejection or explicitly approved fallback. Deletion that leaves required definition references unresolved invalidates the content configuration. User: “3. I agree” to third interview.

- **DATA-004-D04 — 2026-11-05:** Conflicting pixel occupancy by distinct locations, duplicate stable IDs, and ambiguous classic-ID mappings are invalid; explicit replacements remain valid. Report conflicts before main-menu entry rather than selecting arbitrarily, using DATA-003 recovery where applicable. User: “1. I agree” to second interview.
- **DATA-004-D05 — 2026-11-05:** Allow duplicate display names. Gameplay, quests and saves reference stable IDs; name searches may return multiple matches rather than silently selecting the first. Localization does not change identity. User: “2. I agree” to second interview.
- **DATA-004-D06 — 2026-11-05:** Separate authored initially-discovered defaults from character-owned current discovery state. New characters receive defaults; loads restore character discoveries. Verify original defaults, including forgotten graveyards, rather than assuming DFU's summary flag is complete. User: “3. I agree” to second interview.

- **DATA-004-D01 — 2026-11-05:** Use stable region/location IDs independent of display names, list positions and coordinates, with explicit mappings from classic identifiers. Renames and list reordering preserve quest/save identity. User: “1. I agree” to first interview.
- **DATA-004-D02 — 2026-11-05:** Explicit replacement retains existing location identity; an added location receives its own ID. Adding with an existing ID is invalid under DATA-003. Moving or renaming alone does not create a new identity. User: “2. I agree” to first interview.
- **DATA-004-D03 — 2026-11-05:** Initially allow one location per map pixel. Leave potential future support for multiple separately identified locations at a pixel open where practical; no multi-location gameplay, lookup selection or migration policy is approved now. User: “I agree, do it initially, but leave the potential open for allowing more in the future, if possible.” Keep durable identity separate from the initial coordinate-occupancy restriction.

The complete DATA-004 specification is approved under DATA-004-A01 above. These decisions do not authorize implementation.

## DATA-003 interview decisions

- **DATA-003-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-003 Draft v1. The [specification](systems/DATA/DATA-003.md) is finalized v1, including editable pre-menu mod configuration and the run-long lock after actual main-menu entry. Documented technical and cross-owner dependencies remain open, including content schemas, executable-mod lifecycle and configuration UI integration. Approval does not initiate implementation, coding tasks or another feature review.

- **DATA-003-D10 — 2026-11-05:** Before actual game main-menu entry, allow in-application mod reordering and enable/disable changes. Keep edits pending until Continue rebuilds and validates resolved definitions. Failed validation retains configuration; these data changes do not require restarting the application. User: “1. I agree” to fourth interview. Executable-mod unloading/activation constraints remain MOD-owned.
- **DATA-003-D11 — 2026-11-05:** Entering the actual game main menu locks mod order and enabled-mod configuration for the rest of the application run, including returns from gameplay. Restart is required to reenter the editable configuration stage and change that configuration. External classic-file and loose-override edits also require restart. Supported individual mod settings remain changeable in-game under their own contracts. User: “Yes, you interpret correctly” to fourth interview item 2.

- **DATA-003-D07 — 2026-11-05:** Within a source, sort contributing files by normalized relative path and preserve declared record order inside each file. Later patches within that order win on the same field. User: “1. I agree” to third interview. Exact normalization/case rules remain technical dependencies.
- **DATA-003-D08 — 2026-11-05:** An add operation colliding with an existing record ID or a patch targeting a nonexistent ID is invalid. Authors must explicitly choose replacement or another supported operation; patches do not implicitly create records. User: “2. I agree” to third interview.
- **DATA-003-D09 — 2026-11-05:** Mod order must be editable through an in-application mod menu without a complete application restart for each change. Once the actual game main menu is entered, mods are locked, except individual mod settings that support in-game changes. User's third-interview item 3 partially accepted the restart proposal with this explicit exception. Configuration-stage activation/rebuild boundaries, enable/disable behavior and loose-text edit handling remain to be clarified; blanket restart-only mod-order changes are not approved.

- **DATA-003-D04 — 2026-11-05:** Allow valid overrides without blocking popups, retaining contributing-source and winning-source diagnostics. Invalid contributions produce a visible warning/error. User: “1. I agree” to second interview.
- **DATA-003-D05 — 2026-11-05:** Reject an invalid file or patch as a whole without partial application. Identify source/reason; require fix/removal or explicit continuation without that contribution only when remaining content is valid. Do not automatically skip it. User: “2. I agree” to second interview. Cross-contribution dependency validation remains necessary; this is not permission to skip required content.
- **DATA-003-D06 — 2026-11-05:** Omitted patch fields retain previous values; supplied fields replace values, with later patches winning on the same field. Lists replace as a whole unless the content type explicitly supports merging. Deletion requires an explicit supported operation. User: “3. I agree” to second interview.

- **DATA-003-D01 — 2026-11-05:** Identify content by domain and relative path, retaining contributing package identity. Same basenames in different directories remain distinct rather than colliding through basename-only lookup. User: “1. I agree” to first interview.
- **DATA-003-D02 — 2026-11-05:** Use shipped defaults, then enabled mods in resolved load order, then an explicit loose override folder. Later sources win when multiple sources override the same thing, subject to the declared content operation. User: “I'd say the first, later sources win if multiple try to do or override the same thing.” Exact within-source ordering and invalid-contribution behavior remain unresolved.
- **DATA-003-D03 — 2026-11-05:** Declare replace-resource, add-entry or stable-ID record-patch semantics per content type; preserve compatible intended record IDs rather than automatically renumbering them. User: “3. I agree” to first interview.

The complete DATA-003 specification is approved under DATA-003-A01 above. These decisions do not authorize implementation.

## DATA-002 interview decisions

- **DATA-002-D01 — 2026-11-05:** Open required data sources and prepare their basic indexes before entering the normal main menu; decode individual records when needed rather than loading every location and asset in advance. User: “1. I agree” to first interview.
- **DATA-002-D02 — 2026-11-05:** Required-reader startup failure blocks normal entry and reports affected files/reasons through independent error UI with Retry, Choose Folder and Quit. Clean up the failed attempt before retrying; partially initialized required readers must not be exposed as ready. User: “2. I agree” to first interview.
- **DATA-002-D03 — 2026-11-05:** Distinguish record not found, source unavailable, and malformed/unsupported data in record-access results. The consuming feature owns recovery under its requirements, including required-location failure versus approved optional-media fallback; do not silently substitute empty records for required content. User: “3. I agree” to first interview.

The complete DATA-002 specification is approved under DATA-002-A01 below. These decisions do not authorize implementation.

- **DATA-002-D04 — 2026-11-05:** Keep initialized readers and reusable content caches available across character changes, menu returns and location transitions; character-specific state remains session-owned. User: “1. I agree” to second interview.
- **DATA-002-D05 — 2026-11-05:** External edits to classic files require application restart; no live reload or continuous file monitoring. Actual read/decode failures still follow their owning feature's recovery rules. User: “2. I agree” to second interview. This does not promise a byte-for-byte snapshot when files are edited during disk-backed access.
- **DATA-002-D06 — 2026-11-05:** Choose memory-backed versus disk-backed access through measurement of startup time, memory use and loading delays. Preserve equivalent read-only behavior and failure reporting; no player-facing setting initially. User: “3. I agree” to second interview.

- **DATA-002-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-002 Draft v1. The [specification](systems/DATA/DATA-002.md) is finalized v1. Documented technical dependencies remain open, including the required-reader inventory, format contracts and measured performance choices. Approval does not initiate implementation, coding tasks or another feature review.

## DATA-001 interview decisions

- **DATA-001-D01 — 2026-11-05:** Keep startup validation mostly basic: required-file checks and basic readability, with only lightweight structural checks rather than exhaustive decoding or exact-content verification. Exact checks and required-file manifest remain unresolved. User agreed to first interview item 1, emphasizing that externally modified DOS Daggerfall binaries can still function and that validation should remain mostly basic.
- **DATA-001-D02 — 2026-11-05:** Accept modified original data; do not require exact original checksums or an unmodified installation. Acceptance is not a guarantee that every modified record will work. User: “Yes modified original data should be accepted, as stated above.”
- **DATA-001-D03 — 2026-11-05:** Videos are optional for startup; individual playback features handle missing media under their own policies, including approved CORE-008 death-video bypass. User: “3. I agree” to the optional-video recommendation.

The complete DATA-001 specification is approved under DATA-001-A01 below. Individual interview confirmations and complete-feature approval do not authorize implementation.

- **DATA-001-D04 — 2026-11-05:** Check an explicit list of filenames needed by the recreation, using DFU checks as a starting point; a minimum texture count alone is insufficient. Allow extra files and modified contents. User: “1. I agree” to second interview.
- **DATA-001-D05 — 2026-11-05:** Reject missing, unreadable or empty required files and clearly invalid archive headers/index bounds. Do not enforce original file sizes, record counts or content values. User: “2. I agree” to second interview.
- **DATA-001-D06 — 2026-11-05:** Show all detected required-data failures together with affected file and reason, using Choose Folder / Retry / Quit. Missing optional videos do not cause recurring startup warnings. User: “3. I agree” to second interview.

- **DATA-001-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize DATA-001 Draft v1. The [specification](systems/DATA/DATA-001.md) is finalized v1. Documented technical/content dependencies remain open, including the exact required-file manifest and format-specific lightweight checks. Approval does not initiate implementation, coding tasks or another feature review.

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-001-D01 | 2026-11-05 | CORE-001 | Standard per-user storage by default, with optional portable storage. | User response: “1. I agree” to first interview. |
| CORE-001-D02 | 2026-11-05 | CORE-001 | Select storage mode at launch; require restart to change mode. Marker-file selection is the stated interpretation of this answer, with names still open. | User response: “2. I agree” to first interview. |
| CORE-001-D03 | 2026-11-05 | CORE-001 | On an unwritable selected root, identify the path and offer retry, explicit standard storage, or quit. No silent fallback. | User response: “3. I agree” to first interview. |

| CORE-001-D04 | 2026-11-05 | CORE-001 | Saves, settings, logs and writable mod data follow the selected mode; installed game assets remain separate. | User response: “1. I agree” to second interview. |
| CORE-001-D05 | 2026-11-05 | CORE-001 | No automatic copying when switching modes. Each root has its own data; explain that switching does not move saves. Migration tooling is separate scope. | User response: “2. I agree” to second interview. |
| CORE-001-D06 | 2026-11-05 | CORE-001 | Separate editor/development storage by default; explicit choice required to test against normal player storage. | User response: “3. I agree” to second interview. |

| CORE-001-D07 | 2026-11-05 | CORE-001 | Standard-storage fallback lasts for the current launch only. Preserve the portable marker and retry portable storage next launch. | User response: “1. I Agree” to third interview. |
| CORE-001-D08 | 2026-11-05 | CORE-001 | If standard storage also fails, show the failed path with Retry and Quit; block gameplay entry until required storage is usable. | User response: “2. I Agree” to third interview. |
| CORE-001-D09 | 2026-11-05 | CORE-001 | During gameplay storage failure, retain the session in memory, report failed saves and permit retry. Continue gameplay without automatic pause or root switching; do not report failed saves as successful. | User response: “3. I Agree” to third interview. |

| CORE-001-D10 | 2026-11-05 | CORE-001 | Use Portable.txt and PortableAppdata beside the executable. Defer the standard per-user directory's final name until the game has a name. | User response: “1. I Agree” to fourth interview. |
| CORE-001-D11 | 2026-11-05 | CORE-001 | Arbitrary custom storage paths are outside the initial feature scope. | User response: “2. I Agree” to fourth interview. |
| CORE-001-D12 | 2026-11-05 | CORE-001 | One running instance per storage root. A second instance offers Retry or Quit with a directory-in-use explanation. Separate roots may run concurrently. | User response: “3. I Agree” to fourth interview. |

| CORE-001-D13 | 2026-11-05 | CORE-001 | Validate required directory creation and temporary file write/read/removal before gameplay. This does not guarantee future availability. | User response: “1. I Agree” to fifth interview. |
| CORE-001-D14 | 2026-11-05 | CORE-001 | Logs/caches follow the root; isolated failures permit play. Warn about unavailable file logging and recreate disposable caches when possible. Required save/settings/mod-data storage failure blocks startup. | User response: “2. I Agree” to fifth interview. |
| CORE-001-D15 | 2026-11-05 | CORE-001 | Process-owned exclusion releases on exit/crash; leftover lock-file presence alone cannot permanently block use. | User response: “3. I Agree” to fifth interview. |

## CORE-002 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-002-D01 | 2026-11-05 | CORE-002 | Retain current launch plus one previous launch. | First interview: “current plus one would be enough”. |
| CORE-002-D02 | 2026-11-05 | CORE-002 | Cap each file at 200 MiB; stop appending with reserved space for a limit message and no extra files beyond launch retention. | First interview item 2: “I agree, but make the limit 200 MiB per file”. |
| CORE-002-D03 | 2026-11-05 | CORE-002 | Record version/build, launch time, OS, mode and enabled mod IDs/versions. Keep logs local; exclude save contents, credentials and deliberate username collection. | First interview item 3: “I agree”. |

Additional CORE-002 confirmations (second interview, 2026-11-05):

- **CORE-002-D04:** Flush after every message, accepting disk activity and the lack of a power-loss guarantee. User: “1. I agree”.
- **CORE-002-D05:** At the cap, write the reserved final message and give one non-blocking warning; continue play without repeated warnings. User: “2. I agree”.
- **CORE-002-D06:** On prior-log preservation failure, preserve existing files, disable file logging for this launch and warn. User: “3. I agree”.

Additional CORE-002 confirmations (third interview, 2026-11-05):

- **CORE-002-D07:** Player.log and Player-prev.log; readable text with timestamps and severity, plus exception stack traces. User: “1. I agree”.
- **CORE-002-D08:** Replace user-home prefixes with <user-home> in file logs; exclude credentials/save contents. On-screen storage errors may retain the actual path. User: “2. I agree”.
- **CORE-002-D09:** Record available metadata immediately, then mod IDs/versions after discovery. Label the mod list not yet established until then. User: “3. I agree”.

Additional CORE-002 confirmations (fourth interview, 2026-11-05):

- **CORE-002-D10:** Info, warnings, errors and exceptions by default; verbose/debug disabled in normal releases. Keep repeated messages individually. User: “1. I agree”.
- **CORE-002-D11:** Truncate a message exceeding remaining space, mark truncation, write the reserved limit notice and stop. Count encoded bytes, metadata and line endings within 200 MiB. User: “2. I agree”.
- **CORE-002-D12:** On runtime write/flush failure, disable file logging for the rest of the launch, preserve written data, warn once and continue without repeated retries/root switching. Attempt logging next launch. User: “3. I agree”.

The [CORE-002 specification](systems/CORE/CORE-002.md) is approved and finalized v1; see CORE-002-A01 below.

## CORE-003 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-003-D01 | 2026-11-05 | CORE-003 | Create missing settings from packaged defaults without a warning. | First interview: “1. I agree”. |
| CORE-003-D02 | 2026-11-05 | CORE-003 | Replace invalid individual settings with their declared defaults, retain valid preferences and show one recovery summary. Out-of-range numbers default rather than clamp. | First interview: “2. I agree”. |
| CORE-003-D03 | 2026-11-05 | CORE-003 | Preserve unreadable/damaged input, try a validated backup, then defaults if needed; summarize the source used. Do not immediately overwrite damaged input. | First interview: “3. I agree”. |

Additional CORE-003 confirmations (second interview, 2026-11-05):

- **CORE-003-D04:** Keep one previous fully validated, successfully persisted version; replace the backup only when a different validated version is successfully saved. Parsing alone cannot replace it. User: “1. I agree”.
- **CORE-003-D05:** Preserve valid preferences across updates, default new settings and explicitly migrate changed/renamed settings. Retain unknown keys without applying them. User: “2. I agree”.
- **CORE-003-D06:** Write/validate a temporary file before replacing active settings, preserving the previous valid version on failed publication. Startup write failure blocks entry per CORE-001. Runtime failure retains in-memory preferences, warns and permits retry without root switching. User: “3. I agree”.

Additional CORE-003 confirmations (third interview, 2026-11-05):

- **CORE-003-D07:** Keep one separate damaged-input recovery copy; replace an older recovery copy only after the new one is safely preserved. User: “1. I agree”.
- **CORE-003-D08:** Preservation or backup-update failure stops replacement. Report failure; startup offers Retry/Quit, runtime retains in-memory preferences and allows retry. User: “2. I agree”.
- **CORE-003-D09:** Unsupported newer settings-format version remains unchanged. Explain incompatibility; offer Quit or explicit reset to this build's defaults after preserving the newer file. User: “3. I agree”.

Additional CORE-003 confirmations (fourth interview, 2026-11-05):

- **CORE-003-D10:** Human-readable settings.ini with explicit format version. Backup/recovery filenames may remain implementation details. User: “1. I agree”.
- **CORE-003-D11:** One non-blocking summary after successful recovery, naming reset settings and backup/default source. First launch and adding upgrade defaults stay quiet. Unsafe persistence yields the blocking failure screen instead. User: “2. I agree”.
- **CORE-003-D12:** Invalid/missing/unreadable packaged defaults are an installation error: explain, block gameplay, do not invent values or overwrite user settings. Validate defaults. User: “3. I agree”.

Additional CORE-003 confirmations (fifth interview, 2026-11-05):

- **CORE-003-D13:** Preserve a validated backup when restoring active settings, never replacing it with damaged input. If both user files are unusable, preserve damaged active input, publish validated defaults and establish their validated backup. User: “1. I agree”.
- **CORE-003-D14:** Validate related settings together; reset only conflicting groups to declared compatible defaults and summarize recovery. User: “2. I agree”.
- **CORE-003-D15:** Older unsupported formats require the explicit Quit/reset choice, preserving original input before reset. Do not guess migrations. User: “3. I agree”.

The [CORE-003 specification](systems/CORE/CORE-003.md) is approved and finalized v1; see CORE-003-A01 below.

## CORE-004 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-004-D01 | 2026-11-05 | CORE-004 | Require original Daggerfall ARENA2 as external game data. | First interview: “Yes, ARENA2, Daggerfall's original file will be needed.” |
| CORE-004-D02 | 2026-11-05 | CORE-004 | Successful normal launch opens main menu; setup only when required/explicitly requested, with no automatic character start/load. | First interview: “2. I agree”. |
| CORE-004-D03 | 2026-11-05 | CORE-004 | Main-menu Settings/Setup entry and optional Show setup at startup preference; no any-key startup trigger. | First interview: “3. I agree”. |

Additional CORE-004 confirmations (second interview, 2026-11-05):

- **CORE-004-D04:** Accept ARENA2 or its immediate parent folder, show the resolved ARENA2 path and remember it after validation. User: “1. I agree”.
- **CORE-004-D05:** Missing/invalid data shows failure details and Choose Folder/Retry/Quit, blocks the normal main menu, and uses UI independent of ARENA2 assets. User: “2. I agree”.
- **CORE-004-D06:** Require data selection when needed; optional display/audio/control setup uses defaults. Show setup at startup defaults off, with main-menu access retained. User: “3. I agree”.

Additional CORE-004 confirmations (third interview, 2026-11-05):

- **CORE-004-D07:** Recheck required files/basic readability at remembered location each launch. DATA defines detailed validation; startup success does not certify every asset. User: “1. I agree”.
- **CORE-004-D08:** Portable content inside the installation uses executable-relative paths; external content uses absolute paths. Writable storage selection is unchanged. User: “2. I agree”.
- **CORE-004-D09:** Main-menu source changes validate and safely save before restart is offered. Restart activates changes; retain current source meanwhile. No in-session source switching. User: “3. I agree”.

Additional CORE-004 confirmations (fourth interview, 2026-11-05):

- **CORE-004-D10:** Use remembered/explicitly selected paths only; no drive scanning or silently choosing another ARENA2 copy. User: “1. I agree”.
- **CORE-004-D11:** Optional setup returns to main menu when required checks pass. Picker cancel keeps selection unchanged; mandatory cancellation returns to setup/error with Quit available. User: “2. I agree”.
- **CORE-004-D12:** Main-menu transition failure uses independent UI with Retry/Return to Setup/Quit, never reports success and ignores repeated Continue clicks during transition. User: “3. I agree”.

The [CORE-004 specification](systems/CORE/CORE-004.md) is approved and finalized v1; see CORE-004-A01 below.

## CORE-005 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-005-D01 | 2026-11-05 | CORE-005 | Separate application-scoped storage/settings/logging from session-scoped player/world services. Ending a session releases its services/subscriptions to prevent stale character state. | First interview: “1. I agree”. |
| CORE-005-D02 | 2026-11-05 | CORE-005 | Explicitly bind/validate required services before simulation/gameplay input. Missing/duplicate required services fail with actionable errors, without arbitrary selection or silent replacement. Preserve menu/error input. | First interview: “2. I agree”. |
| CORE-005-D03 | 2026-11-05 | CORE-005 | Only feature-defined optional services may use supported fallbacks; disable affected capability with warning. Player control/save restoration are not optional. | First interview: “3. I agree”. |

Additional CORE-005 confirmations (second interview, 2026-11-05):

- **CORE-005-D04:** Failed session initialization disables gameplay, cleans incomplete state and shows independent Retry/Main Menu/Quit UI without claiming successful start/load. Prior-session recovery remains session-entry scope. User: “1. I agree”.
- **CORE-005-D05:** Stop simulation/input, cancel session work, disconnect subscriptions and release services/objects on teardown. Retain app settings/logging; block new sessions until teardown completes. User: “2. I agree”.
- **CORE-005-D06:** Reject ended-session callbacks with diagnostics rather than repeated player interruptions. Losing a required current-session service suspends gameplay and shows recovery error. User: “3. I agree”.

Additional CORE-005 confirmations (third interview, 2026-11-05):

- **CORE-005-D07:** Location changes retain character/session services, replace location objects/references and validate new bindings before resuming. Buildings/dungeons do not create new character sessions. User: “1. I agree”.
- **CORE-005-D08:** Unsafe/incomplete teardown blocks new sessions with Retry Cleanup/Quit; do not resume gameplay with uncertain cleanup. User: “2. I agree”.
- **CORE-005-D09:** Publish session/location readiness only after binding/initialization completes and consistent state is visible. Readiness does not override other suspension requirements. User: “3. I agree”.

Additional CORE-005 confirmations (fourth interview, 2026-11-05):

- **CORE-005-D10:** One declared owner/lifetime per service; explicit reference/registration binding, no global name/tag lookup or silent creation on access. User: “1. I agree”.
- **CORE-005-D11:** Duplicate optional providers disable the capability with warning unless the feature supports multiple providers and defines selection rules. Required duplicates fail. User: “2. I agree”.
- **CORE-005-D12:** Preserve CORE-001–003 recovery. Other required app initialization failures block gameplay with independent UI and retry only after safe cleanup, otherwise Quit. Runtime required-app-service loss suspends play for safe recovery or restart. Optional failures use approved fallback. User: “3. I agree”.

The [CORE-005 specification](systems/CORE/CORE-005.md) is approved and finalized v1; see CORE-005-A01 below.

## CORE-006 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-006-D01 | 2026-11-05 | CORE-006 | Classify settings as live, next session/location or restart-required; show timing in UI. Feature owners define classifications. | First interview: “1. I agree”. |
| CORE-006-D02 | 2026-11-05 | CORE-006 | Stage edits with Apply/Cancel; Apply activates eligible changes and saves accepted preferences via CORE-003. Cancel discards unapplied edits; restart changes remain marked pending. | First interview: “2. I agree”. |
| CORE-006-D03 | 2026-11-05 | CORE-006 | Recreated consumers receive effective preferences; reapplication is safe and handles enabling/disabling and reverse changes explicitly. | First interview: “3. I agree”. |

Additional CORE-006 confirmations (second interview, 2026-11-05):

- **CORE-006-D04:** Test resolution/fullscreen before saving; Keep Changes/Revert and 15-second timeout restore the previous working mode. User: “1. I agree”.
- **CORE-006-D05:** Failed application reverts the affected group and reports failure. Independent groups may succeed with explicit partial-success UI. Failed safe reversion follows CORE-005 recovery. User: “2. I agree”.
- **CORE-006-D06:** Successful application with failed persistence retains active memory, shows Applied, not saved and permits retry. Deferred settings remain separately pending; saved is distinct from active. User: “3. I agree”.

Additional CORE-006 confirmations (third interview, 2026-11-05):

- **CORE-006-D07:** Apply deferred changes only at declared boundaries; no forced reload/restart. Show pending status, offer restart where applicable and allow continuation with current effective values. User: “1. I agree”.
- **CORE-006-D08:** Disable unsupported options with explanation; retain saved requests, use declared supported fallbacks and expose effective values. No safe fallback uses established failure rules. User: “2. I agree”.
- **CORE-006-D09:** Cancel drops edits since last Apply attempt without undoing successful groups or active unsaved changes. Keep unsaved warning/retry; failed groups remain rejected. User: “3. I agree”.

Additional CORE-006 confirmations (fourth interview, 2026-11-05):

- **CORE-006-D10:** Display confirmation uses 15 real-time seconds despite pause/focus loss. Revert without explicit confirmation; never confirm automatically. User: “1. I agree”.
- **CORE-006-D11:** Failed startup display mode tries display-owned conservative windowed fallback, retaining the request and explaining fallback. No usable display blocks initialization with actionable error; exact resolution is display scope. User: “2. I agree”.
- **CORE-006-D12:** Interdependent groups apply at a boundary safe for all members; restart-required members defer the group to restart. Independent options may apply live; show group timing before Apply. User: “3. I agree”.

The [CORE-006 specification](systems/CORE/CORE-006.md) is approved and finalized v1; see CORE-006-A01 below.

## CORE-007 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-007-D01 | 2026-11-05 | CORE-007 | One coordinator handles session-changing requests with mode, payload and tracking identity, including menu/quickload. Routing does not approve individual optional modes. | First interview: “1. I agree”. |
| CORE-007-D02 | 2026-11-05 | CORE-007 | One operation at a time; reject additional requests as busy, without replacing or queueing. Safe ordinary settings/menu navigation may remain available. | First interview: “2. I agree”. |
| CORE-007-D03 | 2026-11-05 | CORE-007 | Preflight before destructive teardown; failed validation preserves the current session. After replacement begins, use safe cleanup/menu recovery without promised full rollback. | First interview: “3. I agree”. |

Additional CORE-007 confirmations (second interview, 2026-11-05):

- **CORE-007-D04:** Track phases and exactly one Succeeded/Failed/Cancelled outcome. Success follows restore/readiness; all terminal paths release operation busy state, without overriding unsafe-cleanup blocking. User: “1. I agree”.
- **CORE-007-D05:** Cancellation allowed during preflight only; destructive replacement disables cancellation and must complete or recover. User: “2. I agree”.
- **CORE-007-D06:** Same identity cannot execute twice; distinct requests while busy reject. Intentional retry uses new identity and repeats validation. User: “3. I agree”.

Additional CORE-007 confirmations (third interview, 2026-11-05):

- **CORE-007-D07:** Suspend gameplay simulation/input during preflight; UI stays responsive and session intact. Failure/cancel releases only the operation's suspension. User: “1. I agree”.
- **CORE-007-D08:** Explicitly confirm discarding a living active session, including quickload; no automatic save. Mode owners may define already-ended-session exceptions. Declining changes nothing. User: “2. I agree”.
- **CORE-007-D09:** After replacement failure, safely clean up before retrying original intent with fresh validation. Never resume partial initialization or substitute missing inputs. User: “3. I agree”.

Additional CORE-007 confirmations (fourth interview, 2026-11-05):

- **CORE-007-D10:** Capture selected character draft/save identity at submission; later UI changes cannot redirect it. Reject late completed/superseded-operation callbacks. User: “1. I agree”.
- **CORE-007-D11:** Prepare consistent validated input before replacement. Changed/missing save before preparation completes fails without touching current session. SAVE defines mechanism; no unchecked generation substitution. User: “2. I agree”.
- **CORE-007-D12:** Show actual phase, not invented percentage; no generic elapsed-time failure. Keep UI responsive, allow preflight cancel and let owners define specific failure timeouts. User: “3. I agree”.

The [CORE-007 specification](systems/CORE/CORE-007.md) is approved and finalized v1; see CORE-007-A01 below.

## CORE-008 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-008-D01 | 2026-11-05 | CORE-008 | Voluntary return confirms loss of unsaved progress, ends session and opens menu, without autosave. Cancel preserves session. | First interview: “1. I agree”. |
| CORE-008-D02 | 2026-11-05 | CORE-008 | Confirmed death return skips living-session confirmation, leaves saves untouched and does not auto-load. CHAR/AV own death presentation/duration. | First interview: “2. I agree”. |
| CORE-008-D03 | 2026-11-05 | CORE-008 | Shared safe teardown with distinct voluntary/death reasons; clear session/transient state and publish session-end/menu-ready rather than new-game events. | First interview: “3. I agree”. |

Additional CORE-008 confirmations (second interview, 2026-11-05):

- **CORE-008-D04:** Preserve death cutscene/video before menu as the death notification, rather than the proposed separate menu notice. User explicitly corrected interview item 1.
- **CORE-008-D05:** After completed teardown/menu-load failure, keep session ended; independent Retry/Setup/Quit UI retries menu only, without repeating cleanup or resurrecting session. User: “2. I agree”.
- **CORE-008-D06:** Busy death requests reject without queue/preemption. Death handler may resubmit fresh request only for the same still-dead session after active operation ends; discard stale intent. User: “3. I agree”.

Additional CORE-008 confirmations (third interview, 2026-11-05):

- **CORE-008-D07:** Original ARENA2 death video plays once per completed death return, never voluntary return. User: “1. I agree”.
- **CORE-008-D08:** Allow early skip. Missing/failed video goes directly to menu with no text fallback; do not trap player or restore dead session. User explicitly modified item 2.
- **CORE-008-D09:** Menu retry does not replay completed/skipped video. Return succeeds only when presentation has finished/skipped (or failure bypass applies) and menu is usable. User: “3. I agree”.

Additional CORE-008 confirmations (fourth interview, 2026-11-05):

- **CORE-008-D10:** Consume skip input; require fresh menu input so skipping cannot activate a menu action. User: “1. I agree”.
- **CORE-008-D11:** Video/menu presentation is independent of ended gameplay. Clear old gameplay presentation/audio/input without stopping video-owned presentation or resuming gameplay. User: “2. I agree”.
- **CORE-008-D12:** Repeated/stale returns cannot repeat completed cleanup/video or affect another session. Death return must match confirmed-dead originating session. Voluntary already-menu return leaves it unchanged. User: “3. I agree”.

The [CORE-008 specification](systems/CORE/CORE-008.md) is approved and finalized v1; see CORE-008-A01 below.

## Deferred features

- **CORE-009-D01 — 2026-11-05 — Deferred.** User: “defer CORE-009 until a clear purpose for it shows up.” Retain the feature ID and reopen review on a concrete need. This does not approve a worldless gameplay/development mode or permanently exclude it. See [deferral record](systems/CORE/CORE-009.md).

## CORE-010 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-010-D01 | 2026-11-05 | CORE-010 | Clean baseline for new and supported restored/imported sessions; defaults for new characters and restoration over baseline for loads. Never reset newly restored values. | First interview: “1. I agree”. |
| CORE-010-D02 | 2026-11-05 | CORE-010 | Clear previous-character gameplay/transient state; retain application preferences, content, saves and reusable caches without character state. Owners classify data. | First interview: “2. I agree”. |
| CORE-010-D03 | 2026-11-05 | CORE-010 | Ordered owner baseline initialization replaces essential broad-event reset side effects. Publish baseline readiness only on success; full entry still gates gameplay. | First interview: “3. I agree”. |

Additional CORE-010 confirmations (second interview, 2026-11-05):

- **CORE-010-D04:** Preserve restored durable identities and initialize safe replacement-session allocation without collisions. SAVE/DATA define the scheme; no required DFU-style counter reset. User: “1. I agree”.
- **CORE-010-D05:** Separate baseline from new-character grants. Do not grant starting gear/spells/quests on load or silently replace missing required save data with a fresh character. User: “2. I agree”.
- **CORE-010-D06:** Required baseline failure stops entry, cleans partial replacement and uses CORE-005/007 recovery. Retry fresh validation/clean construction; no readiness/gameplay on failure. User: “3. I agree”.

Additional CORE-010 confirmations (third interview, 2026-11-05):

- **CORE-010-D07:** Baseline initialization runs once per replacement context; duplicates cannot clear restored state, reset identities or repeat rewards. Intentional retry constructs fresh replacement. User: “1. I agree”.
- **CORE-010-D08:** Baseline readiness is notification only; required reset is ordered owner work. Grants and restored-session completion are separate milestones. User: “2. I agree”.
- **CORE-010-D09:** Retain caches only with established absence of old-character state/references. Clear/rebuild session caches; separate mixed content/state or clear the whole cache. User: “3. I agree”.

The [CORE-010 specification](systems/CORE/CORE-010.md) is approved and finalized v1; see CORE-010-A01 below.

## CORE-011 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-011-D01 | 2026-11-05 | CORE-011 | Privateer's Hold is the ordinary start, with explicit outside-dungeon option retained. Alternate locations may be modified through mods later; detailed mod contract remains open. | First interview item 1, user explicitly retained outside option. |
| CORE-011-D02 | 2026-11-05 | CORE-011 | Missing/invalid required start content fails safely with actionable error, without silent exterior/other-location fallback. | First interview: “2. I agree”. |
| CORE-011-D03 | 2026-11-05 | CORE-011 | Require completed validated character data and ready geometry/collision/spawn before gameplay; no silent default character or bypass of CORE-012. | First interview: “3. I agree”. |

Additional CORE-011 confirmations (second interview, 2026-11-05):

- **CORE-011-D04:** Default interior; saved exterior-start option accessible before main menu or eventual appropriate settings interface. Capture for New Game; subsequent edits affect future new characters only. User modified item 1's UI placement.
- **CORE-011-D05:** Preserve Privateer's Hold's deep-cave new-game marker position, not ordinary entrance/exit. Exterior is validated immediately outside entrance; defined facing/safe footing; fail if intended placement unavailable. User corrected item 2's interior assumption.
- **CORE-011-D06:** Original start date/time for both choices with consistent initial tracking; TIME owns exact values and later mods may override. User agreed to item 3 with mod allowance.

Additional CORE-011 confirmations (third interview, 2026-11-05):

- **CORE-011-D07:** Validate marker/coordinates/capsule/floor; small bounded corrections only on intended floor, no relocation to another room. Invalid intended placement fails safely. User: “1. I agree”.
- **CORE-011-D08:** Preserve original cave-start facing; exterior faces away from entrance. Verify exact marker/orientation in original layout data. User: “2. I agree”.
- **CORE-011-D09:** Keep loading/fade until placement and required CORE-012 complete; block movement/falling/AI attacks/game-time advancement during initialization. Reveal and release only entry suspension. User: “3. I agree”.

The [CORE-011 specification](systems/CORE/CORE-011.md) is approved and finalized v1; see CORE-011-A01 below.

## CORE-012 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-012-D01 | 2026-11-05 | CORE-012 | Preserve DFU class/biography starting-resource baseline; exact tables/formulas remain ITEM/MAGIC/CHAR scope and are not individually approved. | First interview: “1. I agree”. |
| CORE-012-D02 | 2026-11-05 | CORE-012 | Retain tutorial/main-story startup; tutorial participation stays optional by quest offer, with accept/decline. Exterior start retains required opening content with QUEST-owned adaptation. | First interview item 2, user explicitly preserved optional tutorial. |
| CORE-012-D03 | 2026-11-05 | CORE-012 | Biography before grants; progression baseline after starting skill changes; required economic/regional/weather and opening initialization before reveal/resume. Required failures recover safely. | First interview: “3. I agree”. |

Additional CORE-012 confirmations (second interview, 2026-11-05):

- **CORE-012-D04:** New-character world/content loads and becomes ready before tutorial/main-quest opening presentation; withhold control until that presentation. Quests initialize/execute through their own running logic, not an assumed fully eager startup sequence. User clarified item 1; exact QUEST handoff/delays remain open.
- **CORE-012-D05:** Required biography/grant/main-story startup failure fails entry. Tutorial initialization failure warns once and continues without it. Legitimate no-starting-spells class is valid. User: “2. I agree”.
- **CORE-012-D06:** Suppress duplicate startup grants/quests per new-session context. Retry failed entry from clean replacement; loads restore rather than rerun new-character grants. User: “3. I agree”.

Additional CORE-012 confirmations (third interview, 2026-11-05):

- **CORE-012-D07:** Gate only immediate opening presentation; preserve later authored timers/letters/triggers without waiting or fast-forwarding startup. User: “1. I agree”.
- **CORE-012-D08:** Sequential queued popup presentation in defined order preserving intended original sequence after verification. Withhold control through immediate acknowledgments/tutorial offer; decline does not skip story. User agreed and identified DFU queue model.
- **CORE-012-D09:** Future startup registration declares dependencies/requiredness; not all mod entries mandatory. Apply same readiness/duplicate safeguards; QUEST/MOD own API/order. User: “3. I agree”.

The [CORE-012 specification](systems/CORE/CORE-012.md) is approved and finalized v1; see CORE-012-A01 below.

## CORE-013 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-013-D01 | 2026-11-05 | CORE-013 | Saves target this Godot implementation only. DFU/classic save compatibility is outside current scope; do not pursue import work. | First interview item 1, user explicitly excluded both compatibility efforts. |
| CORE-013-D02 | 2026-11-05 | CORE-013 | Restore saved character/location/time/supported activities without fresh grants/tutorial/opening restart. App preferences remain separate; Session Restored follows required readiness. | First interview: “2. I agree”. |
| CORE-013-D03 | 2026-11-05 | CORE-013 | Preflight failure preserves session and offers retry/another save. Post-replacement failure uses safe cleanup/independent UI; no slot substitution or false success. | First interview: “3. I agree”. |

Additional CORE-013 confirmations (second interview, 2026-11-05):

- **CORE-013-D04:** Explicit format versions and preflight-validated supported migrations; reject unsupported versions with explanation, no silent incompatible-data defaults. User: “1. I agree”.
- **CORE-013-D05:** Reject missing/invalid required character/world/quest sections; rebuild disposable caches. Other optional recovery requires owner policy and prior disclosure. User: “2. I agree”.
- **CORE-013-D06:** Preflight required content/mod dependencies; missing required definitions block. Optional differences need safe owner policy; no unrelated silent content substitutions. SAVE/MOD own details. User: “3. I agree”.

Additional CORE-013 confirmations (third interview, 2026-11-05):

- **CORE-013-D07:** Restore pose/movement after geometry readiness with contextual validation; no universal floor requirement for swimming/airborne saves. MOVE/LOC-defined bounded corrections only, no unrelated teleport fallback. User: “1. I agree”.
- **CORE-013-D08:** Restore authoritative activities/quests and rebuild supported UI. Owners define save eligibility/resume; unsupported required state fails rather than dropping obligations or repeating transactions. User: “2. I agree”.
- **CORE-013-D09:** Cover/gate required restoration, links, derived state and UI; reveal, clear stale trigger input and emit Session Restored once after real success. Release only load suspension; restored modal/other gates remain. User: “3. I agree”.

The [CORE-013 specification](systems/CORE/CORE-013.md) is approved and finalized v1; see CORE-013-A01 below.

## Scope exclusions

- **CORE-014-S01 — 2026-11-05 — Outside current scope.** Applied existing approved CORE-013-D01 / CORE-013-A01 exclusion of classic-save compatibility to CORE-014. No new import requirements or specification approval are inferred from the request to review the next feature. Retain the ID/source analysis; reconsider only on explicit scope change. See [scope record](systems/CORE/CORE-014.md).

## CORE-015 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-015-D01 | 2026-11-05 | CORE-015 | Lifecycle is separate from UI overlays/pause reasons; closing UI does not restore stale lifecycle from a single previous-state slot. | First interview: “1. I agree”. |
| CORE-015-D02 | 2026-11-05 | CORE-015 | Commit complete state before notification; carry previous/current state, reason and relevant identities, with matching query values. | First interview: “2. I agree”. |
| CORE-015-D03 | 2026-11-05 | CORE-015 | Distinct once-per-occurrence new/restored readiness, death, session end and menu readiness plus general state change. Load/cleanup/menu are not new game. | First interview: “3. I agree”. |

Additional CORE-015 confirmations (second interview, 2026-11-05):

- **CORE-015-D04:** One lifecycle authority validates requests from responsible owners; other systems cannot directly set lifecycle fields. User: “1. I agree”.
- **CORE-015-D05:** Reject invalid/stale transitions with diagnostics; same-state repeats do not duplicate events. Required transition failure uses owning operation recovery. User: “2. I agree”.
- **CORE-015-D06:** Scope-owned subscriptions disconnect on teardown. Late observers get committed snapshot without replaying historical milestones; no cross-character subscription leaks. User: “3. I agree”.

Additional CORE-015 confirmations (third interview, 2026-11-05):

- **CORE-015-D07:** General committed change then associated milestones; finish batch before observer-requested transitions. CORE-007 busy rejection still applies to operations. User: “1. I agree”.
- **CORE-015-D08:** Isolate/diagnose observer failure, continue others and keep commit. Essential initialization is explicit checked work before readiness; required-service loss follows CORE-005. User: “2. I agree”.
- **CORE-015-D09:** Query distinct application phase, session identity/status, operation phase and readiness; don't conflate windows with lifecycle. Exact enum names deferred. User: “3. I agree”.

The [CORE-015 specification](systems/CORE/CORE-015.md) is approved and finalized v1; see CORE-015-A01 below.

## CORE-016 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-016-D01 | 2026-11-05 | CORE-016 | Independently owned suspension reasons; resume only with no applicable reasons and lifecycle ready. Duplicate release harmless; scope teardown releases its reasons safely. | First interview: “1. I agree”. |
| CORE-016-D02 | 2026-11-05 | CORE-016 | Ordinary pause stops simulation/game time, movement/AI/combat/effect timers; UI/loading/real-time presentation continue. Explicit rest/travel uses separate TIME advancement. | First interview: “2. I agree”. |
| CORE-016-D03 | 2026-11-05 | CORE-016 | HUD visibility separate from pause; pause alone keeps HUD. Explicit hide owners release only own request, respecting others/player preference. | First interview: “3. I agree”. |

Additional CORE-016 confirmations (second interview, 2026-11-05):

- **CORE-016-D04:** Active UI receives input; consume open/close actions and require fresh discrete gameplay presses on return. Held direction may resume movement. User: “1. I agree”.
- **CORE-016-D05:** Focus loss owns suspension; focus return releases only it. Background rendering/loading may continue, world simulation does not. User: “2. I agree”.
- **CORE-016-D06:** Intended gameplay rate remains distinct from zero effective paused advancement; resume uses current intended rate, not first-pause snapshot. No new rate feature approved. User: “3. I agree”.

Additional CORE-016 confirmations (third interview, 2026-11-05):

- **CORE-016-D07:** Pause gameplay-linked audio, allow music/UI/independent video, resume where supported without replaying effects. AV owns categories; focus mute remains separate. User: “1. I agree”.
- **CORE-016-D08:** Active context owns cursor/text; gameplay recaptures only when eligible/focused. Composition cleanup respects other active text fields. User: “2. I agree”.
- **CORE-016-D09:** Coherent nested pause/HUD/input handoffs prevent resume frames/flashes/leaks. Teardown releases only own requests, preserving lifecycle recovery gates. User: “3. I agree”.

The [CORE-016 specification](systems/CORE/CORE-016.md) is approved and finalized v1; see CORE-016-A01 below.

## CORE-017 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-017-D01 | 2026-11-05 | CORE-017 | Use authoritative CORE-015/016 simulation eligibility; input remains separately gated. | First interview: “1. I agree”. |
| CORE-017-D02 | 2026-11-05 | CORE-017 | Leave frequency open for combat/AI review while specifying reliable scheduling. No 16 Hz or DFU-effective target approved. | First interview: “leave the frequency open while defining reliable scheduling”. |
| CORE-017-D03 | 2026-11-05 | CORE-017 | Slow cadence only for declared consumers; other mechanisms remain appropriate. Explicit once-delivered step identity replaces shared sampled boolean. | First interview: “3. I agree”. |

Additional CORE-017 confirmations (second interview, 2026-11-05):

- **CORE-017-D04:** Subtract delivered intervals and retain fractional eligible time instead of resetting accumulator. User: “1. I agree”.
- **CORE-017-D05:** Bound catch-up work per pass, retain remaining eligible time, no silent dropping/unbounded bursts. Limits/long overload remain combat/AI/performance decisions. User: “2. I agree”.
- **CORE-017-D06:** Preserve pre-pause fraction without adding paused time; isolate new-session accumulator. Save phase persistence remains SAVE/TIME decision. User: “3. I agree”.

Additional CORE-017 confirmations (third interview, 2026-11-05):

- **CORE-017-D07:** Explicit stable dependency order, not incidental registration/tree order. Exact order/RNG remains RULE/COMBAT/NPC scope. User: “1. I agree”.
- **CORE-017-D08:** Stop gameplay work when suspension takes effect; track completed consumers to prevent duplicate resume work. Discard ended-session remainder; required failure recovers rather than skips/replays partial mutations. User: “2. I agree”.
- **CORE-017-D09:** Fixed cadence per running session; tuning/mod changes only at declared session/restart boundary with explicit restore-phase policy. No frequency slider implied. User: “3. I agree”.

The [CORE-017 specification](systems/CORE/CORE-017.md) is approved and finalized v1; see CORE-017-A01 below.

## CORE-018 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-018-D01 | 2026-11-05 | CORE-018 | Retain general DFU shortcut action set with configurable keyboard/controller bindings; exact defaults/windows remain owner scope. | First interview: “1. I agree”. |
| CORE-018-D02 | 2026-11-05 | CORE-018 | Gameplay-input context gates shortcuts; other contexts own bindings and all owner restrictions still apply. | First interview: “2. I agree”. |
| CORE-018-D03 | 2026-11-05 | CORE-018 | Quicksave validates/writes safely before success feedback; quickload uses coordinated confirmation/preflight. Missing current-character quicksave explains briefly without cross-character fallback. | First interview: “3. I agree”. |

Additional CORE-018 confirmations (second interview, 2026-11-05):

- **CORE-018-D04:** One window/quick action per dispatch, Escape/options first. Simultaneous quicksave+quickload rejects both with brief conflict feedback. Other priorities input/UI-owned. User: “1. I agree”.
- **CORE-018-D05:** Once per deliberate press, no autorepeat or held-key activation across context handoff. User: “2. I agree”.
- **CORE-018-D06:** Per-stable-character SAVE-owned quick target; capture save identity at invocation/revalidate before replacement. Names/UI changes cannot redirect. Rotation/backups SAVE-owned. User: “3. I agree”.

Additional CORE-018 confirmations (third interview, 2026-11-05):

- **CORE-018-D07:** Resolve same-context binding conflicts before Apply; allow mutually exclusive reuse. Preserve reachable menu navigation, including controller disconnect. User: “1. I agree”.
- **CORE-018-D08:** Busy conflicting quick actions reject with feedback, not queue. SAVE/CORE-007 own conflicts and execution rechecks eligibility. User: “2. I agree”.
- **CORE-018-D09:** Brief non-blocking actual-success/ordinary-rejection feedback uses owner reason; actual I/O/load failure uses recovery. Submission is never success. User: “3. I agree”.

The [CORE-018 specification](systems/CORE/CORE-018.md) is approved and finalized v1; see CORE-018-A01 below.

## CORE-019 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-019-D01 | 2026-11-05 | CORE-019 | NPC/COMBAT threat data, TIME rest policy and explicit query purpose; no automatic shared rest-distance policy. Owner distances/perception remain open. | First interview: “1. I agree”. |
| CORE-019-D02 | 2026-11-05 | CORE-019 | Check before rest and at declared advance boundaries, interrupt further rest promptly, retain committed elapsed time/recovery only. TIME/CHAR own ordering. | First interview: “2. I agree”. |
| CORE-019-D03 | 2026-11-05 | CORE-019 | Structured owner-scoped allow/block reasons, explicit blocker priority and scoped removal; text presence is not eligibility. | First interview: “3. I agree”. |

Additional CORE-019 confirmations (second interview, 2026-11-05):

- **CORE-019-D04:** Exclude dead/inactive/pacified/allied actors unless actual current threat; hostility uses owner proximity/detection/pursuit, not constant LOS. Brief occlusion alone does not permit rest. User: “1. I agree”.
- **CORE-019-D05:** Spawner blocking requires current encounter eligibility; disabled/exhausted/ineligible objects do not block by proximity. Eligible untriggered-spawner policy remains owner decision. User: “2. I agree”.
- **CORE-019-D06:** Required-check failure blocks/stops rest, explains verification failure and permits retry. Optional failures require explicit fallback, not silent permanent block. User: “3. I agree”.

Additional CORE-019 confirmations (third interview, 2026-11-05):

- **CORE-019-D07:** Stop further rest advance and show one message; resume only as UI/other gates permit. No auto-restart after blocker clears; fresh request required. User: “1. I agree”.
- **CORE-019-D08:** Generic threat feedback, no hidden names/positions/counts unless already legitimately revealed; owner-safe other reasons. User: “2. I agree”.
- **CORE-019-D09:** Fresh checks before each segment commit and relevant threat/encounter updates before next advance. Explicit cache scope/freshness; TIME/NPC own segment/order. User: “3. I agree”.

The [CORE-019 specification](systems/CORE/CORE-019.md) is approved and finalized v1; see CORE-019-A01 below.

## CORE-020 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-020-D01 | 2026-11-05 | CORE-020 | Distinct encounter activation/actor availability with session/location and origin, including restore versus new encounter. | First interview: “1. I agree”. |
| CORE-020-D02 | 2026-11-05 | CORE-020 | Explicit scoped/filter queries with separate existing-actor and pending-spawn counts. | First interview: “2. I agree”. |
| CORE-020-D03 | 2026-11-05 | CORE-020 | Owner-validated scoped/purposeful bulk changes; removal is not death and actor clear does not implicitly cancel spawners. Consequences remain owner-controlled. | First interview: “3. I agree”. |

Additional CORE-020 confirmations (second interview, 2026-11-05):

- **CORE-020-D04:** Announce registered/owned actor availability and committed encounter activation, not attempts. Essential rest/quest bookkeeping uses checked owner operations. User: “1. I agree”.
- **CORE-020-D05:** Capture bulk target set at acceptance, revalidate per target; no automatic inclusion of later arrivals without explicit ongoing policy/new request. User: “2. I agree”.
- **CORE-020-D06:** Per-target affected/skipped/failed reasons; owners decide partial acceptability/recovery. No false universal success or blind replay of completed mutations. User: “3. I agree”.

Additional CORE-020 confirmations (third interview, 2026-11-05):

- **CORE-020-D07:** Identify operations/completed targets to prevent repeated consequences; ended-scope requests cannot affect replacements. Retry revalidates unresolved work. User: “1. I agree”.
- **CORE-020-D08:** Restore-origin availability does not activate fresh encounters/rewards. Optional observer failure diagnoses without rollback/blocking others; required bookkeeping stays checked. User: “2. I agree”.
- **CORE-020-D09:** Hostility respects allegiance/pacification/quest/legal ownership; overrides require explicit supported owner operations. Exact exceptions remain domain scope. User: “3. I agree”.

The [CORE-020 specification](systems/CORE/CORE-020.md) is approved and finalized v1; see CORE-020-A01 below.

## CORE-021 interview decisions

| ID | Date | Feature | Confirmed decision | Approval reference |
| --- | --- | --- | --- | --- |
| CORE-021-D01 | 2026-11-05 | CORE-021 | Unified normal quit/interceptable OS close, living-session unsaved-loss confirmation and cancel preservation, no autosave; no character-loss prompt at idle menu/setup. | First interview: “1. I agree”. |
| CORE-021-D02 | 2026-11-05 | CORE-021 | Main-menu setup preserves ARENA2; active game first returns through confirmed menu flow. Existing validation/persistence/restart rules remain; opening setup does not change source. | First interview: “2. I agree”. |
| CORE-021-D03 | 2026-11-05 | CORE-021 | Resolve conflicting saves, tear down session, persist accepted unsaved app preferences, then release app/log/storage. No false saved result/silent failed-write discard. | First interview: “3. I agree”. |

Additional CORE-021 confirmations (second interview, 2026-11-05):

- **CORE-021-D04:** Failed preference save offers Retry or explicit warned Quit Without Saving Preferences. No auto-Apply of staged edits. User: “1. I agree”.
- **CORE-021-D05:** Responsive wait for conflicting work; preflight cancel follows existing rules, destructive restore/committed writes reach safe outcome. Separate quit intent, no general queue/forced interruption. User: “2. I agree”.
- **CORE-021-D06:** Forced termination has no orderly final-save/flush guarantee. No arbitrary normal-shutdown auto-kill timeout; failures expose recovery/exit choices and SAVE owns durability. User: “3. I agree”.

Additional CORE-021 confirmations (third interview, 2026-11-05):

- **CORE-021-D07:** Cancel before teardown releases only shutdown-owned intent/suspension. No session-restoration promise after teardown; cleanup failure offers Retry Cleanup/Quit. User: “1. I agree”.
- **CORE-021-D08:** Repeated Quit/OS close shares one intent; no stacked confirmations/repeated cleanup/implicit force consent. User: “2. I agree”.
- **CORE-021-D09:** Explicit restart uses orderly shutdown/relaunch where supported, preserves markers/paths and activates persisted pending values. Failed relaunch explains manual launch; never auto-restart on preference edit. User: “3. I agree”.

The [CORE-021 specification](systems/CORE/CORE-021.md) is approved and finalized v1; see CORE-021-A01 below.

## Complete specification approval records

- **CORE-021-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-021 Draft v1. The [specification](systems/CORE/CORE-021.md) is finalized v1, including documented platform/lifecycle/persistence dependencies. CORE-009 remains deferred and CORE-014 outside scope. This does not approve unrelated architecture or initiate implementation or another feature review.

- **CORE-020-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-020 Draft v1. The [specification](systems/CORE/CORE-020.md) is finalized v1, including documented query/identity and domain-consequence dependencies. CORE-009 remains deferred and CORE-014 outside scope. This does not approve unrelated architecture or initiate implementation or another feature review.

- **CORE-019-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-019 Draft v1. The [specification](systems/CORE/CORE-019.md) is finalized v1, including documented threshold, rest-ordering and encounter-policy dependencies. CORE-009 remains deferred and CORE-014 outside scope. This does not approve unrelated architecture or initiate implementation or another feature review.

- **CORE-018-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-018 Draft v1. The [specification](systems/CORE/CORE-018.md) is finalized v1, including documented binding/priority and SAVE contract dependencies. CORE-009 remains deferred and CORE-014 outside scope. This does not approve unrelated architecture or initiate implementation or another feature review.

- **CORE-017-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-017 Draft v1. The [specification](systems/CORE/CORE-017.md) is finalized v1; frequency, workload allowance, prolonged-overload behavior, exact ordering and save-phase policy remain open as documented. CORE-009 remains deferred and CORE-014 outside scope. This does not approve unrelated architecture or initiate implementation or another feature review.

- **CORE-016-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-016 Draft v1. The [specification](systems/CORE/CORE-016.md) is finalized v1, including documented owner-contract dependencies/deferrals. CORE-009 remains deferred and CORE-014 outside scope. This does not approve unrelated architecture or detailed cadence/TIME/AV contracts, or initiate implementation or another feature review.

- **CORE-015-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-015 Draft v1. The [specification](systems/CORE/CORE-015.md) is finalized v1, including documented owner-contract dependencies/deferrals. CORE-009 remains deferred and CORE-014 outside scope. This does not approve detailed CORE-016/017 policies or unrelated architectural proposals, or initiate implementation or another feature review.

- **CORE-013-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-013 Draft v1. The [specification](systems/CORE/CORE-013.md) is finalized v1, including documented owner-contract dependencies/deferrals. DFU/classic save compatibility stays outside current scope and CORE-009 remains deferred. This does not approve unrelated architectural proposals or initiate implementation or another feature review.

- **CORE-012-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-012 Draft v1. The [specification](systems/CORE/CORE-012.md) is finalized v1, including documented dependencies/deferrals for exact grants, visible popup order and exterior tutorial adaptation. CORE-009 remains deferred. This does not approve unrelated architectural proposals or initiate implementation or another feature review.

- **CORE-011-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-011 Draft v1. The [specification](systems/CORE/CORE-011.md) is finalized v1, including original marker/facing and calendar verification dependencies and other documented deferrals. CORE-009 remains deferred. This does not approve unrelated architectural proposals or initiate implementation or another feature review.

- **CORE-010-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-010 Draft v1. The [specification](systems/CORE/CORE-010.md) is finalized v1, including documented deferrals. CORE-009 remains deferred. This does not approve unrelated architectural proposals or initiate implementation or another feature review.

- **CORE-008-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-008 Draft v1. The [specification](systems/CORE/CORE-008.md) is finalized v1, including documented deferrals. This does not approve unrelated architectural proposals or initiate implementation or another feature review.

- **CORE-007-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-007 Draft v1. The [specification](systems/CORE/CORE-007.md) is finalized v1, including documented deferrals. This does not approve unrelated architectural proposals or individual entry modes, or initiate implementation or another feature review.

- **CORE-006-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-006 Draft v1. The [specification](systems/CORE/CORE-006.md) is finalized v1, including documented deferrals. This does not approve unrelated architectural proposals or initiate implementation or another feature review.

- **CORE-005-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-005 Draft v1. The [specification](systems/CORE/CORE-005.md) is finalized v1, including documented deferrals. This does not approve unrelated architectural proposals or initiate implementation or another feature review.

- **CORE-004-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-004 Draft v1. The [specification](systems/CORE/CORE-004.md) is finalized v1, including documented deferrals and the DATA validation dependency. This does not approve unrelated architectural proposals or initiate implementation or another feature review.

- **CORE-003-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-003 Draft v1. The [specification](systems/CORE/CORE-003.md) is finalized v1, including its documented deferrals. This does not approve unrelated architectural proposals or initiate implementation or another feature review.

- **CORE-002-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-002 Draft v1. The [specification](systems/CORE/CORE-002.md) is finalized v1, including its documented deferrals. This does not approve unrelated architectural proposals or initiate implementation or another feature review.

- **CORE-001-A01 — 2026-11-05 — Approved.** The user replied “I approve” to the explicit request to finalize CORE-001 Draft v1. The [specification](systems/CORE/CORE-001.md) is finalized v1, including its documented deferrals. No architectural proposal is approved wholesale by this decision. No implementation or subsequent feature review is initiated.

## UI-001 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-001-D01 | 2026-11-16 | Confirmed | Full-screen gameplay menus pause by default, passive HUD overlays remain live, and live interactive overlays own focused input. Make pause behavior moddable, including support for a profile with no ordinary UI-induced pause. User replied “Yes, but make this behavior moddable, say if somebody wanted to make no UI pause the game, similar to say Dark Souls kind of thing.” |
| UI-001-D02 | 2026-11-16 | Confirmed | Back dismisses one eligible layer and restores valid prior selection/focus. Offer Return to Game across eligible layers, subject to required choices and screen-owned draft rules. User replied “Yes” to the proposed navigation behavior and shared Return to Game action. |

- **UI-001-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-001 specification](systems/UI/UI-001.md) is finalized v1, including its documented screen-owner and MOD/DATA dependencies.

## UI-002 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-002-D01 | 2026-11-16 | Confirmed | Navigation and confirmation receive an explicit outcome, with busy rejection for admission failure and stale rejection for invalid targets. Repeated visual refreshes can merge. User replied “1. Yes”. |
| UI-002-D02 | 2026-11-16 | Confirmed | Ordinary screen shortcuts outrank quicksave and quickload, with Escape/options first under CORE-018. User replied “2. Yes” to the recommended order of these groups. |

- **UI-002-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-002 specification](systems/UI/UI-002.md) is finalized v1, including the full priority order, input dispatch boundary and deferred command rules.

## UI-003 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-003-D01 | 2026-11-16 | Confirmed | Open screens fresh unless their own specification explicitly defines retention. |
| UI-003-D02 | 2026-11-16 | Confirmed | Validate declared replacements before the main menu and offer explicit safe built-in fallback after runtime failure. Support small targeted edits as well as straightforward whole-window replacement. |
| UI-003-D03 | 2026-11-16 | Confirmed | Targeted edits follow a custom view that exposes compatible targets. Report incompatible or missing targets before main-menu entry and allow configuration correction. User replied “1. Yes”. |
| UI-003-D04 | 2026-11-16 | Confirmed | Support presentation edits and added text or action buttons. Changing existing behavior requires a declared action hook. Required controls must remain reachable. User replied “2. Yes”. |

- **UI-003-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-003 specification](systems/UI/UI-003.md) is finalized v1, including mod precedence and stock fallback for a single request.

## UI-004 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-004-D01 | 2026-11-16 | Confirmed | Adapt layout to available space, preserve retro artwork proportions and offer independent UI sizing. User replied “1. Yes”. |
| UI-004-D02 | 2026-11-16 | Confirmed | Use visible direct keyboard/controller focus, mouse hover without focus theft, deliberate click focus, and a controller cursor on screens suited to pointing. User replied “2. Yes”. |

- **UI-004-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-004 specification](systems/UI/UI-004.md) is finalized v1, including layout, focus fallback and controller pointing rules.

## UI-005 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-005-D01 | 2026-11-16 | Confirmed | Fresh Confirm or Back dismisses informational prompts, with per-message click-anywhere behavior. Consequential choices start on a safe option when available, and required choices without one demand deliberate selection. Back cancels only if permitted. User replied “1. Yes”. |
| UI-005-D02 | 2026-11-16 | Confirmed | Enter accepts active IME composition before a separate text submission. Rejection preserves typed text and explains the problem. Cancellation is distinct from submitted blank text. User replied “2. Yes”. |

- **UI-005-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-005 specification](systems/UI/UI-005.md) is finalized v1, including multiline input, paged information, pending validation and owner completion rules.

## UI-006 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-006-D01 | 2026-11-16 | Confirmed | Keep steady stock vitals, contextual breath, and exact status values. Allow mods to change vital appearance, position, shapes and formats including numbers only. |
| UI-006-D02 | 2026-11-16 | Confirmed | Prioritize soon-expiring effective disclosed effects in compact UI with steady warning and accessible overflow/details. Allow mods to change effect icons, display behavior and placement. |

- **UI-006-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-006 specification](systems/UI/UI-006.md) is finalized v1, including HUD customization, zero-maximum presentation, expiry coverage and effect ordering.

## UI-007 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-007-D01 | 2026-11-16 | Confirmed | Default compass and crosshair on with independent settings, show current interaction mode and actual mode-change feedback, and allow mods to change cue appearance, position and behavior. User replied “1. Yes”. |
| UI-007-D02 | 2026-11-16 | Confirmed | Briefly queue distinct routine notices, merge repeated outcomes, allow superseding mid-screen announcements and preserve owner prompts and recovery. Make notice policy and presentation moddable. User replied “2. Yes, but keep it moddable as usual.” |

- **UI-007-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-007 specification](systems/UI/UI-007.md) is finalized v1, including routine overflow, mid-screen supersession and hidden-HUD expiry.

## UI-008 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-008-D01 | 2026-11-16 | Confirmed | Play startup video once on first title entry per launch after required validation, with a startup preference and direct title bypass if missing or unplayable. User replied “1. Yes”. |
| UI-008-D02 | 2026-11-16 | Confirmed | Use DFU-style broad any-key skipping for startup/death, subject to fresh-input handoff rules. User replied “2. DFU's broader any-key behavior.” |

- **UI-008-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-008 specification](systems/UI/UI-008.md) is finalized v1, including the startup clip defaults, broad digital skip and menu retry rules.

## UI-009 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-009-D01 | 2026-11-16 | Confirmed | Share categorized settings between pause and title. Include Resume, Save, Load, Settings, Return to Title and common volume controls on pause. User replied “1. Yes”. |
| UI-009-D02 | 2026-11-16 | Confirmed | Preview audio and UI size reversibly. Use the CORE-006 display test and apply bindings and gameplay settings through their owner policies. User replied “2. Yes”. |

The interview reply also included “3. Yes”. The interview contained two questions.

- **UI-009-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-009 specification](systems/UI/UI-009.md) is finalized v1, including the shared settings draft, direct volume controls, settings-surface size preview and unapplied-edit exit prompt.

## UI-010 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-010-D01 | 2026-11-16 | Confirmed | Group native saves by character, newest first. Use context-specific Load defaults and current-character Save with New Save and explicit overwrite. User replied “1. Yes”. |
| UI-010-D02 | 2026-11-16 | Confirmed | Keep recognized unavailable slots visible with known reasons and use a screenshot placeholder. Restore valid selection after cancellation or failed preflight. Require fresh selection for changed or missing slots. User replied “2. Yes”. |

- **UI-010-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-010 specification](systems/UI/UI-010.md) is finalized v1, including generation-specific selection and confirmation, preview fallback and distinct empty and indexing-error states.

## UI-011 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-011-D01 | 2026-11-16 | Confirmed | Use a clean DFU-style step title without a separate progress indicator. Make character creation moddable. |
| UI-011-D02 | 2026-11-16 | Confirmed | Keep the stock wizard linear within the chosen branch. Expose Begin Game only after the required sequence, on the final summary. |
| UI-011-D03 | 2026-11-16 | Confirmed | Retain CHAR-001's five summary edits and require unfinished allocations to be corrected before completion. User confirmed “Yes”. |

- **UI-011-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-011 specification](systems/UI/UI-011.md) is finalized v1, including section-level validation feedback and pre-menu validation of modded routes.

## UI-012 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-012-D01 | 2026-11-16 | Confirmed | Opening the stock character sheet automatically begins pending allocation when safe, as requested. Make the trigger moddable. |
| UI-012-D02 | 2026-11-16 | Confirmed | Use a clean overview of effective stats and skills with separate details for permanent values and disclosed modifiers. Include History and Rename and support modded layout and presentation. User replied “2. Yes”. |

- **UI-012-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-012 specification](systems/UI/UI-012.md) is finalized v1, including manual retry after unsafe entry, return to the sheet between rewards and a moddable claim trigger.

## UI-013 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-013-D01 | 2026-11-16 | Confirmed | Use visible DFU-style stock action modes and paper doll with mouse, keyboard and controller access. Allow alternative modded interaction styles. User replied “1. Yes”. |
| UI-013-D02 | 2026-11-16 | Confirmed | Use a separate Split/Move Quantity action and ordinary whole-stack transfer. User noted the DFU Ctrl+left-click pattern, verified in the transfer source as a Ctrl modifier. |

- **UI-013-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-013 specification](systems/UI/UI-013.md) is finalized v1, including Ctrl+left-click for Split/Move Quantity and atomic whole-stack transfer.

## UI-014 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-014-D01 | 2026-11-16 | Confirmed | Use paged stock reading with remembered passage, return to the originating view and moddable presentation. User also requested images in custom books. |
| UI-014-D02 | 2026-11-16 | Confirmed | Use dedicated selectors with non-activating highlights and clear refusal while retaining valid selection. Successful spell readiness returns for normal cast input. Magic-item success follows its owner flow. User replied “2. Yes”. |

- **UI-014-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-014 specification](systems/UI/UI-014.md) is finalized v1, including per-character and per-work reading position, inline and standalone page illustrations, missing-image fallback, and selector outcomes.

## UI-015 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-015-D01 | 2026-11-16 | Confirmed | Keep separate stock Talk and service views, with an entry menu for mixed interactions and direct Talk where applicable. Support modded composition and layout. User replied “1. Yes”. |
| UI-015-D02 | 2026-11-16 | Confirmed | Finish stock services by returning straight to gameplay. Support modded return behavior. |

- **UI-015-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-015 specification](systems/UI/UI-015.md) is finalized v1, including stock service completion, moddable return behavior, cancellation and quest continuation.

## UI-016 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-016-D01 | 2026-11-16 | Confirmed | Default to Active Quests with History and Notebook, stock search across visible titles, earned text and notes, read-only quest records and editable personal notes. User replied “1. Yes”. |
| UI-016-D02 | 2026-11-16 | Confirmed | Offer Show on Map for authorized locations, preserve vague clues, and retain readable entries with feedback when a formerly valid place is unavailable. User replied “2. Yes”. |

- **UI-016-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-016 specification](systems/UI/UI-016.md) is finalized v1, including cross-view search, note deletion confirmation and historical map-link behavior.

## UI-017 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-017-D01 | 2026-11-16 | Confirmed | Use distinct stock merchant, bank and property screens with a shared transaction review when confirmation applies. Allow modded layout while preserving required terms and access. User replied “1. Yes”. |
| UI-017-D02 | 2026-11-16 | Confirmed | Use a short notice and updated quote when material terms change, with fresh acceptance under owner rules. User replied “2. Simpler notice followed by the new quote.” |

- **UI-017-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-017 specification](systems/UI/UI-017.md) is finalized v1, including the shared review layout, revised quote confirmation and eligible draft retention.

## UI-018 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-018-D01 | 2026-11-16 | Confirmed | Use distinct moddable crafting screens with live disclosed cost, restriction, capacity and ingredient previews. User replied “1. Yes”. |
| UI-018-D02 | 2026-11-16 | Confirmed | Use explicit review, disclose experiment risk without exposing the outcome, and retain drafts on Back or recoverable rejection. User replied “2. Yes”. |

- **UI-018-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-018 specification](systems/UI/UI-018.md) is finalized v1, including live previews, explicit review, renewed acceptance for changed terms and distinct feedback for unsuccessful experiments and technical failures.

## UI-019 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-019-D01 | 2026-11-16 | Confirmed | Share applicable map controls across devices, retain dungeon and travel specializations, and make layout and controls moddable. User replied “1. Yes”. |
| UI-019-D02 | 2026-11-16 | Confirmed | Center fresh local maps on the player and journal-linked maps on authorized places. Restore valid view state from child views and reset after a full close. User replied “2. Yes”. |

- **UI-019-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-019 specification](systems/UI/UI-019.md) is finalized v1, including shared controls, default viewpoints and stale-selection handling.

## UI-020 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-020-D01 | 2026-11-16 | Confirmed | Show familiar blocked choices with a reason, retain eligible alternatives and preserve valid selections on rejection. User replied “1. Yes”. |
| UI-020-D02 | 2026-11-16 | Confirmed | Show actual rest elapsed time and Stop. Use a moddable short travel progress view and truthful outcomes. User replied “2. Yes, but this will need some testing and probably revision, it is difficult to visualize through words alone.” |

- **UI-020-A01 — 2026-11-16 — Behavioral baseline approved.** The user replied “I approve” to the request to finalize the [UI-020 behavioral baseline](systems/UI/UI-020.md) as v1 with travel presentation open for playtesting and revision.

## UI-021 interview decisions

| ID | Date | Status | Decision and user input |
| --- | --- | --- | --- |
| UI-021-D01 | 2026-11-16 | Confirmed | Use explicit pleas and defenses, with one Continue acknowledgment after the verdict and sentence summary. User replied “1. Yes”. |
| UI-021-D02 | 2026-11-16 | Confirmed | Use stock hold-to-speed-up for prison presentation. User replied “2. Hold to speed up control, but all moddable of course.” |

- **UI-021-A01 — 2026-11-16 — Approved.** The user replied “I approve” to the request to finalize Draft v1. The [UI-021 specification](systems/UI/UI-021.md) is finalized v1, including the verdict acknowledgment, moddable hold-to-speed-up control and confirmed release feedback.

## CHAR-003 implementation clarification — 2026-11-26

During authorized IMP-015 increment 2, the user selected DFU's collision-advance
sampling for the **class-selection** questionnaire: “in that case just use DFU's
behavior I'd say.” Draw from all forty questions; on a duplicate, advance to the
next unused question. Retain ten distinct questions/order for the draft and
replace answer scores on revision. This resolves the sampling-policy dependency
in CHAR-003. Biography/background questions remain increment 3 and are unaffected.
The [implementation contract](../../main_project/scripts/char/CREATION_CAREER.md)
records operation-local reviewed PCG generation and the independent vector;
Unity/original-executable RNG sequence parity is not claimed.
