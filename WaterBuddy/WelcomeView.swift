//
//  WelcomeView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 14/10/26.
//

import SwiftData
import SwiftUI

// MARK: - The steps

/// The welcome's four steps, in the order they are walked.
///
/// A **top-level** enum, as ``AppTab`` is beside ``RootTabView``: `View` is `@MainActor`, and a type
/// nested in one would need `await` from `WelcomeStepTests`, which reads it off the main actor
/// (rule `43-concurrency`).
///
/// **The steps stand side by side in this order, and a change of step moves them all together.**
/// The step after the one shown waits a screen's width out on the trailing side, the step before it
/// on the leading side — so *Continue* brings its step in from the trailing edge and *Back* from the
/// leading edge, and nothing but the order decides the direction. ``PageTurn`` does the same for
/// the tabs with two pages at most, because a tab's page is rebuilt each time it is shown; the
/// welcome keeps all four, so a step *Back* returns to is the step as it was left.
nonisolated enum WelcomeStep: Int, CaseIterable, Sendable {

    case hello
    case goal
    case vessels
    case reminders

    /// The step *Continue* brings in; `nil` on the last, where the welcome ends instead.
    var next: WelcomeStep? { WelcomeStep(rawValue: rawValue + 1) }

    /// The step *Back* returns to; `nil` on the first, which has no *Back*.
    var previous: WelcomeStep? { WelcomeStep(rawValue: rawValue - 1) }

    /// Counted from one, as the dots are read: *Step 2 of 4*.
    var number: Int { rawValue + 1 }

    /// Where this step stands while `shown` is on screen, across a screen `width` wide. Under
    /// Reduce Motion (`slides` false) every step stands in place, and the change is a cross-fade
    /// (rule `65-accessibility`).
    func offset(shown: WelcomeStep, across width: CGFloat, slides: Bool) -> CGFloat {
        slides ? CGFloat(rawValue - shown.rawValue) * width : 0
    }

    /// What this step is drawn at. A step that slides is seen all the way out. Under Reduce Motion
    /// the steps stand on one another and only the one shown is seen — the rest at
    /// ``Arrival/hiddenOpacity``, never at exactly nothing, for the reason given there: a view at
    /// zero has not always been given back to a finger and to VoiceOver when it returned.
    func opacity(shown: WelcomeStep, slides: Bool) -> Double {
        slides || self == shown ? 1 : Arrival.hiddenOpacity
    }
}

// MARK: - The welcome

/// The first-run screen: four steps — hello, the daily goal, the quick-add vessels, reminders — and
/// then the app (spec `docs/superpowers/specs/2026-10-14-welcome-design.md`, the canvas
/// *WaterBuddy welcome*).
///
/// Shown instead of ``RootTabView`` while ``DataManager/isGoalSet`` is `false` — a state that exists
/// once per install, because the flag is never unset. Nobody who finished setup before stage 5 ever
/// sees it. It replaced `GoalSetupView`, the one-screen setup every install had shown since 1.0.
///
/// **Nothing is stored until the end.** The goal and the three amounts are this view's own state
/// while the steps are walked (rule `50-views`), so *Back* is free and a welcome left half-way
/// leaves nothing behind. Finishing is one call,
/// ``finish(goal:amounts:asksForReminders:on:using:)``, so its order is tested without a screen.
///
/// **A pinned bar.** The dots, *Back* and the step's main action stand at the foot of the screen
/// whatever the step's height, and the step scrolls above them: *Continue* is always under the
/// thumb (decision W5).
///
/// It stands its own ``AuroraBackground`` and declares the dark appearance itself, because it is a
/// root screen and not a page of ``RootTabView`` (rule `50-views`). Every backdrop reads one clock,
/// so `RootView`'s cross-fade to the tabs is still one surface.
struct WelcomeView: View {

    // MARK: The goal's menu

    /// The range the goal slider offers, which is intentionally *narrower* than what the store
    /// accepts.
    ///
    /// ``DataManager`` clamps a goal to `1...maximumDailyIntake` because a corrupt suite must not
    /// be able to divide by zero or overflow the total. That is a floor against corruption, not a
    /// menu: 1 ml and 100,000 ml are both legal to store and absurd to offer. These two numbers are
    /// the offer, and they live on a screen rather than on `DataManager` because the widget has no
    /// goal picker and nothing in the extension needs to agree about them.
    ///
    /// **Two screens ask** — this one and `SettingsView`'s `GoalCard`, which reads this same
    /// declaration rather than declaring its own: a range narrower in Settings than here would
    /// strand a user at a goal they had already chosen, and one wider there would offer an amount
    /// this screen called absurd. ``GoalSuggestion`` reads it too, so a suggestion always lands on
    /// the slider.
    ///
    /// The seams that *are* load-bearing — that ``DataManager/defaultDailyGoal`` sits inside this
    /// range, lands on a step, and that neither end is rewritten by the store's clamp — are pinned
    /// by `DailyGoalSetupTests`. They lived on `GoalSetupView` until stage 5. `nonisolated`, because
    /// suites off the main actor read them (rule `43-concurrency`).
    nonisolated static let goalRange = 1_000...4_000

    /// The slider's increment. 100 ml is roughly half a glass — fine enough to feel like a choice,
    /// coarse enough that a drag lands on a round number the user can hold in their head.
    nonisolated static let goalStep = 100

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The step on screen. Presentation state, and only the user's taps change it.
    @State private var step = WelcomeStep.hello

    /// The goal under the finger, in millilitres — an `Int`, as every volume in this product is. The
    /// `Double` a `Slider` demands exists only inside ``goalValue``.
    @State private var goal: Int

    /// Cup, Glass, Bottle (``DataManager/servings``), as the vessels step sets them.
    @State private var amounts: [Int]

