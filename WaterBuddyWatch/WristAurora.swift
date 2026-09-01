//
//  WristAurora.swift
//  WaterBuddyWatch
//
//  `WidgetAurora`'s twin, for the same reason: a watch face is a small, fixed canvas with no
//  wallpaper to sample, so this uses `Aurora`'s **colours** with proportional `UnitPoint` geometry,
//  never `AuroraBackground`'s absolute phone-screen offsets (rule `60-design-system`).
//

import SwiftUI

struct WristAurora: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Aurora.gradient

                // `WidgetAurora`'s own precedent (rule `65-accessibility`): with Reduce Transparency
                // on, three blurred discs behind an already-flat pane are a coloured smear with no
                // legibility benefit — the plain gradient alone is the calmer, higher-contrast read.
                // `WristAurora` is this file's declared twin of `WidgetAurora`, so it owes the same
                // branch, and had none until this fix — the gap this codebase's own accessibility
                // rule exists to catch.
                if !reduceTransparency {
                    blob(at: UnitPoint(x: 0.2, y: 0.15), color: Aurora.blue, in: proxy.size)
                    blob(at: UnitPoint(x: 0.85, y: 0.25), color: Aurora.magenta, in: proxy.size)
                    blob(at: UnitPoint(x: 0.5, y: 0.9), color: Aurora.cyan, in: proxy.size)
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func blob(at point: UnitPoint, color: Color, in size: CGSize) -> some View {
        Circle()
            .fill(color.opacity(0.55))
            .frame(width: size.width * 0.9, height: size.width * 0.9)
            .blur(radius: size.width * 0.35)
            .position(x: size.width * point.x, y: size.height * point.y)
    }
}

#Preview {
    WristAurora()
}
