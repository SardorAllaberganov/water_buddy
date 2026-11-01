//
//  ExportSheet.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import CoreTransferable
import SwiftUI
import UniformTypeIdentifiers

/// The export: how many servings, which dates, what the file holds, and *Share as a CSV file* (spec
/// `2026-11-01-export-design.md`; rule `70-privacy`'s *The export file*).
///
/// **It shows what will leave before it leaves.** The file is every serving and its minute, the most this app
/// ever hands over, so its summary stands between the tap and the share sheet. The file was read once, on the
/// card's tap, and is handed here whole: the sheet opens only when there is one, so it has no empty state.
struct ExportSheet: View {

    let export: ServingsExport

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Bumped by the share button's press, for its haptic alone (rule `60-design-system`).
    @State private var shares = 0

    /// Whether the sheet has landed (``Landing``). Presentation state, gone with the sheet.
    @State private var landed = false

    /// The share glyph's one bounce: after the rows, so the eye ends on the action. Held down under Reduce Motion.
    @State private var settled = false

    /// A real magnitude, capped at its use site (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .largeTitle) private var figureSize: CGFloat = 52

    var body: some View {
        ZStack {
            AuroraBackground()

            // Whole at every ordinary size, scrolling once the type outgrows the sheet
            // (rule `65-accessibility`).
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Self.gap) {
                        topBar
                        fileCard
                        // At the foot of the sheet, where the thumb is. At the accessibility sizes the column outgrows the
                        // sheet, and it is scrolled to.
                        Spacer(minLength: Self.gap)
                        shareButton
                    }
                    .padding(.horizontal, ScreenMetrics.margin)
                    .padding(.vertical, Self.verticalInset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: proxy.size.height, alignment: .top)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sensoryFeedback(Haptics.confirm, trigger: shares)
        .tracksLanding($landed)
        .task(id: landed) {
            guard landed, !reduceMotion else { return }
            do { try await Task.sleep(for: .seconds(Landing.longestDelay + Motion.landResponse)) } catch { return }
            guard !Task.isCancelled else { return }
            settled = true
        }
    }

    /// The heading, on the aurora with its shadows, and the shared close button, labelled *Done*: this sheet
    /// makes no offer to decline.
    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Export your servings", bundle: strings)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .legibleOnBackdrop()
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            SheetCloseButton(label: "Done")
        }
    }

    /// The figure, the file and the note, on one card: sentence-length text never stands bare on the aurora
    /// (`tasks/lessons.md`, 2026-10-22). One element to VoiceOver, which reads the real count from the first frame.
    private var fileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                RollingFigure(start: Self.zero(locale: locale), final: export.count.formatted(.number.locale(locale)), rolled: landed)
                    .font(.system(size: min(figureSize, Self.figureCeiling), weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("Servings in this file", bundle: strings)
                    .font(.headline)
                Text(Self.dates(first: export.first, last: export.last, locale: locale, calendar: .waterBuddyDay))
                    .font(.subheadline)
            }
            Hairline()
            file
            Hairline()
            Text(note)
                .font(.footnote)
        }
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .premiumRim(lit: landed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken)
    }

    /// The file's name and its own first lines, commas in, in English in every language: that is what the file holds. Capped:
    /// a line of a file cannot wrap and stay a line of a file, and everything here is spoken in the card's label.
    private var file: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label {
                Text(verbatim: export.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
            } icon: {
                Image(systemName: "doc.text")
            }
            .font(.subheadline.weight(.semibold))
            .padding(.bottom, 4)

            ForEach(Array(export.preview.enumerated()), id: \.offset) { index, line in
                Text(verbatim: line)
                    .font(.system(.footnote, design: .monospaced))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .lands(landed, order: index)
            }
            if export.moreServings > 0 {
                Text(Self.more(export.moreServings, strings: strings, locale: locale))
                    .font(.footnote.weight(.semibold))
                    .lands(landed, order: export.preview.count)
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private var note: String {
        strings.localizedString(
            forKey: "Date, time and amount in millilitres, nothing else. The file leaves your phone only when you send it.",
            value: nil, table: nil
        )
    }

    /// What the card speaks: the count with its noun, the dates, the name and the note.
    private var spoken: String {
        [
            Self.count(export.count, strings: strings, locale: locale),
            Self.dates(first: export.first, last: export.last, locale: locale, calendar: .waterBuddyDay),
            export.name,
            note
        ].joined(separator: ", ")
    }

    /// The screen's one primary surface. Its label is the surface's colour (rule `60-design-system`).
    private var shareButton: some View {
        ShareLink(item: ServingsFile(export: export), preview: SharePreview(export.name)) {
            Label {
                Text("Share as a CSV file", bundle: strings)
            } icon: {
                Image(systemName: "square.and.arrow.up")
                    .symbolEffect(.bounce, value: settled)
            }
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 56)
            .contentShape(Capsule())
            .primarySurface(in: Capsule())
        }
        .buttonStyle(PressStyle())
        // A press, not a share: `ShareLink` reports nothing, and rule `70-privacy` forbids asking. Presentation state, gone
        // with the sheet.
        .simultaneousGesture(TapGesture().onEnded { shares += 1 })
    }

    /// *1,204 servings*: History's strip's key, its noun's form and the figure's grouping both the app's
    /// language's (rule `50-views`).
    nonisolated static func count(_ count: Int, strings: Bundle, locale: Locale) -> String {
        strings.localized("%1$d servings", count, locale: locale)
    }

    /// *and 1,199 more*, its figure grouped the app's language's way (rule `50-views`).
    nonisolated static func more(_ count: Int, strings: Bundle, locale: Locale) -> String {
        strings.localized("and %1$d more", count, locale: locale)
    }

    /// Where the figure rolls from, in the app's own digits.
    nonisolated private static func zero(locale: Locale) -> String {
        0.formatted(.number.locale(locale))
    }

    /// First serving to last, as Foundation writes an interval in `locale`: it trims what the two ends share,
    /// and a single day is one date.
    nonisolated static func dates(first: Date, last: Date, locale: Locale, calendar: Calendar) -> String {
        (first..<last).formatted(Date.IntervalFormatStyle(date: .long, time: .omitted, locale: locale,
                                                          calendar: calendar, timeZone: calendar.timeZone))
    }

    private static let gap: CGFloat = 16
    private static let verticalInset: CGFloat = 24
    private static let figureCeiling: CGFloat = 76
}

/// What `ShareLink` hands the share sheet: the file's bytes, in memory, under its own name. A
/// `DataRepresentation`, so the app writes no file and no whole history waits in a temporary folder (D8).
/// At file scope and `nonisolated`, as a value a suite off the main actor reads (rule `43-concurrency`).
nonisolated struct ServingsFile: Transferable, Sendable {

    let export: ServingsExport

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { $0.export.data }
            .suggestedFileName { $0.export.name }
    }
}

#Preview("The export sheet") {
    let calendar = Calendar.waterBuddyDay
    let today = calendar.startOfDay(for: .now)
    let rows = (0..<40).compactMap { offset in
        calendar.date(byAdding: .day, value: -offset, to: today).map { ServingsExport.Serving(amount: 250, timestamp: $0) }
    }
    return Group {
        if case .file(let export) = ServingsExport.outcome(of: rows, today: today, calendar: calendar) {
            ExportSheet(export: export)
        }
    }
    .environment(\.strings, AppLanguage.english.bundle)
    .environment(\.locale, AppLanguage.english.locale)
}
