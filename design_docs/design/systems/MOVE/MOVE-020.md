# MOVE-020 — Exterior access and trespass

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Make building entry, locks and unauthorized access predictable without conflating an unlocked door with lawful permission. Preserve configurable DFU-derived schedules and access exceptions while ensuring prompts, failed placement and native restoration cannot duplicate attempts or crime events.

## Confirmed requirements

MOVE-020-D01–D11 in [the decision log](../../GAMEPLAY_DECISIONS.md) record four interviews. Rules below consolidate confirmed choices. RULE-009 probability, MOVE-018/019 targeting/modes, MOVE-016 committed dismount and CORE placement/readiness remain binding. LAW owns crime qualification and response.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths below are relative to reference `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/PlayerActivate.cs#BuildingIsUnlocked` considers player-owned house, active quest residence, guild access/membership, daytime residences, shop hours/Sun's Rest and owned ship access. `IsBuildingOpen` compares current hour to opening/closing arrays.
- `ActivateStaticDoor` handles exterior reach/discovery, Open effect, locked-door/Steal picking, bashing and greetings before entry. Failed picking records live skill per building; later picking is rejected until live skill exceeds it. Source random reseeding/comparison is not target probability policy.
- `GetBuildingLockValue` returns quality/2 with an explicit comment that classic calculation is unknown and this is an approximation. `TransitionInterior` sets location flags and enters; greeting close defers that call.
- Source branches directly request crime/guards for some bashing outcomes. Those placements are observations, not approval of unconditional guard response or all consequences.

## Detailed rules and behaviors

### Access evaluation

Evaluate physical lock state, permission to enter and public opening status separately. Unlocked cannot automatically mean lawful, and closed cannot silently erase an explicit unlocked state. Use DFU-derived hours, daytime residence access, guild privileges and holiday closures as moddable baseline definitions.

Evaluate target building region and current game time, not unrelated player-region/default values. Ownership and authorized quest grants have explicit precedence and declare whether they override locks, permission or schedule. Exact schedule/access inventory and precedence require TIME/ECON/FACT/LOC integration; missing required data cannot silently make a building public.

Replace broad active-quest-residence unlock with explicit quest grants: unlock, permission or both. Preserve necessary vanilla quest access through validated content mappings. Theft quests cannot accidentally unlock their own targets simply by listing a residence.

Physically unlocked entrances permit entry even without permission, supplying unauthorized-entry context to LAW. No new universal confirmation prompt is introduced. LAW decides whether circumstances constitute trespass, who notices and ensuing consequences.

### Modes and break-in intent

Ordinary Grab/Talk activation of a locked entrance reports the lock and stops. Steal may request ordinary picking; bashing requires an explicit attack/bash action. Info remains informational under MOVE-019 and cannot execute a break-in.

Open effects follow explicit MAGIC activation/consumption rules, not blanket permission to cast on every click. MOVE-018 spell/interaction arbitration still allows only the declared primary action. Effect resolution and entry are distinct; a completed cast cannot be replayed because subsequent entry fails.

### Lock difficulty and attempts

Initial moddable exterior difficulty is floor(building quality/2), explicitly a DFU approximation, with supported explicit validated content/mod overrides. RULE-009 exterior probability and difficulty explanations use the same model; do not substitute the interior formula or source strict-comparison/reseeding behavior.

After failed picking, record resolved live Lockpicking per building. Another ordinary attempt requires current live skill greater than that failed value. Persist the record across save/load; menus/re-entry cannot reset it. Retry policy is moddable. Blocked requests consume no roll or practice.

Genuine attempts follow RULE-003/009 retained-outcome and CHAR practice contracts. Exact successful/failed attempt side effects, event identity and resource boundaries require owner integration rather than per-frame rerolls. Magical/bashing eligibility and probabilities remain MAGIC/RULE/LAW contracts; no new bash success/detection percentage is selected here.

Successful pick or Open establishes explicit unlocked state retained across re-entry/native saves until a declared owner action relocks it. Opening-hour changes alone cannot erase that state. Scheduled relocking requires explicit moddable policy, not incidental recomputation. Unlocking does not grant permission. Exact multi-door sharing of building lock state and grant-versus-permanent-unlock lifetime require stable identity/owner rules.

### Crime and entry commitment

Report actual attempts, successful forced entry and unauthorized entry as distinct checked LAW events. Successful unlocking is not itself successful physical entry. Picking failure does not directly spawn guards here; bashing noise/detection and legal responses require explicit LAW rules. Audible sound preferences/missing clips cannot change authoritative detectability.

Revalidate target, reach/obstruction, access, current opening status and destination readiness after prompts and before entry commitment. Failed/cancelled entry cannot publish inside state, dismount or successful-entry/trespass events. Already completed lock/cast/bash attempts retain their own consequences; do not roll back by pretending no attempt occurred or replay them on retry.

Commit on-foot transport change with successful entry under MOVE-016, not a pre-transition notification. World/LOC/MOVE-026 own actual reconstruction and bounded placement recovery. Rechecking closed status may update permission/lock-policy outcomes but cannot silently relock a retained explicit unlock.

### Entry presentation

