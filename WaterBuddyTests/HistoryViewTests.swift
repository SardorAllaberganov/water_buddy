//
//  HistoryViewTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation
import SwiftData
import SwiftUI
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private func gregorian(in timeZone: String) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZone)!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}

private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// The same throwaway suite and in-memory store every other suite here builds, for the same two
/// reasons: `@Test` functions run in parallel inside one process, and no test may reach the real
/// App Group (rule `85-testing`).
@MainActor
private func withTempStore<T>(
    onReschedule: @escaping ([ReminderPlan.Slot]) -> Void = { _ in },
    _ body: (DataManager, UserDefaults) throws -> T
) throws -> T {
    let name = "test.waterbuddy.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(
        for: WaterLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let manager = DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: utcDay,
        now: { utc(2026, 8, 28) },
        reloadWidgets: {},
        // Not decoration. `DataManager.init` ends in `rescheduleRemindersNow()`, and the production
        // default builds a real `UNUserNotificationCenter` — so without this, constructing the
        // fixture reconciles against the user's actual reminders. This suite only reads a range,
        // which is exactly why it went unnoticed (rule `85-testing`).
        rescheduleReminders: onReschedule,
        // Same hazard, a second seam: the production default reaches a real `WCSession`.
        publishWrist: { _ in }
    )
    return try body(manager, defaults)
}

// MARK: - Tests

/// The serving editor's **offer**, which is deliberately narrower than what the store accepts —
/// the same split `DailyGoalSetupTests` pins for `WelcomeView.goalRange`.
///
/// `DataManager` clamps a serving only by rejecting anything non-positive, because that is a floor
/// against corruption rather than a menu. These numbers are the menu, and nothing in the compiler
/// notices when one of them moves.
@MainActor
struct HistoryServingTests {

    @Test func theStandardServingIsInsideTheOfferAndLandsOnAStep() {
        #expect(HistoryView.servingRange.contains(DataManager.defaultServing))
        #expect(DataManager.defaultServing % HistoryView.servingStep == 0)
    }

    @Test func theOfferedRangeIsAWholeNumberOfSteps() {
        let span = HistoryView.servingRange.upperBound - HistoryView.servingRange.lowerBound
        #expect(span % HistoryView.servingStep == 0, "the top of the slider would be unreachable")
    }

    /// Neither end may be rewritten on the way into the store, or the editor would offer an amount
    /// it cannot actually save.
    @Test func bothEndsOfTheOfferedRangeSurviveUpdateLog() throws {
        try withTempStore { manager, defaults in
            manager.addLog(amount: DataManager.defaultServing)
            let target = try #require(manager.todaysLogs.first)

            for end in [HistoryView.servingRange.lowerBound, HistoryView.servingRange.upperBound] {
                manager.updateLog(target, newAmount: end)

                #expect(manager.todaysLogs.first?.amount == end)
                // The cache is what the widget reads; an edit that never reached it is invisible
                // to the other process.
                #expect(defaults.integer(forKey: DataManager.Key.currentWater) == end)
            }
        }
    }

    /// The seed migration inserts a **single** log carrying a whole day's cached total, which can
    /// be far larger than the editor offers. Clamping the slider's initial value would silently
    /// show a different figure from the row the user tapped, so the bounds widen to contain it.
    @Test(arguments: [1, 50, 250, 1_000, 1_150, 4_000, DataManager.maximumDailyIntake])
    func theSliderBoundsAlwaysContainTheServingBeingEdited(amount: Int) {
        let bounds = HistoryView.sliderBounds(forAmount: amount)

        #expect(bounds.contains(amount))
        #expect(bounds.lowerBound <= HistoryView.servingRange.lowerBound)
        #expect(bounds.upperBound >= HistoryView.servingRange.upperBound)
        #expect(bounds.lowerBound >= 1, "a zero-width or non-positive offer cannot be edited")
    }

