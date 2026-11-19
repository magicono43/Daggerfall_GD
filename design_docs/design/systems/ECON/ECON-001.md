# ECON-001 — Merchant routing and access

**Approval status** — Approved, finalized v1 on 2026-11-13. See ECON-001-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-001-interview-decisions).

## Gameplay purpose and intended player experience

Players browse individual shelves to buy goods and approach merchants to sell goods or request their services. A shop's hours tell players when its shelves are available. Guild membership and rank govern which halls and services the player can use, including after hours.

## Confirmed requirements

- Generate stock separately for each stock shop shelf. Buy from the selected shelf and sell through the merchant. An open, authorized shelf can sell while the owner NPC is absent or unavailable.
- Allow mods to change the routes and provider requirements, including a single menu presenting shop stock and trade actions.
- Preserve DFU's guild-specific hall access and after-hours service behavior by default. Service qualification confers no hall entry privilege. Make hall access and service hours moddable.

See [ECON-001 interview decisions](../../GAMEPLAY_DECISIONS.md#econ-001-interview-decisions).

## Existing Daggerfall Unity behavior

The local 1.1.1 snapshot sets an open-shop flag on entry using regular hours. Shelf activation uses that flag to choose purchase or theft inventory. `DaggerfallLoot.StockShopShelf` stocks the individual shelf from building type and quality. `PlayerActivate.StaticNPCClick` handles quest interception and guild routes before ordinary merchant routes. A registered custom merchant service takes precedence over the merchant's building-based default. `DaggerfallGuildServicePopupWindow.DoGuildService` checks service entitlement before dispatch.

Source under `Assets/Scripts` includes `Game/PlayerActivate.cs` (`IsBuildingOpen`, `BuildingIsUnlocked`, `ActivateLootContainer`, `StaticNPCClick`), `Internal/DaggerfallLoot.cs` (`StockShopShelf`), `Game/Guilds/Services.cs`, and the merchant and guild service popup windows. These findings come from static inspection.

## Detailed rules and behaviors

1. **Shelf purchases.** Bind the selected shelf to its stable stock source and shop. Check current shop opening status, permission and interaction context when opening trade and again before a purchase commits. Apply ordinary shop hours and applicable closures such as Sun's Rest. The stock route has no NPC presence check. Closed or unauthorized shelves follow MOVE-022 property and theft routing. A stale purchase confirmation cannot initiate theft.
2. **Provider services.** Bind selling and other NPC service actions to the exact authorized provider and declared operating context. Establishments retain their stock and obligations across explicit provider changes. Independent providers can operate under an actor-owned profile in declared contexts. If an approachable provider is unavailable, give a short reason and allow eligible dialogue. A replacement provider requires a new interaction.
3. **Guild services.** Use the applicable guild or variant's public hours and explicit after-hours hall privileges for hall access under MOVE-020. In valid after-hours context, a reachable authorized provider can perform a qualified stock guild service without a separate ordinary business-hours cutoff. FACT-014 still governs the exact membership, rank, visibility and service conditions at opening and commitment. An ordinary locked offer explains its gate. A secret offer follows its discovery rule.
4. **Alternative routes.** Allow validated profiles to change presentation, authorized stock sources, hours and provider requirements. A combined menu may expose eligible shelf stock and merchant services together. Each item selection retains its stock source, and each service retains its authorization and owner. Menu, shortcut and custom handler use the same checks for the selected action.
5. **Commitment.** An opening or availability check grants no goods or effects. On lost eligibility, explain the change and reject the pending action before payment or fulfillment. When an eligible action's price changes, renew acceptance under RULE-021. The service owner commits the action and publishes its outcome.

## Parameters and configuration

- Stock public schedules use the DFU building-type opening and closing tables as the baseline. Opening is inclusive and closing exclusive. Use the current game clock and applicable regional holiday. Support validated authored schedules and after-hours overrides.
- In the local snapshot, `MagesGuild.HallAccessAnytime` and `FightersGuild.HallAccessAnytime` use rank ≥ 6. The Thieves Guild and Dark Brotherhood overrides use membership for the relevant hall access path. The base guild implementation grants no anytime access. Preserve each applicable building's DFU access profile, including separately gated guild houses.
- Moddable data includes service routes and labels, stock sources exposed by each route, authorized providers, operating contexts, schedules, holiday rules, and guild or variant access overrides. Pricing and stock generation parameters remain with their respective owners.

## Required data, inputs, outputs and events

Inputs include the activation route, stable shelf, shop, provider, service and region identities as applicable, declared stock source, authorized provider bindings, current calendar and access state, and applicable guild entitlement and discovery state. Resolve a checked route, a visible denial with a reason, a hidden offer, or a property interaction as applicable. Reevaluate affected choices when provider, permission, schedule or context changes. Opening a route produces no settlement event. Payment, item transfer and service effects publish through their owners after successful commitment.

## Cross-system interactions

[MOVE-020](../MOVE/MOVE-020.md) owns building access, [MOVE-022](../MOVE/MOVE-022.md) owns shelf activation and property routing, and [MOVE-023](../MOVE/MOVE-023.md) owns interaction context and quest reservation handling. [NPC-004](../NPC/NPC-004.md) owns provider identity and bindings, [FACT-014](../FACT/FACT-014.md) owns guild entitlement and visibility, and [ITEM-021](../ITEM/ITEM-021.md) owns persistent stock and refresh. RULE-021 and RULE-023 supply applicable pricing. TIME supplies the clock, LAW handles unauthorized behavior, and DATA/MOD validate authored policies.

## Edge cases and failure conditions

- Closing time, a holiday transition, lost access or a stale provider invalidates affected confirmations. A separate shelf purchase remains eligible if its own checks pass.
- A member below a hall's anytime access threshold gains no entry privilege from a service unlocked at a lower rank. A member with anytime hall access still needs the applicable service entitlement and provider.
- Two shelves using the same template keep distinct stock. A combined view of a shelf and a direct view of that shelf use the same remaining quantities. Browsing or changing routes cannot reroll stock or allow duplicate purchases.
- Missing required identities, unresolved mappings, conflicting bindings or unavailable stock yield explicit unavailability. Stale actions cannot redirect to another shelf or provider.

## Save/load and technical constraints

Target Godot 4.7.2. Restore stock, ownership, provider bindings, entitlements and game time from their authoritative owners. Rebuild access and route availability from restored facts. Any supported pending interaction must revalidate its original context and terms. Loading cannot regenerate retained stock or replay settled purchases. Keep route presentation separate from access decisions and fulfillment. A label, scene instance or cached open flag carries no authorization.

## Acceptance criteria

1. Two shelves in one shop generate and retain individual stock. In an open, authorized shop, either shelf can sell while the merchant is absent. Selling through that merchant requires an available authorized provider.
2. At closing or an applicable holiday closure, a stale shelf confirmation fails without payment, transfer or theft. Forced entry grants no ordinary shelf purchase permission.
3. Stock Mages and Fighters Guild rank 6 anytime hall access respects the applicable building profile. Mages Guild enchanting eligibility at rank 5 grants no anytime hall entry. An eligible after-hours visitor can use a qualified service through its valid provider.
4. A validated mod can present eligible shelf stock and merchant actions together, require a provider for shelf purchases, or alter guild schedules. Shared views preserve stock identity and apply current access checks.
5. Provider replacement, rank loss, changed prices and reload respect the original action's authorization and owner settlement rules. Failed or repeated confirmation cannot duplicate a settled effect.

## Compatibility review and outstanding questions

The specification preserves current authorization for shop shelves under MOVE-022, the independent lock and permission rules in MOVE-020, exact provider binding for NPC services under NPC-004, FACT-014's rank and visibility gates, and ITEM-021's ownership and retention rules. Shelf sales use the shelf's authorization. NPC-mediated actions use provider authorization.

Open integration details include the complete stock schedule and building-profile fixtures, supported mod route declarations, per-shelf generation and refresh parameters under ECON-002 and ITEM-021, and any pending-menu restoration support.
