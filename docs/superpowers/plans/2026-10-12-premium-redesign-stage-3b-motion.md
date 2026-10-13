# The page slide and the small touches — implementation plan

**Goal:** A change of tab slides the pages by direction under Apple's own bar, and the app
gains the four groups of micro-interactions the owner chose.

**Architecture:** `RootTabView` becomes one pager for every system — one backdrop, two pages at
most, a bar in the bottom safe-area inset — steered by a pure value, `PageTurn`. On iOS 26 and
later the bar is a standalone `UITabBar`. Every curve gets a name in `Motion`. Each touch has a
pure half that is unit-tested and a view half that is recorded.

**Tech stack:** SwiftUI, iOS 17 floor; `UIViewRepresentable` over `UITabBar` behind the third
version check; swift-testing for the pure halves, XCTest for the UI.

**Spec:** `docs/superpowers/specs/2026-10-12-page-slide-and-touches-design.md`

**Executed inline by the session that wrote it**, on the owner's standing ruling of
2026-10-09. So the steps name each test and what it asserts, each interface exactly, and each
command — and leave the bodies to the build. Nothing is committed and nothing is staged: stage
3 is in the index and stage 3b is the working tree this is built on.

## Global constraints

- Tests first; each new test is run and seen failing before the code that passes it.
- No assertion is weakened to pass. No rule file is edited.
- `xcodebuild` in the foreground, one simulator, `-parallel-testing-enabled NO`; a run expected
  to fail carries `-collect-test-diagnostics never`. Simulators by name, shut down by UDID,
  never `shutdown all`; `uptime` before a gate run.
- No shared file is touched: `DataManager`, `WaterLog`, `WaterSurface`, `LiquidGlassModifier`,
  `ReminderPlan`, `NotificationManager`, `WristPlan`. No widget or watch file.
- No new string, no new key, no dependency. Every colour from `Aurora`.
- A value a non-`@MainActor` suite reads is at file scope and `nonisolated`.
- Decoration is hidden from accessibility and takes no touch.

## Review focus

1. A second turn started before the first slide ends: the page that was leaving is dropped,
   and the first slide's completion must not remove the page now leaving.
2. Reduce Motion: nothing travels, and the leaving page is still removed.
3. A change of language under Apple's bar: the three captions follow and the selection holds.
4. Landscape and the 375 × 667 pt phone: the leaving page ends wholly off screen, and the bar
   stands where the system stands its own.
5. A pour made twice in quick succession: two drops, neither stranded on screen.

## Task 1 — `Motion` and `PageTurn`

**Files:** create `WaterBuddy/Motion.swift`, `WaterBuddy/PageTurn.swift`,
`WaterBuddyTests/MotionTests.swift`, `WaterBuddyTests/PageTurnTests.swift`.

**Interfaces produced:**

```swift
nonisolated enum Motion {
    static let pageDuration: Double      // 0.45
    static let fadeDuration: Double      // 0.25
    static let settleDuration: Double    // 0.3
    static let landResponse: Double      // 0.5
    static let landDamping: Double       // 0.68
    static let waterResponse: Double     // 0.8
    static let waterDamping: Double      // 0.62
    static let dropDuration: Double      // 0.38
    static var page: Animation { get }
    static var pageFade: Animation { get }
    static var settle: Animation { get }
    static var land: Animation { get }
    static var water: Animation { get }
}

nonisolated struct PageTurn: Equatable, Sendable {
    private(set) var shown: AppTab        // AppTab.opening
    private(set) var leaving: AppTab?
    private(set) var travel: CGFloat      // +1 from the right, -1 from the left
    mutating func turn(to tab: AppTab)
    mutating func settle(on tab: AppTab)  // clears `leaving` only if `tab` is still shown
    var mounted: [AppTab] { get }         // in the bar's order
    func offset(of tab: AppTab, across width: CGFloat, slides: Bool) -> CGFloat
    func entry(across width: CGFloat, slides: Bool) -> CGFloat
    func opacity(of tab: AppTab, slides: Bool) -> Double
}
```

