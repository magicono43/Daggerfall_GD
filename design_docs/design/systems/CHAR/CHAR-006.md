# CHAR-006 — Biography selection and outcomes

**AE/AF baseline clarification, 2026-11-26:** During IMP-015 increment 3,
the user instructed, “Go by what DFU says in this case, please.” This adopts
the pinned DFU dispatcher's no-effect treatment of AE/AF. Retain the original
codes, selectors, ordered operands, answer identities and source provenance as
explicit non-executing metadata. Their presence does not reject an otherwise
supported biography. This is an intentional baseline choice, not verified
original-executable semantics or implementation of an ally/enemy mechanic.
Other unsupported required commands still fail. Original sources remain
read-only. Earlier AE/AF owner-review requirements below are satisfied only
for this treatment.

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Turn background answers into a coherent personal history and starting effects, supporting deliberate roleplaying choices and an automatic alternative without duplicate grants or navigation-based rerolls.

## Intended player experience

Answer questions or let the game choose answers, understand known consequences, review the resulting history and revise choices. Intentionally random rewards remain surprises, while navigating or switching answers cannot repeatedly roll them. Read the established backstory later in play.

## Confirmed requirements

CHAR-006-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish manual/automatic routes, retained random template selection, equal-weight custom skill affinity, answer revision, known-effect disclosure, automatic-result review/editing, classic/mod content baseline, retained first-selection random outcomes and persistent readable history.

Inherited DATA-008 rules require validated stable definitions/choice IDs, isolated preview evaluation and failure on unsupported required effects. CORE-012 applies biography effects before starting grants and captures progression baseline after initial skill changes. CHAR-001 owns draft discard/navigation and requires Restart to change biography from final summary. CHAR-004/005 custom class identity and reputation remain separate inputs.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs`, `CreateCharChooseBioWindow_OnClose`: discovers matching BIOG files and randomly selects a template, then either asks questions or randomly selects one answer per question. Both routes generate effects/backstory; reputation information is shown. Empty matches are not safely handled by the inspected branch.
- `Game/UserInterfaceWindows/CreateCharChooseBio.cs` exposes manual and automatic routes. `CreateCharBiography.cs`, answer handlers, sequentially accumulate answer effects, generate backstory and digest reputation at completion; the inspected handlers do not implement answer-history revision.
- `API/BiogFile.cs` parses twelve classic questions and optional backstory references. `AddEffect` tags narrative commands with question context. `GenerateBackstory` expands narrative tokens and writes the draft race into the live player's BirthRaceTemplate for macro expansion. Intended draft isolation explicitly excludes that live mutation.
- `GetClassAffinityIndex` counts each custom selected skill once if present anywhere in a preset's twelve selected skills, without tier weighting. Strict greater-than comparison keeps the earliest highest result; initial index zero is not an approved no-match fallback.
- `ApplyPlayerEffect` handles skill, gold, item, social/faction reputation, poison/disease/magic resistance, fatigue, reaction and avoidance commands. Book item creation can choose a random book. AE/AF/AO branches log unimplemented commands. Some modifiers assign fields while other effects add values; these differences require owner verification rather than universal additive stacking.
- `GetSkillEffects` supports skill preview in `CreateCharAddBonusSkills.cs`; `Game/Utility/StartGameBehaviour.cs#StartNewCharacter` later calls `ApplyEffects`.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Full biography-content values, narrative macros and runtime effects remain verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Template and custom-class mapping

For a preset class, resolve its declared biography mapping under DATA-008. Select randomly among valid eligible templates and retain the selected template while navigating the same draft. No explicit player template picker is introduced. Missing required mapping/template or invalid required content produces an actionable failure, not an unrelated biography or silent partial result.

For a custom class, compare its twelve distinct selected skills against each classic preset's twelve selected skills. Each overlap counts one regardless of primary/major/minor tier. Select the greatest overlap; ties use explicit stable classic order: Mage, Spellsword, Battlemage, Sorcerer, Healer, Nightblade, Bard, Burglar, Rogue, Acrobat, Thief, Assassin, Monk, Archer, Ranger, Barbarian, Warrior, Knight. Resolve the selected preset's biography mapping explicitly. Directory order, localized names and incidental list position cannot determine the winner.

No valid positive-overlap candidate, missing required preset data or missing selected mapping is a failure rather than automatic index-zero selection. Added-class participation in affinity ranking requires a future explicit extension contract; supported added templates/definitions do not silently alter the classic tie order.

### Manual and automatic routes

Retain supported classic questions, answers and effect values initially, with validated additions/overrides through DATA-003/008. The classic parser's twelve questions are a source baseline, not a universal fixed-size schema; supported added sets may vary under validated consumer contracts.

