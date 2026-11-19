# DATA-016 — Dynamic message and quest macros

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Fill supported authored messages with explicit world/quest values while preserving structured presentation, stable referents and authoritative gameplay boundaries.

## Intended player experience

Messages describe the intended person, place, item or situation consistently. Refreshing language does not invent a new person, reveal information again or consume gameplay randomness. Missing essential substitutions use meaningful fallback/recovery rather than misleading instructions. Authors can discover supported macros and diagnose missing context.

## Confirmed requirements

DATA-016-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish explicit scoped context; side-effect-free expansion with separately committed reveals; message-lifetime retained values and owned generation; missing/unknown substitution failure; safe multiple multiline/literal insertion and bounded explicit nesting; and documented registered macro contracts with validation diagnostics.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Utility/IMacroContextProvider.cs` exposes a MacroDataSource for context handlers. `Utility/MacroHelper.cs#GetValue` invokes registered handlers using supplied providers, including secondary-provider fallback. Several handlers also access global game state.
- `MacroHelper#ExpandMacros` scans text tokens, caches generic macro results once per call and handles multiline expansion. Its source comment notes multiline handling only retains the last expansion and requires a standalone token. Its per-call cache is not a guarantee of stable values across later rerenders.
- Name-related helpers assign `DFRandom.Seed`, including random name-bank and ruler-name paths. These assignments are shared-state coupling; complete downstream random effects require runtime/call-order verification.
- `Utility/QuestMacroHelper.cs#ExpandQuestMessage` resolves context/resource macros and optionally reveals person/location/thing dialogue links through TalkManager when expanding a true-name macro. `ExpandQuestString` is another narrower expansion path. This mixes presentation and information reveal in the reference implementation.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Full macro inventory, missing-context behavior and representative quest/localization fixtures were not tested. Source remains unchanged.

## Detailed rules and behaviors

### Context and authority

Expand from explicitly supplied scoped message/quest context, not whichever NPC, location or quest happens to be globally current. Preserve stable domain references and originating session/quest context where needed. Missing required context is failure rather than unrelated substitute data. A current singleton or last-clicked NPC alone is not proof of the intended referent.

Expansion is side-effect-free. It reads supported values or prepares presentation from supplied context without changing quests, granting rewards, committing choices or revealing dialogue resources. Where presenting a message should reveal a person/place/item link, QUEST/NPC performs a separate explicit owner operation. Its ordering, successful-presentation boundary and duplicate protection must be defined by those owners; this feature does not remove intended reveals, but moves authority out of rendering.

Previewing, validating, translating and rerendering must not reveal information or repeat gameplay effects. CORE lifecycle scope rules prevent ended-session context from being silently replaced with a new character's context. Owners decide appropriate failure/recovery for expired messages.

### Retained referents and generated values

Resolve repeated references consistently within a message and retain chosen/generated values for its lifetime. Language refresh may localize their presentation but must not generate a new person/place/item, reroll message values or consume gameplay randomness. Definition/template lifetime is distinct from one message instance's resolved context.

Any required generation uses an explicitly owned random source or deterministic identity rule. Do not reseed shared randomness during expansion. Separate owner preparation/generation from pure substitution so rendering can reuse retained values without side effects. This does not choose an RNG algorithm, classic parity target or global random-stream architecture.

Exact message lifetime, snapshot versus live-update behavior for changing non-generated values, and persistence of retained context remain owner contracts. No implicit rule freezes every world property forever or allows unrelated global state to replace a retained referent.

### Missing values and fallback

Unknown macros and missing required values make the candidate message unusable. Follow DATA-013/015 selected/base/source fallback and essential-prompt recovery. Do not silently leave raw macro codes or insert empty strings into required instructions. An alternate-language candidate using the same missing required context may also fail; translation fallback cannot invent that data.

Optional values may use only declared defaults or supported suppression. DATA-013 prohibits suppression of essential controls. Distinguish unknown symbol, absent context, missing referenced entity and unsupported output/format in diagnostics where applicable. An ordinary missing-text placeholder cannot certify an essential interaction usable.

Static validation checks symbol/context contracts available in the template. Runtime expansion validates actual supplied values and availability. Do not promise all future quest/world context can be established at startup; required static definition/reference validation still follows DATA-002/003/012 before usable publication.

### Literal, multiline and nested expansion

Support multiple declared multiline substitutions, preserving DATA-015 token boundaries, reading order and required interaction structure. Output type is explicit: ordinary text is not interchangeable with trusted structured token output. Validate supported structured outputs before presentation.

Treat ordinary inserted values as literal text. Percent signs, macro-like strings and markup in names/values must not become another instruction. Escape or represent them appropriately without altering their intended displayed content. No arbitrary executable command is introduced through translation or substituted data.

Nested expansion requires explicit supported syntax and bounded evaluation. Do not automatically recursively interpret every replacement string. Exact supported nesting grammar, cycle/depth/output limits and handler ordering remain technical contracts; nontermination or unsupported nesting is failure rather than a successful truncated required message.

### Macro registry and custom support

Document each supported symbol's meaning, required context, output type and optional fallback. Validate templates/translations against that registry with message/key, symbol and missing-requirement diagnostics. Translation can reorder supported placeholders without changing their gameplay referents or inventing executable behavior.

Custom macros require registered support and the same side-effect-free expansion contract. MOD/domain owners define provider registration, identity, conflicts and executable lifecycle; template declarations alone cannot execute unregistered code. DATA-003 precedence and contribution rejection apply to authored content, not an implicitly approved arbitrary handler override mechanism.

## Relevant formulas and parameters

