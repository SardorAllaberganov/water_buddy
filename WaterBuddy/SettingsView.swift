//
//  SettingsView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftData
import SwiftUI
import UIKit
import UserNotifications

/// The app's settings: the daily goal, and the reminders switch.
///
/// It was built as a *Settings* screen with a section rather than a *Reminders* screen precisely so
/// the goal editor could drop in beside the reminders card without a second surface. ``GoalCard``
/// is that editor, and it closes the gap `docs/AI_CONTEXT.md` recorded as tech debt #1:
/// ``DataManager/saveDailyGoal(ml:)`` used to be called exactly once in an install's life, from
/// `GoalSetupView`, leaving a user who picked 1,500 and later wanted 2,500 with no route to it
/// short of deleting the app — which is not even enough, because the App Group container survives
/// an uninstall.
///
/// App-only. The widget has no preferences to offer, and `UserNotifications` reaches this screen
/// only for the authorization status — the scheduling itself belongs to ``NotificationManager``.
struct SettingsView: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.scenePhase) private var scenePhase

    /// What iOS currently thinks. Presentation state, re-read whenever the screen comes forward —
    /// permission can be revoked in Settings while this app is in the background, and the toggle
    /// must not go on claiming otherwise.
    @State private var authorization: UNAuthorizationStatus = .notDetermined

    /// Whether the system batches notifications into a scheduled summary. Not a failure — but it
    /// changes what "remind me at 11:00" actually means, so it is said out loud.
    @State private var deliveryIsBatched = false

    /// Bumped when reminders are switched on, so the haptic fires on the tap.
    @State private var enables = 0

    private let scheduler = ReminderScheduler.live()

    /// `true` when iOS will not deliver anything, whatever the stored flag says.
    private var isBlocked: Bool {
        authorization == .denied
    }

    var body: some View {
        ZStack {
            AuroraBackground()

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 22) {
                        header
                        // The goal leads: it is the number the whole product is measured against,
                        // and reminders are a preference about it.
                        GoalCard(currentGoal: manager.dailyGoal)
                        ServingsCard(current: manager.servings)
                        remindersCard
                        LanguageCard()
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 24)
                    // The language card is the tallest on this screen and sits last, so without
                    // this its footnote rests under the floating tab bar at the un-scrolled
                    // position. `safeAreaInset` reserves the bar's height for scrolling, not for
                    // the resting layout.
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .frame(minHeight: proxy.size.height, alignment: .top)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        // No `.preferredColorScheme` and no `.presentationDragIndicator` here any more: this is a
        // tab, not a sheet. There is nothing to drag down, and the dark-appearance preference is
        // declared once on `RootTabView`, which owns the hosting controller all three tabs share —
        // the same move `HistoryView` made when the log stopped being a sheet.
        .sensoryFeedback(Haptics.confirm, trigger: enables)
        .task { await readSystemState() }
        .onChange(of: scenePhase) { _, phase in
            // Returning from the Settings app is the whole reason this is here.
            if phase == .active {
                Task { await readSystemState() }
            }
        }
    }

    // MARK: - Header

    /// Just the title now. *Done* sat beside it while this was a sheet presented from the log's
    /// header; a tab is dismissed by tapping another tab, and a button that duplicates the bar is
    /// a second way to do one thing.
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Settings", bundle: strings)
                .font(.title2.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 8, y: 2)

            Spacer(minLength: 12)
        }
    }

    // MARK: - Reminders

    private var remindersCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            toggleRow

            Text(explanation)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)

            if isBlocked {
                openSettingsRow
            }
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        // `.frosted`, not `.sheer`: this pane carries sentence-length text, and the density scale
        // exists because tint and blur compete (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .raised)
    }

    private var toggleRow: some View {
        Toggle(isOn: remindersBinding) {
            Text("Smart reminders", bundle: strings)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .toggleStyle(SwitchToggleStyle(tint: Aurora.cyan))
        .frame(minHeight: 56)
        // The label and hint go on the `Toggle` **itself**. An
        // `.accessibilityElement(children: .ignore)` wrapper around a control adds a second element
        // above one VoiceOver surfaces anyway, and the row gets announced twice — the bug recorded
        // in `tasks/lessons.md` for `HistoryView`'s serving rows.
        .accessibilityLabel(Text("Smart reminders", bundle: strings))
        .accessibilityHint(Text("Reminds you to drink every two hours between 9 AM and 9 PM", bundle: strings))
    }

    /// Writing through the model, never to `UserDefaults` directly (rule `10-architecture`), and
    /// asking for permission at the moment the user has just expressed intent.
    private var remindersBinding: Binding<Bool> {
        Binding(
            get: { manager.remindersEnabled && !isBlocked },
            set: { wantsReminders in
                guard wantsReminders else {
                    manager.remindersEnabled = false
                    return
                }
                enables += 1
                Task { await enableReminders() }
            }
        )
    }

    private var explanation: String {
        if isBlocked {
            return strings.localizedString(forKey: "Notifications are turned off for WaterBuddy in iOS Settings, so reminders can't be delivered.", value: nil, table: nil)
        }
        if manager.remindersEnabled && deliveryIsBatched {
            // Not a failure, and not hidden: `.timeSensitive` would break through a summary, and it
            // needs an entitlement this app deliberately does not carry (rule `70-privacy`).
            return strings.localizedString(forKey: "A nudge every two hours from 9 AM to 9 PM, unless you've already reached your goal. Your notification summary is on, so reminders may arrive in a batch rather than on the hour.", value: nil, table: nil)
        }
        return strings.localizedString(forKey: "A nudge every two hours from 9 AM to 9 PM. Logging water pushes the next one back, and reaching your goal silences the rest of the day.", value: nil, table: nil)
    }

    private var openSettingsRow: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } label: {
            Text("Open iOS Settings", bundle: strings)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .liquidGlass(in: Capsule(), density: .sheer, elevation: .resting, interactive: true)
        }
        .buttonStyle(PressStyle())
    }

    // MARK: - Permission

    /// Asks once, then records the answer.
    ///
    /// A refusal leaves ``DataManager/remindersEnabled`` **off** rather than storing an intent iOS
    /// will never honour: a switch that reads "on" while every notification is silently dropped is
    /// worse than no switch at all.
    private func enableReminders() async {
        let status = await scheduler.authorizationStatus()

        if status == .notDetermined {
            let granted = (try? await scheduler.requestAuthorization()) ?? false
            manager.remindersEnabled = granted
        } else {
            manager.remindersEnabled = status != .denied
        }

        await readSystemState()
    }

    private func readSystemState() async {
        authorization = await scheduler.authorizationStatus()

        // Permission revoked while we were away — stop the toggle from lying, and let the model's
        // own setter clear the schedule that is still filed with the system.
        if authorization == .denied, manager.remindersEnabled {
            manager.remindersEnabled = false
        }

        deliveryIsBatched = await UNUserNotificationCenter.current()
            .notificationSettings()
            .scheduledDeliverySetting == .enabled
    }
}

