# COMBAT-021 — Corpse creation and item transfer

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Create a persistent usable corpse that receives the dead actor's eligible inventory without loss, duplication or rerolled loot. Preserve quest/recovered-arrow obligations, appropriate art, local placement and ownership restrictions while allowing safe retries, cleanup and native restore.

## Confirmed requirements

COMBAT-021-D01–D11 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews. The complete specification is approved under COMBAT-021-A01. COMBAT-020 owns immediate death/required quest acknowledgment and readiness milestones; ITEM owns inventory/eligibility, MOVE-022 looting and LAW property legality. This feature defines corpse preparation/transfer/publication, not new loot tables or pickup exceptions.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity and transfer failure scenarios unverified. Source unchanged. Paths relative to reference `Assets/Scripts/`.

- `Game/EnemyDeath.cs#CompleteDeath` chooses FemaleCorpseTexture when applicable/nonzero, otherwise CorpseTexture, creates marker with new UID, records quest UID, unequips slots, associates CorpseLootContainer and transfers all actor items. It deactivates actor before this work; target instead retains explicit recoverable ownership/progress.
- `Utility/GameObjectHelper.cs#CreateLootableCorpseMarker` uses EnemyMotor.FindGroundPosition, parents by player context, creates CorpseMarker/customDrop with load identity, playerOwned=false/world context and tracks exterior loose objects. Actual death-location scope must remain authoritative in target, not player's later scene context.
- CreateLootContainer configures visual/loot metadata but does not itself roll new items in the inspected path. `Game/Entities/EnemyEntity.cs` invokes DaggerfallLoot.GenerateItems for actor inventory separately. Transfer must not interpret corpse recreation as a fresh loot opportunity.
- `Internal/DaggerfallLoot.cs#Update` destroys quest corpse when associated quest is absent/tombstoned. Target intentionally requires explicit cleanup policy rather than automatic quest-end deletion of remaining contents.

## Detailed rules and behaviors

### Prepared identity and readiness boundary

For each COMBAT-020 confirmed enemy death, prepare one stable corpse identity and actor–corpse association within authoritative death location/world scope. Retain prepared identity across retry/load rather than allocate another corpse each attempt. Scene representation is not inventory ownership or durable identity.

Wait for required original death/quest work under COMBAT-020. Prepare valid corpse container, placement/art state and inventory destination; settle checked unequipping/transfer and required association/receipts before exposing loot and reporting corpse ready. Optional visuals may exist while pending, but incomplete inventory cannot be opened as finalized loot.

An inventory unit cannot be simultaneously lootable from dead actor and corpse. Ownership publication/transfer must be coherent with ITEM/SAVE; preparation may retain original collection or inaccessible destination state as explicitly designed. No promise of one generalized transaction API is made, but partial failure must preserve original items or committed destination plus pending obligation, never delete contents or recreate fresh copies. Resume/reconcile same operation with retained receipts.

### Inventory contents and effect cleanup

Transfer eligible carried/equipped items including quest rewards and recoverable arrows. Preserve stable identity/quantity, condition, enchantments, remaining properties/effects, quest associations and legal ownership metadata. Distinguish physical inventory transfer from serialization copies/stack views; merging/splitting follows ITEM identity/provenance rules without multiplying units.

Equipment becomes unequipped through checked ITEM/MAGIC cleanup once. End legitimate equipped/held source effects through their owners, not by replaying arbitrary combat callbacks. Transfer does not fire fresh strike/break payloads, refresh charges/poison or restart summoned lifetime. Explicit expiry/removal/nonrecoverability policies still apply, with retained result so retry cannot remove another item or repeat gameplay effects. Eligibility exclusions require declared item/effect rules, not silent blanket removal of quest items.

COMBAT-008 lethal recovered-arrow unit must reach the resulting corpse exactly once whether impact recovery addresses actor inventory or its pending corpse association. Summoned arrows remain nonrecoverable; recovered custom arrows preserve remaining spent-property state. Concurrent death/impact/late-grant work must target the same ownership boundary rather than actor and corpse receiving copies.

Transfer actor's already-resolved inventory without fresh random loot solely for death, transfer, retry or restore. Explicit ITEM/mod death-generated loot may be supported as a separate once-resolved retained operation. This feature approves no particular new table, quantity or generation timing beyond that conservation boundary.

### Quest items and property

Required original quest-item work gates first readiness under COMBAT-020. Later legitimate quest action may add to associated ready corpse via its own exactly-once transfer identity, without recreating corpse or resetting previously looted inventory.

Preserve ownership/quest/legal restrictions instead of automatically making contents player-owned or legal to take. MOVE-022/ITEM handle pickup validation/capacity/transfer; LAW/content decide exceptions. Corpse readiness is not pickup or legal permission. Exact item ownership migration from actor to container and quest display labels need explicit owner schemas.

