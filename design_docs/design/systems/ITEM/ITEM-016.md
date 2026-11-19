# ITEM-016 — Books, maps and spellbooks

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Open readable possessions, reveal map knowledge and access learned spells through explicit actions without unintended consumption or duplicated knowledge/rewards.

## Intended player experience

Books remain available for rereading at a remembered position. Maps reveal useful new destinations and are spent only on successful discovery. Spellbook items provide access to existing learned knowledge without teaching or casting through inspection.

## Confirmed requirements

- **ITEM-016-D01:** Ordinary books are reusable/unconsumed. Reading alone grants no skills/spells/rewards unless an explicit supported content action declares them. Approved artifact/quest-readable exceptions remain binding.
- **ITEM-016-D02:** Ordinary discovery maps consume one unit only with successful committed valid new-location discovery. No eligible undiscovered location, invalid target or technical failure leaves the map intact. Discovery/notebook/consumption settle without duplicate outcomes.
- **ITEM-016-D03:** Physical spellbook use opens learned-spell interface under MAGIC-011, not teaching/casting. Multiple books do not duplicate knowledge. Item loss blocks required access without erasing spells.
- **ITEM-016-D04:** Baseline random maps select an eligible undiscovered current-region location through WORLD's declared pool; retain resolved target through technical retry. Explicit mod fixed-target/other-region/reusable maps supported. Action-menu viewing cannot draw/reveal target.
- **ITEM-016-D05:** Ordinary reading requires authorized item access, without artificial inventory transfer. Use approved UI suspension, no automatic calendar-time charge. Explicit mod reading-time/access restrictions supported.
- **ITEM-016-D06:** Remember position per character/work across physical copies; use DATA-018 verified edition anchors or beginning-with-notice fallback. Progress separate from ownership and explicitly granted rewards.
- **ITEM-016-D07:** Successful map reveal records stable location identity/name/map availability and one notebook entry, not interiors/quest completion/travel permission. Already-known fixed targets cause no ordinary consumptive discovery; explicit mod profiles may define other useful outcomes.
- **ITEM-016-D08:** Missing/malformed required reading content reports unavailable without item consumption/reading-effect reward. Lost access prevents further item-authorized actions and preserves last valid position; continued display needs explicit supported policy. Open/close cannot duplicate rewards.
- **ITEM-016-D09:** Persist compatible work/edition anchors, discovered location IDs, retained map outcomes and explicit reward-completion facts. No load rediscovery/extra consumption/duplicate notes/spell or reward grants. Pending saves follow existing supported boundaries without automatic reader reopening/discovery confirmation.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem`: regular nonartifact books attempt reader and report unavailable; map branch calls RecordLocationFromMap then removes a unit; spellbook opens spell UI or shows no-spells feedback. Artifact books bypass regular reading branch.
- `RecordLocationFromMap` calls DiscoverRandomLocation, records revealed name/notebook and shows text. It catches exceptions as discovery failure; caller still removes the map afterward.
- `Game/LocalizedBook.cs#OpenBookFile` supplies localized/classic sourcing; `DaggerfallBookReaderWindow` provides reader presentation/navigation.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; source unchanged.

## Existing approved constraints

DATA-018 owns stable work/edition identity, whole-edition language fallback, unavailable-content preservation and anchor-based position compatibility. MAGIC-011 owns learned knowledge and moddable default physical-spellbook requirement. ITEM-015 owns explicit action/quest routing, knowledge-safe queries, pending UI and recovery; ITEM-001–014 preserve identity/state/custody/quantity and no-replay settlement. WORLD owns actual location discovery.

## Detailed rules and behaviors

### Explicit actions and item access

Read, map discovery and spellbook access are explicit ITEM-015 actions. Validate the actual actor/item/custody/session and required quest/provider context through ITEM-002. Selecting/hovering an item does not open content, reveal a destination or record a quest-use event. Do not automatically invoke Used enchantments after ordinary reading; approved quest/artifact behavior uses its declared route.

Ordinary reading may use any explicitly authorized accessible item without temporary transfer into carried inventory. Permission to read does not grant permission to take, consume or cast. UI uses existing suspension/input ownership rules; no automatic calendar-time charge. Validated mod policies may add access/time requirements with their own commitment/persistence rules.

### Books and readable content

