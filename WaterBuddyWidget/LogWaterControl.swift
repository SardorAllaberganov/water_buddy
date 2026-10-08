//
//  LogWaterControl.swift
//  WaterBuddyWidget
//
//  Created by Sardor Allaberganov on 08/10/26.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Control

/// Logs the Glass from Control Center, from a Lock Screen control slot, or from the Action Button —
/// without opening the app.
///
/// **One control, three places.** iOS 18 gave controls a protocol of their own, and a single
/// `ControlWidget` serves all three; iOS decides how much of it to draw in each.
///
/// **It draws no figure** — its title and the Glass's glyph, nothing else (rule `70-privacy`). All three
/// places are reachable on a locked iPhone, and a tile that says nothing about the user needs no
/// privacy-sensitive marking and no quiet form.
///
/// **It logs the Glass from the snapshot, never live**, as both widgets' buttons do (rule `40-widget`).
/// iOS builds the control from a value it reads when it chooses, and Apple's documented way to have it
/// read again is a reload — which ``DataManager/requestWidgetReload()`` asks for on every change to the
/// Glass or the language.
///
/// Design: `docs/superpowers/specs/2026-10-08-control-center-design.md`.
@available(iOS 18.0, *)
struct LogWaterControl: ControlWidget {

    /// Permanent once shipped: iOS identifies every placed control by its kind, so a renamed kind no
    /// longer matches the controls people have already placed.
    static let kind = "WaterBuddyLogWater"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind, provider: LogWaterControlProvider()) { snapshot in
            ControlWidgetButton(action: AddWaterIntent(amount: snapshot.serving)) {
                Label {
                    // Resolved here and handed over as finished text. Whether iOS resolves a control's
                    // `Text(key, bundle:)` in this process or in Control Center's own is not documented,
                    // and the second would draw the device's language; a `String` is in the chosen
                    // one either way.
                    Text(snapshot.language.bundle.localizedString(forKey: "Log Water", value: nil, table: nil))
                } icon: {
                    // The Glass's own glyph, from the menu that owns the vessels' glyphs, at the one
                    // named slot `DataManager.usualServing(in:)` also reads.
                    Image(systemName: vesselSlots[DataManager.usualSlot].symbol)
                }
            }
        }
        // `AddWaterIntent`'s own title and description, already translated in this catalogue. Static, as
        // every gallery string here is: iOS draws them, in the device's language, before any value has
        // been read (rule `40-widget`).
        .displayName("Log Water")
        .description("Adds a serving of water to today's total in WaterBuddy.")
    }
}

// MARK: - Value

/// Reads what the control's button needs — the Glass and the language — through the same read-only
/// ``DataManager/snapshot(defaults:calendar:now:)`` the widgets' ``HydrationProvider`` uses.
///
/// Never ``DataManager/shared``, and never a new `DataManager`: constructing one writes, from a process
/// whose job here is to describe a button (rule `40-widget`). At file scope rather than nested in the
/// control, as ``HydrationProvider`` is, so it takes no isolation from the type around it
/// (rule `43-concurrency`).
@available(iOS 18.0, *)
private struct LogWaterControlProvider: ControlValueProvider {

    /// What the gallery draws before anything has been read: the default Glass, titled in the device's
    /// language.
    var previewValue: WaterSnapshot {
        WaterSnapshot(currentWater: 0, dailyGoal: DataManager.defaultDailyGoal)
    }

    /// `async throws` because the protocol is; the read is synchronous and cannot fail.
    func currentValue() async throws -> WaterSnapshot {
        DataManager.snapshot(now: Date())
    }
}
