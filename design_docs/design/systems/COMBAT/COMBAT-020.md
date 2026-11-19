# COMBAT-020 — Enemy death and quest synchronization

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Make confirmed enemy death definitive immediately while safely completing quest reactions and corpse readiness. Preserve identity, attribution and pending obligations through failures/retries/save-load without living dead actors, duplicate kills or incomplete loot exposure.

## Confirmed requirements

COMBAT-020-D01–D11 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews. The complete specification is approved under COMBAT-020-A01. COMBAT-010/011 determine authoritative combat outcome/termination; COMBAT-008 requires lethal-arrow corpse recovery; COMBAT-021 will define corpse creation/item transfer. This feature specifies milestones and required-work coordination rather than complete corpse contents or quest scripting semantics.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity and failure/save scenarios unverified. Source unchanged. Paths relative to reference `Assets/Scripts/`.

- `Game/EnemyDeath.cs#EnemyEntity_OnDeath` sets performDeath; Update calls CompleteDeath. QuestResourceBehaviour.IsFoeDead gates completion. Actor is then deactivated rather than destroyed to retain saved enemy state.
- CompleteDeath shows optional death text, creates quest-tagged corpse, unequips/transfers items, plays body sound, clears player alert when relevant and raises static OnEnemyDeath. This bundles multiple gameplay/presentation milestones and has no explicit local recovery contract for partial failure.
- `Game/Questing/Components/QuestResourceBehaviour.cs` processes first injury before death, returning after SetInjured. It later increments foe kills/sets isFoeDead. AddItemQueue targets either live actor collection or existing CorpseLootContainer and tracks queue position. Target preserves legitimate injury/death ordering and late-item routing using explicit stable receipts rather than scene-reference timing alone.

## Detailed rules and behaviors

### Death Confirmed

On authoritative enemy death, immediately stop ordinary AI/attacks, remove living-target eligibility and prevent repeated kill/death admission. Remaining combat components follow COMBAT-010 interruption rules; independent released projectiles retain COMBAT-009/014 lifetime. Finality here concerns ordinary actor life, not permission to discard unresolved effects/rewards/quest work.

Record stable actor/death/session/location identity, true source attribution and settled outcome independently of active scene representation. Optional deactivation/destruction/render replacement cannot erase that record or its quest/inventory/corpse association. No cleanup or load implies resurrection; any future resurrection policy requires an explicit owner contract, not accidental scene recreation.

Remove only this dead actor's threat contribution immediately. Other living actors continue contributing under NPC's alert and purpose-specific rest/exhaustion threat policies. Do not globally clear player alert or keep dead actor counted until corpse completion. Dead representation may remain visible but cannot act as a living combat target.

### Death Finalized / Corpse Ready

Separate Death Confirmed from successful finalization/corpse readiness. Attribution and quest death facts attach to confirmed death; actual owner rewards/credit still require their own predicates/receipts. Loot-ready notification waits for required quest work and COMBAT-021 corpse/inventory boundary to complete. Neither event is a second kill.

During pending work, actor stays dead and corpse inventory remains unavailable. Optional death visuals may appear immediately; safe ordinary gameplay can continue rather than universally suspending the world. Attempted remains interaction may explain temporary unavailability instead of exposing an empty/partial inventory as final loot. Exact visual affordance/wording and collision remain NPC/AV/MOVE integration.

Finalized means required gameplay work succeeded with stable corpse/inventory association and required completion results recorded, not merely animation ended, actor hidden or event callback fired. COMBAT-021 determines exact construction/transfer prerequisites; failed optional presentation does not unfinalize gameplay.

### Quest acknowledgment and ordered reactions

Quest-linked confirmed death submits one stable death fact with actor/quest/resource/source/death identity. Required death-related quest work reports explicit completion/pending/failure; absence of a boolean update is not success. Wait at required corpse/inventory boundary until applicable required work finishes or its obligation is explicitly retained for owner recovery.

If one hit both first injures and kills a quest foe, process applicable first-injury reaction before killed-foe reaction. This orders quest work/notifications, not the authoritative physical death transition: actor is already dead and cannot act again during quest processing. Track each qualifying reaction/count once; a technical retry cannot SetInjured/IncrementKills repeatedly. Exact quest script actions/priority and which work is required are QUEST-owned.

Required quest-item placement tied to original death must settle before initial loot readiness. Source is allowed to prepare an actor-owned inventory grant and transfer it with corpse or target prepared corpse through declared ownership, but COMBAT-021/ITEM must prevent loss/duplication. No cleanup may remove the only item/quest reference before destination commitment.

