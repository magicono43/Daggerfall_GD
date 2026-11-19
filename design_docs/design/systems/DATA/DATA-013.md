# DATA-013 — Localized string lookup and fallback

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Resolve usable player-facing text through stable presentation keys and explicit language fallback, without changing gameplay identities, decisions or outcomes.

## Intended player experience

Incomplete translations remain usable through content-specific base-language and explicit source fallback. Missing ordinary text is visible and diagnosable without repeated blocking popups. Essential startup/recovery controls remain readable without original assets or optional language packs. Players can switch among loaded validated languages without restarting or replaying gameplay.

## Confirmed requirements

DATA-013-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish collection/domain-scoped keys and provenance; selected/base/source fallback; placeholders and independent essential labels; live settings-based switching of validated resources; blank-entry policy; and placeholder/format validation without executable translation semantics.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/TextManager.cs#GetLocalizedText` tries runtime then default internal collections, returning `<LocaleText-NotFound>` or throwing on exhausted lookup. `GetLocalizedTextWithReversion` additionally tries a nonempty caller literal after those collection attempts.
- `TextManager#TryGetLocalizedText` delegates to TextProvider. These wrappers distinguish runtime/default collections, not by themselves the complete locale fallback behavior of provider/Unity assets.
- TextManager includes domain collections and localized font registration/access. Actual locale inventories, initialization and glyph coverage require asset/runtime verification.
- `Localization/LocalizationEnums.cs` records legacy source categories, text groups and formatting-related enums. These do not establish the complete intended translation grammar.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; actual language catalogs, live-switch behavior and format/glyph coverage were not tested. Source remains unchanged. Existing default collections do not automatically define the target content-base-language policy.

## Detailed rules and behaviors

### Stable presentation identity

Use stable text keys scoped by collection/domain. Retain package/source provenance for overrides and diagnostic lookup. Translating, editing or reordering wording does not change item, faction, location, spell, quest or character-choice identity. Authoritative gameplay references use their domain IDs rather than rendered text.

Localization supplies presentation, not executable gameplay rules. Rendering or refreshing text must not cast spells, start quests, grant rewards, change eligibility or repeat committed operations. CORE-019's blocked/failed result remains authoritative regardless of text availability.

Resolve installed contributions under DATA-003's declared operations, precedence and lock, with detailed string-table patch behavior deferred to DATA-014. Switching selected language among validated resources is a presentation operation, not permission to reload packages or alter the locked mod plan.

### Fallback order

For each requested key, try selected language, then the declared base language for that content, then an explicitly supplied source/caller fallback. Skip redundant attempts when selected/base languages coincide. Mods declare their base language; do not assume English for every package. Partial translation may produce mixed-language presentation by design.

Only use entries that satisfy applicable formatting/placeholder requirements. An absent, default-blank or invalid entry advances through the chain. Any explicit source/caller fallback must itself be usable under the applicable presentation contract. Content that lacks a valid base declaration must report a validation problem under its schema rather than guessing a language.

Exact base-language ownership for cross-package overridden keys, locale identifiers and regional-language variants must be documented before implementation. No implicit system-locale, neighboring-language or cross-collection search is approved beyond this chain. Classic RSC fallback has a separate DATA-015 contract and must integrate explicitly rather than be assumed from string lookup.

### Exhausted lookup and essential controls

If ordinary text has no usable fallback, return a visible missing-text placeholder and diagnostic context identifying collection/key and relevant locale/source. Do not repeatedly interrupt the player with blocking popups for missing strings. Exact placeholder wording, deduplication and developer tooling remain technical/UI decisions.

Essential startup/recovery controls require bundled usable fallback labels independent of ARENA2 and optional language packs. They must not become blank or placeholder-only controls through missing translation. UI/CORE must identify and verify that essential set, including controls needed to recover from content/settings failures. Actual required operation failure retains its recovery route; localization failure cannot make it succeed or remove a restriction.

### Blank entries and intentional suppression

Treat blank entries as missing by default and use fallback. Optional text may be intentionally suppressed only through an explicit supported designation. Suppression is distinct from a missing/empty translation. Essential control labels cannot be suppressed this way. Exact blank/whitespace normalization and suppression representation remain schema dependencies.

### Formatting and placeholders

Validate required placeholders and supported formatting before use. Invalid selected-language entries are diagnosed and fall back; apply the same usability requirement to subsequent candidates so fallback itself cannot introduce broken required values. Do not let malformed markup execute gameplay commands or bypass a decision.

DATA-015/016 and UI own exact token/markup/context rules. Translations may change wording/order where the supported grammar permits, but must retain required value references and supported controls. Pluralization, number/date conventions, right-to-left presentation and glyph/font coverage need explicit owner contracts; this feature does not select their implementation or claim existing support.

An invalid individual translation entry can use this explicitly approved fallback policy. That does not authorize partially publishing structurally invalid patch files: DATA-003/014 contribution/schema validation still applies. Distinguish valid sparse catalogs, unusable entries and malformed contributions under their respective contracts.

### Live language switching

Allow language changes through settings without application restart using already loaded/validated resources. Refresh ordinary UI presentation without restarting quests, repeating rewards or changing pending choice identity/state. Refresh handlers must not replay action callbacks. Rendering changed text is separate from granting focus or accepting a selection.

Changes to installed language packs, loose files or mod order retain DATA-003 restart/configuration rules. A language switch does not live-load unvalidated new content. CORE-003/006 own settings persistence/application; exact initial language/default selection and effective failure behavior remain integration dependencies. Supported pending text/choice windows must retain their gameplay context; exact transient-message refresh coverage remains UI-owned.

## Relevant formulas and parameters

