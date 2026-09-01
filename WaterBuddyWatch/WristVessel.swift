//
//  WristVessel.swift
//  WaterBuddyWatch
//
//  The glass vessel, watch-sized. Reproduces `HomeView.swift`'s private `WaterVessel`
//  composition — glass circle, water, a readability scrim, the percentage readout — from the
//  shared primitives, since that type is app-only and cannot be imported here.
//

import SwiftUI

struct WristVessel: View {
    let level: Double
    let percentage: Int
    let volume: Int
    let goal: Int
    let diameter: CGFloat

    var body: some View {
        ZStack {
            WaterSurface(level: level, phase: 0, amplitude: diameter * 0.02)
                .clipShape(Circle())
                .padding(6)
            WaterReadabilityScrim(diameter: diameter)
            VStack(spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(percentage)")
                        .font(.system(size: diameter * 0.28, weight: .bold, design: .rounded))
                    Text("%")
                        .font(.system(size: diameter * 0.14, weight: .semibold, design: .rounded))
                }
                Text("\(volume) / \(goal) ml")
                    .font(.system(size: diameter * 0.09, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .foregroundStyle(.white)
        }
        .frame(width: diameter, height: diameter)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration"))
        .accessibilityValue(Text("\(percentage) percent, \(volume) of \(goal) millilitres"))
    }

    /// The derived clearance formula, `MiniVessel.radius(fitting:besides:gap:)`'s twin (rule
    /// `40-widget`) — a flat proportion of screen width would either clip against the three pour
    /// rows below it on a 41mm screen or waste space on a 49mm one.
    ///
    /// `nonisolated static` and free of any view state, exactly so `WristVesselLayoutTests` can
    /// pin it without instantiating a view at all.
    nonisolated static func diameter(fitting availableWidth: CGFloat, reserving heightForRows: CGFloat) -> CGFloat {
        max(60, availableWidth - heightForRows * 0.3)
    }
}

#Preview {
    WristVessel(level: 0.62, percentage: 62, volume: 1_240, goal: 2_000, diameter: 140)
        .background(WristAurora())
}
