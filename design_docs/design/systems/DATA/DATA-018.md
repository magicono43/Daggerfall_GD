# DATA-018 — Readable book sourcing

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Resolve a book's readable edition and presentation metadata through explicit identity, content precedence and language fallback. Keep book sourcing separate from inventory state, economic rules and reading-triggered gameplay.

## Intended player experience

Read a complete usable edition in the selected language or approved fallback. Translation does not change item value or availability. Missing content is reported without deleting the owned item. Reading position survives presentation changes when a verified anchor exists, otherwise reopening starts predictably with a notice.

## Confirmed requirements

DATA-018-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish stable work/edition identity; whole-edition language fallback; presentation/gameplay metadata separation; edition usability and supported repagination; explicit unavailable reading without item loss; and anchor-based reading position with beginning/notice fallback.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/LocalizedBook.cs#OpenBookFile` tries its localized format then classic format. `Exists` checks a suffixed -LOC asset in mods or StreamingAssets/Text/Books, a narrower condition than successfully opening usable book content.
- `OpenLocalizedBookFile` reads title, author, body and formatting alongside price, adult-content, uniqueness and global-variable availability fields. Its -LOC filename convention alone does not establish a locale-qualified edition model.
- `OpenClassicBookFile` attempts `Utility/AssetInjection/BookReplacement.cs#TryImportBook` before `API/BookFile.cs` original-file loading, then converts page tokens to markup. Original book formatting fidelity requires representative comparison rather than assuming perfect conversion.
- BookReplacement discovers custom ID/file/title mappings and distribution conditions. `Game/Items/ItemHelper.cs` supplies book filename/title lookup. Classic and custom numeric conventions are source details, not universal identity limits.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Complete locale behavior, malformed edition handling, page conversion fidelity and original fixtures were not tested. Source remains unchanged.

## Detailed rules and behaviors

### Identity and metadata

Use a stable book/work ID separate from inventory item instance, filename, title and localized edition. Translations normally reference the same work; an intentionally different book receives a new ID. Preserve explicit classic mappings and allow validated mod additions without relying on display names or list order.

Edition identity includes the declared work/language target and sufficient source/version context for validation and anchors. Duplicate work additions or ambiguous classic mappings follow DATA-003 failure rules; explicit supported replacements remain valid. Same work identity alone does not prove every changed edition or old bookmark compatible.

Translations control supported title/author presentation, body and formatting. Shared price, distribution, uniqueness and availability conditions belong to book/gameplay definitions under ITEM/ECON/QUEST. Language selection cannot change value or loot eligibility. A file mixing presentation and gameplay fields must be interpreted through an explicit validated adapter/schema rather than giving translation fields implicit gameplay authority.

### Edition resolution

Apply DATA-003 contribution precedence within each declared edition target. Select a complete usable edition through DATA-013 selected-language → declared base-language → explicit source fallback. Explicit classic mappings may supply original book content as that source fallback. Do not guess a different classic book or silently combine chapters across editions.

Resolve installed editions during the pre-menu content plan and retain DATA-003's run-long lock. DATA-013 live language selection can switch among loaded/validated edition resources without live-reading new external edits or changing mod order. Exact book resource loading/cache strategy remains technical scope and must respect the approved validated-resource boundary.

Structural contribution errors retain DATA-003's whole-contribution rejection and explicit recovery. A recognized edition that is unusable as presentation invokes whole-edition fallback with diagnostics. This usability fallback is explicit policy, not silent structural-file skipping or permission to reveal an overwritten earlier same-language contribution under DATA-014.

### Usability and layout

Validate required metadata, readable body and supported formatting before calling an edition usable. File existence alone is insufficient. Distinguish missing, unreadable, malformed/unsupported and usable content with source/work/locale context. Exact metadata requiredness and intentional special formats need declared schemas; do not invent author names or substitute another work to fill gaps.

Preserve supported original page/layout meaning while allowing UI repagination for language and display size. This does not require identical page counts or physical line breaks across languages. DATA-015 structural formatting and DATA-016 safe expansion apply where used; translations/body text must not execute gameplay commands. Exact pagination, images, fonts/glyphs and renderer coverage remain owner contracts.

### Unavailable content and gameplay outcomes

If no usable edition remains, show an explicit book-content-unavailable result while retaining the inventory item. Do not silently delete it, substitute another title/work or report successful reading. A valid edition chosen through approved fallback may be read normally; failure of an earlier candidate does not forbid a successful fallback edition.

ITEM/QUEST/CHAR and other owners define reading-triggered effects and their successful-read conditions. Opening, validation, preview or rerendering does not itself grant skills, complete tasks or repeat rewards. Failed opening must remain distinguishable from successful reading; this feature does not choose whether a successful read means opening, viewing a section or finishing a book.

### Reading position

Retain position using stable chapter/section anchors where supported rather than page number alone. After language/edition changes, use a verified corresponding anchor. Without correspondence, reopen at the beginning with a notice instead of guessing a matching page or nearby section. Physical page number may remain transient UI information but cannot alone establish cross-edition position.