No gameplay formulas, RNG algorithm, fixed macro count or numeric recursion limit is approved here. Bounded nested evaluation and consistent retained message values are required outcomes; concrete limits and deterministic-name rules need owner validation. Existing classic macro spelling and suffix behavior are adapter evidence, not proof every legacy case is supported.

## Required data

Stable message/template identity; registered symbol schema and source mapping; typed/scoped context references; actual supplied values; retained generated/selected values; output type/format metadata; declared optional default/suppression; explicit nesting metadata if supported; source/package provenance and failure context. Separate owner data records intended reveals/choice commitment rather than hiding them in token expansion.

## Inputs, outputs and events

Inputs: validated structured template, locale, supplied message/quest context, registry/provider capabilities and prepared retained values. Outputs: usable expanded text/tokens or explicit unknown/missing/unsupported/invalid failure for fallback. These are conceptual contracts, not concrete APIs/signals. Expansion success is not information-revealed, choice-accepted, quest-started or reward-granted; owners commit those outcomes separately.

## Cross-system interactions

- DATA-003/012 govern applicable template contributions, quest-source validation and content lock. DATA-013/014 govern localized placeholder validity and fallback; DATA-015 preserves structural controls and variant selection.
- QUEST/NPC own resource binding, dialogue-link reveal and correct originating context. FACT/ITEM/MAGIC/WORLD and other owners supply authoritative query values without rendering-driven mutations.
- RULE/name-generation owners define any scoped deterministic/random preparation; DATA-017 will review name-bank selection. This feature does not approve their exact generation algorithms.
- UI renders/refreshes messages and retains pending interaction identity without calling gameplay commits again. CORE-005/012/019 preserve lifecycle, ordered presentation and restrictions independently of text availability.
- MOD owns executable providers; SAVE/requesting owners define retained active message and historical context persistence.

## Edge cases and failure conditions

- The same name macro appears repeatedly: use consistent retained referent/value rather than independent random draws.
- Locale refresh follows initial display: localize presentation without rerolling identities, re-revealing links or granting effects.
- Quest ends or source session is replaced: fail stale required context or use an explicitly supported owner snapshot, never a new unrelated global quest/NPC.
- Required value is unavailable in all language candidates: invoke owner recovery; do not produce successful empty essential instructions.
- Inserted name contains percent/markup: display literally, without executing nested macros.
- Several multiline placeholders occur: expand each supported output with coherent structure, not only the last one.
- Nested expansion is cyclic or exceeds declared limits: explicit invalid/unusable result; no unbounded recursion or silent removal of essential content.
- A macro previously revealed a dialogue link in DFU: preserve intended gameplay through a separate owner operation, not accidental render side effects. Exact commit semantics remain a QUEST/NPC dependency.

## Configuration and balancing options

Validated custom templates/macros use supported registry contracts. No ignore-missing-required-value mode, arbitrary recursive evaluation or rendering-driven RNG reseed is approved. Optional defaults/suppression must be declared; supported runtime settings do not unlock installed template/provider configuration.

## Save/load considerations

SAVE/UI/QUEST and requesting owners must define which active message contexts, retained generated values and pending reveals/choices persist in supported saves. Loading/reconstructing presentation must not reroll or recommit gameplay effects. Definitions and registry entries remain reusable content; mutable message-instance context is separate. Historical text snapshot/live-localization policy remains DATA-013/owner scope; no universal message save schema is selected here.

## Technical constraints

Target engine: Godot 4.7.2. Separate context preparation, pure expansion, rendering and gameplay commits. Keep templates/shared definitions immutable to consumers, preserve explicit scoped identity and validate typed outputs. Concrete registry/provider API, schema, escaping, evaluation limits, cache and persistence representation remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Expansion uses explicit originating context and fails missing required values instead of reading unrelated global actors/locations.
2. Reads/preview/validation/translation/rerender are side-effect-free. Intended dialogue reveals use separately committed QUEST/NPC operations.
3. Repeated references remain consistent over message lifetime; locale refresh does not reroll identities, consume gameplay randomness or reseed shared RNG.
4. Unknown/missing required macros make messages unusable under DATA-013/015 fallback; optional defaults/suppression are explicit and essential controls stay protected.
5. Multiple supported multiline substitutions preserve structured output. Ordinary inserted values remain literal even when containing macro/markup syntax.
6. Nested expansion is explicit and bounded; invalid/cyclic cases produce truthful failure rather than nontermination or silent essential-content loss.
7. A documented registry supports author/translation validation with message/symbol/requirement diagnostics. Custom macros require registered compatible support.
8. Context refresh/save reconstruction never commits choices/reveals/rewards implicitly. Read-only source and content lock rules remain intact.
9. Representative missing/stale-context, repeated/generated-value, language refresh, literal injection, multiline and nested-limit fixtures verify contracts before implementation is complete.

These are future verification criteria. No implementation, macro/quest fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–015 and approved CORE lifecycle/presentation/restriction contracts. No contradiction identified. Pure expansion strengthens DATA-012 validation and DATA-013/015 side-effect-free refresh. Retained generated values complement owner-selected variants without approving a specific RNG system. Separate reveal commits preserve potential QUEST/NPC gameplay while removing accidental rendering authority. Required fallback still cannot invent absent world context or bypass restrictions.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: full macro inventory/classic syntax mapping; typed context/output schemas; message lifetime and live/snapshot field policy; locale grammar/pronouns; optional defaults; bounded nesting/escaping; provider registration/conflicts; name/RNG preparation; QUEST/NPC reveal commit and idempotence; SAVE/history policy and representative fixtures. These deferrals do not waive pure expansion, retained referents or explicit missing-context failure.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-016-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including context/provider schemas, macro grammar, randomness, reveal commits and save policies. Approval does not initiate implementation, coding tasks or another feature review.