Retain configurable eligible residence greetings and shop-quality information before entry. Presentation cannot grant access, consume another attempt or commit trespass. Message close continues only the original revalidated operation; cancellation/failure remains outside. UI/ECON/LOC own exact availability/text and accessible close/cancel semantics. Optional presentation failure cannot replay a completed action; required failure follows owner recovery.

## Relevant formulas and parameters

Exterior baseline D=floor(Q/2), where Q is validated building quality; explicit difficulty overrides require valid domains. RULE-009 supplies exterior raw chance S−5D and approved final limits, not this feature's own independent roll. Retry requires live S greater than recorded failed S. Exact schedule tables, bash probabilities and relock cadence are owner dependencies, not approved constants here.

## Required data

Stable building/entrance identity and region/type/quality; physical lock and explicit-unlock state; permission/public status and provenance; ownership/guild/quest grants; game-time/holiday context; failed-pick skill; attempt/outcome identity; deferred entry intent and readiness; committed legal context. Concrete schema and multi-door scope remain engineering dependencies.

## Inputs, outputs and events

Inputs: eligible mode/action, target context, access sources, schedule/time, attempt results, prompt close/cancel and transition completion. Outputs: permission/lock evaluation, blocked explanation, checked attempt request/result, deferred entry, committed inside/Foot state and distinct LAW events. API names remain unselected. Preview/Info cannot authorize a break-in roll or crime attempt.

## Cross-system interactions

MOVE-018/019 own target/mode/consumption; MOVE-016 transport commitment; MOVE-026/027 placement. RULE-009 probability, RULE-003 randomness and RULE-004 hooks; CHAR practice/skills; MAGIC Open; LAW crime/noise; QUEST scoped grants; FACT guild access; TIME/ECON schedules/holidays/ownership; LOC building identity; UI greetings; CORE/SAVE readiness and durable state; MOD/DATA validated policy definitions.

## Edge cases and failure conditions

Test schedule/holiday changes during prompts, expired quest grants, unlocked-but-unauthorized doors, failed placement after a successful pick and repeated failure at unchanged skill. Temporary skill increases can satisfy the deliberately live-skill retry rule; no permanent-skill substitution is implied. Multiple entry callbacks cannot duplicate LAW events or dismount.

Missing guild/building/schedule data cannot imply public access. Source active-quest exceptions require deliberate mappings before necessary routes are claimed covered. Relock changes need explicit owner actions. A prompt cannot retarget a replaced entrance. Required failures use checked recovery without automatic access bypass or repeated partial mutations.

## Configuration and balancing options

Access grants/precedence, schedules, exterior difficulty, retry and relock policies support validated mod contracts. Vanilla follows selected DFU-derived baseline policies and explicit grants. No universal trespass confirmation, forced guard spawn on pick failure, automatic legal permission from unlocking or unreviewed bash formula is introduced.

## Save/load considerations

Persist explicit lock changes, failed-attempt value, stable grant/permission sources and required attempt/entry completion facts. Restore ownership/quests/time before evaluation without rerolling, repeating crime or treating saved outside state as committed entry. Supported pending prompts retain stable intent and revalidate under MOVE-018/SAVE; exact mid-operation save boundaries remain owner contracts.

## Technical constraints

Target: Godot 4.7.2. Separate access evaluation, checked attempts, optional presentation and committed placement/legal consequences. Use stable scoped identity and current target-region time. Concrete policy schemas, transaction boundaries, event IDs and scene reconstruction remain choices to verify. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Lock, permission and public status remain separate with explicit source precedence; missing required data cannot grant access.
2. Quest grants declare unlock/permission scope and theft sites do not unlock merely from active-quest membership.
3. Locked Grab/Talk stops, Steal requests eligible picking, Info stays informational and bashing/casting require explicit actions.
4. Exterior difficulty/explanation uses selected baseline/override and RULE-009 model; blocked retries consume no roll/practice.
5. Failed skill record persists; only greater live skill authorizes ordinary retry under vanilla policy.
6. Successful pick/Open unlock persists until explicit relock without granting legal permission.
7. Unlocked unauthorized entry supplies LAW context without universal confirmation; attempt/forced-entry/unauthorized events stay distinct.
8. Prompt/time/context revalidation and placement failure cannot commit inside/Foot/trespass or replay completed attempts.
9. Greetings/quality remain configurable presentation, not access/entry authority.
10. Save/load preserves required facts without rerolls, duplicate crimes or automatic public fallback.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against RULE-009, MOVE-016/018/019 and CORE transition/readiness contracts. No direct contradiction identified. Info is safe, deferred action retains identity, and Foot change follows successful placement. Failed entry does not erase completed attempts. Separate permission/public/lock state supports explicit persistent unlocking without suppressing holiday/legal evaluation. Exact LAW crime definitions and bash probabilities remain unresolved owner scope rather than copied source branches.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: exact access/schedule/grant precedence/inventory, quest mappings, lock identity/relock actions, bash/MAGIC contracts, CHAR attempt practice, LAW event commitment, presentation availability and native/placement fixtures. These do not waive explicit access sources, retained attempts or safe entry commitment.

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under MOVE-020-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented policy, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
