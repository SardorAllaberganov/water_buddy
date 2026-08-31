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
        private static let prefix = "sardor.WaterBuddy."

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
    @ObservationIgnored private var dayChangeObservers: [NSObjectProtocol] = []

    // MARK: - State

    @ObservationIgnored private var storedCurrentWater: Int
    @ObservationIgnored private var storedDailyGoal: Int
    @ObservationIgnored private var storedIsGoalSet: Bool
    @ObservationIgnored private var storedTodaysLogs: [WaterLog] = []
    @ObservationIgnored private var storedHistory: [DaySummary] = []
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

    /// Whether the user wants a nudge every two hours between 09:00 and 21:00.
    ///
    /// Settable, unlike ``isGoalSet`` — this one genuinely is a preference rather than a consequence
    /// — but it carries the same write-through and equality guard as ``currentWater`` and
    /// ``dailyGoal``, so a no-op write neither invalidates observers nor re-plans the day.
    ///
    /// Changing it re-plans immediately, in both directions. Switching reminders **off** has to
    /// clear the schedule, not merely stop adding to it: notifications already filed with the system
    /// would otherwise keep arriving for days after the toggle said no (rule `80-notifications`).
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
        rescheduleReminders: @escaping ([ReminderPlan.Slot]) -> Void = DataManager.requestReminderReschedule
    ) {
        self.defaults = defaults
        self.modelContext = ModelContext(modelContainer)
        self.calendar = calendar
        self.now = now
        self.reloadWidgets = reloadWidgets
        self.rescheduleReminders = rescheduleReminders

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
    /// `AddWaterIntent` is now the only one left: `HomeView`'s row offers three vessels and calls
    /// this method directly, because "add the standard serving" stopped being what its buttons do.
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

    /// Corrects a serving's amount.
    ///
    /// Non-positive amounts are ignored rather than deleting the row: "set this to zero" and
    /// "remove this" are different intentions, and ``deleteLog(_:)`` is the one that means remove.
    func updateLog(_ log: WaterLog, newAmount: Int) {
        guard newAmount > 0, newAmount != log.amount else { return }
        log.amount = newAmount
        saveAndRecompute()
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

    /// Recomputes ``history`` from the store and publishes it if it moved.
    ///
    /// **Guarded on `isAppExtension`, and the guard is about cost rather than correctness.** The
    /// four existing guards in this file stop an extension writing group state; this one stops it
    /// doing work it can never draw. `recomputeToday()` is deliberately *not* guarded, so
    /// `AddWaterIntent` reaches ``saveAndRecompute()`` on every widget tap — and without this
    /// early return that tap would run a seven-day fetch and a full Swift-side roll-up inside a
    /// process whose entire job is to draw one number. The widget has no history surface: a
    /// per-day series is derivable from none of the seven cache keys, and `WaterSnapshot` may only
    /// carry what the cache alone can answer (rule `40-widget`).
    ///
    /// Returns early on a failed read rather than publishing an empty window. An empty chart is
    /// indistinguishable from a user who never drank, which is the same mistake as writing a
    /// failed read back as a total of zero — one step further out (see ``fetch(_:)``).
    private func republishHistory() {
        guard Self.role.drawsHistory else { return }

        let instant = now()
        let today = calendar.startOfDay(for: instant)
        // Walked by calendar days, never by subtracting 86,400 seconds — a DST day is 23 or 25
        // hours long (rule `30-rollover`).
        guard let start = calendar.date(byAdding: .day, value: -(Self.historyWindow - 1), to: today),
              let logs = readLogs(from: start, to: Self.nextDayBoundary(after: instant, calendar: calendar))
        else { return }

        let series = DaySummary.series(
            from: logs,
            days: Self.historyWindow,
            endingOn: instant,
            in: calendar
        )
        guard series != storedHistory else { return }
        withMutation(keyPath: \.history) { storedHistory = series }
    }

    private func saveAndRecompute() {
        do {
            try modelContext.save()
        } catch {
            #if DEBUG
            // Names the condition, never the user's water (rule `75-diagnostics`).
            print("[WaterBuddy] Could not save the water log; today's total may be stale.")
            #endif
        }
        recomputeToday()
        republishHistory()
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
    }

    // MARK: - Reminders

    /// Today's plan, as the model currently understands the day.
    ///
    /// Exposed so `AddWaterIntent` can hand it straight to ``NotificationManager`` and *await* the
    /// result — the extension cannot use the injected closure for that, because a detached `Task`
    /// does not outlive `perform()` returning.
    func currentReminderSlots() -> [ReminderPlan.Slot] {
        ReminderPlan.slots(
            enabled: storedRemindersEnabled,
            currentWater: storedCurrentWater,
            dailyGoal: storedDailyGoal,
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

    /// The production default for ``init(defaults:modelContainer:calendar:now:reloadWidgets:rescheduleReminders:)``.
    ///
    /// Returns immediately in an extension. A widget process is only guaranteed to live for the span
    /// of *awaited* work inside `perform()`, so the detached `Task` below would be torn down before
    /// it finished — `AddWaterIntent` awaits ``NotificationManager/reconcile(_:calendar:strings:using:)``
    /// directly instead, which is the only place that work can be held open.
    nonisolated static func requestReminderReschedule(_ slots: [ReminderPlan.Slot]) {
        guard role.mayFileReminders else { return }

        let calendar = Calendar.waterBuddyDay
        Task {
            // Built inside the closure: `UNUserNotificationCenter` is not `Sendable` and the
            // scheduler that wraps it must not cross into the task (rule `43-concurrency`).
            await NotificationManager.reconcile(
                slots,
                calendar: calendar,
                // Resolved from the suite rather than from `DataManager.shared`: this is
                // `nonisolated` and may not touch the main actor (rule `43-concurrency`).
                strings: resolveLanguage(in: sharedDefaults).bundle,
                using: ReminderScheduler.live()
            )
        }
    }

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
    private func dayOrdinal(for date: Date) -> Int {
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
    nonisolated static func requestWidgetReload() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
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
    var code: String? { self == .system ? nil : rawValue }

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

    /// The start of that local day, **for formatting a weekday label and nothing else**.
    ///
    /// It is safe here for one reason: a `DaySummary` is derived on every read and never stored.
    /// Rule `30-rollover`'s ban is on *persisting* a day as an instant — a stored `Date` has to be
    /// re-interpreted under whatever zone is current when it is read back, which is how a user
    /// flying west loses a day. Nothing here survives long enough for that, and ``dayOrdinal`` and
    /// this field are computed from the same walked date in ``series(from:days:endingOn:in:)``, so
    /// they cannot disagree.
    ///
    /// **Do not persist this, and do not compare on it.** A screen needs it because `Date` is what
    /// `.dateTime.weekday()` formats, and that formatting has to resolve through the environment's
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
            // Index 1 is the middle vessel — the one the widget's single button logs and draws.
            serving: resolveServings(in: defaults)[1]
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
