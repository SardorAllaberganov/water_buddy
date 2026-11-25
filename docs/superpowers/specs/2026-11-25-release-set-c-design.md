# Set C's release — the walk it owes, its page in four languages, one new shot — design

Taken on the owner's "Go next" (2026-11-25, 21:00), after set C came into `main` and was pushed (`eca5615`). The message
before it named what stands between set C and the store: #236, #237, the privacy policy on the owner's site, and the
Spanish (Mexico) page's four steps. This is that release, written whole for one approval: five rulings asked up front
(§2), the rest recommended (§12). Set C's spec says it "ships in the version after 1.4.1" (D22), and leaves "whether a
later store page shows a theme" to this design (§5 there).

## 1. Why, and what done looks like

Read on 2026-11-25:
- **The store.** Apple's Lookup API: 1.4.1 live since 2026-11-22, 01:21 UTC, in the us, gb, ru, mx and uz stores, with
  **0 ratings** in each.
- **The code.** `main` = `origin/main` = `eca5615`. Set C is on sale in code (`PremiumSet.personal.isOnSale`), so the
  next archive from `main` sells it. `MARKETING_VERSION` 1.4.1 and `CURRENT_PROJECT_VERSION` 7 on all fourteen sites.
- **What the records say is owed before an upload:**
  - **#236:** the widgets, the control, a reminder's button and the watch walked in each theme. Also the widget and watch
    tables `docs/DESIGN.md` owes (*Themes, measured*, *Not measured*). Rule `60-design-system` says a theme ships only
    with its table.
  - **#237:** each alternate icon's dark and tinted forms, from a TestFlight install.
  - **The privacy policy.** The live page reads *Last updated 20 November 2026*. `PRIVACY.md` and
    `Tools/PrivacyPolicy.html` read 25 November: the theme, the vessels and the Watch's copy of them.
  - **es-MX's four steps** (`AppStore/README.md` §6).
- **Found while reading for this design:**
  - **The description is now wrong in one claim.** en-US says the quick-add vessels are "each editable from 50 to
    1,000 ml"; es-MX says the same in Spanish. Since set C (D12) the sliders run **50 to 2,000 ml for everyone**
    (`VesselSliders.range`, drawn by Settings' card and the welcome).
  - The description and the App Review notes name no part of set C.
  - **Set C's report and ledger are gone from where the records point.** The records name the build session's report
    for set C's 78 rulings and nine deferred minors, at
    `~/Library/Application Support/Claude/side-session-notes/local_061126c5-…/2026-11-25-set-c-step-5-report.md`.
    That folder went with the session's archive at 19:17. The executing-plans ledger that held the rulings was inside
    the worktree, and went with `git worktree remove`. Both survive in the build session's transcript,
    `~/.claude/projects/-Users-sardorallaberganov-Desktop-Projects-MobileApps-Games-WaterBuddy--claude-worktrees-hopeful-edison-f6b307/e4c6004a-ee11-4e63-bcb9-111a9509c5e4.jsonl`.
    This design read the nine minors from it (§10).

**Done** is:
- #236 walked on simulators, every surface in each of the five themes, and the widget and watch tables in
  `docs/DESIGN.md`, every pair at its floor or ruled by the owner;
- four listings in files — en-US, en-GB, Russian and Spanish (Mexico) — each with set C, the 2,000 ml fix and a What's
  New, every field counted by `Tools/VerifyListing.sh`, with es-MX added to it;
- the screenshots of R2;
- the build numbered as R1 says, gated, archived in Release from a clean export, uploaded on the owner's word, and seen
  from TestFlight on the owner's iPhone (#237);
- the policy published (R3) before the submission;
- the version page filled and the version submitted, each on the owner's word.

## 2. Rulings asked — the owner's

- **R1 — the version.** Recommended: **1.4.2 (8)**. Set C is the last Premium set of release 1.4 (roadmap §5). "1.5"
  is the roadmap's name for other drinks, the Live Activity and new languages. The alternative is **1.5 (8)**, and the
  roadmap's 1.5 becomes 1.6.
- **R2 — the screenshots.** Recommended: **a themes shot takes slot 9, and *Learn when you drink* (9-patterns) leaves
  the set**. App Store Connect holds ten iPhone shots, and the set has ten. Themes are the most visual thing Premium
  now sells, and the page shows none. Patterns is the least visual of the five Premium shots, and Month and Insights
  already show how deep History goes. The new shot: Settings' Appearance card in **Lagoon**, its five themes and the
  icons, with the headline *Make it / **yours*** and the *Premium* tag (§6). The alternative is to keep the ten.
- **R3 — who publishes the policy.** Recommended: **me, on your word**. That is a clone of `SardorAllaberganov.github.io`
  over HTTPS, `Tools/PrivacyPolicy.html` copied to `waterbuddy/privacy/index.html`, one commit, the push, and the live
  page read back for *25 November 2026*. The alternative: you publish it as you did on 2026-11-20.
- **R4 — the policy's "Home screen"** (set C's deferred minor 10). *"the three vessels on your Home screen"*
  (`PRIVACY.md:71` and `:107`, and the page) can read as iOS's Home Screen. The policy writes the app's tab as *the
  Home screen* elsewhere. Recommended: **"the three vessels on WaterBuddy's Home screen"**, in both places, before it
  is published. The alternative is to keep it.
