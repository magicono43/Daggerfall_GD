# ITEM-015 — Item action routing and extension order

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Resolve deliberate item actions and coordinate quest/effect/UI handoff without accidental fallback actions or implicit repeated activation.

## Intended player experience

Use performs a predictable declared action. Players can select among known actions without activating hidden behavior. Quest messages, inventory closing and retries do not accidentally consume items, activate extra powers or lose committed progress.

## Confirmed requirements

- **ITEM-015-D01:** Define supported actions explicitly, such as Read, Drink, Activate power, Toggle light, Refuel and Change style. General Use resolves a declared default; unhandled routing cannot implicitly cycle appearance or invoke another behavior.
- **ITEM-015-D02:** Ordinary behavior and enchantment activation combine only through an explicitly declared ordered action. Reading/style changes/light toggles do not automatically fire every Used power. Approved artifact-specific actions remain binding.
- **ITEM-015-D03:** Actions declare inventory stay-open/close/yield behavior. Closing alone cannot commit gameplay, cancel unrelated UI or close a newly opened artifact/target interaction. Failure retains explicit recovery without another route.
- **ITEM-015-D04:** Profiles declare default action. Multiple actions without a valid default open action choice or require explicit selection, never registration-order choice. Explicit unavailable actions cannot fall back to others.
- **ITEM-015-D05:** Quest interception explicitly consumes, blocks, owns pending interaction or permits selected ordinary continuation. A message alone implies neither continuation nor consumption. Retried quest-use recording cannot duplicate events.
- **ITEM-015-D06:** Pure knowledge-aware action queries may show known blocked actions/reasons, but cannot reveal hidden powers, spend resources, generate content or activate quest events by opening a menu.
- **ITEM-015-D07:** One authoritative pending operation per interaction; duplicate requests cannot open another picker or repeat commitment. Conflicts reject or use declared cancel/replace policy. Window closure grants no automatic refund or abandonment of committed work.
- **ITEM-015-D08:** Composite actions declare required steps, commitment boundaries and later block/failure handling. Retain completed earlier effects; no automatic whole retry/rollback/fallback. Continuing after optional-step failure requires explicit supported policy.
- **ITEM-015-D09:** Supported pending snapshots retain selected action, stable item/provider/quest identities and completed phases; otherwise explain temporary save blocking. No load auto-confirm/quest-event repeat/reconsumption/unsupported reopening; reject old-session callbacks. Action-specific cancellation/save rules remain binding.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem` calls item override, quest handling, registered handler and built-in branches. Some quest handling consumes the click/returns to HUD, other paths continue after a message.
- Built-ins include books, potions, recipe rejection, map discovery, lights and oil; fallback calls NextVariant. A subsequent enchanted-item branch closes inventory then dispatches Used payloads, allowing implicit combination after a built-in branch.
- `Game/Items/DaggerfallUnityItem.cs#UseItem` and `ItemHelper.cs#GetItemUseHandler` provide extension entry points.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; source unchanged.

## Existing approved constraints

ITEM-002 already governs authoritative use behavior, explicit composition/outcomes, quest restrictions, deferred revalidation, recovery and save boundaries. ITEM-001–014 preserve identity/custody/knowledge/resources and checked mutations. MAGIC-016/027/030 own item powers, costs, pending pickers and artifact actions. ITEM-016–019 will own detailed readable/consumable/light/identification behavior; listing an action does not finalize those rules.

## Detailed rules and behaviors

### Explicit action resolution

Resolve supported actions through stable action/item/provider identity and validated profiles under ITEM-002. Example action families include Read, Drink, Activate power, Toggle light, Refuel and Change style; their detailed gameplay remains ITEM-016–019/MAGIC owner work. Naming an action is not permission to use every item through it.

General Use resolves the declared default. Multiple available actions without a valid default require action choice or explicit selection; registration timing/collection order cannot choose. A specifically requested unavailable action reports its outcome, without selecting another action. An item with no supported action reports that fact; do not use generic appearance cycling or enchanted activation as a catch-all fallback.

