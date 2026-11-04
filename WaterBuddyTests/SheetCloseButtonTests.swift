//
//  SheetCloseButtonTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 24/10/26.
//

import SwiftUI
import Testing
@testable import WaterBuddy

/// The sheets' ✕ — the paywall's and the recap's (known issue #183, spec
/// `2026-10-24-finish-set-a-design.md` §2.1).
@MainActor
struct SheetCloseButtonTests {

    /// At the accessibility sizes a glyph set in a text style outgrew its fixed circle. Sized as a share
    /// of the circle, it draws the same pixels at every text size.
    ///
    /// **Rendered with Reduce Transparency on.** Below iOS 26 the pane is the hand-made stack over a
    /// `Material`, which an `ImageRenderer` cannot draw — rule `40-widget`'s reason for `Base.archived`.
    /// On iOS 18.6 it came back a grey of another shade on every render, some 13,400 pixels apart at one
    /// text size, while the ✕ itself never moved (known issue #221). Under Reduce Transparency the pane is
    /// its opaque fill, the same on every system, and the whole button is still what is drawn.
    @Test func theGlyphDoesNotGrowWithTheTextSize() throws {
        let plain = try #require(Self.render(at: .large))
        let again = try #require(Self.render(at: .large))
        let huge = try #require(Self.render(at: .accessibility5))
        let brightest = try #require(Self.brightestAtTheCentre(of: plain))
        #expect(brightest > 0.9, "no white ✕ was drawn, so the comparison below would prove nothing")
        #expect(plain.pngData() == again.pngData(), "two renders at one text size differ, so the comparison below would prove nothing")
        #expect(plain.pngData() == huge.pngData(), "the ✕ drew differently at the largest text size")
    }

    private static func render(at size: DynamicTypeSize) -> UIImage? {
        let renderer = ImageRenderer(content: SheetCloseButton(label: "Not now")
            .environment(\.strings, AppLanguage.english.bundle)
            .environment(\.dynamicTypeSize, size)
            // SwiftUI's own setter for what `accessibilityReduceTransparency` reads.
            .environment(\._accessibilityReduceTransparency, true)
            .padding(8)
            .background(Aurora.top))
        renderer.scale = 3
        return renderer.uiImage
    }

    /// The whitest pixel within three of the image's centre, `0...1` by its weakest channel — where the
    /// ✕'s two strokes cross.
    private static func brightestAtTheCentre(of image: UIImage) -> Double? {
        guard let cgImage = image.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }
        var brightest = 0.0
        for y in (height / 2 - 3)...(height / 2 + 3) {
            for x in (width / 2 - 3)...(width / 2 + 3) {
                let i = (y * width + x) * 4
                brightest = max(brightest, Double(min(pixels[i], pixels[i + 1], pixels[i + 2])) / 255)
            }
        }
        return brightest
    }
}
