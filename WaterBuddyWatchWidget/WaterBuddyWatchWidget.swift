//
//  WaterBuddyWatchWidget.swift
//  WaterBuddyWatchWidget
//
//  One family: `.accessoryCircular`, a percentage ring — the shape people actually use this
//  complication family for. No interactivity: the phone widget's `AddWaterIntent` has no watch
//  equivalent in v1 (spec §12).
//

import WidgetKit
import SwiftUI

struct WristWidgetEntry: TimelineEntry {
    let date: Date
    let percentage: Int
}

struct WristWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WristWidgetEntry {
        WristWidgetEntry(date: .now, percentage: 62)
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
    /// The 15-minute refresh is a different job and stays: it is how the face picks up pours made in
    /// the watch app, which reloads no timelines of its own.
    func getTimeline(in context: Context, completion: @escaping (Timeline<WristWidgetEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.waterBuddyDay
        let stored = readStore()
        let dates = [now] + WristPlan.dayBoundaries(after: now, mirror: stored.mirror, calendar: calendar)
        let entries = dates.map { entry(at: $0, mirror: stored.mirror, outbox: stored.outbox, calendar: calendar) }
        completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(15 * 60))))
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
        // The face has to agree with the app beside it. `WristView` draws a usable screen before the
        // first sync — against `DataManager.defaultDailyGoal`, counting pours still sitting in the
        // outbox — and counts the phone's total only until the phone's day ends. A complication that
        // did either differently would show a different number from the app it belongs to: same two
        // inputs, same fallback, and `WristPlan.todaysTotal` doing the arithmetic for both.
        let goal = mirror?.dailyGoal ?? DataManager.defaultDailyGoal
        guard goal > 0 else { return WristWidgetEntry(date: date, percentage: 0) }

        let total = WristPlan.todaysTotal(mirror: mirror, outbox: outbox, now: date, calendar: calendar)
        let percentage = Int((Double(total) / Double(goal) * 100).rounded())
        return WristWidgetEntry(date: date, percentage: min(999, max(0, percentage)))
    }
}

struct WaterBuddyWatchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WaterBuddyWatchWidget", provider: WristWidgetProvider()) { entry in
            Gauge(value: Double(entry.percentage), in: 0...100) {
                Image(systemName: "drop.fill")
            } currentValueLabel: {
                Text("\(entry.percentage)")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Aurora.blue)
        }
        .configurationDisplayName("WaterBuddy")
        // No full stop: this is the phone's own `Today's hydration`, so the complication's catalogue
        // holds it value for value and `LocalizationTests` keeps the two from drifting.
        .description("Today's hydration")
        .supportedFamilies([.accessoryCircular])
    }
}
