**User acceptance, 2026-11-26:** "Good work, I accept what you have done in increment 2". Increment 2 is accepted. Individual numbered human-test outcomes were not reported and are not inferred. Later increments, parent IMP-015 and integration/milestone gates remain open. Earlier pending-acceptance wording below is historical.

# Race and career — IMP-015 increment 2

Increment 3 adds the [biography and starting-roll provider](CREATION_STARTING.md)
under qualification. Earlier statements below deferring these providers describe
the accepted increment-2 scope; they do not override the newer contract.

Production New Game binds `creation_inputs.gd` to DATA's locked
`char.career:policy#stock` and `char.career:sources#stock`. These CHAR providers
qualify birth race/gender, class method, eighteen presets, class questionnaire and
custom careers. The `actor.inputs` structural profile remains
`semantic_ready:false`; reader presence is not semantic qualification. Biography,
full name/face/reflex mechanics, starting rolls/allocations and real entry remain
later owners. Providers have no live actor/item/spell/quest/faction interfaces.

## Publication and sources

The native ten-question presentation initializes through the method-selection
request, not render. It uses the original GFX scroll/CEL flourishes and Ignite
feedback. Answers still use normal owner edits, and scores are recomputed from
current retained answers. An application-owned presentation controller waits for
the current clip before advancing; retirement cancels its callbacks. Separate
Previous/Next review controls retain approved answer revision. Final Yes/No uses
the existing recommendation confirmation and direct-list fallback. See the
[questionnaire polish evidence](../../../design_docs/development/evidence/IMP-015-QUESTIONNAIRE-POLISH-2026-11-27.md)
for bounded asset profiles, mod target layouts and focused verification.

`data/creation_career.gd` registers `creation-career-v1` before preparation through
the existing shipped → ordered package → captured loose pipeline. Resources are
`policy` and `sources`, each with stable record `stock`. Add/replace/patch are
supported; patches replace complete top-level members. Schema, ranges, supported
identities, conflicts and references validate before atomic publication. Complete
composition also validates every resolved preset against supported CHAR semantics
and numeric domains. Invalid contributions cannot partially publish. Run locking
and provenance retention are unchanged.

Policy defines eight attributes with starts/bounds/total; existing thirty-five
CHAR skill IDs with classic numbers; fixed 3/3/6 tiers; HP bounds/default;
difficulty bounds; positive advancement endpoints in integer thousandths; separate
bounded configurable trait-list limits (0..90, baseline seven); five reputation starts/bounds/total; ninety supported trait
variants; eight race definitions and forty three-answer category rows. Labels and
list order never establish identity. Numeric domains are bounded. Validated JSON
integers are converted at the DATA boundary; draft edits require exact integers.

`tradeoff_witness` supplies an HP/trait combination proving a legal custom build
exists. Schema validation constructs feasible attributes/reputation and twelve
distinct skills, then uses the complete CHAR evaluator to check it. Mods whose
difficulty interval requires traits can supply that witness. This avoids an
exponential search without banning such mods or substituting a witness into the
player's draft. Bounds/cost changes must update an invalid witness explicitly.

Original descriptions and forty questions use the existing TEXT.RSC decoder.
CLASSES.DAT must have its 216-byte layout, 66 unique nonnegative triples summing
to ten, complete result coverage and valid preset identities. TAMRIEL2.IMG must
decode to the 320×200 province picker. Fifty-six body/clothed/head/background
sources are checked for presence, first-frame decode and source hashes. This
qualifies mappings, not CHAR-007's full portrait selector or complete asset set.

Sources have explicit per-resource failure status. Questionnaire failure offers
direct selection without inventing a recommendation. Required race text, picker,
appearance and preset text/definition failures reject the affected selection.
Optional artwork/audio failure cannot block an otherwise valid choice. Replacing
map artwork does not rewrite hit geometry: a mod changing provinces must also
provide a compatible DATA picker. Source records support explicit replacement.

## Draft authority

Race means confirmed **birth** identity, independently of future effective-race
transformations. Gender revalidates the current race's appearance mapping.
Structured racial parameters are retained/disclosed, with no racial attribute or
gender stat modifiers. Effect resolution/stacking remains MAGIC/COMBAT/MOVE/CHAR.
Race/gender changes invalidate incompatible face selection.

Preset acceptance rechecks actual resolved skill tiers, equipment flags, traits,
spell-point multiplier, HP and advancement. Unsupported bits/conflicts fail.
Spell-point factors resolve from the existing `actor.baseline:policy#player`
numeric definitions used by CHAR actors, including custom default/selected magery;
creation does not duplicate those balance values. Classic skill numbers must match
the shared stable CHAR skill identities. Mods can relabel/reorder skills or replace
career assignments, but cannot renumber supported types behind the live owner.
Advancement uses the exact CLASS fixed-point rational rather than DFU's two-decimal
presentation rounding: an intentional source-precision difference. Original
descriptions are accompanied by actual resolved mechanics.

`CreationDraft.generate_questionnaire(token)` deliberately assigns questions;
validation/navigation cannot draw. Normal initialization uses 32 OS entropy bytes;
a trusted fixture Callable supplies explicit material. Failure has no clock/default
seed fallback. An independent operation-local source uses reviewed
`rpg-rng-v1/progression` derivation, `pcg32-xsh-rr-v1` and bounded mapping. It never
acquires/initializes/advances a gameplay session stream or adds a session purpose.

