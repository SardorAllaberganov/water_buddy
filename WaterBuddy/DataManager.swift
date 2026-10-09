//
//  DataManager.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import Foundation
import Observation
import SwiftData
import SwiftUI

#if canImport(WidgetKit)
import WidgetKit
#endif

#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

/// The single source of truth for today's hydration.
///
/// State lives in the WaterBuddy App Group, so the app and any extension added later
/// (widget, Live Activity, App Intent) read and write the same store. If the App Groups
/// capability has not been added yet, `DataManager` falls back to `UserDefaults.standard`
/// so the app still works — see ``isSharedStorageAvailable``.
///
/// The stored total rolls over to zero on the first interaction of a new calendar day.
@MainActor
@Observable
final class DataManager {

    // MARK: - Configuration

    /// The App Group the app and its extensions share.
    ///
    /// This must match the identifier added under
    /// *Signing & Capabilities → App Groups* on every target that reads this state.
    nonisolated static let appGroupIdentifier = "group.sardor.WaterBuddy"

    /// Goal used until the user picks their own, in millilitres.
    nonisolated static let defaultDailyGoal = 2_000

    /// The middle quick-add vessel's amount **before the user changes it**, in millilitres.
    ///
    /// This was `standardServing`, and it was a genuinely different thing: the single spelling of
    /// the one amount both front doors logged, which existed so the app's button and the widget's
    /// ``AddWaterIntent`` could not drift apart. The vessels are editable now, so that invariant is
    /// gone and the name went with it — a constant asserting an invariant the product no longer has
    /// is worse than the churn of renaming it.
    ///
    /// What replaces the invariant is a *shared read*, not a shared constant: the middle vessel is
    /// persisted in the App Group suite, `WaterSnapshot` carries it, and the widget draws and logs
    /// the value it finds there. The two front doors still cannot disagree — they now agree by
    /// reading the same key rather than by compiling the same literal.
    ///
    /// This value survives as the default the resolver falls back to when the key is absent or
    /// unreadable, and as the middle entry of ``HomeView/servings``' default triple.
    nonisolated static let defaultServing = 250

    /// The three quick-add vessels' amounts before the user edits them, smallest first.
    ///
    /// The middle entry is ``defaultServing`` — the one the widget draws and logs — so the two
    /// cannot be moved apart by accident.
    ///
    /// These live here rather than on `HomeView` because `DataManager` is compiled into the widget
    /// extension and `HomeView` is not, and the resolver needs a fallback on both sides of that
    /// boundary. `HomeView.servings(for:)` still owns the *names, glyphs and order* — the parts the
    /// widget genuinely never reads. The old DocC argued that putting 150 and 500 here would "ship
    /// two amounts and three glyph names into the widget binary that the widget never reads"; half
    /// of that still holds and is why the glyphs stayed behind, and the other half stopped being
    /// true the moment the widget had to follow an editable middle vessel.
    nonisolated static let defaultServings = [150, defaultServing, 500]

    /// Upper bound for both the goal and the running total, in millilitres.
    ///
    /// Guards against overflow and against a corrupt value poisoning the shared suite.
    nonisolated static let maximumDailyIntake = 100_000

    /// How many days ``history`` spans, today included.
    ///
    /// On the model rather than on `HistoryView`, where `servingRange` and `goalRange` live,
    /// because this is not a menu the screen offers the user — it is the width of the fetch the
    /// model performs, and the model is what bounds it. Rule `50-views` puts a screen's *offer* on
    /// the screen; the query behind it belongs here.
    ///
    /// Seven is also a ceiling the drawing depends on: a day column with a 44pt tap target is
    /// unaffordable much past this on the narrowest supported iPhone once `HistoryView`'s 28pt
    /// margins are taken off, so widening the window is a layout decision as well as a fetch one.
    nonisolated static let historyWindow = 7

    /// UserDefaults keys, namespaced because an App Group domain is shared by every
    /// target that joins the group.
    enum Key {
        nonisolated private static let prefix = "sardor.WaterBuddy."

        static let currentWater = prefix + "currentWater"
        static let dailyGoal = prefix + "dailyGoal"
        /// Stores a local day ordinal (`yyyyMMdd` as an `Int`), not a `Date` — see `dayOrdinal(for:)`.
        static let lastActiveDay = prefix + "lastActiveDay"
        /// Absent until the user first picks a goal — see ``DataManager/isGoalSet``. Deliberately
        /// never materialised the way `dailyGoal` is, because its absence carries meaning.
        static let isGoalSet = prefix + "isGoalSet"
        static let didMigrateFromStandard = prefix + "didMigrateFromStandardDefaults"
        /// The reminders toggle. Absent until the user turns reminders on — like ``isGoalSet``, and
        /// unlike ``dailyGoal``, it is deliberately never materialised: scheduling notifications for
        /// someone who never asked is the wrong default, so "missing" and "off" mean the same thing.
        static let remindersEnabled = prefix + "remindersEnabled"
        /// The chosen UI language, as a code like `"ru"`. **Absent means follow the device**, which
        /// is the third key whose absence carries meaning — see ``AppLanguage/system``.
        static let language = prefix + "language"
        /// The three quick-add amounts, as a positional `[Int]` of exactly three: Cup, Glass,
        /// Bottle. **Absent means the user has kept the defaults**, which is why nothing
        /// materialises it — `resolveServings(in:)` answers absence itself, the way
        /// ``remindersEnabled`` and ``language`` do.
        ///
        /// One key rather than three, because the three amounts are one authored fact. Three keys
        /// would manufacture eight presence states, seven of which no writer ever produces, and a
        /// per-key fallback could resolve a triple nobody wrote — Cup stored at 500 beside a Glass
        /// that fell back to 250.
        static let servings = prefix + "servings"
        /// The watch's own pending pours, JSON-encoded `[WristPour]`. Written only by `WristModel`, in
        /// the watch's local App Group suite — never read or written from the phone.
        static let wristOutbox = prefix + "wristOutbox"
        /// The watch's last-received `WristMirror`, JSON-encoded. Written only by `WristModel`, so the
        /// watch has something to draw before the first `updateApplicationContext` of a fresh launch.
        static let wristMirror = prefix + "wristMirror"
        /// The phone's per-day applied ledger, JSON-encoded `[Int: [UUID]]` (day ordinal → ids already
        /// folded into `WaterLog`). Written only by `ingest(_:)`, in the phone's App Group suite.
        ///
        /// `nonisolated` — unlike its neighbours above — because `readAppliedLedger(from:)` and
        /// `writeAppliedLedger(_:to:keepingDaysSince:)` are themselves `nonisolated static` (see
        /// `readAppliedLedger(from:)` for why), and a nested type's members otherwise infer the
        /// enclosing `@MainActor` class's isolation. The older keys above go unmarked only because
        /// nothing nonisolated has needed to read them by name yet — not because they differ.
        nonisolated static let wristApplied = prefix + "wristApplied"

        /// Every key above, for a test that has to prove a read wrote nothing.
        ///
        /// It exists because the widget's two read-path tripwires — `readingLeavesTheStoreUntouched`
        /// and `readingAnEmptySuiteDoesNotCreateKeys` — can only compare the keys they are handed,
        /// and the list they used to be handed was hand-written *in the test file*. It enumerated
        /// six of the seven keys for two releases, omitting ``remindersEnabled``, so both tripwires
        /// were blind to a whole key while reading as though they covered the suite. Rule
        /// `30-rollover` warns about exactly that: the helper "will not notice a new one on its own".
        ///
        /// Keeping the roster **here**, three lines under the declarations it mirrors, is what makes
        /// the omission hard: adding a key and forgetting this list puts the two within one screen
        /// of each other, and `theTripwireHelperEnumeratesEveryStoredKey` fails the moment they
        /// disagree. Production code never reads this — it names the constants directly.
        static let all = [
            currentWater, dailyGoal, lastActiveDay, isGoalSet,
            didMigrateFromStandard, remindersEnabled, language, servings,
            wristOutbox, wristMirror, wristApplied,
        ]
    }

    // MARK: - Shared instance

    @available(watchOS, unavailable, message: "The watch is not a writer of the phone's stores. Use WristModel and WristPlan.")
    static let shared = DataManager()

    // MARK: - Dependencies

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let modelContext: ModelContext
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let reloadWidgets: () -> Void
    @ObservationIgnored private let rescheduleReminders: ([ReminderPlan.Slot]) -> Void
    /// Takes the suite to publish from **as a parameter**, like `rescheduleReminders` takes its
    /// slots — never reading a global — so a test or preview that omits an override still cannot
    /// leak into the real App Group suite merely by publishing from the instance's own throwaway
    /// one (rule `85-testing`; the same fix already applied to `rescheduleReminders`/
    /// `reloadWidgets`, generalised here to the case where the closure itself needs an input).
    @ObservationIgnored private let publishWrist: (UserDefaults) -> Void
    @ObservationIgnored private var dayChangeObservers: [NSObjectProtocol] = []

    // MARK: - State

    @ObservationIgnored private var storedCurrentWater: Int
    @ObservationIgnored private var storedDailyGoal: Int
    @ObservationIgnored private var storedIsGoalSet: Bool
    @ObservationIgnored private var storedTodaysLogs: [WaterLog] = []
    @ObservationIgnored private var storedHistory: [DaySummary] = []
    @ObservationIgnored private var storedHistoryLogs: [Int: [WaterLog]] = [:]
    @ObservationIgnored private var storedRemindersEnabled: Bool
    @ObservationIgnored private var storedLanguage: AppLanguage
    @ObservationIgnored private var storedServings: [Int]

    /// Millilitres logged so far today. Clamped to `0...maximumDailyIntake`.
    ///
    /// Reads and writes are observed by SwiftUI *and* written straight through to the
    /// shared suite, so another process sees the new value on its next read.
    var currentWater: Int {
        get {
            access(keyPath: \.currentWater)
            return storedCurrentWater
        }
        set {
            let clamped = newValue.clamped(to: 0...Self.maximumDailyIntake)
            guard clamped != storedCurrentWater else { return }
            withMutation(keyPath: \.currentWater) {
                storedCurrentWater = clamped
                defaults.set(clamped, forKey: Key.currentWater)
            }
            reloadWidgets()
            publishWrist(defaults)
        }
    }

    /// Today's target in millilitres. Defaults to ``defaultDailyGoal``.
    ///
    /// Clamped to at least 1 so ``progress`` can never divide by zero.
    ///
    /// **Changing it re-plans the day, and that is not optional.** ``ReminderPlan`` silences today
    /// once `currentWater >= dailyGoal`, so the goal is *half* of "goal reached" — raising it
    /// un-meets a met goal and the rest of today has to come back, and lowering it past the total
    /// has to stop the nagging. None of that was reachable while ``saveDailyGoal(ml:)`` ran exactly
    /// once per install, from setup, before any water existed. A goal the user can edit from
    /// `SettingsView` makes it reachable, and `raisingTheGoalPastAMetTotalRePlansToday` and
    /// `loweringTheGoalBelowTheTotalSilencesToday` both failed before this call existed.
    ///
    /// The hook is on the **setter**, not inside ``saveDailyGoal(ml:)``, for two reasons: it is
    /// then symmetrical with ``remindersEnabled``, whose setter re-plans for the identical reason;
    /// and the equality guard above comes to cover the re-plan exactly as it already covers the
    /// widget doorbell, so a no-op write still costs nothing (rule `20-state`).
    var dailyGoal: Int {
        get {
            access(keyPath: \.dailyGoal)
            return storedDailyGoal
        }
        set {
            let clamped = newValue.clamped(to: 1...Self.maximumDailyIntake)
            guard clamped != storedDailyGoal else { return }
            withMutation(keyPath: \.dailyGoal) {
                storedDailyGoal = clamped
                defaults.set(clamped, forKey: Key.dailyGoal)
            }
            reloadWidgets()
            publishWrist(defaults)
            rescheduleRemindersNow()
        }
    }

    /// The three quick-add vessels' amounts, smallest-slot first: Cup, Glass, Bottle.
    ///
    /// Positional and always exactly three. Index 1 is the vessel the **widget** draws and logs, so
    /// the order is load-bearing in a way the values are not — this is never sorted on read or on
    /// write, because sorting would move which vessel the widget follows when the user edited a
    /// different one.
    ///
    /// **Two vessels may hold the same amount and they may be in any order.** The editor does not
    /// enforce ascent, and that is a decision rather than an omission: making an edit to Cup push
    /// Glass out of its way would silently change what the widget logs, which is exactly the
    /// bug-found-only-by-arithmetic that the old `standardServing` constant existed to prevent.
    /// `HomeView.Serving` is identified by its slot rather than by its amount so duplicates draw as
    /// two rows instead of collapsing into one.
    ///
    /// Each vessel is clamped to `1...maximumDailyIntake` on the way in — a floor against
    /// corruption, not a menu; `HistoryView.servingRange` is the menu and it belongs to the screen
    /// that offers it. A triple of the wrong length is **rejected outright** rather than merged,
    /// because merging would invent amounts the user never chose.
    ///
    /// The setter rings ``reloadWidgets()`` and does **not** reschedule reminders: `ReminderPlan`
    /// takes no serving, so the plan cannot move. The doorbell is not optional — the amount is
    /// baked into the widget's archive when it renders, so nothing else would refresh its face.
    var servings: [Int] {
        get {
            access(keyPath: \.servings)
            return storedServings
        }
        set {
            guard newValue.count == Self.defaultServings.count else { return }
            let clamped = newValue.map { $0.clamped(to: 1...Self.maximumDailyIntake) }
            guard clamped != storedServings else { return }
            withMutation(keyPath: \.servings) {
                storedServings = clamped
                defaults.set(clamped, forKey: Key.servings)
            }
            reloadWidgets()
            publishWrist(defaults)
        }
    }

    /// `true` once the user has chosen their own daily goal, so a first launch can show setup and
    /// every launch after it can skip straight to the app.
    ///
    /// Read-only on purpose: the flag is a consequence of ``saveDailyGoal(ml:)``, and letting it be
    /// set independently would allow "setup is complete" and "there is no goal" to be true at once.
    ///
    /// Note this cannot be inferred from the presence of ``Key/dailyGoal``. `init` materialises the
    /// resolved goal into the shared suite so a widget process never reads a missing key as zero,
    /// which means that key exists from the first launch whether or not anyone chose it.
    var isGoalSet: Bool {
        access(keyPath: \.isGoalSet)
        return storedIsGoalSet
    }

    /// Today's servings, newest first — the same rows ``fetchLogsForToday()`` returns, published
    /// so a view can observe them.
    ///
    /// ``fetchLogsForToday()`` reads the store directly and therefore calls no `access(keyPath:)`,
    /// so a `body` that reads it registers no dependency and never redraws. This is the observable
    /// face of those rows, republished by ``recomputeToday()`` — which already fetches exactly this
    /// array on every mutation, so publishing it costs no extra read.
    ///
    /// A SwiftData `@Query` would be the SwiftUI-shaped answer, and is not available here: a
    /// `ModelContext` reached from a view is the boundary rule `10-architecture` exists to hold.
    ///
    /// **There is deliberately no equality guard**, where ``currentWater`` and ``dailyGoal`` both
    /// carry one. ``WaterLog`` is a `@Model` class, so its `Hashable` conformance is by
    /// `persistentModelID`: the array after an *amount edit* compares equal to the array before it,
    /// and a guard would swallow precisely the change a history row most needs to see.
    /// `editingALogInvalidatesObserversOfTodaysLogs` is what keeps anyone from adding one.
    ///
    /// Read-only for the same reason ``isGoalSet`` is — it is a consequence of the logs, and a
    /// caller able to assign it could leave the rows and the total disagreeing.
    var todaysLogs: [WaterLog] {
        access(keyPath: \.todaysLogs)
        return storedTodaysLogs
    }