    /// The sheet's three shortcuts set the amount to a vessel's, so the slider under them has to
    /// be able to show every one — including a vessel a hand-edited suite put outside the offer.
    @Test(arguments: [[150, 250, 500], [1, 30, 5_000], [1_000, 1_000, 1_000], []])
    func theSliderBoundsContainEveryVesselShortcut(vessels: [Int]) {
        let bounds = HistoryView.sliderBounds(forAmount: 250, vessels: vessels)

        for vessel in vessels {
            #expect(bounds.contains(vessel))
        }
        #expect(bounds.contains(250))
        #expect(bounds.lowerBound <= HistoryView.servingRange.lowerBound)
        #expect(bounds.upperBound >= HistoryView.servingRange.upperBound)
        #expect(bounds.lowerBound >= 1, "a zero-width or non-positive offer cannot be edited")
    }

    // MARK: The fixture itself

    /// The twin of ``WaterLogStoreTests/theStoreFixtureRoutesTheReminderPlanToTheInjectedSeam()``,
    /// for this file's own `withTempStore`.
    ///
    /// This suite reads a *range* and looks harmless, which is exactly why it went unnoticed:
    /// `DataManager.init` reschedules, so constructing the fixture was enough to reach the real
    /// notification centre even in a test that never logs water (rule `85-testing`).
    @Test func theServingEditorFixtureRoutesTheReminderPlanToTheInjectedSeam() throws {
        var plans = 0
        try withTempStore(onReschedule: { _ in plans += 1 }) { manager, _ in
            // `addLog` returns the new row's id; discarded here, or it becomes the closure's result.
            _ = manager.addLog(amount: 250)
        }

        #expect(plans > 0, "the fixture is reaching a real UNUserNotificationCenter")
    }
}

// MARK: - Layout, as values

/// The parts of History that are decisions rather than drawing, pinned without building a view.
/// Not `@MainActor`: everything read here is `nonisolated` on purpose (rule `43-concurrency`).
struct HistoryLayoutTests {

    private let first = UUID()
    private let second = UUID()

    // MARK: A row's vessel

    @Test func aServingIsNamedForTheVesselItsAmountEquals() {
        let amounts = [150, 250, 500]

        #expect(HistoryView.vessel(forAmount: 150, amounts: amounts)?.nameKey == "Cup")
        #expect(HistoryView.vessel(forAmount: 250, amounts: amounts)?.nameKey == "Glass")
        #expect(HistoryView.vessel(forAmount: 500, amounts: amounts)?.nameKey == "Bottle")
    }

    /// A log stores an amount and nothing else, so any other amount has no name to draw.
    @Test func anAmountNoVesselHoldsIsNotNamed() {
        #expect(HistoryView.vessel(forAmount: 300, amounts: [150, 250, 500]) == nil)
        #expect(HistoryView.vessel(forAmount: 250, amounts: []) == nil)
    }

    /// Two vessels may hold one amount — the user is allowed to choose that. The Glass is what
    /// every one-tap door logs, so it is the likelier source and is checked first.
    @Test func theGlassIsCheckedFirstWhenTwoVesselsShareAnAmount() {
        #expect(HistoryView.vessel(forAmount: 250, amounts: [250, 250, 500])?.nameKey == "Glass")
        #expect(HistoryView.vessel(forAmount: 250, amounts: [250, 300, 250])?.nameKey == "Cup")
    }

    // MARK: The strip