Missing acknowledgment or failed required quest work enters bounded explicit recovery, not invisible indefinite polling. Owner contracts must declare progress/failure detection, bounded retry/wait budget and safe recovery interface. No arbitrary timeout value, automatic success acknowledgment, dropped quest obligation or rerun of entire script is approved. Local unavailable remains can coexist with safe world activity; an unsafe global state requires CORE-owned gating rather than pretending completion.

### Later quest items and retained associations

A legitimate later quest action may add an item to associated ready corpse using retained actor–corpse identity and exactly-once transfer identity. This is a new owner-authorized action, not replay of original death prerequisites. Do not recreate corpse, revive actor, reset looted inventory or regenerate old grant merely because a quest action arrives late.

Exact handling when corpse is no longer retained/accessible, actor association changes or required content is missing remains QUEST/ITEM/LOC lifecycle/recovery contract. Do not silently put item into an unrelated nearby corpse or player inventory. Required original work still gates first readiness; genuinely later grants do not retroactively make the completed original boundary false.

### Retrying and publication

Reuse same death outcome, attribution, prepared corpse/loot identities and retained work results across finalization retries. No resurrection, loot reroll, kill-count increment, duplicate reward or second corpse from repeating delivery. Each required owner operation needs checked identity/completion, distinct from optional observation.

Retain partial completion when technical failure occurs after quest processing/corpse preparation/transfer. Resume or reconcile pending same-death work through explicit recovery; no universal rollback or whole-death rerun is promised. Required finalization notifications/reward consumers must be reliable and idempotent, not optional UI handlers that can lose gameplay facts.

Publish finalization/loot-ready outcome only when its defined gameplay boundary succeeds. Optional text/body audio and other observation failures cannot replay gameplay, block authoritative death or prevent corpse completion. Exact per-owner notification order/receipt persistence remains implementation contract.

### Optional alert and presentation

Enemy-death text alert is settings-configurable and enabled by default. Present once after successful finalization, separate from any immediate death visuals. Respect legitimately available identity/location information: do not reveal hidden enemy names/positions through alert. No new mandatory death popup, camera movement or player death sequence is added.

Missing text/audio never blocks death/corpse work. Already-played feedback must not replay on retry/restore. AV owns collapse sound/asset mappings, visibility/disclosure eligibility and duplicate sound arbitration with COMBAT-012 lethal feedback. Detailed corpse art/placement belongs to COMBAT-021.

## Relevant formulas and parameters

One authoritative Death Confirmed per actor death operation; one successful finalization boundary per same operation; applicable first-injury/kill/reward/transfer contributions counted under stable owner identities. Confirmed dead actor's living threat contribution=0 regardless of pending finalization. No new XP amount, kill-credit formula, loot generation distribution or corpse lifetime is selected.

Enemy-death text preference default=true. Required-work retry/wait budgets must be bounded but numeric defaults remain QUEST/CORE dependencies. Source flag polling/frame count is not a gameplay clock or proof of acknowledgment. No native unit/animation duration formula is added.

## Required data

Actor/death/session/location and true source identity; confirmed death/stop/threat state; quest/resource associations; applicable first-injury/killed facts and required-work progress/receipts; prepared corpse/loot identities and ownership boundary; finalization/readiness/result publication; late grant identities; pending recovery and optional feedback completion/preferences. Raw scene instance, a single performDeath flag or IsFoeDead boolean alone cannot represent partial obligations.

## Inputs, outputs and events

Inputs: confirmed authoritative enemy death, applicable quest reactions/work outcomes, COMBAT-021 preparation/transfer results, late quest grants, lifecycle/save and presentation settings. Outputs: immediately dead/ineligible actor, removed actor threat, retained Death Confirmed fact, pending/unavailable remains, finalized/corpse-ready result, checked owner notifications or explicit recovery. APIs/event names remain unselected; observing a result cannot kill/reward/create corpse again.

## Cross-system interactions

COMBAT-010/011 death/component termination, COMBAT-012 lethal feedback, COMBAT-008 lethal-arrow inventory association, COMBAT-018 civilian/guard distinct actor policies, COMBAT-021 corpse/transfer; QUEST first-injury/killed/late grants, NPC life/threat/representation, ITEM inventory identity, CHAR health/prevention, LAW/FACT/QUEST source/reward predicates; CORE safe gating, SAVE stable records, AV text/audio and MOD/DATA validated content contracts. No player-death/court flow is adopted for enemy cleanup.

## Edge cases and failure conditions

Verify lethal first injury, multiple death events, overkill/duplicate impacts, queued quest item, missing quest acknowledgment, legitimate pending work and required hook failure. Dead actors never return to ordinary AI while waiting. First-injury-before-kill cannot delay physical death or suppress required kill fact.

