# ITEM-021 — Shop shelves and household stock

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Populate context-specific stock and refresh eligible generated contents without erasing persistent possessions or rerolling through inspection.

## Intended player experience

Shops and households have stable context-appropriate contents until an authorized refresh. Player storage persists, purchases/theft deplete actual stock, and midnight or loading cannot replace a selected item or erase deposits.

## Confirmed requirements

- **ITEM-021-D01:** Distinguish generated shop/household stock from player deposits, quest additions and persistent possessions. Refresh replaces only policy-governed stock, never indiscriminate collection clearing.
- **ITEM-021-D02:** Player-owned house/ship storage is persistent without automatic stocking/refresh by default. Verify specific property/container ownership. Ownership changes require explicit content disposition.
- **ITEM-021-D03:** Initial ordinary shop/non-player household refresh is calendar-day based, one retained refresh per eligible day. Lazy authorized-access evaluation supported; missed days do not accumulate stock piles. Intervals/models moddable.
- **ITEM-021-D04:** Initial profiles retain inspected DFU building/group, shop quality/rarity and household furniture-category table data under approved probability/construction rules. Explicit level/appearance context and validated replacement pools/distributions; no automatic all-registration inclusion.
- **ITEM-021-D05:** Deliberately sold items become merchant-owned stock governed by declared refresh/disposal policy, distinct from deposits/storage/protected quest items. No guaranteed buyback absent explicit ECON policy.
- **ITEM-021-D06:** Defer due replacement while a live stock selection/pending transaction exists. At coherent boundary refresh/invalidate stale selections/requote; midnight cannot swap confirmation targets or erase committed purchases.
- **ITEM-021-D07:** Purchase/theft depletion persists until authorized refresh; empty results retained. Reopen/cancel/UI mode changes cannot refill. Refresh cannot erase theft consequences or alter retained-possession ownership.
- **ITEM-021-D08:** Prepare/validate full replacement before retiring eligible old stock or advancing successful-refresh marker. Failure preserves contents and retained generation for recovery; post-refresh notifications cannot repeat generation/additions.
- **ITEM-021-D09:** Persist stable container/property ID, provenance/contents/ownership, last successful refresh and deferred/incomplete facts. Load is not new-container generation or same-refresh reroll. Overdue evaluation uses authorized policy preserving deposits/protected items.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Internal/DaggerfallLoot.cs#CreateStockedDate`: year×1000+day-of-year marker. `StockShopShelf` marks date/clears contents and uses building group tables, quality/rarity and player construction context. `StockHouseContainer` marks/clears and uses building/furniture-model tables.
- `Game/PlayerActivate.cs` shop/house branches compare date markers and stock on access; route shop buy/theft/private prompts; player-owned house/ship path bypasses household stocking. Source broad ship-ownership check is not approved specific-container ownership.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; source unchanged.

## Existing approved constraints

ITEM-020 owns explicit generation context, retained results, whole-result publication and protected additions. ITEM-001–019 preserve identity/custody/knowledge/quantity and checked transfers/payment. MOVE-022 separates inspection/property/commerce and prohibits Info/prompt/reopen rerolls; current shop context revalidated. ECON owns transaction/service acceptance, TIME calendar and LOC/WORLD stable containers/properties.

## Detailed rules and behaviors

### Container identity and content disposition

Use stable property/building/container identity and explicit stock policy/provenance. Distinguish generated shop/household stock, sold merchant-owned items, player deposits and protected quest/persistent additions. Refresh can retire/replace only entries authorized by its policy. Shared template identity alone does not authorize clearing an item; stacking must preserve distinctions or keep entries separate under ITEM-005.

Player-owned house/ship storage is persistent with no automatic stocking/refresh by default. Validate ownership against the actual property/container, not ownership of any ship/house. Changes of ownership need explicit retained-content/access disposition before support is claimed. No implicit gift of household stock, forfeiture of deposits or generic cleanup follows a boolean ownership change.

Items deliberately sold become merchant-owned stock eligible for its declared refresh/disposal. They are not player deposits or guaranteed buyback. Protected/quest constraints still apply. ECON must explicitly define any buyback interval or special disposition; this feature does not grant universal storage access in a shop.

### Stock construction and baseline data

