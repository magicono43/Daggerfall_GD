# CHAR-022 — Exhaustion and collapse

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Resolve fatigue depletion according to danger and swimming context, with once-only forced collapse/recovery or a normal lethal-health request, without time-skip loops or UI-driven duplication.

## Intended player experience

Exhaustion stops ordinary activity. On safe land the character collapses for an hour and recovers under the ordinary rest rules; in water or near genuine threats exhaustion is lethal unless normal death prevention applies. Unrecoverable exhaustion remains an explicit condition rather than secretly repeating hours or inventing fatigue.

## Confirmed requirements

CHAR-022-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish default safe/lethal classification with mod overrides, shared recovery, purpose-specific threats, protected time activity, authoritative episode identity and persistent unresolved incapacitation.

CHAR-018 owns positive-to-zero depletion and pool mutations. CHAR-020 drains fatigue; CHAR-021 calculates recovery; CHAR-012 reports practice and CHAR-013 advances skills. CHAR-023 owns death/prevention and CORE-019 provides purpose-specific threat-query principles. Ordinary rest vetoes are not automatically lethal collapse criteria.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/PlayerEntity.cs#PlayerEntity_OnExhausted` ignores repeated calls while displayingExhaustedPopup and when current health is zero, queries AreEnemiesNearby, cancels movement and shows a context-dependent message.
- If not swimming and no nearby enemies, it raises time by one hour, calls the three FormulaHelper recovery functions, increases health/fatigue/magicka and tallies Medical +1. Otherwise it calls SetHealth(0), retaining player death-prevention handling.
- `ExhaustedMessageBox_OnClose` merely clears the popup guard. Intended authoritative episode state replaces reliance on that window lifetime.
- `Game/Entities/DaggerfallEntity.cs#SetFatigue` can emit exhaustion at zero while alive. CHAR-018's approved transition-only semantics are authoritative for the recreation rather than repeated source setter events.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; threat reachability, overlapping poison/death and time-skip events remain runtime verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Episode admission

Respond to valid fatigue depletion for the current living character. Stop/cancel ordinary movement and initiate one scoped authoritative exhaustion episode. Reject stale callbacks and ignore duplicate admission for the same episode, independent of popup/UI state. Already-dead characters do not begin another collapse.

A new ordinary episode requires fatigue recovered above zero and subsequently depleted again. Recovery during an active episode does not authorize concurrent duplicate operations; serialize resolution and admit a later genuinely new depletion through explicit owner context. UI closing, reload or periodic zero writes cannot create a new episode.

### Default classification

Use current valid swimming/activity state and an explicit exhaustion-purpose NPC/COMBAT threat result. Swimming includes surface swimming, not only submerged/breath-holding state. If swimming or genuine threats are nearby, issue a lethal health-zero request through CHAR-018/023's normal prevention/death path. Do not bypass authorized prevention, directly declare death or run the safe hour as well.

Otherwise choose safe-land collapse. Rest-specific legal/location/quest vetoes do not independently make exhaustion lethal. Threat eligibility/range/detection belongs to NPC/COMBAT's purpose contract, not guessed from generic distance or presence of any actor. Feedback stays generic where threats are hidden; do not disclose hidden actor names/locations/counts.

Failed required context/query evaluation is not proof of safety or danger. Keep the operation safely gated and report inability to resolve through explicit recovery rather than choose an arbitrary lethal/safe fallback. Exact retry/error presentation remains CORE/UI scope.

### Safe collapse activity

Default safe collapse advances one game hour as a forced protected activity, suspending ordinary movement/controls and settling time/recovery once. TIME still propagates required quest/condition/world events; protection is not permission to cancel obligations. Default does not expose ordinary enemy combat interruption during the skip. Event ordering and required-event settlement must follow declared TIME/owner contracts.

Use CHAR-021's then-current health/fatigue/magicka recovery formulas and restrictions for the completed hour, including its environment/Rapid Healing classification. Apply capped recovery through CHAR-018 and report +1 raw Medical practice through CHAR-012 for that committed hour. Do not apply duplicate ordinary activity fatigue to the same owned interval or reset breath through generic fill.

