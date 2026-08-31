//
//  Celebration.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import SwiftUI

// MARK: - One piece

/// A single scrap of confetti, as a **value**.
///
/// `Sendable` and `nonisolated`-friendly for the reason `AppTab` and `AuroraBackground.Light` are:
/// `ConfettiTests` reads these off the main actor, and a type declared inside a `View` would drag
/// the suite onto it (rule `43-concurrency`).
struct ConfettiPiece: Identifiable, Equatable, Sendable {

    let id: Int

    /// From ``Aurora``, always. Confetti is the most tempting place in the app to reach for a
    /// fistful of new colour literals (rule `60-design-system`).
    let color: Color

    /// Direction of travel, radians, in `0..<2π`.
    let angle: Double

    /// How far it flies, in points.
    let distance: CGFloat

    /// Turns, signed, over the flight.
    let spin: Double

    /// The long edge of the scrap.
    let size: CGFloat

    /// Staggered so the burst reads as a scatter rather than as one expanding ring.
    let delay: Double
}

// MARK: - The burst

/// The goal-reached burst — **a pure function of a seed**.
///
/// That purity is not tidiness, it is the only thing that makes any of this work. A view reaching
/// for `Double.random(in:)` inside its `body` would deal a *different* burst on every re-evaluation,
/// including the ones SwiftUI performs for its own reasons — so the confetti would reshuffle itself
/// mid-flight — and nothing about it could be asserted. Seeding from the burst counter instead
/// gives a layout that is stable while it flies and different the next time.
///
/// No package for this. A confetti dependency for forty lines of arithmetic is exactly what rule
/// `95-dependencies` exists to refuse.
enum Confetti {

    /// Enough to read as a celebration, few enough that the burst is not a render bill.
    static let pieceCount = 24

    /// Seconds of flight. Long enough to register, short enough to be gone before anybody wants to
    /// tap again.
    static let duration: Double = 1.8

    static func pieces(seed: Int) -> [ConfettiPiece] {
        var rng = SeededGenerator(seed)
        let palette = [Aurora.cyan, Aurora.blue, Aurora.magenta]
        let slice = (2 * Double.pi) / Double(pieceCount)

        return (0..<pieceCount).map { index in
            // Evenly spaced *then* jittered within its own slice. Even spacing alone draws a
            // firework diagram; pure randomness leaves visible gaps and clumps at this count.
            // `aBurstThrowsPiecesInEveryDirection` is what keeps the coverage honest.
            let angle = (Double(index) * slice + rng.next(in: 0...slice))
                .truncatingRemainder(dividingBy: 2 * .pi)

            return ConfettiPiece(
                id: index,
                color: palette[index % palette.count],
                angle: angle,
                distance: rng.next(in: 120...320),
                spin: rng.next(in: -2.5...2.5),
                size: rng.next(in: 9...17),
                delay: rng.next(in: 0...0.28)
            )
        }
    }
}

/// A small linear congruential generator, so a burst is reproducible from its seed.
///
/// Deliberately not `SystemRandomNumberGenerator`: the point is that the *same* seed deals the
/// *same* burst, which a system source cannot promise and a test cannot check.
private struct SeededGenerator {

    private var state: UInt64

    init(_ seed: Int) {
        state = UInt64(truncatingIfNeeded: seed) &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
    }

    /// A fresh value in `0..<1`. The shift discards the low bits, which are the weakest in an LCG.
    private mutating func next() -> Double {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Double(state >> 11) / Double(1 << 53)
    }

    mutating func next(in range: ClosedRange<Double>) -> Double {
        range.lowerBound + next() * (range.upperBound - range.lowerBound)
    }
}

// MARK: - The overlay

/// Draws a burst each time `burst` increases.
///
/// **Reduce Motion draws nothing at all**, and that is the considered answer rather than a
/// shortcut. Elsewhere in this app Reduce Motion drops *perpetual travel* and keeps the meaningful
/// change — `WaterVessel` still animates its level, it just stops the waves marching. There is no
/// equivalent middle for two dozen objects thrown across the screen: the throwing *is* the effect.
/// The moment is still marked, twice over, by ``Haptics/goalReached`` and by the vessel arriving at
/// full — neither of which is motion (rule `65-accessibility`).
struct ConfettiOverlay: View {

    /// A counter, not a `Bool`. Crossing the goal twice in one day — log, delete a serving, log
    /// again — has to deal a second burst, and a flag that is already `true` cannot say so.
    let burst: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The burst currently in flight, cleared when it lands so the pieces leave the view tree.
    @State private var inFlight: Int?

    var body: some View {
        ZStack {
            if let seed = inFlight {
                Burst(seed: seed).id(seed)
            }
        }
        // Decorative, and over the controls: neither a VoiceOver stop nor a tap target
        // (rule `65-accessibility`).
        .accessibilityHidden(true)
        .allowsHitTesting(false)
        .onChange(of: burst) { _, latest in
            guard latest > 0, !reduceMotion else { return }
            inFlight = latest

            Task {
                try? await Task.sleep(for: .seconds(Confetti.duration + 0.4))
                // Guarded: a second goal crossing during the flight owns the slot now.
                if inFlight == latest { inFlight = nil }
            }
        }
    }
}

/// One burst's worth of pieces, launched on appear.
///
/// A separate view so `.id(seed)` can rebuild it wholesale — restarting the flight is a fresh
/// `@State`, not a value to reset by hand.
private struct Burst: View {

    let seed: Int

    @State private var launched = false

    var body: some View {
        ZStack {
            ForEach(Confetti.pieces(seed: seed)) { piece in
                Capsule()
                    .fill(piece.color)
                    .frame(width: piece.size * 0.6, height: piece.size)
                    .rotationEffect(.radians(launched ? piece.spin * .pi : 0))
                    .offset(
                        x: launched ? cos(piece.angle) * piece.distance : 0,
                        // The extra fall is gravity. Without it the burst is a ring, which reads
                        // as an explosion rather than as something thrown.
                        y: launched ? sin(piece.angle) * piece.distance + 90 : 0
                    )
                    .opacity(launched ? 0 : 1)
                    .animation(
                        .easeOut(duration: Confetti.duration).delay(piece.delay),
                        value: launched
                    )
            }
        }
        .onAppear { launched = true }
    }
}

// MARK: - Preview

#Preview {
    // Glass and confetti both need something behind them; a flat background shows neither
    // (rule `60-design-system`).
    struct Harness: View {
        @State private var bursts = 1

        var body: some View {
            ZStack {
                AuroraBackground()
                ConfettiOverlay(burst: bursts)

                Button("Again") { bursts += 1 }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .frame(minHeight: 56)
                    .liquidGlass(in: Capsule(), density: .frosted, elevation: .raised)
            }
            .preferredColorScheme(.dark)
        }
    }

    return Harness()
}
