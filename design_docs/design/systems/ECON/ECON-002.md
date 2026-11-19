# ECON-002 — Stock sourcing and item eligibility

**Approval status** — Approved, finalized v1 on 2026-11-13. See ECON-002-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-002-interview-decisions).

## Gameplay purpose and intended player experience

Shops carry goods suited to their trade and buy goods their trade can use. A player can return to the same shelf or guild supplier and find the remaining stock until its next authorized refresh. A stock sale is final from the player's perspective.

## Confirmed requirements

Preserve ordinary DFU buy-group tables and the enchanted-only magic resale route as moddable defaults. Mods can define new shop types with custom item acceptance or no player sales. Guild magic inventory rotates daily, retains purchases and shares quantities where routes expose the same source. Stock buyback is disabled. Mods can add it through declared merchant stock and disposal policies. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-002-interview-decisions).

## Existing Daggerfall Unity behavior

- `Internal/DaggerfallLoot.cs#StockShopShelf` generates each shelf's contents from shop type and quality. `Game/PlayerActivate.cs#ActivateLootContainer` checks its day marker on access.
- `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#FilterLocalItems` filters ordinary sales by the shop's accepted item groups and magic resale by enchantment. Both exclude equipped items. The sale selection handler also blocks the wagon in use while its storage is occupied.
- `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#GetMerchantMagicItems` creates a fresh collection using a game-day seed. It can supply identified magic items and a spellbook, and supplies soul traps where the service entitlement permits. The result is rebuilt when the route asks for it, with no persistent quantity ledger in that generator. The separate potion stock generator uses its own path.

These are static observations from the local DFU 1.1.1 snapshot.

## Detailed rules and behaviors

1. **Ordinary stock.** Resolve a shelf purchase to the selected shelf's retained inventory. Use approved ITEM-021 generation, depletion, daily refresh, deferral and publication rules. Check current ECON-001 access and actual source quantities before purchasing. An aggregate menu can expose stock from several shelves and must retain each selected item's original source.
2. **Merchant acceptance.** Resolve the provider's declared purchase policy. Ordinary stock merchants use their DFU group list. The stock magic resale route requires enchantment. Apply current custody, ownership, quantity and transfer restrictions. Equipped items, protected quest items and a wagon currently holding goods are ineligible for sale. Apply the same eligibility rules during selection and settlement. A missing required policy yields unavailability. An explicitly empty purchase policy is valid.
3. **Guild magic stock.** Publish one retained result per authorized source and game calendar day under the default profile. Draw from the declared pools using explicit generation inputs. Guild magic-item and soul-trap routes that expose the same source draw from the same available quantities for overlapping goods. Bind each view to FACT-014 entitlement. Reopening, changing views, saving or loading cannot refill purchased quantities within the same refresh. Follow ITEM-021's safe refresh boundary when an active selection could be invalidated.
4. **Sold goods.** On successful sale, transfer the goods to merchant custody under a declared disposition policy. Stock profiles exclude player-sold goods from their purchase offers and have no buyback route. Retire goods according to the owning profile under ITEM-021. With a validated mod policy, approved retained goods can be exposed through a buyback or resale route using their precise identity, remaining quantity and stock owner. Any supported buyback policy declares eligible buyers and items, exposure period, expiry/disposal, and applicable terms. Use normal authorization, quotation and settlement checks.

## Formulas, parameters and balancing

Use one game-calendar-day refresh for ordinary shelves and guild magic stock by default. ITEM-021 governs approved shelf quality, rarity, construction and rounding inputs. Guild magic pools and quantities require verification of the local source profiles, including the inclusive loop over `0..floor(quality/2)+1` for generated magic items and eligible soul traps. Pricing follows RULE-021 and the applicable service policy. Mod policies may define shop types, allowed purchase categories or rules, explicitly empty purchase policies, stock pools, cadence and sold-goods disposition. A modded buyback profile must declare its pricing policy so settlement can evaluate the actual terms.

## Required data, inputs, outputs and events

Use stable shop type, provider, service, source, item and profile IDs, authorized source bindings, provenance, remaining quantities, purchase rules, player custody and current authorization, generation context, calendar-day and refresh state, and disposition policy. A sell request resolves to eligible quantities or a reason for rejection. A stock query exposes eligible offers from checked sources. Each successful refresh or transfer reports its committed result through its owner. Listing or filtering creates no transfer event.

## Cross-system interactions

ECON-001 and NPC-004 supply authorized routes and providers. FACT-014 owns guild entitlements. ITEM-020/021 own retained generation and refresh. ITEM owns item identity, custody, stacking, protection and transfer checks. RULE-021 provides pricing and renewed acceptance when terms change. TIME supplies the calendar. DATA/MOD validate shop types, sources and policies. SAVE restores authoritative stock and custody.

## Edge cases and failure conditions

- A valid empty shelf, depleted guild source or shop that buys nothing produces an empty result with the applicable explanation.
- If an item is equipped, moved, sold, depleted or otherwise becomes ineligible after selection, settlement rejects the affected stale action before payment or transfer. Route access and quantities are also checked.
- Midnight and missed refresh days follow the applicable retained refresh policy. Refresh preserves protected entries and resolves the active selection at a coherent boundary. Retry after failure retains the correct stock and refresh state.
- Two views of the same item cannot create separate purchasable copies. Mod buyback and resale share the same quantities whenever they expose the same retained goods.

## Save/load and technical constraints

Target Godot 4.7.2. Persist source identity, quantities, item instances and provenance, merchant custody, and completed or deferred refresh facts. Persist modded buyback state when required by its declared policy. Restore against validated profiles and use explicit migration or recovery for unresolved required identities. Rebuild views from current authorized state. Use the same eligibility boundary for UI and other supported callers. Item labels and menu lists carry no stock authority.

## Acceptance criteria

1. Separate shelves retain distinct quantities. A combined menu and shelf menu draw from the same source when listing the same item.
2. Stock buyers follow DFU group or enchantment rules. A custom shop type can accept different goods or decline all player sales. Revalidation rejects stale or protected selections.
3. Reopening guild magic stock or switching eligible views cannot restore purchased quantities. Save/load preserves depletion, and the next authorized refresh publishes one retained result.
4. A stock sale moves the item to merchant custody and offers no buyback. A modded buyback route can expose an eligible retained item under its declared terms and expiry and can transfer it only once per available quantity.
5. Failed refresh, transfer or restoration preserves coherent stock and custody. Paying for an unavailable item or receiving payment for a rejected sale cannot occur.

## Compatibility review and outstanding questions

The specification uses ECON-001 routes, ITEM-021 refresh and merchant ownership, FACT-014 entitlement and RULE-021 price confirmation. Detailed stock table and guild profiles, exact stock retirement boundaries, supported mod buyback declarations and separate potion stock policy remain integration or follow-on decisions.
