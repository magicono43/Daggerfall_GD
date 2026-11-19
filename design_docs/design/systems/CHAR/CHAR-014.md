# CHAR-014 — Level eligibility and progress

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Determine earned level eligibility from permanent skill development, preserve multiple unclaimed levels and expose truthful progress without awarding level rewards itself.

## Intended player experience

See how class skills contribute to leveling, retain all earned eligibility even after a later skill reduction, and know both how many levels await claiming and progress toward the next unearned level. Live skill advancement works without forcing combat-interrupting sheet popups.

## Confirmed requirements

CHAR-014-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish ranked permanent-skill contributions, vanilla formula/initial baseline, explicit pending levels, nonrevocable earned eligibility, reevaluation triggers and shared UI calculation. Contribution rules, offset and points-per-level support validated mod overrides.

CHAR-011 supplies permanent skill state; temporary modifiers do not contribute. CHAR-013 commits skill gains before eligibility reevaluation in either advancement mode. CORE-012 captures initial progression baseline after all starting skill changes. CHAR-015 owns actual level changes/rewards/claiming, not this feature.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/PlayerEntity.cs#SetCurrentLevelUpSkillSum` sums all Primary skills, all Majors minus the lowest, and the highest Minor, using permanent values. A short accumulator is used; intended safe arithmetic does not adopt overflow.
- `Game/Formulas/FormulaHelper.cs#CalculatePlayerLevel` floors (current sum − starting sum +28)/15.
- `PlayerEntity.CheckForLevelUp` sets ReadyToLevelUp when calculated level exceeds actual level; it does not represent an explicit target/backlog or revoke the latched flag on a false result.
- `Game/Utility/StartGameBehaviour.cs#StartNewCharacter` captures current/starting sums after initial skill changes.
- `Game/Serialization/SerializablePlayer.cs` stores sums, recomputes a zero current sum and estimates a missing/nonpositive starting sum. Intended baseline preservation requires explicit migration rather than silent estimation.
- `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#LevelButton_OnMouseClick` calculates a separate float expression and displays its fractional percentage; intended UI shares resolved gameplay rules instead. Level reward handling is CHAR-015 scope.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full runtime mutation/restore routing and mod combinations remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Contribution and initial baseline

Vanilla current sum S equals all three Primary permanent values plus the two highest Major permanent values plus the highest Minor permanent value. Re-rank Major/Minor values as permanent skills change; no fixed slot remains privileged merely because it contributed previously. Equal-value ties do not alter the numeric sum. Other skills do not contribute by default.

Capture initial S0 only after all starting skills, biography effects and other approved initialization changes under CORE-012. Fresh ordinary character actual level is supplied by entry; vanilla formula assumes the ordinary level-1 start. Initial skill values do not award earned levels merely because they are assigned. Once captured, preserve S0; do not reset it at each level claim, temporary effect, save/load or skill reduction.

### Earned target and claims

Compute formula candidate F=floor((S−S0+28)/15). Track an explicit highest earned/eligible target H, initialized consistently with actual starting level A. On valid reevaluation H=max(previous H,A,F). Pending count N=H−A for valid A≤H. Updating eligibility does not itself change A, maximum health, attributes or grant a reward.

Preserve H and actual levels after permanent skill reductions. Pending levels are not revoked. Further gains must exceed the retained H under the formula; regaining lost skills cannot repeatedly award the same thresholds. Repeated evaluation without changed relevant state produces no duplicate pending levels.

CHAR-015 claims rewards against eligible levels with duplicate-safe committed results. Reevaluate pending count after actual-level changes and preserve remaining eligibility. Do not collapse a multi-level backlog into a Boolean or discard it after the first claim. Exact one-at-a-time/batch reward presentation remains CHAR-015 policy.

### Reevaluation triggers

