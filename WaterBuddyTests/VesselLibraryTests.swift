//
//  VesselLibraryTests.swift
//  WaterBuddyTests
//

import Foundation
import Testing
@testable import WaterBuddy

/// The library as a value — every rule a stored one keeps, and every change as a pure function
/// (spec `2026-11-22-set-c-design.md` §3.6). **Deliberately not `@MainActor`**: the widget's snapshot and the
/// mirror composer read it from `nonisolated` code (rule `43-concurrency`).
struct VesselLibraryTests {

    static let standard = VesselLibrary.standard(amounts: [150, 250, 500])

    static func mine(_ id: String = UUID().uuidString, _ name: String? = "Office", _ amount: Int = 400,
                     _ glyph: VesselGlyph = .flask) -> Vessel {
        Vessel(id: id, glyph: glyph, name: name, amount: amount)
    }

    // MARK: What a stored library must keep

    @Test func theStandardLibraryIsValidAndStandardOnHome() {
        #expect(Self.standard.isValid)
        #expect(Self.standard.isStandardOnHome)
        #expect(Self.standard.amounts == [150, 250, 500])
        #expect(Self.standard.home.map(\.glyph) == VesselGlyph.standardThree)
        #expect(Self.standard.home.allSatisfy { $0.name == nil })
    }

    @Test func aLibraryOfAnyOtherShapeIsDiscardedWhole() {
        let s = Self.standard.home
        let cases: [(String, VesselLibrary)] = [
            ("two on Home", VesselLibrary(home: Array(s.prefix(2)), more: [s[2]])),
            ("ten more", VesselLibrary(home: s, more: (0..<10).map { _ in Self.mine() })),
            ("an id twice", VesselLibrary(home: s, more: [Self.mine("x"), Self.mine("x")])),
            ("a standard missing", VesselLibrary(home: [s[0], s[1], Self.mine()], more: [])),
            ("a standard renamed", VesselLibrary(home: [s[0], Vessel(id: "glass", glyph: .glass, name: "Mine", amount: 250), s[2]], more: [])),
            ("a standard re-glyphed", VesselLibrary(home: [s[0], Vessel(id: "glass", glyph: .flask, name: nil, amount: 250), s[2]], more: [])),
            ("a vessel of mine unnamed", VesselLibrary(home: s, more: [Self.mine(UUID().uuidString, nil)])),
            ("a name too long", VesselLibrary(home: s, more: [Self.mine(UUID().uuidString, String(repeating: "a", count: 21))])),
            ("an amount of zero", VesselLibrary(home: s, more: [Self.mine(UUID().uuidString, "Office", 0)])),
            ("an amount past the ceiling", VesselLibrary(home: s, more: [Self.mine(UUID().uuidString, "Office", DataManager.maximumDailyIntake + 1)])),
        ]
        for (what, library) in cases {
            #expect(!library.isValid, "\(what) must not pass")
        }
    }

    @Test func aNameIsTrimmedAndBoundedAndOnOneLine() {
        #expect(Vessel.validName("  Stanley  ") == "Stanley")
        #expect(Vessel.validName(String(repeating: "é", count: 20)) == String(repeating: "é", count: 20))
        #expect(Vessel.validName(String(repeating: "a", count: 21)) == nil)
        #expect(Vessel.validName("   ") == nil)
        #expect(Vessel.validName("Two\nlines") == nil)
        #expect(Vessel.validName("🫖 Tea") == "🫖 Tea", "a character is what Swift counts, emoji included")
    }

    // MARK: Changes

    @Test func addingAppendsToMoreAndStopsAtNine() throws {
        var library = Self.standard
        for n in 1...9 {
            library = try #require(library.adding(glyph: .drop, name: "Vessel \(n)", amount: 100 * n, id: "id\(n)"))
        }
        #expect(library.more.count == 9)
        #expect(library.adding(glyph: .drop, name: "Tenth", amount: 100, id: "id10") == nil, "twelve is the most")
        #expect(Self.standard.adding(glyph: .drop, name: "  ", amount: 100, id: "blank") == nil)
        #expect(Self.standard.adding(glyph: .drop, name: "Dup", amount: 100, id: "cup") == nil, "a standard id is taken")
    }

