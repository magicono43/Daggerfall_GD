# Fonts and live locale presentation — IMP-007 increment 3

## Creation popup presentation extension, 2026-11-26

The race-confirmation popup uses the explicit classic `FONT0003.FNT` ASCII
mapping when available. This optional bitmap resource is read through DATA and
realized/cached in AV; original bytes stay external. It does not redefine the
three locale roles. A normal `text.fonts:installed` font record with stable ID
`creation-popup` overrides this popup style through existing package/loose
publication, SFNT validation, fallback declarations and content locking. No new
required record or offered locale is introduced. Debug/shell controls keep their
ordinary roles. If a prompt requires glyphs outside the chosen popup font, UI
recovers the whole prompt with the current locale body font and existing literal
glyph diagnostics. Accepted source text is never rewritten. See
[the focused presentation evidence](../../../design_docs/development/evidence/IMP-015-RACE-POPUP-POLISH-2026-11-26.md).

Identities: **locale-fonts-v1**, **text-presentation-v1**, **text-layout-v1**.
Catalog/CSV/token/structured-reader identities and lookup precedence are unchanged.
English is the only offered language. `zz-Test` is a synthetic verification locale;
Hebrew and Arabic strings below are script samples, not shipped localizations.

## DATA definitions and resources

The normal shell explicitly enables `StartupProviderBoundary.enable_locale_fonts`
before reader preparation. Legacy fixtures retain their original compositions.
`locale_fonts.gd` owns domain `text.fonts`, logical resource `installed`, and uses
DATA's real JSON envelopes, stable record IDs, add/replace/patch semantics, file
atomicity, source ordering, contributing/winning/field provenance and omission
tickets. These JSON resources are font definitions, never text-catalog envelopes.
An optional trusted adapter `validate_resource_path(path) -> reason` callback
rejects unsupported logical paths before mutation. Existing adapters are unchanged.

All values contain `schema: "locale-fonts-v1"` and one of:

- `kind: "font"`: exactly one `bundled` asset ID or `sfnt` base64 string;
  `sha256` of decoded bytes, nonempty `license`, `version`, ordered `fallbacks`
  containing stable font record IDs. Unknown fields reject. A bundled ID is from
  the closed application inventory below; it is not a filesystem path. Inline
  single-face SFNT supports ordinary folder/ZIP/loose DATA contributions without
  introducing direct UI filesystem reads, extraction or path traversal. Package
  publishers must include the actual font license in their distribution.
- `kind: "locale"`: exact `locale`, `roles` mapping every `body`, `title`,
  `small-ui` role to a font record, nonempty `coverage` declaration, boolean
  `offer`. Unknown fields reject. This build permits `offer: true` only for `en`;
  new offered-language commitments need their actual acceptance evidence and an
  explicit build capability update. Unoffered mappings permit synthetic testing.

Example mapping value:

```json
{"schema":"locale-fonts-v1","kind":"locale","locale":"en","roles":{"body":"recovery-sans","title":"recovery-sans","small-ui":"recovery-sans"},"coverage":"English Latin","offer":true}
```

`patch` replaces each supplied top-level field; nested role maps and fallback
arrays replace as units. DATA retains original record identity and winning-field
provenance. Required `installed` and English mapping cannot be omitted. Duplicate
exact locale mappings, unresolved role/fallback resources and cycles block the
candidate. A reported reference issue identifies the failing record's winning
contribution token for explicit whole-file omission/rebuild; unresolved remaining requirements
still block. Maximum chain depth is 64. No guessed classic FNT identifier mapping
or implicit regional/neighboring-locale inference exists.

Asset validation checks digest, 12-byte minimum / 8 MiB maximum, single-face
TrueType `00010000` / OpenType `OTTO` signature, at most 128 bounded table entries,
actual FontFile initialization, visible `?` and positive 18-pixel metrics. Encoded
inline input is bounded before decode; DATA's 16 MiB file transport limit remains.
This is not a font security sandbox or a claim to support every SFNT extension.
Bundled bytes come from the actual imported FontFile resource (including exported
`.fontdata` remaps), not raw PCK filesystem assumptions. Each actual FontFile has
system fallback disabled. Imported resource settings
also explicitly disable it. Malformed resources are installation/contribution
failures; an ordinary runtime missing character is a different result.

`prepare_content` validates DATA first, then loads and links the actual fonts and
coherent locale catalogs before menu reservation. Font-only mappings are not
selectable; independent bundled English recovery remains coherent even if every
installed essential entry is unusable. All fallible font loading happens before the existing durable profile
step. After DATA/formula commitment the provider assigns the matching staged
font set and initial effective locale without emitting callbacks. The shell
activates its theme after the completed transaction returns; no I/O or callbacks
enter font commitment. Selected installed
definitions/resources lock with the actual CORE menu and MOD plan. Session return,
new/load transitions and settings do not reopen that configuration. Live switches
use the loaded FontFiles, with no source read, registration, formula rebuild,
package execution, DATA preparation, classic initialization or filesystem adoption.

## Recovery and coverage