    /// The last ``historyWindow`` days, oldest first, today last.
    ///
    /// The observable channel a history screen reads. `allLogs()` fetched from a `body` would
    /// register no `access(keyPath:)`, so the screen would draw once and never redraw — the same
    /// trap ``todaysLogs`` exists to close, and the reason neither is a method.
    ///
    /// **This one carries an equality guard where ``todaysLogs`` deliberately does not**, and the
    /// difference is the element type rather than a change of mind. ``WaterLog`` is a `@Model`
    /// class hashed by `persistentModelID`, so the array after an *amount edit* compares equal to
    /// the array before it and a guard would swallow exactly the change the screen needs.
    /// ``DaySummary`` is a value compared by its fields, so an equal array genuinely means nothing
    /// moved — and ``refresh()`` runs on every foreground, where an unconditional mutation would
    /// redraw the card for nothing (the same reasoning as ``loadFromStore()``).
    ///
    /// Read-only, like ``todaysLogs`` and ``isGoalSet``: a consequence of the rows, never an input.
    var history: [DaySummary] {
        access(keyPath: \.history)
        return storedHistory
    }

    /// The window's servings by day ordinal, newest first within each day — what History lists for a
    /// day that is not today. A day with no servings has no key.
    ///
    /// **Published from the fetch ``history`` is summed from** (``republishHistory()``), so the list
    /// under a bar and the bar itself are one reading of the store — the reason ``recomputeToday()``
    /// publishes today's rows and total from one fetch.
    ///
    /// **No equality guard**, for ``todaysLogs``' reason: a `[WaterLog]` compares by
    /// `persistentModelID`, so the rows after an edit equal the rows before it.
    /// `retimingAServingWithinAPastDayRepublishesItsRows` fails if one is added. ``history`` keeps
    /// its guard, so the week card still does not redraw on every foreground.
    ///
    /// Empty wherever ``role`` does not draw history: the widget extension never builds it.
    /// Read-only, like ``todaysLogs`` — a consequence of the rows, never an input.
    var historyLogs: [Int: [WaterLog]] {
        access(keyPath: \.historyLogs)
        return storedHistoryLogs
    }

    /// Whether the user wants a nudge every two hours between 09:00 and 21:00.
    ///
    /// Settable, unlike ``isGoalSet`` — this one genuinely is a preference rather than a consequence
    /// — but it carries the same write-through and equality guard as ``currentWater`` and
    /// ``dailyGoal``, so a no-op write neither invalidates observers nor re-plans the day.
    ///
    /// Changing it re-plans immediately, in both directions. Switching reminders **off** has to
    /// clear the schedule, not merely stop adding to it: notifications already filed with the system
    /// would otherwise keep arriving for days after the toggle said no (rule `80-notifications`).
    ///
    /// ``refresh()`` re-reads it, as it does ``servings`` and ``language``. Only the app writes it,
    /// but the widget extension's instance can outlive the write, and that instance's plan is what
    /// `AddWaterIntent` files.
    var remindersEnabled: Bool {
        get {
            access(keyPath: \.remindersEnabled)
            return storedRemindersEnabled
        }
        set {
            guard newValue != storedRemindersEnabled else { return }
            withMutation(keyPath: \.remindersEnabled) {
                storedRemindersEnabled = newValue
                defaults.set(newValue, forKey: Key.remindersEnabled)
            }
            rescheduleRemindersNow()
        }
    }

    /// The language every string in the product is resolved through.
    ///
    /// A preference, like ``remindersEnabled`` — settable, write-through, equality-guarded, and
    /// **never materialised**: ``AppLanguage/system`` is the *absence* of the key, so "follow the
    /// device" cannot be stored as a value (rule `25-shared-storage`).
    ///
    /// **It rings the widget doorbell**, which ``remindersEnabled`` does not. The widget draws
    /// localised strings of its own, and a timeline it has already built would otherwise keep the
    /// old language until something else happened to change.
    ///
    /// **It also publishes to the wrist**, which ``remindersEnabled`` again does not — unlike a
    /// reminder, `languageCode` is a field on the wire protocol (`WristMirror.languageCode`), so a
    /// language change is state the watch has to hear about too, the same way `currentWater`,
    /// `dailyGoal` and `servings` already do on their own setters below.
    var language: AppLanguage {
        get {
            access(keyPath: \.language)
            return storedLanguage
        }
        set {
            guard newValue != storedLanguage else { return }
            withMutation(keyPath: \.language) {
                storedLanguage = newValue
                if let code = newValue.code {
                    defaults.set(code, forKey: Key.language)
                } else {
                    // Removed, not set to a sentinel: the absence *is* the state.
                    defaults.removeObject(forKey: Key.language)
                }
            }
            reloadWidgets()
            publishWrist(defaults)
        }
    }

    /// Fraction of the goal reached today, clamped to `0...1`.
    ///
    /// Safe to hand straight to `ProgressView(value:)` or `Gauge`.
    var progress: Double {
        progressUnclamped.clamped(to: 0...1)
    }

    /// Fraction of the goal reached today, *not* clamped — `1.5` means 150% of the goal.
    ///
    /// Use this to celebrate overachievement; use ``progress`` to draw a bar.
    var progressUnclamped: Double {
        let goal = dailyGoal
        guard goal > 0 else { return 0 }
        return Double(currentWater) / Double(goal)
    }

    /// `true` when the App Group container is reachable, meaning state is genuinely shared
    /// with extensions. `false` means the App Groups capability has not been added yet and
    /// this process is reading and writing its own private `UserDefaults.standard`.
    nonisolated static var isSharedStorageAvailable: Bool { appGroupContainerExists }

    // MARK: - Life cycle

    /// - Parameters:
    ///   - defaults: The store to persist into. Defaults to the App Group suite.
    ///   - calendar: Decides when "today" ends. Defaults to the user's local Gregorian day.
    ///   - now: The clock. Injectable so the daily rollover is testable without waiting a day.
    ///   - reloadWidgets: Called after every mutation to nudge WidgetKit.
    @available(watchOS, unavailable, message: "The watch is not a writer of the phone's stores.")
    init(
        defaults: UserDefaults = DataManager.sharedDefaults,
        modelContainer: ModelContainer = DataManager.sharedModelContainer,
        calendar: Calendar = .waterBuddyDay,
        now: @escaping () -> Date = Date.init,
        reloadWidgets: @escaping () -> Void = DataManager.requestWidgetReload,
        rescheduleReminders: @escaping ([ReminderPlan.Slot]) -> Void = DataManager.requestReminderReschedule,
        publishWrist: @escaping (UserDefaults) -> Void = DataManager.requestWristPublish
    ) {
        self.defaults = defaults
        self.modelContext = ModelContext(modelContainer)
        self.calendar = calendar
        self.now = now
        self.reloadWidgets = reloadWidgets
        self.rescheduleReminders = rescheduleReminders
        self.publishWrist = publishWrist

        storedRemindersEnabled = defaults.bool(forKey: Key.remindersEnabled)
        storedLanguage = Self.resolveLanguage(in: defaults)
        storedServings = Self.resolveServings(in: defaults)
        storedDailyGoal = Self.resolveDailyGoal(in: defaults)
        storedIsGoalSet = Self.resolveIsGoalSet(in: defaults, goal: storedDailyGoal)
        storedCurrentWater = defaults.integer(forKey: Key.currentWater).clamped(to: 0...Self.maximumDailyIntake)

        // Materialise the resolved goal so a widget process never reads a missing — or
        // corrupt — key as 0. Only from the app: this write exists *for* the extensions, and an
        // extension doing it to itself would put a key in the group that the one-shot migration
        // then mistakes for state the app already wrote — see `migrateFromStandardIfNeeded`.
        if Self.role.ownsSharedStorage, defaults.object(forKey: Key.dailyGoal) as? Int != storedDailyGoal {
            defaults.set(storedDailyGoal, forKey: Key.dailyGoal)
        }

        resetIfNeeded()
        seedFromCachedTotalIfNeeded()
        recomputeToday()
        republishHistory()
        startObservingDayChanges()
        rescheduleRemindersNow()
    }

    deinit {
        let center = NotificationCenter.default
        for observer in dayChangeObservers {
            center.removeObserver(observer)
        }
    }

    // MARK: - Logging water

    /// Logs `amount` millilitres against today's total.
    ///
    /// Re-reads the store and rolls the day over first, so water tapped in after midnight lands
    /// on the new day rather than topping up yesterday. Non-positive amounts are ignored — use
    /// ``removeWater(amount:)`` to take water back off.
    ///
    /// The re-read is what makes this safe to call from more than one process. `currentWater`'s
    /// getter returns this instance's cached figure, so an instance that has been sitting idle —
    /// a widget extension WidgetKit last woke an hour ago, or the app left open while a Shortcut
    /// logged a glass — would otherwise compute `staleTotal + amount` and write that straight over
    /// a newer figure, quietly losing the other process's serving.
    func addWater(amount: Int) {
        addLog(amount: amount)
    }

    /// Takes `amount` millilitres back off today's total, never going below zero.
    ///
    /// Re-reads the store first, for the reason given on ``addWater(amount:)``.
    func removeWater(amount: Int) {
        guard amount > 0 else { return }
        refresh()

        // Today's total is derived from the logs now, so subtracting from the cached figure
        // would be undone by the next recompute. Take the water off the servings themselves,
        // newest first: delete each one the removal swallows whole, and shrink the one it only
        // partly covers. That is what "take water back off" means once water has provenance.
        var remaining = amount
        for log in fetchLogsForToday() where remaining > 0 {
            if log.amount <= remaining {
                remaining -= log.amount
                modelContext.delete(log)
            } else {
                log.amount -= remaining
                remaining = 0
            }
        }
        saveAndRecompute()
    }

    // MARK: - The log

    /// Records a serving of `amount` millilitres, at `date`.
    ///
    /// This is the only way water enters the product. ``addWater(amount:)`` is a synonym kept so
    /// the callers that log the standard serving did not have to change when the store did.
    /// `AddWaterIntent` and `LogServingIntent` are the two left: `HomeView`'s row offers three vessels
    /// and calls this method directly, because "add the standard serving" stopped being what its
    /// buttons do.
    ///
    /// Re-reads the store and rolls the day over first, for the reason on ``addWater(amount:)``:
    /// two processes hold their own instance, and an idle one would otherwise recompute a total
    /// from a stale figure. Non-positive amounts are ignored in both directions — use
    /// ``deleteLog(_:)`` to take a serving back off.
    func addLog(amount: Int, at date: Date? = nil) {
        guard amount > 0 else { return }
        refresh()

        modelContext.insert(WaterLog(amount: amount, timestamp: date ?? now()))
        saveAndRecompute()
    }

    #if canImport(WatchConnectivity)
    /// Folds pours received from the watch into the ledger.
    ///
    /// The guard is a **conjunction**, and each half closes a hole the other leaves open
    /// (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §4):
    /// - Without the applied ledger, an ordinary swipe-to-delete un-acks a pour still in the
    ///   watch's outbox; the resend finds nothing and re-inserts it. The deletion undoes itself.
    /// - Without a full-history existence check, a resend past the ledger's own day-bucket inserts
    ///   a **second** `WaterLog` with the same id — legal, since `WaterLog.id` is deliberately not
    ///   `@Attribute(.unique)` (two processes insert here) — and the serving counts twice, forever.
    ///
    /// The ledger is keyed by **the pour's own day**, not "today": its job is "was this specific
    /// pour already applied", which does not depend on what day it happens to be on the phone right
    /// now.
    ///
    /// - Returns: how many pours were actually folded. `0` — the expected steady state once the
    ///   watch's outbox and this ledger agree — writes nothing and rings no doorbell.
    @discardableResult
    func ingest(_ pours: [WristPour]) -> Int {
        refresh()

        // Both halves of the conjunction guard must **decline the whole batch** on a failed read,
        // never collapse "could not read" into "empty" (rule `20-state`, `fetch(_:)`'s own DocC).
        // Falling back to `[:]` on a ledger-decode failure, or to `[]` on a failed existence read
        // (`allLogs()`'s own `?? []`, which this deliberately bypasses in favour of `fetch(nil)`
        // directly), would let a re-sent pour insert a permanent duplicate the moment the store
        // degrades: with both halves reading as empty, `existingIds` and the ledger would both
        // wave every incoming id through. Declining here costs nothing real: the watch's own copy
        // is untouched and simply stays in its outbox for the next attempt.
        guard let appliedLedgerOnDisk = readAppliedLedger(), let existingLogs = fetch(nil) else { return 0 }

        var appliedByDay = appliedLedgerOnDisk
        let existingIds = Set(existingLogs.map(\.id))
        var foldedCount = 0
        // Which days this **pass** actually inserted into, as opposed to a day the ledger already
        // held from an earlier write — see the cutoff computation below for why the distinction
        // matters.
        var foldedDaysThisPass: Set<Int> = []

        for pour in pours where pour.amount > 0 && pour.amount <= Self.maximumDailyIntake {
            let day = Self.dayOrdinal(for: pour.at, in: calendar)
            guard !(appliedByDay[day]?.contains(pour.id) ?? false),
                  !existingIds.contains(pour.id) else { continue }
            modelContext.insert(WaterLog(id: pour.id, amount: pour.amount, timestamp: pour.at))
            appliedByDay[day, default: []].insert(pour.id)
            foldedDaysThisPass.insert(day)
            foldedCount += 1
        }

        guard foldedCount > 0 else { return 0 }

        // The ledger is written only **after** a successful save, never before. A crash or a save
        // failure between the two previously left ids marked applied with no `WaterLog` row behind
        // them — every future resend of the same ids was then blocked by the ledger, with nothing
        // for `existingIds` to find either, and the user's watch-authored water was lost silently
        // and irrecoverably. `saveAndRecompute()` reports whether the save actually succeeded; on
        // `false` this declines exactly like a failed read above, leaving the ledger untouched so a
        // resend once the store recovers still folds the pour.
        guard saveAndRecompute() else { return 0 }

        // Calendar-space subtraction, not ordinal arithmetic: `dayOrdinal` is a mixed-radix
        // `year*10_000 + month*100 + day` encoding, and subtracting a plain day count from it
        // borrows incorrectly across the month/day radix the moment the count exceeds a month's
        // length — which 90 always does.
        let cutoffDate = calendar.date(byAdding: .day, value: -Self.appliedLedgerRetentionDays, to: now()) ?? now()
        let normalCutoff = Self.dayOrdinal(for: cutoffDate, in: calendar)
        // A pour whose own day already precedes the 90-day retention window (a watch that was
        // offline a long time, or a system-daemon-held `transferUserInfo` delivered late) must not
        // be trimmed by the **same write** that just folded it — that would leave it protected only
        // by the full-history existence check, which is exactly what `deleteLog(_:)` removes,
        // reopening the resurrection hole this ledger exists to close. Extending the floor back to
        // the oldest day actually folded *this pass* — never to a pre-existing ledger day the
        // ledger already held, which is free to age out on schedule — costs nothing in the ordinary
        // case: `foldedDaysThisPass` is almost always within the window already, so `min` leaves
        // `normalCutoff` unchanged.
        let cutoff = min(normalCutoff, foldedDaysThisPass.min() ?? normalCutoff)
        Self.writeAppliedLedger(appliedByDay, to: defaults, keepingDaysSince: cutoff)
        return foldedCount
    }

