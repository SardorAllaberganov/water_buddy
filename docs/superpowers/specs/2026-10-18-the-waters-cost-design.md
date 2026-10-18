# The water's cost — design

**Status:** built on the owner's rulings of 2026-10-18 in chat — "a" (this change first), *Still
water + find pour cost*, *Settle in 2.5 s*. Change **A** of two; **B**, the streak's re-count, is
its own change, approved to follow.

## 1. The complaint

The owner, on their iPhone, Debug build run from Xcode: lag on Home when pouring, in History, in
Settings and the welcome — motion that stutters, taps slow to answer, screens slow to open, and all
of it worse the longer the app is used.

## 2. What was measured

Simulator, iPhone 18 Pro Max, iOS 27.0, Debug, a fresh start; the app's own CPU time, `XCTCPUMetric`,
three iterations each, from throwaway probes that are not committed. "Idle" is five still seconds on
a screen; "a pour" is a tap on *Cup* and the five seconds after it.

| | `HEAD` | Moving waves (§4, rejected) | Still water, 5 s | Still water, 2.5 s |
|---|---|---|---|---|
| Welcome, first step | 1.10 s (22 %) | 0.36 s | 0.32 s — 0.68 s in the first run, which holds its five seconds of motion; 0.13–0.15 s at rest after | 0.176 s (3.5 %) |
| Home idle | 0.84 s (17 %) | 0.61 s | **0.20 s (4 %)** | 0.198 s (4 %) |
| History / sheet / Settings | 0.11 / 0.17 / 0.13 s | 0.13 / 0.18 / 0.14 s | 0.09 / 0.17 / 0.11 s | not run |
| A pour | 1.78 s (36 %) | **2.14 s (43 %)** | 1.68 s | **1.15 s (23 %)**; 1.17 s against a control of 1.53 in the lever run |

The `HEAD` column is the first baseline, taken before any code changed, except the pour, measured
later from a clean export of `HEAD` on the same simulator — where Home idled at 0.83 s. Each figure
is the average of three runs.

What a pour costs, one part switched off at a time (control 1.65 s): without the water's motion and
slosh **0.73 s**; without the drop 1.51; without the vessel's swell 1.87; without *Undo* 1.54;
without the level's spring 1.61; all five off 0.63. Only the motion is outside the noise. Sampling
the wave every 4 pt instead of 2 saved nothing (1.85 s): the cost is SwiftUI and Core Animation
redrawing moving water under glass, once a frame for as long as it moves — not the arithmetic.

## 3. The design

**The water moves after a pour, and then rests.** `WaterMotion` (app-only, new file) is a pure,
`nonisolated` value: for ``settling`` after a pour the phase travels, setting off at the speed the
clock always drew (1.1 rad/s) and easing evenly to a standstill — `settling · (u − u²/2)` — so it
never stops dead; then it stands. Each pour carries the phase on from where the surface stood, so
the water never jumps. ``remaining(at:since:)`` says how long the movement has left.

- **Home's vessel** runs its `TimelineView` only while the water moves and the app is active. It
  keeps its own `motionStart` and `restingPhase`, changed together in one `onChange(of: lastPour)`,
  so a frame drawn between the pour and the change still stands the surface in the same place. A
  `.task(id: lastPour)` runs the clock for what is left and stops it; a newer pour cancels it. The
  slosh uses the same window.
- **The welcome's hello vessel** moves the same way for ``settling`` each time its step is shown,
  then rests; still paused off its step.
- **``settling`` is 2.5 s** (the owner's ruling, from the measurement above). The slosh, which
  decays as `exp(−1.5 t)`, is at 2 % of its height by then.
- Reduce Motion is unchanged: a still surface, the level still animating.

**Not in this change:** the aurora (never switched off; History and Settings, which carry it and no
water clock, idled at 2.1 % and 2.6 % of a core — its ceiling — and pausing its never-ending drift would
slide every light back to rest); the streak's re-count (change B); the welcome's weight wheel and the
watch publish, neither measured.

## 4. Tried and rejected: moving the waves instead of redrawing them

A sine drawn at a phase is the same sine at none, moved left; so the path was drawn once a
wavelength wider and a `GeometryEffect` moved it. Idle fell less than hoped (Home 0.61 s), and the
pour grew heavier (2.14 s against 1.78), because the slosh still rebuilds the path every frame and
the path was longer. Reverted in full.

## 5. Acceptance

- Tests first (rule `85-testing`): the water sets off at its own speed, slows to a standstill and
  never backwards, stands still once settled, carries on from where it stood after a pour mid-motion
  and at rest and after the first pour of a launch, moves nothing for a pour still ahead, and settles
  in 2.5 s.
- Home idle at or under 0.35 s per 5 s and the welcome at rest likewise; a pour no heavier than
  `HEAD`'s.
- The water looks as it did while it moves, rests still between pours, and never jumps — seen on
  the simulator.
- The full gate, with no new warning against a clean build of `HEAD`.

## 6. Rules

None is changed. Rule `60-design-system`'s *Water* section holds: two `WaveShape`s travelling
opposite ways at 1.1 and 1.7 while the water moves, `animatableData` exposing `level` only. Rule
`65-accessibility`'s *Reduce Motion* holds as well; the perpetual travel it gated is now gone for
everyone, and the motion after a pour is gated as the travel was.
