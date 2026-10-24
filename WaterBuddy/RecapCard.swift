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
/// **Flat, because it is rendered.** Its canvas is `Aurora.gradient`, not glass, and its tiles take a
/// flat base, ``tileBase`` — History's own glass, frozen into a derived fill — because `ImageRenderer`,
/// like a widget snapshot, has no live backdrop for a `Material` to sample (rule `40-widget`'s ruling, in
/// its second case). They took the widget's ``LiquidGlass/Base/archived`` until known issue #182, and
/// read grey-brown beside the app's panes.
///
/// **No streak, no goal, no serving, no time of day.** The streak never leaves the app (rule
/// `20-state`): the sheet draws it beside the card, never on it.
struct RecapCard: View {

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    let month: MonthHistory

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
                .fill(Aurora.gradient)
        )
        .premiumRim()
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
                .foregroundStyle(Aurora.cyan)
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
            Text(strings.figure("%1$@/%2$@", month.daysMet, month.daysCounted, locale: locale))
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
            Circle().fill(Aurora.cyan)
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
            label: Text("This month", bundle: strings)
        )
        if let average = month.average {
            tile(strings.figure("%1$@ ml", average, locale: locale), label: Text("A day, on average", bundle: strings))
        }
    }

    private func tile(_ figure: String, label: Text) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(figure)
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
        .liquidGlass(cornerRadius: LiquidGlass.innerCornerRadius, base: Self.tileBase, density: .sheer, elevation: .flush)
    }

    private func changeLine(_ change: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: HistoryView.changeSymbol(change))
                .font(.body.weight(.semibold))
                .foregroundStyle(Aurora.cyan)
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

    /// History's own pane — Apple's regular glass tinted `Aurora.top`, a `.frosted` pane — frozen into
    /// one flat fill under the hand-made sheer stack (known issue #182, the owner's ruling; spec
    /// `2026-10-24-finish-set-a-design.md` §2.4).
    ///
    /// **Derived, never chosen.** A `.flat` base is always drawn hand-made: in the dark scheme the fill,
    /// then the black scrim at 0.16, then white at 0.05 — `out = w + (1 − w)(1 − s)(a·F + (1 − a)·B)`.
    /// Five live panes over `Aurora.gradient` on iOS 27.0, each read where its sheen is clear and over
    /// the same pixels bare, fitted one colour `F` and one opacity `a` by least squares: worst ΔE₂₀₀₀
    /// 0.26 fitted, 0.29 drawn. sRGB. Retune it only by measuring again — and if the scrim or the tint a
    /// flat base takes moves, this moves with them (`theTilesFillGivesBackTheAppsOwnGlass`).
    ///
    /// Not the tile's own `.sheer` glass: that is Apple's clear glass, untinted, which lightens every
    /// ground alike while the stack's scrim darkens in proportion — no fill in range gives it back
    /// (best 3.34).
    static let tileFill = (red: 0.0287, green: 0.1761, blue: 0.8521, opacity: 0.4856)

    /// The tiles' base: ``tileFill``, and `archived`'s slab under Reduce Transparency — the one opaque
    /// colour every pane takes there, so no second literal.
    static let tileBase = LiquidGlass.Base.flat(
        translucent: Color(red: tileFill.red, green: tileFill.green, blue: tileFill.blue).opacity(tileFill.opacity),
        opaque: LiquidGlass.Base.archived.opaqueFill
    )
}

// MARK: - The image

extension RecapCard {

    /// The image's width in points, and its scale: 360 × 3 = 1,080 px (spec §3.4).
    nonisolated static let imageWidth: CGFloat = 360
    nonisolated static let imageScale: CGFloat = 3

    /// The card rendered as the image the user may share — in memory only: no file, no key, neither
    /// store (rule `70-privacy`). `nil` if the renderer draws nothing.
    static func image(of month: MonthHistory, strings: Bundle, locale: Locale) -> UIImage? {
        let renderer = ImageRenderer(
            content: Rendered(month: month)
                .environment(\.strings, strings)
                .environment(\.locale, locale)
        )
        renderer.scale = imageScale
        return renderer.uiImage
    }

    /// The card on its margin, at the image's width, at the default text size and in the dark
    /// appearance — what ``image(of:strings:locale:)`` renders.
    struct Rendered: View {

        let month: MonthHistory

        var body: some View {
            RecapCard(month: month)
                .padding(RecapCard.imageMargin)
                .frame(width: RecapCard.imageWidth)
                .background(Aurora.top)
                // The picture never depends on the sender's text size (spec §3.4).
                .dynamicTypeSize(.large)
                // A renderer has no hosting controller for `.preferredColorScheme` to reach — the app's
                // one use of the widget's spelling (spec §3.11).
                .environment(\.colorScheme, .dark)
        }
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
