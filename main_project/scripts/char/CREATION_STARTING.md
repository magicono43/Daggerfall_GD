# Biography and starting rolls — IMP-015 increment 3

**User acceptance, 2026-11-26:** The user reports "Also, 1-9 are PASS" and states
"I accept what you have done in increment 3". Increment 3 and its review fixes are
accepted. Increment 4, parent IMP-015, IMP-036, native SAVE and named milestone
gates remain open. Normal fresh entry remains gated. Earlier pending language in
the original machine-run evidence is historical.

## DATA and supported sources

`creation_biography_inputs.gd` extends the real race/career provider and
`creation_starting_inputs.gd`. Normal New Game uses this composition. DATA
publishes `char.starting:policy#stock` and `char.biography:policy#stock`,
`char.biography:texts#text-<RSC ID>` and
`char.biography:books#book-<classic ID>`. Shipped contributions, ordered packages,
captured loose overrides, atomic publication and run locking use the existing
registry. Patch members replace whole top-level members/arrays. Registry
`replace` replaces the logical resource, not just one record: use `patch` for a
single existing history entry. Source identity, contributors and field winners
remain separately inspectable. No whole-catalog read occurs on a point query.

Starting rules provide per-attribute bonus bounds/caps and an independent pool
range, per-tier/other skill ranges, separate tier pools and per-skill final limits.
The resolved CHAR permanent numeric domains constrain them; no UI balance table
or implicit clamping is introduced. Baseline: attribute bonuses 0..10, pool 6..14,
cap 100; Primary/Major/Minor/other skills 28..31/18..21/13..16/3..6, three pools
of six, final skill limits 0..100. Custom bases and fixed distinct 3/3/6 tiers
remain career-owned. Unsupported added skill identities still need the real
career/effect/progression/persistence contracts; a new label is not qualification.

Biography policy contains the explicit eighteen-class affinity order and eligible
template mappings, narrative roots, isolated race context, humanoid name banks,
book pool, item mappings, reward ranges/material mappings and disclosure labels.
Added mapped templates can have a different question count (consumer bound 256).
Stable question/answer identities, not labels or display positions, select facts.
Classic structural definitions come from `actor.inputs`; this does not change
their structural `semantic_ready:false` profile into a global gameplay claim.

The selected classic installation supplies questions, effects, TEXT.RSC and
interface graphics. Text records preserve explicit availability; the corpus has
a reference to absent record 4178. Recording an unused narrative token does not
invent its text. If actual required macro expansion reaches it, evaluation fails
with the exact missing ID. It cannot silently produce an empty required story.

The pinned DFU `Resources/NameGen.txt` supplies eight humanoid banks; unrelated
malformed Monster3 JSON is excluded during extraction. `Resources/books.txt`
supplies book identities. The explicit shipped pool has 90 available books;
112/113 (*Bourn in Wood*, parts I/II) are excluded with provenance because their
files are absent from the selected classic corpus. There is no runtime filtering
of a configured pool. All configured source metadata must qualify. The narrow
read-only book capability checks bounded file/header/page-address structure and
hashes, without claiming a runtime book UI, ITEM constructor or SAVE consumer.
Native source receipts cannot be fabricated by contributions.

DFU metadata/source provenance and hashes are retained in the authored policies;
the snapshot's MIT attribution is in `content/char/DFU_LICENSE.txt`. TES names and
book identities remain source metadata; this is not a new license grant over
original game assets. Original question/story/art/book bytes remain external and
read-only. No reference file is changed.

## Biography evaluation and retained intent

Presets resolve declared mappings. Custom affinity counts each of twelve distinct
skills once against each classic preset's twelve skills. Strict greater-than in
the explicit approved order resolves ties. Missing presets/mappings, zero overlap
and required unsupported semantics fail with no unrelated/default biography.

Deliberate initialization selects uniformly among validated eligible templates.
Manual choices and automatic choices share evaluation. Automatic generation fills
only unanswered questions, then permits revision; repeated automatic requests do
not regenerate a complete set. There is no biography/template reroll control.
The draft retains template, answers, NPC-name outcomes and first-selection reward
outcomes by template/question/answer/effect. Inactive outcomes remain cached.
Switching back restores them. Validation and repaint never resolve new rewards.

