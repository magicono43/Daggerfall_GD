# Implementation dependencies

**Final IMP-006 acceptance, 2026-11-20:** The user confirmed increment 3 complete;
all three assigned increments are accepted ([evidence](evidence/IMP-006-increment-3-2026-11-20.md)).
IMP-014 now has all listed prerequisites delivered. IMP-016/017/032 clear their
IMP-006 edge and retain other prerequisites. IMP-007 was already cleared by
IMP-005. Its requested handoff prompt is preparation, not implementation
authorization. No next IMP is started; remaining real-owner/M1/executable/SAVE
gates and the documented release limits are unchanged. Earlier notes are historical.


**IMP-006 increment 3, 2026-11-20:** The user accepted increment 2 and authorized
the bounded formula registry. All three assigned increments are implemented and
verified; [increment-3 evidence](evidence/IMP-006-increment-3-2026-11-20.md) records
real MOD/DATA/CORE integration, controlled providers, checks and release limits.
Final IMP-006 acceptance is pending. No dependent edge clears and no next IMP is
started. Production hook/executable/SAVE and named M1 real-owner gates remain open.
Earlier increment handoffs below retain their recorded acceptance context.


**IMP-006 increment 2, 2026-11-20:** The user accepted increment 1 and authorized
increment 2. Session isolation/lifetime and controlled retained-result integration
are implemented and verified; see [execution evidence](evidence/IMP-006-increment-2-2026-11-20.md).
Increment 2 awaits user acceptance. Increment 3 is not started. IMP-006 remains
partially delivered; no dependent prerequisite edge or real-owner/M1 gate clears.
Earlier handoff notes below retain their original acceptance context.


**IMP-006 increment 1, 2026-11-20:** Numeric implementation verified;
awaits user acceptance; see [execution evidence](evidence/IMP-006-increment-1-2026-11-20.md).
The separate acceptance gates for lifecycle and formula dispatch remain binding.
IMP-006 is not fully delivered and no dependent prerequisite edge clears.
Earlier authorization/readiness statements below retain historical context.


2026-11-20, final IMP-005 acceptance: all assigned increments are user-accepted
([evidence](evidence/IMP-005-increment-3-2026-11-20.md)). Its edge clears for
IMP-007/008/009/010/028/050. IMP-007/008/009/010 now have all listed prerequisites
delivered. IMP-028 still requires IMP-009/014; IMP-050 still requires IMP-028.
IMP-006 was already cleared by IMP-003 and is not dependent on IMP-005. All new
tasks still require implementation authorization; none was begun. Edges and
remaining M1/domain/executable/SAVE gates are unchanged.

2026-11-20, increment-3 update: user acceptance/authorization cleared the separate
increment-2 gate. IMP-005's definition publication/menu lock is now implemented
with [execution evidence](evidence/IMP-005-increment-3-2026-11-20.md), pending final
user acceptance. Existing dependency edges remain unchanged and are not declared
cleared yet; M1 still retains real domain/executable/SAVE integration obligations.

2026-11-20, increment-2 update: the user accepted IMP-005 increment 1 and authorized
dependency planning, now implemented with
[separate evidence](evidence/IMP-005-increment-2-2026-11-20.md). No dependency edge
changes: increment 3/publication is not authorized or delivered. IMP-005 is not
complete and no downstream prerequisite clears from these partial increments.

2026-11-20: IMP-005's authorized discovery/selection increment is implemented
([evidence](evidence/IMP-005-2026-11-20.md)), pending user acceptance. Planning and
publication increments retain their separate gates. IMP-005 is not delivered as
a whole; no downstream edge is cleared. Existing dependency edges are unchanged.

An arrow runs from prerequisite to dependent. The milestone diagram groups work. Every direct task edge is listed below. The [detailed dependency ledger](../analysis/04_DETAILED_DEPENDENCIES.md) records runtime and content relationships that may be reciprocal. A task edge blocks an implementation handoff. A runtime peer can be integrated later under an approved contract and fixture when the relevant milestone permits it.

```mermaid
flowchart LR
  Decisions[Interface and fixture design under approved architecture] --> M1[Foundation]
  M1 --> M2[Playable room and save]
  M2 --> M3[New character and quest]
  M3 --> M4[Broader RPG loops]
  M4 --> M5[Extensibility and release tooling]
```

## Direct task prerequisites

