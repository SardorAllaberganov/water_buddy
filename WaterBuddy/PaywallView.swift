//
//  PaywallView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import SwiftUI

/// WaterBuddy Premium's paywall — our own, in the app's glass and the app's language, as the owner
/// approved it on the design canvas (spec `2026-10-21-premium-paywall-and-monthly-design.md` §3.4,
/// amending the foundation's §3.7).
///
/// **Never imports StoreKit.** It reads ``PremiumStore`` from the environment and draws
/// ``PremiumAccess/Plan``s; StoreKit's own views would draw their words in the device's language, not
/// the app's (rule `50-views`, rule `70-privacy`).
///
/// **Offered only when ``isOffered(arguments:)`` says so.** A DEBUG build shows it when launched with
/// ``launchArgument``; a Release build only while a ``PremiumSet`` is on sale and the privacy link is
/// set (§3.6).
///
/// **Opened only by the user** — Settings' *See Premium* today, a later step's locked state
/// tomorrow — never at launch, after a pour or from any other surface (rule `70-privacy`).
struct PaywallView: View {

    /// Where the sheet was opened from — its `.sheet(item:)` selection (rule `50-views`).
    enum Entry: Identifiable, Hashable {
        /// Settings' *See Premium*.
        case settings
        /// History's locked month (spec `2026-10-22-month-view-design.md` §3.6).
        case history

        var id: Self { self }
    }

    /// What the sheet shows (plan S8).
    nonisolated enum Screen: Sendable, Equatable {
        /// The plans, to buy — nothing is held, or the first read has not answered yet.
        case offer
        /// The user's own purchase has just landed.
        case thanks
        /// Something is held — bought earlier, restored, or approved by a parent.
        case held
    }

    /// DEBUG's opt-in (rule `85-testing`).
    nonisolated static let launchArgument = "-WaterBuddyPremium"

    /// Apple's standard licence, which an app without its own uses (foundation spec §3.7).
    nonisolated static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")

    /// The owner's privacy policy, on their GitHub user site — `Tools/PrivacyPolicy.html`, the
    /// published form of `PRIVACY.md`. App Review asks every app to link one inside it (spec §8), so
    /// Settings reads this declaration too and links it for every user (spec
    /// `2026-10-24-privacy-policy-design.md` §3).
    nonisolated static let privacyPolicy = URL(string: "https://sardorallaberganov.github.io/waterbuddy/privacy/")

    /// The switch, as a pure function of the build, the arguments, the sets on sale and the privacy
    /// link: DEBUG offers it when launched to; Release only while a set is on sale **and** the link
    /// is an `https` address — so a release cannot ship a paywall with a dead privacy link (spec
    /// `2026-10-21-premium-paywall-and-monthly-design.md` §3.6).
    nonisolated static func isOffered(debug: Bool, arguments: [String], setsOnSale: Int, privacyPolicy: URL?) -> Bool {
        debug ? arguments.contains(launchArgument) : setsOnSale > 0 && privacyPolicy?.scheme == "https"
    }

    /// The switch for this build.
    nonisolated static func isOffered(arguments: [String]) -> Bool {
        isOffered(debug: isDebug, arguments: arguments, setsOnSale: PremiumSet.onSale.count, privacyPolicy: privacyPolicy)
    }

    /// Whether this is a DEBUG build.
    nonisolated static var isDebug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    /// The sets the sheet and the card list: every set in DEBUG, so a set can be seen whole while it
    /// is built; in Release only those on sale.
    nonisolated static func shownSets(debug: Bool) -> [PremiumSet] {
        debug ? PremiumSet.allCases : PremiumSet.onSale
    }

    /// The switch for this process.
    nonisolated static var isOfferedHere: Bool {
        isOffered(arguments: ProcessInfo.processInfo.arguments)
    }

    /// What the sheet shows, from what is held and the last purchase: a refund landing after a
    /// thank-you returns the offer (Review Focus 1), and a subscriber sees what they hold, never the
    /// plans again (Review Focus 5).
    nonisolated static func screen(status: PremiumAccess.Status?, purchase: PremiumStore.Purchase) -> Screen {
        guard let status, status.isPremium else { return .offer }
        return purchase == .bought ? .thanks : .held
    }

    let entry: Entry

    @Environment(PremiumStore.self) private var premium
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    /// The plan picked — the yearly when the sheet opens.
    @State private var chosen: PremiumAccess.Plan.Kind = .yearly

    /// Bumped by a pick, so the selection tick fires on the tap (rule `60-design-system`).
    @State private var picks = 0

