//
//  WristView.swift
//  WaterBuddyWatch
//
//  The one screen (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §8):
//  vessel, the servings, "Synced Nm ago" — always present, never an alert. Deliberately no
//  settings, goal editor, history or reminders here; each would author state the watch cannot own
//  (v1 scope, owner-confirmed).
//
//  The three pour rows that used to sit under the vessel are gone. The **vessel itself** is now the
//  pour button for one serving, and the other two live behind a single button pinned to the bottom
//  of the viewport (owner-approved, this pass). A watch screen has room for one obvious action, and
//  stacking three equal-weight rows under a 140pt circle meant the circle — the thing the whole
//  screen is about — was the one part of it you could not touch.
//

import SwiftUI

// MARK: - Layout constants

/// Off the bezel. A capsule flush to the edge of a round-rect display reads as clipped rather than
/// as a button.
///
/// File scope rather than a `private static` on `WristView`, because `WristServingMenu` below needs
/// the identical figures and Swift's `private` does not reach a sibling type even in the same file.
/// `nonisolated` for the reason rule `43-concurrency` gives: `SWIFT_DEFAULT_ACTOR_ISOLATION =
/// MainActor` infers `@MainActor` onto an unmarked declaration, and these are read from
/// `nonisolated` contexts.
nonisolated let wristScreenInset: CGFloat = 8

/// Inside the capsule. `HistoryView.ServingRow` uses 22pt, which is 5.6% of a 393pt iPhone; the same
/// proportion of a 41mm watch's ~176pt is 9.9, so: 10. Derived rather than picked, the way
/// `MiniVessel`'s own sizing is (rule `60-design-system`), and then confirmed by rendering — a
/// derivation is where a number starts, not proof that it looks right.
///
/// The rows this replaces had **no horizontal padding at all**: the `HStack` filled the row and the
/// capsule wrapped it exactly, so "Cup" sat flush against the left rim and "150 ml" against the
/// right. Nothing else in this codebase draws a capsule that way.
nonisolated let wristCapsuleInset: CGFloat = 10

/// The capsule's vertical inset. Named for the same reason ``wristCapsuleInset`` is, and because it
/// is used by two types: the "More" button and the sheet's own rows have to be the same lockup, and
/// two bare `10`s in two files is how they stop being.
nonisolated let wristCapsuleVerticalInset: CGFloat = 10

/// A `minHeight`, never a fixed `height`, so a target grows with Dynamic Type instead of clipping
/// (rule `65-accessibility`'s 44pt floor).
nonisolated let wristMinimumTarget: CGFloat = 44

// MARK: - One offered serving

/// A slot from `vesselSlots` married to the amount the phone last published for it.
///
/// **File scope, not nested inside `WristView`**, for the reason rule `43-concurrency` gives: a
/// `View` is `@MainActor`, so a type declared inside one inherits that isolation, and
/// `WristViewLogicTests` is deliberately not `@MainActor`. `AppTab` and `ConfettiPiece` are the
/// precedent on the phone side; this is the watch's.
nonisolated struct WristServing: Equatable, Identifiable {
    let nameKey: String
    let symbol: String
    let amount: Int

    /// The slot's name, not the amount. Two vessels holding the same figure is a state the user is
    /// allowed to choose (rule `20-state`), so keying a `ForEach` on the amount would collapse two
    /// legitimate rows into one.
    var id: String { nameKey }

    /// The slot's name in the language being drawn — `HomeView.Serving.name(in:)`'s twin, down to
    /// the `value:` fallback. A function taking a bundle rather than a stored string, so a language
    /// switch reaches it (`tasks/lessons.md`, 2026-08-29).
    func name(in bundle: Bundle) -> String {
        bundle.localizedString(forKey: nameKey, value: nameKey, table: nil)
    }
}

// MARK: - The screen

struct WristView: View {

    @State private var model = WristModel.shared
    @State private var now = Date()
    @State private var isMenuPresented = false

