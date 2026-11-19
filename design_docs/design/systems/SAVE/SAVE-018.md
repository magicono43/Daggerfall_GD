# SAVE-018 — Classic save import

**Review status — Outside current scope under approved CORE-013.** Reviewed 2026-11-17.

## Scope decision

The approved native-load scope covers saves created by this Godot implementation. It excludes classic Daggerfall and DFU save import. SAVE-018 is the persistence counterpart of the deferred classic session entry feature. [CORE-013](../CORE/CORE-013.md) · [CORE-014](../CORE/CORE-014.md)

## Daggerfall Unity reference behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Utility/StartGameBehaviour.cs#StartFromClassicSave` uses the classic `SaveGames`, `SaveTree`, and `SaveVars` readers to translate a selected legacy slot into a running session. The path reads legacy location and character data and applies conversion rules for supported player and world state. The available analysis is based on static source inspection. Import fidelity would require representative classic fixtures.

## Review disposition

Retain the feature ID and reference analysis. Reopen the import design if the user explicitly brings classic save compatibility into scope. The current scope decision authorizes the native SAVE features. [SAVE feature catalog](../../../analysis/systems/SAVE_FEATURE_CATALOG.md#save-018--classic-save-import)
