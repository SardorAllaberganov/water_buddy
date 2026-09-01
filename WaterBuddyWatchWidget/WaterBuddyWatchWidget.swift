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
        guard let data = DataManager.sharedDefaults.data(forKey: DataManager.Key.wristMirror),
              let mirror = try? JSONDecoder().decode(WristMirror.self, from: data),
              mirror.dailyGoal > 0 else {
            return WristWidgetEntry(date: .now, percentage: 0)
        }
        let percentage = Int((Double(mirror.currentWater) / Double(mirror.dailyGoal) * 100).rounded())
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
