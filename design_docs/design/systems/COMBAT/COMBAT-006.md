# COMBAT-006 — Environmental strikes and door bashing

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Make deliberate melee strikes affect eligible doors and authored mechanisms, with appropriate solid-surface feedback. Keep bashing distinct from entry and lockpicking, preserve committed outcomes and prevent incidental door/mechanism activation during enemy combat.

## Confirmed requirements

COMBAT-006-D01–D15 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record five interviews. The complete specification is approved under COMBAT-006-A01. Approved COMBAT-001–005 and MOVE-020/021 contracts remain binding; no implementation or coding tasks are authorized.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity remains unverified. Source unchanged. Paths below are relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#WeaponEnvDamage` calls an attached DaggerfallAction with Attack, then attempts action-door bash, exterior-door bash or static-geometry sound. An attached action and door can both be reached through this source ordering; target composition must be explicit.
- `Internal/DaggerfallActionDoor.cs#AttemptBash` plays eligible sound, bash-closes an open door, and otherwise rolls 20−CurrentLockValue when not magically held. Success clears the lock and toggles opening. Player bashing in dungeon castles can call MakeEnemiesHostile.
- `Game/PlayerActivate.cs#AttemptExteriorDoorBash` routes through ActivateStaticDoor. That path checks 25−buildingLockValue for a locked building entrance, contains conditional 10% detection/guard branches and can transition through building/dungeon entrances. Dungeon exits return without bash transition. These source placements do not approve unconditional crime, guard spawning or automatic entry.
- `Internal/DaggerfallAction.cs#Receive` checks authored trigger flags including Attack and linked action dispatch. Authoritative supported trigger/link/busy behavior remains LOC/MOVE-owned.

## Detailed rules and behaviors

### Deliberate target and one operation

Use COMBAT-005's enemy-first purpose and nearest relevant central-aim contact within reach. If a reachable combat enemy selected enemy handling, no environmental fallback occurs even after miss, zero damage, skipped targets or interruption. Edge-of-cleave door/mechanism proximity is not a deliberate strike.

An environmental door strike submits one explicit bash operation. Attached authored actions run only through declared links/composition, not independent all-component execution. One propagated strike/trigger identity prevents duplicate bash, toggles or linked actions. Intentional linked effects remain supported under MOVE-021; failure after partial mutation uses explicit recovery, not another handler or blind replay.

### Door state and admission

Read current door lock, magical-hold, motion and bashability state at commitment. Current target identity/reach/obstruction must remain valid under COMBAT-005. Committed swing fatigue remains payable independently of whether the door accepts an operation; input rejection before attack commitment is not a committed bash.

For a deliberately targeted stationary open door, request closing without a bash-success roll. During door motion, ignore the door operation without queuing a later toggle. Respect MOVE-021 effective collision/occupancy: never restore solid collision around an occupant or add unapproved crush behavior.

For a stationary closed, unlocked ordinary door, request opening without a success roll. For a magically held closed door, ordinary bashing cannot open it; consume no success roll. A committed strike may still produce appropriate bash feedback/noise. MAGIC owns magical-hold sources and eligibility changes; mods may define supported bypass policies.

Dungeon exits and other transition-only entrances without an explicit bashable-door definition ignore bash effects. A strike cannot automatically enter/exit or invoke a wagon/transition prompt. Applicable surface feedback and committed swing fatigue remain. Bashability is moddable, but ordinary activation remains the entry/exit path.

### Locked-door success checks

For an admitted stationary locked ordinary door not magically held, use initial raw chances:

- Interior action door: C=20−L.
- Exterior building entrance: C=25−L.

L is current validated lock value from the door/building owner. Apply RULE-001 effective chance P=clamp(C,0,100), draw uniform integer 1–100 once, and succeed when draw≤P. Even admitted P=0/100 checks consume their one logical percentile draw under RULE-001. No success roll is consumed for unlocked, moving, magically held or non-bashable states because they are not probabilistic attempts.

Formulas/source eligibility are moddable. No baseline Strength, weapon damage, material or handedness bonus is added. Unarmed attacks, including COMBAT-002 shield-hand unarmed attacks, use the same baseline chance as weapons. An explicit modded shield-bash source may define a different validated policy.

Each genuine new committed eligible bash may resolve a fresh check; no lockpicking-style skill-improvement retry gate or extra bash cooldown is introduced. Failed attempts do not cumulatively weaken the lock. Duplicate delivery of one strike reuses its resolved result; repeated animation, UI or sound callbacks cannot roll again. RULE-003 governs owned gameplay randomness and fresh unresolved attempts after successful loads.

### Successful unlocking, opening and entry

Successful bash clears the ordinary lock persistently until an explicit relock action/effect changes it. Interior doors request opening under MOVE-021; failed motion/presentation cannot repeat the bash or restore the old lock implicitly. Distinguish cleared lock, requested motion and actual opening results for authored/legal notifications.

