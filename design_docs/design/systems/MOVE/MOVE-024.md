# MOVE-024 — Pickpocket execution

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Provide deliberate Steal-mode attempts with clear target limits and modest gold rewards, without duplicate practice, rerolled rewards or save-reset exploits. Eligibility, loot, practice and reactions support validated modding.

## Confirmed requirements

MOVE-024-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, including explicitly moddable practice. RULE-010 probabilities, MOVE-018/019 targeting/modes and CHAR/ITEM/LAW ownership remain binding.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths relative to reference `Assets/Scripts/`:

- `Game/PlayerActivate.cs#ActivateMobileNPC`/`ActivateMobileEnemy` gate Steal on reach/attempt flags; enemy eligibility is enemy class, not ordinary creatures.
- `Pickpocket` awards one practice, uses `FormulaHelper.CalculatePickpocketingChance`, then on success uses `Dice100.FailedRoll(33)` and uniform `Random.Range(0,6)+1` for petty gold.
- Failure with null target is treated as townsperson crime/guards; enemy failure can provoke area/attacker hostility. Target requires explicit valid identity instead of null inference.
- `PickpocketDistance` is 128 classic units scaled by 0.025, or 3.2 reference units.

Static inspection only; source unchanged. Durable target identity and operation commitment require explicit target contracts rather than assuming every source flag persists.

## Detailed rules and behaviors

### Eligibility and commitment

Vanilla targets are live mobile townspeople and humanoid enemy-class actors. Ordinary creatures/static service NPCs are excluded unless a supported mod/quest rule authorizes them. Corpses use loot. Eligible enemy classes may already be hostile; success does not pacify or conceal.

Use deliberate Steal release through MOVE-018. Revalidate identity, explicit target model, eligibility, 3.2-unit moddable reach and obstruction before authorization. Missing/null/stale target cannot select townsperson or easier skill-only probability.

One authorized attempt per persistent target regardless outcome. Invalid/out-of-range/blocked-repeat requests consume no attempt, roll or practice. Once authorized, retain spent state and outcomes despite later UI/technical failure. Exact commit/recovery boundaries remain RULE/SAVE work; technical retries cannot restore a free attempt.

### Probability and rewards

RULE-010 selects valid skill-only or enemy-level success model from coherent live inputs. RULE-003 owns randomness/retained technical retries. Do not make another independent failure/detection roll merely to inspect the success complement.

After success, separate gold-find probability is 67%. If found, uniform integer 1–6 gold; otherwise nothing valuable. No victim inventory browsing/item theft initially. Loot amounts/chance and target eligibility are moddable.

Vanilla generates petty gold rather than deducting a simulated purse. Merchant stock/corpse inventory remain inaccessible through this reward. ITEM gold/capacity validation applies. Failed credit retains resolved reward/spent attempt for explicit recovery without reroll or silent loss. Mods may supply victim-owned transfers under explicit ITEM ownership/transaction rules.

### Practice and reactions

Award default +1 raw Pickpocket practice per genuine authorized attempt, including failure/empty success. Amount and eligibility are explicitly moddable. Use attempt identity to prevent duplicate callbacks/retries awarding again; CHAR owns raw accumulation, not direct permanent increases.

Vanilla townsperson failure is detected and routed to LAW with explicit crime/response context. Enemy failure invokes target hostility and a declared response-group policy, not undeclared aggression from unrelated actors. LAW owns guards/witnesses; NPC/COMBAT own group scope. Audible sound/mute cannot change detection.

Success does not grant legal immunity, concealment or pacification. No additional independent success-detection roll is introduced. Successful theft/guild bookkeeping requires LAW/FACT contracts rather than automatically adopting incidental source calls.

### Feedback and persistence

Report gold success, nothing valuable or failure without exact rolls by default. Optional chance/risk uses RULE-010 labels, distinguishing success from detection. Preview cannot authorize attempts, practice or rewards.

Native saves retain persistent target attempt state and any committed unresolved reward/reaction. Reload/re-entry cannot refresh it; a genuinely new actor has its own authoritative identity. Reconstructing an existing actor is not creating a new allowance.

