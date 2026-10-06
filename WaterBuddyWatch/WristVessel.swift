//
//  WristVessel.swift
//  WaterBuddyWatch
//
//  The glass vessel, watch-sized. Reproduces `HomeView.swift`'s private `WaterVessel`
//  composition — glass circle, water, a readability scrim, the percentage readout — from the
//  shared primitives, since that type is app-only and cannot be imported here.
//

import SwiftUI

/// The vessel draws; it does **not** describe itself to VoiceOver.
///
/// It used to: `.accessibilityElement(children: .ignore)` plus a label and a value sat on the
/// `ZStack` below, which was correct while this was inert decoration in a `List` row. It stopped
/// being correct the moment `WristView` made the circle its pour button — rule `65-accessibility`
/// forbids exactly that wrapper *around a control*, and `HistoryView.ServingRow`'s own comment
/// records what it costs when you do it anyway: the wrapper becomes a second element above the
/// button and every item is announced twice. Only a real accessibility tree shows that; no unit
/// test in this project can see one.
///
/// So the label, the value **and** a hint naming the amount now live on the `Button` in
/// ``WristView``, which is the only place that knows there is a control here at all. The
/// consequence to keep in mind: this type is no longer self-describing, so a second caller that
/// draws it *without* wrapping it in a control has to supply its own — the `#Preview` below is
/// exactly such a caller, and is unlabelled on purpose, because a preview has no VoiceOver user.
struct WristVessel: View {
    let level: Double
    let percentage: Int
    let volume: Int
    let goal: Int
    let diameter: CGFloat

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    var body: some View {
        ZStack {
            WaterSurface(level: level, phase: 0, amplitude: diameter * 0.02)
                .clipShape(Circle())
                .padding(6)
            WaterReadabilityScrim(diameter: diameter)
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    // `HomeView`'s own spelling: formatted against the injected locale, and not a
                    // `%lld` key the build would extract for nobody to translate.
                    Text(percentage, format: .number)
                        .font(.system(size: diameter * 0.28, weight: .bold, design: .rounded))
                    Text("%")
                        .font(.system(size: diameter * 0.14, weight: .semibold, design: .rounded))
                }
                Text(Self.readout(volume: volume, goal: goal, strings: strings, locale: locale))
                    .font(.system(size: diameter * 0.09, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .foregroundStyle(.white)
        }
        .frame(width: diameter, height: diameter)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        // No accessibility modifiers here on purpose — see the type's own DocC above.
    }

    /// The derived clearance formula, `MiniVessel.radius(fitting:besides:gap:)`'s twin (rule
    /// `40-widget`) — a flat proportion of screen width would either clip against the three pour
    /// rows below it on a 41mm screen or waste space on a 49mm one.
    ///
    /// `nonisolated static` and free of any view state, exactly so `WristVesselLayoutTests` can
    /// pin it without instantiating a view at all.
    nonisolated static func diameter(fitting availableWidth: CGFloat, reserving heightForRows: CGFloat) -> CGFloat {
        max(60, availableWidth - heightForRows * 0.3)
    }

    /// The call-site-correct sizing: a circle has one dimension, and on this screen **height** is
    /// the binding constraint, not width.
    ///
    /// `diameter(fitting:reserving:)` above expresses "shrink me by how much room the rows want",
    /// which only works if the caller knows that figure. `WristView` doesn't — it draws the vessel
    /// inside a fixed-height frame and used to pass `reserving: 0`, collapsing that formula to
    /// `max(60, width)`: a ~184pt circle in a 140pt box on a 46mm watch, overflowing into the pour
    /// rows beneath it. Clamping against both dimensions is what the geometry actually requires, and
    /// it cannot be got wrong by passing the wrong number, because there is no number to pass.
    ///
    /// The 60pt floor is kept from the sibling above deliberately: below it the percentage readout
    /// and its scrim stop being legible at all, so a vessel that small is worse than a clipped one.
    nonisolated static func diameter(fitting availableWidth: CGFloat, within availableHeight: CGFloat) -> CGFloat {
        max(60, min(availableWidth, availableHeight))
    }

    /// `1 250 / 2 000 мл` — both figures grouped the way the language being drawn groups them.
    ///
    /// **Deliberately not the phone's `%1$d / %2$d ml`.** `%d` never groups, which is why the phone
    /// draws `1300 / 2000 ml` in every language (spec 2026-10-06 §8.1). The watch grouped this
    /// readout before it was ever localized, and the owner chose to keep that (§3, ruling 3): the
    /// figures are formatted first, against the locale `WristRoot` injects beside the bundle, and
    /// handed to a `%1$@ / %2$@ ml` key only the watch holds.
    ///
    /// `nonisolated static` and free of view state, so `WristViewLogicTests` can pin it.
    nonisolated static func readout(volume: Int, goal: Int, strings: Bundle, locale: Locale) -> String {
        String(
            format: strings.localizedString(forKey: "%1$@ / %2$@ ml", value: nil, table: nil),
            volume.formatted(.number.locale(locale)),
            goal.formatted(.number.locale(locale))
        )
    }
}

#Preview {
    WristVessel(level: 0.62, percentage: 62, volume: 1_240, goal: 2_000, diameter: 140)
        .background(WristAurora())
}
