//
//  Hairline.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 01/11/26.
//

import SwiftUI

/// A one-point rule across a card. Decoration: what it separates is already separate to VoiceOver.
struct Hairline: View {

    /// The rule between a card's parts.
    private static let opacity = 0.16

    var body: some View {
        Rectangle()
            .fill(.white.opacity(Self.opacity))
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}
