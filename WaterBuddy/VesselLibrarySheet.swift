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
            HStack(spacing: 12) {
                Image(systemName: vessel.glyph.symbol)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(aurora.accent)
                    .frame(width: 28)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(vessel.name(in: strings)).font(.body.weight(.semibold)).foregroundStyle(.white)
                    if isGlass {
                        Text("Your Glass: the widget, Siri, Control Center, reminders and your watch log it", bundle: strings)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.88))
                    }
                }
                Spacer(minLength: 8)
                Text(strings.figure("%1$@ ml", vessel.amount, locale: locale))
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(vessel.name(in: strings))
        .accessibilityValue(strings.localized("%1$d millilitres", vessel.amount, locale: locale))
        .accessibilityHint(isGlass ? Text("Your Glass", bundle: strings) : Text(verbatim: ""))
        .accessibilityAddTraits(.isButton)
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
