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
enum AppTab: String, CaseIterable, Identifiable {

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
    var symbol: String {
        switch self {
        case .home: "drop.fill"
        case .history: "list.bullet"
        case .settings: "gearshape.fill"
        }
    }
}

// MARK: - The container

/// The app proper, once setup is done: three screens and the bar that swaps them.
///
/// All three screens draw their own ``AuroraBackground``, which is why the swap reads as one
/// continuous surface rather than as screens trading places — the same ruling `RootView` already
/// records for the setup-to-app transition. Only the content cross-fades.
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
struct RootTabView: View {

    /// Which destination is showing. Presentation state, which is the only kind a view owns
    /// (rule `50-views`) — nothing about the tab is persisted, so a relaunch opens on Home.
    @State private var tab: AppTab = .opening

    var body: some View {
        ZStack {
            switch tab {
            case .home:     HomeView().transition(.opacity)
            case .history:  HistoryView().transition(.opacity)
            case .settings: SettingsView().transition(.opacity)
            }
        }
        // Scoped to the value that changed, never a bare `withAnimation` (rule `50-views`). This
        // runs once per tap rather than forever, so it needs no Reduce Motion path — that rule
        // targets loops that never stop, as `PressStyle` already records.
        .animation(.smooth(duration: 0.28), value: tab)
        // `safeAreaInset` both floats the bar and *reserves* the space under it, so `HistoryView`'s
        // `List` ends above the glass instead of scrolling its last serving underneath it. An
        // overlay would have floated it and occluded that row.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GlassTabBar(selection: $tab)
        }
        // The backdrop is a committed dark surface in either system appearance, so everything on
        // top of it should resolve against dark rather than against the phone's setting.
        //
        // This must be `preferredColorScheme`, not `.environment(\.colorScheme, .dark)`. The
        // environment value only travels *down* the view tree: it would dress the glass correctly
        // and still leave the status bar drawing black glyphs on the indigo backdrop (1.57:1) on a
        // Light Mode device. `preferredColorScheme` travels *up* as a preference to the hosting
        // controller, which sets the window's interface style — so the clock and battery turn
        // white (13.39:1), and the subtree still reads `.dark`.
        //
        // Written on `HomeView` until the tab bar gave the two screens one container; the widget
        // deliberately uses the environment form instead, for the opposite reason — it has no
        // status bar and no hosting controller to hear a preference (rule `50-views`).
        .preferredColorScheme(.dark)
    }
}

// MARK: - The bar

/// The floating glass bar.
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
