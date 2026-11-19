# CHAR-017 — Character initialization and progression restoration

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Establish a coherent fresh character or restore authoritative native character/progression state without cross-session leakage, duplicated grants, silent defaults or reconstruction-triggered gameplay consequences.

## Intended player experience

A new character starts with the approved completed build and full initial vital pools. Loading returns the saved character, obligations and progress exactly under explicit compatibility rules, without rerolls, surprise reward duplication or erased cooldowns. Gameplay remains gated until the character is genuinely ready.

## Confirmed requirements

CHAR-017-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish separate fresh/restore routes, level-1 initial health/full vitals, authoritative versus derived state, clean isolated ownership, side-effect-free reconstruction and explicit fresh/restored timer semantics.

CORE-005/007/010/011/012/013 govern scope, preflight, clean baseline, placement, grants and native restoration. DFU/classic-save compatibility is outside current scope under CORE-013; catalog reference to CORE-014 does not authorize import work. Approved CHAR-001–016 owner rules remain binding, including source-owned modifiers, retained random outcomes and pending progression/activity obligations.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/PlayerEntity.cs#AssignCharacter` transfers identity, career, working attributes/skills, reputation, practice/progression fields and backstory. Several values are assigned by reference, including draft collections. Null input supplies entity defaults. Intended required-data failure and isolated ownership explicitly differ.
- AssignCharacter can use supplied health or call `Game/Formulas/FormulaHelper.cs#RollMaxHealth`, optionally fills vitals and always sets last advancement check to now. RollMaxHealth uses base 25 + class HP per level, then additional level-health rolls for levels above one. This feature retains the ordinary level-1 baseline, not automatic replay for modded higher starts.
- `PlayerEntity.Reset` clears equipment/items/spells/faction/global/notebook state, progression sums/counters/timers, rooms/crime and world variants. Exact complete ownership/teardown is broader CORE/domain scope; this method alone is not proof every prior-session reference is cleared.
- `Game/Serialization/SerializablePlayer.cs` restores identity, skills/stats, vitals with some restore-mode setters, counters/timestamps, inventory/equipment and other character state. It recomputes zero current skill sums, estimates nonpositive starting baselines and zero-fills null skill-use arrays. Intended required validation/migration replaces blanket silent fallbacks.
- `Game/Utility/StartGameBehaviour.cs#StartNewCharacter` applies biography and grants before capturing progression baseline. Native restoration is a separate route, with legacy lifecycle wiring discussed in CORE-013.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Full source restore sequencing, source definitions and runtime readiness remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Shared preparation and isolation

Use explicit fresh-character and native-restore entry intents with validated required inputs. Never infer a fresh start from missing/invalid save fields or manufacture a default character to report success. CORE-007 preflight preserves the existing session until replacement is authorized/prepared; failures after replacement use approved cleanup/recovery rather than promise full rollback.

Build on CORE-010's clean session baseline. Transfer owned character values into isolated runtime state rather than share mutable draft arrays/career objects that UI can later change. Shared immutable definitions may remain shared; per-character state must not mutate reusable definitions or another character.

Ensure prior-character inventory/equipment, effects, skills/practice, timers, pending rewards, activities and callbacks cannot survive into the replacement. Domain owners reset their own state under CORE scope rules. Stale asynchronous results cannot apply to another session. Reset is baseline construction, not a completed new game or restored-session notification.

### Fresh-character initialization

Consume the captured validated creation result, preserving race/gender, name/portrait, class/custom data, permanent attributes/skills, reflexes, biography/template/answers/outcomes and approved progression mode/policies. Do not reroll retained creation/biography choices during assignment or safe retry.

Ordinary actual starting level is 1. Initial base maximum health is 25 + class HP-per-level parameter. No additional level-health loop is required for that ordinary start. Permit validated supported overrides of starting parameters; a higher modded level or different formula requires an explicit compatible starting-state contract rather than silently invoking level rewards or generating a backlog.

Apply initialization through CORE-012 and effect/resource owners exactly once: biography precedes starting grants; all initial skill changes precede capture of CHAR-014 S0. Initialize raw practice to zero as fresh state, not earned use. Establish actual/earned target consistently so initialization does not accidentally award levels. New characters have no inherited prepared reward or training obligation; genuinely defined custom startup content requires its own owner contract.

