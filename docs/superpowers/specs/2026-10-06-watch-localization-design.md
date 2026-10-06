# The watch, in the user's language — design

**Status:** **approved by the owner and implemented, 2026-10-06.** The design was approved section by
section in conversation, this written spec on review, and the plan
(`docs/superpowers/plans/2026-10-06-watch-localization.md`) executed the same day, staged for the
owner's `/commit`. It closes `docs/AI_CONTEXT.md` known issues **#18** (the watch draws hard-coded
English) and **#19** (`WristMirror.languageCode` is a wire field nothing reads). The results, and
the rulings made in execution, are in `HISTORY.md`'s checkpoint of that date; §6.4's live switch,
"More" sheet and face-editor checks were skipped at the owner's choice. *(This line read "awaiting
the owner's review … No code has been written" until the third `/doc_sync` run of 2026-10-06.)*

**Authority.** This document is subordinate to the DocC on the type being changed, then
`.claude/rules/`, then `CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code
wins and this document changes.

**Provenance.** Every claim about the repository was read from the line cited, at HEAD `638a883` on
2026-10-06. Line numbers go stale as soon as code moves (`tasks/lessons.md`, 2026-09-01), so
re-derive one before relying on it.

---

## 1. What is being built

A Russian- or Uzbek-language user sees their language everywhere the watch draws words:
`WristView`'s screen, the "More" sheet, every VoiceOver string on both, and the complication's
description in the watch-face editor. English stays the default.

Done means all three of these:

1. Tests prove three things: every string the watch shares with the phone reads identically, every
   watch string is translated (apart from the two non-words named in §2), and the watch picks its
   language the way §3 rules (§6.1–§6.3).
2. The watch is seen rendering Russian and Uzbek on a simulator, with nothing clipped (§6.4).
3. The five-invocation gate is green, with no new warning against the Xcode 27 baseline (§6.5).

## 2. What is wrong today

Neither `WaterBuddyWatch/` nor `WaterBuddyWatchWidget/` holds a string catalogue, and nothing under
either injects `\.strings` or `\.locale`. Known issue #18 counted eleven English sites in
`WristView.swift`. Re-derived for this design, the real count is **fifteen strings across three
files**:

| File | Line | String | Kind |
|---|---|---|---|
| `WristView.swift` | 222 | `Today's hydration` | VoiceOver label |
| | 223 | `\(percentage) percent, \(total) of \(goal) millilitres` | VoiceOver value |
| | 224 | `Logs \(amount) millilitres` | VoiceOver hint |
| | 261 | `More` (verbatim) | visible label |
| | 278 | `More servings` | VoiceOver label |
| | 279 | `Shows the other serving sizes` | VoiceOver hint |
| | 354 | `Not yet synced · default goal` | caption |
| | 355 | `Set your goal in WaterBuddy on iPhone` | caption |
| | 363 | `Not yet synced` | caption |
| | 365 | `Synced just now` and `Synced \(minutes)m ago` | caption (two strings) |
| | 404 | `serving.nameKey` — `Cup`, `Glass`, `Bottle` — verbatim | sheet |
| | 409 | `\(amount) ml` (verbatim) | sheet |
| `WristVessel.swift` | 47 | `\(volume) / \(goal) ml` | readout |
| `WaterBuddyWatchWidget.swift` | 85 | `Today's hydration.` | complication description |

#18 missed `:365`'s two captions, `WristVessel`'s readout and the complication's description. Two
more literals are not words and stay untranslated on purpose: `%` (`WristVessel.swift:44`) and
`WaterBuddy` (`WaterBuddyWatchWidget.swift:84`). The second is the product's name, and
`theProductNameIsNeverTranslated` already pins the phone's equivalent.