    /// How many days of the applied ledger to keep. Unbounded growth is bounded because every
    /// day's array only ever holds the ids the watch resent while offline for that long — but a
    /// number here is still safer than none, matching the spirit of the wire protocol's own
    /// construction bounds (`WristBatch.maximumPoursPerChunk`, `WristMirror.maximumAckedIds`).
    private static let appliedLedgerRetentionDays = 90

    /// `nonisolated static`, not a private instance method, so `requestWristPublish(from:)` —
    /// which composes a `WristMirror`'s `acked` list — can read the same ledger from a context that
    /// holds no `DataManager` instance, exactly as `WaterSnapshot.snapshot(defaults:calendar:now:)`
    /// reads `currentWater` without one.
    ///
    /// Returns `nil` when the ledger could not be read — which is **not** the same as "no pours
    /// applied yet". A missing key legitimately means an empty ledger (a fresh install, or a
    /// device that has never folded a wrist pour); data *present but undecodable* means the read
    /// failed, and `ingest(_:)` must treat that failure exactly as `fetch(_:)`'s own `nil` is
    /// treated — decline the batch rather than fold it against a ledger it never actually
    /// confirmed was empty (rule `20-state`). An earlier version returned `[:]` on either cause,
    /// which is indistinguishable from "nothing has ever been applied" to a caller deciding
    /// whether to insert — exactly the failed-read-as-data-loss shape `fetch(_:)`'s own DocC warns
    /// against, one layer up.
    nonisolated static func readAppliedLedger(from defaults: UserDefaults) -> [Int: Set<UUID>]? {
        guard let data = defaults.data(forKey: Key.wristApplied) else { return [:] }
        guard let raw = try? JSONDecoder().decode([Int: [UUID]].self, from: data) else { return nil }
        return raw.mapValues(Set.init)
    }

    private func readAppliedLedger() -> [Int: Set<UUID>]? {
        Self.readAppliedLedger(from: defaults)
    }

    nonisolated private static func writeAppliedLedger(
        _ ledger: [Int: Set<UUID>], to defaults: UserDefaults, keepingDaysSince cutoff: Int
    ) {
        let trimmed = ledger.filter { $0.key >= cutoff }
        let raw = trimmed.mapValues(Array.init)
        guard let data = try? JSONEncoder().encode(raw) else { return }
        defaults.set(data, forKey: Key.wristApplied)
    }
    #endif

    /// Today's servings, newest first.
    ///
    /// "Today" is the half-open interval `[startOfToday, nextDayBoundary)` derived from
    /// ``calendar`` — the *same* calendar the `yyyyMMdd` ordinal uses, so the log view and the
    /// rollover can never disagree about which day a serving belongs to (rule `30-rollover`).
    func fetchLogsForToday() -> [WaterLog] {
        readTodaysLogs() ?? []
    }

    /// Today's servings, or `nil` if the store could not be read. ``fetchLogsForToday()`` flattens
    /// that to `[]` for callers that only want to display rows; ``recomputeToday()`` must not.
    ///
    /// Named for the read rather than for the rows because ``todaysLogs`` — the published,
    /// observable array — is the thing callers usually want, and two members cannot share a name.
    private func readTodaysLogs() -> [WaterLog]? {
        // One clock read, not two. The bounds were previously derived from two separate `now()`
        // calls, which is a window that can straddle midnight between its own ends.
        let instant = now()
        return readLogs(
            from: calendar.startOfDay(for: instant),
            to: Self.nextDayBoundary(after: instant, calendar: calendar)
        )
    }

    /// Rows in the half-open interval `[start, end)`, or `nil` when the store could not be read.
    ///
    /// The one predicate shape in this product, shared with ``readTodaysLogs()`` so there is never
    /// a second spelling of "a day". Half-open at the top for the reason rule `30-rollover` gives:
    /// a closed upper bound double-counts the instant of midnight into both days.
    ///
    /// Routed through ``fetch(_:)`` so the nil-on-failure contract comes for free — a caller that
    /// persists or publishes a derived figure must honour it rather than flattening with `?? []`.
    private func readLogs(from start: Date, to end: Date) -> [WaterLog]? {
        fetch(
            #Predicate<WaterLog> { $0.timestamp >= start && $0.timestamp < end }
        )
    }

    /// Every serving ever recorded, newest first. The rollover no longer destroys history, so
    /// this is the whole of it.
    func allLogs() -> [WaterLog] {
        fetch(nil) ?? []
    }

    /// Removes a serving and recomputes today's total.
    func deleteLog(_ log: WaterLog) {
        modelContext.delete(log)
        saveAndRecompute()
    }

    /// Corrects a serving's amount, its time, or both, in one save.
    ///
    /// Non-positive amounts are ignored rather than deleting the row: "set this to zero" and
    /// "remove this" are different intentions, and ``deleteLog(_:)`` is the one that means remove.
    /// A refused amount refuses the **whole** edit — a new time applied while its amount was turned
    /// away would be half an edit nobody confirmed.
    ///
    /// `timestamp` is `nil` to keep the serving's time. Any instant is accepted, as
    /// ``addLog(amount:at:)`` accepts one: the store's floor is against corruption, not a menu. What
    /// the History sheet *offers* is ``correctionRange()``.
    ///
    /// One call for both halves, so the sheet's *Save* stays one call into the model (rule
    /// `50-views`). Moving a serving across midnight moves its water between two days, and
    /// ``saveAndRecompute()`` follows it: today's total is re-derived — ringing the widget doorbell
    /// and publishing to the wrist only if it moved — and the bars and both days' rows republish.
    /// Like ``deleteLog(_:)``, this addresses the row by identity rather than computing from a total,
    /// so it does not ``refresh()`` first (rule `30-rollover`).
    func updateLog(_ log: WaterLog, newAmount: Int, timestamp: Date? = nil) {
        let newTimestamp = timestamp ?? log.timestamp
        guard newAmount > 0, newAmount != log.amount || newTimestamp != log.timestamp else { return }
        log.amount = newAmount
        log.timestamp = newTimestamp
        saveAndRecompute()
    }

    /// The instants the History sheet offers a serving's time from: the start of the first day
    /// ``history`` shows, up to now.
    ///
    /// On the model rather than on the screen — where `HistoryView.servingRange` lives as a
    /// `static let` — because it moves with the clock and is bounded by the window the model owns,
    /// the same reason ``historyWindow`` is declared here. It is an offer, not a floor: the store
    /// accepts any instant. A serving dated before the window would vanish from view the moment it
    /// was saved, and one dated after now would be counted before it happened.
    func correctionRange() -> ClosedRange<Date> {
        let instant = now()
        let opening = Self.historyWindowStart(endingOn: instant, calendar: calendar) ?? calendar.startOfDay(for: instant)
        return opening...instant
    }

    /// Where the History sheet's wheel opens when a serving is added to the day `ordinal`: that day
    /// at the current time of day — or now, for today (`nil`, as `HistoryView` spells it) and for a
    /// day outside the window.
    ///
    /// Stepped back a calendar day at a time with `date(byAdding: .day,…)`, which keeps the wall-clock
    /// time, never 86,400 seconds at a time (rule `30-rollover`). A time a daylight-saving change
    /// skipped resolves the calendar's way and still lands on the chosen day —
    /// `theSuggestionLandsOnTheChosenDayAcrossTheStartOfDaylightTime`.
    func suggestedTime(onDay ordinal: Int?) -> Date {
        let instant = now()
        guard let ordinal else { return instant }
        for offset in 0..<Self.historyWindow {
            guard let candidate = calendar.date(byAdding: .day, value: -offset, to: instant) else { continue }
            if dayOrdinal(for: candidate) == ordinal { return candidate }
        }
        return instant
    }

    // MARK: - The cache

    /// Rewrites today's cached total from the logs.
    ///
    /// The cache in `UserDefaults` is what the widget reads — a `TimelineProvider` is
    /// `nonisolated` and a `ModelContext` is not `Sendable`, so the widget can never query
    /// SwiftData itself (rule `43-concurrency`). Going through the ``currentWater`` setter rather
    /// than writing the key directly is deliberate: that is where the clamp, the equality guard
    /// and the widget doorbell live, and all three still have to fire exactly once per real
    /// change (rule `20-state`).
    private func recomputeToday() {
        // A store that could not be read leaves the total exactly as it was. Writing 0 here would
        // publish a wrong figure to the widget *and* persist it to the cache, turning a transient
        // read failure into permanent data loss — the opposite of failing soft.
        // The rows and the figure are published from the *same* fetch. Two fetches could straddle
        // a write from the other process and leave a list on screen that does not add up to the
        // total printed above it.
        guard let logs = republishTodaysLogs() else { return }

        currentWater = logs.reduce(0) { total, log in
            let (sum, overflowed) = total.addingReportingOverflow(log.amount)
            return overflowed ? Self.maximumDailyIntake : sum
        }

        // Every log mutation from either process funnels through here, and the total is settled by
        // this line — which is what the plan is a function of.
        rescheduleRemindersNow()
    }

    /// Republishes today's rows to observers of ``todaysLogs``, and hands them back.
    ///
    /// Split out from ``recomputeToday()`` because the two halves have different rights. Publishing
    /// rows is a *read* — safe from any path, including ``refresh()``, which runs on every
    /// foreground. Writing the summed total back down is not: it persists to the cache and rings
    /// the widget doorbell, so it belongs only to a path that genuinely knows the new truth.
    ///
    /// Making `refresh()` recompute the total was tried and **rejected**, and
    /// `refreshPicksUpAnExternalWrite` is the test that caught it. `AddWaterIntent` writes a row
    /// *and* the cache from the extension; a cross-process SwiftData read can succeed while
    /// returning rows that do not yet include it, and re-deriving from those would overwrite the
    /// other process's serving with a smaller figure and announce the loss to the widget. A stale
    /// list beside a correct total is a display inconsistency that the next mutation heals; the
    /// other way round destroys water. That is the same lesson as the failed-read guard below, one
    /// step further out — a fetch can be wrong without throwing.
    @discardableResult
    private func republishTodaysLogs() -> [WaterLog]? {
        guard let logs = readTodaysLogs() else { return nil }
        withMutation(keyPath: \.todaysLogs) { storedTodaysLogs = logs }
        return logs
    }

    /// Republishes the window's rows to ``historyLogs``, then recomputes ``history`` from the same
    /// rows and publishes it if it moved.
    ///
    /// **Guarded on `role.drawsHistory`, and the guard is about cost rather than correctness.** The
    /// other role guards in this file stop a non-owner writing group state; this one stops a process
    /// doing work it can never draw. `recomputeToday()` is deliberately *not* guarded, so
    /// `AddWaterIntent` reaches ``saveAndRecompute()`` on every widget tap — and without this
    /// early return that tap would run a seven-day fetch and a full Swift-side roll-up inside a
    /// process whose entire job is to draw one number. The widget has no history surface: a
    /// per-day series is derivable from none of the cache keys, and `WaterSnapshot` may only
    /// carry what the cache alone can answer (rule `40-widget`).
    ///
    /// **One fetch feeds both**, so a bar and the list under it are one reading of the store. The
    /// rows are published first and unguarded (see ``historyLogs``): a time-only edit inside a past
    /// day moves no total, so the series below compares equal and returns early while that day's
    /// rows have still reordered.
    ///
    /// Returns early on a failed read rather than publishing an empty window. An empty chart is
    /// indistinguishable from a user who never drank, which is the same mistake as writing a
    /// failed read back as a total of zero — one step further out (see ``fetch(_:)``).
    private func republishHistory() {
        guard Self.role.drawsHistory else { return }

        let instant = now()
        guard let start = Self.historyWindowStart(endingOn: instant, calendar: calendar),
              let logs = readLogs(from: start, to: Self.nextDayBoundary(after: instant, calendar: calendar))
        else { return }

        // `Dictionary(grouping:by:)` keeps each day's rows in the fetch's newest-first order.
        withMutation(keyPath: \.historyLogs) {
            storedHistoryLogs = Dictionary(grouping: logs) { dayOrdinal(for: $0.timestamp) }
        }

        let series = DaySummary.series(
            from: logs,
            days: Self.historyWindow,
            endingOn: instant,
            in: calendar
        )
        guard series != storedHistory else { return }
        withMutation(keyPath: \.history) { storedHistory = series }
    }

    /// - Returns: whether the save actually succeeded. `ingest(_:)` is the one caller that acts on
    ///   this — the applied ledger may only be written once the rows it names are confirmed on
    ///   disk, never before (rule `20-state`; see `ingest(_:)`'s own DocC for what writing it
    ///   first cost). Every other caller discards it via `@discardableResult`: a save failure
    ///   there already degrades safely on its own — the in-memory state is not rolled back, and
    ///   the next successful save catches the store back up — which is why this stayed a
    ///   `print`-only `catch` for every path except this one.
    @discardableResult
    private func saveAndRecompute() -> Bool {
        let saved: Bool
        do {
            try modelContext.save()
            saved = true
        } catch {
            #if DEBUG
            // Names the condition, never the user's water (rule `75-diagnostics`).
            print("[WaterBuddy] Could not save the water log; today's total may be stale.")
            #endif
            saved = false
        }
        recomputeToday()
        republishHistory()
        return saved
    }

