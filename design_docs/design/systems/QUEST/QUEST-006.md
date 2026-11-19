# QUEST-006 — Action grammar registration

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-006-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-006-interview-decisions).

## Gameplay purpose and intended player experience

Give quest authors predictable commands and let mods add new behavior through validated extensions. Item objectives can ask for an exact item or accept a range of valid items. A player might bring several kinds of flowers to fulfill one request, or fail a quest under its authored rules when suitable items cannot be obtained.

## Confirmed requirements

- Mods can add package-qualified commands. The initial contract supports additions. Native scripts address commands explicitly, and DFU import reports unresolved legacy ambiguity with its matching candidates.
- Commands declare typed arguments, resource references and their role as a condition or an operation. Validation runs without gameplay effects. Runtime changes use the relevant gameplay owner's rules. Quest testing exposes the resolved command and provider.
- Saved commands use stable identity and explicit compatibility versions. Resume with a compatible provider or a supported migration. Otherwise use SAVE recovery with diagnostics naming the quest and command.
- Support objectives for exact items and quantities and for generic item categories and quantities. Authors can offer more than one valid solution and can define failure when qualifying items cannot be obtained in that quest instance.

See QUEST-006-D01–D04 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-006-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/QuestMachine.cs#RegisterAction` appends templates and `GetActionTemplate` returns the first successful pattern match. `Task.cs#ReadTaskLines` creates quest-specific actions through `CreateNew`, tracks trigger conditions, and logs and skips unmatched lines. `QuestAction.cs#GetActionSaveData` stores the implementation type alongside action state. These observations come from static inspection.

## Detailed rules and behaviors

1. Resolve command providers against the approved content plan before validating dependent quests. Register one provider per stable command ID in the initial contract. Reject duplicate IDs with provider diagnostics and apply DATA/MOD recovery. The registration order carries no authority to replace a command.
2. Native definitions resolve commands by explicit ID. DFU import resolves supported legacy forms to the same command declarations. Reject unknown and unresolved ambiguous executable lines with source context and applicable candidates. Document any intentional legacy disambiguation as part of the import grammar.
3. A command declaration identifies the provider, compatibility version, condition or operation role, argument types and required references. Validate arguments and fixed references before publication. A runtime condition can read relevant context to report an outcome. An operation that changes authoritative state requests it through the appropriate owner. Runtime failures report an outcome to QUEST for the applicable recovery or authored branch.
4. Provide built-in quest conditions for checking a required quantity of matching items. Use an exact selector by stable item definition ID or a generic selector by validated item category or tag. The quantity is a positive whole number of qualifying units. A generic objective can combine qualifying units of different item definitions, so two roses and one lily can satisfy a request for three flowers if both match the selector. An exact request for three roses requires three qualifying roses.
5. Let the quest use the condition in authored success or failure paths. A currently unmet quantity leaves the condition unsatisfied. An authored rule, such as expiry or a supported generation check that establishes the requirement cannot be met in this instance, can lead to explicit failure. The check itself has no transfer or consumption effects. Where delivery requires taking items, use a separate owner-authorized hand-in operation that revalidates the match and quantity before commitment. Exact allocation, custody, and quantity reservation rules remain with ITEM and quest hand-in review.
6. During the approved QUEST-005 test workflow, show which command ID, version and provider each line resolves to and expose relevant validation or execution diagnostics. The test path uses the same registration, validation and runtime contracts as regular play.

## Required data, inputs, outputs and events

Inputs include the resolved provider plan, command ID and version, role, typed arguments, source span, definition and instance context, and required owner references. Item checks also need the item selector, target quantity, and the eligible inventory or custody scope supplied by the objective and ITEM owner. Outputs include a validated command binding or diagnostic, a condition result, or a runtime operation outcome. Inventory changes and delivery events are committed by the responsible owners.

## Cross-system interactions

QUEST-005 and DATA-012 own quest compilation, source provenance and validation publication. MOD owns provider trust and lifecycle. DEV owns author tooling with QUEST diagnostics. CORE-020 supplies authoritative change and notification rules. ITEM owns item definitions, category or tag semantics, custody and hand-in contracts. QUEST owns objective evaluation and authored outcomes. QUEST-022 and SAVE coordinate restoration and compatibility.

## Edge cases and failure conditions

- A command ID collision or ambiguous legacy line fails validation with the relevant candidates. A package reorder cannot select a different handler implicitly.
- An invalid exact item ID or unknown category fails fixed-reference validation. A valid category with no currently qualifying items is a gameplay or generation outcome under the quest's authored rules.
- Count each qualifying unit once in an objective check. Repeated queries cannot consume items. If custody changes before delivery, revalidate using the authoritative ITEM state.
- Missing or incompatible providers, unrecognized state versions and failed migrations use SAVE recovery before the affected quest resumes. A successful load does not repeat a committed action.

## Configuration and balancing

Authors configure exact or generic item selectors, quantities, alternative success paths and failure conditions through validated declarations. Category breadth affects how many items qualify. Availability and rewards remain authored decisions. Command IDs and versions identify supported contracts, while MOD defines how providers declare compatibility.

## Save/load considerations

Persist stable command identity and the versions needed to interpret saved arguments and action state. Keep an action's runtime instance identity distinct from its command ID. Restore through a compatible provider or explicit migration. Persist committed delivery and objective progress under QUEST and ITEM rules, including a terminal result when one was committed. Class and file names are implementation details.

## Technical constraints

Target Godot 4.7.2. Separate command declaration, side-effect-free validation and runtime execution. Route authoritative changes through owner contracts. Preserve source attribution and stable resolution across import, tooling and restore.

## Acceptance criteria

1. A mod can add a package-qualified command with typed arguments and a declared role. Duplicate IDs and unresolved ambiguous legacy forms fail with actionable diagnostics.
2. Validation checks fixed references without committing gameplay effects. Test diagnostics identify the resolved command and provider.
3. Saved commands resume through compatible providers or explicit migration. Missing or incompatible commands produce a quest-specific recovery outcome before execution resumes.
4. An exact objective requiring three roses accepts three qualifying roses. A category objective requiring three flowers can accept two roses and one lily when both qualify. Two total flowers leave the condition unsatisfied.
5. A valid item requirement with unavailable matches can reach explicit authored failure. The inventory check does not itself fail the quest or remove items. Delivery revalidates and commits through its owner.

## Compatibility review and outstanding questions

The specification follows QUEST-005's shared definition and test paths, DATA-012's validation and compatibility rules, and ITEM-023's custody and hand-in ownership. Exact item taxonomy, eligible custody, allocation across objectives, failure timing, command extension API and save schema remain open.