Collapse is not automatically a new default CHAR-013 rest/travel checkpoint. In live mode qualifying Medical practice follows the shared live rules. Any alternative trigger requires explicit progression-owner policy; do not award twice because a recovery helper and UI callback both ask.

Commit coherent elapsed-time/recovery/practice state and episode progress before reporting completion. Repeated completion callbacks cannot add another hour or another Medical point. Recovery may restore some pools but is not unconditional full healing.

### Successful recovery and unresolved exhaustion

If fatigue becomes positive and no other required outcome blocks return, resolve the episode and release only its own suspension/control gates. Other pause/modal/death/readiness conditions remain effective. Contextual feedback cannot itself be the authority for an extra recovery operation.

If a completed hour leaves fatigue at zero, explain unresolved exhaustion and retain incapacitation. Do not automatically skip further hours, grant artificial minimum fatigue or request death solely because recovery failed. A zero fatigue maximum is one possible cause; owner restrictions may create others.

Provide the state/reason to explicit condition/mod recovery or alternate-outcome operations. Ordinary movement remains unavailable until a valid owner resolution; required recovery/UI controls follow CORE/UI contracts. This does not invent a cure item, resource fee or automatic rescue mechanic. Persist genuine incapacitation rather than erase it during save/load.

The lethal branch remains a request, not guaranteed death. If death prevention succeeds but leaves fatigue zero, retain coherent unresolved exhaustion for owner resolution rather than repeatedly retry the same lethal request or silently enter the safe-hour branch. Exact prevention consequences remain CHAR-023/FACT scope.

### Mod alternatives

Allow validated outcome/classification/activity policies, including alternate collapse results and event-driven interruption. Define permitted contexts, duration/recovery/practice treatment, continuation/terminal state and required-event settlement explicitly. Default safe hour/lethal danger-water outcomes remain unchanged unless a supported definition overrides them.

An interrupted alternative must declare elapsed-time effects, completed/partial recovery, practice credit and whether the character stays incapacitated, resumes a saved activity or enters another outcome. Do not invent proportional recovery or practice by implication. CHAR-021's default unfinished-hour no-recovery rule remains unless an explicit compatible alternative overrides it.

Alternate policies cannot rely on popup order, duplicate callbacks or save reload to repeat effects. New executable outcomes need supported MOD/owner contracts rather than arbitrary unvalidated code in definitions. Changes to threat criteria must remain purpose-specific and truthfully reported.

## Relevant formulas and parameters

- Trigger: valid current living character's positive-to-zero fatigue transition under CHAR-018.
- Default lethal context: swimming OR exhaustion-purpose genuine threat present.
- Default safe context: not swimming AND valid query reports no genuine threat.
- Default collapse duration: 60 game minutes.
- Completed safe hour: CHAR-021 health/fatigue/magicka rates once, +1 raw Medical practice; no separate ordinary fatigue drain.
- Post-recovery fatigue>0 can resolve exhaustion; fatigue=0 retains incapacitation without automatic retries/death.

No new recovery rates, threat distance, death-prevention chance or partial-duration formula is selected here. Supported alternative parameters must satisfy safe numeric/pool/time contracts.

## Required data

Episode/session identity and phase; depletion provenance; health/fatigue/activity context; explicit threat query/result; resolved default/alternate outcome policy; active elapsed/collapse settlement receipts; source recovery/practice results; unresolved reason and owner resolution state. Concrete schema and operation IDs remain engineering dependencies.

## Inputs, outputs and events

Inputs: valid depletion, activity/threat/context results, time/recovery completion, configured interruption, explicit condition resolution and restoration. Outputs: one admitted episode, forced activity or lethal request, coherent recovery/practice, resolved or persistently incapacitated result, or actionable required-context failure. These are conceptual contracts, not API/signal names. Popup acknowledgement cannot replay consequences.

## Cross-system interactions

CHAR-018 supplies depletion/mutations; CHAR-020 activity ownership; CHAR-021 recovery; CHAR-012/013 practice/advancement. MOVE supplies swimming/control state; NPC/COMBAT exhaustion threats; TIME/QUEST/MAGIC propagate required events/conditions; CHAR-023/FACT handle lethal prevention/death. UI/AV provide feedback, DATA/MOD validate alternatives and CORE/SAVE scope/gate/restore episodes.

