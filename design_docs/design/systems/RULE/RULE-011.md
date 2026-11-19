# RULE-011 — Stealth and climbing

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Compute remaining-hidden and climbing-check probabilities using explicit current inputs, moddable baselines and declared arithmetic. Keep eligibility, cadence and consequences with NPC/MOVE/MAGIC.

## Intended player experience

Distance/live skill affect a particular stealth check; live Climbing, racial/effect context and Luck affect a climbing check. Inspectable explanations and optional percentages do not change outcomes. Passing does not grant invisibility or permission to climb unsupported surfaces.

## Confirmed requirements

RULE-011-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve both moddable baselines, signed stealth rounding/quantization, climbing modifier order and moddable intermediate limits, final 0–100 handling, live inputs, capped baseline Luck contribution, final climbing truncation and labelled optional feedback.

CHAR-002 retains Khajiit +30 before enhancement/clamping. CHAR-011 owns live values; CHAR-020 retains practice for qualifying climbing checks. Those rules remain binding without approving additional caller behavior automatically.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateStealthChance` evaluates twice the arithmetic-right-shift-by-10 of quantized classic distance multiplied by target live Stealth. No final percentile clamp appears in the helper.
- `Game/EnemySenses.cs#StealthCheck` applies target/range/hostility/classic-spawn/game-minute and slow-movement conditions. It interprets Dice100.FailedRoll as detection and tallies Stealth under its own cadence.
- `FormulaHelper#CalculateClimbingChance` adds 30 for Khajiit, doubles for enhanced climbing, clamps effective skill to 5–95, interpolates supplied base success toward 100, adds clamped Luck interpolation 0–10, then casts to int. Final raw chance can exceed 100. Both formula helpers expose overrides.
- `Game/Player/ClimbingMotor.cs#ClimbingSkillCheck` tallies practice, handles perfect/override bypasses, otherwise rolls and can suppress failure near water. These exceptions/cadence/consequences require MOVE review.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime cadence, complete sensory/movement routing and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Stealth

Use finite nonnegative separation d, explicit positive classic-distance scale g and the hiding actor's resolved live Stealth S. Distance and scale must use compatible units; convert Godot world distance explicitly rather than assuming identical Unity/classic units.

Compute D=trunc(d/g), then raw remaining-hidden chance Cs=2×floor(D×S/1024). Preserve distance steps and signed floor equivalent to arithmetic right shift, without copying integer-overflow behavior. Negative live skill remains valid where CHAR-011 permits it.

RULE-001 uses Ps=clamp(Cs,0,100). Passing means remaining hidden for this check; the same result's complement is supplied to NPC's detection logic. Do not roll a second independent detection result. Other sensory/illusion/visibility rules remain relevant; this helper alone neither establishes awareness nor grants invisibility.

### Climbing

Use live Climbing C, live Luck U, validated owner-supplied base chance B and resolved racial/enhancement context. Add applicable Khajiit bonus 30 first, then double for enhanced climbing, then clamp effective skill V to 5–95. Resolved context prevents duplicate racial/effect application; transformation precedence and stacking remain owner contracts.

Let t=clamp(V/100,0,1); interpolated chance J=B+(100−B)×t. Luck bonus K=10×clamp(U/100,0,1). Raw chance Cc=trunc(J+K), toward zero. Effective Pc=clamp(Cc,0,100) under RULE-001. Baseline Luck above 100 still contributes at most 10; do not add another final 95% ceiling.

Intermediate skill limits and supported formula/Luck parameters are moddable. Baseline interpolation saturates t even if a mod extends intermediate limits; changing that mapping requires an explicit supported override. MOVE owns base-chance values, surfaces, cadence, perfect-climbing bypasses, water-exit protection, falling and related consequences. Passing a check cannot bypass movement eligibility.

### Authorization and result lifetime

Sample current valid live values/distance/base chance/racial-effect context at each authorized check. Capture coherent inputs for that resolution; technical retries reuse its outcome rather than rerolling changed context. NPC/MOVE declare check identity/cadence and RULE-003 random-source purpose/order before integration. No per-frame checking or universal per-actor stream is selected here.

Resolve one RULE-001 result per genuine authorized check, including guaranteed effective probabilities. Inspection/rendering/blocked requests are not new checks and award no practice. Owner-defined bypasses need their own draw/practice rules; observed source behavior does not automatically approve them.

### Presentation and customization

Provide inspectable explanations and optional exact percentages labelled remaining hidden for this check or passing this climbing check. Distinguish climbing's intermediate skill cap, raw chance and final effective chance. No mandatory per-check popup is introduced. Estimates can change before authorization; queries never mutate awareness/movement or consume draws.

Both formulas support validated parameters and explicit RULE-004 replacement hooks. Schemas must declare units, parameter/input domains, ordering, integer output conversion and raw-versus-final replacement/limit semantics. Supported stealth scale/mapping and climbing racial/enhancement/cap/interpolation/Luck parameters require concrete contracts before exposure. No generic expression interpreter is approved. DATA-003/RULE-004 validation, locks and explicit failure recovery remain binding.