### Local placement and support

Start from death position/world context. Use bounded collision-checked local adjustment to supported ground where appropriate; do not project loot through walls, across locked barriers or into a different room. Validate intended shape/targetability and required support before success. Exact local search limits, origin conversion and collision masks require native fixtures.

Flying, swimming, unsupported and platform deaths need declared placement profiles rather than assuming every corpse has a floor beneath it. Failure retains pending loot and association for explicit recovery, not unrelated safe-point teleport or inventory destruction. No universal floating/ragdoll/sinking/long vertical-drop policy is invented here.

Where supported, corpse on valid moving platform retains stable support identity and relative attachment, moves with support and restores through persistent references. Support loss requires explicit local placement/recovery while preserving inventory record. Rebase/streaming must preserve world/support context; player's current location must not reparent corpse into unrelated scene.

Corpses are nonblocking visual/interaction markers by default. Interaction targetability remains distinct from movement/projectile obstruction. No new crush, actor shoving or loot barrier is added. Exact exposed/overlapping marker targeting is MOVE/LOC integration.

### Art and cosmetic fallback

Choose art from validated creature/form/body-variant definitions, retaining applicable female override and supporting mod variants. Appearance does not choose contents, alter actor identity or reclassify death. AV/ITEM naming must respect legitimate disclosure rather than expose hidden actor information through a generic marker.

If designated art unavailable but gameplay identity/items/placement are valid, use generic nonblocking lootable remains marker. Cosmetic failure alone cannot lose access or block finalization. Generic marker must still satisfy targeting/readiness; if even fallback presentation/interaction cannot be provided, explicit recovery is required rather than claiming inaccessible loot ready. Required definition/identity/item/placement failures are not cosmetic fallback cases.

### Persistence and cleanup

Empty corpse remains marker by default until explicit location/reset/cleanup policy removes it, rather than vanishing immediately when looted. Quest completion alone does not delete corpse or items. Lifetime/cleanup and explicit quest removal are moddable owner policies with declared scope/eligibility.

Cleanup respects outstanding quest-item/transfer obligations and pending recovery. Exact retained-content disposal, location reset lifetime, active loot interaction and late grant after supported removal require QUEST/ITEM/LOC policy; do not silently destroy obligations or deliver to unrelated nearby container. Distinguish scene unloading from durable deletion. Cleanup cannot cause corpse regeneration with restored contents after return.

## Relevant formulas and parameters

One corpse identity per death; each eligible inventory unit transfers once with conserved quantity except explicit validated expiry/removal/generation policy. Default transfer-time random loot draws=0. No default corpse collider blocking or immediate empty-corpse removal. No universal lifetime, placement radius/drop range, fallback item quantity or loot formula is selected.

All bounded placement/search and numeric quantities require safe validated domains. Actual item/currency/stack arithmetic and pickup capacity remain ITEM/MOVE-022. Body-variant selection is content/profile logic, not a random reroll at every restore.

## Required data

Stable dead actor/death/corpse/session/location identity; prepared/ready ownership state; item unit/stack provenance and legal/quest metadata; equipment cleanup/transfer/expiry receipts; original resolved loot and optional declared generation result; lethal arrow and late grant association; death pose/placement profile/world coordinates/support attachment; art/fallback identity; cleanup policy/status and save recovery obligations. Raw scene parent, current player world context and new marker UID per retry are insufficient.

## Inputs, outputs and events

Inputs: COMBAT-020 confirmed death/quest-ready result, authoritative actor inventory/equipment, ITEM/MAGIC cleanup policies, placement/support/art definitions, late grants and lifecycle/save/cleanup. Outputs: prepared corpse, checked ownership transfer, pending failure/recovery or ready loot association, generic-art fallback and authorized cleanup result. APIs/signals remain unselected. Rendering/open-preview cannot generate loot, transfer twice or finalize required work.

## Cross-system interactions

COMBAT-020 death/quest/readiness and persistent association; COMBAT-008 arrow recovery; ITEM contents/stack/ownership/expiry; MAGIC held/equipped source cleanup; QUEST original/late grants and explicit cleanup; MOVE-022 pickup/capacity plus placement/support principles under MOVE-027/008; LOC/WORLD scope/geometry/streaming; LAW property; AV corpse/fallback; CORE/SAVE coherent snapshots/recovery and DATA/MOD validated definitions. Detailed actor death/rewards and player damage are not rerun through container creation.

## Edge cases and failure conditions

Verify equipped quest/custom items, consumed charges/poison, expiring summoned items, lethal recovered arrows, already-generated loot and technical failure after partial unequip/transfer. Preserve remaining properties and actual authoritative owner; no duplicate actor/corpse loot or fresh generation on retry.

