# The rating prompt — design

**Status:** the outline was approved by the owner in conversation on 2026-10-15, section by section
("ok" to each of three), with four decisions taken as recommended: **D1**, the moment is a pour that
reaches the goal on the third day in a row; **D2**, at most once per app version; **D3**, the
`StoreKit` amendment covers the review request only; **D4**, a DEBUG build never asks unless launched
with `-WaterBuddyReviewPrompt`. **D5** narrows §3.3 after that approval, and is the owner's to confirm
in reviewing this document: only a pour made **on Home** asks, because a crossing picked up when the
app comes forward would ask straight after launch, which Apple's guidance says to avoid (§3.3). This
document writes the outline out, with §5's rule wording, for the owner's review **before** the plan
and before any code (`docs/ROADMAP.md` §8). Roadmap item **1.2.5**.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `450d76f` on 2026-10-15. **SDK** is
`iPhoneSimulator27.0.sdk` in Xcode 27.0 (27A266a) on this machine. Two Apple pages were read on
2026-10-15 through their documentation JSON:
`developer.apple.com/documentation/storekit/requestreviewaction` (**[RRA]**) and
`developer.apple.com/documentation/storekit/requesting-app-store-reviews` (**[RAR]**), the article that
carries Apple's sample code. Each claim below is marked **stated** (an Apple source says it),
**measured** (read or run on this toolchain), **inferred**, or **unconfirmed**. Amended on
2026-10-15 by the plan's decisions (`docs/superpowers/plans/2026-10-15-rating-prompt.md`, P1–P3);
each amendment says so.

## 1. What is being built

Apple's own request for a rating, asked at a moment of success: a few seconds after the user's own
pour on Home reaches the goal on the third day in a row, at most once in each version of the app. iOS
draws the request and decides whether to show it at all; WaterBuddy only asks.

It is done when:
- a DEBUG build launched with `-WaterBuddyReviewPrompt YES` shows the request about 2.2 seconds after
  such a pour, and never a second time in the same version;
