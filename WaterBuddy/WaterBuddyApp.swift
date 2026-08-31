//
//  WaterBuddyApp.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftUI

@main
struct WaterBuddyApp: App {

    @Environment(\.scenePhase) private var scenePhase

    /// Resolved once at launch and handed down the view tree, rather than read back out of the
    /// global on every body evaluation.
    ///
    /// There is no `ModelContainer` alongside it: WaterBuddy's state is four integers in an App
    /// Group's `UserDefaults`, which is what lets a widget extension read it without a store to
    /// open. ``DataManager`` is the whole persistence layer.
    private let manager: DataManager

    init() {
        // Resolve the App Group before anything draws, so the container probe and the one-shot
        // migration out of `UserDefaults.standard` both happen here, in the app, at a moment we
        // picked — see `DataManager.prepareSharedStorage()`. If the capability is missing this is
        // also where the DEBUG warning about it fires, instead of somewhere further in.
        DataManager.prepareSharedStorage()

        // Constructing the singleton adopts today, materialises the goal, and rolls the day over
        // if the app was last open yesterday — all against the store resolved on the line above.
        manager = DataManager.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(manager)
        }
        .onChange(of: scenePhase) { _, phase in
            // Another process may have written while we were away — the widget's `AddWaterIntent`
            // runs in the extension, not here — and the day may have turned over. `refresh()` is
            // idempotent, so an extra call costs nothing.
            if phase == .active {
                manager.refresh()
            }
        }
    }
}

// MARK: - Root

/// Chooses the app's first screen: setup until the user has picked a goal of their own, the app
/// itself — ``RootTabView`` and its two destinations — every launch after that.
///
/// This is a `View` rather than an `if` inside `WaterBuddyApp.body` on purpose. Observation tracks
/// reads made while a *view* body evaluates; an `App` body is not a reliable scope for it, and the
/// gate has to re-evaluate the moment ``DataManager/isGoalSet`` flips — otherwise the first thing
/// the user sees after tapping *Get Started* is the setup screen they just finished.
private struct RootView: View {

    @Environment(DataManager.self) private var manager

    var body: some View {
        Group {
            if manager.isGoalSet {
                RootTabView()
                    .transition(.opacity)
            } else {
                GoalSetupView()
                    .transition(.opacity)
            }
        }
        // A cross-fade rather than a hard cut, so the swap reads as the app opening rather than
        // as a glitch — and so `GoalSetupView` outlives the tap long enough to play its haptic.
        //
        // The `.transition(.opacity)` above is what SwiftUI would apply to an animated `if`
        // anyway; it is written out because this is a deliberate choice and not a default worth
        // inheriting silently. Both screens draw the same `AuroraBackground`, so only the content
        // actually cross-fades — the backdrop holds still and the swap reads as one continuous
        // surface rather than as two screens trading places.
        .animation(.smooth(duration: 0.45), value: manager.isGoalSet)
        // **Both, together.** The bundle switches the strings; the locale switches the number
        // grouping the strings are formatted into. Setting only the first leaves "4 500" wearing
        // the device's separator inside a Russian sentence, which reads as a bug in the app rather
        // than as a language it does not have.
        //
        // Injected here, at the one root above both branches, so setup and the app proper cannot
        // disagree — and read from the model, so changing it invalidates observers and the whole
        // tree redraws without a relaunch.
        .environment(\.strings, manager.language.bundle)
        .environment(\.locale, manager.language.locale)
    }
}
