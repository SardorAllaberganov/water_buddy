//
//  PressStyle.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftUI

/// The press response shared by every glass control in the app — a slight recoil, spring-damped.
///
/// Shared rather than duplicated so the quick-add vessels and *Get Started* answer a finger
/// identically.
/// This is not a perpetual animation: it runs only while a finger is down, so it needs no Reduce
/// Motion path (rule `65-accessibility` targets loops that never stop).
struct PressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.62), value: configuration.isPressed)
            // Hands the press down to any `liquidGlass(interactive: true)` pane inside the label,
            // so the *material* answers the finger and not only the frame. On iOS 26 and later
            // that pane is Apple's `Glass.interactive()` and reacts by itself; in any pane the
            // hand-made stack draws, this value is what brightens the tint, the rim and the
            // specular (`LiquidGlass.Interaction`).
            //
            // This style is the only thing in the app that knows a finger is down, and a label
            // cannot reach up into its own `ButtonStyle.Configuration` — so the state has to travel
            // downward, which is what the environment is for.
            .environment(\.glassIsPressed, configuration.isPressed)
    }
}
