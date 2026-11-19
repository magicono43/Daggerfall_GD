# CORE-007 — Session start dispatch

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Coordinate session-changing requests predictably, preventing competing transitions, premature success and unnecessary destruction of the current session.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Route all session-changing requests through one coordinator, including menu buttons and quickload. Each request carries its mode, required data and tracking identity together. Route support does not itself approve classic import or worldless gameplay.
- Allow only one session-changing operation at a time. Reject additional requests with a clear busy result rather than silently replacing or queueing them. Ordinary settings/menu navigation may remain available where safe.
- Validate the request and available input data before destructive session teardown. Preflight failure leaves the current session intact. Once replacement begins, failures use safe cleanup/menu recovery; full rollback is not promised.

Second interview, confirmed by the user on 2026-11-05:

- Track validation, replacement and initialization with exactly one terminal outcome: Succeeded, Failed or Cancelled. Success requires completed restoration/readiness, not loading initiation. Release operation busy state on all terminal paths; unsafe cleanup still blocks new operations under CORE-005.
- Permit cancellation during preflight while the current session is intact. Once destructive replacement begins, disable cancellation and explain that transition must finish or enter recovery. No post-replacement rollback is promised.
- Repeated delivery of the same request identity refers to the same operation and must not execute twice. Reject distinct requests while busy. An intentional retry after failure uses a new identity and reruns validation.

Third interview, confirmed by the user on 2026-11-05:

- Suspend simulation/gameplay input during preflight, preserving responsive progress/error UI and the intact session. Failure/cancellation releases only the operation's suspension; other pause requirements remain.
- Require explicit confirmation by default before discarding a living active session. The 2026-11-17 [SAVE-005 amendment](../SAVE/SAVE-005.md) allows validated mod policy to suppress the prompt independently for manual native loads and quickloads. Declining preserves the session. Do not automatically save. Individual menu/death features may define exceptions for already-ended sessions.
- After replacement failure, complete safe cleanup before retry. Retry original intent with fresh validation, never resume partially initialized state. Missing inputs produce actionable failure rather than substitution of another save/character.

Fourth interview, confirmed by the user on 2026-11-05:

- Capture the selected character draft or save identity at submission. Later UI selections must not redirect the request. Ignore late callbacks from completed/superseded operations under CORE-005 scope rules.
- Prepare consistent validated input before destructive replacement. If selected save data changes/disappears before preparation completes, fail without touching the current session. SAVE defines snapshot/read mechanics; do not validate one version and load another unchecked version.
- Show the current operation phase without invented percentages. No generic elapsed-time failure limit: large saves may take longer. Report detected errors, permit preflight cancellation and keep recovery controls responsive. Operation owners may define specific evidence-based failure timeouts.

## Inherited approved requirements

