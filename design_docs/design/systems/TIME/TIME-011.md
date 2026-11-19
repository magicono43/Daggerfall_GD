# TIME-011 — Rest interruption and completion

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-16 with “I approve”. See TIME-011-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

End sleep or loiter at the right instant and give the player a clear reason. Preserve time and recovery already earned. If something dangerous happens on a recovery boundary, resolve that danger before sleep can grant recovery. Eligible long sleep can refresh designated enchanted item effects.

## Confirmed requirements

[TIME-011-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm gameplay-first recovery ordering, moddable skill checkpoint routing, one settled outcome with prioritized feedback, and the base long-sleep item-effect reroll with mod support.

## Daggerfall Unity reference

Static inspection of the local DFU 1.1.1 Release snapshot. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits. Paths are relative to `Assets/Scripts/Game/`.

- `UserInterfaceWindows/DaggerfallRestWindow.cs#TickRest` advances time and ticks quests before the completed-hour recovery branch. The completed-hour branch checks threats and vetoes before recovery. `EndRest` selects the outcome message, and `RestFinishedPopup_OnClose` requests `RaiseSkills`.
- `DaggerfallRestWindow.OnPop` clears rest and loiter flags and raises `OnSleepEnd` when `totalHours > 6`. The elapsed-hour counter is shared by the activity modes and is incremented before the final hourly checks. The approved rule restricts the reroll to actual sleep and runs it during gameplay settlement.
- `MagicAndEffects/EntityEffectManager.cs#DaggerfallRestWindow_OnSleepEnd` calls `RerollItemEffects`. It works on pending items, removes eligible recast-enabled bundles from those sources and invokes reroll payloads for items still equipped. It does not globally reroll all enchantments.

## Boundary and terminal ordering

1. A TIME-010 activity advances through TIME-002/004 until a requested endpoint, a heal-until goal, a user stop, or a required interruption or failure. Split at an applicable exact cutoff. At a shared instant, apply required due gameplay consequences and recheck site, entitlement, threat and status eligibility before attempting a CHAR-021 recovery tick. Honor independently approved precedence and validity rules for those consequences.
2. A due recovery tick commits only when the completed hour remains eligible. Rental expiry, hunger, engaged enforcement, lethal damage or a newly disqualifying threat prevents recovery and associated Medical practice at that boundary. Retain the elapsed time and earlier committed ticks. A full hour that stays eligible can settle recovery when it is also the requested end. A voluntary Stop takes effect before the next uncommitted segment. If it arrives during settlement of an already committed eligible hour, allow that hour's required settlement and then stop. Reevaluate heal-until after relevant state changes and any eligible tick.
3. Seal the actual endpoint and terminal cause once. `actual elapsed = committed endpoint − start`. Settle required end-of-activity effects and clear activity ownership before handing back control. Apply other CORE suspension and scene readiness gates. Technical failure retains committed work, gates dependent actions and enters TIME-004 recovery. It is distinct from a successful wake-up or a gameplay interruption.

## Sleep-end effects and feedback

- **Skill checkpoint.** For living-character timed sleep or heal-until that ends after positive elapsed time, request one CHAR-013 rest checkpoint at settlement, including voluntary stop and gameplay interruption. CHAR-013 evaluates the strict `> 360 game minutes` since the last eligible check and its other conditions. Live mode uses its existing practice path. Loiter, zero-time attempts and death have no stock rest checkpoint. Popup acknowledgment cannot award or repeat advancement.
- **Item-effect reroll.** Base qualification is at least seven completed elapsed game hours in a single timed-sleep or heal-until activity, matching DFU's integer count greater than six. A living actor can qualify on successful completion, voluntary stop or interruption after reaching the threshold. This threshold counts completed elapsed sleep hours and is independent of the skill cooldown and of how many recovery ticks awarded healing. Loiter, death and zero elapsed time do not qualify. Request one scoped reroll from MAGIC/ITEM, covering only eligible pending equipped effects under their rules. Do not reroll unrelated effects or re-equip items. Owner-approved ordering applies if an end effect interacts with another required end action. Revalidate living state before actions that require it.
- **Feedback.** Show one primary player-facing reason. Death uses its own flow. Required technical recovery takes precedence over ordinary rest feedback. A gameplay interruption takes precedence over voluntary stop or normal completion at the same boundary. For multiple gameplay reasons, use applicable owner precedence and a stable configured priority for independent reasons. Use player-safe messages for enemies, expiry, and status vetoes. The outcome preserves relevant structured details even when only one reason is displayed.
- **Notification.** Publish one settled outcome per activity with mode, actual elapsed, endpoint, terminal class and reason after required settlement. Keep UI and informational observers independent of required gameplay actions. Restore, redraw and dismissal cannot replay committed work. Support validated mod-defined terminal reason IDs, localized messages and eligible rest-end hooks under DATA-003 and participating owner contracts. Hooks use the same interruption, precedence and retry rules.

## Data, inputs, outputs and configuration

Required data include activity, session and actor identity, mode, requested and actual endpoints, completed elapsed hours, recovery progress, due events, permission and hazard context, terminal reasons, and settlement progress. Inputs include Stop, time and recovery outcomes, eligibility changes and required owner acknowledgments. Outputs include interruption or completion, checkpoint and reroll requests where eligible, a settled outcome and safe UI feedback. API and signal names remain open. Mods can override supported checkpoint routing, long-sleep qualification, end hooks and messages. CHAR-013 and MAGIC/ITEM retain authority over advancement and recast policy.

## Cross-system interactions

TIME-009/010 own site and mode rules. TIME-002/004 own exact advancement and recovery. CORE-019 supplies fresh threat and veto checks. ECON-015 and MAGIC-028 supply exact rental and hunger restrictions. NPC/LAW supply relevant encounter and enforcement state. CHAR-021 owns coherent recovery and practice, CHAR-013 owns advancement, and MAGIC/ITEM own eligible effect rerolls. CORE and UI own death, readiness and feedback handoff.

## Edge cases, failure and save/load

- Resolve conflicting terminal causes deterministically, retain partial elapsed time, and preserve earlier committed recovery. No stock partial-hour grant or banking across requests. A stale callback, duplicate Stop or rebuilt window cannot terminate or reward the same activity twice.
- Use settled save boundaries unless SAVE and TIME-010 support active saves. A supported partial save retains the cutoff, settled recovery and terminal work identities, and retained reroll results where applicable. Restore revalidates unfinished work and preserves settled outcomes with zero wall-clock elapsed. Required failure with an ambiguous mutation outcome uses owner reconciliation before retry under TIME-004.
- Optional message or observer failure cannot repeat a gameplay effect. Required owner failure can defer handoff. Validate mod reason and message definitions. NPC and owner contracts still determine what counts as an encounter and what hidden information may be exposed.

## Acceptance criteria

1. A quest event or threat at the completed-hour boundary settles before recovery. An eligible final hour grants recovery and practice once. Rental expiry or disqualifying harm at that boundary blocks the tick while retaining committed elapsed time.
2. Stop during a partial hour preserves time and prior recovery. Stop during settlement of an already committed eligible hour allows that hour's settlement, then prevents additional advancement.
3. Positive-elapsed living sleep completion, stop and interruption request one applicable checkpoint. Loiter and zero-time or death paths do not. Exactly 360 minutes since the last eligible check fails the default CHAR-013 gate. Dismissal and restore do not recheck a settled outcome.
4. Six completed sleep hours do not qualify for the base reroll. Seven qualify once for eligible pending equipped effects on a qualifying living terminal path. Loiter, unrelated enchantments and replayed terminal callbacks produce no extra reroll.
5. A coincident encounter and normal endpoint show the urgent interruption reason. A mod can add a validated interruption reason, localize its message and use supported rest-end hooks. Neither a duplicate reason nor optional UI failure repeats settlement.
6. Failure after a committed tick or reroll preserves the result and gates handoff until recovery. A supported partial restore resumes unfinished required work and emits no duplicate benefit.

## Consistency review and outstanding dependencies

The specification fits TIME-002/004 and TIME-009/010, CORE-019, CHAR-013/021, ECON-015 and MAGIC-028. Concrete MAGIC/ITEM eligibility and durable reroll settlement, encounter policies, mod priority fields, and supported active-save boundaries remain integration dependencies.
