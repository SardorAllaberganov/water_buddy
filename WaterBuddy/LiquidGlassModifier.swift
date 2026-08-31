//
//  LiquidGlassModifier.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 28/08/26.
//

import SwiftUI

// MARK: - Design tokens

/// Tokens for the glass surface, so every pane in the app is lit by the same light.
enum LiquidGlass {

    /// The default corner radius. Continuous — the iOS squircle, not a circular arc.
    static let cornerRadius: CGFloat = 28

    /// What a pane does while a finger is on it.
    ///
    /// Adopted from Apple's *Applying Liquid Glass to custom views*, which describes
    /// `Glass.interactive()` as glass that "reacts to touch and pointer interactions in real time".
    /// **That API cannot be called here** — `glassEffect(_:in:)` and friends ship in the iOS 26 SDK
    /// and this project builds against 18.5, so the symbols do not exist to guard with
    /// `#available`. The behaviour is expressed in this system instead.
    ///
    /// Three multipliers rather than one, because the three layers carry the press in different
    /// schemes. In **light** mode the tint does the work: frosted goes 0.45 → 0.61, clamped to the
    /// 0.6 ceiling rule `60-design-system` measured. In **dark** mode — which this app is committed
    /// to — the tint is only 0.07, so ×1.35 moves it four thousandths and is invisible on its own;
    /// there the **lit rim and the specular** carry it, which is consistent with the edge being
    /// "the detail that sells it". `theDarkModePressLeansOnTheEdgeRatherThanTheTint` asserts that
    /// balance rather than leaving it to taste.
    enum Interaction {

        /// Ceiling from rule `60-design-system`: past roughly 0.6 in light mode the backdrop stops
        /// reading through and the pane becomes flat white paint.
        static let maximumTintOpacity = 0.6

        static let tintBoost = 1.35
        static let edgeBoost = 1.3
        static let specularBoost = 1.25

        /// The tint a pressed pane draws, clamped so a press can approach the ceiling and never
        /// cross it — including when a caller has overridden `tintOpacity` with something absurd.
        static func pressedTint(_ resting: Double) -> Double {
            min(resting * tintBoost, maximumTintOpacity)
        }
    }

    /// How far the pane floats above what it covers.
    ///
    /// Each level is two shadows: a wide ambient one for the sense of height, and a tight
    /// contact shadow that keeps the edge from drifting off the surface below it.
    enum Elevation: CaseIterable {
        case flush, resting, raised, floating

        var ambient: (radius: CGFloat, y: CGFloat, opacity: Double) {
            switch self {
            case .flush:    (0, 0, 0)
            case .resting:  (18, 8, 0.14)
            case .raised:   (28, 14, 0.18)
            case .floating: (44, 22, 0.22)
            }
        }

        var contact: (radius: CGFloat, y: CGFloat, opacity: Double) {
            switch self {
            case .flush:    (0, 0, 0)
            case .resting:  (3, 1, 0.10)
            case .raised:   (4, 2, 0.12)
            case .floating: (6, 3, 0.14)
            }
        }
    }

    /// The pane's bottom layer — the thing every other layer is stacked on.
    ///
    /// ``material(_:)`` is the real article and the default: it samples and blurs whatever the
    /// pane covers. It only works where there *is* something to sample, and a WidgetKit widget
    /// is the case where there is not — the extension renders its view into a display-list
    /// archive that another process replays, with no wallpaper and no app behind it, so a
    /// `Material` there resolves to nothing. ``flat(translucent:opaque:)`` supplies the two
    /// fills that context needs instead.
    enum Base {

        /// The system material, blurring what the pane covers.
        case material(Material)

        /// Fixed fills for a context that cannot sample a backdrop: `translucent` stands in for
        /// the material, `opaque` for the Reduce Transparency slab.
        case flat(translucent: Color, opaque: Color)

        /// The frozen equivalent of `.ultraThinMaterial` over WaterBuddy's own backdrop, for
        /// WidgetKit.
        ///
        /// Not a guess. `platformContentUltraThinDark.materialrecipe` is a saturation boost, a
        /// backdrop blur, and a 50% mix toward a grey chosen by remapping the backdrop's
        /// luminance through the stops `[0.24, 0.24, 0.30, 0.39]`. Every colour in
        /// `AuroraBackground` has luminance below the first knee, so the remap is constant at
        /// 0.24 and the material collapses to exactly `Color(white: 0.24).opacity(0.5)`. The
        /// blur half contributes nothing because the aurora is already low-frequency — which is
        /// the same reason the app's backdrop needs blobs at all.
        ///
        /// `opaque` is that stack composited down over the aurora, rather than the neutral
        /// `secondarySystemBackground` grey, so Reduce Transparency keeps the product's colour.
        static let archived = Base.flat(
            translucent: Color(white: 0.24).opacity(0.5),
            opaque: Color(red: 0.22, green: 0.19, blue: 0.36)
        )

