//
//  GenerateAppIcon.swift
//  WaterBuddy — tooling, NOT a build input
//
//  Renders `WaterBuddy/Assets.xcassets/AppIcon.appiconset`'s three 1024pt images from the same
//  `Aurora` palette the app draws with, so the icon and the product cannot drift apart.
//
//  Lives in `Tools/` at the repo root **on purpose**. Every target's sources come from a
//  `PBXFileSystemSynchronizedRootGroup`, so a `.swift` file dropped into `WaterBuddy/` joins the
//  app target with no project edit at all (rule `15-project`) — which is exactly what must not
//  happen to a script that imports AppKit.
//
//  Run:  swift Tools/GenerateAppIcon.swift
//

import AppKit
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// MARK: - The palette, transcribed from WaterSurface.swift's `Aurora`

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

enum Aurora {
    static let top = RGB(r: 0.04, g: 0.13, b: 0.52)
    static let bottom = RGB(r: 0.36, g: 0.10, b: 0.62)
    static let blue = RGB(r: 0.00, g: 0.55, b: 1.00)
    static let magenta = RGB(r: 0.78, g: 0.25, b: 0.98)
    static let cyan = RGB(r: 0.00, g: 0.85, b: 0.85)
}

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

func render(_ variant: Variant) -> CGImage? {
    let space = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil, width: Int(side), height: Int(side),
        bitsPerComponent: 8, bytesPerRow: 0, space: space,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    // 1 — the vertical gradient every screen in the app stands on.
    if let base = CGGradient(
        colorsSpace: space,
        colors: [variant.apply(Aurora.bottom).cg(), variant.apply(Aurora.top).cg()] as CFArray,
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
    light(ctx, colour: variant.apply(Aurora.blue),
          centre: CGPoint(x: side * 0.20, y: side * 0.82), radius: side * 0.62, opacity: 0.80)
    light(ctx, colour: variant.apply(Aurora.magenta),
          centre: CGPoint(x: side * 0.80, y: side * 0.16), radius: side * 0.58, opacity: 0.75)
    light(ctx, colour: variant.apply(Aurora.cyan),
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
let iconSet = root.appending(path: "WaterBuddy/Assets.xcassets/AppIcon.appiconset")

for variant in Variant.allCases {
    guard let image = render(variant) else {
        print("failed to render \(variant.rawValue)")
        exit(1)
    }
    let url = iconSet.appending(path: "\(variant.rawValue).png")
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        print("failed to open \(url.path)")
        exit(1)
    }
    CGImageDestinationAddImage(dest, image, nil)
    CGImageDestinationFinalize(dest)
    print("wrote \(url.lastPathComponent)  \(image.width)x\(image.height)")
}

// The asset catalogue's own manifest, rewritten so each appearance points at its file.
let contents = """
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
try contents.write(to: iconSet.appending(path: "Contents.json"), atomically: true, encoding: .utf8)
print("wrote Contents.json")