    /// Bumped when the user's own purchase lands.
    @State private var purchases = 0

    /// A feature's glyph box, growing with the row's type up to a ceiling — it is decorative — with
    /// its glyph sized from it, never from a text style of its own: at the largest sizes a fixed
    /// box and a `.body` glyph crossed over, and the bars stood out of the tile they then had (the
    /// walk, W10; rule `65-accessibility`).
    @ScaledMetric(relativeTo: .subheadline) private var glyphBox: CGFloat = PaywallStyle.glyphBox

    var body: some View {
        ZStack {
            AuroraBackground()

            // Whole at every ordinary size, scrolling once the type outgrows the sheet
            // (rule `65-accessibility`).
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: PaywallStyle.sectionGap) {
                        topBar
                        preview
                        heading
                        switch Self.screen(status: premium.state.status, purchase: premium.purchase) {
                        case .offer:
                            features
                            offer
                        case .thanks:
                            held(thanks: true)
                        case .held:
                            held(thanks: false)
                        }
                        footer
                    }
                    .padding(.horizontal, PaywallStyle.margin)
                    .padding(.vertical, PaywallStyle.verticalInset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: proxy.size.height, alignment: .top)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        // Never swiped away mid-purchase: StoreKit's own sheet is over it, and the answer lands here.
        // The close button stays, so a purchase that never answers cannot trap the user.
        .interactiveDismissDisabled(premium.purchase == .buying)
        .sensoryFeedback(Haptics.select, trigger: picks)
        .sensoryFeedback(Haptics.confirm, trigger: purchases)
        .animation(Motion.settle, value: premium.plans)
        .animation(Motion.settle, value: premium.purchase)
        .animation(Motion.settle, value: premium.restoring)
        .task { await premium.prepare() }
    }

    // MARK: - The top