`WristMirror.languageCode` is composed on every publish (`DataManager.swift:1451`,
`resolveLanguage(in: defaults).code`), and the watch persists it inside `Key.wristMirror`. Nothing
under `WaterBuddyWatch/` or `WaterBuddyWatchWidget/` reads it (#19).

## 3. Rulings (the owner, 2026-10-06)

1. **The watch follows the phone's in-app language.** It reads `WristMirror.languageCode`. A `nil`
   code (the phone set to *Follow device*) and the time before the first mirror arrives both mean
   the watch's **own** system language. Rejected alternative: "the watch's own language only". It
   would ignore the in-app picker and leave #19 dead.
2. **Copy the phone's pattern** (approach A). A root view injects `\.strings` and `\.locale`;
   literals go through `Text(_:bundle:)` and `String(format: strings.localizedString(…))`; pure
   functions take a `Bundle`. Rejected alternatives:
   - **A state enum the view maps to keys** (approach B). It would rewrite every existing caption
     assertion, and it departs from the "functions taking a bundle" pattern the phone already uses:
     `AppLanguage.name(in:)` and `HomeView.Serving.name(in:)` (`tasks/lessons.md`, 2026-08-29).
   - **The phone sending ready-made text.** The caption counts up on the watch's own clock, and the
     screen has to work before any sync.
3. **The vessel's readout keeps its thousands grouping**, in the chosen language. It uses a
   watch-only key, `%1$@ / %2$@ ml`, with both numbers formatted for the injected locale. Today the
   watch draws `1 250 / 2 000 ml` (`Screenshots/census/AppleWatch/06-wrist-water-63pct.png`), while
   the phone draws `1300 / 2000 ml` (`Screenshots/census/iPhone-6.9/07-home-partial-65.png`). The
   phone's ungrouped figure is recorded as its own issue (§8.1), not copied to the watch.
4. **The "More" button becomes one string.** Rule `65-accessibility` says: "A control's visible text
   and its VoiceOver label are **one string**". The separate `More servings` label goes, and
   VoiceOver reads the visible `More`, then the hint.
5. **Besides ruling 4, the English text changes in exactly two places.** Both adopt a phone key
   that is already translated:
   - The VoiceOver value becomes the phone's sentence: `62 percent. 1240 of 2000 millilitres.` —
     a period where the watch had a comma.
   - The complication's description drops its trailing period, so it can reuse
     `Today's hydration`.
6. **The draft translations in §4.4 are approved as drafted**, subject to any edits the owner makes
   at this review.
7. **The rule amendments in §7 are applied as the implementation plan's last task**, once this spec
   is approved. `.claude/` is the owner's to change (rule `99-docs-cascade`). Approving this spec is
   what authorises the edit, the same way §9 and §14 of the watchOS design did.

## 4. Design

### 4.1 Where the language comes from

`WristModel` gains one computed property:

```swift
var language: AppLanguage {
    AppLanguage(code: mirror?.languageCode)
}
```

- `AppLanguage(code:)` is the phone's own resolver (`DataManager.swift:1539`). It is already
  compiled into the watch through `DataManager.swift`. An unrecognised code falls back to `.system`
  and says so under `#if DEBUG`, naming no user value (rule `70-privacy`).
- **Nothing new is stored.** `languageCode` already travels inside the mirror that `WristModel`
  saves under `Key.wristMirror`, so the choice survives a relaunch, and `apply(_:)` switches it as
  soon as a new mirror arrives. Observation tracks `language` through `mirror`, the same way
  `displayGoal` already works.
- What each value resolves to:
  - `.system` → `Bundle.main`, the watch's own system language.
  - `en`, `ru` or `uz` → that `.lproj` inside the watch app (`AppLanguage.bundle`, `:1561`). That is
    why every authored key carries an explicit `en` value. Without one no `en.lproj` is emitted, and
    choosing English on a Russian watch would draw Russian (`tasks/lessons.md`, 2026-08-29).
- `AppLanguage.locale` (`:1581`) supplies the number formatting.

**This is a read, never a write.** `WristModel.language` is not `DataManager.language`: it never
writes `Key.language`, and on the watch the process role answers `false` to every
write-on-behalf-of-the-group question (rule `25-shared-storage`). Each store still has exactly one
writer (rule `20-state`).

### 4.2 Where it is applied

A `private struct WristRoot: View` in `WaterBuddyWatchApp.swift`, and `WindowGroup { WristRoot() }`:

```swift
private struct WristRoot: View {
    @State private var model = WristModel.shared

    var body: some View {
        WristView()
            .environment(\.strings, model.language.bundle)
            .environment(\.locale, model.language.locale)
    }
}
```

- **Both values, together.** Rule `70-privacy`: "Inject `\.strings` and `\.locale` together at every
  root".
- **A view, not the `App` body.** `RootView`'s DocC in `WaterBuddyApp.swift` gives the reason:
  "Observation tracks reads made while a *view* body evaluates; an `App` body is not a reliable
  scope for it." It is a private struct in the file that uses it, as `RootView` is (rule
  `50-views`).