// MARK: - The language picker

/// Switches the language the whole product draws in, **without a relaunch**.
///
/// ## Why this is a picker and not a link to iOS Settings
///
/// iOS resolves `Bundle.main`'s localisation once at launch and never again, so the usual answer
/// is to hand the user to the system's per-app language screen and let the app be killed. This one
/// switches live instead, which is only possible because nothing in the product asks `Bundle.main`
/// for a string: every site resolves through ``EnvironmentValues/strings``, injected at each root
/// from ``DataManager/language``. Changing the model invalidates observers, the roots re-evaluate,
/// a different bundle travels down, and every label redraws.
///
/// ## What it cannot do
///
/// The widget's **gallery** strings — its name and description in the widget picker — are read by
/// the system, not by us, and stay in the device language. The widget's *face* does follow, but
/// only from its next refresh: a timeline already built is an archive another process is replaying,
/// so the setter rings the doorbell and WidgetKit decides when to redraw. The card says so rather
/// than implying it is instant.
private struct LanguageCard: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings

    /// Bumped on a real change, so the haptic fires on a switch rather than on a re-tap.
    @State private var switches = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Language", bundle: strings)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            VStack(spacing: 0) {
                ForEach(AppLanguage.allCases) { language in
                    row(language)

                    if language != AppLanguage.allCases.last {
                        Divider().overlay(Color.white.opacity(0.12))
                    }
                }
            }

            Text("The app switches straight away. The widget follows on its next refresh.", bundle: strings)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        // `.frosted` and `.raised`, matching both siblings on this screen.
        .liquidGlass(density: .frosted, elevation: .raised)
        .sensoryFeedback(Haptics.confirm, trigger: switches)
    }

    private func row(_ language: AppLanguage) -> some View {
        let isSelected = manager.language == language

        return Button {
            guard !isSelected else { return }
            manager.language = language
            switches += 1
        } label: {
            HStack(spacing: 12) {
                // The three languages name themselves in their own script; only *Follow device*
                // is translated, because it names a behaviour rather than a language.
                Text(language.name(in: strings))
                    .font(.body)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Spacer(minLength: 8)

                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .semibold))
                    // `.clear` rather than absent, so the row does not resize as the selection
                    // moves and SwiftUI animates a colour instead of inserting a layer — the same
                    // ruling `GlassTabBar` records for its glow.
                    .foregroundStyle(isSelected ? Aurora.cyan : .clear)
                    .shadow(color: isSelected ? Aurora.cyan.opacity(0.5) : .clear, radius: 8)
            }
            // Past the 44pt floor, and a `minHeight` so the target grows with Dynamic Type rather
            // than clipping the name (rule `65-accessibility`).
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        // Label and trait on the `Button` itself. A wrapping
        // `.accessibilityElement(children: .ignore)` around a control adds a stop instead of
        // replacing one, which is how `HistoryView`'s rows were once announced twice
        // (`tasks/lessons.md`).
        .accessibilityLabel(language.name(in: strings))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - The goal editor

