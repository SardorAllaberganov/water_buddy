//
//  LiveWaterWidget.swift
//  WaterBuddyWidget
//

import ActivityKit
import SwiftUI
import WidgetKit

/// The extension's half of the conformance: `LiveWaterAttributes` lives in `DataManager.swift`, Foundation only, and
/// each of the two files that import ActivityKit — this one and the app's `LiveWater.swift` — declares it (rule
/// `15-project`).
extension LiveWaterAttributes: ActivityAttributes {}

/// Today on the Lock Screen and in the Dynamic Island — the extension's fifth widget (rule `40-widget`, spec
/// `2026-11-27-live-activity-design.md` §5).
///
/// **It draws the content iOS hands it, and nothing else.** No provider runs for it and nothing here reads the suite:
/// the app's `LiveWater` starts it, updates it and ends it, from the app's process alone. ActivityKit does not show this
/// process the app's activities, so a pour from a widget's button reaches it the next time the app runs.
///
/// **iOS 18 and later, as the Control Center control is** — the codebase's fourth version check (rule `15-project`).
/// Apple Watch's small layout, `supplementalActivityFamilies`, is iOS 18's, and the bundle's builder takes an `if`
/// with no `else`, so the activity could not stand below 18 without giving the watch up; Settings draws its card from
/// 18 only, and `LiveWater` reports Live Activities as not allowed below it.
@available(iOS 18.0, *)
struct LiveWaterWidget: Widget {

    /// Past its stale date — the day's end — every view draws the new day empty, as the widgets' midnight entry does
    /// (rule `30-rollover`).
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveWaterAttributes.self) { context in
            let today = context.state.snapshot(stale: context.isStale)
            LiveWaterPresentation(snapshot: today)
                .liveWaterRoot(today)
                // The aurora is drawn by the view itself, edge to edge; iOS's own tint would sit behind it.
                .activityBackgroundTint(.clear)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            let today = context.state.snapshot(stale: context.isStale)
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    LiveWaterRing(snapshot: today, diameter: 52, showsFigure: true)
                        .liveWaterRoot(today)
                        // The figures beside it speak today; a second stop saying the same would only repeat it.
                        .accessibilityHidden(true)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    LiveWaterGlassButton(snapshot: today)
                        .liveWaterRoot(today)
                }
                DynamicIslandExpandedRegion(.center) {
                    LiveWaterFigures(snapshot: today)
                        .liveWaterRoot(today)
                }
            } compactLeading: {
                // Spoken by the percentage beside it, the compact form's one element (rule `65-accessibility`).
                Image(systemName: "drop.fill")
                    .foregroundStyle(Aurora.classic.first)
                    .accessibilityHidden(true)
            } compactTrailing: {
                LiveWaterCompactFigure(snapshot: today)
                    .liveWaterRoot(today)
            } minimal: {
                LiveWaterRing(snapshot: today, diameter: 22, showsFigure: false)
                    .liveWaterRoot(today)
            }
            .keylineTint(Aurora.classic.first)
        }
        // Apple Watch's Smart Stack, where iOS puts every iPhone Live Activity by itself, gets a layout of its own
        // (spec R5): the presentation reads the family.
        .supplementalActivityFamilies([.small])
    }
}

// MARK: - The root

private extension View {

    /// What every widget injects at its root, from the content instead of a snapshot read: the dark appearance, the
    /// app's language for the strings and the figures, and its theme (rule `40-widget`).
    func liveWaterRoot(_ today: WaterSnapshot) -> some View {
        self
            .environment(\.colorScheme, .dark)
            .environment(\.strings, today.language.bundle)
            .environment(\.locale, today.language.locale)
            .environment(\.theme, today.theme)
    }
}

// MARK: - The Lock Screen, and the watch

/// The Lock Screen's view, which iOS also shows as a banner, in StandBy, in CarPlay and on the Mac — and, where the
/// activity stands on Apple Watch, its small layout.
@available(iOS 18.0, *)
private struct LiveWaterPresentation: View {
    let snapshot: WaterSnapshot
    @Environment(\.activityFamily) private var family

    var body: some View {
        switch family {
        case .small:
            LiveWaterSmall(snapshot: snapshot)
        default:
            LiveWaterLockScreen(snapshot: snapshot)
        }
    }
}

/// The ring holding the percentage, today over the goal, and the Glass's button, on the Home Screen widgets' card over
/// the theme's sky — the archived glass and the widget's aurora, flat, because an activity is drawn out of process like
/// a widget (rule `60-design-system`). **On the card, not on the bare sky** (D10): there the caption measured 3.15 to
/// 3.72:1 in four themes of five, under the 4.5:1 small text holds.
private struct LiveWaterLockScreen: View {
    let snapshot: WaterSnapshot
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        HStack(spacing: 14) {
            HStack(spacing: 14) {
                LiveWaterRing(snapshot: snapshot, diameter: 56, showsFigure: true)
                LiveWaterFigures(snapshot: snapshot)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            // The ring and the figures are one stop; the button beside them is its own (rule `65-accessibility`).
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            .accessibilityValue(redactionReasons.contains(.privacy) ? "" : snapshot.spokenFigures(in: strings, locale: locale))

            LiveWaterGlassButton(snapshot: snapshot)
        }
        .widgetCard(fillingHeight: false)
        .padding(HydrationView.cardInset)
        .background {
            WidgetAurora()
        }
    }
}