- [ ] `MotionTests` (not `@MainActor`): `aPageChangesInUnderHalfASecond`,
      `theFadeIsShorterThanTheSlide`, `whatLandsPassesItsPlaceAndDoesNotRing`
      (`0.6 <= landDamping < 1`, the same for `waterDamping`),
      `neitherSpringIsThePresss` (not `0.28` / `0.62`), `aDropLandsBeforeTheLevelDoes`.
- [ ] `PageTurnTests` (not `@MainActor`): `theAppOpensOnOnePage`,
      `aTabToTheRightComesInFromTheRight`, `aTabToTheLeftComesInFromTheLeft`,
      `thePageLeavingEndsAWholeWidthAway`, `theTabAlreadyShownTurnsNothing`,
      `twoPagesAtMostAreMounted`, `aTurnThatHasEndedMountsOnePage`,
      `anOlderTurnsEndDoesNotEndANewerTurn`, `thePagesAreMountedInTheBarsOrder`,
      `underReduceMotionNothingTravels`.
- [ ] Run both suites: RED (the types do not exist — a build failure naming them).
- [ ] Write the two files. Run: GREEN.

Run: `xcodebuild test … -only-testing:WaterBuddyTests/MotionTests -only-testing:WaterBuddyTests/PageTurnTests`

## Task 2 — The pager and the bar

**Files:** modify `WaterBuddy/RootTabView.swift`, `Arrival.swift`, `HomeView.swift`,
`HistoryView.swift`, `SettingsView.swift`; `WaterBuddyUITests/GoalSetupUITests.swift`,
`AppStoreScreenshotUITests.swift` (one comment); `WaterBuddyTests/RootTabViewTests.swift` if a
DocC there names the old container.

**Consumes:** `PageTurn`, `Motion.page`, `Motion.pageFade`.

- [ ] UI test `testOnlyThePageShownIsInTheTreeAfterAChangeOfTab`: Home → History (wait for
      *Add a serving*) → Home; then *Add a serving* stops existing and exactly one static text
      is named *Today*. Run on iOS 27.0: RED is not available from the current container (it
      removes the page at once) — so it is first run against a pager that never settles, by
      leaving `settle(on:)` uncalled, and seen failing; then with the completion: GREEN.
- [ ] `RootTabView`: `@State private var turn = PageTurn()`; the container of the spec's §2.3;
      `SystemTabBar` (`@available(iOS 26.0, *)`, private, in this file) and `GlassTabBar`
      chosen in one `if #available`; the shade drawn by the container under Apple's bar only;
      the tick still on the shown tab; `preferredColorScheme(.dark)` as before. `SystemTabs`
      and `HandMadeTabs` go.
- [ ] `Arrival`: `isShownTab` goes; `tracksArrival` is a task that waits `hiddenFirst` and sets
      the flag. `rise` 14, `stagger` 0.05 (inside what `ArrivalTests` already holds).
- [ ] The three screens: their own `AuroraBackground()` goes (their previews stand one); Home's
      and History's `.onDisappear` resets go.
- [ ] `AppStoreScreenshotUITests`: the comment on `returnToTop` says what the container is now.
- [ ] Run the tab tests on iOS 27.0, then 26.5, then 18.6:
      `testTheTabBarSwitchesBetweenHomeAndHistory`, `testAScreenComesBackWholeAfterItsTabIsLeft`,
      `testAKeptScreenAnswersATapWhenItIsShownAgain`, `testAPressDraggedAlongTheBarChangesTheTab`,
      `testTheBarsCaptionsShareALine`, `testHistoryReturnsToTodayWhenItsTabIsLeft`,
      `testTheTitleHoldsItsPlaceOnEveryTab`, `testTheTitleHoldsItsPlaceWhereItsAccessoryIsTaller`,
      `testHomeIsHeadedTodayOnce`, `testSettingsIsReachableFromHomeAsATab`,
      `testAnUndoOfferDoesNotOutliveItsScreen`, and the new one.
