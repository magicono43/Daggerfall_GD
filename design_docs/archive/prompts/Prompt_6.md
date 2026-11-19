# Task: Development Roadmap and Implementation Backlog

Act as a senior technical lead and game development project planner.

Using the approved game specifications, architecture decisions, and dependency documentation, produce a structured development roadmap for implementing the RPG.

The roadmap should support development primarily through autonomous coding agents such as Codex.

Do not implement code.

# Phase 1: Dependency-Ordered Roadmap

1. Identify foundational technical requirements.
2. Identify major development milestones.
3. Establish dependencies between features.
4. Identify critical-path systems.
5. Organize development around playable vertical slices.
6. Identify systems that can be implemented independently.
7. Recommend integration and validation checkpoints.

Prioritize reaching a functional gameplay loop early rather than completing every system in isolation.

# Phase 2: Implementation Task Decomposition

Convert approved features into agent-ready implementation tasks.

Each task must contain:

- Unique task ID
- Related feature IDs
- Objective
- Relevant specifications
- Prerequisites
- Expected functionality
- Proposed integration points
- Constraints
- Acceptance criteria
- Automated verification requirements
- Manual testing requirements
- Estimated complexity
- Task status

Tasks should be scoped so that a coding agent can complete and verify them independently when practical.

Avoid tasks requiring unrelated architectural changes.

Avoid breaking tasks into trivial operations that provide no independent verification value.

# Phase 3: Implementation Readiness

For every task, verify:

1. The relevant gameplay specification is approved.
2. Required architectural decisions are resolved.
3. Dependencies are identified.
4. Required interfaces are defined.
5. Acceptance criteria are measurable.
6. Testing expectations are clear.
7. No essential design decisions are left for the coding agent to invent.

If any condition is not met, mark the task BLOCKED and document the missing information.

Do not generate implementation tasks based on unapproved assumptions.

# Phase 4: Output

Create:

docs/development/ROADMAP.md
docs/development/MILESTONES.md
docs/development/TASK_BACKLOG.md
docs/development/DEPENDENCY_GRAPH.md
docs/development/IMPLEMENTATION_READINESS.md

Store detailed task specifications under:

docs/development/tasks/

Maintain links between each task, its approved feature specification, and relevant architectural decisions.

# Final Review

Check the plan for:
- Missing dependencies
- Circular prerequisites
- Unreasonably large tasks
- Poorly defined acceptance criteria
- Integration risks
- Conflicting specifications
- Unrealistic parallelization assumptions

Summarize the recommended implementation order.

Do not begin implementation without explicit authorization.