Exact anchor granularity, multiple bookmarks, persistence and notice behavior remain UI/SAVE scope. No fabricated chapter structure is required for every classic book; unsupported correspondence uses the approved beginning fallback. This does not approve overwriting an old persistent bookmark before its owner defines safe persistence behavior.

## Relevant formulas and parameters

No economic formulas, distribution weights, page dimensions, font sizes or bookmark limits are approved. Language and contribution order follow DATA-003/013. Original page counts and numeric book IDs are source facts, not target presentation/extension limits.

## Required data

Stable work ID and classic mappings; item-to-work reference; declared edition/locale/base/source context; title/author presentation, readable body and supported formatting; shared gameplay metadata references; provenance and usability outcomes; stable section anchors/correspondence where supported. Bookmark state remains UI/SAVE-owned. Complete schemas and source-format conversions remain dependencies.

## Inputs, outputs and events

Inputs: work/item reference, selected language, resolved editions/source mappings, open/validation requests and reading-position context. Outputs: complete usable edition with provenance, unavailable/failure details, verified anchor or beginning-with-notice result. These are conceptual contracts, not APIs/signals. Source-open success is distinct from owner-defined reading completion or reward commitment.

## Cross-system interactions

- DATA-001/002 retain source access/readiness and failure reporting. DATA-003/013/014 govern installed contributions, locale selection and fallback boundaries.
- DATA-010 links item instances/templates to readable content without merging work identity with ownership/condition. DATA-015/016 provide supported structure/macros where applicable; DATA-019/UI/font owners determine rendering capability.
- ITEM/ECON/QUEST own value, distribution, uniqueness and availability. CHAR/QUEST and other owners define reading-triggered effects independently from text display.
- UI owns book presentation, repagination, anchors and notices. SAVE/owners define persistence and compatibility; CORE settings/lifecycle recovery remains binding. MOD owns package/executable lifecycle.

## Edge cases and failure conditions

- Title or filename changes: stable work/item references remain intact; unrelated same titles do not merge identities.
- Translation has a usable file but invalid required body/format: reject its usability and try whole-edition fallback, not chapter mixing.
- Language change produces different page count: use verified anchor, otherwise beginning/notice; do not copy page number blindly.
- Mod removes readable content from an owned item: preserve the item and report unavailable content. Saved item compatibility separately follows DATA-010/SAVE.
- Translation attempts to change price/availability: gameplay metadata stays under shared authoritative definitions and owner validation.
- Classic fallback missing/unreadable: explicit failure, not another work or successful empty book.
- Repeated reading UI refresh: no automatic re-award or quest advancement. Exact successful-read trigger remains owner-defined.

## Configuration and balancing options

Validated new works/editions and explicit replacements follow supported schemas and content locks. No language-dependent pricing/eligibility or automatic missing-book deletion is approved. Reading UI options and economic/distribution balancing remain owner decisions.

## Save/load considerations

Persist stable work references through owner item schemas, separately from edition presentation and bookmarks. UI/SAVE define anchor/version context and compatibility; changed editions do not justify guessed position. Loading or refreshing must not replay reading rewards. Historical/snapshot text policy remains DATA-013/owner scope; no universal full-book snapshot or bookmark serialization is selected here.

## Technical constraints

Target engine: Godot 4.7.2. Separate work identity, locale edition resolution, rendering, item state and gameplay metadata. Keep inputs read-only, source provenance explicit and outcomes truthful. Concrete formats, APIs, cache, renderer and anchor representation remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Stable work IDs/classic mappings support validated additions and translations without relying on title/filename or merging item instance identity.
2. Complete usable editions follow approved language fallback and per-target contribution precedence; no silent chapter mixing or guessed classic source.
3. Translation changes presentation, not price/distribution/uniqueness/availability.
4. Required metadata/body/format validate before usability; existence alone does not pass. Supported original layout meaning survives appropriate repagination.
5. Exhausted fallback reports unavailable reading while preserving inventory item and avoiding substitution or false successful-read outcomes.
6. Reading-triggered gameplay remains owner-committed and distinguishes failure; validation/refresh cannot repeat rewards.
7. Language/edition changes use verified stable anchors, otherwise beginning with notice rather than guessed pages.
8. Source/content-lock rules remain intact. Representative classic/localized/malformed/missing, metadata-isolation and changed-pagination fixtures verify these contracts before implementation is complete.

These are future verification criteria. No implementation, book/layout fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–017 and approved CORE settings/lifecycle/load contracts. No contradiction identified. Whole-edition usability fallback refines DATA-013 without bypassing DATA-003 structural rejection. Work/item distinction preserves DATA-010 state/compatibility boundaries. Repagination respects DATA-015 structural meaning, and display remains independent of DATA-016 gameplay commits. Missing readable content does not erase the item or promise save compatibility.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: stable work/edition/classic mapping schemas; metadata and format requiredness; verified original conversion/layout meaning; locale/base ownership; font/pagination support; anchor generation/correspondence and bookmark persistence; reading-effect success boundaries; shared gameplay metadata migration and SAVE compatibility; representative fixtures. These deferrals do not waive complete-edition fallback, item retention or explicit reading failure.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-018-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including edition schemas, rendering, reading-effect triggers and bookmark/save contracts. Approval does not initiate implementation, coding tasks or another feature review.
