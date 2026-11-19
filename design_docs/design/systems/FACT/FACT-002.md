# FACT-002 — Direct faction standing

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-002-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-002-interview-decisions).

## Gameplay purpose and intended player experience

Track the player's standing with each faction so dialogue, work offers, and other systems can respond consistently to the player's actions. The player receives the actual gain or loss when a change reaches a cap. Returning to a saved game preserves the standing already earned and any quest consequences already settled.

## Confirmed requirements

- Use a shared integer range of −100 through +100, with 0 as neutral. Initialize new characters from validated faction defaults and preserve saved values for existing characters.
- Use signed changes for ordinary gameplay and allow absolute sets for explicitly authorized systems. Return the previous value, new value, and actual change. A valid request that changes nothing still settles successfully. Notify standing observers only when the stored value changes.
- Use stable faction IDs. Distinguish a missing required faction from a known faction at neutral standing. See [FACT-001](FACT-001.md), [DATA-009](../DATA/DATA-009.md), and [the decision log](../../GAMEPLAY_DECISIONS.md#fact-002-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Player/PersistentFactionData.cs` stores an integer reputation in each faction record. `GetReputation` returns 0 for unknown IDs. `SetReputation` and the direct branch of `ChangeReputation` clamp to −100 through +100 and return success for a known faction. `Game/Questing/Actions/ChangeReputeWith.cs` explicitly requests propagation. `Game/Serialization/SerializablePlayer.cs` saves and restores faction records. These are static source findings.

## Detailed rules and formulas

1. Maintain one current integer standing per character and faction ID. Read the exact target supplied by FACT-001 or the authorized consumer. An unaffiliated actor has no faction standing target. A known faction at 0 is a successful read.
2. For a signed change, calculate `new = clamp(previous + requestedDelta, -100, 100)`. For an authorized absolute set, calculate `new = clamp(requestedValue, -100, 100)`. In both cases, `actualChange = new - previous`. Evaluate the addition without integer overflow before clamping.
3. Validate the target, authorization, and integer input before mutation. Apply a direct write to the selected faction only. FACT-003 owns propagation selection and routing, and FACT-004 owns normalization. Legal standing belongs to LAW.
4. Return a successful result for a valid request even if the actual change is 0, whether the request reaches a cap, adds zero, or sets the existing value. Commit a changed value before notifying observers. A settlement result is available to the caller for every valid write. Emit a standing change notification only when the stored value differs.
5. For quest consequences, retain the settled target and result under QUEST-019. A repeated delivery returns the settled outcome without applying the change or emitting another notification, even if standing has since changed. A distinct authorized consequence can apply normally. Apply distinct quest effects in declared order and clamp each effect as it settles.

## Required data, inputs, outputs, and events

Required data includes stable faction ID, validated authored starting value, and current character standing. Reads take a faction ID and return standing or an explicit unavailable or invalid outcome. Writes take an authorized context, stable target, and signed delta or requested absolute value. Successful writes return target ID, previous and new values, and actual change. A change notification carries the same values. A rejected write reports its reason and leaves standing intact.

## Cross-system interactions

- FACT-001 resolves affiliation and hierarchy. DATA-009 provides validated faction definitions and authored defaults. FACT owns mutable standing.
- NPC-018 combines applicable standing with other reaction inputs. QUEST-002/003 consume standing for eligibility. QUEST-019 supplies the authorized consequence target and uses the actual applied amount and the retained settlement. Guild eligibility and rank rules consume standing under their own features.
- FACT-003 owns related-faction effects, FACT-004 owns time-based changes, and LAW owns regional legal standing.

## Edge cases and failure conditions

- A +10 change at +95 settles at +100 with an actual change of +5. At +100 the same requested amount settles at +100 with an actual change of 0. A −10 change at −95 settles at −100 with an actual change of −5.
- An unknown required faction fails lookup or mutation. A rejected write cannot settle as an applied quest consequence. An explicitly unaffiliated context follows the consumer's rules for absence.
- Very large signed amounts saturate in the intended direction. An invalid or unauthorized absolute set leaves the value intact.
- A capped reward settles once. Lowering standing later does not reopen that reward. A legitimate repeatable quest run has its own consequence identity under QUEST-019.

## Configuration and balancing

The range and neutral value are shared. Content authors can tune validated starting values and signed rewards or penalties. An out-of-range write is clamped using the same rules for every faction. Dialogue thresholds, guild requirements, and propagation weights remain with their owning features.

## Save/load considerations

Persist current standing by stable faction ID and restore it before dependent gameplay resumes. Apply new-character defaults only during new-character initialization. Restored quest settlement records preserve outcomes, including zero-change results. A removed required faction follows explicit migration or compatibility handling under DATA-009 and SAVE. Handle invalid saved values through the applicable save validation or migration policy.

## Technical constraints and consistency review

Keep authored defaults separate from mutable character state. Queries have no side effects. A write applies against the current committed value and returns the outcome of that write. Keep settlement and quest retry semantics consistent across save and load under QUEST-019/022. Review found no conflict with DATA-009, FACT-001, NPC-018, or QUEST-019.

## Acceptance criteria

1. A new character receives the authored standing for a known faction. A saved character recovers its changed value. A known value of 0 and a missing required faction produce distinct results.
2. Authorized delta and absolute writes clamp at both endpoints and report the actual change. Large deltas do not wrap. Unauthorized writes fail without a change.
3. A direct write changes only its authorized faction. An effective change emits one notification after commitment. A capped or otherwise unchanged write settles successfully and emits no standing change notification.
4. Reload and retry of a settled quest consequence cannot grant its standing again, including when its original applied change was zero and the player's standing has since fallen below the cap.

## Outstanding questions

No outstanding gameplay decision within direct standing. Classic import and save recovery details remain with DATA and SAVE. Propagation and normalization remain separate feature decisions.
