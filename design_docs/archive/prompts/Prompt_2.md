# Task: Detailed System Decomposition

Analyze the following Daggerfall Unity system:

SYSTEM: [INSERT SYSTEM ID AND NAME]

Use the master systems catalog and existing analysis documents as context.

Your objective is to break this system into a comprehensive collection of individually reviewable gameplay features.

Do not modify game code.

# Analysis Requirements

1. Locate and inspect the source code responsible for this system.

2. Identify all relevant subsystems and gameplay features.

3. Document the behavior currently implemented by each feature.

4. Identify relevant classes, methods, data structures, events, and configuration data.

5. Identify dependencies on other systems.

6. Document important edge cases and gameplay interactions.

7. Identify functionality that is incomplete, uncertain, externally defined, or not covered by the inspected source.

8. Identify behavior that may be inherited from original Daggerfall rather than explicitly implemented in Daggerfall Unity.

# Feature Granularity

Break the system into features that are small enough for independent human design review.

Avoid both extremes:
- Features so broad that they require designing an entire major gameplay system.
- Features so granular that they describe trivial methods or internal implementation details.

Prefer features representing distinct gameplay behaviors or coherent groups of closely related rules.

When a feature is too broad, divide it into smaller features.

When features are inseparable, document their relationship rather than creating artificial divisions.

# Feature Documentation

For each feature, include:

- Stable feature ID
- Feature name
- Parent subsystem
- Purpose
- Existing implementation behavior
- Relevant source files and symbols
- Inputs and outputs
- Dependencies
- Important edge cases
- Potential design questions
- Estimated complexity: Small, Medium, or Large
- Analysis confidence: High, Medium, or Low
- Review status: Unreviewed

Create a placeholder section titled "My Intended Specification" for future design decisions.

Do not fill this section with assumptions about my preferred gameplay.

# Documentation Output

Create or update:

docs/analysis/systems/[SYSTEM_ID]_FEATURE_CATALOG.md

Preserve stable identifiers on subsequent revisions.

Cross-reference related features rather than duplicating their documentation.

Update the analysis progress tracker and any relevant master catalog entries.

# Quality Control

Before finishing:
- Check whether important functionality has been overlooked.
- Identify features whose scope is too broad.
- Verify that source references are accurate.
- Distinguish observed behavior from interpretation.
- Record unresolved questions.

Report the number of features identified, areas of uncertainty, and recommended next review steps.

Do not begin architecture redesign or implementation.