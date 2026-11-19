# ECON-019 — Accounts, deeds and service state restoration

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-019-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-019-interview-decisions).

## Gameplay purpose and intended player experience

Loading returns the player to the saved balances, property rights and service obligations. A paid repair stays paid, depleted stock stays depleted under its approved policy, and property contents stay tied to the correct location. If a required dependency is missing, the player receives an explanation while their current session remains available.

## Confirmed requirements

Validate required economic state before replacing the current session. Missing dependencies require validated migration or owner-defined recovery. Allow disclosed recovery for closed history used solely for display. Defer ordinary saves across unsettled mutations unless the owner supports a coherent recovery save. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-019-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/Serialization/SaveLoadManager.cs` captures and restores bank accounts, ship deeds and houses. House records can restore before affected interior reconstruction. `Game/Serialization/SerializablePlayer.cs` restores rentals and daily Daedra selection, and `Game/Items/ItemRepairData.cs` restores repair facts. `Game/Utility/StartGameBehaviour.cs` includes a separate classic bank import route through `DaggerfallBankManager.ReadNativeBankData`. These are static observations. The target load contract covers native Godot saves under CORE-013.

## Detailed rules and behaviors

1. **Capture authoritative state.** Preserve balances, carried and stored money and credit, outstanding debt and default facts, deeds and protected contents, rentals and expiry, repair custody and terms, retained stock and daily selections, and required committed operation and reward identities through their owners. Apply each approved stock policy. Transient baskets, uncommitted confirmations and per-opening potion offers expire with the session.
2. **Admit saves at coherent boundaries.** Allow persistent loans, rentals and repair jobs while their records are coherent. During unsettled payment, delivery or required consequences, defer the save according to the owning save contract and explain the delay. A supported recovery save preserves exact completed phases and outstanding obligations. Validate all required owner records as one save generation.
3. **Preflight the selected save.** Validate required records, stable identities, referenced definitions and profile versions before session replacement. Prepare and validate any migration or declared owner recovery against the saved candidate. Recovery must preserve possessions, amounts, enforceable obligations and their required history. When required state remains unresolved, reject the load with an actionable explanation under CORE-013. Preserve the current session and the source save.
4. **Recover display-only history.** An owner can designate closed history as optional only when its absence affects presentation alone. Disclose the proposed recovery before proceeding. Loan default or reward history, replay protection, ownership and eligibility records remain required wherever consumed by gameplay.
5. **Restore and reconcile.** Restore authoritative records and saved game time before dependent interactions resume. Make ownership, custody and entitlements available before affected scene, access and storage reconstruction. Rebuild transient views and derived scene registration. Run owner reconciliation at approved game-time boundaries for due repair completion, rental expiry, stock refresh and overdue loans. Resume only unfinished authoritative work. Publish restored readiness through CORE-013 after required phases succeed.

## Formulas, parameters and configuration

Use accepted amounts, deadlines and policies already bound to each operation. Reconciliation follows the owning feature's clock and eligibility rules. Loading introduces no elapsed time. Mods can supply validated version migrations and owner recovery profiles. A profile that changes future values or rates must keep previously accepted obligations coherent.

## Required data, inputs, outputs and events

Use the save generation and schema version, stable player, region, account, property, service, item and operation identities, definition versions, saved game time, authoritative holdings, accepted terms, phase facts and optional-history classifications. Inputs include save and load requests, migration and recovery results, and reconciliation context. Outputs include coherent capture, temporary save deferral, actionable preflight rejection, disclosed recovery, or restored readiness. Reconstruction emits no new trade, payment or reward.

## Cross-system interactions

SAVE and CORE-013 own native preflight, replacement and readiness. ECON-001 through ECON-018 supply their respective authoritative state and operation rules. ITEM owns custody, stock and credit. TIME supplies saved clock and eligible boundaries. LOC/WORLD/MOVE consume restored property and transport facts. LAW and FACT restore penalty, entitlement and reward history. MAGIC and QUEST resume relevant service outcomes. DATA/MOD validate definitions and migration support.

## Edge cases and failure conditions

- An unavailable required provider, region or property cannot silently erase debt, release custody or restore an empty account. An approved migration or recovery must preserve the relevant facts.
- Corrupt display-only history can use disclosed recovery. A similar-looking receipt needed to prevent replay remains required.
- A paid repair due at restore completes coherently once. A rental that has expired grants no further rental rights. An overdue loan follows the approved collection sequence.
- If restoration fails after replacement begins, follow CORE-013 cleanup and recovery. Keep interactions gated until mandatory reconciliation succeeds. Invalidate callbacks from the previous session.

## Save/load and technical constraints

Target Godot 4.7.2. Keep state scoped to the loaded session. Version durable records and keep derived handles disposable. Persist only the authoritative facts needed by the owners and their reconciliation contracts. Do not replay accepted transactions, reprice accepted terms or apply elapsed wall-clock time. Concrete schemas and load ordering interfaces remain integration work.

## Acceptance criteria

1. Round-trip regional accounts, credit, active debt, deeds, rentals, repair custody and retained stock without loss, repricing or replay.
2. A missing required dependency either resolves through a validated owner migration or recovery, or blocks preflight with the current session intact.
3. Disclosed recovery can omit unreadable display-only history. Missing eligibility or no-replay facts cannot use that path.
4. An in-flight mutation defers saving unless the owner supports coherent recovery. On load, supported recovery resumes only unfinished work. Coherent active service obligations remain savable.
5. Restore entitlements before their consumers, reconcile due work against game time, and discard stale UI and callbacks.

## Compatibility review and outstanding questions

The specification follows CORE-013 native load preflight and the approved ECON owner contracts for transient offers, accepted terms, retained results and committed state. Exact save schemas, supported migration mappings, deferral feedback and cross-owner recovery fixtures remain open.
