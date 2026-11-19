# DATA-002 — Classic reader initialization and access

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Make classic records available to world, location, gameplay and presentation consumers after source selection. Establish truthful reader readiness and useful access failures without requiring every asset to be decoded at startup.

## Intended player experience

Required source-initialization problems are caught before the normal main menu. Starting another character or changing locations does not unnecessarily reopen the same archives. Compatible modified classic data remains supported. Later record failures follow the affected feature's recovery policy rather than silently producing missing required content.

## Confirmed requirements

DATA-002-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish:

- Open required sources and prepare basic indexes before the normal main menu; decode individual records when needed.
- Required-reader startup failure blocks normal entry, reports affected files/reasons through independent UI, and offers Retry, Choose Folder and Quit. Clean up a failed attempt before retrying; do not expose partial required initialization as ready.
- Distinguish record not found, source unavailable, and malformed/unsupported data. Consumers own recovery; required content must not silently become empty records.
- Keep initialized readers and reusable caches across characters, menus and location transitions; character state remains session-owned.
- External edits require application restart; no live reload or continuous monitoring.
- Choose memory/disk access through measurements, with equivalent read-only behavior and failure reporting, and no initial player-facing setting.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `DaggerfallUnity.cs#SetupContentReaders` constructs `ContentReader` with the validated ARENA2 root or an empty path. Construction alone is permitted even without validated classic data.
- `Utility/ContentReader.cs#SetupReaders` creates block, map, monster, woods, faction, flats and paint readers, generally using `FileUsage.UseMemory` and read-only access. Faction input is the packaged StreamingAssets faction file rather than an ARENA2 file. The method then sets its ready flag without aggregating individual load results.
- `ContentReader#GetBlock` and `GetLocation` test the facade flag, then interpret an unknown block type or unloaded location as lookup failure. The map dictionary is built lazily through `MapDictCheck`/`EnumerateMaps`.
- `API/FileProxy.cs#Load` supports memory-backed, disk-backed and byte-backed access. `API/BsaFile.cs#Load` opens and indexes archives, while record access retrieves bytes separately. Lower-level readers expose differing failure forms, including false, null, unloaded data and exceptions.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Findings are static observations, not runtime validation. Source remains unchanged. The facade's reader list is not claimed to enumerate every classic reader in the project.

## Detailed rules and behaviors

### Initialization and publication

Use DATA-001's resolved, accepted source and CORE-004's activation rules. Basic directory validation and reader initialization are separate prerequisites. Before normal main-menu entry, open each required source and prepare the basic archive/index structures needed to support subsequent record requests. This is not full world construction, complete record decoding, or proof every record is usable.

Publish required-reader readiness only after all required initialization succeeds. An allocated reader object or passing DATA-001 check is insufficient. Keep partially initialized required access unavailable to normal consumers. On failure, release resources from the failed attempt before retrying and show affected source files and reasons through independent UI with Retry, Choose Folder and Quit. Cleanup must complete safely before another initialization attempt; CORE-005's required-service cleanup rules remain binding.

Required-source classification must be documented from actual consumer dependencies. Missing optional capability uses only its explicitly approved fallback. In particular, optional videos under DATA-001 do not become mandatory because required readers initialize early. This feature does not approve treating an otherwise required gameplay source as optional.

### Record access

Decode individual records when requested rather than eagerly decoding every location and asset. Consumers receive a successful usable record or an explicit failure distinguishing at least: record not found, source unavailable, and malformed/unsupported data. Carry source and requested-record context when available so the owner can diagnose the failure. A request made before initialization completes must not be represented as a successful empty record.

Keep access semantics separate from recovery policy. LOC/WORLD decide how a required block failure affects location entry; AV and playback owners apply approved optional-media fallback; other consumers retain their own failure rules. DATA must not silently replace missing required content, select a different installation, or convert parse failure into a successful default value. Missing records that are legitimate optional queries remain distinguishable from corrupt data.

Support modified original data under DATA-001's compatibility policy. Decode according to supported formats, without requiring original checksums, sizes, record populations or content values. Actual malformed or unsupported data may still fail decoding after basic startup validation passes.

### Lifetime and external changes

Readers and reusable content caches have application lifetime and remain available across character changes, menu returns and location transitions. Session-specific character/world mutations stay with their owners and must not leak into shared definitions or caches. Reusable cache lifetime does not require retaining every decoded record indefinitely; concrete cache retention remains a measured implementation choice.

All active readers use the current approved source selection. CORE-004's pending source changes do not replace running readers or their caches before application restart. External classic-file edits likewise require restart to be supported. Do not implement live reload or continuous file monitoring as part of this feature.

This restart policy is not a guarantee that files can be edited safely during play. Memory and disk access can observe external mutation differently; without monitoring or copying every file, a coherent immutable byte snapshot is not promised. Actual read/decode failures still surface truthfully under owner recovery. Restart revalidates the source and rebuilds reader/index state.

### Storage access

Classic source files are read-only inputs. Memory, disk or mixed access may be selected by implementation measurements of startup time, memory use and loading delays. All modes preserve the same successful record meaning, read-only source policy and failure categories; physical availability can differ when external files disappear or change. No initial player-facing memory/disk preference is approved.

## Relevant formulas and parameters

No gameplay formulas or balance values apply. Readiness requires successful initialization of all declared required readers. No fixed memory budget, cache size, startup duration, timeout, preload count or threading strategy is selected here.

## Required data

