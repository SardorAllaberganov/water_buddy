//
//  WaterBuddyShortcuts.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 07/10/26.
//

import AppIntents

/// The product's one App Shortcut: "Log water in WaterBuddy" logs the user's Glass by voice, with no
/// setup, and the same action shows as a tile in Spotlight and the Shortcuts app.
///
/// **One provider per app, in the target of the intent it names** — Apple's rule; the build reports an
/// intent that is not. So it lives in the app beside ``LogServingIntent``, never in the widget
/// extension.
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
    }

    static let shortcutTileColor: ShortcutTileColor = .blue
}
