//
//  HomeView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftData
import SwiftUI

struct HomeView: View {

    /// One entry in the quick-add row — a vessel the user recognises, and what it holds.
    ///
    /// **The amounts are user data now and live on the model; the names, glyphs and order stay
    /// here.** That split is what is left of the old ruling, and the half that survives is still
    /// the important half: `DataManager` is compiled into the widget extension, so anything put on
    /// it ships into a binary that mostly does not read it. Three glyph names and two localisation
    /// keys genuinely never cross, so they stayed. The three *amounts* had to, because the widget's
    /// one button now draws and logs the middle one — which is the entire point of the feature.
    ///
    /// What this type is no longer is a **menu**. ``HistoryView/servingRange`` and
    /// ``GoalSetupView/goalRange`` still are — they are what a screen *offers* — and the editor in
    /// `SettingsView` offers exactly that range. But these three numbers are now a stored
    /// preference, and rule `20-state` makes `DataManager` the only thing allowed to persist one.
    struct Serving: Identifiable, Hashable {
        /// The **untranslated key** spoken by VoiceOver; the glyph is what says "cup" on screen.
        ///
        /// A key rather than a resolved string, because `servings` is a `static let` evaluated once
        /// and the user can change the language at any time — a name resolved here would be frozen
        /// at whatever the app launched in. ``name(in:)`` resolves it at render.
        let nameKey: String
        /// Millilitres, as `Int`, like every volume in this product.
        let amount: Int
        /// An SF Symbol name. `HomeServingTests.everyServingSymbolResolves` proves it resolves,
        /// because an unknown symbol draws **nothing at all** — no glyph, no warning, no failed
        /// build, and nothing else in the gate can see it.
        let symbol: String

        func name(in bundle: Bundle) -> String {
            bundle.localizedString(forKey: nameKey, value: nameKey, table: nil)
        }

        /// The **slot**, not the amount.
        ///
        /// This was `amount`, which was safe only while the three were compile-time constants
        /// chosen to be distinct. The user can now set two vessels to the same number, and a
        /// colliding `id` in the row's `ForEach` makes SwiftUI drop or merge a row, route a tap to
        /// the wrong button and mis-target `PressStyle`'s recoil — silently, with at most a debug
        /// warning, and invisibly to every test in the gate.
        ///
        /// The slot is also what the stored triple's index means and what "the middle vessel" names
        /// for the widget, so identifying by it keeps all three in agreement.
        var id: String { nameKey }
    }

    /// The vessels the row draws: the fixed slots, wearing the user's amounts.
    ///
    /// **Takes the amounts rather than the `DataManager` that holds them**, which is what keeps it
    /// a pure function and safely `nonisolated`. Taking the model would mean reaching a
    /// `@MainActor` property from a `nonisolated` context, and the only way to do that without an
    /// `await` is `MainActor.assumeIsolated`, which *traps* when the assumption is wrong — a
    /// `precondition` in all but name, and rule `75-diagnostics` records that this codebase has
    /// zero of those. The caller is a `body`, which is already on the main actor, so it simply
    /// reads `manager.servings` and hands the array over; that read is also what registers the
    /// observation which redraws the row after an edit.
    ///
    /// `zip` truncates to the shorter side, so a mismatch between slots and amounts silently
    /// shortens the row rather than trapping — and `everySlotIsNamedAndDrawn` asserts the two
    /// counts agree so the mismatch cannot arrive unnoticed.
    nonisolated static func servings(amounts: [Int]) -> [Serving] {
        zip(vesselSlots, amounts).map { slot, amount in
            Serving(nameKey: slot.nameKey, amount: amount, symbol: slot.symbol)
        }
    }