Manual selection records one valid answer per required question. Permit revisiting and replacing answers while retaining the template. Rebuild candidate effects and narrative from authoritative current answers, not by adding new effects to stale accumulated results.

Automatic generation chooses one valid answer per question using the same definitions and effect/narrative rules. Show the selected answers, generated backstory and known effects, and permit manual editing. Merely returning to this route does not regenerate previously chosen answers. No separate reroll button is introduced. Exact random-stream/sampling implementation remains a technical contract subject to retention rules.

### Disclosure and random outcomes

Before selecting an answer, show known mechanical effects, including applicable skill changes, gold/items, reputation and supported modifiers. Identify genuinely random rewards without disclosing their eventual exact result. Descriptions must reflect the actual owner-approved meaning; do not infer percentages, stacking or quantity from a command name alone.

On first selection of an answer within the draft, resolve and retain any randomized reward outcomes associated with it. Automatic selection follows the same rule. Switching away excludes that answer's effects from the current result but retains its resolved outcome; switching back restores it without rerolling. Retain outcomes for noncurrent answers until the draft is discarded. Intentionally hidden exact results remain hidden throughout creation, including review and the final summary.

Creating a candidate random outcome is not granting a live item. Preserve enough result data for later owner application to deliver the selected outcome rather than roll a new identity/material/quantity during entry. Concrete item allocation/UID timing remains ITEM-owned. Exact random distribution follows verified supported content and owner rules; no new distribution is approved here.

### Effect evaluation and application

Compute previews and final consequences with the same validated definitions/owner rules. Known deterministic effects must remain consistent; retained random outcomes cannot change between draft selection and startup retry. Reject malformed/unsupported required effects or missing targets before live mutation under DATA-008. Unimplemented legacy commands require explicit owner review; logging and skipping is not successful support.

Keep candidate skills, reputation, narrative context and reward descriptions separate from live player state. Macro expansion must use draft context directly, not temporarily overwrite the live player's race or other identity. Repeated narrative generation must not duplicate token/effect accumulation.

Apply selected biography effects once under CORE-012 before starting grants. Capture progression baseline after all initial skill changes. Previewed skill bonuses are not already-awarded permanent increases; handoff must distinguish candidate display values from committed base values so startup does not add them twice. Exact modifier arithmetic, gold-floor policy and reputation stacking with class adjustments remain owner contracts; preserve the supported classic baseline pending verification rather than invent replacements.

Final entry retry uses the captured completed intent and retained outcomes through CORE-007, with clean reconstruction rather than partial reward resumption. Save loading restores established state without invoking fresh biography grants.

### History and lifetime

Preserve the completed selected template, question/answer identities and generated backstory with the character. Make the backstory readable after creation; exact UI placement remains deferred. Restore established history on load without regenerating rewards or rewriting it from later-edited definitions. Save representation must retain sufficient resolved narrative data to meet this requirement; a current-definition pointer alone is insufficient.

Ordinary navigation preserves answers, template and resolved outcomes. Restart/exit discard all unfinished biography state without confirmation under CHAR-001. Changing biography from final summary requires Restart. No in-game biography respec/editor is introduced. Missing saved-history display content cannot silently rewrite identity or grant effects; exact SAVE recovery/localization behavior remains a dependency.

## Relevant formulas and parameters

Custom affinity for preset p: score(p) = count of custom selected skill IDs contained in p's selected skill set. Each of the twelve custom skills contributes at most one; choose greatest positive score and break ties by the declared classic order. No tier weighting or name matching.

One current answer per required question. Candidate effects derive only from current answers; retained outcomes for noncurrent answers are inactive. The feature approves supported classic effect values as the baseline but does not assert an unverified exhaustive quantity table. Content fixtures and mechanics-owner formulas must be established before implementation is complete.

## Required data

Stable class/template/question/answer IDs; explicit eligible-template mappings; preset skill sets/order; validated effect type/target/parameters; narrative references/macros; selected answers; current candidate result; per-answer retained random outcomes including inactive cached outcomes; generated backstory; and captured definition/outcome context for entry. Completed saves require history and applied-state data sufficient to avoid regeneration. Exact schemas remain owner dependencies.

## Inputs, outputs and events

Inputs: class/custom tiers, resolved content, route selection, answers/revisions, navigation, random inputs, narrative evaluation and owner validation. Outputs: retained template/answers/outcomes, known/hidden-result presentation, candidate effects/backstory or actionable failure, followed by validated biography intent for entry. These are conceptual contracts, not concrete API/signal names. A preview is not an effect-grant event.

## Cross-system interactions

