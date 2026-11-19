# TIME-004 — Elapsed-time catch-up across systems

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-15 with “I approve”. See TIME-004-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Keep deadlines, ongoing effects and scheduled world changes consistent when time passes through ordinary play, rest, travel or prison. A time-skipping activity reports the duration it actually committed. If a lethal effect interrupts rest, the player dies at the simulated instant of that effect. When an activity completes, the resulting state is ready before the player can act on it.

## Confirmed requirements

[TIME-004-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm TIME coordination with owner-declared policies, chronological processing for order-sensitive work, equivalent bulk processing, approved coalescing and skipping, explicit precedence at simultaneous instants, and bounded recovery that preserves committed progress.

## Daggerfall Unity reference

Static inspection of the local DFU 1.1.1 Release snapshot. Paths are relative to `Assets/Scripts/`. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

- `Game/MagicAndEffects/EntityEffectBroker.cs#Update` processes elapsed classic game minutes with a cap of two days or 2,880 rounds. It then sets the minute cursor to the current time. Separate effect paths can have different policies.
- `Game/Entities/PlayerEntity.cs#Update` iterates elapsed minutes for periodic faction and legal work. It applies separate suppression flags to normalization and encounter processing.
- `Game/Questing/Clock.cs#Tick` subtracts sampled game time from running quest clocks. `Game/LoanChecker.cs#CheckOverdueLoans` compares sampled current time to due dates and checks crossed reminder thresholds.

## Detailed rules and parameters

### Plan and settle a committed advance

1. For each TIME-002 request or eligible ordinary interval, gather the applicable owner rules using the advance reason, operation scope and current state. Owners declare due instants, dependencies, and whether their work is required before progression or is presentation. TIME-003 supplies relevant calendar crossings. Already-due work retained by a supported recovery path belongs to that path.
2. Use native game milliseconds. A scheduled instant `t` is crossed when `previous < t ≤ end`. Process order-sensitive consequences at their due instants, in ascending timestamp order. Before committing past a candidate instant, settle any earlier work that could change later work, eligibility or the actual endpoint. Re-evaluate affected future work after a relevant mutation. A rule created at `t` cannot receive elapsed work from before `t`. Its immediate or same-instant behavior follows its owner's declared contract.
3. At a shared instant, apply approved precedence and declared dependencies first. Independent work uses stable owner and occurrence identities to break ties. A dependency cycle or undefined precedence between known interacting rules is a validation or recovery failure. A late same-instant dependency cannot silently run ahead of work it needed to precede. Quest expiry takes precedence over uncommitted on-time hand-in at the exact cutoff under QUEST-010.
4. Apply a per-pass work budget. Continue unfinished required work across passes while keeping consequential player actions and dependent activity completion gated. Retain outstanding eligible work and settlement position. A budget limit cannot silently discard elapsed time or advance the clock past unfinished work that could change the outcome. Presentation may show progress while independent UI remains responsive.
5. On an applicable interruption, stop further advancement at the interrupting instant. Preserve committed effects and record actual elapsed duration as `committed endpoint − start`. Apply same-instant consequences according to their dependencies and eligibility after the interruption. Required work still valid at that instant settles before the applicable handoff. No work from the uncommitted future interval is eligible.

### Owner catch-up policies

- **Chronological.** Process individual due consequences when intermediate state, eligibility, randomness or interruption can affect their results. Due-time computation can jump directly to the next relevant instant.
- **Equivalent bulk update.** Combine work only when the owner can preserve the ordered outcome, including observable interactions, random outcomes and interruption opportunities. End a bulk interval before a dependency or interruption point whose outcome is still unknown.
- **Owner-approved coalescing or skip.** Apply the approved occurrence selection, identity and eligibility rules. A skip is final for the covered interval. Apply QUEST-010's distinction between missed recurrence and an occurrence due exactly at the actual destination. If choosing the destination depends on an interruption, defer endpoint-dependent selection until known. If the selection can itself affect the endpoint, require an explicit owner ordering and interruption contract before admitting that combination.
- **Destination state.** Derive presentation and endpoint-only eligibility from the committed endpoint and resolved context. A skipped availability window does not count as a visit or interaction.

### Activity rules and configuration

- Use explicit activity reasons and validated owner policies. LAW-015 skips ambient encounters, periodic pursuit, and legal and faction normalization for the prison sentence. Its separate four-hour release interval skips ambient encounters and periodic pursuit while custody remains active, and applies ordinary calendar and normalization rules. Calendar deadlines, rentals and timed effects retain their own approved treatment. The countdown's pacing and skip produce the same authorized sentence accounting.
- Rest rechecks applicable threats and vetoes before each segment under CORE-019. Travel, rest and other activity owners define their allowed interruptions, interval context and completion effects. Owner-approved behavior for those activities remains the authority for suppression and rewards.
- Support validated owner timing data and mod contributions under DATA-003 and the applicable feature contracts. Owners configure intervals and authored recurrence limits. Processing budgets manage responsiveness. Owner-approved occurrence limits can change gameplay as specified by those owners.

## Required data, inputs, outputs and events

Inputs include the TIME-002 session and operation identity, start and requested endpoint, reason, relevant activity and location context, TIME-003 markers, owner policies and due work, occurrence identities, dependency order, and interruption or failure outcomes. Outputs include committed segments, settled occurrence outcomes, actual endpoint and elapsed time, remaining work, and an explicit completion, interruption or failure result. Required consequences use checked owner operations. Observer notifications can refresh presentation from committed state. Public API and signal names remain open.

## Cross-system interactions

- [TIME-002](TIME-002.md) owns the clock operation and exclusive advance admission. [TIME-003](TIME-003.md) defines grouped crossings and destination refresh. CORE-016/017 provide eligibility and bounded processing principles. An explicit calendar advance triggers only applicable owner work. Ordinary movement, combat and AI keep their own simulation eligibility and cadence.
- [MAGIC-008](../MAGIC/MAGIC-008.md) owns effect clock units, conversion and interruptible ticking. Effects with their own elapsed path each have one progression owner. [QUEST-010](../QUEST/QUEST-010.md) owns expiry and recurrence. LAW, FACT, ECON and other owners supply due boundaries, timing policies and activity exceptions. CHAR owns vital and death consequences. SAVE coordinates coherent publication and restore.

## Edge cases, failure and save/load

- A zero-length interval yields no crossings. Reject reversed, overflowing, unauthorized or stale-session work. A callback or retry cannot start a competing advance or apply the same occurrence twice. Choose stable operation and occurrence identities that survive supported retry and restore.
- If required work fails, preserve the committed clock and completed effects, retain the exact unfinished position, and suspend dependent actions until valid recovery. Resume the unfinished work using its identity and recorded outcome where available. An ambiguous mutation outcome requires owner reconciliation before retry. Report failure or recovery state truthfully. No success notification is published while required work is unresolved.
- Save at settled boundaries unless the owner and SAVE support coherent in-progress saves. A supported partial save retains clock and operation progress, applicable resolved policies, due-work position and durable evidence of completed consequences where needed. Restore that snapshot with zero wall-clock elapsed. Reconcile supported pending work before readiness. Loading a settled snapshot produces no historical catch-up.

## Acceptance criteria

1. A long jump with mandatory effect ticks retains all required outcomes across processing passes, even beyond 2,880 ticks where supported. Equivalent bulk processing produces the same observable outcome and interruption behavior as the stepwise reference.
2. A lethal poison tick during rest stops at its exact instant. A later deadline or heal is untouched by the uncommitted portion, and the operation reports actual elapsed time. A deadline already crossed before the lethal tick settles once.
3. Simultaneous interacting consequences follow declared dependencies regardless of registration order. Independent work is repeatable. Quest expiry defeats a pending on-time hand-in at the cutoff. A dependency cycle fails explicitly.
4. A prison sentence and its release interval apply their distinct approved suppression rules. An expired quest is reconciled before control returns. Countdown skip leaves the committed outcomes identical.
5. An owner-approved coalesced recurrence preserves the selected occurrence identity and handles an occurrence due exactly at the destination separately. Suppressed occurrences do not replay after the activity.
6. A required owner operation fails after earlier commitments. Recovery keeps those commitments, avoids duplicate charges and effects, and resumes at the unfinished step. A supported partial save and restore achieves the same result with zero wall-clock catch-up.

## Consistency review and outstanding questions

The specification fits approved TIME-001–003 clock and boundary rules, CORE-016/017 eligibility and work accounting, CORE-019 rest checks, QUEST-010 recurrence and deadline precedence, MAGIC-008 timing and interruption, and LAW-015 sentence and release policies. Remaining dependencies are the concrete precedence table for interacting owners, occurrence identity and recovery formats, safe save boundaries per activity, and validated work budgets.