    /// The three slots' fixed identity: what each vessel is called and what it looks like.
    ///
    /// Deliberately not the amounts — those are stored. Order is load-bearing: slot 1 is the vessel
    /// the widget draws and logs, and it is what index 1 of ``DataManager/servings`` means.
    ///
    /// `mug.fill` stands in for a drinking glass because **SF Symbols has no drinking glass.**
    /// Checked against `CoreGlyphs.bundle/name_availability.plist` rather than guessed: the entire
    /// drink set is `cup.and.saucer`, `mug`, `waterbottle`, `wineglass` and
    /// `takeoutbag.and.cup.and.straw`. `wineglass.fill` is the only other vessel-shaped candidate
    /// and it is wrong for a hydration app. What the row has to communicate is three *sizes*, and
    /// cup → mug → bottle reads as that even though the middle glyph is not literally a tumbler.
    /// `HomeServingTests.everyServingSymbolResolves` proves each one resolves, because an unknown
    /// symbol draws **nothing at all** — no glyph, no warning, no failed build.
    nonisolated static let vesselSlots: [(nameKey: String, symbol: String)] = [
        (nameKey: "Cup", symbol: "cup.and.saucer.fill"),
        (nameKey: "Glass", symbol: "mug.fill"),
        (nameKey: "Bottle", symbol: "waterbottle.fill"),
    ]

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings

    /// Bumped on every tap. Drives the haptic, so a daily rollover cannot fire one.
    @State private var pours = 0
    /// Bumped each time the goal is crossed **upward**, and used as the confetti's seed as well as
    /// its trigger — so two celebrations in one day are two different bursts, not a replay.
    @State private var goalBursts = 0
    /// When water last landed. The waves read this to slosh and settle.
    @State private var lastPour = Date.distantPast
    @ScaledMetric(relativeTo: .largeTitle) private var vesselDiameter: CGFloat = 280
    /// A real magnitude, never a unitless `1` — `@ScaledMetric` resolves through `UIFontMetrics`,
    /// which rounds to the nearest third of a point, so scaling `1` would quantise twelve
    /// categories into three (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .title3) private var scaledServingDiameter: CGFloat = 76

    var body: some View {
        ZStack {
            AuroraBackground()

            VStack(spacing: 40) {
                Spacer(minLength: 0)

                WaterVessel(
                    level: manager.progress,
                    percentage: percentage,
                    volume: manager.currentWater,
                    goal: manager.dailyGoal,
                    diameter: min(vesselDiameter, 340),
                    lastPour: lastPour
                )
                // On the vessel, not on the screen. The celebration belongs to the thing that
                // just filled up, and the two centres are not the same point — the quick-add row
                // and the bar push the vessel above the middle of the display, so a burst
                // anchored to the `ZStack` threw its confetti out of the bottom of the glass.
                // An `overlay` does not clip, so the pieces still travel past the rim.
                .overlay { ConfettiOverlay(burst: goalBursts) }

                Spacer(minLength: 0)

                quickAddRow
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)

        }
        // The dark-appearance ruling moved to `RootTabView` with the modifier itself: there is one
        // hosting controller for both tabs now, so there is one place to declare the preference.
        .sensoryFeedback(Haptics.pour, trigger: pours)
        .sensoryFeedback(trigger: hasReachedGoal) { wasReached, isReached in
            // Only on the way up — crossing back down is a new day, not an achievement.
            isReached && !wasReached ? Haptics.goalReached : nil
        }
        // Same edge, a second consumer. `sensoryFeedback`'s closure cannot mutate state, so the
        // burst counter is bumped here rather than folded into the modifier above.
        .onChange(of: hasReachedGoal) { wasReached, isReached in
            if isReached && !wasReached { goalBursts += 1 }
        }
        .onAppear { manager.refresh() }
    }

    private var percentage: Int {
        Int((manager.progressUnclamped * 100).rounded())
    }

    private var hasReachedGoal: Bool {
        manager.currentWater >= manager.dailyGoal
    }

    /// The quick-add buttons' diameter.
    ///
    /// Scaled with type, then held between the 44pt floor rule `65-accessibility` sets and a
    /// ceiling that stops one vessel filling the screen at the accessibility sizes.
    ///
    /// The ceiling is what makes the row overflow rather than each button shrinking, and
    /// ``quickAddRow`` answers that overflow by scrolling. A target is never traded away to make
    /// three of them fit.
    private var servingDiameter: CGFloat {
        min(max(scaledServingDiameter, 44), 104)
    }

