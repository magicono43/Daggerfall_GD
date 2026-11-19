# FACT-013 — Guild quest access and progression requirements

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-013-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-013-interview-decisions).

## Gameplay purpose and intended experience

Guild providers offer work appropriate to the player's membership, progression, and standing. Experienced characters can qualify for some stock assignments through player level. Authors can reserve other work for a particular rank or a completed storyline. Once accepted, an assignment keeps its authorized faction context.

## Confirmed requirements

- For stock Mages Guild and knightly order offers, allow player level to substitute for rank where the entry permits it. Make substitution moddable per guild or variant. An authored offer can require actual rank. Membership, standing, and other gates still apply.
- Allow authored combinations of membership, rank, committed faction standing, and recorded quest outcomes. Resolve the faction used for eligibility separately from the authorized consequence target. Both roles may use the same faction. Recheck eligibility on acceptance and preserve the accepted faction binding under the quest's authored rules. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-013-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Guilds/Guild.cs#IsSatisfyQuestReqByLevel` defaults to false. `MagesGuild.cs` and `KnightlyOrder.cs` override it to true. `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#GetQuest` checks the provider's quest reservation, resolves membership audience, and passes standing and effective rank to the pool. Its consequence faction comes from the building faction for temples and orders and the guild group mapping for other guilds. The generic nonmember object's faction lookup returns ID 0. `Game/Questing/QuestListsManager.cs#GetGuildQuestPool` checks member or nonmember audience, adds general member entries for deity members, interprets the imported minimum as rank or standing, and filters mature and previously accepted one-time entries.

## Detailed rules and formulas

1. Resolve the authorized provider, exact guild and variant, active membership set, audience, and applicable standing context under FACT-001/009. Use the committed rank after any due FACT-011 visit review. A valid nonmember context can access the provider's authorized nonmember audience. A member of another variant does not supply rank or membership to this provider.
2. For a rank gate that permits substitution, use `effectiveRank = max(applicableRank, playerLevel)` only when the provider's guild or variant policy enables it. Otherwise use the applicable actual rank. An explicit actual-rank requirement uses the exact membership's committed rank and is unsatisfied without that membership. Rank and standing minimums are inclusive. Level substitution cannot satisfy audience, standing, or recorded quest outcome requirements.
3. Apply QUEST-002's stock audience and import rules. A Holy Order member can qualify for general member rows and rows for their own deity. An imported minimum below 10 maps to rank and a minimum of 10 or higher maps to standing. A stock nonmember row with a zero minimum is unrestricted for its audience. New entries declare the requirement type explicitly. QUEST-002 owns pool filtering, deduplication, selection, and one-time history.
4. For authored combinations, evaluate each declared requirement against its owner. Membership and rank come from the exact provider context, standing comes from FACT-002, and quest outcome requirements use committed outcome references and selectors under QUEST-020. Live reaction modifiers are excluded from ordinary standing checks under FACT-005.
5. Resolve the eligibility faction and authorized consequence context independently. Capture the provider and authorized faction context in the offer. Before acceptance, revalidate the selected entry, exact provider, audience, and current requirements under QUEST-002/008 and NPC-023. An invalidated offer cannot commit. On successful activation preserve the authorized binding for later consequences under QUEST-019. Explicit quest rules govern later changes.

## Approved integration defaults

- Resolve level-substitution policy at the exact variant first, then use its guild default. Where no policy enables it, use the applicable actual rank. Authored rank gates may explicitly disallow substitution even when the provider enables it.
- Resolve standing only when a declared gate needs it. A valid unrestricted nonmember offer can proceed with no standing predicate. A missing required eligibility faction, consequence target, or outcome dependency yields an explicit validation or recovery result.
- Requirement evaluation is read-only. Revalidation of an open offer does not draw a replacement or consume one-time history. QUEST-002 owns any new offer flow after an unavailable result.

## Required data, inputs, outputs, and events

Use stable provider, guild, variant, membership set, eligibility faction, consequence target, quest, and outcome identities. Inputs include audience, committed rank and standing, player level, applicable substitution policy, and authored predicates. Outputs include a resolved offer context, eligible or ineligible result, or explicit unavailability. Queries emit no rank, reward, or acceptance effects. QUEST owns offer and activation events.

## Cross-system interactions

FACT-009 resolves exact membership context. FACT-011 owns rank review. FACT-001/002/005 supply faction context and committed standing. CHAR supplies level. NPC-023 supplies provider availability and reservations. QUEST-002/008 own selection and activation, QUEST-019 owns consequence settlement, and QUEST-020 supplies recorded outcome selectors. DATA and MOD validate authored policies and dependencies. SAVE restores accepted bindings.

## Edge cases and failure conditions

- A rank 2, level 8 member can pass a substitution-enabled minimum of 5 and fail an actual-rank minimum of 5. Membership and standing gates still evaluate independently.
- A member visiting a different deity's provider gets that provider's nonmember audience. A valid nonmember row with a stock zero requirement remains available when its other rules pass.
- Losing standing, membership, or provider authorization while an offer is open can block acceptance. Those changes alone do not redirect an accepted quest's reward.
- A missing required context cannot become neutral standing or qualify as a recorded quest failure.

## Configuration and balancing

Stock substitution applies to Mages Guild and knightly order offers under the stock rank-check policy. Validated guild and variant policies can tune substitution. Offer authors can configure audiences, typed thresholds, and outcome predicates. Service and promotion requirements retain their own policies.

## Save/load considerations

Retain the provider and faction context for accepted quests under QUEST-008/019/022. Restore durable membership and quest outcome inputs through their owners. Any supported retained offer must revalidate current eligibility before acceptance. Loading preserves settled consequences and does not reroll an accepted assignment.

## Technical constraints and consistency review

Keep rank, player level, and the calculated quest rank input distinct. Validate author references and preserve the exact provider context across the offer. The draft preserves QUEST-002 stock filtering, FACT-009 variant isolation, FACT-011 rank ownership, and QUEST-008/019/020 binding, settlement, and outcome rules.

## Acceptance criteria

1. A qualifying stock Mages Guild or knightly order offer uses the higher of rank and level for a substitution-enabled rank gate. An actual-rank gate and a standing gate ignore that substitution.
2. Holy Order membership admits general member and matching deity entries. Another deity's provider uses its nonmember context.
3. An authored combination of membership, rank, standing and recorded outcome passes only under its declared rules. Missing required inputs yield explicit failure.
4. A stale offer fails revalidation without committing or consuming history. A successfully accepted quest preserves its authorized consequence target through later rank, membership, and standing changes and reload.
5. A validated custom guild or variant can configure its substitution policy independently of stock guilds.

## Outstanding questions

Exact predicate schema, imported faction mappings, and persistence details remain integration work.
