# FACT-010 — Joining and leaving

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-010-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-010-interview-decisions).

## Gameplay purpose and intended experience

Players can qualify for ordinary guild membership through lasting skill and faction standing. They can resign through an authorized provider and later apply again. The confirmation identifies the guild and variant, and the result explains when a conflicting membership must be ended first.

## Confirmed requirements

- Use DFU's ordinary admission thresholds as stock defaults. Validated guild policies may use different skills, thresholds, or prerequisites. Recheck eligibility and the variant limit when the player confirms. An existing exact membership retains its rank and dates. A conflicting temple or order requires separate resignation.
- Allow ordinary resignation through an authorized provider after confirmation. Resignation ends future member access and preserves faction standing and existing quest obligations, subject to explicitly authored rules. Rejoining requires fresh eligibility and starts at rank 0 with a new join date. Guild policies can declare exceptions, including a rejoin cooldown. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-010-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Guilds/Guild.cs#IsEligibleToJoin` reads faction reputation and counts permanent guild skills. `Join` sets rank 0 and records the current game day as the last rank change. `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#JoinButton_OnMouseClick` checks eligibility before opening confirmation. The confirmation handler calls `GuildManager.AddMembership` without repeating that check. `GuildManager.RemoveMembership` invokes the guild's leave hook and removes its membership entry. The ordinary guildhall flow inspected here exposes joining. The removal path also serves expulsion, and crime guilds have specialized initiation and membership hooks.

## Detailed rules and formulas

1. Resolve the authorized provider, exact guild and variant, applicable membership set, and standing faction under FACT-001/009. Evaluate admission as a read-only query. For stock ordinary admission, require committed standing of at least 0 and at least one distinct permanent guild skill at 22 or higher plus a second at 4 or higher. Two skills at 22 qualify. In equivalent terms, require at least one skill at 22 and at least two distinct skills at 4. Temporary skill boosts and live dialogue modifiers do not contribute.
2. On confirmation, revalidate the same provider and target, the applicable membership set, the current admission policy, and group capacity. If an exact membership already exists, return it without changing rank, dates, or benefits. If an exclusive group already contains another variant, report the conflict and leave both membership states intact. Resignation requires its own confirmed action.
3. Commit successful ordinary admission at rank 0 with the current game day as the join date and initial last rank change. Publish success after commitment. A later rejoin is a fresh admission under current rules and receives fresh dates.
4. An authorized resignation request identifies the exact membership and explains the loss of member access. Revalidate it on confirmation. Remove the active membership and end future member eligibility for that organization. Apply explicitly authored consequences through their owners. Existing quest bindings and settled consequences remain governed by their quest contracts.
5. Expulsion and rank transitions belong to FACT-011. Crime-guild recruitment belongs to FACT-012. Neither flow is treated as ordinary voluntary admission or resignation.

## Approved integration defaults

- A confirmation is scoped to the current character, membership set, provider, and exact target. A changed or unavailable context requires a new request. Declining or dismissing the prompt leaves membership intact.
- An already completed request returns its recorded outcome within its supported retry lifetime. A fresh resignation for an absent membership has no effect. Only committed transitions publish membership change notifications. A later rejoin creates a new membership, so retrying an old resignation cannot remove it.
- Stock ordinary guilds have no extra cooldown. For a configured cooldown, retain the departure date and evaluate eligibility against elapsed game days under the guild's policy.

## Required data, inputs, outputs, and events

Use stable guild, variant, provider, faction, character, and membership set references, current permanent skills, faction standing, guild admission policy, group limits, world day, and applicable departure history. A confirmed operation carries its exact target and request identity. Return eligibility, a reason for denial, committed join or resignation, already member, or an explicit unavailable or stale result. Emit membership changes only after commitment.

## Cross-system interactions

FACT-009 resolves exact membership context and limits. FACT-002 provides committed standing. CHAR-011 provides skill values. TIME provides world day. NPC and UI present and confirm authorized choices. QUEST-002 and service owners evaluate future eligibility, and QUEST-008/019 preserve existing bindings and committed consequences. FACT-011/012 and FACT-018 own adjacent transitions and restore integration.

## Edge cases and failure conditions

- A player at standing 0 with distinct skills at 22 and 4 qualifies. A single skill at 22 and all others below 4 fails. A missing required faction is unavailable rather than an eligible neutral score.
- Eligibility can change while the prompt is open. Confirmation uses current standing, permanent skills, and capacity before admission.
- A request to join another stock deity cannot silently remove the first. Resigning does not settle or fail an active quest by itself.
- An old or repeated confirmation cannot reset rank, repeat a join or leave effect, or affect a replacement membership.

## Configuration and balancing

Validated policies can configure the eligible skill list, standing and skill thresholds, additional prerequisites, resignation exceptions, and rejoin cooldowns. Count distinct skills. Admission at rank 0 and the applicable FACT-009 group limit remain the ordinary defaults.

## Save/load considerations

Persist active membership identity, rank, join date and last rank change, and any departure history or settled request outcome required by a supported policy. Restore these through FACT-018 without calling join or leave hooks. An uncommitted ordinary confirmation closes on reload and can be opened again through its provider.

## Technical constraints and consistency review

Make eligibility evaluation read-only. Commit membership before exposing its benefits or welcome result. Keep standing, quest obligations, and membership separate. Review found no conflict with FACT-009's variant limits, FACT-002's standing checks, or QUEST-002/008/019's provider, binding, and consequence rules.

## Acceptance criteria

1. Stock admission passes at the exact standing and permanent skill thresholds. Temporary bonuses, missing required faction context, and a repeated skill ID cannot make an otherwise ineligible character qualify.
2. Confirming after eligibility or group capacity changes cannot add membership. A conflicting variant stays active until separately resigned.
3. A successful join records rank 0 and the current game day. A duplicate join preserves existing rank and dates.
4. Confirmed resignation removes future member access while retaining standing and existing quest obligations under their owner rules. A fresh rejoin requires current eligibility and any configured cooldown.
5. Reload preserves committed membership and required departure history. A repeated old resignation cannot remove a new membership.

## Outstanding questions

Exact request retention and save schema remain integration details. Specialized recruitment and expulsion remain separate feature decisions.