## Edge cases and failure conditions

- Poison or simultaneous damage cannot stack collapse windows/time awards; already-dead state suppresses new collapse.
- Surface swimming is lethal exhaustion context by default even with full breath; water-breathing does not implicitly prevent fatigue exhaustion.
- Generic rest veto is not a lethal criterion; failed queries cannot silently choose danger or safety.
- One-hour recovery obeys restrictions and can leave fatigue zero; no free repeated Medical practice/hour loop.
- Required quest/condition events remain valid during protected activity; alternate interruptions require explicit settlement.
- Prevention success cannot retrigger the same lethal request merely because fatigue stayed zero.
- Popup rebuilding/save load cannot reset episode identity or abandon unresolved incapacitation.
- Multiple suspension owners prevent premature gameplay release after collapse/death transitions.

## Configuration and balancing options

Validated mods may override supported classification/outcomes, duration and interruption/settlement policies. Recovery values remain CHAR-021/domain inputs unless explicitly overridden through compatible rules. No universal automatic rescue, repeated collapse recovery or direct death bypass is introduced. DATA-003 validation/locking and required owner support apply.

## Save/load considerations

Persist authoritative episode/incapacitation state, active activity progress, committed time/recovery/practice receipts and policy context together with vitals. Restore through CHAR-017 without re-admitting depletion, repeating the hour or replaying a lethal request as a new event.

Supported active collapse resumes coherently or follows declared migration/recovery; unresolved zero-fatigue incapacitation remains unresolved until its owner resolves it. Required missing/invalid episode/source state fails explicitly rather than set fatigue positive or silently discard consequences. SAVE/TIME define safe boundaries, interrupted-activity schema and duplicate-safe reconstruction; UI is rebuilt from state, not serialized windows.

## Technical constraints

Target: Godot 4.7.2. Separate episode state, threat classification, forced-time activity, outcome mutation and presentation. Use source/session-scoped operation identity and coherent once-only settlement, not popup-visible flags. Concrete APIs, transaction/staging and mod hook formats remain engineering choices. Reference source/content remain read-only.

## Acceptance criteria

1. Valid fatigue depletion admits one living-character episode; duplicate/stale/UI callbacks cannot add hours/rewards or re-admit the same depletion.
2. Default swimming/nearby genuine threats request normal lethal handling; safe land uses one forced hour. Rest vetoes alone do not become lethal.
3. Protected default controls/time propagation settle once without cancelling required world events or charging ordinary activity twice.
4. Completed safe hour uses CHAR-021 rates/restrictions and +1 Medical, without invented default advancement checkpoint.
5. Positive recovered fatigue permits scoped resolution; remaining zero retains explained incapacitation without repeated skips/free fatigue/automatic death.
6. Prevention/death integration cannot replay lethal requests or accidentally run safe recovery as well.
7. Validated alternate outcomes/interruption policies specify complete settlement and preserve required-context safety.
8. Save/load preserves active/resolved/unresolved states and receipts without false recovery, duplicate consequences or UI-driven state loss.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-012/013/017/018/020/021, CORE-019 and relevant CORE lifecycle/restore requirements. No direct contradiction identified. Transition admission follows CHAR-018; safe recovery reuses CHAR-021 without turning all rest restrictions into lethal criteria. Protected/default and interruptible/mod policies remain explicit. Unresolved exhaustion preserves authoritative state rather than overriding pool limits. Lethal requests retain CHAR-023 ownership and do not preapprove prevention/death details.

## Outstanding questions and approval

No further blocking exhaustion-policy question is identified. Before implementation is complete: finalize exhaustion-purpose threat thresholds, forced-activity event boundaries, required-query recovery, prevention-zero-fatigue handoff and explicit incapacitation-resolution controls; define supported alternate schemas and SAVE episode settlement. Dependencies cannot waive one episode, normal lethal routing or persistent unresolved exhaustion.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-022-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented threat/activity/outcome, mod-schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