Evaluation rebuilds additive skill/social/faction adjustments and ordered reward
obligations from current answers. Poison/disease/magic/fatigue/reaction/avoid-hit
biography modifiers use last assignment in question/effect order, as in DFU;
they are not universally additive. Class/racial adjustments remain separate.
Faction obligations bind actual resolved DATA identities/winners through the
existing faction index's narrow point projection. Missing or ambiguous targets
fail preparation; no live standing service or grant is created. The complete
faction/quest graph is not copied for each target lookup.
FT retains the assigned field; the pinned DFU inspection found no active fatigue
formula consumer beyond storage. No total-fatigue change is invented here.
Gold intent uses ordered signed additions with a zero floor: an explicit routine
correction of DFU's subtraction of a negative GP amount. Later entry applies it
in order, before grants, rather than summing away intermediate floors.

**AE/AF user decision, 2026-11-26:** “Go by what DFU says in this case, please.”
Adopt DFU's no-effect behavior. Preserve all 122 installed declarations, selectors,
operands and source/answer identities as non-executing intent metadata. Do not
infer allies, enemies, reputation or combat effects. This exception does not
permit unknown required commands, including AO, to execute or disappear.

Known effects are disclosed before selection. Exact randomized book identity,
cover, armor variant and arrow quantity remain hidden in creation, including
summary. Reward intent retains the selected stable item definition/winner,
material conversion, quantity, variant and applicable book source/price. No UID
or possession is allocated. Book price uses the existing local classic generator,
seeded with the book's first four bytes, with resolved baseline bounds 300..800,
matching DFU BookFile. It does not touch a session RNG. Armor/arrow choices use
the declared replaceable reward ranges. Each outcome retains its original
generator receipt and before/after logical/raw counts.

`biography_evaluator.gd` expands first/second/third narrative channels (`%qN`,
`%qNa`, `%qNb`), retained NPC names, race/home/terrain and reputation macros using
draft context only. Unknown macros, unavailable required text and bounded
recursion fail. No live race/name mutation or global RNG reseed is available.
History is a pure current projection, not a second stale mutable text field.
Fresh validation receipts capture `resolved_history` as a complete readable
string. A birth-race revision can therefore update history without new names or
reward draws. Final intent retains that exact string and provenance; later
history/SAVE consumers must restore it rather than regenerate from changed data.

## Starting state and operation boundary

UI requests `operate(owner, token, operation)` for initial attributes/skills,
attribute reroll and Save/Load Roll. The owner-generated pending capability seals
baseline, original pools, RNG receipt, context and slot. Ordinary/alternate input
may propose allocations only. Validation compares immutable generated fields to
the actual retained state, then recomputes budgets/bounds from values. A forged
baseline, pool, slot or generation receipt cannot be accepted by a widget.

Eight independent inclusive uniform attribute bonuses and a separate pool draw
replace the entire current attribute state on deliberate reroll. Save replaces
one complete transient snapshot, including partial allocation, generation and
context; reroll preserves it. Load restores the whole compatible snapshot without
draws or merging. Incompatible Load fails and preserves current values/slot.

Each stable skill ID receives one independent inclusive draw from its tier or
other range. Separate pools refund to their own tier; other skills cannot spend
them. No skill reroll or Save/Load exists. Biography revisions and attribute
rerolls retain skill baselines and allocations. Final preview is baseline plus
allocation plus biography. Invalid revised contexts stay visibly invalid; they
are not clamped, redrawn or granted advancement.

Both stages require complete allocation, authoritative budgets and final domains.
All seven attribute-derived previews invoke the actual published formula hooks
through a CORE-scoped, read-only CHAR draft operation. They use current class
magery and exclude later effects. An unavailable/failed preview blocks attribute
completion. No default formula or truthful-looking zero is substituted.

