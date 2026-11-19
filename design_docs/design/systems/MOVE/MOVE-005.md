# MOVE-005 — Walk, run and sneak speed

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose and intended player experience

Resolve ordinary on-foot gait and speed from character capabilities, player requests and valid restrictions. Preserve fine analog control, predictable gait selection and familiar DFU-derived pacing, while allowing supported mods to add encumbrance consequences or sprint-resource restrictions.

## Confirmed requirements

MOVE-005-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews and the user's explicit vanilla/modding clarifications. Rules below consolidate confirmed requirements. Approved MOVE-001–004, CHAR-020 and CORE settings/suspension remain binding. No recommendation awaiting selection is treated as a confirmed numerical default.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source remains unchanged.

- `Game/Player/PlayerSpeedChanger.cs#GetWalkSpeed` derives walk speed from live Speed with a low-Speed drag term. `GetRunSpeed` uses Speed, Running skill and posture; `GetBaseSpeed` selects walking, crouching or transport bases.
- `CaptureInputSpeedAdjustment` supports Hold/Toggle gait requests and autorun; its autorun path changes ToggleRun. `ApplyInputSpeedAdjustment` prioritizes running, clears sneak, retains gait while airborne and maximizes controller movement when running.
- `RefreshWalkSpeed`/`RefreshRunSpeed` multiply source-added positive factors. `AddWalkSpeedMod`, `AddRunSpeedMod`, `RemoveSpeedMod` and `ResetSpeed` manage contributions/caches. Source crouch paths do not uniformly traverse ordinary walk modifiers.
- `Game/Player/FrictionMotor.cs#GroundedMovement` constructs motion from axes and optionally applies 0.7071 when both axes are nonzero. `PlayerMotor.UpdateSpeed` applies swimming adjustment separately.

Target behavior below deliberately retains proportional running input and does not let autorun rewrite Hold/Toggle preferences. The user's vanilla encumbrance policy is a target requirement, not a claim that all DFU encumbrance behavior was established by this inspection.

## Detailed rules and behaviors

### Gaits and requests

Support Walk, Run and Sneak as ordinary on-foot gaits. Run and Sneak each have independently selectable Hold or Toggle controls. When both are requested, Run wins and clears the Sneak request. A cleared Hold Sneak request can only resume according to eligible held-input evaluation after Run ends, not by replaying a discrete toggle. Exact input evaluation must preserve MOVE-001 once-only edges.

Sneak is independent of crouching: it slows movement but does not automatically lower posture, guarantee concealment or directly award Stealth practice. NPC/CHAR own detection and practice. MOVE-006 owns actual crouch/clearance; use crouched formulas only while actually crouched outside swimming.

Equal base forward/backward/sideways speed applies. Cap resolved voluntary direction-vector magnitude to prevent diagonal advantage, retaining submaximal analog magnitude. Controller movement remains proportional while running; do not snap it to full strength. This cap does not limit passive platform or external motion under MOVE-004.

### Baseline formulas and modifier order

Let S be live Speed, R live Running, and k=39.5 the reference conversion divisor. Accepted initial moddable baselines:

| Actual posture | Walk | Run | Sneak |
| --- | --- | --- | --- |
| Standing, ordinary on foot | (S+150-0.5×(100-max(S,30)))/k | ((S+150)/k)×(1.35+R/200) | standing Walk/2-1/k |
| Crouched, not swimming | (S+50)/k | ((S+50)/k)×(1.35+R/200) | crouched Walk/2-1/k |

Sneak's formula uses its unmodified posture-specific Walk baseline, then its own Sneak modifiers; it does not inherit Walk multipliers again. Each gait has separate source-owned finite positive multipliers. Apply each source once against that gait's baseline, then enforce the configured maximum on the resolved ordinary gait speed. Removing a source removes only its contribution. Applicable changes take effect at the next eligible movement step.

Retain baseline relationships and verify actual traversal against selected Godot world scale; copying divisor 39.5 alone cannot establish matching physical pace. Exact engine-unit conversion is a measured implementation dependency.

Validate supported stat/formula domains and enforce a finite positive configurable maximum speed. The cap bounds otherwise valid stacking, not malformed configuration. Invalid/nonfinite/negative formula results cannot silently become backwards movement, substitute defaults or collision bypass. Exact supported ranges, cap and overflow-safe arithmetic require validation/testing before implementation is complete. Immobilization is an explicit restriction rather than a zero multiplier.

### Airborne behavior and restrictions