Restore without rerolls/repeated gold/practice/hostility/crime. Missing required model/outcome data invokes compatibility/recovery, not new skill-only attempts. Pause preserves valid retained work and cannot generate new input/attempts.

## Relevant formulas and parameters

RULE-010 baseline raw chance: skill-only S, or supported enemy S+5*(L−T), with its approved final limits. P(gold|success)=67%; quantity uniform [1,6]; default practice=1 per authorized attempt; reach=3.2 reference units. Supported policies are moddable. Validate finite domains, ordered amount bounds and safe credit arithmetic. No new shoplifting/detection formula is selected.

## Required data

Stable target/session identity and explicit model/level; attempted state; captured intent/eligibility; live inputs/provider provenance; retained success/find/amount outcomes; practice/credit/legal completion and feedback policy. Concrete schema/commit markers remain owner work.

## Inputs, outputs and events

Inputs: valid Steal activation, actor/context, rules, owner credit/reaction results and restore. Outputs: spent authorized attempt, retained outcome, once-only practice/gold request, LAW/NPC response and feedback. API names unselected; rejected/preview requests are not attempt events.

## Cross-system interactions

MOVE-018/019/023 targeting/modes/actor routing; RULE-001/003/010 probability/randomness; CHAR practice/skills; ITEM gold/transfers; LAW crime; NPC/COMBAT hostility; FACT guild bookkeeping; CORE/SAVE scope/state and DATA/MOD validated definitions. Shoplifting's detection model is not substituted for pickpocket success.

## Edge cases and failure conditions

Test dead/replaced targets, hostile classes, repeat blocking, scene rebuild, skill changes before authorization and failed reward credit. Null actor cannot downgrade model. Technical retry retains amount, not rerolls. Duplicate handler delivery cannot repeat practice/crime. Real inventory mods cannot launder ownership or bypass capacity through generated-gold fallback.

## Configuration and balancing options

Validated target/attempt policy, reach, RULE-010 success parameters, loot chance/amount, practice and response-group rules are moddable. Vanilla remains one attempt/generated petty gold/supported targets/detected failure. Added item theft/purse simulation requires its own owner schemas and UI, not implicit inventory access.

## Save/load considerations

Persist spent target and sufficient outcome/completion state to recover without duplicate or discarded rewards. Required transaction/save boundaries must distinguish credited from pending gold. Raw actor/UI pointers are not durable authority. ITEM/LAW/SAVE define interruption recovery; no universal rollback is promised.

## Technical constraints

Target: Godot 4.7.2. Separate eligibility, authorization, random resolution, reward, practice, reactions and presentation. Stable scoped identity/checked owner consequences are required. Concrete APIs, RNG subdivision and schema need fixtures. No implementation/coding tasks authorized.

## Acceptance criteria

1. Supported live actors in reach/line authorize once; rejected/blocked requests spend nothing.
2. Spent target state survives load/re-entry; recreated actor is not a fresh allowance.
3. Correct RULE-010 model resolves once, then separate 67% find and uniform 1–6 reward without inventory browsing.
4. Failed credit retains reward/spent state without reroll/duplication.
5. Default +1 practice occurs once per genuine attempt, including failure/empty success; practice policy is moddable.
6. Explicit LAW/NPC reactions have valid target/group context without null inference or undeclared unrelated hostility.
7. Hostile-target success grants no concealment/pacification and presentation settings do not affect detection.
8. Restore preserves outcomes without replayed gold/practice/reactions and rejects missing required data explicitly.

These are future verification criteria; no implementation/runtime tests performed.

## Consistency review

Reviewed against RULE-010, MOVE-018/019/023 and CHAR/ITEM/LAW ownership. No direct contradiction identified. Success and loot are separate approved checks. Explicit target eligibility prevents null-model fallback. Retained committed outcomes prevent free retries and duplicate rewards. Practice remains explicitly moddable; detection/hostility are selected owner-routed policies, not universal probability semantics.

## Outstanding questions and approval

No further blocking player-policy choice identified. Dependencies: target lifetime, attempt/reward/practice/legal commit boundaries, group response/guild bookkeeping, gold admission, mod schemas/RNG purposes and native interruption fixtures. These do not waive once-only outcomes or retained reward recovery.

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under MOVE-024-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented identity, transaction, reaction, persistence and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