- **R5 — set C's Russian and Uzbek strings (#239).** Recommended: **I make a table of the 37 keys, English, Russian and
  Uzbek side by side, for you to read before the archive.** What you change goes into the catalogue. What you leave
  ships as drafted. The alternative is to ship the drafts unread.

## 3. The order of the work

1. **The branch:** `release/1.4.2` from `main` at `eca5615` (R1 names it).
2. **The walk and the tables** (§4), first, because a pair under its floor changes code before anything else is
   built on it.
3. **The code:** the version (§8), and the harness's new capture for R2 (§6). The gate (§11).
4. **The words** (§5) and **the shot** (§6). The store capture runs only from 1:45 to 11:45 PM.
5. **The archive and TestFlight** (§7): the upload on your word, then #237 and the device checks on your iPhone.
6. **The policy** (R3), **the version page** and **Submit for Review**, each on your word.
7. **The records** through `/doc_sync`, and the Growth Journal before each push.

## 4. The walk (#236) and the tables

### 4.1 Where, and how Premium is held

- **A new simulator pair**, *WaterBuddy Walk iPhone* (iPhone 17, iOS 27.0) and *WaterBuddy Walk Watch* (Series 12,
  46 mm, watchOS 27.0), paired.
  - Not the store pair: the shots need its lived-in week as it is.
  - Never another project's simulator, and no `simctl shutdown all`.
- **Premium on the phone's own stores comes only from Xcode's Run with the scheme's local StoreKit file** (#236). A
  test run cannot buy, and rule `85-testing` keeps the sandbox out of tests.
  - Xcode is opened on the project, the walk phone chosen as the destination, and ▶ pressed. I do it with computer
    use on Xcode, clicks only, which is Xcode's tier, once you approve its access. Or you press ▶ once.
  - From then on the simulator tool does every tap. The purchase is the local file's: free, and it never leaves the
    Mac.
- **The watch app** goes onto the walk watch with `simctl install`, from the same build's products. The theme and
  Home's vessels reach it through the mirror, as they reach a real watch.
- **Before the purchase:** a free user's Appearance card, each locked icon with its lock at the corner (the final
  review's Important 1).

### 4.2 What is walked, in each of the five themes

- **The Home Screen:** the small and medium Hydration widgets and the week widget, placed by the simulator tool. Each
  sky takes the theme (Important 3). A tap on the week widget opens History.
- **A vessel of the user's own in Home's middle slot**, named and with its own icon:
  - Home's middle button wears it;
  - Control Center's *Log Water* control wears its glyph;
  - a reminder's *Log a Glass* wears its glyph. The reminder is delivered by `xcrun simctl push` with the reminder's
    category, which the app registers with Home's middle glyph;
  - the watch's row wears the names, and its Glass logs the vessel.
- **The watch app** in each theme.
- **Once, not per theme,** the surfaces rule `60-design-system` keeps free of any theme: the Lock Screen widget, and
  one watch face.

### 4.3 The tables