Verify arrow recovery on lethal hit, partial actor/corpse transfer, scene unload/reload, previously looted ready corpse receiving legitimate later grant and unavailable corpse identity. Preserve completed inventory/kill results without arbitrary fallback target or reroll. Exact corpse disposal/late-item policies require later owner contracts.

Verify another living threat while one dies, pending corpse rest/threat checks, hidden kill notifications and disabled/missing feedback. Do not globally clear alert, leak hidden information or depend on blood/audio success. Snapshot/restore cannot reemit death/reward under new IDs.

## Configuration and balancing options

Settings-configurable death text enabled by default; owner-declared quest required-work/retry/recovery and notification policies; validated content/mod integrations may define supported additional death reactions. This feature does not approve generic arbitrary death replacement, resurrection, reward values, quest auto-success, corpse disposal or new loot formulas. Exact schemas/provider precedence and recovery budgets remain dependencies.

## Save/load considerations

Support native saves containing confirmed-dead actors with pending quest/corpse work when all progress/required obligations can be captured coherently. Persist death/source identity, processed quest/reward facts, prepared corpse/loot identities, transfer/readiness completion and pending recovery. Restore continues pending same-operation work; it cannot replay death, show incomplete loot or regenerate/reward again.

When a current phase cannot be safely serialized, temporarily block saving with explanation, rather than silently dropping obligations or pretending finalization complete. Existing saves remain unchanged. Exact coherent boundary/migration/versioned owner schema remains SAVE/QUEST/ITEM integration.

Reconstruct dead/nonthreatening state before ordinary simulation; restore required associations/geometry before finalizing or exposing loot. Optional already-presented text/audio is not replayed. COMBAT-009/014 pending projectiles/impacts must coordinate with death records so one lethal shot cannot create a second death or recovered arrow after load.

## Technical constraints

Target Godot 4.7.2. Separate authoritative death, ordered required quest work, corpse readiness and optional presentation. Use stable identities and explicit pending/completed/failed results, bounded recovery and idempotent owner receipts. Avoid deactivate-before-safe-state loss, unbounded boolean polling or static observer callback as sole durable completion. Native quest/transfer/threat/save failure fixtures required. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Confirmed death immediately disables living AI/attacks/target eligibility and removes only that actor's threat while required finalization may remain pending.
2. Stable death/actor/source identity survives representation cleanup, retry and native restore without another kill or fabricated life state.
3. Death Confirmed and Finalized/Corpse Ready are distinct; attribution/quest facts use confirmation and loot-ready publication waits required completion.
4. Required quest work acknowledges explicitly; missing acknowledgment uses bounded recovery without dropping obligations or invisible endless wait.
5. Applicable first-injury work precedes killed reaction on lethal hit, both once, without allowing actor to act again.
6. Pending remains inventory is unavailable; safe gameplay may continue, optional visuals may show and attempted interaction can explain temporary state.
7. Late valid quest grants address retained corpse association exactly once without corpse recreation/reset of prior loot.
8. Retries retain prepared identities/results rather than reroll loot/reward/kill counts; partial errors resume/reconcile pending work explicitly.
9. Optional death text defaults on, once after finalization with safe disclosure; missing/disabled audio/text cannot block gameplay completion or replay effects.
10. Coherent pending-death saves restore progress without death/inventory/reward replay; unsafe save phases block temporarily with explanation.

## Contradiction review

Reviewed against approved COMBAT-008–018, CHAR health/death ownership and CORE/SAVE principles plus inspected quest/death source/catalog/architecture. No direct contradiction identified. Physical death immediately invalidates target while quest reaction order remains logically first-injury-before-kill, not a living-state delay. COMBAT-008 corpse-safe arrow recovery remains required during subsequent transfer. Per-actor threat removal preserves purpose-specific threat policies. Pending-save support is conditional on coherent serialization, not approval to capture half-transfer states. No unreviewed COMBAT-021 item contents/placement details are finalized here. Broader architecture proposals remain Proposed.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: QUEST acknowledgment/work inventory/order and recovery budgets; stable actor/corpse association; actual transfer/finalization boundary under COMBAT-021; late grants after corpse disposal; owner fact/reward receipts; threat/disclosure mappings and native pending-save fixtures. These cannot leave dead enemies attacking, expose unfinished loot, duplicate quest kills/rewards or silently wait forever. COMBAT-021 and detailed QUEST/ITEM lifetime reviews remain separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-020-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented quest work/recovery budgets, corpse associations, transfer boundaries, owner receipts and pending-save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