CHAR-001 controls creation lifetime/summary restrictions; CHAR-003–005 supply class, custom skills and initial class choices. DATA-003/008 resolve validated content, stable identity and provenance. CHAR/COMBAT/MAGIC/MOVE/ITEM/ECON/FACT own corresponding effect semantics, rewards and stacking. CHAR-009 consumes skill previews; CORE-007 captures intent and safe retry; CORE-012 orders application/grants/progression baseline. UI shows questions/review/history and preserves hidden outcomes; SAVE restores history and effects without reruns.

## Edge cases and failure conditions

- No eligible template, invalid answer, unsupported required command, missing reward definition or invalid macro context cannot become a successful empty/default biography.
- Revision removes obsolete effects/narrative and does not accumulate skill or reputation bonuses.
- Repeated automatic-route entry, answer switching, summary visits and entry retries cannot reroll retained outcomes or duplicate grants.
- Random selection is limited to validated eligible templates/answers; it cannot silently select invalid content and report success.
- Custom affinity ties remain deterministic across directory/display reordering. Missing mapping is distinct from a legitimate tie.
- Backstory generation cannot mutate the live character. Repeated generation must produce a coherent history without duplicated tokens.
- Source commands may add or replace modifiers; consumers cannot assume all repeated effects stack additively. Unsupported behavior requires explicit resolution.
- Mod edits/localization cannot change durable answer identity or cause load-time reward regeneration/history replacement.

## Configuration and balancing options

Validated mods may add/override supported biography templates, questions, answers and effect values under DATA contracts. New executable effects or unsupported schemas require explicit owner support. No template picker, standalone reroll button, universal reward multiplier or alternate affinity weighting is approved. Mod content remains subject to DATA-003 configuration locking and required-effect validation.

## Save/load considerations

Unfinished drafts remain transient. Preserve completed template/answers/generated history and resulting gameplay state; do not recompute history or reapply rewards from changed current definitions. Retained random outcomes used for committed effects must remain consistent through captured entry/retry and required persistence. SAVE defines exact representation/migrations, content compatibility and history localization policy. Saved history must remain readable after normal restoration; missing compatibility requires explicit recovery rather than silent replacement.

## Technical constraints

Target: Godot 4.7.2. Separate content parsing, candidate evaluation, randomness, narrative rendering and owner-applied effects. Use explicit draft macro context and stable IDs; avoid live-player access as preview storage. Track selected versus inactive cached random results separately. Concrete random APIs, schema/versioning and history widgets remain engineering decisions. Reference source/content remain read-only.

## Acceptance criteria

1. Preset mappings select only valid eligible templates; template selection persists during navigation and has no player picker.
2. Custom classes use the twelve-skill equal-overlap rule and declared stable tie order; missing/no-positive-match/mapping failures never silently choose index zero.
3. Both routes record one valid answer per required question and use identical effect/narrative rules. Automatic results are reviewable and manually editable.
4. Answer revision rebuilds current effects/history without stale or multiplied bonuses.
5. Known effects are disclosed before selection; intentionally random exact outcomes remain hidden in creation.
6. First selection resolves random rewards once per answer/draft. Switching away/back, navigation and entry retries preserve outcomes; inactive answers grant nothing.
7. Preview/macro generation never mutates live state. Required invalid effects block success; unimplemented commands are not silently skipped.
8. Selected effects apply once before starting grants; starting skills precede progression baseline capture and previewed bonuses are not awarded twice.
9. Completed history/template/answers are preserved and the backstory is readable after creation/load without regeneration from changed definitions or duplicate rewards.
10. Restart/exit clear unfinished state under CHAR-001; final-summary biography changes require Restart. Validated mod content follows DATA contracts.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001–005, DATA-003/008 and CORE-007/011/012. No direct contradiction identified. D03 supplies the previously deferred custom-affinity rule; D05/D08 supply disclosure/random retention without requiring hidden outcomes to appear in CHAR-001's summary. Persisted completed history is distinct from forbidden unfinished-draft resumption. Clean startup retry retains intent/outcomes without granting twice. Supported content baseline does not approve unsupported legacy commands or unrelated architecture wholesale.

## Outstanding questions and approval

No further blocking biography-policy question is identified. Before implementation is complete: verify all original template/answer/effect/macro fixtures and class mappings; establish effect arithmetic/stacking/limits and reward-owner construction; specify RNG distributions/stream isolation and retained-outcome schemas; integrate skill preview/startup handoff; finalize history UI/localization and SAVE compatibility. Unsupported AE/AF/AO commands require explicit owner review where present in required content. These dependencies cannot waive hidden-outcome retention, draft isolation or truthful failures.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-006-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented effect/content/RNG, UI and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