- `WristView` keeps its own `@State private var model = WristModel.shared`. It is the same
  instance.
- **The "More" sheet** gets the environment from the view that presents it, as the phone's
  `EditServingSheet` does with no re-injection (`HistoryView.swift:97-99`). That is confirmed on
  screen (§6.4), not assumed.
- **The complication gets no injection, and its view code does not change.** It draws a number and
  a glyph, no words. Its one piece of text, `.description`, is resolved by WidgetKit in the watch's
  system language before any entry exists. The phone widget's description and the Shortcuts strings
  already live under the same limit (`LocalizationTests.swift:310-312`).

### 4.3 How each string is drawn

| Site | After this change |
|---|---|
| vessel label (`WristView`) | `.accessibilityLabel(Text("Today's hydration", bundle: strings))` |
| vessel value | `.accessibilityValue(String(format: strings.localizedString(forKey: "%1$d percent. %2$d of %3$d millilitres.", value: nil, table: nil), percentage, total, goal))` — the exact call at `HomeView.swift:275` |
| vessel hint | `.accessibilityHint(String(format: strings.localizedString(forKey: "Logs %1$d millilitres", value: nil, table: nil), amount))` |
| "More" button | `Label { Text("More", bundle: strings) } icon: { … }`; the `.accessibilityLabel` line is deleted; `.accessibilityHint(Text("Shows the other serving sizes", bundle: strings))` |
| caption | `Text(Self.attribution(mirror: model.mirror, now: now, strings: strings))` |
| sheet name | `Text(serving.name(in: strings))` |
| sheet amount | `Text(String(format: strings.localizedString(forKey: "%1$d ml", value: nil, table: nil), serving.amount))` — the exact call at `HomeView.swift:232` |
| readout (`WristVessel`) | `Text(Self.readout(volume: volume, goal: goal, strings: strings, locale: locale))` |
| percentage (`WristVessel.swift:42`) | `Text(percentage, format: .number)` |
| complication description | `.description("Today's hydration")` — the period dropped (ruling 5) |

The percentage row uses the spelling `HomeView`'s own readout uses. It changes nothing on screen,
but the build stops extracting a `%lld` key that nobody translates, and the number is formatted for
the injected locale explicitly. A `Text` built from a `String` uses the verbatim initializer, so an
already-resolved string is never looked up a second time, as on the phone.