    /// Returns `nil` when the store could not be read — which is **not** the same as "no water".
    ///
    /// An earlier version returned `[]` on failure, and ``recomputeToday()`` faithfully wrote that
    /// empty result through as a total of zero: a failed *read* silently destroyed the figure the
    /// widget shows, and persisted the destruction to the cache. Distinguishing "nothing today"
    /// from "I could not tell" is the whole reason this is optional.
    private func fetch(_ predicate: Predicate<WaterLog>?) -> [WaterLog]? {
        var descriptor = FetchDescriptor<WaterLog>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.includePendingChanges = true
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            #if DEBUG
            // Names the condition, never the user's water (rule `75-diagnostics`).
            print("[WaterBuddy] Could not read the water log; leaving today's total as it stands.")
            #endif
            return nil
        }
    }

    /// Carries a total written by the UserDefaults-only build into the log, once.
    ///
    /// An upgrading user has `currentWater` but no rows. Without this their day silently empties
    /// on first launch, which is the same failure the App Group migration exists to prevent
    /// (rule `25-shared-storage`) — and it is guarded the same three ways: it only runs when the
    /// cached total belongs to *today*, it never runs in an extension, and it never runs when a
    /// log already exists, so it cannot double the water on a second launch.
    private func seedFromCachedTotalIfNeeded() {
        guard Self.role.mayHaveLegacyStandardDefaults else { return }

        let cached = defaults.integer(forKey: Key.currentWater)
        guard cached > 0, fetchLogsForToday().isEmpty else { return }

        // Only a total stamped today can be seeded — an older one belongs to a day that has
        // already rolled, and inventing a serving for it would resurrect yesterday's water.
        guard let stamped = defaults.object(forKey: Key.lastActiveDay) as? Int,
              stamped == dayOrdinal(for: now()) else { return }

        modelContext.insert(WaterLog(amount: cached, timestamp: now()))
        saveAndRecompute()
    }

    // MARK: - The daily goal

    /// Records the user's own daily goal, in millilitres, and marks setup complete.
    ///
    /// Clamped to `1...maximumDailyIntake` exactly as ``dailyGoal`` is, so a slider bound to this
    /// cannot store a goal that would divide by zero or overflow the running total.
    ///
    /// ``isGoalSet`` is marked unconditionally, including when the chosen amount happens to equal
    /// ``defaultDailyGoal``: picking 2,000 on purpose is still a choice, and treating it as "no
    /// choice made" would send that user back through setup on every launch.
    ///
    /// **The stored key and the in-memory flag are not the same fact**, and the write below is
    /// guarded on the key for that reason. ``resolveIsGoalSet(in:goal:)`` *infers* `true` from a
    /// non-default stored goal when the key is absent — the upgrade path — so an instance can hold
    /// `storedIsGoalSet == true` with nothing on disk behind it. Guarding the write on the
    /// in-memory value instead would skip it there, and an edit down to exactly
    /// ``defaultDailyGoal`` would leave the inference re-deriving `false` on the very next read:
    /// `RootView` cross-fades the whole app back into setup, mid-session, for a user who only moved
    /// a slider.
    ///
    /// That was unreachable while this ran once per install from `GoalSetupView`, which is
    /// presented *only* while the flag is `false` — so the guard could never short-circuit.
    /// `SettingsView`'s `GoalCard` is the second caller that made it reachable, and
    /// `editingAnInferredGoalDownToTheDefaultPersistsTheFlag` is what failed before this shape.
    func saveDailyGoal(ml: Int) {
        // The setter does the clamping, the write-through, the observation and the widget reload,
        // and skips all four when the value has not actually changed.
        dailyGoal = ml

        // Persistence: whenever the key does not already say `true`, regardless of what this
        // instance believes.
        if defaults.object(forKey: Key.isGoalSet) as? Bool != true {
            defaults.set(true, forKey: Key.isGoalSet)
        }

        // Unconditional, unlike the `dailyGoal` setter's own guarded publish above: a user who
        // accepts `GoalSetupView`'s slider unchanged saves exactly `defaultDailyGoal`, which the
        // setter's equality guard treats as a no-op — no mirror is ever published for that user,
        // and `WristView` gates its whole UI on `mirror.isGoalSet`, so their watch would be stuck on
        // the empty state forever. `isGoalSet` genuinely changed here even when `dailyGoal` did not,
        // and that change alone is wire-relevant (`WristMirror.isGoalSet`), so this call cannot rely
        // on the setter's guard the way every other publish site in this file does.
        publishWrist(defaults)

        // Observation: separate, and still guarded, so a no-op save neither invalidates observers
        // nor redraws the root gate.
        guard !storedIsGoalSet else { return }
        withMutation(keyPath: \.isGoalSet) { storedIsGoalSet = true }
    }

    // MARK: - Daily rollover

    /// Zeroes today's total if the last recorded day is not today.
    ///
    /// Idempotent and cheap, so it is safe to call from any lifecycle hook.
    /// - Returns: `true` if a new day actually started.
    @discardableResult
    func resetIfNeeded() -> Bool {
        let today = dayOrdinal(for: now())

        // Fresh install: adopt today rather than reporting a rollover. Claiming the day is the
        // app's to do, for the same reason the goal is — an extension that stamped an empty group
        // would be creating exactly the state the migration checks for.
        guard let lastActiveDay = defaults.object(forKey: Key.lastActiveDay) as? Int else {
            if Self.role.ownsSharedStorage {
                defaults.set(today, forKey: Key.lastActiveDay)
            }
            return false
        }

        guard lastActiveDay != today else { return false }

        applyDailyReset(on: today)
        return true
    }

    /// Clears today's total unconditionally, for a user-facing "start over" action.
    ///
    /// Leaves ``dailyGoal`` untouched.
    func resetDailyProgress() {
        // Deletes only *today's* servings. Yesterday is history and a "start over" button has no
        // business reaching into it — which is the whole reason the rollover stopped destroying
        // rows when the log became the source of truth.
        for log in fetchLogsForToday() {
            modelContext.delete(log)
        }
        applyDailyReset(on: dayOrdinal(for: now()))
        saveAndRecompute()
    }

    /// Re-reads the shared suite, then rolls the day over if needed.
    ///
    /// Call this when the app returns to the foreground: another process — a widget
    /// intent, say — may have written since this instance last looked.
    ///
    /// The closing republish is what makes ``todaysLogs`` safe to display. ``loadFromStore()``
    /// picks the *total* back up out of the cache, which the other process did update — but the
    /// rows behind it live in the store, and this is the only place they are re-read. Without it a
    /// widget tap taken while the app was backgrounded moves the figure and leaves the servings
    /// that produced it untouched: a history list contradicting the number printed above it.
    ///
    /// It republishes the rows and deliberately does **not** recompute the total from them — see
    /// ``republishTodaysLogs()`` for why that direction destroys water. It also runs *after*
    /// ``resetIfNeeded()``, so a rollover has already emptied the day before the rows are read
    /// (rule `30-rollover`).
    func refresh() {
        loadFromStore()
        resetIfNeeded()
        republishTodaysLogs()
        republishHistory()

        // The backstop for the widget. `AddWaterIntent` reconciles reminders itself, but whether an
        // app extension is permitted at runtime to reach the notification service is the one thing
        // that could not be verified ahead of time — so the app re-reconciles every time it comes
        // forward. `reconcile` is idempotent, so when the extension did its job this costs nothing.
        rescheduleRemindersNow()

        // The backstop for the watch, the identical shape as the reminder reconcile just above:
        // every setter below already publishes on a real *change*, but a watch paired onto an
        // **existing** phone install, or one that was simply out of Bluetooth range for every
        // mutation that happened while it was away, has no mutation of its own to piggyback on —
        // there is no launch-time or activation-time publish anywhere else in this file, so without
        // this such a watch would never receive a first mirror at all and would sit on `WristView`'s
        // empty state forever. `refresh()` runs on every foreground and every `.onAppear` of a
        // model-drawing tab (rule `50-views`), which is exactly the cadence "the app just became
        // reachable, tell the watch what's true" wants — and `updateApplicationContext` is a
        // last-write-wins property update, not a queued send, so a call that changes nothing costs
        // nothing on the wire and is safe to repeat as often as this method already runs.
        publishWrist(defaults)
    }

    // MARK: - Reminders

    /// Today's plan, as the model currently understands the day.
    ///
    /// Exposed so `AddWaterIntent` can hand it straight to ``NotificationManager`` and *await* the
    /// result — the extension cannot use the injected closure for that, because a detached `Task`
    /// does not outlive `perform()` returning.
    ///
    /// **The latest drink is the latest this process has read**, taken off ``todaysLogs`` — which
    /// ``recomputeToday()`` republishes from the same fetch just before it reschedules, and
    /// ``refresh()`` before its own. A mutation therefore plans twice — once from the `refresh()` it
    /// starts with, on the rows from before it, then from `recomputeToday()` — and the two plans
    /// differ whenever the drink silences a slot or the serving crosses the goal. The production
    /// hook files them one at a time, in that order (``requestReminderReschedule(_:)``), so the
    /// older plan can never land after the newer one. Not "fresh" in any stronger sense, and two
    /// gaps follow:
    /// - A cross-process read can succeed and still miss the other process's newest row (see
    ///   ``republishTodaysLogs()``), so `refresh()`'s backstop can put back a slot a widget tap
    ///   silenced, until a read sees the row. And a failed fetch after ``deleteLog(_:)`` skips the
    ///   reschedule, leaving the deleted drink's slot silent until the next good read.
    /// - A trigger resolves in whatever zone the device is in when it fires, and a zone change only
    ///   re-plans when it also turns the day — so flying east soon after a drink can bring a kept
    ///   slot inside the hour, until the app next re-plans.
    func currentReminderSlots() -> [ReminderPlan.Slot] {
        ReminderPlan.slots(
            enabled: storedRemindersEnabled,
            currentWater: storedCurrentWater,
            dailyGoal: storedDailyGoal,
            // `max()`, not `.first`, though the rows are fetched newest first: the plan should not
            // lean on a sort order chosen for a list.
            lastDrink: storedTodaysLogs.lazy.map(\.timestamp).max(),
            now: now(),
            calendar: calendar
        )
    }

    /// Recomputes the plan and hands it out.
    ///
    /// Always calls through, even when reminders are off — an empty plan is the instruction to
    /// *clear* the schedule, and skipping the call would strand notifications already filed with
    /// the system after the user switched them off.
    private func rescheduleRemindersNow() {
        rescheduleReminders(currentReminderSlots())
    }

    #if !os(watchOS)
    /// Every reminder reconcile this process files, one at a time, in the order they were asked for
    /// — see ``requestReminderReschedule(_:)``.
    ///
    /// One per process: the hook is `static`, and what has to be ordered is every call it receives.
    /// `nonisolated` so the `nonisolated` hook can reach it — safe, because a `ReconcileQueue` is
    /// `Sendable` (rule `43-concurrency`).
    nonisolated private static let reminderReconciles = ReconcileQueue()
    #endif

    /// The production default for ``init(defaults:modelContainer:calendar:now:reloadWidgets:rescheduleReminders:publishWrist:)``.
    ///
    /// Returns immediately in any process that may not file reminders — the widget extension, and
    /// both watch roles. A widget process is only guaranteed to live for the span of *awaited* work
    /// inside `perform()`, so a reconcile queued from here would be torn down before it finished —
    /// `AddWaterIntent` awaits ``NotificationManager/reconcile(_:calendar:strings:using:)`` directly
    /// instead, which is the only place that work can be held open.
    ///
    /// **Queued on ``reminderReconciles``, never a `Task` per call.** A mutation reschedules twice,
    /// and a reconcile makes the pending set equal *its* plan, so of two that overlap, the last to
    /// finish wins. Two `Task`s are unordered: the plan from before a drink could land after the plan
    /// from after it and file the slot the drink dropped — the one reminder the drink exists to skip.
    /// The queue runs them one at a time, in the order they were asked for (``ReconcileQueue``).
    ///
    /// `role.mayFileReminders` is already `false` on both watch roles, so the body below never runs
    /// there — but `NotificationManager.swift` is deliberately excluded from the watch target's
    /// membership exceptions (rule `80-notifications`, Task 9), so `NotificationManager`,
    /// `ReminderScheduler` and `ReconcileQueue` are types this file's module does not have on
    /// watchOS. The runtime guard alone does not stop the compiler from needing those types to
    /// exist, so the references themselves — not just the call — are compiled out with
    /// `#if !os(watchOS)`, the same pattern ``role`` uses.
    nonisolated static func requestReminderReschedule(_ slots: [ReminderPlan.Slot]) {
        guard role.mayFileReminders else { return }

        #if !os(watchOS)
        let calendar = Calendar.waterBuddyDay
        reminderReconciles.enqueue {
            // Built inside the operation: `UNUserNotificationCenter` is not `Sendable` and the
            // scheduler that wraps it must not cross into the queue (rule `43-concurrency`).
            await NotificationManager.reconcile(
                slots,
                calendar: calendar,
                // Resolved from the suite rather than from `DataManager.shared`: this is
                // `nonisolated` and may not touch the main actor (rule `43-concurrency`).
                strings: resolveLanguage(in: sharedDefaults).bundle,
                using: ReminderScheduler.live()
            )
        }
        #endif
    }

    #if !os(watchOS)
    /// Returns once every reminder plan asked for before the call has reached the notification centre.
    ///
    /// **What `LogServingIntent` awaits before Siri's reply.** Siri launches the app in the background
    /// to run the intent, and the system may suspend it as soon as `perform()` returns — before the
    /// re-plan the intent's own mutation queued has run. Waiting on the queue rather than calling
    /// ``NotificationManager/reconcile(_:calendar:strings:using:)`` directly keeps every plan in call
    /// order: a reconcile run beside the queue is how known issue #46 raced (rule `80-notifications`).
    ///
    /// Compiled out on watchOS with ``reminderReconciles`` itself: `ReconcileQueue` is not in the watch
    /// targets.
    nonisolated static func remindersSettled() async {
        await reminderReconciles.settled()
    }
    #endif

    // MARK: - Store

    private func loadFromStore() {
        let water = defaults.integer(forKey: Key.currentWater).clamped(to: 0...Self.maximumDailyIntake)
        if water != storedCurrentWater {
            withMutation(keyPath: \.currentWater) { storedCurrentWater = water }
        }

        let goal = Self.resolveDailyGoal(in: defaults)
        if goal != storedDailyGoal {
            withMutation(keyPath: \.dailyGoal) { storedDailyGoal = goal }
        }

        let goalSet = Self.resolveIsGoalSet(in: defaults, goal: goal)
        if goalSet != storedIsGoalSet {
            withMutation(keyPath: \.isGoalSet) { storedIsGoalSet = goalSet }
        }

        // Compared before mutating, like every value above: `refresh()` runs on every foreground,
        // and an unconditional publish would redraw the quick-add row for nothing.
        let vessels = Self.resolveServings(in: defaults)
        if vessels != storedServings {
            withMutation(keyPath: \.servings) { storedServings = vessels }
        }

        let language = Self.resolveLanguage(in: defaults)
        if language != storedLanguage {
            withMutation(keyPath: \.language) { storedLanguage = language }
        }

        // Only the app writes this flag, and a widget extension can outlive the write. Without the
        // re-read, `AddWaterIntent` plans from the value its process launched with: an empty plan
        // that clears the reminders just switched on, or a full one that brings back the ones just
        // switched off. No reschedule here — `refresh()` always ends in one.
        let reminders = defaults.bool(forKey: Key.remindersEnabled)
        if reminders != storedRemindersEnabled {
            withMutation(keyPath: \.remindersEnabled) { storedRemindersEnabled = reminders }
        }
    }

    /// Writes the zeroed total *before* stamping the day. A crash between the two leaves a
    /// stale marker, which simply resets again — the opposite order would launder
    /// yesterday's water into today with no way back.
    private func applyDailyReset(on day: Int) {
        defaults.set(0, forKey: Key.currentWater)
        if storedCurrentWater != 0 {
            withMutation(keyPath: \.currentWater) { storedCurrentWater = 0 }
        }
        defaults.set(day, forKey: Key.lastActiveDay)
        reloadWidgets()
        publishWrist(defaults)

        // Midnight is the one schedule change nobody taps for, and this path deliberately bypasses
        // the `currentWater` setter (it writes the zero *before* stamping the day, rule
        // `30-rollover`), so a hook hung on the setter alone would never see it.
        rescheduleRemindersNow()
    }

    /// The chosen language, or ``AppLanguage/system`` when nothing was chosen — and also when
    /// something unrecognised was stored.
    ///
    /// `nonisolated` because the widget's read path needs it and a `TimelineProvider` has no
    /// isolation at all (rule `43-concurrency`).
    nonisolated static func resolveLanguage(in defaults: UserDefaults) -> AppLanguage {
        AppLanguage(code: defaults.string(forKey: Key.language))
    }

    /// A missing key reads as `0` through `integer(forKey:)`, and a `0` goal would make the
    /// first sip read as 100%. Anything below 1 is therefore treated as "never set".
    /// The three vessels as stored, or the defaults when the suite cannot supply a coherent triple.
    ///
    /// `nonisolated static` and **not** `private`, unlike ``resolveDailyGoal(in:)`` beside it: the
    /// widget's timeline provider carries no isolation and has to reach this, and a `private`
    /// resolver is also unreachable from a test even under `@testable import`.
    /// ``resolveLanguage(in:)`` is the precedent on both counts.
    ///
    /// **Any anomaly discards the whole triple.** That is deliberately unlike `resolveDailyGoal`,
    /// which rejects a value below its floor but *clamps* one above its ceiling — an asymmetry that
    /// is reasonable for one scalar and wrong for a set. Repairing a single element leaves a triple
    /// no writer could have produced, and a row of vessels the user never chose is worse than the
    /// honest defaults.
    ///
    /// Arity is checked explicitly because it is the one failure the cast does not catch: a short
    /// array casts to `[Int]` perfectly happily, and indexing `[1]` for the widget's vessel would
    /// then trap or silently draw the wrong one.
    nonisolated static func resolveServings(in defaults: UserDefaults) -> [Int] {
        guard let stored = defaults.array(forKey: Key.servings) as? [Int],
              stored.count == defaultServings.count,
              stored.allSatisfy({ (1...maximumDailyIntake).contains($0) })
        else { return defaultServings }
        return stored
    }

    /// The serving every one-tap door logs: the middle quick-add vessel, the Glass.
    ///
    /// **One definition, so the widget's button and the Siri shortcut cannot read different slots.**
    /// Each used to need "index 1" spelled where it read the triple; a `[1]` drifting in one place
    /// would make two front doors log different amounts, with nothing to show it but arithmetic.
    /// ``snapshot(defaults:calendar:now:)`` and `LogServingIntent` both call this.
    ///
    /// `nonisolated static` for the reason ``resolveServings(in:)`` is: the widget's timeline provider
    /// carries no isolation and reaches it through `snapshot`.
    nonisolated static func usualServing(in defaults: UserDefaults) -> Int {
        resolveServings(in: defaults)[usualSlot]
    }

    /// Which of the three vessels the one-tap doors log: the middle one, the Glass.
    ///
    /// **Named once, because two things read it.** ``usualServing(in:)`` takes its amount, and the
    /// Control Center control (`LogWaterControl`) draws its glyph — a tile with no figure, which could
    /// never show that the two had come from different slots.
    nonisolated static let usualSlot = 1

    nonisolated private static func resolveDailyGoal(in defaults: UserDefaults) -> Int {
        guard let stored = defaults.object(forKey: Key.dailyGoal) as? Int, stored >= 1 else {
            return defaultDailyGoal
        }
        return min(stored, maximumDailyIntake)
    }

    /// Whether the user has chosen their own goal.
    ///
    /// A missing flag means a build from before the flag existed, not necessarily a user who never
    /// chose. Rather than sending everyone who already has a goal back through setup, infer one:
    /// nothing but ``saveDailyGoal(ml:)`` ever stores a goal that differs from ``defaultDailyGoal``,
    /// so a stored goal that is not the default can only have come from the user.
    ///
    /// A stored goal that *is* the default stays genuinely ambiguous — "never asked" and "asked,
    /// chose 2,000" are indistinguishable — and the safe reading of an ambiguity is to ask once.
    nonisolated private static func resolveIsGoalSet(in defaults: UserDefaults, goal: Int) -> Bool {
        if let stored = defaults.object(forKey: Key.isGoalSet) as? Bool {
            return stored
        }
        return goal != defaultDailyGoal
    }

    /// The local calendar day as `yyyyMMdd`.
    ///
    /// The day is recorded rather than the instant it happened. An instant has to be
    /// re-interpreted under whatever time zone is current when it is *read*, and that is not
    /// stable across travel: a user who logs water at 14:00 in Paris and then lands in London
    /// an hour behind would have yesterday's stored midnight re-read as the day before,
    /// wiping a day of water on a date that never changed. Comparing day ordinals also still
    /// rolls over correctly flying the other way, where the local date genuinely does advance.
    ///
    /// Not `private`: `HistoryView` asks it which day a saved serving landed on, on this model's
    /// calendar, rather than holding a calendar of its own.
    func dayOrdinal(for date: Date) -> Int {
        Self.dayOrdinal(for: date, in: calendar)
    }

    /// `nonisolated` so ``snapshot(defaults:calendar:now:)`` can apply the same rollover rule
    /// from a widget's timeline provider, which is not on the main actor.
    nonisolated static func dayOrdinal(for date: Date, in calendar: Calendar) -> Int {
        let day = calendar.dateComponents([.year, .month, .day], from: date)
        return (day.year ?? 0) * 10_000 + (day.month ?? 0) * 100 + (day.day ?? 0)
    }

    // MARK: - Automatic rollover while the app is open

    /// Catches the app sitting open across midnight, and the user crossing a time zone.
    private func startObservingDayChanges() {
        let center = NotificationCenter.default
        let names: [Notification.Name] = [.NSCalendarDayChanged, .NSSystemTimeZoneDidChange]

        dayChangeObservers = names.map { name in
            center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                // `queue: .main` guarantees the main thread, which is the main actor.
                MainActor.assumeIsolated {
                    _ = self?.resetIfNeeded()
                }
            }
        }
    }

    // MARK: - Shared storage resolution

    /// `true` when this process is an app extension rather than the app itself.
    ///
    /// A bundle path ending in `.appex` is the only signal available before any extension point
    /// has loaded, and it cannot change while the process runs, so it is resolved once.
    nonisolated static let isAppExtension: Bool = Bundle.main.bundleURL.pathExtension == "appex"

    /// Which of the product's binaries this process is.
    ///
    /// ``isAppExtension`` is a **two-state answer to a four-state question**, and it answers it
    /// wrongly for a watch: a watchOS app is a `.app`, so `pathExtension == "appex"` is `false`
    /// and every `!isAppExtension` guard in this file *opens* on the wrist. That would materialise
    /// the goal into a container the phone will never see, stamp its own day, seed a phantom
    /// serving out of a cache it did not derive, burn the burn-once migration flag, and file a
    /// full `ReminderPlan` of **byte-identical** identifiers into a second notification centre
    /// that cannot dedupe against the phone's.
    ///
    /// Resolved **from** ``isAppExtension`` and the compile-time platform rather than from a
    /// second runtime probe — rule `25-shared-storage` forbids a competing detection scheme
    /// precisely because two probes can disagree and leave one guard open.
    ///
    /// The four questions below are currently answered identically by every role, and they are
    /// still four questions rather than one property: they mean different things, they may diverge
    /// (a watch could one day legitimately draw history), and each is an exhaustive `switch` with
    /// **no `default`**, so a fifth binary fails to compile until somebody answers all four for it.
    nonisolated static let role: Role = {
        #if os(watchOS)
        return isAppExtension ? .watchExtension : .watchApp
        #else
        return isAppExtension ? .phoneExtension : .phoneApp
        #endif
    }()

    /// The product's binaries. See ``role``.
    enum Role: Sendable, CaseIterable {
        /// The iPhone app — the only first-class owner of the App Group's bookkeeping.
        case phoneApp
        /// The WidgetKit extension on the phone.
        case phoneExtension
        /// The watch app. Holds its own suite; owns none of the phone's.
        case watchApp
        /// The watchOS widget extension.
        case watchExtension

        /// *Is this container my own first-class home?* Gates materialising the goal and the
        /// fresh-install day stamp — writes made **for** other processes, which only the owner
        /// may make.
        var ownsSharedStorage: Bool {
            switch self {
            case .phoneApp: true
            case .phoneExtension, .watchApp, .watchExtension: false
            }
        }

        /// *Has my `UserDefaults.standard` ever held WaterBuddy state?* Gates the cached-total
        /// seed and the one-shot migration. An extension's `.standard` is its own `.appex` domain;
        /// a watch's is a different device's.
        var mayHaveLegacyStandardDefaults: Bool {
            switch self {
            case .phoneApp: true
            case .phoneExtension, .watchApp, .watchExtension: false
            }
        }

        /// *Do I have a history surface to draw?* Gates the seven-day roll-up, which is cost
        /// rather than correctness — `recomputeToday()` is deliberately unguarded, so a widget tap
        /// reaches `saveAndRecompute()` on every pour.
        var drawsHistory: Bool {
            switch self {
            case .phoneApp: true
            case .phoneExtension, .watchApp, .watchExtension: false
            }
        }

        /// *May I file notifications for this user?* Gates the reminder reschedule.
        ///
        /// The one question no rule file names and no DocC marks as group bookkeeping, and the
        /// only one whose wrong answer is immediately user-visible: `ReminderPlan.Slot.identifier`
        /// is a pure function of day and hour, so a second notification centre filing the same
        /// plan cannot dedupe against the first.
        var mayFileReminders: Bool {
            switch self {
            case .phoneApp: true
            case .phoneExtension, .watchApp, .watchExtension: false
            }
        }
    }

    /// `UserDefaults(suiteName:)` returns a live object even when the App Group is missing —
    /// it only fails for the app's own bundle identifier or the global domain — and that
    /// object silently degrades to a process-local store. The container URL is the real
    /// entitlement probe, and entitlements cannot change while the process runs, so this
    /// is resolved once.
    nonisolated private static let appGroupContainerExists: Bool = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) != nil

    /// The App Group suite, or `UserDefaults.standard` when the capability is not enabled.
    // Safe: UserDefaults is thread-safe; it simply predates `Sendable`.
    nonisolated(unsafe) static let sharedDefaults: UserDefaults = {
        guard appGroupContainerExists, let suite = UserDefaults(suiteName: appGroupIdentifier) else {
            #if DEBUG
            print("""
                [WaterBuddy] App Group "\(appGroupIdentifier)" is not available — \
                falling back to UserDefaults.standard. Add the App Groups capability under \
                Signing & Capabilities to share state with extensions.
                """)
            #endif
            return .standard
        }

        migrateIfNeeded(from: .standard, into: suite)
        return suite
    }()

    /// The SwiftData store holding every ``WaterLog``, in the App Group container so the app and
    /// `AddWaterIntent` in the widget extension write to the same file.
    ///
    /// Resolved once, for the same reasons ``sharedDefaults`` is: entitlements cannot change while
    /// the process runs, and opening a `ModelContainer` twice in one process is waste at best.
    ///
    /// **Fails soft, and says so.** When the App Group container is unreachable the store falls
    /// back to the process-local default location, exactly as `sharedDefaults` falls back to
    /// `.standard` — the app keeps working and the widget goes blank, rather than the app
    /// crashing on launch (rule `25-shared-storage`). The final `try!` is reached only if an
    /// in-memory container cannot be created, which would mean SwiftData itself is unusable.
    @available(watchOS, unavailable, message: "The watch holds no WaterLog store. See rule 25-shared-storage.")
    nonisolated static let sharedModelContainer: ModelContainer = {
        let schema = Schema([WaterLog.self])

        if let container = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let url = container.appending(path: "WaterBuddy.store")
            if let store = try? ModelContainer(
                for: schema,
                configurations: ModelConfiguration(schema: schema, url: url)
            ) {
                return store
            }
            #if DEBUG
            print("[WaterBuddy] The water log in the App Group could not be opened.")
            #endif
        } else {
            #if DEBUG
            print("""
                [WaterBuddy] App Group "\(appGroupIdentifier)" is not available — the water log \
                is falling back to a process-local store and the widget will not see it. Add the \
                App Groups capability under Signing & Capabilities.
                """)
            #endif
        }

        if let local = try? ModelContainer(for: schema) { return local }
        return try! ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        )
    }()

    /// Carries state written before the App Groups capability existed into the shared suite,
    /// once. Without this, enabling the capability would look like data loss.
    ///
    /// `source` is `UserDefaults.standard` in production and is a parameter only so the one-shot
    /// can be tested — it runs inside a lazy global that resolves the real App Group, which is not
    /// something a test can stand in front of.
    nonisolated static func migrateIfNeeded(from source: UserDefaults, into suite: UserDefaults) {
        // Only the app can have anything to migrate. An extension's `UserDefaults.standard` is
        // its own bundle's domain, which has never held WaterBuddy's state — so a widget process
        // that resolved the suite first would copy nothing while still burning the one-shot flag,
        // stranding the user's pre-App-Group water in the app's own defaults forever.
        guard role.mayHaveLegacyStandardDefaults else { return }

        guard !suite.bool(forKey: Key.didMigrateFromStandard) else { return }
        defer { suite.set(true, forKey: Key.didMigrateFromStandard) }

        // Never clobber state already in the group — but decide that per key, not by probing one
        // key and abandoning the whole migration. A single key can be present on its own: a widget
        // tap that landed before the app was first opened after the update writes `currentWater`
        // and nothing else, and a whole-set probe on a *different* key would then either strand
        // every value or overwrite the tap.
        for key in [Key.currentWater, Key.dailyGoal, Key.lastActiveDay, Key.isGoalSet] {
            guard suite.object(forKey: key) == nil, let value = source.object(forKey: key) else { continue }
            suite.set(value, forKey: key)
        }
    }

    /// Resolves the shared store — and, first time round, runs the one-shot migration out of
    /// `UserDefaults.standard` — before anything else asks for it.
    ///
    /// Every step here happens anyway, lazily, on the first touch of ``sharedDefaults``. Calling it
    /// deliberately at launch fixes *when*, and that is the point: the migration can only run once
    /// and is the app's to run, so leaving it to whichever code path happens to read the store
    /// first means it lands somewhere nobody chose. It also means the App Groups diagnostic below
    /// fires at launch rather than at some arbitrary later moment.
    ///
    /// - Returns: `false` when the App Group is unreachable — this process is then reading and
    ///   writing its own private defaults, and nothing it stores will ever reach the widget.
    @discardableResult
    nonisolated static func prepareSharedStorage() -> Bool {
        _ = sharedDefaults
        return isSharedStorageAvailable
    }

    /// Nudges WidgetKit after a mutation. A no-op when no widget is installed, and
    /// `nonisolated` so it can be used as a plain `() -> Void` default argument.
    ///
    /// **It reloads the control too.** iOS builds the Control Center control from a value it reads when
    /// it chooses — the Glass its button logs, the language of its title — and a reload is Apple's
    /// documented way to have it read again; this is the doorbell every change to either already rings.
    /// Without it, a press made after an edit logs the previous Glass — measured on the iOS 26.5
    /// simulator, where nothing else reloaded the control between the edit and the press.
    /// All controls rather than one kind, because a shared file may not name a type that lives only in
    /// the widget extension (`LogWaterControl`); iOS only, because the watch targets compile this file
    /// and have no control.
    nonisolated static func requestWidgetReload() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #if os(iOS)
        if #available(iOS 18.0, *) {
            ControlCenter.shared.reloadAllControls()
        }
        #endif
        #endif
    }

    #if canImport(WatchConnectivity)
    /// Composes the current state into a `WristMirror` — the pure half of publishing, kept separate
    /// from the `WCSession` call so it is testable without a paired watch (`WristPublishTests`).
    nonisolated static func composeWristMirror(from defaults: UserDefaults, calendar: Calendar, now: Date) -> WristMirror {
        // Flattened across **every** retained day, not just today's bucket: a watch pour authored
        // while offline, or from a day before the outbox last synced, still needs to be named in
        // `acked` before the watch will retire it — restricting this to today's day-ordinal would
        // strand any pour whose own day has already passed by the time it's folded.
        // A failed read degrades to an empty acked list rather than blocking the mirror
        // entirely — the watch just carries its outbox one round trip longer, which is safe;
        // `ingest(_:)` is the path that must decline outright, because it is the one deciding
        // whether to *apply* a pour rather than merely report what has been.
        let ledger = readAppliedLedger(from: defaults) ?? [:]
        // Newest day **first**: the ids the watch is still holding in its outbox must win the cap,
        // not the ones it retired long ago. An ascending sort here previously kept the OLDEST ids
        // once the ledger exceeded `maximumAckedIds` and silently dropped the newest — which
        // happens in steady state — permanently stranding every pour still genuinely in flight.
        let acked = Array(ledger.sorted { $0.key > $1.key }.flatMap(\.value).prefix(WristMirror.maximumAckedIds))

        // The total through the rollover, never the raw key. This also publishes from `WCSession`'s
        // own activation callback, which can land before this process has run `resetIfNeeded()` —
        // and read raw, a cache still holding yesterday's total would go out under today's
        // `phoneDayStart`, inside a window the watch now trusts (spec §17). `snapshot` applies the
        // same `lastActiveDay` rule the phone's own widget draws by.
        let today = snapshot(defaults: defaults, calendar: calendar, now: now)

        return WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion,
            currentWater: today.currentWater,
            dailyGoal: resolveDailyGoal(in: defaults),
            servings: resolveServings(in: defaults),
            languageCode: resolveLanguage(in: defaults).code,
            isGoalSet: resolveIsGoalSet(in: defaults, goal: resolveDailyGoal(in: defaults)),
            composedAt: now,
            phoneDayStart: calendar.startOfDay(for: now),
            phoneDayEnd: nextDayBoundary(after: now, calendar: calendar),
            acked: acked
        )
    }

    /// Sends the current state to the watch. A no-op when `WCSession` isn't supported (e.g. no
    /// paired watch) or hasn't activated yet — `updateApplicationContext` throws in both cases, and
    /// this is a best-effort push: `refresh()`'s own reconcile-on-foreground backstop (rule
    /// `80-notifications`'s equivalent for reminders) is not duplicated here for v1, so a push that
    /// fails silently degrades to "the watch shows a stale mirror until the next successful one" —
    /// stated, not hidden, per rule `75-diagnostics`.
    ///
    /// Takes `defaults` as a parameter rather than reading ``sharedDefaults`` itself — the same
    /// fix rule `85-testing` already required of `reloadWidgets`/`rescheduleReminders`. Every call
    /// site hands this the instance's own injected `defaults`, so a test or preview that forgets
    /// to override `publishWrist:` still cannot leak a read of the real App Group suite merely by
    /// composing a mirror — only the un-guardable `WCSession.default` call below still touches a
    /// real system object, which is why fixtures must still pass a no-op explicitly.
    ///
    /// **Then pushes the same mirror to the watch face when it is news**, through
    /// ``WristLink/pushToFace(_:encoded:after:in:)`` — the context stays the record, and the push only
    /// gets it there sooner (`docs/superpowers/specs/2026-10-07-complication-current-design.md` §4.4).
    /// What it is news *against* is `session.applicationContext`, read before it is overwritten: the
    /// mirror this phone last sent. Should the system ever hand that back empty, the next mirror simply
    /// counts as news, at the cost of one push.
    nonisolated static func requestWristPublish(from defaults: UserDefaults) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        let mirror = composeWristMirror(from: defaults, calendar: .waterBuddyDay, now: Date())
        guard let data = try? JSONEncoder().encode(mirror) else { return }
        let lastSent = WristLink.decodeMirror(from: session.applicationContext)
        do {
            try session.updateApplicationContext(["mirror": data])
        } catch {
            #if DEBUG
            print("[WaterBuddy] Could not publish the wrist mirror: \(error.localizedDescription)")
            #endif
            return
        }
        #if os(iOS)
        WristLink.pushToFace(mirror, encoded: data, after: lastSent, in: session)
        #endif
    }
    #endif
}

