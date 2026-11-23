//
//  VesselGlyphTests.swift
//  WaterBuddyTests
//

import Testing
import UIKit
@testable import WaterBuddy

/// The seven icons a vessel may wear (spec `2026-11-22-set-c-design.md` D13).
///
/// **Deliberately not `@MainActor`** — `VesselGlyph` is read by the widget's snapshot and the watch, neither of
/// which has a main actor to lean on (rule `43-concurrency`).
struct VesselGlyphTests {

    /// The raw values are what a stored library holds. Renaming one strands every library that stored it.
    @Test func theCodesAreTheOnesALibraryStores() {
        #expect(VesselGlyph.allCases.map(\.rawValue) == ["cup", "glass", "bottle", "wineGlass", "takeaway", "flask", "drop"])
    }

    /// An unknown symbol draws nothing at all — no glyph, no warning (rule `65-accessibility`).
    @Test(arguments: VesselGlyph.allCases)
    func everyGlyphResolves(_ glyph: VesselGlyph) {
        #expect(UIImage(systemName: glyph.symbol) != nil, "\(glyph.symbol) draws nothing on this system")
    }

    @Test func theStandardThreeWearTheirOwnGlyphsInTheirOwnPlaces() {
        #expect(VesselGlyph.standardThree == [.cup, .glass, .bottle])
        #expect(vesselSlots.map(\.symbol) == VesselGlyph.standardThree.map(\.symbol))
        #expect(vesselSlots.map(\.nameKey) == VesselGlyph.standardThree.compactMap(\.standardNameKey))
    }

    @Test func onlyTheStandardThreeHaveAStandardName() {
        #expect(VesselGlyph.allCases.filter { $0.standardNameKey != nil } == VesselGlyph.standardThree)
    }

    @Test func everyGlyphIsSpokenByAName() {
        #expect(Set(VesselGlyph.allCases.map(\.spokenKey)).count == VesselGlyph.allCases.count)
    }
}
