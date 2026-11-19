# ITEM-007 — Collection transfer and selective retrieval

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Move possessions between authoritative collections and find eligible instances without item loss, duplication or unintended selection changes.

## Intended player experience

Transfers either move the requested possessions or clearly explain what stayed. Searches behave consistently despite inventory sorting. Retrying or loading cannot duplicate items, erase special state or silently bypass restrictions.

## Confirmed requirements

- **ITEM-007-D01:** Validate source membership, access, requested quantity and the complete destination insertion plan before single-transfer commitment. Success moves requested quantity under approved split/merge identities; rejection leaves both collections unchanged.
- **ITEM-007-D02:** A valid same-collection transfer is an explicit no-op without removal, merge, duplication or reordering. Reordering/consolidation are separate operations.
- **ITEM-007-D03:** Selective retrieval is a pure query with explicit filters and deterministic stable-identity selection, not display order. Optional summoned-first selection uses shortest remaining lifetime then stable identity. Query results grant no consumption/transfer permission; commitment revalidates state. Ammo-specific approved rules remain binding.
- **ITEM-007-D04:** Bulk transfer supports explicit all-or-nothing whole-batch validation. Separate take-what-fits mode moves a deterministic eligible subset and reports moved/remaining items and reasons. Skipped failures cannot be reported as complete success.
- **ITEM-007-D05:** Copying is separate from transfer and requires authorized generation/debug/content operation, fresh identities and type-aware state handling. Ordinary inventory movement cannot clone items, souls, charges or unique rewards through a copy helper.
- **ITEM-007-D06:** Wholesale replacement/import is privileged restoration or explicitly authorized operation. Validate full replacement and required reference cleanup before discarding contents; failure preserves original collection. Imported references cannot create two authoritative owners.
- **ITEM-007-D07:** Validate both ends' access, capacity, quest/property restrictions and equipment/source-effect requirements through owners. Transfers cannot silently unequip, suppress effects or legalize taking property; required transitions are explicitly authorized/coordinated.
- **ITEM-007-D08:** Distinguish no eligible match from missing definitions, invalid filters, unavailable collections and provider failures. Queries exclude expired/invalid candidates without mutation; cleanup remains owner-controlled. Technical failure cannot masquerade as empty inventory.
- **ITEM-007-D09:** Revalidate current item/custody/session before commitment and retain completed transfer facts against duplicate retries. Save coherent completed state or explicitly supported pending progress; otherwise explain temporary blocking. Load cannot replay transfers or accept old-session callbacks.

User confirmed each of three interviews with “1. Yes / 2. Yes / 3. Yes”. See [the decision log](../../GAMEPLAY_DECISIONS.md).

## Existing Daggerfall Unity behavior — reference only

