//
//  LanguageSheet.swift
//  WaterBuddy
//

import SwiftUI

/// The languages, in a sheet from the bottom: *Follow device* and every language the app ships, each one button
/// (spec `2026-11-26-spanish-and-language-selector-design.md` §4.2).
///
/// **It opens at half the screen.** Five rows fit there at the default text size; a swipe up shows the whole list,
/// and it scrolls past that, so a language added later costs Settings nothing — the owner's reason for the sheet
/// (R2). It is the app's one sheet that opens below full height.
///
/// **A tap chooses and closes**, as a menu would (D3): the app is already in the new language when the sheet has
/// gone. The choice is one call, `manager.language = …`; the tick is the card's, which stays (``LanguageCard``).
struct LanguageSheet: View {

    /// The language chosen when the sheet opened — its `.sheet(item:)` selection (rule `50-views`). The rows read
    /// the live choice from the manager.
    let opened: AppLanguage

    /// Called on a real change, for the card's tick.
    let chose: () -> Void

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.aurora) private var aurora
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.dismiss) private var dismiss

    /// Whether the sheet has landed (``Landing``). Presentation state, gone with the sheet.
    @State private var landed = false

    var body: some View {
        ZStack {
            AuroraBackground()

            // Whole at the default size, scrolling once the list or the type outgrows the sheet
            // (rule `65-accessibility`).
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Self.gap) {
                        topBar
                        list
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
        .tracksLanding($landed)
    }

    /// The heading and the shared close button, labelled *Done*: closing chooses nothing.
    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Language", bundle: strings)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .legibleOnBackdrop()
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            SheetCloseButton(label: "Done")
        }
    }

    /// Every choice on one card, *Follow device* first, each row arriving once the sheet has landed.
    private var list: some View {
        VStack(spacing: 0) {
            ForEach(Array(AppLanguage.allCases.enumerated()), id: \.element) { index, language in
                row(language)
                    .lands(landed, order: index)
                if language != AppLanguage.allCases.last {
                    Hairline()
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        // `.frosted` and `.raised`, as the cards on Settings beneath it.
        .liquidGlass(density: .frosted, elevation: .raised)
    }

    /// The language *Follow device* draws today, named in its own script.
    private var followDeviceLine: String {
        let drawn = AppLanguage.drawnOnFollowDevice(preferredLocalizations: Bundle.main.preferredLocalizations)
        return strings.localized("Your iPhone's language: %1$@", drawn.name(in: strings), locale: locale)
    }

    /// One choice: the greeting, or *Follow device*'s glyph, then the name, then the tick.
    ///
    /// **At the accessibility sizes the tick stands on the first line**, beside the greeting or the glyph, and the
    /// name takes the row's whole width below, so no word is cut (spec §4.3). With the tick beside the name,
    /// *dispositivo* broke across two lines with a hyphen at the largest size, the glyph above it or not
    /// (2026-11-26).
    private func row(_ language: AppLanguage) -> some View {
        let isSelected = manager.language == language

        return Button {
            choose(language)
        } label: {
            Group {
                if typeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: language.greeting == nil ? 8 : 2) {
                        HStack(spacing: 12) {
                            lead(language)
                            Spacer(minLength: 8)
                            tick(isSelected)
                        }
                        words(language)
                    }
                } else {
                    HStack(spacing: 12) {
                        // The name on the greeting's baseline; the glyph centred on *Follow device*'s two lines.
                        HStack(alignment: language.greeting == nil ? .center : .firstTextBaseline, spacing: 12) {
                            lead(language)
                            words(language)
                        }
                        Spacer(minLength: 8)
                        tick(isSelected)
                    }
                }
            }
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)
            // A serving row's height, past the 44pt floor, growing with the text (rule `65-accessibility`).
            .frame(minHeight: Self.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        // Label, value and trait on the `Button` itself, never on a wrapper (rule `65-accessibility`).
        .accessibilityLabel(language.name(in: strings))
        .accessibilityValue(language == .system ? followDeviceLine : "")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    /// The greeting — its own words, untranslated, as the name is (D3a) — or *Follow device*'s glyph. Decoration to
    /// VoiceOver, which reads the name.
    @ViewBuilder
    private func lead(_ language: AppLanguage) -> some View {
        if let greeting = language.greeting {
            Text(verbatim: greeting)
                .font(.title3.weight(.bold))
                .frame(minWidth: typeSize.isAccessibilitySize ? nil : Self.greetingWidth, alignment: .leading)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "iphone")
                .font(.title3.weight(.semibold))
                .frame(minWidth: Self.glyphWidth)
                .accessibilityHidden(true)
        }
    }

    /// The language's name, and under *Follow device* the language it draws today.
    @ViewBuilder
    private func words(_ language: AppLanguage) -> some View {
        if language == .system {
            VStack(alignment: .leading, spacing: 2) {
                Text(language.name(in: strings))
                    .font(.body)
                // Full white, as Export's sheet writes its lines: an opacity here would be a contrast figure nobody
                // measured (rule `65-accessibility`).
                Text(followDeviceLine)
                    .font(.footnote)
            }
        } else {
            Text(language.name(in: strings))
                .font(.body)
        }
    }

    private func tick(_ isSelected: Bool) -> some View {
        Image(systemName: "checkmark")
            .font(.body.weight(.bold))
            // `.clear` rather than absent, so the row does not resize as the selection moves and SwiftUI animates a
            // colour instead of inserting a layer — the ruling `GlassTabBar` records for its glow.
            .foregroundStyle(isSelected ? aurora.accent : .clear)
            .shadow(color: isSelected ? aurora.accent.opacity(0.5) : .clear, radius: 8)
            .accessibilityHidden(true)
    }

    private func choose(_ language: AppLanguage) {
        if manager.language != language {
            manager.language = language
            chose()
        }
        dismiss()
    }

    private static let gap: CGFloat = 16
    private static let verticalInset: CGFloat = 24
    private static let rowHeight: CGFloat = 56
    /// Wide enough for the longest greeting at the default size, so the names stand in one column.
    private static let greetingWidth: CGFloat = 92
    private static let glyphWidth: CGFloat = 28
}
