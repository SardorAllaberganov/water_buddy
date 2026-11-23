//
//  VesselEditorSheet.swift
//  WaterBuddy
//

import SwiftUI

/// One vessel — its icon, its name, its amount — and where it stands (spec `2026-11-22-set-c-design.md` §3.8).
///
/// An existing vessel is saved as it is changed: the icon on its tap, the name on *Return* and when the sheet
/// closes, the amount when the slider lets go — one write each, never one a keystroke, since a library write rings
/// the widgets and the wrist. A new vessel is saved once, by *Add to your vessels*. A standard vessel's editor
/// offers its amount alone: its icon and name are the standard ones (D10).
struct VesselEditorSheet: View {

    struct Draft: Identifiable, Hashable {
        let id: String
        let isNew: Bool
        let isStandard: Bool
        var glyph: VesselGlyph
        /// Empty for a standard vessel, whose name is translated, never edited.
        var name: String
        var amount: Int

        static func new() -> Draft {
            Draft(id: "new", isNew: true, isStandard: false, glyph: .bottle, name: "", amount: 500)
        }

        init(vessel: Vessel) {
            self.init(id: vessel.id, isNew: false, isStandard: vessel.isStandard, glyph: vessel.glyph,
                      name: vessel.name ?? "", amount: vessel.amount)
        }

        init(id: String, isNew: Bool, isStandard: Bool, glyph: VesselGlyph, name: String, amount: Int) {
            self.id = id; self.isNew = isNew; self.isStandard = isStandard
            self.glyph = glyph; self.name = name; self.amount = amount
        }
    }

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Draft
    @State private var isDragging = false
    @State private var picks = 0
    @State private var landed = false

    init(draft: Draft) {
        _draft = State(initialValue: draft)
    }

    var body: some View {
        ZStack {
            AuroraBackground()
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        topBar
                        if !draft.isStandard {
                            glyphs.lands(landed, order: 0)
                            nameField.lands(landed, order: 1)
                        }
                        amount.lands(landed, order: 2)
                        if !draft.isNew { placement.lands(landed, order: 3) }
                        if draft.isNew { addButton.lands(landed, order: 4) }
                        if canDelete { deleteButton.lands(landed, order: 5) }
                    }
                    .padding(.horizontal, ScreenMetrics.margin)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: proxy.size.height, alignment: .top)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sensoryFeedback(Haptics.select, trigger: picks)
        .tracksLanding($landed)
        .onDisappear(perform: commitName)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Text(draft.isNew ? "New vessel" : "Edit vessel", bundle: strings)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .legibleOnBackdrop()
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            SheetCloseButton(label: "Done")
        }
    }

    private var glyphs: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 52), spacing: 8)], spacing: 8) {
            ForEach(VesselGlyph.allCases, id: \.self) { glyph in
                Button {
                    draft.glyph = glyph
                    picks += 1
                    save()
                } label: {
                    Image(systemName: glyph.symbol)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .liquidGlass(cornerRadius: LiquidGlass.innerCornerRadius, density: .sheer, interactive: true)
                        // The chosen icon wears `LiquidGlass.Selection`'s fill and rim, as every selected slot does
                        // (rule `60-design-system`); both are there at zero while it is not chosen.
                        .overlay {
                            RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous)
                                .fill(.white.opacity(draft.glyph == glyph ? LiquidGlass.Selection.fillOpacity : 0))
                                .strokeBorder(.white.opacity(draft.glyph == glyph ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
                        }
                }
                .buttonStyle(PressStyle())
                .accessibilityLabel(Text(LocalizedStringKey(glyph.spokenKey), bundle: strings))
                .accessibilityAddTraits(draft.glyph == glyph ? [.isSelected] : [])
            }
        }
    }

    private var nameField: some View {
        TextField(text: $draft.name, prompt: Text("Name", bundle: strings)) {
            Text("Name", bundle: strings)
        }
        .textInputAutocapitalization(.words)
        .submitLabel(.done)
        .onSubmit(commitName)
        .onChange(of: draft.name) { _, typed in
            if typed.count > Vessel.nameLimit { draft.name = String(typed.prefix(Vessel.nameLimit)) }
        }
        .font(.body.weight(.semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .frame(minHeight: 50)
        .liquidGlass(density: .frosted)
        .accessibilityLabel(Text("Name", bundle: strings))
    }

    private var amount: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(strings.figure("%1$@ ml", draft.amount, locale: locale))
                .font(.title3.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.white)
                .accessibilityHidden(true)
            Slider(
                value: Binding(
                    get: { Double(draft.amount) },
                    set: { draft.amount = Int($0.rounded()) }
                ),
                in: Double(VesselSliders.range.lowerBound)...Double(VesselSliders.range.upperBound),
                step: Double(VesselSliders.step)
            ) { editing in
                isDragging = editing
                if !editing { save() }
            }
            .tint(.white)
            .accessibilityLabel(draft.isStandard
                ? Text(LocalizedStringKey(draft.glyph.standardNameKey ?? "Glass"), bundle: strings)
                : Text(draft.name.isEmpty ? strings.localizedString(forKey: "Amount", value: nil, table: nil) : draft.name))
            .accessibilityValue(strings.localized("%1$d millilitres", draft.amount, locale: locale))
            .onChange(of: draft.amount) { _, _ in
                // A VoiceOver adjustment is not a drag: commit it here (rule `65-accessibility`).
                guard !isDragging else { return }
                save()
            }
        }
        .padding(16)
        .liquidGlass(density: .frosted)
    }

    /// *Put on Home* — one choice per Home slot this vessel does not already stand in.
    private var placement: some View {
        let home = manager.vessels.home
        let here = home.firstIndex { $0.id == draft.id }
        return VStack(alignment: .leading, spacing: 8) {
            Text("Put on Home", bundle: strings)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .legibleOnBackdrop()
            ForEach(home.indices.filter { $0 != here }, id: \.self) { slot in
                Button {
                    manager.putOnHome(id: draft.id, slot: slot)
                    picks += 1
                } label: {
                    Text(strings.localized("In place of %1$@", home[slot].name(in: strings), locale: locale))
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                        .padding(.horizontal, 16)
                        .liquidGlass(density: .frosted, interactive: true)
                }
                .buttonStyle(PressStyle())
            }
        }
    }

    private var addButton: some View {
        Button {
            if manager.addVessel(glyph: draft.glyph, name: draft.name, amount: draft.amount) != nil {
                dismiss()
            }
        } label: {
            Text("Add to your vessels", bundle: strings)
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 56)
                .primarySurface(in: Capsule())
        }
        .buttonStyle(PressStyle())
        .disabled(Vessel.validName(draft.name) == nil)
    }

    private var canDelete: Bool {
        !draft.isNew && !draft.isStandard && !manager.vessels.home.contains { $0.id == draft.id }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            manager.deleteVessel(id: draft.id)
            dismiss()
        } label: {
            Text("Delete", bundle: strings)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .liquidGlass(cornerRadius: LiquidGlass.cornerRadius, density: .sheer, interactive: true)
        }
        .buttonStyle(PressStyle())
    }

    /// One write for an existing vessel; nothing for a new one, which *Add to your vessels* writes once.
    private func save() {
        guard !draft.isNew else { return }
        manager.updateVessel(id: draft.id, glyph: draft.glyph,
                             name: draft.isStandard ? nil : draft.name, amount: draft.amount)
    }

    private func commitName() {
        guard !draft.isNew, !draft.isStandard, Vessel.validName(draft.name) != nil else { return }
        save()
    }
}
