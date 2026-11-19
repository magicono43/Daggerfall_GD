# MAGIC-019 — Drain and transfer

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Track persistent attribute penalties and transfer actual newly lost resources or attribute damage into bounded receiver recovery, with explicit source provenance and optional linked-effect profiles.

## Intended player experience

Attribute drain reduces live capabilities until repaired without rewriting permanent development or accumulating invisible healing debt. Transfers cannot generate recovery from overkill or blocked loss. Attribute transfer repairs matching damage rather than automatically fortifying a healthy caster. Mods can replace/extend these behaviors and add declared paired links without changing the vanilla spell inventory implicitly.

## Confirmed requirements

MAGIC-019-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm persistent source drain, moddable limits, actual-loss resource conservation, attribute-repair transfer/mod extensions, full receiver behavior, optional links, valid receiver, source accumulation, paired recovery, permanent-value reconciliation and native state. The complete specification is approved under MAGIC-019-A01.

MAGIC-017 damage/units, MAGIC-018 repair/recovery, MAGIC-009 contributions, CHAR-011/018 attributes/pools and health/death consequences remain authoritative. This feature does not invent a vanilla linked-fortification spell or assume every resource-transfer variant exists in DFU.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete variant/runtime boundary fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/MagicAndEffects/Effects/Destruction/`.

- `DrainEffect.cs` maintains incumbent magnitude as negative stat modifier, persists until healed, matches by drained stat and adds subsequent accepted magnitude. IncreaseMagnitude limits against permanent value−1; healing reduces modifier/magnitude and permits cleanup at zero.
- `TransferEffect.cs` extends drain and calls caster HealAttribute using lastMagnitudeIncreaseAmount. That value can exceed newly permitted target drain, motivating actual-addition target design.
- `TransferHealth.cs` resolves magnitude, damages target and heals caster by magnitude rather than authoritative actual loss. `TransferFatigue.cs` similarly damages/restores fatigue with unit multiplier. Source scene caster is required in these paths.
- `VampiricFortifyEffect.cs` is explicitly marked work in progress and not implemented by any effects. It demonstrates player-only linked target penalty/caster bonus with maxLinkDistance=25, not verified vanilla gameplay or an approved target distance.

## Detailed rules and behaviors

### Ordinary attribute drain

Default drain is source-owned attribute damage persisting until explicit repair/removal, not a change to permanent attribute. Merely ticking for lifecycle bookkeeping does not reapply damage. Supported timed mod alternatives must declare duration/cadence under MAGIC-008 rather than inheriting ordinary expiry accidentally.

Default accumulated ordinary drain on an attribute is limited to B=max(0,P−1), P=current permanent attribute. Add only permitted new penalty, retaining each source's actual contribution and repair/attribution/removal identity. Repeated drain does not reroll already committed contributions or reset their damage. Other disease/temporary penalties may still reduce final live value; this floor is not global protection from all combined zero-attribute consequences.

At limit, added drain is zero and grants zero transfer repair. Avoid invisible healing debt beyond tracked permitted penalty. Validate safe magnitudes/domains rather than letting negative values become bonuses. Source compatibility/order follows explicit family rules under MAGIC-009; shared incumbents cannot erase constituent ownership.

When permanent value increases, existing drain stays unchanged. If permanent decrease makes tracked drain exceed B, explicitly reconcile only excess drain using documented source-order rule. Later permanent increase cannot restore removed excess or silently inflict fresh damage. Exact reconciliation source allocation must be specified before implementation; mods may declare supported alternative floors/limits.

### Repair, removal and source absence

MAGIC-018 repairs eligible drain contributions oldest-first by default, up to remaining damage. Full repair ends that contribution without raising permanent values or providing a second restoration on later cleanup. Removal affects only selected source contributions; permanent/other disease/fortification state remains intact.

Persistent ordinary drain does not require original caster to remain represented after application. Retain stable attribution and captured power; do not bind to a new actor/item or reroll when source disappears. A declared live-link dependency is different from ordinary persistent damage.

### Resource transfer

Baseline resource transfer requires valid living receiver at application. Validate both endpoint identities and required context before target mutation. If receiver unavailable, reject the transfer rather than silently changing it to damage-only. Explicit mod profiles may permit damage without recovery.

Apply target loss through authoritative typed resource operations under MAGIC-017/CHAR. Fully settle health prevention/death or fatigue exhaustion, retaining actual loss. Default receiver gain is at most that actual loss and its current available capacity. Full receiver does not reduce attack amount; excess recovery is discarded, not banked.

Overkill, immunity, saturation and zero loss cannot produce default recovery from damage not dealt. Use explicit truthful intake result rather than inferring loss from a stale pool snapshot, especially around prevention. Mod conversion ratio/formula may differ only through declared supported profiles with safe units/domains.

Fatigue transfer accounts in authoritative internal units, avoiding two ×64 conversions or rounding-created gains. A display-point magnitude converts once for loss; actual internal loss is the transfer basis, with recovery in the same explicit units. No unverified magicka-transfer baseline variant is invented; supported profiles may declare additional resources through owners.

### Attribute transfer and extensibility

Default attribute transfer applies permitted target drain, then repairs receiver's eligible damage to the same attribute under MAGIC-018, capped by actual newly added drain. Healthy receiver gains no bonus/permanent points. Target can still be drained if receiver has no repairable damage; unused repair is discarded.

Only newly committed target penalty supplies transfer budget, not a raw attempted magnitude or total existing drain. Retain remaining source damage/repair progress and matching attribute units. Mod profiles may change or add conversion behavior, including declared other resources/bonuses, but must specify receiver eligibility, basis, caps, source lifetime and cleanup rather than mutating arbitrary character state implicitly.

### Magnitude, admission and paired commitment

Use MAGIC-017 supported inclusive magnitude/captured power and MAGIC-006 retained admission/save policies. A genuine new drain/transfer resolves its own accepted result; no repeated lifecycle tick rerolls initial damage. Explicit recurring profiles must define cadence/defense accounting separately.

Retain settled target result, then apply permitted receiver gain once. Check receiver validity again before gain; confirmed-dead receiver cannot revive through ordinary recovery. Normal receiver full/invalid-after-target outcomes need explicit settled result; technical failure of required second step uses same-operation recovery without repeating target loss or refunding already settled consequences.

Do not aggregate independent transfers if that changes prevention, gain caps or attribution. Duplicate callback must return/reuse retained result, not execute either side again. Required reaction/owner failures remain explicit pending obligations; there is no promise of rollback of irreversible death or general transaction framework.

### Optional linked fortification

Support explicit mod profile for paired target penalty/receiver bonus without adding vanilla spell or adopting unfinished source example wholesale. Profile declares exact range, lifetime/clock, endpoints, power conservation, potency/defenses, source dependency, pause/location transitions and missing-endpoint behavior.

Validate both endpoint identities and required range/lifetime under profile. Link end coherently removes only its paired temporary contributions, preserving unrelated modifiers/permanent ownership and prior committed resource damage. Repeated cleanup is harmless; no permanent attribute ownership transfer or refund of spent health.

Exact formulas, permitted actor types, spell availability and link range remain profile/content work. Source's 25-unit/player-only demo is not automatically a native default. Paired link state cannot silently become two unrelated permanent effects when one endpoint is absent.

## Relevant formulas and parameters

Default drain budget B=max(0,P−1); added penalty≤max(0,B−tracked ordinary drain). Default resource gain=min(actual target pool loss,receiver available capacity). Default attribute repair budget≤actual newly added target drain, then eligible repair limits apply. Zero values valid; no excess banking. Mod ratios/floors/linked conservation must explicitly declare safe domains and rounding. No new universal link distance or transfer-to-fortify coefficient selected.

## Required data

Stable application/source/target/receiver/contribution identities; attribute/resource/units; permanent-value limit policy; captured magnitude/defense result; requested/permitted/actual target loss; receiver gain/repair capacity and result; source repair/reconciliation allocation; optional paired link endpoint/timing/range/profile state; committed step/recovery receipts and native compatibility. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: accepted drain/transfer, current endpoints/pools/permanent limits, explicit repair/removal, permanent change and link validity/restore. Outputs: tracked penalty or actual pool loss, bounded receiver gain, source repair/cleanup or technical recovery, retained truthful consequences. APIs/signals unselected. Transfer feedback is not permission to issue another damage/heal call.

## Cross-system interactions

CHAR-011/018 own live attributes/pools, MAGIC-017 typed damage/units and MAGIC-018 repair/gain; health/prevention/death/exhaustion owners settle target result. MAGIC-005/006/007 source power/admission, MAGIC-008/009 timing/provenance/cleanup, MAGIC-010 persistence. NPC/LAW/QUEST consume stable attribution through explicit policies. DATA/MOD validate conversion/link extensions; SAVE/CORE-013 preserve paired completion and compatibility before gameplay readiness.

## Edge cases and failure conditions

- Target nearly empty/prevention alters loss: default gain uses actual settled loss, not raw magnitude.
- Drain at floor: zero new penalty/repair, no invisible debt. Combined other penalties still use their owners.
- Healthy/full receiver: target can lose normally, excess gain discarded without fortification/banking.
- Receiver absent before application: baseline no target mutation. Receiver dies after target settles: no revival or repeated loss; handle truthful outcome/recovery.
- Permanent value changes: no auto new drain on increase; explicit excess reconciliation on decrease.
- Original caster disappears after ordinary drain: damage persists/attribution retained; explicit link may end under its own contract.
- Link ends or counterpart unloads: paired scoped cleanup, no unrelated modifier deletion or resource rollback.
- Retry/load after target loss: retained gain obligation, never damage again to finish healing.

## Configuration and balancing options

Validated mod persistent/timed drain, floors/limits, compatibility/source allocation, transfer ratios/custom conversion/receiver behavior and optional linked profiles supported. Baselines remain stated conservation and attribute repair, not arbitrary bonus generation. Exact extension APIs, selector precedence, numeric bounds and supported link schemas remain owner work. Replacing baseline behavior must preserve explicit source/commit/save contracts rather than hidden fallback.

## Save/load considerations

Save drain contributions/repair/reconciliation progress, transfer target/gain completion receipts and supported link endpoint/profile/lifetime state. Restore modifiers once without new target loss/receiver gain or admission reroll. Missing source representation is distinct from missing required endpoint/provider.

Pending paired work requires coherent save boundary or sufficient supported retained progress; otherwise explained safe-boundary admission. Migration cannot silently change persistent to timed damage, reset link lifetime or erase one side's committed result. MAGIC-008/010 compatibility and CORE-013 recovery apply. Classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. Separate attempted magnitude, actual target change and receiver recovery; preserve typed units/stable source identity. Link endpoints and paired receipts cannot depend on live scene pointers alone. Exact resource/repair adapters, reconciliation source order, link API and native schema remain implementation design. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Default drain preserves permanent values/persists until repair/removal and adds no more than stated ordinary-drain budget without invisible debt.
2. Per-source accumulation/repair/reconciliation preserves attribution; permanent increase adds no drain and excess on decrease reconciles explicitly.
3. Resource gain uses actual settled loss/receiver capacity; full receiver does not reduce attack, zero/overkill cannot generate gain, fatigue units conserve once.
4. Attribute transfer repairs only same-attribute eligible damage within actual new-drain budget by default; declared mod alternative behavior remains explicit.
5. Missing receiver prevents default target mutation; paired technical recovery cannot repeat loss, resurrect receiver or refund settled consequences blindly.
6. Optional links have declared endpoint/range/lifetime/conservation/cleanup and do not introduce unfinished source demo as vanilla content.
7. Native restore retains contribution/paired/link state without loss/gain replay or silent lifetime/model conversion.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-009/010/017/018, CHAR-011/018 and health/intake consequences plus MAGIC-019-D01–D12. No direct contradiction identified. Persistent attribute drain differs from current-pool damage; repairing source contribution cannot permanently raise stats. Conservation uses actual authoritative loss rather than attempted source amounts. Explicit mod conversion support does not change defaults, and optional WIP link is not claimed vanilla. Timing/source migrations and paired recovery preserve prior native safeguards. Exact reconciliation/compatibility/source allocations remain dependencies, not guessed global rules.

## Outstanding questions

No further blocking drain/transfer player-policy choice is identified. Before implementation is complete: inventory variant settings/classifications, define source reconciliation/compatibility and repair adapters; verify authoritative prevention/exhaustion loss reporting; specify custom conversion/links, receiver-change outcomes, partial-step receipts and native migrations. These deferrals cannot authorize hidden debt, magnitude-based overkill healing, double fatigue scaling, unbounded live links or replayed transfer.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: MAGIC-019-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented variant inventories, source reconciliation/repair adapters, authoritative loss reporting, conversion/link profiles and paired native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