Initial data uses the inspected DFU building-type/item-group, shop-quality/rarity and household furniture-category tables in `DaggerfallLoot`/`DaggerfallLootDataTables`. Interpret them through approved RULE probability and ITEM construction semantics, with explicit source/profile identity. This adopts data/profile structure, not global current-player lookups, clear-first mutation or an unverified claim of classic parity.

Shop profiles declare building type, quality, eligible pools and rarity selection; household profiles declare building/container category and eligible property pools. Level/scaling and intended appearance inputs are explicit under ITEM-020/003 rather than automatically current-player context. Exact caller assignments and construction distributions must be extracted/validated before support is complete.

Validated mods may replace/add pools/distributions and schedule models. Registration alone does not include every added item. Generated quantities/condition/knowledge/special contents follow approved constructors, with artifact/provider restrictions. Required failures are errors, not missing items silently skipped from stock. Valid empty stock is a retained success.

### Calendar refresh

Initial ordinary shop/non-player-house profiles refresh by game calendar day, with one retained refresh per eligible day. Lazy evaluation on authorized access is permitted; missed days produce no accumulated stacks of past inventory. New refresh has explicit generation/source/day identity and ITEM-020 owned randomness; reopening/retry cannot produce a different result for the same refresh.

Purchases/theft reduce actual contents until next authorized refresh. Info/hover, cancelled private-property prompts and repeated UI mode changes cannot authorize refill or new randomness under MOVE-022. Due refresh evaluation is separate from a view refresh and must occur only at a policy-authorized boundary; no automatic calendar mutation is assigned to every display call.

Current shop/private-property access remains MOVE-022/LAW/ECON-owned. Stocking does not grant purchase permission, make theft lawful, clear incidents/reputation, or transfer ownership. Current context must be revalidated for acquisition; an old shop-open state is insufficient.

### Live interactions and publication

Defer due replacement while a live stock selection/pending transaction could be invalidated. At a coherent boundary apply refresh, invalidate stale intents and requote as required; never swap a confirmation target at midnight. Already committed purchases retain their moved items and settlement facts. Exact interaction ownership/release protocol is required integration work, not permission for an indefinite hidden lock or unilateral interruption.

Prepare and validate complete new stock and disposition of eligible old stock before retiring anything or advancing the successful-refresh marker. Preserve deposits/protected additions. Validate identity, custody, state, source lifecycle and actual container admission under ITEM-005–007/020; player carry capacity applies to taking items, not generated world stock size.

On ordinary validation failure preserve existing collection/marker and retained generation results. If a technical boundary partially committed, retain true phases and explicit recovery rather than reroll or blind whole-refresh retry. Post-publication notifications report committed stock; loot-changing extensions are declared pre-publication stages, not mutable repeated observer additions. No generalized transaction framework is mandated.

## Relevant formulas and parameters

Baseline interval is one game calendar day for eligible ordinary profiles. Compare authoritative calendar/day identities, including year rollover; do not infer robust native identity from DFU's year×1000+day encoding or use timestamp zero as both unstocked and valid empty.

Inspected shop selection includes rarity <= shop quality and a source chance expression `chanceModifier × 5 × (21 − rarity) / 100`; baseline extraction must preserve its integer rounding and approved probability endpoints. Book counts, potion quantities and household continuation/pools also require faithful data/profile fixtures rather than silently replacing them with ITEM-020's distinct dungeon-category model. No universal player scaling, buyback duration, refresh quantity cap or catch-up stock multiplier is selected here.

## Required data

Stable property/building/container/policy/generation/session identities; specific ownership and access; item provenance/disposition; building quality/type and container category; explicit pools/context and retained generated item state; last successful calendar refresh/empty state; live interaction/deferred refresh and publication/recovery facts. Exact schemas and date boundaries remain dependencies.

## Inputs, outputs and events

Inputs: authorized initial stocking/eligible-day evaluation, explicit policy/source context, transaction selection/settlement, ownership/content changes and native restore. Outputs: retained prepared stock, committed replacement/empty result, deferred refresh or explicit rejection/recovery. UI refresh/Info is not a stock-generation event. Notifications cannot repeat mutation. Concrete APIs/signals remain unselected.

## Cross-system interactions