Retain the gait selected at takeoff until landing. Requests may change in air, but the new gait applies on landing and cannot instantly change airborne speed. Air steering and airborne response to changed stats/modifiers belong to MOVE-009; next-step modifier recomputation cannot bypass its velocity rules. Immediate restrictions and explicit movement-mode transitions still take effect under MOVE-004.

Gait request, eligibility and actual resolved movement are distinct. Rejected running cannot count as moving Running for fatigue/practice. Exact fallback while a restriction disallows Run must be declared by the responsible rule; do not infer that every restriction stops all physical motion. Paralysis, gravity and passive carriage retain MOVE-004 semantics.

### Autorun and interruptions

Provide a rebindable Autorun toggle supplying continuous forward intent and a Run request. Backward input or another Autorun press cancels it. Menus, focus loss, loading and controller-disconnection recovery also cancel it; deliberate reactivation is required. Autorun never changes saved Hold/Toggle preferences. It is a synthetic intent source subject to gait eligibility, collisions and MOVE-004, not an exception that moves through obstacles.

Ordinary menus preserve toggled Run/Sneak selections. Hold controls resume from current eligible physical input, while autorun remains cancelled. CORE pause preserves physical motion history and creates no elapsed catch-up. Native loading clears Run/Sneak toggles and autorun, beginning with Walk selection; airborne restoration and required pose/motion preservation remain SAVE/MOVE-009 contracts rather than permission to rewrite saved velocity. Hold input resumes only under MOVE-001 eligibility/fresh-input rules. Preferences remain application settings.

### Encumbrance and sprint extension contracts

Vanilla encumbrance has no movement penalty: it restricts adding further weighted items to inventory. ITEM owns capacity, admission thresholds and exact handling of transfers, weightless items, capacity changes and already-overweight inventories. No item deletion or automatic movement slowdown is inferred here.

Support mod-defined encumbrance movement consequences through explicit source-owned speed contributions and/or restrictions. Also support optional mod-defined sprint eligibility/resource restrictions, including a sprint meter or other sprint rule. These are supported extension capabilities, disabled in vanilla; no meter size, drain/recharge rate, UI, exhaustion fallback or mod-specific save behavior is selected now.

Vanilla Running uses CHAR-020 fatigue costs and actual-moving practice. No additional sprint meter, fixed sprint duration or automatic fatigue-based speed penalty is introduced. CHAR owns exhaustion/action restrictions. Mods cannot bypass authoritative movement gates, duplicate ordinary fatigue/practice, or treat passive carriage/held Run as qualifying running. Restriction results and state/resource mutations need explicit owner contracts; arbitrary callbacks with unspecified stacking are not approved by this capability request. RULE-004 provider validation, provenance and failure handling remain binding wherever formula replacements are exposed.

## Required data

Live S/R and supported domains; actual posture and mode; Run/Sneak request/selection/eligibility; independent Hold/Toggle preferences; takeoff gait; autorun state; resolved analog direction/magnitude; baseline definitions and scale mapping; source-owned gait multipliers; validated maximum; external encumbrance/sprint restrictions and provenance; actual activity output. Optional mod resources need declared owner/schema, not hidden gait-local meters.

## Inputs, outputs and events

Inputs: eligible gait/direction/autorun actions, live stats/skills, actual posture, takeoff/landing, source contribution changes, restriction results and context/load invalidation. Outputs: resolved requested/eligible gait, bounded target speed and direction intent for MOVE-004, activity context and truthful restriction explanations. API/signal names remain unselected. Setting a speed or requesting Run does not itself charge fatigue or award practice.

## Cross-system interactions

MOVE-001/002 own input edges, bindings and preferences; MOVE-004 owns mode/physical authority and voluntary/passive distinction. MOVE-006/009 own posture and air behavior; swimming, levitation and transport remain MOVE-013–016 scope. CHAR-011 resolves live attributes, CHAR-020 applies fatigue/practice, and CHAR owns exhaustion. ITEM owns admission/encumbrance; MOD/RULE/DATA own validated extensions, definitions and provider contracts. UI exposes gait settings/restrictions; CORE gates application/suspension, SAVE reconstructs state without replaying activity.

## Edge cases and failure conditions

Diagonal and combined devices cannot increase ordinary speed. Tiny analog movement retains fine control; exact actual-moving thresholds remain CHAR/MOVE integration. Crouch denial uses actual standing posture, not requested crouch formulas. Sneak modifiers apply once without hidden Walk stacking. Source removal cannot remove other effects, leave stale caches or multiply restored effects twice.

