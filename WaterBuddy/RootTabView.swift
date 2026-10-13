//
//  RootTabView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 29/08/26.
//

import SwiftData
import SwiftUI

// MARK: - The destinations

/// The app's three destinations.
///
/// A **top-level** enum, deliberately not nested inside the view that draws it. `View` is
/// `@MainActor`, so a type declared inside one inherits that isolation and every non-isolated
/// reader needs `await` to touch it — which is exactly what `HomeView.servings` cost when
/// `@Test(arguments:)` evaluated it off the main actor and produced three *"error in the Swift 6
/// language mode"* warnings. Declaring this at file scope means the question never arises, and
/// `AppTabTests` stays non-`@MainActor` (rule `43-concurrency`).
///
/// `nonisolated` as well, since ``PageTurn`` — a plain value that decides which pages are on
/// screen — reads ``opening`` off the main actor: this target isolates an unmarked declaration
/// to it, and a `static let` on one is a main-actor property.
nonisolated enum AppTab: String, CaseIterable, Identifiable {

    case home
    case history
    case settings

    var id: String { rawValue }

    /// The tab the app opens on.
    ///
    /// Pinned separately from `allCases.first` and asserted equal to it, because the two are
    /// independently editable and a bar that opens on its second slot is a bug nobody would think
    /// to look for.
    static let opening = AppTab.home

    /// Drawn under the glyph **and** read by VoiceOver.
    ///
    /// One string for both, rather than a visible label plus a separate accessibility label: two
    /// strings for one idea is how a control comes to say different things to different users.
    /// Takes the bundle rather than reading `Bundle.main`, because the user can change the
    /// language without relaunching and a value resolved once at first access would freeze the tab
    /// bar in whatever language the app happened to launch in.
    func title(in bundle: Bundle) -> String {
        switch self {
        case .home: bundle.localizedString(forKey: "Home", value: "Home", table: nil)
        case .history: bundle.localizedString(forKey: "History", value: "History", table: nil)
        case .settings: bundle.localizedString(forKey: "Settings", value: "Settings", table: nil)
        }
    }

    /// The glyph. There is no separate filled variant for the active state — the glow and the
    /// colour carry that, and `list.bullet` has no `.fill` counterpart to pair with `drop.fill`
    /// anyway, so a two-symbol scheme would have had to invent one.
    ///
    /// `gearshape.fill` rather than the outline the log's old header button used: at the bar's
    /// 18pt these glyphs are read by silhouette, and a filled gear survives that where a thin
    /// outline turns to mush. The set is deliberately not uniform in weight — recognition beats
    /// consistency in a three-slot bar.
    ///
    /// The sizes and the glow are the app's own bar's, below iOS 26. Apple's bar is handed the
    /// same three symbols and draws them, and the selected one, its own way.
    var symbol: String {
        switch self {
        case .home: "drop.fill"
        case .history: "list.bullet"
        case .settings: "gearshape.fill"
        }
    }
}

// MARK: - The container

/// The app proper, once setup is done: three pages, one sky behind them, and the bar that turns
/// between them.
///
/// **A change of tab slides the pages by direction.** They sit side by side in the bar's order:
/// going to a tab on the right, its page comes in from the right as the old one leaves to the
/// left, both on screen and moving together (``PageTurn``, ``Motion/page``). Under Reduce
/// Motion nothing travels and the page cross-fades (rule `65-accessibility`).
///
/// **One sky, and it is this view's.** The three screens each drew their own
/// ``AuroraBackground`` while a change of tab was a cut or a cross-fade in place. A backdrop
/// inside a page slides with the page, so the pages are clear and the one behind them holds
/// still. The first-run screen and the serving sheet are not pages and keep their own; every
/// backdrop reads one clock, so the swap from setup to here is still one surface.
///
/// **A page is built when it is shown and gone when its slide has ended.** Two exist for the
/// length of a slide and one otherwise, so a screen always opens at its top, History on today,
/// and Home's *Undo* ends when its tab is left — by being rebuilt, as they were before the bar
/// was Apple's. The page that is leaving is hidden from accessibility and takes no touch.
///
/// **Why not Apple's `TabView`.** It was this view's container on iOS 26 and later for one
/// build. It removes the old page in a single frame and offers no transition, and the owner,
/// holding that build on a phone, saw no animation in a change of page. Its bar is kept and
/// its container is not: ``SystemTabBar`` is the same `UITabBar`, standing alone
/// (`docs/superpowers/specs/2026-10-12-page-slide-and-touches-design.md`).
///
/// `SettingsView` joined them when the gear in `HistoryView`'s header became a third tab. One
/// screen of preferences reached through *another* screen's header is a route a user finds once
/// and then hunts for; the header comment that argued against a third tab is superseded by this
/// one.
///
/// `preferredColorScheme(.dark)` lives **here** rather than on each screen. All three used to
/// declare it: `HomeView` because the backdrop is a committed dark surface, `HistoryView` and
/// `SettingsView` because a sheet has a hosting controller of its own. With a tab bar there is one
/// screen and one hosting controller, so one declaration — children each stating a window-level
/// preference is duplication that can only drift.
///
/// **Two bars, chosen by the system and by nothing else.** On iOS 26 and later the bar is
/// Apple's: the glass, the lens that follows a finger dragged along it, and whatever iOS makes
/// of it next. Below iOS 26 Apple's bar is the flat one, so the app keeps its own. The branch
/// cannot change while the app runs, and the floor stays iOS 17.
struct RootTabView: View {

