# CHAR-015 — Level rewards and allocation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Claim earned levels and artifact attribute rewards without lost eligibility, rerolled benefits or partial level/health/attribute commits.

## Intended player experience

Choose a safe time to claim a pending reward, distribute its points and confirm a complete result. Vanilla requires finishing once allocation starts. Rewards retain their rolls through recovery; a validated optional mod policy can allow close/resume without early benefits.

## Confirmed requirements

CHAR-015-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish ordinary/artifact baselines, atomic confirmation, distinct ordered rewards, capped remainder handling, mandatory vanilla allocation, unchanged current health, optional mod deferral and safe player-initiated presentation.

CHAR-014 supplies actual/earned target levels and preserved backlog. CHAR-011 governs permanent bounds/live modifiers; allocation changes permanent values, not temporary bonuses. CHAR-005 supplies class HP parameters. CHAR-013 gains/eligibility do not automatically interrupt combat or grant these rewards. CORE/SAVE scope and duplicate-safe restoration remain binding.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#UpdatePlayerValues`: ordinary ReadyToLevelUp rolls FormulaHelper.BonusPool, increments Level and MaxHealth immediately, then creates working attribute allocation. OghmaLevelUp instead supplies the constant 30-point pool without ordinary level/health changes. Shared flags are cleared before allocation completes.
- `CheckIfDoneLeveling` blocks closing with points remaining unless working attributes are all at maximum; completion replaces player stats with working stats. Exit/cancel/hotkey paths call this validation.
- `Game/Formulas/FormulaHelper.cs#BonusPool` samples inclusive integer 4–6 and reseeds Unity randomness from frame count. `CalculateHitPointsPerLevelUp` samples inclusive floor(class HP/2)..class HP, adds a permanent-Endurance modifier and floors gain at one; it reseeds DFRandom from rendered frames. Intended retained outcomes do not require these shared reseeding patterns.
- `FormulaHelper.HitPointsModifier` is floor(Endurance/10)−5.
- `Game/MagicAndEffects/Effects/Special/OghmaInfiniumEffect.cs` sets the shared flags, requests the character sheet and removes the source item. Intended durable reward ownership must prevent item loss/flag collision.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Full save gating, reward overlap and derived-vital behavior remain owner verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Pending rewards and order

Represent ordinary level claims and artifact bonuses as distinct pending rewards with origin/claim identity. Preserve every CHAR-014 eligible level; at most one claim can own a given ordinary level number. Artifact requests cannot overwrite ordinary eligibility or another artifact request.

Process acquisition order and leave an active reward uninterrupted. Multiple ordinary levels earned together are separate level-ordered claims. Record sufficient ordering context when eligibility/reward entitlement is acquired, even though numerical preparation waits until activation. Repeated eligibility evaluation cannot enqueue the same ordinary level twice.

Prepare each reward only when its allocation begins. Later ordinary rewards therefore use permanent Endurance resulting from earlier committed rewards, including earlier artifacts if their acquisition order places them first. Do not roll all future backlog rewards against an earlier stale Endurance value.

Oghma creation and source-item consumption must succeed together, producing exactly one durable 30-point entitlement per valid use. If reward creation fails, do not lose the item; repeated delivery cannot duplicate either consumption or reward. Exact inventory transaction/recovery mechanics remain ITEM/MAGIC/SAVE contracts.

### Ordinary reward baseline

One ordinary claim grants exactly one actual level, uniform integer 4–6 attribute points and maximum-health gain G=max(1,h+floor(E/10)−5), where h is uniform inclusive integer floor(H/2)..H, H is class HP per level and E is permanent Endurance before this reward's allocation.

Resolve and retain the pool, HP roll and resulting gain once at preparation. Reopening, loading, preview refresh and retry cannot reroll them. No frame-dependent reseeding of shared simulation randomness is required or approved by source parity. Record enough captured inputs to explain/validate the prepared result.

Endurance spent within this reward does not improve its already-prepared G, and no previous level's G is recalculated retroactively. Higher Endurance can affect later rewards prepared after this commit. Commit increases raw/base maximum health through the health owner's operation while leaving current health unchanged; do not heal, preserve health percentage or add G twice through temporary max-health modifiers. Exact derived-vital recomputation remains CHAR/vital-owner scope.

### Artifact rewards

Oghma baseline is 30 permanent attribute points, no actual level increase and no ordinary maximum-health roll/grant. Keep the reason/type separate from ordinary claims. Attribute changes can affect derived gameplay values under their owners, but this is not an ordinary level-health award. Validated overrides may adjust supported artifact parameters; further artifact types require explicit definitions/owner support.