- The pairs are the ones `docs/DESIGN.md` records for Aurora's widgets (*The week widget, measured* and the Hydration
  widget's) and for the watch's screen (*The watch's screen, measured*). They are read on each theme's renders with
  `Tools/MeasureContrast.swift`, and `Tools/theme-pairs.json` is extended to these surfaces.
- **Runtimes:** iOS 27.0 for the widgets and watchOS 27.0 for the watch, as Aurora's were taken. A widget does not
  move, so one frame per surface is the whole of it.
- **The floor is rule `60-design-system`'s:** every pair at its floor, and none lower than Aurora's where Aurora is
  under on clean ground. **A pair that fails stops the release for your ruling**, as the palettes' first tables did.
- The figures go into *Themes, measured*, and its *Not measured* loses the widgets and the watch.

## 5. The words

### 5.1 en-US — `AppStore/`, with `README.md` the master copy

- **Name, subtitle, keywords and promotional text: unchanged.** 1.4.1 has been live three days, too soon to read a
  rank. The monthly `rank.py` run decides the next change.
- **What's New**, a draft, put through `humanize` before it is final:

  > New in Premium:
  > - Four more themes beside Aurora: Lagoon, Dusk, Midnight and Bloom, with an app icon to match each.
  > - Your own vessels: add up to nine, each with a name and an icon, and put any vessel on Home. The one in the
  >   middle is what your widget, Siri, Control Center, reminders and Apple Watch log.
  >
  > For everyone: the quick-add vessels now go up to 2,000 ml.

- **The description:**
  - *"each editable from 50 to 1,000 ml"* becomes *"from 50 to 2,000 ml"*;
  - the Premium list gains two lines after *Export every serving as a CSV file*: *"Four more themes beside Aurora, with
    an app icon to match each."* and *"Your own vessels, up to nine, each with a name and an icon. Put any of them on
    Home."*
  - It stands at 3,987 of 4,000 characters, so room is made, in three cuts:
    - *PRIVATE BY CONSTRUCTION*'s list becomes *"No analytics, no tracking, no ads, no third-party code and no
      networking code."*
    - The insights line drops its second sentence and keeps *"Not medical advice."* The model's part stays in the App
      Review notes.
    - The Premium section drops its *"Optional extras:"* line, which its closing sentence already says.
  - With the first two cuts, a script counted 4,001 characters on 2026-11-25. The third takes 17 more, to **3,984**.
    `VerifyListing.sh` prints the final count.
- **App Review notes** gain one paragraph, about 300 of the 1,554 bytes left. Premium also unlocks four more themes and
  their app icons in Settings › Appearance, and the vessel library in Settings › Your vessels. Aurora, the standard
  icon and the standard vessels stay free. Changing the icon shows iOS's own alert.

### 5.2 en-GB — `AppStore/en-GB/`

en-US's What's New and description word for word, as for 1.4.1. Its own keywords and its fallback name are unchanged.

### 5.3 Russian — `AppStore/ru/`

The same changes, written in the app's own Russian words: *Пункт управления*, *Записать стакан*, the themes' names as
the catalogue has them after R5. Through `humanize`, and every claim read against the build.

### 5.4 Spanish (Mexico) — `AppStore/es-MX/`, the four steps

1. Set C's changes and the 2,000 ml fix in the description, cut to stay within 4,000 characters (it is at 3,980).
2. A Spanish What's New, from en-US's.
3. The Support and Privacy Policy URLs. Connect leaves a new language's empty, so they are filled with en-US's
   addresses when the page is filled.
4. `es-MX` added to `Tools/VerifyListing.sh`'s `LISTINGS`, and the script passes it.

The name, subtitle, keywords and promotional text are as staged on 2026-11-23.

## 6. The screenshot (R2)

- **Captured by the store harness.** `AppStoreScreenshotUITests.testCaptureAppStoreScreenshots` gains one launch, beside
  its others, with `-WaterBuddyTheme lagoon`. That is the fresh start, the store's sample and Premium held, as now.
  Settings is scrolled to the Appearance card, and `11-themes` is saved into `captures/iPhone-6.9/`. Run by
  `bash Tools/CaptureScreenshots.sh` between 1:45 and 11:45 PM.
- **Framed as the others** (`Tools/StoreScreenshots.html`, `Tools/FrameScreenshots.sh`): the headline *Make it /
  **yours***, the phone, and the swatches lifted out of the same capture (F4). The backdrop's aurora runs on from panel
  to panel in Aurora's colours as now: the theme shows on the phone.
- **Upload order:** `9-themes` replaces `9-patterns`. `07-patterns`' capture stays in `captures/`. The 6.3″ set is
  made again from the 6.9″ with `sips`, and `bash Tools/VerifyScreenshots.sh` passes both.
- The watch's shot and the product page's header video are unchanged.

## 7. TestFlight before review, and #237

- The Release archive (§11) is uploaded **on your word**, as 1.4.1 (7) was. Connect then offers the build in
  TestFlight's internal testing.
- **On your iPhone, from TestFlight:**
  - **#237:** each alternate icon, set from Settings, in light, dark and tinted on the Home Screen.
  - **StandBy:** the small widget in a theme, by day and at night. The simulator has no StandBy.
  - **Premium** bought in TestFlight's sandbox, which charges nothing. This is the closest thing to #156's purchase on
    a device that this release can give.
- **If an icon's dark or tinted form does not survive distribution**, the release stops there for a fix. The
  likeliest fix is the icons moved to Icon Composer (set C's D21 left that open).

## 8. The version

`MARKETING_VERSION` 1.4.1 → **1.4.2** (R1) and `CURRENT_PROJECT_VERSION` 7 → **8**, on all fourteen sites each. Read
back as `1.4.2 (8)` from the four built products: the watch app and both extensions carry the iPhone app's own.

## 9. Branch and `main`

The work goes on `release/1.4.2`, from `main` at `eca5615`. `main` fast-forwards to it only after the Release archive
of the final tree has passed (lesson 2026-11-07), and only on your word, as every push is.

## 10. Set C's deferred minors

Read from the build session's transcript (§1), by the ledger's own numbers. The final review found ten minors. One of
them, the library's names breaking at the largest text sizes, was re-graded by its effect and fixed. The ledger numbers
the other nine 1–4 and 6–10. Only minor 10 is taken here, by R4; the other eight stay deferred:
- **1:** the launch's heal of `Key.servings` rings no widget doorbell, which only a crash between two adjacent writes
  reaches.
- **2, narrower than its line said:** the vessel editor saves its name, icon and amount when it closes
  (`.onDisappear(perform: commitName)`). An icon or amount change is lost only if the sheet closes with the name field
  empty, and the vessel then keeps its old name, icon and amount.
- **3:** `RecapCard.swift:257–258`'s DocC still says other themes wear Aurora's tile.
- **4:** no lapsed-holder UI test.
- **6:** the editor's sibling panes take no `.glassGroup()` and mix densities without a stated reason.
- **7:** `AppIconSwitcher` has no "can icons change" closure.
- **8:** rule 75's print census (#241, the owner's wording).
- **9:** the harness's self-test lived in a scratchpad, now gone.
- **10:** the policy's "Home screen" — R4.

## 11. How it is proved

- **The walk:** each surface read on a scratch picture before its frame is kept. The tables' figures are printed by
  `MeasureContrast.swift` and checked against `docs/DESIGN.md` when written.
- **The words:** `bash Tools/VerifyListing.sh` passes all four listings. en-US is diffed against its block in
  `README.md`, and en-GB against en-US. Every claim in the four descriptions is read against what the build does.
- **The shot:** the scratch picture read before framing, the framed shot read by eye, and `VerifyScreenshots.sh` passes
  the 6.9″ and 6.3″ sets.
- **The gate:** the five invocations on iOS 27.0, and the UI suite on iOS 18.6, where set C ran it, since 26.5's runtime
  is missing (#230). Warnings are compared by file and message against a clean build of an `eca5615` export. Only named
  WaterBuddy simulators are shut down.
- **The archive:** Release, `generic/platform=iOS`, from a clean export of the final commit, before `main` moves and
  before any upload. It checks:
  - the four bundles read `1.4.2 (8)`;
  - both Health keys are there;
  - the App Group is on all four, and HealthKit on the app alone;
  - one privacy-manifest hash across the four;
  - the four alternate icons are named in the built Info.plist;
  - there is no `held` or `StoreSample` symbol.
- **The policy:** the live page read back for *25 November 2026* and R4's sentence.

## 12. Decisions

The owner's: R1–R5 (§2).

Mine, recommended, for the owner to change at review:
- **D1.** The walk on a new simulator pair. Premium through Xcode's Run with the local StoreKit file: me on Xcode by
  clicks, or you press ▶ once (§4.1).
- **D2.** The widget and watch tables on iOS 27.0 and watchOS 27.0. A failing pair stops the release (§4.3).
- **D3.** Name, subtitle, keywords and promotional text unchanged in en-US, en-GB and Russian. es-MX's go up as staged.
- **D4.** What's New and the description as §5.1. en-GB is en-US's. Russian and Spanish are written from it and passed
  through `humanize`.
- **D5.** The App Review notes gain one paragraph on set C.
- **D6.** TestFlight before review, so #237 and StandBy are seen on the build that ships (§7).
- **D7.** Set C's deferred minors stay deferred, but for minor 10, which R4 takes (§10).
- **D8.** `release/1.4.2` from `eca5615`. `main` moves after the archive, on your word.
- **D9.** The records: the dead report path corrected to the transcript's, and a lesson that archiving a session
  deletes its side-session notes, through `/doc_sync`.

## 13. Yours, or mine on your word

- Approve this design, and rule R1–R5.
- Approve computer use on Xcode for the walk, or press ▶ once (D1).
- Read R5's table.
- **On your word, each time:** the TestFlight upload; the policy's push (R3); `main`'s fast-forward and each push; the
  version page in App Store Connect, done in your Chrome as for 1.4.1; *Submit for Review*.
- **On your iPhone:** §7's checks.

## 14. Not in this work

- 1.4.11 and every item of release 1.5. A Russian or Spanish screenshot set, and the watch-face shots.
- The prices: set on 2026-11-24, and set C adds no product.
- #238 (VoiceOver on the wrist), #240–#242 and #136: the owner's rulings or a device's.
- Any upload, push, App Store Connect change or published page without the owner's word.
