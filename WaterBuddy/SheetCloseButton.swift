//
//  SheetCloseButton.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 24/10/26.
//

import SwiftUI

/// The ✕ that closes a sheet — the paywall's and the recap's, one button since known issue #183
/// (spec `2026-10-24-finish-set-a-design.md` §2.1). A helper earns its own file when a second screen
/// wants it (rule `50-views`).
///
/// **The glyph is a share of its circle, never a text style.** The circle is a fixed 44-pt target, and a
/// `.body` glyph in it grew with the text size until it outgrew the circle at the accessibility sizes
/// (set A's step 5's walk, W3; rule `65-accessibility`). At the default size the two are the same 17 pt.
struct SheetCloseButton: View {

    @Environment(\.strings) private var strings
    @Environment(\.dismiss) private var dismiss

    /// What VoiceOver calls it — *Not now* on the paywall, *Done* on the recap.
    let label: LocalizedStringKey

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: Self.size * Self.glyph, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: Self.size, height: Self.size)
                .liquidGlass(in: Circle(), density: .sheer, elevation: .resting, interactive: true)
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(Text(label, bundle: strings))
    }

    /// The circle, and the button's target: 44 pt, the floor (rule `65-accessibility`).
    static let size: CGFloat = 44

    /// The glyph's share of the circle: 17 pt in 44, `.body`'s size at the default text size.
    static let glyph: CGFloat = 17.0 / 44.0
}