    /// Which page is showing, which is still leaving, and which way the shown one came.
    /// Presentation state, which is the only kind a view owns (rule `50-views`) — nothing about
    /// the tab is persisted, so a relaunch opens on Home.
    @State private var turn = PageTurn()

    @Environment(\.strings) private var strings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Whether a change of page carries the pages across the screen, or cross-fades them.
    private var slides: Bool { !reduceMotion }

    var body: some View {
        GeometryReader { proxy in
            // The whole screen's width, not the safe area's: in landscape a page moved by the
            // lesser of the two would stop with a strip of itself still showing.
            let width = proxy.size.width + proxy.safeAreaInsets.leading + proxy.safeAreaInsets.trailing

            ZStack {
                AuroraBackground()

                ForEach(turn.mounted) { tab in
                    page(tab)
                        // The page the app opens on settles in, section by section; a page that
                        // slides in is whole as it comes (``Arrival``).
                        .environment(\.pageSettlesIn, turn.turns == 0)
                        // The page shown stands in place; the one leaving is moved a whole width
                        // out the far side, by the same animation that brings the other in.
                        .offset(x: turn.offset(of: tab, across: width, slides: slides))
                        .opacity(turn.opacity(of: tab, slides: slides))
                        // **Only the way in is a transition.** A page's direction is known when
                        // it is inserted. On the way out it would be the direction of the turn
                        // that brought it in — a removal's transition is the one the view was
                        // last drawn with — so the page leaving is not removed at the turn: it
                        // is moved by the offset above and removed, with nothing to animate,
                        // when the slide has ended.
                        .transition(.asymmetric(insertion: entry(across: width), removal: .identity))
                        // Two pages exist for the length of a slide. VoiceOver and a finger get
                        // the one that is arriving.
                        .accessibilityHidden(tab != turn.shown)
                        .allowsHitTesting(tab == turn.shown)
                        .zIndex(tab == turn.shown ? 1 : 0)
                }
            }
            // Scoped to the value that changed, never a bare `withAnimation` (rule `50-views`).
            // A transaction rather than `.animation(_:value:)` because the end of the slide has
            // to be known: that is when the page that left is taken out of the tree.
            .transaction(value: turn.shown) { transaction in
                transaction.animation = slides ? Motion.page : Motion.pageFade
                let started = turn.turns
                // `settle` checks that no turn has been made since this one: a slide that ends
                // after another has begun must not remove the page that one is still moving.
                transaction.addAnimationCompletion { turn.settle(started) }
            }
            .overlay(alignment: .bottom) { shade }
            // `safeAreaInset` both floats the bar and *reserves* the space under it, so
            // `HistoryView`'s `List` ends above the glass instead of scrolling its last serving
            // underneath it. An overlay would have floated it and occluded that row.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bar(reaching: proxy.safeAreaInsets.bottom)
            }
        }
        // A tick as the selection moves, on either bar. Off the view's own state, which only the
        // user's tap or drag changes (rule `60-design-system`).
        .sensoryFeedback(Haptics.select, trigger: turn.shown)
        // The backdrop is a committed dark surface in either system appearance, so everything on
        // top of it should resolve against dark rather than against the phone's setting.
        //
        // This must be `preferredColorScheme`, not `.environment(\.colorScheme, .dark)`. The
        // environment value only travels *down* the view tree: it would dress the glass correctly
        // and still leave the status bar drawing black glyphs on the indigo backdrop (1.57:1) on
        // a Light Mode device. `preferredColorScheme` travels *up* as a preference to the hosting
        // controller, which sets the window's interface style — so the clock and battery turn
        // white (13.39:1), and the subtree still reads `.dark`.
        //
        // Written on `HomeView` until the tab bar gave the two screens one container; the widget
        // deliberately uses the environment form instead, for the opposite reason — it has no
        // status bar and no hosting controller to hear a preference (rule `50-views`).
        .preferredColorScheme(.dark)
    }

    /// One tab's page. Built when its tab is shown and gone when its slide out has ended, so a
    /// page's own state lives as long as the page is on screen. (A tab returned to before its
    /// page had finished leaving gets that same page back, state and all: it never left.)
    @ViewBuilder
    private func page(_ tab: AppTab) -> some View {
        switch tab {
        case .home: HomeView()
        case .history: HistoryView()
        case .settings: SettingsView()
        }
    }

    /// How the page shown comes in: from a whole width out on the side its tab is on, or, under
    /// Reduce Motion, by fading in where it stands.
    private func entry(across width: CGFloat) -> AnyTransition {
        slides ? .offset(x: turn.entry(across: width, slides: true)) : .opacity
    }

    /// The bar's binding. Reading it gives the page shown; setting it turns the page, which is
    /// what makes a tap and a drag along Apple's bar the same thing to this view.
    private var selection: Binding<AppTab> {
        Binding(get: { turn.shown }, set: { turn.turn(to: $0) })
    }

    /// The bar, by the system's version and by nothing else.
    ///
    /// Apple's bar asks for its own height — 83 pt on a phone with a home indicator — and stands
    /// at the foot of the screen, not above the indicator. Pulled down by the bottom inset it
    /// is where the system puts its own, and the pages' safe area ends at its top: measured
    /// against a `TabView`'s bar on iOS 27.0, no pixel of the screen's foot differed.
    @ViewBuilder
    private func bar(reaching foot: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            SystemTabBar(selection: selection, titles: AppTab.allCases.map { $0.title(in: strings) })
                .padding(.bottom, -foot)
        } else {
            GlassTabBar(selection: selection)
        }
    }

    /// ``BarShade``, drawn over the foot of the pages and under Apple's bar: a ramp ending at
    /// the bar's top, and from there the full shade to the foot of the screen. The app's own
    /// bar carries its own pane and takes none.
    ///
    /// Over the content and not under it, so what scrolls toward the bar dims as it goes — the
    /// same thing the system's own scroll edge does. The second layer has no height of its own:
    /// it is the part of the screen under the bar, outside the pages' safe area.
    ///
    /// **Drawn once, here, and not by each page**: the bar does not move in a change of page,
    /// and neither may the ground it was measured on.
    @ViewBuilder
    private var shade: some View {
        if #available(iOS 26.0, *) {
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [.clear, .black.opacity(BarShade.opacity)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: BarShade.ramp)

                Color.black.opacity(BarShade.opacity)
                    .ignoresSafeArea(edges: .bottom)
                    .frame(height: 0)
            }
            // To the screen's own edges in landscape, where the safe area stands in from the
            // sides and the shade would otherwise end in two upright edges.
            .ignoresSafeArea(edges: .horizontal)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

