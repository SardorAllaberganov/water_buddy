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
    /// On iOS 26 and later an interactive pane **is** that glass
    /// (``LiquidGlass/systemVariant(density:interactive:)``). These multipliers are what the
    /// hand-made stack does instead, wherever ``LiquidGlass/rendering(base:reduceTransparency:systemGlassAvailable:)``
    /// answers `.handMade`: below iOS 26, in the widget, and on the watch until its own stage.
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

    /// The primary surface: the one solid thing among the glass, for a screen's one main action.
    ///
    /// Solid white, because a main action drawn as one more glass pane read as disabled — *Get
    /// Started* was frosted glass with a glow, and looked like a control waiting to be enabled.
    /// The content on it is `Aurora.top`, the deep blue the backdrop starts from, so the surface
    /// borrows the product's colour without a new token
    /// (`thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade`).
    enum Primary {

        /// How far the fill leans toward `Aurora.top` at its foot. Enough to read as lit from
        /// above; the contrast test is what stops it growing.
        nonisolated static let shadeOpacity = 0.12

        /// The wash laid over the whole fill while a finger is down — the material answering
        /// the press, as `Interaction` does for glass.
        nonisolated static let pressedShadeOpacity = 0.10

        /// The soft ring outside the shape, and how far it reaches.
        nonisolated static let ringOpacity = 0.13
        nonisolated static let ringWidth: CGFloat = 6
    }

    /// How a selected slot is marked: the tab bar's active tab and History's shown day.
    ///
    /// A fill and a lit rim, always both and never colour alone (rule `65-accessibility`). Both
    /// values were read off History's rendered week card before the tab bar borrowed them.
    enum Selection {

        /// The fill behind the selected slot. Low on purpose: it sits under a small white
        /// caption, and every point of white added here comes straight off that caption's
        /// contrast.
        nonisolated static let fillOpacity = 0.08

        /// The lit rim around it. A non-text mark, so its floor is 3:1.
        nonisolated static let rimOpacity = 0.55
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
        ///
        /// `.material` delegates to `.archived.opaqueFill` rather than a system colour: the app
        /// and the widget already agree here (rule `65-accessibility`: "the widget draws ... a
        /// contrast threshold, not taste"), and `Color(.secondarySystemBackground)` does not exist
        /// on watchOS — this is the fix for the one compile error that blocks `WaterSurface.swift`
        /// from joining a watch target (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md`
        /// §13). Never add a second literal here: `Base.archived` is the one place the number lives.
        var opaqueFill: Color {
            switch self {
            case .material: Base.archived.opaqueFill
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

    /// Which of the three panes a `liquidGlass(…)` call draws.
    ///
    /// A value rather than three `if`s inside the modifier, so the choice can be pinned by a test
    /// that never builds a view (`LiquidGlassRoutingTests`).
    nonisolated enum Rendering: Equatable, Sendable {

        /// The opaque fill and lit rim that replace everything under Reduce Transparency.
        case opaque

        /// Apple's glass, `glassEffect(_:in:)`. The system draws the pane, its edge and its
        /// depth; none of this file's layers is stacked on it.
        case system

        /// The stack this file has always drawn: base, scrim, tint, specular, rim, two shadows.
        case handMade
    }

    /// Decides the pane, in this order — and the order is the ruling.
    ///
    /// 1. **Reduce Transparency first, on every OS.** The SDK's doc comments say nothing about
    ///    what Apple's glass does under that setting, so this system keeps its own answer rather
    ///    than depend on one it cannot read.
    /// 2. **A `.flat` base is hand-made, always.** It exists for a context that cannot sample a
    ///    backdrop — the widget — and Apple's glass samples one as a `Material` does.
    /// 3. Otherwise Apple's glass where the system has it, and the hand-made stack where it has
    ///    not.
    ///
    /// Spec `docs/superpowers/specs/2026-10-09-premium-redesign-design.md` §3.2.
    nonisolated static func rendering(
        base: Base,
        reduceTransparency: Bool,
        systemGlassAvailable: Bool
    ) -> Rendering {
        if reduceTransparency { return .opaque }

        switch base {
        case .flat: return .handMade
        case .material: return systemGlassAvailable ? .system : .handMade
        }
    }

    /// Whether this process can draw Apple's glass.
    ///
    /// **iOS only, for now.** watchOS 26 has the API and the watch's floor is 26.0, so the watch
    /// could take this path today — but no watchOS 26 simulator runtime was installed where this
    /// was built, and a pane nobody has rendered is not one to ship. The watch stage of the
    /// redesign turns it on (spec §9, §14).
    ///
    /// A `static let`, resolved once: the answer cannot change while the process lives.
    nonisolated static let systemGlassAvailable: Bool = {
        #if os(iOS)
        if #available(iOS 26.0, *) { return true }
        #endif
        return false
    }()

    /// Which of Apple's two glasses a pane takes.
    nonisolated enum SystemVariant: Equatable, Sendable {

        /// `Glass.regular` — the adaptive one, for any pane that carries a label.
        case regular

        /// `Glass.clear` — for a container whose content brings its own legibility.
        case clear
    }

    /// `.sheer` asks for the least glass, and only a pane that is not a control gets Apple's
    /// clear variant for it: the vessel, whose readout sits on its own scrim. A sheer *control*
    /// — *Cancel*, *Open iOS Settings* — carries a label straight on the glass and needs the
    /// regular variant's legibility.
    ///
    /// A starting mapping, settled by measurement: the figures are in `docs/DESIGN.md`.
    nonisolated static func systemVariant(density: Density, interactive: Bool) -> SystemVariant {
        switch density {
        case .sheer: return interactive ? .regular : .clear
        case .frosted, .opaque: return .regular
        }
    }

    /// How much black Apple's glass is tinted with, through `Glass.tint(_:)`.
    ///
    /// **Measured, not chosen.** Over this aurora the regular glass reads about sRGB
    /// `(0.07, 0.50, 0.88)` where the hand-made pane read `(0.21, 0.30, 0.44)`, and every dimmed
    /// white in the app was picked from samples of the darker one: untinted, most of them fell
    /// to 2.3–3.9:1. The value was climbed a rung at a time, each rendered on iOS 27.0 — whose
    /// glass is lighter than iOS 26's — and followed through a minute of the aurora's swing,
    /// because the ground under a pane keeps moving: `0.44` failed, `0.48` left the dimmest text
    /// exactly on its floor, and this is the first rung with room. The tables are in
    /// `docs/DESIGN.md`, *Apple's glass, measured* — re-take them before moving the number, and
    /// never estimate one value from another.
    ///
    /// The clear variant takes none. It is the vessel: its readout has
    /// ``WaterReadabilityScrim``, and a tint would dull the water behind it.
    nonisolated static func systemTintOpacity(for variant: SystemVariant) -> Double {
        switch variant {
        case .regular: return 0.52
        case .clear: return 0
        }
    }
}

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

// MARK: - Modifier

/// A glass surface, drawn one of three ways. ``LiquidGlass/rendering(base:reduceTransparency:systemGlassAvailable:)``
/// decides which, and no call site is told.
///
/// - **Apple's glass**, on iOS 26 and later, for a base that can sample its backdrop. The system
///   draws the pane, its edge and its depth. `tint`, `elevation`, the border and the highlight
///   below describe the hand-made stack, and Apple's glass takes none of them.
/// - **The opaque pane**, under Reduce Transparency, on every OS.
/// - **The hand-made stack**, everywhere else. Its six layers, bottom to top, are what make it
///   read as a physical pane rather than a translucent rectangle:
///
///   1. ``LiquidGlass/Base`` — the real blur, sampling whatever is behind the view. Or, where
///      nothing can be sampled, the fill that measures out to the same thing.
///   2. A black scrim, in Dark Mode only — see ``LiquidGlass/Density/scrimOpacity(for:)``.
///   3. A white tint — the body of the glass.
///   4. A specular gradient — a light source above and to the left, falling off fast.
///   5. An inset stroke that is bright where the light hits and dim where it does not.
///   6. Two shadows — ambient height plus a contact edge.
///
/// Glass is invisible without something behind it. Place it over content, imagery, or colour,
/// never over a flat background.
///
/// Density is a legibility decision, not only a look: a pane is only as readable as the
/// background it failed to hide. Use ``LiquidGlass/Density/frosted`` or
/// ``LiquidGlass/Density/opaque`` behind body text, and keep ``LiquidGlass/Density/sheer`` for
/// short labels and controls where a busy backdrop cannot swallow a whole sentence.
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
        routed(content)
            // Scoped to the value that changed, never a bare `withAnimation` (rule `50-views`),
            // and matched to `PressStyle`'s spring so the material and the frame move together
            // rather than arriving one after the other.
            //
            // No Reduce Motion path, deliberately: this runs only while a finger is down. That
            // rule targets loops that never stop, which is the same ruling `PressStyle` records
            // for its recoil (rule `65-accessibility`).
            .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isReacting)
    }

    // MARK: Routing

    private var rendering: LiquidGlass.Rendering {
        LiquidGlass.rendering(
            base: base,
            reduceTransparency: reduceTransparency,
            systemGlassAvailable: LiquidGlass.systemGlassAvailable
        )
    }

    @ViewBuilder
    private func routed(_ content: Content) -> some View {
        switch rendering {
        case .system: systemPane(content)
        case .opaque: content.background(opaquePane)
        case .handMade: content.background(handMadePane)
        }
    }

    /// Apple's glass. Applied **to** the content rather than laid behind it, because that is what
    /// the API is: it anchors its shape behind the view and applies the glass's foreground
    /// effects over it.
    ///
    /// The `else` and the `#else` can only be reached if `rendering` and this check ever
    /// disagree, which `theAvailabilityFlagMatchesTheRunningSystem` exists to prevent. They draw
    /// the hand-made stack rather than nothing.
    @ViewBuilder
    private func systemPane(_ content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            content
                .glassEffect(systemGlass, in: shape)
                // A pane answers a tap anywhere inside its shape. The hand-made stack gets that
                // from its fills; Apple's glass does not promise it. On iOS 26.5 a serving row in
                // History's `List` took a tap on its text and ignored one on the bare glass
                // between, while iOS 27.0 took both — so say it rather than rely on it
                // (`testAServingRowOpensItsSheetWhereverItIsTapped`).
                .contentShape(shape)
        } else {
            content.background(handMadePane)
        }
        #else
        content.background(handMadePane)
        #endif
    }

    #if os(iOS)
    @available(iOS 26.0, *)
    private var systemGlass: Glass {
        let variant = LiquidGlass.systemVariant(density: density, interactive: interactive)
        let darkening = LiquidGlass.systemTintOpacity(for: variant)

        let glass: Glass
        switch variant {
        case .regular: glass = .regular
        case .clear: glass = .clear
        }
        // `nil` rather than a clear colour: no tint at all is what the vessel is meant to get.
        let tinted = glass.tint(darkening > 0 ? Color.black.opacity(darkening) : nil)
        return interactive ? tinted.interactive() : tinted
    }
    #endif

    // MARK: Layers

    /// Translucency is the thing being turned off, so there is nothing to soften: an opaque
    /// surface, keeping only the edge and the depth.
    private var opaquePane: some View {
        shape
            .fill(base.opaqueFill)
            .overlay { shape.strokeBorder(edge, lineWidth: borderWidth) }
            .compositingGroup()
            .modifier(Shadows(elevation: elevation, colorScheme: colorScheme))
    }

    private var handMadePane: some View {
        baseLayer
            .overlay { shape.fill(Color.black.opacity(density.scrimOpacity(for: colorScheme))) }
            .overlay { shape.fill(tint.opacity(resolvedTintOpacity)) }
            .overlay { shape.fill(specular) }
            .overlay { shape.strokeBorder(edge, lineWidth: borderWidth) }
            .compositingGroup()
            .modifier(Shadows(elevation: elevation, colorScheme: colorScheme))
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

// MARK: - The primary surface

/// Draws ``LiquidGlass/Primary``. In this file and not one of its own, because the widget and the
/// watch will draw it too and the shared set does not grow (rule `15-project`).
struct PrimarySurfaceModifier<S: Shape & InsettableShape>: ViewModifier {

    var shape: S

    /// The ring is the phone's. A widget's pour button is exactly its 44pt target, and its
    /// vessel's clearance is derived from that (rule `40-widget`), so it passes `false`.
    var ring: Bool = true

    @Environment(\.colorScheme) private var colorScheme

    /// Set by ``PressStyle``, as for a glass pane.
    @Environment(\.glassIsPressed) private var isPressed

    func body(content: Content) -> some View {
        content
            // The surface owns its content's colour: a label that set `.white` itself would be
            // white on white.
            .foregroundStyle(Aurora.top)
            .background(surface)
            // The same spring as `PressStyle` and `LiquidGlassModifier`, so the wash and the
            // frame move together (rule `60-design-system`).
            .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isPressed)
    }

    private var surface: some View {
        shape
            .fill(.white)
            .overlay { shape.fill(shade) }
            .overlay {
                shape.fill(Aurora.top.opacity(isPressed ? LiquidGlass.Primary.pressedShadeOpacity : 0))
            }
            // One shadow for the assembled surface, not one per layer.
            .compositingGroup()
            .modifier(Shadows(elevation: .raised, colorScheme: colorScheme))
            .background {
                // Present at zero opacity rather than removed, so a caller that turns it off
                // changes a colour and not the view tree.
                shape
                    .inset(by: -LiquidGlass.Primary.ringWidth)
                    .fill(.white.opacity(ring ? LiquidGlass.Primary.ringOpacity : 0))
            }
    }

    private var shade: LinearGradient {
        LinearGradient(
            colors: [Aurora.top.opacity(0), Aurora.top.opacity(LiquidGlass.Primary.shadeOpacity)],
            startPoint: .top,
            endPoint: .bottom
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

    /// Places the content on the primary surface: solid white, `Aurora.top` content.
    ///
    /// One per screen, for its main action. Never give its label a foreground colour of its own.
    func primarySurface<S: Shape & InsettableShape>(in shape: S, ring: Bool = true) -> some View {
        modifier(PrimarySurfaceModifier(shape: shape, ring: ring))
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
