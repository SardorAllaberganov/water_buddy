//
//  ExportSheetTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import CoreTransferable
import Foundation
import Testing
import UniformTypeIdentifiers
@testable import WaterBuddy

/// What the export sheet says, and what it hands the share sheet (spec `2026-11-01-export-design.md`).
struct ExportSheetTests {

    private func utc() throws -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "UTC"))
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }

    private func date(_ calendar: Calendar, _ year: Int, _ month: Int, _ day: Int, hour: Int = 12) throws -> Date {
        try #require(calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour)))
    }

    /// Foundation's own interval, which trims what the two ends share by the locale's rules, so only the parts
    /// are pinned.
    @Test func theDatesLineSpansFirstToLast() throws {
        let calendar = try utc()
        let line = ExportSheet.dates(first: try date(calendar, 2025, 3, 3), last: try date(calendar, 2026, 11, 1),
                                     locale: Locale(identifier: "en_GB"), calendar: calendar)
        #expect(line.contains("3 March 2025"))
        #expect(line.contains("1 November 2026"))
    }

    @Test func oneDayDrawsOneDate() throws {
        let calendar = try utc()
        let line = ExportSheet.dates(first: try date(calendar, 2026, 11, 1, hour: 8),
                                     last: try date(calendar, 2026, 11, 1, hour: 20),
                                     locale: Locale(identifier: "en_GB"), calendar: calendar)
        #expect(line == "1 November 2026")
    }

    @Test func oneServingIsOneInstant() throws {
        let calendar = try utc()
        let moment = try date(calendar, 2026, 11, 1)
        let line = ExportSheet.dates(first: moment, last: moment, locale: Locale(identifier: "en_GB"), calendar: calendar)
        #expect(line == "1 November 2026")
    }

    /// `@MainActor` for `AppLanguage.locale` alone; the function it pins is `nonisolated`.
    @Test @MainActor func theCountFollowsTheAppsLanguageAndIsGrouped() {
        let english = AppLanguage.english, russian = AppLanguage.russian
        #expect(ExportSheet.count(1, strings: english.bundle, locale: english.locale) == "1 serving")
        #expect(ExportSheet.count(1_204, strings: english.bundle, locale: english.locale) == "1,204 servings")
        let line = ExportSheet.count(1_204, strings: russian.bundle, locale: russian.locale)
        #expect(line.contains("порции"))
        #expect(line.filter(\.isNumber) == "1204")
        #expect(!line.hasPrefix("1204"), "the figure was not grouped")
    }

    /// The name a destination files it under (D9). `suggestedFilename` is iOS 18.2 and later, as `exported(as:)` is;
    /// that the name survives *Save to Files* was measured on 27.0, 26.5 and 18.6 (plan Task 0).
    @Test func theSharedFileCarriesItsName() throws {
        guard #available(iOS 18.2, *) else { return }
        let calendar = try utc()
        let moment = try date(calendar, 2026, 11, 1)
        let outcome = ServingsExport.outcome(of: [.init(amount: 250, timestamp: moment)], today: moment, calendar: calendar)
        guard case .file(let export) = outcome else {
            Issue.record("no file")
            return
        }
        #expect(ServingsFile(export: export).suggestedFilename == "WaterBuddy-2026-11-01.csv")
    }

    /// The bytes the share sheet is handed, read back through the item, as
    /// `RecapImageTests.theSharedPictureKeepsItsPixels` does.
    @Test func theSharedFileIsTheCSV() async throws {
        // `exported(as:)` is iOS 18.2 and later; the gate runs on 27.0, and the item is the same on 17.
        guard #available(iOS 18.2, *) else { return }
        let calendar = try utc()
        let moment = try date(calendar, 2026, 11, 1)
        let outcome = ServingsExport.outcome(of: [.init(amount: 250, timestamp: moment)], today: moment, calendar: calendar)
        guard case .file(let export) = outcome else {
            Issue.record("no file")
            return
        }
        let data = try await ServingsFile(export: export).exported(as: .commaSeparatedText)
        #expect(data == export.data)
    }
}
