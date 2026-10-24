//
//  PrivacyManifestTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 24/10/26.
//

import Foundation
import Testing

// MARK: - Fixtures

/// The four shipping bundles' privacy manifests, read out of the **built** app this target is hosted
/// by — the artifact App Store Connect reads, never the source tree (`LocalizationTests`' reason: a
/// host path under `~/Desktop` is TCC-protected on the simulator, and the inputs are not the upload).
///
/// A function, not a stored constant, so nothing non-`Sendable` sits in a global (rule
/// `43-concurrency`).
private func shippingManifests() -> [(bundle: String, manifest: Data?)] {
    let app = Bundle.main
    let widget = Bundle(url: app.bundleURL.appending(path: "PlugIns/WaterBuddyWidgetExtension.appex"))
    let watch = Bundle(url: app.bundleURL.appending(path: "Watch/WaterBuddyWatch.app"))
    let watchWidget = watch.flatMap {
        Bundle(url: $0.bundleURL.appending(path: "PlugIns/WaterBuddyWatchWidget.appex"))
    }
    return [
        ("WaterBuddy.app", app),
        ("WaterBuddyWidgetExtension.appex", widget),
        ("WaterBuddyWatch.app", watch),
        ("WaterBuddyWatchWidget.appex", watchWidget),
    ].map { name, bundle in
        (name, bundle?.url(forResource: "PrivacyInfo", withExtension: "xcprivacy").flatMap { try? Data(contentsOf: $0) })
    }
}

private func propertyList(_ data: Data) -> [String: Any]? {
    try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
}

// MARK: - The manifests

/// What every upload declares (rule `15-project`, *Submission*). App Store Connect refuses an upload
/// whose binary calls a required-reason API its manifest does not name, after a green archive — so
/// nothing in the gate would otherwise see one go missing. Spec
/// `docs/superpowers/specs/2026-10-24-privacy-policy-design.md` §1.4, §3.3.
struct PrivacyManifestTests {

    /// A bundle that lost its manifest, or one edited without the other three, fails here: the four
    /// are byte-identical by rule, and each must be in reach first, or every check below passes on
    /// nothing.
    @Test func everyShippingBundleCarriesTheSameManifest() throws {
        let manifests = shippingManifests()
        for (bundle, manifest) in manifests {
            #expect(manifest != nil, "\(bundle) carries no PrivacyInfo.xcprivacy — or is not in the test host")
        }
        let first = try #require(manifests.first?.manifest)
        for (bundle, manifest) in manifests.dropFirst() {
            #expect(manifest == first, "\(bundle)'s manifest differs from the app's")
        }
    }

    /// No account, no server, no analytics (rule `70-privacy`): a manifest that declared tracking, a
    /// domain or a collected data type would contradict the privacy label's *Data Not Collected*.
    @Test func theManifestDeclaresNoTrackingAndNoCollectedData() throws {
        let manifest = try #require(shippingManifests().first?.manifest)
        let list = try #require(propertyList(manifest), "the app's manifest is not a property list")
        #expect(list["NSPrivacyTracking"] as? Bool == false)
        #expect((list["NSPrivacyTrackingDomains"] as? [Any])?.isEmpty == true)
        #expect((list["NSPrivacyCollectedDataTypes"] as? [Any])?.isEmpty == true)
    }

    /// The required-reason APIs the code calls, each with its reason, and nothing more:
    /// `UserDefaults` — the App Group suite (`1C8F.1`) and the `.standard` fallback and migration
    /// (`CA92.1`) — and `ProcessInfo.systemUptime`, which `AuroraClock` reads to place the aurora's
    /// lights by the time elapsed since the first backdrop drew (`35F9.1`, *System boot time*).
    @Test func theManifestDeclaresUserDefaultsAndTheBootTimeTheAuroraReads() throws {
        let manifest = try #require(shippingManifests().first?.manifest)
        let list = try #require(propertyList(manifest), "the app's manifest is not a property list")
        let entries = try #require(list["NSPrivacyAccessedAPITypes"] as? [[String: Any]])
        var declared: [String: Set<String>] = [:]
        for entry in entries {
            let category = try #require(entry["NSPrivacyAccessedAPIType"] as? String)
            let reasons = try #require(entry["NSPrivacyAccessedAPITypeReasons"] as? [String])
            declared[category, default: []].formUnion(reasons)
        }
        #expect(declared == [
            "NSPrivacyAccessedAPICategoryUserDefaults": ["1C8F.1", "CA92.1"],
            "NSPrivacyAccessedAPICategorySystemBootTime": ["35F9.1"],
        ])
    }
}
