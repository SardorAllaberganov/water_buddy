//
//  AppIconTests.swift
//  WaterBuddyTests
//

import SwiftUI
import Testing
import UIKit
@testable import WaterBuddy

/// The icon each theme brings (spec `2026-11-22-set-c-design.md` §3.7). Not `@MainActor`: the names are plain values.
struct AppIconTests {

    @Test func auroraIsThePrimaryAndEveryOtherThemeHasItsAlternate() {
        #expect(AppTheme.aurora.iconName == nil)
        #expect(AppTheme.allCases.dropFirst().map(\.iconName) == ["AppIcon-Lagoon", "AppIcon-Dusk", "AppIcon-Midnight", "AppIcon-Bloom"])
    }

    @Test func iOSsIconNameReadsBackAsItsTheme() {
        for theme in AppTheme.allCases {
            #expect(AppTheme.icon(named: theme.iconName) == theme)
        }
        #expect(AppTheme.icon(named: "AppIcon-Unknown") == .aurora)
    }

    /// The picker draws these: a missing image draws nothing at all.
    @Test(arguments: AppTheme.allCases)
    func everyPreviewIsInTheBundle(_ theme: AppTheme) {
        #expect(UIImage(named: theme.iconPreviewName) != nil, "\(theme.iconPreviewName)")
    }

    /// A locked icon shows its lock (the final review's Important 1). Every preview draws its white drop at its centre,
    /// where a white lock measured about 1:1, and the four locked icons looked as choosable as Aurora's. Rendered locked
    /// and open, the light pixels the lock adds must make a glyph, and that glyph must hold 3:1 — a glyph's floor (rule
    /// `65-accessibility`) — against the pixels round it.
    @Test(arguments: Array(AppTheme.allCases.dropFirst()))
    @MainActor
    func aLockedIconShowsItsLock(_ theme: AppTheme) throws {
        let locked = try #require(Self.render(SettingsView.IconTile(theme: theme, selected: false, locked: true)))
        let open = try #require(Self.render(SettingsView.IconTile(theme: theme, selected: false, locked: false)))
        try #require(locked.luminance.count == open.luminance.count)

        let glyph = locked.luminance.indices.filter { locked.luminance[$0] > 0.5 && abs(locked.luminance[$0] - open.luminance[$0]) > 0.15 }
        #expect(glyph.count >= 40, "\(theme): the lock adds \(glyph.count) light pixels")
        guard !glyph.isEmpty else { return }

        // The ground round the glyph: its box, 4 px wider each way, less the glyph's own light and any clear pixel.
        let xs = glyph.map { $0 % locked.width }, ys = glyph.map { $0 / locked.width }
        let box = (x: max(0, xs.min()! - 4)...min(locked.width - 1, xs.max()! + 4),
                   y: max(0, ys.min()! - 4)...min(locked.luminance.count / locked.width - 1, ys.max()! + 4))
        let ground = box.y.flatMap { y in box.x.map { y * locked.width + $0 } }
            .filter { locked.luminance[$0] <= 0.5 && locked.alpha[$0] > 0.5 }
        #expect(!ground.isEmpty, "\(theme): the lock has no ground round it")
        guard !ground.isEmpty else { return }
        let mean = { (pixels: [Int]) in pixels.map { locked.luminance[$0] }.reduce(0, +) / Double(pixels.count) }
        let ratio = (mean(glyph) + 0.05) / (mean(ground) + 0.05)
        #expect(ratio >= 3, "\(theme): the lock reads \(ratio):1 against its ground")
    }

    /// A view rendered at 3×: each pixel's relative luminance (WCAG, from sRGB) and alpha, row by row.
    @MainActor
    private static func render(_ view: some View) -> (luminance: [Double], alpha: [Double], width: Int)? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3
        guard let image = renderer.cgImage, let space = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        let (width, height) = (image.width, image.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                                          bytesPerRow: width * 4, space: space,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }
        let linear = { (byte: UInt8) -> Double in
            let v = Double(byte) / 255
            return v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        var luminance: [Double] = [], alpha: [Double] = []
        for i in stride(from: 0, to: bytes.count, by: 4) {
            let a = Double(bytes[i + 3]) / 255
            alpha.append(a)
            // Premultiplied: a clear pixel reads black, and the alpha filter above keeps it out of a ground.
            luminance.append(0.2126 * linear(bytes[i]) + 0.7152 * linear(bytes[i + 1]) + 0.0722 * linear(bytes[i + 2]))
        }
        return (luminance, alpha, width)
    }
}
