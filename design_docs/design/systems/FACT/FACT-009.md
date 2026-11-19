# FACT-009 — Guild group and variant resolution

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-009-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-009-interview-decisions).

## Gameplay purpose and intended experience

A guildhall, temple, or knightly order recognizes membership in the organization it represents. A player who belongs to one temple can visit another as a nonmember and see the offers and services available to that audience.

## Confirmed requirements

- Stock rules allow one temple deity and one knightly order at a time within the applicable membership set. Validated mod policies can allow multiple memberships in a group. Each variant keeps its own membership and rank.
- Resolve an authorized provider to a validated guild and variant, then check for an exact membership in the applicable set. A valid provider with no matching membership supplies its own nonmember context. Missing or ambiguous required mappings make the guild interaction unavailable. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-009-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Guilds/GuildManager.cs` stores separate ordinary and vampire membership dictionaries, each keyed by guild group. `GetGuild` checks deity or order when a building faction is supplied and returns nonmember behavior on mismatch. `GetGuildGroup` excludes the shop faction numbered 510 and can use a deity's first child to obtain its guild group. `Temple.GetDivine` and `KnightlyOrder.GetOrder` map classic faction records to variants. `RegisterCustomGuild` and `CreateGuildObj` use registered types and reflected constructors. Variant lookups later assume the corresponding Temple or KnightlyOrder subtype. These findings come from static source inspection.

## Detailed rules and behaviors

1. Represent the guild group as a classification and resolve the organization by stable guild ID and variant identity where applicable. Several halls can represent the same organization. A faction mapping can provide the standing target under FACT-001, while the provider context determines which organization the interaction represents.
2. Validate a provider's applicable mapping before checking membership. Use the authorized building, actor, or service context for the current interaction. Return the exact member context with its rank when found. A valid provider with no exact membership returns that organization's nonmember context. Membership in a different variant does not grant its rank, member offers, or member benefits.
3. A stock group with multiple temple or order variants permits at most one active membership in that group within the applicable set. A validated mod policy may explicitly permit more. Maintain independent rank and membership facts for each permitted variant. FACT-010 owns joining and leaving, and FACT-011 owns rank transitions.
4. A group-wide query can report membership presence or enumerate matches. A consumer that needs one organization must supply an exact identity or a separately authorized selection rule. Content order cannot choose a member context from an ambiguous result.
5. An invalid or ambiguous required mapping returns an unavailable result. A location with no guild provider has no guild interaction. A valid nonmember context still follows the provider's eligibility and service rules.

## Approved integration defaults

- Support ordinary and vampire membership sets as distinct contexts where the applicable gameplay policy uses them. FACT receives the authorized active set from the character state and transformation integration. Resolution reads only that set. Switching context does not copy, merge, or erase memberships. MAGIC-028 and the owning membership features determine transition consequences.
- Keep legacy faction number exceptions and deity or order translations in the import adapter. Validate native provider mappings and any registered behavior against the declared guild and variant contract before publishing them. Resolve behavior through a validated definition or provider contract.

## Required data, inputs, outputs, and events

Use stable guild group, guild, variant, provider, faction, and membership set identities. Retain authorized provider mappings, membership limits and per-variant membership and rank. Inputs include the provider and applicable character context, or an explicit group query. Outputs distinguish exact member, valid nonmember, no guild provider, and unavailable required context. Resolution emits no membership event. Join, rank, and service owners publish their own outcomes.

## Formulas, configuration, and balancing

Stock temple and knightly order group limits are one active membership each per applicable set. Mods may declare alternative limits and eligible variants. Join prerequisites, rank calculations and cross-membership benefit stacking belong to their respective features.

## Cross-system interactions

FACT-001 supplies authorized faction context. NPC and LOC supply the actor, service, and establishment context. QUEST-002 uses the exact provider's member or nonmember audience, variant, rank, and applicable standing. FACT-010/011 own join and rank changes. MAGIC-028 supplies applicable transformation context. DATA and MOD validate mappings and policies. SAVE and FACT-018 own restore compatibility.

## Edge cases and failure conditions

- Temple A membership yields Temple B's nonmember context at a valid Temple B provider. An invalid Temple B mapping yields unavailable.
- A stock shop with misleading legacy guild metadata cannot grant Fighters Guild access. The classic adapter handles that record explicitly.
- Two authorized halls of the same variant resolve the same membership. Two permitted variants in one group keep independent ranks.
- Missing required behavior, ambiguous mapping, or incompatible restored membership receives explicit owner recovery. A different guild in the same group cannot substitute for it.

## Save/load considerations

Persist memberships by stable organization, variant and applicable set, with rank and other owner data. Validate mappings and restored state before dependent queries resume. A mod removal or a change to an exclusivity policy requires supported migration or an explicit compatibility outcome. Loading preserves separate sets and cannot grant new membership.

## Technical constraints and consistency review

Keep provider lookup read-only and validate mappings independently of membership. The draft preserves FACT-001's authorized provider context, QUEST-002's deity and audience checks, and MAGIC-028's explicit transformation consequences.

## Acceptance criteria

1. A stock membership set can contain one temple deity and one knightly order. A validated mod policy can admit multiple variants and retain each rank independently.
2. The same variant at two authorized halls resolves the same membership. A different variant gets the requested provider's nonmember context.
3. A missing or ambiguous required provider mapping makes guild interaction unavailable. A legacy shop excluded by the adapter cannot resolve as a guildhall.
4. Queries scoped to different membership sets return only their own memberships. Reload preserves each set and variant without duplication.

## Outstanding questions

Exact key formats, the full classic mapping inventory, transition consequences, and save migrations remain owner integration details.