The pure functions are all `nonisolated static` (rule `43-concurrency`) and free of view state. Each
takes its bundle with **no default value**, because a defaulted `Bundle` would silently mean
`Bundle.main` (rule `80-notifications` holds `reconcile`'s `strings:` to the same rule):

- **`WristView.attribution(mirror:now:strings:) -> String`** and
  **`WristView.syncedCaption(composedAt:now:strings:) -> String`.** The same branches as today. Each
  returns `strings.localizedString(forKey:value:table:)`, and `Synced %1$dm ago` goes through
  `String(format:)`.
- **`WristServing.name(in:) -> String`.** The body is
  `bundle.localizedString(forKey: nameKey, value: nameKey, table: nil)`, exactly as in
  `HomeView.Serving.name(in:)` (`HomeView.swift:41`).
- **`WristVessel.readout(volume:goal:strings:locale:) -> String`.** The body is
  `String(format: strings.localizedString(forKey: "%1$@ / %2$@ ml", value: nil, table: nil),
  volume.formatted(.number.locale(locale)), goal.formatted(.number.locale(locale)))`.

`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is set only on the phone app target
(`project.pbxproj:938`, `:976`; known issue #30). So on the watch, `AppLanguage.bundle` and `.locale`
are not inferred `@MainActor`, and the deliberately non-`@MainActor` `WristViewLogicTests` can
resolve the bundles it passes in.

### 4.4 The two catalogues

**`WaterBuddyWatch/Localizable.xcstrings`.** `sourceLanguage` is `en`, and every authored key has
explicit `en`, `ru` and `uz` values.

Six keys are copied exactly from `WaterBuddy/Localizable.xcstrings`, in all three languages, and are
never retranslated: `Today's hydration`, `%1$d percent. %2$d of %3$d millilitres.`, `%1$d ml`,
`Cup`, `Glass`, `Bottle`.

Nine keys are new and watch-only:

| Key (= `en`) | `ru` | `uz` |
|---|---|---|
| `%1$@ / %2$@ ml` | `%1$@ / %2$@ мл` | `%1$@ / %2$@ ml` |
| `Logs %1$d millilitres` | `Записывает %1$d миллилитров` | `%1$d millilitr qayd etadi` |
| `More` | `Ещё` | `Yana` |
| `Shows the other serving sizes` | `Показывает другие порции` | `Boshqa porsiyalarni ko‘rsatadi` |
| `Not yet synced · default goal` | `Нет синхронизации · цель по умолчанию` | `Hali sinxronlanmagan · standart maqsad` |
| `Set your goal in WaterBuddy on iPhone` | `Задайте цель в WaterBuddy на iPhone` | `Maqsadni iPhone’dagi WaterBuddy’da belgilang` |
| `Not yet synced` | `Нет синхронизации` | `Hali sinxronlanmagan` |
| `Synced just now` | `Синхронизировано только что` | `Hozirgina sinxronlandi` |
| `Synced %1$dm ago` | `Синхронизировано %1$d мин назад` | `%1$d daqiqa oldin sinxronlandi` |

- **`Not yet synced` can't be reached by production code today.** `WristMirror.composedAt` is
  non-optional, so `attribution` always passes `syncedCaption` a date. The function still accepts
  `Date?`, though, so the branch is translated rather than left in English. §8.3 records the dead
  branch.
- **Plural forms.** Russian minutes are written `мин`, which needs no plural form, and Uzbek nouns
  take none after a numeral. `Logs %1$d millilitres` uses a single Russian plural form, as the
  phone's `Add %1$d millilitres` already does. That is correct for 150, 250 or 500, and wrong for
  amounts ending in 1–4 (§8.2).
- **Uzbek apostrophes** are `’` and `‘`, the ones the phone's catalogue already uses
  (`WaterBuddy’dagi`, `qo‘shish`).
- **Every key uses positional specifiers** (rule `70-privacy`).
- **Deliberately English-only: `%`.** It carries an explicit `en` value like every key (rule
  `70-privacy`) and is on the coverage allowlist, as on the phone.
- **Preview-only keys.** The build also extracts the `#Preview` strings the shared files carry
  (`1,450 ml`, `+%lld`, `Today`, per the phone widget's allowlist at `LocalizationTests.swift:278`).
  They carry no `en` value and reach no table.

**`WaterBuddyWatchWidget/Localizable.xcstrings`.** One authored key, `Today's hydration`, copied
exactly from the phone. `WaterBuddy`, the display name, carries an `en` value only and is never
translated.

**Membership.** Each file joins its target through that target's synced root group, so **no
`project.pbxproj` edit is needed**. A catalogue can't be shared through a membership exception: the
build compiles it into one target and then deletes the entry (`tasks/lessons.md`, 2026-08-29). That
is why there are two. `knownRegions` already lists `en`, `ru` and `uz`. The plan diffs
`project.pbxproj` **after** the build, because the toolchain edits that file too.

### 4.5 What does not change

- Nothing on the phone.
- Nothing sent between the devices: `languageCode` is already sent, and `schemaVersion` stays 1.
- The key roster, the three exception sets, the entitlements and the four `PrivacyInfo.xcprivacy`
  files.
- The complication's view and timeline.
- `WristModel`'s writes.
- `.claude/commands/`: their "all three languages" stays true.

## 5. Sequence

1. Write the failing tests (§6.1–§6.3), run them, and confirm RED. Pass
   `-collect-test-diagnostics never` to runs that are meant to fail, so the run doesn't hang
   collecting diagnostics (`tasks/lessons.md`, 2026-10-05).
2. Add the two catalogues.
3. Add `WristModel.language` and `WristRoot`.
4. Change `WristView`, `WristVessel` and the complication's description.
5. Run GREEN, then the full gate, the warning comparison and the `project.pbxproj` diff.
6. Check on screen (§6.4).
7. Apply the rule amendments (§7).
8. Add a `HISTORY.md` checkpoint and any `tasks/lessons.md` entry, then run `/doc_sync`. Stage, and
   do not commit (rule `90-git`).

## 6. Testing

### 6.1 `WristModelTests` (watch, `@MainActor`)

- `theWatchFollowsTheLanguageChosenOnThePhone` — a mirror carrying `ru` gives `.russian`.
- `withNoMirrorTheWatchFollowsItsOwnLanguage` — gives `.system`.
- `aPhoneFollowingItsDeviceLeavesTheWatchOnItsOwn` — `languageCode: nil` gives `.system`.
- `anUnrecognisedLanguageCodeFallsBackToTheWatchsOwn` — `xx` gives `.system`.
- `aNewMirrorSwitchesTheLanguageForObservers` — `ru`, then `uz`. `withObservationTracking`'s
  `onChange` fires, counted through a `final class … : @unchecked Sendable` box (rule `85-testing`).
- `theChosenLanguageSurvivesARelaunch` — a second `WristModel` on the same throwaway suite reads
  `.russian`.

Every fixture builds its own UUID-named suite and tears it down (rule `85-testing`).

### 6.2 `WristViewLogicTests` (watch, deliberately not `@MainActor`)

The watch test bundle runs inside the watch app (`TEST_HOST`, `project.pbxproj:1088`), so
`Bundle.main` is the watch app and its `.lproj` folders are reachable.

- `theWatchShipsAStringsBundleForEveryLanguage` — the guard test, first. `en`, `ru` and `uz` all
  resolve. Rule `85-testing`: prove the bundle loaded before asserting against it.
- **The six existing caption tests** gain `strings:` set to the `en` bundle and **keep their exact
  English expectations**, so nothing is narrowed (rule `85-testing`). They are
  `syncedJustNowReadsAsNow`, `syncedMinutesAgoReadsInWholeMinutes`, `noMirrorYetReadsAsNeverSynced`,
  `beforeTheFirstSyncTheAttributionNamesTheDefaultGoal`,
  `aMirrorWithNoGoalSetAsksForSetupOnTheePhone` and `aFullySyncedMirrorFallsBackToTheSyncedCaption`.
- `everyCaptionReadsInRussian` and `everyCaptionReadsInUzbek` — every branch, word for word from
  §4.4.
- `theServingNamesAreTranslated` — `Glass` reads `Стакан` and `Stakan`.
- `theVesselReadoutGroupsThousandsInTheChosenLanguage`:
  - In `en`, exactly `1,250 / 2,000 ml`.
  - In `ru` and `uz`, the digits are split by a non-digit (never `1250`), and the text ends in `мл`
    or `ml`. The separator character itself is not named, because it differs between OS releases.

### 6.3 `LocalizationTests` (phone)

The built phone app embeds the watch app at `Watch/WaterBuddyWatch.app`, and the watch app embeds
its widget at `PlugIns/WaterBuddyWatchWidget.appex`. Both were observed in DerivedData on
2026-10-06. So the phone's suite can read all four bundles, and it is the only place the watch can
be compared against the phone.

- `theWatchBundlesAreWhereWeThinkTheyAre` — the guard test, first.
- `theWatchShipsEveryLanguage(language:)` — `en`, `ru` and `uz`, in both watch bundles. This is the
  regression test for a catalogue that ends up in the wrong target.
- `theWatchAgreesWithThePhoneOnEverySharedString(language:)` — the six copied keys, plus the
  widget's `Today's hydration`, are identical to the phone app's values in all three languages.
- `everyWatchStringIsTranslatedUnlessDeliberatelyNot` — in both watch bundles, the `en` table is a
  subset of `ru` and of `uz`, with the allowlist argued in place.
- `theWatchsOwnKeysResolveInEveryLanguage(language:)` — the nine new keys by name, through the
  `missingMarker` sentinel. This is needed because the build does not extract keys looked up with
  `localizedString(forKey:)`, so the coverage check above can't see a missing one. It closes the
  same gap `theShortcutsVocabularyIsTranslated` exists for.
- `noWatchTranslationLosesAFormatArgument(language:)`.
- `theProductNameIsNeverTranslatedOnTheWatch(language:)`.

### 6.4 On screen

No test sees a rendered screen (rule `85-testing`).

- **The device-language path can be automated.** Launch the watch app with
  `-AppleLanguages "(ru)"`, then `"(uz)"`. That is an argument-domain override: it persists nothing
  and writes no suite (`CLAUDE.md`'s hard limits). Screenshot it on the Series 11 (46mm) and the
  SE 3 (40mm).
  - Pass if nothing is truncated or clipped, and the readout shows grouping (`0 / 2 000 мл` in the
    empty state).
  - The caption may wrap; the 40mm already scrolls (`WristView.vesselHeightFraction`'s DocC).
- **The live switch and the "More" sheet need a tap.** `simctl` has no tap command on either
  platform, Xcode 27 ships no `Simulator.app` to drive (`tasks/lessons.md`, 2026-10-05), and the
  DeviceHub route hasn't been explored. On the paired simulators (phone app installed first), the
  owner sets the phone app to Русский and opens the sheet. Or the owner explicitly skips both, and
  the checkpoint records that.
- **The complication's description in the face editor** is the owner's call, as the complication
  check was for spec §17.

### 6.5 The gate

- The five invocations from rule `85-testing`, in the foreground, on one simulator, with
  `-parallel-testing-enabled NO`.
- A clean build into an empty DerivedData folder, compared per file and message against the Xcode 27
  baseline: 31 unique warning lines on `-scheme WaterBuddy`, plus the two `actool` lines on
  `WaterBuddyWatchWidget` (known issue #36).
- `git diff project.pbxproj`, empty after the build.

## 7. Rule amendments — exact text

### `70-privacy.md` — *Localization*

- **Delete lines 87–91**, the "Known gap, tracked, not fixed here" paragraph.
- **Add after lines 99–100** ("The widget takes its language from `entry.snapshot.language`, never
  `Bundle.main` or the device locale"):
  > - The watch takes its language from `WristMirror.languageCode`, through `WristModel.language`,
  >   injected at `WristRoot`. `nil` — the phone set to *Follow device* — and the time before the
  >   first mirror both resolve the watch's own `Bundle.main`. The complication's `.description` is
  >   resolved by WidgetKit and follows the watch's system language
- **Lines 101–103.** "shipping the matching translations in **both** `Localizable.xcstrings` files"
  becomes "shipping the matching translations in **all four** `Localizable.xcstrings` files".
- **Lines 104–105.** "Keep the two catalogues separate — one in `WaterBuddy/`, one in
  `WaterBuddyWidget/`." becomes "Keep the four catalogues separate — `WaterBuddy/`,
  `WaterBuddyWidget/`, `WaterBuddyWatch/` and `WaterBuddyWatchWidget/`."
- **Lines 106–107.** Append: "The watch's copies of phone strings are held to the same standard:
  `LocalizationTests` compares them against the app bundle in every language".
- **Lines 117–118.** "via `Bundle.main` and `PlugIns/WaterBuddyWidgetExtension.appex`" becomes "via
  `Bundle.main`, `PlugIns/WaterBuddyWidgetExtension.appex`, `Watch/WaterBuddyWatch.app` and its
  `PlugIns/WaterBuddyWatchWidget.appex`".

### `15-project.md` — *Localization*, lines 169–170

"Adding a language means the catalogue in **both** `WaterBuddy/` and `WaterBuddyWidget/`" becomes
"Adding a language means the catalogue in **all four** of `WaterBuddy/`, `WaterBuddyWidget/`,
`WaterBuddyWatch/` and `WaterBuddyWatchWidget/`".

### `50-views.md` — *Text and strings*, lines 102–104

"injected once at the root from `manager.language` together with `\.locale`" becomes "injected once
at the root from `manager.language` — on the watch, `WristModel.language` — together with
`\.locale`".

### `65-accessibility.md` — *Proving it*, lines 117–118

"the shared ones go into `sharedKeys` so both bundles are checked" becomes "the shared ones are
listed in `LocalizationTests` so every bundle that draws them is checked".

### Deliberately unchanged

`80-notifications.md:77` and `:85-86` say reminder copy belongs in "both string catalogues". That
stays true: the watch never files a reminder (`role.mayFileReminders`) and does not compile
`NotificationManager.swift`, so reminder copy still belongs in exactly the two phone catalogues.

## 8. Known issues this records (not fixed here)

1. **The phone's `String(format:)` figures never show a thousands separator.** `HomeView.swift:332`
   draws `1300 / 2000 ml`, and `HistoryView`'s week card draws `Best 8050 ml`, in every language,
   because `%1$d` does no grouping. Yet `AppLanguage.locale`'s DocC (`DataManager.swift:1578`),
   `WaterBuddyApp.swift:97-100` and `docs/STATE.md:432` all say `\.locale` groups numbers
   ("4 500"). Only the `Text(_:format:)` sites actually do.
2. **The shared Russian keys use a single plural form.** `%1$d percent. …` reads `62 процентов`
   (the correct form is `процента`), and `Add %1$d millilitres` reads `Добавить 222 миллилитров`.
   Both are wrong for counts ending in 1–4, except 11–14. The watch now inherits both, plus
   `Logs %1$d millilitres`. A fix means plural variations in every catalogue that holds these keys,
   all at once.
3. **`WristView.syncedCaption`'s `nil` branch can't be reached by production code.**
   `WristMirror.composedAt` is non-optional, and `attribution` handles a missing mirror before it
   gets there. Only `noMirrorYetReadsAsNeverSynced` exercises the branch.
4. **Out-of-date docs found while orienting**, for `/doc_sync` to fix:
   - Known issue #1 is fixed on disk. All five Shortcuts strings carry `ru` and `uz`, and
     `everyWidgetStringIsTranslatedUnlessDeliberatelyNot` and `theShortcutsVocabularyIsTranslated`
     guard them.
   - Known issue #12 is fixed on disk: `GoalSetupUITests.swift:31` locks the simulator to portrait.
   - Known issue #25 claims the phone widget never shows more than 100%. That's false:
     `WaterBuddyWidget.swift:350` draws `snapshot.percentage` uncapped.
   - Known issue #18 undercounted its own sites (§2).
   - `docs/AI_CONTEXT.md` still gives the latest commit as `55c73b2`.

## 9. Out of scope

- The complication's view, timeline and VoiceOver. Its VoiceOver is generated by the system from the
  `Gauge`, not hard-coded English.
- `import Combine` in `WristView.swift` (#29). It's in the same file, but an unrelated change (rule
  `90-git`).
- #20 (four copies of the percentage formula), #35 (the watch's scrim) and #38 (`isMirrorStale`).
- Phone-side fixes for §8.1 and §8.2.
- The watch app's home-screen name, `Water Buddy`. It's a product name.

## 10. What stays unproven

- VoiceOver *speech*. The tests prove each string resolves, not how VoiceOver speaks it.
- The live switch on real hardware, and on simulators too if the owner skips the tap (§6.4).
- The complication's description in the face editor, unless the owner checks it.
- A watch whose system language differs from the phone's, while the phone follows its device. By
  ruling 1 the watch draws its own language. That is the intended behaviour, but nobody has
  observed it.