    /// Whether a finger is on the goal slider: a step under a finger ticks.
    @State private var isDraggingGoal = false

    /// Set by the first tap of either finishing button and never cleared: the welcome finishes once,
    /// whatever iOS's question does meanwhile (decision W10).
    @State private var finishing = false

    /// Set as a step starts to turn and cleared when its slide has ended. Until then the bar's
    /// buttons are disabled: the bar stands still while the steps move, so a second tap of a quick
    /// pair landed on the step arriving — a double tap on *Get Started* skipped the goal, and one on
    /// the vessels' *Continue* could land on the arriving *Not now* and finish the welcome unseen
    /// (the final review, 2026-10-14; `testADoubleTapMovesOneStep`). Disabled rather than merely
    /// untouchable, so the state can be read: the UI tests wait on it before their next tap
    /// (`tapWhenReady(_:)`). `PressStyle` draws no dimmed state, so nothing visible changes.
    @State private var turning = false

    /// Bumped by a step of the goal slider under a finger: the tick.
    @State private var goalSteps = 0

    /// Bumped by a finishing tap: the confirmation.
    @State private var finishes = 0

    /// The calculator's weight, in ``unit`` — written nowhere, and gone with the welcome
    /// (rule `70-privacy`).
    @State private var weight: Int

    /// The weight's unit: the device region's to start with (spec §4).
    @State private var unit: GoalSuggestion.Unit

    /// How active a day is: *Moderate* to start with (decision W2).
    @State private var activity = GoalSuggestion.Activity.moderate

    /// Whether *Work it out for me* is open.
    @State private var calculatorOpen = false

    /// Bumped by *Use*: the confirmation, and the slider's glide to the suggestion. A drag moves
    /// the slider without it, and does not glide.
    @State private var uses = 0

    /// Whether the welcome has arrived (``Arrival``). Hello settles in as the app opens; the steps
    /// that slide in after it are whole as they come.
    @State private var arrived = false

    /// The title VoiceOver is moved to when the step changes.
    @AccessibilityFocusState private var focusedTitle: WelcomeStep?

    /// The canvas's 60-pt goal figure, scaled as a large title is and capped at its use site.
    @ScaledMetric(relativeTo: .largeTitle) private var figureSize: CGFloat = 60

    /// The canvas's 42-pt *WaterBuddy*, scaled the same way.
    @ScaledMetric(relativeTo: .largeTitle) private var nameSize: CGFloat = 42

    /// Seeded from the model through `init`, never in `.task` (rule `50-views`). On a fresh install
    /// these are ``DataManager/defaultDailyGoal`` and ``DataManager/defaultServings``. The goal is
    /// kept on the slider, which offers nothing outside ``goalRange``.
    init(goal: Int, amounts: [Int]) {
        _goal = State(initialValue: min(max(goal, Self.goalRange.lowerBound), Self.goalRange.upperBound))
        _amounts = State(initialValue: amounts)

        // The device's region, deliberately not the app's language (spec §4, the owner's ruling).
        let unit = GoalSuggestion.Unit.starting(for: Locale.current.measurementSystem)
        _unit = State(initialValue: unit)
        _weight = State(initialValue: unit.start)
    }

    /// Whether a change of step carries the steps across the screen, or cross-fades them.
    private var slides: Bool { !reduceMotion }

    var body: some View {
        ZStack {
            AuroraBackground()

            VStack(spacing: 0) {
                steps
                bar
            }
        }
        // A root screen, so the status bar hangs over it: only the preference travels *up* to the
        // hosting controller and turns the clock and battery white (`RootTabView`'s note).
        .preferredColorScheme(.dark)
        // Ticks off the view's own state, which only the user's taps change (rule
        // `60-design-system`).
        .sensoryFeedback(Haptics.select, trigger: step)
        .sensoryFeedback(Haptics.select, trigger: goalSteps)
        .sensoryFeedback(Haptics.confirm, trigger: finishes)
        .sensoryFeedback(Haptics.confirm, trigger: uses)
        .tracksArrival($arrived)
        // VoiceOver starts the new step at its title, as a new screen would.
        .onChange(of: step) { _, shown in focusedTitle = shown }
    }

    // MARK: - The steps

    private var steps: some View {
        GeometryReader { proxy in
            // The whole screen's width, as `RootTabView` measures it.
            let width = proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing

            ZStack {
                ForEach(WelcomeStep.allCases, id: \.self) { page in
                    content(of: page)
                        // Hello settles in as the app opens; a step that slides in is whole as it
                        // comes (``Arrival``).
                        .environment(\.pageSettlesIn, page == .hello)
                        .offset(x: page.offset(shown: step, across: width, slides: slides))
                        .opacity(page.opacity(shown: step, slides: slides))
                        // Four steps exist; VoiceOver and a finger get the one shown.
                        .accessibilityHidden(page != step)
                        .allowsHitTesting(page == step)
                }
            }
            // Scoped to the step, never a bare `withAnimation` (rule `50-views`). A transaction rather
            // than `.animation(_:value:)`, as `RootTabView`'s page turn is, because the end of the
            // slide has to be known: that is when the bar answers again (``turning``).
            .transaction(value: step) { transaction in
                transaction.animation = slides ? Motion.page : Motion.pageFade
                transaction.addAnimationCompletion { turning = false }
            }
        }
        // One point clear of the status bar — History's remedy (#108) — so a step scrolled up is
        // clipped under the clock rather than drawn across it (#89). Each step's inset gives the
        // point back, so its title stands where the tabs' titles do.
        .padding(.top, 1)
    }