`recovery-sans` is DejaVu Sans 2.37. It serves all three bundled English roles.
`sample-mono` is Inconsolata Regular 3.000; only synthetic installed fixtures map
it to body/small-UI with DejaVu as fallback. The bundled recovery FontFile and
English `TextCatalog.RECOVERY` constants are available before any classic reader,
catalog/font pack, settings initialization or DATA publication. The shell installs
that font on its root Theme before startup. All eleven recovery keys have actual
font checks; no machine-installed font is needed. English recovery from unusable
localized controls never removes an operation restriction or changes its result.

`literal` preserves original scalars and whitespace, replacing each exhausted
ordinary glyph with visible ASCII `?` and a returned `missing_glyph` diagnostic
(scalar, scalar position, selected locale, role, caller key/source/window context).
No transliteration or selected-text-locale change occurs. Callers retain diagnostic
values; there is no global text log or render-driven gameplay callback. Essential
controls recover their complete English label/font, rather than marker-only text.
Required prompt text/answer glyph failure rejects a switch and retains the prior
usable prompt. Initial unsupported prompt structure yields readable blocked
presentation with independent shell Quit recovery; it never submits an answer.

No Unicode normalization is performed. Engine shaping handles combining marks,
bidirectional formatting and joiners. Accepted coverage is English Latin plus
explicit synthetic strings: `e` + U+0301 (one source cluster 0..2), Hebrew
`אבג` (visual source starts 2,1,0), Arabic `سلام` (contextual lam-alef ligature;
visual source starts 3,1,0), and mixed Latin/Hebrew/Arabic. Tests examine real
shaped glyph clusters, not glyph presence alone, and saved PNGs. These samples
do not establish full Hebrew/Arabic localization, Windows IME qualification or
coverage of other scripts/emoji/arbitrary mod Unicode.

## UI measurement, structure and refresh

`text_layout.gd` uses TextParagraph with the actual FontFile/fallbacks, logical
pixel size/width, automatic direction and mandatory/word/adaptive breaks. This
matches Label's WORD_SMART mode; trim flags are disabled for meaningful spaces.
No precomputed glyph-count width, normalization, fixed-height clipping or
shrink-to-fit is used. Required labels grow vertically in the existing scrollable
shell. Buttons wrap, retain at least 40 pixels height and disable text trimming.
Horizontal MOD/profile rows share available width so wrapped controls cannot
collapse to padding-only bars.
The rendered suite compares real Label line counts with actual-font measurement.
`measure` returns width/size/height/font size and per-line scalar ranges/sizes.

`structure` retains literal/LF text and distinct page/input/record blocks and
explicit left/center controls. A font control requires a caller's explicit
classic-ID-to-role map; none is guessed. Unselected variants, positions,
unexpanded references and every other unsupported required control reject rather
than flatten. Selecting a variant belongs to the existing DATA/requesting owner.
This helper is not a full classic gameplay renderer or production macro registry.

The real SessionShell binds SessionPrompt to the application text owner. An
opening `text_ref` or per-response `label_refs` uses stable collection/key and
optional exact `required_controls`. Literal opening text stays literal. Prompts
prepare all text/fonts/metrics before applying anything. The owner checks all
plans' original window ID, scope and binding-time window context, then synchronously commits
them without yielding; a frame cannot draw a partially selected presentation.
Shell recovery labels and role fonts update in that same turn. Godot performs
the matching container layout before draw. Resize remeasures with the same font.

Active controls survive refresh. The LineEdit, caret, draft, focus, selected answer,
variant and operation/session identity stay intact. No action signal, response,
window handoff/gate change, RNG operation, reward/reveal or gameplay request is
issued. Covered/stale/retired views reject; active IME composition defers selection
by rejecting the attempt without changing accepted/effective locale. Same-locale
requests are idempotent. Scoped deferred initial focus verifies the window is
still current before grabbing focus. There is no asynchronous locale work queue.

Book-shaped verification wraps actual font text in a scrollable narrow column.
`reading_position` accepts only a caller-verified corresponding anchor present in
the new layout; otherwise it returns beginning plus a notice. Physical page
numbers never infer correspondence. This does not deliver production DATA-018
editions/bookmarks, reading rewards or SAVE serialization.

## CORE settings and lifetimes

The application owner declares `presentation/locale` before Settings.initialize:
TYPE_STRING, explicit default `en`, `live`. CORE validates exact identifier syntax;
availability is a runtime capability. Thus a syntactically valid unavailable
persisted request remains accepted/persisted, with effective `en` and an actionable
notice when installed resources commit. Prior to publication only independent
English recovery is used. No OS locale lookup occurs.

The stock shell stages language selection, Apply calls real CORE Settings.apply
with the presentation consumer, Cancel discards only the widget edit, and Retry
saves accepted values without repeating refresh. Failure to prepare a locale
rejects that group and retains the working presentation/accepted value. Successful
application followed by write failure retains accepted/effective state, the old
persisted value, and an Applied, not saved message/retry. Consumer recreation uses
the effective owner locale. Installing/replacing packs remains restart work.
No backend/player/font-size preference is silently changed.

The controlled gameplay fixture uses real CORE/window/RULE interfaces and fixed
32 zero bytes of seed material, retains one nonzero-draw outcome and checks all
facts before/after switching. Actual QUEST/CHAR/WORLD/SAVE, production message
expansion (IMP-030), authoring (increment 4/IMP-056) and real IME/language coverage
remain their separate gates.
