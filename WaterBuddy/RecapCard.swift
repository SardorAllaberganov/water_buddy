//
//  RecapCard.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 24/10/26.
//

import SwiftUI

/// A finished month in one card — the monthly recap's, drawn in its sheet and rendered as the image the
/// user may share (spec `2026-10-24-monthly-recap-design.md` §3.4).
///
/// **The card is the image**: one view from one ``MonthHistory``, so what is sent is what was seen.
///
/// **Flat, because it is rendered.** Its canvas is the theme's `gradient`, not glass, and its tiles take a
/// flat base, ``tileBase(for:)`` — History's own glass, frozen into a derived fill — because `ImageRenderer`,
/// like a widget snapshot, has no live backdrop for a `Material` to sample (rule `40-widget`'s ruling, in
/// its second case). They took the widget's ``LiquidGlass/Base/archived`` until known issue #182, and
/// read grey-brown beside the app's panes.
///
/// **No streak, no goal, no serving, no time of day.** The streak never leaves the app (rule
/// `20-state`): the sheet draws it beside the card, never on it.
///
/// **It draws itself in its sheet, and never in the image** (spec `2026-11-01-premium-look-design.md` §5). The motion is the
/// sheet's to ask for, through ``drawn`` and ``lit``, and ``Rendered`` asks for none of it, so a tap on *Share* in the first
/// second sends the whole month.
struct RecapCard: View {

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.aurora) private var aurora
    @Environment(\.theme) private var theme

    let month: MonthHistory

    /// Whether the month has drawn. **`true` unless the sheet says otherwise:** ``Rendered`` passes nothing, so the image is
    /// always the whole card.
    var drawn = true

    /// Whether the rim runs its lap. The image never does.
    var lit = false

    var body: some View {
        VStack(alignment: .leading, spacing: Self.gap) {
            header
            hero
            dots
            tiles
            if let change = month.change {
                changeLine(change)
            }
        }
        .foregroundStyle(.white)
        .padding(Self.inset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous)
                .fill(aurora.gradient)
        )
        .premiumRim(lit: lit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Monthly recap", bundle: strings))
        .accessibilityValue(spokenFigures)
    }

    /// The month's first instant, for formatting its name and nothing else (``DaySummary/date``).
    private var start: Date? {
        month.days.first?.summary.date
    }

    /// The month's name and the mark on one line where they fit, and one above the other where they do
    /// not — at the accessibility sizes one line cut both (the walk, W2). The image, rendered at the
    /// default size, always takes the line.
    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                monthName.fixedSize()
                Spacer(minLength: 8)
                mark.fixedSize()
            }
            VStack(alignment: .leading, spacing: 6) {
                monthName.fixedSize(horizontal: false, vertical: true)
                mark.fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var monthName: some View {
        if let start {
            // Small cyan text is assumed to fail until a render says otherwise
            // (`tasks/lessons.md`, 2026-10-22): measured in the walk, white if under 4.5:1.
            Text(start, format: .dateTime.month(.wide).year())
                .textCase(.uppercase)
                .font(.footnote.weight(.heavy))
                .tracking(Self.tracking)
                .foregroundStyle(aurora.accent)
        }
    }

    private var mark: some View {
        Label {
            Text("WaterBuddy", bundle: strings)
        } icon: {
            Image(systemName: "drop.fill")
        }
        .font(.caption.weight(.bold))
        .foregroundStyle(.white.opacity(Self.quiet))
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 4) {
            RollingFigure(
                start: strings.figure("%1$@/%2$@", 0, month.daysCounted, locale: locale),
                final: strings.figure("%1$@/%2$@", month.daysMet, month.daysCounted, locale: locale),
                rolled: drawn
            )
                .font(.largeTitle.weight(.heavy))
                .fontDesign(.rounded)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text("Days on goal", bundle: strings)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    /// One dot a day, in date order, rows of ``dotsPerRow`` — no weekday alignment, so no first weekday
    /// enters the image. A `Grid`, not a lazy one: `ImageRenderer` draws no lazy container.
    private var dots: some View {
        let rows = stride(from: 0, to: month.days.count, by: Self.dotsPerRow).map {
            Array(month.days[$0..<min($0 + Self.dotsPerRow, month.days.count)])
        }
        return Grid(alignment: .leading, horizontalSpacing: Self.dotGap, verticalSpacing: Self.dotGap) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    ForEach(row, id: \.summary.dayOrdinal) { day in
                        dot(for: day)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .scaleEffect(drawn ? 1 : 0)
                            .animation(drawn ? Motion.popped(at: day.summary.dayOrdinal % 100 - 1) : nil, value: drawn)
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }

    /// Met and unmet differ in shape, never in colour alone (rule `65-accessibility`).
    @ViewBuilder
    private func dot(for day: MonthHistory.Day) -> some View {
        if !day.isCounted {
            Circle().fill(.white.opacity(Self.uncountedDot))
        } else if day.isMet {
            Circle().fill(aurora.accent)
        } else {
            Circle().strokeBorder(.white.opacity(Self.unmetRing), lineWidth: Self.ringWidth)
        }
    }

    /// Offered the card's whole width; a row, or a column where a row does not fit
    /// (`tasks/lessons.md`), as `MonthFigures`' tiles are.
    private var tiles: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: Self.tileGap) { tileViews }
            VStack(spacing: Self.tileGap) { tileViews }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var tileViews: some View {
        tile(
            strings.localized("%1$@ L", HistoryView.litres(month.total, locale: locale), locale: locale),
            from: strings.localized("%1$@ L", HistoryView.litres(0, locale: locale), locale: locale),
            label: Text("This month", bundle: strings)
        )
        if let average = month.average {
            tile(
                strings.figure("%1$@ ml", average, locale: locale),
                from: strings.figure("%1$@ ml", 0, locale: locale),
                label: Text("A day, on average", bundle: strings)
            )
        }
    }

    /// The figure holds one width from the first frame (``RollingFigure``): ``tiles`` chooses a row or a column by measuring,
    /// and a roll must not flip it.
    private func tile(_ figure: String, from start: String, label: Text) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            RollingFigure(start: start, final: figure, rolled: drawn)
                .font(.title3.weight(.heavy))
                .fontDesign(.rounded)
                .monospacedDigit()
            label
                .font(.footnote)
                .foregroundStyle(.white.opacity(Self.quiet))
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: LiquidGlass.innerCornerRadius, base: Self.tileBase(for: theme), density: .sheer, elevation: .flush)
    }

    private func changeLine(_ change: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: HistoryView.changeSymbol(change))
                .font(.body.weight(.semibold))
                .foregroundStyle(aurora.accent)
            Text(HistoryView.drawnChange(change, strings: strings, locale: locale))
                .font(.subheadline.weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// The month and every figure the card draws, in millilitres — each an existing spoken key.
    private var spokenFigures: String {
        var parts: [String] = []
        if let start {
            parts.append(start.formatted(.dateTime.month(.wide).year().locale(locale)))
        }
        parts.append(strings.localized("%1$d of %2$d days on goal", month.daysMet, month.daysCounted, locale: locale))
        parts.append(strings.localized("%1$d millilitres", month.total, locale: locale))
        if let average = month.average {
            parts.append(strings.localized("Average %1$d millilitres a day", average, locale: locale))
        }
        if let change = month.change {
            parts.append(HistoryView.spokenChange(change, strings: strings, locale: locale))
        }
        return parts.joined(separator: ", ")
    }

    // MARK: - Measures — the concept board's, each pair measured off renders in the walk

    private static let gap: CGFloat = 18
    private static let inset: CGFloat = 22
    private static let tracking: CGFloat = 1.2
    private static let quiet: Double = 0.86
    private static let dotsPerRow = 10
    private static let dotGap: CGFloat = 6
    private static let uncountedDot: Double = 0.12
    private static let unmetRing: Double = 0.4
    private static let ringWidth: CGFloat = 2
    private static let tileGap: CGFloat = 10
    private static let imageMargin: CGFloat = 20

    // MARK: - The tiles' fill

    /// History's own pane — Apple's regular glass tinted the theme's `top`, a `.frosted` pane — frozen into
    /// one flat fill under the hand-made sheer stack (known issue #182, the owner's ruling; spec
    /// `2026-10-24-finish-set-a-design.md` §2.4). **Fitted per theme** on iOS 27.0 (set C, D7; `docs/DESIGN.md`):
    /// Aurora's is the fit of 2026-10-25, and every other theme wears it until its own is fitted.
    ///
    /// **Derived, never chosen.** A `.flat` base is always drawn hand-made: in the dark scheme the fill,
    /// then the black scrim at 0.16, then white at 0.05 — `out = w + (1 − w)(1 − s)(a·F + (1 − a)·B)`.
    /// Five live panes over Aurora's `gradient` on iOS 27.0, each read where its sheen is clear and over
    /// the same pixels bare, fitted one colour `F` and one opacity `a` by least squares: worst ΔE₂₀₀₀
    /// 0.26 fitted, 0.29 drawn. sRGB. Retune it only by measuring again — and if the scrim or the tint a
    /// flat base takes moves, this moves with them (`theTilesFillGivesBackTheAppsOwnGlass`).
    ///
    /// Not the tile's own `.sheer` glass: that is Apple's clear glass, untinted, which lightens every
    /// ground alike while the stack's scrim darkens in proportion — no fill in range gives it back
    /// (best 3.34).
    ///
    /// **One per theme** (set C): each fitted as Aurora's was, over the theme's own gradient on iOS 27.0
    /// (2026-11-23, `docs/DESIGN.md`, *Themes, measured*). Lagoon's red came out below zero, which a colour cannot
    /// hold: it is held at 0, and the opacity raised to 0.71 so the stack gives the glass back at both ends of the
    /// gradient — the stack's white tint alone draws more red than Lagoon's live glass shows (worst ΔE₂₀₀₀ 0.93).
    static func tileFill(for theme: AppTheme) -> (red: Double, green: Double, blue: Double, opacity: Double) {
        switch theme {
        case .aurora: (red: 0.0287, green: 0.1761, blue: 0.8521, opacity: 0.4856)   // worst ΔE₂₀₀₀ 0.26
        case .lagoon: (red: 0.0000, green: 0.2212, blue: 0.3776, opacity: 0.7100)   // 0.93, red held at 0
        case .dusk: (red: 0.2807, green: 0.0493, blue: 0.3144, opacity: 0.5232)     // 0.27
        case .midnight: (red: 0.0647, green: 0.0742, blue: 0.1464, opacity: 0.5320) // 0.31
        case .bloom: (red: 0.3301, green: 0.0399, blue: 0.2994, opacity: 0.5346)    // 0.21
        }
    }

    /// The tiles' base: ``tileFill(for:)``, and `archived`'s slab under Reduce Transparency — the one opaque
    /// colour every pane takes there, so no second literal.
    static func tileBase(for theme: AppTheme) -> LiquidGlass.Base {
        let fill = tileFill(for: theme)
        return .flat(
            translucent: Color(red: fill.red, green: fill.green, blue: fill.blue).opacity(fill.opacity),
            opaque: LiquidGlass.Base.archived(for: theme).opaqueFill(in: theme)
        )
    }
}