    @ViewBuilder
    private func content(of page: WelcomeStep) -> some View {
        switch page {
        case .hello:
            hello
        case .goal:
            // The goal's and the vessels' lines open their cards rather than standing under the
            // title: there the aurora's blue light sits behind their second line, and white read
            // 4.38:1 at its brightest even at full strength (the owner's ruling, 2026-10-14).
            stepPage(.goal, title: Text("Daily goal", bundle: strings), subtitle: nil) { proxy in
                goalPage(scrolling: proxy)
            }
        case .vessels:
            stepPage(.vessels, title: Text("Quick-add vessels", bundle: strings), subtitle: nil) { _ in
                vesselsStep
            }
        case .reminders:
            stepPage(
                .reminders,
                title: Text("Reminders", bundle: strings),
                subtitle: Text("A gentle nudge when it has been a while.", bundle: strings)
            ) { _ in
                remindersStep
            }
        }
    }

    /// A step after the first: its title where the tabs' titles stand, a line under it if the step
    /// has one there, and what it asks — all of it scrolling above the bar (rule
    /// `65-accessibility`). The content is handed the scroll view's proxy, for the goal step's
    /// calculator.
    private func stepPage<Content: View>(
        _ page: WelcomeStep,
        title: Text,
        subtitle: Text?,
        @ViewBuilder content: @escaping (ScrollViewProxy) -> Content
    ) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    title
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                        // It wraps rather than shrinking out of sight: *Tez qo‘shish idishlari* is a
                        // long title at the ordinary size, and the largest sizes are larger still.
                        .fixedSize(horizontal: false, vertical: true)
                        // The tabs' title line, so the title stands where theirs does
                        // (`testAStepsTitleStandsWhereATabsTitleDoes`).
                        .frame(maxWidth: .infinity, minHeight: ScreenMetrics.titleLine, alignment: .leading)
                        .legibleOnBackdrop()
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityFocused($focusedTitle, equals: page)

                    if let subtitle {
                        subtitle
                            .font(.body)
                            // Full white, not the canvas's 0.92: on the aurora at 0.92 it read
                            // 4.36:1 at the light's brightest (`docs/DESIGN.md`, *Welcome,
                            // measured*).
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                            .legibleOnBackdrop()
                            .padding(.top, WelcomeStyle.subtitleGap)
                    }

