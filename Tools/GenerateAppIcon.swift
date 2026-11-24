//
//  GenerateAppIcon.swift
//  WaterBuddy — tooling, NOT a build input
//
//  Renders one icon per theme from the same palettes the app draws with, so an icon and its theme cannot drift
//  apart (rule `60-design-system`): three 1024pt images each — light, dark, tinted — into
//  `WaterBuddy/Assets.xcassets/AppIcon-<Theme>.appiconset` for the four alternates, and each theme's 180-px preview
//  for Settings' picker into `IconPreview-<Theme>.imageset`. Aurora's is the primary, `AppIcon.appiconset`, and is
//  rewritten only with `--primary`: a run for the alternates can never change the icon every install shows.
//
//  Lives in `Tools/` at the repo root **on purpose**. Every target's sources come from a
//  `PBXFileSystemSynchronizedRootGroup`, so a `.swift` file dropped into `WaterBuddy/` joins the
//  app target with no project edit at all (rule `15-project`) — which is exactly what must not
//  happen to a script that imports AppKit.
//
//  Run:  swift Tools/GenerateAppIcon.swift [--primary]
//

import AppKit
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// MARK: - The palettes, transcribed from WaterSurface.swift's `Aurora` palettes

struct RGB {
    let r: Double, g: Double, b: Double

    func cg(_ alpha: Double = 1) -> CGColor {
        CGColor(srgbRed: r, green: g, blue: b, alpha: alpha)
    }

    /// Toward black, for the dark variant.
    func darkened(_ factor: Double) -> RGB {
        RGB(r: r * factor, g: g * factor, b: b * factor)
    }

    /// Rec. 709 luminance, for the tinted variant — which the system re-colours itself, so what
    /// it needs from us is a good grayscale *mask*, not a second colour scheme.
    var grey: RGB {
        let y = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return RGB(r: y, g: y, b: y)
    }
}

/// One theme's five colours, transcribed from `WaterSurface.swift`'s `Aurora` palettes — a palette's change
/// regenerates its icon in the same change (rule `60-design-system`).
struct Palette {
    let name: String
    let top, bottom, blue, magenta, cyan: RGB   // the app's `top`, `bottom`, `first`, `second`, `accent`
}

let palettes: [Palette] = [
    Palette(name: "Aurora",   top: RGB(r: 0.04, g: 0.13, b: 0.52), bottom: RGB(r: 0.36, g: 0.10, b: 0.62),
            blue: RGB(r: 0.00, g: 0.55, b: 1.00), magenta: RGB(r: 0.78, g: 0.25, b: 0.98), cyan: RGB(r: 0.00, g: 0.85, b: 0.85)),
    Palette(name: "Lagoon",   top: RGB(r: 0.01, g: 0.15, b: 0.26), bottom: RGB(r: 0.00, g: 0.27, b: 0.33),
            blue: RGB(r: 0.00, g: 0.60, b: 0.78), magenta: RGB(r: 0.05, g: 0.58, b: 0.50), cyan: RGB(r: 0.25, g: 0.88, b: 0.75)),
    Palette(name: "Dusk",     top: RGB(r: 0.17, g: 0.04, b: 0.20), bottom: RGB(r: 0.42, g: 0.09, b: 0.22),
            blue: RGB(r: 0.95, g: 0.38, b: 0.22), magenta: RGB(r: 0.90, g: 0.22, b: 0.50), cyan: RGB(r: 1.00, g: 0.74, b: 0.30)),
    Palette(name: "Midnight", top: RGB(r: 0.04, g: 0.05, b: 0.09), bottom: RGB(r: 0.11, g: 0.12, b: 0.18),
            blue: RGB(r: 0.28, g: 0.38, b: 0.62), magenta: RGB(r: 0.42, g: 0.40, b: 0.55), cyan: RGB(r: 0.40, g: 0.82, b: 1.00)),
    Palette(name: "Bloom",    top: RGB(r: 0.20, g: 0.03, b: 0.18), bottom: RGB(r: 0.36, g: 0.06, b: 0.34),
            blue: RGB(r: 0.92, g: 0.30, b: 0.62), magenta: RGB(r: 0.62, g: 0.30, b: 0.96), cyan: RGB(r: 1.00, g: 0.66, b: 0.78)),
]

// MARK: - Variants