Toggle/autorun changes cannot duplicate from multiple physics deliveries. Midair requests wait for landing while immediate restrictions remain effective. Loading cannot revive autorun or erase saved fall state under cover of starting Walk. Invalid values require explicit approved recovery; the speed cap cannot conceal malformed formulas. Mod meter depletion cannot grant immunity to gravity or duplicate fatigue. Missing required mod state uses compatibility/recovery, not a silent vanilla fallback.

## Configuration and balancing options

Baseline constants/formulas, per-gait contributions and resolved maximum are moddable through validated supported contracts. Players independently choose Hold/Toggle Run/Sneak. Vanilla encumbrance causes no movement penalty and vanilla Running has no separate sprint resource. Mods may introduce the confirmed optional restrictions; exact hooks, combination precedence and resource tuning remain required owner dependencies. No default directional penalties or analog-running snap are introduced.

## Save/load considerations

Persist application Hold/Toggle preferences under CORE/MOVE settings rules. Native load resets Run/Sneak toggle requests and autorun, not authoritative saved velocity/fall facts. Rebuild effective speed from current validated stats/posture/effects; do not save transient modifier handles as durable authority. Restore source effects once under their owner identities. Optional mod sprint resources/restrictions require versioned SAVE contracts and compatibility checks; no universal serialization format is selected. No past movement costs/practice replay on reconstruction.

## Technical constraints

Target: Godot 4.7.2. Calculate gait target speed separately from authoritative collision movement, passive forces and actual activity measurement. Keep modifier lifetime/provenance explicit and validate finite arithmetic and world-scale/collision limits. No frame-count fatigue, uncoordinated motor movement or general scripting framework is approved. Concrete hook APIs, formula schemas, numeric limits and scale remain engineering decisions. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Standing/crouched baselines match the approved formulas for valid S/R fixtures; measured world-scale conversion preserves intended traversal pace.
2. Run/Sneak Hold/Toggle settings are independent. Run wins simultaneous requests and clears Sneak without duplicate toggle processing.
3. Sneak does not automatically crouch, grant concealment or award practice; actual posture determines the baseline.
4. Forward/back/sideways base speeds agree, diagonals provide no bonus, and submaximal controller running remains proportional.
5. Each gait applies its own source multipliers once; source removal affects only that source. Valid stacking is capped; malformed/nonfinite results follow recovery.
6. Airborne gait requests apply on landing without instant airborne speed switches; restrictions/mode transitions remain immediate under their owners.
7. Autorun supplies forward/Run intent and cancels on backward input, retoggle and specified interruptions without changing control preferences.
8. Menus preserve toggled gait selections, hold input resumes appropriately, and autorun stays cancelled. Native load resets selections to Walk without rewriting required saved physical state.
9. Vanilla encumbrance introduces no movement penalty and leaves weighted-item admission enforcement to ITEM. Supported mod consequences can contribute explicit gait penalties/restrictions.
10. Vanilla Running adds no sprint meter or duration limit beyond approved CHAR rules; optional mod sprint restrictions can participate without duplicate fatigue/practice or bypassed physical gates.
11. Only actual qualifying movement reaches CHAR activity reporting; held Run, blocked requests and passive carriage alone do not grant Running practice.

These are future verification criteria; no runtime tests or game implementation have been performed.

## Consistency review

Reviewed against MOVE-001–004, CHAR-020, RULE-004/005, CORE settings/suspension and all twelve confirmed decisions. No direct contradiction identified. Proportional analog running intentionally differs from DFU. Separate Sneak contributions resolve modifier order without applying Walk effects twice. Starting Walk after load changes request state, not required saved airborne motion. User-selected vanilla inventory-only encumbrance policy leaves exact ITEM admission behavior open while explicitly supporting mod consequences. Optional sprint resources do not add an unapproved vanilla meter. Airborne speed integration and exact extension semantics remain explicit dependencies.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Before implementation is complete resolve scale/collision fixtures, maximum and valid stat/formula domains, exact Hold defaults, gait/input evaluation, autorun mixed-input arbitration, airborne speed-change policy, restriction fallback/precedence, ITEM admission schema, supported mod hook/resource/UI/save contracts, multiplier numerical validation and actual-moving thresholds. These deferrals do not waive proportional input, vanilla no-penalty encumbrance or requested extension capabilities.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under MOVE-005-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
