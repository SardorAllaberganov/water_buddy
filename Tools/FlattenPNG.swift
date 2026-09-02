//
//  FlattenPNG.swift
//  Tools
//
//  Re-encodes a PNG with no alpha channel, leaving every RGB byte untouched.
//
//  Run:  swift Tools/FlattenPNG.swift <file.png> [<file.png> …]
//
//  Files are rewritten in place. Anything already free of an alpha channel is left alone.
//
//  WHY THIS EXISTS. App Store Connect's screenshot rule is absolute — "Images can't include alpha
//  channels or transparencies" — and `xcrun simctl io … screenshot` writes RGBA on watchOS **even
//  with `--mask=ignored`**, because the watch display is non-rectangular and the framebuffer carries
//  a mask regardless of how the corners are filled. `Tools/VerifyScreenshots.sh` catches it; this is
//  what fixes it.
//
//  WHY NOT `sips`. `sips` has no alpha, matte or flatten flag. A png→png roundtrip preserves colour
//  type 6, and `-p … --padColor` does too. The only `sips` path that reaches colour type 2 is a JPEG
//  roundtrip, which is lossy — it alters well over half the RGB bytes. Unacceptable for a store
//  asset, so this draws through a `.noneSkipLast` context instead, which discards the channel and
//  reproduces the colour planes bit for bit.
//
//  This file lives in `Tools/`, which sits outside every PBXFileSystemSynchronizedRootGroup and so
//  belongs to no build target (rule `15-project`). It imports CoreGraphics/ImageIO, which is why it
//  must not sit inside one.
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

private func hasAlpha(_ image: CGImage) -> Bool {
    switch image.alphaInfo {
    case .none, .noneSkipFirst, .noneSkipLast:
        return false
    default:
        return true
    }
}

private func flatten(_ path: String) -> Bool {
    let url = URL(fileURLWithPath: path)

    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        print("  FAIL  \(path) — cannot read")
        return false
    }

    guard hasAlpha(image) else {
        print("  skip  \(path) — already has no alpha channel")
        return true
    }

    // `bytesPerRow: 0` lets CoreGraphics choose the row stride. `.noneSkipLast` is a valid 8-bit
    // RGB combination: 32 bits per pixel with the fourth byte ignored, which ImageIO then writes out
    // as PNG colour type 2.
    guard let context = CGContext(data: nil,
                                  width: image.width,
                                  height: image.height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: 0,
                                  space: CGColorSpaceCreateDeviceRGB(),
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
        print("  FAIL  \(path) — cannot create context")
        return false
    }

    context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))

    guard let flattened = context.makeImage(),
          let destination = CGImageDestinationCreateWithURL(
              url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        print("  FAIL  \(path) — cannot create destination")
        return false
    }

    CGImageDestinationAddImage(destination, flattened, nil)
    guard CGImageDestinationFinalize(destination) else {
        print("  FAIL  \(path) — write failed")
        return false
    }

    print("  ok    \(path) — alpha removed, \(image.width)x\(image.height)")
    return true
}

let paths = Array(CommandLine.arguments.dropFirst())
guard !paths.isEmpty else {
    print("usage: swift Tools/FlattenPNG.swift <file.png> [<file.png> …]")
    exit(2)
}

var allSucceeded = true
for path in paths where !flatten(path) {
    allSucceeded = false
}
exit(allSucceeded ? 0 : 1)
