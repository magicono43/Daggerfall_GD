# Development documentation

Start with the repository [AGENTS.md](../AGENTS.md), then the assigned [IMP task](development/tasks/). Read its linked requirements, approved decisions, prerequisites and contracts. Expand into adjacent documents when needed; each task does not require reading the entire catalog.

## Authority and purpose

| Location | Purpose |
| --- | --- |
| [Gameplay specifications](design/systems/) and [gameplay decisions](design/GAMEPLAY_DECISIONS.md) | Approved gameplay behavior and recorded approvals. |
| [Architectural decisions](analysis/architecture/ARCHITECTURAL_DECISIONS.md) | Approved cross-system architecture. Review proposals retain their recorded status. |
| [Implementation tasks](development/tasks/) | Assigned scope, prerequisites, interfaces and acceptance checks. Linked approved requirements govern behavior. |
| [Development contracts](development/) | Task-specific refinements, including input defaults, randomness, media formats and runtime selections. |
| [Source analysis](analysis/) | DFU evidence, dependency analysis and architecture reviews supporting the approved requirements. Source behavior alone does not approve a mechanic. |
| [Archive](archive/) | Historical prompts and the superseded first audit, retained for provenance. These do not establish current readiness. |

If documents materially conflict, follow the clarification rules in AGENTS.md rather than silently changing approved gameplay or architecture.

## Planning and delivery

- [Roadmap](development/ROADMAP.md): overall delivery direction.
- [Task backlog](development/TASK_BACKLOG.md): task scope and handoff rules.
- [Dependency graph](development/DEPENDENCY_GRAPH.md): implementation prerequisites and order.
- [Milestones](development/MILESTONES.md): progressively playable integration and acceptance gates.
- [Implementation readiness](development/IMPLEMENTATION_READINESS.md) and [second audit](development/PRE_IMPLEMENTATION_AUDIT_2.md): current planning baseline. READY means sufficiently specified; execution still requires authorization, delivered prerequisites and the required environment.
- [First audit](archive/PRE_IMPLEMENTATION_AUDIT.md): historical findings, superseded by the second audit.
- [Original prompts](archive/prompts/): historical instructions used to produce the documentation.

## Repository layout

Paths below are relative to the repository root:

- `main_project/`: Godot project and implementation. Godot `res://` paths resolve here.
- `design_docs/`: this documentation tree.
- `reference_material/`: read-only reference source, including DFU.
- `base_data_files/`: read-only classic game data.

Record implementation progress, verification evidence and remaining integration obligations in the affected task and delivery records. Preserve approval history and stable feature/task IDs. Use GitHub Desktop review and publishing as specified in AGENTS.md.