// MARK: - The image

extension RecapCard {

    /// The image's width in points, and its scale: 360 × 3 = 1,080 px (spec §3.4).
    nonisolated static let imageWidth: CGFloat = 360
    nonisolated static let imageScale: CGFloat = 3

    /// The card rendered as the image the user may share — in memory only: no file, no key, neither
    /// store (rule `70-privacy`). `nil` if the renderer draws nothing.
    static func image(of month: MonthHistory, strings: Bundle, locale: Locale, theme: AppTheme) -> UIImage? {
        let renderer = ImageRenderer(
            content: Rendered(month: month)
                .environment(\.strings, strings)
                .environment(\.locale, locale)
                // The theme the sender sees the card in: the picture is drawn in it too (set C).
                .environment(\.theme, theme)
        )
        renderer.scale = imageScale
        return renderer.uiImage
    }

    /// The card on its margin, at the image's width, at the default text size and in the dark
    /// appearance — what ``image(of:strings:locale:theme:)`` renders.
    struct Rendered: View {

        let month: MonthHistory

        var body: some View {
            RecapCard.framed(RecapCard(month: month))
        }
    }

    /// The ground around the card in the image: the theme's `top`, read from the environment
    /// ``image(of:strings:locale:theme:)`` injects — a view, because ``framed(_:)`` is a `static` and cannot read it.
    private struct ImageGround: View {
        @Environment(\.aurora) private var aurora

