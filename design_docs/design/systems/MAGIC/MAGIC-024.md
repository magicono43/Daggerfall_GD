# MAGIC-024 — Recall anchor and teleport

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose and intended player experience

Set a persistent return point and spend a later Recall cast to return there, including across exterior, building and dungeon contexts. Arrival is predictable and safely validated. Default one-use anchors support exploration and escape; mods can define multiple/reusable anchors, restrictions and alternate journeys.

## Confirmed requirements

MAGIC-024-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. The complete specification is approved under MAGIC-024-A01. Approved MAGIC-003/004/008–010, MOVE-026/027 and CORE/SAVE readiness contracts remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths relative to reference `Assets/Scripts/`:

- `Game/MagicAndEffects/Effects/Mysticism/Teleport.cs#SetProperties` declares self target, magic element, Mysticism and SpellMaker eligibility. `Start` opens an Anchor/Teleport choice for the player. Cancellation is allowed with an explicit no-refund comment.
- `SetAnchor` captures `SerializablePlayer.GetPlayerPositionData`, adds building door/discovery context and replaces `PlayerEntity.AnchorPosition`. `TeleportPlayer` restores directly within the same interior or reconstructs world context through `RestorePositionHelper`, scene caching and a respawner callback. Successful paths clear the anchor.
- `EffectActionPrompt_OnButtonClick` displays a message when no anchor exists. `GetSaveData`/`RestoreSaveData` retain legacy effect-owned anchor compatibility; the latter migrates to player ownership. `Game/Serialization/SerializablePlayer.cs` also serializes/restores the player anchor.
- `Game/UserInterfaceWindows/DaggerfallTeleportPopUp.cs` implements travel-map destination teleportation, not Recall's Anchor/Teleport dialog. Its random destination-marker path does not define Recall placement.

Static inspection only; no runtime/classic-parity verification. Source callbacks, duplicated legacy serialization and floating-origin representation are not selected target architecture.

## Detailed rules and behaviors

### Cast and interaction

Recall uses the normal authorized casting route, release checks, payment, practice/history and recovery under MAGIC-003/004; item-origin rules remain MAGIC-016. A committed cast opens the Anchor/Teleport choice. Cancel or Teleport without an anchor changes no anchor/location and refunds no committed magicka. Release preparation failure before commitment remains unpaid under MAGIC-004. Opening the dialog is committed delivery, not proof arrival succeeded.

Expose validated interaction/payment policy alternatives to mods. Default self Recall does not imply an NPC AI selection behavior or permission to teleport arbitrary recipients; custom actor/target profiles require explicit adapters and MAGIC targeting contracts.

### Anchor creation and lifetime

Default capacity is one anchor. Capture and validate the new destination record before replacing the previous record; a failed capture leaves the previous anchor intact. No additional replacement confirmation is required by these decisions.

Store stable location identity, authoritative pose/facing, coordinate version and required building/dungeon context. Default anchor is a fixed world/location pose, without implicit attachment to an actor or moving platform. A platform moving away does not move the anchor. Attached-anchor mods explicitly define identity, transform, loss and migration behavior.

Anchors have no default expiry and survive rest, travel and native save/load until successfully used or replaced. Changing or missing destination content reports unavailability rather than silently deleting the record or selecting another location. Supported migration may preserve the intended destination; unresolved required content follows recovery. Saving an anchor does not reserve empty space or freeze destination geometry.

### Admission and destination preparation

Default set/recall works across exteriors, buildings and dungeons without added distance or combat restrictions. Existing cast eligibility still applies. Mods may define location-, state- or spell-dependent restrictions, anchor capacity/names, expiry and consumption. These policies cannot silently bypass required content/placement validity.

Validate current destination geometry and full collision shape through MOVE-027. Try exact intended pose before its permitted bounded local corrections; no crossing barriers, random marker fallback or unrelated replacement destination. Ground, water, airborne and active-effect contexts require their appropriate validation rather than universal floor snapping. An anchored airborne pose may be valid and subsequently fall.

