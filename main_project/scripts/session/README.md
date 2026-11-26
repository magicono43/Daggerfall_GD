# Session shell interfaces

IMP-012 increment 3 extends the existing ground consumer to resolved Jump,
air/landing RULE hooks and an explicit MOVE health-damage consumer. It uses the
same body, CORE gates, CHAR and camera projection. See [AIR.md](../move/AIR.md).
No second controller, native SAVE or platform-carriage entry is introduced.

IMP-016 increment 4 adds scoped prevention-directory and disclosed-effect
bindings, CHAR's checked actor/event death confirmation, the real
[vitals/effects view](../char/VITALS_VIEW.md) and an independent
[death observer/return](../char/DEATH.md). A provider's CHAR service may declare
`player_actor` for the stock HUD. Initial presentation never decides death.
The stock session provider invokes the shell's real classic video consumer for
ANIM0012.VID from the selected published root through an optional read, without
adding a startup requirement; missing/failed playback remains classified Failed
bypass. No ordinary death-state SAVE or complete IMP-035 readiness is implied.

IMP-016 increment 3 adds requester-scoped `actor_activity:{id,roles}` service
declarations. CORE validates actual ready session Objects and allowed owner
domains, with weak bindings retired alongside vital/formula bindings. The
[CHAR activity contract](../char/ACTIVITY.md) defines exact role methods and
continuation receipts. No binding certifies delivered locomotion/TIME/NPC/death.
Forced advancement excludes only the requesting actor's CHAR simulation hold;
independent suspension holds still block it. No other token can be released.

`SessionShell.new(host,material_provider=Callable())` forwards the existing CORE
fixture material seam while constructing exactly one lifecycle. Ordinary launch
retains OS entropy. Validated actor-suite fixture modes supply a labelled 32-byte
zero material vector to the real session RNG; no player seed preference, new
stream or alternate random implementation is added.

IMP-016 increment 2 adds explicit session `vital_intake` consumer declarations.
CORE binds actual COMBAT/MAGIC/ITEM/CHAR providers and stable scope-local consumer
handles at readiness; arbitrary request labels or observers confer no authority.
Bindings retire with the session and remain distinct from pure formula bindings.
CHAR owns current pools and retained results, with requester-scoped input,
simulation and save holds for unresolved zero/fatigue outcomes. Lethal intake is
currently unavailable and rejected unchanged. See [vital intake](../char/VITAL_INTAKE.md).

IMP-016 increment 1 composes `core.actors`, the [CHAR baseline authority](../char/README.md),
using the same application's DATA/formula registries. CORE admits its pure actor
helpers under the exact safe baseline/initialization ticket before full readiness.
Ready session consumers retain ordinary declared hook admission. This exception
grants no RNG, gameplay entry, SAVE eligibility or release of other owners' holds.
Source/formula callbacks recheck original session/operation/content before CHAR
publication. Stock creation/restore handlers remain unavailable. CHAR's owner
record reconstruction is an in-memory quiescent interface, not Session Restored.
MOVE retains its sole body/shape/physical-pose authority.

IMP-013 increment 3 composes the [MOVE placement owner](../move/PLACEMENT.md)
beside the single LOC assembly owner. `require_placement` retains an exact LOC
ticket on the current CORE operation; successful readiness checks require the
corresponding currently valid committed physical pose. The operation hold now
also restricts save eligibility. MOVE cannot complete CORE or release another
requester's holds. Stock unavailable gameplay providers remain unavailable.

IMP-011 increment 3 adds the [production view/cursor owner](../input/VIEW_CURSOR.md).
SessionShell composes its current Camera3D, consumes Center/Toggle edges and
attaches input/view to the same effective controls map. Startup admits mouse motion
after engine GUI refusal and advances view once per presentation update. Only the
scoped view owner writes gameplay mouse mode; windows/focus/readiness provide its
eligibility and cursor policy. Facing capture/restore and checked rays are provider
interfaces, not a native SAVE/activation/COMBAT implementation.

IMP-011 increment 1 composes [logical action delivery](../input/README.md) through
these same CORE gates and UI context generations. Reserved recovery remains a
separate UI route; gameplay edges/cancellation never grant simulation eligibility
or clear another requester's hold. Real gameplay consumers remain later gates.

IMP-007 increment 3 supplies [application font/locale presentation](../data/LOCALE_FONTS.md).
The real prompt can bind stable `text_ref` / response-keyed `label_refs` to DATA
lookups. It stages matching text/font/metrics and updates active controls in place,
preserving input composition ownership, focus, caret, draft, variant/answer and
window/session/operation identity. Stale/covered/retired plans and active IME
composition reject a switch. Refresh never submits responses or invokes gameplay.
The stock shell exposes live language Apply/Cancel and persistence retry; English
is the only offered language and synthetic `zz-Test` remains test-only.