enum Variant: String, CaseIterable {
    case light = "AppIcon-light"
    case dark = "AppIcon-dark"
    case tinted = "AppIcon-tinted"

    /// How the backdrop is treated.
    ///
    /// The **dark** icon is not the light one on a black square: iOS composites it over a dark
    /// home screen, so a full-brightness aurora reads as a glowing tile rather than as an icon.
    /// The **tinted** icon is drawn in grey because the system replaces the hue with the user's
    /// chosen tint and keeps only luminance — supplying colour there is work thrown away, and
    /// worse, colour that maps to similar luminance turns into a flat shape.
    func apply(_ colour: RGB) -> RGB {
        switch self {
        case .light: colour
        case .dark: colour.darkened(0.52)
        case .tinted: colour.grey.darkened(0.85)
        }
    }
}

// MARK: - Drawing

let side = 1024.0

/// A soft round light, as a radial gradient rather than a blurred circle.
///
/// The same substitution `WidgetAurora` makes: a disc plus a Gaussian and a radial falloff are
/// visually interchangeable at this scale, and the gradient needs no filter chain
/// (rule `60-design-system`).
func light(_ ctx: CGContext, colour: RGB, centre: CGPoint, radius: Double, opacity: Double) {
    let space = CGColorSpaceCreateDeviceRGB()
    guard let gradient = CGGradient(
        colorsSpace: space,
        colors: [
            colour.cg(opacity),
            colour.cg(opacity * 0.55),
            colour.cg(0),
        ] as CFArray,
        locations: [0, 0.45, 1]
    ) else { return }

    ctx.drawRadialGradient(
        gradient,
        startCenter: centre, startRadius: 0,
        endCenter: centre, endRadius: radius,
        options: []
    )
}

/// A water drop: a round bulb with a drawn-out point.
///
/// Deliberately the only figure on the icon. At the 40pt an icon is actually read on a home
/// screen, anything more — a vessel, a wave, a percentage — collapses into texture.
func dropletPath(centre: CGPoint, height: Double) -> CGPath {
    let path = CGMutablePath()
    let apex = CGPoint(x: centre.x, y: centre.y + height / 2)
    let bulb = CGPoint(x: centre.x, y: centre.y - height * 0.15)
    let radius = height * 0.35

    path.move(to: apex)
    // Down the right flank, tangent into the bulb.
    path.addQuadCurve(
        to: CGPoint(x: bulb.x + radius, y: bulb.y),
        control: CGPoint(x: centre.x + radius * 0.78, y: centre.y + height * 0.16)
    )
    // Round the bottom. `clockwise: true` in this y-up context is the short way under the bulb.
    path.addArc(center: bulb, radius: radius, startAngle: 0, endAngle: .pi, clockwise: true)
    // Back up the left flank.
    path.addQuadCurve(
        to: apex,
        control: CGPoint(x: centre.x - radius * 0.78, y: centre.y + height * 0.16)
    )
    path.closeSubpath()
    return path
}

func render(_ variant: Variant, _ p: Palette) -> CGImage? {
    let space = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil, width: Int(side), height: Int(side),
        bitsPerComponent: 8, bytesPerRow: 0, space: space,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    // 1 — the vertical gradient every screen in the app stands on.
    if let base = CGGradient(
        colorsSpace: space,
        colors: [variant.apply(p.bottom).cg(), variant.apply(p.top).cg()] as CFArray,
        locations: [0, 1]
    ) {
        ctx.drawLinearGradient(
            base,
            start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: side),
            options: []
        )
    }

    // 2 — the three lights, proportionally where `AuroraBackground` puts them on a phone. The app's
    // absolute ±240pt offsets mean nothing on a square canvas, so they are re-expressed as
    // fractions, exactly as `WidgetAurora` does for the widget.
    light(ctx, colour: variant.apply(p.blue),
          centre: CGPoint(x: side * 0.20, y: side * 0.82), radius: side * 0.62, opacity: 0.80)
    light(ctx, colour: variant.apply(p.magenta),
          centre: CGPoint(x: side * 0.80, y: side * 0.16), radius: side * 0.58, opacity: 0.75)
    light(ctx, colour: variant.apply(p.cyan),
          centre: CGPoint(x: side * 0.78, y: side * 0.78), radius: side * 0.38, opacity: 0.42)

    // 3 — the droplet. White in every variant: on the tinted icon the system keeps luminance, and
    // white is what survives that as the shape rather than as a smudge.
    let centre = CGPoint(x: side / 2, y: side / 2)
    let drop = dropletPath(centre: centre, height: side * 0.50)

    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -side * 0.012),
                  blur: side * 0.045,
                  color: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.28))
    ctx.addPath(drop)
    ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
    ctx.fillPath()
    ctx.restoreGState()

    // A single soft highlight down the drop, so it reads as volume and not as a sticker. Clipped
    // to the path, so it cannot spill onto the backdrop.
    ctx.saveGState()
    ctx.addPath(drop)
    ctx.clip()
    // The sheen goes through `variant.apply` like everything else: on the tinted icon a blue
    // highlight is the one thing that would survive as *colour* in an image the system expects to
    // be a luminance mask.
    let sheenTint = variant.apply(RGB(r: 0.62, g: 0.85, b: 1.0))
    if let sheen = CGGradient(
        colorsSpace: space,
        colors: [
            CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0),
            sheenTint.cg(0.42),
        ] as CFArray,
        locations: [0.45, 1]
    ) {
        ctx.drawLinearGradient(
            sheen,
            start: CGPoint(x: 0, y: side * 0.72), end: CGPoint(x: 0, y: side * 0.24),
            options: []
        )
    }
    ctx.restoreGState()

    return ctx.makeImage()
}

