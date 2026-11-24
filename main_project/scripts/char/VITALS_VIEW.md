# UI-006 vitals and disclosed effects

The normal shell composes `vitals_view.gd`. CHAR supplies the detached narrow
`presentation_projection(session,actor)` containing coherent current/max pools,
units and owner breath visibility; it does not copy receipts, sources or the
whole actor record. A mode provider declares `player_actor` on CHAR's existing
service binding. A view may explicitly bind another current actor for controlled
qualification. Retirement clears its model, controls and opening state.

Health/fatigue/magicka remain visible at full capacity. Zero maximum renders
empty without division. Exact authoritative values are shown in status, including
fatigue's internal-64 units; UI does not round or convert gameplay state. Breath
shows at zero while holding and during owner-reported partial gradual recovery.
Uninitialized/instant inactive breath is hidden. No display clock consumes or
refills reserve, estimates drowning or changes an activity.

## MAGIC-010 disclosure boundary

A ready MAGIC service declares `disclosed_effects:true`. Its methods are
`disclosed_effects_revision(session,actor)` and `disclosed_effects(session,actor)`.
The latter returns the complete detached `disclosed-effects-v1` model:

```
{schema, revision, groups:[
  {id, label, icon, compact, components:[
    {id, label, lifetime, effective, suppressed, warning}
  ]}
]}
```

Revision is strict integer 0..1e9; labels/lifetime descriptions are bounded
strings; state flags are strict booleans. Group and component identities are
unique in their scopes. Model bounds are 4,096 groups/256 components per group,
not caps on active gameplay effects. Unsupported display state is unavailable;
UI never deletes effects to fit. Hidden contributions/groups must be omitted by
the owning disclosure projection, including labels/counts/warnings. The controlled
provider intentionally owns a hidden record that never crosses this interface.
No real MAGIC runtime is inferred from that fixture.

Only an effective, nonsuppressed warned component earns the steady `!` marker.
Warned groups get first slots. Within tiers, existing order is retained; new
identities sort deterministically. Compact-eligible omitted groups count toward
reachable `+N` overflow. Details include all disclosed groups/components with
owner lifetime/suppression descriptions; the UI never infers expiry from a local
timer or treats a mixed group as having one universal countdown.

Missing cosmetic artwork uses a generic diamond. Supported bundled texture
paths can supply a Texture2D icon; loading is restricted to image extensions.
Registered image targets also resolve through the real locked MEDIA replacement
owner. Unavailable/malformed disclosure is explicitly marked unavailable, not
reported as a ready empty effect set.
Unknown source labels remain exactly what the disclosure owner supplied.
Unchanged revisions avoid repeated full effect snapshots and group/control
reconstruction, including ordinary pool updates. Changed snapshots are
validated and copied only on publication to the view; public model queries detach.

## Customization and interaction

`actor.baseline:vitals#player` is a locked checked DATA definition, with shipped,
resolved MOD and captured-loose precedence. Its `vitals-view-v1` schema supplies
the supported complete data-defined view replacement (`stock-bars` or `numbers`),
four named targets (`health`, `fatigue`, `magicka`, `breath`), row order, labels,
per-target bar/numbers format, visibility, height 8..64, finite RGBA colour
components 0..1, left/right anchoring, width
220..600 reference pixels, compact capacity 1..32 and effect-row visibility.
The common `details` action always remains available. Whole record replacement
resolves before targeted top-level patches through the existing DATA adapter;
missing/duplicate/unknown targets and unsupported view kinds reject before menu.
No executable package loader or general UI expression system is added.

Default is red/green/blue bars, conditional cyan breath, left anchor, width 280
and eight compact effects. These are project-authored visual defaults. Numeric
replacement and targeted edits cannot change the owner projections or disclosure.
Advanced arbitrary executable scene factories/shapes are not qualified
by these two supported data-defined templates.

Status and effect buttons use the real window stack's `vitals_details` opening,
pause/no-UI-pause policy, input context and close routing. The existing Status
shortcut reaches the same view. Covered HUD controls are inactive. Inspecting,
closing, hiding/revealing, resizing or rebuilding controls produces no gameplay
request, RNG draw, duration advancement or application notice. Detail opening is
transient and not serialized. Independent HUD hide reasons cannot strand the
already-open inspection window. Exact values/overflow remain reachable there.

HUD placement uses actual viewport coordinates and adapts to measured row height.
Details scroll/reflow in the available area with a contrasting background and
focusable stock Close action. Theme scaling changes text/control hit regions
together. Compact capacity is an upper bound: measured available space reserves
overflow access, and a crowded view moves the count to the reachable details
action. Exact detail labels wrap and scroll, including long modded labels.
Rendered qualification includes actual framebuffer sampling, since a
Control's `visible` property alone does not establish that it paints on screen.

Gameplay effect restoration, actual equipment/career sources, native SAVE and
real breath consumption/drowning remain with their named owners. This view does
not make those unavailable integrations ready.
