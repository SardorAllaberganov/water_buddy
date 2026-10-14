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

/// The app's settings: the daily goal, the three quick-add vessels, the reminders switch and the
/// language.
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

    /// Whether this screen has arrived — set a few frames after it is built (``Arrival``).
    @State private var arrived = false

    private let scheduler = ReminderScheduler.live()

    /// `true` when iOS will not deliver anything, whatever the stored flag says.
    private var isBlocked: Bool {
        authorization == .denied
    }

    var body: some View {
        // No backdrop of its own: the three tabs share the one `RootTabView` stands, which holds
        // still while the pages slide over it.
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: SettingsStyle.cardGap) {
                    // Were Settings the page the app opens on, the cards would settle in under
                    // the header; a page that slides in is whole as it comes (``Arrival``).
                    // Each section recedes as it scrolls past the top or the foot of the screen
                    // (``ScrollDepth``), the header with the rest.
                    header
                        // The canvas stands the first card 20 pt under the title and the cards 16
                        // apart; the stack's own spacing is the 16.
                        .padding(.bottom, SettingsStyle.headerGap - SettingsStyle.cardGap)
                        .scrollDepth()
                    // The goal leads: it is the number the whole product is measured against,
                    // and reminders are a preference about it.
                    GoalCard(currentGoal: manager.dailyGoal).arrives(arrived, order: 0).scrollDepth()
                    ServingsCard(current: manager.servings).arrives(arrived, order: 1).scrollDepth()
                    remindersCard.arrives(arrived, order: 2).scrollDepth()
                    LanguageCard().arrives(arrived, order: 3).scrollDepth()
                    Spacer(minLength: 0)
                }
                // The reminders card changes what it says, and with it its height: when
                // permission is refused, when the notification summary is on, and when the
                // language changes. On the whole stack, so the card below moves with it; on
                // that card alone it grew over a third of a second while its neighbour jumped.
                .animation(Motion.settle, value: explanation)
                // Every tab's margin and inset (``ScreenMetrics``).
                .padding(.horizontal, ScreenMetrics.margin)
                // Every tab's inset, less the point the reader stands off the safe area (below):
                // the title stands where Home's and History's do (`testTheTitleHoldsItsPlaceOnEveryTab`).
                .padding(.top, ScreenMetrics.topInset - 1)
                // The language card is the tallest on this screen and sits last, so without this
                // its footnote rests under the floating tab bar at the un-scrolled position. The
                // bar's height is reserved for scrolling, not for the resting layout, by
                // `RootTabView`'s `safeAreaInset`.
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .top)
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollDepthContainer()
        }
        // One point clear of the status bar, and it is not spacing — History's remedy, for
        // History's reason. A scroll view whose top edge meets the safe area's draws its content
        // on up under the status bar, and a card scrolled to the top ran under the clock (known
        // issue #108). On the reader rather than inside it, so the height it hands the column
        // is the height that is left, and the screen does not gain a point of scroll.
        .padding(.top, 1)
        // A tab that draws model data re-reads it when it is shown (rule `50-views`): the goal,
        // the vessels, the language and the reminders flag can each have been written since this
        // screen was last built. The goal and vessel cards copy their values once, as they are
        // built, and take a re-read value from there (`GoalCard`, `ServingsCard`).
        .onAppear { manager.refresh() }
        // No `.preferredColorScheme` and no `.presentationDragIndicator` here any more: this is a
        // tab, not a sheet. There is nothing to drag down, and the dark-appearance preference is
        // declared once on `RootTabView`, which owns the hosting controller all three tabs share —
        // the same move `HistoryView` made when the log stopped being a sheet.
        .sensoryFeedback(Haptics.confirm, trigger: enables)
        .tracksArrival($arrived)
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
    ///
    /// Every tab's header (``ScreenHeader``), so the title stands where *Today* does on the other
    /// two (`testTheTitleHoldsItsPlaceOnEveryTab`).
    private var header: some View {
        ScreenHeader {
            Text("Settings", bundle: strings)
                .accessibilityAddTraits(.isHeader)
        } detail: {
            EmptyView()
        } accessory: {
            EmptyView()
        }
    }

    // MARK: - Reminders

    private var remindersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            toggleRow

            Text(explanation)
                .cardNote()

            if isBlocked {
                openSettingsRow
                    .transition(.opacity)
            }
        }
        // `.frosted`, not `.sheer`: this pane carries sentence-length text, and the density scale
        // exists because tint and blur compete (rule `60-design-system`).
        .settingsCard()
    }

    private var toggleRow: some View {
        Toggle(isOn: remindersBinding) {
            Text("Smart reminders", bundle: strings)
                .cardTitle()
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .toggleStyle(SwitchToggleStyle(tint: Aurora.cyan))
        // The floor and no more: the canvas sets the title and the switch on one line, with its
        // sentence close under them, and a taller row only stood the sentence further off.
        .frame(minHeight: 44)
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
            return strings.localizedString(forKey: "A nudge every two hours from 9 AM to 9 PM, unless you drank in the hour before it or have already reached your goal. Your notification summary is on, so reminders may arrive in a batch rather than on the hour.", value: nil, table: nil)
        }
        return strings.localizedString(forKey: "A nudge every two hours from 9 AM to 9 PM, skipped if you drank in the hour before it. Reaching your goal silences the rest of the day.", value: nil, table: nil)
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
        VStack(alignment: .leading, spacing: 0) {
            Text("Language", bundle: strings)
                .cardTitle()
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .padding(.bottom, 6)

            VStack(spacing: 0) {
                ForEach(AppLanguage.allCases) { language in
                    row(language)

                    if language != AppLanguage.allCases.last {
                        Hairline()
                    }
                }
            }

            Text("The app switches straight away. The widget follows on its next refresh.", bundle: strings)
                .cardNote()
                .padding(.top, 10)
        }
        // `.frosted` and `.raised`, matching every sibling on this screen.
        .settingsCard()
        // A choice among four peers, so the selection tick rather than `confirm`'s impact —
        // the tick a tab or a day gives (``Haptics/select``).
        .sensoryFeedback(Haptics.select, trigger: switches)
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
                    // About the canvas's mark — 14 pt across, drawn in a 20-pt box — at the row's
                    // own size, so it grows with the name.
                    .font(.body.weight(.bold))
                    // `.clear` rather than absent, so the row does not resize as the selection
                    // moves and SwiftUI animates a colour instead of inserting a layer — the same
                    // ruling `GlassTabBar` records for its glow.
                    .foregroundStyle(isSelected ? Aurora.cyan : .clear)
                    .shadow(color: isSelected ? Aurora.cyan.opacity(0.5) : .clear, radius: 8)
                    // Once, on the row that was picked — and on the one that was left, where the
                    // mark is clear and nothing shows.
                    .symbolEffect(.bounce, value: isSelected)
            }
            // Past the 44pt floor — the canvas's 50 — and a `minHeight` so the target grows with
            // Dynamic Type rather than clipping the name (rule `65-accessibility`).
            .frame(minHeight: 50)
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
/// `GoalSetupView` that card is the whole page and here it is one of four. It wears `remindersCard`'s
/// `.raised` elevation for the same reason (rule `60-design-system`).
///
/// **The current goal arrives through `init`, not through `.task`.** A `@State` seeded after the
/// first frame renders ``DataManager/defaultDailyGoal`` and then snaps, so a user whose goal is
/// 3,500 would watch it jump up from 2,000 every time Settings opened. History's serving sheet
/// takes its serving as an `init` parameter for the identical reason.
///
/// **And a goal re-read after that arrives through `onChange`.** `SettingsView` re-reads the model
/// as it appears, after this card has copied it, and a `@State` ignores every later `init` value —
/// so a goal written meanwhile would otherwise stand on the screen beside the model's. Never under
/// a finger: a drag in flight is the user's, and it commits its own value when it ends. The copy
/// writes nothing and plays nothing: ``commitIfChanged()`` finds the model already holding it, and
/// the step tick is bumped only by the slider.
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

    /// Bumped each time a drag moves the goal by a step: the tick under the finger. A counter the
    /// slider bumps, not the goal itself, so a goal the card takes from a re-read never ticks
    /// (rule `60-design-system`, *Haptics*).
    @State private var steps = 0

    /// The canvas's 36-pt figure, scaled as a title is.
    @ScaledMetric(relativeTo: .title) private var readoutSize: CGFloat = 36

    /// The canvas sets *ml* at 17 pt beside its 36-pt figure.
    private static let unitRatio: CGFloat = 17 / 36

    init(currentGoal: Int) {
        _goal = State(initialValue: currentGoal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            readoutRow
            slider
        }
        // `.frosted` and `.raised`, matching `remindersCard`: the panes on this screen are lit
        // by the same light, and a one-off density here would be a second one.
        .settingsCard()
        .sensoryFeedback(Haptics.confirm, trigger: commits)
        .sensoryFeedback(Haptics.select, trigger: steps)
        .onChange(of: manager.dailyGoal) { _, stored in
            guard !isDragging else { return }
            goal = stored
        }
    }

    private var readoutRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Daily goal", bundle: strings)
                .cardTitle()
                // Drawn when a change has been saved. The slider has no Save button, so until
                // now only the haptic said the goal had been kept.
                .savedTick(commits)

            Spacer(minLength: 12)

            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(goal, format: .number)
                    // Bounded so the largest accessibility sizes cannot push the figure through
                    // the edges of the card containing it (rule `65-accessibility`).
                    .font(.system(size: min(readoutSize, 48), weight: .bold, design: .rounded))
                    .tracking(-0.8)
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(goal)))

                // Sized as a ratio of the figure it annotates, never with its own text style: a
                // fixed style and a scaled figure cross over at the accessibility sizes and the
                // unit ends up larger than the number.
                Text("ml", bundle: strings)
                    .font(.system(size: min(readoutSize, 48) * Self.unitRatio, weight: .semibold, design: .rounded))
                    // The canvas's 0.9: 7.76 / 10.38 / 7.82:1 on iOS 27.0 / 26.5 / 18.6
                    // (`docs/DESIGN.md`, *Settings, measured*).
                    .foregroundStyle(.white.opacity(0.9))
            }
            .animation(.smooth(duration: 0.35), value: goal)
            // The figure under the finger: a little larger while the slider is held, and it
            // lands back when it is let go. From its trailing edge, which is where it is pinned.
            .scaleEffect(isDragging ? 1.06 : 1, anchor: .trailing)
            .animation(Motion.land, value: isDragging)
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
            .font(.footnote.weight(.semibold))
            .monospacedDigit()
            // The canvas's 0.88, measured at 5.35 / 7.06 / 5.50:1 on iOS 27.0 / 26.5 / 18.6, the
            // worst frame of a minute (`docs/DESIGN.md`, *Settings, measured*). They were 0.6
            // until that read under 4.5:1 on Apple's glass, then 0.75.
            .foregroundStyle(.white.opacity(0.88))
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
    ///
    /// Only the slider writes through here, so this is where a step is counted — under a finger
    /// only: a VoiceOver adjustment commits at once and takes `confirm`'s haptic for itself.
    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(goal) },
            set: { value in
                let stepped = Int(value.rounded())
                guard stepped != goal else { return }
                goal = stepped
                if isDragging { steps += 1 }
            }
        )
    }
}

