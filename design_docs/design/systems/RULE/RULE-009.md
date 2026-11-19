# RULE-009 — Lockpicking

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Calculate door-specific ordinary lockpicking probabilities with moddable formulas and limits, while separating chance from action eligibility and consequences.

## Intended player experience

Live Lockpicking and the selected door model determine the chance of an authorized attempt. Players normally see a qualitative difficulty description and may enable an exact percentage. Mods can rebalance either model or its limits. A blocked door cannot become pickable merely because a formula has a minimum chance.

## Confirmed requirements

RULE-009-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm separate moddable formulas, moddable vanilla 5–95 limits, actual claimed level/live skill inputs, one authorized RULE-001 check, parameter and replacement-hook customization, independent 0–100 limits and qualitative/default plus optional exact feedback.

Retry eligibility, skill-practice awards, unlocking/opening, costs and legal consequences are not approved by this formula review. MOVE/LOC/MAGIC/LAW retain those decisions.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateInteriorLockpickingChance` returns clamp(skill+5×(level−lock value),5,95). `CalculateExteriorLockpickingChance` returns clamp(skill−5×lock value,5,95). Both expose replacement hooks.
- `Internal/DaggerfallActionDoor.cs#AttemptLockpicking` rejects moving doors and repeat attempts at its recorded failed live skill value, blocks ordinary picking of magically held doors, tallies +1 Lockpicking and calls the interior formula with player Level/current lock/live skill. It uses Dice100.FailedRoll; success clears the lock and opens the door. These are observed interaction rules, not automatically adopted target requirements.
- `Game/PlayerActivate.cs#LookAtLock` uses the interior formula for qualitative feedback in the inspected path and comments on differences from classic descriptions and incomplete exterior handling. The existence of an exterior helper does not prove all exterior interactions use it.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full door routing, failed-attempt persistence, legal effects and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Door models and inputs

Retain distinct interior animated-door and exterior entrance models. The interaction owner explicitly identifies the model and supplies a valid lock-difficulty value. Do not infer a universal normalized difficulty scale from the fact that both source parameters are named lock value; content adapters/owners must verify their meanings and supported domains.

Use resolved live Lockpicking S and actual claimed player level L, not permanent skill or highest earned/unclaimed target. Temporary skill bonuses/penalties apply within CHAR-011's supported domains. Vanilla interior raw chance C=S+5×(L−D); vanilla exterior C=S−5×D, where D is the appropriate model's lock value. Thus vanilla exterior chances do not depend on level.

No extra hidden skill clamp is introduced before calculation. Negative/above-100 live skills can reach the formula if valid under CHAR-011; chance limits then bound the result. Invalid identities or lock data are explicit errors, not zero-difficulty defaults.

### Moddable formulas and limits

For each model, support validated data parameters in the form C=wS×S+wL×L+wD×D+b. Vanilla interior coefficients are (1,5,−5,0); exterior coefficients are (1,0,−5,0). Each model has its own coefficients/offset and minimum a/maximum z, vanilla a=5 and z=95.

Require 0<=a<=z<=100 for the final integer-percent bounds. Equal bounds are valid and give a constant chance. Mods may use 0 or 100 to permit guarantees. Formula results are limited to the configured model bounds before the RULE-001 check. This is a feature-specific chance policy, not a change to RULE-001's general 0–100 semantics.

Also expose explicit supported replacement hooks under RULE-004 for alternative models. Contracts must distinguish raw formula replacement from complete chance replacement and define output validation/limit application before implementation; neither callback arrival nor UI code can decide this implicitly. Eligibility gates remain outside ordinary formula replacement. No hook automatically authorizes picking magical/unpickable doors.

Concrete supported coefficient types/ranges and any conversion of fractional raw values must be documented before use. RULE-001 requires an integer percentage and approves no implicit fractional rounding. Do not claim fractional coefficient support without an explicit consistent rounding contract. Validate finite safe arithmetic, supported inputs/outputs and compatibility at preflight; no general executable data-expression interpreter is introduced.

DATA-003 controls provenance/locked configuration/invalid-definition recovery. RULE-004 controls explicit hook validation, winner selection and runtime failure without silent fallback. Returning an unsupported value cannot silently publish an invented chance.

### Eligibility and resolution

The owner validates current session, target/door state and attempt eligibility before authorizing a genuine attempt. An unpickable/magically blocked door is an explicit restriction, not an eligible 5% or modded 0% attempt. This review does not choose retry policy, skill-change bypasses, tools, animation duration, action costs, quest exceptions or magical unlocking rules.

For each authorized attempt, resolve current inputs/configuration once and perform one RULE-001 check using an explicitly owned source under RULE-003. Success is the shared percentile result, including exact configured guarantees. Even a permitted 0%/100% attempt consumes one logical draw under RULE-001; blocked inspection/attempt rejection does not.

Reuse the resolved result for technical retries/diagnostics rather than rolling independently for success/failure. Owners apply practice, lock mutations, opening, sound and crime consequences under their own exactly-once contracts. This specification does not approve DFU's observed +1 practice or failed-skill retry gate merely by documenting them.

### Presentation

Default feedback is qualitative difficulty derived from the same resolved final chance used by gameplay. Offer an optional exact integer-percentage display. Qualitative category thresholds/labels, setting location/default persistence and concrete UI layout remain UI/owner dependencies; do not silently copy a classic or unrelated formula for display.

Show explicit restrictions instead of implying an attempt is available at a percentage. Inspection does not draw, award practice, unlock doors or mutate retry eligibility. A displayed chance is a current estimate: if level, live skill, lock state or configuration context validly changes before authorization, recompute before the attempt rather than guaranteeing the stale preview. Explanations/diagnostics retain model, inputs, raw/final chance, limits and selected formula provider where relevant.

