//
//  LiveWater.swift
//  WaterBuddy
//

import ActivityKit
import Foundation
import Observation
import UIKit

/// The app's half of the conformance: `LiveWaterAttributes` lives in `DataManager.swift`, Foundation only, and each of
/// the two files that import ActivityKit — this one and `LiveWaterWidget.swift` — declares it (rule `15-project`).
extension LiveWaterAttributes: ActivityAttributes {}

/// Keeps the one Live Activity in step with today while Settings' switch is on — today on the Lock Screen and in the
/// Dynamic Island (spec `2026-11-27-live-activity-design.md` §4). One of the two files that import ActivityKit (rule
/// `70-privacy`).
///
/// **Apple Health's mirror's shape** (`HealthMirror`): ActivityKit only through ``Source``, a struct of closures built
/// by ``Source/live()``, so every decision here is tested without it (rule `85-testing`); its passes on one
/// ``ReconcileQueue``; the decision itself ``LiveWaterPlan``'s, pure.
///
/// **It watches the manager** through Observation — today's total, the goal, the Glass, the language, the theme and
/// the switch — and each change asks for a pass; `WaterBuddyApp` asks for one each time the app comes forward. So every
/// change this process makes reaches the activity: Home, History, *Undo*, Settings, a watch pour, Siri's phrase, a
/// reminder's *Log a Glass*, `refresh()` and the day turning. **A pour the widget extension logs does not**: ActivityKit
/// does not show that process the app's activities, so the activity shows it the next time the app runs (D8).
///
/// **It starts one in the foreground only.** iOS refuses a start from the background and there is no server, so
/// after iOS ends an activity — eight hours in — the next waits for the app to come forward (D5).
///
/// App-only. ``shared`` is the app's, built by `WaterBuddyApp.init()` before anything draws, so it hears every change
/// from launch, and reachable by the intents that log in the background, so they can wait for it (``settled()``).
@MainActor
@Observable
final class LiveWater {

    /// Every way ActivityKit is reached. Main-actor, as `HealthMirror.Source` is: only the owner calls these.
    struct Source {
        /// Whether iOS lets WaterBuddy show Live Activities — its per-app setting, or *Don't Allow*.
        var allowed: () -> Bool
        /// Whether the app is in the foreground, the one place iOS allows a start.
        var inForeground: () -> Bool
        /// The activity running, if one is. One iOS has ended no longer counts.
        var running: () -> LiveWaterPlan.Running?
        /// Starts the one activity, after removing any ended one still on the Lock Screen, and says whether iOS took it.
        var start: (_ content: LiveWaterAttributes.ContentState, _ staleDate: Date) async -> Bool
        var update: (_ content: LiveWaterAttributes.ContentState, _ staleDate: Date) async -> Void
        /// Ends every activity of WaterBuddy's, at once.
        var end: () async -> Void
    }

    /// The app's own, over the app's manager and ActivityKit itself. The DEBUG fresh start builds one of its own on
    /// ``Source/silent()`` and never touches this one.
    static let shared = LiveWater(manager: .shared)

    /// What iOS last said — read when the switch is turned, on every pass and each time the app comes forward. Settings
    /// draws its refusal line from it.
    private(set) var allowed: Bool

    @ObservationIgnored private let manager: DataManager
    @ObservationIgnored private let source: Source
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let passes = ReconcileQueue()
    /// Whether a pass is waiting its turn: a request while one waits joins it rather than queueing a second.
    @ObservationIgnored private var waiting = false

    init(manager: DataManager, source: Source, calendar: Calendar, now: @escaping () -> Date = Date.init) {
        self.manager = manager
        self.source = source
        self.calendar = calendar
        self.now = now
        allowed = source.allowed()
        watch()
    }

    /// The product's calendar, named in the body rather than as a default argument: a default is evaluated outside the
    /// main actor, where `Calendar.waterBuddyDay` cannot be reached without a warning.
    convenience init(manager: DataManager, source: Source) {
        self.init(manager: manager, source: source, calendar: .waterBuddyDay)
    }

    convenience init(manager: DataManager) {
        self.init(manager: manager, source: .live())
    }

    /// The switch turning on, in Settings — the foreground, so the activity starts at once. On only if iOS allows it.
    func enable() {
        allowed = source.allowed()
        manager.liveActivityEnabled = allowed
        request()
    }

    /// The switch turning off: the activity leaves the Lock Screen at once.
    func disable() {
        manager.liveActivityEnabled = false
        request()
    }

    /// The app coming forward. iOS is asked again — Live Activities turned off for WaterBuddy turn the switch off, as
    /// refused notifications turn the reminders' off — and a pass follows, which starts one if iOS ended the last.
    func reconcile() async {
        allowed = source.allowed()
        if !allowed, manager.liveActivityEnabled {
            manager.liveActivityEnabled = false
        }
        request()
    }