                    content(proxy)
                        .padding(.top, WelcomeStyle.contentGap)
                }
                .padding(.horizontal, ScreenMetrics.margin)
                // Every tab's inset, less the point the steps stand off the safe area.
                .padding(.top, ScreenMetrics.topInset - 1)
                .padding(.bottom, WelcomeStyle.contentGap)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    // MARK: - Hello

    /// The canvas's first board: the vessel, the name and one line, centred while they fit and
    /// scrolling at the largest sizes (rule `65-accessibility`).
    private var hello: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: WelcomeStyle.contentGap)

                    HelloVessel(isShown: step == .hello)
                        .arrives(arrived, order: 0)

                    greeting
                        .padding(.top, WelcomeStyle.helloGap)
                        .arrives(arrived, order: 1)

                    Spacer(minLength: WelcomeStyle.contentGap)
                }
                .padding(.horizontal, ScreenMetrics.margin)
                .frame(maxWidth: .infinity)
                .frame(minHeight: proxy.size.height)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    private var greeting: some View {
        VStack(spacing: 0) {
            // Two lines, split by hand, because the name must never share a line box with the words
            // before it: left as one string the layout hyphenated it, "WaterBud-dy", at the
            // accessibility sizes. Each line's own `lineLimit(1)` is what turns "does not fit"
            // into "scale down" instead of "break". *WaterBuddy* is the larger: the name is the
            // point of the line (decision W8).
            VStack(spacing: 0) {
                Text("Welcome to", bundle: strings)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                Text("WaterBuddy", bundle: strings)
                    .font(.system(size: min(nameSize, WelcomeStyle.nameCeiling), weight: .heavy))
                    .tracking(WelcomeStyle.nameTracking)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            // One greeting, one stop — and the step's heading.
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityFocused($focusedTitle, equals: .hello)

            Text("One tap logs a glass. Watch your day fill up.", bundle: strings)
                .font(.body)
                .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, WelcomeStyle.helloLineGap)
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(.white)
        .legibleOnBackdrop()
    }

    // MARK: - The daily goal

    /// Where the calculator is scrolled to when it opens.
    private static let calculatorID = "calculator"

    private func goalPage(scrolling proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            goalCard
            footnote(Text("You can change this later in Settings.", bundle: strings))
            calculator
                .padding(.top, WelcomeStyle.cardGap)
                .id(Self.calculatorID)
        }
        .onChange(of: calculatorOpen) { _, open in
            guard open else { return }
            // Opening the row brings the panel into view (spec §4). A scroll position is not view
            // state that `.animation(_:value:)` can scope, so this one scroll runs in a transaction
            // of its own — decision P5, put to the owner with the plan.
            withTransaction(\.animation, Motion.settle) {
                proxy.scrollTo(Self.calculatorID, anchor: .bottom)
            }
        }
    }

    /// *Work it out for me*: a row that opens into the calculator, on the goal card's glass.
    private var calculator: some View {
        VStack(spacing: 0) {
            Button {
                calculatorOpen.toggle()
            } label: {
                HStack(spacing: 8) {
                    Text("Work it out for me", bundle: strings)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    // After the words, not before them: at the row's leading end it stood in the
                    // pane's lit sheen and read 2.84:1 (the owner's ruling, 2026-10-14).
                    Image(systemName: "sparkles")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Aurora.cyan)
                        .accessibilityHidden(true)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.down")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                        .rotationEffect(.degrees(calculatorOpen ? 180 : 0))
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, WelcomeStyle.cardPadding)
                .frame(minHeight: WelcomeStyle.rowHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressStyle())

            if calculatorOpen {
                CalculatorPanel(weight: $weight, unit: $unit, activity: $activity, goal: goal) { suggestion in
                    goal = suggestion
                    uses += 1
                }
                .padding(.horizontal, WelcomeStyle.panelInset)
                .padding(.bottom, WelcomeStyle.panelBottom)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .liquidGlass(density: .frosted, elevation: .raised)
        .animation(Motion.settle, value: calculatorOpen)
    }

    /// The question, the figure and the slider, on one pane. The question opens the card rather than
    /// standing under the title, on the aurora's brightest light (the owner's ruling, 2026-10-14).
    private var goalCard: some View {
        VStack(spacing: WelcomeStyle.cardGap) {
            cardLine(Text("How much water do you want to drink each day?", bundle: strings))
            goalFigure
            goalSlider
        }
        .welcomeCard()
    }

    /// The line that opens a step's card: what the step asks, on glass. Full white, as Settings' card
    /// titles are: it stands by the pane's lit corner, where the canvas's 0.92 read 4.46:1 (the
    /// owner's ruling, 2026-10-14).
    private func cardLine(_ text: Text) -> some View {
        text
            .font(.body)
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var goalFigure: some View {
        let size = min(figureSize, WelcomeStyle.figureCeiling)

        return HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(goal, format: .number)
                .font(.system(size: size, weight: .bold, design: .rounded))
                .tracking(WelcomeStyle.figureTracking)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(goal)))

            // Sized as a ratio of the figure it annotates, never with its own text style: a fixed
            // style and a scaled figure cross over at the accessibility sizes (rule
            // `65-accessibility`).
            Text("ml", bundle: strings)
                .font(.system(size: size * WelcomeStyle.unitRatio, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(WelcomeStyle.unitOpacity))
        }
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .frame(maxWidth: .infinity)
        .shadow(color: .black.opacity(0.3), radius: 10, y: 2)
        .animation(Motion.settle, value: goal)
        // One idea, one element, as `GoalSetupView` read it: *Daily goal*, *N millilitres*.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Daily goal", bundle: strings))
        .accessibilityValue(spokenMillilitres(goal))
    }

    private var goalSlider: some View {
        VStack(spacing: 8) {
            Slider(
                value: goalValue,
                in: Double(Self.goalRange.lowerBound)...Double(Self.goalRange.upperBound),
                step: Double(Self.goalStep),
                onEditingChanged: { isDraggingGoal = $0 }
            )
            .tint(Aurora.cyan)
            // Glides when *Use* sets it, and only then: keyed to the tap, not to the goal, so a
            // drag is never chased by its own animation.
            .animation(Motion.settle, value: uses)
            // A `Slider`'s stock VoiceOver value is a percentage of its range, which would announce
            // "33%" for 2,000 ml — a number that appears nowhere in the product.
            .accessibilityLabel(Text("Daily water goal", bundle: strings))
            .accessibilityValue(spokenMillilitres(goal))

            HStack {
                Text(Self.goalRange.lowerBound, format: .number)
                Spacer()
                Text(Self.goalRange.upperBound, format: .number)
            }
            .font(.footnote.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(.white.opacity(WelcomeStyle.footnoteOpacity))
            // The slider already says where it is and what it can reach (rule `65-accessibility`).
            .accessibilityHidden(true)
        }
    }

    /// Bridges the `Int` this view holds to the `Double` a `Slider` requires. `rounded()`, never
    /// truncation, so floating-point dust cannot turn 2,000 into 1,999. A step is ticked only under
    /// a finger.
    private var goalValue: Binding<Double> {
        Binding(
            get: { Double(goal) },
            set: { value in
                let stepped = Int(value.rounded())
                guard stepped != goal else { return }
                goal = stepped
                if isDraggingGoal { goalSteps += 1 }
            }
        )
    }

    // MARK: - The vessels

    private var vesselsStep: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: WelcomeStyle.vesselGap) {
                // The step's line opens the card, as the goal's does — and stands where Settings'
                // card title stands, so the Cup's glyph sits below the pane's lit corner, where it
                // read 2.81:1 when it opened the card (the owner's ruling, 2026-10-14).
                cardLine(Text("Home pours these in one tap. Set each to what yours holds.", bundle: strings))

                // Settings' rows, the same view (``VesselSliders``). Nothing is saved here until the
                // welcome ends, so the drag is not listened to.
                VesselSliders(amounts: $amounts)

                VStack(alignment: .leading, spacing: WelcomeStyle.cardGap) {
                    Rectangle()
                        .fill(.white.opacity(WelcomeStyle.hairlineOpacity))
                        .frame(height: 1)
                        .accessibilityHidden(true)
                    Text("The Glass is the one your widget, Siri and Control Center log.", bundle: strings)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .welcomeCard(alignment: .leading)

            footnote(Text("You can change these later in Settings.", bundle: strings))
        }
    }

    // MARK: - Reminders

    private var remindersStep: some View {
        VStack(spacing: WelcomeStyle.cardGap) {
            NotificationPreview()
            schedule
        }
    }

    private var schedule: some View {
        VStack(alignment: .leading, spacing: WelcomeStyle.cardGap) {
            Text("Smart reminders", bundle: strings)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)

            ReminderBells()

            Text("A nudge every two hours from 9 AM to 9 PM, skipped if you drank in the hour before it. Reaching your goal silences the rest of the day.", bundle: strings)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                .fixedSize(horizontal: false, vertical: true)
        }
        .welcomeCard(alignment: .leading)
    }

    /// ``ReminderPlan/hours`` as instants on one fixed day, for drawing only. A time of day is
    /// formatted from a date, and a fixed one keeps the clock out of it.
    nonisolated static func bellTimes(in calendar: Calendar) -> [Date] {
        ReminderPlan.hours.compactMap {
            calendar.date(from: DateComponents(year: 2026, month: 1, day: 15, hour: $0))
        }
    }

    // MARK: - The bar

    private var bar: some View {
        VStack(spacing: 0) {
            dots
            buttons
                .padding(.top, WelcomeStyle.dotsGap)
            if step == .reminders {
                notNow
                    .padding(.top, WelcomeStyle.notNowGap)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, ScreenMetrics.margin)
        .padding(.top, WelcomeStyle.barTop)
        .padding(.bottom, WelcomeStyle.barBottom)
        // *Back* arriving, *Not now* arriving, the dots moving on: a state that changes.
        .animation(Motion.settle, value: step)
    }

    private var dots: some View {
        HStack(spacing: WelcomeStyle.dotGap) {
            ForEach(WelcomeStep.allCases, id: \.self) { page in
                Capsule()
                    .fill(.white.opacity(page == step ? 1 : WelcomeStyle.dotOpacity))
                    .frame(width: page == step ? WelcomeStyle.currentDot : WelcomeStyle.dot,
                           height: WelcomeStyle.dot)
            }
        }
        // One element: *Step 2 of 4*.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(strings.localized("Step %1$d of %2$d", step.number, WelcomeStep.allCases.count, locale: locale))
    }

    /// *Back* and the step's main action side by side while both fit on one line. At the largest
    /// sizes the main action stands over *Back*, each as wide as the bar — never a label cut short
    /// and never a control under 44 pt (rule `65-accessibility`).
    private var buttons: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: WelcomeStyle.buttonGap) {
                if step.previous != nil { backButton(oneLine: true) }
                primaryButton(oneLine: true)
            }
            VStack(spacing: WelcomeStyle.buttonGap) {
                primaryButton(oneLine: false)
                if step.previous != nil { backButton(oneLine: false) }
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// The step's one main action, on the primary surface (rule `60-design-system`). At 56 pt its
    /// corner is a capsule's; a label wrapped at the largest sizes keeps the corner (decision P3).
    private func primaryButton(oneLine: Bool) -> some View {
        Button(action: advance) {
            primaryLabel
                .font(.headline.weight(.bold))
                .lineLimit(oneLine ? 1 : nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: oneLine, vertical: true)
                .padding(.horizontal, WelcomeStyle.buttonInset)
                .frame(maxWidth: .infinity, minHeight: WelcomeStyle.buttonHeight)
                .primarySurface(in: RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous))
        }
        .buttonStyle(PressStyle())
        .disabled(finishing || turning)
    }

    @ViewBuilder
    private var primaryLabel: some View {
        switch step {
        case .hello: Text("Get Started", bundle: strings)
        case .goal, .vessels: Text("Continue", bundle: strings)
        case .reminders: Text("Turn on reminders", bundle: strings)
        }
    }

    private func backButton(oneLine: Bool) -> some View {
        Button {
            if let previous = step.previous { turn(to: previous) }
        } label: {
            Text("Back", bundle: strings)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(oneLine ? 1 : nil)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: oneLine, vertical: true)
                .padding(.horizontal, WelcomeStyle.buttonInset)
                .frame(minWidth: WelcomeStyle.backWidth, maxWidth: oneLine ? nil : .infinity,
                       minHeight: WelcomeStyle.buttonHeight)
                // A short label on a control, so `.sheer`; the glass itself is what is pressed
                // (rule `60-design-system`).
                .liquidGlass(in: RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous),
                             density: .sheer, elevation: .raised, interactive: true)
        }
        .buttonStyle(PressStyle())
        .disabled(finishing || turning)
    }

    /// Ends the welcome and asks nothing: reminders stay off, as a fresh install has them.
    private var notNow: some View {
        Button {
            guard !turning else { return }
            finish(askingForReminders: false)
        } label: {
            Text("Not now", bundle: strings)
                .font(.headline)
                .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
                .legibleOnBackdrop()
        }
        .buttonStyle(PressStyle())
        .disabled(finishing || turning)
    }

    /// *Continue*, or — on the last step, where it reads *Turn on reminders* — the welcome's end
    /// with reminders asked for.
    private func advance() {
        guard !turning else { return }
        if let next = step.next {
            turn(to: next)
        } else {
            finish(askingForReminders: true)
        }
    }

    /// One step, and nothing else until it has arrived. The guard as well as the bar's hit testing:
    /// VoiceOver activates a button without a touch.
    private func turn(to page: WelcomeStep) {
        guard !turning else { return }
        turning = true
        step = page
    }

    // MARK: - Finishing

    /// The welcome's end, from a tap. Once: both finishing buttons are disabled from the first tap.
    private func finish(askingForReminders: Bool) {
        guard !finishing else { return }
        finishing = true
        finishes += 1

        let goal = goal
        let amounts = amounts
        Task {
            // The scheduler is built here, inside the task, and never stored (rule
            // `80-notifications`).
            await Self.finish(goal: goal, amounts: amounts, asksForReminders: askingForReminders,
                              on: manager, using: ReminderScheduler.live())
        }
    }

    /// Ends the welcome: the vessels, then — if asked — reminders, then the goal.
    ///
    /// **The goal is last because it is what closes the welcome.** ``DataManager/saveDailyGoal(ml:)``
    /// flips ``DataManager/isGoalSet`` and `RootView` moves on to the tabs, so iOS's question about
    /// reminders is asked, and answered, over the welcome that asked it (spec 2026-10-09 §4.2). A
    /// refusal stores reminders off and the app still opens (``ReminderPermission``).
    ///
    /// Vessels left as they were store nothing: ``DataManager/servings``' setter guards on equality,
    /// so the defaults are not pinned into the suite for good.
    static func finish(goal: Int, amounts: [Int], asksForReminders: Bool,
                       on manager: DataManager, using scheduler: ReminderScheduler) async {
        manager.servings = amounts
        if asksForReminders {
            await ReminderPermission.enable(on: manager, using: scheduler)
        }
        manager.saveDailyGoal(ml: goal)
    }

    // MARK: - Parts

    /// A line under a card, on the aurora itself.
    private func footnote(_ text: Text) -> some View {
        text
            .font(.footnote)
            .foregroundStyle(.white.opacity(WelcomeStyle.asideOpacity))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .legibleOnBackdrop()
            .padding(.top, WelcomeStyle.footnoteGap)
    }

    /// A volume as VoiceOver reads it: the noun in the form its count takes, the figure grouped as
    /// the language groups it (rule `50-views`).
    private func spokenMillilitres(_ volume: Int) -> String {
        strings.localized("%1$d millilitres", volume, locale: locale)
    }
}

