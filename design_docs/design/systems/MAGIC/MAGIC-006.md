# MAGIC-006 — Bundle admission and chance

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Admit delivered spell/effect entries independently, resolve chance and saving throws without premature gameplay mutations, and start accepted effects in authored order with retained outcomes.

## Intended player experience

Mixed spells can partly succeed through ordinary chance/resistance outcomes. Failed effects leave no bonuses, damage or duration extensions. Accepted earlier effects can influence later entries, and immediate effects apply promptly. Loading or technical retries cannot reroll already resolved admission or repeat committed consequences.

## Confirmed requirements

MAGIC-006-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm mutation-free pre-admission preparation, independent ordinary outcomes, authored sequential application, retained per-application chance, chance-before-save order, separate bypass permissions, baseline chance scaling, caster-only save exemption and immediate initial application. The complete specification is approved under MAGIC-006-A01.

Inherited requirements include MAGIC-001/002 complete supported definitions, MAGIC-004 once-only release/payment, MAGIC-005 captured caster power/current target eligibility, COMBAT-014 per-recipient delivery, RULE-001 percentile boundaries and RULE-017 retained per-effect saves. MAGIC-007 defense scope and MAGIC-008/009 ongoing scheduling/merging remain separate reviews.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; effect-family startup/runtime failure behavior unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/MagicAndEffects/`.

- `EntityEffectManager.cs#AssignBundle` copies bundle provenance/settings, constructs effects and skips unknown keys. It checks hard disease/paralysis immunity and spell absorption/reflection/resistance before invoking effect.Start.
- After Start it checks on-cast ChanceSuccess, handles non-incumbent merge results, then performs some non-magnitude saving throws. Accepted live effects are added and receive MagicRound immediately. Magnitude saving paths occur later in effect evaluation.
- `EntityEffect.cs#BaseEntityEffect.Start` sets manager/caster, duration and chance. Overrides can perform additional work. Calling Start before chance/save rejection allows potential gameplay mutations or incumbent merges before acceptance; no universal absence of such side effects was established.
- `ChanceValue` computes ChanceBase+ChancePlus×floor(casterLevel/ChancePerLevel); missing caster defaults to one in this source path. `RollChance` delegates percentile success to Dice100.
- AssignBundle flags include saving-throw bypass, chance bypass and special infection. Absorption has a separate condition; saving-throw bypass also gates reflection/resistance in this implementation. These couplings are not automatically adopted.

## Detailed rules and behaviors

### Valid context and mutation-free preparation

Require supported complete bundle/effect definitions, stable source/caster/recipient identity, classifications, settings and applicable permissions. Use MAGIC-005 release-captured power inputs and current recipient state. Missing required provider/context or malformed parameters is an explicit technical failure, not a zero-cost effect, full-payload bypass, ordinary immunity or permission to silently drop an entry.

Validate required definitions/references before treating a bundle as usable. If a technical fault nevertheless occurs after earlier entries commit, retain committed progress and recover explicitly; do not pretend the bundle was fully successful, roll back unrelated accepted effects, or replay the whole bundle. Whole-definition rejection and independent ordinary runtime failure are distinct.

Initialization, construction, inspection and pre-admission checks must not apply damage, modifiers, grants, durations, incumbent merges or initial ticks. They may retain authorized random results and prepare non-gameplay instance state. Effect startup and mutation occur only after acceptance. Acceptance does not authorize ignoring an effect family's own checked owner operations.

### Sequential per-entry pipeline

Process active entries in authored order, including repeated entries as distinct applications. For each recipient/entry:

1. Prepare valid context and check current applicability/hard-immunity rules, respecting only explicit authorized exceptions.
2. Perform applicable spell-defense stages defined by MAGIC-007. Their exact scope/order/redirect behavior remains that review's decision.
3. If supported and configured for on-cast chance, resolve that chance unless explicitly bypassed. Failure ends this entry without startup/merge/save draw.
4. Resolve applicable RULE-017 effect save unless an explicit saving-throw exemption applies. Retain its result and use the effect's declared numeric/binary interpretation.
5. Only after acceptance perform startup or checked incumbent handling and initial application. Commit/retain its outcome before the next authored entry.

An accepted earlier effect may change recipient state used by a later entry, including defenses/eligibility. Do not precompute all recipient-dependent outcomes from a stale whole-bundle snapshot. Captured caster inputs remain captured; this sequencing does not silently make airborne caster power live again.

Ordinary eligibility/chance/resistance failure of one entry does not suppress other independently applicable entries or area recipients. Later effects still check current recipient validity, including any death caused by an earlier effect. Missing technical dependencies are not classified as ordinary failures to continue silently.

### On-cast chance

