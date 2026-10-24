//
//  RecapSheet.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 24/10/26.
//

import SwiftUI

/// The monthly recap: the month's card, its best streak beside it, and *Share as an image* (spec
/// `2026-10-24-monthly-recap-design.md` §3.3).
///
/// **The image leaves on the user's own tap, and only the card's figures go** (rule `70-privacy`). The
/// best streak is drawn here and never on the card, because the streak never leaves the app (rule
/// `20-state`). The image is rendered when the sheet appears and kept in memory — no file, no key.
///
/// **`ShareLink`, and no *Save to Photos*.** iOS offers *Save Image* only to an app that carries
/// `NSPhotoLibraryAddUsageDescription`, which this one never does — measured on iOS 27.0, 26.5 and 18.6
/// (spec §4a) — so the share sheet leaves Photos out on its own, and notifications stay the one
/// permission the app asks for. Everything else the sheet offers, *Save to Files* included, is the
/// user's own tap.
struct RecapSheet: View {

    let month: MonthHistory

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// The card, rendered — presentation state, gone with the sheet.
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            AuroraBackground()

            // Whole at every ordinary size, scrolling once the type outgrows the sheet
            // (rule `65-accessibility`).
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Self.gap) {
                        topBar
                        RecapCard(month: month)
                        streak
                        shareButton
                        footnote
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
        .task { image = RecapCard.image(of: month, strings: strings, locale: locale) }
    }

    /// The heading, on the aurora with its shadows, and the paywall's close button, labelled *Done*: this
    /// sheet makes no offer to decline.
    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Monthly recap", bundle: strings)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .legibleOnBackdrop()
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            SheetCloseButton(label: "Done")
        }
    }

    /// The month's best run — here, never on the image.
    private var streak: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text("Best streak", bundle: strings)
                Spacer(minLength: 8)
                Text(strings.localized("%1$d days", month.bestRun, locale: locale))
                    .monospacedDigit()
            }
            .font(.subheadline.weight(.bold))
            Text("Stays in the app, not on the image", bundle: strings)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.9))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .combine)
    }

    /// Sentence-length text never stands bare on the aurora (`tasks/lessons.md`, 2026-10-22): the streak
    /// pane's pair.
    private var footnote: some View {
        Text("The image leaves your phone only when you send it.", bundle: strings)
            .font(.footnote)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .liquidGlass(density: .frosted, elevation: .raised)
    }

    /// The screen's one primary surface. Its label is the surface's colour (rule `60-design-system`).
    private var shareLabel: some View {
        Label {
            Text("Share as an image", bundle: strings)
        } icon: {
            Image(systemName: "square.and.arrow.up")
        }
        .font(.headline)
        .frame(maxWidth: .infinity, minHeight: 56)
        .contentShape(Capsule())
        .primarySurface(in: Capsule())
    }

    /// Drawn, and dimmed, for the moment before the image is rendered; a `ShareLink` once it is.
    @ViewBuilder
    private var shareButton: some View {
        if let image {
            let picture = Self.sharedItem(image)
            ShareLink(
                item: picture,
                preview: SharePreview(strings.localizedString(forKey: "Monthly recap", value: nil, table: nil), image: picture)
            ) {
                shareLabel
            }
            .buttonStyle(PressStyle())
        } else {
            shareLabel
                .opacity(Self.pending)
                .accessibilityHidden(true)
        }
    }

    /// What `ShareLink` hands the share sheet for the rendered card. The sheet sends the item's exported
    /// representation, not the `UIImage` in memory, so `RecapImageTests.theSharedPictureKeepsItsPixels`
    /// reads this function's export (the final review's I1).
    static func sharedItem(_ image: UIImage) -> Image {
        Image(uiImage: image)
    }

    private static let gap: CGFloat = 16
    private static let verticalInset: CGFloat = 24
    /// The share button before its image exists — a few milliseconds, at most.
    private static let pending: Double = 0.5
}

#Preview("The recap sheet") {
    RecapSheetPreview.sheet
}

/// A month for the canvas, made from a few rows with no store and no `DataManager`.
private enum RecapSheetPreview {

    @MainActor static var sheet: some View {
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
        return Group {
            if let month {
                RecapSheet(month: month)
            }
        }
        .environment(\.strings, AppLanguage.english.bundle)
        .environment(\.locale, AppLanguage.english.locale)
    }
}