// MARK: - Hello's vessel

/// Half a glass of water, its waves moving: the first thing a new user sees.
///
/// Drawn from ``WaterSurface``'s waves in a sheer glass circle — the parts Home's vessel is built
/// from — and not from Home's own vessel, which brings a readout, a scrim, a slosh tied to pours and
/// an accessibility element that a decoration needs none of (decision W9). Hidden from VoiceOver.
///
/// The waves travel on a `TimelineView` clock that pauses while its step is not shown, and stand at
/// their resting frame under Reduce Motion: a perpetual animation resolves to nothing, never to a
/// gentler one (rule `65-accessibility`).
private struct HelloVessel: View {

    /// Whether Hello is the step on screen.
    let isShown: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase

    /// When the water last began to move, and where the surface stood then — set together, as on
    /// Home's vessel.
    @State private var motionStart = Date.distantPast
    @State private var restingPhase = 0.0

    /// Whether the water is moving, and so whether the clock runs at all.
    @State private var moving = false

    /// Half full: the app's promise, drawn.
    private static let level = 0.5

    var body: some View {
        Group {
            if reduceMotion {
                waves(phase: 0)
            } else {
                // Moves as Home's water does after a pour — here, each time the step is shown — and
                // then rests (``WaterMotion``); stopped off its step and while the app is not active.
                TimelineView(.animation(minimumInterval: nil, paused: !moving || !isShown || scenePhase != .active)) { context in
                    waves(phase: WaterMotion.phase(at: context.date, since: motionStart, base: restingPhase))
                }
                .task(id: isShown) {
                    guard isShown else {
                        moving = false
                        return
                    }
                    let shown = Date.now
                    restingPhase = WaterMotion.base(after: restingPhase, from: motionStart, to: shown)
                    motionStart = shown
                    moving = true
                    try? await Task.sleep(for: .seconds(WaterMotion.settling))
                    guard !Task.isCancelled else { return }
                    moving = false
                }
            }
        }
        .frame(width: WelcomeStyle.vessel, height: WelcomeStyle.vessel)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        .accessibilityHidden(true)
    }

