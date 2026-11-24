//
//  AppIconSwitcher.swift
//  WaterBuddy
//

import UIKit

/// iOS's app icon, reached through one seam (spec `2026-11-22-set-c-design.md` §3.7; rule `10-architecture`).
///
/// **Nothing is stored**: iOS keeps the choice, and the card reads it back each time it appears. A struct of
/// closures built by ``live()``, each reaching `UIApplication.shared` in its own body — `ReminderScheduler`'s shape —
/// so no UIKit value sits in a `static let` (rule `43-concurrency`). iOS shows its own alert after a change; a
/// failed change leaves the icon and the selection as they were, said under `#if DEBUG`, never retried.
struct AppIconSwitcher {
    var current: @MainActor () -> String?
    var set: @MainActor (String?) async throws -> Void

    static func live() -> AppIconSwitcher {
        AppIconSwitcher(
            current: { UIApplication.shared.alternateIconName },
            set: { try await UIApplication.shared.setAlternateIconName($0) }
        )
    }
}

extension AppTheme {
    /// The alternate icon set's name in the asset catalogue — `nil` for Aurora's, the primary (D4, D21).
    nonisolated var iconName: String? { self == .aurora ? nil : "AppIcon-\(rawValue.capitalized)" }

    /// The picker's image of the icon, generated beside it by `Tools/GenerateAppIcon.swift`.
    nonisolated var iconPreviewName: String { "IconPreview-\(rawValue.capitalized)" }

    /// The theme whose icon iOS shows, read from `alternateIconName`; Aurora's for the primary and for a name this
    /// build does not have.
    nonisolated static func icon(named name: String?) -> AppTheme {
        allCases.first { $0.iconName == name } ?? .aurora
    }
}