The user selected DFU's collision-advance **sampling behavior** on 2026-11-26:
ten draws from forty; duplicates advance modulo forty until unused, with no extra
draw. This does not claim Unity RNG or original-executable sequence equivalence.
An independent Python unsigned-integer oracle with 32 material bytes of value 5
produces raw indices `38,27,30,7,7,24,34,7,1,3`, assigned as
`38,27,30,7,8,24,34,9,1,3`. Questions/order/answers/generator provenance persist
for this draft. Scores are recomputed from current answers. Partial/malformed
answers cannot recommend. Declining opens the direct list including Custom.
Restart/exit clear the assignment.

Custom facts contain stable `<draft-id>/custom`, nonblank Unicode name (at most
256 code points; Unicode White_Space alone is blank), actual attributes, tier
arrays, trait IDs, HP and reputation. Renaming retains identity. Temporary budget,
difficulty and reputation imbalance is editable, but cannot complete. Duplicates,
unsupported IDs, target conflicts, singleton violations and excessive lists reject
atomically. Skill replacement releases the previous skill without swapping.
Subtype selection commits only with Add; cancellation cannot charge a placeholder.

Trait-menu polish (2026-11-27): Add opens a category picker; confirming a category
with variants opens its subtype picker, whose confirmation submits the complete
candidate. A single click on either displayed line removes a selected trait.
Picker cancellation leaves owner state unchanged. Conflicts/duplicates are
silently ignored by the presentation; CHAR still validates every submitted edit.
The baseline per-side limits remain seven. Mods can replace `limits.advantage`
and `limits.disadvantage` through `char.career:policy#stock` (0..90).
Each trait's `conflict` is a bounded lowercase group identifier (letters, digits,
underscore, hyphen; empty disables membership). Different categories in the same
nonempty group conflict when their supported effect targets match. Stock groups
are `enemy`, `weapon` and `tolerance`, matching DFU's pairs. Mods can change group
membership without changing effect identity. `singleton` controls whether a
category allows multiple variants; if either variant requires a singleton, the
pair rejects in either selection order. Duplicate IDs always reject. Stable
IDs, supported targets/sides, atomic publication and the legal-build witness
remain validated; changing creation compatibility does not implement new live
trait effects or define runtime effect stacking.

Unapplied class-name text survives nested editors/backtracking. Use name, Enter
or Next submits the visible value through the same CHAR validation. Editable text
retains its original scalars. The existing font owner supplies read-only `?`
previews and retained `missing_glyph` diagnostics when the active font cannot
display a character; a visible notice explains the required font pack. The
bundled English font does not establish arbitrary CJK/emoji coverage. No new
font dependency, normalization, transliteration or rejection of stored Unicode
is introduced. Summary/read-only controls use the same display recovery.

Every completion recomputes HP contribution, selected costs, difficulty, exact
rational advancement and reputation from actual facts. Selected effect metadata
is rebuilt from current trait IDs; no live effects are inferred/dispatched.
Removal cannot retain charges/flags. Preset/custom state stays isolated; ordinary
backtracking retains section caches while declared dependencies invalidate active
downstream facts.

`section_status` returns current validation provenance without mutating the draft.
Capture records these fresh receipts, including retained gender after a race
change, rather than stale edit-time receipts. Immutable capture/retry, at-most-once
CORE admission and the five summary editor restrictions remain intact.

## Presentation and lifecycle

The map uses DATA hits plus accessible province buttons. Race/class confirmations
show original text, actual disclosure and Yes/No. Escape cancels a pending race
candidate, stops narration and permits reselection; explicit Exit discards as
before. Local UI transitions retire callbacks immediately before deferred repaint.

Custom controls occupy corresponding CUST00 regions for name, attributes, twelve
skills, HP, nested traits/reputation and the original dagger. Opaque controls mask
incompatible baked labels. Configured endpoints replace baked multiplier numbers.
Dagger position alone is clipped; actual invalid difficulty remains visible and
blocks completion. Contributions/balances/advancement remain visible below.
Long content scrolls. Comprehensive presentation acceptance remains increment 4.

`creation.dagger` maps to CUST08I0.IMG with palette index zero transparent.
Eight `creation.narration.<race-id>` targets use the existing media replacement/
loose pipeline and DATA clip IDs. Caches retain one texture/failure per image and
one stream/failure per race. Navigation/cancel/discard stop/free the player.
Invalid selected replacements fail without unrelated fallback.

## Provenance and gates

`tools/build_creation_baseline.py` regenerates authored policy from approved
CHAR-002/004/005 tables and pinned DFU RaceTemplate/DFCareer/question metadata.
DFU metadata/evidence is MIT; see `content/char/DFU_LICENSE.txt`. Original Bethesda
text/questions/results/images/audio remain external installation data. No original
asset bytes or modified reference files enter Git. PROJECT-DATA-D01 applies.

`tests/creation_career_review_inputs.gd` is an explicitly labelled review-only
composition: real race/career plus assigned later stages. Normal New Game never
selects it. Assigned biography/portrait/allocations do not qualify actual affinity,
distributions, portrait selection, grants or entry. IMP-036, runtime effect/stacking
owners, native SAVE, later increments, human acceptance and M2/M3 remain open.
