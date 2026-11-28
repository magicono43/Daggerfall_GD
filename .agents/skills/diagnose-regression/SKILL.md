---
name: diagnose-regression
description: Reproduce and isolate behavior that previously worked and now fails, distinguish product defects from fixture or environment drift, and verify an authorized repair at the responsible boundary. Use for focused regression investigations rather than routine feature delivery or cosmetic polish.
---

# Diagnose regression

Find the responsible change or boundary with the smallest useful reproduction.
Match the requested scope: an explanation/investigation request is read-only by
default; a request to fix the defect authorizes focused repairs and verification.
Invoking the skill does not itself authorize unrelated mutations.

## Establish a reliable failure

Capture the concrete trigger, expected behavior, actual result and relevant
environment/data/configuration. Identify the last known good evidence and first
known bad state where available. Use logs, reports, current diffs and callers
before asking the user to repeat information already present.

Reproduce through the actual entry point or responsible owner interface, with
disposable storage and controlled inputs where appropriate. Preserve an original
failure report before changing code or fixtures. Distinguish an actual product
failure from a wrong invocation, obsolete fixture, unavailable dependency,
environment mismatch or unrelated known diagnostic. Do not label all failures
as test drift merely because implementation changed.

## Narrow the cause

Form specific hypotheses and choose checks that distinguish them. Follow requests
across the boundary that owns the result, including lifecycle, stale callbacks,
publication/override precedence, persistence or retry ordering when relevant.
Inspect adjacent changes only when evidence points there.

Use Git history/diffs read-only to compare behavior. Do not reset, switch branches,
bisect the user's checkout, discard work or mutate historical evidence without
authorization. If executing an old version is necessary, use a disposable isolated
snapshot consistent with project rules and record its identity.

Separate the root cause from symptoms and incidental warnings. If causation is
not established, say what is known and what evidence would resolve it; do not
invent a confident explanation from temporal proximity alone.

## Repair and verify when authorized

Make the smallest coherent correction at the owning boundary. Preserve accepted
behavior, domain ownership and user changes. Avoid unrelated refactoring. Fix a
test helper only when its expectations or invocation conflict with the approved
behavior, retaining the original intent of the check.

For an escaped functional regression, add or update maintained coverage at the
boundary that missed it. Assert the contract, including the relevant rejected,
interrupted, repeated or restored outcome; do not merely mirror the implementation.
A cosmetic tweak needs proportionate presentation checks, not automatic new tests.

Show the original reproduction now passing, then check affected callers. Expand
to broader suites or exports only for concrete shared-path, build/platform or
integration risk, or an applicable checkpoint requirement. Do not automatically
run the whole repository suite. Reuse unchanged preparation only with adequate
freshness evidence; retain broader deferred checks in the existing task ledger.

## Report and clean up

Explain what failed, why, what changed and how the result was verified. Identify
whether recent work caused the defect, whether it predates those changes, or
whether that remains uncertain. For leaks/performance claims, name the resource
or operation and report observed before/after evidence rather than assuming
that a warning proves a leak or that a quiet log proves all allocations are sound.

Record real failures and unavailable checks accurately. Clean understood inactive
repro/build outputs under existing authorization, preserving compact evidence and
unique inputs. Leave changes uncommitted unless instructed otherwise. Do not add
approval steps for already-authorized diagnostics, repairs or routine cleanup;
respect actual host permissions and material scope/design conflicts.
