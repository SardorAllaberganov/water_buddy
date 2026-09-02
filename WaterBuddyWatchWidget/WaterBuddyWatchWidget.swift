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
        completion(context.isPreview ? placeholder(in: context) : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WristWidgetEntry>) -> Void) {
        completion(Timeline(entries: [currentEntry()], policy: .after(Date().addingTimeInterval(15 * 60))))
    }

    /// Reads the persisted mirror directly, never through `WristModel.shared` — a `TimelineProvider`
    /// is `nonisolated`, and `WristModel` is `@MainActor` (rule `40-widget`'s "the provider reads
    /// `WaterSnapshot`, never `DataManager.shared`", one platform over).
    private func currentEntry() -> WristWidgetEntry {
        let defaults = DataManager.sharedDefaults
        let mirror = defaults.data(forKey: DataManager.Key.wristMirror)
            .flatMap { try? JSONDecoder().decode(WristMirror.self, from: $0) }

        // The face has to agree with the app beside it. `WristView` now draws a usable screen before
        // the first sync — against `DataManager.defaultDailyGoal`, counting pours still sitting in
        // the outbox — so a complication that read only the mirror would sit at 0% while the app it
        // belongs to showed real water. Same two inputs, same fallback, same arithmetic.
        let goal = mirror?.dailyGoal ?? DataManager.defaultDailyGoal
        guard goal > 0 else { return WristWidgetEntry(date: .now, percentage: 0) }

        let outbox = defaults.data(forKey: DataManager.Key.wristOutbox)
            .flatMap { try? JSONDecoder().decode([WristPour].self, from: $0) } ?? []
        let pending = WristPlan.todaysTotal(from: outbox, now: .now, calendar: .waterBuddyDay)

        let total = (mirror?.currentWater ?? 0) + pending
        let percentage = Int((Double(total) / Double(goal) * 100).rounded())
        return WristWidgetEntry(date: .now, percentage: min(999, max(0, percentage)))
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
        .description("Today's hydration.")
        .supportedFamilies([.accessoryCircular])
    }
}
