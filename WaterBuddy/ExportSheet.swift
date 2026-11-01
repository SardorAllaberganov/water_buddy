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

    var body: some View {
        ZStack {
            AuroraBackground()

            // Whole at every ordinary size, scrolling once the type outgrows the sheet
            // (rule `65-accessibility`).
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Self.gap) {
                        topBar
                        summary
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
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

    /// Sentence-length text never stands bare on the aurora (`tasks/lessons.md`, 2026-10-22): the recap's
    /// pane, for the recap's pair. One element to VoiceOver, read in the order it is drawn.
    private var summary: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Self.count(export.count, strings: strings, locale: locale))
                .font(.headline)
                .monospacedDigit()
            Text(Self.dates(first: export.first, last: export.last, locale: locale, calendar: .waterBuddyDay))
                .font(.subheadline)
            Text("Date, time and amount in millilitres, nothing else. The file leaves your phone only when you send it.", bundle: strings)
                .font(.footnote)
                .padding(.top, 8)
        }
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .combine)
    }

    /// The screen's one primary surface. Its label is the surface's colour (rule `60-design-system`).
    private var shareButton: some View {
        ShareLink(item: ServingsFile(export: export), preview: SharePreview(export.name)) {
            Label {
                Text("Share as a CSV file", bundle: strings)
            } icon: {
                Image(systemName: "square.and.arrow.up")
            }
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 56)
            .contentShape(Capsule())
            .primarySurface(in: Capsule())
        }
        .buttonStyle(PressStyle())
    }

    /// *1,204 servings*: History's strip's key, its noun's form and the figure's grouping both the app's
    /// language's (rule `50-views`).
    nonisolated static func count(_ count: Int, strings: Bundle, locale: Locale) -> String {
        strings.localized("%1$d servings", count, locale: locale)
    }

    /// First serving to last, as Foundation writes an interval in `locale`: it trims what the two ends share,
    /// and a single day is one date.
    nonisolated static func dates(first: Date, last: Date, locale: Locale, calendar: Calendar) -> String {
        (first..<last).formatted(Date.IntervalFormatStyle(date: .long, time: .omitted, locale: locale,
                                                          calendar: calendar, timeZone: calendar.timeZone))
    }

    private static let gap: CGFloat = 16
    private static let verticalInset: CGFloat = 24
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