// MARK: - The chosen language

/// The language the product draws in.
///
/// Lives in this file rather than one of its own **because a seventh shared file would change a
/// contract**: `CLAUDE.md` and four rule files name the six `.swift` files compiled into both
/// targets, and `.claude/` is the owner's to edit. This is a stored preference and its resolution,
/// which sits naturally beside ``DataManager/Key`` and ``WaterSnapshot`` — the two other things in
/// here that both processes read.
///
/// `Sendable` and free of isolation, because ``DataManager/snapshot(defaults:calendar:now:)``
/// carries it into a `TimelineProvider`, which has none (rule `43-concurrency`).
enum AppLanguage: String, CaseIterable, Sendable, Identifiable {

    /// Follow the device. **Stored as the absence of the key**, never as a value — the same reading
    /// `isGoalSet` and `remindersEnabled` already use (rule `25-shared-storage`). Writing
    /// `"system"` would make "I never chose" indistinguishable from "I chose to follow", and only
    /// one of those should survive the user later adding a language to their phone.
    case system

    case english = "en"
    case russian = "ru"
    case uzbek = "uz"

    var id: String { rawValue }

    /// What goes in the suite. `nil` for ``system``, which is why the setter *removes* the key.
    ///
    /// `nonisolated` — like `resolveLanguage(in:)`, which returns the `AppLanguage` this is read
    /// from — because `composeWristMirror(from:calendar:now:)` reads it from a `nonisolated static`
    /// context with no `Task` to inherit isolation from. Without this, the `WaterBuddy` app
    /// target's own `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` infers this property `@MainActor`,
    /// and every other existing reader happens to dodge the resulting warning only by being
    /// main-actor already or by sitting inside an unannotated `Task { }` (which the same default
    /// isolation setting also infers as `@MainActor`) — `composeWristMirror` is the first caller
    /// with neither escape, so the warning was latent rather than hypothetical (rule
    /// `43-concurrency`).
    nonisolated var code: String? { self == .system ? nil : rawValue }

