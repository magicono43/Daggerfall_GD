# CHAR-003 — Preset class and questionnaire

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Let players choose a preset career directly or receive a roleplaying-questionnaire suggestion, with informed confirmation before proceeding. Class selection supplies later creation and startup systems with a coherent career identity and definition.

## Intended player experience

Choose a familiar preset, discover one through ten questions, or enter custom-class creation. Understand the selected class's mechanical consequences before accepting. Revise questionnaire answers without getting a different question set merely by navigating.

## Confirmed requirements

CHAR-003-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm retained routes/roster, classic questionnaire scoring/mapping, explicit class confirmation, mechanical disclosure, answer revision and explicit route-level failure recovery.

Inherited CHAR-001 requirements preserve draft isolation, navigation outcomes and summary restrictions: changing class from the final summary requires Restart. DATA-008 requires stable identities, validated definitions and separation of content reads from live effects. CORE-007/011/012 govern completed input validation and startup; class browsing cannot grant resources.

## Existing Daggerfall Unity behavior — reference only

Source paths below are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/CreateCharChooseClassGen.cs` offers direct choice or questionnaire.
- `Game/UserInterfaceWindows/CreateCharClassSelect.cs`, `Setup` and confirmation handlers, load CLASS*.CFG careers, append Custom and show description tokens beginning at 2100 plus a list index. Yes accepts; No returns to selection. The inspected loop processes `files.Length - 1` entries without explicit sorting. Filesystem enumeration/list position is not a reliable durable identity or approved roster rule.
- `Game/UserInterfaceWindows/CreateCharClassQuestions.cs`, `GetQuestions`, selects ten distinct indices from forty text entries. Random draws colliding with an existing selection advance to the next free index. This is source behavior, not approval of that sampling bias.
- `answerTable` maps each of three answers to Warrior, Rogue or Mage. `AnswerAndPlayAnim` increments one counter. `GetHeaderIndex`/`GetClassIndex` resolve totals through CLASSES.DAT. EndQuestions shows a Yes/No class description; rejection returns noClassIndex. The inspected screen advances answers without implementing answer-history revision.
- `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs`, questionnaire/list close handlers, loads the chosen career and continues to biography, opens the list on rejected suggestion, or routes Custom to its builder.
- `Game/Entities/EntityEnums.cs`, ClassCareers, enumerates the eighteen classic preset identities; `API/ClassFile.cs` decodes career fields into `API/DFCareer.cs`.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Original questions, class values, result-table completeness and runtime presentation have not been exhaustively verified. Source remains unchanged.

## Detailed rules and behaviors

### Routes and roster

Retain direct preset selection, the questionnaire and a Custom entry leading to CHAR-004/005. Initial presets: Mage, Spellsword, Battlemage, Sorcerer, Healer, Nightblade, Bard, Burglar, Rogue, Acrobat, Thief, Assassin, Monk, Archer, Ranger, Barbarian, Warrior and Knight.

Resolve selection by stable class identity, not translated name, directory order or visible row. Validated added/replaced definitions follow DATA-008/003; this feature does not freeze importer extensibility or approve new class balance implicitly. Exact class parameters remain owner-reviewed definitions.

Selecting Custom transfers control to the custom-class features; it is not a missing/null preset silently accepted as a valid finished career. Custom legality, trait costs and biography affinity remain CHAR-004/005/006 responsibilities.

### Questionnaire

Use ten distinct questions from the classic forty-question library. Each answer adds one point to its declared Warrior, Rogue or Mage category. Resolve the completed totals with the classic result mapping. Do not replace this with nearest-class matching, arbitrary tie-breaking or a different recommendation algorithm.

Allow Back/Next and answer revision within the questionnaire. Preserve the selected ten questions and their order for navigation/revision in the current draft. Retain recorded answers; revisiting alone does not generate new questions. Recalculate totals from current answers rather than adding a replacement answer on top of its predecessor. Partial answers cannot yield an accepted final recommendation. Restart/exit clear questionnaire state under CHAR-001.

The exact unbiased/bias-preserving sampling algorithm, random stream and any deliberate fresh-question-set control remain technical/design dependencies; no such control is approved here. The retained ten-of-forty rule does not by itself authorize changing the selected set on navigation.

### Review and confirmation

Both a direct selection and a questionnaire suggestion require Yes/No confirmation. Before confirmation show the original description and the actual definition's primary/major/minor skills, equipment restrictions, special advantages/disadvantages, hit points per level and advancement multiplier. Displayed values must describe the same resolved definition that will be accepted. Exact numerical balance and trait-resolution semantics remain domain-owned.

Yes accepts the class into the isolated draft and continues the creation flow toward biography. No on a direct selection leaves the player choosing from the list. No on a questionnaire result opens the class list, including Custom. Do not commit the suggestion merely because the questionnaire finished. Detailed list sorting, visual layout and animation pacing remain UI choices.

### Failure handling

If required question content or result mapping is missing/invalid, report the problem and offer an explicit return to direct selection. Do not silently pick a substitute class or treat malformed data as an ordinary rejected suggestion. A resolved result that references an unavailable class cannot be accepted as valid.

Invalid preset definitions remain unavailable until resolved. This does not authorize silent partial imports: DATA-003's whole-contribution rejection and explicit recovery remain binding. The alternate direct route is usable only with a valid resolved content configuration. Missing required career data still blocks acceptance/entry; choosing the alternate route cannot bypass required validation.

Definition reads, previews, score updates and confirmation do not mutate a live character or apply starting spells, items, biography rewards or advancement changes. Owners apply those during approved initialization.

## Relevant formulas and parameters

- Default library: 40 classic questions; selected set: 10 distinct questions; each question has three classic answers.
- Each answered question contributes exactly 1 point to Warrior, Rogue or Mage. With n current answers, W + R + M = n; at completion the sum is 10.
- Completed totals resolve through the validated classic table, including its declared mappings for equal totals. No invented tie/no-match fallback.
- Hit points per level, advancement multipliers, skill tiers and restrictions are read from the selected definition. This feature selects no replacement balance values.

DATA-008 permits validated extended content; complete schemas and mapping rules for nonclassic questionnaire sizes remain future owner contracts rather than an assumed extension of the classic result table.

## Required data

Stable preset/classic mappings, validated career definitions, original descriptions and localized mechanical labels; question/answer identities and text; per-answer category mapping; validated result table; current ordered question set, answers, derived totals and candidate/accepted class identity. Keep localized labels distinct from durable identifiers and reusable definitions distinct from draft state.

## Inputs, outputs and events

Inputs: route choice, preset choice, Custom, answers/revisions, navigation, confirmation/rejection and content/validation outcomes. Outputs: isolated candidate, accurate review information, accepted career identity/definition, custom-builder transition or actionable route failure. API/signal names remain implementation choices; accepting a class is not new-character-entry success.

## Cross-system interactions

CHAR-001 owns flow/restart/discard/submission. CHAR-004/005 own custom creation; CHAR-006 and DATA-008 own biography-selection inputs/contracts. DATA-003/008 validate and resolve definitions/identity. UI presents questions, answers, review and errors. CHAR progression, COMBAT, MAGIC and ITEM own the consequences of skills/traits/restrictions; CORE-012 applies starting grants under their rules. CORE-007/011 validate completed entry inputs. SAVE owns durable completed-character compatibility.

## Edge cases and failure conditions

- Revision replaces one answer's contribution, including after revisiting a completed result; no duplicate points or new question draw from navigation.
- Empty/malformed question sets, missing answer-category mapping or unsupported result data produce explicit failure, never an invented recommendation.
- Declining a suggestion enters the class list without applying the declined career's effects.
- Reordering or translation cannot change the chosen identity, class description or biography mapping.
- Repeated input/animation callbacks cannot record an answer twice or accept multiple careers.
- If a required definition is unavailable, show truthful failure/unavailability rather than substitute a class with a similar name.
- Custom and preset state must remain distinguishable; cached custom traits cannot leak into an accepted preset or a fresh draft.

## Configuration and balancing options

Retain the classic initial roster, ten-of-forty questionnaire and result mapping. Validated content overrides follow DATA contracts; they do not authorize arbitrary rule changes. No new reroll button, alternate scoring mode or player-facing difficulty toggle is selected here. Question animations/sounds are presentation; exact fallback/readiness behavior remains UI/AV integration scope and must not misrecord answers or bypass validation.

## Save/load considerations

Do not persist unfinished questionnaires for later resumption under CHAR-001. Preserve current draft questions/answers through in-session navigation. Completed gameplay saves preserve the resulting career and relevant state through SAVE; loading does not rerun questionnaire selection or starting grants. Exact durable definition/version representation remains SAVE/DATA scope.

## Technical constraints

Target: Godot 4.7.2. Separate content decoding, question selection, score evaluation, draft state and presentation. Derive totals from authoritative answers and resolve stable IDs explicitly. Avoid reliance on filesystem order, translated text parsing or animation callbacks as the sole authority for game decisions. Original source/content remain read-only. Concrete schemas, widgets and APIs remain engineering choices.

## Acceptance criteria

1. All eighteen initial presets, questionnaire and Custom routes are available with valid supporting content.
2. Questionnaire selects ten distinct classic questions; answers contribute one category point each and completed totals resolve through the validated classic mapping.
3. Back/Next/revision preserves the question set/order and replaces prior contributions; revisiting alone never rerolls.
4. Both selection routes show original description and all approved mechanical fields from the actual candidate before Yes/No confirmation.
5. Yes accepts only a valid career; direct No returns to list selection and questionnaire No opens the list including Custom.
6. Missing/invalid questionnaire inputs produce a reported error and explicit direct-route choice, with no silent substitute and no bypass of DATA validation.
7. Invalid presets cannot be accepted. Stable identity survives display reordering/localization; description and biography references remain correctly associated.
8. Draft navigation and repeated callbacks cannot grant resources, multiply scores or leak custom/preset state.
9. Summary class changes require Restart; restart/exit clear draft questionnaire state without discard prompts, consistent with CHAR-001.
10. Loading completed characters does not rerun class selection or new-character grants.

These are future verification criteria; no implementation or runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001/002, DATA-003/008 and relevant CORE-007/011/012 constraints. No direct contradiction identified. Answer revision deliberately adds behavior beyond the inspected DFU screen while preserving CHAR-001 navigation retention. Explicit direct-route recovery does not permit silent contribution skipping. Stable identity replaces incidental list-index coupling without changing approved classic class mapping. Custom-class construction and biography affinity are not approved by implication.

## Outstanding questions and approval

No further blocking player-policy question is identified for preset selection and the classic questionnaire. Before implementation is complete: verify original question/category/result fixtures and all eighteen class mappings; validate complete definition schemas and truthful review fields; establish sampler/random-stream details; complete UI/media failure and navigation integration; define nonclassic questionnaire/result schemas if extended; define SAVE compatibility. Exact class balance, custom legality and biography affinity remain owner specifications.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-003-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented content-fixture, sampler, UI/media and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