    @Test func aBarStandsWhereItsServingFellInTheDay() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 250, position: 0.25), (id: second, amount: 500, position: 0.6)],
            vessels: [150, 250, 500]
        )

        #expect(bars.map(\.id) == [first, second])
        #expect(bars.map(\.position) == [0.25, 0.6])
    }

    /// A day lists its servings newest first; the strip reads left to right.
    @Test func barsAreDrawnInTheOrderOfTheDay() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 250, position: 0.9), (id: second, amount: 250, position: 0.1)],
            vessels: [150, 250, 500]
        )

        #expect(bars.map(\.id) == [second, first])
    }

    /// The largest current vessel fills the plot, so a day of Cups reads as small drinks and not
    /// as a day of full bars.
    @Test func aBarIsSizedAgainstTheLargestVessel() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 250, position: 0.3), (id: second, amount: 500, position: 0.5)],
            vessels: [150, 250, 500]
        )

        #expect(bars.map(\.height) == [0.5, 1])
    }

    /// The seeded log carries a whole day's total in one row. It sets the scale, rather than
    /// running through the top of the plot.
    @Test func aServingLargerThanEveryVesselSetsTheScale() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 2_000, position: 0.3), (id: second, amount: 500, position: 0.5)],
            vessels: [150, 250, 500]
        )

        #expect(bars.map(\.height) == [1, 0.25])
    }

    @Test func aSipStillDrawsABar() {
        let bars = HistoryView.stripBars(for: [(id: first, amount: 1, position: 0.5)], vessels: [150, 250, 500])

        #expect(bars.first?.height == HistoryView.stripFloor)
    }

    /// 00:00 and the last minute of the day are both inside the plot; a position from a clock
    /// that ran ahead is pulled back in.
    @Test func aBarNeverLeavesThePlot() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 250, position: -0.2), (id: second, amount: 250, position: 1.4)],
            vessels: [150, 250, 500]
        )

        #expect(bars.map(\.position) == [0, 1])
    }

    @Test func twoServingsInOneMinuteAreTwoBars() {
        let bars = HistoryView.stripBars(
            for: [(id: first, amount: 250, position: 0.5), (id: second, amount: 250, position: 0.5)],
            vessels: [150, 250, 500]
        )

        #expect(bars.count == 2)
        #expect(Set(bars.map(\.id)) == [first, second])
    }

    /// A row the store should never hold — nothing poured, or less — and no vessels at all: a
    /// floor-high bar, never a division by zero.
    @Test func aCorruptServingAndNoVesselsStillDrawABar() {
        let bars = HistoryView.stripBars(for: [(id: first, amount: 0, position: 0.5)], vessels: [])

        #expect(bars.first?.height == HistoryView.stripFloor)
    }

    @Test func theStripLabelsTheMorningNoonAndEvening() {
        #expect(HistoryView.stripHours == [6, 12, 18])
        #expect(HistoryView.stripFloor > 0 && HistoryView.stripFloor < 1)
    }

    // MARK: The shown day's marker

    /// One marker, moved from day to day: it stands at the leading edge of the slot of the day
    /// shown. Seven days share the row evenly, so that is the day's place times a seventh.
    ///
    /// The widths are the day row's on the phones the app runs on — the screen less two margins
    /// of 24 — and none of them is a whole number of sevenths, so the comparison allows a
    /// thousandth of a point: far under a pixel, and far over a rounding in the last place.
    @Test(arguments: [327, 345, 354, 382] as [CGFloat])
    func theMarkerStandsOverTheDayShown(width: CGFloat) {
        let slot = width / 7

        #expect(HistoryView.markerOffset(ofDay: 0, among: 7, across: width) == 0)
        #expect(abs(HistoryView.markerOffset(ofDay: 3, among: 7, across: width) - 3 * slot) < 0.001)
        #expect(abs(HistoryView.markerOffset(ofDay: 6, among: 7, across: width) - (width - slot)) < 0.001)
    }

    /// A week with no days is never drawn, and must not be a division by zero if it is asked.
    @Test func aMarkerAmongNoDaysIsNotADivisionByZero() {
        #expect(HistoryView.markerOffset(ofDay: 0, among: 0, across: 322).isFinite)
    }

    /// Every day on the week card is a tap target on every iPhone: the card is 327 pt wide on a
    /// 375-pt phone, 345 on 393, 354 on 402, 382 on 430 (two margins of 24 off the screen).
    @Test(arguments: [327, 345, 354, 382] as [CGFloat])
    func everyDayClearsTheTapFloor(across width: CGFloat) {
        #expect(HistoryView.daySlot(across: width, count: 7) >= 44)
    }

    /// The full 16 pt inset — the outer tracks 20 pt from the card's edge, as the canvas's padding
    /// puts them — where the card affords it; on the narrowest phone the inset gives way — to 9.5,
    /// which leaves each day exactly 44 — and never the days.
    @Test func theRowTakesTheCanvasInsetWhereTheCardAffordsIt() {
        #expect(HistoryView.dayRowInset(across: 354, count: 7) == 16)
        #expect(HistoryView.dayRowInset(across: 327, count: 7) == 9.5)
        #expect(HistoryView.dayRowInset(across: 300, count: 7) == 0)
    }

    /// A row of no days is never drawn, and must not be a division by zero if it is asked.
    @Test func aRowOfNoDaysIsNotADivisionByZero() {
        #expect(HistoryView.daySlot(across: 322, count: 0).isFinite)
    }
}