/// The daily goal, editable after setup.
///
/// It offers ``GoalSetupView/goalRange`` — the same 1,000–4,000, in the same 100 ml steps, that
/// setup offers. Those numbers are a *menu* and not the store's limit, and the two screens that ask
/// have to offer the identical one: a range narrower here than at setup would strand a user at a
/// goal they had already chosen and could no longer reach.
///
/// It shares setup's readout *idiom* — monospaced digits, a ratio-sized unit, a numeric transition,
/// an `Aurora.cyan` slider — but arranges it as a settings row rather than as a hero, because on
/// `GoalSetupView` that card is the whole page and here it is one of two. It wears `remindersCard`'s
/// `.raised` elevation for the same reason (rule `60-design-system`).
///
/// **The current goal arrives through `init`, not through `.task`.** A `@State` seeded after the
/// first frame renders ``DataManager/defaultDailyGoal`` and then snaps, so a user whose goal is
/// 3,500 would watch it jump up from 2,000 every time Settings opened. `EditServingSheet` takes its
/// serving as an `init` parameter for the identical reason.
private struct GoalCard: View {

    @Environment(\.strings) private var strings

    @Environment(DataManager.self) private var manager

    /// The amount under the finger, in millilitres, held as an `Int` for the same reason every
    /// other volume in this product is one. The `Double` a `Slider` demands exists only inside
    /// ``sliderValue`` and is rounded away on the way back out.
    @State private var goal: Int

    /// Whether a drag is in flight. Load-bearing rather than cosmetic — it is what makes one
    /// gesture one write. See ``commitIfChanged()``.
    @State private var isDragging = false

    /// Bumped on a committed change, so the haptic fires on the change rather than on the touch.
    @State private var commits = 0

    @ScaledMetric(relativeTo: .title) private var readoutSize: CGFloat = 34

    init(currentGoal: Int) {
        _goal = State(initialValue: currentGoal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            readoutRow
            slider
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        // `.frosted` and `.raised`, matching `remindersCard`: the two panes on this screen are lit
        // by the same light, and a one-off density here would be a second one.
        .liquidGlass(density: .frosted, elevation: .raised)
        .sensoryFeedback(Haptics.confirm, trigger: commits)
    }

    private var readoutRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Daily goal", bundle: strings)
                .font(.body.weight(.semibold))

            Spacer(minLength: 12)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(goal, format: .number)
                    // Bounded so the largest accessibility sizes cannot push the figure through
                    // the edges of the card containing it (rule `65-accessibility`).
                    .font(.system(size: min(readoutSize, 48), weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(goal)))

                // Sized as a ratio of the figure it annotates, never with its own text style: a
                // fixed style and a scaled figure cross over at the accessibility sizes and the
                // unit ends up larger than the number.
                Text("ml", bundle: strings)
                    .font(.system(size: min(readoutSize, 48) * 0.4, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .animation(.smooth(duration: 0.35), value: goal)
        }
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
        // The slider below is labelled *and* valued, so it already announces both of these as one
        // sentence; left visible they are two more stops saying the same thing. Safe to hide as a
        // group — unlike the widget's hero, this row holds no control, the slider is its sibling
        // (rule `65-accessibility`).
        .accessibilityHidden(true)
    }

    private var slider: some View {
        VStack(spacing: 8) {
            Slider(
                value: sliderValue,
                in: Double(GoalSetupView.goalRange.lowerBound)...Double(GoalSetupView.goalRange.upperBound),
                step: Double(GoalSetupView.goalStep),
                onEditingChanged: { editing in
                    isDragging = editing
                    if !editing { commitIfChanged() }
                }
            )
            .tint(Aurora.cyan)
            // A `Slider`'s stock VoiceOver value is a percentage of its range, which here would
            // announce "50%" for 2,500 ml — a number that appears nowhere in the product.
            .accessibilityLabel(Text("Daily water goal", bundle: strings))
            .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), goal))