    /// The three vessels, side by side under the water.
    ///
    /// **The horizontal scroll is a Dynamic Type escape hatch, not a carousel** — so it is reached
    /// through `ViewThatFits` rather than being the row itself. Three buttons fit every iPhone at
    /// the default text sizes; at the accessibility sizes the scaled buttons and their captions
    /// genuinely overflow, and scrolling is what lets them keep their full size instead of being
    /// squeezed under the 44pt floor (rule `65-accessibility`).
    ///
    /// A bare `ScrollView` was the first attempt and it is **wrong**, for a reason a green suite
    /// cannot show you: a scroll view's content aligns to its leading edge and its frame takes the
    /// full width, so at the sizes where the row fits — which is nearly always — the three vessels
    /// sat hard against the left margin with dead space to their right, out of register with the
    /// centred *Today's log* button under them. `ViewThatFits` gives the common case a plain,
    /// self-centring `HStack` and keeps the scroll for the case that actually needs it.
    ///
    /// `.scrollClipDisabled()` on the fallback is not cosmetic either. A `ScrollView` clips to its
    /// bounds and `.raised` throws a 28pt shadow at 14pt of offset — more than any sane padding
    /// would reserve — so without it every button would have its shadow sliced off square, which
    /// is the "flat pane with no sense of height" rule `60-design-system` is written against.
    private var quickAddRow: some View {
        ViewThatFits(in: .horizontal) {
            vesselRow
            ScrollView(.horizontal) {
                vesselRow
            }
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
        }
    }

    /// Factored out because ``quickAddRow`` builds it **twice** — once plain, once inside the
    /// scrolling fallback — and two copies of a row would be two places to change a spacing.
    ///
    /// **All three vessels share one density.** Two panes at the same density read as two equal
    /// choices, and they *are* three equal choices — ranking one above the others would be a claim
    /// about the user's glass that this app cannot make. (This ruling was written on the
    /// `historyButton` that the tab bar replaced, where it explained why that button was `.sheer`
    /// against the row's `.frosted`; it is kept here because the half about the row still holds.)
    private var vesselRow: some View {
        HStack(spacing: 16) {
            ForEach(Self.servings(amounts: manager.servings)) { serving in
                servingButton(serving)
            }
        }
        .padding(.vertical, 8)
    }

