# TIME-016 — Mount and cart availability

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-16 with “I approve”. See TIME-016-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Let the player benefit from an available horse or cart during fast travel, even when the current room cannot fit a mount. The quote shows the transport it assumes. The player arrives on foot by default and can use their remembered transport choice for the next local mount request.

## Confirmed requirements

[TIME-016-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm separate local and fast-travel eligibility, horse/cart/foot priority, moddable selection and access, and foot arrival with local preference preserved.

## Daggerfall Unity reference

Static inspection of the local DFU 1.1.1 Release snapshot. `Assets/Scripts/Game/TransportManager.cs#HasHorse` and `#HasCart` check transportation inventory. `ToggleMount` dismounts a mounted player or prefers horse over cart. `Assets/Scripts/Game/Utility/TravelTimeCalculator.cs#CalculateTravelTime` selects the horse factor before cart or foot. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Local access and travel eligibility

- [MOVE-016](../MOVE/MOVE-016.md) owns local mounting, safe dismount, posture and remembered selection. TIME reads current transport facts from ITEM/ECON and the relevant transport owner. Base ownership uses eligible character inventory. Local clearance, current stance and being mounted do not by themselves establish land-route eligibility. Transport does not authorize departure from a blocked location or bypass doors, containment or other owner restrictions.
- A horse or cart can be used for a land portion when the actor can reach an eligible departure point and the accepted route allows its use. A low interior ceiling by itself does not remove that benefit. Validate geographic and transport restrictions using WORLD and TIME-013. Stock local mounted movement across surface-only exterior water does not grant ship passage on the fast-travel ocean graph. Sea segments use their own travel terms.
- The base quote uses one land mode for all positive land segments. If a mode is ineligible on the candidate journey, consider the next eligible mode and obtain its route estimate. An unavailable candidate can fall through to the next choice. A required technical validation failure remains explicit. Sea-only and zero-land-time trips use no land modifier. Ship carriage or retrieval requirements need explicit transport policy where applicable.
- Provide validated mod policies for eligibility, selection order and explicit selection. Mods can require a retrievable mount or cart, supported route segments, or other capabilities supplied by their owners. Such policies declare their data, validation, failure reasons and compatibility. Base fast travel does not add upkeep, parked entities, retrieval simulation or a wagon storage transfer.

## Quote, parameters and revalidation

Select among eligible options in base order **horse, cart, foot**. TIME-013 uses land factors of **128, 192, and 256** respectively in its stock formula. Use the same selected mode and capability context for estimation and departure. The remembered local mount choice does not reorder the base fast-travel choices. Quest-authored estimates may use TIME-013's explicit assumptions and grant no transport entitlement.

Show the assumed mode on the TIME-014 quote. Revalidate its ownership and availability at commitment. A material change, including an assumed mode change, invalidates earlier consent. Requote with the currently eligible alternative and require fresh confirmation, or give an explicit refusal if none qualifies. For a modded explicit choice, report unavailability and require fresh consent before using a different mode. A successfully committed trip retains its accepted selection. If a supported mod mechanic can invalidate it en route, apply declared interruption or recovery through TIME-015 and TIME-004 without silently granting a different duration.

## Arrival and movement handoff

Base fast travel commits a valid on-foot arrival using TIME-015, WORLD-003 and MOVE-027. The accepted land mode is a journey fact and does not itself place the player in a mounted controller state. Preserve the remembered local selection and ownership. A modded mounted arrival requires valid access, supported location and water context, mounted shape clearance, and checked movement handoff under MOVE-016. Use an explicitly authorized fallback or recovery when placement fails. Preparation and rejection leave the original committed mode intact until a valid transition or applicable recovery commits.

## Data, inputs, outputs and events

Inputs include character, session and trip identities, current transport entitlement or capability facts, departure and route context, resolved selection policy, optional modded choice, and arrival movement policy and readiness. Outputs include eligible modes, selected mode and factor, explicit unavailability or verification failure, and a checked arrival movement result. Quotes and queries do not mount, spend, transfer items or move the player. Committed notifications expose the resolved transport and final mode after their owner actions. API and mod schema names remain implementation decisions.

## Configuration, persistence and failure conditions

- DATA-003 validates mod definitions. TIME-013 owns timing formulas, TIME-014 owns quote revalidation, TIME-015 owns settlement, MOVE owns local transitions, and ITEM/ECON own entitled assets and storage. WORLD and LOC supply route and placement context. TIME-017 owns ship access and return context.
- Restore owned transportation and remembered selection through ITEM/MOVE and their compatibility rules. An uncommitted quote requires current validation after restore. If active-trip saves are supported, retain the accepted mode, applicable capability context and completed arrival handoff with the trip. Restore causes no mount transition, charge or elapsed time replay. Missing required ownership or content uses authorized recovery under the relevant owner.
- Distinguish a currently inaccessible mode, an invalid capability definition, and a technical failure to verify. An owned mode with invalid route access cannot quietly receive its travel bonus. A failed or repeated handoff cannot mutate ownership or force a mounted pose.

## Acceptance criteria

1. Owning an eligible horse and cart selects horse for base land travel. An eligible cart is selected when horse is unavailable, and foot when neither is available. Local riding preference does not change those choices.
2. An inn ceiling that prevents local mounting does not alone block an eligible route's horse factor. An actual restriction or unmet mod retrieval rule can make the horse unavailable. Land transport confers no ocean access or discount.
3. Losing the selected transport before departure produces an updated quote or a clear refusal. No changed mode or material quote can depart using stale consent. A quest-authored hypothetical estimate does not change ownership or eligibility.
4. Base arrival commits Foot and retains the remembered local selection. A modded mounted arrival succeeds only with a valid mounted pose and context. Failed preparation cannot prematurely dismount a player.
5. Repeated queries, obsolete callbacks and supported native restore do not replay mount, payment or travel work.

## Consistency review and outstanding dependencies

The specification fits MOVE-016's local access, selection and shape rules, TIME-013's transport factors, TIME-014's changed-quote rules and TIME-015's checked arrival. Exact route eligibility data, sea carriage policies, capability schemas and active-trip save support remain owner dependencies.
