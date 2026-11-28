# IMP-017 — Review Mod Support, 2026-11-28

**Parent acceptance follow-up:** The user subsequently considers IMP-017 completed,
including the review repairs. See [acceptance](IMP-017-ACCEPTANCE-2026-11-28.md).
Earlier review/repair-time pending-parent statements below are historical.

**Repair follow-up, 2026-11-28:** The user subsequently authorized the two proposed
corrections. F1/F2 are repaired and verified by 1,886 assertions across eight
commands, including independent rendered/fresh-process and Windows debug/release
persistence exports. See [repair evidence](IMP-017-MOD-SUPPORT-REPAIRS-2026-11-28.md).
Parent/user acceptance and the named later integration gates remain open. The
findings and audit below retain their original review-time scope and source.

Review-time status: **review complete; two P2 contract defects remain open; no repairs authorized or made**.
All four increment acceptances retain their recorded scopes. This review does not
accept parent IMP-017 or close its later integration gates.

Started 2026-11-28 **02:38:28 EST (UTC−05:00)**.
Completed 2026-11-28 **02:50:54 EST (UTC−05:00)**; elapsed 12 minutes 26 seconds.
Reviewed source: `c4897dc1df96bb63fe09d1a14a0db479057709a4`, initially clean working
tree. The accepted increment-4 implementation is committed at this HEAD; earlier
uncommitted notes describe their preparation-time state.

## Findings

### F1 — P2: a validated armor category collides with the internal semantic discriminator

Affected extension: mod-added armor categories using the existing property and
appearance adapters. `item_construction.gd:60–62,77–82` accepts the stable category
key `semantic`, a supported property mode and complete style/resource mappings.
Actual menu publication and explicit ITEM construction succeed. The resulting
ordinary armor then receives `unsupported` from recalculation, appearance
modification and authorized copy because consumers compare the public category
key with an internal representation sentinel:

