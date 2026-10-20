//
//  WristVesselLayoutTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Testing
@testable import WaterBuddyWatch

struct WristVesselLayoutTests {

    /// The vessel takes what the line and the row leave, between its floor and its ceiling
    /// (spec 2026-10-20 §3.4) — `HomeView.vesselDiameter`'s arithmetic, one device over.
    @Test
    func theVesselTakesWhatTheLineAndTheRowLeave() {
        #expect(WristColumn.diameter(available: 210, others: 100, range: 60...100) == 100, "held at its ceiling")
        #expect(WristColumn.diameter(available: 180, others: 100, range: 60...100) == 80)
        #expect(WristColumn.diameter(available: 140, others: 100, range: 60...100) == 60, "held at its floor; the screen scrolls")
    }

    /// The sync caption gives way to the vessel, never the vessel to it (spec 2026-10-20 §3.4, §9):
    /// where it fits it takes what is spare and the screen stands still; where it does not, the
    /// vessel keeps its size and the caption is a turn of the crown away. Heights in order — the
    /// vessel's own (ignored), the line, the row with its amounts, the caption — with 6 pt gaps.
    @Test
    func theCaptionTakesFromTheSpareNeverFromTheVessel() {
        let furniture: [CGFloat] = [0, 16, 62, 14]
        let roomy = WristColumn.arrangement(height: 230, width: 192, heights: furniture, range: 60...100)
        #expect(roomy.diameter == 100)
        #expect(roomy.spare == 20, "230 less the vessel, the line, the row, the caption and three gaps")
        let tight = WristColumn.arrangement(height: 200, width: 192, heights: furniture, range: 60...100)
        #expect(tight.diameter == 100, "the caption does not shrink the vessel")
        #expect(tight.spare == 0, "it falls below the fold instead")
    }

    /// The column runs into the bottom safe-area inset — the screen's rounded corners, where a scroll
    /// view still draws — but stops the canvas's 22 pt short of the bottom edge, so the amounts under
    /// the discs stay clear of the corners (the owner's ruling, 2026-10-20, from the 46 mm render:
    /// its safe area is 159 pt tall with a 36 pt bottom inset, and the canvas's own layout did not
    /// fit below the real clock). An inset no deeper than the margin adds nothing.
    @Test
    func theColumnRunsIntoTheBottomInsetDownToTheCanvasMargin() {
        #expect(WristView.columnHeight(safeHeight: 159, bottomInset: 36) == 173)
        #expect(WristView.columnHeight(safeHeight: 159, bottomInset: 22) == 159)
        #expect(WristView.columnHeight(safeHeight: 159, bottomInset: 10) == 159)
        #expect(WristView.columnHeight(safeHeight: 159, bottomInset: 0) == 159)
    }

    /// A column's fair share of the row: the width less the least gaps, split evenly, in whole points
    /// so three shares and their gaps never sum past the row. 142 pt is the 40 mm watch's row, 188 the
    /// 46 mm's, 164 the 44 mm's.
    @Test
    func eachColumnGetsAnEvenShareOfTheRow() {
        #expect(WristView.columnShare(rowWidth: 142, count: 3) == 44)
        #expect(WristView.columnShare(rowWidth: 188, count: 3) == 60)
        #expect(WristView.columnShare(rowWidth: 164, count: 3) == 52)
        #expect(WristView.columnShare(rowWidth: 142, count: 1) == 142)
    }