Once required initialization and derived-limit reconstruction finish, health, fatigue and magicka begin full at their valid owner-defined limits. CHAR-018 defines pool semantics; no filling of unrelated pools or healing during later native loads is implied. Required conditions that make a modded start invalid must be resolved explicitly, not bypassed by a fill operation.

Set the last advancement-check timestamp to the initialized starting game clock. Represent paid training as never trained, permitting the first purchase immediately under CHAR-016. Do not use a zero timestamp as an ambiguous substitute for that state. Synchronize activity/time baselines so startup does not create phantom elapsed practice or drain.

### Native restoration

Restore authoritative assigned identity and history, permanent values, actual level, retained eligible target/S0, raw counters, timestamps, fixed reflex/mode/policy context, pending rewards/rolls/allocations and supported training/activity receipts. Include required equipment/effect sources and their saved ownership/lifecycle state through domain owners.

Preserve saved current vitals and authoritative maximum-health state through CHAR-018/SAVE contracts; do not fill, reroll or derive accumulated health by replaying past levels. Preserve saved timestamps rather than resetting to now. Loading does not rerun biography effects, starting equipment/spells, opening quests or initial rolls.

Validate required identities, numeric bounds, source links, chronological/activity consistency and supported versions. Rebuild only explicitly derived data: current contribution sums, live modifiers/caps, equipment-derived values and presentation. Rebuilding a cache cannot overwrite authoritative S0, retained earned target, assigned name/history or resolved reward outcome.

Missing/invalid required data needs supported explicit migration/recovery or failure. Do not estimate a baseline, silently zero a counter, substitute Average reflexes or drop pending rewards. Zero may be a legitimate value; schema/version presence must distinguish missing from zero. CHAR-007's explicit compatible missing-portrait recovery remains its approved exception, not a generic fallback license.

### Reconstruction side effects and readiness

Assignments/relinking must not trigger new damage, death/collapse presentation, practice, mastery/level rewards, transactions or purchase effects merely because setters run. Restore authoritative consequences rather than replaying the events that originally caused them.

After consistent reconstruction, resume genuine saved conditions and obligations through their owners: pending vanilla allocation still gates gameplay; mod-deferred rewards/training resume according to stored policy; ongoing effects keep valid lifecycle context. Do not suppress a real required outcome forever or erase a saved obligation in the name of quiescent restoration. Exact dead/zero-vital or interrupted-activity eligibility follows its owner/SAVE policy, not an invented revival rule.

Keep gameplay/time-dependent consumers gated through required data/reference linking, modifier reconstruction and supported UI restoration. Publish readiness/restoration once through CORE only after truthful completion. A copied character document or finished serializer call is not playable success. Release only entry-owned suspension; active reward/other modal gates can remain.

## Relevant formulas and parameters

- Ordinary fresh actual level A=1.
- Ordinary initial base maximum health Hmax=25+career HP-per-level, requiring a valid positive supported result.
- Fresh current health/fatigue/magicka equal their valid initialized owner-defined maxima.
- Fresh last skill-check time=initialized starting game time; fresh training state=never trained; raw counters=0.

All other progression and modifier formulas remain their approved CHAR-008–016 contracts. This feature approves no new estimate of missing baseline, retroactive health reconstruction or elapsed-time catch-up algorithm. Starting mod overrides must satisfy permanent domains, pools, progression and content readiness together.

## Required data

Entry intent and session identity; complete captured character inputs or versioned native snapshot; stable definition/choice/source IDs; authoritative identity/history/permanent/vital/progression state; policy/configuration provenance; pending reward/training receipts; and domain validation/readiness results. Derived caches require declared reconstruction rules. Concrete schema/version and ownership representation remain SAVE/DATA/domain dependencies.

## Inputs, outputs and events

Inputs: fresh captured intent or prepared native snapshot, validated definitions, initialized clock, clean baseline and owner reconstruction results. Outputs: coherent isolated character state, explicit initialization/restore failure or owner readiness milestone. CORE owns terminal entry/restoration notifications. Conceptual contracts do not prescribe API names; field assignment is not reward/practice/damage notification.

## Cross-system interactions

CORE-007 coordinates admission/preflight/capture, CORE-010 clean baseline, CORE-011 placement/time, CORE-012 fresh grants and CORE-013 native entry. CHAR-001–010 provide creation state; CHAR-011 reconstructs live sources; CHAR-012–016 preserve progression/reward/training obligations. CHAR-018 and later condition owners define vitals/transformation/death semantics. ITEM/MAGIC/FACT/QUEST restore their owned state; TIME aligns clocks; DATA/MOD validate compatible definitions; UI rebuilds presentation from state; SAVE validates/migrates snapshots.