For a supported on-cast chance component, baseline raw chance Q=B+I×floor(L/D), using authored base B, increase I, captured caster level L and positive validated divisor D. Resolve P=clamp(Q,0,100) through RULE-001: one logical percentile draw U in 1–100, success U≤P, including draws at P=0 and P=100.

Do not repair invalid divisors or invent level one when required caster context is missing. Explicit source/effect contracts must supply supported context for non-caster-backed effects. Mod overrides may change supported scaling/parameters through validated rules; no unsafe arithmetic, preview mutation or implicit fallback is approved.

Resolve chance once per effect/recipient application. Distinct recipients and repeated authored entries have distinct checks. Retain results for diagnostics, retry and restoration; reading ChanceSuccess cannot draw again. A bypass is a declared outcome, not a hidden roll. Effects without an applicable on-cast chance gate are not automatically rejected for having no chance component.

Later ticks reroll only under an explicit recurring-chance policy with declared cadence/identity. MAGIC-008/effect-family reviews must establish such policies; this draft creates no automatic reroll every round.

### Saving throws and exemptions

After chance success, use RULE-017 once per applicable effect application. Retain percentage, reasons and relevant draws; reuse across relevant magnitude/duration fields and technical retries. Separate effects may receive separate saves. Numeric scaling follows RULE-017 safe truncation/no implicit minimum; binary effects need declared cancel/apply interpretation. This feature does not assign one binary rule universally or silently add a second magnitude-stage save.

Ordinary caster-only mode bypasses effect-level saving throws. This depends on target mode, not caster/recipient identity alone: an own-caster ranged explosion is not automatically exempt. Caster-only mode still obeys chance, applicability and hard immunity unless separately authorized. Absorption/reflection and spell-resistance handling remain MAGIC-007 scope.

Chance bypass, effect-save bypass and hard-immunity exceptions require separate explicit permissions with source provenance. No generic bypass-everything flag is approved. Potion, item, special-infection and effect-family reviews must declare exact exceptions; this draft approves none merely because DFU has a flag. Hard disease/paralysis immunity composition also requires owner validation rather than assuming every source immunity is absolute against all weaknesses under RULE-017.

### Startup, initial application and incumbent handling

Each newly accepted effect receives its initial application immediately, before the next authored entry. Immediate damage/healing/status need not wait for the next global magic round. Startup and initial application together must not accidentally deliver the same initial consequence twice.

Incumbent merging occurs only after admission. Rejected recasts cannot extend, replace or modify an existing effect. Accepted merging must not accidentally add a second initial tick; explicit family rules in MAGIC-009 define merge/refresh/replace/stack and any intentional reapplication. Initial application does not select duration accounting, expiry boundary or later scheduling; those remain MAGIC-008/009.

Notifications describe committed accepted/merged/failed results. No optional observer can repeat application or turn a rejected entry into an accepted one. Technical startup/partial-mutation failure uses explicit recovery retaining completed work and random outcomes.

## Relevant formulas and parameters

Q=B+I×floor(L/D), D>0; P=clamp(Q,0,100); U uniform integer 1–100; success U≤P. Per applicable effect save, RULE-017 retained percentage R is reused, numeric A becomes trunc(A×R/100) under valid amount domains. No duration/magnitude formula, binary interpretation, immunity table or new tick period is approved here. All arithmetic must support validated safe numeric domains.

## Required data

Bundle/delivery/effect-entry/application/recipient identity; stable spell/effect/source/provider references; authored ordering and settings; captured caster inputs; current applicability/defense context; separate bypass permissions; chance policy/raw/resolved value/result; retained save/result interpretation; startup/merge/initial-application progress; accepted/rejected/technical-failure reasons and pending recovery facts. Exact schemas and retention representation remain dependencies.

## Inputs, outputs and events

Inputs: authorized recipient delivery, validated settings/source snapshot, current target context, admission/bypass policies and owner startup/merge outcomes. Outputs: independently accepted, ordinarily rejected, merged or technically failed entries; retained chance/save results; committed immediate/live effects and truthful notifications. API/signal names remain unselected. A bundle with no live persistent effects may still have valid completed immediate effects or ordinary failures; persistent-list length alone is not a complete success result.

## Cross-system interactions

MAGIC-001/002 and DATA-011 establish complete definitions/provider support. MAGIC-004 owns paid release, not admission refunds; MAGIC-005/COMBAT-014 provide stable recipient/delivery context. MAGIC-007 defines interception/defense scope; RULE-001/003 own authorized random checks and retained outcomes; RULE-017 supplies per-effect saving percentage. MAGIC-008/009 own ongoing cadence/stacking, MAGIC-010/SAVE restore. CHAR and other effect owners apply authoritative changes; UI/DEV observe retained results under knowledge rules without rolling or reapplying. DATA/MOD validate locked policies/hooks.

