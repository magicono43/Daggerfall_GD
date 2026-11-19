# Task: Cross-System Architecture Analysis

Review the completed Daggerfall Unity systems catalogs and architecture assessments.

Your objective is to identify relationships, dependencies, and architectural concerns spanning multiple gameplay systems.

Do not modify source code.

# Investigate

1. Which systems depend on which other systems?

2. Which systems own persistent game data?

3. Which systems share data structures or directly modify another system's state?

4. How do gameplay events propagate between systems?

5. How are item instances, character entities, NPCs, quests, and world locations identified?

6. How do saving and loading interact with major gameplay systems?

7. Which systems rely on game time, location state, or character progression?

8. Which architectural patterns appear consistently, and which systems follow incompatible patterns?

9. Are there circular dependencies, ambiguous ownership boundaries, or unnecessary coupling?

10. Which architectural decisions should be made before implementation begins?

# Proposed Architecture

Recommend a coherent high-level architecture for implementing a similar RPG.

Consider:
- Core game-state management
- Entity identification and lifecycle
- Data definitions and registries
- Gameplay services
- Event communication
- Persistence and version migration
- Time and scheduling
- World simulation
- Content loading
- Testing infrastructure
- Modding support

Define proposed system boundaries and interface contracts at a conceptual level.

Do not design individual classes or methods unless necessary to demonstrate an important architectural decision.

# Dependency Analysis

Produce a directed dependency graph.

Distinguish between:
- Hard prerequisites
- Interface dependencies
- Runtime dependencies
- Content dependencies
- Optional integrations

Identify critical architectural decisions whose later modification would cause substantial rework.

Identify independent systems that could eventually be implemented concurrently.

# Output

Create or update:

docs/analysis/architecture/GLOBAL_ARCHITECTURE_REVIEW.md
docs/analysis/architecture/PROPOSED_SYSTEM_BOUNDARIES.md
docs/analysis/architecture/ARCHITECTURAL_DECISIONS.md
docs/analysis/04_DETAILED_DEPENDENCIES.md

In ARCHITECTURAL_DECISIONS.md, record proposals separately from approved decisions.

Provide:
1. High-priority architecture decisions.
2. Cross-system risks.
3. Recommended dependency boundaries.
4. Areas requiring additional investigation.
5. Potentially parallelizable development domains.

All recommendations must include rationale and trade-offs.

Do not generate implementation tasks yet.