/// Apple Watch's Smart Stack: the ring, the percentage and today's total. No button — the wrist logs through the
/// watch app.
private struct LiveWaterSmall: View {
    let snapshot: WaterSnapshot
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        HStack(spacing: 10) {
            LiveWaterRing(snapshot: snapshot, diameter: 40, showsFigure: true)
            if redactionReasons.contains(.privacy) {
                Text("Hydration", bundle: strings)
                    .font(.headline)
                    .foregroundStyle(.white)
            } else {
                Text(strings.localized("%1$d ml", snapshot.currentWater, locale: locale))
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .privacySensitive()
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(redactionReasons.contains(.privacy) ? "" : snapshot.spokenFigures(in: strings, locale: locale))
    }
}

// MARK: - The parts

/// A closed ring that fills, in water's colour — the Lock Screen widget's, drawn in full colour here — with the
/// percentage inside it where there is room. Its quiet form is the drop alone.
private struct LiveWaterRing: View {
    let snapshot: WaterSnapshot
    let diameter: CGFloat
    let showsFigure: Bool
    @Environment(\.locale) private var locale
    @Environment(\.strings) private var strings
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        let line = max(diameter * 0.11, 2.5)
        ZStack {
            Circle()
                .stroke(.white.opacity(0.18), lineWidth: line)
            if redactionReasons.contains(.privacy) {
                Image(systemName: "drop.fill")
                    .font(.system(size: diameter * 0.36, weight: .semibold))
                    .foregroundStyle(Aurora.classic.first)
            } else {
                Circle()
                    .trim(from: 0, to: snapshot.progress)
                    .stroke(Aurora.classic.first, style: StrokeStyle(lineWidth: line, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .privacySensitive()
                if showsFigure {
                    Text(snapshot.percentage, format: .percent.locale(locale))
                        .font(.system(size: diameter * 0.27, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(line)
                        .privacySensitive()
                }
            }
        }
        .frame(width: diameter, height: diameter)
        // On its own in the Island's minimal form, it speaks for itself; beside the figures, the stop around both does.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(redactionReasons.contains(.privacy) ? "" : snapshot.spokenFigures(in: strings, locale: locale))
    }
}

/// *1 300 ml* over *of 2 000 ml* — the Lock Screen widget's two keys, so the two surfaces word today alike. Its quiet
/// form is *Hydration*, the widget's own name.
private struct LiveWaterFigures: View {
    let snapshot: WaterSnapshot
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        Group {
            if redactionReasons.contains(.privacy) {
                Label {
                    Text("Hydration", bundle: strings)
                } icon: {
                    Image(systemName: "drop.fill")
                }
                .font(.headline)
                .foregroundStyle(.white)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(strings.localized("%1$d ml", snapshot.currentWater, locale: locale))
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                    Text(strings.localized("of %1$d ml", snapshot.dailyGoal, locale: locale))
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.82))
                }
                .privacySensitive()
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(redactionReasons.contains(.privacy) ? "" : snapshot.spokenFigures(in: strings, locale: locale))
    }
}

/// The compact Island's percentage: the compact form's one element, the drop beside it hidden.
private struct LiveWaterCompactFigure: View {
    let snapshot: WaterSnapshot
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        Group {
            if redactionReasons.contains(.privacy) {
                Image(systemName: "drop")
                    .foregroundStyle(Aurora.classic.first)
            } else {
                Text(snapshot.percentage, format: .percent.locale(locale))
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .privacySensitive()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(redactionReasons.contains(.privacy) ? "" : snapshot.spokenFigures(in: strings, locale: locale))
    }
}

/// The one action: the Glass, logged by ``LiveActivityGlassIntent`` in the app's process. The primary surface, at the
/// 44-pt target and with no ring, as the Home Screen widget's pour button is (rule `60-design-system`); it draws the
/// Glass's glyph and speaks its amount — *Log Water* in the quiet form, where an amount is a figure too.
private struct LiveWaterGlassButton: View {
    let snapshot: WaterSnapshot
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        Button(intent: LiveActivityGlassIntent()) {
            Image(systemName: snapshot.servingGlyph)
                // A glyph inside a fixed container is sized off the container, never off a text style (rule
                // `60-design-system`).
                .font(.system(size: PourButton.minimumTarget * 0.43, weight: .semibold))
                .frame(width: PourButton.minimumTarget, height: PourButton.minimumTarget)
                .primarySurface(in: Circle(), ring: false)
                .contentShape(Circle())
        }
        // Without it the system draws its own bordered button over the surface.
        .buttonStyle(.plain)
        .accessibilityLabel(spokenLabel)
    }

    private var spokenLabel: String {
        if redactionReasons.contains(.privacy) {
            strings.localizedString(forKey: "Log Water", value: nil, table: nil)
        } else {
            strings.localized("Add %1$d millilitres", snapshot.serving, locale: locale)
        }
    }
}

// MARK: - Preview

// The views themselves, outside the activity's chrome: the activity is iOS 18's, and a preview of it would have to be
// too. Its Lock Screen and the Island's three forms are seen on the simulator (rule `40-widget`'s *Proving it*).

#Preview("Lock Screen") {
    VStack(spacing: 12) {
        ForEach([0, 1_300, 2_400], id: \.self) { water in
            let today = WaterSnapshot(currentWater: water, dailyGoal: 2_000)
            LiveWaterLockScreen(snapshot: today)
                .clipShape(RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius))
                .liveWaterRoot(today)
        }
    }
    .padding()
    .background(.black)
}

#Preview("Watch") {
    let today = WaterSnapshot(currentWater: 1_300, dailyGoal: 2_000)
    LiveWaterSmall(snapshot: today)
        .liveWaterRoot(today)
        .background(.black)
}