// MARK: - The month, as values

/// History's Month decisions, pinned without building a view (spec `2026-10-22-month-view-design.md`
/// §3.1, §3.3, §3.5). Not `@MainActor`: everything read here is `nonisolated` on purpose
/// (rule `43-concurrency`). The month's seven columns are the week card's ``DayRow`` slots, whose
/// 44-pt floor `everyDayClearsTheTapFloor(across:)` already holds.
struct MonthLayoutTests {

    @Test func theSwitchWaitsForTheFirstReadOfPurchases() {
        #expect(!HistoryView.offersMonth(status: nil, offered: true))
        #expect(!HistoryView.offersMonth(status: nil, offered: false))
    }

    @Test func aHolderKeepsTheMonthWhereThePaywallIsNotOffered() {
        #expect(HistoryView.offersMonth(status: .lifetime, offered: false))
        #expect(HistoryView.offersMonth(status: .monthly(until: .distantFuture), offered: true))
    }

    @Test func aFreeUserMeetsTheSwitchOnlyWhereThePaywallIs() {
        #expect(HistoryView.offersMonth(status: .free, offered: true))
        #expect(!HistoryView.offersMonth(status: .free, offered: false))
    }

    @Test func aMonthIsLaidUnderItsWeekdays() {
        // 1 October 2026 is a Thursday (5).
        let sundayFirst = HistoryView.monthGrid(dayCount: 31, weekdayOfFirst: 5, firstWeekday: 1)
        #expect(sundayFirst.count == 5)
        #expect(sundayFirst.first == [nil, nil, nil, nil, 0, 1, 2])
        let mondayFirst = HistoryView.monthGrid(dayCount: 31, weekdayOfFirst: 5, firstWeekday: 2)
        #expect(mondayFirst.first == [nil, nil, nil, 0, 1, 2, 3])
        #expect(mondayFirst.last == [25, 26, 27, 28, 29, 30, nil])
    }

    @Test func aMonthTakesFourToSixWeeks() {
        // February 2026 starts on a Sunday, August 2026 on a Saturday, September 2026 on a Tuesday.
        #expect(HistoryView.monthGrid(dayCount: 28, weekdayOfFirst: 1, firstWeekday: 1).count == 4)
        #expect(HistoryView.monthGrid(dayCount: 31, weekdayOfFirst: 7, firstWeekday: 1).count == 6)
        #expect(HistoryView.monthGrid(dayCount: 30, weekdayOfFirst: 3, firstWeekday: 1).count == 5)
    }

    @Test(arguments: [(28, 1), (29, 4), (30, 3), (31, 7)])
    func everyDayStandsOnceAndInOrder(dayCount: Int, weekdayOfFirst: Int) {
        for firstWeekday in 1...7 {
            let weeks = HistoryView.monthGrid(dayCount: dayCount, weekdayOfFirst: weekdayOfFirst, firstWeekday: firstWeekday)
            #expect(weeks.allSatisfy { $0.count == 7 })
            #expect(weeks.flatMap { $0 }.compactMap { $0 } == Array(0..<dayCount))
        }
    }