Verify first quest prerequisite versus late grant, missing/tombstoned quest, emptied corpse, active pickup at cleanup and location unload/restore. Explicit cleanup must resolve obligations without silently losing still-required items; default quest completion is not removal authorization.

Verify death near wall/ledge/water, flying actor without nearby support, moving-platform attachment loss, world rebase and player leaving location during pending work. No through-geometry placement, arbitrary scene reparent or unrelated teleport. Technical placement failure retains record and truthful unavailability.

Verify missing body-variant art/fallback resource, multiple duplicate completion calls and source/death representations still present. Art cannot affect content; pending visuals cannot open unfinished loot. A restored empty corpse cannot regain old items or replay cleanup/effect grants.

## Configuration and balancing options

Validated corpse art/variant/fallback, placement/support profiles, item recoverability/expiry and explicit death-generated loot, lifetime/cleanup policies. Defaults preserve inventory, no extra transfer roll, nonblocking persistent empty markers and no automatic quest-end deletion. Exact schemas/provider precedence, cleanup content disposition and geometry limits remain owner contracts; no new universal despawn timer or free-ownership rule is added.

## Save/load considerations

Save corpse identity/location/support/art, actual inventory/ownership/equipped cleanup completion, item/quest/arrow/grant associations and ready/pending transfer/cleanup progress. COMBAT-020 permits coherent pending-death saves; unsafe partial operations temporarily block save with explanation rather than invent completion/drop obligations.

Restore dead actor/corpse association and geometry/required support before exposing loot. Do not regenerate contents, allocate another corpse or reapply unequip/expiry/effect cleanup simply from fields loading. If item moved to player before save, restored corpse remains without that unit. Generic art can reconstruct visuals independently of gameplay inventory. Scene streaming unload does not erase persistent corpse state unless explicit reset/cleanup policy commits removal.

Late grants and pending lethal-arrow transfer must reconcile against saved completion records so an actor/corpse pair cannot each regain one copy. Exact native schema/migration, stack identity, support recovery and cleanup tombstone records require SAVE/ITEM/QUEST integration.

## Technical constraints

Target Godot 4.7.2. Separate prepared identity/container ownership, placement/art, checked equipment cleanup, item transfer and ready publication. Use stable per-death/per-transfer identity and safe recovery stages, not deactivate actor then assume creation/TransferAll always succeeds. Movement owns geometry/support and optional rendering cannot authorize loot rolls. Native transfer/placement/quest/streaming/save fixtures required. No implementation or coding tasks are authorized.

## Acceptance criteria

1. One prepared stable corpse per death exposes inventory only after required COMBAT-020/ITEM work completes; duplicate calls cannot create another.
2. Eligible carried/equipped/quest/recovered-arrow units move once preserving all remaining properties/ownership, never simultaneously lootable from both owners.
3. Equipment cleanup runs once without new strike/break/charge/expiry resets; legitimate item exclusions/expiry follow explicit owner policy.
4. Existing resolved inventory does not reroll on death/transfer/retry/load. Explicit death generation has its own retained operation.
5. Placement stays within bounded checked local context, handling declared airborne/water/platform modes without wall/room crossing or unrelated teleport; failure preserves loot obligation.
6. Valid moving support/relative attachment persists through motion/restore; support loss uses local recovery without item loss.
7. Validated corpse variant/female override and generic cosmetic fallback preserve content and nonblocking loot access; required gameplay failure is explicit recovery.
8. Quest completion/empty inventory do not automatically delete marker/items; cleanup is explicit and respects pending obligations/late grants.
9. Actual pickup follows MOVE-022/ITEM/LAW restrictions rather than universal ownership/capacity bypass.
10. Native pending/ready/empty/removed corpse state restores without duplicate items, regenerated loot, repeated effects or lost associations; unsafe save boundaries are blocked truthfully.

## Contradiction review

Reviewed against approved COMBAT-008/020, MOVE-022/027 and supporting equipment/movement/quest ownership plus source/catalog/architecture. No direct contradiction identified. Corpse readiness implements COMBAT-020's pending-loot boundary without delaying authoritative death. Conservation includes lethal-arrow and late-quest obligations; owner expiry is explicit rather than silent transfer loss. Native persistence/cleanup distinguish unload from deletion. Quest-end retention deliberately differs from source destructive cleanup. Generic art fallback does not bypass required placement/identity validation. Broader architecture proposals remain Proposed.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: item/equipment effect cleanup/stack identities; transfer/publication/save boundaries; corpse art/fallback resources; native placement limits/mode/support profiles; lifetime/reset/cleanup content policies and late grants after disposal; LAW metadata adapters and failure fixtures. These cannot duplicate loot, reroll inventory, delete corpse solely on quest completion or teleport through barriers. Detailed ITEM/QUEST/LOC content/lifetime reviews remain separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-021-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented item/effect cleanup, transfer boundaries, placement/support profiles, cleanup policies and native persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
