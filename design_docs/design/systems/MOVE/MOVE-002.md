# MOVE-002 — Binding profiles

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose and intended player experience

Let players customize keyboard/mouse and controller controls without losing existing assignments unexpectedly or becoming unable to recover controls. Changes are reviewable before application, shared across characters and retained across restarts and supported updates.

## Confirmed requirements

MOVE-002-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews, each confirmed with three “Yes” answers. The rules below consolidate those requirements. Approved MOVE-001 input semantics, CORE-003 settings recovery, CORE-006 preference application and CORE-016 context ownership remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; no runtime verification or source modifications.

- `Game/InputManager.cs#SetBinding` maintains primary/secondary dictionaries. It removes the same input from the other dictionary, clears the selected action slot and can replace another action assigned to that input.
- `GetComboCode` encodes two keycodes; `GetUnaryKey` and modifier tracking resolve combination input. This encoding is a Unity implementation detail, not a target storage contract.
- `SetAxisBinding` and `SetJoystickUIBinding` maintain separate axis/UI mappings, each with a single assignment per action in the inspected setters. Axis inversion has its own dictionary.
- `SaveKeyBinds` serializes bindings, inversions and deliberate removals separately from character state, preserves some unknown action entries and refreshes caches/notifies listeners. `LoadKeyBinds` restores these collections and tracks deliberately removed actions.

These observations do not approve DFU conflict replacement, persistence mechanics or every default binding.

## Detailed rules and behaviors

### Configuration and slots

Use one application-wide custom configuration shared across characters. Multiple named profiles and import/export are outside initial scope. Each discrete gameplay action has two keyboard/mouse slots and two controller-button slots. Assigning a controller input cannot displace a keyboard/mouse assignment. Analog movement/look have separate axis assignments; exact supported axis inventory and defaults remain owner dependencies.

Keyboard/mouse bindings support single inputs and one modifier plus a key or mouse button. Initial controller bindings use single buttons, not controller button combinations. Exact modifier inventory and supported mouse-button/wheel/trigger representations require a declared support inventory; this specification does not promise every device input type.

Store gameplay keyboard bindings by physical position and display the current keyboard layout's labels. Layout changes do not relocate gameplay bindings to preserve a typed letter. Text entry retains normal active-layout behavior.

### Conflicts, clearing and defaults

When an assignment conflicts with another action in the same active context, show the conflict and offer Replace or Cancel. Replacement must be explicit and reflected in the staged configuration; no silent reassignment. Mutually exclusive contexts can reuse input. Context overlap must be declared rather than inferred from incidental UI order.

Allow deliberate unbound gameplay actions, warn clearly and preserve their unbound state across restarts. Distinguish intentional clearing from a new or missing setting. Reset this action and Reset all controls are staged edits, not immediate changes to effective controls. Their resulting assignments still require complete validation before Apply; defaults cannot silently steal custom assignments.

Controller UI actions such as Confirm and Back are reassignable separately from gameplay actions. Validate conflicts within their UI context. Exact UI slot counts and action inventory remain UI integration dependencies; gameplay's two-plus-two slot rule does not silently define every UI action.

### Modifier precedence

An eligible modifier combination takes precedence over the same plain key binding. Shift+E triggers the combination alone when that combination is used. Releasing Shift while still holding E cannot start plain E; the main key must release before either can start again. Modifier changes cannot manufacture a second discrete start from that press. Late modifier presses and interruption of an already-started plain-key activity need explicit tested transition semantics consistent with MOVE-001; they cannot replay effects or synthesize release-triggered actions.

### Capture and recovery

Capture waits for the input opening it to release before accepting a new assignment. Escape or controller Back cancels capture; cancellation does not clear the slot. A separate Clear binding command deliberately unbinds it. Mouse motion and stick drift cannot be captured as button bindings. Axis assignment uses a distinct validated operation rather than accidental button capture.

