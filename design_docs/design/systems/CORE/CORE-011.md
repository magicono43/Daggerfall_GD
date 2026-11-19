# CORE-011 — New-character placement

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Place a validated new character in the intended initial world context, with a ready location and no premature gameplay activation.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Ordinary new characters start at Privateer's Hold. Preserve an explicit setting/option to start outside that dungeon. Alternative starting locations may be supported through mods later; no alternate-origin UI or mod contract is approved yet.
- Missing/invalid required starting content fails entry with actionable error and safe recovery. Do not silently fall back to exterior or another dungeon. Explicitly choosing the exterior start is different from a failure fallback.
- Require a validated, completed character document; do not silently create a default character. Keep gameplay suspended until required geometry/collision and intended spawn position are ready. Placement readiness does not bypass required CORE-012 initialization.

Second interview, confirmed by the user on 2026-11-05:

- Default to the interior start. Provide the saved outside-Privateer's-Hold option before the main menu, or in the eventual appropriate settings interface; exact final UI location remains open. Capture its value at New Game submission. Later changes affect future new characters, not the current session or loaded saves.
- Interior new-game placement must use Privateer's Hold's special deep-cave starting position from original dungeon/block marker data, not the ordinary dungeon entrance/exit position. This corrects the prior generic entry-position recommendation. Exterior start uses a validated position immediately outside the entrance. Define facing and safe footing for both; failure to establish intended placement fails safely rather than choosing an arbitrary nearby spot.
- Use original Daggerfall starting date/time for both options and initialize player time tracking consistently, without phantom elapsed time on the first update. TIME owns exact calendar values. Mods may alter starting time later; detailed mod contracts remain open.

Third interview, confirmed by the user on 2026-11-05:

- Validate selected marker, coordinate conversion, capsule clearance and supporting floor. Permit only small bounded adjustments onto the intended floor, not relocation to another room. Fail safely if intended placement remains invalid.
- Preserve original new-game facing at the deep-cave spawn. Exterior start faces away from the entrance toward the surrounding area. Verify exact orientation/marker mapping against original layout data before implementation.
- Cover the scene with loading UI/fade until placement and required CORE-012 work complete. Prevent movement, falling, AI attacks and gameplay-time advancement during initialization. Reveal the ready scene and release only entry-owned gameplay suspension.

## Inherited requirements and deferrals