        /// The fill that replaces the whole stack when Reduce Transparency is on.
        var opaqueFill: Color {
            switch self {
            case .material: Color(.secondarySystemBackground)
            case .flat(_, let opaque): opaque
            }
        }
    }

    /// How milky the pane is.
    ///
    /// The tint and the blur compete: every point of tint hides a point of the material behind
    /// it. Rendered comparisons put the light-mode ceiling at about 0.6 — past it the
    /// background stops reading and the pane becomes flat white paint — so the scale tops out
    /// where glass still looks like glass.
    enum Density: CaseIterable {
        case sheer, frosted, opaque

        /// A black scrim beneath the tint, in Dark Mode only.
        ///
        /// This is the layer that makes dark glass work. White alone cannot hold back a vivid
        /// background at any opacity a dark UI can afford: too little and the colours punch
        /// straight through as a coloured film, too much and the pane turns into a light slab
        /// with nowhere for white text to go. The scrim attenuates first; the tint then only
        /// has to supply sheen.
        func scrimOpacity(for scheme: ColorScheme) -> Double {
            guard scheme == .dark else { return 0 }

            return switch self {
            case .sheer:   0.16
            case .frosted: 0.28
            case .opaque:  0.40
            }
        }

        /// The white body of the glass in light mode; a thin sheen over the scrim in dark.
        func tintOpacity(for scheme: ColorScheme) -> Double {
            switch (self, scheme) {
            case (.sheer, .dark):    0.05
            case (.sheer, _):        0.22
            case (.frosted, .dark):  0.07
            case (.frosted, _):      0.45
            case (.opaque, .dark):   0.09
            case (.opaque, _):       0.58
            }
        }
    }
}

// MARK: - Modifier

/// A glossy glass surface: system blur, a white tint, a lit edge, a specular sweep, and depth.
///
/// The five layers, bottom to top, are what make it read as a physical pane rather than a
/// translucent rectangle:
///
/// 1. ``LiquidGlass/Base`` — the real blur, sampling whatever is behind the view. Or, where
///    nothing can be sampled, the fill that measures out to the same thing.
/// 2. A black scrim, in Dark Mode only — see ``LiquidGlass/Density/scrimOpacity(for:)``.
/// 3. A white tint — the body of the glass.
/// 4. A specular gradient — a light source above and to the left, falling off fast.
/// 5. An inset stroke that is bright where the light hits and dim where it does not.
/// 6. Two shadows — ambient height plus a contact edge.
///
/// Glass is invisible without something behind it. Place it over content, imagery, or colour,
/// never over a flat background.
///
/// Density is a legibility decision, not only a look: a pane is only as readable as the
/// background it failed to hide. Use ``LiquidGlass/Density/frosted`` or
/// ``LiquidGlass/Density/opaque`` behind body text, and keep ``LiquidGlass/Density/sheer`` for
/// short labels and controls where a busy backdrop cannot swallow a whole sentence.
// MARK: - The press state

private struct GlassPressedKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {

    /// Whether a finger is down on the control containing this pane.
    ///
    /// Set by ``PressStyle`` and read by ``LiquidGlassModifier``. It is an environment value for a
    /// structural reason: `liquidGlass(…)` is applied *inside* a button's label, and
    /// `ButtonStyle.Configuration` is only visible to the style, which wraps the label from
    /// outside. The style can hand the state down; the label cannot reach up for it.
    ///
    /// Defaults to `false`, so a glass pane that is not inside a `PressStyle` button — the vessel,
    /// the settings cards — simply never reacts.
    var glassIsPressed: Bool {
        get { self[GlassPressedKey.self] }
        set { self[GlassPressedKey.self] = newValue }
    }
}

struct LiquidGlassModifier<S: Shape & InsettableShape>: ViewModifier {

    var shape: S
    var base: LiquidGlass.Base = .material(.ultraThinMaterial)
    var density: LiquidGlass.Density = .frosted
    var tint: Color = .white
    /// Overrides ``LiquidGlass/Density`` when you need one specific pane to differ.
    var tintOpacity: Double?
    var elevation: LiquidGlass.Elevation = .resting
    var borderWidth: CGFloat = 1
    var highlightStart: UnitPoint = .topLeading
    var highlightEnd: UnitPoint = .bottomTrailing

