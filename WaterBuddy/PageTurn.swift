//
//  PageTurn.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 12/10/26.
//

import CoreGraphics

/// A change of tab, as a value: the page shown, the page still leaving, and which way the shown
/// one came.
///
/// **The pages sit side by side in the bar's order**, so going to a tab on the right brings its
/// page in from the right while the old one leaves to the left. ``RootTabView`` draws what this
/// says and decides nothing of it: the direction, which pages exist and where each stands are
/// here, where `PageTurnTests` can reach them without a screen.
///
/// **Two pages at most.** A page is built when it is shown and gone when its slide has ended.
/// A second turn before the first has ended drops the page that was leaving, where it stands —
/// after a fifth of a second it is three quarters of the way out, and sooner than that it is
/// seen to go — and the page that was shown leaves in its turn.
///
/// A plain value, at file scope and `nonisolated`, so the suite reads it off the main actor
/// (rule `43-concurrency`).
nonisolated struct PageTurn: Equatable, Sendable {

    /// The page that is shown, or arriving.
    private(set) var shown: AppTab = .opening

    /// The page still on its way out, until its slide ends.
    private(set) var leaving: AppTab?

    /// Which way the shown page came: `1` from the right, `-1` from the left.
    private(set) var travel: CGFloat = 1

    /// How many turns have been made. Nothing when the app opens, which is how the first page
    /// is told from every one after it; and each slide's end is matched against the turn that
    /// started it (``settle(_:)``).
    private(set) var turns = 0

    /// Turns to `tab`. Turning to the tab already shown is nothing: no page leaves, nothing
    /// moves, and no turn is counted.
    mutating func turn(to tab: AppTab) {
        guard tab != shown else { return }
        travel = Self.place(of: tab) > Self.place(of: shown) ? 1 : -1
        leaving = shown
        shown = tab
        turns += 1
    }

    /// Ends turn number `turn`, if no turn has been made since.
    ///
    /// **Matched to the turn, not to the page.** A slide reports its end for the turn that
    /// started it. If the user has turned again meanwhile, the page that turn brought in may be
    /// the one now leaving (`anOlderTurnsEndDoesNotEndANewerTurn`) — or, there and back and
    /// there again inside one slide, the one now *shown* again, which a check on the page
    /// would take for the newest slide's own end and remove the page still moving
    /// (`aTurnBackAndForthInsideOneSlideIsNotEndedByTheFirst`).
    mutating func settle(_ turn: Int) {
        guard turn == turns else { return }
        leaving = nil
    }

    /// The pages that exist, in the bar's order whichever way the turn went. The order is the
    /// views' identity order; one that flipped with the direction would rebuild both.
    var mounted: [AppTab] {
        AppTab.allCases.filter { $0 == shown || $0 == leaving }
    }

    /// Where `tab` stands across a screen `width` wide: in place when it is the one shown, a
    /// whole width out on the far side when it is the one leaving.
    ///
    /// `slides` is false under Reduce Motion, where both stand in place and the page cross-fades
    /// (rule `65-accessibility`).
    func offset(of tab: AppTab, across width: CGFloat, slides: Bool) -> CGFloat {
        guard slides, tab != shown else { return 0 }
        return -travel * width
    }

    /// Where the shown page starts from: a whole width out on the side its tab is on.
    func entry(across width: CGFloat, slides: Bool) -> CGFloat {
        slides ? travel * width : 0
    }

    /// What `tab` is drawn at. A page that slides is seen all the way out; under Reduce Motion
    /// the one leaving is the one that fades.
    func opacity(of tab: AppTab, slides: Bool) -> Double {
        slides || tab == shown ? 1 : 0
    }

    private static func place(of tab: AppTab) -> Int {
        AppTab.allCases.firstIndex(of: tab) ?? 0
    }
}
