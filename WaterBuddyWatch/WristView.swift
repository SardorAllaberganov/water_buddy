//
//  WristView.swift
//  WaterBuddyWatch
//
//  The one screen (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §8):
//  vessel, three pour rows, "Synced Nm ago" — always present, never an alert. Deliberately no
//  settings, goal editor, history or reminders here; each would author state the watch cannot own
//  (v1 scope, owner-confirmed).
//

import SwiftUI

struct WristView: View {

    @State private var model = WristModel.shared
    @State private var now = Date()

    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            WristAurora()

            if let mirror = model.mirror, mirror.isGoalSet {
                List {
                    Section {
                        VStack {
                            GeometryReader { proxy in
                                let diameter = WristVessel.diameter(fitting: proxy.size.width, reserving: 0)
                                WristVessel(
                                    level: mirror.dailyGoal > 0 ? min(1, Double(model.todaysTotal) / Double(mirror.dailyGoal)) : 0,
                                    percentage: mirror.dailyGoal > 0 ? Int((Double(model.todaysTotal) / Double(mirror.dailyGoal) * 100).rounded()) : 0,
                                    volume: model.todaysTotal,
                                    goal: mirror.dailyGoal,
                                    diameter: diameter
                                )
                                .frame(maxWidth: .infinity)
                                .position(x: proxy.size.width / 2, y: diameter / 2)
                            }
                            .frame(height: 140)
                        }
                        .listRowBackground(Color.clear)
                    }

                    Section {
                        ForEach(Array(zip(vesselSlots, Self.resolveServings(from: mirror))), id: \.0.nameKey) { slot, amount in
                            Button {
                                model.pour(amount: amount)
                            } label: {
                                HStack {
                                    Label(slot.nameKey, systemImage: slot.symbol)
                                    Spacer()
                                    Text("\(amount) ml")
                                        .foregroundStyle(.secondary)
                                }
                                .frame(minHeight: 44)
                                .contentShape(Rectangle())
                                // The pane is the row, `HistoryView.ServingRow`'s own pattern:
                                // `.sheer` because this carries a short label and a control, not
                                // sentence-length text (rule `60-design-system`). Replaces a
                                // hand-rolled `Color.white.opacity(0.08))` `.listRowBackground` —
                                // every colour in this system comes from `Aurora` or `.liquidGlass`,
                                // and that literal was neither.
                                .liquidGlass(in: Capsule(), density: .sheer)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                        }
                    }

                    Section {
                        Text(Self.syncedCaption(composedAt: mirror.composedAt, now: now))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "iphone")
                        .font(.title)
                        .accessibilityHidden(true)
                    Text("Open WaterBuddy on your iPhone")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                }
                .foregroundStyle(.white)
                .padding()
            }
        }
        .onReceive(clock) { now = $0 }
    }

    /// `mirror.servings` when a mirror has arrived; `DataManager.defaultServings` before the first
    /// sync — never an empty row, and never invented amounts the phone hasn't confirmed once one
    /// has arrived.
    nonisolated static func resolveServings(from mirror: WristMirror?) -> [Int] {
        mirror?.servings ?? DataManager.defaultServings
    }

    /// "Synced Nm ago", rounded to whole minutes; "Synced just now" under a minute; "Not yet
    /// synced" before the first mirror ever arrives — attribution, always present, never an alert
    /// (spec §8).
    nonisolated static func syncedCaption(composedAt: Date?, now: Date) -> String {
        guard let composedAt else { return "Not yet synced" }
        let minutes = Int(now.timeIntervalSince(composedAt) / 60)
        return minutes < 1 ? "Synced just now" : "Synced \(minutes)m ago"
    }
}

#Preview {
    WristView()
}