CORE-001–003 retain storage, logging and settings rules. CORE-004 owns startup/menu routing and ARENA2 source restart behavior. CORE-005 requires validated dependencies, safe teardown, stale-work rejection and independent recovery UI; unsafe cleanup blocks new sessions with Retry Cleanup/Quit. CORE-006 effective preferences remain distinct from saved/pending preferences and service readiness does not override other suspension requirements.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/Utility/StartGameBehaviour.cs`, Update/InvokeStartMethod: a mutable StartMethod slot is checked each frame, pauses gameplay, disables world parents and dispatches by mode. Request mode/save index clear on normal return. StartMethods includes new character, native/classic save load, menu/death return and worldless startup. Mode-specific validation happens after common parent disabling. Exceptions can bypass normal field cleanup. Modes set LastStartMethod individually; native load dispatch may start asynchronous work rather than complete restoration on return.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per repository overview. Source remains unchanged. These static observations do not approve the original request model or every entry mode.

## Detailed operation rules

The coordinator owns admission, operation identity, conflict rejection, phase tracking and terminal results. Mode handlers own their mode-specific validation and initialization. Supported routes may include new character, native/classic load, voluntary/death menu return and worldless entry, but individual mode behavior is not approved by this routing contract. Unsupported modes/payloads fail validation without destructive changes.

A request binds its mode and stable selected input together. Resolve a save by stable identity rather than a mutable UI row/index. Capture a character draft so later edits do not mutate the submitted intent. Maintain enough operation provenance to prevent repeated execution and reject stale callbacks. This does not require cross-process durable request receipts or define a public ID format.

Permit one active session-changing operation. Same-identity redelivery observes the original operation/result without rerunning it; distinct arrivals receive a clear busy result and are not queued. Reject attempts to reinterpret an existing identity as another mode/payload. Intentional retry is a fresh request identity with original intent and fresh validation.

Before destructive replacement, validate mode/payload, required services and available input. Suspend simulation/gameplay input while validating, retaining the current session and responsive UI. For native loads, complete mandatory preflight before any applicable discard prompt and follow SAVE-005 for mod policy and recovery disclosure. Obtain explicit consent before discarding a living active session where the prompt applies. Do not autosave. Preflight failure, cancellation or declined confirmation leaves the session intact and releases only this operation's suspension.

SAVE prepares consistent validated input; the coordinator must not destroy the current session and then discover that it only validated a different unchecked save generation. Preparation failure on changed/missing input leaves the session intact. A retry may revalidate the same selected identity's currently available data, but cannot substitute another save or character. Input validity does not guarantee all later initialization will succeed.

At the destructive boundary, disable cancellation and explain that completion or recovery is required. Coordinate CORE-005 teardown and scope initialization. Track replacement/initialization until the owning handler actually completes required restore and readiness checks. Returning from an asynchronous start call is not terminal success. This feature does not define a load restore order, initial world placement, opening quest sequence or death reset policy.

Each admitted operation reaches exactly one Succeeded, Failed or Cancelled terminal outcome when its work completes, fails or is canceled safely. Publish success only after actual required completion. All terminal paths clear the operation's busy state and release its own suspension as safe; this does not clear independent cleanup/readiness gates or resume unsafe gameplay. If cleanup remains unsafe, retain CORE-005's block on new sessions and Retry Cleanup/Quit UI even after a Failed result.

After replacement failure, clean incomplete state safely. Once safe, independent error UI offers Retry, Return to Main Menu and Quit under CORE-005. Retry reconstructs from the original intent with a new identity and fresh validation, not a halfway checkpoint. If safe cleanup cannot complete, offer Retry Cleanup/Quit instead. A preflight error is not a replacement failure: preserve the running session rather than tearing it down for recovery. Full rollback of an already-replaced session is not promised.

## Relevant formulas and parameters

No gameplay formulas or balance parameters apply. At most one active session-changing operation is admitted. Terminal outcomes are Succeeded, Failed and Cancelled; phase labels distinguish validation, replacement and initialization. Progress reports phase rather than guessed percentage. There is no generic elapsed-time failure threshold. Specific handler timeouts require an owner-defined failure condition.

## Required data

Request identity, mode, stable payload/selection, origin, current phase, cancellation eligibility, consent state, prepared input/version context, operation-owned suspension, result/error and cleanup safety. Retain sufficient completed-request identity/result information to suppress redelivery within the supported request lifetime; exact memory bounds/retention mechanism are implementation details that must preserve non-reexecution. No persistent cross-launch retry ledger is approved here.

## Inputs, outputs and events

Inputs: session-changing submissions from menu, quickload or authorized systems; validation/preparation results; consent/cancel; teardown/initialization callbacks; errors and retry/menu/quit choices. Outputs: admission/busy/invalid-request results, phase updates, cancellation availability, one terminal outcome per admitted operation and appropriate recovery UI. Busy rejection does not become a new active operation. API/signal names are deferred.

Observers must distinguish admitted, started and completed. Completion callbacks carry enough originating context to reject stale work and cannot emit a second terminal result. Diagnostics are subject to CORE-002 privacy rules; request payloads/save contents must not be dumped into logs.

## Cross-system interactions

CORE-004 owns application startup and main-menu routing. CORE-005 provides scope readiness, teardown and safe failure handling. CORE-006 supplies effective preferences without activating pending restart changes prematurely. SAVE owns decoding, prepared input consistency, format compatibility and restore semantics. CHAR supplies stable character draft data; LOC/WORLD and other owners initialize their own state. CORE-008–014 define the mode-specific behaviors. UI owns confirmation/progress/error presentation and remains usable while gameplay is suspended. Storage/settings/logging rules remain CORE-001–003 responsibilities.

## Edge cases and failure conditions

- Two distinct submissions arriving together cannot both replace the session. Same-identity redelivery cannot execute twice, including after terminal completion within the supported request lifetime.
- A captured selection is not a mutable list row; later sorting, slot selection or character editing cannot redirect the operation.
- Missing/invalid payload, unavailable selected input or unsupported route fails preflight before teardown. A changed save during preparation must not yield an unchecked mixed-generation restore.
- User decline/preflight cancellation leaves gameplay state intact; menus/other suspension owners may still prevent resume.
- Cancellation racing with destructive replacement must resolve unambiguously: if cancellation is accepted, destruction has not begun; otherwise cancellation is unavailable and the operation completes or recovers.
- Late asynchronous completions cannot mutate a new session or overwrite an already published outcome. Cleanup failure is distinct from busy state and continues to block new sessions.
- Exceptions or early exits must produce a failed outcome and safe state rather than leave an operation permanently busy. A still-running operation is not failed merely because it is slow.
- Once replacement begins, preflight success is not a rollback guarantee. Follow cleanup/menu recovery rather than announcing completion or silently loading a different source.
- Death/critical system transitions arriving while busy are not secretly queued or given implicit preemption. Their owning feature must define how to reconcile the resulting busy outcome safely; this feature does not approve such exceptions.

No numerical balance effects apply. Main risks are loss of unsaved progress without consent, mixed-save inputs, double execution and partially initialized gameplay escaping its gates.

## Configuration and balancing options

Single-operation admission, preflight preservation, cancellation boundary and truthful outcomes are fixed policies. Live-session discard confirmation is the default, with validated native-load prompt controls under SAVE-005. Detailed mode options remain feature-owned.

## Save/load considerations

Requests and progress are transient coordinator state, not character-save data. SAVE may provide prepared immutable input or another validated consistency mechanism; this document selects no storage schema. Loading must not change writable roots or the active ARENA2 source. Quickload uses the same coordination/confirmation rules. Intentional retry must validate input again and not reuse partially restored gameplay state. No resume-after-process-crash transaction journal is promised.

## Technical constraints

Project target: Godot 4.7.2. Use one logical coordination authority without requiring a particular singleton/autoload/framework. Capture request data together; do not rely on independently mutable request/save fields. Integrate actual asynchronous handler completion and guaranteed terminal cleanup. Maintain responsive UI, scope-safe callbacks and independently owned gameplay gating. Exact APIs, request ID representation, prepared-data ownership and deduplication storage are deferred implementation details.

## Acceptance criteria

1. Menu and quickload session-changing operations use the same coordinator with stable mode/payload/identity; unsupported routes fail without mutation.
2. Only one operation is active. Distinct competing submissions reject as busy without replacing/queueing. Repeated same-identity delivery does not rerun an active or completed request within its supported lifetime.
3. Preflight suspends simulation/gameplay input while keeping progress/error UI responsive and retaining the existing session. Failed/canceled preflight releases only its own suspension.
4. Discarding a living active session requires explicit confirmation by default. Native loads complete preflight first and honor validated SAVE-005 prompt controls. Declining preserves the session. Mode-specific ended-session exceptions require their own approval. No automatic save occurs.
5. Validation and consistent input preparation precede destructive teardown. Changed/missing save data before preparation completes fails safely; unchecked different generations are not restored.
6. Captured character/save selections do not change when UI edits/selections change after submission.
7. Cancellation is accepted only before destructive replacement; afterward UI explains unavailability and completion/recovery continues.
8. Each admitted operation produces exactly one Succeeded/Failed/Cancelled outcome. Success follows actual required restoration/readiness rather than asynchronous initiation. Exceptions/early exits clear busy state without releasing unsafe cleanup gates.
9. Replacement failure safely cleans partial state before retry/menu recovery. Unsafe cleanup permits Retry Cleanup/Quit and blocks new sessions. No full old-session rollback is claimed.
10. Retry uses a new identity and freshly validates original intent; it neither resumes partial initialization nor substitutes a different save/character. Stale callbacks cannot affect the new operation/session.
11. Progress shows actual phase with no invented percentages or generic time-limit failure. Specific supported errors/timeouts are reported by their owner.
12. Storage/settings/logging, source-restart and preference/lifetime contracts remain intact. Terminal readiness does not override another owner's suspension.

These are future verification criteria. No implementation or runtime tests have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001 through CORE-006 v1, the decision log, CORE catalog and CORE architecture review. All 12 interview decisions are represented. No conflict identified: CORE-005 cleanup safety remains separate from clearing operation busy state, and readiness does not bypass suspension. Preflight preserves old state; post-replacement recovery makes no rollback promise. CORE-008–014 and broader architecture proposals remain open beyond accepted dispatch constraints.

## Outstanding questions and approval

No further blocking dispatch-policy choice is currently identified. SAVE must define consistent preparation/read semantics. Mode owners must define detailed validation, ended-session confirmation exceptions, death/critical-request behavior under busy rejection, initialization and safe recovery. Request ID/retention design, APIs, progress labels and cancellation synchronization are implementation details subject to these criteria. No optional entry mode is approved solely by naming its route.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-007. This document is finalized v1. Approval reference: CORE-007-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented deferrals remain deferred. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
