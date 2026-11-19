# RPG development roadmap

The proposed build order targets Godot 4.7.2. Gameplay authority comes from the [approved feature specifications](../design/GAMEPLAY_DECISIONS.md). Architecture approval and engineering readiness are tracked in the [architecture register](../analysis/architecture/ARCHITECTURAL_DECISIONS.md) and [implementation readiness](IMPLEMENTATION_READINESS.md). The [dependency ledger](../analysis/04_DETAILED_DEPENDENCIES.md) supplies runtime context from the static DFU analysis.

| Order | Milestone | Demonstration |
| --- | --- | --- |
| 1 | [M1 foundation](MILESTONES.md#m1) | Start through setup with validated content, recover from invalid inputs, and reproduce a fixture failure. |
| 2 | [M2 playable room](MILESTONES.md#m2) | Enter a small test encounter through the normal session and placement seams, move, fight, loot, save and reload. |
| 3 | [M3 new character and quest](MILESTONES.md#m3) | Create a character, finish approved opening presentations, walk between a settlement and dungeon, complete a supported quest and restore it from a save. |
| 4 | [M4 wider loops](MILESTONES.md#m4) | Exercise progression/rest, traversal and travel, magic crafting, trade services and law through connected workflows. |
| 5 | [M5 extensibility](MILESTONES.md#m5) | Exercise permitted mod execution, extension compatibility and authoring workflows in an exported candidate. |

## Critical path

All 12 architecture policies are approved. The next planning handoff is the concrete storage and startup contract for IMP-001, followed by session lifecycle and verification contract design in parallel. For the first gameplay gate, place an actor and a supported opponent in an assembled room, verify physical combat and loot, then exercise coherent native restore. Prepare publication and preflight with synthetic snapshots in parallel with encounter work. The M2 restore gate also requires room presentation and the generation-matched preview check. Settlement and quest work adds time, site identities, reward settlement and restore relinking. The full new-character gate also requires validated starting grants, opening quest behavior and required regional state.

M2 is a development checkpoint. Use a bounded authored fixture with controlled actor, time and content through production entry points under DEV-014. Its first pass needs one entry route, one melee exchange, one loot transfer and one native save/restore path. Settle the fixture entry seam and certify the enabled consumers at M2. M3 supplies fresh-character startup. CORE-009 and DEV-007 remain deferred under their recorded scope. Expand content families after their smallest production path has passed integration.

## Conditional concurrency

- Once identity and fixture inputs settle, assign format decoding, localization and media to separate owners. Integrate them at resolved content publication.
- After session/input contracts settle, develop isolated input, actor rules, inventory rules and representative geometry fixtures concurrently. Combat integration waits on all applicable providers.
- Once save envelope and snapshot contracts settle, exercise publication/recovery with synthetic owner snapshots while gameplay owners implement their real projections.
- Once time, identity and operation contracts settle, work concurrently on quest parsing, dialogue projections, faction rules and world assembly with fixtures. Integrate each declared provider before enabling the corresponding verb.
- After feature-owner outcomes stabilize, authoring and inspection tools can reuse the same loaders and validators. Executable mod activation needs its own exported feasibility gate before dependent extension work.

The [task graph](DEPENDENCY_GRAPH.md) defines implementation precedence. The [second pre-implementation audit](PRE_IMPLEMENTATION_AUDIT_2.md) confirms the revised planning status and implementation order. Implementation requires explicit authorization and delivered prerequisites.