Keep the anchor until coherent arrival succeeds. A blocked/unavailable destination or technical failure retains it without automatic refund of the already committed cast. A retained anchor does not automatically retry: another cast uses current checks/payment unless an explicit mod policy says otherwise. Technical partial failure uses identified recovery, not blind replay.

Preserve departure context while feasible. If destructive reconstruction has already invalidated it, keep gameplay suspended and provide explicit CORE recovery; universal streamed-world rollback is not promised. Neither failure nor recovery may report a successful arrival without valid owner state.

### Arrival and character state

Successful default Recall restores anchored position and facing with fresh movement placement: departure velocity/momentum and fall distance do not carry across. Teleport displacement is not physical travel or a landing impact. Initialize current destination movement through its owner: ground, swimming, falling or valid active levitation as applicable. Do not reinstate an obsolete platform/climb relationship merely because it existed at capture.

Ongoing effects and their remaining lifetimes persist, with source eligibility reconciled normally. Recall does not restore an old health, magicka, fatigue, breath or effect snapshot. Destination water/hazards operate on current character state through CHAR/MOVE; no intrinsic breath refill or resource restoration is granted. Validated mod movement handoffs may explicitly preserve/alter momentum or histories through the same owners.

Consume the selected anchor only as part of completed successful arrival. Corrected success under MOVE-027 is success with appropriate provenance. Preserve once-only commitment facts so duplicate callbacks cannot repeat placement, consumption or notifications.

### Timing and competing requests

Default added journey time is zero regardless of distance. Casting retains normal eligible-gameplay timing. Choice and loading suspend gameplay: wall-clock delay creates no ticks, regeneration, rest benefit or travel encounters. Remaining cast recovery freezes under suspension and resumes according to MAGIC-004; closing a dialog cannot erase it.

Explicit timed-journey mods must define authorized time advance, interruptions and effect processing through TIME/MAGIC-008, never loading duration. They do not gain a silent wall-clock progression path.

Allow one active Recall interaction/arrival operation per actor. Repeated input cannot queue duplicate operations. Competing load/doorway/teleport requests use explicit reject/defer/supersede ownership under CORE/MOVE-026; exact priority remains an integration dependency. Cancellation/cleanup must reject stale callbacks and release only owned suspension reasons. A superseded request cannot overwrite a newer anchor or arrival.

## Relevant formulas and parameters

Default anchor capacity = 1; successful-arrival consumption = enabled; expiry = none; distance-based journey duration = 0. Cost and cast timing remain RULE-018/MAGIC-003/004, not distance-derived here. Placement bounds, coordinate precision and recovery budgets remain MOVE-027/WORLD tuning. Validated mod profiles support alternative limits, consumption, timing and handoffs; no additional numeric ranges are invented.

## Required data

Single authoritative anchor owner; stable anchor/actor/location identity; authoritative pose/facing and coordinate/schema versions; required location reconstruction context; selected policy/version; attached-source metadata only for declared profiles; operation/session identity, selected anchor version, committed cast and arrival/consumption result; readiness and recovery provenance. Exact schemas and compatibility precedence remain engineering dependencies. An anchor is destination data, not a serialized whole character or live scene object reference.

## Inputs, outputs and events

Inputs: committed Recall delivery, choice/cancel, current anchor and actor state, current destination readiness/validation, competing transitions and restore. Outputs: atomic anchor replacement or retained old anchor, no-anchor/unavailable/failure feedback, suspended preparation, exact/corrected successful arrival and once-only consumption. Distinguish cast committed, anchor set, arrival completed and arrival failed. Concrete API/signal names remain unselected.

## Cross-system interactions

MAGIC-003/004 payment/casting/history; MAGIC-008 timing and MAGIC-009/010 active-effect continuity; MAGIC-016 item origins; MOVE-004/008–015 physical states and history; MOVE-026/027 transition/placement; WORLD/LOC stable destination reconstruction/current scene state; CORE readiness/scope/suspension/recovery; SAVE/DATA versions and mods; CHAR current pools/hazards; UI choice, disclosure and missing-destination feedback. Recall does not infer quest completion, crime immunity or destination-world resets; those owners retain their contracts.

## Edge cases and failure conditions