    /// The close button — *Not now* to VoiceOver, the welcome's own word for declining — and the
    /// promise on its own capsule (`docs/ROADMAP.md` §1). At the accessibility text sizes the promise
    /// takes a row of its own, the sheet's width, on a rounded pane: beside the button it wrapped to
    /// four lines inside a capsule (the walk, W8).
    @ViewBuilder
    private var topBar: some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 12) {
                SheetCloseButton(label: "Not now")
                promise(in: RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous))
            }
        } else {
            HStack(alignment: .center, spacing: 12) {
                SheetCloseButton(label: "Not now")
                Spacer(minLength: 0)
                promise(in: Capsule())
            }
        }
    }

    private func promise<S: Shape & InsettableShape>(in shape: S) -> some View {
        Label {
            Text("Logging water is free, always.", bundle: strings)
        } icon: {
            // The line's white: cyan read 2.83:1 even on frosted glass (Task 8; the owner's ruling
            // R4).
            Image(systemName: "checkmark")
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, PaywallStyle.capsuleInset)
        .padding(.vertical, PaywallStyle.capsuleInset / 2)
        // Frosted: on sheer glass over the aurora's cyan light the line read 3.49:1 (Task 8).
        .liquidGlass(in: shape, density: .frosted, elevation: .resting)
    }

    /// Decoration — a month of dots and a day of bars, with no figure, no date and no name. It is not
    /// the user's data and does not pretend to be (spec §3.4, 2).
    private var preview: some View {
        HStack(spacing: PaywallStyle.previewGap) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(PaywallStyle.dot), spacing: PaywallStyle.dotGap), count: 7),
                spacing: PaywallStyle.dotGap
            ) {
                ForEach(0..<35, id: \.self) { day in
                    Circle()
                        .fill(PaywallStyle.quietDays.contains(day) ? .white.opacity(PaywallStyle.restOpacity) : Aurora.cyan)
                        .frame(width: PaywallStyle.dot, height: PaywallStyle.dot)
                }
            }
            .fixedSize()

            HStack(alignment: .bottom, spacing: PaywallStyle.barGap) {
                ForEach(PaywallStyle.bars.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == PaywallStyle.tallestBar ? Aurora.cyan : .white.opacity(PaywallStyle.barOpacity))
                        .frame(height: PaywallStyle.barHeight * PaywallStyle.bars[index])
                }
            }
            .frame(maxWidth: .infinity, maxHeight: PaywallStyle.barHeight, alignment: .bottom)
        }
        .padding(PaywallStyle.previewInset)
        .frame(maxWidth: .infinity)
        .liquidGlass(density: .frosted, elevation: .resting)
        .accessibilityHidden(true)
    }

    /// The one line on the aurora with no pane under it — large text, so 3:1, which it holds with the
    /// backdrop's two shadows (3.18 at the cyan light's brightest, Task 8).
    private var heading: some View {
        Text("WaterBuddy Premium", bundle: strings)
            .font(.largeTitle.weight(.heavy))
            .foregroundStyle(.white)
            .accessibilityAddTraits(.isHeader)
            .fixedSize(horizontal: false, vertical: true)
            .legibleOnBackdrop()
    }

    // MARK: - The set

    /// The line under the title, one row per feature of the sets shown (``shownSets(debug:)``), then
    /// the promise that later features come included — on one frosted pane, rule
    /// `60-design-system`'s place for sentence-length text: on the aurora, even with its two
    /// shadows, they read 2.9 to 4.3:1 where the cyan light passes behind them (Task 8; the owner's
    /// ruling R1).
    private var features: some View {
        VStack(alignment: .leading, spacing: PaywallStyle.rowGap) {
            // Full white: by the card's lit corner it read 4.32:1 at 0.92, 4.54 at 0.96 and 4.77 at
            // 1.0 (Task 8) — as the welcome's card line went to full white.
            Text("See how you really drink, and what would help.", bundle: strings)
                .font(.body)
                .foregroundStyle(.white)
            ForEach(Self.shownSets(debug: Self.isDebug).flatMap(\.features), id: \.self) { feature in
                featureRow(feature)
            }
            Text("New Premium features arrive in updates, included.", bundle: strings)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(PaywallStyle.cardInset)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .resting)
    }

    /// A glyph, a title and one line — one element to VoiceOver. The glyph is `Aurora.cyan`, as the
    /// Settings card draws the same features: blue and magenta read 1.5 to 1.7:1 on frosted glass
    /// (Task 8; the owner's ruling R2).
    private func featureRow(_ feature: PremiumSet.Feature) -> some View {
        let box = min(glyphBox, PaywallStyle.glyphBoxCeiling)
        // Beside the title once the lines run long, rather than halfway down them.
        return HStack(alignment: typeSize.isAccessibilitySize ? .top : .center, spacing: 14) {
            Image(systemName: feature.symbol)
                .font(.system(size: box * PaywallStyle.glyphScale, weight: .semibold))
                .foregroundStyle(Aurora.cyan)
                .frame(width: box, height: box)
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title(in: strings))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Text(feature.line(in: strings))
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - The offer

    @ViewBuilder
    private var offer: some View {
        switch premium.plans {
        case .notLoaded, .loading:
            ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity, minHeight: PaywallStyle.quietHeight)
        case .unavailable:
            unavailable
        case .loaded(let plans):
            planTiles(plans)
            if let plan = plans.first(where: { $0.kind == chosen }) {
                outcome
                buyButton(plan)
                Text(plan.terms(in: strings, locale: locale))
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(PaywallStyle.footnoteOpacity))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .legibleOnBackdrop()
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var unavailable: some View {
        VStack(spacing: 14) {
            Text("The App Store can't be reached right now.", bundle: strings)
                .font(.body)
                .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .legibleOnBackdrop()

            Button {
                Task { await premium.loadPlans() }
            } label: {
                Text("Try Again", bundle: strings)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, PaywallStyle.capsuleInset * 1.7)
                    .frame(minHeight: PaywallStyle.linkHeight)
                    .liquidGlass(in: Capsule(), density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())
        }
        .frame(maxWidth: .infinity, minHeight: PaywallStyle.quietHeight)
    }

    /// The three plans side by side — in a column at the accessibility text sizes, where three
    /// abreast would squeeze a price (rule `65-accessibility`, plan S2).
    private func planTiles(_ plans: [PremiumAccess.Plan]) -> some View {
        let saving = PremiumAccess.yearlySaving(among: plans)
        let column = typeSize.isAccessibilitySize
        // Side by side, every tile keeps the badge's line while one draws it, so the names and the
        // prices stand level.
        let reservesBadge = !column && plans.contains { $0.showsBestValue(saving: saving) }
        let layout = column
            ? AnyLayout(VStackLayout(spacing: PaywallStyle.tileGap))
            : AnyLayout(HStackLayout(alignment: .top, spacing: PaywallStyle.tileGap))
        // At its ideal height, so every tile stands as tall as the tallest — the yearly's (the walk,
        // W9).
        return layout {
            ForEach(plans) { plan in
                planTile(plan, saving: saving, reservesBadge: reservesBadge)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .glassGroup()
    }

    /// One plan: the yearly's badge, its name, its price — the largest figure — its period, the
    /// yearly's saving and its note; one button whose label is the name and whose value is the full
    /// price line, the selected trait on the one picked (rule `65-accessibility`).
    private func planTile(_ plan: PremiumAccess.Plan, saving: Double?, reservesBadge: Bool) -> some View {
        let isSelected = plan.kind == chosen
        let marked = plan.showsBestValue(saving: saving)
        let shape = RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous)

        return Button {
            guard !isSelected else { return }
            chosen = plan.kind
            picks += 1
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                if marked || reservesBadge {
                    badge
                        .opacity(marked ? 1 : 0)
                }
                Text(plan.name(in: strings))
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(plan.price)
                    .font(.title2.weight(.heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(plan.period(in: strings))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
                if let line = plan.savingLine(in: strings, locale: locale, saving: saving) {
                    Text(line)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
                }
                if let note = plan.note(in: strings, locale: locale) {
                    // White, the yearly's too: cyan read 4.1:1 on the selected tile (Task 8; the
                    // owner's ruling R4).
                    Text(note)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
                }
            }
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)
            .padding(PaywallStyle.tileInset)
            .frame(maxWidth: .infinity, minHeight: PaywallStyle.tileHeight, maxHeight: .infinity, alignment: .topLeading)
            .background { selectionMark(isSelected, in: shape) }
            .liquidGlass(in: shape, density: .frosted, elevation: .resting, interactive: true)
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(plan.name(in: strings))
        .accessibilityValue(plan.priceLine(in: strings, locale: locale))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    /// The yearly's mark, its tile's first line, in the tile's white. It stood across the tile's top
    /// edge as cyan words on a pill of opaque glass (plan S3), where the pill's sheen left them at
    /// 1.74:1 (Task 8; the owner's ruling R3).
    private var badge: some View {
        Text("Best value", bundle: strings)
            .font(.caption2.weight(.heavy))
            .textCase(.uppercase)
            .lineLimit(1)
            // The Russian, uppercase and heavy, is wider than a tile three abreast (the walk, W3).
            .minimumScaleFactor(0.7)
            .accessibilityHidden(true)
    }

    /// What became of the last purchase, when there is something to say. A purchase that landed is
    /// the thank-you screen's, never a line here (Review Focus 1).
    @ViewBuilder
    private var outcome: some View {
        switch premium.purchase {
        case .pending: note("Waiting for approval.")
        case .failed: note("The purchase didn't go through.")
        case .idle, .buying, .bought: EmptyView()
        }
    }

    private func note(_ key: LocalizedStringKey) -> some View {
        Text(key, bundle: strings)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .legibleOnBackdrop()
            .frame(maxWidth: .infinity)
    }

    /// The screen's one primary surface (rule `60-design-system`). It does not close the sheet: the
    /// thank-you does, on the user's own *Done* (the final review's minors 1 and 2).
    private func buyButton(_ plan: PremiumAccess.Plan) -> some View {
        Button {
            Task {
                await premium.buy(plan)
                if premium.purchase == .bought { purchases += 1 }
            }
        } label: {
            ZStack {
                Text(plan.action(in: strings))
                    .opacity(premium.purchase == .buying ? 0 : 1)
                ProgressView()
                    .opacity(premium.purchase == .buying ? 1 : 0)
            }
            .font(.body.weight(.bold))
            .frame(maxWidth: .infinity, minHeight: PaywallStyle.buttonHeight)
            .primarySurface(in: Capsule())
        }
        .buttonStyle(PressStyle())
        .disabled(premium.purchase == .buying)
        .accessibilityLabel(plan.action(in: strings))
    }

    // MARK: - Held

    /// *Thank you* after the user's own purchase, *You have Premium.* otherwise; the plan's line;
    /// *Done* on the primary surface.
    private func held(thanks: Bool) -> some View {
        VStack(spacing: 14) {
            VStack(spacing: 6) {
                if thanks {
                    Text("Thank you", bundle: strings)
                        .font(.title2.weight(.bold))
                } else {
                    Text("You have Premium.", bundle: strings)
                        .font(.title2.weight(.bold))
                }
                if let line = premium.state.status?.line(in: strings, locale: locale, now: premium.now()) {
                    Text(line)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
                }
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .legibleOnBackdrop()
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)

            Button {
                dismiss()
            } label: {
                Text("Done", bundle: strings)
                    .font(.body.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: PaywallStyle.buttonHeight)
                    .primarySurface(in: Capsule())
            }
            .buttonStyle(PressStyle())
        }
        .frame(maxWidth: .infinity, minHeight: PaywallStyle.quietHeight)
    }

    // MARK: - Footer

    /// What a restore found, then *Restore Purchases* while nothing is held and the two links — in a
    /// row where they fit, a column where they do not (rule `50-views`).
    private var footer: some View {
        VStack(spacing: 6) {
            if premium.restoring == .nothingFound {
                Text("No purchases to restore.", bundle: strings)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .legibleOnBackdrop()
                    .frame(maxWidth: .infinity)
            }
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) { footerLinks }
                    .fixedSize()
                VStack(spacing: 0) { footerLinks }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var footerLinks: some View {
        if premium.state.status?.isPremium != true {
            Button {
                Task { await premium.restore() }
            } label: {
                ZStack {
                    footerLabel("Restore Purchases")
                        .opacity(premium.restoring == .restoring ? 0 : 1)
                    ProgressView()
                        .tint(.white)
                        .opacity(premium.restoring == .restoring ? 1 : 0)
                }
            }
            .buttonStyle(PressStyle())
            .disabled(premium.restoring == .restoring)
        }
        if let terms = Self.termsOfUse {
            Link(destination: terms) { footerLabel("Terms of Use") }
        }
        if let privacy = Self.privacyPolicy {
            Link(destination: privacy) { footerLabel("Privacy Policy") }
        }
    }

    private func footerLabel(_ key: LocalizedStringKey) -> some View {
        Text(key, bundle: strings)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
            .multilineTextAlignment(.center)
            .legibleOnBackdrop()
            .frame(minHeight: PaywallStyle.linkHeight)
            .contentShape(Rectangle())
    }

    /// ``LiquidGlass/Selection``'s fill and rim, present at nothing when not picked
    /// (rule `60-design-system`) — the welcome's own mark.
    private func selectionMark<S: InsettableShape>(_ isSelected: Bool, in shape: S) -> some View {
        shape
            .fill(.white.opacity(isSelected ? LiquidGlass.Selection.fillOpacity : 0))
            .strokeBorder(.white.opacity(isSelected ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
            .scaleEffect(isSelected ? 1 : 0.9)
            .animation(Motion.land, value: isSelected)
    }
}

/// The paywall's measures. The two text opacities are the welcome's, measured again on this sheet in
/// step 1's walk, worst frame of a minute (Task 8, `docs/DESIGN.md`): 0.92 reads 5.9:1 and up on the
/// feature card, 6.5 and up on the tiles, 5.05 in the footer; 0.88, the terms, 4.63.
private enum PaywallStyle {
    static let margin: CGFloat = 20
    static let verticalInset: CGFloat = 12
    static let sectionGap: CGFloat = 18
    static let rowGap: CGFloat = 12
    static let capsuleInset: CGFloat = 14
    /// At the ordinary size; it grows with ``PaywallView/glyphBox``, to the ceiling.
    static let glyphBox: CGFloat = 28
    static let glyphBoxCeiling: CGFloat = 42
    /// The glyph's size as a share of its box — 20 in 28, the size the Settings card's previews draw
    /// the same glyphs at (`.title3`) at the ordinary setting.
    static let glyphScale: CGFloat = 0.72
    /// The feature card's padding.
    static let cardInset: CGFloat = 16
    static let previewGap: CGFloat = 20
    static let previewInset: CGFloat = 16
    static let dot: CGFloat = 14
    static let dotGap: CGFloat = 6
    static let barGap: CGFloat = 4
    static let barHeight: CGFloat = 34
    /// The preview's bars, as fractions of its height — fixed, no one's own hours.
    static let bars: [CGFloat] = [0.3, 0.55, 0.45, 1, 0.6, 0.35, 0.48, 0.2]
    static let tallestBar = 3
    /// The preview's quiet days — fixed, so it never reads as anyone's own month.
    static let quietDays: Set<Int> = [2, 9, 15, 23, 24, 30, 31, 32, 33, 34]
    static let restOpacity = 0.22
    static let barOpacity = 0.6
    static let tileGap: CGFloat = 10
    static let tileInset: CGFloat = 12
    /// Four lines of type at the ordinary sizes, past the 44 floor — a floor: the row stands as tall
    /// as its tallest tile, the yearly's.
    static let tileHeight: CGFloat = 124
    /// The primary buttons' 56 (rule `65-accessibility`).
    static let buttonHeight: CGFloat = 56
    /// The 44 floor.
    static let linkHeight: CGFloat = 44
    /// Where the plans stand while they load, or when they cannot.
    static let quietHeight: CGFloat = 150
    static let textOpacity = 0.92
    static let footnoteOpacity = 0.88
}

#Preview {
    PaywallView(entry: .settings)
        .environment(PremiumStore(source: .silent()))
}
