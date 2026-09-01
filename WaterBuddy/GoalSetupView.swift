//
//  GoalSetupView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftData
import SwiftUI

/// First-run setup: welcomes the user and asks for the one number the rest of the product is
/// measured against.
///
/// Shown instead of ``HomeView`` while ``DataManager/isGoalSet`` is `false`, which is a state that
/// only ever exists once per install — the flag is never unset, and `resetDailyProgress()`
/// deliberately leaves the goal alone.
///
/// **Committing is a single call.** ``DataManager/saveDailyGoal(ml:)`` records the amount *and*
/// marks setup complete; ``DataManager/isGoalSet`` is read-only precisely so a caller cannot mark
/// the flag without a goal, or store a goal without the flag, and leave "setup is complete" and
/// "there is no goal" both true. There is deliberately nothing else for this view's button to do.
struct GoalSetupView: View {

    @Environment(\.strings) private var strings

    /// The range the slider offers, which is intentionally *narrower* than what the store accepts.
    ///
    /// ``DataManager`` clamps a goal to `1...maximumDailyIntake` because a corrupt suite must not
    /// be able to divide by zero or overflow the total. That is a floor against corruption, not a
    /// menu: 1 ml and 100,000 ml are both legal to store and absurd to offer. These two numbers are
    /// the offer, and they live here rather than on `DataManager` because the widget has no goal
    /// picker and nothing in the extension needs to agree about them.
    ///
    /// **Two screens now ask** — this one and `SettingsView`'s `GoalCard`, which reads these same
    /// constants rather than declaring its own. That is not tidiness: a range narrower in Settings
    /// than at setup would strand a user at a goal they had already chosen and could no longer
    /// reach, and one wider there would offer an amount setup called absurd.
    ///
    /// The seams that *are* load-bearing — that ``DataManager/defaultDailyGoal`` sits inside this
    /// range, lands on a step, and that neither end is rewritten by the store's clamp — are pinned
    /// by `DailyGoalSetupTests`, because nothing in the compiler notices when one of them moves.
    /// Both screens are covered by those four, precisely because both read this declaration.
    static let goalRange = 1_000...4_000

    /// The slider's increment. 100 ml is roughly half a glass — fine enough to feel like a choice,
    /// coarse enough that a drag lands on a round number the user can hold in their head.
    static let goalStep = 100

    @Environment(DataManager.self) private var manager

    /// The amount under the finger, in millilitres, held as an `Int` for the same reason every
    /// other volume in this product is one: there is no such thing as 1,999.9997 ml of water.
    /// The `Double` a `Slider` demands exists only inside ``sliderValue`` and is rounded away on
    /// the way back out.
    @State private var goal = DataManager.defaultDailyGoal

    /// Bumped when the goal is committed. Drives the haptic, so it fires on the tap itself rather
    /// than on any later change to the model.
    @State private var commits = 0

    @ScaledMetric(relativeTo: .largeTitle) private var readoutSize: CGFloat = 56