    /// Whether this pane answers a finger. **Opt-in**, so every pane written before this existed
    /// renders exactly as it did — a design system that quietly started animating twenty panes
    /// would be a redesign rather than a feature (`panesAreInertUnlessTheyAskNotToBe`).
    var interactive: Bool = false

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    /// Injected by ``PressStyle``, which is the only thing in the app that knows a finger is down.
    ///
    /// An environment value rather than a parameter because `liquidGlass(…)` is applied *inside* a
    /// button's label, where `ButtonStyle.Configuration` is out of reach — the style wraps the
    /// label, so it can hand the state down but the label cannot ask for it.
    @Environment(\.glassIsPressed) private var isPressed

    func body(content: Content) -> some View {
        content
            .background(pane)
            // Scoped to the value that changed, never a bare `withAnimation` (rule `50-views`),
            // and matched to `PressStyle`'s spring so the material and the frame move together
            // rather than arriving one after the other.
            //
            // No Reduce Motion path, deliberately: this runs only while a finger is down. That
            // rule targets loops that never stop, which is the same ruling `PressStyle` records
            // for its recoil (rule `65-accessibility`).
            .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isReacting)
    }

    // MARK: Layers

    @ViewBuilder
    private var pane: some View {
        if reduceTransparency {
            // Translucency is the thing being turned off, so there is nothing to soften:
            // swap in an opaque surface and keep only the edge and the depth.
            shape
                .fill(base.opaqueFill)
                .overlay { shape.strokeBorder(edge, lineWidth: borderWidth) }
                .compositingGroup()
                .modifier(Shadows(elevation: elevation, colorScheme: colorScheme))
        } else {
            baseLayer
                .overlay { shape.fill(Color.black.opacity(density.scrimOpacity(for: colorScheme))) }
                .overlay { shape.fill(tint.opacity(resolvedTintOpacity)) }
                .overlay { shape.fill(specular) }
                .overlay { shape.strokeBorder(edge, lineWidth: borderWidth) }
                .compositingGroup()
                .modifier(Shadows(elevation: elevation, colorScheme: colorScheme))
        }
    }

    @ViewBuilder
    private var baseLayer: some View {
        switch base {
        case .material(let material): shape.fill(material)
        case .flat(let translucent, _): shape.fill(translucent)
        }
    }

    /// `true` only when this pane opted in *and* a finger is down on the button containing it.
    private var isReacting: Bool { interactive && isPressed }

    private var resolvedTintOpacity: Double {
        let resting = tintOpacity ?? density.tintOpacity(for: colorScheme)
        return isReacting ? LiquidGlass.Interaction.pressedTint(resting) : resting
    }

    /// A light source above and to the left: a bright band along the top edge that falls away
    /// quickly, then the faintest lift at the far edge where light passes back through.
    private var specular: LinearGradient {
        let resting = colorScheme == .dark ? 0.28 : 0.55
        let peak = isReacting ? min(resting * LiquidGlass.Interaction.specularBoost, 1) : resting

        return LinearGradient(
            stops: [
                .init(color: .white.opacity(peak), location: 0.00),
                .init(color: .white.opacity(peak * 0.22), location: 0.28),
                .init(color: .clear, location: 0.55),
                .init(color: .white.opacity(peak * 0.10), location: 1.00),
            ],
            startPoint: highlightStart,
            endPoint: highlightEnd
        )
    }

    /// The edge is the detail that sells it. A flat 1pt white border reads as a drawn outline;
    /// a stroke that is bright where the light lands and nearly gone on the shaded side reads
    /// as the lit rim of something solid.
    private var edge: LinearGradient {
        let isDark = colorScheme == .dark
        let lit = isDark ? 0.55 : 0.85
        let shaded = isDark ? 0.06 : 0.18
        // Two independent reasons to brighten, and they multiply: increased contrast is a
        // standing accessibility need, a press is momentary. Neither should cancel the other.
        let contrastBoost = contrast == .increased ? 1.4 : 1.0
        let pressBoost = isReacting ? LiquidGlass.Interaction.edgeBoost : 1.0
        let boost = contrastBoost * pressBoost

        return LinearGradient(
            colors: [
                .white.opacity(min(lit * boost, 1)),
                .white.opacity(min(shaded * boost, 1)),
            ],
            startPoint: highlightStart,
            endPoint: highlightEnd
        )
    }
}

