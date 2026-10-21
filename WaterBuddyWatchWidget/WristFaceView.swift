//
//  WristFaceView.swift
//  WaterBuddyWatchWidget
//
//  The complication's three faces — circular, rectangular, corner — all display-only: a tap opens
//  the watch app. Every figure is `.privacySensitive()`, and each shape draws a quiet form when
//  watchOS redacts (spec 2026-10-20 §3.6, rule `70-privacy`).
//

import SwiftUI
import WidgetKit

/// Injects the language and the background once, above every face — a view cannot read an
/// environment value it injects itself (`tasks/lessons.md`, 2026-10-08).
struct WristFaceRoot: View {

    let entry: WristWidgetEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        WristFaceView(face: entry.face, family: family)
            // watchOS asks every widget to declare its background, as iOS does; a face draws none.
            .containerBackground(for: .widget) { Color.clear }
            .environment(\.strings, entry.language.bundle)
            .environment(\.locale, entry.language.locale)
    }
}

/// The shape for a family. Takes the family as a parameter — `widgetFamily` cannot be set — so a
/// render can draw any shape outside a face.
struct WristFaceView: View {

    let face: WristPlan.Face
    let family: WidgetFamily

    var body: some View {
        switch family {
        case .accessoryRectangular: WristFaceCard(face: face)
        case .accessoryCorner: WristFaceCorner(face: face)
        default: WristFaceRing(face: face)
        }
    }
}

// MARK: - Circle

/// Today's open ring, the drop and the percentage — unchanged to the eye.
private struct WristFaceRing: View {

    let face: WristPlan.Face

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        if redactionReasons.contains(.privacy) {
            // The quiet form: no figure and no fill — only the drop, as on the phone's Lock Screen.
            Gauge(value: 0.0) {
                EmptyView()
            } currentValueLabel: {
                Image(systemName: "drop.fill")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Aurora.blue)
            .widgetAccentable()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
        } else {
            Gauge(value: face.progress) {
                Image(systemName: "drop.fill")
            } currentValueLabel: {
                Text(face.percentage, format: .number.locale(locale))
                    .minimumScaleFactor(0.4)
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Aurora.blue)
            .widgetAccentable()
            .privacySensitive()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            .accessibilityValue(face.spokenFigures(in: strings, locale: locale))
        }
    }
}

// MARK: - Corner

/// The percentage in the corner, a curved gauge along the bezel.
private struct WristFaceCorner: View {

    let face: WristPlan.Face

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        if redactionReasons.contains(.privacy) {
            Image(systemName: "drop.fill")
                .font(.title3.weight(.semibold))
                .widgetAccentable()
                .widgetLabel {
                    // The system draws the label along the bezel; hidden here too, so it can never
                    // be a second stop beside the face's one element (rule `65-accessibility`).
                    Gauge(value: 0.0) { EmptyView() }
                        .tint(Aurora.blue)
                        .widgetAccentable()
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Today's hydration", bundle: strings))
        } else {
            // `.percent` under the injected locale: Russian writes *100 %*, so three digits are
            // checked in every language (`tasks/lessons.md`, 2026-10-08). One line, or the Russian
            // figure breaks at its space instead of shrinking.
            Text(face.percentage, format: .percent.locale(locale))
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .widgetAccentable()
                .privacySensitive()
                .widgetLabel {
                    Gauge(value: face.progress) { EmptyView() }
                        .tint(Aurora.blue)
                        .widgetAccentable()
                        .privacySensitive()
                        // Spoken by the figure's element below, as the quiet form's gauge is.
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Today's hydration", bundle: strings))
                .accessibilityValue(face.spokenFigures(in: strings, locale: locale))
        }
    }
}

// MARK: - Rectangle

/// A header — the drop, *Hydration*, the percentage — the app screen's own line, and a bar.
private struct WristFaceCard: View {

    let face: WristPlan.Face

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        let quiet = redactionReasons.contains(.privacy)

        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Label {
                    Text("Hydration", bundle: strings)
                } icon: {
                    Image(systemName: "drop.fill")
                }
                Spacer(minLength: 4)
                if !quiet {
                    Text(face.percentage, format: .percent.locale(locale))
                        .privacySensitive()
                }
            }
            .font(.headline)
            .widgetAccentable()

            // The quiet form keeps the line's height, so the bar does not move up the face. It marks
            // nothing sensitive, because it draws nothing to hide: under the privacy reason a marked
            // line is drawn as the system's grey placeholder, where the quiet form draws nothing.
            Text(quiet ? " " : face.millilitreLine(in: strings, locale: locale))
                .font(.body.weight(.semibold))
                .privacySensitive(!quiet)

            Gauge(value: quiet ? 0 : face.progress) { EmptyView() }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(Aurora.blue)
                .widgetAccentable()
                .privacySensitive(!quiet)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(quiet ? "" : face.spokenFigures(in: strings, locale: locale))
    }
}

// MARK: - Previews

#Preview("Circle", as: .accessoryCircular) {
    WaterBuddyWatchWidget()
} timeline: {
    WristWidgetEntry(date: .now, face: .sample, language: .system)
}

#Preview("Rectangle", as: .accessoryRectangular) {
    WaterBuddyWatchWidget()
} timeline: {
    WristWidgetEntry(date: .now, face: .sample, language: .system)
}

#Preview("Corner", as: .accessoryCorner) {
    WaterBuddyWatchWidget()
} timeline: {
    WristWidgetEntry(date: .now, face: .sample, language: .system)
}
