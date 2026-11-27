# Creation identity and presentation — IMP-015 increment 4

Implementation is machine-qualified; human review and explicit acceptance remain
pending. This document describes owner interfaces and does not accept increment 4,
parent IMP-015 or a milestone.
Increments 1–3 remain user-accepted, including the separately reported nine
increment-3 human checks. IMP-036 supplies actual entry, placement and grants.

## Locked identity definitions

`char.identity:policy#stock` (`creation-identity-v1`) publishes through the normal
shipped → ordered package → captured loose pipeline. Add/replace/patch use the
existing adapter contract; a patch replaces complete top-level members. Required
portrait mappings, provided banks/patterns, portrait sets and all five reflex
records validate before atomic publication. An absent optional culture bank is
reported by Random while manual naming remains available; it does not substitute
another culture or block manual creation. Runtime editing never unlocks content.

Banks have stable IDs, ordered component sets and explicit weighted, named
patterns per supported gender. A pattern contains component-set indices and
literal joins. Required component sets cannot be empty. Every pattern must
guarantee nonblank output and a conservative maximum of 31 grapheme clusters;
controls and bidi formatting are rejected. Names are validated again after
composition. This bounded schema supports additional banks and explicit mappings,
without a silent alternative culture. Unknown or missing resources fail clearly.

`tools/build_creation_identity.py` reproducibly extracts the eight humanoid
objects from the pinned DFU `Resources/NameGen.txt`; the unrelated malformed
Monster3 tail is excluded, without changing the source. Source hash and pattern
interpretation are retained. DFU attribution is in `content/char/DFU_LICENSE.txt`.
TES names remain source metadata; this is no new license grant over game assets.
No original image/video/palette bytes are copied into the repository.

Breton, Redguard, Nord, Dark Elf, High Elf, Wood Elf and Khajiit map to their
explicit culture banks; Argonian maps to Imperial. Ordinary first names compose
sets 0+1 (male) or 2+3 (female), with surnames 4+5. Nords use 0+1+`sen` for the
surname. Redguards use 0+1+2, with set 3 included at 75% for males, and set 4
always included for females. Each part uses the existing unbiased bounded PCG
mapping. This retains DFU's composition/probabilities, not Unity RNG sequence parity.

Each deliberate Random action obtains separate OS entropy and a new operation
source through the existing `rpg-rng-v1/progression` derivation. It never acquires,
seeds or advances a session stream, biography generator, questionnaire or starting
roll source. A separate trusted `name_material` seam qualifies deterministic and
failed entropy. Draft retained metadata records bank/pattern/mapping, entropy
hash, algorithm and draw counts. Equal-text deliberate suggestions still record
their new outcome; ordinary identical edits remain no-ops. Navigation never draws.

## Shared name/input policy

`scripts/ui/character_name.gd` is the shared authoritative text policy, called by
CHAR validation and the real field. It trims Unicode White_Space at the edges,
requires nonblank text and accepts at most 31 composite grapheme clusters. It
does not normalize, truncate, interpret markup or require uniqueness. C0/C1
controls, line separators, BOM and bidi formatting controls are rejected before
trimming; ZWJ/ZWNJ and variation selectors remain available for scripts and emoji.

