//
//  WristViewLogicTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Testing
@testable import WaterBuddyWatch

/// One language's strings as the watch ships them. This suite is hosted by the watch app
/// (`TEST_HOST`), so `Bundle.main` here is `WaterBuddyWatch.app` and these are its own `.lproj`s —
/// the same lookup `AppLanguage.bundle` makes.
private func shipped(_ language: String) -> Bundle? {
    Bundle.main.url(forResource: language, withExtension: "lproj").flatMap(Bundle.init(url:))
}

/// The pure functions `WristView` reads from — which servings to offer, which single one the
/// vessel itself pours, what is left for the menu, and how the sync line reads — pulled out so
/// they're testable without instantiating a `View` at all (rule `43-concurrency`'s "a value type a
/// non-@MainActor suite reads is declared at file scope" extended to functions for the same
/// reason). This suite is deliberately **not** `@MainActor`; that is what proves the claim.
struct WristViewLogicTests {

    /// Every bundle below is the watch app's own, and every assertion against one is vacuous if it
    /// didn't resolve — so this runs over the languages the product *offers*, not a list typed here
    /// (review focus: a language added to `AppLanguage.selectable` must not silently draw English
    /// on the watch).
    @Test(arguments: AppLanguage.selectable.compactMap(\.code))
    func theWatchShipsAStringsBundleForEveryLanguage(language: String) {
        #expect(shipped(language) != nil, "the watch app ships no \(language).lproj")
    }

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
    func syncedJustNowReadsAsNow() throws {
        let english = try #require(shipped("en"))
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_030), strings: english, locale: Locale(identifier: "en"))
        #expect(text == "Synced just now")
    }

    @Test
    func syncedMinutesAgoReadsInWholeMinutes() throws {
        let english = try #require(shipped("en"))
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_000 + 245), strings: english, locale: Locale(identifier: "en"))
        #expect(text == "Synced 4m ago")
    }

    @Test
    func noMirrorYetReadsAsNeverSynced() throws {
        let english = try #require(shipped("en"))
        #expect(WristView.syncedCaption(composedAt: nil, now: .now, strings: english, locale: Locale(identifier: "en")) == "Not yet synced")
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
    func beforeTheFirstSyncTheAttributionNamesTheDefaultGoal() throws {
        let english = try #require(shipped("en"))
        let text = WristView.attribution(mirror: nil, now: Date(timeIntervalSince1970: 1_000), strings: english, locale: Locale(identifier: "en"))
        #expect(text == "Not yet synced · default goal")
    }

    /// The one case where telling the user to reach for their phone is genuinely the fix: the mirror
    /// arrived intact, the phone simply has no goal yet. Previously indistinguishable from "no mirror".
    @Test
    func aMirrorWithNoGoalSetAsksForSetupOnTheePhone() throws {
        let english = try #require(shipped("en"))
        let text = WristView.attribution(mirror: Self.mirror(isGoalSet: false), now: Date(timeIntervalSince1970: 1_030), strings: english, locale: Locale(identifier: "en"))
        #expect(text == "Set your goal in WaterBuddy on iPhone")
    }

    @Test
    func aFullySyncedMirrorFallsBackToTheSyncedCaption() throws {
        let english = try #require(shipped("en"))
        let text = WristView.attribution(mirror: Self.mirror(isGoalSet: true), now: Date(timeIntervalSince1970: 1_000 + 245), strings: english, locale: Locale(identifier: "en"))
        #expect(text == "Synced 4m ago")
    }

    /// Every caption state in the owner-approved Russian, word for word
    /// (`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §4.4).
    @Test
    func everyCaptionReadsInRussian() throws {
        let russian = try #require(shipped("ru"))
        let start = Date(timeIntervalSince1970: 1_000)
        let neverSynced = WristView.attribution(mirror: nil, now: start, strings: russian, locale: Locale(identifier: "ru"))
        let noGoal = WristView.attribution(mirror: Self.mirror(isGoalSet: false), now: start, strings: russian, locale: Locale(identifier: "ru"))
        let noDate = WristView.syncedCaption(composedAt: nil, now: start, strings: russian, locale: Locale(identifier: "ru"))
        let justNow = WristView.syncedCaption(composedAt: start, now: start.addingTimeInterval(30), strings: russian, locale: Locale(identifier: "ru"))
        let minutes = WristView.syncedCaption(composedAt: start, now: start.addingTimeInterval(245), strings: russian, locale: Locale(identifier: "ru"))

        #expect(neverSynced == "Нет синхронизации · цель по умолчанию")
        #expect(noGoal == "Задайте цель в WaterBuddy на iPhone")
        #expect(noDate == "Нет синхронизации")
        #expect(justNow == "Синхронизировано только что")
        #expect(minutes == "Синхронизировано 4 мин назад")
    }

    /// The same states in Uzbek. The apostrophes are `’` and `‘`, the ones the phone's catalogue
    /// already uses.
    @Test
    func everyCaptionReadsInUzbek() throws {
        let uzbek = try #require(shipped("uz"))
        let start = Date(timeIntervalSince1970: 1_000)
        let neverSynced = WristView.attribution(mirror: nil, now: start, strings: uzbek, locale: Locale(identifier: "uz"))
        let noGoal = WristView.attribution(mirror: Self.mirror(isGoalSet: false), now: start, strings: uzbek, locale: Locale(identifier: "uz"))
        let noDate = WristView.syncedCaption(composedAt: nil, now: start, strings: uzbek, locale: Locale(identifier: "uz"))
        let justNow = WristView.syncedCaption(composedAt: start, now: start.addingTimeInterval(30), strings: uzbek, locale: Locale(identifier: "uz"))
        let minutes = WristView.syncedCaption(composedAt: start, now: start.addingTimeInterval(245), strings: uzbek, locale: Locale(identifier: "uz"))

        #expect(neverSynced == "Hali sinxronlanmagan · standart maqsad")
        #expect(noGoal == "Maqsadni iPhone’dagi WaterBuddy’da belgilang")
        #expect(noDate == "Hali sinxronlanmagan")
        #expect(justNow == "Hozirgina sinxronlandi")
        #expect(minutes == "4 daqiqa oldin sinxronlandi")
    }

    /// Review focus: a phone whose clock runs ahead of the watch's stamps `composedAt` in the
    /// watch's future. That reads "just now" in every language — never "Synced -3m ago".
    @Test(arguments: ["en", "ru", "uz"])
    func aMirrorFromThePhonesFutureReadsAsJustNow(language: String) throws {
        let strings = try #require(shipped(language))
        let expected = ["en": "Synced just now", "ru": "Синхронизировано только что", "uz": "Hozirgina sinxronlandi"]
        let watchNow = Date(timeIntervalSince1970: 1_000)
        let text = WristView.syncedCaption(composedAt: watchNow.addingTimeInterval(180), now: watchNow, strings: strings, locale: Locale(identifier: language))
        #expect(text == expected[language])
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

    // MARK: - The pour row (spec 2026-10-20 §3.4)

    /// Cup, Glass, Bottle — `vesselSlots`' order — each with the phone's amount. Membership and
    /// order both, so a slot sliding onto the wrong amount fails too (lesson (b)).
    @Test
    func theRowOffersCupGlassAndBottleInTheirSlotsOrder() {
        let row = WristView.pourRow(from: Self.mirror(isGoalSet: true, servings: [100, 200, 300]))
        #expect(row == [
            WristServing(nameKey: "Cup", symbol: "cup.and.saucer.fill", amount: 100),
            WristServing(nameKey: "Glass", symbol: "mug.fill", amount: 200),
            WristServing(nameKey: "Bottle", symbol: "waterbottle.fill", amount: 300),
        ])
        #expect(WristView.pourRow(from: nil).map(\.amount) == DataManager.defaultServings)
    }

    /// Review focus 1: the wire's `[Int]` is not re-checked on this side. A short or empty mirror
    /// leaves a smaller row — never an empty one, and never one without the Glass.
    @Test
    func theRowKeepsTheGlassForAShortOrEmptyMirror() {
        let short = WristView.pourRow(from: Self.mirror(isGoalSet: true, servings: [100]))
        #expect(short == [
            WristServing(nameKey: "Cup", symbol: "cup.and.saucer.fill", amount: 100),
            WristServing(nameKey: "Glass", symbol: "mug.fill", amount: DataManager.defaultServing),
        ])
        let empty = WristView.pourRow(from: Self.mirror(isGoalSet: true, servings: []))
        #expect(empty == [WristServing(nameKey: "Glass", symbol: "mug.fill", amount: DataManager.defaultServing)])
    }

    /// Review focus 2: a vessel of a litre is grouped wherever the row says it.
    @Test
    func aVesselOfAThousandIsGroupedEverywhereTheRowSaysIt() throws {
        let english = try #require(shipped("en"))
        let en = AppLanguage.english.locale
        let bottle = WristServing(nameKey: "Bottle", symbol: "waterbottle.fill", amount: 1_000)
        #expect(WristView.amountLabel(bottle.amount, strings: english, locale: en) == "1,000 ml")
        #expect(WristView.pourLabel(for: bottle, strings: english, locale: en) == "Bottle, add 1,000 millilitres")
    }

    /// The phone's own sentence for a quick-add vessel, in each language, in the form its count takes.
    @Test(arguments: ["en", "ru", "uz"])
    func eachButtonIsLabelledWithThePhonesSentence(language: String) throws {
        let strings = try #require(shipped(language))
        let glass = WristServing(nameKey: "Glass", symbol: "mug.fill", amount: 250)
        let expected = [
            "en": "Glass, add 250 millilitres",
            "ru": "Стакан, добавить 250 миллилитров",
            "uz": "Stakan, 250 millilitr qo‘shish",
        ]
        #expect(WristView.pourLabel(for: glass, strings: strings, locale: Locale(identifier: language)) == expected[language])
    }

    /// Review focus 5: the phone set to Russian, whatever the watch speaks — the line and the labels
    /// take the bundle and the locale `WristModel.language` resolves from the mirror.
    @Test
    func theLineAndTheLabelsFollowThePhonesLanguage() {
        let russian = AppLanguage(code: "ru")
        let line = WristPlan.Face(total: 1_250, goal: 2_000).millilitreLine(in: russian.bundle, locale: russian.locale)
        let label = WristView.pourLabel(for: WristServing(nameKey: "Glass", symbol: "mug.fill", amount: 250),
                                        strings: russian.bundle, locale: russian.locale)
        #expect(line.hasSuffix(" мл") && line.contains(" из "), "\(line) is not the Russian line")
        #expect(!line.contains(","), "\(line) groups with the English separator")
        #expect(label.hasPrefix("Стакан"), "\(label) is not the Russian label")
    }

    // MARK: - Names and the readout, in the chosen language (spec 2026-10-06 §4.3)

    /// All three slots, in order, so a name that slid onto the wrong vessel fails too. The names
    /// are the phone's own (`Cup`, `Glass`, `Bottle`), copied value for value.
    @Test
    func theServingNamesAreTranslated() throws {
        let english = try #require(shipped("en"))
        let russian = try #require(shipped("ru"))
        let uzbek = try #require(shipped("uz"))
        let slots = WristView.servings(from: nil)

        let inEnglish = slots.map { $0.name(in: english) }
        let inRussian = slots.map { $0.name(in: russian) }
        let inUzbek = slots.map { $0.name(in: uzbek) }

        #expect(inEnglish == ["Cup", "Glass", "Bottle"])
        #expect(inRussian == ["Чашка", "Стакан", "Бутылка"])
        #expect(inUzbek == ["Chashka", "Stakan", "Shisha"])
    }

    /// Review focus: the empty state and five-digit figures as well as the everyday four. English is
    /// pinned exactly. Russian and Uzbek group with a no-break space whose exact code point has
    /// changed between OS releases, so it is matched as "a non-digit splits the figure". Uzbek puts
    /// the goal first (*2 000 dan 1 250 ml*).
    @Test
    func theLineUnderTheVesselGroupsThousandsInTheChosenLanguage() throws {
        let english = try #require(shipped("en"))
        let russian = try #require(shipped("ru"))
        let uzbek = try #require(shipped("uz"))
        let en = AppLanguage.english.locale

        #expect(WristPlan.Face(total: 1_250, goal: 2_000).millilitreLine(in: english, locale: en) == "1,250 of 2,000 ml")
        #expect(WristPlan.Face(total: 0, goal: 2_000).millilitreLine(in: english, locale: en) == "0 of 2,000 ml")
        #expect(WristPlan.Face(total: 12_500, goal: 10_000).millilitreLine(in: english, locale: en) == "12,500 of 10,000 ml")

        let others: [(Bundle, Locale, String, String)] = [
            (russian, AppLanguage.russian.locale, "мл", "12502000"),
            (uzbek, AppLanguage.uzbek.locale, "ml", "20001250"),
        ]
        for (strings, locale, unit, digitsInOrder) in others {
            let text = WristPlan.Face(total: 1_250, goal: 2_000).millilitreLine(in: strings, locale: locale)
            #expect(text.hasSuffix(" \(unit)"), "\(text) does not end in its own unit")
            #expect(text.filter(\.isNumber) == digitsInOrder, "\(text) lost, gained or misplaced a digit")
            #expect(!text.contains("1250") && !text.contains("2000"), "\(text) is not grouped")
            #expect(!text.contains(","), "\(text) groups with the English separator")
        }
    }

    // MARK: - How much readability scrim the vessel lays down (known issue #35)

    /// The bug itself. At 0% there is no water behind the readout to hold back, so a scrim only
    /// darkens the glass — at full strength the empty vessel drew as a near-black disc, every watch's
    /// first screen of the day and the shipped App Store image. Without it the percentage sits over
    /// the bare glass alone (`WristVessel.scrimIntensity(at:)` carries the measured figures).
    @Test
    func anEmptyWatchVesselLaysDownNoScrim() {
        #expect(WristVessel.scrimIntensity(at: 0) == 0)
        #expect(WristVessel.scrimIntensity(at: -0.1) == 0, "a level below empty is still no water")
    }

    /// Below full strength the scrim comes on with the water rather than all at once — "only as much
    /// shade as there is water to hold back", the phone widget's own reasoning. One that switched on
    /// at the threshold would visibly pop on a pour; one that thinned as the water rose would be the
    /// ramp run backwards.
    @Test
    func theWatchScrimRampsUpWithTheWaterBelowFullStrength() {
        let full = WristVessel.scrimFullStrengthLevel
        let ramp = [0.25, 0.5, 0.75].map { WristVessel.scrimIntensity(at: full * $0) }
        #expect(ramp.allSatisfy { $0 > 0 && $0 < 1 }, "\(ramp) is not a partial scrim below full strength")
        #expect(zip(ramp, ramp.dropFirst()).allSatisfy { $0 < $1 }, "\(ramp) does not rise with the water")
    }

    /// Where water first reaches the percentage — since stage 7 the vessel's lowest readout, the
    /// millilitre line having moved out of the water (#44) — worked out from the vessel's own
    /// geometry, not from the code under test: the water sits in a well inset 6 pt from the rim, its
    /// wave peaks `0.02 × diameter` above the mean surface, and the figure's lowest ink sits
    /// `0.12 × diameter` below the centre — measured off `ImageRenderer` renders at 60, 77, 80, 100
    /// and 123 pt (0.106 to 0.115) and rounded up (spec 2026-10-20 §3.4).
    private static func waterReachesThePercentage(_ diameter: Double) -> Double {
        let inset = 6.0
        let crest = 0.02 * diameter
        let inkBottom = 0.12 * diameter
        return (diameter / 2 - inset - crest - inkBottom) / (diameter - 2 * inset)
    }

    /// Full strength before water can be behind the figure, on every size: the percentage is large
    /// text held to 3:1, and a ramp still climbing as water reaches it would give contrast away.
    @Test(arguments: [60.0, 80, 100, 123])
    func theWatchScrimIsAtFullStrengthBeforeWaterCanReachThePercentage(diameter: Double) {
        #expect(WristVessel.scrimIntensity(at: Self.waterReachesThePercentage(diameter)) == 1)
        #expect(WristVessel.scrimIntensity(at: 1) == 1)
    }

    /// And no sooner than it needs to be: below where water reaches the figure, only glass is behind
    /// it, and the scrim is "only as much shade as there is water to hold back"
    /// (`WaterReadabilityScrim`). The ramp the millilitre line needed — full by 20% — darkened the
    /// vessel for nothing once the line left the water.
    @Test
    func belowWhereWaterReachesThePercentageTheScrimIsStillRamping() {
        let earliest = [60.0, 80, 100, 123].map(Self.waterReachesThePercentage).min()!
        #expect(WristVessel.scrimIntensity(at: earliest - 0.05) < 1)
    }
}
