# Input defaults

Keyboard/mouse choices confirmed by the user on 2026-11-18. Unlisted actions use the DFU ResetDefaults assignments from the inspected source. The first keyboard/mouse slot is assigned below and the second starts unbound. Physical key position is binding identity; displayed labels follow the active layout.

| Gameplay action | Keyboard/mouse |
| --- | --- |
| Move forward / backward | W / S |
| Strafe left / right | A / D |
| Turn left / right | Left Arrow / Right Arrow |
| Look | Mouse |
| Look up / down | Insert / Delete |
| Center view | Home |
| Float up / down | Page Up / Page Down |
| Jump | Space |
| Crouch | Left Ctrl, Toggle default |
| Slide | Unbound |
| Run | Left Shift |
| Sneak | Left Alt |
| Autorun | Middle mouse |
| Activate/interact | Left mouse |
| Gameplay cursor toggle | Enter |
| Ready/sheath weapon | X |
| Attack / bow draw-release | Right mouse |
| Switch hand | Z |
| Cast Spell — open spellbook selector | F |
| Recast spell | Q |
| Abort spell | C |
| Use magic item | G |
| Rest / transport | R / T |
| Steal / grab / info / talk mode | 1 / 2 / 3 / 4, top number row |
| Character sheet | N |
| Inventory | B |
| Status | H |
| Quest log / notebook | K / J |
| Automap / travel map | V / M |
| Screenshot | F8 |
| Quicksave / quickload | F9 / F11 |
| Options/recovery | Escape, reserved |
| Developer console | Physical grave/tilde key, with or without Shift |
| Spellbook selector | F through Cast Spell |
| HUD visibility toggle | F7 |

Cast Spell opens the spellbook selector, matching GameManager.cs in the DFU reference. Selection/readying and subsequent casting follow MAGIC-003 and UI-014, including automatic self-target policy. Opening the selector alone does not execute a spell.

Toggle crouch changes desired posture once per accepted press and retains MOVE-006's clearance and restore rules. The Hold/Toggle setting remains available. No collision or forced-posture rule changes.

Console accepts either Shift state on the same physical key, produces one toggle per fresh press, and consumes the input in its owning context. F7 is the separately rebindable HUD toggle.

## Controller baseline

The user's instruction retains DFU defaults for controls not listed. Use axes 1/2 for movement and axes 4/5 for camera with axis inversion off. DFU button 0 supplies left click, button 3 right click, button 2 middle click and button 1 Back. Physical labels are device-dependent. Additional gameplay buttons from the earlier draft are unapproved. Preserve the independently reserved Menu/Start recovery route required by MOVE-002. One explicitly selected gameplay controller remains the approved initial policy.

## Menu and binding capture

Confirm uses Enter or left mouse and controller A. Back uses Escape and controller B. Navigate with arrow keys, D-pad or eligible left stick. Preserve the independent reserved Menu/Start recovery route. Controller UI Confirm and Back have two configurable slots, with the first assigned initially. Capture waits for its opening input to release. Ordinary menu repeat belongs to UI and cannot repeat gameplay shortcuts.

Keyboard modifiers supported initially are Shift, Ctrl and Alt, one modifier per binding. Treat left/right identities explicitly and show them. Mouse buttons and wheel steps can bind discrete actions. Controller triggers can bind eligible discrete/held actions using a documented threshold and hysteresis. Axis assignment is separate from button capture. Invalid or unsupported inputs return a validation reason.

## Approved response defaults

The user approved these response defaults on 2026-11-18. Mouse horizontal/vertical sensitivity starts at 0.10 degrees per reported relative-motion unit, adjustable independently. Default inversion is off. Controller trigger press/release thresholds are 0.55/0.45. Controller cursor speed is 800 UI reference pixels/second at full stick, with the same linear deadzone mapping and resolution-independent UI coordinates. Keyboard look has smoothing off. Other camera rates and deadzones use the already approved IMP-011 values.

Run and Sneak initially use Hold with independent Hold/Toggle settings retained. A user may deliberately leave any nonreserved gameplay action unbound. Binding a shortcut executes only when its owner is available. Actual action support and eligibility come from the approved feature owner.

## Verification

Validate the complete map for overlapping contexts. Exercise keyboard and mouse together, a selected controller and device disconnect, reserved menu access, explicit conflict Replace/Cancel, staged resets and deliberate unbound persistence. Verify trigger hysteresis, mouse displacement and rate-based look separately. Test gameplay cursor speed at two viewport sizes and matched eligible elapsed time.
