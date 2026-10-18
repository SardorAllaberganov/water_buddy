//
//  WaterBuddyApp.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftData
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
        // also where the DEBUG warning about it fires, instead of somewhere further in. It runs on
        // a fresh start too: it is the app's own bookkeeping on its own group, not test data.
        DataManager.prepareSharedStorage()

        #if DEBUG
        if let fresh = Self.freshStartManager(arguments: ProcessInfo.processInfo.arguments) {
            manager = fresh
            // No watch link: a paired watch's pours belong to the device's own store, which a
            // fresh start never opens.
            return
        }
        #endif

        // Constructing the singleton adopts today, materialises the goal, and rolls the day over
        // if the app was last open yesterday — all against the store resolved on the line above.
        manager = DataManager.shared

        #if canImport(WatchConnectivity)
        // `WristLink.session(_:didReceiveUserInfo:)` posts `didReceiveBatchNotification` rather
        // than calling `WristInbox` directly (see that notification's own DocC in
        // `DataManager.swift`), and `WristInbox.init` is where the observer for it gets
        // registered. Touching the singleton here — before `activate()` below can let anything
        // arrive — is what guarantees an early batch is never dropped for lack of a listener.
        _ = WristInbox.shared

        // Installs `WristLink.live` as the session's delegate and activates it, so a paired watch's
        // wrist pours (and this phone's own mirror, once Task 14/16 send one) have somewhere to
        // land the moment the session comes up.
        WristLink.live.activate()
        #endif

        // The reminder's *Log a Glass* launches the app in the background, and iOS hands the press to
        // the centre's delegate only if one is set before the app finishes launching; this runs
        // first. After the fresh start's return, so a UI test's fresh start installs nothing.
        ReminderResponder.install()
    }

    #if DEBUG
    /// The argument a UI test launches with to open on a new install; rule `85-testing` names the
    /// tests that pass it.
    static let freshStartArgument = "-WaterBuddyFreshStart"

    /// The fresh start's one suite, in the app's own preferences — never the App Group. Its name is
    /// fixed, so there is never more than one, and it is cleared at each launch (decision W11).
    static let freshStartSuite = "uitest.waterbuddy.freshstart"

    /// A new install, for the welcome's UI tests, on a device that finished its welcome long ago
    /// (spec 2026-10-14 §9).
    ///
    /// Given ``freshStartArgument``, the app is built on a throwaway suite, cleared first, and an
    /// in-memory store. Every side effect a test fixture turns off is turned off — the widget
    /// doorbell, the reminder reschedule, the wrist publish — the fixture discipline rule
    /// `85-testing` sets, applied to a run of the real app. The App Group's suite and store are
    /// never opened by it; `init()` resolves the suite before this, for the launch's own
    /// bookkeeping. Without the argument this is `nil`, and a Debug build runs what a Release
    /// one does — save the rating request, which a Debug build asks only when launched with
    /// `ReviewPrompt.launchArgument`; a Release build does not contain it.
    ///
    /// `nil`, said aloud, if the throwaway cannot be made. The run then opens on the device's own
    /// state, and the welcome's tests fail on their first look rather than writing anywhere they
    /// should not.
    static func freshStartManager(arguments: [String]) -> DataManager? {
        guard arguments.contains(freshStartArgument) else { return nil }

        guard let defaults = UserDefaults(suiteName: freshStartSuite),
              let store = try? ModelContainer(
                  for: WaterLog.self,
                  configurations: ModelConfiguration(isStoredInMemoryOnly: true)
              )
        else {
            print("WaterBuddy: the fresh start's throwaway suite or store could not be made, so this run opens on the device's own state.")
            return nil
        }
        defaults.removePersistentDomain(forName: freshStartSuite)

        return DataManager(
            defaults: defaults,
            modelContainer: store,
            reloadWidgets: {},
            rescheduleReminders: { _ in },
            publishWrist: { _ in }
        )
    }
    #endif

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

                // And notifications may have been turned off in iOS Settings meanwhile. Noticed
                // here, every screen stops promising a reminder that cannot fire (known issue
                // #100(d)). The scheduler is built inside the task and never stored
                // (rule `80-notifications`).
                Task { await ReminderPermission.reconcile(manager, using: ReminderScheduler.live()) }
            }
        }
    }
}

// MARK: - Root

/// Chooses the app's first screen: the welcome until the user has picked a goal of their own, the app
/// itself — ``RootTabView`` and its two destinations — every launch after that.
///
/// This is a `View` rather than an `if` inside `WaterBuddyApp.body` on purpose. Observation tracks
/// reads made while a *view* body evaluates; an `App` body is not a reliable scope for it, and the
/// gate has to re-evaluate the moment ``DataManager/isGoalSet`` flips — otherwise the first thing
/// the user sees after finishing the welcome is the welcome.
private struct RootView: View {

    @Environment(DataManager.self) private var manager

    var body: some View {
        Group {
            if manager.isGoalSet {
                RootTabView()
                    .transition(.opacity)
            } else {
                WelcomeView(goal: manager.dailyGoal, amounts: manager.servings)
                    .transition(.opacity)
            }
        }
        // A cross-fade rather than a hard cut, so the swap reads as the app opening rather than
        // as a glitch — and so the welcome outlives its last tap long enough to play its haptic.
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
