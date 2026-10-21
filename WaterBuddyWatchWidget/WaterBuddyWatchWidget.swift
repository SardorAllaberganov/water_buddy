//
//  WaterBuddyWatchWidget.swift
//  WaterBuddyWatchWidget
//
//  Three families — `.accessoryCircular`, `.accessoryRectangular` and `.accessoryCorner` — drawn by
//  `WristFaceView`, all display-only: a tap opens the watch app, and the phone widget's
//  `AddWaterIntent` has no watch equivalent (spec 2026-10-20 §3.6).
//

import WidgetKit
import SwiftUI

struct WristWidgetEntry: TimelineEntry {
    let date: Date
    /// Today's figures, from `WristPlan.face(…)` — the function the screen reads too.
    let face: WristPlan.Face
    /// The phone's choice, carried on the mirror, as `WristModel.language` resolves it — so the
    /// faces draw the screen's language, not the watch's (rule `70-privacy`).
    let language: AppLanguage
}

struct WristWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WristWidgetEntry {
        WristWidgetEntry(date: .now, face: .sample, language: .system)
    }

    func getSnapshot(in context: Context, completion: @escaping (WristWidgetEntry) -> Void) {
        guard !context.isPreview else { return completion(placeholder(in: context)) }
        let stored = readStore()
        completion(entry(at: Date(), mirror: stored.mirror, outbox: stored.outbox, calendar: .waterBuddyDay))
    }

    /// An entry's `date` is when WidgetKit *renders* it, so each future-dated entry is a scheduled
    /// turnover that costs no wake-up: the phone's day ending, and the watch's own midnight. Without
    /// them a face nobody touches would still show yesterday's water tomorrow morning — the phone
    /// widget's midnight entry (rule `40-widget`), one platform over (spec §17).
    ///
    /// **`.atEnd`, not a periodic refresh.** The watch app reloads this face whenever it writes the
    /// store — on every pour, and on every mirror that is news (`WristModel.apply(_:)`) — and every
    /// instant the total changes with nothing arriving is already an entry here, so a timer would have
    /// nothing left to catch. The 15-minute refresh this replaced asked for 96 reloads a day of the
    /// ~75 a complication on the face is given, the same budget the phone's pushes need. `.atEnd` asks
    /// once, after the last boundary — when the next day's boundaries are due
    /// (`docs/superpowers/specs/2026-10-07-complication-current-design.md` §4.3).
    func getTimeline(in context: Context, completion: @escaping (Timeline<WristWidgetEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.waterBuddyDay
        let stored = readStore()
        let dates = [now] + WristPlan.dayBoundaries(after: now, mirror: stored.mirror, calendar: calendar)
        let entries = dates.map { entry(at: $0, mirror: stored.mirror, outbox: stored.outbox, calendar: calendar) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    /// Reads the persisted mirror and outbox directly, never through `WristModel.shared` — a
    /// `TimelineProvider` is `nonisolated`, and `WristModel` is `@MainActor` (rule `40-widget`'s "the
    /// provider reads `WaterSnapshot`, never `DataManager.shared`", one platform over). Read once per
    /// timeline, so every entry in it is drawn from the same store.
    private func readStore() -> (mirror: WristMirror?, outbox: [WristPour]) {
        let defaults = DataManager.sharedDefaults
        let mirror = defaults.data(forKey: DataManager.Key.wristMirror)
            .flatMap { try? JSONDecoder().decode(WristMirror.self, from: $0) }
        let outbox = defaults.data(forKey: DataManager.Key.wristOutbox)
            .flatMap { try? JSONDecoder().decode([WristPour].self, from: $0) } ?? []
        return (mirror, outbox)
    }

    private func entry(at date: Date, mirror: WristMirror?, outbox: [WristPour], calendar: Calendar) -> WristWidgetEntry {
        // The face has to agree with the app beside it: same store, same fallback, same arithmetic.
        WristWidgetEntry(
            date: date,
            face: WristPlan.face(mirror: mirror, outbox: outbox, now: date, calendar: calendar),
            language: AppLanguage(code: mirror?.languageCode)
        )
    }
}

struct WaterBuddyWatchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WaterBuddyWatchWidget", provider: WristWidgetProvider()) { entry in
            WristFaceRoot(entry: entry)
        }
        .configurationDisplayName("WaterBuddy")
        // No full stop: this is the phone's own `Today's hydration`, so the complication's catalogue
        // holds it value for value and `LocalizationTests` keeps the two from drifting.
        .description("Today's hydration")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryCorner])
    }
}
