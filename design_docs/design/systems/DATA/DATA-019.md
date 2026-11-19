# DATA-019 — Locale fonts and glyph coverage

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Resolve validated font resources by locale and role so supported localized text, mixed-language fallback and essential controls remain readable. Separate font selection/coverage from text identity and authoritative gameplay.

## Intended player experience

Supported languages render correctly with suitable fonts and layout. Missing characters are visible rather than silently erased. Language changes reflow presentation without changing choices or focus. Recovery remains usable when original assets or optional font packs are unavailable.

## Confirmed requirements

DATA-019-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm extensible locale/role mappings and classic styling where practical; mixed-language font fallback and bundled recovery; Unicode/script capability with verified offered-language support; visible missing-glyph handling; actual-font layout without clipping/indefinite shrinking; and validated acyclic resources/chains under content-lock rules.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/TextManager.cs#RegisterLocalizedFont` keys replacements by locale/font role, replaces an existing registration and forces SDFFontRendering on. `GetLocalizedFont` may return null; selected-locale overloads wait for locale selection.
- `Game/UserInterface/DaggerfallFont.cs` contains classic and SDF font paths, glyph access and text measurement. Registration or glyph existence alone does not establish every text renderer's shaping/layout support.
- `API/FntFile.cs` reads original FONT000*.FNT data with 240 glyph entries and fixed 16×16 source glyph dimensions. These are format facts, not approved limits on added fonts.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Actual font inventories, fallback coverage, mixed scripts and rendered UI were not verified. Source remains unchanged.

## Detailed rules and behaviors

### Roles and resources

Use explicit locale-and-role mappings with stable font-resource references and validated mod overrides. Roles include supported body/title/small-UI purposes; exact role inventory remains a schema contract. Preserve classic styling where practical without restricting additions to classic glyph counts, five font names or a particular bitmap/SDF backend.

Resolve contributions under DATA-003's declared operations, precedence, provenance and whole-contribution recovery. Validate assets, mappings and fallback chains before publishing them; reject cycles and required unresolved resources. Do not rely on incidental registration order as the override policy. Actual main-menu entry locks installed resources/configuration for the run.

### Coverage and font fallback

Use a declared fallback-font chain supporting mixed-language text, including the base/source text that DATA-013 can select. Font fallback supplies glyph/rendering capability; it does not itself change the chosen language or string. Validate the resulting text's required script behavior, not just the presence of individual character images.

Missing characters must not silently disappear. After font fallback is exhausted, ordinary text shows a visible replacement marker and diagnostic context. Do not guess transliteration. Essential prompts that cannot remain understandable require bundled readable fallback text or usable recovery rather than marker-only controls. Those resources must work without ARENA2 or optional font packs.

This does not promise complete coverage of arbitrary user/mod Unicode input. Offered language/content coverage must be declared and verified; runtime missing-character behavior remains truthful outside that coverage. Exact marker design, diagnostic deduplication and essential readability checks remain UI/technical contracts.

### Language/script capability

Use a Unicode-capable path supporting shaping, combining marks and right-to-left text where required by an offered language. Advertise a language as supported only after its required fonts and layout behavior pass verification. No initial language roster or commitment to every language is approved here.

UI/AV own actual shaping, bidirectional layout and rendering integration. Exact script coverage, fallback selection granularity, font licensing/provenance metadata and engine APIs remain implementation dependencies. A font claiming glyph coverage does not prove correct shaping, reading order or interaction layout.

### Measurement and reflow

Measure and wrap using the primary/fallback fonts actually rendered. Reflow text and book pages as needed while preserving meaningful DATA-015 structure, option identities and keyboard/controller focus. Do not clip required instructions or shrink text indefinitely to retain classic-sized boxes.

DATA-018's verified anchor/beginning-with-notice rule governs reading-position changes when repagination lacks correspondence. Text reflow does not authorize guessing a bookmark page or accepting a pending choice. Exact scrolling, resizing, minimum readable sizes and scaling are UI contracts, not selected here.

### Activation and validation

Language switching may select already loaded/validated font resources without restart under DATA-013. Recompute affected layout coherently; do not expose stale metrics while drawing a newly selected font or replay gameplay callbacks during refresh. Installing/replacing fonts or changing mod order retains DATA-003 lock/restart rules. Font registration must not silently rewrite unrelated player settings merely because DFU forces its SDF option.

Rendered verification must cover mixed-language fallback, long labels, required scripts, book reflow and independent recovery controls. Include actual focus/choice identity preservation and meaningful structure, not only atlas screenshots. Structural invalidity follows DATA-003 recovery; ordinary runtime missing glyphs follow the explicitly approved marker policy rather than silently disabling packages.

## Relevant formulas and parameters

No fixed font count, glyph count, font size, minimum scale, atlas dimension or rendering backend is approved. Text metrics must correspond to actual rendering. Classic FNT constants are source-adapter facts. Exact readability/scaling and supported-language criteria remain measurable owner contracts.