One resolved authoritative behavior owns action execution. Ordered composite behavior is explicitly declared, not independently chained overrides that happen to return false. Only ITEM-002 not-applicable permits progression to a next declared behavior; blocked/failed/handled/pending outcomes stop ordinary dispatch. Missing required providers or invalid routes are errors, not not-applicable results.

### Admission, knowledge and quests

All callers supply explicit actor/item/action/context and share authoritative identity/custody/access/eligibility/session checks under ITEM-002. Pure available-action queries respect knowledge and may explain a known blocked action. They cannot reveal hidden powers, generate contents, record quest clicks, spend resources or mutate appearance/equipment. Display menus are not gameplay commitment.

Apply access/quest protection before custom execution. Quest interception explicitly consumes, blocks, owns a pending interaction or permits the selected ordinary action to continue. A quest message alone has no automatic routing meaning. Record genuine quest-use facts at declared commitment once, not for hover/query or duplicate retries. Missing required quest/resource identity needs explicit failure/recovery rather than ignoring protection or invoking a generic action.

Approved artifact and action-specific MAGIC behavior remains binding. Ordinary Read/style/light behavior and Used powers combine only in an explicit ordered composite. Do not fire every Used power after a built-in action merely because the item is enchanted. A known Activate power action may delegate grouping/selection to MAGIC-016; this feature does not redefine its power costs/order.

### Pending operation and UI handoff

Each interaction has one authoritative pending operation with action/item/actor/session identity. Duplicate delivery cannot create a second picker or commitment. Conflicting requests reject or follow a declared supported cancel/replace policy; no universal queue, automatic cancellation or unlimited concurrency is selected.

Actions declare inventory stay-open, close or yield behavior and owned child interaction lifecycle. Close inventory without accidentally closing the new artifact/target window or unrelated UI. Window closure alone cannot commit use, refund costs or discard required recovery. CORE/UI suspension/input ownership remains its approved owner contract, not an unrestricted PopToHUD operation.

Deferred selections revalidate original item, custody/access, quest context, session, eligibility and resources at commitment. Retired/merged/replaced identity cannot silently retarget. Cancellation follows the selected action's approved cost/recovery semantics, including already committed MAGIC costs, rather than a universal no-cost/refund assumption.

### Composite commitment and recovery

Explicit composites declare step ordering, required/optional status, inputs, commitment boundaries and later block/failure handling. Preserve completed facts if a later step fails; do not blindly rerun earlier consumption/rewards/quest events or roll back arbitrary owner effects. Continue after an optional failure only under an explicit supported policy. This does not reinterpret blocked/failed as not-applicable general fallback.

Coordinate authoritative ITEM/MAGIC/QUEST/other owner mutations through their existing contracts. Pre-mutation rejection leaves state unchanged; partial technical commitment retains completed phases and explicit remaining obligations. Action routing grants no authority to mint rewards, bypass equipment/capacity or duplicate item use. Notifications report facts without independently repeating execution.

## Relevant formulas and parameters

No new action cost, damage, duration, consumption amount, style rule or quest trigger formula is approved. Detailed actions retain their existing owner formulas. One pending operation per interaction and declared composite ordering are lifecycle constraints, not a universal global action-count limit. Concrete default-action maps and result/API representations remain dependencies.

## Required data

Stable action/item/provider/actor/session/quest identities; action capabilities/default and knowledge visibility; access/eligibility and explicit quest outcome; ordered composite steps/optional rules/commitment boundaries; UI handoff/child ownership; pending selection/resources and completed phases/recovery. Exact schemas/provider versions and save representation remain dependencies.

## Inputs, outputs and events

Inputs: pure action query, general Use or explicit action request, quest interception result, deferred selection/cancel/replace, owner outcomes and restore/recovery. Outputs: known action choices, resolved default, handled/not-applicable/blocked/failed/pending outcomes, owned UI handoff and committed phase facts. Query/menu/window closure is not an item-use/quest-use event. Concrete APIs/signals remain unselected.

## Cross-system interactions