### Allocation and confirmation

Capture starting permanent attributes and use an isolated working allocation. Spend/refund one point per increase, never below that reward's starting permanent values or above resolved permanent caps. Temporary buffs/debuffs and live caps do not reduce/increase the permanent allocation budget. Show working changes and remaining points truthfully.

Require all spendable points allocated. If every attribute is at its resolved permanent cap, show the exact unusable remainder and allow explicit confirmation discarding it. Do not convert that remainder into gold, health or another reward, and do not silently discard it before confirmation. All-max rewards remain claimable under this explicit rule, including artifact rewards.

Confirm only a valid complete allocation, then atomically commit actual level where applicable, maximum-health gain, permanent attributes, reward completion and ordinary-level claim result. Until confirmation, none of those benefits apply. Update CHAR-014 after actual-level commit, preserving other pending levels. Prevent partial resource/claim commits on failure; the active prepared reward remains recoverable without rerolling.

### Presentation and deferral

Pending eligibility waits for character-sheet opening or a safe player claim action; it does not force allocation during combat. Integrate an explicit safe-entry policy with UI/COMBAT rather than assume every sheet opening is a safe claim. Exact threat/control conditions are an integration dependency; mandatory allocation cannot be imposed on an unsafe running fight.

Once vanilla allocation begins, hold gameplay suspension and block return to gameplay until confirmation. Refreshing/cancelling/closing the window cannot discard or postpone the active reward. Save/recovery/quit behavior must preserve consistency, not grant permission to lose the reward. Exact application-quit UI is outside this feature.

Support validated mod-only deferral, disabled by default. When enabled, closing can retain the complete prepared reward and partial allocation, applying no benefits; reopening resumes that same active reward. Later rewards cannot overtake it. While deferred gameplay can change underlying permanent state; revalidate before commit and explicitly report/reconcile conflicts without rerolling, overwriting unrelated changes or silently adding stale full attribute snapshots. Exact conflict-resolution operation is an owner implementation dependency.

Release only allocation-owned suspension after completion or supported mod deferral, respecting other pause/readiness gates. Provide gain/allocation/completion feedback after authoritative state changes; UI/audio callbacks cannot grant a second reward.

## Relevant formulas and parameters

- Ordinary level increment: +1 per distinct claim.
- Ordinary pool P ~ uniform integers [4,6].
- HP roll h ~ uniform integers [floor(H/2),H]; G=max(1,h+floor(E/10)−5), captured before allocation.
- Oghma pool P=30; level increment=0; ordinary HP grant=0.
- Allocation a_i≥0; working_i=start_i+a_i≤permanent_cap_i. Remaining R=P−sum(a_i), with 0≤R≤P.
- Confirmation requires R=0, or all working attributes at cap and explicit acceptance of discarding R. Exact actual values and original P are validated, not just UI labels.

Use supported safe numeric ranges and finite valid parameters. No negative pool/health award or arithmetic wrap is permitted. Derived health/attribute effects use the same authoritative owner rules as gameplay.

## Configuration and balancing options

Validated mods may override supported ordinary pool bounds, HP reward formula parameters, artifact point parameters and optional deferral policy. Permanent attribute caps remain CHAR-011 inputs, not duplicate uncoordinated settings. Preserve explicit uniform integer distributions for configured random ranges and one-level ordinary claim unless a future specification changes that contract.

Require ordered supported ranges, nonnegative integer pools and compatible positive HP-growth semantics/minimum, safe numeric domains and known reward/attribute targets. Unsupported formula/effect behavior requires owner approval rather than arbitrary executable definitions. DATA-003 precedence/locking and explicit invalid-data recovery remain binding. No reroll button, reward transfer, automatic capped-point conversion or vanilla later-allocation option is introduced.

## Required data

Stable reward/type/origin/ordinary-level identity; acquisition order and completion state; actual/eligible level context; captured reward parameters and prepared random outcomes; starting/working permanent values, allocated/remaining points; HP gain inputs/result; explicit discarded remainder; artifact-consumption receipt/context and deferral policy. Concrete schemas/receipts and coherent transaction boundaries remain SAVE/owner dependencies.

## Inputs, outputs and events

Inputs: eligible-level changes, validated artifact use, safe claim entry, preparation randomness, allocation/refund, confirmation, optional mod close/resume and restore. Outputs: distinct queued/prepared/completed rewards, previews/errors, atomic level/HP/attribute changes, discarded remainder acknowledgement and CHAR-014 claim result. Conceptual contracts do not prescribe APIs/signals; notifications cannot substitute for committed claim identity.