Reserve keyboard Escape and controller Menu/Start for menu access and control recovery; neither can be assigned to gameplay actions. During capture, Escape/controller Back cancels, while Menu/Start exits capture to the controls screen. Show reserved inputs in the controls screen. Editable UI bindings cannot remove the independent recovery route. Exact device-specific Menu/Start identifiers and recovery access while UI bindings are incomplete must be verified.

### Apply, Cancel and runtime safety

Stage edits until Apply. Cancel discards pending edits and leaves effective bindings intact. Apply validates the complete candidate configuration and activates it together, so consumers cannot observe a partially replaced binding map. Rejected validation leaves the previous effective map available and explains the problem.

Assignment, confirmation and Apply input cannot fall through into gameplay. Honor MOVE-001 cancellation/fresh-press rules and CORE-016 context ownership; held inputs cannot become newly started discrete actions merely because bindings changed. Controller reconnect/disconnect remains MOVE-001 scope.

Apply and persistence outcomes remain distinct. Runtime save failure retains applied controls in memory, visibly identifies unsaved changes and permits retry under CORE-003/006. Do not claim saved success prematurely. Recreated consumers receive effective bindings under CORE-006 rather than stale cached assignments.

### Updates and recovery

Preserve existing valid assignments and deliberate unbound choices across supported upgrades. For a genuinely new action, install its default only if conflict-free; otherwise leave it unbound and show one notice identifying it. Never take an existing assignment to make room for a new default.

CORE-003 governs defaults validation, explicit migrations, unknown-key preservation without application, invalid-setting/group recovery, backup/recovery copies and safe publication. Unsupported formats require its explicit recovery choices. Binding semantics must participate in compatible-group validation rather than blindly replacing unrelated valid controls. The new-action conflict notice supplements ordinary quiet additions; it does not authorize warnings for every harmless added default.

## Relevant formulas and parameters

Per discrete gameplay action: two keyboard/mouse slots plus two controller-button slots. Keyboard/mouse combinations have one modifier plus one main input; controller combinations are excluded initially. No gameplay balance formula applies.

Separate movement/look deadzone adjustment is already approved under MOVE-001. Exact deadzone defaults/curves, axis assignments/inversion exposure and camera tuning remain MOVE-002/003 integration dependencies. No numeric defaults, repeat cadence, input-buffer duration or controller-button threshold is chosen here.

## Required data

Stable action/context identities; device family and physical key/button/axis identifiers; binding slots and optional modifier; declared context overlap/conflict rules; reserved recovery inputs; packaged defaults; intentional-unbound markers; format version/migrations; staged, effective and persisted configurations; validation and unsaved/recovery status. Layout labels are presentation, not binding identity. Exact storage schema/file placement must conform to CORE settings decisions; DFU JSON is not adopted implicitly.

## Inputs, outputs and events

Inputs: start/cancel capture, eligible assignment, clear/reset, Apply/Cancel, keyboard-layout changes, startup load, version migration and persistence retry. Outputs: staged preview, conflict choices/warnings, complete effective binding configuration, refreshed display labels, truthful persistence results and new-action notices. API/signal names remain unselected. Binding edits do not execute the assigned gameplay action.

## Cross-system interactions

MOVE-001 owns logical aggregation, once-only taps, cancellation, device arbitration and disconnect suspension. MOVE-003 owns final view/cursor behavior. CORE-003/006 own storage recovery and effective/requested preference application; CORE-005 owns consumer lifetimes. CORE-016/UI own active contexts, text input, capture routing and reserved recovery. DATA/MOD action additions require stable identities, declared contexts and validated defaults under their eventual contracts; this feature does not approve an unrestricted action-registration framework.

## Edge cases and failure conditions

Handle reassignment that leaves another action unbound visibly; conflict Cancel leaves the candidate assignment unchanged. A modifier combination must not invoke its plain-key action as well or on modifier release. Capture must not bind its opening click, mouse motion or stick noise. Unsupported inputs are not silently stored as usable bindings.

