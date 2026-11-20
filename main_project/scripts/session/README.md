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
