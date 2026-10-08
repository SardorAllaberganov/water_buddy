//
//  LockScreenWidget.swift
//  WaterBuddyWidget
//
//  Created by Sardor Allaberganov on 08/10/26.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Widget

/// Today's hydration on the iPhone Lock Screen — a ring, a card with a pour button, or a line above
/// the clock.
///
/// **A second widget, not three more families on ``WaterBuddyWidget``.** That widget's configuration
/// is glass over an aurora with the system margins disabled, and every one of those applies to every
/// family a configuration lists. The Lock Screen wants none of them: iOS renders it in the vibrant
/// mode, which desaturates a widget into its own material, so this one is drawn from the system's
/// accessory vocabulary and keeps the system's margins.
///
/// **The same provider, deliberately.** ``HydrationProvider`` hands both widgets one snapshot, one
/// midnight and one reload, so the Lock Screen cannot disagree with the Home Screen about today.
///
/// **What it may show is a ruling** (rule `70-privacy`): the user's own figures, because the user put
/// the widget there — every one marked privacy-sensitive, so the user's own *Allow Access When Locked →
/// Lock Screen Widgets* setting hides them, as it hides a notification's preview.
///
/// Design: `docs/superpowers/specs/2026-10-08-lock-screen-widget-design.md`.
struct LockScreenWidget: Widget {

    static let kind = "WaterBuddyLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: HydrationProvider()) { entry in
            LockScreenView(entry: entry)
        }
        // The Home Screen widget's two literals, static for the reason they are static there: the
        // gallery is drawn by the system, which cannot carry a format argument (rule `40-widget`).
        // The description holds for this widget too — its rectangle logs a glass.
        .configurationDisplayName("Hydration")
        .description("Track today's hydration and log a glass without opening the app.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Entry view

/// Injects the snapshot's language and picks the shape.
///
/// **It reads no string itself, and that is why every shape is a view of its own.** A view's own
/// `@Environment` comes from *above* it, so the bundle this body injects reaches only the views below.
/// A string resolved here would come from `Bundle.main` — the device's language — while the app drew
/// the chosen one.
struct LockScreenView: View {

    let entry: HydrationEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        shape
            // The Lock Screen draws no container background, but iOS overlays a warning on any widget
            // that does not declare its background removable.
            .containerBackground(for: .widget) { Color.clear }
            // The language travels in the snapshot, as on the Home Screen (rule `40-widget`).
            .environment(\.strings, entry.snapshot.language.bundle)
            .environment(\.locale, entry.snapshot.language.locale)
    }

    @ViewBuilder
    private var shape: some View {
        switch family {
        case .accessoryRectangular: LockScreenCard(snapshot: entry.snapshot)
        case .accessoryInline: LockScreenLine(snapshot: entry.snapshot)
        default: LockScreenRing(snapshot: entry.snapshot)
        }
    }
}

// MARK: - Circle

/// A ring that fills to today's progress, with the percentage inside.
///
/// A *closed* ring that fills — `.accessoryCircularCapacity` — because it reads as the app's vessel:
/// how full, not where on a dial. The watch's complication keeps its open ring with a marker; matching
/// the two is a separate change (spec §3.1).
private struct LockScreenRing: View {

    let snapshot: WaterSnapshot

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        if redactionReasons.contains(.privacy) {
            // The quiet form: no figure and no fill — only the drop, so the widget is still
            // recognisably WaterBuddy to the person it belongs to.
            Gauge(value: 0.0) {
                EmptyView()
            } currentValueLabel: {
                Image(systemName: "drop.fill")
                    .accessibilityHidden(true)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
        } else {
            Gauge(value: snapshot.progress) {
                EmptyView()
            } currentValueLabel: {
                Text(snapshot.percentage, format: .percent.locale(locale))
                    .minimumScaleFactor(0.4)
                    // Spoken by the gauge's combined element below; hidden here too, as rule
                    // `65-accessibility` hides every figure something beside it already speaks.
                    .accessibilityHidden(true)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .privacySensitive()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            .accessibilityValue(snapshot.spokenFigures(in: strings))
        }
    }
}

// MARK: - Rectangle

/// Today's millilitres, the goal under them, a bar that fills — and the pour button.
private struct LockScreenCard: View {

    let snapshot: WaterSnapshot

    @Environment(\.strings) private var strings
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        HStack(spacing: 8) {
            figures
                .frame(maxWidth: .infinity, alignment: .leading)

            LockScreenPourButton(serving: snapshot.serving)
        }
    }