    /// The shipped localisations, in the order the picker offers them under *Follow device*.
    ///
    /// `theOfferedLanguagesAreExactlyTheOnesShipped` pins this against the `.lproj` folders that
    /// are actually in the bundle — an entry here with no strings behind it would silently draw
    /// English while claiming otherwise, and a user's own language is the one thing they can check.
    nonisolated static let selectable: [AppLanguage] = [.english, .russian, .uzbek]

    /// Reads a stored code, falling back to ``system`` for anything unrecognised.
    ///
    /// **Fail soft, and say so** (rule `75-diagnostics`): a corrupt suite, or a build that once
    /// shipped a language this one does not, must leave the app on the device language rather than
    /// blank. `"system"` is rejected too — it is a case name, never a stored value.
    init(code: String?) {
        guard let code,
              let match = AppLanguage(rawValue: code),
              match != .system
        else {
            #if DEBUG
            if let code, !code.isEmpty {
                print("WaterBuddy: unrecognised language code — following the device instead")
            }
            #endif
            self = .system
            return
        }
        self = match
    }

    /// The bundle every string is resolved through.
    ///
    /// ``system`` is `Bundle.main`, which is ordinary iOS behaviour. The rest are the `.lproj`
    /// inside it — **including English**, which is why the catalogues carry explicit `en` values:
    /// without them the development language lives in the binary with no `en.lproj`, and choosing
    /// *English* on a Russian phone would resolve through `Bundle.main` and draw Russian.
    var bundle: Bundle {
        guard let code,
              let url = Bundle.main.url(forResource: code, withExtension: "lproj"),
              let resolved = Bundle(url: url)
        else {
            #if DEBUG
            if code != nil {
                print("WaterBuddy: no strings bundle for the chosen language — following the device")
            }
            #endif
            return .main
        }
        return resolved
    }

    /// The locale to format numbers and dates against.
    ///
    /// Set alongside the bundle, or the strings would switch while `4 500` kept the device's
    /// grouping separator — half-translated is worse than untranslated, because it looks like a bug
    /// in the app rather than a language it does not have.
    var locale: Locale {
        guard let code else { return .autoupdatingCurrent }
        return Locale(identifier: code)
    }

    /// What the picker shows.
    ///
    /// Each language **names itself in its own script**, untranslated: a picker listing "Russian"
    /// in English is unreadable to precisely the person looking for it. Only *Follow device* is
    /// localised, which is why this takes a bundle rather than being a plain property.
    func name(in bundle: Bundle) -> String {
        switch self {
        case .system: bundle.localizedString(forKey: "Follow device", value: "Follow device", table: nil)
        case .english: "English"
        case .russian: "Русский"
        case .uzbek: "O‘zbekcha"
        }
    }
}

// MARK: - Resolving strings in the view tree

private struct StringsBundleKey: EnvironmentKey {
    /// `Bundle.main` is ordinary iOS behaviour, so a view that never had the value injected — a
    /// preview, a detached subtree — draws the device language rather than nothing.
    static let defaultValue: Bundle = .main
}

extension EnvironmentValues {

    /// The bundle every localised string in this subtree is resolved through.
    ///
    /// Injected once at each root from ``DataManager/language``, and read by every view that draws
    /// text. **This is why the language can change without a relaunch**: iOS resolves
    /// `Bundle.main`'s localisation once at launch and never again, so the only way to switch live
    /// is to stop asking `Bundle.main` and ask a bundle we choose.
    ///
    /// It is an environment value rather than a parameter because the tree is deep — `WaterVessel`
    /// and `ServingRow` are three levels below the model — and threading a `Bundle` through every
    /// initialiser would be the kind of magic-free that turns into noise.
    var strings: Bundle {
        get { self[StringsBundleKey.self] }
        set { self[StringsBundleKey.self] = newValue }
    }
}

// MARK: - Per-day history

/// One day's water, as a plain value.
///
/// **Declared at file scope inside `DataManager.swift`, and that is not arbitrary.**
/// ``DataManager`` publishes `[DaySummary]`, and `DataManager.swift` is one of the six files
/// compiled into the widget extension through `membershipExceptions`. A `DaySummary` living in its
/// own app-only file would therefore be a type the extension's copy of `DataManager` references
/// and cannot see — a break that appears *only* in the separate widget build, which the app
/// scheme's green test run never touches (rule `15-project`). ``WaterSnapshot`` and ``AppLanguage``
/// sit here for the same reason.
///
/// **There is deliberately no `goal` field.** ``DataManager/dailyGoal`` is a single scalar
/// overwritten in place, and ``WaterLog`` carries no goal, so nothing in either store can say what
/// the goal *was* on a past day — `resolveIsGoalSet(in:goal:)` is the only historical inference in
/// the product and it yields neither a value nor a date. A per-day `goal` here would be today's
/// figure stamped onto every bar while looking like a record, and the next reader would believe it.
/// The screen compares against the current goal and says so; see `HistoryView`.
struct DaySummary: Sendable, Equatable {

    /// The local day as `yyyyMMdd`, from ``DataManager/dayOrdinal(for:in:)`` — the one day
    /// representation this product has (rule `30-rollover`).
    ///
    /// This is the identity. Two summaries are the same day when their ordinals match, never when
    /// their ``date``s do.
    let dayOrdinal: Int

    /// Millilitres logged on that day, saturated at ``DataManager/maximumDailyIntake``.
    let total: Int

    /// The start of that local day, **for formatting the day's label and nothing else** — the week
    /// card's weekday letters, and History's heading and spoken names for a past day.
    ///
    /// It is safe here for one reason: a `DaySummary` is derived on every read and never stored.
    /// Rule `30-rollover`'s ban is on *persisting* a day as an instant — a stored `Date` has to be
    /// re-interpreted under whatever zone is current when it is read back, which is how a user
    /// flying west loses a day. Nothing here survives long enough for that, and ``dayOrdinal`` and
    /// this field are computed from the same walked date in ``series(from:days:endingOn:in:)``, so
    /// they cannot disagree.
    ///
    /// **Do not persist this, and do not compare on it.** A screen needs it because `Date` is what
    /// `.dateTime` formats, and that formatting has to resolve through the environment's
    /// locale so the label follows the in-app language picker rather than the device
    /// (rule `70-privacy`).
    let date: Date
}

extension DaySummary {

    /// The last `days` local days ending on the day containing `now`, oldest first.
    ///
    /// Always returns exactly `days` entries, zero-filling a day nobody drank on: a window that
    /// omitted empty days would draw a seven-bar axis describing some other number of days, and
    /// the average below would divide by the wrong denominator.
    ///
    /// Grouping happens in Swift, after the fetch, because it cannot happen in the store. A
    /// SwiftData `#Predicate` cannot call `Calendar` or group, so the only expressible form is a
    /// comparison against pre-computed bounds — which is what `readLogs(from:to:)` does — and
    /// ``WaterLog`` may never gain a day column to index instead (rule `30-rollover`).
    ///
    /// The day each serving lands in is derived from its `timestamp` under the calendar passed in,
    /// so buckets move if the device's zone moves. That is the deliberate cost of recording an
    /// instant rather than a day, and `theSameInstantsRegroupUnderAWestwardTimeZone` pins it.
    ///
    /// - Parameters:
    ///   - logs: rows to roll up. Anything outside the window is ignored, so a caller may hand over
    ///     a wider fetch without filtering first.
    ///   - days: how many days the window spans. Non-positive yields `[]` rather than trapping,
    ///     the way `ReminderPlan.slots` bounds its own loop.
    ///   - now: the instant whose local day ends the window.
    ///   - calendar: the injected day calendar — `Calendar.waterBuddyDay` in production, never
    ///     `Calendar.current`.
    nonisolated static func series(
        from logs: [WaterLog],
        days: Int,
        endingOn now: Date,
        in calendar: Calendar
    ) -> [DaySummary] {
        guard days > 0 else { return [] }

        let today = calendar.startOfDay(for: now)

        // Walked with `date(byAdding: .day,)`, never by subtracting 86,400 seconds — a DST day is
        // 23 or 25 hours long and a seconds-based walk silently drops or repeats one
        // (rule `30-rollover`).
        let window: [(ordinal: Int, date: Date)] = (0..<days).reversed().compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today).map {
                (DataManager.dayOrdinal(for: $0, in: calendar), $0)
            }
        }

        var totals: [Int: Int] = [:]
        for log in logs {
            let ordinal = DataManager.dayOrdinal(for: log.timestamp, in: calendar)
            // Saturate rather than overflow. A corrupt `Int.max` row traps a plain `+` and crashes
            // the app instead of degrading (rule `20-state`).
            let (sum, overflowed) = (totals[ordinal] ?? 0).addingReportingOverflow(log.amount)
            totals[ordinal] = overflowed ? DataManager.maximumDailyIntake : min(sum, DataManager.maximumDailyIntake)
        }

        return window.map {
            DaySummary(dayOrdinal: $0.ordinal, total: totals[$0.ordinal] ?? 0, date: $0.date)
        }
    }

    /// The mean daily volume across the whole window, in whole millilitres.
    ///
    /// Empty days are part of the denominator — they are days the user drank nothing, not days that
    /// did not happen. Integer division, because a volume is an `Int` everywhere in this product
    /// and a `Double` may only ever be a drawing fraction.
    nonisolated static func average(of series: [DaySummary]) -> Int {
        guard !series.isEmpty else { return 0 }
        let total = series.reduce(0) { running, day in
            let (sum, overflowed) = running.addingReportingOverflow(day.total)
            return overflowed ? Int.max : sum
        }
        return total / series.count
    }

    /// The largest single day in the window, or `0` for an empty one.
    nonisolated static func best(of series: [DaySummary]) -> Int {
        series.map(\.total).max() ?? 0
    }
}

// MARK: - Read-only snapshot

/// Today's hydration as a plain value, for a process that must read the store but must never
/// write to it.
///
/// A widget's timeline provider is such a process: it is not on the main actor, so it cannot
/// touch ``DataManager/shared`` at all, and merely *constructing* a `DataManager` would
/// materialise the goal, stamp the day, roll the total over and ring the widget doorbell — four
/// writes from a process whose job is to draw.
struct WaterSnapshot: Sendable, Equatable {

    /// Millilitres logged today, after the daily rollover has been applied in memory.
    var currentWater: Int

    /// Today's target in millilitres. Always at least 1.
    var dailyGoal: Int

    /// The language the widget should draw in.
    ///
    /// The widget has its own strings table and its own process, so without this it would render
    /// in the *device* language while the app rendered in the chosen one — two front doors
    /// disagreeing, which is the failure ``DataManager/defaultServing`` exists to prevent for the
    /// serving amount.
    var language: AppLanguage = .system

