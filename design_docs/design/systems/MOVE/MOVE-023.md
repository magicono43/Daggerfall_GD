# MOVE-023 — NPC, quest and board activation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Route actors and boards to intended dialogue, service or quest behavior without identity drift, unintended theft or duplicated effects. Local news and quest reservations have explicit context and lifetime.

## Confirmed requirements

MOVE-023-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) record three confirmed interviews. MOVE-018 targeting/consumption and MOVE-019 safe Info remain binding. Pickpocket execution is MOVE-024; service and quest consequences remain domain-owned.

## Existing Daggerfall Unity behavior — reference only

Local baseline: DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths relative to reference `Assets/Scripts/`:

- `Game/PlayerActivate.cs#StaticNPCClick` checks NPC/fade validity, assigns global `LastNPCClicked`, handles quest resource clicks/faction listeners and selects guild/merchant/repair/bank/tavern/coven/dialogue UI from faction/building context.
- `ActivateStaticNPC` excludes selected authored text-action actors; mobile NPC/enemy paths have distinct mode routing. Target safe Info deliberately supersedes source Info-to-dialogue behavior.
- `ActivateBulletinBoard` checks NPC-distance reach and requests `TalkManager.GetNewsOrRumorsForBulletinBoard`, formatting local heading/message. Caller inspection alone does not establish refresh semantics.

Static inspection only; no runtime verification/source changes. Global last-click authority and broad faction-listener suppression are not adopted target architecture.

## Detailed rules and behaviors

### Actor routing

Explicit actor capabilities plus current location/faction context select dialogue, merchant, bank, tavern or guild services. Grab/Talk may share approved mappings. Appearance cannot grant service capability; unsupported interaction cannot become theft. Info remains descriptive and Steal uses only its supported domain route.

Require valid available actor. Dead, removed or otherwise unavailable actors cannot open stale services. Hostility does not automatically imply dialogue/theft: NPC/COMBAT/QUEST define permitted exceptions. Exact capability/availability inventory remains owner work.

Retain stable scoped actor identity/context per interaction. Another click, redraw or global last-click update cannot redirect quest response, purchase or dialogue. Reject replaced/ended-session targets even if numeric IDs repeat.

### Quest reservations

Quest ownership/listeners explicitly declare replacement or observation under MOVE-018. Scope to intended actor and release when the owning action ends. Do not disable every same-faction actor merely because a listener exists. Preserve necessary scripted exceptions through validated mappings.

Required quest reactions use checked once-only owner contracts; optional UI/audio failure cannot replay a primary action. Exact notification timing, override priority and partial-failure recovery remain QUEST/MOVE-018 contracts. No generic rollback is promised.

### Service continuation

Opening UI does not guarantee later transaction permission. At consequential confirmation, revalidate actor availability, access, location and service requirements. Invalid intent cancels with explanation without repeated costs/rewards or alternate-target fallback. ECON/FACT/NPC own prices, permissions and transaction boundaries.

Retain release-time mode/action under MOVE-018/019; changing modes cannot reinterpret a pending choice as theft. Exact in-dialogue reach/context persistence is owner-defined rather than a blanket rule cancelling every conversation on any positional change.

### Boards and content

Explicit board activation displays permitted local news/rumors using the board's actual location context. It does not automatically accept quests, advance time or execute unrelated actions. Info describes only.

Retain the resolved message while UI is open; redraw cannot reroll. Reopen uses owner-declared refresh policy, without assuming permanent text or fresh randomness every click. Reading cannot repeatedly generate rewards/discoveries. NPC/QUEST/TIME own cadence/selection; RULE source/result-retention contracts apply.

A valid board with no news gives concise localized no-news text. Missing required location/content data is not valid emptiness. Content/routing supports validated mods without unrestricted competing handlers or hidden-data disclosure.

### Failure, suspension and restore