// MARK: - Apple's bar

/// Apple's own tab bar, standing alone: a `UITabBar` with no tab controller round it.
///
/// **The bar is the system's and the pages are the app's.** Inside a `TabView` the system owns
/// the change of page as well, and makes it a cut. Alone, the bar still draws its glass and its
/// lens, still answers a tap and a press dragged along it, and reports the tab chosen to a
/// delegate — which is all this view asks of it.
///
/// It is given the titles already resolved, in the app's language, and is handed new ones when
/// the language changes. The symbols are ``AppTab/symbol``, as the app's own bar draws them.
///
/// **On iOS 26.x its glass is darker than a `TabView`'s** over the same aurora; on iOS 27.0
/// the two are identical. Not cured by the bar's appearance objects, nor by a tab controller
/// only as tall as the bar: it seems to need the pages inside the controller
/// (`docs/DESIGN.md`, *Apple's tab bar, measured*).
@available(iOS 26.0, *)
private struct SystemTabBar: UIViewRepresentable {

    @Binding var selection: AppTab

    /// One per tab, in the bar's order.
    let titles: [String]

    func makeCoordinator() -> Coordinator {
        Coordinator(selection: $selection)
    }

    func makeUIView(context: Context) -> UITabBar {
        let bar = UITabBar()
        bar.delegate = context.coordinator
        // The selected tab's glyph and caption. White, not `Aurora.cyan`: on iOS 26.5 the system
        // draws the selected lozenge lighter than the bar, and cyan on it read 3.98:1
        // (`docs/DESIGN.md`, *Apple's tab bar, measured*).
        bar.tintColor = .white
        return bar
    }

