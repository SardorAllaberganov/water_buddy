//
//  WristViewLogicTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Testing
@testable import WaterBuddyWatch

/// The pure functions `WristView` reads from — which servings to offer, which single one the
/// vessel itself pours, what is left for the menu, and how the sync line reads — pulled out so
/// they're testable without instantiating a `View` at all (rule `43-concurrency`'s "a value type a
/// non-@MainActor suite reads is declared at file scope" extended to functions for the same
/// reason). This suite is deliberately **not** `@MainActor`; that is what proves the claim.
struct WristViewLogicTests {

    @Test
    func fallsBackToTheDefaultServingsWithNoMirrorYet() {
        let resolved = WristView.resolveServings(from: nil)
        #expect(resolved == DataManager.defaultServings)
    }

    @Test
    func usesTheMirrorsServingsWhenPresent() {
        let mirror = WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: 0, dailyGoal: 2_000,
            servings: [100, 200, 300], languageCode: nil, isGoalSet: true,
            composedAt: .now, phoneDayStart: .now, phoneDayEnd: .now, acked: []
        )
        #expect(WristView.resolveServings(from: mirror) == [100, 200, 300])
    }

    @Test
    func syncedJustNowReadsAsNow() {
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_030))
        #expect(text == "Synced just now")
    }

    @Test
    func syncedMinutesAgoReadsInWholeMinutes() {
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_000 + 245))
        #expect(text == "Synced 4m ago")
    }

    @Test
    func noMirrorYetReadsAsNeverSynced() {
        #expect(WristView.syncedCaption(composedAt: nil, now: .now) == "Not yet synced")
    }

    // MARK: - Attribution (the always-present line, spec §8's "never an alert")

    /// `servings:` is a parameter rather than the fixed triple it used to be so a test can hand the
    /// screen a **malformed** one. That is not a hypothetical shape: the phone validates arity on
    /// the way into its own suite and then publishes a bare `[Int]` over the wire, which nothing
    /// re-checks on this side.
    private static func mirror(
        isGoalSet: Bool,
        goal: Int = 2_000,
        servings: [Int] = [150, 250, 500],
        composedAt: Date = Date(timeIntervalSince1970: 1_000)
    ) -> WristMirror {
        WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: 0, dailyGoal: goal,
            servings: servings, languageCode: nil, isGoalSet: isGoalSet,
            // The day's end plays no part in what the screen says about where its number came from.
            composedAt: composedAt, phoneDayStart: composedAt, phoneDayEnd: nil, acked: []
        )
    }

    /// Before any sync the watch now draws a usable screen against the default goal rather than a
    /// dead-end nag, so the attribution has to say *which* goal is on screen — otherwise the number
    /// is a confident fiction, which is exactly what spec §5 forbids.
    @Test
    func beforeTheFirstSyncTheAttributionNamesTheDefaultGoal() {
        let text = WristView.attribution(mirror: nil, now: Date(timeIntervalSince1970: 1_000))
        #expect(text == "Not yet synced · default goal")
    }

    /// The one case where telling the user to reach for their phone is genuinely the fix: the mirror
    /// arrived intact, the phone simply has no goal yet. Previously indistinguishable from "no mirror".
    @Test
    func aMirrorWithNoGoalSetAsksForSetupOnTheePhone() {
        let text = WristView.attribution(mirror: Self.mirror(isGoalSet: false), now: Date(timeIntervalSince1970: 1_030))
        #expect(text == "Set your goal in WaterBuddy on iPhone")
    }

    @Test
    func aFullySyncedMirrorFallsBackToTheSyncedCaption() {
        let text = WristView.attribution(mirror: Self.mirror(isGoalSet: true), now: Date(timeIntervalSince1970: 1_000 + 245))
        #expect(text == "Synced 4m ago")
    }

    // MARK: - Which serving the vessel pours, and what is left for the menu

    /// The vessel is the pour button now, and it pours the phone's **middle** quick-add vessel —
    /// index 1, the same one `AddWaterIntent` logs from the Home Screen widget (rule `40-widget`),
    /// so the two ambient front doors on the two devices cannot disagree about what one tap means.
    ///
    /// The symbol is pinned as well as the amount, deliberately: the two come from different
    /// sources — `vesselSlots` for the slot, the mirror for the figure — and an edit could keep one
    /// aligned while silently sliding the other, which is a wrong icon over a right number.
    @Test
    func theVesselPoursThePhonesMiddleVessel() {
        let primary = WristView.primary(from: Self.mirror(isGoalSet: true, servings: [100, 200, 300]))
        #expect(primary.amount == 200)
        #expect(primary.nameKey == "Glass")
        #expect(primary.symbol == "mug.fill")
    }

    @Test
    func theVesselPoursTheDefaultServingBeforeAnySync() {
        #expect(WristView.primary(from: nil).amount == DataManager.defaultServing)
    }

    /// The hardening this restructure actually required, and the reason it is a test and not a
    /// comment. `WristMirror.servings` crosses the wire as a bare `[Int]`: `DataManager`'s own
    /// setter rejects any triple that is not exactly three long, but **nothing re-checks it on this
    /// side of the transfer**. While the three rows were built with `zip`, a short array was
    /// harmless — it truncated and a row simply vanished. Indexing `[1]` for the vessel turns the
    /// same mirror into a trap, so this fallback is what stops a malformed publish taking the
    /// screen's only pour action down with it.
    @Test
    func aMirrorTooShortToNameAMiddleVesselStillPoursTheDefault() {
        let primary = WristView.primary(from: Self.mirror(isGoalSet: true, servings: [100]))
        #expect(primary.amount == DataManager.defaultServing)
    }

    /// Asserts **membership**, not cardinality — `tasks/lessons.md`'s lesson (b), from the applied
    /// ledger's truncation bug: a count assertion passes just as happily against the wrong two
    /// slots, and would not notice the menu offering Cup twice or dropping Bottle for Glass.
    @Test
    func theMenuOffersEverySlotExceptTheOneTheVesselPours() {
        let menu = WristView.secondary(from: Self.mirror(isGoalSet: true, servings: [100, 200, 300]))
        #expect(menu == [
            WristServing(nameKey: "Cup", symbol: "cup.and.saucer.fill", amount: 100),
            WristServing(nameKey: "Bottle", symbol: "waterbottle.fill", amount: 300),
        ])
    }

    /// A mirror carrying no servings at all leaves the menu genuinely empty rather than inventing
    /// amounts the phone never confirmed — `WristView` hides the button entirely rather than
    /// offering one that opens onto nothing — while the vessel still pours its default, so the
    /// screen never loses its only action.
    @Test
    func aMirrorWithNoServingsOffersAnEmptyMenuRatherThanInventedAmounts() {
        let mirror = Self.mirror(isGoalSet: true, servings: [])
        #expect(WristView.secondary(from: mirror).isEmpty)
        #expect(WristView.primary(from: mirror).amount == DataManager.defaultServing)
    }
}