        var body: some View { aurora.top }
    }

    /// What stands around a card in the image. ``Rendered`` hands it a card that asks for no motion, and only
    /// `theImageIsNeverHalfDrawn` hands it any other.
    static func framed(_ card: RecapCard) -> some View {
        card
            .padding(imageMargin)
            .frame(width: imageWidth)
            .background(ImageGround())
            // The picture never depends on the sender's text size (spec §3.4).
            .dynamicTypeSize(.large)
            // A renderer has no hosting controller for `.preferredColorScheme` to reach — the app's
            // one use of the widget's spelling (spec §3.11).
            .environment(\.colorScheme, .dark)
    }
}

#Preview("The card, September") {
    RecapCardPreview.card
}

/// A month for the canvas, made from a few rows with no store and no `DataManager`.
private enum RecapCardPreview {

    @MainActor static var card: some View {
        let calendar = Calendar.waterBuddyDay
        let september = calendar.date(from: DateComponents(year: 2026, month: 9, day: 1, hour: 12))
        let october = calendar.date(from: DateComponents(year: 2026, month: 10, day: 22, hour: 12))
        let rows = september.map { start in
            (0..<24).compactMap { offset in
                calendar.date(byAdding: .day, value: offset, to: start).map { WaterLog(amount: 2_000 + offset * 40, timestamp: $0) }
            }
        } ?? []
        let month = october.flatMap {
            MonthHistory.make(rows: rows, month: 20260901, firstServing: september, goal: 2_500, now: $0, calendar: calendar)
        }
        return ZStack {
            AuroraBackground()
            if let month {
                RecapCard(month: month).padding(24)
            }
        }
        .environment(\.strings, AppLanguage.english.bundle)
        .environment(\.locale, AppLanguage.english.locale)
        .preferredColorScheme(.dark)
    }
}
