# ITEM-014 — Repair jobs

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Track accepted repair custody, agreed terms, game-time completion and safe item return without lost possessions or replayed payment/restoration.

## Intended player experience

Players know what repair costs, when it finishes and where to retrieve the same possession. Accepted jobs keep their terms through travel and saves. Failed pickup or unavailable services preserve the item and paid obligation.

## Confirmed requirements

- **ITEM-014-D01:** Accepted jobs place the original item in explicit service custody, preserving identity/contents. Player equip/use/sale/transfer is unavailable until authorized collection/cancellation returns it. Quote selection alone does not surrender custody.
- **ITEM-014-D02:** Show eligibility, price, restoration scope and completion time before confirmation. Acceptance coordinates payment, custody and durable job record; rejection unchanged. Later prices/new work cannot silently rewrite accepted terms.
- **ITEM-014-D03:** Progress uses game-world time including authorized wait/travel, independent of loaded service scene. Closed-game wall-clock time grants no progress. At/after agreed completion the job becomes ready once.
- **ITEM-014-D04:** Ordinary eligible repair restores condition to the agreed maximum without maximum loss, preserving identity/material/enchantments/knowledge/contents and not refilling separate charges. Explicit mod profiles may define quoted partial repair, maximum loss or recharge services.
- **ITEM-014-D05:** Baseline collection is from the original service using stable service/location identity, not scene-name text alone. Current access and destination capacity required. Failed collection retains ready item in service custody without another repair fee. Alternate pickup/delivery requires explicit mod/service policy.
- **ITEM-014-D06:** Baseline independent per-item completion uses RULE-023 durations. New jobs cannot delay accepted jobs. Mod queues/shared workload must quote effects before acceptance and preserve prior terms unless separately authorized changes are accepted.
- **ITEM-014-D07:** Before completion, cancellation returns submitted condition without refund by default. Disclose terms before acceptance/cancellation. Mod refunds/partial-work recovery require explicit policies. Return still validates access/capacity.
- **ITEM-014-D08:** Completed items remain collectible indefinitely without default storage fees/degradation/forfeiture. Mod alternatives require explicit policies disclosed before acceptance.
- **ITEM-014-D09:** Temporary service closure blocks collection while preserving the job. Permanently missing service/location/provider requires explicit recovery/migration preserving item and paid obligation, not deletion/replacement/invented pickup location.
- **ITEM-014-D10:** Apply agreed repair once at game-time completion in service custody. Collection returns the completed item without repairing again, equipping or reactivating powers. At completion equality, completed collection rules replace early cancellation.
- **ITEM-014-D11:** Reject expiry/quest/curse/provider conflicts with custody unless an explicit compatible profile handles them. Repair custody cannot pause expiry, remove curses or bypass quest protection implicitly.
- **ITEM-014-D12:** Persist stable job/item/service IDs, submitted condition, accepted scope/price/schedule/cancellation terms, payment facts and completion/return progress. No load repricing/timer restart/double repair/refund/return. Unsupported pending settlement explains temporary save blocking; technical failures retain recovery obligations.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

Fourth interview confirmed D10–D12 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Items/ItemRepairData.cs`: stores sceneName/timeStarted/duration, game-time finished check, collection clearing and native record. Remaining-day subtraction uses unsigned timestamps and can underflow after completion.
- `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#UpdateRepairTimes`: estimates/commits item durations, combines batch workload and can extend existing schedules. Other trade paths handle condition restoration/payment/collection.
- `DaggerfallMerchantRepairPopupWindow` routes merchant interaction into repair-mode trade UI.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; source unchanged.

## Existing approved constraints

RULE-023 owns fee/per-item duration formulas and retained accepted terms, not batch queues/custody. ITEM-013 owns repairability/broken state and prohibits destroyed-ID resurrection/implicit separate-charge restoration. ITEM-001–012 preserve identity/state/custody, checked transfers/payments and lifecycle. ITEM-009 owns explicit tender/valuation; ECON owns service settlement and TIME the game clock.

## Detailed rules and behaviors

### Eligibility and quote

Resolve the actual item and service using stable identity, current access, supported repairability and active session context. ITEM-013 governs retained broken eligibility; destroyed items cannot be resurrected. Enchanted/artifact repair requires explicit support, not merely retention or affordability. Equipped items need an explicitly coordinated ITEM-010/011 removal before service custody; quote selection cannot unequip them.

Reject incompatible expiry, quest, curse or required-provider lifecycles unless an explicit profile supports custody and repair. Holding an item cannot silently suspend expiry, cure curses or bypass protection. Required service/provider unavailability is distinct from ordinary ineligibility. Full-condition ordinary items need no repair under RULE-023, not a minimum-priced new job.

Use approved RULE-023 fee and per-item duration calculations, with current authorized ECON/FACT/TIME context. Before acceptance show eligibility, accepted tender/fees, restoration scope, completion and cancellation/collection terms. Pure quotes do not repair, pay, transfer custody, identify hidden powers or advance game time. Materially changed terms require renewed acceptance under ITEM-009/RULE-023.