Reevaluate after committed permanent-skill changes, including default or live CHAR-013 gains, and after level claims. Other permanent skill grants contribute by default unless an approved owning specification explicitly excludes them. An exclusion requires its own precise accounting contract; this feature does not invent baseline shifts or hidden subtraction rules.

Temporary live modifiers never change S or eligibility. Initialization establishes the baseline rather than replaying earned development. Restore reconstructs saved identity/state and validates/recomputes derived values without replaying skill-gain events or generating rewards. Stale callbacks or UI refreshes cannot create a second eligibility award.

### Progress display

Use the same resolved contributions, offset and step size for simulation and display. Show actual level A, pending count N and progress toward H+1, the next level not already earned, even when several rewards remain unclaimed.

Do not hide pending levels behind a fractional percentage. If skills have decreased, progress may return to zero while H/N remain preserved. Do not show negative progress or promise level loss. Exact display precision/rounding and explanatory breakdown layout remain UI choices, using shared authoritative threshold data.

Publish eligibility information after consistent skill/target updates. Do not automatically interrupt combat to open the sheet. CHAR-015 owns reward prompts and safe claiming flow; eligibility notifications do not apply rewards.

## Relevant formulas and parameters

Vanilla S=sum(Primary)+sum(top 2 Major)+max(Minor), offset O=28 and points-per-level P=15. General approved formula: F=floor((S−S0+O)/P), P>0.

For target level j, required sum Sreq(j)=S0+P×j−O. At level-1 initialization S=S0, F=1. Level 2 needs S−S0≥2; later thresholds are 15 contributing points apart. Not every individual skill +1 changes S, because lower-ranked Major/Minor values may remain outside the selected subset.

Retained H=max(previous H,A,F); N=H−A. For the next unearned level H+1, progress fraction q=clamp((S−Sreq(H))/P,0,1). This is a display clamp, not a mutation of skills/baseline/earned levels. At the vanilla start q=13/15 (about 86.7%) with 2 sum points still needed. Display can also show required points directly to make the early first level understandable.

Use safe integer sums and mathematically consistent floor, especially when S−S0 is negative. Valid configurations must have finite supported offset, positive supported P and compatible starting-level/contribution rules. Derived candidate below actual level cannot delevel a character. Numeric overflow is a validation failure, not a wrapped target.

## Configuration and balancing options

Allow validated mod contribution rules and offset/step overrides. Supported contribution schemas must define eligible skill/tier IDs, ranking/count/weight behavior where offered, deterministic ties and enough data to derive truthful thresholds/progress. The vanilla all-Primary/top-two-Major/top-Minor rule remains default. This does not authorize arbitrary executable formulas or extra tier slots under CHAR-004.

Validate missing IDs, impossible selection counts, numeric ranges and compatibility with available tiers/permanent skills/starting level. Invalid definitions follow DATA-003 recovery rather than silently reverting to vanilla or omitting required contributors. Configuration changes affecting existing baselines/H require explicit SAVE migration; locked mod definitions cannot hot-reload during play.

## Required data

Stable skill/tier identities, permanent values, resolved contribution/formula configuration and provenance, S0, actual level A, retained earned target H and derived S/N/next threshold/progress. Exact serialized policy identity/version and UI breakdown representation remain technical dependencies.

## Inputs, outputs and events

Inputs: validated initialization, committed skill mutations, claim results, resolved configuration and restoration. Outputs: contribution sum, candidate/retained target, pending count, next threshold/progress or actionable invalid-state result. Notifications reflect committed eligibility; exact API/signal names are deferred. Reading these values cannot claim levels or replay rewards.

## Cross-system interactions

CHAR-003/004 define tiers; CHAR-006/009 and CORE-012 establish starting skills before S0; CHAR-011 supplies permanent state; CHAR-013 reports committed gains. CHAR-015 consumes eligible levels and reports claims. UI renders shared thresholds. DATA-003 and rule owners validate definitions; CORE/SAVE scope and restore state without duplicate events. Economy/combat/other consumers continue using actual claimed level under their own rules, not H unless explicitly specified.