Source relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`: `Game/Items/ItemCollection.cs`.

- `Transfer` removes from source then calls destination AddItem, without checked outcomes.
- `TransferAll` adds each source item then clears source, without checking individual insertion outcomes.
- `GetItem` template overload filters enchanted/quest items, ordinarily returns first collection match, and optionally prioritizes summoned items with shortest lifetime.
- `CopyAll` clones with new UIDs; `ReplaceAll` clears then copies. `Import` clears and adds supplied references retaining UIDs. `Export` returns item references and clears collection. These paths are reference evidence, not adopted target contracts.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Runtime reachability/failure behavior not verified; source unchanged.

## Existing approved constraints

ITEM-001 owns stable identity/custody, split/merge references and active sessions. ITEM-005 owns checked insertion, quantity/cap conservation and all-or-nothing plans; ITEM-006 owns state-preserving splits/extraction versus consumption. ITEM-002–004 preserve provider/content/resource state and recovery. COMBAT-008 owns ammo selection and per-shot provenance. Capacity, quest/property access and equipment/effect transitions remain their owners' policies, not permissions granted by a query.

## Detailed rules and behaviors

### Single transfer and custody

Requests name explicit source/destination, item identity, quantity, mode and authorized actor/context. Validate authoritative membership, current access, positive integral available quantity, required definitions/state and active session. Prepare the complete destination insertion plan under ITEM-005 before commitment. Full moves preserve identity unless a permitted merge retires the source; partial moves use ITEM-006 split identity/state rules. Return all relevant resulting identities/counts, including multiple capped destinations, without silent reference aliasing.

Success moves the requested quantity with exactly one authoritative custody per live item. Rejection leaves both collections unchanged. Coordinate split/extraction and insertion without exposing an unowned result or reducing the source before destination admission is assured. Required technical design must preserve whole-transfer failure semantics; this does not mandate a general transaction framework.

Validate access/capacity at both ends and relevant quest/property/equipment/source-effect contracts. Physical movement does not itself authorize theft, waive legal consequences or grant quest permission. If unequip/effect cleanup is required, the owning action must explicitly authorize and coordinate it; silent lifecycle callbacks are not a transfer default. Actual capacity values, wagon access, crime policy and equip restrictions remain owner features.

A valid same-collection transfer returns an explicit no-op without merge, split, remove, reorder or duplication. It still validates identity/request/access as applicable. Sorting, consolidation and explicit split are separate operations; an invalid request is not converted into a successful no-op.

### Bulk transfer

The request explicitly selects all-or-nothing or take-what-fits. All-or-nothing validates the entire batch and combined destination plan, including cumulative weight/entry/capacity effects and source restrictions, before changing anything. Any inability to complete rejects the batch unchanged; independently valid individual moves do not prove the whole batch fits.

Take-what-fits is a distinct authorized partial mode, not a failed atomic request silently downgraded. Use declared deterministic ordering/selection and report exact moved/remaining quantities and reasons. Each committed move retains full identity/state/admission guarantees; failed entries do not justify clearing the source. No eligible match, ordinary exclusion, capacity rejection and technical error remain distinguishable. Already committed partial-mode moves are reported truthfully if a later technical failure requires recovery.

Exact partial-batch ordering and whether a final item can move by partial quantity remain an explicit UI/owner profile dependency before that profile is supported; no hidden optimal-value packing, display-order priority or maximal-capacity algorithm is approved. ITEM-005 stable destination ordering remains binding for every insertion. Retries retain moved-item facts instead of restarting the whole batch.

### Pure selective retrieval

Queries use stable item/template identity and explicit supported filters such as quest/enchanted inclusion and summoned preference. Default ordinary selection is deterministic stable item identity, independent of display/collection order. Optional summoned-first selection prefers shortest remaining lifetime, then stable identity; ordinary fallback uses stable identity. COMBAT-008 or other approved action-specific selectors override generic priorities in their scope.

Exclude expired or otherwise invalid candidates without mutating collections or running cleanup. Return no eligible match separately from invalid filter, missing required definition, unavailable collection or provider failure. A technical failure is not proof of empty inventory. Exact partial diagnostics for invalid records remain schema work; they cannot be hidden as successful emptiness.

Queries do not consume, transfer, clone, merge, reserve or grant access to an item. Revalidate selected identity/custody/quantity/eligibility/session at commitment, including delayed UI actions. A retired or merged reference cannot silently select a different item. No universal reservation mechanism is mandated.

### Copy, replacement and import

Copy is creation, not transfer. Only explicitly authorized generation/debug/content operations may create genuine copies with fresh identities and complete type-aware state handling. Source possessions remain unchanged; resulting copies require normal grant/admission and owner rules for limited resources, artifacts/unique rewards and providers. Ordinary inventory movement cannot clone souls/charges/entitlements by calling a copy helper. This feature does not approve universal copyability of every item.

Wholesale replacement/import is privileged restoration or another explicit authorized operation. Validate complete replacement, identity/custody compatibility, required reference cleanup and owner lifecycle effects before discarding old contents. Failure preserves the original collection. Imported existing references cannot create two owners; restore/scope reconstruction remains distinct from cloning. Detailed disposition of replaced items and references is part of the authorized operation, not an automatic clear-first convention.

### Results and commitment

Report moved, valid no-op, rejected, or explicit partial-batch result with moved/remaining counts, source and resulting identities, custody and reasons. Preserve completed operation facts so retry/observer callbacks cannot move or grant twice. Notifications report committed facts, not permission to repeat mutations. Delayed work checks active session as well as matching item IDs. Concrete receipt/API/signals remain implementation design.

## Relevant formulas and parameters

For ordinary transfer, total quantity across source/destination before equals total afterward; partial splitting and compatible merge redistribute entries without creating units. Both collection plans use approved caps/numeric bounds and actual cumulative admission. No new carry limit, price, theft chance, partial-batch packing formula or universal selection-pool priority is introduced. Copy creation is separately authorized and is not represented as quantity-conserving transfer.

## Required data

Stable source/destination/item/template/session/operation identities; custody/access and actor context; requested quantity/mode/filters; current availability and applicable restrictions; destination insertion/admission plan; owner lifecycle authorizations; resolved selections; moved/remaining/result identities and quantities; copy/replacement authorization/reference disposition and retained completion/recovery facts. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: pure filtered query; authorized single/bulk transfer; explicit copy/replacement/import request; owner access/capacity/lifecycle results; restore and deferred completion context. Outputs: selected identity/no eligible match/distinct errors; checked moved/no-op/rejected/partial results; created-copy or replacement outcome where separately authorized. Querying is not item-use, transfer or grant. Committed notifications cannot replay authoritative changes. Concrete APIs remain unselected.

## Cross-system interactions

ITEM-001 governs identity/custody/reference/session safety; ITEM-005 insertion/caps; ITEM-006 split/extraction/resource conservation. ITEM-002–004 retain provider/content/material/magic state and grant recovery. ITEM-008 owns carry/wagon capacity, ITEM-009 currency integration, ITEM-010–012 equipment/source lifecycle, ITEM-022/023/024 container access/quest/expiry and ITEM-025 persistence. QUEST/LAW/ECON authorize their restrictions and consequences, COMBAT-008 owns ammo selection, UI selects explicit modes and SAVE/CORE coordinate coherent restore. These dependencies are not finalized automatically by this feature.

## Edge cases and failure conditions

- Missing source member, stale session, invalid/over-available quantity or duplicate identity: reject before changing collections.
- Destination fails insertion/admission: single or atomic batch leaves both ends unchanged.
- Same source/destination: valid no-op, never self-clear or accidental merge/reorder.
- Partial move creates capped/merged destinations: report all identities and retain ITEM-001 reference semantics.
- Unavailable wagon/container or protected/equipped item: owner validation/authorized transition, no implicit bypass.
- Take-what-fits hits exclusions/capacity/error: truthful moved/remaining/recovery outcome, not complete success or source.Clear.
- Expired query candidate: no selection or cleanup mutation; technical failure distinct from no match.
- Replacement/copy failure: no clear-first loss, downgraded custom item or unauthorized duplicate limited resource.

## Configuration and balancing options

Validated filters, summoned preference, explicit batch mode and supported deterministic partial-batch profiles are available. Copy/replacement permissions remain explicit owner operations. No automatic stack consolidation, inventory-order priority, capacity bypass, arbitrary clone privilege or legality override is approved. Access/capacity/quest/effect policies remain their owners' rules.

## Save/load considerations

Persist coherent custody, quantities, identities/state and completed operation facts. Supported pending/bulk progress retains exact completed moves and recovery, not a fresh batch invocation. Otherwise temporarily block saving with a clear explanation until a supported boundary; action-specific save rules remain binding.

Load cannot replay transfer, duplicate copies/grants, clear source again or accept prior-session callbacks. Restore preserves distinct stacks under ITEM-005 and validates required definitions/providers/references before gameplay under CORE-013/ITEM-025. Missing required state needs migration/recovery rather than silently omitting items. Exact native operation/migration schemas remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate pure queries, explicit request modes, complete planning/owner admission and authoritative commit. Do not rely on remove-then-unchecked-add, add-all-then-clear, mutable UI indexes or engine handles for identity. Type-aware cloning/replacement needs explicit owner semantics. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Single transfer validates both ends and the full plan; success conserves quantity/state/custody, rejection leaves both collections unchanged.
2. Full/partial/merged transfer identities and results follow ITEM-001/005/006 without reference aliasing or unowned results.
3. Valid same-collection transfer is an explicit no-op without merge/reorder/remove/duplication.
4. Queries are pure, filtered and deterministic by stable identity; summoned-first uses shortest lifetime then identity, with approved action-specific rules retained.
5. Expired/invalid candidates are not selected; no eligible match differs from technical/definition/filter/unavailability failure.
6. Atomic batches validate combined effects and commit all or none; partial mode is explicit/deterministic and reports exact moves/remainders/reasons without clearing skipped items.
7. Owner access/capacity/quest/property/equipment/effect rules remain enforced without silent transitions or legality changes.
8. Copies require explicit authorization/fresh IDs/type-aware state; ordinary movement cannot duplicate resources or rewards.
9. Replacement/import validates full state/reference disposition before discard; failure preserves original and imported references cannot create duplicate custody.
10. Retries/save/load retain completed facts without repeated moves/grants; unsupported pending saves explain blocking and old-session callbacks are rejected.

## Contradiction review

Reviewed against approved ITEM-001–006 and COMBAT-008. No direct contradiction identified. Atomic single insertion remains unchanged; take-what-fits is an explicit batch contract reporting separate committed moves. Same-collection no-op does not replace standalone split or consolidation. Generic filters cannot override ammo-specific quest exclusion/priorities. Copy authorization does not waive limited-resource conservation or artifact restrictions. Replacement cannot silently destroy protected references. Future capacity/access/equipment/expiry features remain owner dependencies.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: source/destination admission and lifecycle schemas; batch planning/commit/receipt recovery; explicit partial-batch ordering and partial-quantity profile choices; query/filter/error/expiry schemas; copy/replace authorization and reference disposition; native pending-save/migration fixtures. Concrete partial-mode gameplay profiles require explicit owner decisions before support is claimed; these deferrals cannot waive custody/state conservation, truthful outcomes or no-replay guarantees.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-007-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented admission/lifecycle schemas, batch commitment/recovery, concrete partial-batch policies, query/error schemas, copy/replacement authorization/reference disposition and native persistence/migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