## Edge cases and failure conditions

- Null/partial character input cannot silently create a default test character.
- Mutable draft references or cached old-session callbacks cannot change an assigned replacement character.
- Fresh start and load must not share flags that rerun grants or fill saved vitals.
- Missing counter/baseline differs from valid zero; silent source estimates are not migrations.
- Pending levels/artifacts/training cannot vanish during reset or double-apply during resume.
- Restoring a temporary cap/source cannot permanently rewrite underlying stats or duplicate its modifiers.
- Saved time/check/cooldown conflicts require explicit policy; setting all timestamps to now is not recovery.
- Required reconstruction failure prevents readiness; notifications cannot unpause unsafe or incomplete state.

## Configuration and balancing options

Vanilla starting level/health baseline/full vitals remain defaults. Allow validated supported starting overrides under owner contracts and locked DATA-003 configuration. No higher-level reward replay, new import format, default-character recovery or automatic save repair is introduced. Existing characters retain authoritative saved configuration according to approved SAVE compatibility policies.

## Save/load considerations

Persist authoritative identity/permanent/vital state and all progression obligations named above. Derived live modifiers/sums/UI are rebuilt without generating fresh random values or effects. Explicit native versions/migrations must be validated before destructive replacement where possible under CORE-013. Preserve source/definition dependencies and consistent pending-operation boundaries; load cannot partly consume a reward or time activity.

SAVE defines exact serialization, atomic boundaries and optional cache handling. Invalid required baseline, counters, timestamps, mode, reward/source references or unsupported activity state produce explicit migration/recovery/failure, not a playable guessed character. DFU/classic compatibility remains outside scope.

## Technical constraints

Target: Godot 4.7.2. Keep initialization, restoration, baseline reset and gameplay mutation distinct. Use stable IDs, owned mutable state, explicit restore-safe operations, quiescent rebuild and session-scoped callbacks. Validate derived readiness before dependent systems run. APIs, restore pipeline phases and schemas remain engineering decisions; broader architecture proposals are not approved wholesale. Reference source/content remain read-only.

## Acceptance criteria

1. Fresh and native routes cannot trigger each other's grants, rolls or pool-filling behavior.
2. Ordinary fresh characters start at level 1, base max health 25+class HP and full valid health/fatigue/magicka after required initialization.
3. Baseline captures all initial skills once; fresh practice is zero, skill-check time matches starting clock and first paid training is immediately eligible.
4. New/restored state is isolated from mutable drafts/previous characters; stale callbacks and old obligations cannot leak.
5. Native load preserves authoritative identity/history/vitals/progression/policies/pending rewards/activities/timestamps exactly under supported compatibility rules.
6. Derived modifiers/sums/UI rebuild from validated sources without permanent reward replay or random draws.
7. Missing/invalid required state uses explicit migration/failure rather than defaults, zeroing or baseline estimates.
8. Reconstruction assignments cause no new damage/death/practice/transactions; genuine saved obligations resume through owners without being erased.
9. Gameplay remains gated until required state/linking/UI/readiness succeeds; completion emits once and respects other suspension owners.
10. Supported starting overrides validate across domains; DFU/classic import remains outside scope and reference source unchanged.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001–016, CORE-005/007/010/011/012/013 and relevant DATA-003/008 rules. No direct contradiction identified. Explicit never-trained state implements CHAR-016 immediate first purchase without weakening restore cooldowns. Initial full vitals do not imply load healing. Preserved authoritative baselines/rolls/obligations supersede source fallback heuristics. Restore quiescence does not erase mandatory allocation or genuine saved conditions. Existing import references are scope notes only.

## Outstanding questions and approval

No further blocking initialization/restore policy question is identified. Before implementation is complete: define versioned authoritative schema/ownership and derived-cache list; finalize CHAR-018 pool/condition semantics and supported starting override contracts; integrate required source/activity/UI reconstruction; verify clock units and new-session baselines; establish coherent SAVE migrations/readiness/failure traces. These dependencies cannot waive separate routes, retained state, no silent defaults or gated restoration.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-017-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented schema/clock/vital, owner/UI and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