    @Test func aStandardVesselChangesItsAmountAndNothingElse() {
        #expect(Self.standard.updating(id: "glass", glyph: .glass, name: nil, amount: 330)?.home[1].amount == 330)
        #expect(Self.standard.updating(id: "glass", glyph: .glass, name: "Mine", amount: 330) == nil)
        #expect(Self.standard.updating(id: "glass", glyph: .flask, name: nil, amount: 330) == nil)
    }

    @Test func aVesselOfMineChangesItsGlyphNameAndAmount() throws {
        let library = try #require(Self.standard.adding(glyph: .flask, name: "Office", amount: 400, id: "o"))
        let changed = try #require(library.updating(id: "o", glyph: .bottle, name: " Gym ", amount: 750))
        #expect(changed.vessel(id: "o") == Vessel(id: "o", glyph: .bottle, name: "Gym", amount: 750))
        #expect(library.updating(id: "o", glyph: .bottle, name: nil, amount: 750) == nil, "mine keeps a name")
    }

    @Test func onlyAVesselOfMineInMoreCanBeDeleted() throws {
        let library = try #require(Self.standard.adding(glyph: .flask, name: "Office", amount: 400, id: "o"))
        #expect(library.deleting(id: "o")?.more.isEmpty == true)
        #expect(library.deleting(id: "cup") == nil, "a standard vessel is never deleted")
        let onHome = try #require(library.puttingOnHome(id: "o", slot: 0))
        #expect(onHome.deleting(id: "o") == nil, "a vessel on Home is replaced first")
    }

    @Test func puttingOnHomeTradesPlaces() throws {
        let library = try #require(Self.standard.adding(glyph: .flask, name: "Stanley", amount: 1_180, id: "s"))
        let picked = try #require(library.puttingOnHome(id: "s", slot: 1))
        #expect(picked.home.map(\.id) == ["cup", "s", "bottle"])
        #expect(picked.more.map(\.id) == ["glass"], "the Glass takes the Stanley's place in More")
        #expect(picked.amounts == [150, 1_180, 500], "what Key.servings will hold")
        let moved = try #require(picked.puttingOnHome(id: "bottle", slot: 1))
        #expect(moved.home.map(\.id) == ["cup", "bottle", "s"], "two Home slots trade")
        #expect(library.puttingOnHome(id: "nobody", slot: 1) == nil)
        #expect(library.puttingOnHome(id: "s", slot: 3) == nil)
    }

    @Test func standardOnHomeKeepsEveryVesselStored() throws {
        var library = try #require(Self.standard.adding(glyph: .flask, name: "A", amount: 400, id: "a"))
        library = try #require(library.adding(glyph: .drop, name: "B", amount: 200, id: "b"))
        library = try #require(library.puttingOnHome(id: "a", slot: 1))
        library = try #require(library.puttingOnHome(id: "glass", slot: 2))   // Glass right, Bottle to More
        let back = library.standardOnHome()
        #expect(back.isStandardOnHome)
        #expect(Set(back.all.map(\.id)) == Set(library.all.map(\.id)), "nothing is deleted")
        #expect(back.isValid)
    }

    @Test func homesAmountsCanBeReplacedAsAWhole() {
        #expect(Self.standard.withHomeAmounts([200, 330, 750])?.amounts == [200, 330, 750])
        #expect(Self.standard.withHomeAmounts([200, 330]) == nil)
        #expect(Self.standard.withHomeAmounts([0, 330, 750]) == nil, "the setter clamps before it gets here")
    }

    @Test func aStandardVesselIsNamedInTheLanguageDrawnAndMineAsTyped() {
        let english = AppLanguage.english.bundle
        #expect(Self.standard.home[1].name(in: english) == "Glass")
        #expect(Self.standard.home[1].name(in: AppLanguage.russian.bundle) == "Стакан")
        #expect(Self.mine("x", "Stanley 40oz").name(in: AppLanguage.russian.bundle) == "Stanley 40oz")
    }

    @Test func aLibraryRoundTripsAndAnUnknownGlyphDoesNot() throws {
        let library = try #require(Self.standard.adding(glyph: .wineGlass, name: "Wine", amount: 150, id: "w"))
        let data = try JSONEncoder().encode(library)
        #expect(try JSONDecoder().decode(VesselLibrary.self, from: data) == library)
        let foreign = Data(String(decoding: data, as: UTF8.self).replacingOccurrences(of: "wineGlass", with: "teapot").utf8)
        #expect((try? JSONDecoder().decode(VesselLibrary.self, from: foreign)) == nil)
    }
}