    func updateUIView(_ bar: UITabBar, context: Context) {
        context.coordinator.selection = $selection

        // Rebuilt only when a title has changed — a change of language — and not on every
        // update: new items would restart the lens wherever it stood.
        if bar.items?.map({ $0.title ?? "" }) != titles {
            bar.items = zip(AppTab.allCases, titles).enumerated().map { place, tab in
                UITabBarItem(title: tab.1, image: UIImage(systemName: tab.0.symbol), tag: place)
            }
        }

        let place = AppTab.allCases.firstIndex(of: selection) ?? 0
        if bar.selectedItem?.tag != place {
            bar.selectedItem = bar.items?.first { $0.tag == place }
        }
    }

    final class Coordinator: NSObject, UITabBarDelegate {

        var selection: Binding<AppTab>

        init(selection: Binding<AppTab>) {
            self.selection = selection
        }

        func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            guard AppTab.allCases.indices.contains(item.tag) else { return }
            selection.wrappedValue = AppTab.allCases[item.tag]
        }
    }
}

/// The shade drawn at the foot of the pages, under Apple's tab bar.
///
/// **Measured, not chosen.** Apple's bar is glass over whatever is behind it, and behind it here
/// is the aurora at its brightest — the magenta light sits at the foot of the screen. On iOS 27.0
/// every caption passes without help. On iOS 26.5 the system draws the *selected* tab's lozenge
/// lighter than the bar and mixes its caption toward it, and that caption read 3.79–4.46:1
/// against the 4.5:1 floor whatever tint the bar was given. The lozenge follows its backdrop, so
/// the backdrop is what is darkened: `0.20` left the worst frame of a minute at 4.78:1, and this
/// is the first rung with room (`theShadeIsNoLighterThanTheFirstRungWithRoom`).
///
/// A value at file scope and `nonisolated`, so `BarShadeTests` reads it off the main actor (rule
/// `43-concurrency`). Drawn on iOS 26 and later only: the app's own bar carries its own pane.
nonisolated enum BarShade {

    /// How dark the ground under the bar is made.
    static let opacity: Double = 0.25

    /// The height the shade fades in over, above the bar. No taller than the padding Home keeps
    /// at its foot (`theRampFitsInsideHomesFoot`), so where Home fits its screen the ramp dims
    /// nothing Home draws. On a 375 × 667 pt phone Home's vessel is at its floor and the
    /// vessels' names stand in the ramp: read off one capture on iOS 26.5, the three were
    /// 8.0, 7.0 and 5.6:1.
    static let ramp: CGFloat = 20
}

// MARK: - The app's own bar

/// The floating glass bar — the app's own, drawn below iOS 26. On iOS 26 and later the bar is
/// Apple's (``SystemTabBar``) and none of this is built.
///
/// `.frosted` and `.floating` — the highest pair in the design system, and the only place in the
/// app that uses it. This is the one pane that sits *over* other panes: the vessel is `.floating`
/// but nothing overlaps it, while the bar overlaps the quick-add row's `.raised` glass. A lighter
/// density here would read as a smear over the buttons behind it rather than as a surface above
/// them (rule `60-design-system`).
private struct GlassTabBar: View {

    @Binding var selection: AppTab

    @Environment(\.strings) private var strings

    /// A real magnitude, not a unitless `1` — `@ScaledMetric` resolves through `UIFontMetrics`,
    /// which rounds to the nearest third of a point (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .caption2) private var scaledGlyph: CGFloat = 18