    var body: some View {
        ZStack {
            AuroraBackground()

            // Onboarding is the one screen whose text can genuinely outgrow the display: three
            // stacked blocks, all of them type. It scrolls at the accessibility sizes and centres
            // itself at every size below, rather than being pinned to the top for everyone.
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: 24)
                        welcome
                        Spacer(minLength: 32)
                        goalCard
                        Spacer(minLength: 32)
                        getStartedButton
                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 28)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        // Same ruling as `HomeView`, and for the same reason — this is a root view, so the status
        // bar hangs over it. See the comment there for why `preferredColorScheme` and not
        // `.environment(\.colorScheme, .dark)`: only the preference travels *up* to the hosting
        // controller and turns the clock and battery white.
        .preferredColorScheme(.dark)
        .sensoryFeedback(Haptics.confirm, trigger: commits)
    }

    // MARK: - Welcome

    private var welcome: some View {
        VStack(spacing: 12) {
            // Two lines, split by hand, because the name must never share a line box with the
            // words before it. Left as one string the layout hyphenates it — measured at the
            // accessibility sizes as "WaterBud-dy", the product's own name broken across a line.
            //
            // `.minimumScaleFactor` alone does not fix that: with the break allowed, the text
            // *fits* hyphenated, so nothing ever asks it to shrink. Giving each line its own
            // `lineLimit(1)` is what turns "does not fit" into "scale down" instead of "break".
            VStack(spacing: 2) {
                Text("Welcome to", bundle: strings)
                Text("WaterBuddy")
            }
            .font(.largeTitle.weight(.bold))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.center)
            // One greeting, not two VoiceOver stops.
            .accessibilityElement(children: .combine)

            Text("How much water do you want to drink each day?", bundle: strings)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))

            // This line was deliberately withheld until it was true. Until `SettingsView` gained
            // `GoalCard`, `saveDailyGoal(ml:)` was called exactly once in an install's life and
            // there was no route back to it — so promising editability here would have been a lie
            // told at the one moment the user is deciding whether to trust the number.
            Text("You can change this later in Settings.", bundle: strings)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.6))
        }
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
    }

    // MARK: - The goal card

    private var goalCard: some View {
        VStack(spacing: 24) {
            readout
            slider
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        // `.frosted` rather than `.sheer`: this pane carries a sentence-length label and the whole
        // readout, and the density scale exists because tint and blur compete — a busy backdrop
        // under `.sheer` swallows body text (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .floating)
    }

    private var readout: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(goal, format: .number)
                // Bounded so the largest accessibility sizes cannot push the figure through the
                // edges of the card containing it.
                .font(.system(size: min(readoutSize, 76), weight: .semibold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(goal)))

            // Sized as a ratio of the figure it annotates, never with its own text style: a fixed
            // style and a scaled hero cross over at the accessibility sizes and the unit ends up
            // larger than the number.
            Text("ml", bundle: strings)
                .font(.system(size: min(readoutSize, 76) * 0.36, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .shadow(color: .black.opacity(0.3), radius: 10, y: 2)
        .animation(.smooth(duration: 0.35), value: goal)
        // One idea, one element: read as a single sentence rather than as "2,000" then "ml".
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Daily goal", bundle: strings))
        .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), goal))
    }

    private var slider: some View {
        VStack(spacing: 8) {
            Slider(
                value: sliderValue,
                in: Double(Self.goalRange.lowerBound)...Double(Self.goalRange.upperBound),
                step: Double(Self.goalStep)
            )
            .tint(Aurora.cyan)
            // A `Slider`'s stock VoiceOver value is a percentage of its range, which here would
            // announce "33%" for 2,000 ml — a number that appears nowhere in the product.
            .accessibilityLabel(Text("Daily water goal", bundle: strings))
            .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d millilitres", value: nil, table: nil), goal))

            HStack {
                Text(Self.goalRange.lowerBound, format: .number)
                Spacer()
                Text(Self.goalRange.upperBound, format: .number)
            }
            .font(.caption.weight(.medium))
            .monospacedDigit()
            .foregroundStyle(.white.opacity(0.6))
            // The slider already announces where it is and what it can reach; these two are
            // orientation for the eye, and as VoiceOver stops they are bare numbers with nothing
            // to attach them to.
            .accessibilityHidden(true)
        }
    }

    /// Bridges the `Int` this view holds to the `BinaryFloatingPoint` a `Slider` requires.
    ///
    /// The `step` already snaps the value; `rounded()` is what stops floating-point dust from
    /// turning 2,000 into 1,999.9999999 on the way back to an `Int`, which truncation would then
    /// read as 1,999.
    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(goal) },
            set: { goal = Int($0.rounded()) }
        )
    }

    // MARK: - Commit

    private var getStartedButton: some View {
        Button {
            // Records the amount and marks setup complete, in one call — see the type's note.
            manager.saveDailyGoal(ml: goal)
            commits += 1
        } label: {
            Text("Get Started", bundle: strings)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                // Comfortably past the 44pt floor, and a deliberate `minHeight` so the target
                // grows with Dynamic Type instead of clipping the label.
                .frame(minHeight: 56)
                .liquidGlass(in: Capsule(), density: .frosted, elevation: .raised, interactive: true)
                // The glow: three static layers drawn from the `Aurora` palette — the same
                // lights already behind the glass, so the button reads as lit *by* the backdrop
                // rather than painted on top of it.
                //
                // Three and not one because a single wide shadow renders as haze. A tight hot
                // core is what the eye reads as the source; the mid bloom carries it off the
                // edge; the wide blue layer seats it against the magenta the button happens to
                // sit on, where a lone cyan shadow measured almost invisible on device.
                //
                // Static on purpose: a breathing pulse is a perpetual animation and would owe a
                // Reduce Motion path (rule `65-accessibility`) for no gain.
                .shadow(color: Aurora.cyan.opacity(0.55), radius: 12)
                .shadow(color: Aurora.cyan.opacity(0.38), radius: 28)
                .shadow(color: Aurora.blue.opacity(0.38), radius: 46, y: 10)
        }
        .buttonStyle(PressStyle())
    }
}

// MARK: - Preview

#Preview {
    // A throwaway suite *and* an in-memory store, so previewing — and tapping Get Started in the
    // canvas — never writes into the real store or rings the real widget doorbell.
    //
    // Omitting `modelContainer:` resolves `DataManager.sharedModelContainer`, which is the live App
    // Group `WaterBuddy.store` — the same defaulted-dependency trap that once pointed all 74 tests
    // at live data (`tasks/lessons.md`). A preview reaching the real store is forbidden outright
    // (rule `50-views`).
    let defaults = UserDefaults(suiteName: "preview.waterbuddy.goalsetup")!
    defaults.removePersistentDomain(forName: "preview.waterbuddy.goalsetup")

    let manager = DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        reloadWidgets: {},
        // The production default builds a real `UNUserNotificationCenter`; a canvas rebuild must
        // not reconcile the user's actual reminders, and this screen can write water (rule
        // `85-testing`, `tasks/lessons.md`).
        rescheduleReminders: { _ in },
        // The production default reaches a real `WCSession`; same reasoning as above.
        publishWrist: { _ in }
    )

    return GoalSetupView().environment(manager)
}
