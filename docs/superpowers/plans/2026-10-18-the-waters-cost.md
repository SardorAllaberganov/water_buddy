# The water's cost — plan

Spec: `docs/superpowers/specs/2026-10-18-the-waters-cost-design.md`. Run inline, tests first.

The first plan moved the waves instead of redrawing them; its measurement failed the spec's
acceptance and made the pour heavier, so it was reverted in full (spec §4) and the owner chose still
water between pours. This is the plan that was run.

1. **Red.** `WaterBuddyTests/WaterMotionTests.swift` against a missing `WaterMotion`: a build
   failure. Then a stub modelling today's behaviour — moving for ever, never settling, never
   carrying the phase on — and every test failing on its assertion.
2. **Green.** `WaterBuddy/WaterMotion.swift`: the phase eases from 1.1 rad/s to a standstill over
   `settling`, carries on across pours, and `remaining(at:since:)` says how long is left.
3. **Red again, for the stop.** `theWaterSlowsToAStandstill` added after the first green showed the
   water stopping dead; seen red against the constant-speed version, then green with `u − u²/2`.
4. **Wire.** `HomeView`'s vessel and `WelcomeView`'s hello vessel: the clock runs only while the
   water moves and the app is active; the phase is carried in `motionStart`/`restingPhase`; the slosh
   shares the window.
5. **Find the pour's cost.** Temporary `-ZZOff…` switches, one part of the pour off at a time, then
   two levers (a 4 pt sample, a 2.5 s settle); all removed, the tree grepped clean.
6. **The owner's ruling: 2.5 s.** `theWaterSettlesInTwoAndAHalfSeconds` seen red at 5, green at 2.5.
7. **Measure and look.** The probe against `HEAD`; screenshots at rest, moving and settled.
8. **Gate** — with change B, on the combined tree: the five invocations and the UI run on iOS 26.5;
   warnings compared per file and message against a clean build of `HEAD`.
9. **Records.** Delete the throwaway probes; `HISTORY.md`; known issues; `/doc_sync`. Staged by
   explicit path, in one `git add` with B — the two touch disjoint source files, so `/commit` can
   still take A alone — and stop.
