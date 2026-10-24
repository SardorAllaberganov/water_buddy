//
//  RecapImageTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 24/10/26.
//

import Foundation
import SwiftUI
import Testing
import UniformTypeIdentifiers
@testable import WaterBuddy

private let utcDay: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

/// September 2026 with water on twenty days and a month before to compare with, read on 22 October.
private func september(amount: Int = 2_400) -> MonthHistory? {
    let rows = (1...31).map { WaterLog(amount: 1_800, timestamp: utc(2026, 8, $0)) }
        + (1...20).map { WaterLog(amount: amount, timestamp: utc(2026, 9, $0)) }
    return MonthHistory.make(rows: rows, month: 20260901, firstServing: utc(2026, 8, 1), goal: 2_500,
                             now: utc(2026, 10, 22), calendar: utcDay)
}

@MainActor
private func render<V: View>(_ view: V) -> UIImage? {
    let renderer = ImageRenderer(content: view)
    renderer.scale = RecapCard.imageScale
    return renderer.uiImage
}

/// The image the recap shares (spec `2026-10-24-monthly-recap-design.md` §3.4): a fixed width, the default
/// text size whatever the sender's, in every language.
@MainActor
struct RecapImageTests {

    @Test func theImageIsTenEightyPixelsWide() throws {
        let month = try #require(september())
        let image = try #require(RecapCard.image(of: month, strings: AppLanguage.english.bundle,
                                                 locale: AppLanguage.english.locale))
        #expect(image.size.width * image.scale == 1_080)
    }

    /// Review Focus 3.
    @Test func theImageIgnoresTheSendersTextSize() throws {
        let month = try #require(september())
        let strings = AppLanguage.english.bundle
        let plain = try #require(render(RecapCard.Rendered(month: month)
            .environment(\.strings, strings).environment(\.dynamicTypeSize, .large)))
        let huge = try #require(render(RecapCard.Rendered(month: month)
            .environment(\.strings, strings).environment(\.dynamicTypeSize, .accessibility5)))
        #expect(plain.size == huge.size)
    }

    /// Known issue #182: the tiles' fill is derived from History's own pane — Apple's regular glass tinted
    /// `Aurora.top` — read live on iOS 27.0 over the card's gradient (spec
    /// `2026-10-24-finish-set-a-design.md` §2.4). Drawn through the hand-made sheer stack, with the scrim
    /// and the tint the stack itself declares, it gives that glass back at both ends of the gradient. A
    /// fill retuned by eye fails this, and so does a change to the stack the derivation rests on.
    @Test func theTilesFillGivesBackTheAppsOwnGlass() {
        let scrim = LiquidGlass.scrim(density: .sheer, scheme: .dark, base: RecapCard.tileBase, onPhone: true)
        let tint = LiquidGlass.Density.sheer.tintOpacity(for: .dark)
        #expect(scrim.color == .black, "the derivation takes the flat base's black scrim")
        let fill = RecapCard.tileFill
        // The ground, then the live glass over it, sRGB of 255 — the probe's top and bottom panes.
        let measured: [(ground: [Double], glass: [Double])] = [
            ([30, 34, 137], [28, 45, 154]),
            ([83, 28, 155], [50, 41, 160]),
        ]
        for (ground, glass) in measured {
            for (channel, colour) in [fill.red, fill.green, fill.blue].enumerated() {
                let base = fill.opacity * colour + (1 - fill.opacity) * ground[channel] / 255
                let drawn = tint + (1 - tint) * (1 - scrim.opacity) * base
                #expect(abs(drawn * 255 - glass[channel]) <= 2,
                        "channel \(channel) over \(ground) drew \(drawn * 255), the glass read \(glass[channel])")
            }
        }
    }

    @Test(arguments: [AppLanguage.english, .russian, .uzbek])
    func itRendersInEveryLanguage(language: AppLanguage) throws {
        let month = try #require(september())
        #expect(language.bundle.bundleURL.lastPathComponent == "\(language.code ?? "").lproj",
                "the \(language.code ?? "") strings did not resolve")
        let image = try #require(RecapCard.image(of: month, strings: language.bundle, locale: language.locale))
        #expect(image.size.width * image.scale == 1_080)
    }

    /// Review Focus 4: a 31-day month at the most a day can hold, against a small month before — the
    /// one layout with a fourth row of dots, a single one — still renders whole, and taller than a
    /// 30-day month by that row.
    @Test func theLargestMonthStillRenders() throws {
        let rows = (1...31).map { WaterLog(amount: 500, timestamp: utc(2026, 7, $0)) }
            + (1...31).map { WaterLog(amount: DataManager.maximumDailyIntake, timestamp: utc(2026, 8, $0)) }
        let august = try #require(MonthHistory.make(rows: rows, month: 20260801, firstServing: utc(2026, 7, 1),
                                                    goal: 2_500, now: utc(2026, 10, 22), calendar: utcDay))
        #expect(august.days.count == 31)
        #expect(august.total == 31 * DataManager.maximumDailyIntake)
        let strings = AppLanguage.russian.bundle
        let locale = AppLanguage.russian.locale
        let image = try #require(RecapCard.image(of: august, strings: strings, locale: locale))
        let september = try #require(september())
        let thirty = try #require(RecapCard.image(of: september, strings: strings, locale: locale))
        #expect(image.size.width * image.scale == 1_080)
        #expect(image.size.height > thirty.size.height, "the 31st day's row is missing")
    }

    /// The final review's I1: what `ShareLink` hands the share sheet is the item's exported PNG, not the
    /// `UIImage` in memory — and a picture exported in points would reach a recipient at 360 px.
    @Test func theSharedPictureKeepsItsPixels() async throws {
        // `exported(as:)` is iOS 18.2 and later; the gate runs on 27.0, and the item is the same on 17.
        guard #available(iOS 18.2, *) else { return }
        let month = try #require(september())
        let rendered = try #require(RecapCard.image(of: month, strings: AppLanguage.english.bundle,
                                                    locale: AppLanguage.english.locale))
        let data = try await RecapSheet.sharedItem(rendered).exported(as: .png)
        let received = try #require(UIImage(data: data))
        #expect(received.cgImage?.width == 1_080)
        #expect(received.cgImage?.height == Int(rendered.size.height * rendered.scale))
    }
}