    /// Below the accessibility sizes a disc gives way to its column's share, down to the 44 pt floor,
    /// where three do not fit — the 40 mm watch, whose renders put the last amount off its edge at
    /// the default size, and whose row would scroll sideways from xLarge on (spec 2026-10-20 §3.4: "at
    /// least 44pt, the canvas's 46pt where the screen allows"). At the accessibility sizes a disc
    /// keeps the size type gave it and the row scrolls instead; none goes under the floor or over the
    /// ceiling (rule `65-accessibility`).
    @Test
    func aDiscGivesWayToTheFloorBelowTheAccessibilitySizes() {
        #expect(WristView.discDiameter(scaled: 46, rowWidth: 188, count: 3, accessibilitySize: false) == 46, "room for the canvas's disc")
        #expect(WristView.discDiameter(scaled: 52, rowWidth: 188, count: 3, accessibilitySize: false) == 52, "room for one grown by type")
        #expect(WristView.discDiameter(scaled: 46, rowWidth: 142, count: 3, accessibilitySize: false) == 44, "the 40 mm watch")
        #expect(WristView.discDiameter(scaled: 49, rowWidth: 142, count: 3, accessibilitySize: false) == 44, "the 40 mm watch at xLarge")
        #expect(WristView.discDiameter(scaled: 52, rowWidth: 142, count: 3, accessibilitySize: true) == 52, "an accessibility size: kept, and the row scrolls")
        #expect(WristView.discDiameter(scaled: 70, rowWidth: 188, count: 3, accessibilitySize: true) == 56, "held at the ceiling")
        #expect(WristView.discDiameter(scaled: 40, rowWidth: 188, count: 3, accessibilitySize: false) == 44, "never under the floor")
        #expect(WristView.discDiameter(scaled: 46, rowWidth: 100, count: 3, accessibilitySize: false) == 44, "never under the floor, even when nothing fits")
    }

    /// The "%" never drops under the canvas's own 14 pt, so it stays large text — bold at 14 pt — held
    /// to 3:1 over the water on every watch (the owner's ruling, 2026-10-20). At the share alone it
    /// was 11 pt in the 46 mm watch's 77 pt vessel and 8 pt at the 60 pt floor: small text, measured
    /// at 3.99:1 over a full vessel against 4.5. Above 100 pt it grows with the vessel again.
    @Test(arguments: [(CGFloat(60), CGFloat(14)), (CGFloat(77), CGFloat(14)), (CGFloat(100), CGFloat(14)), (CGFloat(123), CGFloat(17.22))])
    func theSignStaysLargeTextOnEveryWatch(diameter: CGFloat, size: CGFloat) {
        #expect(abs(WristVessel.signSize(diameter: diameter) - size) < 0.01)
    }

    /// The canvas drew a 100 pt vessel on the 46 mm screen's 208 pt; every watch keeps that share as
    /// its ceiling, and none goes under the 60 pt floor below which the readout stops being legible.
    @Test(arguments: [(CGFloat(162), CGFloat(77.88)), (CGFloat(208), CGFloat(100)), (CGFloat(100), CGFloat(60))])
    func theCeilingIsTheCanvasShareOfTheScreen(width: CGFloat, ceiling: CGFloat) {
        let range = WristView.vesselRange(screenWidth: width)
        #expect(range.lowerBound == 60)
        #expect(abs(range.upperBound - ceiling) < 0.01)
    }

    /// The call-site bug this pins: `WristView` drew the vessel inside a `.frame(height: 140)` but
    /// sized it with `diameter(fitting:reserving:)` and `reserving: 0`, which reduces that formula to
    /// `max(60, width)` — a ~185pt circle in a 140pt box on a 46mm watch, overflowing into the pour
    /// rows below. Height is the binding constraint on this screen, and the old signature could not
    /// express it. Every real watch width/height pair must fit **both** dimensions.
    @Test(arguments: [
        (CGFloat(184), CGFloat(140)),   // 46mm
        (CGFloat(176), CGFloat(140)),   // 45mm
        (CGFloat(162), CGFloat(140)),   // 42mm
        (CGFloat(155), CGFloat(140)),   // 41mm
        (CGFloat(198), CGFloat(140)),   // 49mm Ultra
    ])
    func theVesselFitsInsideBothItsWidthAndItsHeight(size: (width: CGFloat, height: CGFloat)) {
        let diameter = WristVessel.diameter(fitting: size.width, within: size.height)
        #expect(diameter <= size.width, "a vessel wider than its row clips horizontally")
        #expect(diameter <= size.height, "a vessel taller than its frame overflows into the pour rows")
        #expect(diameter >= 60, "the 60pt floor still holds")
    }

    @Test
    func theHeightConstraintWinsWhenItIsTheTighterOne() {
        // 46mm: 184pt wide, 140pt tall — height is what must bind.
        #expect(WristVessel.diameter(fitting: 184, within: 140) == 140)
    }
}
