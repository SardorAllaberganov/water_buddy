//
//  StoreSampleTests.swift
//  WaterBuddyTests
//

#if DEBUG
import Foundation
import Testing
@testable import WaterBuddy

/// The store capture's history (spec `2026-10-25-store-page-design.md` §3.1). Not `@MainActor`: a
/// canary for `StoreSample`'s isolation (rule `43-concurrency`).
struct StoreSampleTests {

    /// New York, so the DST test has a fall-back day to cross; the rest only need a fixed zone.
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }()

    private static func instant(_ year: Int, _ month: Int, _ day: Int, _ hour: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    /// Each day's water by its ordinal, on the test's calendar.
    private static func totals(_ servings: [StoreSample.Serving]) -> [Int: Int] {
        servings.reduce(into: [:]) { $0[DataManager.dayOrdinal(for: $1.at, in: calendar), default: 0] += $1.amount }
    }

    @Test func todayIsTheSetsFiveServings() {
        let servings = StoreSample.servings(endingAt: Self.instant(2026, 10, 25, 14), calendar: Self.calendar)
        let today = servings.filter { DataManager.dayOrdinal(for: $0.at, in: Self.calendar) == 20261025 }
        #expect(today.map(\.amount) == [250, 150, 500, 250, 150])
        #expect(today.map { Self.calendar.dateComponents([.hour, .minute], from: $0.at) }
                == [(7, 40), (9, 15), (10, 50), (12, 25), (13, 30)].map { DateComponents(hour: $0.0, minute: $0.1) })
    }

    @Test func theSixDaysBeforeAreTheSetsWeek() {
        let totals = Self.totals(StoreSample.servings(endingAt: Self.instant(2026, 10, 25, 14), calendar: Self.calendar))
        #expect((19...24).map { totals[20261000 + $0] } == [1_650, 2_000, 2_250, 2_150, 2_500, 2_000])
    }

    @Test func nothingIsLaterThanNow() {
        let now = Self.instant(2026, 10, 25, 10)
        let servings = StoreSample.servings(endingAt: now, calendar: Self.calendar)
        #expect(servings.allSatisfy { $0.at <= now })
        #expect(Self.totals(servings)[20261025] == 400, "only 7:40 and 9:15 are before 10 AM")
    }

    @Test func everyAmountIsAFreshStartsVessel() {
        let servings = StoreSample.servings(endingAt: Self.instant(2026, 10, 25, 14), calendar: Self.calendar)
        #expect(!servings.isEmpty)
        #expect(servings.allSatisfy { DataManager.defaultServings.contains($0.amount) })
    }

    @Test func theHistoryOpensOnTheFirstOfTheMonthTwoMonthsBack() {
        let totals = Self.totals(StoreSample.servings(endingAt: Self.instant(2026, 10, 25, 14), calendar: Self.calendar))
        #expect(totals.keys.min() == 20260801)
        #expect(totals.count == 31 + 30 + 25, "every day from 1 August to today holds water")
    }

    @Test func thePreviousMonthHoldsARecapAndBothKindsOfDay() {
        let totals = Self.totals(StoreSample.servings(endingAt: Self.instant(2026, 10, 25, 14), calendar: Self.calendar))
        let september = (1...30).compactMap { totals[20260900 + $0] }
        #expect(september.count >= MonthHistory.recapDays)
        #expect(september.contains { $0 >= DataManager.defaultDailyGoal })
        #expect(september.contains { $0 < DataManager.defaultDailyGoal })
    }

    @Test func aDSTDayKeepsEveryServingOnItsDay() {
        // 1 November 2026 is the fall-back Sunday in New York: a 25-hour day.
        let totals = Self.totals(StoreSample.servings(endingAt: Self.instant(2026, 11, 1, 14), calendar: Self.calendar))
        #expect(totals[20261101] == 1_300)
        #expect((26...31).map { totals[20261000 + $0] } == [1_650, 2_000, 2_250, 2_150, 2_500, 2_000])
    }
}
#endif
