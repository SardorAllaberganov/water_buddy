//
//  WaterBuddyShortcuts.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 07/10/26.
//

import AppIntents

/// The product's two App Shortcuts: "Log water in WaterBuddy" logs the user's Glass by voice, and "How
/// much water today in WaterBuddy" answers with today's total and what is left — both with no setup,
/// and each shows as a tile in Spotlight and the Shortcuts app. *Log a Glass* is listed first, so its
/// tile keeps the place it had before the second arrived.
///
/// **One provider per app, in the target of the intents it names** — Apple's rule; the build reports
/// an intent that is not. So it lives in the app beside ``LogServingIntent`` and
/// ``TodaysWaterIntent``, never in the widget extension.
///
/// **Phrases are English and Russian only.** Siri has no Uzbek, so `AppShortcuts.xcstrings` ships no
/// `uz` — the one catalogue exempt from shipping all three languages. Every phrase names the app: Siri
/// needs `\(.applicationName)` to know whose shortcut it is.
struct WaterBuddyShortcuts: AppShortcutsProvider {

    // A computed `static var`, unlike the `static let`s elsewhere: the protocol's
    // `@AppShortcutsBuilder` requirement can only be met by one.
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogServingIntent(),
            phrases: [
                "Log water in \(.applicationName)",
                "Add water in \(.applicationName)",
                "Log a glass in \(.applicationName)",
            ],
            shortTitle: "Log a Glass",
            systemImageName: "mug.fill"
        )
        AppShortcut(
            intent: TodaysWaterIntent(),
            phrases: [
                "How much water today in \(.applicationName)",
                "How much water have I had in \(.applicationName)",
                "Check my water in \(.applicationName)",
            ],
            shortTitle: "Today's Water",
            systemImageName: "drop.fill"
        )
    }

    static let shortcutTileColor: ShortcutTileColor = .blue
}