## Edge cases and failure conditions

- Chance fails after preparation: no startup, merge, damage or save draw. A failed recast leaves incumbent duration unchanged.
- One effect fails and another succeeds: retain independent outcomes in authored order. A newly changed recipient defense may affect the later entry.
- Two repeated effects or two area recipients: separate identities/chance results; duplicate callbacks for one application do not create new attempts.
- Caster-only buff: no ordinary effect save, but chance/immunity rules remain. Own-caster blast: normal non-caster-only save policy.
- Magnitude/duration getters, diagnostics and retry: reuse the same effect save; no accidental double mitigation or rerolls.
- Accepted instant effect expires immediately or has no live record: committed outcome still retained; absence from persistent collection is not failure.
- Earlier effect kills/removes recipient: later applicability is revalidated, not blindly applied or redirected.
- Missing provider or startup fails after partial mutation: explicit same-application recovery, not silent skip or whole-bundle replay.

## Configuration and balancing options

Support validated chance parameters/scaling overrides, explicit on-cast versus declared recurring policies, per-effect save interpretation and separate source-authorized bypass exceptions. Earlier-effect ordering is meaningful and must remain authored rather than automatically sorted. Exact hook APIs, safe limits, immunity classifications and family exceptions remain owner schemas, not approval of arbitrary scripting or a universal bypass switch. No new global stacking rule, retry cadence or minimum chance is introduced.

## Save/load considerations

Retain already resolved admission/committed consequences so native restoration does not reroll chance/save or repeat startup/initial application. RULE-001 fresh randomness on load applies to newly authorized checks, not replacement of saved resolved outcomes. MAGIC-010/SAVE must specify active-effect state, identities and compatibility.

At partial admission/startup boundaries, save coherently or preserve sufficient supported progress/recovery facts; do not expose an ordinary successful snapshot that loses required effects or repeats completed work. Exact mid-application save eligibility is deferred. Required missing definitions use approved CORE-013 recovery; no silent effect loss or timer restart. Classic/DFU save import remains outside scope.

## Technical constraints

Target Godot v4.7.2. Separate nonmutating preparation from accepted-effect owner operations without requiring DFU Start/MagicRound methods. Keep stable application identities, authored sequencing and retained outcomes independent of UI/collider callbacks. Exact defense integration, chance hook representation, effect lifecycle contracts and native persistence require implementation design. Reference source remains read-only; no implementation/coding tasks authorized.

## Acceptance criteria

1. Rejected effects cannot damage, modify stats, grant items, extend incumbents or receive initial ticks.
2. Supported independent entries proceed through ordinary failures in authored order, observing accepted earlier target changes.
3. Chance resolves once per entry/recipient, precedes applicable save, and follows baseline formula/RULE-001 boundaries; invalid context/divisors fail explicitly.
4. Chance failure consumes no effect-save draw. Later fields/retries/restore reuse retained save and chance results.
5. Separate chance/save/hard-immunity permissions work independently; caster-only save exemption cannot exempt own-caster ranged blasts or bypass chance/immunity.
6. Accepted new effects apply immediately before the next entry; startup/merge cannot accidentally duplicate initial application.
7. Missing providers/malformed settings/partial startup failures remain explicit technical outcomes, not ordinary resistance or silent reduced bundles.
8. Native restore and repeated callbacks cannot reroll admission, repeat initial work or modify an unrelated recipient/incumbent.
9. MAGIC-007 defense stages and MAGIC-008/009 recurring policies are explicitly integrated before claiming complete framework behavior.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-001–005, COMBAT-014, RULE-001/017 and recorded MAGIC-006-D01–D09. No direct contradiction identified. Complete-definition validation is distinct from ordinary partial gameplay success. Authored application order uses current recipient state while preserving captured caster power. Retained chance/save results agree with fresh RNG for new checks on load. Self exemption is explicit rather than missing-context fallback. Defense interception remains MAGIC-007, and immediate application does not silently select global tick/merge duration rules. Architecture recommendations remain proposals beyond confirmed behavior.

## Outstanding questions

No further blocking admission player-policy choice is identified. Before implementation is complete: MAGIC-007 must define defense scope/order/bypass integration; effect owners must inventory applicability/immunity and binary/numeric save interpretations; MAGIC-008/009 must define tick/expiry/merge policies; DATA/MOD must specify chance/bypass schemas and valid numeric contexts; MAGIC-010/SAVE must settle retained admission state, partial-operation saves/migrations and required recovery. These dependencies cannot authorize pre-acceptance gameplay mutations, silent missing effects, duplicated ticks or rerolled committed outcomes.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-006-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented defense integration, immunity/save interpretation inventories, tick/merge contracts, mod schemas and native persistence/recovery dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