### Acceptance and custody

Validate the complete payment, item handoff, owner lifecycle and durable job plan before acceptance. Rejection leaves money, items and job state unchanged. Successful acceptance retains the original identity/contents in explicit service custody, with accepted terms recorded. Player inventory actions cannot equip/use/sell/transfer the held item; UI references do not create another authoritative copy.

Coordinate any already committed external facts with explicit recovery instead of repeating payment or losing the job/item. Concrete commit/receipt APIs remain open; no generalized transaction framework is mandated. Batch payment/custody admission must declare supported whole-batch or explicit per-item settlement, not silently report success for failed items.

### Schedule and restoration

Baseline jobs finish independently at acceptance game time plus their agreed per-item RULE-023 duration. New work does not extend old jobs. Mod queue/shared-workload profiles are supported only with explicit quoted effects; already accepted terms remain binding absent a separately authorized accepted change.

Progress uses authoritative game-world time, including authorized waits/travel, without requiring a loaded service scene. Closed-game wall-clock time grants no progress. At now >= scheduled completion, apply the agreed repair once and mark ready coherently while retaining service custody. Reconstruction/query after unloaded time reconciles due completion before exposing actionable state, without replaying it.

Ordinary repair restores to agreed maximum without maximum loss, preserving item identity/material/contents/enchantments/knowledge. It does not refill separate charges, identify, equip, activate powers or clear suppression/curses. Explicit mod profiles may quote partial repair, maximum loss or recharge under compatible owners. Accepted scope is not permission to silently apply a changed current template; incompatible profile/maximum changes require explicit recovery/migration.

Completion resolves ITEM-013 repair/break state through its authorized above-zero restoration rules, without replaying Breaks or resurrecting retired identities. Apply completion once regardless of UI visits, repeated queries or load. At exact completion, use completed collection rather than pre-completion cancellation.

### Collection, cancellation and overdue custody

Collect from the original stable service/location under baseline rules. Validate current access, item/job identity and destination ITEM-007/008 admission before return. Collection transfers the already-repaired item, not another restoration/equip event. Failure retains ready custody without another repair fee. Alternate delivery/pickup requires explicit service/mod policy; no automatic wagon or remote fallback.

Before completion, baseline cancellation returns submitted condition without refund. Disclose this before initial acceptance and cancellation; check return access/capacity before finalizing cancellation. Failure to return preserves custody/job obligations rather than leaving an unowned item. Concrete mod refund/partial-work profiles may differ when quoted and supported. Cancellation after completion is not a way to recover submitted state or obtain a refund.

Ready items remain collectible indefinitely by default, with no storage fee, degradation or forfeiture. This retention rule does not override an independently declared item expiry lifecycle; conflicting items require D11 compatibility before acceptance. Mod storage/forfeiture rules require explicit pre-acceptance disclosure and compatible ownership/quest policies.

Temporary closure blocks collection, not job existence or scheduled game-time progress. Permanent missing service/location/provider requires explicit recovery/migration preserving possession and paid obligation. Do not silently delete, replace, refund or invent a pickup location. Concrete recovery destinations/remedies require owner policy.

### Job results and recovery

Distinguish quoted, accepted/in progress, ready, returned, cancelled/returned and explicit recovery states, with sufficient phase facts for partial technical failures. These are conceptual outcomes, not a required enum/API. Revalidate delayed item/service/custody/session context before actions. Duplicate callbacks cannot pay, complete, refund or return twice; historical job receipts cannot grant another usable item.

## Relevant formulas and parameters

Use approved RULE-023 formulas: for damaged items, repair fee seed max(1,trunc(10×baseValue/100)) followed by declared regional/shop/guild/bargaining/paid-minimum stages; explicit free outcomes remain free. Duration for missing raw condition D is max(one game day,trunc(D×secondsPerDay/1000)); full condition means no service, not one day. Owner overrides retain declared units/rounding and accepted terms.

Baseline scheduled completion = accepted start game time + accepted duration, with checked arithmetic. Remaining time = max(0, completion − now); displayed remaining days = ceil(remainingTime/secondsPerDay), without unsigned underflow. Ordinary restoration reaches the agreed maximum, not a new template-derived maximum. No new queue formula, refund rate, storage fee or real-time progress is approved.

## Required data

Stable job/item/service/location/session/operation IDs; submitted condition and actual retained item state; accepted scope/target maximum, price/tender/payment facts, start/duration/completion, cancellation/collection/storage terms; custody/access/provider compatibility; lifecycle phase/completion/return/refund/recovery facts. Concrete schemas and quote retention policy remain dependencies.

## Inputs, outputs and events

Inputs: pure quote/status queries, explicit acceptance/cancellation/collection, authorized game-time advance, owner payment/custody results and native restore/recovery. Outputs: quote/rejection, durable accepted job, ready completion, returned/cancelled item or explicit blocked/recovery result. Inspection and presentation do not start jobs or advance the clock. Committed notifications report facts without repeating repair/payment/return. Concrete APIs/signals remain unselected.

