# FACT-012 — Crime-guild recruitment

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-012-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-012-interview-decisions).

## Gameplay purpose and intended experience

Successful illicit deeds can attract the attention of a secret guild. After a delay, the guild makes contact when the player is outdoors. Completing its initiation earns membership. Each guild tracks its own recruitment, and a technical problem delivering contact leaves the opportunity available for recovery.

## Confirmed requirements

- Keep the stock point weights, thresholds, and three-game-day delay. Count each qualifying successful deed once from its authoritative outcome. Make deed types, weights, thresholds, and delays moddable. A failed theft or the start of private-property theft resolution earns no credit.
- Make contact due at the exact due time and deliver it at the next eligible outdoor opportunity, including after travel. A technical activation failure leaves contact pending. An authorized successful initiation grants membership once. Stock authored refusal or failure ends the opportunity. Mods may define explicit retry policies. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-012-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Entities/PlayerEntity.cs#TallyCrimeGuildRequirements` schedules contact three days after reaching 10 thieving points or 15 murder points. `HandleStartingCrimeGuildQuests` requires the time to be strictly past due and the player to be outdoors. It marks the invitation sent and clears the due time before requesting quest start. `Game/Guilds/GuildManager.cs#QuestMachine_OnQuestEnded` grants membership after a successful quest with the configured stock name. `PlayerActivate.cs`, the inventory and trade windows, `WeaponManager.cs`, and `Entities/DaggerfallEntityBehaviour.cs` supply the tallies. The private-property theft path tallies at the start of its resolution. These findings come from static source inspection.

## Stock parameters

| Guild | Qualifying deed | Points | Threshold |
| --- | --- | ---: | ---: |
| Thieves Guild | Successful qualifying exterior lockpicking, pickpocketing, or theft | 1 | 10 |
| Dark Brotherhood | Qualifying civilian murder | 5 | 15 |
| Dark Brotherhood | Qualifying city watch kill | 1 | 15 |

For either guild, the due time is the threshold-crossing game time plus 4,320 game minutes. One point applies per qualifying thieving deed. The owner defines the boundaries of a theft attempt or completed theft, including a single action that takes several items.

## Detailed rules and behaviors

1. Evaluate each committed deed against the recruitment policy using its stable occurrence identity, classification, outcome, and player attribution. Credit one contribution per qualifying deed per policy. Count qualifying successes independently of whether the player was detected, arrested, or convicted. LAW owns crime classification and penalties, and the deed owner supplies its settled outcome.
2. Accumulate points until the threshold is met or exceeded. Capture the crossing time and schedule one pending invitation for the applicable guild. Later deeds do not move the due time or schedule another invitation while one is pending. Stock recruitment progress is separate for each guild.
3. At or after the due time, request initiation through QUEST-008 when the player's current gameplay context is eligible and outdoors. Evaluate eligibility on arrival after a time jump. An advance across an outdoor location does not itself create an interaction there. Keep a stable invitation and activation request identity. Delivery is settled when the required initiation start commits. Decline, authored failure, and technical unavailability remain distinct outcomes.
4. Bind initiation to the authorized invitation, guild and variant, applicable membership set, and quest instance. Successful authored initiation settles the membership award through FACT and QUEST-019. Commit the exact membership at rank 0 with its initial dates. Crime recruitment uses its own eligibility rules. If the exact membership already exists, preserve it and settle without a second join. An unrelated quest with the same display name cannot grant membership.
5. An authored refusal or failure closes the stock opportunity. A validated mod retry policy may define when another attempt can become eligible, including its cooldown, qualifying deeds and whether a fresh invitation is required. Technical activation failure leaves the existing invitation pending for retry or explicit recovery under QUEST.

## Approved integration defaults

- Track each guild's recruitment progress per character and applicable membership set. Retain the selected set on the invitation. If that set is unavailable at delivery or award, defer or use explicit owner recovery. A context switch does not redirect the invitation or award to another set.
- Preserve one stock opportunity per guild and applicable set after contact and authored resolution. Resignation or an existing membership does not automatically reset recruitment progress. A mod policy may explicitly define a new opportunity.
- Retry a blocked activation only when readiness changes or an authorized recovery requests it. Avoid issuing repeated identical prompts or retrying every frame. If both guilds are due, keep their independent requests and let QUEST order eligible presentation.

## Required data, inputs, outputs, and events

Use stable character, guild, variant, policy, membership set, deed, invitation, and quest identities. Retain credited deed progress, the due time, delivery and initiation status, and settled award outcomes. Inputs include authoritative deed outcomes, committed game time and current outdoor readiness, and authorized quest outcomes. Outputs include credit, pending or delivered contact, explicit recovery, closed opportunity, and committed membership. Publish membership benefits only after commitment.

## Cross-system interactions

LAW, COMBAT, MOVE, and ITEM supply authoritative deed classification and outcomes as applicable. TIME supplies due dates and travel arrival. QUEST-008 owns activation and QUEST-019 owns settlement of the membership consequence. FACT-009 resolves membership sets and exact guild variants. FACT-010 supplies ordinary membership context and FACT-011 owns later rank review. FACT-018 and SAVE restore progress and membership. DATA and MOD validate custom policies.

## Edge cases and failure conditions

- Duplicate deed or death delivery cannot add points again. A failed attempt, repeated inventory refresh, or duplicate callback supplies no new success.
- At the exact due minute indoors, the invitation stays pending. At the next eligible outdoor arrival it can be delivered once. If activation fails technically, the same invitation remains available.
- Duplicate success delivery or reload preserves a settled award and cannot reset the current rank. An authored failure closes stock recruitment and never grants membership.
- Missing required guild, quest, policy, or set context uses explicit owner recovery. A technical fault cannot silently count as authored refusal.

## Configuration and balancing

Authors can configure qualifying deed types and outcomes, weights, thresholds, delays, eligible delivery contexts, initiation quests, and retry rules. Stock points and delay use the table above. Validate meaningful positive thresholds and supported references. The recruitment policy governs eligibility for this route.

## Save/load considerations

Persist enough deed accounting to prevent repeat credit, plus points, due time, invitation and quest bindings, pending recovery, and committed outcome. Restore these before processing time or quest callbacks. Loading preserves completed and pending states. Resume outstanding work from the retained state.

## Technical constraints and consistency review

Use a committed deed outcome, a settled activation request, and a settled quest consequence as distinct boundaries. The draft follows QUEST-008's rule that technical start failure preserves eligibility, QUEST-019's explicit target and retry rules, and FACT-009's exact membership identity. The stock thresholds are verified in source. The shipped initiation scripts and their complete branch inventory remain to be verified.

## Acceptance criteria

1. Ten distinct qualifying thieving deeds schedule one Thieves Guild invitation. Failed theft and duplicate delivery add no credit. Three qualifying civilian murders or fifteen qualifying watch kills reach the Dark Brotherhood threshold.
2. Contact is due three game days after threshold crossing. It can activate at the exact due time outdoors or at the next eligible outdoor arrival. An indoor arrival retains it.
3. A technical start failure followed by recovery activates the same invitation once. Stock authored refusal or failure closes the opportunity.
4. A successful authorized initiation grants the exact membership once. Repeated completion, reload, and unrelated quests cannot grant it again or reset rank.
5. A custom recruitment policy can change deed weights, thresholds, delay, and retry behavior independently of the stock policies.

## Outstanding questions

Exact deed event mappings, initiation script coverage, and save schema remain integration details.