Execution update, 2026-11-19: IMP-001's assigned Windows startup increment is
delivered ([evidence](evidence/IMP-001-2026-11-19.md)), clearing that prerequisite
for IMP-002/003. Edges are retained for traceability. M1 real-provider checks and
all other prerequisites remain open; dispatch still requires authorization.

IMP-002's assigned session/modal shell increment is also delivered on 2026-11-19
([evidence](evidence/IMP-002-2026-11-19.md)). That prerequisite is cleared for
IMP-005/011/014/024/013/022/052. At that delivery, IMP-003 had all prerequisites
delivered and awaited authorization. No other dependent became fully
dispatchable from IMP-002 alone. Named real-provider checks remain
open, and the dependency edges below are unchanged.

IMP-003's authorized M1 verification increment is delivered on 2026-11-19
([evidence](evidence/IMP-003-2026-11-19.md)). Its edge clears for IMP-004/006/011/022.
IMP-004, IMP-006 and IMP-011 now have all listed prerequisites delivered; each
requires authorization. IMP-022 still requires IMP-017. Staged real-provider
verification and M1 DATA/MOD integration remain open. No dependency edge changed.

IMP-004's explicitly authorized Windows foundation reader increment is delivered
on 2026-11-19 ([evidence](evidence/IMP-004-2026-11-19.md)). Its edge clears for
IMP-005, which also has IMP-002 delivered and is now fully prerequisite-cleared.
IMP-006/011 remain prerequisite-cleared. Real IMP-005 publication and later enabled
adapter/schema/owner gates remain open. No dependency edge changed and no next
task is authorized by this handoff.