## Relevant formulas and parameters

- Interior C=S+5×(L−D); exterior C=S−5×D.
- Configurable per-model linear baseline C=wS×S+wL×L+wD×D+b.
- Final integer chance P=clamp(C,a,z), following the declared numeric conversion contract; vanilla formulas are integer arithmetic.
- Vanilla a=5, z=95; validated mod limits satisfy 0<=a<=z<=100.
- RULE-001 draw R in 1–100 succeeds when R<=P.

Example: S=40,L=5,D=3 gives interior 50% and exterior 25%. With identical S/D, changing L only affects the vanilla interior model. S=0,L=1,D=10 yields the vanilla minimum 5%, provided the owner authorizes the ordinary lock attempt; a blocked door has no such minimum-chance entitlement.

## Required data

Stable door/lock identity and explicit model; current valid lock state/difficulty; live skill/actual level; validated per-model coefficients/limits and provider provenance; eligibility/restriction context; owned random source for authorized resolution; and owner-managed attempt/result/application identity. Exact schemas, difficulty adapters and save state remain owner dependencies.

## Inputs, outputs and events

Inputs: validated model/input/configuration queries and owner-authorized attempts. Outputs: raw/final chance and preview explanation, explicit restriction/validation failure, or one resolved attempt result. This helper does not independently award practice, open a door, trigger guards or persist failed attempts. API/event names are unselected.

## Cross-system interactions

MOVE-020/021 and LOC-017 own routing/eligibility/door mutation and retries; MAGIC owns magical holds/unlocking; LAW owns legal consequences; CHAR-011 supplies live skill and actual-level state; CHAR-012 owns accepted practice tracking. RULE-001 supplies probability semantics, RULE-003 source ownership/retries and RULE-004 hooks. DATA-003 validates configuration; UI/DEV share calculated chance; SAVE/CORE preserve valid target/session state and readiness.

## Edge cases and failure conditions

- Clamp extreme but supported computed values safely; reject overflow rather than wrap it into an easy lock.
- Invalid/reversed/out-of-0–100 limits fail preflight; equal bounds and endpoint guarantees are valid.
- Changed live skill can affect chance but does not itself approve another attempt after failure. That eligibility decision remains owner scope.
- Lock already opened, moving, stale or magically blocked requires owner handling before any new roll; no minimum chance overrides it.
- Missing difficulty/model/source or failed hook invokes explicit recovery rather than an assumed unlocked/easy door or silent vanilla fallback.
- Display and gameplay cannot disagree because they use different models/override providers. Preview refresh cannot consume attempts or practice.
- Successful loading permits fresh future unresolved rolls under RULE-003 but cannot relock opened doors or erase owner-required saved retry restrictions by implication.

## Configuration and balancing options

Both models support independent weights/offsets, chance limits and explicit supported replacement hooks. Defaults preserve the differing level relationship and 5–95 uncertainty. Mods may choose different relationships or guarantees within validated contracts. No new lock minigame, global retry rule, tool consumption, anti-save-scumming rule or universal legal consequence is introduced.

## Save/load considerations

Chance is derived from restored valid character/door/configuration inputs, not saved as a permanent bonus. Door lock state, failed-attempt eligibility and any retained in-flight result belong to MOVE/LOC/SAVE; their precise lifetime/persistence is not chosen here. Do not replay unlock/practice/crime consequences on restore. Preserve locked provider configuration and use explicit compatibility/migration if required definitions change. RULE-003 fresh sources do not waive saved-state eligibility or retained-result contracts.

## Technical constraints

Target: Godot 4.7.2. Separate pure chance calculation, eligibility, one-roll resolution and consequence application. Use safe explicit arithmetic and integer probability output; keep UI on the same resolved calculation. Concrete domains, interfaces, adapter mapping and setting serialization remain engineering/owner dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Vanilla eligible chances match both formulas and 5–95 limits; interior uses actual claimed level/live skill while exterior's default level weight is zero.
2. Independent valid per-model parameters/limits alter only the declared rules; 0/100/equal bounds work and malformed/overflowing definitions fail explicitly.
3. Explicit formula hooks follow RULE-004 and a documented output/limit contract without bypassing eligibility.
4. Authorized attempts use one RULE-001 result, including guarantees; blocked/query paths consume no draw or practice.
5. Default qualitative and optional exact feedback share the resolved gameplay chance; blocked doors explain restrictions and stale previews recompute appropriately.
6. Technical retries reuse outcomes; consequence owners cannot duplicate unlock/practice/crime from diagnostic or UI callbacks.
7. Restore derives chance without replaying consequences, resetting owner-required retry state or changing locked provider selection.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this design interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-011/012, RULE-001/003/004 and DATA-003. Feature-specific modded limits coexist with RULE-001's general percentage semantics, and ordinary checks use live skill. Attempt eligibility remains separate, so source retry/magic/crime behavior is not implicitly approved. Fresh loading changes future random sources while respecting saved facts and retained outcomes. MOVE/LOC/LAW/MAGIC interaction reviews remain open.

## Outstanding questions and approval

No blocking gameplay policy question remains for chance computation. Before implementation: define numeric coefficient/conversion domains, supported hook output/limit contracts, difficulty/model adapters, interaction-source purpose, qualitative mappings/UI settings and owner attempt/save integration. Retry restrictions, practice amounts, tools, costs and legal consequences need their own reviews. These cannot waive both-model moddability, independently moddable 0–100 bounds, shared feedback or eligibility-before-roll.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-009-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and interaction-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
