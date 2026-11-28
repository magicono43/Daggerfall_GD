---
name: review-mod-support
description: Review a specific feature's intended customization points through definitions, stable identities, overrides, validation, publication and consumers, with evidence-backed findings. Use for a focused moddability review or feature checkpoint, not as an automatic audit on every edit; repairs require authorization from the user's request.
---

# Review mod support

Determine whether the intended customization actually reaches the feature's real
behavior. Review the named feature and its affected interfaces, not the entire
project. Stay read-only by default unless the user also requests repairs; disposable
verification fixtures may be used within the task's actual permissions.

## Establish the intended extension points

Read the relevant feature contract, owner interfaces and data/mod publication
rules. Identify what is meant to be changeable: labels/art/audio, values and
limits, order, supported identities, rules/conflicts or trusted/restricted scripts.
Separate baseline replacement from adding genuinely new capabilities.

Do not assume that every internal constant must be configurable, every feature
must accept arbitrary schemas, or moddability means allowing unsafe/unsupported
behavior. Judge the promised extension points and the project's explicit priorities.
Identify a material unspecified requirement rather than inventing a new mod API.

## Trace definition to outcome

Follow a representative override from discovery through validation, precedence,
atomic publication/content locking, owner queries and the actual consumer.
Look for hardcoded duplicates, assumed list positions, label-based identities,
fixed counts that contradict exposed limits, cached values that ignore publication
identity, and UI controls that display an override without submitting it correctly.

Inspect the applicable boundaries:

- Stable IDs survive reordering, label changes and supported additions/removals;
  defaults and fallbacks do not silently substitute another identity.
- Schema/range/reference validation rejects unsupported combinations without
  partial publication or an unintended baseline fallback.
- Shipped, package and loose overrides use the approved deterministic precedence;
  corrections match their intended inputs and do not overwrite external changes.
- Consumers use resolved definitions rather than copied vanilla tables. Owner
  validation remains authoritative even when presentation reflects custom values.
- Supported assets preserve their declared geometry/frame/audio contracts, and
  missing optional media does not accidentally become a gameplay prerequisite.
- Persistence/restore, resource lifetime and script permissions remain consistent
  with the supported identities and trust model where those systems are in scope.

Use only the checks relevant to the promised feature. A table format need not
support arbitrary pairwise exceptions if the agreed extension point is narrower;
state that limitation clearly rather than calling it unrestricted customization.

## Gather proportionate evidence

Prefer a small valid override that differs visibly/mechanically from stock, a
representative invalid override, and the precedence or stability case most likely
to expose a defect. Exercise real publication and owner queries when claiming
end-to-end support. Use disposable mod/storage roots; never alter the user's active
mods, original data or reference sources to conduct a review.

Controlled projections can isolate a consumer, but label them honestly: replacing
a cached texture in a fixture does not qualify package discovery/publication;
validating a schema does not prove a live gameplay effect. Separate code-inspected,
fixture-verified and real-integration results. Use existing evidence when fresh;
do not launch all regressions/exports merely because the feature supports mods.

## Deliver findings

Lead with concrete gaps, their affected customization and user-visible consequence.
Support each finding with the relevant file/owner boundary and reproduction or
source evidence. Distinguish defects against the contract, documented limitations,
optional improvements and unverified integration. If no defect is found, state
the reviewed scope and evidence rather than claiming the entire project moddable.

Recommend the smallest correction consistent with existing ownership and APIs.
Do not implement speculative frameworks or change approved mechanics during a
review. When repairs are authorized, use targeted regression coverage and carry
broader obligations to the Implementation checkpoint. Preserve compact evidence,
clean understood disposable fixtures under project policy, and leave commits
and acceptance decisions to the user.
