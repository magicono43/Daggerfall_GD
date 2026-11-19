# TIME-006 — Weather transitions and interior context

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-15 with “I approve”. See TIME-006-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Make weather changes feel continuous during exploration and keep enclosed spaces visually coherent. A player leaving shelter encounters the current outdoor conditions. Modded interiors can convey outdoor weather through roof sounds, thunder, window views or localized exposure where their authored setup supports it.

## Confirmed requirements

[TIME-006-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm local interior presentation, practical mod opt-ins for exterior cues, moddable live blends, destination setup before reveal, and committed gameplay state independent of presentation timing.

## Daggerfall Unity reference

In the local DFU 1.1.1 Release snapshot, `Assets/Scripts/Game/WeatherManager.cs#SetWeather` clears current effects, applies the new weather's settings, raises its callback, then assigns `PlayerWeather.WeatherType`. `SetFog` tracks outdoor settings separately. Transition handlers apply building or dungeon fog and restore outdoor fog on exit. `SaveLoadManager_OnLoad` first applies saved outdoor weather and then applies the applicable interior fog. `Assets/Scripts/Game/PlayerWeather.cs#SetWeather` disables local rain and snow particles indoors. Cloudy skybox changes and smoother transitions are marked as TODOs. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Detailed rules and behavior

- TIME-005 supplies the committed outdoor weather and its validity interval. Resolve it against the committed location and exposure context, such as outdoor, enclosed building, enclosed dungeon, or authored partially exposed area. Track the outdoor selection independently from the effective local presentation. A covered doorway uses MOVE-026's zero calendar cost. Weather selection can still advance while indoors when committed calendar time passes.
- An enclosed space uses its local fog, lighting and ambience. Suppress outdoor precipitation and direct outdoor weather audio in the enclosed area by default. A roof rain loop, exterior thunder or window view is an explicit opt-in. On exit, derive the target from current weather and the ready destination. A transition does not reroll weather.
- Provide data-driven mod extension points for weather-driven audio and exterior views. Authored audio profiles can use the current weather and local placement or exposure to drive effects such as muffled thunder or rain hitting a roof. Authored window or portal views can use the current exterior weather profile and a compatible exterior representation. Open-roof or exposed zones may enable local outdoor effects within their authored bounds. Hearing or seeing outdoor weather does not by itself designate the player as exposed for gameplay.
- AV and LOC own implementation and asset requirements for exterior views. The mod contract supports authored placements and compatible view providers where practical. Existing interior layouts may require new window geometry, exterior context or other authored assets. When an optional exterior cue cannot be built, retain the valid interior presentation and report the missing dependency through the applicable content diagnostics.
- Live outdoor changes and seamless climate crossings blend to the new visual and audio targets using short moddable durations. Zero duration means immediate application. Blend from the currently presented state when retargeting. Retire obsolete emitters and loops when no longer needed. A renewed selection with the same effective target does not restart a blend solely because its validity interval changed.
- For covered transitions, fast travel and native load, establish the destination presentation while covered and reveal when required context and presentation are ready. Initialize the target directly with no replay of skipped weather or the prior scene's blend. Apply effective local context as a coherent update so outdoor precipitation or fog does not flash inside a newly revealed room.
- Publish committed weather and context together before notifying dependent systems. Consumers observing a change can read the matching committed snapshot. Rendered fog density, particles, audio gain and blend progress are presentation values. Gameplay timing, visibility and exposure use explicit approved owner inputs. Visual settings and optional asset availability do not change them.

## Parameters, configuration and required data

Inputs include committed session and location identity, selected weather ID and profile, validated local environment and exposure context, destination readiness, and any authored cue definitions. Profiles can provide visual and audio targets and finite nonnegative blend durations under DATA-003. Each continuous channel can use normalized progress `clamp(elapsed / duration, 0, 1)` on its presentation clock. AV chooses appropriate interpolation and crossfades for individual channels. Exact stock durations and curves remain tuning dependencies. Blend timing contributes zero elapsed calendar time.

## Outputs, events and cross-system interactions

Outputs include a coherent effective environment snapshot, presentation targets, and checked readiness or failure status. Distinguish committed state change from presentation completion. An interior context change can update the environment while the outdoor weather ID remains the same. Public API and signal names remain implementation decisions.

- [TIME-005](TIME-005.md) owns selection and retention. [TIME-003](TIME-003.md) supplies endpoint refresh semantics. TIME-007 owns sunlight and gameplay exposure rules. TIME-018 owns weather restoration coordination.
- WORLD, LOC and MOVE-026 supply ready location and transition context. AV owns fog, rendering, lighting composition, audio and optional exterior view providers. CORE owns suspension and scene readiness. Required presentation honors the existing covered-transition contract. Optional mod cues use their own declared fallback.

## Save/load, edge cases and technical constraints

- Restore retained TIME-005 weather and committed location before building the effective environment. Derive blend targets from that state. Blend progress, transient particles and audio voices are presentation state and are rebuilt on native load.
- While context is unready, keep the destination covered under the owner readiness contract. Required context or profile failure enters the applicable transition recovery path. Ignore stale work from a cancelled transition or replaced session. Scope optional views and emitters to the authored location and tear them down on exit.
- A modded open area or view can experience weather changes while the player remains inside. Keep authored precipitation bounds, audio cues and exterior views synchronized to the same committed outdoor weather. Leaving or interrupting a blend clears its superseded targets. Keep the engine and asset work within the relevant AV/LOC contracts for Godot 4.7.2.

## Acceptance criteria

1. Enter a stock enclosed building or dungeon during snow or rain. The revealed scene uses local fog and lighting and suppresses outdoor precipitation. If weather changes while inside, exit presents the new conditions without rerolling.
2. An authored interior can enable roof rain or thunder cues. With a compatible authored view and provider, a window can show current exterior weather while the room uses its interior profile. A missing optional view leaves the interior usable and produces a diagnostic.
3. An exposed courtyard or open-roof zone can enable outdoor effects only where authored. A view or sound alone does not change gameplay exposure.
4. A live change retargeted mid-blend continues from the presented state and settles on the new profile without duplicate emitters. Recommitting an identical target does not restart presentation. An immediate profile applies at zero duration.
5. Covered traversal, fast travel and native load show the destination weather and fog on the first revealed frame. An obsolete callback cannot change the new scene. Loading adds no elapsed time and replays no historical weather transitions.
6. A weather notification observes the committed weather and location context. Changing graphics quality, audio settings or blend duration leaves gameplay timing and exposure unchanged.

## Consistency review and outstanding dependencies

The specification fits TIME-003 destination refresh, TIME-005 retained weather, MOVE-026 doorway readiness and zero elapsed cost, and DATA-003 resolved content. The exterior-view rendering method, asset requirements, stock blend tuning and weather-dependent gameplay hooks remain with AV, LOC and the relevant gameplay owners.