            HStack {
                Text(GoalSetupView.goalRange.lowerBound, format: .number)
                Spacer()
                Text(GoalSetupView.goalRange.upperBound, format: .number)
            }
            .font(.caption.weight(.medium))
            .monospacedDigit()
            .foregroundStyle(.white.opacity(0.6))
            // The slider already announces where it is and what it can reach; as VoiceOver stops
            // these are bare numbers with nothing to attach them to.
            .accessibilityHidden(true)
        }
        .onChange(of: goal) { _, _ in
            // **A VoiceOver adjustment is not a drag.** `onEditingChanged` is documented for the
            // drag gesture, and a goal that can only be committed by dragging is a goal a
            // VoiceOver user cannot change at all — so a change arriving with no drag in flight
            // commits here instead.
            //
            // The guard is the other half: during a drag `isDragging` is true, so the fifteen
            // steps between 2,000 and 3,500 stay **one** write, one widget reload and one
            // reminder re-plan rather than fifteen of each.
            guard !isDragging else { return }
            commitIfChanged()
        }
    }

    /// Writes the goal through the model — once, and only when it has actually moved.
    ///
    /// ``DataManager/dailyGoal``'s equality guard would absorb a redundant call anyway. The guard
    /// here is what keeps the *haptic* honest: it fires on a change, not on a touch that ended
    /// where it started.
    private func commitIfChanged() {
        guard goal != manager.dailyGoal else { return }
        // One call. The model clamps, writes through, invalidates observers, rings the widget
        // doorbell and re-plans the day's reminders — none of which is this view's business to
        // repeat (rule `20-state`).
        manager.saveDailyGoal(ml: goal)
        commits += 1
    }

    /// Bridges the `Int` this view holds to the `BinaryFloatingPoint` a `Slider` requires.
    ///
    /// The `step` already snaps the value; `rounded()` is what stops floating-point dust from
    /// turning 2,500 into 2,499.9999999, which truncation would then read as 2,499.
    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(goal) },
            set: { goal = Int($0.rounded()) }
        )
    }
}

// MARK: - The quick-add vessels

/// The three amounts the Home tab's quick-add row logs.
///
/// **The middle vessel is also what the widget's single button logs and draws**, which is the one
/// thing about this card a user could not otherwise discover — so it is stated on the card rather
/// than left to be found by arithmetic. That sentence is the replacement for what used to be a
/// compile-time guarantee: the amount was a constant both front doors spelled, and it is now a
/// stored value both front doors read.
///
/// Three sliders stacked is affordable here only because `SettingsView` wraps its content in the
/// `GeometryReader`/`ScrollView`/`minHeight` shape rule `65-accessibility` prescribes — at the
/// accessibility sizes the card grows and the screen scrolls, rather than the stack compressing and
/// its text truncating, which is exactly how the week card shipped a bug earlier in this session.
///
/// Ascent is deliberately **not** enforced. Making an edit to Cup push Glass out of its way would
/// silently change what the widget logs; see ``DataManager/servings``.
private struct ServingsCard: View {

    @Environment(\.strings) private var strings
    @Environment(DataManager.self) private var manager

    /// The three amounts under the finger. Seeded through `init` rather than in `.task` or
    /// `.onAppear`, for the reason ``GoalCard`` is (rule `50-views`).
    @State private var amounts: [Int]

    /// Whether a drag is in flight — what makes one gesture one write. See ``commitIfChanged()``.
    @State private var isDragging = false

    /// Bumped on a committed change, so the haptic fires on the change rather than on the touch.
    @State private var commits = 0