`starting_rolls.gd` proves worst-case attribute capacity before generating.
`biography_feasibility.gd` proves feasibility across all independent question
choices and skill rolls. For required lower-bound spending it uses
`sum(max(0,x_i)) = max_S sum(x_i for i in S)`; each question's minimum sum for
that subset is independent. Fixed 3/3/6 tiers require at most 64 subsets. Upper
capacity uses each question's maximum tier sum. This accounts for correlated
effects within an answer without a pessimistic per-skill interval rejection or
an exponential question Cartesian product. No favorable sampling is substituted.

## RNG, navigation and capture

Each deliberate generation operation uses independent 32-byte OS material with
the already reviewed `rpg-rng-v1/progression` derivation, `pcg32-xsh-rr-v1` and
bounded uniform mapping. A trusted fixture Callable controls material. There is
no clock/default-seed fallback and no gameplay stream acquisition/reseed/advance.
Provenance includes operation, material hash and logical/raw counts. Template and
answer sampling is ordinary uniform choice, not the class questionnaire's
separately approved collision-advance rule, which remains unchanged.

Structural invalidation is refined by feature compatibility: biography method
changes keep existing biography facts. Substantive career changes invalidate
active dependent facts, while section-owned caches retain each compatible
context. Revisiting an earlier context restores its template/rewards/rolls and
allocations without draws. Numeric compatibility uses actual class bases/tiers,
resolved rules and permanent domains/content ticket, not object/display identity.
The single attribute slot travels separately and can truthfully be incompatible.
Restart/exit discard all state/caches/slot and retire callbacks immediately.

Stock biography, attribute and skill controls use fresh tokens, generation guards
and the existing held-key/window handoff protection. Summary editors remain the
approved five; biography operations cannot bypass Restart through raw stock
actions. Repeated confirmation/capture/retry retain the same resolved intent.

Each selected biography effect has a captured obligation identity and
`represented_in_candidate` marker. Skills are displayed with biography included,
while the accepted rolled/allocated baseline excludes it. IMP-036 must commit
that baseline, apply selected biography once, then capture progression baseline
before later grants. Noncurrent cached outcomes do not enter obligations.
No actor, possession, spell membership, faction standing, quest, placement,
cinematic or native SAVE is created by this increment.

## Review and remaining integration

Native allocation pages display owner-evaluated totals. Positive player-assigned
allocations are green; their remaining pools and limits remain policy-owned.
Accepted navigation initializes missing rolls; render and repaint do not draw.
Successful initial attribute rolls and rerolls play replaceable overlapping dice
one-shots. Both allocation screens support 150-ms held arrows with fresh owner
contexts per tick and gesture retirement checks. Overview uses the same permitted
summary editors for inline allocation, identity and reflex changes. Redistributing
points temporarily makes capture invalid until all pools are complete again.

The biography method chooser starts automatic generation or initializes manual
questions directly. The native BIOG00I0 screen advances after each answer across
twelve questions, retaining normal owner requests and cached outcomes. Completion
shows a parchment reputation summary before Name. Higher/Lower/Unchanged comes
from the accepted biography intent's social additions, not starting class standing.
Dismissal (including Escape) advances to Name; Previous/Next question and history
remain available for review. Native Name and face OK controls advance through
normal validation; Random, answers and deliberate confirmations play UI feedback.

Creation navigation stays above the classic art panel. Escape from biography
returns to method selection with answers/outcomes retained; one held press cannot
fall through into global Pause or discard. Interactive review uses stock English;
the automated suite alone installs the French/CJK wrapping/font-recovery fixture.

`creation_biography_review_inputs.gd` assigns only name, portrait and reflexes.
Biography, affinity, rewards, rolls and allocations use production providers.
`tools/review_creation_biography.ps1` rebuilds and runs the labelled review;
normal New Game never borrows its assigned later providers. Comprehensive polish,
physical controller/IME results, completed history display/SAVE compatibility,
runtime modifier/standing/grant consumers, IMP-036 and M2/M3 stay explicitly open.

Navigation correction: Back from Name skips the biography question step when the selected method is automatic, returning to the method chooser without discarding generated outcomes. Manual biography still returns to its question page. This is handled in shared creation navigation so button and Escape paths agree.
