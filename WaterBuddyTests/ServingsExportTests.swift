//
//  ServingsExportTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import Foundation
import Testing
@testable import WaterBuddy

/// The export's file, exactly (spec `2026-11-01-export-design.md`). Not `@MainActor`: a canary that
/// `ServingsExport` stays `nonisolated` and imports `Foundation` alone (rule `43-concurrency`).
struct ServingsExportTests {

    private func calendar(_ zone: String, locale: String = "en_US_POSIX") throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: zone))
        calendar.locale = Locale(identifier: locale)
        return calendar
    }

    private func instant(_ calendar: Calendar, _ year: Int, _ month: Int, _ day: Int,
                         _ hour: Int = 12, _ minute: Int = 0, _ second: Int = 0) throws -> Date {
        try #require(calendar.date(from: DateComponents(year: year, month: month, day: day,
                                                        hour: hour, minute: minute, second: second)))
    }

    private func file(_ rows: [ServingsExport.Serving], today: Date, calendar: Calendar) throws -> ServingsExport {
        guard case .file(let export) = ServingsExport.outcome(of: rows, today: today, calendar: calendar) else {
            Issue.record("no file")
            throw CancellationError()
        }
        return export
    }

    private func text(_ export: ServingsExport) -> String {
        String(decoding: export.data, as: UTF8.self)
    }

    @Test func theWholeFileIsItsHeadingsAndItsRows() throws {
        let utc = try calendar("UTC")
        let rows = [
            ServingsExport.Serving(amount: 250, timestamp: try instant(utc, 2026, 3, 3, 9, 14)),
            ServingsExport.Serving(amount: 500, timestamp: try instant(utc, 2026, 3, 3, 13, 2)),
        ]
        let export = try file(rows, today: try instant(utc, 2026, 11, 1), calendar: utc)
        #expect(text(export) == "date,time,amount_ml\r\n2026-03-03,09:14,250\r\n2026-03-03,13:02,500\r\n")
    }

    /// `logs(since:)` answers newest first.
    @Test func rowsRunOldestFirst() throws {
        let utc = try calendar("UTC")
        let rows = [
            ServingsExport.Serving(amount: 500, timestamp: try instant(utc, 2026, 3, 4, 8)),
            ServingsExport.Serving(amount: 250, timestamp: try instant(utc, 2026, 3, 3, 8)),
        ]
        let lines = text(try file(rows, today: try instant(utc, 2026, 11, 1), calendar: utc))
            .components(separatedBy: "\r\n")
        #expect(lines[1] == "2026-03-03,08:00,250")
        #expect(lines[2] == "2026-03-04,08:00,500")
    }

    /// History's `+` logs an old instant after newer rows, so the order is the instant's, never the input's.
    @Test func aServingAddedLaterToAnEarlierDayStandsInItsPlace() throws {
        let utc = try calendar("UTC")
        let rows = [
            ServingsExport.Serving(amount: 200, timestamp: try instant(utc, 2026, 3, 5, 8)),
            ServingsExport.Serving(amount: 100, timestamp: try instant(utc, 2026, 3, 1, 8)),
            ServingsExport.Serving(amount: 300, timestamp: try instant(utc, 2026, 3, 9, 8)),
        ]
        let lines = text(try file(rows, today: try instant(utc, 2026, 11, 1), calendar: utc))
            .components(separatedBy: "\r\n")
        #expect(Array(lines[1...3]) == ["2026-03-01,08:00,100", "2026-03-05,08:00,200", "2026-03-09,08:00,300"])
    }

    /// As History reads it: the wall clock in the zone the phone is in now (D6).
    @Test func aRowReadsItsInstantInTheCalendarsZone() throws {
        let utc = try calendar("UTC")
        let moment = try instant(utc, 2026, 6, 15, 3, 30)
        let rows = [ServingsExport.Serving(amount: 250, timestamp: moment)]
        let paris = try calendar("Europe/Paris"), angeles = try calendar("America/Los_Angeles")
        #expect(text(try file(rows, today: moment, calendar: paris)).contains("2026-06-15,05:30,250"))
        #expect(text(try file(rows, today: moment, calendar: angeles)).contains("2026-06-14,20:30,250"))
    }

    /// The clocks go back on 1 November 2026 in Los Angeles: 01:30 happens twice, an hour apart.
    @Test func bothRowsOfARepeatedHourAreKept() throws {
        let utc = try calendar("UTC"), angeles = try calendar("America/Los_Angeles")
        let rows = [
            ServingsExport.Serving(amount: 250, timestamp: try instant(utc, 2026, 11, 1, 8, 30)),
            ServingsExport.Serving(amount: 500, timestamp: try instant(utc, 2026, 11, 1, 9, 30)),
        ]
        let lines = text(try file(rows, today: try instant(utc, 2026, 11, 1, 20), calendar: angeles))
            .components(separatedBy: "\r\n")
        #expect(lines[1] == "2026-11-01,01:30,250")
        #expect(lines[2] == "2026-11-01,01:30,500")
    }

    @Test func aServingAtMidnightBelongsToTheDayItStarts() throws {
        let utc = try calendar("UTC")
        let rows = [
            ServingsExport.Serving(amount: 100, timestamp: try instant(utc, 2026, 3, 3, 23, 59, 59)),
            ServingsExport.Serving(amount: 200, timestamp: try instant(utc, 2026, 3, 4, 0, 0, 0)),
        ]
        let lines = text(try file(rows, today: try instant(utc, 2026, 11, 1), calendar: utc))
            .components(separatedBy: "\r\n")
        #expect(lines[1] == "2026-03-03,23:59,100")
        #expect(lines[2] == "2026-03-04,00:00,200")
    }

    @Test func twoServingsInOneMinuteStayTwoRows() throws {
        let utc = try calendar("UTC")
        let moment = try instant(utc, 2026, 3, 3, 9, 14)
        let rows = [
            ServingsExport.Serving(amount: 250, timestamp: moment),
            ServingsExport.Serving(amount: 250, timestamp: moment.addingTimeInterval(20)),
        ]
        let export = try file(rows, today: moment, calendar: utc)
        #expect(export.count == 2)
        #expect(text(export).components(separatedBy: "\r\n").count == 4)
    }

    /// Never clamped and never grouped: the file is the record (D7). Nothing here sums, so nothing can overflow.
    @Test func anAmountIsWrittenAsStored() throws {
        let utc = try calendar("UTC")
        let moment = try instant(utc, 2026, 3, 3)
        let rows = [
            ServingsExport.Serving(amount: 100_000, timestamp: moment),
            ServingsExport.Serving(amount: Int.max, timestamp: moment.addingTimeInterval(60)),
        ]
        let body = text(try file(rows, today: moment, calendar: utc))
        #expect(body.contains(",100000\r\n"))
        #expect(body.contains(",\(Int.max)\r\n"))
    }

    /// 02:00 UTC on the 1st is still the 31st in Los Angeles.
    @Test func theNameCarriesTodaysDayOnTheCalendar() throws {
        let utc = try calendar("UTC"), angeles = try calendar("America/Los_Angeles")
        let today = try instant(utc, 2026, 11, 1, 2)
        let rows = [ServingsExport.Serving(amount: 250, timestamp: today)]
        #expect(try file(rows, today: today, calendar: utc).name == "WaterBuddy-2026-11-01.csv")
        #expect(try file(rows, today: today, calendar: angeles).name == "WaterBuddy-2026-10-31.csv")
    }

    @Test func theSummaryCountsTheFile() throws {
        let utc = try calendar("UTC")
        let early = try instant(utc, 2026, 3, 3), middle = try instant(utc, 2026, 4, 4), late = try instant(utc, 2026, 5, 5)
        let rows = [late, early, middle].map { ServingsExport.Serving(amount: 250, timestamp: $0) }
        let export = try file(rows, today: late, calendar: utc)
        #expect(export.count == 3)
        #expect(export.first == early)
        #expect(export.last == late)
    }

    @Test func noRowsIsNothingToExport() throws {
        let utc = try calendar("UTC")
        #expect(ServingsExport.outcome(of: [], today: .distantPast, calendar: utc) == .nothing)
    }

    /// A failed read is never handed over as an empty history (rule `20-state`).
    @Test func aFailedReadIsNotNothing() throws {
        let utc = try calendar("UTC")
        #expect(ServingsExport.outcome(of: nil, today: .distantPast, calendar: utc) == .unreadable)
    }

    /// Fixed in every language: a format, not copy (D3).
    @Test func theFileDoesNotFollowACalendarsLocale() throws {
        let plain = try calendar("UTC")
        let moment = try instant(plain, 2026, 3, 3, 9, 14)
        let rows = [ServingsExport.Serving(amount: 1_250, timestamp: moment)]
        let expected = try file(rows, today: moment, calendar: plain)
        for locale in ["ru_RU", "uz_UZ", "ar_SA"] {
            #expect(try file(rows, today: moment, calendar: try calendar("UTC", locale: locale)).data == expected.data)
        }
    }

    /// Five years at eight a day.
    @Test func aLongHistoryLosesNoRow() throws {
        let utc = try calendar("UTC")
        let start = try instant(utc, 2021, 1, 1, 8)
        let rows = (0..<15_000).map {
            ServingsExport.Serving(amount: 250, timestamp: start.addingTimeInterval(Double($0) * 10_800))
        }
        let export = try file(rows.reversed(), today: start, calendar: utc)
        let lines = text(export).components(separatedBy: "\r\n")
        #expect(export.count == 15_000)
        #expect(lines.count == 15_002)
        #expect(lines[1] == "2021-01-01,08:00,250")
        #expect(lines[15_000] == "2026-02-19,05:00,250")
    }
}