Active resolved source identity/root; required/optional source and reader inventory; supported format definitions; basic indexes; initialization results; record identifiers and access results; failure source/reason; application-owned reusable cache context. Exact required readers, per-format initialization work and index requirements remain technical dependencies. Include packaged definitions where their consumers require them rather than assuming every source lives in ARENA2.

## Inputs, outputs and events

Inputs: accepted active root, packaged source dependencies, initialization/retry requests, record queries, source availability and application shutdown. Outputs: truthful initialized/not-ready/failed outcomes, decoded records or differentiated access failures, and diagnostic context. Readiness is separate from session/location readiness and gameplay eligibility. These are conceptual outcomes, not concrete API or signal names.

## Cross-system interactions

- DATA-001 selects and basically validates external data; DATA-002 initializes access and decodes requested records. Neither replaces the other's checks.
- CORE-003 persists path settings. CORE-004 controls initial activation, startup recovery and pending-source restart rules. CORE-005 controls application/session lifetimes, safe cleanup and required-service failures.
- WORLD/LOC consume geography and layout records; their reconstruction and failure recovery remain owner responsibilities. Other DATA features own domain record interpretation and lookup semantics.
- CHAR and other session owners retain mutable gameplay state. Returning to the menu releases session state without discarding reusable application content solely because a character ended.
- UI provides error presentation independent of classic assets. CORE-002 owns optional logging and privacy filtering. AV/media owners retain approved optional fallbacks.
- SAVE restores mutable state and checks compatibility; classic reader readiness neither proves save compatibility nor restores a session.

## Edge cases and failure conditions

- DATA-001 passes but a required archive cannot initialize: block normal entry, report the initialization failure and clean up before retry.
- Some readers succeed and another fails: do not expose the partial set as required-ready. Repeated retry must not accumulate open handles or stale indexes.
- A record is absent, its source disappears, or its bytes are unsupported/corrupt: return the corresponding failure category; do not conflate these with a valid empty result.
- A pending new directory is valid while the old directory remains active: retain existing readers until restart, even after returning to the menu or changing character.
- An optional video is absent: preserve DATA-001/CORE-008 optional-media behavior.
- External files are edited during execution: no supported live refresh; cached and disk-backed data are not promised to remain coherent. Restart is required, and actual failures follow consumer/CORE recovery.
- A required current application reader/service disappears during play: retain CORE-005's suspension and safe recovery/restart policy. An isolated record failure is not automatically equivalent to loss of the entire reader service.

## Configuration and balancing options

No gameplay balance settings or player-facing preload/storage controls are introduced. Required versus optional classification follows owner contracts, not a user toggle that bypasses required initialization. Performance choices remain measurable implementation decisions.

## Save/load considerations

Reader handles, indexes and cache objects are reconstructed application resources, not character-save payloads. Character loading must not change the active source or activate pending settings. Share reusable content across successive sessions while keeping each session's mutable state isolated. Save/content identity, missing-definition recovery and migration remain SAVE/domain specifications.

## Technical constraints

Target engine: Godot 4.7.2. Separate source validation, reader initialization, per-record decode and engine resource creation. Keep source inputs read-only, initialization outcomes truthful and consumer recovery explicit. Do not depend on Unity facade-ready flags or assume reader construction proves loading success. APIs, decoder libraries, threading, index layouts, cache eviction and memory/disk selection remain implementation details; broader DATA architecture proposals are not approved wholesale.

## Acceptance criteria

1. Required sources open and their basic indexes initialize before the normal main menu; individual locations/assets are not all decoded eagerly.
2. A failed required reader prevents ready publication and normal entry, reports source/reason through independent UI and offers Retry, Choose Folder and Quit.
3. Retry begins only after safe failed-attempt cleanup; repeated attempts do not retain stale reader/index state or leak resources.
4. Record queries distinguish not found, source unavailable and malformed/unsupported data. Failed or premature requests never return successful empty required records.
5. Consumers apply their own approved recovery, preserving both required-location failure and optional-media fallback behavior.
6. Compatible modified data works without exact-original content requirements; malformed individual records can fail even after basic validation succeeds.
7. Initialized readers and reusable caches survive character/menu/location transitions without sharing character-specific mutable state.
8. Pending source selection does not replace active readers before restart. Restart revalidates and initializes the selected source; no live file reload or continuous monitoring occurs.
9. Source files remain unchanged. Memory/disk choices preserve successful decoding semantics and error categories without a player-facing setting.
10. Required-service loss follows CORE-005; isolated record errors retain their consumer-specific recovery. Reader readiness never alone authorizes session readiness or gameplay.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001, CORE-004 source selection/activation, CORE-005 application/session ownership and recovery, CORE-008 optional death-video fallback, and the recorded interview decisions. No contradiction identified. Before-menu initialization strengthens the required-data readiness gate without adding exhaustive DATA-001 validation or requiring optional videos. Application content reuse preserves CORE session teardown. External edits remain unsupported until restart without inventing a snapshot guarantee. No implementation or coding tasks are authorized.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Technical dependencies remain: enumerate required versus optional readers/sources with domain owners; define basic indexes and initialization success per format; specify concrete result/context contracts; verify original, modified and malformed fixtures; measure memory/disk/cache behavior; establish owner-specific later record recovery where not already approved. DATA-001's exact manifest/format-check dependencies remain open. These items must be resolved before implementation can be considered complete.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-002-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical dependencies remain open, including the required-reader inventory, format contracts and measured performance choices. Approval does not initiate implementation, coding tasks or another feature review.