## Cross-system interactions

CHAR-014 supplies preserved eligibility and consumes claim results; CHAR-011 validates permanent values/modifiers; CHAR-005 career H and vital owners resolve health effects. ITEM/MAGIC own artifact authorization/consumption. UI/COMBAT/CORE coordinate safe entry and suspension. DATA-003 validates mod policy. SAVE persists queue/prepared/committed state without replay; CHAR-013 practice does not directly grant these rewards.

## Edge cases and failure conditions

- Several eligible levels/artifacts cannot collide in shared flags, overwrite rewards or reorder an active claim.
- Save/reopen/refresh cannot reroll pool/HP, duplicate a level or add maximum health twice.
- Current health remains unchanged; an Endurance increase affects future prepared HP gains only, not earlier results.
- All-max and partially capped allocations show exact remainder and require explicit discard acknowledgement.
- Mandatory vanilla allocation cannot escape via alternate close/hotkey path; mod deferral resumes without early benefits.
- Under mod deferral, changed permanent values must not be overwritten by stale allocation snapshots. Invalid conflicts block confirmation until explicitly resolved.
- Missing required definitions or failed item/reward commit cannot consume an artifact without entitlement or report a completed level with missing benefits.
- Repeated callbacks/stale sessions cannot commit another character's reward. Invalid allocations cannot pass via negative/forged pool labels.

## Save/load considerations

Persist pending order/identity, active prepared outcomes, partial allocation, policy and completion/claim state consistently with actual level, health, attributes and artifact inventory. Saving/loading cannot reset rolls or reapply consumed rewards. Vanilla restored active allocation resumes with gameplay gated until confirmed; mod-deferred rewards may resume according to their stored valid policy.

SAVE must define permitted save boundaries or complete coherent pending-state serialization; no snapshot may contain a consumed level/artifact with missing reward or a committed benefit with an unconsumed claim. Invalid/missing saved reward/configuration requires explicit migration/recovery rather than clearing it or generating replacements. Exact schema, crash durability and deferral-conflict persistence remain technical dependencies.

## Technical constraints

Target: Godot 4.7.2. Separate eligibility, entitlement/order, one-time preparation, isolated allocation and validated atomic commit. Keep authoritative state outside UI windows, use stable claim identity and safe arithmetic, and protect asynchronous callbacks by session context. Concrete transaction/serialization/RNG APIs remain engineering decisions. Reference source/content remain read-only.

## Acceptance criteria

1. Ordinary reward uses +1 level, uniform 4–6 pool and captured pre-allocation-Endurance HP formula; current health remains unchanged.
2. Results prepare once when active, remain fixed through reopen/load/retry and do not affect earlier HP gains.
3. Level/HP/attributes/reward completion/claim commit together on valid confirmation, never before.
4. Ordinary and artifact rewards retain acquisition order and separate identity; multiple ordinary levels claim in level order without backlog loss.
5. Oghma grants 30 points with no level/ordinary HP increase; item consumption and durable entitlement succeed together exactly once.
6. Allocation respects permanent baselines/caps and exact pool invariants; capped remainder is explicitly displayed/discarded only on valid confirmation.
7. Safe player-initiated entry avoids combat interruption. Vanilla blocks gameplay return during allocation; validated mod deferral retains state without benefits and prevents overtaking.
8. Restored pending rewards preserve outcomes/allocation/policy; mandatory active allocation gates gameplay, and inconsistent state requires explicit recovery.
9. Supported mod parameters validate without silent fallback; stale callbacks, UI paths and repeated confirmations cannot duplicate benefits.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-005/011/013/014, DATA-003 and CORE lifecycle/restore constraints. No direct contradiction identified. Atomic confirmation intentionally replaces source split commit. CHAR-014 pending eligibility remains separate from actual level until claim. Mandatory vanilla allocation follows the user's correction; optional mod deferral is explicitly approved and disabled by default. Ordinary skill gains do not force combat interruption. Permanent caps and owner-applied modifiers remain separate; full architecture/mod APIs are not approved wholesale.

## Outstanding questions and approval

No further blocking reward-policy question is identified. Before implementation is complete: define supported mod HP/artifact schemas/numeric limits; finalize safe claim-entry conditions, artifact consumption transaction and chronological eligibility claims; establish deferral-conflict reconciliation; verify health/derived-vital operations and RNG distributions; complete coherent SAVE pending/commit/crash-recovery contracts. These dependencies cannot waive retained rolls, atomic confirmation, mandatory vanilla allocation or artifact entitlement preservation.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-015-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented transaction/UI/vital, mod-schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