- [construction_owner.gd:215](../../../main_project/scripts/item/construction_owner.gd#L215): appearance modification.
- [construction_owner.gd:246](../../../main_project/scripts/item/construction_owner.gd#L246): copy.
- [construction_owner.gd:276](../../../main_project/scripts/item/construction_owner.gd#L276): recalculation.

This is a validation/consumer mismatch, not a request for arbitrary new gameplay
semantics. ITEM-003-D03 and its approved construction contract support validated
added categories with explicit adapters. A mod author can publish a category and
create a possession which ordinary supported helpers subsequently misclassify.
Initial-custody retirement also uses this sentinel (`construction_owner.gd:266`;
code-inspected, not separately probed).

Reproduction used a disposable real package, preserving the shipped policy:

1. Add `policy.categories.semantic = {mode: "material", dye: "steel"}`.
2. Add `dfu-item-102.styles.semantic` as a detached copy of its existing plate
   styles. Publish both through an ordinary `item.construction:profiles` patch.
3. Enter the actual menu and a CORE-authorized ITEM requester session.
4. Construct profile `dfu-item-102`, body `male-human`, category `semantic`,
   material `steel`, quantity 1. Construction succeeds with item identity 241,
   armor kind, steel material and a validated classic appearance.
5. Recalculate that identity, submit a supported dye request, or copy with explicit copy
   permission. All three return `unsupported` and semantic-provider reasons.

**Smallest correction:** reserve `semantic` in the construction category schema
and reject conflicting policy/style mappings before publication. Supporting that
name would instead require separating representation from the public category key
in all affected consumers. Reserving a documented internal key is sufficient;
there is no need to redesign the mod API. Add a publication-to-owner regression.

Evidence: construction probe below; `review-category.json` retains the actual
constructed record and all three owner responses. An otherwise identical added
category named `custom-plate` successfully constructs, recalculates, accepts the
same dye request and copies. This isolates the key collision from generic added
category support or invalid helper arguments. Other categories/materials in the
maintained suite continued to pass.

### F2 — P2: load preflight trusts the category sentinel to bypass required reference validation

Affected extension: reliable rejection of malformed or incompatible custom item
records before replacing the outgoing session. At
[persistence.gd:219](../../../main_project/scripts/item/persistence.gd#L219), a
nonmonetary record with `category == "semantic"` skips the constructed-item
body/style/material/visual and template identity-category checks. The remaining
state-schema query at line 233 does not establish that the record is a valid
semantic intake representation. For example, semantic intake creates
`kind == stack_type` with a stack identity (`collections.gd:400`), while the
accepted malformed example retains constructed ammo kind `ammo` and stack type
`arrow`.

Reproduction exercised `persistence.prepare` during the real CORE load preflight,
with the exact current compatibility metadata and a valid owner-created snapshot:

```gdscript
var bad := saved.duplicate(true)
bad.possessions[0].category = "semantic"
bad.possessions[0].material = "missing-material"
bad.possessions[0].erase("visual")
bad.possessions[0].erase("body")
var result := item_owner.persistence.prepare(controlled, core.ticket(), bad)
# Actual: {"ok": true, "candidate": 1}
```

The record is the five-arrow stack `18446744073709550001`, profile
`dfu-item-131`. Expected: explicit rejection before replacement, preserving the
live store. Existing tests reject missing appearance and unresolved material
when the category remains its original value; changing this discriminator defeats
that protection. This violates ITEM-025's required reference/representation
validation and the persistence contract's stated preflight gate.

**Smallest correction:** validate a complete, supported representation before
selecting the constructed versus semantic path. Enforce the semantic intake's
actual kind/type/identity and property requirements, and reject contradictory
constructed records instead of treating the sentinel as sufficient authority.
Preserve legitimate custom semantic types and their declared state contracts.
Add this adversarial combination alongside the existing appearance/material cases.
Fixing only F1 does not protect malformed incoming payloads.

Evidence establishes **invalid candidate acceptance**, not a demonstrated full
production SAVE-slot load. The probe deliberately did not publish the malformed
candidate; normal valid preparation replaced it and the maintained load/reload
checks completed. `_publish` copies prepared records without repeating these
record checks (`persistence.gd:435–461`, code-inspected). No script permission
bypass or executable-code injection is claimed.

## Reviewed extension paths and positive evidence

Authority inspected: IMP-017 and its linked ITEM-001/003/005/006/007/008/009/025,
RULE-025/026 specifications; the four delivered ITEM contracts; increment-4
acceptance, execution and audit; approved GAD-01/02/04/08/10; PROJECT-DATA-D01;
DATA-003, MOD discovery/priority/dependency/trust/entry-point rules, and applicable
DATA/RULE implementation. IMP-006/009 and supporting IMP-016 delivery scopes are
accepted, rather than inferred from planning READY.

| Path | Trace and qualified evidence |
| --- | --- |
| Discovery and precedence | `package_library.gd` validates folder/ZIP identities and paths; MOD planning supplies enabled order. `definition_registry.gd:170–286,295–371` applies shipped contributions, sorted package content, then captured loose overrides; patch fields replace explicitly and preserve originating identity, field winners and contributors. Required reference validation precedes commit. Reused publication/reader cases include folder/ZIP/loose precedence, collisions, replacement, stale candidates and menu failure. |
| Construction and generation | Stock startup registers the adapters; session shell supplies the same registry to ITEM. `construction_owner.gd:106–164,321–414` queries resolved profiles/materials/policy and selected RULE hooks. Existing real-package fixture adds bronze, extends template compatibility/style and selector mappings, then loose-overrides coefficients. Actual construction, generation and isolated distribution observe the published changes. No enum position or display label becomes a material identity. Draw order, retained choices and no-fallback failure are exercised. F1 is the category-name exception. |
| Collections and semantic extensions | `collections.gd:82–143,379–539` resolves type/template eligibility, cap and declared state rule; compatible stacks preserve complete per-unit state and stable identities. Real package/loose cases use cap 5, deny/allow overrides, charged contents and unordered key sets. Split/merge, no-stack, whole-plan admission, expiry, stale identities, reentry and retained partial results are covered. Provider declarations are required before DATA preparation; missing special owners remain explicit failures. |
| Weight and capacity | `capacity.gd:15–193` consumes resolved accounting, weight/exemption, access and capacity profiles. Actual CHAR supplies base capacity, and provider facts supply additional modifiers/wagon context. Checked integer quantum conversion, positive-to-zero rejection, revision-keyed loads, exact fill, overweight retention and fitting admission are exercised. Custom finer precision and selected CHAR capacity replacement reach owner outcomes. No copied vanilla capacity formula was found in ITEM. |
| Currency and tender | `money.gd:17–114,182–347` uses stable denomination/profile/issuer/rate IDs, explicit denomination order, integer values, per-instrument weights and exact rational lots. Real package cases add a value-3 denomination, a gold-formula mapping of 7, a letter and two contextual rates; actual tender and custody outcomes conserve value. Invalid rates/units, exact subset failures, changed acceptance, missing change and failed ECON acknowledgment have explicit outcomes. ECON is controlled, not a delivered merchant/bank service. |
| Persistence and compatibility | `definition_registry.gd:429–453`, `formula_registry.gd:226–239`, and `persistence.gd:71–133,239–478` retain resolved content/provenance and selected provider versions, normalize only explicit scope envelopes and preserve actual possessions/claims/counters. Compatibility uses sorted keyed content rather than UI/list labels or process tickets. Real CORE/ITEM/CHAR load composition and separate-process tests preserve nonfull pools, distinct stacks, high decimal IDs and pending ECON acknowledgment without grants, rerolls or re-debits. F2 limits the otherwise broad malformed-record coverage. |
| Trust and lifetime | Data envelopes do not load GDScript/Luau or restore callbacks/Objects. `formula_registry.gd` accepts controlled staged standard callbacks through its existing declaration/signature/publication path; it is explicitly not a package executable loader. Runtime request authority remains CORE-scoped requester Objects, with durable custody/context/request identities. Script activation, consent and sandbox qualification retain their existing MOD gates. |

The adopted baseline remains explicit DATA with provenance; ITEM/RULE consumers
do not duplicate the 10-material, denomination-value or capacity tables in owners.
The reader's conditional-correction helper matches complete expected input, and
later package/loose precedence remains intact. No new baseline correction or
reference/classic source mutation was made during review.

## Verification, freshness and limits

The final Implementation ledger remains **17,233 passing assertions across 32
commands**. All 32 original report SHA-256 values still match the execution audit.
The final candidate inventory was compared against the current 677 recorded
inputs: 676 match; the sole absent input is generated
`creation_questionnaire_mask.gdshader.uid`. It is an unrelated editor sidecar,
not changed ITEM implementation. Current native dependency identities match.
The audit's recorded per-suite source equivalence and controlled-provider limits
remain applicable; this review does not relabel old executions as fresh runs.

Two **review-instrumented headless** runs used the maintained runner copied into
the review root. Only their disposable fixture scripts were extended; all game
implementation and normal production interfaces remained unchanged. Added
observations do not enter or weaken the maintained assertion inventories:

| Command from repository root (PowerShell 7) | Result and retained root |
| --- | --- |
| `& ./main_project/tests/.runs/imp017-mod-review-2026-11-28/run-probe.ps1` | 138 primary + 36 separate-process reload assertions PASS; F2's expected rejection failed as a review observation. `verification-headless-447adfa25afb45348edde1562a8c5825` |
| `& ./main_project/tests/.runs/imp017-mod-review-2026-11-28/run-construction-probe.ps1` | 125 assertions PASS; F1's three expected ordinary helper outcomes failed as review observations, while all four control outcomes succeeded. `verification-headless-ffb9e9eaf4414a07a695319934ae375e` |

Thus **299 additional maintained assertions passed**, while the focused probes
found the two defects above. An earlier construction probe also passed 125
assertions at `verification-headless-1c79c6eea39d48d8904967b2c12af1f5`; the final
run supersedes it with an explicitly valid dye request and the comparison
category. Its executed source and report remain archived, without counting its
observations as the final evidence. Engine: `4.7.2.stable.official.ed1daf0bf`. Classic
source: `C:/Games/Daggerfall/arena2`, held read-only by the maintained runner's
source guard. Original fixtures, custom injection text, exact commands, modified
executed source, reports and observation JSON are retained under
`main_project/tests/.runs/`; the [companion review audit](IMP-017-MOD-SUPPORT-REVIEW-2026-11-28.audit.json) binds hashes and paths.
The known root-certificate-store diagnostic appears in logs; the runner reported
no unexpected script errors. It does not invalidate the recorded owner responses.

No new rendered or export run was warranted: neither probe changes frame,
presentation or playback behavior. The fresh probe results are headless owner and
publication evidence, not physical-device or playable inventory acceptance.
Existing independent rendered/export checkpoint results are carried forward.

Documented limits remain: construction's named property/appearance adapters and
declared classic archive inventory; homogeneous per-unit semantics rather than
heterogeneous/shared-resource stacks; named bounded fitting/tender algorithms;
exact locked content compatibility with no registered migration; and no hot
reload. These are not defects or promises of arbitrary schemas/providers.

Full IMP-022 SAVE slots/publication, IMP-023 full-room restore/Session Restored,
native actor identity, live equipment/effects/quest/service/loot/trade/bank and
WORLD/LOC wagon providers, and M2 remain unverified separate obligations.
Controlled ECON, spatial/modifier, SAVE and link participants cannot close them.

## Cleanup and disposition

All three owned commands returned exit 0 before their cleanup. Non-elevated process evidence,
absolute containment and no-reparse checks guarded the three exact owned roots.
Executed sources were archived and every archived entry hash verified before
removing **5,151 reproducible/runtime files, 631,716,833 logical bytes**. Original
child evidence, disposable mod inputs and checkpoints remain at their paths.
No runnable copied build remains. Per-root `IMP017-MOD-REVIEW-COMPACTION.json`
records exact deletions, hashes and retention. No unrelated/older roots, external
classic/reference data, tools or active mods were modified. The existing >8-GiB
backlog review remains recorded in the cleanup guide; this bounded review adds no
full builds and performs no global storage/history scan.

Review documentation and current tracking status are the only tracked changes.
No implementation repair, later task, chat/subagent, branch operation, commit or
push was started. Parent acceptance and authorization to repair F1/F2 remain with
the user. Automated reproductions above are the useful human review entry points;
no additional physical-device action is needed to assess these owner defects.