## Cross-system interactions

RULE-023 owns fee/duration calculation; ECON service payment/tender and FACT benefits; TIME authoritative game clock. ITEM-001–009 retain identity/custody/state/weight/payment; ITEM-010–013 manage unequip, curses, powers and condition repair/break guards. QUEST and MAGIC validate protected/expiring/source state. WORLD/LOC supply stable service identity/access; UI shows accepted terms/status/reasons and SAVE/CORE preserve coherent progress. Future ECON/repair content is not finalized automatically.

## Edge cases and failure conditions

- Full-condition, destroyed or unsupported magical item: no fabricated job/repair permission.
- Changed quote, missing funds or failed custody handoff: reject unchanged or retain truthful already committed recovery facts.
- New jobs at the same service: no unaccepted delay to existing jobs.
- Time advances beyond completion while unloaded: ready once, nonnegative remaining time, no underflow/repeated repair.
- Collection exceeds carry capacity or service closes: item stays safely held, no repeat fee/automatic alternate destination.
- Cancellation arrives exactly at completion: completed rules, not no-refund submitted-condition rollback.
- Item expiry/curse/quest conflict: explicit compatible profile or reject, not implicit pause/cure/protection bypass.
- Missing service/provider on load: explicit recovery preserves item/payment obligation, not fake empty custody.

## Configuration and balancing options

Validated repairability/service scope, price/duration overrides, mod queue/shared workload, cancellation/refund/partial work, alternate collection/delivery and disclosed storage profiles are supported. Baseline independent schedules, no-refund early cancellation and indefinite free ready storage remain defaults. No universal magical repair, automatic recharge, artifact resurrection or invented inaccessible-service remedy is introduced.

## Save/load considerations

Persist original item/service custody, accepted terms, submitted condition and completed payment/repair/return/refund phases. Restore using game time without repricing, timer restart, offline wall-clock progress or fresh random results. Reconcile due completion once before gameplay exposes actionable job state; never repair/return twice or activate item powers through reconstruction.

Changed/missing definitions/services/providers require explicit compatibility/migration/recovery, preserving possessions and obligations. Supported pending settlement retains exact completed facts; unsupported pending saves are temporarily blocked with explanation. New session scope rejects old callbacks. Exact schemas and error recovery fixtures remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate calculation/quote, authoritative job/custody, clock-driven completion, payment/return settlement and UI. Use stable service identity rather than scene names, explicit job state rather than timestamp-zero sentinels, and checked time arithmetic. No particular queue/ledger framework is mandated. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Quote selection mutates nothing; accepted original item enters service custody with checked payment and durable terms, rejection unchanged.
2. Player cannot use/equip/sell held items; identity/contents and authorized lifecycle remain preserved.
3. RULE-023 independent schedules progress by game time unloaded, not closed-game wall time; new work does not silently delay existing jobs.
4. Due completion applies agreed scope once, without maximum loss/charge refill unless explicitly quoted, then keeps ready custody.
5. Original-service collection validates access/capacity and returns without repair/equip/power replay; failure retains item without repeat fee.
6. Before-completion baseline cancellation returns submitted condition/no refund with disclosed terms and checked return; completion equality uses ready rules.
7. Ready storage is indefinite/free/no degradation by default; mod alternatives are explicit/disclosed and compatible with separate expiry/protection.
8. Temporary closure preserves job/progress; permanent missing service/provider yields explicit recovery without silent loss/substitution.
9. Conflicting expiry/quest/curse/provider profiles reject unless explicitly supported; repair cannot cure/pause/bypass implicitly.
10. Native restore/retry preserves terms/phases without repricing/restart/double repair/refund/return; unsupported pending saves explain blocking and old-session callbacks fail.

## Contradiction review

Reviewed against approved ITEM-001–013 and RULE-023, with TIME/ECON owner boundaries. No direct contradiction identified. Independent baseline schedules intentionally differ from reference batch rewriting while preserving accepted terms. Physical custody and collection admission retain ITEM-007/008 guarantees. Repair authorization follows ITEM-013 and cannot resurrect destroyed magical/artifact items. Indefinite service retention does not suspend independently approved expiry. Concrete magical repair/recharge and recovery remedies remain explicit profiles, not automatic permissions.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: service/job/custody/time schemas and numeric bounds; eligibility/scope and expiry/curse/quest compatibility; batch payment/admission semantics; accepted-quote/settlement receipts; cancellation/refund/delivery/queue profiles; permanent-service recovery remedies and native migrations/fixtures. Concrete unresolved gameplay profiles require explicit owner decisions before support is claimed. These cannot waive retained terms, custody, once-only completion or safe return.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-014-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented service/job/custody/time schemas, eligibility/lifecycle compatibility, batch settlement, receipts, mod service profiles, permanent-service recovery and native migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