    /// Home's water at Home's proportions: the same amplitude for the diameter, inset 10 pt so it
    /// sits in a well and never covers the lit rim.
    private func waves(phase: Double) -> some View {
        WaterSurface(level: Self.level, phase: phase, amplitude: WelcomeStyle.vessel * 0.018)
            .clipShape(Circle())
            .padding(10)
    }
}

// MARK: - The calculator

/// The calculator under *Work it out for me*: a weight on a wheel, its unit, how active, and the
/// suggestion they make (spec 2026-10-14 §4).
///
/// **Nothing above it moves until *Use* is tapped** (decision W1). The wheel, the unit and the
/// activity change only the figure on the button, and *Use* hands it to the goal. While the goal
/// already is the suggestion, the button says so and does nothing; it comes back as soon as either
/// moves.
///
/// It holds nothing of its own but a haptic counter. The weight, unit and activity are the welcome's
/// state, bound here, and go with it — written nowhere (rule `70-privacy`).
private struct CalculatorPanel: View {

    @Binding var weight: Int
    @Binding var unit: GoalSuggestion.Unit
    @Binding var activity: GoalSuggestion.Activity

    /// The goal step's goal, to tell whether the suggestion is already it.
    let goal: Int

    /// *Use*, with the suggestion.
    let onUse: (Int) -> Void

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// Bumped by a unit or an activity picked: the tick. The wheel plays the system's own.
    @State private var picks = 0

    private var suggestion: Int {
        GoalSuggestion.goal(weight: weight, unit: unit, activity: activity)
    }

    var body: some View {
        VStack(spacing: 0) {
            // The weight beside the activity while both fit; one over the other at the largest
            // sizes (rule `65-accessibility`).
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 12) {
                    weightColumn
                        .frame(width: WelcomeStyle.weightColumn)
                    activityColumn
                }
                VStack(alignment: .leading, spacing: WelcomeStyle.cardGap) {
                    weightColumn
                    activityColumn
                }
            }

            useRow
                .padding(.top, WelcomeStyle.cardGap)