Required missing actor/faction/service/quest data produces explicit unavailable/recovery, not a fabricated generic service or alternate primary action. Optional presentation fallback follows DATA.

UI follows CORE context/suspension. Supported restored UI retains original actor/board identity, resolved message and necessary owner state, revalidating before consequential continuation. Load cannot reroll an open message, replay purchases/rewards or restore a reservation whose owner ended. Unsupported states need declared UI/SAVE restrictions/recovery rather than silent partial restoration.

## Relevant formulas and parameters

Reach/obstruction use MOVE-018 and Info permissions MOVE-019. Exact board reach and service-context limits require declared owner inventory; DFU's caller uses NPC distance. No rumor probability, refresh interval, service price or reward formula is selected here.

## Required data

Stable actor/board/session identity, capabilities/availability/location/faction, captured mode/intent, reservation owner/role/lifetime, resolved service/message, refresh policy and consequence completion state. Concrete schemas remain implementation dependencies.

## Inputs, outputs and events

Inputs: eligible activation, target/context/mode, quest reservations, service/dialogue choice, content request and lifecycle/restore. Outputs: checked primary route, resolved content, explicit observation/reservation, domain transaction request or unavailable result. API names unselected. Preview/redraw cannot become a new purchase, quest click or content roll.

## Cross-system interactions

MOVE-018/019 dispatch/modes and MOVE-024 theft; NPC availability/dialogue, QUEST reservations, ECON/FACT services, LOC/WORLD context, DATA content/identity, RULE randomness/hooks, UI windows, CORE scopes/readiness and SAVE reconstruction. MOD supplies validated capability/content definitions.

## Edge cases and failure conditions

Test quest/service overlap, actor removal/replacement, ended listeners, same-faction actors, hostile exceptions, remote board context and changed permissions during UI. Required failure after partial quest work cannot silently fall through to dialogue or replay. Stable identity must survive unrelated clicks while rejecting stale session references. Recreated messages cannot farm rewards.

## Configuration and balancing options

Validated capability/routing mappings, actor-scoped quest reservations and board content are moddable. Exact refresh/service/reward policy remains domain-owned. No automatic board quest acceptance, faction-wide veto or missing-service fallback is introduced.

## Save/load considerations

Supported UI persists stable intent, resolved content and required owner/completion context. Rebuild reservations from active authoritative quest state, not stale listener lists. No purchase/reward replay or redraw reroll. Exact UI support inventory, commit/save boundaries and compatibility remain UI/SAVE/QUEST contracts.

## Technical constraints

Target: Godot 4.7.2. Separate routing, pure descriptions, checked domain effects and presentation. Stable scoped identities replace mutable global last-click authority. Concrete APIs, registrations and transaction boundaries require fixtures. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Capability/context selects supported services/dialogue; availability/hostility exceptions are explicit, with safe Info and no unintended theft.
2. Later clicks/redraw cannot redirect an interaction; consequences revalidate without replay.
3. Actor-scoped quest reservations declare role/lifetime and cannot suppress unrelated same-faction NPCs.
4. Board activation uses actual local context, no automatic quest/time effects; Info describes only.
5. Open messages remain stable; reopen follows declared refresh without reading-based reward farming.
6. Valid no-news differs from missing required data; no fabricated service/alternate primary fallback.
7. Supported restore preserves target/message/active owner context without rerolls, replayed consequences or ended reservations.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-018/019 and CORE context/scope/restoration. No direct contradiction identified. Explicit quest roles preserve intentional composition without broad faction suppression. Safe Info supersedes dialogue fallback. Deferred stable identity and checked confirmations preserve no-replay rules. Refresh remains owner-defined, not an invented random schedule.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: capability/quest/service inventory, reservation priority/identity, availability/context limits, board reach/refresh, domain commit boundaries, mod schemas and native/UI fixtures. These do not waive stable identity, valid ownership or no replay.

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under MOVE-023-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented routing, content, persistence and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