Ordinary books remain reusable and unconsumed. Read alone grants no skill/spell/reward; explicit supported content actions may do so, with declared eligibility/trigger/cost/once-only facts. Approved Oghma and quest-readable exceptions remain binding rather than becoming ordinary book defaults.

Resolve stable work/edition content through approved DATA-018 language fallback/usability rules. Missing/malformed required content reports unavailable without consuming the item or awarding reading effects. A filename/title/translation alone cannot establish a new work or reset reward history. No new content filters or locale fallback precedence are introduced here.

Remember position per character/work across physical copies, independent of ownership. Use verified compatible edition anchors; otherwise restart at beginning with notice under DATA-018. Raw page numbers alone do not prove compatibility after repagination/translation. Reading progress is not proof of an explicit reward trigger; reward completion is tracked separately by its owner.

If access is lost during reading, preserve last valid position and block further item-authorized actions. Continued display requires a declared supported policy; default unrestricted continued access is not implied. Closing/reopening cannot duplicate rewards. Exact UI closure versus retained display behavior is an explicit owner profile dependency.

### Map discovery

Baseline random maps ask WORLD for an eligible undiscovered location in the current region through a declared pool and owned randomness. Retain a resolved target through technical retries; action-menu inspection does not draw, reveal or alter the pool. WORLD defines eligible location types/exclusions and stable geography; this feature does not approve a distribution table or force exposure of protected destinations.

Successful discovery records stable location identity/name and map availability, one corresponding notebook entry and consumption of one ordinary map as a coherent owner operation. It does not reveal interiors, complete quests, teleport, buy passage or grant entry/travel permission. Optional feedback failure cannot repeat successful discovery or map consumption.

No eligible undiscovered location, invalid target or technical failure leaves the map intact. Distinguish legitimate no-target/already-known outcomes from missing required services/data. If a technical boundary has partially committed discovery/note/consumption, preserve exact facts and recovery; do not retry the whole action or pretend nothing committed. Never consume another unit to settle the same operation.

Explicit mod profiles may provide fixed-target, other-region or reusable maps with validated scope/consumption and discovery rules. Already-known fixed targets do not consume under ordinary new-discovery behavior. Other useful known-target outcomes need explicit profiles; do not silently reroll a fixed target or invent a replacement reward. Concurrent discovery changes are revalidated at commitment without automatic unapproved retargeting.

### Physical spellbook

Use opens the MAGIC-011 learned-spell interface under its default physical-book requirement and supported on/off mod policy. It does not teach or cast spells. Multiple physical copies access the same character-owned knowledge rather than creating separate spell lists. Loss of a required accessible book blocks access without erasing spells.

Empty learned knowledge receives truthful no-spells presentation under MAGIC-011, not a hidden grant or item consumption. Innate/item powers remain distinct and follow their own access. Revalidate spellbook access and cast intent through MAGIC before an action commits; opening this interface is not readiness, release or resource expenditure.

## Relevant formulas and parameters

Ordinary successful new map discovery consumes exactly one unit; ordinary book/spellbook opening consumes zero. No new skill reward, reading duration, discovery chance/pool weighting, travel cost or spell formula is approved. Mod profile changes require explicit supported semantics; map selection uses RULE-owned randomness and retained results rather than frame reseeding.

## Required data

Stable actor/item/work/edition/locale/provider/session IDs; authorized access and knowledge; compatible reading anchors; explicit action/quest/reward facts; map profile/region/pool and retained stable target; discovered identity/map availability/notebook completion/consumption phases; learned-spell access context. Exact schemas and state ownership integrations remain dependencies.

## Inputs, outputs and events

Inputs: explicit Read/Discover/Open spellbook, validated accessible item/content, WORLD target/discovery result, reader navigation/access loss, owner reward/quest results and native restore. Outputs: usable reader/position or unavailable, committed discovery/note/one-unit consumption or distinct no-target/recovery, learned-spell interface/no-spells result. Preview/query/opening is not automatic reward/cast/discovery commitment. Concrete APIs/signals remain unselected.

## Cross-system interactions

DATA-018 resolves editions/bookmarks/content compatibility; WORLD owns location selection/discovery and map availability; notebook/UI own presentation of retained knowledge. MAGIC-011 owns learned knowledge/access and MAGIC-015/016/030 explicit item/artifact powers. ITEM-001–015 preserve stable identity/access/quantity/state and explicit routing. QUEST owns readable interception/protection, TIME/CORE any declared reading-time/suspension, and SAVE compatible reading/discovery/reward restoration. Future WORLD/readable reward details are not finalized automatically.