- a DEBUG build launched without it never asks and writes nothing new to the suite;
- no other surface (the widget, Siri, the control, a reminder's button, the watch, History) ever asks;
- the widget and both watch targets still build without linking `StoreKit`.

## 2. What happens today

- No file in any target imports `StoreKit` (grep over `WaterBuddy/`, `WaterBuddyWidget/`,
  `WaterBuddyWatch/`, `WaterBuddyTests/`, `WaterBuddyUITests/`: zero hits, **measured**). Rule
  `70-privacy` bans it by name.
- Home marks the goal with a haptic and confetti on the upward edge of `manager.hasReachedGoal`
  (`HomeView.swift:267–275`). That edge fires for any crossing Home observes — its own pour, or a
  total picked up by `refresh()` when the app comes forward after a widget tap.
- `pour(_:)` (`HomeView.swift:819–835`) makes one synchronous call, `manager.addLog(amount:)`.
- `manager.streak` counts the days in a row the goal was reached, **today included once today reaches
  it** (`DaySummary.streak(of:goal:)`, `DataManager.swift:2164–2174`). It is republished after every
  pour: `saveAndRecompute()` → `republishHistory()` → `republishStreak()` (`:1056`, `:981`). It is zero
  wherever `role.drawsHistory` is `false` — every process but the phone app.
- The phone's suite holds nine keys; `Key.all` lists eleven, the watch's two included
  (`DataManager.swift:159–163`). `migrateIfNeeded(from:into:)` copies a fixed list of four
  (`:1735`).
- `MARKETING_VERSION` is `1.1` at all five sites in `project.pbxproj` that set it.

## 3. The design

### 3.1 The moment (D1)

The goal reached on the **third day in a row**: `hasReachedGoal` true and `streak >= 3`. Both are
needed — a streak of 3 can be three days ending yesterday while today is still short, and today must
be the day that completed it.

It can never fall in the first session or on the first day, which the roadmap requires, and it picks a
user the app is plainly working for. It costs no new count: the streak is already published.

### 3.2 How often (D2)

At most once per app version, recorded by `CFBundleShortVersionString` (e.g. `"1.2"`). This is
Apple's sample's own rule: *"The app hasn't shown a review prompt for a version of the app bundle that
matches the current bundle version"* (**stated**, [RAR]). Apple's own limit applies on top: *"StoreKit
displays the ratings and review request a maximum of three times within a 365-day period"*, and to a
user who has already rated, only for a new version after more than 365 days (**stated**, [RRA]).

### 3.3 Where and when it fires (D5)

Only **Home's own pour** can lead to a request.

1. `pour(_:)` reads `manager.hasReachedGoal` before its `addLog` call and again after it. When the
   pour took it from `false` to `true`, Home bumps a new presentation counter, `goalPours`. Both are
   reads: the button still makes exactly one call into the model (rule `50-views`).
2. A `.task(id: goalPours)` waits `ReviewPrompt.pause` — `Confetti.duration + 0.4` seconds, the time
   the confetti overlay keeps its burst (`Celebration.swift`), about 2.2 seconds. The same pause runs
   under Reduce Motion, where no confetti is drawn.
3. After the pause it re-checks: the task was not cancelled, the app stayed active throughout — a
   `@State` wait Home clears whenever the scene leaves `.active`, never a read of `scenePhase` after
   the sleep (plan P2) — and `manager.hasReachedGoal` still holds — an *Undo* inside the pause asks
   nothing. *(Amended after the final review, 2026-10-15.)* This point first inferred that SwiftUI
   cancels the task when Home leaves the screen. It does not, in time: a page that is left stays in
   the tree, sliding out, until its slide ends (`PageTurn.mounted`, 0.45 s), so a tab change late in
   the pause still asked, over the page sliding in (**measured**: a throwaway probe, the tab tapped
   1.96 s after the pour by its own stamp).
   Home now also clears the wait the moment it stops being the page shown, which `RootTabView` tells
   each page through a new environment value, `pageIsShown` (**measured**: the same probe, the tab
   again at 1.96 s, no request).
4. Then `manager.claimReviewRequest(version: ReviewPrompt.version)`; on `true`, `requestReview()`.

Apple's guidance this follows: *"Make the request at a time that doesn't interrupt what someone is
trying to achieve in your app, for example, at the end of a sequence of events that they successfully
complete"*; its sample waits *"for a few seconds"* on the completed scene before asking; and *"Avoid
showing a request for a review immediately when a user launches your app, even if it isn't the first
time it launches"* (all **stated**, [RAR]).

**Why only Home's pour (D5).** Section 1 of the approved outline let any upward crossing Home observed
ask, including one `refresh()` picks up when the app comes forward after the widget, Siri, the control
or a reminder's button reached the goal. That request would land about two seconds after the app
opened — the case [RAR]'s last line above warns against. Those crossings still celebrate exactly as
today; they only never ask.

**Not a reply to a button.** [RRA] says *"Because this API may not present an alert, don't call it in
response to a button tap or other user action."* The request follows a pour, as Apple's sample's
follows a completed process, after the same kind of pause; the pour's own answer is the water and the
confetti, never the request (**inferred**: the line is read as forbidding a control whose result *is*
the request, which the sample itself does not avoid).

### 3.4 The stored mark

**`Key.reviewRequestedVersion`**, a `String`: the version the app last asked in.
- **Absent means never asked**, and nothing materialises it — like `isGoalSet`, `remindersEnabled`,
  `language` and `servings`, each of whose absence also carries a meaning (`Key`'s DocC).
- Read with `defaults.object(forKey:) as? String` (plan P1) — not `string(forKey:)`, which hands back
  a stored number as a string. A stored value that is not a string reads as absent: the worst it can
  cost is one extra request, which Apple's limit still bounds.
- It joins `Key.all`, so `readingLeavesTheStoreUntouched` and `readingAnEmptySuiteDoesNotCreateKeys`
  cover it, and `everyKeyTheProductWritesIsOnTheRoster` drives the claim.
- The phone's suite goes from nine keys to ten. It reaches no snapshot, no mirror, no notification.
- The migration's fixed list of four does not gain it: `.standard` never held it.

### 3.5 The model's surface

On `DataManager`, compiled into all four targets and importing nothing new:

- `nonisolated static let reviewStreak = 3`
- `nonisolated static func mayRequestReview(reachedToday: Bool, streak: Int, askedVersion: String?,
  version: String) -> Bool` — pure; `true` only when `reachedToday`, `streak >= reviewStreak`,
  `!version.isEmpty` and `askedVersion != version`.
- `func claimReviewRequest(version: String) -> Bool` — reads the key, asks `mayRequestReview` with
  `hasReachedGoal` and `streak`, and on `true` **writes `version` before returning `true`**. We cannot
  learn whether iOS showed the request, and Apple's sample records it the same way (**stated**,
  [RAR]: *"The app already displayed the rating and review request view. Store this current
  version."*). It touches no row, rings no widget doorbell and reschedules nothing: the widget never
  reads the key and no plan depends on it.

No new role guard. `streak` is zero in every role but `.phoneApp`, so the decision answers `false`
there by construction; a fifth question beside the four the role answers would restate that. No
`refresh()` first: only this method writes the key, so there is no stale copy from another process to
overwrite.

### 3.6 `ReviewPrompt` — the app's side (D4)

A new app-only file, `WaterBuddy/ReviewPrompt.swift`, importing `Foundation` alone, holding:
- `launchArgument`, `"-WaterBuddyReviewPrompt"`, and `isEnabled(arguments:)`: under `#if DEBUG` it
  answers whether the argument is present; otherwise always `true`. Read for this process by a
  computed `isEnabledHere`.
- `pause`, `Confetti.duration + 0.4` seconds — computed, like `isEnabledHere` (plan P3).
- `version`, `Bundle.main`'s `CFBundleShortVersionString`, or `""` when absent — which §3.5 never asks
  for.

**Why DEBUG is off by default.** *"When your app calls this method while it's in development mode,
StoreKit always displays the rating and review request view"* (**stated**, [RRA]). The UI suite
builds `XCUIApplication()` at 22 sites (**measured**), none of which would pass the argument, and runs
against the gate simulator's real data, which has gathered water over several days of gating — its
streak may already be 3 (**unconfirmed**).
A UI test whose pour crossed the goal would meet a system alert. Off unless asked: in a DEBUG build
without the argument Home never claims, so nothing is written and nothing is shown. TestFlight shows
nothing either way: *"this method has no effect in apps that you distribute for beta testing using
TestFlight"* (**stated**, [RRA]).

`StoreKit` is imported by **`HomeView.swift` alone**, for `@Environment(\.requestReview)`.
`RequestReviewAction` lives in the `_StoreKit_SwiftUI` cross-import overlay, `@available(iOS 16.0, *)`,
`@available(watchOS, unavailable)`, `@MainActor` (**measured**, the SDK's `.swiftinterface`). The floor
is iOS 17.0, so no `#available` is needed.

### 3.7 What never asks

The widget's **+**, the Lock Screen widget, the Control Center control, the Siri phrase, a reminder's
*Log a Glass*, the watch, and History's **+** — even when a serving it adds for today reaches the goal.
None of them is Home's pour, and the extension and the watch cannot import `StoreKit` (§5).

## 4. What it touches beyond the app

- **The widget extension and both watch targets** compile `DataManager.swift` and gain the key, the
  pure decision and the claim, none of which imports anything. None of them calls the claim.
- **`project.pbxproj`: no change.** `ReviewPrompt.swift` joins the app through its synchronized root
  group; no exception set gains it.
- **No entitlement, no Info.plist key, no `PrivacyInfo.xcprivacy` change.** The request touches none
  of the five required-reason categories — file timestamps, system boot time, disk space, active
  keyboards, `UserDefaults` (**inferred**). The new key is `UserDefaults` in the App Group suite, the
  use the four manifests already declare as `1C8F.1` (rule `15-project`, *Submission*).
- **No string.** The request's words are the system's, in the system's language. No catalogue changes.
- **Linking.** `import StoreKit` links the framework into the app binary by auto-linking; every
  `PBXFrameworksBuildPhase` stays `files = ()` (rule `95-dependencies`).

## 5. What this amends

Typed into the rule files **unstaged**, for the owner, before any code. Approving this document
approves this wording.

**`70-privacy`**, *Nothing leaves the device*, first bullet becomes:

> - Import no networking, analytics or sensor framework: `URLSession`, `Network`, `CoreLocation`,
>   `HealthKit`, `CloudKit`, `StoreKit` (one exception, below), `AdSupport`,
>   `AppTrackingTransparency` — and no third-party SDK (rule `95-dependencies`)

and a new section follows *WatchConnectivity is a ruling, not an omission*:

> ## The review request is the one use of StoreKit
>
> `StoreKit` stays banned, with one exception: `HomeView.swift`, in the app target, imports it for
> `@Environment(\.requestReview)` and nothing else. iOS draws the request, decides whether to show it,
> and sends any rating or review to Apple itself, under the user's own Apple Account and only on the
> user's own tap. The app hands it nothing — no figure, no identifier, no account — and learns nothing
> back, not even whether it was shown. It needs no entitlement and no usage-description key.
>
> Three limits are conditions of the permission:
> - **One file.** No widget or watch file imports `StoreKit`, and neither does `DataManager.swift`,
>   which compiles into all four targets
> - **One call.** No product, purchase, transaction or subscription API until roadmap item 1.4.1 writes
>   its own amendment here. A *Rate WaterBuddy* link to the App Store is not part of this permission
>   either
> - **One moment.** Asked only after the user's own pour on Home reaches the goal on the third day in
>   a row, at most once per app version, after the confetti lands — never at launch, never from a
>   button whose answer is the request, never from the widget, Siri, the control, a reminder's button,
>   the watch or History

**`20-state`**, *One writer*, a bullet after the mutation surface's:

> - `claimReviewRequest(version:)` joins that surface. It writes `Key.reviewRequestedVersion` and
>   nothing else: it decides through `mayRequestReview(reachedToday:streak:askedVersion:version:)` and
>   writes the version **before** it answers `true`, so nothing can ask without recording it. It
>   touches no row, rings no doorbell and reschedules nothing

**`25-shared-storage`**, *Keys*, the absence bullet becomes:

> - Absence carries meaning for `Key.isGoalSet`, `Key.language` and `Key.reviewRequestedVersion`
>   (never asked): never materialise a sentinel for "not chosen". The `language` setter calls
>   `removeObject(forKey:)` for `.system`, because a stored code would pin the app to today's system
>   language forever

**`10-architecture`**, the diagram's `9 keys, derived cache` becomes `10 keys, derived cache`, and
the paragraph under it ends:

> … `Key.wristApplied`, the phone-side half of that exchange's apply ledger, lives in the 10 keys
> above, bringing the phone suite from 8 to 9; `Key.reviewRequestedVersion`, the version the app last
> asked for a rating in, brings it to 10.

**`85-testing`**, *A fixture may never reach real data*, after the fresh-start bullet:

> - `-WaterBuddyReviewPrompt` is DEBUG's opt-in to the rating request, read through
>   `ReviewPrompt.isEnabled(arguments:)`. Without it a DEBUG build never claims, never writes
>   `Key.reviewRequestedVersion` and never asks — StoreKit shows the request every time in development,
>   and a UI test whose pour crossed the goal on a long-gated simulator would meet a system alert. No
>   UI test passes it. The request itself has no automated coverage: prove it by hand on a simulator
>   launched with the argument

**`CLAUDE.md`** (the owner's, as the rules are): the storage table's row becomes *"`UserDefaults` —
ten keys | today's total, the goal, the day ordinal, three flags, the chosen language, the three
quick-add amounts, the phone's applied-pours ledger, the version the app last asked for a rating in —
a **derived cache**"*, and *One Writer*'s list of methods gains *"and `claimReviewRequest` for the
rating request's mark"* after `ingest`'s clause.

## 6. Testing

Written first and seen failing (rule `85-testing`). A new `@MainActor` suite,
`WaterBuddyTests/ReviewRequestTests.swift`, each fixture with a UUID-named suite, an in-memory store,
`reloadWidgets: {}`, `rescheduleReminders: { _ in }` and an injected clock:

- **The decision:** a streak of 2 does not ask and 3 does; a streak of 3 with today short does not ask;
  a version already asked in does not ask again and a new one may; an empty version never asks.
- **The claim:** on three goal days ending today it answers `true` and stores the version; a second
  claim in that version answers `false`; a claim on a new version answers `true` again.
- **A refused claim writes nothing:** two goal days, or today short — `false`, and the key absent.
- **A stored number counts as never asked** (plan P1).
- **`ReviewPrompt.isEnabled(arguments:)`:** the test host is a DEBUG build, so it answers `false`
  without the argument and `true` with `["-WaterBuddyReviewPrompt", "YES"]`. The Release branch is not
  compiled by the gate; said so in the test's DocC.
- **`ReviewPrompt.version`** is not empty in the test host.
- **`everyKeyTheProductWritesIsOnTheRoster`** gains a claim on a qualifying fixture, so the new key is
  seen written and rostered.

Home's timing (§3.3) is presentation state with no unit seam; it is proved by hand (§7.3).

## 7. Verification

### 7.1 The gate

The five invocations of rule `85-testing`, one simulator at a time, `-parallel-testing-enabled NO`,
the UI class in chunks by test name (`tasks/lessons.md`, the simulator memory).

### 7.2 Warnings

No new warning against the clean baseline — 29 unique lines on the `WaterBuddy` scheme as measured on
2026-10-15 — compared by file and message from a clean build of the change.

### 7.3 On the simulator

On one simulator, launched from Xcode with `-WaterBuddyReviewPrompt YES`:
1. In History, add a goal's worth on each of the two days before today with **+**.
2. On Home, pour across the goal. The request appears about 2.2 seconds after the pour.
3. Undo, and pour across again. Nothing appears (the version is recorded).
4. On a fresh install with the same two past days: pour across, then *Undo* inside the pause. Nothing
   appears; pour across again and it does.
5. On a fresh install with the same two past days: pour across, then switch to History inside the
   pause. Nothing appears.
6. Relaunch **without** the argument after a fresh install with the same two past days, and pour
   across. Nothing appears, and the suite holds no `reviewRequestedVersion`.

Then the widget build and both watch builds succeed with no `StoreKit` in their link (`otool -L` on
the three binaries).

### 7.4 What only a real install shows

Whether iOS shows the request from an App Store build cannot be proved here: Xcode builds always show
it and TestFlight never does (§3.6). It opens a known issue for the device sweep (1.2.7): on the
owner's iPhone, an Xcode build with the argument on the scheme, steps 2–3 of §7.3, and the first App
Store release watched for ratings arriving.

## 8. Known limitations, and what is not in scope

- **Apple decides.** The request may not appear at all; the app records the version either way, so a
  user iOS declined to show it to is not asked again in that version.
- **The streak is judged against today's goal** (`streak`'s DocC): raising the goal can shorten a run,
  and so delay the request.
- **A *Rate WaterBuddy* row** linking to the App Store's review page is not in scope; §5's amendment
  does not permit it.
- **1.4.1's purchases** need their own amendment.
- **Noticed, not amended:** rule `25-shared-storage`'s watch section says the watch's keys are *"none
  shared with the phone's eight"*; the phone holds nine today and ten after this. The owner's to
  reword.

## 9. Sequence

1. The owner reviews this document.
2. §5's wording typed into the rule files and `CLAUDE.md`, unstaged.
3. The plan, under `docs/superpowers/plans/`.
4. `ReviewRequestTests`, run and seen RED.
5. The key, the decision and the claim on `DataManager`; `ReviewPrompt.swift`; Home's counter, task
   and request — GREEN.
6. §7.3 on the simulator; §7.1 and §7.2.
7. The records: `docs/STATE.md`'s new key row, `docs/AI_CONTEXT.md`, the roadmap's line, the new known
   issue (§7.4), `HISTORY.md`. Staged, never committed.
