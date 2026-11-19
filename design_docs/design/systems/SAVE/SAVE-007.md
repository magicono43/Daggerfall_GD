# SAVE-007 — Serialization and compatibility

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Players can continue a character after upgrading the game. The game checks compatibility before replacing a session and explains what the player can do when a save requires unavailable content or an unsupported version.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#Serialize` and `#Deserialize` use FullSerializer to encode and decode typed JSON records. The manager writes a save-format version to slot metadata and supports strict deserialization through an assert-success option. `SerializablePlayer.cs` handles older data shapes, including uninitialized regional records and legacy exterior positions. These are findings from static source inspection.

## Confirmed requirements

- **SAVE-007-D01.** Support valid native saves from every stable public release starting with 1.0. Pre-release saves are supported when compatibility is explicitly announced.
- **SAVE-007-D02.** Use one top-level base-game save-format version. Base-game owners supply migrations for their records. Mods can version their own saved data independently.

## Detailed rules and behaviors

1. Identify native saves and read the base format version before interpreting gameplay records. Compare it to the supported format range and available migration paths. A release number may aid diagnostics. Compatibility is determined by the saved format and content requirements.
2. Maintain a supported path from each covered stable release to the current reader, including when players skip releases. Format-compatible changes can share a version. Changes that require migration use an explicit version transition. SAVE coordinates migrations and validates the prepared result. Each base-game owner defines the semantics for its records, default values justified by the source format, and dependencies needed for migration.
3. Apply migrations to the selected generation's prepared data during cancellable preflight. Preserve durable identities, references, and committed gameplay consequences. Check that the resulting required records are valid together before session replacement. Preserve the original save on disk. A later successful save publishes in the then-current format under SAVE-006.
4. Identify mod records by stable package identity and independent payload version. Ask the responsible owner to validate or migrate its supported data under the active content plan. Failure involving required content or required mod records blocks loading. Optional recovery follows an explicit owner policy and SAVE-005 disclosure. Rebuild explicitly disposable caches as allowed by CORE-013.
5. Distinguish an unsupported version, absent required data, malformed data, unavailable required content, and failed migration in player-facing feedback. Preserve the running session on any preflight failure. Show recognized unavailable slots with the known reason under SAVE-001. A newer save presented to an older build requires a supported reader. No downgrade compatibility is promised.

## Parameters, required data, and configuration

No gameplay formulas apply. The compatibility baseline is stable public release 1.0. Required information includes native identification, base format version, stable save and record identities, required and optional record declarations, migration coverage, and content dependencies. Mod records also carry package identity and payload version. Exact encodings, field layouts, and version-number representation remain technical choices.

## Inputs, outputs, and events

Inputs include the selected committed generation, its format and records, registered migration paths, the resolved content plan, and owner validation results. Outputs include validated prepared input and any recovery disclosure, or a specific incompatibility or validation reason. CORE-007 and SAVE-005 coordinate cancellation and load outcomes.

## Cross-system interactions

[SAVE-001](SAVE-001.md) identifies recognized slots and reports known availability. [SAVE-005](SAVE-005.md) governs preflight and recovery disclosure. [SAVE-006](SAVE-006.md) publishes complete committed generations. [CORE-013](../CORE/CORE-013.md) defines native scope, preflight safety, and restore readiness. DATA and MOD validate content and package dependencies. Gameplay owners validate and migrate their own state.

## Edge cases and failure conditions

- A player skips multiple public releases. Preflight uses a supported migration from the original format to the current reader without requiring those releases to be installed.
- A valid older-format save can still require unavailable content. Identify the missing dependency and preserve the current session.
- A required migration produces invalid records or unresolved references. Reject the prepared result and preserve the source generation.
- An unknown newer format or unsupported pre-release format stays unavailable when recognized. A missing optional preview follows SAVE-002 independently of format compatibility.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Support this project's native saves. Treat record decoding, migration, cross-record validation, and session application as distinct responsibilities. Preserve fixtures for covered format versions and relevant mod-version transitions. Check migration output against owner invariants and required references before replacing the active session.

## Acceptance criteria

1. Representative valid saves from each covered base format load on the current build given compatible required content. This includes direct upgrade from the oldest covered format and saves from players who skipped releases.
2. Supported migrations preserve durable references and committed outcomes. Loading, failing, or canceling preflight leaves the source generation unchanged.
3. Unsupported formats, corrupt required records, failed migrations, and missing required dependencies yield distinct actionable results. Preflight failure preserves the active session.
4. A mod payload can migrate independently of the base-game format. An owner-approved optional recovery is disclosed before replacement.
5. A later successful save uses the current version and follows SAVE-006 publication.

## Outstanding questions and approval

Concrete schemas, migration paths for actual format changes, per-owner record declarations, and mod compatibility registration remain follow-on design or implementation choices. See [SAVE-007-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-007-interview-decisions).
