# Task: Architectural Evaluation

Evaluate the implementation architecture of the following Daggerfall Unity system:

SYSTEM: [INSERT SYSTEM ID AND NAME]

Use its completed feature catalog and inspect the relevant source code.

The objective is to identify architectural strengths, weaknesses, and potential improvements for implementing similar functionality in a new, maintainable RPG.

This is an analysis task only. Do not modify game code.

# Analysis Requirements

For each relevant subsystem:

1. Describe the existing architecture and responsibility boundaries.

2. Identify the important classes, interfaces, data models, and communication patterns.

3. Document architectural strengths worth preserving.

4. Investigate potential weaknesses involving:
   - Tight coupling
   - Excessive class responsibilities
   - Duplicated logic
   - Global or shared mutable state
   - Inconsistent data ownership
   - Hardcoded gameplay definitions
   - Difficult-to-test behavior
   - Performance and memory overhead
   - Serialization and save compatibility
   - Error handling
   - Extensibility and modding
   - Dependencies on engine-specific functionality

5. Propose improvements where justified.

6. Consider alternative approaches and explain trade-offs.

7. Identify other systems affected by each proposed change.

8. Assess whether the improvement should be established early or can safely be deferred.

# Design Priorities

Favor:
- Clear responsibility boundaries
- Explicit data ownership
- Modular and reusable systems
- Data-driven content definitions
- Testable gameplay calculations
- Separation of simulation and presentation
- Stable public interfaces
- Versioned persistence where necessary
- Efficient runtime behavior
- Straightforward debugging
- Architecture that coding agents can understand and modify locally

However, do not introduce unnecessary abstractions, layers, interfaces, managers, or design patterns.

Prefer the simplest architecture that meets the project's actual requirements.

# Recommendations

For each proposed improvement, document:

- Recommendation ID
- Related feature IDs
- Existing approach
- Evidence from source code
- Observed problem or potential risk
- Proposed architecture
- Expected benefits
- Disadvantages and trade-offs
- Implementation complexity
- Cross-system impact
- Priority: Critical, Recommended, Optional
- Confidence in the assessment
- Decision status: Proposed

Clearly distinguish confirmed problems from hypothetical risks.

Do not assume that Daggerfall Unity's existing architecture is deficient simply because it is older or uses unfamiliar patterns.

# Output

Create:

docs/analysis/architecture/[SYSTEM_ID]_ARCHITECTURE_REVIEW.md

Include a concise comparison of the existing and proposed architectures.

Reference relevant source files and feature IDs.

Do not alter previously approved design decisions.

Do not automatically accept or implement proposed improvements.

Update the analysis progress tracker when finished.