// MARK: - Write

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let catalogue = root.appending(path: "WaterBuddy/Assets.xcassets")
/// Aurora's set is the primary icon every install shows; it is written only when asked.
let writePrimary = CommandLine.arguments.contains("--primary")

/// The asset catalogue's own manifest for an icon set, so each appearance points at its file.
let iconContents = """
{
  "images" : [
    {
      "filename" : "AppIcon-light.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "filename" : "AppIcon-dark.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "tinted"
        }
      ],
      "filename" : "AppIcon-tinted.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

"""

/// A preview's manifest: one universal image at 3×.
func previewContents(_ name: String) -> String {
    """
    {
      "images" : [ { "filename" : "IconPreview-\(name).png", "idiom" : "universal", "scale" : "3x" } ],
      "info" : { "author" : "xcode", "version" : 1 }
    }

    """
}

/// An image, or the run stops saying which one failed.
func rendered(_ image: CGImage?, _ what: String) -> CGImage {
    guard let image else {
        print("failed to render \(what)")
        exit(1)
    }
    return image
}

/// The light icon at the picker's size — 60pt at 3× — drawn down with high-quality interpolation.
func preview(of image: CGImage, pixels: Int = 180) -> CGImage? {
    guard let ctx = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
                              space: CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
    ctx.interpolationQuality = .high
    ctx.draw(image, in: CGRect(x: 0, y: 0, width: pixels, height: pixels))
    return ctx.makeImage()
}

func writePNG(_ image: CGImage, to url: URL) {
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        print("failed to open \(url.path)")
        exit(1)
    }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
    print("wrote \(url.deletingLastPathComponent().lastPathComponent)/\(url.lastPathComponent)  \(image.width)x\(image.height)")
}

func writeText(_ text: String, to url: URL) throws {
    try text.write(to: url, atomically: true, encoding: .utf8)
    print("wrote \(url.deletingLastPathComponent().lastPathComponent)/\(url.lastPathComponent)")
}

for p in palettes {
    let primary = p.name == "Aurora"
    let set = catalogue.appending(path: primary ? "AppIcon.appiconset" : "AppIcon-\(p.name).appiconset")
    let images = Variant.allCases.map { (variant: $0, image: rendered(render($0, p), "\(p.name) \($0.rawValue)")) }
    if !primary || writePrimary {
        for (variant, image) in images { writePNG(image, to: set.appending(path: "\(variant.rawValue).png")) }
        try writeText(iconContents, to: set.appending(path: "Contents.json"))
    }
    // Every theme's preview, Aurora's included: the picker shows all five.
    let previewSet = catalogue.appending(path: "IconPreview-\(p.name).imageset")
    let light = images.first { $0.variant == .light }?.image
    writePNG(rendered(light.flatMap { preview(of: $0) }, "\(p.name) preview"),
             to: previewSet.appending(path: "IconPreview-\(p.name).png"))
    try writeText(previewContents(p.name), to: previewSet.appending(path: "Contents.json"))
}
