# Session shell interfaces

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
Actual Windows language/IME qualification remains open.

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