    /// Asks for a pass. One already waiting takes this one's place.
    func request() {
        guard !waiting else { return }
        waiting = true
        passes.enqueue { [weak self] in
            await self?.runWaitingPass()
        }
    }

    /// Returns once every pass asked for before it has run.
    func settled() async {
        await passes.settled()
    }

    private func runWaitingPass() async {
        guard waiting else { return }
        waiting = false
        await pass()
    }

    /// One pass: the next change watched for first, then the plan's answer for today, carried out.
    private func pass() async {
        watch()
        allowed = source.allowed()
        let wanted = LiveWaterAttributes.ContentState(snapshot: today)
        let staleDate = DataManager.nextDayBoundary(after: now(), calendar: calendar)
        let step = LiveWaterPlan.step(
            enabled: manager.liveActivityEnabled, allowed: allowed, inForeground: source.inForeground(),
            running: source.running(), wanted: wanted, staleDate: staleDate
        )
        switch step {
        case .start:
            if !(await source.start(wanted, staleDate)) {
                #if DEBUG
                // Names the condition, never a figure (rule `75-diagnostics`).
                print("[WaterBuddy] iOS did not start the Live Activity; the next pass tries again.")
                #endif
            }
        case .update:
            await source.update(wanted, staleDate)
        case .end:
            await source.end()
        case .nothing:
            break
        }
    }

    /// Today as the manager holds it: the figures the widgets' snapshot carries, read from the observed state, so a
    /// change to any of them is watched.
    private var today: WaterSnapshot {
        WaterSnapshot(
            currentWater: manager.currentWater,
            dailyGoal: manager.dailyGoal,
            language: manager.language,
            serving: manager.servings[DataManager.usualSlot],
            servingGlyph: manager.vessels.home[DataManager.usualSlot].glyph.symbol,
            theme: manager.theme
        )
    }

    /// Watches everything the activity draws, and the switch, once; the change asks for a pass, which watches again
    /// before it reads. `onChange` runs synchronously on the thread of the mutation — the main actor's, since
    /// `DataManager` is — hence `assumeIsolated` (rule `43-concurrency`).
    private func watch() {
        withObservationTracking {
            _ = today
            _ = manager.liveActivityEnabled
        } onChange: { [weak self] in
            MainActor.assumeIsolated {
                self?.request()
            }
        }
    }
}

extension LiveWater.Source {

    /// Allows everything and shows nothing — for a `#Preview`, the DEBUG fresh start and its UI tests.
    static func silent() -> Self {
        Self(
            allowed: { true },
            inForeground: { true },
            running: { nil },
            start: { _, _ in true },
            update: { _, _ in },
            end: {}
        )
    }

    /// ActivityKit itself. One activity at a time (D1), requested with **no push type**, so ActivityKit never hands the
    /// app an APNs token (rule `70-privacy`); its stale date the day's end (D7). An activity counts as running while it
    /// is active or stale — one iOS ended, or the user dismissed, does not.
    ///
    /// **Not allowed below iOS 18**, where the widget extension lists no activity to draw it (`LiveWaterWidget`): an
    /// iPhone on 17 never starts one, and a switch restored onto one turns off when the app comes forward.
    static func live() -> Self {
        Self(
            allowed: {
                guard #available(iOS 18.0, *) else { return false }
                return ActivityAuthorizationInfo().areActivitiesEnabled
            },
            inForeground: { UIApplication.shared.applicationState == .active },
            running: {
                guard let activity = Activity<LiveWaterAttributes>.activities.first(where: { $0.stillRuns }) else {
                    return nil
                }
                return LiveWaterPlan.Running(content: activity.content.state, staleDate: activity.content.staleDate)
            },
            start: { content, staleDate in
                // An ended activity iOS still keeps on the Lock Screen goes first, so two never stand side by side.
                for activity in Activity<LiveWaterAttributes>.activities {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
                do {
                    _ = try Activity.request(
                        attributes: LiveWaterAttributes(),
                        content: ActivityContent(state: content, staleDate: staleDate),
                        pushType: nil
                    )
                    return true
                } catch {
                    return false
                }
            },
            update: { content, staleDate in
                for activity in Activity<LiveWaterAttributes>.activities where activity.stillRuns {
                    await activity.update(ActivityContent(state: content, staleDate: staleDate))
                }
            },
            end: {
                for activity in Activity<LiveWaterAttributes>.activities {
                    await activity.end(nil, dismissalPolicy: .immediate)
                }
            }
        )
    }
}

private extension Activity {

    /// Active, or past its stale date and not yet ended: one the app may still update.
    var stillRuns: Bool {
        activityState == .active || activityState == .stale
    }
}
