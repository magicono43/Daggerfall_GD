# ITEM-011 — Equip restrictions and inventory presentation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Apply consistent actor-specific equipment eligibility and present truthful committed equipment without UI-driven gameplay side effects.

## Intended player experience

Equipment restrictions behave consistently across input methods. Inventory shows actual committed equipment and useful reasons for rejection without leaking hidden powers. Mods can add persistent cursed-item removal restrictions with explicit discovery and recovery rules.

## Confirmed requirements

- **ITEM-011-D01:** Every equip caller, including inventory/hotkeys/scripts/NPC systems, uses authoritative eligibility with explicit actor/item/context. UI presents results rather than owning bypassable checks. Special overrides are explicitly declared and authorized.
- **ITEM-011-D02:** Initial baseline rejects broken equipment and enforces declared career restrictions on shields, armor categories, weapon proficiencies and materials. Validated mod policies are supported; added types/materials use explicit mappings rather than legacy bit shifts. Appearance alone adds no race/gender restriction.
- **ITEM-011-D03:** Present committed equipment and actionable rejection reasons. Selection/hover/paper-doll refresh/enchantment indicators cannot equip, activate powers, change armor values or reveal properties beyond approved identification rules.
- **ITEM-011-D04:** Restrictions explicitly declare future-equip-only versus required removal of existing equipment. No implicit drop/delete; required removal follows ITEM-010 coordinated retention in inventory. Approved break/expiry/transformation rules remain binding.
- **ITEM-011-D05:** Ordinary career prohibitions block equipping, not removal. Mods must be able to add cursed items/other unequip restrictions through explicit supported policies with clear feedback and defined removal/recovery conditions. No new vanilla cursed equipment is introduced automatically.
- **ITEM-011-D06:** Paper-doll/accessory controls resolve stable item/slot identities from committed layout. Custom/multi-slot equipment remains inspectable/selectable; clicking an occupied part identifies the whole item. Stale selection revalidates and cannot act on a replacement merely occupying the same slot.
- **ITEM-011-D07:** Feedback respects player knowledge without automatically identifying hidden powers/curses. Failed removal may disclose resistance to removal; exact cause/cure follows declared discovery rules.
- **ITEM-011-D08:** Curse profiles explicitly resolve break/expiry/transformation/quest forced-removal interactions. Ordinary cannot-unequip flags cannot silently override approved lifecycles or destroy items to resolve conflicts. Unsupported combinations fail validation or require explicit recovery.
- **ITEM-011-D09:** Persist required restriction/curse state and provider compatibility. Delayed actions revalidate identity/eligibility/session; load/refresh cannot clear curses, replay application or bypass preparation. Missing required providers require migration/recovery rather than freely removable fallback.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06, adding for D05: “I would like cursed items like that to be something that mods could implement/add.” This is a required mod capability, not merely a hypothetical future option.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`: `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs`.

- `EquipItem` rejects arrows and currentCondition <1, checks career forbidden shields/armor/materials/proficiencies, then calls the equip table and updates equipped armor values. These checks are in the inventory UI path, not universally applied by the equipment table.
- `UnequipItem` calls the equipment table, updates armor, reorders inventory and refreshes.
- `UpdateAccessoryItemsDisplay` shows equipped icons/LongName/enchantment animation. `PaperDoll_GetItem` resolves equipment via paper-doll slot interaction. These source UI choices do not approve hidden-knowledge disclosure.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; source unchanged.

## Existing approved constraints

ITEM-010 owns complete equip/unequip planning, slot conflicts, no-op and restoration. ITEM-001–009 preserve identity/state/knowledge/custody and checked operations. Character definitions retain declared career restrictions; ITEM owns their equipment enforcement. COMBAT-001/002 readiness/timing, MAGIC source lifecycle/forms and ITEM-012 armor/power derivation remain owner contracts. Appearance alone imposes no fit restriction under ITEM-003.

## Detailed rules and behaviors

### Authoritative eligibility

All equip entry points use the same authoritative eligibility with explicit actor, stable item identity and current context. Inventory/hotkeys/controller/scripts/NPC systems cannot bypass a rule because it was previously checked only in UI. A special override declares its authority, scope and supported semantics; it is not an unrestricted bypass flag.

Initial baseline rejects broken equipment and enforces the actor's declared career restrictions on shield types, armor categories, weapon proficiencies and materials. Resolve stable supported identities/mappings rather than raw legacy bit shifts. Added types/materials require valid restriction interpretation, not accidental exemption because a bitfield cannot represent them. Appearance alone creates no race/gender eligibility under ITEM-003; actual fit rules require explicit owner policy.

Broken-state semantics follow the supported durability profile. DFU's currentCondition <1 is reference evidence, not permission to reject every custom item with no durability concept. Concrete conditionless/charge-only equipment must explicitly define supported eligibility. Default ammunition remains outside ordinary hand equipping under ITEM-010.

Return eligible/ineligible with inspectable reason and applicable policy, or distinct invalid/unavailable definition/provider state. Pure checks do not split, unequip, activate or change armor/preparation. ITEM-010 validates the complete slot/conflict/split/displacement plan before commitment; a positive eligibility query alone does not promise successful equip.

### Restriction changes and removal

Each supported restriction declares whether it blocks future equip only or requires removing already-equipped possessions. No generic silent eviction: required removal is coordinated through ITEM-010 and effect/combat owners, preserving inventory identity/contents/recovery without forced dropping or deletion. Capacity changes follow ITEM-008 retained-overweight rules.

Ordinary career prohibitions block equipping, not unequipping. Validated mods must be able to add cursed items or other voluntary-removal restrictions, with explicit activation scope, persistent state, rejection feedback and removal/recovery conditions. No concrete vanilla curse, cure spell, fee or discovery trigger is introduced.

Restriction composition and special override precedence require explicit validated policies. A generic cannot-unequip flag cannot silently override breakage, expiry, approved transformation cleanup or quest action. Curse profiles declare interactions with each supported forced-removal path. Unsupported/inconsistent combinations fail validation or use explicit recovery without deleting items or leaving half-equipped multi-slot objects. An override to an already approved gameplay lifecycle needs explicit compatible owner policy, not merely registration order.

### Knowledge and feedback

Present useful rejection feedback consistent with player knowledge. A failed removal may say the item resists removal, without automatically naming a hidden curse, revealing all powers or revealing a cure. Detailed discovery/identification/cure knowledge follows the provider's supported policy and ITEM-019/MAGIC contracts. Technical diagnostics can retain precise causes without treating diagnostic text as in-game knowledge.

Equipment and accessory indicators respect the same knowledge boundary. Copying DFU's IsEnchanted animation unconditionally is not approval to disclose hidden enchantment status. Required hidden/presentation schemas remain owner dependencies; do not invent a universal unknown-item marker here.

### Inventory and custom layouts

Render committed authoritative item-slot bindings. Paper-doll/accessory controls use stable item/slot identities and current layout; a click on any occupied part of a multi-slot item identifies that same whole item. This means interaction identity, not magical identification. Custom layouts/items remain inspectable/selectable through supported presentation, without prescribing a fixed UI arrangement or pixel hit-mask implementation.

Selection, hover, refresh and preview cannot equip, recalculate armor by mutation, activate powers or grant rewards. UI may show a clearly distinguished preview of a proposed arrangement, but only committed state represents current equipment. No new preview UI is required by this feature.

Before acting on a delayed selection, revalidate the selected item identity, custody, eligibility, layout and active session. A replacement occupant in the same slot is not the original target. ITEM-010 no-op, all-slot replacement permission and once-only transitions remain binding; UI refresh cannot reset preparation or replay shield initial selection.

## Relevant formulas and parameters

No new numerical career penalties, fit restrictions, curse chances/durations/cure costs, equipment delays or armor formulas are approved. Eligibility uses resolved supported restrictions and durability state, not numeric enum arithmetic as a native contract. COMBAT-002 timing and ITEM-010 split/occupancy rules remain unchanged.

## Required data

Stable actor/item/slot/layout/session/provider IDs; resolved career/instance restriction policies and versions; durability/eligibility context; current custody/bindings; future-equip versus removal semantics; authorized overrides; curse state/discovery/removal and forced-lifecycle compatibility; player knowledge/display permissions; rejection/error reasons and pending action identity. Concrete schemas remain dependencies.

## Inputs, outputs and events

Inputs: pure eligibility/removal checks, authorized equip/unequip or forced-transition requests, restriction changes, committed bindings, player knowledge and deferred UI/restore context. Outputs: eligible/blocked/distinct technical errors; supported removal plan/recovery; truthful committed display and knowledge-safe feedback. Queries/presentation are not equip/use/armor events. Committed owner notifications cannot independently repeat lifecycle changes. Concrete APIs/signals remain unselected.

## Cross-system interactions

CHAR definitions supply career restrictions; DATA/MOD validate policy/provider identities and added-type mappings. ITEM-010 owns actual placement/removal, ITEM-012 derived armor/power transitions, ITEM-019 identification/display knowledge and ITEM-025 persistence. ITEM-001–009 preserve custody/contents/weight/payment boundaries. COMBAT-001/002 own readiness/preparation, MAGIC owns source/curse/effect/form lifecycles and QUEST forced-action protection. UI renders owner outcomes; CORE/SAVE coordinate restore/provider compatibility. No future feature is finalized automatically.

## Edge cases and failure conditions

- Script/NPC equip of career-prohibited/broken item: same authoritative checks unless explicit authorized policy says otherwise.
- Added material without restriction mapping or missing provider: invalid/unavailable, not freely eligible fallback.
- Career changes with an equipped item: declared future-only/removal rule, not silent deletion.
- Voluntary removal of prohibited career gear: career prohibition alone cannot trap it.
- Curse versus expiry/break/form/quest: explicit compatible policy or validation/recovery, no silent override/destruction.
- Hidden curse removal rejected: knowledge-safe resistance feedback, no automatic power/cure disclosure.
- Stale slot click after replacement: reject/revalidate original identity, never act on new occupant.
- Multi-slot UI hit: targets whole bound item without partial unequip.

## Configuration and balancing options

Validated career/material/type restrictions, explicit special overrides, future-equip/removal semantics and mod curse profiles are supported. Mods can define removal/discovery/recovery conditions and compatible forced-lifecycle interactions. No vanilla curse content, arbitrary global veto, new race/gender ban or automatic identification is introduced. UI customization cannot independently change authoritative eligibility or powers.

## Save/load considerations

Persist relevant restriction/curse state, provenance/provider versions and discovery/removal facts. Rebuild eligibility and committed presentation from compatible authoritative state without clearing/reapplying curses, changing knowledge, repeating rewards or bypassing preparation. Required changed/missing definitions/providers need explicit migration/recovery under DATA-010/CORE-013; generic freely-removable fallback is not allowed.

Restriction changes/load conflicts require declared existing-item policy and ITEM-010 layout recovery. Preserve possessions and owner lifecycle commitments; do not silently invoke a new equip/unequip to make UI look consistent. Deferred actions use new session context and reject old callbacks. Exact native schemas, save boundaries and compatibility fixtures remain integration work.

## Technical constraints

Target Godot 4.7.2. Separate pure shared eligibility, owner-approved mutation and presentation/knowledge. Use stable identity for UI actions and type mappings; avoid global-player context, transient slot positions and legacy bitfield limitations in native policies. No fixed UI layout, generic curse framework architecture or unrestricted executable policy mechanism is mandated. No implementation/coding tasks authorized; reference source unchanged.

## Acceptance criteria

1. All equip callers share explicit actor/item/context eligibility; special overrides require declared authority.
2. Baseline broken/career restrictions apply through validated mappings, with supported added types and no appearance-only race/gender prohibition.
3. Checks/hover/selection/refresh/indicators cannot mutate equipment/powers/armor or disclose hidden knowledge beyond approved rules.
4. Changing restrictions follows declared future-only/removal semantics with preserved possessions and coordinated owner transitions.
5. Career prohibitions do not block unequip; supported mod curses define explicit feedback/removal/recovery without adding vanilla curses automatically.
6. Curse forced-lifecycle interactions validate explicitly or recover without silent override, destruction or partial multi-slot state.
7. Knowledge-safe rejection can disclose resistance without revealing exact curse/powers/cure automatically.
8. Custom/multi-slot items remain selectable/inspectable by stable committed identities; stale UI cannot target a replacement item.
9. Native restore preserves restriction/provider/discovery state without clearing/reapplying curses, replaying effects or bypassing preparation; missing required providers need migration/recovery.

## Contradiction review

Reviewed against approved ITEM-001–010, COMBAT-001/002 and relevant CHAR career, MAGIC-016/029 and CORE restore boundaries. No direct contradiction identified. Shared eligibility complements ITEM-010 whole-plan validation, not a replacement. Mod curse support does not override approved forced lifecycles or introduce vanilla content. Clicking identifies an interaction target, not hidden magical properties. Armor/power mutation remains ITEM-012/owner work rather than refresh logic. Future ITEM-019/QUEST/MOD details remain dependencies.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: career/added-type/durability eligibility schemas; restriction composition/override authority; concrete curse activation/removal/discovery and forced-lifecycle profiles; knowledge-safe reason/indicator rules; custom-layout interaction/presentation; native compatibility/migration and stale-action fixtures. Concrete curse content needs explicit owner decisions before support is claimed. These cannot waive authoritative checks, possession preservation, knowledge boundaries or lifecycle compatibility.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-011-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented eligibility/override schemas, concrete curse/discovery/removal profiles, forced-lifecycle compatibility, knowledge-safe presentation, custom-layout interaction and native migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