// MARK: - Shadows

/// Depth as two stacked shadows. One shadow alone either hugs the edge with no sense of height
/// or floats with no contact; the pair does both.
private struct Shadows: ViewModifier {
    let elevation: LiquidGlass.Elevation
    let colorScheme: ColorScheme

    func body(content: Content) -> some View {
        // Shadows fall on darker ground in Dark Mode and need more weight to register.
        let weight = colorScheme == .dark ? 1.5 : 1.0
        let ambient = elevation.ambient
        let contact = elevation.contact

        content
            .shadow(
                color: .black.opacity(ambient.opacity * weight),
                radius: ambient.radius,
                x: 0,
                y: ambient.y
            )
            .shadow(
                color: .black.opacity(contact.opacity * weight),
                radius: contact.radius,
                x: 0,
                y: contact.y
            )
    }
}

// MARK: - View API

extension View {

    /// Places the content on a glass pane clipped to `shape`.
    ///
    /// Use for a non-rectangular pane — `Capsule()` for a floating control, `Circle()` for a
    /// badge.
    func liquidGlass<S: Shape & InsettableShape>(
        in shape: S,
        base: LiquidGlass.Base = .material(.ultraThinMaterial),
        density: LiquidGlass.Density = .frosted,
        tint: Color = .white,
        tintOpacity: Double? = nil,
        elevation: LiquidGlass.Elevation = .resting,
        borderWidth: CGFloat = 1,
        highlightStart: UnitPoint = .topLeading,
        highlightEnd: UnitPoint = .bottomTrailing,
        interactive: Bool = false
    ) -> some View {
        modifier(
            LiquidGlassModifier(
                shape: shape,
                base: base,
                density: density,
                tint: tint,
                tintOpacity: tintOpacity,
                elevation: elevation,
                borderWidth: borderWidth,
                highlightStart: highlightStart,
                highlightEnd: highlightEnd,
                interactive: interactive
            )
        )
    }

    /// Places the content on a rounded glass pane.
    func liquidGlass(
        cornerRadius: CGFloat = LiquidGlass.cornerRadius,
        base: LiquidGlass.Base = .material(.ultraThinMaterial),
        density: LiquidGlass.Density = .frosted,
        tint: Color = .white,
        tintOpacity: Double? = nil,
        elevation: LiquidGlass.Elevation = .resting,
        borderWidth: CGFloat = 1,
        highlightStart: UnitPoint = .topLeading,
        highlightEnd: UnitPoint = .bottomTrailing,
        interactive: Bool = false
    ) -> some View {
        liquidGlass(
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous),
            base: base,
            density: density,
            tint: tint,
            tintOpacity: tintOpacity,
            elevation: elevation,
            borderWidth: borderWidth,
            highlightStart: highlightStart,
            highlightEnd: highlightEnd,
            interactive: interactive
        )
    }
}

// MARK: - Preview

/// Glass has nothing to refract on a flat background, so the preview puts real colour and
/// shape behind it.
private struct LiquidGlassPreview: View {
    var body: some View {
        ZStack {
            backdrop

            VStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Today")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text("1,450 ml")
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    ProgressView(value: 0.725)
                        .tint(.primary.opacity(0.7))
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .liquidGlass(elevation: .raised)

                HStack(spacing: 14) {
                    ForEach([250, 500, 750], id: \.self) { amount in
                        Text("+\(amount)")
                            .font(.callout.weight(.semibold))
                            .monospacedDigit()
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .liquidGlass(in: Capsule(), density: .sheer)
                    }
                }

                Image(systemName: "drop.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.primary.opacity(0.8))
                    .frame(width: 88, height: 88)
                    .liquidGlass(in: Circle(), elevation: .floating)
            }
            .padding(28)
        }
    }

    /// Deliberately busy — a uniform field would let a flat white rectangle pass for glass.
    private var backdrop: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.42, blue: 0.86), Color(red: 0.55, green: 0.24, blue: 0.78)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color(red: 1.0, green: 0.55, blue: 0.25))
                .frame(width: 260)
                .offset(x: -110, y: -180)
            Circle()
                .fill(Color(red: 0.1, green: 0.85, blue: 0.75))
                .frame(width: 200)
                .offset(x: 130, y: 200)
        }
        .ignoresSafeArea()
    }
}

#Preview("Light") {
    LiquidGlassPreview()
}

#Preview("Dark") {
    LiquidGlassPreview().preferredColorScheme(.dark)
}