    @ViewBuilder
    private var figures: some View {
        if redactionReasons.contains(.privacy) {
            VStack(alignment: .leading, spacing: 4) {
                // *Hydration*, the widget's own name: in Russian *Today's hydration* is 24 characters.
                Label {
                    Text("Hydration", bundle: strings)
                } icon: {
                    Image(systemName: "drop.fill")
                }
                .font(.headline)
                .accessibilityHidden(true)

                Gauge(value: 0.0) {
                    EmptyView()
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .accessibilityHidden(true)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
        } else {
            VStack(alignment: .leading, spacing: 2) {
                // The medium Home Screen widget's own two keys, so the two surfaces word today alike.
                // Each hidden individually, as the medium family hides its own (rule
                // `65-accessibility`): the column's combined element below speaks them.
                Text(String(format: strings.localizedString(forKey: "%1$d ml", value: nil, table: nil), snapshot.currentWater))
                    .font(.headline)
                    .accessibilityHidden(true)

                Text(String(format: strings.localizedString(forKey: "of %1$d ml", value: nil, table: nil), snapshot.dailyGoal))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                Gauge(value: snapshot.progress) {
                    EmptyView()
                }
                .gaugeStyle(.accessoryLinearCapacity)
                .accessibilityHidden(true)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            // The figures the button beside them changes: marked, so a tap shows at once that it
            // registered rather than leaving a stale total looking current until the reload — and a
            // second tap logging a second Glass (rule `40-widget`).
            .invalidatableContent()
            .privacySensitive()
            // One stop for the figures, in the vessel's own sentence. The button beside this column is
            // its own element — the stack does not contain it, so `.ignore` hides no control
            // (rule `65-accessibility`).
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            .accessibilityValue(snapshot.spokenFigures(in: strings))
        }
    }
}

// MARK: - Line

/// A drop and the percentage, beside the date above the clock.
///
/// iOS draws an inline widget in its own font and colour, and the whole line is one tap target that
/// opens the app — so it carries no button.
private struct LockScreenLine: View {

    let snapshot: WaterSnapshot

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        if redactionReasons.contains(.privacy) {
            // *Hydration*, not *Today's hydration*: this line shares its width with the date.
            Label {
                Text("Hydration", bundle: strings)
            } icon: {
                Image(systemName: "drop.fill")
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
        } else {
            Label {
                Text(snapshot.percentage, format: .percent.locale(locale))
            } icon: {
                Image(systemName: "drop.fill")
            }
            .privacySensitive()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            .accessibilityValue(snapshot.spokenFigures(in: strings))
        }
    }
}

// MARK: - Pour button

/// The rectangle's one control: logs the Glass, as the Home Screen widget's button does.
///
/// While the phone is locked iOS holds the tap until the owner authenticates — on a locked device
/// "buttons and toggles are inactive" — so a stranger cannot log water on it, and with Face ID the
/// owner has usually authenticated by the time they look.
private struct LockScreenPourButton: View {

    /// The middle quick-add vessel, from the same snapshot as every figure beside it — never read live
    /// (rule `40-widget`).
    let serving: Int

    @Environment(\.strings) private var strings
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        Button(intent: AddWaterIntent(amount: serving)) {
            Image(systemName: "plus")
                // The Home Screen button's 19pt, as a ratio of the disc it sits in: a glyph inside a
                // fixed container is sized off the container, never off a text style
                // (rule `60-design-system`).
                .font(.system(size: PourButton.minimumTarget * 0.43, weight: .semibold))
                .frame(width: PourButton.minimumTarget, height: PourButton.minimumTarget)
                .background {
                    // The system's own Lock Screen backing — black in the vibrant mode, which reads as
                    // a dim, fully blurred disc. `PourButton`'s tinted fallback would draw a white rim
                    // at 0.45 opacity, the transparent colour this mode advises against.
                    AccessoryWidgetBackground()
                        .clipShape(Circle())
                }
                .contentShape(Circle())
        }
        // Without it the system draws its own bordered button over the backing.
        .buttonStyle(.plain)
        .accessibilityLabel(spokenLabel)
    }

    /// What VoiceOver calls the button. A serving size is a figure too, so the quiet form says only what
    /// the button does — the intent's own title, already translated in this catalogue.
    private var spokenLabel: String {
        if redactionReasons.contains(.privacy) {
            strings.localizedString(forKey: "Log Water", value: nil, table: nil)
        } else {
            String(format: strings.localizedString(forKey: "Add %1$d millilitres", value: nil, table: nil), serving)
        }
    }
}

// MARK: - Speech

private extension WaterSnapshot {

    /// The Home Screen vessel's own sentence — the percentage and both volumes — so VoiceOver says the
    /// same thing about today on either screen.
    func spokenFigures(in strings: Bundle) -> String {
        String(format: strings.localizedString(forKey: "%1$d percent. %2$d of %3$d millilitres.", value: nil, table: nil), percentage, currentWater, dailyGoal)
    }
}

// MARK: - Preview

#Preview("Circle", as: .accessoryCircular) {
    LockScreenWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 3_000, dailyGoal: 2_000))
}

#Preview("Rectangle", as: .accessoryRectangular) {
    LockScreenWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 3_000, dailyGoal: 2_000))
}

#Preview("Line", as: .accessoryInline) {
    LockScreenWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 3_000, dailyGoal: 2_000))
}

/// The quiet forms — what each shape draws once the user has turned off *Lock Screen Widgets* under
/// *Allow Access When Locked*. Drawn outside a widget, so the sizes are approximate.
#Preview("Quiet forms") {
    let snapshot = WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000)

    VStack(spacing: 24) {
        LockScreenRing(snapshot: snapshot)
        LockScreenCard(snapshot: snapshot)
        LockScreenLine(snapshot: snapshot)
    }
    .padding()
    .redacted(reason: .privacy)
}