    /// The amount the widget's one button logs, and the figure it draws on its face.
    ///
    /// The middle quick-add vessel, which the user can change. Before it was editable the widget
    /// compiled the constant in and could not drift; now the two front doors agree by reading the
    /// same key instead, and this field is that read. It is derivable from the cache alone, which
    /// is the whole bar for living on a `WaterSnapshot` (rule `40-widget`).
    ///
    /// **Defaulted, and that is load-bearing.** Eleven other sites build a `WaterSnapshot` through
    /// the memberwise initialiser, seven of them inside the widget target that the app scheme never
    /// compiles. Without the default this field would break all seven at once, and only the
    /// separate extension build would say so.
    var serving: Int = DataManager.defaultServing

    /// Fraction of the goal reached today, clamped to `0...1`.
    var progress: Double {
        min(max(progressUnclamped, 0), 1)
    }

    /// Fraction of the goal reached today, *not* clamped — `1.5` means 150% of the goal.
    var progressUnclamped: Double {
        guard dailyGoal > 0 else { return 0 }
        return Double(currentWater) / Double(dailyGoal)
    }

    /// The whole-percent figure the app shows, rounded the same way ``HomeView`` rounds it.
    var percentage: Int {
        Int((progressUnclamped * 100).rounded())
    }

    /// The same snapshot with today's water zeroed and **every other field left exactly as it is**.
    ///
    /// This is the widget's midnight timeline entry — the future-dated one `getTimeline` emits so a
    /// widget nobody touches still turns over (rule `40-widget`).
    ///
    /// **It is a method, not a second initialiser call at that site, and that is the whole point.**
    /// The entry used to be built by enumeration —
    /// `WaterSnapshot(currentWater: 0, dailyGoal: current.dailyGoal)` — which silently reset every
    /// field the author did not name. ``language`` carries a default of `.system`, so a user who
    /// chose Russian in the app watched the widget revert to the *device* language at local
    /// midnight and stay there until something else reloaded the timeline: exactly the failure
    /// rule `70-privacy` forbids, invisible in the source and invisible to the whole gate, because
    /// the widget's rendering has no automated coverage and the app scheme never compiles it.
    ///
    /// Copying `self` and clearing one field is what makes a forgotten field impossible rather than
    /// merely unlikely. Any field added to this type from now on is carried across midnight for
    /// free, and `rollingOverChangesNothingExceptTheTotal` asserts the whole value rather than a
    /// list of them.
    func rolledOver() -> WaterSnapshot {
        var next = self
        next.currentWater = 0
        return next
    }
}

// MARK: - WatchConnectivity wire protocol

#if canImport(WatchConnectivity)

/// One pour, as the watch authored it. `id` becomes `WaterLog.id` verbatim on the phone — the merge
/// key already exists (`WaterLog.swift:33-37`, deliberately not `@Attribute(.unique)`), so this
/// struct invents no identity scheme of its own.
nonisolated struct WristPour: Codable, Sendable, Equatable, Identifiable {
    let id: UUID
    /// Millilitres, like every other volume in this product (Global Constraints).
    let amount: Int
    /// An **instant**. Deliberately no `dayOrdinal` — a day stamped on one device and re-read on
    /// another names a day neither device may still be in (rule `30-rollover`, one device further
    /// out: `WristPlan` derives "today" itself, on read, from this instant).
    let at: Date
}

/// A batch of pours, wrist → phone. Chunked at ``maximumPoursPerChunk`` because
/// `WCErrorCodePayloadTooLarge` has no numeric threshold anywhere in the SDK — the cap is by
/// construction, not by catching the error after the fact.
nonisolated struct WristBatch: Codable, Sendable, Equatable {
    /// An unrecognised version is **not** acked by the phone, so the watch keeps retrying rather
    /// than silently losing pours to a binary that doesn't understand them yet.
    let schemaVersion: Int
    /// Groups this batch's chunks back together and doubles as the coalescing key if the same
    /// batch is ever re-sent.
    let batchId: UUID
    let chunkIndex: Int
    let chunkCount: Int
    let pours: [WristPour]

    static let currentSchemaVersion = 1
    static let maximumPoursPerChunk = 64
}

/// What the phone last told the watch, phone → wrist. Delivered as a **property**
/// (`updateApplicationContext`/`receivedApplicationContext`) — the watch reads whatever the phone most
/// recently composed, with no callback needed on wake.
///
/// **And, when it is news, pushed to the face as well** (`WristLink.pushToFace(_:encoded:after:in:)`,
/// `docs/superpowers/specs/2026-10-07-complication-current-design.md` §4.4). That second lane is a
/// queue, not a property, so two mirrors can arrive in the wrong order: `WristModel.apply(_:)` keeps
/// the order by never taking a mirror composed before the one it holds.
nonisolated struct WristMirror: Codable, Sendable, Equatable {
    let schemaVersion: Int
    let currentWater: Int
    let dailyGoal: Int
    /// All three quick-add vessels, positional, so the wrist's row is the phone's row
    /// (`DataManager.servings`, `:238-253`) — never a single "the" serving.
    let servings: [Int]
    /// `nil` means "follow the device" — the same absence-carries-meaning rule
    /// `AppLanguage`/`Key.language` already follow (rule `70-privacy`). Never a sentinel string.
    let languageCode: String?
    let isGoalSet: Bool
    /// An instant: when the phone composed this mirror, for the watch's "Synced Nm ago" line.
    ///
    /// The one `var`, so ``isNews(since:)`` can re-stamp a whole copy rather than list the fields.
    var composedAt: Date
    /// The phone's `startOfDay`, **as an instant** — compared against the watch's own day, never
    /// stored as an ordinal the watch would have to re-interpret under its own time zone
    /// (rule `30-rollover`, spec §5).
    let phoneDayStart: Date
    /// When the phone's day ends, **as an instant** — ``DataManager/nextDayBoundary(after:calendar:)``
    /// on the phone's own calendar. `currentWater` is the phone's total for `[phoneDayStart,
    /// phoneDayEnd)` and for nothing after it, so the watch stops counting it here (spec §17).
    ///
    /// An instant, not a comparison of calendar days on the watch, because the two devices can
    /// disagree about the time zone: compared on the watch's own calendar, a mirror composed a minute
    /// ago can look like yesterday's, and zeroing it shows nothing on the wrist while the phone reads
    /// its real total — the failure spec §5 was written to rule out.
    ///
    /// Optional only so a mirror persisted before this field existed, or sent by a phone build that
    /// predates it, still decodes. A current phone always sends one.
    let phoneDayEnd: Date?
    /// Pour ids the phone has already folded, capped at ``maximumAckedIds``. Once the ledger holds
    /// more ids than the cap, ``DataManager/composeWristMirror(from:calendar:now:)`` keeps the
    /// **newest**-folded ids, not the oldest — the watch's own outbox only ever holds recently
    /// authored pours, so those are the ones the cap must never strand. This is what lets the watch
    /// retire a pour from its own outbox.
    let acked: [UUID]

    static let currentSchemaVersion = 1
    static let maximumAckedIds = 256

    /// Whether this mirror tells the watch anything `previous` did not: any field but ``composedAt``,
    /// which differs on every composition by construction. `true` when there is no `previous`.
    ///
    /// **The one test both ends use** (`docs/superpowers/specs/2026-10-07-complication-current-design.md`
    /// §4.6). The phone spends a complication push only on news, and the watch reloads its face only on
    /// news: `refresh()` republishes on every foreground, and a push or a background reload spent on
    /// "synced at" alone is one the day's budget no longer has.
    ///
    /// **Re-stamps a whole copy, then compares the whole value** — never a list of fields, which is
    /// correct only on the day it is written (`tasks/lessons.md`, 2026-08-30). A field added to the wire
    /// later is compared here without anyone touching this method.
    func isNews(since previous: WristMirror?) -> Bool {
        guard var restamped = previous else { return true }
        restamped.composedAt = composedAt
        return restamped != self
    }
}

#endif

#if canImport(WatchConnectivity)
import WatchConnectivity