Successful exterior bash unlocks the entrance and leaves the player outside. A separate deliberate activation must revalidate access/destination/readiness and enter under MOVE-020/026. Do not automatically transition, run entry greetings or announce entry as a bash consequence. Later entry failure does not erase the completed unlock/attempt incident. Scheduled/explicit relocking remains door-owner policy, not an automatic reapplication during refresh/load.

### Costs, practice and surface feedback

Each committed swing uses COMBAT-004's captured once-per-attack fatigue drain, vanilla 11 internal units, even if the bash fails or the target is moving/magically held/non-bashable. No default structural damage, weapon wear or skill practice is added for door/surface strikes. COMBAT-004 enemy-practice rules do not apply merely because a door is a legal incident target.

Deliberate solid-scenery strikes provide appropriate material/weapon/unarmed impact feedback. Default surface contact does not cancel the swing; optional COMBAT-005 modded wall-stop behavior retains its approved pre/postcommit consequences. Mods may add explicit durability, wear, practice, costs and material responses; this feature invents no vanilla door-health pool, damage accumulation or bash skill.

Ordinary bash success/failure uses motion and appropriate impact feedback without a new per-bash popup or numerical-chance display. Required invalid-data/recovery failures still need clear explanations. Ordinary feedback is moddable. Missing/disabled audio or optional feedback failure cannot replay gameplay, change success or suppress authoritative detection data.

### Noise, legal incidents and authored mechanisms

Genuine door bashes report authoritative noise and applicable attempted/successful forced-opening incidents to NPC/LAW with stable strike/door/session identity and truthful operation outcome. Not every open-door closure or authorized action is automatically a crime; LAW owns applicability, detection, classification and response. Combat neither directly spawns guards nor universally makes enemies hostile. No source 10% detection chance or castle-wide hostility rule is adopted here. Exact noise strength/range, incident stages and authorized-property rules remain NPC/LAW contracts, independent of sound-volume settings/assets.

An attack-triggered mechanism accepts deliberate central strike only if its authored contract permits Attack. Respect one-shot, repeatable and busy/retrigger policy under MOVE-021. Unsupported/busy activation is not queued. Propagate one authorized trigger identity through linked actions, preserving intentional scheduled/repeated effects while deduplicating accidental delivery. LOC/DATA must declare link order and supported effect types; no all-components execution or unbounded linked cycle is authorized.

## Relevant formulas and parameters

Interior/exterior raw success baselines are 20−L and 25−L, followed by RULE-001 clamp/roll semantics. Door owner supplies validated L; no lock domain or exterior quality formula is newly invented. Example: L=10 gives 10% interior and 15% exterior. A valid formula result below zero yields 0%, distinct from a malformed lock definition or arithmetic overflow requiring explicit error.

Fatigue is COMBAT-004's captured vanilla 11 internal units, not multiplied by linked actions. Baseline environmental wear, structural damage and practice are zero. No new bash cadence, sound-detection radius, cumulative weakening, per-bash chance display or direct legal-response percentage is selected. Modded formula outputs/amounts must obey explicit numeric and owner validation contracts.

## Required data

Strike/session/source identity and commitment state; deliberate contact/door identity; current lock/magical-hold/motion/bashability; interior/exterior classification; formula/provider context and retained result; persistent unlock outcome; opening/closing request/completion; authored trigger/link/busy state; noise/incident identity and applicable result; configured feedback and partial-operation recovery status. Durable identities cannot be raw hit-transform references or component enumeration order.

## Inputs, outputs and events

Inputs: committed central environmental strike, current target state, explicit bash/formula policies, authored trigger acceptance, door motion and persistence outcomes. Outputs: ignored/not-bashable/magically-held result, one success check where admitted, retained failure or persistent unlock, checked open/close request, one authored trigger chain, noise/legal reports and optional impact feedback. Exact APIs/event names remain unselected. Actual attempt, successful unlocking/opening and later entry are distinct facts, not one “entered” notification.

## Cross-system interactions

Confirmed enemy-specific integration: COMBAT-016-D03/D07–D12 require capability-driven explicit door intent and COMBAT-015 cadence; an enemy's intended door opening/moving before commitment skips bash rather than closing it or substituting an actor. Closed-door shared lock rules apply without player crime/fatigue/practice behavior. See [COMBAT-016](COMBAT-016.md) for separate approval status and NPC/door dependencies; player deliberate open-door bash-close remains unchanged.

COMBAT-001 interruption, COMBAT-002 selected source/unarmed shield hand, COMBAT-003 input, COMBAT-004 fatigue/commitment/practice and COMBAT-005 enemy priority/reach/contact/wall stop. MOVE-020 exterior access/entry, MOVE-021 door motion/occupancy/links and MOVE-026 transition; MAGIC holds; RULE-001/003/004 chance/randomness/validated overrides; ITEM modded wear/costs; LOC/DATA authored mechanism definitions; NPC/LAW noise/detection/legal consequences; AV feedback; CORE/SAVE lifecycle, persistent locks and recovery. No ordinary activation or spell is implicitly dispatched from a strike.

## Edge cases and failure conditions

