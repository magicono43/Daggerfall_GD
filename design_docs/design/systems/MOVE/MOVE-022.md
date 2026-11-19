# MOVE-022 — Loot and property prompts

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Route loot, private containers, shop shelves and dungeon wagon access deliberately, preserving ownership and capacity rules without duplicate items or rerolled contents. Inspection, acquisition, commerce and legal consequences remain distinct.

## Confirmed requirements

MOVE-022-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. MOVE-018/019 targeting/Info, MOVE-005 inventory-only encumbrance and CORE context/persistence contracts remain binding. ITEM/ECON own contents/transfers and LAW legal consequences.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source relative to reference `Assets/Scripts/`:

- `Game/PlayerActivate.cs#ActivateLootContainer` routes shop shelves to trade when the stored open-shop flag permits, otherwise theft inventory. Household containers distinguish owned house/ship context, stocking and private-property prompts.
- Corpse Info shows descriptions; empty corpses report no treasure and `DisableEmptyCorpseContainer` disables a sphere collider. Arrow-only contents can transfer automatically.
- Stocking branches use dates and `OnLootSpawned`; activation also reseeds Unity randomness. Target results must follow approved RULE randomness/retention rather than copying frame reseeding.
- `DungeonWagonAccess_OnButtonClick` distinguishes wagon inventory from dungeon exit using a Yes/No prompt. Target adds an explicit Cancel outcome.

Static inspection only; no runtime verification or source changes. Source branches do not automatically approve Info stocking, capacity bypass or broad owned-ship identity assumptions.

## Detailed rules and behaviors

### Inspection and property

Opening/inspection and item transfer are separate. Opening does not transfer ownership; LAW explicitly defines whether private inspection itself has consequences. Taking separately checks ownership/access.

Retain confirmation before eligible non-player household inspection. Valid player-owned house/ship storage opens without that warning. Confirmation revalidates original stable container, reach, permission and context under MOVE-018. Cancellation transfers nothing and cannot authorize content rerolls. Ownership uses validated target identity, not merely owning any ship or house.

Info remains descriptive: no auto-collection, container opening, trade or implicit quest click under MOVE-019. Prompt and routing policies are moddable through validated contracts, not unrestricted bypass of ownership/target checks.

### Shops and content generation

Current open/authorized shop context routes browsing to trade. Closed/unauthorized shelves use explicit theft/property policies. Revalidate purchases/transfers against current context; an old entry-time open flag cannot retain buying permission. No automatic purchase or theft occurs merely because inventory UI is shown.

ITEM/ECON own stocking/restocking as authorized operations with retained results and exactly-once publication. Info, hover, cancelled private prompts or reopening UI cannot reroll contents. Restock timing, inventory definitions and randomness follow their owner contracts; this feature selects no restock frequency or stock table. Required preparation failure uses explicit recovery without exposing partially published contents or silently regenerating.

### Corpses and automatic arrows

Empty corpses provide concise feedback while remaining eligible for Info and valid quest interactions. Loot cleanup cannot disable unrelated target behavior or permanently hide later legitimate contents. Exact visual/removal lifetime is LOC/ITEM scope.

Retain a moddable arrow-only corpse shortcut. Collect the maximum eligible quantity fitting ITEM capacity, leaving remainder with concise partial/full-capacity feedback. Failed collection leaves items safely in source; no duplication or weighted-admission bypass. Do not auto-select arrows from mixed loot or convert stolen/owned arrows to lawful property. ITEM owns stacking, quantity eligibility, weight rounding and transaction validation.

### Dungeon wagon access

At a valid dungeon exit, optional owned-cart prompt offers Access wagon, Leave dungeon and Cancel. Access opens authorized wagon storage without exiting. Leave follows validated exterior placement. Cancel performs neither.

Revalidate cart ownership, original exit and applicable context before action. ITEM/LOC own storage reach/availability and MOVE-026/027 exit readiness. Missing cart/exit cannot retarget another container or bypass placement. Other save/input/pause requests retain ownership.

### Transfer commitment and restoration

Committed item moves publish once across source/destination. Closing UI, loading or technical retry cannot duplicate items, lose committed source deductions or reroll generated stock. Retain ownership metadata and generated contents in native persistence. Exact atomic publication/partial-failure recovery and save boundaries belong to ITEM/SAVE; no generic rollback of arbitrary item effects is promised.