Cover no anchor, canceled choice, failed replacement, occupied pose, changed geometry, missing provider/location, airborne/underwater destination, moved platforms, overlapping transitions and stale callbacks. Actor death/session teardown follows owner cleanup rather than publishing stale teleport completion; exact commit-boundary handling requires fixtures. Scene reconstruction must preserve supported destination world state rather than reset enemies/loot to manufacture repeat rewards. Any irreversible partial outcome retains truthful recovery facts.

## Configuration and balancing options

Support named/multiple/reusable anchors, consumption/expiry/invalidation, restrictions by spell/location/actor state, alternative choice/payment rules, attached anchors, timed journeys and movement handoffs through explicit validated profiles. Default behavior above remains unchanged. Exact selector precedence, UI for multiple destinations, attached-source loss policy and profile numeric domains require contracts before implementing those alternatives; no unsupported state may be silently discarded.

## Save/load considerations

Save coherent committed anchor data under one authoritative owner. Unresolved choice or arrival temporarily blocks saving with a clear reason. A completed native save restores whether the anchor exists and its exact committed destination/policy without opening the dialog, recasting, charging, awarding practice or replaying arrival/consumption. Restore ongoing effects and physical state through their owners, not by treating load as new Recall.

Use versioned migration and required-provider recovery for changed content. Any legacy import, if separately authorized, must resolve duplicate historical ownership explicitly; this feature does not authorize classic/DFU save import. Native saves must not need an active transient Recall effect to preserve an anchor.

## Technical constraints

Target Godot 4.7.2. Separate destination data ownership, cast interaction, world preparation and movement placement. Stable operation/session identities and checked completion prevent stale mutations. Prepare/validate before replacing or consuming anchor state; preserve known partial commitments during recovery. Concrete concurrency, persistence and world-cache implementation remains deferred. No implementation or coding tasks authorized.

## Acceptance criteria

1. Default one anchor replaces only after successful capture; failed replacement preserves the old record.
2. Choice follows committed cast; cancel/no anchor does not refund, teleport or erase the record.
3. Default cross-context recall has no added combat/distance limit; normal cast and destination validity apply.
4. Current full-shape destination validation follows bounded MOVE-027 correction with no unrelated fallback.
5. Anchor persists across saves/rest/travel; missing content reports unavailability without deletion or guessed remapping.
6. Only coherent successful arrival consumes the anchor; failures retain it without automatic refund/retry and keep safe recovery gates.
7. Arrival restores pose/facing with fresh default momentum/fall history; current effects, pools and destination hazards remain authoritative.
8. Default journey adds zero game time; choice/loading wall time cannot advance effects/resources/encounters or erase cast recovery.
9. One operation per actor and identified completions prevent duplicate arrival/consumption; competing transitions cannot publish stale results.
10. Unresolved interaction/arrival blocks saves clearly; completed native load restores data without replaying gameplay.
11. Declared mod alternatives cover anchor limits/consumption, restrictions, payment/interaction, timing, attachment and movement handoff with validated owner contracts.

These are future verification criteria; no implementation/runtime tests performed.

## Consistency review

Reviewed against MAGIC-004/008/010 and MOVE-026/027. Payment precedes this post-cast interaction; preparation failures before release remain unpaid, while later canceled/failed interaction remains paid. Loading freezes timing and does not bypass recovery. Fresh teleport history is an explicit placement intent, distinct from native restoration that preserves physical history. Destination correction remains bounded; retention after failed arrival does not promise universal rollback. Current breath is retained, while independent Water Breathing transitions remain MAGIC-023/CHAR-owned.

## Outstanding questions and approval

No further blocking player-policy question identified. Dependencies: stable destination/coordinate schema, world-state reconstruction, current-shape/hazard placement fixtures, operation/anchor-version commitment, competing-transition priority, death/teardown recovery, mod selectors/attached-anchor profiles and native migrations/UI. These do not waive once-only consumption, truthful failure or current-state preservation.

The user explicitly approved the complete Draft v1 on 2026-11-10 with “I approve”. This specification is finalized v1 under MAGIC-024-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented integration, tuning and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