    init(current: [Int]) {
        _amounts = State(initialValue: current)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Quick-add vessels", bundle: strings)
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(Array(HomeView.vesselSlots.enumerated()), id: \.element.nameKey) { index, slot in
                vessel(at: index, slot: slot)
            }

            Text("The middle vessel is the one your widget logs.", bundle: strings)
                .font(.caption)
                // 0.70 measured against this pane, not chosen: white at 0.55 lands at 4.06:1 on
                // the frosted glass over the aurora, under the 4.5:1 small-text floor. See
                // `docs/DESIGN.md`.
                .foregroundStyle(.white.opacity(0.70))
                // The card sits in a `ScrollView`, but a `Text` still gives up lines before it
                // pushes back when the stack is tight.
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .sensoryFeedback(Haptics.confirm, trigger: commits)
    }

    private func vessel(at index: Int, slot: (nameKey: String, symbol: String)) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: slot.symbol)
                    .font(.body)
                    .foregroundStyle(Aurora.cyan)
                    // The name beside it says which vessel this is; the glyph repeating it would
                    // be a second stop saying the same thing.
                    .accessibilityHidden(true)

                Text(verbatim: strings.localizedString(forKey: slot.nameKey, value: slot.nameKey, table: nil))
                    .font(.subheadline.weight(.medium))

                Spacer(minLength: 8)

                Text(String(format: strings.localizedString(forKey: "%1$d ml", value: nil, table: nil), amounts[index]))
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.75))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(.white)
            // The slider below speaks the name and the value as one sentence, so this row would be
            // a duplicate stop (rule `65-accessibility`).
            .accessibilityHidden(true)

            Slider(
                value: binding(for: index),
                in: Double(HistoryView.servingRange.lowerBound)...Double(HistoryView.servingRange.upperBound),
                step: Double(HistoryView.servingStep),
                onEditingChanged: { editing in
                    isDragging = editing
                    if !editing { commitIfChanged() }
                }
            )
            .tint(Aurora.cyan)
            // A `Slider`'s stock VoiceOver value is a percentage of its range, which would announce
            // "22%" for a 250 ml glass — a number that appears nowhere in the product.
            // Resolved through the chosen bundle rather than written as `Text(slot.nameKey,
            // bundle:)`: that initialiser takes a `LocalizedStringKey`, which must be a literal,
            // and a runtime key silently becomes the *fallback text* instead of a lookup.
            .accessibilityLabel(strings.localizedString(forKey: slot.nameKey, value: slot.nameKey, table: nil))
            .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), amounts[index]))
        }
        .onChange(of: amounts[index]) { _, _ in
            // A VoiceOver adjustment is not a drag, so a change arriving with no drag in flight
            // commits here — otherwise a vessel could only be edited by dragging, which a VoiceOver
            // user cannot do. The guard keeps a whole drag to one write (rule `50-views`).
            guard !isDragging else { return }
            commitIfChanged()
        }
    }

    /// One call into the model, only when something actually moved.
    ///
    /// The setter clamps each vessel, guards on equality, writes through and rings the widget
    /// doorbell — none of which is this view's to repeat (rule `20-state`). The guard here keeps the
    /// *haptic* honest: it fires on a change, not on a touch that ended where it started.
    private func commitIfChanged() {
        guard amounts != manager.servings else { return }
        manager.servings = amounts
        commits += 1
    }

    /// Bridges the `Int` this view holds to the `BinaryFloatingPoint` a `Slider` requires.
    ///
    /// `rounded()`, never truncation: the `step` already snaps the value, and rounding is what stops
    /// floating-point dust from turning 250 into 249.9999 which truncation would read as 249.
    private func binding(for index: Int) -> Binding<Double> {
        Binding(
            get: { Double(amounts[index]) },
            set: { amounts[index] = Int($0.rounded()) }
        )
    }
}

// MARK: - Preview

#Preview {
    // A throwaway suite *and* an in-memory store, so the canvas never touches the real App Group.
    // Omitting `modelContainer:` resolves the live `WaterBuddy.store` (rule `50-views`).
    let defaults = UserDefaults(suiteName: "preview.waterbuddy.settings")!
    defaults.removePersistentDomain(forName: "preview.waterbuddy.settings")

    let manager = DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        reloadWidgets: {},
        // Never ring the real notification centre from a canvas.
        rescheduleReminders: { _ in }
    )

    // A goal that is *not* the default, so the canvas shows `GoalCard` seeding from the model
    // rather than from `defaultDailyGoal` — the bug an `.task`-seeded `@State` would hide.
    manager.saveDailyGoal(ml: 2_500)

    return SettingsView().environment(manager)
}