## Required data

Stable font-resource and role IDs; locale mappings; fallback order; validated assets/metrics; script/coverage declarations; source/package provenance; bundled essential resources; missing-character diagnostics and effective layout context. Complete role/schema, supported language inventory and resource lifetime/cache rules remain dependencies.

## Inputs, outputs and events

Inputs: selected locale, font role, resolved validated resources, chosen text/script requirements and layout context. Outputs: effective font/fallback selection and metrics, coverage failures/markers or essential recovery. These are conceptual contracts, not APIs/signals. Font selection/layout completion does not commit a choice, alter a restriction or mutate gameplay identity.

## Cross-system interactions

- DATA-003 owns installed contributions/lock; DATA-013 selects text/language and protects essential labels. DATA-014 text patches cannot bypass required coverage/format handling.
- DATA-015/016 provide supported structure and literal/context-safe expansion; UI must not reinterpret glyph fallback as executable markup.
- DATA-017 names retain identity even when glyphs are missing. DATA-018 governs book editions and anchor correspondence during reflow.
- UI/AV own rendering, shaping, pagination, focus and resource lifetimes. CORE-003/006 own settings application; CORE recovery and CORE-019 restrictions remain independent of text availability.
- MOD owns package/executable lifecycle. SAVE/UI own persistent reading/interaction state, separate from font atlases or localized text metrics.

## Edge cases and failure conditions

- Selected-language text falls back to another language: effective font chain must support that text, not assume one language/script per screen.
- Glyph exists but shaping is wrong: offered-language verification fails; glyph count alone cannot establish support.
- Ordinary unknown character remains unsupported: visible marker and diagnostics, not omission/transliteration. Essential unusable text invokes bundled fallback/recovery.
- Fallback cycle or unresolved required font reference: reject candidate before publication rather than recurse indefinitely.
- Locale switch changes glyph widths: reflow using matching metrics without losing focus or changing pending option identity.
- Book repaginates: apply DATA-018 anchor rules; raw page-number retention is insufficient.
- Font pack changed externally: no unsupported live resource replacement; use restart/configuration rules.

## Configuration and balancing options

Validated locale/role font overrides are supported. No silent missing-glyph omission, indefinite shrink-to-fit or forced backend preference change is approved. Exact accessibility/font-size settings remain UI/CORE owner specifications. There are no gameplay balance changes.

## Save/load considerations

Font assets/atlases/metrics are application presentation resources, not character-save identity. Loads must not remap names, options or bookmarks through glyph indexes/page metrics. UI/SAVE retain interaction/book anchor state under their contracts; reflow does not replay effects or alter gameplay. Font preferences follow approved application settings policies where defined.

## Technical constraints

Target engine: Godot 4.7.2. Separate locale/role resolution, glyph fallback, shaping/measurement and authoritative gameplay. Keep sources read-only, contribution publication coherent and required recovery independent. Concrete font formats, APIs, caches, fallback granularity and layout implementation remain choices to verify; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Stable locale/role references and validated overrides support fonts beyond classic counts/roles while preserving styling where practical.
2. Declared fallback handles mixed-language strings without changing text identity/language selection or silently omitting characters.
3. Ordinary exhausted glyph fallback shows a visible marker/diagnostics; essential unreadable prompts retain bundled usable text/recovery independent of original/optional assets.
4. Offered languages pass required Unicode shaping/combining/RTL and layout verification before support is advertised.
5. Actual rendered font metrics drive wrapping/reflow; required instructions are not clipped or indefinitely shrunk, and choice identity/focus survives refresh.
6. Fallback graphs/assets/mappings validate coherently and cycles fail. Live locale switches use validated resources without bypassing installed-content locks.
7. Book reflow follows DATA-018 anchors/fallback rather than guessed pages. Rendering does not mutate gameplay or force unrelated preferences.
8. Representative required-script, mixed-language, long-label, missing-glyph, cyclic-chain and independent recovery rendered fixtures verify implementation.

These are future verification criteria. No implementation, font/glyph fixtures or rendered tests were performed during specification.

## Consistency review

Reviewed against DATA-001–018 and approved CORE settings/recovery/restriction contracts. No contradiction identified. Glyph fallback complements DATA-013 language fallback without adding silent language tiers. Structured text and book anchors remain authoritative under DATA-015/018. Unicode support is capability-driven and verified per offered language, not a claim of unlimited coverage. Installed font changes retain DATA-003 lock while validated locale selection remains live.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: role/resource schemas; language/script roster and shaping contracts; fallback granularity/coverage checks; exact markers/diagnostics and essential readability policy; UI sizing/scaling/focus implementation; font resource lifetime/provenance; book/settings integration and rendered fixtures. These deferrals do not waive readable recovery, actual-font metrics or verified language support.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-019-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including font-resource schemas, language coverage, layout/settings integration and rendered verification. Approval does not initiate implementation, coding tasks or another feature review.
