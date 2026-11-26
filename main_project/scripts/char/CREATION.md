**User acceptance, 2026-11-26:** "Good work, I accept what you have done in increment 2". Increment 2 is accepted. Individual numbered human-test outcomes were not reported and are not inferred. Later increments, parent IMP-015 and integration/milestone gates remain open. Earlier pending-acceptance wording below is historical.

# Creation draft and navigation — IMP-015

**Increment 2 implementation, 2026-11-26:** Production race/gender, presets,
questionnaire and custom careers now extend this contract. See the
[race/career contract](CREATION_CAREER.md) for publication, source qualification,
deliberate retained generation, real stock controls and remaining gates.
Increment-1-only unavailability statements below are historical where superseded.
Human results/acceptance of increment 2 remain separate.

`SessionLifecycle.creation` is the composed runtime CHAR draft authority. It is
separate from `actors`, persistent saves, Control instances and UI navigation.
The stock shell opens `creation_view.gd` from New Game. The view uses
`creation_navigation.gd`; each edit/navigation callback carries the exact draft
identity, integer revision, content ticket, step and UI generation. Rebuilding
controls does not create a draft. Restart and exit discard immediately, without
confirmation. Re-entry allocates a new identity. There is no draft persistence.

## Owner requests

`bind(content, bindings)` is permitted only outside a draft and provider callback.
Each binding names an actual trusted callable, separately from any translated
label or content-authored readiness claim. No package script loader is added.
`edit(section, token, exact_value)` validates a detached candidate and publishes
atomically. Rejected edits preserve every prior fact/revision. Identical exact
typed edits are no-ops. Numbers in draft facts are integers; booleans, fractions
and floats cannot stand in for numeric allocation values. Bounded plain-data
checks reject runtime objects and recursively excessive inputs.

The synchronous provider contract is `creation-validation-v1`: section, detached
candidate draft and retained caches. A successful receipt contains exactly `ok`,
`value`, `retained`, `invalidate`, `provenance`, `semantic_ready`, `errors`.
Providers own actual choice legality, compatibility, numeric bounds, candidate
evaluation and dependent invalidation. They must not mutate live owners, yield,
or draw during validation/navigation. Deliberate owner generation belongs to
later increments; this increment has no reroll or implicit generation action.
Provider results are checked after callback return against the original token.
Retirement during a callback makes its result stale, including when discarding
from inside the callback. Unavailable/malformed provider results fail explicitly.

`section_status` revalidates the existing exact facts and retained cache; it
cannot replace them with a newly generated answer. `capture` revalidates every
required section and requires semantic readiness and no section errors. Captured
`creation-submission-v1` has one stable submission identity, complete draft facts,
validation/provider/content provenance and the completed UI route receipt.
Detached copies canonicalize StringName keys without lossy JSON numeric coercion.

`submit` seals one capture per draft before invoking real CORE `request(new)`.
CORE retains exact origin/intent and owns admission, busy handling, preflight,
living-session consent, cancellation, teardown, recovery and readiness. Duplicate
submissions return that same request's outcome; changed captures cannot reuse its
identity. Different later draft revisions cannot create another admitted intent.
Explicit `retry` requires the previous request's terminal Failed result, the same
original scope and the same captured values. It creates a distinct attempt ID;
it does not regenerate facts. Cancelled operations are not silently retried.
Unsubmitted captures retire with their draft. Submitted context is retained for
safe explanation/retry and disposed with CORE; this is not a resumable saved draft.

## Dependency and invalidation fixture

The real structural provider does not pretend to qualify missing mechanics.
These are the increment-1 assigned-provider expectations, with owner hooks for
later real compatibility rules:

| Deliberate change | Invalidate selected facts/validation | Retain |
| --- | --- | --- |
| Identical typed value | Nothing; revision unchanged | Entire draft |
| Race or gender | Incompatible face | Class, name, biography outcomes, allocations |
| Class method | Questionnaire, preset/custom selection, biography, attributes, skills | Race/gender, name, face, reflexes; retained outcome caches |
| Preset/custom career | Biography, attributes and skills in the old career context | Unrelated identity; retained outcomes for their original context |
| Biography method | Active biography selection | Existing generated/candidate outcome cache; attribute/skill facts |
| Biography answer | Provider recomputes current candidate facts; no new baseline roll | Previously resolved answer outcomes, attribute/skill rolls and allocations |
| Name, face, attributes, skills, reflexes | Only explicitly returned owner dependents | Other compatible facts |
| Back/Next/summary revisit | No facts or random outcomes | Entire draft |
| Restart/exit | Entire draft, candidates, allocations, route state and callbacks | Only separately submitted CORE input, when applicable |

The fixture declares one preset and one custom route in `creation_fixture.json`,
explicit biography answers/outcomes, assigned baselines and allocations. It
qualifies interfaces, not original distributions, custom legality, full tier
mechanics, biography execution, actor intake or gameplay entry. No fabricated
`captured-actor-v1`, skills-finalized receipt or starting grants are produced.

## UI and locked content