// MARK: - The quick-add vessels

/// The three amounts the Home tab's quick-add row logs.
///
/// **The Glass is also what the widget's button, Siri's phrase and the Control Center control
/// log**, which is the one thing about this card a user could not otherwise discover — so it is
/// stated on the card rather than left to be found by arithmetic, and by the vessel's name, which
/// is what the row above it says. That sentence is the replacement for what used to be a
/// compile-time guarantee: the amount was a constant both front doors spelled, and it is now a
/// stored value every one-tap door reads (``DataManager/usualServing(in:)``).
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
    @Environment(\.locale) private var locale
    @Environment(DataManager.self) private var manager

    /// The three amounts under the finger. Seeded through `init` rather than in `.task` or
    /// `.onAppear`, and re-seeded from a re-read, for the reasons ``GoalCard`` is (rule `50-views`).
    @State private var amounts: [Int]

    /// Whether a drag is in flight — what makes one gesture one write. See ``commitIfChanged()``.
    @State private var isDragging = false

    /// Which vessel's slider is held, by slot. Its figure is drawn a little larger meanwhile.
    @State private var held: Int?

    /// Bumped on a committed change, so the haptic fires on the change rather than on the touch.
    @State private var commits = 0

    /// Bumped each time a drag moves a vessel by a step — ``GoalCard``'s tick, for the same reason
    /// a counter.
    @State private var steps = 0

    /// The canvas's 26-pt glyph box, scaled with the name beside it and capped at its use site.
    @ScaledMetric(relativeTo: .body) private var glyphBox: CGFloat = 26

    init(current: [Int]) {
        _amounts = State(initialValue: current)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quick-add vessels", bundle: strings)
                .cardTitle()
                // Drawn when a vessel's new amount has been saved (``SavedTick``).
                .savedTick(commits)

            ForEach(Array(vesselSlots.enumerated()), id: \.element.nameKey) { index, slot in
                vessel(at: index, slot: slot)
            }

            VStack(alignment: .leading, spacing: 16) {
                Hairline()
                Text("The Glass is the one your widget, Siri and Control Center log.", bundle: strings)
                    .cardNote()
            }
        }
        .settingsCard()
        .sensoryFeedback(Haptics.confirm, trigger: commits)
        .sensoryFeedback(Haptics.select, trigger: steps)
        .onChange(of: manager.servings) { _, stored in
            guard !isDragging else { return }
            amounts = stored
        }
    }

    private func vessel(at index: Int, slot: (nameKey: String, symbol: String)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Side by side while they fit. At the accessibility text sizes on a small phone the
            // amount was cut to "150…" beside its name; there it drops under the name instead
            // (rule `65-accessibility`, *Dynamic Type*).
            //
            // **The side-by-side row is measured at its widest**, every vessel's name and the
            // largest amount the slider reaches, drawn hidden underneath: a fit decided by the
            // amount under the finger flipped the row to two lines as a drag passed 1,000, and
            // left the three rows in different shapes.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    ZStack(alignment: .leading) {
                        ForEach(vesselSlots, id: \.nameKey) { label(for: $0).hidden() }
                        label(for: slot)
                    }
                    Spacer(minLength: 8)
                    ZStack(alignment: .trailing) {
                        amountText(HistoryView.servingRange.upperBound).hidden()
                        amount(at: index, anchor: .trailing)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    label(for: slot)
                    amount(at: index, anchor: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
                    held = editing ? index : nil
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

    /// A vessel's glyph and name.
    private func label(for slot: (nameKey: String, symbol: String)) -> some View {
        let box = min(glyphBox, 40)

        return HStack(spacing: 12) {
            Image(systemName: slot.symbol)
                .font(.system(size: box * 0.8))
                // Against its 3:1 floor the Cup's, beside the card's sheen, is the tightest:
                // 3.08 / 4.02 / 3.09:1 on iOS 27.0 / 26.5 / 18.6 (`docs/DESIGN.md`, *Settings,
                // measured*).
                .foregroundStyle(Aurora.cyan)
                // One box for all three, so the names beside them start on one line whatever
                // each glyph's own width.
                .frame(width: box, height: box)
                // The name beside it says which vessel this is; the glyph repeating it would be a
                // second stop saying the same thing.
                .accessibilityHidden(true)

            Text(verbatim: strings.localizedString(forKey: slot.nameKey, value: slot.nameKey, table: nil))
                .font(.body.weight(.medium))
        }
    }

    /// A vessel's amount, grouped as every visible volume is (rule `50-views`): a bottle of 1,000
    /// read "1000 ml" here while Home and History drew "1,000 ml".
    private func amountText(_ volume: Int) -> some View {
        Text(strings.figure("%1$@ ml", volume, locale: locale))
            .font(.body.weight(.bold))
            .fontDesign(.rounded)
            .monospacedDigit()
    }

    /// The amount under the finger, a little larger while its slider is held, as the goal's is —
    /// from the edge it is pinned to, so it grows into its row and not into the card's padding.
    private func amount(at index: Int, anchor: UnitPoint) -> some View {
        amountText(amounts[index])
            .scaleEffect(held == index ? 1.06 : 1, anchor: anchor)
            .animation(Motion.land, value: held)
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
    /// A step under a finger is counted here, as ``GoalCard``'s is.
    private func binding(for index: Int) -> Binding<Double> {
        Binding(
            get: { Double(amounts[index]) },
            set: { value in
                let stepped = Int(value.rounded())
                guard stepped != amounts[index] else { return }
                amounts[index] = stepped
                if isDragging { steps += 1 }
            }
        )
    }
}

// MARK: - The cards' type

/// What every card on this screen shares: the canvas's *Settings* board, read from its source
/// (`docs/superpowers/plans/2026-10-13-premium-redesign-stage-4.md`).
///
/// **One place, because the cards had drifted apart.** The four titles were drawn in two styles and
/// the three notes in three, each card spelling its own (spec 2026-10-09 §7). The notes share the
/// 15-pt style although the canvas draws the language footnote at 13: the spec says one, and the
/// owner chose it (2026-10-13, S1).
private enum SettingsStyle {

    /// Every card's title — 17-pt semibold at the ordinary size.
    static let title: Font = .body.weight(.semibold)

    /// The sentence under a card's controls: the vessels note, the reminders explanation, the
    /// language footnote.
    static let note: Font = .subheadline

    /// The canvas's 0.92. The tightest of the three notes, the reminders explanation — its first
    /// line starts at the card's sheen — measured 4.89 / 6.37 / 4.93:1 on iOS 27.0 / 26.5 / 18.6,
    /// the worst frame of a minute (`docs/DESIGN.md`, *Settings, measured*).
    static let noteOpacity = 0.92

    /// Inside every card, on every side.
    static let cardPadding: CGFloat = 20

    /// Between two cards.
    static let cardGap: CGFloat = 16

    /// From the title to the first card.
    static let headerGap: CGFloat = 20

    /// The rule between the language rows and above the vessels note.
    static let hairlineOpacity = 0.16
}

private extension Text {

    /// A card's title, in the one style all four share.
    func cardTitle() -> Text {
        font(SettingsStyle.title).foregroundStyle(.white)
    }

    /// A card's note, in the one style all three share. It wraps rather than truncates: the card
    /// sits in a `ScrollView`, but a `Text` still gives up lines before it pushes back when the
    /// stack is tight.
    func cardNote() -> some View {
        font(SettingsStyle.note)
            .foregroundStyle(.white.opacity(SettingsStyle.noteOpacity))
            .fixedSize(horizontal: false, vertical: true)
    }
}

private extension View {

    /// A card: the canvas's padding, the full width, and the screen's one glass —
    /// `.frosted` + `.raised` on every card, since siblings on one screen share a pair
    /// (rule `60-design-system`) and every card carries sentence-length text.
    func settingsCard() -> some View {
        padding(SettingsStyle.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(density: .frosted, elevation: .raised)
    }
}

/// A one-point rule across a card. Decoration: what it separates is already separate to VoiceOver.
private struct Hairline: View {

    var body: some View {
        Rectangle()
            .fill(.white.opacity(SettingsStyle.hairlineOpacity))
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

// MARK: - Saved

/// A tick that draws itself when a change has been saved, stays a moment, and fades.
///
/// The goal and the vessels are saved when their slider is let go. There is no Save button to
/// press, so until this only the haptic said a change had been kept — and a haptic says nothing
/// on a phone lying on a desk.
///
/// A stroke trimmed from nothing to whole, so it is seen being drawn; it lands
/// (``Motion/land``). Decoration: the slider beside it speaks its own value, so this is hidden
/// from accessibility (rule `65-accessibility`).
private struct SavedTick: View {

    /// How many times the card has saved. Zero is the card as it opens, and draws nothing.
    let commits: Int

    /// How long the tick stays before it fades.
    private static let stay: Duration = .milliseconds(1_600)

    @State private var shown = false

    /// A real magnitude, capped at its use site (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .body) private var scaledSize: CGFloat = 16

    private var size: CGFloat { min(scaledSize, 26) }

    var body: some View {
        CheckShape()
            .trim(from: 0, to: shown ? 1 : 0)
            .stroke(Aurora.cyan, style: StrokeStyle(lineWidth: size * 0.16, lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size * 0.75)
            .opacity(shown ? 1 : 0)
            // Drawn on the way in, faded on the way out.
            .animation(shown ? Motion.land : Motion.settle, value: shown)
            .accessibilityHidden(true)
            .task(id: commits) {
                guard commits > 0 else { return }
                shown = true
                // Cancelled by the next save, which starts the wait again with the tick still
                // drawn — and asked again after the wait, for a save that landed in the turn
                // it ended (rule `43-concurrency`).
                do { try await Task.sleep(for: Self.stay) } catch { return }
                guard !Task.isCancelled else { return }
                shown = false
            }
    }
}

private extension View {

    /// Draws ``SavedTick`` just past this view's trailing edge, for a card that has saved
    /// `commits` times.
    ///
    /// **Over the row and not in it.** As a member of the row it took its width whether or not
    /// it was showing, and the line beside it — a goal's figure, in a row that is already
    /// tight in Russian — was the one that gave it up.
    func savedTick(_ commits: Int) -> some View {
        overlay(alignment: .trailing) {
            SavedTick(commits: commits)
                // The overlay's trailing guide is eight points before its own leading edge:
                // aligned to this view's trailing edge, it stands that far after it.
                .alignmentGuide(.trailing) { $0[.leading] - 8 }
        }
    }
}

/// A check mark as one stroke, short arm first, so that trimming it draws it the way a hand
/// would.
private struct CheckShape: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.36, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
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
        rescheduleReminders: { _ in },
        // Never reach a real WCSession from a canvas.
        publishWrist: { _ in }
    )

    // A goal that is *not* the default, so the canvas shows `GoalCard` seeding from the model
    // rather than from `defaultDailyGoal` — the bug an `.task`-seeded `@State` would hide.
    manager.saveDailyGoal(ml: 2_500)

    // The backdrop is `RootTabView`'s in the app; alone on the canvas the screen stands on one.
    return SettingsView().background { AuroraBackground() }.environment(manager)
}
