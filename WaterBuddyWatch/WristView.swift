//
//  WristView.swift
//  WaterBuddyWatch
//
//  The one screen (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §8): the
//  vessel, the millilitre line under it, a row of three pour buttons — Cup, Glass, Bottle, the Glass
//  the screen's primary surface — and "Synced Nm ago", always present, never an alert. Deliberately
//  no settings, goal editor, history or reminders here; each would author state the watch cannot
//  own (v1 scope, owner-confirmed).
//
//  The redesign's §9 and spec 2026-10-20 §3.4 drew it so. The tap-to-pour vessel with Cup and Bottle
//  behind a *More* sheet that came before was reversed by decision D5: the vessel is a display again,
//  and every serving is one tap away.
//

import SwiftUI

// MARK: - Layout constants

/// Off the bezel. A pane flush to the edge of a round-rect display reads as clipped rather than as a
/// button.
///
/// File scope rather than a `private static` on `WristView`, because `WristPourRow` below needs the
/// figures beside it and Swift's `private` does not reach a sibling type even in the same file.
/// `nonisolated` for the reason rule `43-concurrency` gives: `SWIFT_DEFAULT_ACTOR_ISOLATION =
/// MainActor` infers `@MainActor` onto an unmarked declaration, and these are read from
/// `nonisolated` contexts.
nonisolated let wristScreenInset: CGFloat = 8

/// A `minHeight`, never a fixed `height`, so a target grows with Dynamic Type instead of clipping
/// (rule `65-accessibility`'s 44pt floor).
nonisolated let wristMinimumTarget: CGFloat = 44

/// A pour disc's diameter: the canvas's 46 pt, scaled with type and held between the 44 pt floor rule
/// `65-accessibility` sets and ``wristDiscCeiling``.
nonisolated let wristDiscDiameter: CGFloat = 46

/// The most a disc grows with type. Past it the row stops fitting and scrolls sideways instead
/// (rule `65-accessibility`: never shrink a control to make the set fit).
nonisolated let wristDiscCeiling: CGFloat = 56

/// The least air between two panes in the row — glass discs may never share an edge
/// (rule `60-design-system`). The spare width is spread between them, so on the 46 mm screen the
/// gaps come out at the canvas's 8 pt.
nonisolated let wristRowMinimumGap: CGFloat = 4

/// Between a disc and the amount under it.
nonisolated let wristAmountSpacing: CGFloat = 3

/// Inside the Glass's capsule, either side of its glyph and amount — the canvas's 84 pt capsule
/// around a 20 pt glyph, a 4 pt gap and a ~48 pt amount, rounded up. Wider, and the capsule row
/// would not fit the 46 mm screen's 192 pt with its 4 pt gaps.
nonisolated let wristCapsuleSideInset: CGFloat = 8