## Relevant formulas and parameters

- D=trunc(d/g); Cs=2×floor(D×S/1024); Ps=clamp(Cs,0,100).
- V=clamp((C+racial bonus)×enhancement multiplier,5,95).
- J=B+(100−B)×clamp(V/100,0,1); K=10×clamp(U/100,0,1).
- Cc=trunc(J+K); Pc=clamp(Cc,0,100).
- Racial bonus: resolved Khajiit 30, otherwise 0. Enhancement multiplier: applicable 2, otherwise 1.

Examples: D=512,S=50 gives raw stealth 50; D=1024 gives 100. D=1,S=−1 gives raw −2 and effective zero, preserving signed floor. For C=20, Khajiit and enhancement give (20+30)×2=100, capped to 95. B=50,U=50 then give J=97.5,K=5,raw 102,effective 100.

## Required data

Actor/observer or climb identity; validated distance/scale; live skills/Luck; base chance; resolved racial/effect context; formula parameters/provider provenance; eligibility/check identity; owned source and retained outcome/application context. Concrete units, schema and source subdivision remain dependencies.

## Inputs, outputs and events

Inputs: explicit validated queries and owner-authorized checks. Outputs: raw/effective chance/explanation, labelled resolved result or explicit failure. Helpers do not award practice, set awareness, initiate climbing or apply falls. NPC/MOVE own authoritative changes/notifications; APIs/signals are unselected.

## Cross-system interactions

NPC owns senses/awareness/stealth cadence; MOVE owns climbing eligibility/base chance/cadence/consequences. MAGIC resolves effects; CHAR-002/011 provide racial/live state; CHAR-020/012 own eligible fatigue/practice. RULE-001/003 govern resolution/source lifetime, RULE-004/DATA-003 override validation/configuration. CORE/SAVE gate valid session/operation state; UI/DEV observe without draws.

## Edge cases and failure conditions

- Missing context, negative/nonfinite distance, nonpositive scale, invalid limits and unsupported/overflowing arithmetic fail explicitly rather than become zero/default successful queries.
- Negative computed chances saturate to zero; valid above-100 Luck retains baseline bonus cap. No hidden global live-skill clamp is added.
- Bonus/order/interpolation cannot change through duplicate effect application or accidental engine arithmetic differences.
- Duplicate callbacks cannot multiply rolls/practice; new checks follow owner cadence.
- Failed overrides invoke explicit RULE-004/owner recovery without automatic vanilla fallback or duplicate consequences.

## Configuration and balancing options

Both baselines are moddable through supported validated parameter/hook contracts. Keep units, rounding, order and intermediate-versus-final limits explicit. No new global skill cap, lighting/noise term, sensory cadence, fall rule or perfect-climbing policy is introduced.

## Save/load considerations

Restore authoritative actor/effect/awareness/movement state and derive chances from valid current inputs. Chance caches are not additional bonuses. Do not replay checks/practice/falls or create fresh effects during reconstruction. Retained in-flight outcomes follow owner/SAVE contracts; successful loading permits fresh future unresolved checks under RULE-003 without erasing saved facts. Exact sensory-memory/climb-phase persistence remains owner review.

## Technical constraints

Target: Godot 4.7.2. Use explicit units, safe signed floor for stealth, clamped interpolation and final toward-zero climbing conversion. Separate formula, eligibility, cadence and outcomes. Numeric representation/interfaces/persistence remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Stealth matches distance quantization/signed-floor mapping and negative-skill boundaries without overflow.
2. Climbing applies racial bonus before enhancement/cap, supports validated modded intermediate limits and caps baseline Luck bonus at 10.
3. Final climbing raw chance truncates toward zero; RULE-001 saturates both outputs to 0–100 without another 95% ceiling.
4. Authorized checks use current coherent live inputs and one retained result; inspection/rendering/blocked paths create no checks/practice.
5. Both customization surfaces validate units/domains/output semantics and fail explicitly without hidden fallback.
6. Explanations/optional percentages identify check meaning without promising invisibility/surface access.
7. Restore derives chance without replay or duplicate effects, respecting retained state and fresh future unresolved randomness.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-002/011/020 and RULE-001/003/004. Khajiit order matches the retained baseline; negative live skills receive explicit consumer arithmetic. Intermediate climbing limits coexist with guaranteed final probabilities. Practice remains separate from querying. NPC/MOVE exceptions/cadence are not adopted automatically; configuration locks/recovery remain binding.

## Outstanding questions and approval

No blocking gameplay policy question remains for the calculations. Before implementation: finalize numeric/parameter/hook domains, world/classic conversion, base-chance mappings, racial/effect resolution, NPC/MOVE source/check/cadence contracts, UI settings and persistence. Awareness, water protection, perfect climbing, falling and retries require owner reviews. These cannot waive baseline rounding/order, both-formula moddability or eligibility-before-resolution.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-011-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and interaction-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
