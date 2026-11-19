# Role

Act as a senior game systems analyst, software architect, and technical documentation specialist.

# Project Goal

I am using the Daggerfall Unity open-source codebase as a reference for planning a similar recreation in the Godot Engine v4.7.2.

My eventual goal is to create a comprehensive, structured blueprint that allows me to review gameplay features individually, define my own specifications, evaluate improved architectures, and direct coding agents to implement the game systematically.

This phase is strictly repository reconnaissance and system discovery.

Do not implement, refactor, or modify game code.

# Tasks

1. Inspect the repository structure, main assemblies, project organization, and major gameplay components.

2. Identify all major gameplay and supporting systems, including but not limited to:
   - Character creation and progression
   - Attributes, skills, and leveling
   - Player movement and interaction
   - Combat and damage
   - Magic and spell effects
   - Items, inventory, and equipment
   - NPC behavior and dialogue
   - Quests and quest generation
   - Factions and reputation
   - Crime and legal systems
   - Economy, merchants, and services
   - World generation and exploration
   - Dungeons and locations
   - Time, weather, and travel
   - User interface
   - Saving, loading, and persistence
   - Data definitions and content loading
   - Modding and extensibility
   - Testing and debugging infrastructure

3. Organize identified functionality into a hierarchical systems catalog.

4. Identify important source directories, classes, interfaces, managers, data structures, and existing architectural patterns.

5. Record how major systems interact at a high level.

6. Identify functionality whose behavior depends on original Daggerfall data, Unity assets, external libraries, or other sources that cannot be established through code inspection alone.

# Documentation Requirements

Create the following files under docs/analysis/:

- 00_REPOSITORY_OVERVIEW.md
- 01_MASTER_SYSTEMS_CATALOG.md
- 02_INITIAL_DEPENDENCY_OVERVIEW.md
- 03_ANALYSIS_PROGRESS.md

The master catalog should assign stable system identifiers such as:

CHAR — Character Systems
COMBAT — Combat Systems
ITEM — Item Systems
MAGIC — Magic Systems
QUEST — Quest Systems

Use consistent identifiers throughout future documentation.

For each major system, provide:
- System ID and name
- Purpose
- Subsystems identified so far
- Primary source locations
- Major dependencies
- Estimated analysis complexity
- Confidence in coverage

# Quality Requirements

- Base findings on actual inspected source code.
- Cite relevant file paths and symbols.
- Distinguish verified facts, inferences, and unknowns.
- Do not invent systems or mechanics.
- Do not confuse absence from inspected files with confirmed absence from the project.
- Record the repository revision or Git commit analyzed.
- Do not attempt detailed analysis of every feature in this pass.
- Avoid redundant or unnecessarily verbose documentation.

# Completion Criteria

Finish with:
1. A comprehensive high-level systems catalog.
2. A high-level dependency overview.
3. A list of areas requiring deeper investigation.
4. A recommended order for analyzing systems.
5. A summary of coverage limitations.

Do not begin subsequent analysis phases automatically.