    @Test func noDaysIsNoWeeks() {
        #expect(HistoryView.monthGrid(dayCount: 0, weekdayOfFirst: 1, firstWeekday: 1).isEmpty)
    }

    @Test func theWeekStartsOnTheLanguagesFirstDay() {
        #expect(HistoryView.firstWeekday(in: Locale(identifier: "en")) == 1)
        #expect(HistoryView.firstWeekday(in: Locale(identifier: "ru")) == 2)
        #expect(HistoryView.firstWeekday(in: Locale(identifier: "uz")) == 2)
    }

    @Test func theLettersFollowTheFirstDay() {
        #expect(HistoryView.weekdayLetters(in: Locale(identifier: "en")) == ["S", "M", "T", "W", "T", "F", "S"])
        let russian = HistoryView.weekdayLetters(in: Locale(identifier: "ru"))
        #expect(russian.count == 7)
        #expect(russian.first == "П", "Monday first, in Russian's own letter: \(russian)")
    }

    @Test func litresAreDrawnToOneDecimal() {
        #expect(HistoryView.litres(62_570, locale: Locale(identifier: "en")) == "62.6")
        #expect(HistoryView.litres(62_570, locale: Locale(identifier: "ru")) == "62,6")
        #expect(HistoryView.litres(0, locale: Locale(identifier: "en")) == "0.0")
        #expect(HistoryView.litres(1_234_500, locale: Locale(identifier: "en")) == "1,234.5")
    }

    // MARK: Patterns (spec `2026-10-23-patterns-design.md` §3.4, §3.7)

    /// The weekend is the app's locale's, as its first weekday is: Saturday and Sunday in all three of
    /// the app's languages, and the device's own under *Follow device*.
    @Test func theWeekendIsTheLanguagesOwn() {
        #expect(HistoryView.weekend(in: Locale(identifier: "en")) == [1, 7])
        #expect(HistoryView.weekend(in: Locale(identifier: "ru")) == [1, 7])
        #expect(HistoryView.weekend(in: Locale(identifier: "uz")) == [1, 7])
        #expect(HistoryView.weekend(in: Locale(identifier: "ar_SA")) == [6, 7], "Friday and Saturday")
        #expect(HistoryView.weekend(in: Locale(identifier: "en_IN")) == [1], "Sunday alone")
    }

    @Test func anHourStandsOnTheChartsTwentyFourSlots() {
        #expect(HistoryView.hourPosition(0) == 0)
        #expect(HistoryView.hourPosition(6) == 6.0 / 23)
        #expect(HistoryView.hourPosition(12) == 12.0 / 23)
        #expect(HistoryView.hourPosition(18) == 18.0 / 23)
        #expect(HistoryView.hourPosition(23) == 1)
        #expect(HistoryView.hourPosition(-1) == 0)
        #expect(HistoryView.hourPosition(24) == 1)
    }

    /// Each hour's bar against the busiest, a sip still seen and an empty hour drawing nothing.
    @Test func theHoursAreDrawnAgainstTheBusiest() throws {
        var hourly = Array(repeating: 0, count: 24)
        hourly[8] = 1_000
        hourly[13] = 2_000
        hourly[22] = 50
        let bars = HistoryView.hourBars(hourly)
        try #require(bars.count == 24)
        #expect(bars[13] == 1)
        #expect(bars[8] == 0.5)
        #expect(bars[22] == HistoryView.stripFloor, "a sip still has to be seen")
        #expect(bars[0] == 0, "an hour with no water draws nothing")
        #expect(HistoryView.hourBars(Array(repeating: 0, count: 24)).allSatisfy { $0 == 0 })
        #expect(HistoryView.hourBars([Int.max] + Array(repeating: 1, count: 23)).first == 1, "a corrupt hour degrades")
    }
}