Resetting one action may conflict with customized bindings and must use explicit resolution/validation. UI remapping cannot strand the player without menu/recovery access. Keyboard layout changes update labels without moving controls or interfering with text composition. Missing controller hardware does not turn retained mappings into deliberate removals.

Interrupted application cannot expose mixed maps. Persistence failure cannot silently restore old effective controls or report success. A new action cannot overwrite an existing binding, and explicit unbinding cannot be mistaken for an upgrade omission. Required malformed configuration follows CORE recovery, not ad hoc invented defaults.

## Configuration and balancing options

Supported options are per-slot reassignment/clearing, controller UI reassignment, analog axis assignments, staged per-action/all reset and the inherited separate deadzones. Supported inversion/axis response inventory and concrete packaged layouts remain to be specified and tested. Multiple named profiles, import/export and controller combinations are outside initial scope. No change to movement/combat balance is introduced.

## Save/load considerations

Bindings are application preferences shared across characters, not character-save state. Loading another character cannot replace them or restore pending capture inputs. Staged editor state is not approved durable character state. CORE-003 versioned persistence preserves valid choices and deliberate unbound markers; MOVE-001 prevents physical holds/queued presses replaying after load. Exact application settings representation remains a technical dependency.

## Technical constraints

Target: Godot 4.7.2. Use stable physical identifiers independently of localized labels. Keep staged/effective/persisted state distinct, validate complete maps, refresh scoped consumers coherently and retain independent recovery input. Concrete engine APIs, profile schema and input-context conflict representation are implementation choices to verify. The MOVE architecture proposals remain Proposed beyond individually approved contracts. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Each discrete gameplay action exposes two keyboard/mouse and two controller-button slots; controller changes preserve keyboard bindings and vice versa.
2. Keyboard modifier-plus-key/mouse bindings work; controller button combinations are outside supported initial scope.
3. Same-context conflicts offer explicit Replace/Cancel; mutually exclusive contexts can reuse an input. No silent binding theft occurs.
4. Deliberately unbound gameplay actions are visibly identified and remain unbound across restart/update.
5. Capture ignores its opening input until release, excludes mouse motion/stick drift as buttons, cancels without clearing, and supports explicit Clear.
6. Escape/Menu/Start recovery remains usable despite gameplay/UI edits; reserved inputs cannot be assigned to gameplay.
7. Modifier combinations suppress the plain-key action, including after modifier release while the main key stays down; no second start is manufactured.
8. Changing keyboard layout preserves physical gameplay positions, updates displayed labels and leaves text entry layout-correct.
9. Cancel preserves effective controls. Apply validates/publishes the complete candidate without partial maps or assignment-input fall-through.
10. Runtime persistence failure leaves applied controls usable, shows unsaved status and offers retry without claiming saved success.
11. Per-action/all reset are staged and cannot silently steal conflicting custom assignments. All characters share the applied configuration.
12. Updates preserve existing assignments/intentional clearing; conflicting new defaults leave the new action unbound with one identifying notice. Supported settings recovery follows CORE-003.

These are future verification criteria; no runtime tests or game implementation have been performed.

## Consistency review

Reviewed against MOVE-001, CORE-003/006/016, the MOVE feature catalog/architecture review and all twelve interview decisions. No direct contradiction identified. Reserved recovery inputs qualify editable controls explicitly. Modifier precedence is intentional action selection, not permission to duplicate logical starts. Settings persistence failure remains separate from runtime application, and application-wide configuration does not overwrite character state. Unknown/new action handling preserves CORE settings rules while adding the approved conflict notice.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Before implementation is complete, resolve: exact action/default/UI inventories and UI slot counts; modifier-key inventory and late-modifier transitions; supported mouse/wheel/trigger and controller mappings; axis assignment/inversion and deadzone curves/defaults; context-overlap/conflict validation, including resets; stable schemas/migrations and physical-layout labels; coherent publication/recovery and rendered/controller verification. These dependencies do not waive independent recovery, explicit conflict handling or fresh-input safety.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under MOVE-002-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
