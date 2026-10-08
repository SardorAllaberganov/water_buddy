//
//  WaterBuddyWidget.swift
//  WaterBuddyWidget
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Widget

/// Today's hydration on the Home Screen, with one tap to log a serving.
///
/// A `StaticConfiguration`: there is nothing to configure *here*. The serving the button logs is
/// the middle quick-add vessel, which the user edits in the app's Settings and which reaches this
/// process through ``WaterSnapshot/serving`` — not through a compiled-in constant, and not through
/// an `AppIntentConfiguration`. The two front doors agree by reading one key rather than by
/// compiling one literal.
struct WaterBuddyWidget: Widget {

    static let kind = "WaterBuddyHydration"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: HydrationProvider()) { entry in
            HydrationView(entry: entry)
        }
        .configurationDisplayName("Hydration")
        // Both of these must be *static* strings. They are read by the system for the widget
        // gallery, not rendered by us, so WidgetKit cannot carry format arguments across that
        // boundary: interpolating anything here — by either the `LocalizedStringKey` or the `Text`
        // overload, both were tried — traps the moment `body` is evaluated, with
        // "WidgetKit/Text.swift:16: Fatal error: Formatted text for `description` is not
        // supported". That happens in the gallery on device, not only in the Xcode preview.
        //
        // So the serving is deliberately not named here. That was already true when the amount
        // was a constant two spellings could drift apart; it is more true now that the user can
        // change it, because any figure written into the gallery copy would be wrong for everyone
        // who edited theirs — and the gallery renders before a snapshot exists to ask.
        .description("Track today's hydration and log a glass without opening the app.")
        .supportedFamilies([.systemSmall, .systemMedium])
        // The system's default margins are ~16pt, which on a 158pt widget is a fifth of the
        // canvas. The glass card supplies its own inset — see `HydrationView.cardInset` — and the
        // aurora is meant to run edge to edge behind it.
        .contentMarginsDisabled()
    }
}

// MARK: - Timeline

struct HydrationEntry: TimelineEntry {
    let date: Date
    let snapshot: WaterSnapshot
}

/// Reads the shared store and schedules the one change that happens without anybody tapping:
/// midnight.
///
/// Every method here is `nonisolated` — `TimelineProvider` carries no isolation — so nothing in
/// this type may touch ``DataManager/shared``, which is `@MainActor`. It reads through
/// ``DataManager/snapshot(defaults:calendar:now:)`` instead, which is also the only way to read
/// without writing: merely *constructing* a `DataManager` materialises the goal, stamps the day,
/// can zero the total, and rings the widget doorbell — four writes from a process whose whole job
/// is to draw.
struct HydrationProvider: TimelineProvider {