No gameplay formulas or balance parameters apply. Ordered fallback is selected language → declared content base language → explicit source/caller fallback → ordinary missing-text placeholder, with essential controls requiring bundled usable labels. No particular default language, locale list, font, placeholder text or message-retention count is selected here.

## Required data

Stable collection/domain/key; selected and declared base locale; validated locale resources; explicit source/caller fallback when present; package/key provenance; required placeholder/format metadata; optional-suppression designation; essential-label inventory and bundled fallbacks; lookup status and diagnostics. Exact catalog/locale schemas, base-language inheritance and font coverage remain dependencies.

## Inputs, outputs and events

Inputs: keyed lookup, selected locale, resolved catalogs, explicit fallback/context and settings language-change requests. Outputs: usable selected/base/source text, explicitly suppressed optional text, ordinary placeholder or essential fallback, with lookup/failure provenance as applicable. Presentation refresh is distinct from gameplay outcome/choice commitment. These are conceptual contracts, not concrete API or signal names.

## Cross-system interactions

- DATA-003/014 own installed contribution resolution/patch contracts. DATA-015/016 own classic text tokens/macros; DATA-019 and UI/AV cover font/glyph presentation where applicable.
- DATA-004–012 and other gameplay owners retain stable identities and authoritative rules. Localized names/messages do not become lookup or permission keys.
- CORE-003/006 own language setting persistence/effective application; CORE-004/005 and other recovery owners require independent usable error UI. CORE-019 restrictions remain independent of explanation text.
- UI/NPC/QUEST/ITEM/MAGIC and other consumers provide stable keys/context and refresh presentation without replaying effects. SAVE preserves gameplay/choice identity independently of localized strings; detailed narrative snapshot rules remain owner contracts.
- CORE-002 owns optional local logging/privacy filtering. Missing-key diagnostics should not require logging dynamic save contents or raw expanded personal text.

## Edge cases and failure conditions

- Translation missing but base text exists: use base content, allowing mixed languages.
- A mod is authored in a non-English base language: use its declared base rather than guessing English.
- Blank untranslated entry: fall back. Explicit optional suppression: intentionally hide only where supported; never blank essential controls.
- Placeholder/markup invalid: diagnose and try a usable fallback rather than showing broken formatting or dropping required values.
- All ordinary candidates fail: visible placeholder and diagnostics, without repeated blocking popups. Essential labels retain bundled usable text.
- Language changes while a choice is pending: stable answer identity and pending state remain intact; refresh does not accept/restart/reward anything.
- Catalog edit or package change during a run: language selection does not bypass the locked content plan or external-edit restart requirement.
- Missing explanation for a blocked action: keep the action blocked and use appropriate fallback; absence of text never means permission.

## Configuration and balancing options

Players can select supported loaded/validated languages through settings. No toggle for executing translation code, bypassing required placeholders or suppressing essential labels is approved. Default locale, OS-language detection, available language presentation and detailed fallback diagnostics remain owner/technical decisions.

## Save/load considerations

Language selection is an application presentation setting under CORE-003/006 rather than a gameplay identity. Character loads must not remap choices/quests/items by translated wording or replay effects to refresh text. Owner specifications decide whether authored narrative/player-entered text or historical messages are saved as text, keys or snapshots; this feature does not mandate translating every historical string. Catalog/locale validation remains independent of save restoration.

## Technical constraints

Target engine: Godot 4.7.2. Separate locale selection, key resolution, format validation, presentation refresh and gameplay authority. Keep resolved installed content under approved lock rules and original inputs read-only. Avoid treating missing-label strings as operation status or requiring optional catalogs for recovery controls. Concrete APIs, catalog format, locale matching, caches and text rendering remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Stable domain/collection keys and package provenance identify text without changing gameplay identity through wording/translation.
2. Lookup follows selected → declared base → explicit source/caller fallback; incomplete translations remain usable in mixed languages without assuming English for mods.
3. Ordinary exhausted lookup produces a visible placeholder and missing-key diagnostics without repeated blocking popups.
4. Essential startup/recovery controls retain bundled usable labels independent of original assets/optional packs; missing text cannot change operation results or restrictions.
5. Blank entries fall back by default. Only explicitly designated optional text can be suppressed; essential labels cannot.
6. Required placeholders/formatting validate before use. Invalid entries use approved fallback rather than broken markup/missing required values or gameplay commands.
7. Switching loaded/validated language resources requires no restart and refreshes ordinary UI without replaying rewards/quests or changing pending choices.
8. Installed-pack/mod-order/external-file changes retain content-lock/restart rules; language switching does not publish malformed contributions.
9. Representative partial/non-English-base/missing/blank/invalid-format and pending-choice refresh fixtures verify these rules, including independent recovery controls, before implementation is complete.

These are future verification criteria. No implementation, catalog/glyph fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–012 and approved CORE settings, recovery and restriction contracts, particularly CORE-003/004/006/019. No contradiction identified. Live language selection is an explicitly approved presentation operation among validated resources, distinct from DATA-003 package changes. Entry-level fallback does not waive whole-contribution structural validation. Stable choices/definitions and authoritative gameplay outcomes remain independent of text availability.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: catalog/locale/base-language ownership schemas; initial language and regional-locale rules; blank/suppression representation; essential-label inventory; token/placeholder/markup contracts; font/glyph and text-direction support; UI refresh/settings integration; malformed-file versus entry-level validation; classic RSC integration; save/history text policies and representative fixtures. These deferrals do not waive fallback ordering, independent controls or side-effect-free switching.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-013-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including catalog schemas, token/font support, settings integration, UI refresh and historical-text policies. Approval does not initiate implementation, coding tasks or another feature review.