/// The WatchConnectivity session, wrapped the way `NotificationManager.ReminderScheduler` wraps
/// `UNUserNotificationCenter` — but as a class, not a struct of closures: `WCSessionDelegate` is a
/// real delegate protocol a type conforms to, not a sealed-`init` singleton that forbids
/// subclassing the way `UNUserNotificationCenter` does.
///
/// **Never `@MainActor`, and marked `nonisolated` explicitly rather than left to infer.**
/// `WCSession`'s own header states delegate callbacks land on "a non-main serial queue" — a
/// `@MainActor` type conforming to a nonisolated delegate protocol produces `#ConformanceIsolation`,
/// a warning at this project's `SWIFT_VERSION = 5.0` and an error at Swift 6, and rule
/// `43-concurrency` treats a new warning as a gate failure today (spec §6).
///
/// **The explicit `nonisolated` documents intent even though this project's current build settings
/// cannot demonstrate its absence via a compiler diagnostic.** Every native target sets
/// `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, which is exactly the mechanism that silently
/// inferred `@MainActor` onto `Key.wristApplied`, `AppLanguage.code`, `vesselSlots` and
/// `WristModel.requestSend` before each needed the identical explicit keyword — every one of those
/// is a plain Swift declaration, and removing the keyword from any of them does reproduce a real
/// "main actor-isolated … can not be referenced from a nonisolated context" warning on this
/// toolchain. `WristLink` was probed the same way, three separate times — an unapplied reference to
/// `activate()`, a direct synchronous call to it, and a control experiment with a freshly-added,
/// unrelated `NSObject` subclass exposing one plain unmarked method, all read from a non-`@MainActor`
/// `@Test` context — and **none of the three reproduced a warning, with or without this keyword**.
/// The most likely explanation is `SWIFT_APPROACHABLE_CONCURRENCY = YES` (also set on every target),
/// which relaxes several categories of this exact class of diagnostic; it does not by itself prove
/// the underlying isolation was ever safe to omit; a class conforming to `NSObject` and an `@objc
/// optional` delegate protocol may simply route isolation checking differently than a plain
/// declaration does, in a way this probe could not distinguish either. Kept explicit regardless,
/// on the same reasoning as its four siblings above and because `WCSession`'s own header is
/// unambiguous that a callback lands off-main — this is the safe, self-documenting spelling of
/// "never `@MainActor`" whether or not the compiler currently enforces it, and it costs nothing to
/// state.
///
/// **This type itself never hops to the main actor.** Its delegate methods post a `Notification`
/// synchronously, straight from whatever queue `WCSession` calls them on — that is what "never
/// `@MainActor`" buys, and it needs no hop of its own to stay correct, because posting is
/// thread-safe and every observer is responsible for its own isolation. The hop happens one step
/// further out, on the *receiving* side: `WristInbox`/`WristModel` register their observers with
/// `queue: .main` and enter isolation with `MainActor.assumeIsolated` — the same idiom
/// `DataManager.startObservingDayChanges()` already established for `NotificationCenter`
/// observations, not the `Task { @MainActor in }` shape this file's own header comment once claimed
/// for this class (rule `43-concurrency` is corrected to match, `.claude/rules/43-concurrency.md`).
///
/// One type, one behaviour that **branches by platform** rather than one instance configured
/// differently per side — `Sendable` is earned by holding zero stored properties, so there is
/// nothing for the compiler to reject, and exactly one `static let live` retains it for the whole
/// process, on either side of the pairing.
nonisolated final class WristLink: NSObject, WCSessionDelegate, Sendable {

    /// The **strong** retainer. `WCSession.delegate` is `weak` (`WCSession.h:43`) and nothing else
    /// in this design holds one — without this, ARC frees the delegate the instant `activate()`
    /// returns, and every transfer afterward fails `SessionMissingDelegate` (7003) with no
    /// diagnostic in Debug or Release.
    static let live = WristLink()

    private override init() { super.init() }

    /// Activates the session and installs `self` as its delegate. `WCSession` tolerates redundant
    /// `activate()` calls, so this is safe to call more than once.
    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()

        #if os(watchOS)
        // Spec §4 chose `updateApplicationContext` precisely because its payload is **a property,
        // readable on the watch's own wake with no callback and no ordering dependency** — and yet
        // nothing in this app ever read that property, so the watch depended entirely on
        // `didReceiveApplicationContext` firing while it happened to be running. A context that
        // landed while the watch app was not running was therefore invisible until the phone
        // published again, which (before the activation publish added below) could be never.
        //
        // Reading it here closes that hole from the receiving side, and is safe to do unconditionally:
        // it is last-write-wins state, `WristModel.apply(_:)` is idempotent, and an empty dictionary
        // before the first sync simply decodes to nil. A push can now deliver a mirror ahead of its
        // context, so the context re-read here may be older than the mirror held — and `apply(_:)`
        // sets an older one aside rather than taking it (spec 2026-10-07 §4.5).
        applyPersistedContext(from: session)
        #endif
    }

    #if os(watchOS)
    /// Decodes whatever the system is already holding for us and posts it on the same channel a live
    /// delegate callback would. Separate from `activate()` only so the intent reads at the call site.
    private func applyPersistedContext(from session: WCSession) {
        guard let mirror = Self.decodeMirror(from: session.receivedApplicationContext),
              mirror.schemaVersion == WristMirror.currentSchemaVersion else { return }
        NotificationCenter.default.post(name: Self.didReceiveMirrorNotification, object: nil, userInfo: ["mirror": mirror])
    }

    // MARK: - Holding a background wake open (watch)

    /// Returns once the session has handed over everything it was woken to deliver — activated, with
    /// no content pending — or after about ten seconds, or the moment the system cancels the task.
    ///
    /// **What `.backgroundTask(.watchConnectivity)` awaits after `activate()`.** That task is complete
    /// when its closure returns, so a closure that returned straight after activating let the system
    /// suspend the app before anything had been delivered to it. Apple's instruction for the WatchKit
    /// form of the same task is to defer completion "until after you've activated your session and
    /// received all the pending data", using `hasContentPending`
    /// (`docs/superpowers/specs/2026-10-07-complication-current-design.md` §3, §4.2).
    ///
    /// **Polls rather than observes:** `activationState` is documented as key-value observable,
    /// `hasContentPending` is not. **Bounded,** so a flag that never clears cannot hold a wake open,
    /// and **cancellable,** because cancelling is how the system ends a task that has run out of time —
    /// and a closure still running past that risks the app being terminated.
    nonisolated static func waitForPendingDelivery() async {
        let delivered = await poll(
            until: {
                let session = WCSession.default
                return session.activationState == .activated && !session.hasContentPending
            },
            every: .milliseconds(100), atMost: 100
        )
        #if DEBUG
        if !delivered {
            print("[WaterBuddy] A background wake ended with WatchConnectivity content still pending.")
        }
        #endif
    }
    #endif

    #if os(iOS)
    /// Returns once `WCSession` has activated, after about a second, at once where `WCSession` is
    /// unsupported, or the moment the task is cancelled.
    ///
    /// **What `LogServingIntent` awaits before it logs.** Siri launches the app in the background just
    /// to run the intent, and `WaterBuddyApp.init()` starts activation on that same launch — so the
    /// intent's mutation could publish before the session is up, and
    /// ``DataManager/requestWristPublish(from:)`` drops a publish that throws `sessionNotActivated`.
    /// Bounded, because a watch that never answers must not hold Siri's reply; the publish on
    /// activation (`activationDidCompleteWith`) still fires later if the process is alive. The pure
    /// half is ``poll(until:every:atMost:)``.
    nonisolated static func waitUntilActivated() async {
        guard WCSession.isSupported() else { return }
        _ = await poll(until: { WCSession.default.activationState == .activated },
                       every: .milliseconds(100), atMost: 10)
    }
    #endif

    /// Checks `isDone` up to `attempts` times, `interval` apart, and says whether it ever held — `false`
    /// at once if the task is cancelled. The pure half of `waitForPendingDelivery()` on the watch and of
    /// `waitUntilActivated()` on the phone — which is why it is compiled for both — testable with no
    /// session (`WristLinkDeliveryTests`).
    nonisolated static func poll(until isDone: () -> Bool, every interval: Duration, atMost attempts: Int) async -> Bool {
        for attempt in 0..<max(attempts, 0) {
            if isDone() { return true }
            guard attempt < attempts - 1 else { break }
            do {
                try await Task.sleep(for: interval)
            } catch {
                return false
            }
        }
        return false
    }

    // MARK: - Sending (wrist → phone)

    /// Splits `pours` into one or more `WristBatch`es of at most `WristBatch.maximumPoursPerChunk`
    /// each, all sharing `batchId`. The pure half of sending — no `WCSession`, testable with no
    /// paired watch.
    nonisolated static func chunk(_ pours: [WristPour], batchId: UUID) -> [WristBatch] {
        guard !pours.isEmpty else { return [] }
        let groups = stride(from: 0, to: pours.count, by: WristBatch.maximumPoursPerChunk).map {
            Array(pours[$0..<min($0 + WristBatch.maximumPoursPerChunk, pours.count)])
        }
        return groups.enumerated().map { index, chunkPours in
            WristBatch(
                schemaVersion: WristBatch.currentSchemaVersion, batchId: batchId,
                chunkIndex: index, chunkCount: groups.count, pours: chunkPours
            )
        }
    }

    /// Sends pours to the phone. `WristModel.requestSend` (Task 11) is this function's only caller —
    /// wired for real in Task 12's own Step 5, replacing that task's no-op default.
    ///
    /// `transferUserInfo` is the carrier of record: durable across sender exit, survives the
    /// process being killed, needs no reachability (spec §4's wire table). `sendMessage` alongside
    /// it is "a deliberate heresy" — the only documented way to wake the phone app — and its
    /// failure is swallowed on purpose: the identical batch is already durably queued above, and
    /// folding is idempotent under `WaterLog.id`, so both landing produces exactly one serving.
    nonisolated static func send(_ pours: [WristPour]) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        for batch in chunk(pours, batchId: UUID()) {
            guard let data = try? JSONEncoder().encode(batch) else { continue }
            session.transferUserInfo(["batch": data])
        }
        if session.activationState == .activated, session.isReachable {
            session.sendMessage(["wake": true], replyHandler: nil, errorHandler: { _ in })
        }
    }

    #if os(iOS)
    // MARK: - Pushing to the face (phone → wrist)

    /// Sends the watch's complication the mirror just written to the application context, with the one
    /// priority the system reserves for a complication on the active face: transferred at once, waking
    /// the watch app in the background to take it (`WCSession.h`, `transferCurrentComplicationUserInfo:`).
    /// The context stays the record; this only gets the same mirror there sooner
    /// (`docs/superpowers/specs/2026-10-07-complication-current-design.md` §4.4).
    ///
    /// **Only news, and only while the face can use it.** A mirror that is not news against `lastSent`
    /// spends nothing — `refresh()` republishes on every foreground, against a budget of 50 pushes a
    /// day. Nor does a complication that is not on the active face. At zero remaining, the SDK would
    /// send an ordinary user-info transfer instead, which the context already covers, so that is
    /// skipped too, and said so in `DEBUG`.
    ///
    /// **A replacement cancels what it replaces.** A push superseded while still queued is untagged but
    /// kept, and delivered after the one that replaced it (`WCSession.h`) — only to wake the watch and
    /// be set aside by `WristModel.apply(_:)`. Only a push about to be sent cancels: a publish that is
    /// not news leaves a waiting push alone, since it may be the only fast copy of a real change.
    nonisolated static func pushToFace(_ mirror: WristMirror, encoded data: Data, after lastSent: WristMirror?, in session: WCSession) {
        guard mirror.isNews(since: lastSent), session.isComplicationEnabled else { return }
        guard session.remainingComplicationUserInfoTransfers > 0 else {
            #if DEBUG
            print("[WaterBuddy] No complication pushes left today; the watch catches up through the application context.")
            #endif
            return
        }
        for transfer in session.outstandingUserInfoTransfers where transfer.userInfo["mirror"] != nil {
            transfer.cancel()
        }
        session.transferCurrentComplicationUserInfo(["mirror": data])
    }
    #endif

    // MARK: - Decoding (the pure half — testable with no paired watch)

    nonisolated static func decodeBatch(from userInfo: [String: Any]) -> WristBatch? {
        guard let data = userInfo["batch"] as? Data else { return nil }
        return try? JSONDecoder().decode(WristBatch.self, from: data)
    }

    nonisolated static func decodeMirror(from context: [String: Any]) -> WristMirror? {
        guard let data = context["mirror"] as? Data else { return nil }
        return try? JSONDecoder().decode(WristMirror.self, from: data)
    }

    /// Posted with the decoded `WristBatch`, wrist → phone, in lieu of `WristLink` naming
    /// `WristInbox` directly.
    ///
    /// **Why the indirection:** `WristLink` lives in `DataManager.swift`, which is also compiled
    /// into `WaterBuddyWidgetExtension` (already in that target's exception set, for the wire
    /// structs and `WaterSnapshot` above) — but `WristInbox` is deliberately app-only
    /// (`WristInbox.swift`'s own header), absent from the widget's exception set. `#if !os(watchOS)`
    /// is true for *both* the phone app and the widget extension, so a direct
    /// `WristInbox.shared.receive(batch)` call at this call site fails with "cannot find 'WristInbox'
    /// in scope" the moment the widget extension is built — `os(watchOS)` alone cannot distinguish
    /// "the container app" from "an iOS app extension"; only target membership can, and Swift has no
    /// `#if` conditional for that. Posting through `NotificationCenter` — the same decoupling point
    /// `startObservingDayChanges()` already reaches for above — lets this file name only Foundation
    /// symbols, so it compiles identically in both targets. The widget extension posts this exactly
    /// as often as it calls `activate()`: never, so having no observer there is inert, not a bug.
    ///
    /// `WristInbox.shared` must exist (and so have registered its observer) before this can ever
    /// fire — the app's entry point wiring `WristLink.live.activate()` (Task 13) must also touch
    /// `WristInbox.shared` once, so construction — and observer registration — happens no later than
    /// activation.
    static let didReceiveBatchNotification = Notification.Name("sardor.WaterBuddy.wristLink.didReceiveBatch")

    /// Posted with the decoded `WristMirror`, phone → wrist, in lieu of `WristLink` naming
    /// `WristModel` directly — for both lanes: a delivered application context, and a mirror pushed to
    /// the complication (spec 2026-10-07 §4.5).
    ///
    /// **Why the indirection, the same shape as `didReceiveBatchNotification` above, mirrored:**
    /// `WristLink` lives in `DataManager.swift`, which — since Task 16 — is also compiled into
    /// `WaterBuddyWatchWidget` (in that target's own exception set, for `sharedDefaults`/`Key`/
    /// `WristMirror`, rule `40-widget` one platform over) — but `WristModel` sits in
    /// `WaterBuddyWatch/`, outside every exception set that reaches `WaterBuddyWatchWidget` (and
    /// deliberately so: the widget's `TimelineProvider` must never touch `WristModel.shared`, the
    /// same rule that keeps `HydrationProvider` off `DataManager.shared`). `#if os(watchOS)` is true
    /// for *both* the watch app and the watch widget extension, so a direct
    /// `WristModel.shared.apply(mirror)` call at this call site fails with "cannot find 'WristModel'
    /// in scope" the moment the widget extension is built. Posting through `NotificationCenter` lets
    /// this file name only Foundation/WatchConnectivity symbols, so it compiles identically in both
    /// targets. The widget extension never calls `WristLink.live.activate()`, so it never receives an
    /// application context and never posts this — having no observer there is inert, not a bug.
    ///
    /// `WristModel.shared` must exist (and so have registered its observer) before this can ever
    /// fire. `WaterBuddyWatchApp.init()` calls `WristLink.live.activate()` first, but `WCSession`
    /// activation itself is asynchronous — the earliest a real delegate callback can arrive is well
    /// after `WristView`'s own `@State private var model = WristModel.shared` has run, which SwiftUI
    /// evaluates while building the very same launch's window content. Unlike `WristInbox`, which
    /// needs an explicit extra touch at the phone's entry point (Task 13) because nothing else on
    /// that side constructs it, `WristModel.shared` has no such gap to close here.
    static let didReceiveMirrorNotification = Notification.Name("sardor.WaterBuddy.wristLink.didReceiveMirror")

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        #if DEBUG
        if let error {
            print("[WaterBuddy] WCSession activation failed: \(error.localizedDescription)")
        }
        #endif

        #if os(iOS)
        // Activation is asynchronous, and every publish site in `DataManager` is a foreground or
        // mutation event that can fire *before* it completes: `requestWristPublish` guards only
        // `WCSession.isSupported()`, so a pre-activation call throws `WCErrorCodeSessionNotActivated`
        // into a DEBUG-only catch and is gone, with nothing to retry it. On a cold launch that is a
        // real race — `DataManager.shared` is built before `WristLink.live.activate()` runs — and
        // losing it leaves the watch on its pre-sync screen until the user foregrounds the phone a
        // second time.
        //
        // Publishing from the completion callback is the one moment guaranteed to be after
        // activation, and it costs nothing when a publish already succeeded: the context is
        // last-write-wins, so a redundant identical write is a no-op on the wire.
        guard activationState == .activated else { return }
        DataManager.requestWristPublish(from: DataManager.sharedDefaults)
        #endif
    }

    #if os(iOS)
    /// The watch app was just installed, or a different watch was paired. Either way the counterpart
    /// has no mirror yet and nothing else in this design would send one: every other publish site is
    /// a phone-side foreground or mutation, and the user has no reason to touch their phone right
    /// after installing something on their watch. Without this, a freshly installed watch app waits
    /// for an unrelated phone interaction before it can show anything real.
    func sessionWatchStateDidChange(_ session: WCSession) {
        guard session.isPaired, session.isWatchAppInstalled else { return }
        DataManager.requestWristPublish(from: DataManager.sharedDefaults)
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    /// A different watch may be paired next — Apple's own documented recovery is to reactivate.
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif

    /// Both directions, one per platform. Wrist → phone, a batch of pours; phone → wrist, a mirror
    /// pushed to the complication (``pushToFace(_:encoded:after:in:)``). Each posts a notification
    /// rather than calling `WristInbox` or `WristModel` directly — see the two constants' DocC for why.
    /// A pushed mirror is the only user info a watch receives: batches travel wrist → phone alone.
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        #if os(watchOS)
        // The context's own notification, so `WristModel` keeps one door — and its "never older" rule
        // is what sets aside a push that lands after the one that replaced it (spec 2026-10-07 §4.5).
        guard let mirror = Self.decodeMirror(from: userInfo), mirror.schemaVersion == WristMirror.currentSchemaVersion else { return }
        NotificationCenter.default.post(name: Self.didReceiveMirrorNotification, object: nil, userInfo: ["mirror": mirror])
        #else
        guard let batch = Self.decodeBatch(from: userInfo), batch.schemaVersion == WristBatch.currentSchemaVersion else { return }
        NotificationCenter.default.post(name: Self.didReceiveBatchNotification, object: nil, userInfo: ["batch": batch])
        #endif
    }

    /// Phone → wrist. Only meaningful on `watchOS` — the phone composes a mirror, it never applies
    /// one to itself.
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        #if os(watchOS)
        guard let mirror = Self.decodeMirror(from: applicationContext), mirror.schemaVersion == WristMirror.currentSchemaVersion else { return }
        NotificationCenter.default.post(name: Self.didReceiveMirrorNotification, object: nil, userInfo: ["mirror": mirror])
        #endif
    }
}
#endif

extension DataManager {

    /// Reads today's hydration out of the shared suite without mutating anything.
    ///
    /// Applies the same day-ordinal rollover rule as ``resetIfNeeded()`` — a total stamped
    /// yesterday reports as zero — but only in the returned value. The store is left exactly as
    /// it was found, so the app remains the only writer of the rollover and a widget rendered at
    /// 00:01 cannot race the app into clearing the day.
    ///
    /// - Parameters:
    ///   - defaults: The store to read. Defaults to the App Group suite.
    ///   - calendar: Decides when today ends. Defaults to the user's local Gregorian day.
    ///   - now: The clock. Injectable so the rollover is testable without waiting a day.
    nonisolated static func snapshot(
        defaults: UserDefaults = DataManager.sharedDefaults,
        calendar: Calendar = .waterBuddyDay,
        now: Date = Date()
    ) -> WaterSnapshot {
        var water = defaults.integer(forKey: Key.currentWater).clamped(to: 0...maximumDailyIntake)

        // `if let`, not `guard let ... else { water = 0 }`: a *missing* marker means a build that
        // never stamped a day, which `resetIfNeeded()` adopts without resetting. Reporting zero
        // there would blank the widget for everyone upgrading.
        if let lastActiveDay = defaults.object(forKey: Key.lastActiveDay) as? Int,
           lastActiveDay != dayOrdinal(for: now, in: calendar) {
            water = 0
        }

        return WaterSnapshot(
            currentWater: water,
            dailyGoal: resolveDailyGoal(in: defaults),
            language: resolveLanguage(in: defaults),
            // The middle vessel — the one the widget's single button logs and draws, and the one the
            // Siri shortcut logs.
            serving: usualServing(in: defaults)
        )
    }

    /// The next local midnight after `date` — when a widget's total should visibly fall back to
    /// zero.
    ///
    /// Uses the same calendar as the rollover itself, so the widget and the app never disagree
    /// about when the day turns.
    nonisolated static func nextDayBoundary(
        after date: Date = Date(),
        calendar: Calendar = .waterBuddyDay
    ) -> Date {
        calendar.nextDate(
            after: date,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? date.addingTimeInterval(24 * 60 * 60)
    }

    /// The start of the first day ``DataManager/history`` shows: midnight, ``historyWindow`` − 1
    /// calendar days before the day containing `now`.
    ///
    /// The one definition of where the week starts, as ``nextDayBoundary(after:calendar:)`` is of
    /// where a day ends. The bars' fetch and the History sheet's wheel both call it, so the oldest
    /// bar and the earliest instant the sheet offers cannot disagree. Stepped with
    /// `date(byAdding: .day,…)`: a DST day is 23 or 25 hours long, so six days of 86,400 seconds can
    /// land an hour off midnight (rule `30-rollover`).
    ///
    /// `nil` only if the calendar cannot step back a day.
    nonisolated static func historyWindowStart(endingOn now: Date, calendar: Calendar) -> Date? {
        calendar.date(byAdding: .day, value: -(historyWindow - 1), to: calendar.startOfDay(for: now))
    }
}

// MARK: - Supporting extensions

extension Calendar {

    /// The calendar WaterBuddy uses to decide when today ends.
    ///
    /// Pinned to Gregorian so a device set to a non-Gregorian calendar still gets a
    /// 24-hour day, and built fresh on each access so a `TimeZone.autoupdatingCurrent`
    /// change (the user flying somewhere) takes effect.
    static var waterBuddyDay: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }
}

private extension Comparable {

    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
