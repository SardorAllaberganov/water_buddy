//
//  ComposeStoreScreenshot.swift
//  Tools
//
//  Composites an iPhone screenshot onto WaterBuddy's own aurora at a target App Store size.
//
//  Run:  swift Tools/ComposeStoreScreenshot.swift <WIDTHxHEIGHT> <out-dir> <in.png> [<in.png> …]
//  e.g.  swift Tools/ComposeStoreScreenshot.swift 2064x2752 Screenshots/en-US/iPad-13 \
//            Screenshots/en-US/iPhone-6.5/*.png
//
//  WHY THIS EXISTS, AND WHAT IT IS NOT
//
//  WaterBuddy is iPhone-only — `TARGETED_DEVICE_FAMILY = 1`, and the built Info.plist reads
//  `UIDeviceFamily [1]`. Apple's screenshot spec makes the 13" iPad set "Required if app runs on
//  iPad", so an iPhone-only app is not asked for one; App Store Connect only offers the tab because
//  no build has been processed yet.
//
//  When the tab is filled anyway, the alternative is a raw capture from an iPad simulator — and that
//  is worse. An iPhone-only app runs there in a *compatibility window*: a floating phone-shaped
//  window over the iPad's own wallpaper, with the iPad status bar and the window's ●●● control
//  visible. Correct pixel dimensions, but it advertises the desktop rather than the app, and it is
//  the sort of asset App Review 2.3.3 objects to.
//
//  So this composes instead: the real, unaltered app screen, centred on the product's own aurora
//  gradient. Nothing about the UI is redrawn or faked — the source pixels are scaled and placed.
//  Apple explicitly permits image and text overlays in screenshots, and a device-on-branded-
//  background composition is ordinary App Store practice.
//
//  The gradient is `Aurora.top` → `Aurora.bottom` from WaterSurface.swift:150-151. If those move,
//  move these (rule `60-design-system`: colour comes from Aurora, and a copy that drifts is worse
//  than no copy).
//
//  Output is written opaque, PNG colour type 2 — App Store Connect rejects any screenshot carrying
//  an alpha channel.
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// Aurora.top and Aurora.bottom, WaterSurface.swift:150-151.
private let auroraTop = CGColor(red: 0.04, green: 0.13, blue: 0.52, alpha: 1)
private let auroraBottom = CGColor(red: 0.36, green: 0.10, blue: 0.62, alpha: 1)

/// The fraction of the canvas height the phone screen occupies. Leaves a margin top and bottom so
/// the composition reads as deliberate rather than as a crop that failed.
private let fillFraction: CGFloat = 0.88

private func loadImage(_ path: String) -> CGImage? {
    guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil) else {
        return nil
    }
    return CGImageSourceCreateImageAtIndex(src, 0, nil)
}

private func roundedPath(in rect: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

private func compose(_ inputPath: String, into outDir: String, width: Int, height: Int) -> Bool {
    guard let phone = loadImage(inputPath) else {
        print("  FAIL  \(inputPath) — cannot read")
        return false
    }

    // `.noneSkipLast` rather than a premultiplied variant: the canvas is fully painted, and this is
    // what makes ImageIO emit PNG colour type 2 with no alpha channel.
    guard let ctx = CGContext(data: nil,
                              width: width,
                              height: height,
                              bitsPerComponent: 8,
                              bytesPerRow: 0,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
        print("  FAIL  \(inputPath) — cannot create context")
        return false
    }

    let canvas = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))

    // The aurora, top to bottom. CoreGraphics' origin is bottom-left, so `top` is the second stop.
    if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                 colors: [auroraBottom, auroraTop] as CFArray,
                                 locations: [0, 1]) {
        ctx.drawLinearGradient(gradient,
                               start: CGPoint(x: 0, y: 0),
                               end: CGPoint(x: 0, y: canvas.height),
                               options: [])
    }

    // Scale the phone screen to `fillFraction` of the canvas height, preserving its aspect ratio.
    let targetHeight = canvas.height * fillFraction
    let scale = targetHeight / CGFloat(phone.height)
    let targetWidth = CGFloat(phone.width) * scale
    let frame = CGRect(x: (canvas.width - targetWidth) / 2,
                       y: (canvas.height - targetHeight) / 2,
                       width: targetWidth,
                       height: targetHeight)

    // A drop shadow lifts the screen off the gradient so it does not read as a flat paste. Drawn
    // before the clip, because a clipped context cannot cast outside its own path.
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -targetHeight * 0.012),
                  blur: targetHeight * 0.03,
                  color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.45))
    ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
    let radius = targetWidth * 0.055
    ctx.addPath(roundedPath(in: frame, radius: radius))
    ctx.fillPath()
    ctx.restoreGState()

    // The screen itself, corner-rounded to match a device.
    ctx.saveGState()
    ctx.addPath(roundedPath(in: frame, radius: radius))
    ctx.clip()
    ctx.draw(phone, in: frame)
    ctx.restoreGState()

    guard let out = ctx.makeImage() else {
        print("  FAIL  \(inputPath) — cannot render")
        return false
    }

    let name = URL(fileURLWithPath: inputPath).lastPathComponent
    let outURL = URL(fileURLWithPath: outDir).appendingPathComponent(name)
    try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

    guard let dest = CGImageDestinationCreateWithURL(
        outURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        print("  FAIL  \(inputPath) — cannot create destination")
        return false
    }
    CGImageDestinationAddImage(dest, out, nil)
    guard CGImageDestinationFinalize(dest) else {
        print("  FAIL  \(inputPath) — write failed")
        return false
    }

    print("  ok    \(outURL.path) — \(width)x\(height)")
    return true
}

let args = Array(CommandLine.arguments.dropFirst())
guard args.count >= 3 else {
    print("usage: swift Tools/ComposeStoreScreenshot.swift <WIDTHxHEIGHT> <out-dir> <in.png> …")
    exit(2)
}

let parts = args[0].lowercased().split(separator: "x")
guard parts.count == 2, let w = Int(parts[0]), let h = Int(parts[1]), w > 0, h > 0 else {
    print("first argument must be WIDTHxHEIGHT, e.g. 2064x2752")
    exit(2)
}

let outDir = args[1]
var ok = true
for input in args.dropFirst(2) where !compose(input, into: outDir, width: w, height: h) {
    ok = false
}
exit(ok ? 0 : 1)