Verify enemy in doorway, enemy behind closed door, open/moving/occupied-closing doors, magic-hold changes during wind-up, expired target, repeated legitimate attempts, duplicate delivery and action-plus-door components. A failed enemy attack never becomes a bash. Moving-door rejection cannot queue another toggle or roll; lock state is checked at commitment rather than attack input time.

Successful unlock followed by failed opening or invalid destination retains unlock without duplicated roll, fatigue, practice or incidents. Technical failure after unlock/linked action needs explicit recovery; no claim of universal rollback. Same-strike retries cannot spawn multiple incidents or trigger links twice. Separate genuine attempts remain distinct.

Unsupported transition doors cannot move the player through a strike. Sound disabled/missing must leave detection/legal eligibility unchanged. Modded durability/wear/wall-stop interactions need explicit ordered policies and cannot retroactively undo committed outcomes. Closing occupancy follows MOVE-021's safe collision contract.

## Configuration and balancing options

Moddable bash formulas and source/door eligibility, magical-hold bypass admission, material feedback/responses, durability/wear/practice/extra costs and ordinary feedback. Authored actions retain validated trigger/link/busy contracts. Exact schemas/provider precedence and numeric bounds remain owner work under DATA/MOD/RULE. No vanilla Strength bonus, structural-damage system or arbitrary legal callback replacement is approved.

## Save/load considerations

Persist cleared locks and actual authored mechanism/door state through their owners. Native load must not reroll a completed bash, repeat fatigue, replay noise/legal incidents or reexecute links merely from restoring fields. Preserve a legitimate relock or pending required consequence according to its owner; do not treat load as ordinary door equip/activation.

COMBAT-001 cancels unfinished attacks while retaining committed costs/results. Exact save admission/representation during unlock, motion requests, authored effects or incident handoff remains SAVE/domain integration. Require a coherent boundary or recoverable completion facts so no partial operation loses obligations or replays effects. A separately authorized new bash after successful load may use fresh RULE-003 randomness; restoring a prior result does not.

## Technical constraints

Target Godot 4.7.2. Use explicit typed door/bash outcomes and one propagated operation identity across door, mechanism and legal owners. Separate probabilistic admission, persistent unlock, motion request and actual transition. Presentation failure cannot authorize replay. Do not copy Unity transform/component routing or source guard-spawn side effects as architecture. Native scheduling, idempotency, lock/link schema and partial-failure fixtures remain dependencies. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Only COMBAT-005's selected deliberate environmental purpose reaches bash/mechanism handling; reachable-enemy priority cannot fall through after a miss.
2. One door operation composes declared links once; no independent duplicate door/action execution occurs.
3. Stationary open door requests closing; moving door ignores without queue/roll; stationary unlocked closed door requests opening without roll; magically held closed door resists ordinary bash without roll.
4. Eligible locked interior/exterior doors resolve 20−L/25−L under RULE-001 once per genuine attempt. New strikes can retry without skill gating or cumulative weakening.
5. Unarmed/shield-hand unarmed sources use equal baseline chance; valid mod policies may change eligibility/formula.
6. Success persistently unlocks; failed opening/entry/feedback does not reroll or silently relock. Exterior bash leaves player outside until separate activation.
7. Committed strikes retain one fatigue cost with no default environmental practice, wear or structural damage. Default wall contact does not add early cancellation.
8. Genuine bash noise/incidents are authoritative regardless of audio settings; LAW owns response and no combat branch directly spawns guards/universally changes hostility.
9. Authored Attack admission honors one-shot/repeatable/busy rules and propagated identity; unsupported/busy triggers do not queue.
10. Transition-only non-bashable doors cannot transition from strikes. Ordinary feedback avoids new spam popups/chance displays while errors remain clear.
11. Duplicate callbacks, technical recovery and native restore cannot repeat rolls, unlock effects, links, fatigue or incident delivery. Partial failures preserve committed facts and required obligations.

## Contradiction review

Reviewed against approved COMBAT-001–005, MOVE-020/021/026 and RULE-001/003/004 contracts plus source/catalog/architecture. No direct contradiction identified. No-roll ineligible/unlocked door handling does not contradict RULE-001's required draw for admitted 0/100 checks. Persistent bash unlocking follows MOVE lock persistence; separate activation respects exterior access/entry ownership. Noise/incident reporting preserves MOVE-020's LAW ownership and independence from audible sound. Declared action composition preserves MOVE-021's authored links without duplicate component execution. Source automatic transitions, direct guard/hostility responses and non-player bash behavior are not adopted implicitly. Architecture proposals remain Proposed outside confirmed requirements.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: lock/classification domains, formula/mod schemas, action-link inventory/order, incident/noise magnitude/detection contracts, exact unlock-versus-opening notification stages, safe door-motion fixtures, partial-operation recovery and save boundaries. These cannot silently add guard spawning, automatic exterior entry, environmental practice/wear or incident suppression through audio settings. Enemy-initiated door attacks remain a separate owner review.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-006-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented lock/formula schemas, authored links, noise/legal contracts, motion verification, recovery and save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