The existing startup scene owns `SessionShell`, `SessionLifecycle` and
`SessionWindowStack`. Storage/settings/logging remain application-owned by the
existing startup controller. CORE projects checked startup routing and requires
checked main-menu readiness before new session admission.

## Mode providers

`session_provider.gd` declares the normal checked boundary. Its stock character
and restore handlers explicitly report unavailable; fixtures select controlled
providers only in isolated tests. Actual providers use the same interfaces.

- `request({id, mode, origin, selection})` captures value-only stable selection
  identity/revision. Same-ID delivery observes the retained operation/result;
  changed intent under the same ID is invalid. Intentional retry uses a fresh ID.
- Providers receive `{id, generation, scope}`. Return `{ok, reason}` or
  `{pending: true}`; pending work completes through matching `complete_preflight`,
  `complete_baseline`, `complete_readiness`, `complete_presentation` or
  `complete_menu`. Retain the issued ticket, never fetch a new ticket for old work.
- Preparation validates actual selected data before discard consent/replacement.
  `cancel_preparation` retires preparation resources; late callbacks stay invalid.
- `initialize_baseline` initializes domain owners in dependency-safe order.
  `initialize` then performs placement/grants/restoration/UI readiness. Both
  declare checked services: role, owner, lifetime, requiredness, initialized
  provider, dependencies, and an approved optional fallback if applicable.
  Missing required owners must not be omitted to pass validation. Readiness can
  bind CHAR's explicit `death_authority`; animation callbacks are not authority.
- `cleanup(ticket, scope)` stops/cancels work, disconnects subscriptions, then
  releases only owned resources. Empty scope owns no gameplay resources. It must
  be safe to retry partial cleanup without double disposal. Complete asynchronous
  cleanup through `complete_cleanup` using its additional `cleanup_generation`.
  Failed cleanup blocks admission independently of the single terminal result.
- Report unexpected required loss with `required_service_lost`. Death presentation
  releases its independent resources before completion. Missing/failed playback
  bypasses silently. A failed menu retry cannot replay completed presentation.

CORE alone writes lifecycle readiness/safety/session fields. `snapshot()` is a
read-only projection. Other owners request their own gate tokens and release only
those tokens. Empty scope is application lifetime; session retirement removes
only the retired scope. Simulation, input, presentation and HUD hides are separate.
Actual AV suspension, location rebindings and SAVE work safe points require their
real owner integrations; no scene-name discovery or generic domain reset exists.

## Windows, input and clocks

Stock layer IDs: `pause`, `settings`, `discard_settings`, `message`, `prompt`.
Title and recovery/shutdown remain independent shell destinations. Opening data
belongs to the opening scope. `top`/`layers` return copies; `update_data` changes
only the matching active draft. `open`, `close`, `replace`, `return_to_game`,
`respond` and `complete_response` report explicit applied/busy/stale/blocked or
owner outcomes. Pending responses carry original layer/context generation. There
is no command queue to overflow. Replacement preparation must succeed before
handoff; full provider/mod composition and action-hook validation remain IMP-051.

`capture`/`dispatch` retain brief edges, suppress held repeats, consume handoff
input, apply fixed shortcut priority and remove simultaneous quicksave/quickload.
Only stock Escape/options and Godot UI navigation are connected here. Real
gameplay bindings, owner delivery, cursor capture and device policy join IMP-011.
Prompt text uses Godot LineEdit composition ownership and a submission guard.
The user reported a physical Microsoft Japanese IME PASS on 2026-11-22 using
`91f6898 / m1-ime-review-v1`: candidate/hiragana Enter commits without submitting,
separate Enter submits once, Escape resolves composition before prompt cancel,
and Backspace/focus switching cause no unintended response. English text and
glyph/candidate display also passed. This qualifies the tested local configuration
and stock application-scoped prompt; other IMEs/Windows configurations and later
gameplay input-provider integrations remain unqualified. See
[M1 follow-up evidence](../../../design_docs/development/evidence/M1-ACCEPTANCE-FOLLOWUP-91f6898-2026-11-22.md).

Cadence requires explicit session-fixed interval, dependency-ordered checked
consumers and a positive budget counted in consumer deliveries. Only eligible
simulation delta seconds accumulate. Fraction/backlog and partial-step position
survive pause; failure does not blindly retry partially mutating work. No default
frequency, RNG ordering, save-phase or prolonged-overload policy is selected.
The 0.1-second/two-delivery test configuration is fixture data, not game tuning.

