# CHAR-002 — Race and gender selection

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Establish the new character's birth race and gender, connecting identity to racial abilities and the supported appearance assets.

## Intended player experience

Choose a home province on the familiar map, read and hear its race description, understand its gameplay benefits, confirm the race and select Male or Female. These choices precede class and appearance selection under CHAR-001.

## Confirmed requirements

CHAR-002-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish the eight-race roster, map/description/narration/confirmation experience, Male/Female choice and race-specific assets, baseline racial abilities, accurate benefit disclosure and separate birth/effective race identity.

Inherited CHAR-001 rules remain binding: summary cannot directly edit race/gender; changes from summary require Restart. Restart/exit discard the entire draft without discard confirmation. Race-selection Yes/No confirmation is retained and is distinct from a discard prompt.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/CreateCharRaceSelect.cs`, `Setup`, `ClickHandler`, confirmation handlers: map picker pixels resolve race IDs; selection displays TEXT.RSC description tokens, plays a sound and offers Yes/No. Declining/cancelling the confirmation resets race selection; Back cancels the step.
- `Game/UserInterfaceWindows/CreateCharGenderSelect.cs`: Male/Female buttons close with the corresponding selection. Wizard close handlers transfer race/gender into `Game/Player/CharacterDocument.cs`.
- `Game/Entities/RaceTemplate.cs`: eight standard templates carry names, description/audio references, male/female body and head resources, and racial effect flags. Some gameplay bonuses are instead encoded in FormulaHelper/PlayerEntity.
- `Game/Entities/PlayerEntity.cs`, `AssignCharacter`, `BirthRaceTemplate`, `GetLiveRaceTemplate`: assigns creation identity and distinguishes birth template from a racial-effect override.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Original description/audio content and complete runtime interactions have not been verified; source remains unchanged.

## Detailed rules and behaviors

### Selection and identity

Initial playable races are Breton, Redguard, Nord, Dark Elf, High Elf, Wood Elf, Khajiit and Argonian. Additional races remain a later content/extensibility decision. Use the home-province map to select the corresponding race, followed by description, narration and explicit Yes/No race confirmation. A rejected selection does not advance creation or commit that race. Narration failure must allow selection to continue.

Present Male/Female selection after race confirmation, using the supported race-specific face/body sets. Independent gender/body/appearance controls are not introduced. Face selection remains CHAR-007 scope. This choice does not itself authorize new gender-based stat or skill modifiers; other verified owner rules require their own review.

Store the chosen birth race separately from effective race/appearance during later magical transformations. CHAR-019 determines which abilities and presentation transformations replace and how they revert. Do not overwrite birth identity merely to represent a temporary override.

### Racial ability baseline

Retain the following verified DFU baseline; detailed resolution and stacking remain owner specifications:

| Race | Baseline | Source |
| --- | --- | --- |
| Breton | Magic resistance flag | RaceTemplate, Breton constructor |
| Nord | Frost resistance flag | RaceTemplate, Nord constructor |
| High Elf | Paralysis immunity flag | RaceTemplate, HighElf constructor |
| Dark Elf | With a weapon, hit/damage modifiers each floor(level / 4) | FormulaHelper.CalculateRacialModifiers |
| Redguard | With a non-archery weapon, hit/damage modifiers each floor(level / 3) | FormulaHelper.CalculateRacialModifiers |
| Wood Elf | With an archery weapon, hit/damage modifiers each floor(level / 3) | FormulaHelper.CalculateRacialModifiers |
| Khajiit | +30 effective Climbing skill before enhancement and clamping | FormulaHelper.CalculateClimbingChance |
| Argonian | Reduced breath consumption; exempt from failed-swimming-check fatigue penalty | PlayerEntity underwater/per-minute activity logic |

Source details: racial combat modifiers require a non-null weapon, excluding unarmed attacks in the inspected function. Khajiit bonus precedes enhanced-climbing doubling and the source's 5–95 skill clamp. For Argonians, each inspected breath decrement has a 50% chance of being restored, rather than a fixed doubled breath pool; swimming still incurs ordinary applicable fatigue. These details describe the retained baseline, not a newly approved complete movement/combat algorithm.

Do not add racial attribute adjustments in this feature. Resistance percentages/rolls, interactions with class advantages/disadvantages, final combat calculations, climbing success, breath cadence and transformation override precedence remain relevant MAGIC/COMBAT/MOVE/CHAR owner contracts. Retaining these abilities does not resolve those contracts by implication.

### Disclosure and draft isolation

Alongside the original race description, display a concise accurate explanation of gameplay benefits before confirmation. Explain relevant limits without claiming stronger benefits: for example, reduced breath consumption is not water breathing. Presentation and gameplay must use consistent approved rules; exact wording/localization belongs to UI/content integration.

Race/gender selection modifies the isolated creation draft, not a live character. Revisiting selection cannot accumulate bonuses or grants. Handoff requires a supported completed selection and valid required data under CHAR-001/CORE-007/011. Do not silently substitute another race or gender when required data is missing.

## Relevant formulas and parameters

The ability table and source details above specify the approved baseline parameters. No additional stat adjustments or new gender-based numerical parameters are selected. Exact resistance resolution and cross-system stacking remain dependencies, rather than inferred percentages.

## Required data

Stable race identity; province-picker mapping; localized race name/original description; narration reference; accurate benefit presentation; supported gender values and race/gender appearance mappings; racial ability definitions/parameters; separate birth and effective-race state where applicable. Do not use translated names or UI row positions as durable identity.

## Inputs, outputs and events

Inputs: province selection, race confirmation/rejection, Male/Female selection, Back/Next, narration result and validated content. Outputs: candidate selection, confirmed draft birth race/gender and appearance/ability references for consumers. API and signal names remain implementation choices; selecting a race is not a live ability-grant event.

## Cross-system interactions

CHAR-001 controls flow/discard/submission; CHAR-007 owns face selection; CHAR-019 owns transformation semantics. UI/AV present map, text and optional narration. DATA provides validated definitions and resources; DATA-017 owns name-bank mapping rather than silently assuming Breton names. COMBAT/MAGIC/MOVE and character activity owners resolve racial mechanics. ITEM/appearance owners consume race/gender asset mappings. CORE validates and coordinates entry; SAVE preserves resulting identity through its versioned state.

## Edge cases and failure conditions

- Map clicks outside supported province mappings must not commit an unrelated race or advance the step.
- No/confirmation cancellation leaves the player able to choose again; it is not creation abandonment.
- Narration failure cannot block confirmation. Required gameplay/appearance-data failures remain distinct from optional audio failure; no unapproved visual fallback is selected here.
- Restart clears both choices and candidate ability state; previous-character/transformation state cannot leak into a fresh draft.
- Repeated confirmation or navigation cannot multiply bonuses. Birth identity remains intact while a transformation affects effective state.
- Missing required identity/mappings fail the affected preparation rather than silently selecting defaults. Exact presentation-resource recovery remains a UI/DATA dependency.

## Configuration and balancing options

Initial roster and Male/Female choice are fixed as approved. Later validated overrides and added races require their owner contracts. No independent body/gender mode, racial attribute adjustment or new player-facing balance toggle is introduced. Balance changes to retained abilities require explicit review.

## Save/load considerations

Unfinished drafts are discarded under CHAR-001. Completed characters preserve birth race/gender and sufficient definition identity for truthful restoration. Effective transformation state is separate under CHAR-019/MAGIC/SAVE. Loading must not apply racial grants again or reinterpret identity from translated labels. Missing required saved definitions require SAVE compatibility/recovery policy, not automatic race substitution.

## Technical constraints

Target: Godot 4.7.2. Keep identity, reusable definitions, appearance resources and effective overrides distinct. The original map's pixel IDs may be adapted without making them the only supported identity mechanism. Concrete resource formats, APIs and serialization remain engineering choices. Reference source and original assets remain unchanged.

## Acceptance criteria

1. All eight initial races are selectable through their mapped home provinces; unsupported map areas do not select a race.
2. Selection displays the original description, narration and accurate gameplay benefits before Yes/No confirmation; narration failure does not block progression.
3. Confirming advances to Male/Female selection; rejecting permits another race choice without committing the rejected candidate.
4. Supported race/gender selections resolve the appropriate face/body sets without introducing independent customization controls.
5. The listed racial abilities/parameters are retained through their owners; no additional racial attribute adjustments are introduced here. Detailed owner-resolution fixtures are required before mechanics can be considered complete.
6. Selection/revisiting never mutates the live character or stacks bonuses. Invalid required selections cannot reach successful entry via defaults.
7. Birth race survives effective racial overrides and restoration; CHAR-019 determines effective replacement behavior.
8. Summary restrictions, full-draft discard and no discard prompts comply with CHAR-001, while race confirmation remains available.
9. Save/load preserves identity and does not duplicate benefits; missing required content follows explicit compatibility/failure policy.

These are future verification criteria. No implementation or runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001 and relevant CORE-007/011/012, DATA-001/008/017 constraints and the character architecture review. No direct contradiction identified. Race confirmation does not restore rejected discard prompts. Birth/effective separation does not preapprove CHAR-019 transformation rules. Explicit racial baseline approval does not approve all source formulas, gender-based mechanics or architecture proposals wholesale.

## Outstanding questions and approval

No further blocking selection-policy question is identified. Before implementation is complete: verify original province/text/audio and race/gender asset mappings; define required versus optional appearance resources and recovery; complete owner rules for resistance/stacking, combat, climbing, swimming and transformation; define stable race schema and SAVE compatibility. Exact benefit wording must follow those rules. These dependencies do not waive retained abilities or permit silent identity substitution.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-002-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented owner-resolution, resource and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