    @Environment(\.strings) private var strings

    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    /// The share of the screen's safe area the vessel's box may take — **a fraction, not a fixed
    /// height**, and that is the whole point.
    ///
    /// Two fixed heights were tried and both were rendered and rejected. At 140 (the figure the
    /// three-row layout used) the vessel, the caption and the button together overflowed a 46mm and
    /// the button was cut off by the screen edge; at 120 it still overflowed, by about 23pt. A fixed
    /// number cannot be right on a range of screens that runs from a 40mm to a 49mm, which is
    /// exactly the reasoning `WristVessel.diameter(fitting:within:)` already applies one level down.
    ///
    /// The furniture below the vessel is a two-line `.caption2` (~32pt), a 44pt button and two 10pt
    /// gaps — ~96pt of fixed height that does not scale with the screen. Half was where that
    /// arithmetic landed first, and `diameter(fitting:within:)`'s own 60pt floor guards the bottom
    /// end of the range.
    ///
    /// **0.78125 — the owner asked for 25% bigger twice, and the two steps compound: 0.5 × 1.25 ×
    /// 1.25.** The vessel is height-bound on every watch (its box is far narrower than the screen),
    /// so the box's share of the height *is* the diameter, and a 25% ask is a 25% multiplication
    /// here.
    ///
    /// Each step is spent out of the screen's slack, never out of the furniture: the button keeps
    /// its 44pt floor and the caption keeps both its lines, because rule `65-accessibility` sets the
    /// first and spec §8 sets the second. What a bigger circle buys in presence it pays for in
    /// reach — at this fraction the "More" button sits below the fold at rest on every size and is
    /// found by turning the crown. That is a deliberate, owner-directed trade, recorded here so the
    /// next reader does not "fix" it back.
    ///
    /// **On the two smallest watches (40mm, 42mm) the screen scrolls, and that is deliberate.**
    /// Verified by rendering on a 40mm: its safe area is ~134pt while the furniture alone is ~95pt,
    /// so even at the 60pt floor the vessel cannot fit beside it — *no* value of this fraction makes
    /// that screen static. The choice is therefore between a short crown scroll and a ~6pt
    /// `volume / goal` readout (`WristVessel` sizes its type as a ratio of the diameter), and the
    /// scroll is plainly the better one — which is the same judgement
    /// `diameter(fitting:within:)`'s own floor already records: "a vessel that small is worse than a
    /// clipped one". `.scrollBounceBehavior(.basedOnSize)` keeps the screen static wherever it does
    /// fit, so the larger watches pay nothing for this.
    private static let vesselHeightFraction: CGFloat = 0.78125

    /// Index 1 of `vesselSlots` and of `Key.servings` — "Glass". Named once rather than spelled `1`
    /// at three sites: rule `20-state` calls this position "the vessel the widget follows", and a
    /// bare literal in three places is exactly how the phone widget and the watch would drift into
    /// following different ones.
    ///
    /// `nonisolated` is load-bearing, not decoration. Without it this is inferred `@MainActor`
    /// (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is set on every target) and the three
    /// `nonisolated static func`s below cannot read it — four *"main actor-isolated static property
    /// … can not be referenced from a nonisolated context"* warnings, which is a Swift 6 error
    /// later. Rule `43-concurrency` names `HomeView.servings` and `AuroraBackground.lights` as the
    /// same case; this is the watch's third.
    nonisolated private static let primaryIndex = 1

