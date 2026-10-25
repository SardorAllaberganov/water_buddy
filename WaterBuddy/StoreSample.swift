//
//  StoreSample.swift
//  WaterBuddy
//

#if DEBUG
import Foundation

/// The store capture's history: three months of servings ending at `now`, for the fresh start's
/// in-memory store and nothing else (spec `2026-10-25-store-page-design.md` §3.1).
///
/// History's sheet offers seven days, so a UI test cannot enter what the month, Patterns and the recap
/// need. `WaterBuddyApp.freshStartManager(arguments:now:)` logs these through `addLog(amount:at:)` —
/// the one writer — only beside the fresh start's own argument, so a seed can never reach a device's
/// App Group. Pure: no clock, no store, no `DataManager` instance.
nonisolated enum StoreSample {

    /// One serving to log.
    struct Serving: Equatable, Sendable {
        let at: Date
        let amount: Int
    }

    /// A serving as a time of day, before it has a day.
    private typealias Pour = (hour: Int, minute: Int, amount: Int)

    // The fresh start's three vessels — the store set's servings are always one of them.
    private static let cup = DataManager.defaultServings[0]
    private static let glass = DataManager.defaultServings[1]
    private static let bottle = DataManager.defaultServings[2]

    /// Today: 1,300 ml, 65 % of the default goal — the set's figure since 1.1.
    private static let today: [Pour] = [
        (7, 40, glass), (9, 15, cup), (10, 50, bottle), (12, 25, glass), (13, 30, cup),
    ]

    /// The six days before today, oldest first: 1,650 (short), 2,000, 2,250, 2,150, 2,500, 2,000 —
    /// five met, so Home's chip reads *5 days*.
    private static let week: [[Pour]] = [
        [(7, 45, glass), (10, 30, bottle), (13, 0, cup), (16, 20, bottle), (19, 40, glass)],
        [(7, 40, glass), (10, 15, bottle), (12, 40, glass), (15, 30, bottle), (18, 50, bottle)],
        [(7, 20, bottle), (9, 45, glass), (12, 15, bottle), (14, 50, glass), (17, 30, bottle), (20, 10, glass)],
        [(7, 50, glass), (10, 20, bottle), (12, 30, cup), (15, 10, bottle), (17, 45, glass), (20, 30, bottle)],
        [(7, 15, glass), (9, 30, bottle), (11, 45, glass), (14, 0, bottle), (16, 15, glass), (18, 40, bottle), (20, 50, glass)],
        [(8, 5, glass), (10, 40, bottle), (13, 10, glass), (15, 50, bottle), (18, 20, glass), (20, 40, glass)],
    ]

    // Every day before those: a weekday starts early and a weekend late, so Patterns has a difference
    // to draw; one day in four is short of the goal, so the month has misses and the recap a real count.
    private static let weekdayMet: [Pour] = [
        (7, 30, glass), (9, 45, bottle), (12, 0, glass), (14, 30, bottle), (17, 0, cup), (19, 15, glass), (21, 0, cup),
    ]
    private static let weekdayShort: [Pour] = [
        (7, 45, glass), (10, 30, bottle), (13, 15, glass), (17, 0, bottle), (20, 30, cup),
    ]
    private static let weekendMet: [Pour] = [
        (9, 30, cup), (11, 15, bottle), (12, 45, glass), (14, 30, glass), (17, 0, bottle), (19, 30, glass), (21, 30, cup),
    ]
    private static let weekendShort: [Pour] = [
        (10, 0, cup), (12, 30, glass), (15, 30, bottle), (19, 0, glass), (21, 15, cup),
    ]

    /// Every serving from the 1st of the month two months before `now`'s to `now`, oldest first —
    /// none later than `now`, so a launch before 1:30 PM never holds a future serving.
    ///
    /// Days are stepped with `date(byAdding: .day, …)` and times set on them, never counted in
    /// seconds, so a 23- or 25-hour day keeps every serving on its own day (rule `30-rollover`).
    static func servings(endingAt now: Date, calendar: Calendar) -> [Serving] {
        let today = calendar.startOfDay(for: now)
        guard let thisMonth = calendar.dateInterval(of: .month, for: today)?.start,
              let opening = calendar.date(byAdding: .month, value: -2, to: thisMonth),
              let days = calendar.dateComponents([.day], from: opening, to: today).day
        else { return [] }

        var servings: [Serving] = []
        for offset in stride(from: days, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            for pour in pours(offset: offset, day: day, calendar: calendar) {
                guard let at = calendar.date(bySettingHour: pour.hour, minute: pour.minute, second: 0, of: day),
                      at <= now
                else { continue }
                servings.append(Serving(at: at, amount: pour.amount))
            }
        }
        return servings
    }

    /// The day `offset` days before today: today's five, the set's week, or a generated day.
    private static func pours(offset: Int, day: Date, calendar: Calendar) -> [Pour] {
        if offset == 0 { return today }
        if offset <= week.count { return week[week.count - offset] }
        // Sunday is 1 and Saturday 7 on every Gregorian calendar.
        let weekday = calendar.component(.weekday, from: day)
        let weekend = weekday == 1 || weekday == 7
        let short = calendar.component(.day, from: day) % 4 == 0
        switch (weekend, short) {
        case (false, false): return weekdayMet
        case (false, true): return weekdayShort
        case (true, false): return weekendMet
        case (true, true): return weekendShort
        }
    }
}
#endif