            Text("A starting point, not medical advice.", bundle: strings)
                .font(.footnote)
                .foregroundStyle(.white.opacity(WelcomeStyle.footnoteOpacity))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
        .sensoryFeedback(Haptics.select, trigger: picks)
    }

    // MARK: The weight

    private var weightColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your weight", bundle: strings)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 4)
                // The wheel below carries the same words as its label.
                .accessibilityHidden(true)

            Picker(selection: $weight) {
                ForEach(Array(unit.range), id: \.self) { value in
                    Text(verbatim: weightText(value))
                        .font(.title3.weight(.semibold))
                        .fontDesign(.rounded)
                        .tag(value)
                }
            } label: {
                Text("Your weight", bundle: strings)
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .frame(height: WelcomeStyle.wheelHeight)
            .clipShape(RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous))
            // A wheel built anew for the other unit, rather than one range swapped under a wheel
            // mid-turn.
            .id(unit)
            .accessibilityLabel(Text("Your weight", bundle: strings))

            unitSwitch
        }
    }

    /// *70 kg*, *154 lb*. A weight, not a volume, and never above three digits, so a `%1$d` key.
    private func weightText(_ value: Int) -> String {
        let key = switch unit {
        case .kilograms: "%1$d kg"
        case .pounds: "%1$d lb"
        }
        return strings.localized(key, value, locale: locale)
    }

    private var unitSwitch: some View {
        HStack(spacing: 2) {
            ForEach(GoalSuggestion.Unit.allCases, id: \.self) { choice in
                let isSelected = choice == unit

                Button {
                    guard !isSelected else { return }
                    // The weight shown, converted: 70 kg becomes 154 lb, and back.
                    weight = unit.convert(weight, to: choice)
                    unit = choice
                    picks += 1
                } label: {
                    unitName(choice)
                        .font(.subheadline.weight(isSelected ? .bold : .semibold))
                        .foregroundStyle(.white.opacity(isSelected ? 1 : WelcomeStyle.footnoteOpacity))
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background { selectionMark(isSelected, in: Capsule()) }
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressStyle())
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
    }

    private func unitName(_ choice: GoalSuggestion.Unit) -> Text {
        switch choice {
        case .kilograms: Text("kg", bundle: strings)
        case .pounds: Text("lb", bundle: strings)
        }
    }

    // MARK: The activity

    private var activityColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How active are you?", bundle: strings)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 4)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: 6) {
                ForEach(GoalSuggestion.Activity.allCases, id: \.self) { level in
                    activityButton(level)
                }
            }
        }
    }

    /// One level: its name over what it means. One button whose label is both — *Moderate, Exercise
    /// some days* — with the selected trait on the one picked (rule `65-accessibility`).
    private func activityButton(_ level: GoalSuggestion.Activity) -> some View {
        let isSelected = level == activity

        return Button {
            guard !isSelected else { return }
            activity = level
            picks += 1
        } label: {
            VStack(alignment: .leading, spacing: 1) {
                activityName(level)
                    .font(.subheadline.weight(isSelected ? .bold : .semibold))
                    .foregroundStyle(.white)
                activityLine(level)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(isSelected ? WelcomeStyle.textOpacity : WelcomeStyle.footnoteOpacity))
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: WelcomeStyle.choiceHeight, alignment: .leading)
            .background {
                selectionMark(isSelected, in: RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private func activityName(_ level: GoalSuggestion.Activity) -> Text {
        switch level {
        case .light: Text("Light", bundle: strings)
        case .moderate: Text("Moderate", bundle: strings)
        case .active: Text("Active", bundle: strings)
        }
    }

    /// What a level means, in a line short enough for the narrow column (decision W3).
    private func activityLine(_ level: GoalSuggestion.Activity) -> Text {
        switch level {
        case .light: Text("Mostly sitting", bundle: strings)
        case .moderate: Text("Exercise some days", bundle: strings)
        case .active: Text("Exercise most days", bundle: strings)
        }
    }

    // MARK: Use

    /// *Use 2,500 ml* — or, once the goal is that, *✓ Your goal is 2,500 ml*. The button draws a
    /// grouped figure and speaks a `%1$d` one (rule `50-views`).
    @ViewBuilder
    private var useRow: some View {
        if goal == suggestion {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.body.weight(.bold))
                    .foregroundStyle(Aurora.cyan)
                    .accessibilityHidden(true)
                Text(strings.figure("Your goal is %1$@ ml", suggestion, locale: locale))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: WelcomeStyle.useHeight)
            .accessibilityElement(children: .combine)
        } else {
            Button {
                onUse(suggestion)
            } label: {
                Text(strings.figure("Use %1$@ ml", suggestion, locale: locale))
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, WelcomeStyle.buttonInset)
                    .frame(maxWidth: .infinity, minHeight: WelcomeStyle.useHeight)
                    .liquidGlass(in: RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous),
                                 density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel(strings.localized("Use %1$d millilitres", suggestion, locale: locale))
        }
    }

    /// ``LiquidGlass/Selection``'s fill and rim, present at nothing when not picked, and landing on
    /// the one that is (rule `60-design-system`, decision P9).
    private func selectionMark<S: InsettableShape>(_ isSelected: Bool, in shape: S) -> some View {
        shape
            .fill(.white.opacity(isSelected ? LiquidGlass.Selection.fillOpacity : 0))
            .strokeBorder(.white.opacity(isSelected ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
            .scaleEffect(isSelected ? 1 : 0.9)
            .animation(Motion.land, value: isSelected)
    }
}

// MARK: - The reminder, previewed

/// What a reminder looks like, drawn from the real one's two strings, so the step shows exactly what
/// the user is agreeing to before iOS asks (decision W6). One element to VoiceOver.
private struct NotificationPreview: View {

    @Environment(\.strings) private var strings

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "drop.fill")
                .font(.system(size: WelcomeStyle.tileGlyph))
                .foregroundStyle(Aurora.cyan)
                .frame(width: WelcomeStyle.tile, height: WelcomeStyle.tile)
                .background(Aurora.gradient,
                            in: RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("WaterBuddy", bundle: strings)
                    Spacer(minLength: 0)
                    Text("now", bundle: strings)
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(WelcomeStyle.footnoteOpacity))

                Text("Time for water", bundle: strings)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)

                Text("A glass now keeps you on track for the day.", bundle: strings)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, WelcomeStyle.previewInset)
        .padding(.horizontal, WelcomeStyle.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - The bells

/// The day's seven reminders as a row of bells, each over its time.
///
/// The times are ``ReminderPlan/hours`` — the schedule itself — drawn as hours in the phone's own
/// 12- or 24-hour form (decision P10). One element to VoiceOver, speaking the seven as a sentence;
/// the bells are decoration, so their type is capped where seven columns run out of room.
private struct ReminderBells: View {

    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale

    private static let hour = Date.FormatStyle.dateTime.hour(.defaultDigits(amPM: .abbreviated))

    var body: some View {
        let times = WelcomeView.bellTimes(in: calendar)

        HStack(spacing: 0) {
            ForEach(times, id: \.self) { time in
                VStack(spacing: 6) {
                    Image(systemName: "bell")
                        .font(.system(size: WelcomeStyle.bellGlyph, weight: .semibold))
                        .foregroundStyle(Aurora.cyan)
                        .frame(width: WelcomeStyle.bell, height: WelcomeStyle.bell)
                        // Frosted, not sheer: on iOS 27.0 a sheer disc came out light enough that
                        // the cyan bell on it read 1.83:1 (the owner's ruling, 2026-10-14).
                        .liquidGlass(in: Circle(), density: .frosted, elevation: .resting)

                    Text(time, format: Self.hour)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(WelcomeStyle.textOpacity))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .frame(maxWidth: .infinity)
            }
        }
        // Seven discs side by side (rule `60-design-system`).
        .glassGroup()
        .background(alignment: .top) {
            // The line the bells sit on: from the first one's centre to the last one's, six of the
            // seven columns.
            GeometryReader { proxy in
                Rectangle()
                    .fill(.white.opacity(WelcomeStyle.bellLineOpacity))
                    .frame(width: proxy.size.width * CGFloat(max(times.count - 1, 0)) / CGFloat(max(times.count, 1)),
                           height: WelcomeStyle.bellLine)
                    .position(x: proxy.size.width / 2, y: WelcomeStyle.bell / 2)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(times.map { $0.formatted(Self.hour.locale(locale)) }
            .formatted(.list(type: .and).locale(locale)))
    }
}

// MARK: - The canvas's figures

/// The welcome's figures, read from the canvas's five boards' source (spec 2026-10-14 §3). They are
/// starting values. Every text pair on glass or on the aurora is measured off a render before it is
/// kept (`docs/DESIGN.md`, *Welcome, measured*).
private enum WelcomeStyle {

    // Type
    static let textOpacity = 0.92
    static let footnoteOpacity = 0.88
    /// A line under a card, on the aurora. The canvas's 0.88 read 4.25:1 there at the light's
    /// brightest; 0.95 is the owner's (2026-10-14).
    static let asideOpacity = 0.95
    static let unitOpacity = 0.9

    // A step
    static let subtitleGap: CGFloat = 6
    static let contentGap: CGFloat = 18
    static let cardPadding: CGFloat = 20
    static let cardGap: CGFloat = 16
    static let footnoteGap: CGFloat = 10
    static let vesselGap: CGFloat = 20
    static let hairlineOpacity = 0.16

    // Hello
    static let vessel: CGFloat = 232
    static let helloGap: CGFloat = 52
    static let helloLineGap: CGFloat = 14
    static let nameCeiling: CGFloat = 64
    static let nameTracking: CGFloat = -0.8

    // The goal
    static let figureCeiling: CGFloat = 80
    static let figureTracking: CGFloat = -1.4
    static let unitRatio: CGFloat = 22 / 60
    static let rowHeight: CGFloat = 56
    static let panelInset: CGFloat = 16
    static let panelBottom: CGFloat = 18
    static let weightColumn: CGFloat = 124
    static let wheelHeight: CGFloat = 160
    static let choiceHeight: CGFloat = 50
    static let useHeight: CGFloat = 50

    // Reminders
    static let previewInset: CGFloat = 14
    static let tile: CGFloat = 38
    static let tileGlyph: CGFloat = 20
    static let bell: CGFloat = 34
    static let bellGlyph: CGFloat = 15
    static let bellLine: CGFloat = 2
    static let bellLineOpacity = 0.22

    // The bar
    static let barTop: CGFloat = 12
    static let barBottom: CGFloat = 8
    static let dot: CGFloat = 8
    static let currentDot: CGFloat = 22
    static let dotGap: CGFloat = 8
    /// The steps not shown. The canvas's 0.35 read 2.2:1 against the 3:1 a mark holds; 0.6 is the
    /// owner's (2026-10-14).
    static let dotOpacity = 0.6
    static let dotsGap: CGFloat = 16
    static let buttonHeight: CGFloat = 56
    static let buttonGap: CGFloat = 12
    static let buttonInset: CGFloat = 20
    static let backWidth: CGFloat = 112
    static let notNowGap: CGFloat = 6
}

private extension View {

    /// A card on a step: the canvas's padding, the full width, and the welcome's one glass —
    /// `.frosted` + `.raised` on every card, Settings' pair, because every card carries
    /// sentence-length text (rule `60-design-system`).
    func welcomeCard(alignment: Alignment = .center) -> some View {
        padding(WelcomeStyle.cardPadding)
            .frame(maxWidth: .infinity, alignment: alignment)
            .liquidGlass(density: .frosted, elevation: .raised)
    }
}

// MARK: - Preview

#Preview {
    // A throwaway suite *and* an in-memory store, so finishing the welcome on the canvas writes
    // nothing real, rings no real widget doorbell and reconciles no real reminders (rule `50-views`).
    let defaults = UserDefaults(suiteName: "preview.waterbuddy.welcome")!
    defaults.removePersistentDomain(forName: "preview.waterbuddy.welcome")

    let manager = DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )

    return WelcomeView(goal: manager.dailyGoal, amounts: manager.servings).environment(manager)
}
