# QUEST-005 — Script grammar and resources

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-005-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-005-interview-decisions).

## Gameplay purpose and intended experience

Turn authored quests into usable definitions before they enter play. Players should receive quests whose declarations and required references have been checked. Authors should be able to diagnose script errors and easily exercise a specific modded quest in the actual game world.

## Confirmed requirements

- Support DFU quest text as an import format and a versioned native format for new quests. Both feed the same validated quest definition.
- Reject malformed declarations, conflicting duplicate IDs, missing required references and references of the wrong type. Optional behavior must be explicit. Report independent errors together where practical, with source locations.
- Validate declarations and fixed references up front. Resolve world-dependent choices during generation. Allow metadata inspection without randomness or a claim of playability.
- Make specific modded quests easy to debug and test in the actual environment. The choice of external tooling, in-game workflow or a combination remains open.

See QUEST-005-D01–D04 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-005-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/Parser.cs#Parse` reads the quest header, checks for the QRC message and QBN runtime sections, and on a full parse builds messages, resources and tasks. `ParseQBN` handles clocks, items, persons, foes, places and task forms. Partial parsing skips the contents of QRC and QBN. `QuestMachine.cs#ParseQuest` reseeds Unity randomness before parsing and logs exceptions before returning null. `Task.cs#ReadTaskLines` can log and skip unrecognized executable lines. These findings come from static inspection.

## Detailed rules and behaviors

1. Resolve source, provenance and the content plan under DATA-012. Import supported DFU syntax and parse versioned native syntax into the same definition model. Preserve declaration and executable order where the supported grammar gives order meaning. Unsupported legacy constructs get explicit diagnostics. A partial import cannot publish as a usable definition.
2. The definition contains stable quest identity, authored messages and message references, resource declarations, tasks and action references. Validate syntax, IDs and types in their declared scopes. Validate required fixed references against the resolved content plan, including forward references permitted by the grammar. Executable constructs require supported commands under QUEST-006. Keep optional behavior explicit and validate any fallback the definition depends on.
3. Distinguish blocking errors from advisory warnings. Malformed declarations, conflicting IDs, unsupported executable commands, and missing or mistyped required references block publication. Advisory issues such as an unused resource can produce warnings. Report independent issues where practical without flooding authors with consequences of the same underlying error. Include quest ID where available, pack, source, line where applicable, and the reason.
4. Metadata inspection can expose identity and display metadata for tooling or UI. It consumes no gameplay randomness and confers no usability status. Full validation is side-effect-free. It cannot instantiate live resources, mark acceptance, start a quest, or grant rewards.
5. Generation instantiates a validated definition using current context. A valid place selector whose current candidate set is empty returns a generation failure with its resource and selector context. An invalid selector or missing fixed definition fails validation. Runtime failures are classified for the applicable owner policy, including bounded fallback under QUEST-003 where eligible.

## Author testing and diagnostics

DEV and MOD own a workflow to identify a quest by stable ID and exercise it in an actual game world without waiting for a random offer. Authors can see validation diagnostics and distinguish invalid source, missing current-world prerequisites and runtime failure. The workflow uses the normal quest definition, generation and runtime paths. How authors choose or prepare a test context, enter through an offer or direct start, and inspect running tasks remains for the tooling and runtime reviews. Test actions that mutate gameplay use an explicit test session or equivalent isolation so ordinary character history stays intact.

## Required data, inputs, outputs and events

Inputs include resolved source, format and version, stable IDs, provenance and source spans, supported command declarations and domain reference indexes. Generation additionally needs authorized player/world context and its scoped randomness. Outputs include inspected metadata, a validated reusable definition or diagnostics, and a generated instance or classified runtime failure. Validation and generation do not emit a committed start event. QUEST-004 and QUEST-008 own activation.

## Cross-system interactions

DATA-003/012 own source resolution and publication recovery. QUEST-006 owns command registration and grammar extension. QUEST-007 owns localization and message expansion. QUEST-012 through QUEST-017 own runtime resource selection and binding. RULE-003 supplies generation randomness. MOD and DEV own the author-facing test workflow, with QUEST supplying diagnostics and supported entry points. SAVE and QUEST-022 own active quest compatibility and restoration.

## Edge cases and failure conditions

- A title can be inspected while the body is malformed. The title is visible to inspection tooling and the quest remains unavailable for play.
- A task referencing an item where a person is required fails validation. A valid person selector with no qualifying actor in the current world reports a generation failure.
- An unsupported executable command remains a blocking error even if other lines are valid. Comments and explicitly supported optional constructs remain usable.
- Changing a resolved script or command dependency requires the approved content resolution and validation flow. Test diagnostics identify the resolved version used for the run.

## Configuration and balancing

The native format has an explicit version. Supported DFU constructs, native serialization and command extension contracts remain integration decisions. Authors configure quest resources and rules through supported declarations. This feature adds no gameplay balance formulas.

## Save/load considerations

Validated definitions are reusable content. Instance state, resolved bindings, task progress and one-time history are owned by QUEST and SAVE. A changed definition requires explicit compatibility or recovery under DATA-012. Restoring an existing quest cannot reroll its bindings or replay committed effects. Test runs follow their test context's persistence rules.

## Technical constraints

Target Godot 4.7.2. Keep inspection, validation, generation and activation separate. Preserve diagnostic provenance through import and native parsing. Tooling uses the shared validation and runtime contracts. The local DFU source is a read-only reference.

## Acceptance criteria

1. Representative supported DFU and native scripts produce equivalent validated definitions where they express the same behavior.
2. Malformed declarations, conflicting IDs, unsupported commands and missing or mistyped required references block publication with actionable source diagnostics. An unused declaration can produce an advisory warning.
3. Inspecting metadata and validating scripts consume no gameplay randomness and commit no gameplay effects.
4. An invalid selector fails validation. A valid selector with no current match reports a classified generation failure. A successful instance enters normal activation through its owner.
5. In an actual game environment, an author can select and exercise a specific modded quest through the supported workflow without relying on random selection, and can identify whether a failure occurred in validation, generation or execution. The test session or equivalent isolation preserves ordinary character history.

## Compatibility review and outstanding questions

The specification follows DATA-012 validation and recovery, QUEST-003's pre-settlement failure policy, QUEST-004 activation and RULE-003 randomness. Native serialization, supported legacy syntax coverage, exact ID and diagnostic schemas, and the author test interface and scope remain open.
