//
//  VesselLibrarySheet.swift
//  WaterBuddy
//

import SwiftUI

/// *Your vessels* — Home's three and up to nine more, for Premium (spec `2026-11-22-set-c-design.md` §3.8, D15).
///
/// Every change is one call into the model and is saved as it is made; the sheet has no *Save* (rule
/// `50-views`). A vessel opens its editor, a second sheet handed the vessel through `init`. The middle Home
/// vessel is marked as the Glass every one-tap door logs, by words, never by colour alone.
struct VesselLibrarySheet: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.aurora) private var aurora
    @Environment(\.dynamicTypeSize) private var typeSize

    /// The library the row opened the sheet on (rule `50-views`). What the sheet draws is `manager.vessels`,
    /// read live, so a change made in the editor is here when it closes.
    let opened: VesselLibrary

    @State private var editing: VesselEditorSheet.Draft?
    @State private var landed = false

    var body: some View {
        let library = manager.vessels
        ZStack {
            AuroraBackground()
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Self.gap) {
                        topBar
                        section("On Home", vessels: library.home, onHome: true).lands(landed, order: 0)
                        if !library.more.isEmpty {
                            section("More vessels", vessels: library.more, onHome: false).lands(landed, order: 1)
                        }
                        add(library).lands(landed, order: 2)
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
        .tracksLanding($landed)
        .sheet(item: $editing) { VesselEditorSheet(draft: $0) }
    }

    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Your vessels", bundle: strings)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .legibleOnBackdrop()
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            SheetCloseButton(label: "Done")
        }
    }

    private func section(_ title: LocalizedStringKey, vessels: [Vessel], onHome: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title, bundle: strings)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .legibleOnBackdrop()
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: 0) {
                ForEach(Array(vessels.enumerated()), id: \.element.id) { slot, vessel in
                    row(vessel, isGlass: onHome && slot == DataManager.usualSlot)
                    if slot < vessels.count - 1 { Hairline() }
                }
            }
            .padding(.horizontal, 16)
            .liquidGlass(density: .frosted)
        }
    }

    private func row(_ vessel: Vessel, isGlass: Bool) -> some View {
        Button {
            editing = VesselEditorSheet.Draft(vessel: vessel)
        } label: {
            Group {
                // At the accessibility sizes the name takes the row's whole width and wraps between its words,
                // and the glyph and the amount stand under it: beside them the name had a third of the row, and
                // "Bottle" broke into "Bot-tle", "150 ml" into two lines, the glyph ran over the name (the final
                // review; `testTheLibrarysNamesStayWholeAtTheLargestSize`; rule `65-accessibility`). History's day
                // title and the paywall's title switch the same way.
                if typeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 4) {
                        name(of: vessel)
                        if isGlass { glassNote }
                        HStack(spacing: 12) {
                            glyph(of: vessel)
                            amount(of: vessel)
                        }
                    }
                    .padding(.vertical, 8)
                } else {
                    HStack(spacing: 12) {
                        glyph(of: vessel).frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            name(of: vessel)
                            if isGlass { glassNote }
                        }
                        Spacer(minLength: 8)
                        amount(of: vessel)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        // Label, value and hint on the `Button` itself. A wrapping `.accessibilityElement(children: .ignore)` around
        // a control adds a stop instead of replacing one: the button came back under it as "Cup, 150 ml", and each
        // vessel was a second stop (`tasks/lessons.md`, 2026-08-28).
        .accessibilityLabel(vessel.name(in: strings))
        .accessibilityValue(strings.localized("%1$d millilitres", vessel.amount, locale: locale))
        .accessibilityHint(isGlass ? Text("Your Glass", bundle: strings) : Text(verbatim: ""))
    }

    private func glyph(of vessel: Vessel) -> some View {
        Image(systemName: vessel.glyph.symbol)
            .font(.body.weight(.semibold))
            .foregroundStyle(aurora.accent)
            .accessibilityHidden(true)
    }

    private func name(of vessel: Vessel) -> some View {
        Text(vessel.name(in: strings)).font(.body.weight(.semibold)).foregroundStyle(.white)
    }

    private var glassNote: some View {
        Text("Your Glass: the widget, Siri, Control Center, reminders and your watch log it", bundle: strings)
            .font(.footnote)
            .foregroundStyle(.white.opacity(0.88))
    }

    private func amount(of vessel: Vessel) -> some View {
        Text(strings.figure("%1$@ ml", vessel.amount, locale: locale))
            .font(.body.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(.white)
    }

    private func add(_ library: VesselLibrary) -> some View {
        let full = library.more.count >= VesselLibrary.moreLimit
        return VStack(alignment: .leading, spacing: 8) {
            Button {
                editing = .new()
            } label: {
                Text("Add a vessel", bundle: strings)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .primarySurface(in: Capsule())
            }
            .buttonStyle(PressStyle())
            .disabled(full)
            .opacity(full ? 0.5 : 1)
            if full {
                Text("Twelve is the most.", bundle: strings)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.88))
                    .legibleOnBackdrop()
            }
        }
    }

    private static let gap: CGFloat = 20
    private static let verticalInset: CGFloat = 24
}