    /// The screen is **never** gated on having heard from the phone.
    ///
    /// It used to be: `if let mirror = model.mirror, mirror.isGoalSet` drew everything, and both
    /// halves of that condition fell through to one dead-end sentence telling the user to open their
    /// iPhone. That produced a first-mirror deadlock — the only watch-side action that makes the
    /// phone publish is a pour, and the pour rows were behind the gate a mirror was needed to open —
    /// and it made two helpers written *for* the pre-sync case (`resolveServings(from: nil)`,
    /// `syncedCaption(composedAt: nil, …)`) unreachable in production while their tests stayed green.
    ///
    /// The number is never presented as more certain than it is: ``WristModel/displayGoal`` names
    /// the goal actually in use, and ``attribution(mirror:now:strings:)`` — always on screen,
    /// outside every branch, as spec §8 requires — says whether it came from the phone or is still
    /// the default.
    ///
    /// **A `ScrollView`, not a `List`.** With three stacked items there is nothing left for a `List`
    /// to do, and its own row insets were half of why the capsules were mis-padded — every row
    /// needed a `.listRowBackground(Color.clear)` to undo a surface the design never wanted.
    ///
    /// **The button is in the flow, pushed down by a `Spacer`, and deliberately *not* mounted
    /// through `.safeAreaInset(edge: .bottom)`.** That was the first attempt and it was rendered and
    /// rejected: `safeAreaInset` reserves the bar's height *for scrolling*, not for the resting
    /// layout — rule `50-views` says so in as many words — so at rest the capsule drew straight over
    /// the bottom of the vessel and pushed the attribution line below it, inverting the very order
    /// the design settled on. The screenshot is in this pass's `HISTORY.md` entry.
    ///
    /// `GeometryReader` + `.frame(minHeight:)` + `.scrollBounceBehavior(.basedOnSize)` is rule
    /// `65-accessibility`'s own prescribed shape for a screen that should fill the viewport at
    /// ordinary text sizes and scroll at the accessibility ones. The `Spacer(minLength: 0)` is what
    /// puts the button at the bottom of the viewport when there is room and lets it flow when there
    /// is not — "at the bottom" without a floating bar that can cover what it sits above.
    var body: some View {
        let others = Self.secondary(from: model.mirror)

        return ZStack {
            WristAurora()

            GeometryReader { proxy in
                ScrollView {
                    // 6, not 10: the 25% bigger vessel spends the screen's slack, and the two gaps
                    // are the only place left to claw any back that doesn't cost the button its
                    // 44pt floor or the caption its second line.
                    VStack(spacing: 6) {
                        vessel(boxedInto: proxy.size.height * Self.vesselHeightFraction)
                        attributionLine
                        Spacer(minLength: 0)
                        menuButton(offering: others)
                    }
                    .padding(.horizontal, wristScreenInset)
                    .frame(minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .onReceive(clock) { now = $0 }
        // `isPresented:` rather than rule `50-views`' usual `.sheet(item:)`, and the exception is
        // principled: that rule exists to stop "a `Bool` plus a separately-stored selection", where
        // the two can disagree. There is no selection here — the sheet is a menu of actions, not an
        // editor for a thing — so there is no second piece of state to fall out of step.
        .sheet(isPresented: $isMenuPresented) {
            WristServingMenu(servings: others) { model.pour(amount: $0) }
        }
    }

    // MARK: - The vessel, which is now the pour button

    /// The circle is the control. Its accessibility label, value and hint sit on the **`Button`**,
    /// not on an `.accessibilityElement(children: .ignore)` wrapper around it — rule
    /// `65-accessibility`, and `HistoryView.ServingRow` records what the wrapper actually costs:
    /// every serving announced twice, visible only in a real accessibility tree and in no unit test
    /// this project can write. ``WristVessel`` gave those three modifiers up for this.
    ///
    /// `.contentShape(Circle())` is what keeps the target honest. The label is a square frame with
    /// the circle inscribed, so without it the dead corners either side of the vessel would pour
    /// water — a tap that logs a serving because you brushed the edge of the screen.
    private func vessel(boxedInto height: CGFloat) -> some View {
        let serving = Self.primary(from: model.mirror)
        let progress = model.displayGoal > 0 ? Double(model.todaysTotal) / Double(model.displayGoal) : 0
        let percentage = Int((progress * 100).rounded())

        return GeometryReader { proxy in
            let diameter = WristVessel.diameter(fitting: proxy.size.width, within: proxy.size.height)
            Button {
                model.pour(amount: serving.amount)
            } label: {
                WristVessel(
                    level: min(1, progress),
                    percentage: percentage,
                    volume: model.todaysTotal,
                    goal: model.displayGoal,
                    diameter: diameter
                )
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            // The phone vessel's own sentence, so VoiceOver reads the same figures the same way on
            // both devices (spec 2026-10-06 §3, ruling 5).
            .accessibilityValue(String(format: strings.localizedString(forKey: "%1$d percent. %2$d of %3$d millilitres.", value: nil, table: nil), percentage, model.todaysTotal, model.displayGoal))
            .accessibilityHint(String(format: strings.localizedString(forKey: "Logs %1$d millilitres", value: nil, table: nil), serving.amount))
            .position(x: proxy.size.width / 2, y: diameter / 2)
        }
        .frame(height: height)
    }

    // MARK: - The attribution line and the menu

    /// Named `attributionLine`, not `attribution`: a private computed property of that name shadows
    /// the `static func attribution(mirror:now:strings:)` it is trying to call, and
    /// `Self.attribution(…)` then fails to resolve. Caught at compile time here, but the same
    /// collision with a *different* return type would have compiled and drawn the wrong thing.
    private var attributionLine: some View {
        Text(Self.attribution(mirror: model.mirror, now: now, strings: strings))
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    /// Everything the vessel does not pour, behind one button.
    ///
    /// **A `Button` presenting a `.sheet`, not a `Menu`.** `Menu` is unavailable on watchOS — the
    /// compiler is unambiguous about it (*"'Menu' is unavailable in watchOS"*), so the shape the
    /// design asked for is reached with the platform's own equivalent rather than abandoned.
    ///
    /// Hidden outright when there is nothing to offer rather than shown as a button that opens onto
    /// an empty sheet — which is reachable, not hypothetical: a mirror can carry a servings array
    /// too short to fill the slots (see ``secondary(from:)``), and a control that does nothing when
    /// tapped is worse than one that isn't there.
    @ViewBuilder
    private func menuButton(offering others: [WristServing]) -> some View {
        if !others.isEmpty {
            Button {
                isMenuPresented = true
            } label: {
                Label {
                    Text("More", bundle: strings)
                } icon: {
                    Image(systemName: "ellipsis")
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, wristCapsuleInset)
                .padding(.vertical, wristCapsuleVerticalInset)
                .frame(maxWidth: .infinity, minHeight: wristMinimumTarget)
                // `.sheer`: a short label and a control, not sentence-length text — the density the
                // rows this replaces already used (rule `60-design-system`).
                .liquidGlass(in: Capsule(), density: .sheer)
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            // No `.accessibilityLabel`: VoiceOver reads the visible "More", then the hint. A
            // control's visible text and its VoiceOver label are one string (rule `65-accessibility`).
            .accessibilityHint(Text("Shows the other serving sizes", bundle: strings))
        }
    }

    // MARK: - The pure functions the screen reads from

    /// `mirror.servings` when a mirror has arrived; `DataManager.defaultServings` before the first
    /// sync — never an empty row, and never invented amounts the phone hasn't confirmed once one
    /// has arrived.
    nonisolated static func resolveServings(from mirror: WristMirror?) -> [Int] {
        mirror?.servings ?? DataManager.defaultServings
    }

    /// Every serving the screen offers, each slot married to its amount.
    ///
    /// **`zip` is the arity guard, and deliberately the only one.** `WristMirror.servings` crosses
    /// the wire as a bare `[Int]`: `DataManager`'s own setter rejects any triple that is not exactly
    /// three long, but nothing re-checks that on this side of the transfer. Truncating to the
    /// shorter of the two is what keeps a malformed publish a *smaller menu* rather than a crash —
    /// the same discard-rather-than-repair instinct rule `20-state` applies to
    /// `resolveServings(in:)`, one device further out.
    nonisolated static func servings(from mirror: WristMirror?) -> [WristServing] {
        zip(vesselSlots, resolveServings(from: mirror)).map { slot, amount in
            WristServing(nameKey: slot.nameKey, symbol: slot.symbol, amount: amount)
        }
    }

    /// The serving the vessel itself pours: the phone's **middle** quick-add vessel, index 1 — the
    /// same one `AddWaterIntent` logs from the Home Screen widget (rule `40-widget`), so the two
    /// ambient front doors on the two devices cannot disagree about what one tap means.
    ///
    /// **Non-optional by construction, and that is the point.** `vesselSlots` is a compiled-in
    /// constant of exactly three, so the *slot* always exists and only the *amount* can be missing.
    /// A mirror too short to carry one falls back to ``DataManager/defaultServing`` — the identical
    /// figure `AddWaterIntent.init()` seeds for a caller that has expressed no preference. A vessel
    /// that cannot be tapped is a worse failure than one that pours the default, because on this
    /// screen it is the only action there is.
    nonisolated static func primary(from mirror: WristMirror?) -> WristServing {
        let amounts = resolveServings(from: mirror)
        let slot = vesselSlots[primaryIndex]
        return WristServing(
            nameKey: slot.nameKey,
            symbol: slot.symbol,
            amount: amounts.indices.contains(primaryIndex) ? amounts[primaryIndex] : DataManager.defaultServing
        )
    }

    /// Everything the vessel does not pour, in `vesselSlots` order — the menu's whole contents.
    ///
    /// Filters by **position**, not by comparing amounts: two vessels are allowed to hold the same
    /// figure (rule `20-state` forbids sorting or deduping the triple for exactly this reason), so
    /// dropping "the one equal to the primary" would silently empty a slot the user authored.
    nonisolated static func secondary(from mirror: WristMirror?) -> [WristServing] {
        servings(from: mirror)
            .enumerated()
            .filter { $0.offset != primaryIndex }
            .map(\.element)
    }

    /// The one always-on-screen line that says how much to trust the number above it.
    ///
    /// Three distinct states used to collapse into the single sentence *"Open WaterBuddy on your
    /// iPhone"*, which was actionable advice in exactly one of them and a dead end in the other two.
    /// They are now told apart:
    ///
    /// - **no mirror** — the watch is drawing against ``DataManager/defaultDailyGoal``, and says so.
    ///   Not an error: the screen is fully usable, pours are recorded, and they reconcile on the
    ///   first sync.
    /// - **a mirror, but the phone has no goal yet** (`isGoalSet == false`) — the *only* case where
    ///   reaching for the phone is genuinely the fix, so it is the only case that asks.
    /// - **a mirror with a goal** — ordinary attribution, delegated to
    ///   ``syncedCaption(composedAt:now:strings:)``.
    ///
    /// Kept `nonisolated static` and free of view state for the same reason its siblings are:
    /// `WristViewLogicTests` pins every branch without instantiating a `View`.
    ///
    /// **It takes its `Bundle`, and with no default.** A function taking a bundle rather than a
    /// stored string is what lets a language switch reach it (`tasks/lessons.md`, 2026-08-29), and a
    /// defaulted parameter would quietly mean `Bundle.main` — the device's language, not the one the
    /// phone chose. Rule `80-notifications` holds `reconcile`'s `strings:` to the same.
    nonisolated static func attribution(mirror: WristMirror?, now: Date, strings: Bundle) -> String {
        guard let mirror else {
            return strings.localizedString(forKey: "Not yet synced · default goal", value: nil, table: nil)
        }
        guard mirror.isGoalSet else {
            return strings.localizedString(forKey: "Set your goal in WaterBuddy on iPhone", value: nil, table: nil)
        }
        return syncedCaption(composedAt: mirror.composedAt, now: now, strings: strings)
    }

    /// "Synced Nm ago", rounded to whole minutes; "Synced just now" under a minute — and for a
    /// `composedAt` in the watch's future, which a phone clock running ahead produces; "Not yet
    /// synced" without a date — attribution, always present, never an alert (spec §8).
    ///
    /// The `nil` branch is unreachable from production today: `WristMirror.composedAt` is
    /// non-optional, and `attribution(mirror:now:strings:)` answers a missing mirror before it gets
    /// here. Kept, and translated, because the parameter is optional
    /// (`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §8.3).
    ///
    /// Russian writes the minutes as `мин`, which needs no plural form, and Uzbek takes none after a
    /// numeral — so one `%1$d` key serves every count.
    nonisolated static func syncedCaption(composedAt: Date?, now: Date, strings: Bundle) -> String {
        guard let composedAt else {
            return strings.localizedString(forKey: "Not yet synced", value: nil, table: nil)
        }
        let minutes = Int(now.timeIntervalSince(composedAt) / 60)
        guard minutes >= 1 else {
            return strings.localizedString(forKey: "Synced just now", value: nil, table: nil)
        }
        return String(format: strings.localizedString(forKey: "Synced %1$dm ago", value: nil, table: nil), minutes)
    }
}

// MARK: - The sheet behind the button

/// The other servings, one tap each. `Menu` does not exist on watchOS, so this is what "a button
/// with a menu" resolves to on this platform.
///
/// A `private struct` in the file that uses it, per rule `50-views` — it earns its own file only
/// when a second screen wants it, and there is only one screen here.
///
/// It stands its own ``WristAurora`` because a sheet is a full-screen surface on watchOS, and rule
/// `60-design-system` is explicit that glass goes over content, imagery or colour and **never** over
/// a flat background. Without it these capsules would sit on black.
private struct WristServingMenu: View {

    let servings: [WristServing]
    let pour: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.strings) private var strings

    var body: some View {
        ZStack {
            WristAurora()

            List {
                ForEach(servings) { serving in
                    Button {
                        pour(serving.amount)
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            // The phone's own two calls — `HomeView.Serving.name(in:)` and the
                            // `%1$d ml` caption under each quick-add vessel — so a serving reads the
                            // same on both devices and `LocalizationTests` can hold the two
                            // catalogues to it.
                            Label {
                                Text(serving.name(in: strings))
                            } icon: {
                                Image(systemName: serving.symbol)
                            }
                            Spacer(minLength: 8)
                            Text(String(format: strings.localizedString(forKey: "%1$d ml", value: nil, table: nil), serving.amount))
                                .foregroundStyle(.secondary)
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, wristCapsuleInset)
                        .padding(.vertical, wristCapsuleVerticalInset)
                        .frame(minHeight: wristMinimumTarget)
                        .liquidGlass(in: Capsule(), density: .sheer)
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    // A glass row clears the list's own surfaces (rule `60-design-system`).
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    WristView()
}