Segmentation uses the Advanced TextServer's `string_get_character_breaks(text,
"en")`, pinned here to Godot 4.7.2 `ed1daf0bf001b61586d9930840f2f1394092c079`.
That source uses ICU `UBRK_CHARACTER`; its dependency manifest pins ICU 78.3.
The name receipt retains engine/server/policy identity. Missing break-iterator
capability fails acceptance. Maintained vectors include combining marks, regional
indicators, emoji ZWJ families and an Indic conjunct at the 31/32 boundary. Engine
upgrades require requalification rather than assuming identical segmentation.

`project.godot` explicitly includes TextServer support data in exports. Without
that data the stock Windows template advertised break iterators but counted
combined characters as code points; the maintained exported 31/32-boundary
vectors caught this. Debug and release qualification must use the included data.
See [Godot export guidance](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html).

Sources: [Godot TextServer API](https://docs.godotengine.org/en/4.6/classes/class_textserver.html),
[pinned implementation](https://github.com/godotengine/godot/blob/ed1daf0bf/modules/text_server_adv/text_server_adv.cpp#L7679),
[pinned ICU dependency](https://github.com/godotengine/godot/blob/ed1daf0bf/thirdparty/README.md#icu4c).

`character_name_field.gd` retains the actual Unicode input and provides keyboard
and context-menu clipboard operations. Raw paste is validated before the native
single-line control can strip line breaks. Invalid paste preserves the field;
invalid typed/submitted text remains editable and cannot replace accepted facts.
Next, Use name, Enter, Random and summary editing all reach the same CHAR rule.
IME preedit remains control-owned; composition or its ending frame cannot submit
or discard creation. Physical IME/controller observations are distinct from
synthetic event and composition-guard coverage.

Labels render literal text through the existing presentation/font owner. Missing
glyph previews/diagnostics never rewrite the stored name. Display names are not
actor IDs, SAVE identities or paths. The pure validator is reusable by a future
character-sheet rename owner; that UI/native SAVE recovery is not implemented here.
Existing biography history and generated rewards do not regenerate after renaming.

## Portraits and original framing

Mappings name a stable compatible set. Its ordered entries each have a stable
portrait ID, image target and explicit classic record (`-1` for a new mod face).
The baseline declares ten records for each of sixteen race/gender combinations.
IDs survive display-order changes. Previous/Next wraps over the resolved count;
an absent selection requires a deliberate press and never silently picks zero.
Compatible upstream mappings retain the selected ID. Missing/incompatible faces
block completion until the player explicitly chooses a valid replacement.

`creation_art.gd` declares 160 logical portrait targets and resolves original
`FACE<gender><race>I0.CIF` records through the existing classic image codec,
`ART_PAL.COL` and transparent palette index zero. The bounded classic capability
caches source bytes/hashes per active source and one decoded palette; AV caches
one realized texture or failure per logical target. Returned value metadata is
detached; texture resources are read-only by owner contract. Disposal releases
the cache. Mod-added images use `asset.<provider>.<local>` targets and validated
PNG exports; replacing an existing target uses normal media precedence.

Optional `creation.parchment` assembles the nine original 22×22 `SPOP.RCI` tiles
in DFU's row-major border order. Native creation backgrounds, palettes and nearest
sampling remain external. Real controls cover inactive baked actions. Original
framing failure falls back to readable panels; portrait failure still blocks its
required choice. Creation layout shrinks within a narrow viewport and retains
scrolling, visible Back/Restart/Exit, focus restoration and genuine controls.

## Reflex parameters and consumers

The five fixed IDs are `very-high`, `high`, `average`, `low`, `very-low`, mapped
explicitly to classic indices 0–4. Fresh drafts validate Average once through the
normal owner edit. Missing/invalid data never recovers by substituting Average.
Navigation and summary editing retain the selected identity.

Each record couples an integer pre-division timer adjustment (±1,000,000), monster
component probability (0–100 inclusive), and positive Q16 practice multiplier
(1..1,048,576, up to 16×). Mod overrides need not be monotonic. Descriptions use
resolved values and distinguish the component gate from final accuracy and
practice credit from immediate skill gains. Selection consumes no combat RNG,
awards no practice and changes neither movement nor input response.

`reflex_parameters.gd` provides pure checked arithmetic. Effective practice is
`(uses * practice_q16) >> 16`, with nonnegative uses at most 2^42−1 so the product
fits signed 64-bit. It does not alter the recorded tally or compound scaling.
The checked timer projection consumes a supplied inclusive 1500..3000 draw and
level 1..1,000,000: `max(0,draw−50*(level−10)+adjustment)/980.0`. It does not draw.
Live COMBAT branches, progression checks, SAVE compatibility and post-creation
character storage remain their actual owner/task gates. No live difficulty slider
or new combat/progression system is introduced.

## Final review, CORE and optional clips

Normal New Game composes `creation_identity_inputs.gd` over the accepted career,
biography and starting-roll providers. The summary contains name, actual portrait,
reflex parameters and the existing career/history/allocations, while exact hidden
biography rewards remain hidden. Its only direct editors remain name, face,
attributes, skills and reflexes. Other changes require Restart.
Read-only tabs separate attributes/skills, career/reflexes and history without
adding editors. A separate horizontal name scroller prevents a valid long name
from overlapping the portrait. Nested content retains vertical scrolling.

Capture revalidates all required sections and retains stable definitions, field
contributors, source receipts, generated outcomes and once-only obligations in
the existing immutable `creation-submission-v1`. CORE admits at most one original
intent; retry uses that captured input. No UI edit creates actors or grants.
After submission the draft is sealed: Retry uses the original capture, while
editing requires Restart. Read-only review tabs remain usable.

`session/creation_cinematics.gd` requests the existing AV consumer during CORE
preflight, before replacement. Targets `creation.intro.0..2` map to DFU's verified
`ANIM0000.VID`, `ANIM0011.VID`, `DAG2.VID` order, with classic 1.6 display aspect.
Normal media replacements may supply the supported native video profiles instead.
`media/creation_videos` is a persisted live application preference, exposed on
final review and Settings. It is independent of UI-008's startup/death policies.
Application, failed saving and rejection are reported separately.

Finished, Skipped and optional failure advance only their exact current attempt.
Duplicate/stale callbacks cannot advance again. Disabled/missing clips bypass
without recurring missing-media warnings. The AV consumer carries held-input
fences between attempts and releases its windows/audio/overrides before terminal
delivery. The consumer also emits release-only input observation so covered
UI/action quarantines can clear held state without activating controls.
CORE cancellation clears the sequence before cancelling playback; Quit cancels
cancellable creation preflight. Presentation never returns fake entry
success: the stock provider completes with its truthful unavailable-entry failure.
Real entry/grants/placement/opening content remain IMP-036.

`tools/review_creation_presentation.ps1` opens a labelled human review using all
production creation providers. No name, face, reflex or other creation choice is
assigned by the review harness. Acceptance remains the user's decision.
