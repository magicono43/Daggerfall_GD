# QUEST-002 — Guild offer eligibility

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-002-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-002-interview-decisions).

## Gameplay purpose and intended player experience

Guild membership, rank and standing open up work appropriate to the player. Some guilds also offer work to outsiders. By default, asking for work produces one assignment offer. Players who enable the guild quest picker can choose among eligible assignments. When there is no eligible work, the guild can give general guidance without revealing unavailable quests or exact requirements.

## Confirmed requirements

- Preserve DFU stock eligibility outcomes with explicit typed requirements, including the zero-requirement nonmember exception, Holy Order general and deity-specific work, and level substitution where allowed.
- Default to random assignment and offer an optional picker showing eligible quests only. General guidance can explain why work may be unavailable.
- Gate adult-tagged quests through a dedicated mature quest content setting independent of visual nudity.

See QUEST-002-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-002-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/QuestListsManager.cs#GetGuildQuestPool` matches membership, checks `minReq` against rank or reputation, and filters adult and previously accepted one-time rows. `GetGuildQuest` calls `SelectQuest` for a random draw. `Assets/Scripts/Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#GetQuest` supplies guild context, checks for a questor reservation, and uses `GuildQuestListBox` to choose between the picker and a random draw. The picker resolves quest display titles. These findings are from static inspection.

## Detailed rules and formulas

1. Resolve the authorized provider, guild group, membership status, rank, applicable reputation and faction context. The guild owner supplies those values. Respect active quest reservations under NPC-023 and the applicable interaction rules.
2. Evaluate only entries for the requested guild group. Match the authored audience. Stock member and nonmember rows match their respective audiences. Holy Order members qualify for both general member entries and entries for their own deity. Nonmembers use the nonmember audience.
3. Apply the typed requirement. The stock effective rank is `max(guild rank, player level)` when the guild permits level substitution for this request. Otherwise use the caller's applicable rank value. Rank and reputation checks pass at equality. For stock imports, `minReq < 10` maps to minimum rank and `minReq >= 10` maps to minimum reputation. A stock zero-requirement row for nonmembers maps to an unrestricted requirement for that audience, preserving the outcome even when effective rank is below zero. Authored requirements declare their type directly, including reputation thresholds below 10.
4. Exclude adult-tagged entries when mature quest content is disabled. Exclude one-time entries when QUEST-004 reports prior acceptance for that quest. Evaluate eligibility before collapsing matches to one candidate per quest definition under QUEST-001.
5. For the default flow, draw uniformly from the distinct eligible candidates. With the picker enabled, show only those candidates and identify each choice by stable definition ID. Choosing a candidate opens its offer under the ordinary interaction contract. Acceptance is a separate choice. An empty pool gives a no-work response with optional general guidance that fits the context.

## Required data, inputs, outputs and events

Inputs include validated list entries, stable guild, deity, faction, provider and quest IDs, audience and requirement type/value, rank, level, applicable reputation, level-substitution policy, content tags, settings, provider authorization and acceptance history. Output is a distinct eligible pool or a contextual no-work result. The selection flow yields an offer candidate or an explicit availability failure. Presentation and acceptance events belong to the offer lifecycle. Eligibility queries and picker construction have no acceptance or reward effects.

## Cross-system interactions

- QUEST-001 and DATA-012 supply validated entries, stable definition references and pool deduplication. QUEST-004 owns one-time history and when it changes.
- FACT supplies guild membership, deity, rank, level-substitution policy and reputation context. CHAR supplies player level. The quest's reputation target comes from the authorized guild/faction context.
- NPC-023 and MOVE-023 govern provider authorization, reservations, presentation and consequential choice. UI displays picker choices and no-work feedback. CORE settings own preference persistence and application. RULE owns random draws and SAVE restores durable owner state.

## Edge cases and failure conditions

- An unknown guild pool or a valid pool with zero eligible entries yields no work. Missing required provider or faction data uses explicit owner failure handling.
- Threshold boundaries preserve stock outcomes. An imported 9 checks rank and an imported 10 checks reputation. An authored minimum reputation of 5 checks reputation. General Holy Order work and deity work can both qualify, with overlapping definitions receiving one slot.
- Revalidate current eligibility and authorization at consequential choice. A stale picker row cannot resolve to a different quest after refresh. If a settled offer loses eligibility, use the existing offer owner's unavailable outcome. Redraw and reload preserve settled outcomes under the owner contract.
- A runtime generation or binding failure is distinguishable from an empty eligible pool. Retry and recovery policy remain open. A failed display or a declined offer does not itself mark a quest accepted.

## Configuration and balancing

Authors can configure validated audiences, thresholds, content tags and supported level substitution through the owning definitions. Player settings select the optional picker and independently control mature quest eligibility. The mature setting applies to this feature's offer eligibility. Policies for already active quests and adoption by other offer channels belong to their own review.

## Save/load considerations

Rebuild eligible pools from current resolved content, settings and restored owner state. Restore durable one-time acceptance and supported settled offers before allowing new consequential choices. Save/load cannot spend an offer again, reroll a settled offer or clear acceptance history. Exact preference storage and offer snapshot format remain CORE, NPC, QUEST and SAVE integration details.

## Technical constraints

Target Godot 4.7.2. Use stable IDs and typed requirements. Keep evaluation side-effect-free and separate from quest instantiation. Resolve localized titles for display independently of row identity. Require the relevant owner inputs for each eligibility decision.

## Acceptance criteria

1. Stock rows preserve membership and threshold outcomes at boundary values, including zero-requirement nonmember access, level substitution only where permitted, and Holy Order deity plus general membership.
2. Authored minimum reputation below 10 evaluates against reputation. Equality satisfies rank and reputation minimums.
3. Adult-tagged entries respond to the dedicated mature quest setting while visual nudity can vary independently. Previously accepted one-time entries are excluded.
4. The default draws uniformly from distinct eligible quests. The optional picker lists the same eligible set, and choosing a row opens an offer without accepting it. Empty pools yield appropriate no-work feedback.
5. A stale choice, invalid provider, or repeated callback cannot bind another quest, duplicate acceptance, or bypass eligibility.

## Compatibility review and outstanding questions

The specification follows QUEST-001 deduplication, DATA-012 validated source and history contracts, and NPC-023 and MOVE-023 offer continuity and revalidation. Open integration details include the mature setting's default and application timing, provider-specific FACT adapters, picker ordering and title exposure, and runtime generation failure and retry behavior.
