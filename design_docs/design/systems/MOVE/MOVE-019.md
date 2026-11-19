# MOVE-019 — Interaction modes and information

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Let players deliberately select Grab, Talk, Info or Steal, understand the selected mode and inspect permitted information without accidentally executing dialogue, theft or mechanisms. Target-specific mappings remain explicit and moddable.

## Confirmed requirements

MOVE-019-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. Rules below consolidate those choices. MOVE-001/002 input/bindings, MOVE-003 targeting view and MOVE-018 dispatch/communication remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths below are relative to reference `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/PlayerActivate.cs` initializes Grab; `ChangeInteractionMode` changes mode with optional text. `NextInteractionMode`/`PreviousInteractionMode` cycle Steal/Grab/Info/Talk and reverse.
- `ActivateBuilding` in Info discovers building identity and can show opening-status information. `ActivateStaticNPC` routes Info to `PresentNPCInfo`, while other modes may share NPC click behavior.
- `ActivateMobileNPC` can route Info/Grab/Talk to dialogue; Steal attempts pickpocketing. `ActivateMobileEnemy` exposes descriptions in several modes and a separate Steal branch. Non-person quest clicks are suppressed in Info in `Update`.

These observations show Info is not universally read-only in DFU. Target behavior below deliberately makes information activation safe from implicit non-information actions without promising every source target mapping is retained.

## Detailed rules and behaviors

### Selection, cycling and communication

Retain four modes: Grab, Talk, Info and Steal. Provide rebindable direct selections and forward/backward cycle actions under MOVE-002. Fresh characters start Grab. Forward order is Steal→Grab→Info→Talk→Steal; reverse order is opposite. One fresh press changes mode once; selecting the current mode is a no-op with no repeated notification.

Actual changes use concise mode notification and existing HUD mode indication without adding proactive target highlights. Information/mode presentation is moddable and follows localization/accessibility and HUD ownership rules. Mode indication must not override an approved HUD-hide request. Exact visual assets/wording remain UI scope.

### Mode-to-target meaning

Each supported target declares explicit validated mode mappings. Grab/Talk may intentionally share dialogue for NPCs. Steal cannot silently fall back to another criminal action; Info always remains informational. Unsupported mappings return appropriate effect-free/blocked outcomes under MOVE-018 rather than searching for unrelated actions.

LAW, NPC, ITEM, QUEST and later MOVE interaction features own theft, access and action consequences. This specification does not authorize pickpocketing every actor or invent a new criminal fallback. Validated mod mappings cannot silently bypass Info safety or dispatch consumption; intentional changes to those semantics need explicit supported contracts/design review.

Capture mode when activation is released, alongside release-time target/action context. Deferred prompts retain that intended action; subsequent mode selection cannot reinterpret confirmation as theft or another action. Revalidate under MOVE-018; invalid context cancels with explanation without retargeting or repeated effects.

### Info and discovery

Explicit Info activation may reveal permitted target descriptions and record specifically approved discoveries such as building identity. It cannot implicitly talk, steal, open containers, operate mechanisms or advance activation-triggered quests. Unsupported targets remain harmless.

Hovering, selection and previews record no discoveries, run no quest scripts and consume no randomness. An actual Info discovery is distinct from a pure preview. Discovery notifications cannot trigger a quest's ordinary activation/click reaction; QUEST must explicitly define any discovery-based progression and its once-only semantics.

Descriptions cannot expose hidden inventory, undiscovered quest facts or private identity. Target owners define what is visible/known, including names versus generic descriptions. This is an explicit permission boundary, not a guarantee that every visible actor's full name is public.

### Inspection reach

Visible building/NPC/enemy descriptions may be available beyond ordinary interaction distance. Use an explicit moddable inspection-distance policy and solid-obstruction checks; no through-wall information or universal unlimited inspection. Exact vanilla distance and per-target permissions must be specified before implementation is complete.

This resolves MOVE-018's Info-reach deferral: dispatch uses authorized Info reach rather than ordinary category action reach, while preserving obstruction, input and handler rules. Long-distance Info cannot authorize physical interaction or extend a later deferred theft/dialogue action's reach. Discovery availability beyond ordinary reach requires explicit target policy, not automatic inference from description permission.

### Presentation and failure

Present concise localized information after explicit Info activation, without automatic stat panels or hidden-data tooltips. Missing optional description uses declared generic text or silence. Missing required identity data invokes owner recovery, not an invented name or unrelated target description. Presentation failure cannot trigger a different primary action or replay discovery.

No generic proactive targeting layer is introduced. Existing interaction-specific attempted responses remain MOVE-018 policy. Modded descriptions/mode feedback use validated definitions and preserve semantic placeholders/identity under DATA contracts.