ITEM-002 owns the provider/dispatch framework; ITEM-001 and ITEM-003–014 retain identity/state/custody/resources and checked operations. ITEM-016–019 own detailed readable/consumable/light/knowledge actions. QUEST owns interception/resource use and MAGIC-016/027/030 own power/picker/artifact behavior. UI/CORE own presentation/input/suspension and SAVE reconstructs supported state. DATA/MOD validate action/provider resolution and compatibility. Future detailed actions are not finalized by the routing catalog.

## Edge cases and failure conditions

- Several actions but no valid default: choose explicitly, no registration-order execution.
- Explicit Drink unavailable: report without Read/style/Activate fallback.
- Enchanted readable/light: no implicit Used payload after ordinary action.
- Quest message: continuation depends on explicit outcome, not message presence.
- Missing quest/provider or stale item: explicit failure/recovery, not bypass.
- Duplicate picker/confirmation: one pending operation and no repeat commitment.
- Later composite failure: preserve earlier facts; optional continuation only declared.
- Closing inventory/new artifact UI: handoff preserves intended child and unrelated UI, no accidental spend/refund.

## Configuration and balancing options

Validated action capabilities/defaults, explicit ordered composites, quest outcomes, knowledge-safe visibility and UI handoff/pending conflict policies are moddable. No universal fallback action, hidden-power menu disclosure, automatic multi-power activation or unconditional continuation is approved. Costs/content remain owner profiles; policy registration timing cannot determine precedence.

## Save/load considerations

Only explicitly supported pending-state snapshots retain selected action, item/provider/quest/session context and completed phase/recovery facts. Other unresolved interactions explain temporary save blocking. Existing MAGIC and other action-specific save restrictions/cancellation rules remain binding; generic snapshot support does not authorize reopening every picker.

Native load cannot auto-confirm, repeat quest events, consume again, replay earlier composite steps or reopen unsupported interactions. Required missing action/provider/quest state needs explicit migration/recovery, not fallback to a different action. New sessions reject old callbacks even when saved item IDs match. Exact compatible reconstruction/cancellation and save schemas remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate pure capability query, explicit selection, authoritative dispatch/owner commitment and UI ownership. Use stable action/item/context identity rather than widget location, implicit globals or class-name routing. No universal scripting language, queue or transaction framework is mandated. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. General Use selects a declared default or requires explicit choice; unavailable explicit requests never fall back to another action.
2. Ordinary/enchanted combinations execute only through declared ordered actions, retaining approved artifact/power rules.
3. Provider outcomes preserve ITEM-002 semantics; required failures cannot masquerade as not-applicable.
4. Quest interception explicitly consumes/blocks/pends/continues, with no duplicate use event or implied message behavior.
5. Action queries/menu previews are pure and knowledge-safe without content generation, spend or quest activation.
6. UI stay/close/yield follows owned handoff without unrelated/new-window closure or closure-driven gameplay commitment/refund.
7. One pending operation per interaction prevents duplicate picker/commitment; conflicts require declared policy and deferred commitment revalidates context.
8. Composite later failures retain earlier facts; no automatic whole retry/rollback/fallback or undeclared optional continuation.
9. Save/load preserves supported phase state without auto-confirm/replay/reconsumption/unsupported reopening; unsupported pending saves explain blocking and stale callbacks reject.

## Contradiction review

Reviewed against approved ITEM-001–014, especially ITEM-002, and MAGIC-016/027/030. No direct contradiction identified. This refines action selection/UI ownership without reopening provider outcome/quest protection rules. Explicit optional-step continuation remains inside the declared composite, not general failed-handler fallthrough. Known actions do not reveal hidden item powers. Existing artifact/picker cost/save rules override generic assumptions; detailed ITEM-016–019 actions remain dependencies.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: concrete action/default/visibility schemas; quest outcome/resource contracts; composite commitment/optional failure receipts; UI handoff/pending ownership and conflict policies; per-action content/cost/cancel rules; native pending snapshot/migration fixtures. Concrete unresolved action profiles require explicit owner decisions before support is claimed. These cannot waive explicit routing, quest protection, knowledge boundaries or no-replay guarantees.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-015-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented action/default/visibility schemas, quest outcomes, composite commitment/recovery, UI pending ownership, per-action rules and native snapshot/migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