CORE-007 requires stable request input/preflight, discard consent and safe failure/retry. CORE-010 establishes a clean baseline before new-character placement; CORE-005 owns scope/readiness/cleanup. CORE-001–006 application storage/preferences remain intact, and CORE-008 handles return flow. CORE-009 worldless behavior remains deferred. CORE-012 owns starting grants/opening quests; placement alone does not approve their rules.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/Utility/StartGameBehaviour.cs`, StartNewCharacter: assign supplied/default CharacterDocument, set classic starting time and player time tracking, resolve configured map cell, enter dungeon if requested and available, otherwise enable exterior and request origin reposition. NoWorld can suppress placement in the reference implementation; that behavior is not approved here.

`Assets/Scripts/Game/PlayerEnterExit.cs`, StartDungeonInterior owns dungeon generation and marker selection. Exact intended spawn/orientation for this recreation still requires discussion.

Baseline: local DFU 1.1.1 Release snapshot, exact commit unavailable per repository overview. Static inspection only; source remains unchanged.

## Detailed rules and behaviors

New Game captures a completed validated character document, chosen interior/exterior preference and resolved starting context under CORE-007. Do not silently manufacture a default character. Preflight validates required starting content and available placement definitions before destructive replacement; later geometry/physics checks still occur after construction. CORE-010 establishes the clean replacement baseline before owner initialization.

The standard interior opening is Privateer's Hold's original deep-cave new-game position, not its normal doorway/entrance spawn. Identify that purpose from original layout/marker data; a generic StartMarker/EnterMarker label or enumeration order is not sufficient evidence. Exterior start is an explicit alternative at a validated position immediately outside Privateer's Hold's entrance, not a fallback for failed interior content. Keep required location identity and selected placement stable through the request.

The exterior option defaults off, is saved through CORE-003 and must be available before the main menu or in the eventual appropriate settings interface. Exact final navigation is deferred. Capture it for the new-character request; later preference edits do not move the current character, alter loaded poses or redirect an already submitted start. This setting governs new-character placement and needs no immediate world reapplication.

Resolve layout coordinates through WORLD/LOC/MOVE contracts, construct required geometry/collision and verify intended placement with the actual player capsule. Establish supporting floor, clearance and declared facing. Only bounded local correction onto the intended floor is permitted. Do not choose arbitrary markers, another room/dungeon or exterior after a failure. If the correct marker/data, required floor or safe pose cannot be established, fail with actionable diagnostics and CORE-005/007 cleanup/retry. Failed preflight leaves any existing session intact; failure after replacement does not promise rollback.

Initialize original Daggerfall starting date/time for both standard start choices. Synchronize player elapsed-time tracking with that initial time so the first update cannot apply phantom elapsed time. TIME owns exact calendar values and representation. Initialization itself must not advance gameplay time or permit movement, falling or AI attacks; construction/physics queries may operate as necessary without simulating a playable scene.

Keep loading UI or a fade over the world while placement and required CORE-012 resources/opening initialization are incomplete. Placement readiness is an intermediate milestone, not a successful playable start. Reveal after the full entry gate is satisfied, then release only entry-owned suspension; menus or other owners may still require gameplay to remain suspended. Do not introduce an extra autosave or starting reward as part of placement.

Allow future mods to change start location/time through a later defined MOD/content contract. This approval establishes that customization intent, not arbitrary coordinate override APIs, mod precedence or alternate-origin UI. A modded start must later define required location/spawn/time and compatibility with opening content while retaining validation/readiness safety. No worldless exception is approved; CORE-009 remains deferred.

## Relevant formulas and parameters

No gameplay balance formulas apply. Standard location is Privateer's Hold; outside-start defaults false. Interior orientation is the original new-game facing; exterior direction points away from the entrance. Initial time is original Daggerfall start time for both choices. Exact marker identity, coordinate transform, facing angle, floor-correction bounds and calendar values require verification/owner contracts; no numeric values are invented here.

## Required data

Validated character document, stable operation/session identity, captured outside-start choice, resolved location/layout identity, purpose-specific interior/exterior spawn definition, facing, coordinate context, player capsule dimensions, geometry/collision/floor readiness and validation result. Initial TIME state and player elapsed-time baseline must agree. Future mod-defined overrides require an explicit supported contract. Raw scene-object references are not durable location identities.

## Inputs, outputs and events

Inputs: validated New Game request, starting preference/content, original layout records, TIME initialization and geometry/physics owner results. Outputs: assigned new-character context, initialized clock tracking, validated player pose/location, placement-ready milestone or actionable failure. Full-entry completion remains CORE-007/012 coordination. API/signal names are deferred. Notifications carry originating context so late placement cannot affect a replacement session.

## Cross-system interactions

CHAR validates and assigns completed character data. CORE-010 supplies clean baseline; CORE-007 coordinates preflight, consent, outcomes and retry. DATA resolves original layouts/markers; LOC constructs dungeon/exterior local content; WORLD supplies global coordinate/residency context; MOVE validates capsule pose and footing. TIME initializes date/tracking without simulation advancement. UI maintains loading coverage and later reveal. CORE-012 owns starting grants/opening quests and their dependency on placement. MOD later defines safe location/time customization. CORE-005 governs readiness/lifetimes and CORE-006 preference timing.

## Edge cases and failure conditions

- Missing or incomplete character data fails preflight; do not hide errors by creating a default character.
- Missing/ambiguous special cave-spawn mapping must be resolved from original content before implementation is considered complete. Never use a doorway marker merely because it is called start/enter.
- Missing/invalid requested starting content does not silently flip the outside option. Exterior also requires its own validated content/pose.
- Capsule placement may intersect walls, lack a floor or use a mismatched coordinate scale. Bounded correction is limited to the intended floor; invalid final pose fails safely.
- The world can load asynchronously. Do not reveal unfinished geometry or enable falling/enemy attacks before all required entry work completes.
- Initial time and entity time baselines must use consistent units/representation. Starting either inside/outside must not cause elapsed-time effects before gameplay begins.
- Late/repeated placement callbacks cannot move a different session or emit duplicate start success. Retry reconstructs safely under CORE-007 rather than continuing partial placement.
- A preference edit after submission affects future starts only. Loaded saves retain saved placement under SAVE rules, not the outside-start preference.
- Future mod starts may invalidate opening quests; do not silently assume compatibility or approve a fallback route without the later MOD/QUEST contract.

There are no new balance values, safe-area guarantees after gameplay starts, enemy removals, rewards or death protections approved here.

## Configuration and balancing options

Players may select interior versus exterior Privateer's Hold start in the eventual pre-menu/settings interface. Ordinary new-character location is fixed otherwise. Mods may later alter location/time, subject to a separately defined contract. Starting gear/spells/quests are CORE-012 scope. Exact placement tolerances are engineering parameters justified by layout/physics evidence rather than player balance controls.

## Save/load considerations

Persist the outside-start preference as application configuration through CORE-003. Capture it at New Game submission. Character saves store the resulting pose/world/time through SAVE; subsequent loading does not reinterpret that pose using new-character settings. Do not write an automatic save or alter existing save files as part of this feature. TIME/save owners define durable clock/pose representations. Pending entry/scene handles remain transient.

## Technical constraints

Project target: Godot 4.7.2. Translate original layout units/axes through explicit WORLD/LOC/MOVE contracts rather than copying Unity vectors blindly. Read original content without modifying it. Verify actual original deep-cave marker/facing before claiming placement fidelity. Perform required collision readiness checks while gameplay remains gated. Specific import/marker IDs, engine APIs, physics tolerances, loading fade and mod hooks remain deferred.

## Acceptance criteria

1. Ordinary New Game uses Privateer's Hold, defaults inside and requires validated completed character data; no default character is silently created.
2. An explicit saved outside-start option is available before the main menu or through the finalized appropriate settings interface. Capture at submission; later edits affect future new characters only.
3. Interior start uses the verified original deep-cave new-game spawn/facing, not ordinary entrance/exit placement. Original data evidence is required before this criterion can pass.
4. Exterior start places the character immediately outside the entrance with validated footing and facing away toward the surroundings. It is not invoked as automatic interior-failure fallback.
5. Required layout, coordinate conversion, collision, capsule clearance and floor checks finish before placement readiness. Only bounded correction onto the intended floor occurs; invalid placement fails rather than selecting another room/site.
6. Both standard choices initialize original starting date/time and synchronized player tracking, with no phantom elapsed time. Exact values are verified through TIME/original data.
7. Loading/fade coverage remains until placement and required CORE-012 work finish. Movement, falling, AI attacks and gameplay-time advancement cannot occur during initialization.
8. Full entry reveal/completion releases only entry-owned suspension and respects other pause/readiness requirements. Placement alone is not playable-start success.
9. Preflight failure leaves the existing session intact; post-replacement failure uses safe cleanup/retry. Stale callbacks and duplicate results cannot affect another character.
10. Existing saves/content remain unchanged; loaded poses are not overridden by the exterior preference. CORE-009 remains deferred; future mod starts require their own compatibility/validation contract.

These are future verification criteria. No implementation/runtime tests or original binary marker-placement inspection have been performed in this specification phase.

## Additional source evidence and limitations

`Assets/Scripts/Utility/RDBLayout.cs` categorizes editor-flat record 10 as StartMarkers and record 8 as EnterMarkers. `Assets/Scripts/Internal/DaggerfallDungeon.cs` stores those categories separately. `PlayerEnterExit.StartDungeonInterior` prefers EnterMarker when requested/available, otherwise StartMarker, and then sets facing north. These code facts do not by themselves establish the original Privateer's Hold cave marker's exact position or original new-game facing. The user explicitly requires the deep-cave opening; original binary layout verification remains necessary.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001 through CORE-008 and CORE-010 v1, CORE-009 deferral, the decision log, CORE catalog and CORE architecture review. All nine CORE-011 interview decisions are represented, including the user's special-marker correction and settings-location preference. No conflict identified: outside start is explicit, not silent fallback; readiness remains gated; grants/quests stay CORE-012 scope. Worldless startup and specific mod APIs are not approved by implication.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Before implementation is considered complete, verify original cave/exterior mapping and facing, original calendar values, coordinate transforms and safe correction bounds. Final settings navigation, exact loading presentation and future mod/quest compatibility contract remain deferred. These dependencies do not waive placement fidelity or safety criteria.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-011. This document is finalized v1. Approval reference: CORE-011-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented verification dependencies and deferrals remain open; approval does not establish unverified original marker/facing or calendar values. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