| Task | Must complete first |
| --- | --- |
| [IMP-001](tasks/IMP-001.md) | Interface and fixture gates only |
| [IMP-002](tasks/IMP-002.md) | [IMP-001](tasks/IMP-001.md) |
| [IMP-003](tasks/IMP-003.md) | [IMP-001](tasks/IMP-001.md) |
| [IMP-004](tasks/IMP-004.md) | [IMP-001](tasks/IMP-001.md), [IMP-003](tasks/IMP-003.md) |
| [IMP-006](tasks/IMP-006.md) | [IMP-003](tasks/IMP-003.md) |
| [IMP-005](tasks/IMP-005.md) | [IMP-002](tasks/IMP-002.md), [IMP-004](tasks/IMP-004.md) |
| [IMP-007](tasks/IMP-007.md) | [IMP-005](tasks/IMP-005.md) |
| [IMP-008](tasks/IMP-008.md) | [IMP-005](tasks/IMP-005.md) |
| [IMP-009](tasks/IMP-009.md) | [IMP-005](tasks/IMP-005.md) |
| [IMP-010](tasks/IMP-010.md) | [IMP-005](tasks/IMP-005.md) |
| [IMP-011](tasks/IMP-011.md) | [IMP-002](tasks/IMP-002.md), [IMP-003](tasks/IMP-003.md) |
| [IMP-014](tasks/IMP-014.md) | [IMP-002](tasks/IMP-002.md), [IMP-006](tasks/IMP-006.md) |
| [IMP-016](tasks/IMP-016.md) | [IMP-006](tasks/IMP-006.md), [IMP-009](tasks/IMP-009.md) |
| [IMP-017](tasks/IMP-017.md) | [IMP-006](tasks/IMP-006.md), [IMP-009](tasks/IMP-009.md) |
| [IMP-024](tasks/IMP-024.md) | [IMP-002](tasks/IMP-002.md), [IMP-008](tasks/IMP-008.md), [IMP-007](tasks/IMP-007.md) |
| [IMP-061](tasks/IMP-061.md) | [IMP-008](tasks/IMP-008.md), [IMP-010](tasks/IMP-010.md) |
| [IMP-013](tasks/IMP-013.md) | [IMP-002](tasks/IMP-002.md), [IMP-008](tasks/IMP-008.md), [IMP-010](tasks/IMP-010.md), [IMP-061](tasks/IMP-061.md) |
| [IMP-015](tasks/IMP-015.md) | [IMP-007](tasks/IMP-007.md), [IMP-009](tasks/IMP-009.md), [IMP-016](tasks/IMP-016.md) |
| [IMP-018](tasks/IMP-018.md) | [IMP-016](tasks/IMP-016.md), [IMP-017](tasks/IMP-017.md) |
| [IMP-022](tasks/IMP-022.md) | [IMP-002](tasks/IMP-002.md), [IMP-003](tasks/IMP-003.md), [IMP-017](tasks/IMP-017.md) |
| [IMP-012](tasks/IMP-012.md) | [IMP-011](tasks/IMP-011.md), [IMP-013](tasks/IMP-013.md), [IMP-016](tasks/IMP-016.md) |
| [IMP-019](tasks/IMP-019.md) | [IMP-011](tasks/IMP-011.md), [IMP-012](tasks/IMP-012.md), [IMP-018](tasks/IMP-018.md) |
| [IMP-020](tasks/IMP-020.md) | [IMP-012](tasks/IMP-012.md), [IMP-014](tasks/IMP-014.md), [IMP-016](tasks/IMP-016.md), [IMP-018](tasks/IMP-018.md) |
| [IMP-021](tasks/IMP-021.md) | [IMP-013](tasks/IMP-013.md), [IMP-017](tasks/IMP-017.md), [IMP-019](tasks/IMP-019.md), [IMP-020](tasks/IMP-020.md) |
| [IMP-023](tasks/IMP-023.md) | [IMP-013](tasks/IMP-013.md), [IMP-019](tasks/IMP-019.md), [IMP-021](tasks/IMP-021.md), [IMP-022](tasks/IMP-022.md), [IMP-024](tasks/IMP-024.md) |
| [IMP-025](tasks/IMP-025.md) | [IMP-010](tasks/IMP-010.md), [IMP-012](tasks/IMP-012.md), [IMP-013](tasks/IMP-013.md), [IMP-024](tasks/IMP-024.md), [IMP-020](tasks/IMP-020.md) |
| [IMP-028](tasks/IMP-028.md) | [IMP-005](tasks/IMP-005.md), [IMP-009](tasks/IMP-009.md), [IMP-014](tasks/IMP-014.md) |
| [IMP-032](tasks/IMP-032.md) | [IMP-006](tasks/IMP-006.md), [IMP-009](tasks/IMP-009.md), [IMP-014](tasks/IMP-014.md), [IMP-016](tasks/IMP-016.md) |
| [IMP-033](tasks/IMP-033.md) | [IMP-007](tasks/IMP-007.md), [IMP-014](tasks/IMP-014.md), [IMP-018](tasks/IMP-018.md), [IMP-019](tasks/IMP-019.md) |
| [IMP-027](tasks/IMP-027.md) | [IMP-007](tasks/IMP-007.md), [IMP-013](tasks/IMP-013.md), [IMP-025](tasks/IMP-025.md) |
| [IMP-035](tasks/IMP-035.md) | [IMP-008](tasks/IMP-008.md), [IMP-014](tasks/IMP-014.md), [IMP-024](tasks/IMP-024.md), [IMP-025](tasks/IMP-025.md) |
| [IMP-057](tasks/IMP-057.md) | [IMP-025](tasks/IMP-025.md) |
| [IMP-058](tasks/IMP-058.md) | [IMP-023](tasks/IMP-023.md), [IMP-033](tasks/IMP-033.md) |
| [IMP-062](tasks/IMP-062.md) | [IMP-014](tasks/IMP-014.md), [IMP-032](tasks/IMP-032.md) |
| [IMP-026](tasks/IMP-026.md) | [IMP-023](tasks/IMP-023.md), [IMP-025](tasks/IMP-025.md), [IMP-057](tasks/IMP-057.md) |
| [IMP-034](tasks/IMP-034.md) | [IMP-033](tasks/IMP-033.md), [IMP-058](tasks/IMP-058.md) |
| [IMP-037](tasks/IMP-037.md) | [IMP-017](tasks/IMP-017.md), [IMP-027](tasks/IMP-027.md), [IMP-032](tasks/IMP-032.md), [IMP-062](tasks/IMP-062.md) |
| [IMP-029](tasks/IMP-029.md) | [IMP-021](tasks/IMP-021.md), [IMP-026](tasks/IMP-026.md), [IMP-027](tasks/IMP-027.md), [IMP-028](tasks/IMP-028.md) |
| [IMP-030](tasks/IMP-030.md) | [IMP-007](tasks/IMP-007.md), [IMP-027](tasks/IMP-027.md), [IMP-029](tasks/IMP-029.md), [IMP-032](tasks/IMP-032.md) |
| [IMP-031](tasks/IMP-031.md) | [IMP-029](tasks/IMP-029.md), [IMP-030](tasks/IMP-030.md), [IMP-032](tasks/IMP-032.md), [IMP-037](tasks/IMP-037.md) |
| [IMP-038](tasks/IMP-038.md) | [IMP-023](tasks/IMP-023.md), [IMP-026](tasks/IMP-026.md), [IMP-029](tasks/IMP-029.md), [IMP-030](tasks/IMP-030.md), [IMP-032](tasks/IMP-032.md), [IMP-031](tasks/IMP-031.md) |
| [IMP-036](tasks/IMP-036.md) | [IMP-015](tasks/IMP-015.md), [IMP-023](tasks/IMP-023.md), [IMP-029](tasks/IMP-029.md), [IMP-030](tasks/IMP-030.md), [IMP-032](tasks/IMP-032.md), [IMP-033](tasks/IMP-033.md), [IMP-035](tasks/IMP-035.md), [IMP-038](tasks/IMP-038.md), [IMP-058](tasks/IMP-058.md), [IMP-037](tasks/IMP-037.md), [IMP-062](tasks/IMP-062.md) |
| [IMP-039](tasks/IMP-039.md) | [IMP-014](tasks/IMP-014.md), [IMP-019](tasks/IMP-019.md), [IMP-023](tasks/IMP-023.md), [IMP-033](tasks/IMP-033.md), [IMP-058](tasks/IMP-058.md) |
| [IMP-041](tasks/IMP-041.md) | [IMP-019](tasks/IMP-019.md), [IMP-020](tasks/IMP-020.md), [IMP-033](tasks/IMP-033.md), [IMP-058](tasks/IMP-058.md) |
| [IMP-042](tasks/IMP-042.md) | [IMP-013](tasks/IMP-013.md), [IMP-019](tasks/IMP-019.md), [IMP-023](tasks/IMP-023.md), [IMP-033](tasks/IMP-033.md), [IMP-058](tasks/IMP-058.md) |
| [IMP-043](tasks/IMP-043.md) | [IMP-019](tasks/IMP-019.md), [IMP-020](tasks/IMP-020.md), [IMP-027](tasks/IMP-027.md), [IMP-032](tasks/IMP-032.md), [IMP-037](tasks/IMP-037.md), [IMP-042](tasks/IMP-042.md) |
| [IMP-047](tasks/IMP-047.md) | [IMP-033](tasks/IMP-033.md), [IMP-034](tasks/IMP-034.md), [IMP-042](tasks/IMP-042.md) |
| [IMP-049](tasks/IMP-049.md) | [IMP-014](tasks/IMP-014.md), [IMP-020](tasks/IMP-020.md), [IMP-025](tasks/IMP-025.md), [IMP-039](tasks/IMP-039.md) |
| [IMP-064](tasks/IMP-064.md) | [IMP-033](tasks/IMP-033.md), [IMP-034](tasks/IMP-034.md), [IMP-042](tasks/IMP-042.md) |
| [IMP-063](tasks/IMP-063.md) | [IMP-043](tasks/IMP-043.md) |
| [IMP-044](tasks/IMP-044.md) | [IMP-023](tasks/IMP-023.md), [IMP-039](tasks/IMP-039.md), [IMP-043](tasks/IMP-043.md), [IMP-063](tasks/IMP-063.md) |
| [IMP-045](tasks/IMP-045.md) | [IMP-014](tasks/IMP-014.md), [IMP-023](tasks/IMP-023.md), [IMP-037](tasks/IMP-037.md), [IMP-043](tasks/IMP-043.md), [IMP-063](tasks/IMP-063.md) |
| [IMP-048](tasks/IMP-048.md) | [IMP-034](tasks/IMP-034.md), [IMP-039](tasks/IMP-039.md), [IMP-044](tasks/IMP-044.md), [IMP-058](tasks/IMP-058.md) |
| [IMP-060](tasks/IMP-060.md) | [IMP-026](tasks/IMP-026.md), [IMP-037](tasks/IMP-037.md), [IMP-039](tasks/IMP-039.md), [IMP-045](tasks/IMP-045.md) |
| [IMP-040](tasks/IMP-040.md) | [IMP-012](tasks/IMP-012.md), [IMP-025](tasks/IMP-025.md), [IMP-033](tasks/IMP-033.md), [IMP-060](tasks/IMP-060.md) |
| [IMP-046](tasks/IMP-046.md) | [IMP-034](tasks/IMP-034.md), [IMP-037](tasks/IMP-037.md), [IMP-039](tasks/IMP-039.md), [IMP-040](tasks/IMP-040.md), [IMP-045](tasks/IMP-045.md), [IMP-047](tasks/IMP-047.md), [IMP-060](tasks/IMP-060.md) |
| [IMP-059](tasks/IMP-059.md) | [IMP-025](tasks/IMP-025.md), [IMP-035](tasks/IMP-035.md), [IMP-039](tasks/IMP-039.md), [IMP-040](tasks/IMP-040.md), [IMP-045](tasks/IMP-045.md), [IMP-049](tasks/IMP-049.md) |
| [IMP-050](tasks/IMP-050.md) | [IMP-005](tasks/IMP-005.md), [IMP-028](tasks/IMP-028.md) |
| [IMP-052](tasks/IMP-052.md) | [IMP-002](tasks/IMP-002.md), [IMP-019](tasks/IMP-019.md), [IMP-020](tasks/IMP-020.md), [IMP-024](tasks/IMP-024.md), [IMP-026](tasks/IMP-026.md), [IMP-032](tasks/IMP-032.md) |
| [IMP-054](tasks/IMP-054.md) | [IMP-008](tasks/IMP-008.md), [IMP-013](tasks/IMP-013.md), [IMP-025](tasks/IMP-025.md) |
| [IMP-051](tasks/IMP-051.md) | [IMP-023](tasks/IMP-023.md), [IMP-031](tasks/IMP-031.md), [IMP-034](tasks/IMP-034.md), [IMP-042](tasks/IMP-042.md), [IMP-050](tasks/IMP-050.md), [IMP-044](tasks/IMP-044.md), [IMP-046](tasks/IMP-046.md), [IMP-047](tasks/IMP-047.md), [IMP-059](tasks/IMP-059.md), [IMP-060](tasks/IMP-060.md), [IMP-064](tasks/IMP-064.md) |
| [IMP-053](tasks/IMP-053.md) | [IMP-028](tasks/IMP-028.md), [IMP-038](tasks/IMP-038.md), [IMP-052](tasks/IMP-052.md) |
| [IMP-055](tasks/IMP-055.md) | [IMP-026](tasks/IMP-026.md), [IMP-051](tasks/IMP-051.md), [IMP-054](tasks/IMP-054.md), [IMP-057](tasks/IMP-057.md) |
| [IMP-056](tasks/IMP-056.md) | [IMP-007](tasks/IMP-007.md), [IMP-051](tasks/IMP-051.md) |