ITEM-020 owns random generation/publication; ITEM-001–019 preserve item/custody/provenance/knowledge/payment and checked acquisitions. MOVE-022 owns shop/private-property routing and inspection boundaries; ECON merchant ownership/sales/quotes; LAW legal consequences. TIME supplies calendar, WORLD/LOC stable property/container identity and DATA/MOD validated profiles/tables. QUEST protects additions and SAVE/CORE restore coherent stock history. Future buyback/access/restock content is not finalized automatically.

## Edge cases and failure conditions

- Empty or fully stolen/purchased stock: retain depletion until authorized refresh, no reopen reroll.
- Year rollover/several missed days: one eligible latest refresh, not historical stock accumulation.
- Midnight during selection/payment: defer replacement, preserve exact target and committed purchases.
- Player deposits/quest additions mixed with generated entries: preserve or reject unsafe representation, never indiscriminate clear.
- Owns a different ship/property: no generic ownership bypass for this container.
- Provider/construction/overflow/disposition failure: preserve stock/marker/results for explicit recovery.
- Merchant-sold item: disposition explicit merchant policy, no assumed buyback or player-storage guarantee.

## Configuration and balancing options

Validated building/container pools, quality/rarity distributions, explicit level/appearance contexts, refresh intervals/models and governed-stock disposition are moddable. Player-owned storage remains nonrefreshing by default. No automatic player-deposit permission, all-mod inclusion, missed-day accumulation, legal reset or guaranteed buyback is introduced.

## Save/load considerations

Persist stable source/property/container IDs, contents/provenance/ownership, successful refresh identity and retained empty/deferred/incomplete results. Load reconstructs the same source, not a fresh container; same refresh cannot reroll or duplicate additions. Evaluate overdue state only through the same authorized schedule/coherent-boundary policy.

Preserve deposits/quest state and current transaction facts. Changed/missing profiles/containers require explicit migration/recovery without replacing an unrelated container or discarding possessions. Supported pending snapshots retain phases; unsupported boundaries explain temporary save restriction under ITEM-002/020/CORE. Reject old-session callbacks. Exact native schemas/migrations remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate stock policy/provenance, calendar eligibility, generation, ownership/access, transaction coordination and display. Stable IDs replace scene names and broad ownership flags. No clear-first stocking or UI-refresh RNG. Safe publication/recovery required without mandating a stock-service framework. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Refresh distinguishes governed stock from player/quest/persistent contents and never clears ungoverned possessions.
2. Specific owned house/ship storage remains persistent/nonstocking by default; ownership changes need explicit disposition.
3. Calendar-day baseline resolves once per eligible day with retained emptiness/depletion and no missed-day accumulation or inspection reroll.
4. Baseline table/quality/rarity/furniture data and validated mods use explicit context/pools and constructor semantics.
5. Sold items follow declared merchant disposition without assumed buyback/storage guarantees.
6. Live selection/pending transaction defers replacement; coherent refresh invalidates stale intents/requotes without target swap or committed-item loss.
7. Full replacement/disposition validation precedes retiring old stock/advancing marker; failure retains contents/results and explicit technical recovery.
8. Restock does not clear theft consequences, grant property permission or repeat additions from notifications.
9. Native restore preserves source identity/history/provenance/deferred state without same-refresh reroll, lost deposits or stale-session publication.

## Contradiction review

Reviewed against approved ITEM-001–020 and MOVE-022. No direct contradiction identified. Governed stock disposition qualifies authorized replacement under ITEM-007/020 while preserving deposits/protected contents. Calendar-day eligibility does not authorize Info/cancel/reopen rerolls. Live-interaction deferral preserves exact item/quote commitments; overdue load uses the same schedule rather than new-container generation. Buyback, ownership-change remedies and concrete source-level profiles remain owner dependencies.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: extracted shop/household table/distribution fixtures; explicit level/appearance and rarity domains; provenance/stack/disposition schemas; ownership-change rules; authorized calendar/access/coherent-interaction boundaries; sold-item disposal/buyback profiles; refresh receipts and native migration fixtures. Concrete unresolved gameplay profiles require explicit owner decisions before support is claimed. These cannot waive persistent possessions, retained results or transaction safety.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-021-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented stock fixtures/context, provenance/disposition, ownership-change rules, calendar/interaction boundaries, merchant disposal profiles, refresh receipts and native migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