## Edge cases and failure conditions

- Unavailable/malformed edition: keep possession, no reading reward, truthful reason.
- Translation/repagination: verified anchor or beginning/notice, not incorrect raw-page reuse or reset reward entitlement.
- Different copy of same work: resume character/work position without transferring ownership or duplicating rewards.
- Lost reader access: preserve position, block unauthorized actions, no universal continued-display permission.
- Empty discovery pool/known fixed target: no ordinary consumption or random replacement.
- Discovery partly committed/duplicate callback: preserve phases, no duplicate note/extra unit.
- Spellbook lost/empty or several copies: knowledge retained, truthful access/no-spells, no duplication or cast.
- Artifact book: explicit approved route, not automatic ordinary read plus Used activation.

## Configuration and balancing options

Validated book/read-action additions, explicit rewards, reading access/time profiles and fixed/other-region/reusable map policies are supported. DATA-018/MAGIC-011 approved mod capabilities remain. No automatic reading reward, full dungeon reveal, calendar reading charge, new spell grant or universal arbitrary-container access is approved.

## Save/load considerations

Save character/work anchors with edition compatibility, stable discoveries, map operation selections/phase facts and owner reward completion separately from physical ownership. Native load cannot rediscover, repeat notes, consume another map, grant a spell/reward twice or reset reading progress to farm explicit content rewards.

Required incompatible content/providers/location identities require explicit owner migration/recovery rather than random substitutions or silent item loss. Reader reopening is not automatic; supported pending snapshots follow ITEM-002/015 and action-specific rules, otherwise explain temporary save restriction. New session rejects old callbacks. Exact native schemas/anchors/note linkage and partial-discovery recovery remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate readable resource identity, physical possession, reading progress, knowledge/rewards, discovery commitment and UI. Avoid filename/title/page index or localized location name as authoritative persistent identity. Retain owner operation facts without a mandated general transaction framework. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Ordinary books reusable/unconsumed and reading has no implicit skill/spell/reward; explicit artifact/quest exceptions retain their rules.
2. DATA-018 usable editions/anchors work across copies; incompatible anchors restart with notice without reward reset.
3. Authorized reading needs no artificial transfer, no default calendar charge; lost access preserves position and blocks further unauthorized actions.
4. Random maps select declared eligible undiscovered current-region targets with retained results; menus draw/reveal nothing.
5. Successful ordinary discovery records stable location/map availability and one note while consuming one unit, without interiors/quests/travel permissions.
6. No-target/known fixed/invalid/technical failure preserves map or explicit partial recovery; retries never duplicate note/discovery/consumption.
7. Supported mod fixed/other-region/reusable profiles are explicit and cannot silently reroll or substitute targets.
8. Spellbook opens MAGIC-011 access without teaching/casting; copies share knowledge and loss blocks required access without erasure.
9. Native restore preserves progress/knowledge/phase/reward facts without replay or unsupported reopening; stale callbacks reject.

## Contradiction review

Reviewed against approved DATA-018, MAGIC-011, ITEM-001–015 and applicable MAGIC-030 artifact boundaries. No direct contradiction identified. Work-level progress refines DATA-018 without replacing edition compatibility. Ordinary map consumption corrects the reference failure path while retaining checked quantity settlement. Physical spellbook access does not duplicate knowledge or authorize casts. Explicit content rewards/artifacts remain separate from ordinary Read and knowledge-safe ITEM-015 queries. WORLD pool and detailed discovery policies remain dependencies.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: readable access/discovery/reward profiles and interrupted-display rules; work/edition anchor schemas; WORLD pool/target/map availability contracts; notebook linkage and coherent consumption/recovery receipts; spellbook accessibility integration; native migration/pending-save fixtures. Concrete unresolved content/discovery gameplay profiles require explicit owner decisions before support is claimed. These cannot waive reusable reading, success-only consumption, retained knowledge or no-replay guarantees.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-016-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented readable access/reward profiles, interrupted-display rules, edition anchors, WORLD discovery pools, notebook/consumption recovery, spellbook access and native migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
