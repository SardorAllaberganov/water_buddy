//
//  ServingsExport.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import Foundation

/// Every serving, as the CSV file Premium's export sends, and what the sheet says of it (spec
/// `2026-11-01-export-design.md`).
///
/// **A pure value, as ``HealthPlan`` is.** It is handed plain rows and imports nothing but Foundation, so
/// every case is testable without a store or a screen, and nothing past the read holds a ``WaterLog``.
///
/// **No locale and no bundle, on purpose.** The headings are fixed English in every language, a format and
/// not copy (D3), and a date is a calendar's components, never a date style, so the file's bytes cannot
/// follow the app's language. Three columns and nothing else — rule `70-privacy`'s *The export file*.
///
/// A row reads its instant on the calendar it is handed, the zone the phone is in now, as History does:
/// ``WaterLog`` keeps no zone (D6).
///
/// `nonisolated`, stated outright: the app's default isolation is the main actor, and
/// `ServingsExportTests` reads this from off it, as a canary (rule `43-concurrency`).
nonisolated struct ServingsExport: Identifiable, Sendable, Equatable {

    /// One row, as the store holds it.
    nonisolated struct Serving: Sendable, Equatable {
        let amount: Int
        let timestamp: Date
    }

    /// What one read came to. A failed read stays apart from an empty history: it is never answered with a
    /// file of headings (rule `20-state`).
    nonisolated enum Outcome: Sendable, Equatable {
        case file(ServingsExport)
        case nothing
        case unreadable
    }

    /// *WaterBuddy-2026-11-01.csv*: dated, so two exports in Files do not collide.
    let name: String
    /// The file itself, in memory: the app writes none (rule `70-privacy`).
    let data: Data
    /// How many servings it holds.
    let count: Int
    /// The oldest serving's instant.
    let first: Date
    /// The newest serving's instant.
    let last: Date
    /// The file's first lines, headings first, as they are in the file: what the sheet shows of what will leave. Cut from
    /// the same lines as ``data``, so it cannot say anything the file does not.
    let preview: [String]

    var id: String { "\(name).\(count)" }

    /// How many servings ``preview`` leaves out.
    var moreServings: Int { count - (preview.count - 1) }

    /// How many servings the sheet shows.
    private static let previewServings = 5

    private static let headings = "date,time,amount_ml"
    /// RFC 4180's line ending.
    private static let lineEnding = "\r\n"

    /// The answer for one read. `nil` rows is a failed read; `today` dates the file's name.
    static func outcome(of rows: [Serving]?, today: Date, calendar: Calendar) -> Outcome {
        guard let rows else { return .unreadable }
        // By instant, not by the read's order: History's `+` logs an old instant after newer rows.
        let ordered = rows.sorted { $0.timestamp < $1.timestamp }
        guard let first = ordered.first, let last = ordered.last else { return .nothing }
        let lines = [headings] + ordered.map { line(for: $0, calendar: calendar) }
        return .file(ServingsExport(
            name: "WaterBuddy-\(day(of: today, calendar: calendar)).csv",
            data: Data((lines.joined(separator: lineEnding) + lineEnding).utf8),
            count: ordered.count,
            first: first.timestamp,
            last: last.timestamp,
            preview: Array(lines.prefix(previewServings + 1))
        ))
    }

    /// No field can hold a comma, so nothing is quoted.
    private static func line(for serving: Serving, calendar: Calendar) -> String {
        let clock = calendar.dateComponents([.hour, .minute], from: serving.timestamp)
        let time = String(format: "%02d:%02d", clock.hour ?? 0, clock.minute ?? 0)
        return "\(day(of: serving.timestamp, calendar: calendar)),\(time),\(serving.amount)"
    }

    private static func day(of date: Date, calendar: Calendar) -> String {
        let day = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", day.year ?? 0, day.month ?? 0, day.day ?? 0)
    }
}