## Runtime cycles and staged checks

| Collaboration | Early boundary | Later closure |
| --- | --- | --- |
| CORE, UI and SAVE | Scope input eligibility, requests and completion before creating a replacement session. | Real restore publishes completion only when owners and placement agree. |
| WORLD, LOC and MOVE | Validate geometry and pose using a bounded local fixture. Freeze coordinate and rebase contracts first. | Stage streamed collision and seam readiness, then restore exterior and discovery state. |
| NPC, COMBAT, CHAR, ITEM and MAGIC | Exercise baseline physical attack and non-enchanted loot with an agreed effect query. NPC intent and COMBAT commitment need a joint trace. | Integrate spell effects, enchanted equipment, enemy ranged delivery and death/quest receipts. |
| QUEST, NPC, FACT, ECON and owner actions | Register parseable grammar, execute fixture verbs, then bind real sites, actors and eligible offers. | Enable rewards, guild offers, opening content and restoration against real owners. Later legal, travel or magic service verbs require the relevant M4 provider. |
| TIME, ECON, FACT and LAW | Establish time advancement and regional queries, then route incidents through an explicit contract. | Integrate real default events when the ledger exists and verify exactly one legal consequence. |
| DATA, MOD, CORE and owner registration | Validate identity, provider order and publication through the data-only seam. | Integrate executable capabilities, custom registrations and mod payload compatibility under M5. |
| DEV-014 and implementation fixtures | Establish independent invocation and reporting early with a fixture check. | Add enemy/restore production scenarios at M2 and quest fault/retry at M3. |
 
The table admits a topological order across all 64 tasks. Edge ordering is a dependency check. Calendar critical path and staffing require effort estimates, approved contracts and observed integration cost.
