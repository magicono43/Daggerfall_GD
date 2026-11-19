# CORE-014 — Classic save session entry

Review status: **Outside current scope — recorded 2026-11-05.**
Specification approval status: No classic-import gameplay specification approved.

## Scope decision

During CORE-013 review, the user explicitly chose to focus on saves functioning with this Godot implementation and exclude DFU/classic save compatibility. That decision was included in approved CORE-013 v1 (CORE-013-D01 / CORE-013-A01).

CORE-014 is the classic-save import feature, so it falls under that existing exclusion. The subsequent request to review CORE-014 did not explicitly reverse it. This record applies the approved scope decision; it does not claim a new approval or permanently reject future compatibility work.

## Reference behavior

DFU's `Assets/Scripts/Game/Utility/StartGameBehaviour.cs`, StartFromClassicSave and RestoreOldClassSpecials, translate classic save records into a running session. Existing details remain in the [CORE feature catalog](../../../analysis/systems/CORE_FEATURE_CATALOG.md). Original-game ARENA2 content is still required under CORE-004; reading that content is separate from importing classic saves.

## Reconsideration

Retain CORE-014's stable ID and analysis. Reopen specification only if the user explicitly brings classic-save compatibility into scope. Until then, do not define import fidelity rules, migrations, coding tasks or implementation. Native Godot save entry is covered by [approved CORE-013](CORE-013.md).

Source remains unchanged. No implementation or coding tasks have been produced.