DATA publishes `char.creation:flows#stock` (`creation-flow-v1`) through its normal
shipped → ordered package → captured loose pipeline. Supported declarations have
stable step IDs, owner hooks, titles, optional art targets, choices and six
class/biography branch combinations. IDs are independent of labels and list order.
Routes validate required sections, supported hooks, unique steps/no cycles,
prerequisites and terminal summary before publication. Invalid contributions
cannot partially activate. Mods can reorder independent sections, replace step
IDs/titles/art and choose supported branch declarations while preserving owner
prerequisites. Required unsupported executable hooks fail; new scripted behavior
requires its actual qualified owner. Exit/Restart remain stock navigation actions
and cannot be removed by route data. Runtime editing never unlocks DATA/MOD.

`title` and choice `label` fields are literal localization fallbacks, not a second
text authority. Existing stock titles/actions resolve through collection
`creation`, keys `step.<step-id>` and `action.<action-id>`; optional choice keys
are `choice.<hook>.<choice-id>`. Replace existing localized text through the
ordinary text CSV adapter. New step IDs without a catalog entry use their declared
fallback. Presentation changes never change selection identity or validation.

Summary direct editors are exactly name, face, attributes, skills and reflexes.
Other changes require Restart. There is one Begin Game on terminal summary, no
separate progress indicator, and no upstream warning/correction workflow.
After reaching summary, sequential Back can inspect earlier upstream sections,
but their selection controls remain read-only until Restart. Repeated Back is
not an indirect upstream-edit bypass. This UI permission never confers CHAR
semantic validation; the owner independently derives all required branch facts.
The window stack retains its requester-scoped hold and input boundary on page
handoff. Old rendered controls are generation checked. Keyboard echo does not
repeat navigation; ordinary controller mappings/fresh-press routing are reused.
Focus is retained by action identity and deferred only for current live controls.

The stock `creation_inputs.gd` now qualifies real race/gender, preset/questionnaire
and custom-career semantics against locked DATA. Structural reader profiles stay
`semantic_ready:false`. Missing later providers explain their unavailable mechanics
and retain Back/Restart/Exit. Full name/face/reflex, biography, starting rolls and
allocations remain increments 3–4. The stock session provider rejects fresh entry.
The increment-2 review combines real race/career with explicitly assigned later
providers on these same CHAR/UI/CORE paths; normal New Game never borrows them.

## Optional original interface art

`av/creation_art.gd` registers ten logical image targets in the existing media
resolver before content preparation. DATA's active classic source supplies the
bounded read-only `creation_image` interface. It opens only the declared interface
filenames; no wildcard paths, world-texture substitution or copied source assets.
Optional absence/decoding failure uses a readable UI fallback and cannot block
startup. An invalid selected replacement remains an explicit resolver failure;
it never silently selects an unrelated classic image.

| Target | Classic image | Palette |
| --- | --- | --- |
| creation.race | TMAP00I0.IMG | MAP.PAL, six-bit components |
| creation.questionnaire | CHGN00I0.IMG | Embedded six-bit RGB |
| creation.custom | CUST00I0.IMG | ART_PAL.COL |
| creation.dagger | CUST08I0.IMG | ART_PAL.COL, transparent index zero |
| creation.name | CHAR00I0.IMG | ART_PAL.COL |
| creation.face | CHAR01I0.IMG | ART_PAL.COL |
| creation.attributes | CHAR02I0.IMG | ART_PAL.COL |
| creation.skills | CHAR03I0.IMG | ART_PAL.COL |
| creation.summary | CHAR04I0.IMG | ART_PAL.COL |
| creation.reflexes | CHAR05I0.IMG | ART_PAL.COL |

Mapping evidence: pinned DFU `CreateChar*.cs` constants and `API/ImgFile.cs`
`PaletteName`; `classic_image.gd` owns actual decoding. UI backgrounds are opaque
(`alpha_index:-1`), top-left indexed imagery, nearest sampled at 2× native
320×200 coordinates. Controls remain real Godot controls. Native OK/name regions
are used where practical; readable overlays cover incompatible baked English
instructions. Rich later editors are deliberately unavailable rather than painted
over with invented mechanics. Increment 2 qualifies the province picker and
first-frame appearance mappings; the full portrait selector remains later.
Gender/class/biography method dialogs have accessible untextured
panels. The user requested close classic layout where practical on 2026-11-26.

Selection follows existing media package/loose precedence and run locking. The
application cache retains one resolved texture (or failure) per target, with
provenance and bounded diagnostics; revisits do not decode/create again. Disposal
releases caches and source references. Original art remains Bethesda classic game
data under the user's external installation, not DFU MIT artwork. No original
asset bytes are committed. DFU source is MIT evidence only; no source code copied.

Remaining joint gates: full mechanics/presentation increments, IMP-036 once-only
grants/placement/opening content, creation cinematics, native SAVE, named real
TIME/MOVE/CHAR integration and M2/M3. Controlled qualification and human review do
not close any of them or self-accept IMP-015.