/// A pour glyph as a share of its disc — the canvas's 22 pt in 46 pt, rounded down. A ratio, never a
/// text style: the disc is a capped container (rule `60-design-system`).
nonisolated let wristGlyphShare: CGFloat = 0.46

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

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    /// The canvas's vessel against its screen: 100 pt on the 46 mm watch's 208 pt.
    nonisolated static let canvasVesselShare: CGFloat = 100.0 / 208.0

    /// The diameters the vessel may take on a screen this wide: the 60 pt floor below which its
    /// readout stops being legible, up to the canvas's share of the screen.
    nonisolated static func vesselRange(screenWidth: CGFloat) -> ClosedRange<CGFloat> {
        60...max(60, screenWidth * canvasVesselShare)
    }

    /// How far above the screen's bottom edge the canvas ended its amounts: 226 of 248 pt.
    nonisolated static let canvasBottomMargin: CGFloat = 22

    /// The height ``WristColumn`` fills: the safe area, and as much of the bottom inset — the
    /// rounded corners, where a scroll view still draws — as leaves ``canvasBottomMargin`` below the
    /// row, so the amounts under the discs stay clear of the corners.
    ///
    /// **Not the safe area alone, by the owner's ruling (2026-10-20).** On the 46 mm watch the safe
    /// area is 159 pt tall under a 53 pt clock inset, where the plan had assumed about 210; the
    /// line and the row left the vessel 63 pt of the canvas's 100. The canvas itself does not fit
    /// below the real clock, so the three renders went to the owner, who chose this middle one —
    /// 77 pt there, the row on screen, the caption a turn of the crown away.
    nonisolated static func columnHeight(safeHeight: CGFloat, bottomInset: CGFloat) -> CGFloat {
        safeHeight + max(0, bottomInset - canvasBottomMargin)
    }

    /// A column's even share of the pour row: the width less the least gaps, split evenly and
    /// rounded down to whole points, so the shares and their gaps never sum past the row — the most
    /// an amount under a disc may take before it gives a little.
    nonisolated static func columnShare(rowWidth: CGFloat, count: Int) -> CGFloat {
        guard count > 0 else { return rowWidth }
        return ((rowWidth - CGFloat(count - 1) * wristRowMinimumGap) / CGFloat(count)).rounded(.down)
    }

    /// A pour disc's diameter on a row this wide.
    ///
    /// **Below the accessibility sizes a disc gives way to its column's share, down to the 44pt
    /// floor,** where three do not fit — the 40mm watch, whose row is 142pt wide: its renders put the
    /// last amount off the edge at the default size, and from xLarge on the scaled disc would send the
    /// row into its sideways scroll (spec 2026-10-20 §3.4: "at least 44pt, the canvas's 46pt where the
    /// screen allows"). **At the accessibility sizes a disc keeps the size type gave it,** and a row it
    /// does not fit scrolls sideways — the one place rule `65-accessibility` lets a set overflow
    /// rather than shrink a control. Held to ``wristDiscCeiling``, and never under the floor.
    nonisolated static func discDiameter(scaled: CGFloat, rowWidth: CGFloat, count: Int, accessibilitySize: Bool) -> CGFloat {
        let wanted = min(scaled, wristDiscCeiling)
        guard !accessibilitySize else { return max(wristMinimumTarget, wanted) }
        return max(wristMinimumTarget, min(wanted, columnShare(rowWidth: rowWidth, count: count)))
    }

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
    /// the goal actually in use, and ``attribution(mirror:now:strings:locale:)`` — always present,
    /// outside every branch, as spec §8 requires, and on screen wherever it fits — says whether it
    /// came from the phone or is still the default.
    ///
    /// **A `ScrollView`, not a `List`.** With four stacked items there is nothing left for a `List`
    /// to do, and its own row insets would need a `.listRowBackground(Color.clear)` on every row to
    /// undo a surface the design never wanted.
    ///
    /// **The column, not a fraction of the height.** ``WristColumn`` gives the vessel what the line
    /// and the row leave of ``columnHeight(safeHeight:bottomInset:)``, between
    /// ``vesselRange(screenWidth:)``'s floor and ceiling, and lets the sync caption take what is
    /// spare — so the row is never pushed off the screen by the vessel. `GeometryReader` +
    /// `ScrollView` + `.scrollBounceBehavior(.basedOnSize)` is rule `65-accessibility`'s own shape for
    /// a screen that fills the viewport at ordinary sizes and scrolls at the accessibility ones; the
    /// column itself is at least that height, which is what `.frame(minHeight:)` used to say. Because
    /// that height runs into the bottom inset, the screen always scrolls a little — far enough to
    /// bring the caption up, where it did not fit.
    var body: some View {
        let face = model.face

        return ZStack {
            WristAurora()

            GeometryReader { proxy in
                ScrollView {
                    WristColumn(
                        height: Self.columnHeight(safeHeight: proxy.size.height, bottomInset: proxy.safeAreaInsets.bottom),
                        vessel: Self.vesselRange(screenWidth: proxy.size.width)
                    ) {
                        vessel(face)
                        lineUnderTheVessel(face)
                        WristPourRow(
                            servings: Self.pourRow(from: model.mirror),
                            glassID: Self.primary(from: model.mirror).id,
                            rowWidth: proxy.size.width - 2 * wristScreenInset
                        ) { model.pour(amount: $0) }
                        attributionLine
                    }
                    .padding(.horizontal, wristScreenInset)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .onReceive(clock) { now = $0 }
    }

    // MARK: - The vessel and the line under it

    /// The vessel, drawn and spoken; no longer a button (D5). It describes itself — one element,
    /// the label and the phone vessel's own sentence (``WristVessel``).
    private func vessel(_ face: WristPlan.Face) -> some View {
        GeometryReader { proxy in
            WristVessel(face: face, diameter: WristVessel.diameter(fitting: proxy.size.width, within: proxy.size.height))
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }

    /// *1,240 of 2,000 ml*, out of the water and under the vessel (#44). Hidden: the vessel speaks
    /// the same figures (rule `65-accessibility`).
    private func lineUnderTheVessel(_ face: WristPlan.Face) -> some View {
        Text(face.millilitreLine(in: strings, locale: locale))
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }

    // MARK: - The attribution line

    /// Named `attributionLine`, not `attribution`: a private computed property of that name shadows
    /// the `static func attribution(mirror:now:strings:locale:)` it is trying to call, and
    /// `Self.attribution(…)` then fails to resolve. Caught at compile time here, but the same
    /// collision with a *different* return type would have compiled and drawn the wrong thing.
    private var attributionLine: some View {
        Text(Self.attribution(mirror: model.mirror, now: now, strings: strings, locale: locale))
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
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
    /// shorter of the two is what keeps a malformed publish a *smaller row* rather than a crash —
    /// the same discard-rather-than-repair instinct rule `20-state` applies to
    /// `resolveServings(in:)`, one device further out.
    nonisolated static func servings(from mirror: WristMirror?) -> [WristServing] {
        zip(vesselSlots, resolveServings(from: mirror)).map { slot, amount in
            WristServing(nameKey: slot.nameKey, symbol: slot.symbol, amount: amount)
        }
    }

    /// The serving the Glass button pours: the phone's **middle** quick-add vessel,
    /// ``DataManager/usualSlot`` — the one name for the slot every one-tap door logs, the same one
    /// `AddWaterIntent` logs from the Home Screen widget (rule `40-widget`), so the two ambient front
    /// doors on the two devices cannot disagree about what one tap means.
    ///
    /// **Non-optional by construction, and that is the point.** `vesselSlots` is a compiled-in
    /// constant of exactly three, so the *slot* always exists and only the *amount* can be missing.
    /// A mirror too short to carry one falls back to ``DataManager/defaultServing`` — the identical
    /// figure `AddWaterIntent.init()` seeds for a caller that has expressed no preference. A Glass
    /// that cannot be tapped is a worse failure than one that pours the default, because it is the
    /// screen's primary action.
    nonisolated static func primary(from mirror: WristMirror?) -> WristServing {
        let amounts = resolveServings(from: mirror)
        let slot = vesselSlots[DataManager.usualSlot]
        return WristServing(
            nameKey: slot.nameKey,
            symbol: slot.symbol,
            amount: amounts.indices.contains(DataManager.usualSlot) ? amounts[DataManager.usualSlot] : DataManager.defaultServing
        )
    }

    /// Everything the Glass does not pour, in `vesselSlots` order — Cup and Bottle, the rest of the
    /// row.
    ///
    /// Filters by **position**, not by comparing amounts: two vessels are allowed to hold the same
    /// figure (rule `20-state` forbids sorting or deduping the triple for exactly this reason), so
    /// dropping "the one equal to the primary" would silently empty a slot the user authored.
    nonisolated static func secondary(from mirror: WristMirror?) -> [WristServing] {
        servings(from: mirror)
            .enumerated()
            .filter { $0.offset != DataManager.usualSlot }
            .map(\.element)
    }

    /// The row under the vessel: every serving the screen offers, in `vesselSlots` order, the Glass
    /// always among them.
    ///
    /// **Built from ``primary(from:)`` and ``secondary(from:)``, never from the raw servings** (the
    /// redesign's §9.2): a mirror too short to name a middle vessel still leaves a Glass that pours
    /// the default, because on this screen the row is the only action there is. A slot whose amount
    /// the mirror does not carry is left out, as the menu always left it out.
    nonisolated static func pourRow(from mirror: WristMirror?) -> [WristServing] {
        let primary = primary(from: mirror)
        let others = secondary(from: mirror)
        return vesselSlots.compactMap { slot in
            slot.nameKey == primary.nameKey ? primary : others.first { $0.nameKey == slot.nameKey }
        }
    }

    /// A pour button's VoiceOver label — the phone's own quick-add sentence (`HomeView`), so a
    /// serving is spoken alike on both devices, in the form its count takes.
    nonisolated static func pourLabel(for serving: WristServing, strings: Bundle, locale: Locale) -> String {
        strings.localized("%1$@, add %2$d millilitres", serving.name(in: strings), serving.amount, locale: locale)
    }

    /// The amount a button carries — inside the Glass's capsule, under a disc — grouped as `locale`
    /// groups it.
    nonisolated static func amountLabel(_ amount: Int, strings: Bundle, locale: Locale) -> String {
        strings.localized("%1$d ml", amount, locale: locale)
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
    ///   ``syncedCaption(composedAt:now:strings:locale:)``.
    ///
    /// Kept `nonisolated static` and free of view state for the same reason its siblings are:
    /// `WristViewLogicTests` pins every branch without instantiating a `View`.
    ///
    /// **It takes its `Bundle`, and with no default.** A function taking a bundle rather than a
    /// stored string is what lets a language switch reach it (`tasks/lessons.md`, 2026-08-29), and a
    /// defaulted parameter would quietly mean `Bundle.main` — the device's language, not the one the
    /// phone chose. Rule `80-notifications` holds `reconcile`'s `strings:` to the same.
    /// It takes the locale beside it, for the same reason and with no default either.
    nonisolated static func attribution(mirror: WristMirror?, now: Date, strings: Bundle, locale: Locale) -> String {
        guard let mirror else {
            return strings.localizedString(forKey: "Not yet synced · default goal", value: nil, table: nil)
        }
        guard mirror.isGoalSet else {
            return strings.localizedString(forKey: "Set your goal in WaterBuddy on iPhone", value: nil, table: nil)
        }
        return syncedCaption(composedAt: mirror.composedAt, now: now, strings: strings, locale: locale)
    }

    /// "Synced Nm ago", rounded to whole minutes; "Synced just now" under a minute — and for a
    /// `composedAt` in the watch's future, which a phone clock running ahead produces; "Not yet
    /// synced" without a date — attribution, always present, never an alert (spec §8).
    ///
    /// The `nil` branch is unreachable from production today: `WristMirror.composedAt` is
    /// non-optional, and `attribution(mirror:now:strings:locale:)` answers a missing mirror before it gets
    /// here. Kept, and translated, because the parameter is optional
    /// (`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §8.3).
    ///
    /// Russian writes the minutes as `мин`, which needs no plural form, and Uzbek takes none after a
    /// numeral — so one `%1$d` key serves every count.
    nonisolated static func syncedCaption(composedAt: Date?, now: Date, strings: Bundle, locale: Locale) -> String {
        guard let composedAt else {
            return strings.localizedString(forKey: "Not yet synced", value: nil, table: nil)
        }
        let minutes = Int(now.timeIntervalSince(composedAt) / 60)
        guard minutes >= 1 else {
            return strings.localizedString(forKey: "Synced just now", value: nil, table: nil)
        }
        return strings.localized("Synced %1$dm ago", minutes, locale: locale)
    }
}

// MARK: - The pour row

/// The three pour buttons (spec 2026-10-20 §3.4). Two whole rows, one chosen — the Glass as a capsule
/// carrying its amount where the row has room, three discs where it has not — and a sideways scroll
/// past the largest text sizes, where even three discs do not fit (rule `65-accessibility`).
///
/// A `private struct` in the file that uses it, per rule `50-views`. `.buttonStyle(.plain)` and no
/// haptic: `PressStyle` and `Haptics` are in none of the watch's exception sets (rule
/// `60-design-system`), so the discs' press response is Apple's interactive glass and the white
/// Glass has none.
private struct WristPourRow: View {

    let servings: [WristServing]
    let glassID: String
    /// The width the row is laid across — the screen's, less ``wristScreenInset`` either side.
    let rowWidth: CGFloat
    let pour: (Int) -> Void

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .body) private var scaledDisc: CGFloat = wristDiscDiameter

    private var disc: CGFloat {
        WristView.discDiameter(scaled: scaledDisc, rowWidth: rowWidth, count: servings.count,
                               accessibilitySize: typeSize.isAccessibilitySize)
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            row(glassCarriesItsAmount: true)
            row(glassCarriesItsAmount: false)
            ScrollView(.horizontal) { row(glassCarriesItsAmount: false) }
        }
        .frame(maxWidth: .infinity)
        .glassGroup()
    }

    private func row(glassCarriesItsAmount: Bool) -> some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(servings.enumerated()), id: \.element.id) { index, serving in
                if index > 0 { Spacer(minLength: wristRowMinimumGap) }
                column(serving, glassCarriesItsAmount: glassCarriesItsAmount)
            }
        }
    }

    private func column(_ serving: WristServing, glassCarriesItsAmount: Bool) -> some View {
        let isGlass = serving.id == glassID
        let inside = isGlass && glassCarriesItsAmount
        return VStack(spacing: wristAmountSpacing) {
            Button { pour(serving.amount) } label: { face(of: serving, isGlass: isGlass, carriesAmount: inside) }
                .buttonStyle(.plain)
                // The phone's own quick-add sentence, so a serving is spoken alike on both devices.
                .accessibilityLabel(WristView.pourLabel(for: serving, strings: strings, locale: locale))
            if !inside {
                amount(serving)
                    // The button's label already speaks the amount (rule `65-accessibility`).
                    .accessibilityHidden(true)
            }
        }
    }

    /// The amount under a disc. **Below the accessibility sizes it gives a little** — down to half
    /// its size, held to its column's even share of the row — so that on the 40mm watch, where three
    /// amounts at full size are wider than the row (47pt each against 44pt shares), the row still
    /// stands still; elsewhere it is drawn at full size. **At the accessibility sizes it keeps its
    /// size,** and a row it does not fit scrolls sideways instead, so no amount is ever cut short.
    @ViewBuilder
    private func amount(_ serving: WristServing) -> some View {
        let text = Text(WristView.amountLabel(serving.amount, strings: strings, locale: locale))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
        if typeSize.isAccessibilitySize {
            text.fixedSize()
        } else {
            // A frame with a `maxWidth` grows to it when offered more, and squeezed the Glass's
            // capsule on the 46mm watch; held at its own width, it only ever gives way.
            text
                .minimumScaleFactor(0.5)
                .frame(maxWidth: WristView.columnShare(rowWidth: rowWidth, count: servings.count))
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    @ViewBuilder
    private func face(of serving: WristServing, isGlass: Bool, carriesAmount: Bool) -> some View {
        if carriesAmount {
            HStack(spacing: wristAmountSpacing) {
                Image(systemName: serving.symbol)
                Text(WristView.amountLabel(serving.amount, strings: strings, locale: locale)).fixedSize()
            }
            .font(.footnote.weight(.heavy))
            .fontDesign(.rounded)
            .padding(.horizontal, wristCapsuleSideInset)
            .frame(minWidth: disc, minHeight: disc)
            // The screen's one primary surface; it sets its label's colour (rule `60-design-system`).
            .primarySurface(in: Capsule(), ring: false)
            .contentShape(Capsule())
        } else if isGlass {
            Image(systemName: serving.symbol)
                .font(.system(size: disc * wristGlyphShare, weight: .semibold))
                .frame(width: disc, height: disc)
                .primarySurface(in: Circle(), ring: false)
                .contentShape(Circle())
        } else {
            Image(systemName: serving.symbol)
                .font(.system(size: disc * wristGlyphShare, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: disc, height: disc)
                // A control: the glass is what is pressed, so Apple's regular, tinted variant — the
                // clear one would leave its glyph on untinted glass (#91(b)).
                .liquidGlass(in: Circle(), density: .sheer, interactive: true)
                .contentShape(Circle())
        }
    }
}

#Preview {
    WristView()
}