    /// Capped so the bar cannot eat the screen at the accessibility sizes. A tab bar has nowhere
    /// to scroll to, so the ceiling is the only thing keeping it off the vessel.
    private var glyph: CGFloat { min(scaledGlyph, 30) }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(6)
        .liquidGlass(
            in: RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous),
            density: .frosted,
            elevation: .floating
        )
        // Capped, then centred. `.padding(.horizontal, 44)` alone is a *proportional* inset, so the
        // bar grows with the container: the wider the screen, the wider each of the three slots.
        // The cap is what keeps this a floating pill rather than a stretched toolbar.
        //
        // The measurement that produced 420 was taken on an iPad Pro 11-inch, where the app ran
        // 1,210 x 834 in landscape and the bar came out 1,120pt wide with a 553pt *History*
        // button. iPad support was dropped on 2026-09-02 (`TARGETED_DEVICE_FAMILY = 1`), so that
        // device can no longer produce the failure — but the cap is kept rather than reverted,
        // because it is not iPad-specific: 420 is below the widest iPhone's own content width, so
        // removing it would visibly widen the bar on every large phone in landscape. Keeping it
        // changes nothing on any shipping device; removing it is a layout change needing its own
        // verification pass. `theBarHoldsThreeTabs` still pins the 44pt floor inside this cap.
        .frame(maxWidth: 420)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 44)
        .padding(.bottom, 4)
        .animation(.smooth(duration: 0.28), value: selection)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isActive = tab == selection

        return Button {
            selection = tab
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.symbol)
                    .font(.system(size: glyph, weight: .semibold))
                    // One box for three glyphs of three heights. Without it each caption hung
                    // under its own glyph, and *History* stood two and a half points above the
                    // other two (`testTheBarsCaptionsShareALine`).
                    .frame(height: glyph * 1.2)
                    .foregroundStyle(isActive ? Aurora.cyan : Color.white.opacity(0.72))
                    // The glow, and it is two shadows for the same reason the design system's
                    // elevation is: one alone either hugs the glyph with no bloom or floats with
                    // no core. Both are `.clear` when inactive, so the modifier is present in
                    // either branch and SwiftUI animates the colour rather than inserting and
                    // removing a layer.
                    .shadow(color: isActive ? Aurora.cyan.opacity(0.55) : .clear, radius: 9)
                    .shadow(color: isActive ? Aurora.cyan.opacity(0.40) : .clear, radius: 3)

                Text(tab.title(in: strings))
                    // Sized as a ratio of the glyph it annotates, never with its own text style.
                    // The glyph is capped at 30pt and a text style is not, so `.caption2` would
                    // overtake it at the accessibility sizes — the inversion rule
                    // `65-accessibility` names, and the one the quick-add caption already hit.
                    // 0.62 x 18pt is 11.2pt, which is where `.caption2` sits.
                    .font(.system(size: glyph * 0.62, weight: .semibold))
                    // **The label stays white even when the tab is active, and that is measured.**
                    // Sampled off the rendered bar, the pane is sRGB (0.388, 0.282, 0.484), and
                    // `Aurora.cyan` on it is **4.34:1** — under the 4.5:1 that rule
                    // `65-accessibility` requires of small text. The *glyph* may still be cyan:
                    // an icon is not text and its floor is 3:1, which 4.34:1 clears. White at
                    // 0.72 measures **4.89:1** and full white **7.66:1**, so the state is carried
                    // by the glyph's colour and glow rather than by tinting the caption below the
                    // line. All four figures were sampled from a rendered screenshot, not derived
                    // — the pane is a `Material` over the aurora and cannot be computed.
                    //
                    // They are the hand-made bar's figures, from before the lozenge below. With
                    // it the active caption sits on a lighter fill and reads at least 5.0:1 on
                    // every path (`docs/DESIGN.md`, *Selection*).
                    .foregroundStyle(.white.opacity(isActive ? 1 : 0.72))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            // The whole slot is the target, not just the glyph — 44pt is the floor and the width
            // is shared evenly (rule `65-accessibility`).
            .frame(maxWidth: .infinity, minHeight: 44)
            .background {
                // The active tab's lozenge: History's shown-day treatment, from the same two
                // tokens, so "selected" is drawn one way in the app. Present for every slot at
                // zero opacity rather than inserted for one, so moving the selection animates a
                // colour instead of a layer (rule `50-views`). It adds to the glyph's colour, its
                // glow and the `.isSelected` trait; it replaces none of them.
                Capsule()
                    .fill(.white.opacity(isActive ? LiquidGlass.Selection.fillOpacity : 0))
                    .strokeBorder(.white.opacity(isActive ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        // Label and trait go on the `Button`, never on a wrapping
        // `.accessibilityElement(children: .ignore)` — that adds a stop instead of replacing one
        // when what it wraps is a control, which is how `HistoryView`'s rows were once announced
        // twice (`tasks/lessons.md`).
        .accessibilityLabel(tab.title(in: strings))
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }
}

// MARK: - Preview

#Preview {
    // A throwaway suite *and* an in-memory store, so previewing never writes into the real store
    // (rule `50-views`). `reloadWidgets: {}` matters as much: the canvas must not ring the real
    // WidgetKit doorbell.
    let defaults = UserDefaults(suiteName: "preview.waterbuddy.roottab")!
    defaults.removePersistentDomain(forName: "preview.waterbuddy.roottab")

    let manager = DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        reloadWidgets: {},
        // The production default builds a real `UNUserNotificationCenter`; a canvas rebuild must
        // not reconcile the user's actual reminders (rule `85-testing`, `tasks/lessons.md`).
        rescheduleReminders: { _ in },
        // The production default reaches a real `WCSession`; same reasoning as above.
        publishWrist: { _ in }
    )
    manager.addLog(amount: 250)
    manager.addLog(amount: 500)

    return RootTabView().environment(manager)
}
