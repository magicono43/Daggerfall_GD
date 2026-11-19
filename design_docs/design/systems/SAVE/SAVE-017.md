# SAVE-017 — Mod save payloads

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Players can continue a character with compatible mods and understand what happens when a mod is unavailable. Adding a mod to an existing game is possible when the mod supports it. An eligible load without an optional mod preserves the source save. A later successful save from that session omits the unavailable mod's data.

## Existing Daggerfall Unity behavior

In DFU 1.1.1, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#SaveGame` writes enabled mod state to separate files named using the mod filename. `#LoadGame` enumerates mods with save interfaces, deserializes files when present, or calls `NewSaveData` when absent. It reports per-mod failures and continues. A failed capture or write during overwrite can leave an earlier mod file alongside newer core state.

## Confirmed requirements

- **SAVE-017-D01.** After an eligible load without an optional mod, omit that mod's payload from any subsequent successful save from that session. Loading and failed saves preserve the source generation under the existing native save rules.
- **SAVE-017-D02.** Allow a newly added mod to initialize when the save contains no prior payload for it and its declared policy supports joining an existing game. Corrupt or incompatible prior data requires migration or approved recovery.

## Detailed rules and behaviors

1. Identify payloads by stable package ID and mod-owned version under SAVE-007. Validate the active provider, supported version or migration, and required dependencies during preflight. A changed filename alone does not change package identity. The owning mod defines compatible migration, required state, and safe optional recovery.
2. Block loading if unavailable or incompatible mod state is required by the save or by another required gameplay reference. For data eligible for omission, disclose the unavailable mod, the player-visible consequence, and that the next successful save from this session will omit its payload. Follow SAVE-005 disclosure and cancellation rules.
3. Restore compatible payloads or validated migrations through the owner. For a genuinely absent payload, initialize only under a declared policy compatible with the selected saved state and resolved content plan. Preserve validated owner behavior for new characters separately. Missing required prior records, corrupt data, and unsupported versions cannot enter the new-mod initialization path.
4. Capture current mod state at the SAVE-006 snapshot boundary. Publish it with the same save generation. A required capture or write failure fails the save. An optional failure uses declared owner handling with an intelligible outcome. Old files cannot supply stale state for a new generation.
5. Exclude the unavailable optional mod payload from each newly committed generation produced by that session. Loading and failed publication preserve the source. If the player creates a distinct slot, the earlier source slot keeps its own payload. If the player successfully overwrites the source, SAVE-006 governs cleanup of the prior generation. Reinstalling a mod cannot recover omitted state from a generation that lacks it.

## Parameters, required data, and configuration

No gameplay formulas apply. Required data includes stable package ID, payload version, saved generation, active content plan, required and optional dependency classification, migration and initialization policy, and validation and restore outcomes. Exact encoding, API and policy registration belong to SAVE and MOD.

## Inputs, outputs, and events

Inputs include owner snapshot results, saved payload and dependency records, compatibility and migration results, and declared initialization or recovery policies. Outputs include a validated payload, eligible initialized state, diagnosed omission, or required failure, plus owner readiness. Save publication produces one coherent generation and load readiness follows CORE-013.

## Cross-system interactions

[SAVE-005](SAVE-005.md) governs recovery disclosure, [SAVE-006](SAVE-006.md) governs coherent publication, and [SAVE-007](SAVE-007.md) governs versioning and migration. [SAVE-016](SAVE-016.md) requires owner readiness before success. MOD and DATA validate providers, content, and dependencies. Gameplay owners determine when a mod-provided record is required by saved state.

## Edge cases and failure conditions

- Renaming a package file preserves access to compatible payload data when package identity matches.
- Re-enabling the mod and loading the original generation can restore its retained state if compatible. Loading a later generation without the payload uses the applicable policy for absent state.
- An optional package can still supply required effects, items, or quest facts for a particular save. Such dependencies block omission unless validated recovery resolves them.
- A failed overwrite preserves the previous generation and its mod payloads. Repeated preparation cannot replay completed gameplay consequences.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Prepare migrations without modifying the source generation. Scope owner results to the current request and session. Bind payloads and dependency metadata to the coherent committed generation. Required mod restoration participates in readiness before gameplay resumes.

## Acceptance criteria

1. A compatible mod payload restores through its stable package ID even when its package filename changes. Its version migrates independently of the base format.
2. An unavailable required dependency blocks loading through approved recovery. Eligible optional omission is disclosed before replacement.
3. Loading without an eligible optional mod leaves the source unchanged. A successful resave omits the data, and failed replacement leaves it intact. Creating a distinct slot preserves the prior slot.
4. A newly added mod initializes only when there is no prior payload and the owner supports joining an existing save. Corrupt or incompatible prior data follows explicit migration, recovery, or failure.

## Outstanding questions and approval

The concrete package registration interface, payload encoding, and owner migration and recovery contracts remain follow-on design. See [SAVE-017-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-017-interview-decisions).