    /// One vessel: the glyph in the glass, the amount underneath it.
    ///
    /// The label and value go on the `Button` itself rather than on an enclosing
    /// `.accessibilityElement(children: .ignore)`. That wrapper **adds** a stop instead of
    /// replacing one when what it wraps is a control, which is how every row in `HistoryView` came
    /// to be announced twice (`tasks/lessons.md`). The caption is hidden because the label already
    /// says the amount, and the glyph is what names the vessel on screen.
    private func servingButton(_ serving: Serving) -> some View {
        VStack(spacing: 10) {
            Button {
                manager.addLog(amount: serving.amount)
                pours += 1
                lastPour = Date()
            } label: {
                Image(systemName: serving.symbol)
                    // Sized as a ratio of the circle it sits in, never with its own text style, so
                    // it cannot grow through the edge at the accessibility sizes
                    // (rule `65-accessibility`).
                    .font(.system(size: servingDiameter * 0.34, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: servingDiameter, height: servingDiameter)
                    .liquidGlass(in: Circle(), density: .frosted, elevation: .raised, interactive: true)
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel(String(format: strings.localizedString(forKey: "%1$@, add %2$d millilitres", value: nil, table: nil), serving.name(in: strings), serving.amount))

            // A glyph says which vessel; it does not say how much.
            Text(String(format: strings.localizedString(forKey: "%1$d ml", value: nil, table: nil), serving.amount))
                // Sized as a ratio of the vessel it annotates, never with its own text style
                // (rule `65-accessibility`). `.footnote` and this glyph are the same size at the
                // default and **cross over** further up, because the glyph is capped with the
                // button at 104pt while a text style is not — so from about `accessibilityLarge`
                // the caption renders visibly larger than the vessel it labels. Confirmed on the
                // simulator at `accessibility-extra-extra-extra-large`, not reasoned about.
                // A ratio cannot invert: 0.17 x 76pt is 12.9pt, which is where `.footnote` sat.
                .font(.system(size: servingDiameter * 0.17, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Vessel

private struct WaterVessel: View {

    let level: Double
    let percentage: Int
    let volume: Int
    let goal: Int
    let diameter: CGFloat
    let lastPour: Date

    @Environment(\.strings) private var strings

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var readoutSize: CGFloat = 58

    var body: some View {
        ZStack {
            water
            readabilityScrim
            readout
        }
        .frame(width: diameter, height: diameter)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d percent. %2$d of %3$d millilitres.", value: nil, table: nil), percentage, volume, goal))
    }

    // MARK: Water

    @ViewBuilder
    private var water: some View {
        if reduceMotion {
            // Reduce Motion is aimed squarely at exactly this: a loop that never stops. The
            // level still animates when it changes; only the perpetual travel is dropped.
            waves(phase: 0, slosh: 0)
        } else {
            TimelineView(.animation) { context in
                let seconds = context.date.timeIntervalSinceReferenceDate
                waves(phase: seconds * 1.1, slosh: slosh(at: context.date))
            }
        }
    }

    private func waves(phase: Double, slosh: Double) -> some View {
        WaterSurface(
            level: level,
            phase: phase,
            amplitude: diameter * 0.018 + diameter * 0.05 * slosh
        )
        .clipShape(Circle())
        // Inset so the water sits in a well and can never cover the vessel's lit rim.
        .padding(10)
        .animation(.smooth(duration: 0.9), value: level)
    }

    /// How agitated the surface is, decaying after a pour.
    private func slosh(at date: Date) -> Double {
        let elapsed = date.timeIntervalSince(lastPour)
        guard elapsed >= 0, elapsed < 5 else { return 0 }
        return exp(-elapsed * 1.5)
    }

    // MARK: Readout

    /// See ``WaterReadabilityScrim`` for why this is here rather than being tuned away.
    private var readabilityScrim: some View {
        WaterReadabilityScrim(diameter: diameter)
    }

    private var readout: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(percentage, format: .number)
                    .font(.system(size: readoutSize, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(percentage)))
                Text("%")
                    .font(.system(size: readoutSize * 0.44, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }

            Text(String(format: strings.localizedString(forKey: "%1$d / %2$d ml", value: nil, table: nil), volume, goal))
                .font(.footnote.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.85))
        }
        // At the largest accessibility sizes the scaled readout would otherwise grow straight
        // through the vessel's edge. Bound it to the circle and let it shrink instead.
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .frame(maxWidth: diameter * 0.78)
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.3), radius: 10, y: 2)
        .animation(.smooth(duration: 0.5), value: percentage)
    }
}

// MARK: - Preview

#Preview {
    // A throwaway suite *and* an in-memory store, so previewing — and tapping + in the canvas —
    // never writes into the real store.
    //
    // The container is the half that is easy to miss, and this preview was missing it: omitting
    // `modelContainer:` resolves `DataManager.sharedModelContainer`, which is the **live App Group
    // `WaterBuddy.store`**, so every canvas rebuild wrote a real 1,150 ml row into the user's own
    // data. Same defaulted-dependency trap that once pointed all 74 tests at live storage
    // (`tasks/lessons.md`), and rule `50-views` forbids it outright.
    let defaults = UserDefaults(suiteName: "preview.waterbuddy.home")!
    defaults.removePersistentDomain(forName: "preview.waterbuddy.home")

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
        rescheduleReminders: { _ in }
    )
    manager.addWater(amount: 1_150)

    return HomeView().environment(manager)
}