### Menus, pause and restoration

Ordinary menus preserve selected mode. Native saves restore it, including Steal, with its eligible HUD indication. Loading/menu close does not itself activate anything; MOVE-001 fresh-input and cancellation rules remain authoritative.

Fresh characters start Grab independently of prior sessions. Readiness and UI ownership still gate mode input/activation. Stored mode is not a persisted raw action edge. Exact simultaneous direct-selection/cycle precedence requires deterministic input handling rather than callback order.

## Relevant formulas and parameters

Four-mode cycle and fresh-character Grab default are fixed confirmed behavior. Inspection distance is finite/validated under an explicit owner policy; exact numeric default remains open. Ordinary action distances remain MOVE-018 and their owners. No detection, theft or discovery probability is selected here.

## Required data

Stable selected mode, supported cycle/direct bindings, target mode mapping, inspection policy/obstruction, permitted description/discovery identity, prior discovery status, captured deferred action/mode and localization/optional fallback policy. Versioned mode serialization and exact schemas remain implementation dependencies.

## Inputs, outputs and events

Inputs: eligible selection/cycle, explicit Info activation, target permission/visibility/context, mode-captured deferred operation and native restore. Outputs: committed mode/notification, permitted description, explicit once-only discovery or checked no-op/failure. API names remain unselected. Mode selection alone is not an interaction/discovery event.

## Cross-system interactions

MOVE-001–003 input/view, MOVE-018 targeting/consumption, MOVE-020–025 target actions; UI mode/Info presentation; NPC/LOC descriptions/identity; QUEST explicit discovery contracts; LAW/ITEM criminal/access consequences; DATA localization/definitions; CORE HUD/input/readiness and SAVE selected mode/discovery persistence. MOD supports validated mappings/communication without incidental handler order.

## Edge cases and failure conditions

Test repeated current-mode selection, multiple selection inputs, mode changes during prompts and saved Steal restoration. Info over a mechanism/loot/NPC cannot invoke its ordinary action as a fallback. Longer inspection cannot reveal hidden facts or cross solid blockers. Discovery duplicate delivery/reconstruction cannot repeat progression. Missing optional text cannot corrupt required identity; required failure cannot silently become dialogue or theft.

## Configuration and balancing options

Support validated target mappings, inspection-distance/permission policies and information/mode presentation. Four modes and safe Info semantics are vanilla requirements. No new stat panel, proactive hover information, broad criminal fallback or automatic remapping is introduced. Exact provider precedence remains MOD/MOVE-018 integration.

## Save/load considerations

Persist selected mode and target-owner discoveries as authoritative character state, with valid enum/identity handling. Restore without input/action replay; HUD indication obeys readiness/visibility. Supported pending prompts retain original action/mode and revalidate under MOVE-018/SAVE. Unknown required saved mode/identity needs explicit migration/recovery, not silent reinterpretation into Steal or another action.

## Technical constraints

Target: Godot 4.7.2. Keep selected mode, pure information query, permitted discovery mutation and primary domain action separate. Use stable target/mode identity, checked permissions and scope-safe deferred operations. Concrete signals, mappings, query precision and UI layout require fixtures. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Four direct modes and forward/reverse cycle work once per press in approved order; fresh characters start Grab.
2. Current-mode selection is a no-op; actual changes show eligible concise/HUD feedback without target highlights.
3. Target mappings are explicit; shared Grab/Talk dialogue is intentional and Steal cannot silently become another crime.
4. Info never implicitly talks, steals, opens/operates or triggers ordinary quest activation; unsupported targets stay harmless.
5. Only explicit permitted Info can record discovery; preview/hover/selection cannot mutate or roll.
6. Long-range inspection obeys explicit distance/visibility permissions and cannot grant action reach or hidden identity/inventory facts.
7. Deferred actions retain release-time mode and cannot be reinterpreted after mode changes.
8. Localized optional descriptions use declared fallback/silence; required identity failure uses recovery without alternate actions.
9. Menus/native saves preserve mode including Steal without automatic activation or prior-session input; fresh sessions remain separate.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-001/002/003/018 and relevant CORE context/HUD/restoration rules. No direct contradiction identified. Explicit Info discovery is a declared mutation distinct from prohibited preview mutation. Longer inspection resolves an open reach policy without extending physical actions. Mode notification is selected-state feedback, not default target highlighting. Saved Steal is intentional and protected by fresh input and deferred-action identity.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: per-target mapping/description/discovery inventory, vanilla inspection distances, disclosure permissions, quest discovery semantics, deterministic simultaneous selection, communication assets, mod ordering and native/mode/prompt verification. These do not waive safe Info or original-action confirmation.

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under MOVE-019-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented mapping, inspection, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