    func placeholder(in context: Context) -> HydrationEntry {
        HydrationEntry(date: Date(), snapshot: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (HydrationEntry) -> Void) {
        let now = Date()
        // In the gallery there is no user data worth showing — a brand-new install would offer an
        // empty vessel as its advertisement.
        let snapshot = context.isPreview ? .sample : DataManager.snapshot(now: now)
        completion(HydrationEntry(date: now, snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HydrationEntry>) -> Void) {
        let now = Date()
        let midnight = DataManager.nextDayBoundary(after: now)
        let current = DataManager.snapshot(now: now)

        // An entry's `date` is when WidgetKit *renders* it, so a future-dated entry is a scheduled
        // visual change that costs no wake-up. The second one is the day turning over: without it
        // a widget nobody touches would still be showing yesterday's water tomorrow morning.
        let entries = [
            HydrationEntry(date: now, snapshot: current),
            HydrationEntry(date: midnight, snapshot: current.rolledOver()),
        ]

        completion(Timeline(entries: entries, policy: .after(midnight)))
    }
}

private extension WaterSnapshot {

    /// What the widget gallery and the redacted placeholder show. Past halfway, so the water has
    /// a visible surface and the readout has two digits.
    static let sample = WaterSnapshot(currentWater: 1_150, dailyGoal: DataManager.defaultDailyGoal)
}

// MARK: - Entry view

struct HydrationView: View {

    @Environment(\.strings) private var strings

    /// How far the card floats inside the widget. Small enough that the card is still the widget,
    /// wide enough that the aurora reads as a surface the card is resting *on* rather than a
    /// hairline.
    private static let cardInset: CGFloat = 10

    /// Breathing room inside the card.
    private static let cardPadding: CGFloat = 12

    let entry: HydrationEntry

    @Environment(\.widgetFamily) private var family

    /// The medium family's hero figure. Scaled, because a widget honours Dynamic Type; bounded
    /// below by the column's own `minimumScaleFactor`.
    @ScaledMetric(relativeTo: .title2) private var totalSize: CGFloat = 28

    var body: some View {
        card
            .padding(Self.cardInset)
            .containerBackground(for: .widget) { WidgetAurora() }
            // The app sets `.preferredColorScheme(.dark)` deliberately, because a preference
            // travels *up* and turns the status bar white too. A widget has no status bar and no
            // hosting controller to hear a preference, so here the value has to travel down the
            // tree instead — the exact form HomeView rejects, for the exact opposite reason.
            .environment(\.colorScheme, .dark)
            // The language travels in the snapshot, because a `TimelineProvider` reads the cache
            // and never the model (rule `40-widget`). Without it the widget would draw the
            // *device* language while the app drew the chosen one — two front doors disagreeing.
            // `serving` travels in the same snapshot for the same reason, and the midnight entry
            // carries both across via `rolledOver()`.
            .environment(\.strings, entry.snapshot.language.bundle)
            .environment(\.locale, entry.snapshot.language.locale)
    }

    @ViewBuilder
    private var card: some View {
        content
            .padding(Self.cardPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .widgetPane(in: ContainerRelativeShape(), density: .frosted, elevation: .raised)
            // Under the pane, not over it: `.background` applied *after* `.widgetPane` lands
            // beneath the glass, which is where a backdrop belongs.
            .background {
                WidgetCardBackdrop().clipShape(ContainerRelativeShape())
            }
            .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemMedium: medium
        default: small
        }
    }

    // MARK: Small

    /// The vessel and the pour button on a diagonal. They cannot stack — a 138pt card will not
    /// hold a legible vessel *and* a 44pt target beneath it — and they must not overlap, because
    /// two glass discs sharing an edge read as one dented shape rather than two controls.
    private var small: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let vessel = 2 * MiniVessel.radius(fitting: side, besides: PourButton.minimumTarget)

            ZStack {
                MiniVessel(snapshot: entry.snapshot)
                    .frame(width: vessel, height: vessel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                PourButton(shape: .circle, serving: entry.snapshot.serving)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
    }

    // MARK: Medium

    /// The vessel beside the numbers: the hero volume, the goal under it, and a full-width
    /// quick-add — the hero-figure-plus-capsule pairing the design system's own preview uses,
    /// with the vessel from `HomeView` standing in for the preview's progress bar.
    private var medium: some View {
        HStack(spacing: 16) {
            MiniVessel(snapshot: entry.snapshot)
                .aspectRatio(1, contentMode: .fit)

            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: strings.localizedString(forKey: "%1$d ml", value: nil, table: nil), entry.snapshot.currentWater))
                    .font(.system(size: totalSize, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .invalidatableContent()
                    // Both figures are already in the vessel's accessibility value, read as one
                    // sentence. Left visible to VoiceOver they become two more stops saying the
                    // same numbers, the second of which — "of 2,000 ml" — is a fragment with
                    // nothing to attach it to. Hidden individually, never on the enclosing stack:
                    // that also holds the button, and hiding it would leave the widget's only
                    // control unreachable.
                    .accessibilityHidden(true)

                // Sized off the total rather than given its own text style. `.footnote` and a
                // fixed 28pt hero are the same size at default and cross over at the accessibility
                // sizes — the annotation ends up bigger than the number it annotates. A ratio
                // cannot invert.
                Text(String(format: strings.localizedString(forKey: "of %1$d ml", value: nil, table: nil), entry.snapshot.dailyGoal))
                    .font(.system(size: totalSize * 0.46, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.85))
                    .accessibilityHidden(true)

                Spacer(minLength: 8)

                PourButton(shape: .capsule, serving: entry.snapshot.serving)
            }
            // The column is the full height of the card and the button's 44pt is not negotiable,
            // so when the numbers cannot fit — a five-digit total, a long locale, a large Dynamic
            // Type size — they shrink rather than push the button off the bottom. The cap is where
            // shrinking stops being able to save it: a widget cannot scroll or reflow, so past the
            // first accessibility size the type holds still rather than eating the control.
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Vessel

/// The app's water vessel at widget scale: the same two interfering waves, the same readability
/// scrim, the same sheer glass rim — but frozen.
///
/// A widget's view is evaluated once, encoded into a display-list archive and replayed by another
/// process. There is no clock on the other side, so `TimelineView(.animation)` has nothing to
/// drive it and the travelling phase the app uses is simply not available. A single fixed phase
/// still reads as water, because what makes the surface legible is the *interference* between the
/// two waves, not their motion.
private struct MiniVessel: View {

    @Environment(\.strings) private var strings

    /// A phase picked so both waves show a crest and a trough across the vessel's width rather
    /// than crossing zero flat in the middle.
    private static let frozenPhase = 0.6

    /// The largest vessel radius that still clears a `target`-sized circular button placed in the
    /// opposite corner of a `side`-square area.
    ///
    /// Two glass discs sharing an edge read as one dented shape rather than as two controls, so
    /// the clearance is a constraint, not a preference. With the vessel's centre at `(r, r)` and
    /// the button's at `(side - t/2, side - t/2)`, the centres are `√2·(side - t/2 - r)` apart and
    /// that has to beat `r + t/2` by the gap — which rearranges to the cap below.
    ///
    /// A flat proportion cannot do this job: 74% of the short side clears by 6pt on a 158pt
    /// widget but *overlaps* by 3pt on the 141pt one an iPhone SE-class device gets. The
    /// proportion still governs everywhere it fits.
    static func radius(fitting side: CGFloat, besides target: CGFloat, gap: CGFloat = 4) -> CGFloat {
        // Spelled out in typed steps: the one-line form of this takes the type checker past its
        // time limit.
        let root2: CGFloat = 2.0.squareRoot()
        let button: CGFloat = target / 2
        let reach: CGFloat = root2 * (side - button)
        let cap: CGFloat = (reach - button - gap) / (1 + root2)
        let proportional: CGFloat = side * 0.37
        return max(0, min(proportional, cap))
    }

    let snapshot: WaterSnapshot

    @Environment(\.widgetRenderingMode) private var renderingMode

    /// The percentage's type size at default Dynamic Type.
    ///
    /// `@ScaledMetric` resolves through `UIFontMetrics`, which rounds to the nearest third of a
    /// point — so scaling a unitless `1` quantises twelve Dynamic Type categories into three
    /// distinct sizes, and the widget would not move at all between Large and XXL. Scaling a real
    /// magnitude gives it the resolution to track the app's readout instead of stepping past it.
    @ScaledMetric(relativeTo: .largeTitle) private var readoutSize: CGFloat = 27

    var body: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)

            ZStack {
                water(diameter: diameter)
                readout(diameter: diameter)
            }
            .frame(width: diameter, height: diameter)
            .widgetPane(in: Circle(), density: .sheer, elevation: .resting)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d percent. %2$d of %3$d millilitres.", value: nil, table: nil), snapshot.percentage, snapshot.currentWater, snapshot.dailyGoal))
    }

    @ViewBuilder
    private func water(diameter: CGFloat) -> some View {
        // The app's resting amplitude is 1.8% of the diameter, which at 280pt is 5pt of surface
        // and at 92pt is 1.7 — flat. Scaled up so the surface still reads at widget size.
        let amplitude = diameter * 0.035
        let level = snapshot.progress

        if renderingMode == .fullColor {
            ZStack {
                WaterSurface(level: level, phase: Self.frozenPhase, amplitude: amplitude)
                    .clipShape(Circle())
                    // Inset so the water sits in a well and can never cover the vessel's lit rim.
                    .padding(diameter * 0.04)

                // Only as much shade as there is water to hold back. An empty vessel needs none —
                // the numerals are already white on dark glass — and a full one needs all of it.
                WaterReadabilityScrim(diameter: diameter, intensity: min(1, level * 1.6))
            }
            .widgetAccentable()
            .invalidatableContent()
        } else {
            // A tinted Home Screen throws colour away and keeps only alpha, so the water's blues
            // would come back as an even wash. One opaque wave silhouette survives the treatment
            // and still says how full the vessel is.
            WaveShape(level: level, phase: Self.frozenPhase, amplitude: amplitude, frequency: 1.1)
                .fill(.white.opacity(0.55))
                .clipShape(Circle())
                .padding(diameter * 0.04)
                .widgetAccentable()
                .invalidatableContent()
                .accessibilityHidden(true)
        }
    }

    private func readout(diameter: CGFloat) -> some View {
        // A fixed size, bounded by the vessel it has to sit inside. Both families therefore show
        // the percentage at the same size wherever the vessel is big enough to hold it — which is
        // every phone at default Dynamic Type — and only the vessel itself changes between them.
        // On the smallest widget, and at the accessibility sizes, the vessel wins and the numerals
        // give way, exactly as they do in the app.
        let size = min(readoutSize, diameter * 0.33)

        return HStack(alignment: .firstTextBaseline, spacing: 1) {
            Text(snapshot.percentage, format: .number)
                .font(.system(size: size, weight: .semibold, design: .rounded))
                .monospacedDigit()
            // Full white, where the app softens the same glyph to 0.8. That softening is safe at
            // the app's 25pt, which clears the large-text bar; at the widget's 12pt the glyph is
            // small text and needs 4.5:1, and white-at-0.8 over the bright wave fill measures
            // 3.4-3.9:1. The size difference already subordinates it without the tint.
            Text("%")
                .font(.system(size: size * 0.44, weight: .semibold, design: .rounded))
        }
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .frame(maxWidth: diameter * 0.78)
        .foregroundStyle(.white)
        // Two shadows where the app has one. The scrim behind this is radial and centred on the
        // vessel, so it is strongest under the digits and nearly gone by the time it reaches the
        // "%" out on the right — which is also the smallest glyph, and therefore the one held to
        // the 4.5:1 bar rather than 3:1. The tight second shadow is a local halo that travels with
        // whatever it lands on, and it is what carries that glyph over the line.
        .shadow(color: .black.opacity(0.3), radius: 6, y: 1)
        .shadow(color: .black.opacity(0.45), radius: 2)
        .invalidatableContent()
    }
}

// MARK: - Pour button

/// The interactive half. `Button(intent:)` is the only kind of button a widget can have: the
/// archive carries the intent, and the system runs it when the user taps.
///
/// Not `private`, for one reason: the Lock Screen widget's button reads ``minimumTarget``, so the 44pt
/// floor both widgets' buttons honour has one definition rather than two.
struct PourButton: View {

    @Environment(\.strings) private var strings

    enum Shape {
        case circle, capsule
    }

    /// Below this a target is fiddly on a Home Screen, and WidgetKit does not pad it out for you —
    /// the hit region is exactly the label's frame.
    static let minimumTarget: CGFloat = 44

    let shape: Shape

    /// The middle quick-add vessel, from `entry.snapshot` — never from a constant and never read
    /// live from the suite here.
    ///
    /// Through the snapshot for a specific reason: the face is rendered into an archive ahead of
    /// time, so a value read live at `AddWaterIntent.init()` could disagree with the number already
    /// drawn beside it. Both coming from the same snapshot means they can be stale together but
    /// never inconsistent with each other.
    let serving: Int

    var body: some View {
        // The `init(amount:)` that has existed unused since the intent was written. The button no
        // longer goes through `init()`, which compiled the constant in.
        Button(intent: AddWaterIntent(amount: serving)) {
            label
        }
        // Without this the system draws `WidgetBorderedButtonStyle`'s capsule over the glass pane.
        .buttonStyle(.plain)
        .accessibilityLabel(String(format: strings.localizedString(forKey: "Add %1$d millilitres", value: nil, table: nil), serving))
    }

    @ViewBuilder
    private var label: some View {
        switch shape {
        case .circle:
            Image(systemName: "plus")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: Self.minimumTarget, height: Self.minimumTarget)
                .widgetPane(in: Circle(), density: .frosted, elevation: .resting)
                .contentShape(Circle())

        case .capsule:
            Text(String(format: strings.localizedString(forKey: "+%1$d ml", value: nil, table: nil), serving))
                .font(.callout.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: Self.minimumTarget)
                .widgetPane(in: Capsule(), density: .frosted, elevation: .resting)
                .contentShape(Capsule())
        }
    }
}

// MARK: - Glass in a widget

private extension View {

    /// ``LiquidGlassModifier``, with the two things a widget has to do differently.
    func widgetPane<S: SwiftUI.Shape & InsettableShape>(
        in shape: S,
        density: LiquidGlass.Density,
        elevation: LiquidGlass.Elevation
    ) -> some View {
        modifier(WidgetPane(shape: shape, density: density, elevation: elevation))
    }
}

/// The glass pane, adapted for the two ways a widget is drawn.
///
/// In `.fullColor` — an ordinary Home Screen — it is the app's pane exactly, with
/// ``LiquidGlass/Base/archived`` standing in for the material because there is no live backdrop to
/// sample.
///
/// On a *tinted* Home Screen the system treats the whole widget as a template: colour is discarded
/// and only alpha survives. Every layer LiquidGlass stacks then becomes additive — including the
/// black scrim, which would brighten the pane instead of darkening it, and the shadows, which
/// would ring it in haze. What is left of glass under that treatment is its lit rim, so that is
/// all this draws.
private struct WidgetPane<S: Shape & InsettableShape>: ViewModifier {

    let shape: S
    let density: LiquidGlass.Density
    let elevation: LiquidGlass.Elevation

    @Environment(\.widgetRenderingMode) private var renderingMode

    @ViewBuilder
    func body(content: Content) -> some View {
        if renderingMode == .fullColor {
            content.liquidGlass(in: shape, base: .archived, density: density, elevation: elevation)
        } else {
            content.background {
                shape.strokeBorder(.white.opacity(0.45), lineWidth: 1)
            }
        }
    }
}

// MARK: - Backdrop

/// What the card refracts.
///
/// The card cannot sample what is behind it, so it is handed its own copy of the aurora — the same
/// three lights, pushed off-register and blurred. That offset is the whole point: an unblurred
/// backdrop shared pixel-for-pixel with the surround gives the eye nothing to tell the card from a
/// grey rectangle painted on top, whereas a version that is softer and slightly displaced reads
/// immediately as something seen *through* glass.
///
/// It is opaque, so it also covers the case where the system has stripped the container background
/// — in StandBy the card brings its own light rather than floating on bare black.
private struct WidgetCardBackdrop: View {

    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        if renderingMode == .fullColor && !reduceTransparency {
            WidgetAurora()
                // Drawn larger than the card and clipped back, for two reasons: a blur samples
                // past its own edge and would otherwise fade the corners to nothing, and the
                // resulting offset is what puts these lights out of register with the ones
                // outside the card — which is the whole refraction cue.
                .scaleEffect(1.22)
                .blur(radius: 12)
                // `.ultraThinMaterial`'s recipe boosts saturation by exactly this much before it
                // mixes toward grey. `LiquidGlass.Base.archived` reproduces the mix but cannot
                // reproduce the boost, because a flat fill has no backdrop to saturate — so it
                // is applied here, to the backdrop itself.
                .saturation(1.1)
        } else {
            Color.clear
        }
    }
}

/// The aurora, re-expressed for a 158pt canvas.
///
/// `AuroraBackground` in the app blurs three discs at absolute offsets sized for a phone screen;
/// ±240pt means nothing inside a widget. These are the same three lights at the same three hues,
/// positioned proportionally and drawn as radial gradients rather than blurred circles — the stops
/// are the numeric profile of the app's disc-plus-Gaussian, so the falloff matches without the
/// widget archive having to carry a blur filter at all.
struct WidgetAurora: View {

    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        if renderingMode == .fullColor {
            GeometryReader { proxy in
                let width = proxy.size.width

                ZStack {
                    Aurora.gradient

                    // With Reduce Transparency on, the card above is an opaque slab and the lights
                    // would only show as a rim of colour around it. The plain gradient is the
                    // calmer read.
                    if !reduceTransparency {
                        light(Aurora.blue, at: UnitPoint(x: 0.18, y: 0.10), size: width * 1.05, opacity: 0.75)
                        light(Aurora.magenta, at: UnitPoint(x: 0.86, y: 0.92), size: width * 1.00, opacity: 0.70)
                        light(Aurora.cyan, at: UnitPoint(x: 0.84, y: 0.20), size: width * 0.65, opacity: 0.38)
                    }
                }
            }
        } else {
            // Templated: a gradient collapses to a flat wash of the accent colour, so there is
            // nothing to gain and legibility to lose.
            Color.black
        }
    }

    private func light(_ color: Color, at center: UnitPoint, size: CGFloat, opacity: Double) -> some View {
        RadialGradient(
            stops: [
                .init(color: color.opacity(opacity), location: 0.00),
                .init(color: color.opacity(opacity * 0.98), location: 0.35),
                .init(color: color.opacity(opacity * 0.87), location: 0.50),
                .init(color: color.opacity(opacity * 0.57), location: 0.65),
                .init(color: color.opacity(opacity * 0.21), location: 0.80),
                .init(color: color.opacity(opacity * 0.08), location: 0.90),
                .init(color: .clear, location: 1.00),
            ],
            center: center,
            startRadius: 0,
            endRadius: size * 0.72
        )
    }
}

// MARK: - Preview

#Preview("Small", as: .systemSmall) {
    WaterBuddyWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 3_000, dailyGoal: 2_000))
}

#Preview("Medium", as: .systemMedium) {
    WaterBuddyWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 250, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000))
}