- [ ] The bar beside the `TabView`'s: a capture of the built app against the stage 3b build's,
      iOS 27.0 (no pixel of the foot differing by more than 24 levels) and iOS 26.5 (same
      frame; the glass differs — M1).

## Task 3 — Water that reacts

**Files:** create `WaterBuddy/PourDrop.swift`, `WaterBuddyTests/PourDropTests.swift`; modify
`WaterBuddy/HomeView.swift`.

```swift
nonisolated enum PourArc {
    static let lift: CGFloat                       // how far above the line the arc rises
    static func point(at progress: Double, from start: CGPoint, to end: CGPoint) -> CGPoint
}
```

- [ ] `PourArcTests` (not `@MainActor`): `aDropStartsAtTheDisc`, `aDropEndsInTheVessel`,
      `aDropRisesAboveTheLineBetween`, `progressOutsideTheJourneyIsHeldAtItsEnds`. RED, then
      `PourArc`: GREEN.
- [ ] `PourDrop` (the view): one drop, flown along `PourArc` by an `Animatable` modifier in
      `Motion.dropDuration`, reporting when it lands.
- [ ] `HomeView`: the discs' centres and the vessel's frame collected as anchor preferences;
      a pour adds a drop from the pressed disc; a landing removes it, bumps `lands` (the
      vessel's swell, by `keyframeAnimator`) and sets `lastPour`. Under Reduce Motion a pour
      sets `lastPour` at once and adds no drop. The level animates on `Motion.water`.
- [ ] Home's UI tests on iOS 27.0: the pour, *Undo* and disc tests.

## Task 4 — Rows and cards that move

**Files:** modify `WaterBuddy/HistoryView.swift`, `WaterBuddyTests/HistoryViewTests.swift`.

```swift
extension HistoryView {
    nonisolated static func markerOffset(ofDay index: Int, among count: Int, across width: CGFloat) -> CGFloat
}
```

- [ ] `HistoryLayoutTests`: `theMarkerStandsOverTheDayShown` (first day at 0, the last at
      `width − slot`, a day in the middle at `index × slot`), `aMarkerAmongNoDaysIsNotADivisionByZero`.
      RED, then GREEN.
- [ ] `HistoryCard`: one capsule behind the row of days, moved on `Motion.land`; the per-day
      capsules go; the weekday's weight and the `.isSelected` trait stay on each day.
- [ ] `DayStrip`: told which day it draws; its bars drop without animation and grow again when
      that day changes.
- [ ] History's UI tests on iOS 27.0.

## Task 5 — Controls that answer

**Files:** modify `WaterBuddy/SettingsView.swift`, `HomeView.swift`.

- [ ] `SettingsView`: `SavedTick` (file-private: a stroked check trimmed to whole on
      `Motion.land`, shown for a moment after `commits` changes) beside *Daily goal* and
      *Quick-add vessels*; the figure under a held slider at 1.06; the language's checkmark
      bounces on a pick; the reminders card's text cross-fades.
- [ ] `HomeView`: the streak chip and *Undo*'s capsule arrive from 0.8 on `Motion.land`.
- [ ] Settings' and Home's UI tests on iOS 27.0.

## Task 6 — Scrolling with depth

**Files:** create `WaterBuddy/ScrollDepth.swift`, `WaterBuddyTests/ScrollDepthTests.swift`;
modify the three screens.

```swift
nonisolated enum ScrollDepth {
    static let smallest: Double      // 0.94
    static let faintest: Double      // 0.5
    static func scale(at phase: Double) -> Double
    static func opacity(at phase: Double) -> Double
}
extension View { func scrollDepth() -> some View }
```

- [ ] `ScrollDepthTests` (not `@MainActor`): `aSectionAtRestIsWhole`,
      `aSectionAtTheEdgeIsAtItsFloors`, `theTopAndTheFootAreTreatedAlike`,
      `aPhaseBeyondTheEdgeGoesNoFurther`. RED, GREEN.
- [ ] `scrollDepth()` on every section of Home, History and Settings, the header included.
      Under Reduce Motion the scale is 1.
- [ ] The whole UI class on iOS 27.0, in chunks.

## Task 7 — Seen, then reviewed

- [ ] Recordings of a change of tab, a pour, a day picked and a goal saved on iOS 27.0; the
      change of tab on 26.5 and 18.6; frames read.
- [ ] The selected caption on Apple's bar on iOS 26.5, read as `docs/DESIGN.md` reads it, with
      the darker glass.
- [ ] A fresh reviewer on the diff against the tree as this pass found it
      (`scratchpad/pre-motion`), with the spec, this plan and the review focus. One fix pass,
      each fix test-first.

## Task 8 — The gate

- [ ] Phone unit; phone UI in chunks on iOS 27.0, 26.5 and 18.6; watch unit; both widget
      builds. Warnings against the saved baselines of the index.

## Task 9 — The records

- [ ] `docs/AI_CONTEXT.md`, `docs/DESIGN.md`, `CLAUDE.md` if its one clause moved,
      `tasks/lessons.md`, `HISTORY.md`, memory. The staging block last. Nothing staged.

## As built — where the build and its review left the tasks above

The tasks are kept as they were written. What differs in the tree:

- **Task 1.** `PageTurn` counts its turns (`turns`) and `settle(_:)` takes a turn's number, not
  a page: the review found that there, back and there again inside one slide ended the newest
  slide early. `Motion` gained `drop` and `landSpring`; `dropDuration` is 0.42.
  `MotionTests`: `neitherSpringIsAsQuickAsThePresss`, `aDropIsQuickerThanTheLevel`,
  `aChangeOfStateIsQuickerThanAChangeOfPage`.
- **Task 2.** `Arrival` settles the opening page only: `EnvironmentValues.pageSettlesIn`,
  `Arrival.opacity(arrived:settles:)` and `lift(arrived:settles:reduceMotion:)`, four tests. A
  page that slides in has its sections whole (History's bars still grow on every page, unless
  Reduce Motion is on).
  `testAKeptScreenAnswersATapWhenItIsShownAgain` is
  `testAScreenAnswersATapWhenItIsShownAgain`.
- **Task 3.** The drop is 22 pt. The surface surges when it lands, and at the press only when
  no drop flies. The landing spring is scoped to the capsule and the chip, not Home's root.
  The counter a landing bumps is `landings`, where the task says `lands`. `PourArc.lift` (56)
  is how far the curve's control point stands above the middle of the line, where the task's
  interface says "how far above the line the arc rises": the drop rises half of it, 28 pt.
- **Task 4.** Added by the fifty-fourth pass of `docs/AI_CONTEXT.md`; this section had no
  entry for it. Built as written but for one phrase, "its bars drop without animation". The
  shown day's bars start at nothing without animation and grow (under Reduce Motion they are
  simply there); the bars of the day being left are other bars and fade out over 0.45 s as
  they do. `HistoryView.markerOffset(ofDay:among:across:)`
  is the marker's pure half, with two tests in `HistoryLayoutTests`.
- **Task 5.** The tick is drawn over its row (`savedTick(_:)`), both held figures are 1.06, and
  the reminders card's animation is on the stack of cards.
- **Task 6.** `scrollTransition` did not survive a `List`; `ScrollDepth.phase(of:within:)`,
  `span(from:to:)`, `anchor(at:)`, `scrollDepthContainer()`. It shrinks to 0.92 and does not
  fade; there is no `faintest` and no `opacity(at:)`. History and Settings only, not Home.
  The task's `aSectionAtTheEdgeIsAtItsFloors` is `aSectionAtTheEdgeIsAtItsFloor`: one floor,
  with the fade gone.
