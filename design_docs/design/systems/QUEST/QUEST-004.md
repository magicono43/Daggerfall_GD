# QUEST-004 — Automatic starts and one-time tracking

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-004-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-004-interview-decisions).

## Gameplay purpose and intended player experience

Initialize the intended opening quests for a new character and remember which one-time quests that character has taken on. Players can decline the tutorial and still reach the main-story opening. Declining a one-time offer can leave that quest available through a future opportunity. Taking it on successfully consumes it for the character.

## Confirmed requirements

- Record one-time history per character by stable quest definition ID when acceptance and activation commit together. Decline, closure and failed activation leave history untouched. Completion, failure or abandonment after activation preserve the record.
- A successfully activated automatic quest uses the same history if its definition is one-time. Repeatable quests remain governed by their ordinary rules.
- Mods can declare startup registrations with stable IDs, dependencies and deterministic ordering. Additional entries default to optional and can explicitly be required. CORE-012 continues to govern the required main-story opening and optional tutorial.

See QUEST-004-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-004-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Utility/StartGameBehaviour.cs#StartNewCharacter` requests `_TUTOR__`, `_BRISIEN`, an optional launch quest, then registered startup-list quests. `QuestListsManager.cs#InitAtGameStartQuests` loads the registered entries, skips null results and starts loadable quests. Start request order alone does not establish the actual popup order.

`QuestListsManager.cs#QuestMachine_OnQuestStarted` appends a one-time quest's name if its acceptance list exists. `QuestMachine.cs#Tick` can emit a second notification after `StartQuest(Quest)` has already emitted one. `SerializablePlayer.cs` stores and restores the list. These findings are from static inspection.

## Detailed rules and behaviors

### Fresh-character startup

1. Resolve a validated startup plan for the fresh-character entry operation. Registrations declare stable registration and quest definition IDs, dependencies, and required or optional policy. Preserve the built-in opening policies. Process dependencies before dependents and resolve independent entries deterministically using the resolved content order and stable registration IDs.
2. Validate missing dependencies, cycles and duplicate registrations before using the plan. Reject multiple registrations for the same definition in a startup plan. If a prerequisite fails at runtime, mark its dependent as blocked and apply the dependent's required or optional policy. Surface the cause and affected registration.
3. After CORE confirms the required startup context and world are ready, request quest initialization through the authoritative start operation. Retry delivery for the same fresh-entry operation reuses its outcome. A required failure triggers CORE-007/012 safe-entry recovery. An optional failure warns once and startup can continue when all required steps remain satisfied.
4. Present immediate opening messages through the CORE-012 queue before releasing player control. Tutorial participation remains an accept-or-decline choice. Delayed events keep their authored triggers. Exterior starts retain required opening content and adapt tutorial steps to the intended placement. Exact built-in popup order and exterior tutorial content remain open.

### Acceptance and automatic activation

1. The resolved definition determines one-time policy consistently across guild, social, startup and scripted starts. If legacy rows disagree about the same definition's one-time status, require an explicit resolution during content validation.
2. At acceptance, revalidate the offer and check current character history. For a one-time definition, publish activation and the history record together. If activation cannot commit, use the owner failure path and leave history unconsumed. Concurrent or duplicate requests cannot activate a one-time definition twice. A stale competing offer reports unavailability under its owner rules.
3. Successful automatic activation uses the same check and records consumption for a one-time definition. A failed or blocked start leaves no record. A repeatable quest still uses request identity to avoid duplicate activation from callbacks or retry delivery.
4. Publish a committed start notification once per successful start operation. Show acceptance confirmation after the authoritative acceptance commit. Observer notifications, offer display, decline, expiry, and restored active records do not consume a quest. A stock NPC opportunity can still be spent at presentation under NPC-023.

## Required data, inputs, outputs and events

Inputs include a fresh-entry or activation request ID, stable character, definition, instance, offer and registration IDs where applicable, the startup dependency graph and requiredness, readiness, authorization and one-time policy. Outputs include committed activation and history, prior committed result, consumed or unavailable offer, blocked registration, or an explicit failure. A committed start event carries the start identity and origin. CORE consumes required startup outcomes and immediate presentation requests.

## Cross-system interactions

CORE-007/012 own safe entry, retries, control release and opening presentation gates. DATA-003/012 and MOD resolve and validate startup contributions. QUEST-001 supplies stable definitions and list metadata. QUEST-002/003 query one-time history for eligibility. NPC-023 and MOVE-023 govern offer identity, presentation and choice. QUEST-008 owns the general runtime lifecycle, and SAVE coordinates coherent restoration.

## Edge cases and failure conditions

- Two visible offers for one definition can coexist before acceptance. The first successful commit consumes the quest. The other cannot start it or apply acceptance effects.
- Failed optional initialization can block dependent entries. If any blocked dependent is required, entry fails safely. A failed fresh-entry attempt cannot leak its partial history or start receipts into the clean replacement.
- Declining or closing can spend the current NPC opportunity while leaving the quest eligible through a future opportunity. Completing, failing or abandoning an activated one-time quest preserves consumption.
- Loading saved state does not execute the fresh-character plan or emit new starts for restored quests. Duplicate delivery cannot apply a grant, quest effect, or acceptance twice.

## Configuration and balancing

Authors configure one-time policy and startup registrations through validated content. Startup dependencies and requiredness are explicit. There are no numeric balance formulas. A definition replacement retaining its stable ID preserves history subject to approved compatibility and migration rules.

## Save/load considerations

Persist the character's one-time history independently of active quest records. Save activation and its history from a coherent committed state. Restore history before eligibility queries and acceptance become available. Missing or incompatible saved definition references require explicit compatibility or recovery under DATA-012 and SAVE. Exact save schema and treatment of supported unfinished operations remain integration decisions.

## Technical constraints

Target Godot 4.7.2. Keep startup planning, activation, and presentation distinct. Validate startup plans without running quests. Use stable identities and one authoritative start commit for both offers and automatic requests.

## Acceptance criteria

1. Fresh entry initializes the required main-story opening and presents the optional tutorial under CORE-012. Delayed events retain their triggers. Load does not rerun the plan.
2. Valid startup dependencies determine order. Missing dependencies, cycles and duplicates are detected. Optional failure warns once and can continue. A required failure or blocked required entry uses safe-entry recovery.
3. Decline, closure and failed activation leave one-time history unchanged. Successful acceptance or automatic activation of a one-time definition consumes it across channels. Later quest outcomes preserve consumption.
4. Concurrent acceptance, duplicate callbacks and repeated startup delivery yield a single applicable activation, history record and start notification. Repeatable quests can still start on separate legitimate requests.
5. Restoring a character preserves one-time history even after the quest is no longer active. Other characters keep independent histories.

## Compatibility review and outstanding questions

The specification follows CORE-012's required opening and optional tutorial, NPC-023's opportunity lifetime, and DATA-012's stable identity and save compatibility. The exact built-in popup sequence, exterior tutorial adaptation, legacy flag mappings and runtime/save interfaces remain open.