On application exit call `SessionShell.dispose()` to disconnect owned callbacks;
normal session retirement disposes its UI scopes earlier. See the
[execution evidence](../../../design_docs/development/evidence/IMP-002-2026-11-19.md)
for verified outcomes and all remaining owner integrations.

## RULE session sources — IMP-006 increment 2

CORE now owns the `randomness` participant for each lifecycle instance. New/load
preflight prepares independent candidates; successful readiness activates them
before ready/restored publication. Cancellation/failure discards candidates,
retirement revokes outgoing capabilities and disposal clears all remaining state.
See the [RULE interface](../rule/README.md#session-lifetime--imp-006-increment-2)
for ordering, errors and owner responsibilities.

Readiness service declarations may add `random_purposes: ["combat", ...]` for
explicit ready session-lifetime consumers. The existing binding validator still
runs first. RULE then validates these declarations before activation; malformed,
duplicate/unknown or location-scoped purpose bindings reject readiness and use
normal incomplete-session cleanup. Empty declarations retain no draw authority.
The owner calls `core.randomness.source(current_scope, self, purpose)`; every
returned handle is checked again per draw. Session or operation tickets cannot
be replaced by a fresh ticket when completing stale work.

The optional `SessionLifecycle.new(material_provider)` seam is trusted fixture
construction only. The default is the existing OS entropy implementation. The
factory takes a copied preparation ticket and new/load mode and returns the
checked material result. Reentrant cancellation invalidates preparation before
its result can publish. Ordinary session request intents do not accept raw source
Objects or material byte arrays, preserving the existing plain-value boundary.

The source handle is not an attempt authorization or consequence coordinator.
Owners retain results/application flags under their own contracts; technical
redelivery reuses them. Controlled `retained-owner-v1` tests are not CHAR/WORLD
or native SAVE support. The stock provider still rejects unavailable real entry
and restore. Formula hooks/executable providers remain outside this increment.

## Formula consumer bindings — IMP-006 increment 3

`SessionShell` binds `core.formulas` to the application registry owned by the normal
startup provider. Ready session services may declare `formula_hooks` and must
implement a pure `formula_operation_current(Dictionary) -> bool` owner predicate.
CORE validates published-hook availability and actual consumer identity, retains
weak bindings and clears them at retirement. Formula admission also requires
current scope, ready/safe state and no lifecycle busy/publication/finishing phase.
Application registry identity is distinct from session and owner operation IDs.

The invoker rechecks context after its one synchronous pure-integer callback.
Callback errors, invalid results and context invalidation stop the affected
operation and use existing CORE service-loss recovery; they cannot select another
provider. The registry remains locked through return/new/load. Owner predicates
and operation retention remain trusted owner contracts, not a universal action
system. See [the formula contract](../rule/FORMULA_DISPATCH.md).

## IMP-007 increment 4

[Mod preferences](../mod/PREFERENCES.md) have application lifetime. SessionShell
binds the application owner to CORE; successful new/load readiness activates only
eligible next-session groups using the original lifecycle ticket, before ready
publication. Failure uses ordinary incomplete-session cleanup. Character restore
cannot replace the application store. Location authority remains an explicit
future provider boundary with controlled verification here. Recreated consumers
receive effective values while deferred saved requests remain pending.

The two bounded editors open ordinary window-stack layers with requester-owned
gates. Preference locale plans retain their binding-time window context; Escape
closes the editor before routing to underlying navigation. Font/label refresh keeps
controls/draft/focus/confirmation stable. No owner answer, choice, RNG draw or
session/location replacement is created by preview/presentation.


## Binding controls - IMP-011 increment 2

The stock title menu and Pause > Settings route expose Controls. Its application
owner supplies a private draft; closing discards that draft, while Apply leaves
accepted controls effective even when persistence fails. The controls window owns
its normal CORE input/simulation holds. Capture consumes events before GUI input;
closing, focus loss and reconfiguration retain the existing physical fresh-press
quarantine and cancellation semantics. Escape/Start recovery is independent of
editable controller Confirm/Back. UI actions use a compiled configuration index;
ordinary navigation remains available while gameplay is gated. Disposal detaches
the input consumer and breaks editor/owner references. No character snapshot can
replace the application controls. See [input](../input/README.md) and
[settings](../startup/README.md) for the request/result and recovery contracts.
# IMP-014 calendar integration

CORE now composes the [TIME calendar owner](../time/README.md), validates its load
payload during preflight and initializes its exact origin before dependent
baseline providers. The stock physics handler accounts one eligible calendar
interval through CORE, separately from MOVE/CHAR proofs and slow cadence. CORE
intended rate and DATA calendar rate apply once each at their own boundaries.
Disposal clears the provider/death-authority references as well as subscriptions.
Controlled entry/activity checks do not qualify real rest, scheduling or native SAVE.