## Edge cases and failure conditions

- Multiple thresholds crossed in one committed batch preserve every eligible level without applying rewards twice.
- Major/Minor rank changes update S correctly; equal-value ties cannot create order-based gains.
- Skill losses reduce S/progress but not A/H/N except when actual claims reduce N. Regaining the same territory does not create duplicate levels.
- Temporary buffs, scene reload, repeated callbacks and UI refresh cannot change earned target without legitimate authoritative state.
- Invalid baseline/configuration and missing contributors cannot be hidden by an estimated starting sum or successful zero result.
- Explicitly excluded future grants need an approved accounting rule before implementation; arbitrary runtime exclusions cannot silently rewrite history.
- Changed mod policies cannot reinterpret saved S0/H without migration. Current-sum caches must be checked/rebuilt from correct permanent values.

## Save/load considerations

Persist S0, H, A and required contribution/formula identity/configuration consistently with permanent skill state. N/S/progress may be derived; saved caches are not independent authority. Loading must preserve earned backlog and baseline without estimating a new one, replaying gains or claiming rewards.

Missing/invalid required baseline, target or definitions requires explicit SAVE migration/recovery/failure policy. Legacy zero values cannot automatically be interpreted as missing when zero is valid under modded domains. A saved inconsistent actual/target relationship or uncommitted claim needs explicit recovery, not silent reward duplication. Exact atomic save boundaries and migration schemas remain SAVE/CHAR-015 scope.

## Technical constraints

Target: Godot 4.7.2. Separate pure contribution/threshold evaluation, authoritative retained target and reward claims. Use stable IDs, safe arithmetic and one shared UI/gameplay calculation. Avoid short accumulators, incidental array order, Boolean-only backlog or UI-driven rewards. Reference source/content remain read-only; concrete APIs, schema and optimizations remain engineering choices.

## Acceptance criteria

1. Vanilla S uses permanent Primary/top-two-Major/top-Minor values with dynamic ranking; temporary modifiers never count.
2. S0 captures all initial skill changes once. Vanilla candidate formula yields level-2 eligibility at +2 sum, then +15 per subsequent threshold.
3. Explicit H/N preserve multi-level backlog and remain duplicate-safe under repeated evaluation.
4. Skill reductions cannot remove earned/actual levels; regaining lost skill values does not re-award prior eligibility.
5. Committed default/live skill changes and actual claims update eligibility; initialization/restoration/UI queries do not replay awards.
6. Shared gameplay/UI rules show A/N and next-unearned progress truthfully, including vanilla early-level behavior, without automatic combat-interrupting sheet opening.
7. Validated mod contribution/offset/step rules remain compatible and deterministic; invalid definitions fail without hidden fallback.
8. Save/load preserves baseline/earned target/actual level/configuration without silent estimation, lost backlog or duplicate rewards.
9. CHAR-015 alone applies level rewards and claims; other systems do not mistake eligible target for actual level without explicit owner rules.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-004/006/009/011/013, relevant DATA-003/008 and CORE-007/012 restore/startup constraints. No direct contradiction identified. Starting skill initialization does not count as earned development; live-mode gains can update eligibility without automatic reward popups. Nondecreasing H explicitly preserves earned eligibility beyond source Boolean behavior. Contribution overrides do not change fixed tier counts or authorize silent baseline migration. CHAR-015 reward timing remains unapproved here.

## Outstanding questions and approval

No further blocking eligibility-policy question is identified. Before implementation is complete: define supported mod contribution schema/numeric ranges; verify original tier/formula fixtures; integrate authoritative skill batches/CHAR-015 claim identities; finalize UI rounding and excluded-grant accounting where proposed; define SAVE migrations and coherent baseline/claim persistence. Dependencies cannot waive retained earned levels, exact initial baseline or shared progress calculation.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-014-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented mod-schema, claim-integration and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