Supported restored loot UI must revalidate stable target/access/context before continuing. Raw scene references, stale click callbacks and pending physical input are transient. UI reconstruction is not another inspection, generation or transfer event. Required ownership/content mismatch invokes explicit compatibility/recovery rather than silently assigning new contents.

## Relevant formulas and parameters

Automatic arrow quantity is the maximum eligible quantity admitted by ITEM's validated capacity/stack policy, bounded by actual source quantity. No weight conversion/rounding or restock interval is selected here. Reach retains MOVE-018 category rules, with separate Info permissions under MOVE-019. No new theft probability or legal penalty is introduced.

## Required data

Stable container/owner/type identity, generated/stocked content state, source/destination quantities and ownership metadata, current shop/access status, deferred intent/prompt result, transfer identity/completion and wagon/exit context. Concrete schemas and commit markers remain ITEM/SAVE dependencies.

## Inputs, outputs and events

Inputs: eligible activation/mode, property confirmation, current shop/ownership state, authorized generation and transfer requests, dungeon prompt choices and restored UI. Outputs: descriptive response, checked trade/loot UI target, retained content publication, once-only transfer result, legal-context notifications and validated exit. API names remain unselected. Preview or prompt creation is not an item acquisition.

## Cross-system interactions

MOVE-018/019 targeting/Info, MOVE-020 access context, MOVE-016 cart/ownership and MOVE-026/027 exit placement; ITEM contents/capacity/transfer, ECON stock/trade, LAW inspection/taking legality, QUEST explicit reactions, LOC target/lifetime, UI prompts, CORE context/readiness, RULE randomness and SAVE durable state. MOD/DATA define validated routing/prompt extensions.

## Edge cases and failure conditions

Test capacity-limited arrow stacks, mixed loot, changed ownership/reach during prompts, empty corpses later receiving contents, shop closing while UI is open and missing wagon on confirmation. No stale open-shop flag or reused target ID can authorize transfer. Failed generation/transfer cannot silently retry after partial mutation. Optional feedback failure cannot duplicate completed moves. Info cannot reveal hidden inventory by generating it first.

## Configuration and balancing options

Property prompts, shop routing and arrow shortcut are moddable through supported validated policies. Contents, restock, theft and capacity definitions remain their owners. No automatic mixed-loot pickup, ownership laundering, universal inspection crime or new capacity exception is introduced.

## Save/load considerations

Persist authoritative source/destination contents, retained generation/restock state and ownership once. Supported pending UI retains stable intent and revalidates; unsupported state needs declared restriction/recovery rather than silent loss. Do not serialize raw UI/scene objects as authority. Completed item movement cannot be replayed from restored presentation.

## Technical constraints

Target: Godot 4.7.2. Separate inspection, authorization, content preparation, transfer commitment and presentation. Scope-safe stable identities and checked outcomes are required; concrete inventory APIs, transaction/save mechanism and UI routes remain choices to verify. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Inspection and taking remain distinct; eligible private prompts respect ownership and revalidate original target without transfer on cancel.
2. Info cannot generate/open/collect implicitly; player-owned storage bypasses warning only for validated ownership.
3. Current shop authorization controls routing/purchases; old open flags cannot bypass changed context.
4. Authorized generation publishes retained contents once; hover/cancel/reopen/load cannot reroll.
5. Arrow-only shortcut takes maximum eligible fitting amount, leaves remainder and obeys capacity/ownership without mixed-loot selection.
6. Empty-body feedback preserves Info/quest targeting and later legitimate contents.
7. Wagon Access/Leave/Cancel are distinct and revalidate ownership/original exit; access does not exit.
8. Transfer/native restore cannot duplicate items, replay costs or reroll stock; supported restored UI revalidates context.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-005/016/018–020 and CORE context/restoration principles. No direct contradiction identified. Arrow convenience is subject to existing weighted admission. Info safety prevents source stocking side effects. Private inspection legality remains LAW-owned without assuming opening equals theft. Current shop revalidation complements entry-time status. Exactly-once publication is a required contract with concrete ITEM/SAVE boundaries still unresolved.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: ownership/inspection legality, stock/restock schemas/randomness, exact transfer/capacity rounding and commit boundaries, target lifecycle, wagon reach, restored UI support and native/concurrency fixtures. These do not waive no rerolls, no duplication or target revalidation.

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under MOVE-022-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented ownership, content, transfer, persistence and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
