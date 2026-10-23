# The Month View and Full History — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (this repository's
> `CLAUDE.md`: *there is no implementation subagent* — planning, tests, implementation and review
> happen in the main loop). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Step 2 of 5 of set A — roadmap item 1.4.2: a *Week · Month* switch in History; for a holder,
every day ever logged as a month of rings, any counted day opened read-only, and the month's figures;
for a free user, the locked month that opens the paywall.

**Architecture:** A pure value, `MonthHistory`, works a month out from rows, the first serving's
instant, the current goal, the clock and the calendar. `DataManager` publishes one month at a time —
`month` and `monthLogs`, mirroring `history` and `historyLogs` — while History asks for one through
`showMonth(_:)`, reading it with the store's existing range query. `HistoryView` gains the switch,
Month mode's rows and the locked month as private structs beside its own, and decides only what its
`nonisolated static`s decide. Nothing is stored; nothing reaches the widget or the watch.

**Tech Stack:** Swift 5 mode, SwiftUI, SwiftData (iOS 17 floor), swift-testing, XCTest UI tests.

**Spec:** `docs/superpowers/specs/2026-10-22-month-view-design.md` (approved 2026-10-22, "ok"). The
design canvas: https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy, row *Set A, step 2* (private to the
owner).

**Starting point:** HEAD `a6e287b`; staged — the spec. Unstaged and the owner's: `.claude/settings.json`;
Xcode's rewrites (#50) of the two watch schemes, `WaterBuddy/AppShortcuts.xcstrings` and the two watch
catalogues. Untracked: `Screenshots/census/`. None of them is touched by this plan.

## Decisions this plan takes

Each is a reading of the spec where its text left a choice; each says what it costs if wrong.

- **M1 — the UI tests join `PremiumUITests`**, not a new `MonthUITests` (spec §6), so rule
  `85-testing`'s "`PremiumUITests` passes it and no other UI test does" stays true. Cost: a class name.
- **M2 — `MonthHistory.earlier` and `.later` are `Neighbour?`** — the first-day ordinal and the
  month's first instant — rather than `Int?`: an arrow is labelled with the month it goes to, and a
  view holds no calendar to make one from an ordinal (rule `30-rollover`). The instant is for
  formatting the label and nothing else, as `DaySummary.date` is.
- **M3 — `MonthHistory.Day` carries `isMet`, `isToday` and `fraction`**, so the view judges nothing
  against the goal and divides nothing (rule `50-views`).
- **M4 — the grid is `monthGrid(dayCount:weekdayOfFirst:firstWeekday:)`**, plain numbers, the
  weekday of the 1st from the model's calendar (`MonthHistory.weekdayOfFirst`). Beside it, three more
  `nonisolated static`s on `HistoryView`: `firstWeekday(in:)` — from `Locale.firstDayOfWeek` (iOS 16),
  which honours the user's own *First Day of Week*; `weekdayLetters(in:)`; `litres(_:locale:)`.
- **M5 — the month's total counts the days up to today.** A pour stamped ahead of the phone's clock
  — the watch's own — lands on a day still to come and counts nowhere until that day (Review Focus
  1). The spec's "today's included" stands.
- **M6 — the opened day's name and total stand on the aurora as a heading** (`legibleOnBackdrop()`)
  over `DayStrip`'s own pane, where the board drew one pane round both: `DayStrip` is reused
  unchanged. Cost if wrong: a pane round two lines, which the walk shows the owner.
- **M7 — the opened day's disc is `Selection.discFill` with its number in `Aurora.top`**, the week
  card's own tokens (`theShownDaysLetterReadsOnItsDisc`); the board drew a translucent disc.
- **M8 — the arrows are chevrons with a 44-pt target, not glass circles:** glass inside the card's
  glass is avoided, as step 1's card previews avoided it (its S7). At a bound an arrow is drawn at
  0.35 and hidden from VoiceOver, since there is no month to name.
- **M9 — a quiet day's number starts at white 0.7**, the value History's empty state measured on
  this pane (5.25:1 on iOS 27.0), and is measured in the walk (spec §8).
- **M10 — the first serving has its own one-row read**, `readOldestLog()`, oldest first,
  `fetchLimit` 1, `nil` on failure, beside `fetch(_:)` — whose sort is newest first.
- **M11 — History's own `MonthStyle.buttonHeight`, 56:** the paywall's and the card's are private
  to their files.
- **M12 — an opened day with nothing logged draws its heading alone** (*0 of 3,000 ml*): Week mode's
  empty state points at a `+` the opened day does not carry.
- **M13 — History lets go of a month in `.onAppear` only while Week is shown**, and when
  `\.pageIsShown` turns `false`; a holder's Premium lapsing with Month open lets it go too.
  *(Amended 2026-10-23, the owner's ruling on the final review's I1 and I2: not when `\.pageIsShown`
  turns `false` but when the page is removed, in `.onDisappear` — spec §3.8, as amended. Task 7's code
  below keeps its original text; the tree's `HistoryView` is the authority.)*
- **M14 — the warnings baseline is a clean build of a `HEAD` `a6e287b` export:** 20 / 17 / 2 / 2,
  as step 1 left them.

## Global Constraints

- iOS floor **17.0**, no `#available`: `Locale.firstDayOfWeek` is iOS 16.
- **Nothing stored**: no `DataManager.Key`, no `UserDefaults` write, no schema change; no exception
  set, `project.pbxproj`, entitlement, Info.plist or privacy manifest change.
- `MonthHistory` lives in `WaterBuddy/DataManager.swift`, compiled into all four targets: Foundation
  and `WaterLog` only, every member `nonisolated`.
- Every day is judged against the **current** goal. Which days count (spec §3.5): a past month every
  day; this month the days before today, and today once it has reached the goal; the first month from
  the first serving's day.
- A month is named by the ordinal of its 1st; its bounds come from `dateInterval(of: .month, for:)`
  on the injected calendar, its days from `date(byAdding: .day, …)` — never 86,400 seconds. The grid's
  first weekday is the app's locale's, never `Calendar.waterBuddyDay`'s.
- Month mode's servings are **read-only**, for every day and every user. The correction range stays
  the week.
- `-WaterBuddyPremium` reaches `PremiumUITests` alone. The paywall opens from Settings' *See Premium*
  and History's locked month only (rule `70-privacy`).
- Text on the aurora carries `legibleOnBackdrop()`; sentence-length text sits on `.frosted` glass.
  `.premiumRim()` marks Settings' card and the locked month and nothing else.
- Tests first: write, run, **see RED by a stub** (never by a compile failure), implement, run GREEN.
  Never narrow an assertion.
- **No new warning** against Task 0's baseline, all four schemes, by file and message.
- Edit with `Edit`/`Write` only — no `sed -i`, no script into the tree. Scratch work in this session's
  scratchpad (`$SCRATCH`).
- **Xcode closed** while `WaterBuddy/Localizable.xcstrings` is edited (#50).
- Simulators: unit and probe on the stock *iPhone 17* (iOS 27.0); UI on *WaterBuddy Gate 27* and
  *WaterBuddy Gate 26.5*; watch on *WaterBuddy Watch 27*; the walk on *WaterBuddy Probe 27*. `uptime`
  before each run, wait while the 1-minute load is above 6. Shut down **by UDID**, never
  `simctl shutdown all` while another `xcodebuild` runs. `-parallel-testing-enabled NO`;
  `-collect-test-diagnostics never` on runs meant to fail.
- Never write the real App Group suite or `UserDefaults.standard`. **Never commit**; stage explicit
  paths. Rule files stay unstaged for the owner.

## Review Focus

Five inputs a person will meet that the spec's tests do not reach as written, each pinned in the task
that owns it:

1. **A serving stamped after today** — a watch pour carrying a clock ahead of the phone's → in no
   figure, its day not openable → `aServingStampedAfterTodayCountsNowhere` (Task 3).
2. **The first serving deleted while its month is shown** → the earliest bound moves, the days before
   the new first go quiet, ‹ goes → `deletingTheFirstServingMovesTheEarliestBound` (Task 4).
3. **Midnight on the month's last day, Month open** → the month stays, turns past, › appears →
   `aMonthEndingOnScreenStaysShownAndBecomesPast` (Task 4).
4. **A flight west across a month's edge** → a serving follows its instant into the month the new zone
   puts it in → `aServingAtTheMonthsEdgeRegroupsWithTheZone` (Task 3).
5. **A month ordinal that names no month** (a stale or corrupt request) → nothing published, nothing
   trapped → `aMonthThatNamesNoMonthPublishesNothing` (Task 4).

And one only a hand can reach: **Premium refunded while Month is open** → the locked month replaces
the month and the model stops reading it (Task 8, walk step 9).

## File structure

| File | Target | Change |
|---|---|---|
| `WaterBuddy/DataManager.swift` | all four | `MonthHistory` (Task 3); `month`, `monthLogs`, `thisMonth`, `showMonth(_:)`, `republishMonth()`, `readOldestLog()` and four call sites (Task 4) |
| `WaterBuddy/HistoryView.swift` | app | five statics (Task 5); the switch, Month mode, the locked month, `ServingRow` read-only, the previews (Task 7) |
| `WaterBuddy/PaywallView.swift` | app | `Entry.history` (Task 7) |
| `WaterBuddy/Localizable.xcstrings` | app | 20 keys (Task 6) |
| `WaterBuddyTests/MonthHistoryTests.swift` | tests — **new** | `MonthHistoryTests` (Task 3), `MonthPublishingTests` (Task 4) |
| `WaterBuddyTests/HistoryViewTests.swift` | tests | `MonthLayoutTests` (Task 5) |
| `WaterBuddyTests/LocalizationTests.swift` | tests | `historyKeys` + 20, `countedKeys` + 5, `expected` + 15 (Task 6) |
| `WaterBuddyUITests/PremiumUITests.swift` | UI tests | two tests (Task 7) |
| `.claude/rules/20-state.md`, `30-rollover.md`, `43-concurrency.md`, `50-views.md`, `60-design-system.md`, `85-testing.md` | — | wording, **unstaged** (Task 2) |
| `docs/…`, `CLAUDE.md`, `HISTORY.md`, `tasks/lessons.md` | — | records (Task 10) |

Expected counts after the work, by the attribute grep, not trusted from here: unit `@Test`
768 + 22 + 12 + 10 = **812**; watch **70**; UI `func test` 58 + 2 = **60** (73 executed, 1 skipped).

## Commands used below

```bash
# UNIT <filters>: swift-testing on the stock iOS 27.0 iPhone 17
W=.superpowers/sdd/2026-10-22-month-view
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' <-only-testing:WaterBuddyTests/Suite> -parallel-testing-enabled NO -collect-test-diagnostics never > $W/<name>.log 2>&1; grep -E "Test run with|✘|error:" $W/<name>.log | tail -40

# UI <filters>: XCTest on WaterBuddy Gate 27
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' <-only-testing:WaterBuddyUITests/Class/testName> -parallel-testing-enabled NO -collect-test-diagnostics never > $W/<name>.log 2>&1; grep -E "Executed|error:|failed" $W/<name>.log | tail -12
```

A swift-testing filter names a suite, or a test **with its parentheses** —
`-only-testing:WaterBuddyTests/MonthHistoryTests/aPastMonthCountsEveryDay()`. Read a run's executed
count, never its last line alone.

---

### Task 0: The ledger and the baselines

**Files:** `$W/progress.md` (git-ignored); `$SCRATCH/base/*`.

- [ ] **Step 1: The ledger.** Create `$W/progress.md` with `Write`: its identity line (*Set A, step 2 —
  the month view; plan `docs/superpowers/plans/2026-10-22-month-view.md`*), the starting state
  (`git status --short`, HEAD), and an empty *Rulings* list.
- [ ] **Step 2: The warnings baseline** (M14), from a `HEAD` export into one empty DerivedData:

```bash
rm -rf "$SCRATCH/head" "$SCRATCH/head-dd"; mkdir -p "$SCRATCH/head"; git archive a6e287b | tar -x -C "$SCRATCH/head"
xcodebuild build-for-testing -project "$SCRATCH/head/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/head-dd" > "$SCRATCH/base-app.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/head/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/head-dd" > "$SCRATCH/base-widget.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/head/WaterBuddy.xcodeproj" -scheme WaterBuddyWatch -destination 'generic/platform=watchOS Simulator' -derivedDataPath "$SCRATCH/head-dd" > "$SCRATCH/base-watch.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/head/WaterBuddy.xcodeproj" -scheme WaterBuddyWatchWidget -destination 'generic/platform=watchOS Simulator' -derivedDataPath "$SCRATCH/head-dd" > "$SCRATCH/base-watchwidget.log" 2>&1; echo "exit $?"
for s in app widget watch watchwidget; do grep -E '^/.*: warning: ' "$SCRATCH/base-$s.log" | sed -E 's#^.*/head/##; s#^(Water[^:]+):[0-9]+:[0-9]+: #\1: #' | sort -u > "$SCRATCH/base-$s-messages.txt"; echo "$s $(wc -l < "$SCRATCH/base-$s-messages.txt")"; done
```

  Expected: four `exit 0`; app **20**, widget **17**, watch **2**, watch widget **2**. A different
  count is read and ledgered before going on.

---

### Task 1: The probe — the reads' cost, the calendar, the languages

**Files:** a throwaway copy in `$SCRATCH/probe`, removed after.

- [ ] **Step 1: The copy.** `git checkout-index -a --prefix="$SCRATCH/probe/"`.
- [ ] **Step 2: A probe suite** in the copy, `WaterBuddyTests/ProbeTests.swift`:

```swift
import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

@MainActor
@Suite(.serialized)
struct ProbeTests {

    /// A file-backed store in the temporary directory — SQLite, as the product reads — holding `days`
    /// days of `perDay` servings. Synthetic data, so seconds are fine here and nowhere in the product.
    private func store(days: Int, perDay: Int = 8) throws -> (ModelContainer, URL) {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let schema = Schema([WaterLog.self])
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, url: directory.appendingPathComponent("probe.store"))
        )
        let context = ModelContext(container)
        let now = Date()
        for day in 0..<days {
            for serving in 0..<perDay {
                context.insert(WaterLog(amount: 250, timestamp: now.addingTimeInterval(-Double(day) * 86_400 - Double(serving) * 3_600)))
            }
        }
        try context.save()
        return (container, directory)
    }

    /// The median of `runs` timings, in milliseconds.
    private func median(_ runs: Int = 21, _ work: () -> Void) -> Double {
        let clock = ContinuousClock()
        let times = (0..<runs).map { _ in clock.measure(work) }.map {
            Double($0.components.seconds) * 1_000 + Double($0.components.attoseconds) / 1e15
        }
        return times.sorted()[runs / 2]
    }

    @Test(arguments: [7, 45, 150, 500])
    func theReadsCost(days: Int) throws {
        let (container, directory) = try store(days: days)
        defer { try? FileManager.default.removeItem(at: directory) }
        let name = "probe.waterbuddy.month.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer {
            defaults.removePersistentDomain(forName: name)
            UserDefaults.standard.removeSuite(named: name)
        }
        let manager = DataManager(
            defaults: defaults, modelContainer: container,
            reloadWidgets: {}, rescheduleReminders: { _ in }, publishWrist: { _ in }
        )
        let refresh = median { manager.refresh() }

        let context = ModelContext(container)
        let calendar = Calendar.waterBuddyDay
        let end = DataManager.nextDayBoundary(after: .now, calendar: calendar)
        let start = calendar.date(byAdding: .month, value: -2, to: end)!
        let twoMonths = median {
            let descriptor = FetchDescriptor<WaterLog>(
                predicate: #Predicate { $0.timestamp >= start && $0.timestamp < end },
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            _ = try? context.fetch(descriptor)
        }
        let oldest = median {
            var descriptor = FetchDescriptor<WaterLog>(sortBy: [SortDescriptor(\.timestamp, order: .forward)])
            descriptor.fetchLimit = 1
            descriptor.includePendingChanges = true
            _ = try? context.fetch(descriptor)
        }
        print("PROBE cost days=\(days) refresh=\(refresh)ms twoMonths=\(twoMonths)ms oldest=\(oldest)ms")
    }

    @Test func theOldestRowIsReadBesideAnUnsavedOne() throws {
        let container = try ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        context.insert(WaterLog(amount: 1, timestamp: Date(timeIntervalSince1970: 2_000_000)))
        try context.save()
        context.insert(WaterLog(amount: 2, timestamp: Date(timeIntervalSince1970: 1_000_000)))
        var descriptor = FetchDescriptor<WaterLog>(sortBy: [SortDescriptor(\.timestamp, order: .forward)])
        descriptor.fetchLimit = 1
        descriptor.includePendingChanges = true
        print("PROBE oldest-with-pending", try context.fetch(descriptor).map(\.amount))
        try context.save()
        print("PROBE oldest-after-save", try context.fetch(descriptor).map(\.amount))
    }

    @Test func theCalendarAndTheLanguages() {
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = TimeZone(identifier: "America/New_York")!
        newYork.locale = Locale(identifier: "en_US_POSIX")
        let noon = newYork.date(from: DateComponents(year: 2025, month: 11, day: 1, hour: 12))!
        let month = newYork.dateInterval(of: .month, for: noon)!
        print("PROBE nov2025", month.start, month.end, month.duration / 3_600)
        for code in ["en", "ru", "uz", "en_GB"] {
            let locale = Locale(identifier: code)
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = locale
            print("PROBE week", code, locale.firstDayOfWeek, calendar.firstWeekday, calendar.veryShortStandaloneWeekdaySymbols,
                  noon.formatted(.dateTime.month(.wide).year().locale(locale)),
                  noon.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale)),
                  (Decimal(62_570) / 1_000).formatted(.number.precision(.fractionLength(1)).locale(locale)))
        }
    }
}
```

- [ ] **Step 3: Run it in the copy** (UNIT against `$SCRATCH/probe/WaterBuddy.xcodeproj`,
  `-only-testing:WaterBuddyTests/ProbeTests`) and ledger every `PROBE` line. Expected:
  - the cost lines — the two reads' sum is the most a shown month adds to a `refresh()`; at 500 days
    it is under **3 ms**. Over it, stop and re-plan with the owner (spec §3.7's budget);
  - `oldest-with-pending [2]` and `oldest-after-save [2]`. A `[1]` with the unsaved row is ledgered
    and accepted — every mutation saves before it republishes (`saveAndRecompute()`), so the read that
    matters is the one after a save — and a `[1]` after the save stops the plan;
  - `nov2025` from 1 November 04:00 UTC to 1 December 05:00 UTC, **721** hours;
  - `week en sunday … [S, M, T, W, T, F, S]`, `ru monday`, `uz monday`, `en_GB monday`; the month as
    *November 2025*, *ноябрь 2025 г.* and Uzbek's own; *62.6*, *62,6*, *62,6*. If `uz` reads
    `sunday`, `theWeekStartsOnTheLanguagesFirstDay` in Task 5 takes the probe's answer for Uzbek,
    ledgered as a ruling.
- [ ] **Step 4:** `rm -rf "$SCRATCH/probe"`. Ledger: Task 1 complete (probe).

---

### Task 2: The rule wording, typed and unstaged

**Files:** `.claude/rules/20-state.md`, `30-rollover.md`, `43-concurrency.md`, `50-views.md`,
`60-design-system.md`, `85-testing.md` — **not staged**.

- [ ] **Step 1: `20-state`**, *Clamps and guards*:
  - "`isGoalSet`, `todaysLogs`, `historyLogs` and `streak` stay get-only. All four are consequences,
    not inputs" → "`isGoalSet`, `todaysLogs`, `historyLogs`, `month`, `monthLogs` and `streak` stay
    get-only. All six are consequences, not inputs";
  - after the `streak` bullet, a new one:

  > - `month` and `monthLogs` are published only while History has asked for a month through
  >   `showMonth(_:)`, behind `role.drawsHistory`, from `showMonth`, `refresh()`, `saveAndRecompute()`,
  >   `dayDidTurn()` and the `dailyGoal` setter — never `init`. A failed read leaves both as they stand.
  >   `showMonth(_:)` writes neither store

  - "Do **not** add an equality guard to the `todaysLogs` or `historyLogs` republish" → "Do **not** add
    an equality guard to the `todaysLogs`, `historyLogs` or `monthLogs` republish".
- [ ] **Step 2: `30-rollover`**, *Day bounds*, a bullet after the `historyWindowStart` one:

  > - A month is named by the ordinal of its 1st. Its bounds come from the injected calendar's
  >   `dateInterval(of: .month, for:)` and its days from `date(byAdding: .day, …)`. Its grid's first
  >   weekday is the app's locale's, never `Calendar.waterBuddyDay`'s

- [ ] **Step 3: `50-views`**:
  - *Composition*: "History is one `List`, and everything on the screen is a row of it: the header,
    the week card, the strip and the servings, each with the list's own surfaces cleared." → "History
    is one `List`, and everything on the screen is a row of it: the header, the week card, the strip
    and the servings — in Month mode the header, the switch, the month card, an opened day and the
    figures — each with the list's own surfaces cleared.";
  - *Navigation*, a bullet after the widget-link one:

  > - History's *Week · Month* switch is a control inside the screen, not a route. It is drawn where
  >   `HistoryView.offersMonth(status:offered:)` says, and Month mode's servings are read-only —
  >   adding and correcting stay Week mode's, for every user

  - "The paywall is presented with `.sheet(item:)` bound to an optional `PaywallView.Entry` — where it
    was opened from — never a `Bool`" → "The paywall is presented with `.sheet(item:)` bound to an
    optional `PaywallView.Entry` — where it was opened from, `.settings` or `.history` — never a
    `Bool`".
- [ ] **Step 4: `60-design-system`**, *Glass*:
  - in the selection bullet, after "the letter heavier than the rest.", insert "The month card's
    opened day takes the same ring round its ring **and** disc behind its number, the number heavier;
    today's number is heavier and takes no disc.";
  - "Premium's card is marked with `.premiumRim()` — `Aurora.cyan`, `Aurora.magenta` and `Aurora.blue`
    stroked around a standard pane — and nowhere else." → "Premium's Settings card and History's
    locked month are marked with `.premiumRim()` — `Aurora.cyan`, `Aurora.magenta` and `Aurora.blue`
    stroked around a standard pane — and nothing else is."
- [ ] **Step 5: `43-concurrency`** (*Tests*' list of suites never to annotate) and **`85-testing`**
  (*Isolation*'s list of suites that are not `@MainActor`): add `MonthHistoryTests` and
  `MonthLayoutTests` after `PaywallScreenTests`.
- [ ] **Step 6:** `git diff --stat -- .claude/rules` shows six files; none staged. Ledger: Task 2
  complete (no tests — the wording, unstaged).

---

### Task 3: The month, as a value — `MonthHistory`

**Files:**
- Modify: `WaterBuddy/DataManager.swift` (insert before `// MARK: - Read-only snapshot`)
- Create: `WaterBuddyTests/MonthHistoryTests.swift`

**Interfaces — produces:**
- `nonisolated struct MonthHistory: Sendable, Equatable` with `firstDay: Int`, `weekdayOfFirst: Int`,
  `days: [Day]`, `daysMet: Int`, `daysCounted: Int`, `bestRun: Int`, `total: Int`, `average: Int?`,
  `change: Int?`, `earlier: Neighbour?`, `later: Neighbour?`
- `MonthHistory.Day` — `summary: DaySummary`, `isCounted: Bool`, `canOpen: Bool`, `isToday: Bool`,
  `isMet: Bool`, `fraction: Double`
- `MonthHistory.Neighbour` — `firstDay: Int`, `start: Date`
- `MonthHistory.firstDay(ofMonthHolding: Date, in: Calendar) -> Int`
- `MonthHistory.interval(of: Int, in: Calendar) -> DateInterval?`
- `MonthHistory.firstDay(of: Int, movedBy: Int, in: Calendar) -> Int?`
- `MonthHistory.days(of: Int, in: Calendar) -> [(ordinal: Int, date: Date)]`
- `MonthHistory.make(rows: [WaterLog], month: Int, firstServing: Date?, goal: Int, now: Date, calendar: Calendar) -> MonthHistory?`

- [ ] **Step 1: The tests.** Create `WaterBuddyTests/MonthHistoryTests.swift`:

```swift
//
//  MonthHistoryTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 22/10/26.
//

import Foundation
import SwiftData
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private func gregorian(in timeZone: String) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: timeZone)!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}

/// A Gregorian/UTC day, so no test can flake near local midnight or across a DST change.
private let utcDay = gregorian(in: "UTC")

private func utc(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
    utcDay.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
}

/// A serving at an instant, with no store behind it.
private func log(_ amount: Int, at date: Date) -> WaterLog {
    WaterLog(amount: amount, timestamp: date)
}

/// `amount` at noon on each of `days` of October 2026.
private func october(_ days: ClosedRange<Int>, _ amount: Int) -> [WaterLog] {
    days.map { log(amount, at: utc(2026, 10, $0)) }
}

private let goal = 3_000

/// Thursday 22 October 2026, 14:00 UTC — *today* in this file.
private let thursday22 = utc(2026, 10, 22, 14)

private func make(
    _ rows: [WaterLog],
    month: Int = 20261001,
    first: Date? = utc(2026, 8, 1),
    goal: Int = goal,
    now: Date = thursday22,
    calendar: Calendar = utcDay
) -> MonthHistory? {
    MonthHistory.make(rows: rows, month: month, firstServing: first, goal: goal, now: now, calendar: calendar)
}

// MARK: - The value

/// One month, worked out with no store, no `DataManager` and no main actor (spec
/// `2026-10-22-month-view-design.md` §3.5). Not `@MainActor`, on purpose: a canary for
/// ``MonthHistory`` staying a pure value (rule `43-concurrency`), as `DaySummaryTests` is for
/// ``DaySummary``. Fix the declaration it reads, never this suite.
struct MonthHistoryTests {

    // MARK: Naming a month

    @Test func aMonthIsNamedByItsFirstDay() {
        #expect(MonthHistory.firstDay(ofMonthHolding: thursday22, in: utcDay) == 20261001)
        #expect(MonthHistory.firstDay(of: 20261001, movedBy: -1, in: utcDay) == 20260901)
        #expect(MonthHistory.firstDay(of: 20261001, movedBy: 3, in: utcDay) == 20270101)
        #expect(MonthHistory.firstDay(of: 20260101, movedBy: -1, in: utcDay) == 20251201)
    }

    @Test func anOrdinalThatNamesNoMonthIsNothing() {
        #expect(MonthHistory.interval(of: 20261301, in: utcDay) == nil)
        #expect(MonthHistory.days(of: 20260001, in: utcDay).isEmpty)
        #expect(make([], month: 20261301) == nil)
    }

    @Test func aMonthHasItsOwnNumberOfDays() {
        #expect(MonthHistory.days(of: 20261001, in: utcDay).count == 31)
        #expect(MonthHistory.days(of: 20260901, in: utcDay).count == 30)
        #expect(MonthHistory.days(of: 20270201, in: utcDay).count == 28)
        #expect(MonthHistory.days(of: 20280201, in: utcDay).count == 29, "a leap February")
        #expect(MonthHistory.days(of: 20261001, in: utcDay).map(\.ordinal) == Array(20261001...20261031))
    }

    /// November 2025 in New York holds the 25-hour fall-back day: still thirty days, each once, and two
    /// servings on it 24h29m apart are one day (rule `30-rollover`).
    @Test func aDaylightSavingMonthKeepsEveryDay() throws {
        let newYork = gregorian(in: "America/New_York")
        #expect(MonthHistory.days(of: 20251101, in: newYork).map(\.ordinal) == Array(20251101...20251130))

        let early = newYork.date(from: DateComponents(year: 2025, month: 11, day: 2, hour: 0, minute: 30))!
        let late = newYork.date(from: DateComponents(year: 2025, month: 11, day: 2, hour: 23, minute: 59))!
        let now = newYork.date(from: DateComponents(year: 2025, month: 12, day: 5, hour: 12))!
        let month = try #require(make([log(500, at: early), log(250, at: late)], month: 20251101, first: early, now: now, calendar: newYork))
        #expect(month.days.first { $0.summary.dayOrdinal == 20251102 }?.summary.total == 750)
        #expect(month.days.filter { $0.summary.total > 0 }.count == 1)
    }

    @Test func aMonthKnowsTheWeekdayItsFirstFallsOn() throws {
        #expect(try #require(make([])).weekdayOfFirst == 5, "1 October 2026 is a Thursday")
        #expect(try #require(make([], month: 20260801)).weekdayOfFirst == 7, "1 August 2026 is a Saturday")
    }

    // MARK: Which days count

    @Test func aPastMonthCountsEveryDay() throws {
        let month = try #require(make([], month: 20260901))
        #expect(month.daysCounted == 30)
        #expect(month.days.allSatisfy { $0.isCounted && $0.canOpen })
        #expect(month.average == 0, "an empty day is a day the user drank nothing")
    }

    @Test func thisMonthCountsTodayOnlyOnceItHasReachedTheGoal() throws {
        let past = october(1...21, 3_000)
        let morning = try #require(make(past + [log(1_000, at: utc(2026, 10, 22, 9))]))
        #expect(morning.daysCounted == 21)
        #expect(morning.daysMet == 21)
        #expect(morning.days.first { $0.isToday }?.canOpen == true, "today opens before it counts")

        let met = try #require(make(past + [log(3_000, at: utc(2026, 10, 22, 9))]))
        #expect(met.daysCounted == 22)
        #expect(met.daysMet == 22)
    }

    @Test func daysStillToComeAreNeitherCountedNorOpened() throws {
        let ahead = try #require(make([])).days.filter { $0.summary.dayOrdinal > 20261022 }
        #expect(ahead.count == 9)
        #expect(ahead.allSatisfy { !$0.isCounted && !$0.canOpen })
    }

    @Test func theFirstMonthCountsFromTheFirstServing() throws {
        let month = try #require(make(october(15...21, 2_100), first: utc(2026, 10, 15, 9)))
        #expect(month.daysCounted == 7)
        #expect(month.average == 2_100, "averaged over the seven days since the first serving, not twenty-one")
        #expect(month.days.prefix(14).allSatisfy { !$0.canOpen && !$0.isCounted })
        #expect(month.earlier == nil, "nothing was logged before this month")
    }

    @Test func aMonthBeforeAnythingWasLoggedCountsNothing() throws {
        let month = try #require(make([], first: nil))
        #expect(month.daysCounted == 0)
        #expect(month.average == nil)
        #expect(month.change == nil)
        #expect(month.days.allSatisfy { !$0.canOpen })
        #expect(month.earlier == nil)
    }

    // MARK: The figures

    @Test func daysOnGoalAndTheBestRun() throws {
        // Met on every day from the 1st to the 21st but the 3rd, 13th, 15th and 19th: runs of 2, 9, 1, 3, 2.
        let short = [3, 13, 15, 19]
        let month = try #require(make((1...21).map { log(short.contains($0) ? 1_500 : 3_200, at: utc(2026, 10, $0)) }))
        #expect(month.daysMet == 17)
        #expect(month.daysCounted == 21)
        #expect(month.bestRun == 9)
    }

    @Test func aRunDoesNotCarryOverFromTheMonthBefore() throws {
        let rows = (25...30).map { log(3_000, at: utc(2026, 9, $0)) } + october(1...3, 3_000) + [log(500, at: utc(2026, 10, 4))]
        #expect(try #require(make(rows)).bestRun == 3)
    }

    @Test func theAverageCountsTheEmptyDays() throws {
        let month = try #require(make((1...15).map { log(3_000, at: utc(2026, 9, $0)) }, month: 20260901))
        #expect(month.average == 1_500)
        #expect(month.total == 45_000)
    }

    @Test func theTotalCountsTodaysWaterAndSaturates() throws {
        let month = try #require(make([log(Int.max, at: utc(2026, 10, 2)), log(250, at: utc(2026, 10, 22, 9))]))
        #expect(month.days[1].summary.total == DataManager.maximumDailyIntake, "a corrupt row is one full day, never a trap")
        #expect(month.total == DataManager.maximumDailyIntake + 250, "today's water is in the total before today counts")
    }

    /// Review Focus 1, plan M5: a pour stamped ahead of the phone's clock lands on a day still to come,
    /// and counts nowhere until that day comes.
    @Test func aServingStampedAfterTodayCountsNowhere() throws {
        let month = try #require(make([log(500, at: utc(2026, 10, 25))]))
        #expect(month.total == 0)
        #expect(month.days.first { $0.summary.dayOrdinal == 20261025 }?.canOpen == false)
    }

    @Test func theChangeComparesTheAverageWithTheMonthBefore() throws {
        let september = (1...30).map { log(2_000, at: utc(2026, 9, $0)) }
        #expect(try #require(make(september + october(1...21, 2_240))).change == 240)
        #expect(try #require(make(september + october(1...21, 1_900))).change == -100)
        #expect(try #require(make(september + october(1...21, 2_000))).change == 0)
    }

    @Test func thereIsNoChangeWithoutAMonthBefore() throws {
        #expect(try #require(make(october(1...21, 2_000), first: utc(2026, 10, 1))).change == nil)
    }

    @Test func raisingTheGoalRejudgesEveryDay() throws {
        let rows = october(1...21, 2_500)
        #expect(try #require(make(rows, goal: 2_000)).daysMet == 21)
        #expect(try #require(make(rows, goal: 3_000)).daysMet == 0)
    }

    @Test func aDayTellsItsRingWhatToDraw() throws {
        let month = try #require(make([log(1_500, at: utc(2026, 10, 5)), log(4_500, at: utc(2026, 10, 6))]))
        #expect(month.days[4].fraction == 0.5)
        #expect(!month.days[4].isMet)
        #expect(month.days[5].fraction == 1, "the arc closes at the goal and goes no further")
        #expect(month.days[5].isMet)
        #expect(month.days[21].isToday)
        #expect(month.days.filter(\.isToday).count == 1)
    }

    // MARK: The neighbours

    @Test func theArrowsStopAtTheFirstServingAndAtThisMonth() throws {
        let first = utc(2026, 8, 10)
        let october = try #require(make([], first: first))
        #expect(october.earlier?.firstDay == 20260901)
        #expect(october.later == nil)

        let august = try #require(make([], month: 20260801, first: first))
        #expect(august.earlier == nil)
        #expect(august.later?.firstDay == 20260901)
        #expect(august.later?.start == utc(2026, 9, 1, 0))
    }

    // MARK: The calendar's edges

    @Test func theLastMinuteAndTheFirstFallInTheirOwnMonths() throws {
        let rows = [log(400, at: utc(2026, 10, 31, 23, 59)), log(600, at: utc(2026, 11, 1, 0, 1))]
        let now = utc(2026, 11, 5)
        #expect(try #require(make(rows, now: now)).total == 400)
        #expect(try #require(make(rows, month: 20261101, now: now)).total == 600)
    }

    /// Review Focus 4: 00:30 on 1 October in Paris is 23:30 on 30 September in London. A serving
    /// follows its instant into whichever month the zone puts it in — the cost of recording an instant
    /// and not a day (`theSameInstantsRegroupUnderAWestwardTimeZone`, rule `30-rollover`).
    @Test func aServingAtTheMonthsEdgeRegroupsWithTheZone() throws {
        let paris = gregorian(in: "Europe/Paris")
        let london = gregorian(in: "Europe/London")
        let instant = paris.date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 0, minute: 30))!
        let rows = [log(500, at: instant)]
        let now = utc(2026, 10, 22)

        #expect(try #require(make(rows, first: instant, now: now, calendar: paris)).total == 500)
        #expect(try #require(make(rows, first: instant, now: now, calendar: london)).total == 0)
        #expect(try #require(make(rows, month: 20260901, first: instant, now: now, calendar: london)).total == 500)
    }
}
```

- [ ] **Step 2: A stub**, inserted with `Edit` before `// MARK: - Read-only snapshot` in
  `WaterBuddy/DataManager.swift` — the declarations of Step 4 with every body answering nothing:
  `firstDay(ofMonthHolding:in:)` returns `0`, `interval(of:in:)` and `firstDay(of:movedBy:in:)` return
  `nil`, `days(of:in:)` returns `[]`, `make(…)` returns `nil`.
- [ ] **Step 3: RED.** `UNIT -only-testing:WaterBuddyTests/MonthHistoryTests` (log `t3-red`). Expected:
  every test but `anOrdinalThatNamesNoMonthIsNothing` fails (that one passes on the stub — first seen
  green, ledgered).
- [ ] **Step 4: The value**, replacing the stub:

```swift
// MARK: - A month

/// One month of the user's water, as History's Month view draws it (spec
/// `2026-10-22-month-view-design.md` §3.5, §3.7).
///
/// **At file scope in this file, for ``DaySummary``'s reason.** ``DataManager`` publishes it, and every
/// target that compiles `DataManager.swift` — the widget extension and both watch targets beside the
/// app — must see the type, though only the app draws it. It is derived on every read and stored
/// nowhere.
///
/// **Every day is judged against the goal handed in** — the current one, because no past goal is
/// recorded (``DaySummary``'s ruling). History says so under the grid.
///
/// **Which days count is the streak's rule, a month wide.** A past month counts every day; this month
/// the days before today, and today once it has reached the goal, so a morning never reads *17 / 21*;
/// the first month counts from the day of the first serving, so an install on the 15th is not averaged
/// over fourteen empty days. A day still to come counts in nothing, the total included (plan M5).
nonisolated struct MonthHistory: Sendable, Equatable {

    /// One day of the month, with what History draws for it worked out here — the view judges
    /// nothing against the goal (rule `50-views`).
    nonisolated struct Day: Sendable, Equatable {
        let summary: DaySummary
        /// Whether it counts toward the month's figures.
        let isCounted: Bool
        /// Whether History may open it: on or after the first serving's day, and not after today.
        let canOpen: Bool
        let isToday: Bool
        /// Whether its water reached the goal.
        let isMet: Bool
        /// Its ring's arc — a drawing fraction, clamped to `0...1`, the one place a `Double` may stand
        /// for water.
        let fraction: Double
    }

    /// A neighbouring month: the ordinal of its 1st, and its first instant **for formatting an arrow's
    /// label and nothing else**, as ``DaySummary/date`` is (plan M2).
    nonisolated struct Neighbour: Sendable, Equatable {
        let firstDay: Int
        let start: Date
    }

    /// The month's name: the ordinal of its 1st (``DataManager/dayOrdinal(for:in:)``).
    let firstDay: Int

    /// The weekday of its 1st on the model's calendar, `1` for Sunday. History lays it under the app's
    /// own first weekday (`HistoryView.monthGrid(dayCount:weekdayOfFirst:firstWeekday:)`).
    let weekdayOfFirst: Int

    /// Every day of the month, the 1st first.
    let days: [Day]

    let daysMet: Int
    let daysCounted: Int

    /// The longest run of met days inside the month. A run does not carry over from the month before.
    let bestRun: Int

    /// Every millilitre logged in the month up to today, today's included.
    let total: Int

    /// The counted days' water over the counted days, `nil` when none counts.
    let average: Int?

    /// ``average`` less the month before's, worked out the same way; `nil` when either has no
    /// counted day.
    let change: Int?

    /// The month before, while the first serving is earlier than this month; the month after, while
    /// this one is before the month holding today.
    let earlier: Neighbour?
    let later: Neighbour?
}

extension MonthHistory {

    /// The ordinal of the 1st of the month holding `instant`: its day's ordinal with the day set to
    /// the 1st, the one day representation (rule `30-rollover`).
    nonisolated static func firstDay(ofMonthHolding instant: Date, in calendar: Calendar) -> Int {
        DataManager.dayOrdinal(for: instant, in: calendar) / 100 * 100 + 1
    }

    /// The month whose 1st is `firstDay`, as the calendar's own interval of it — however long its days
    /// are. Found from noon on the 1st, which every zone has; a midnight a zone skips does not move it.
    /// `nil` for an ordinal that names no month.
    nonisolated static func interval(of firstDay: Int, in calendar: Calendar) -> DateInterval? {
        let month = (firstDay / 100) % 100
        guard (1...12).contains(month),
              let noon = calendar.date(from: DateComponents(year: firstDay / 10_000, month: month, day: 1, hour: 12))
        else { return nil }
        return calendar.dateInterval(of: .month, for: noon)
    }

    /// The 1st of the month `offset` months from `firstDay`'s, or `nil`.
    nonisolated static func firstDay(of firstDay: Int, movedBy offset: Int, in calendar: Calendar) -> Int? {
        guard let start = interval(of: firstDay, in: calendar)?.start,
              let moved = calendar.date(byAdding: .month, value: offset, to: start)
        else { return nil }
        return Self.firstDay(ofMonthHolding: moved, in: calendar)
    }

    /// Every day of the month whose 1st is `firstDay`, the 1st first, as its ordinal and its start —
    /// walked with `date(byAdding: .day, …)`, never by 86,400 seconds, so a DST month keeps every day
    /// (rule `30-rollover`). Empty for an ordinal that names no month.
    nonisolated static func days(of firstDay: Int, in calendar: Calendar) -> [(ordinal: Int, date: Date)] {
        guard let month = interval(of: firstDay, in: calendar) else { return [] }
        var days: [(ordinal: Int, date: Date)] = []
        var offset = 0
        while offset < 31, let date = calendar.date(byAdding: .day, value: offset, to: month.start), date < month.end {
            days.append((DataManager.dayOrdinal(for: date, in: calendar), calendar.startOfDay(for: date)))
            offset += 1
        }
        return days
    }

    /// The month whose 1st is `firstDay`, worked out from `rows` — which may reach outside it; the
    /// month before's are what ``change`` compares with — the instant of the first serving ever
    /// recorded, the current `goal`, `now` and the calendar. `nil` for an ordinal that names no month.
    nonisolated static func make(
        rows: [WaterLog],
        month firstDay: Int,
        firstServing: Date?,
        goal: Int,
        now: Date,
        calendar: Calendar
    ) -> MonthHistory? {
        let walked = days(of: firstDay, in: calendar)
        guard let opening = walked.first else { return nil }

        let totals = dayTotals(of: rows, in: calendar)
        let today = DataManager.dayOrdinal(for: now, in: calendar)
        let first = firstServing.map { DataManager.dayOrdinal(for: $0, in: calendar) }
        // At least 1, as the `dailyGoal` setter clamps it, so an arc never divides by zero.
        let judged = max(goal, 1)

        let days = summaries(of: walked, totals: totals).map { summary in
            Day(
                summary: summary,
                isCounted: counts(summary, first: first, today: today, goal: judged),
                canOpen: first.map { summary.dayOrdinal >= $0 && summary.dayOrdinal <= today } ?? false,
                isToday: summary.dayOrdinal == today,
                isMet: summary.reached(judged),
                fraction: min(max(Double(summary.total) / Double(judged), 0), 1)
            )
        }
        let counted = days.filter(\.isCounted).map(\.summary)
        let average = counted.isEmpty ? nil : DaySummary.average(of: counted)

        var previous: Int?
        if let before = Self.firstDay(of: firstDay, movedBy: -1, in: calendar) {
            let countedBefore = summaries(of: Self.days(of: before, in: calendar), totals: totals)
                .filter { counts($0, first: first, today: today, goal: judged) }
            previous = countedBefore.isEmpty ? nil : DaySummary.average(of: countedBefore)
        }
        var change: Int?
        if let average, let previous { change = average - previous }

        let firstMonth = first.map { $0 / 100 * 100 + 1 }
        return MonthHistory(
            firstDay: firstDay,
            weekdayOfFirst: calendar.component(.weekday, from: opening.date),
            days: days,
            daysMet: counted.filter { $0.reached(judged) }.count,
            daysCounted: counted.count,
            bestRun: longestRun(of: counted, goal: judged),
            total: saturatedSum(days.filter { $0.summary.dayOrdinal <= today }.map(\.summary.total)),
            average: average,
            change: change,
            earlier: neighbour(of: firstDay, by: -1, exists: firstMonth.map { $0 < firstDay } ?? false, in: calendar),
            later: neighbour(of: firstDay, by: 1, exists: firstDay < Self.firstDay(ofMonthHolding: now, in: calendar), in: calendar)
        )
    }

    /// Each day's water, bucketed by its instant's day on `calendar` and saturated at
    /// ``DataManager/maximumDailyIntake`` — ``DaySummary/series(from:days:endingOn:in:)``'s bucketing.
    nonisolated private static func dayTotals(of rows: [WaterLog], in calendar: Calendar) -> [Int: Int] {
        var totals: [Int: Int] = [:]
        for row in rows {
            let ordinal = DataManager.dayOrdinal(for: row.timestamp, in: calendar)
            // Saturate rather than overflow: a corrupt `Int.max` row would trap a plain `+` (rule `20-state`).
            let (sum, overflowed) = (totals[ordinal] ?? 0).addingReportingOverflow(row.amount)
            totals[ordinal] = overflowed ? DataManager.maximumDailyIntake : min(sum, DataManager.maximumDailyIntake)
        }
        return totals
    }

    nonisolated private static func summaries(of days: [(ordinal: Int, date: Date)], totals: [Int: Int]) -> [DaySummary] {
        days.map { DaySummary(dayOrdinal: $0.ordinal, total: totals[$0.ordinal] ?? 0, date: $0.date) }
    }

    /// Spec §3.5's rule: on or after the first serving's day, and before today — or today, once it has
    /// reached the goal.
    nonisolated private static func counts(_ day: DaySummary, first: Int?, today: Int, goal: Int) -> Bool {
        guard let first, day.dayOrdinal >= first, day.dayOrdinal <= today else { return false }
        return day.dayOrdinal < today || day.reached(goal)
    }

    nonisolated private static func longestRun(of days: [DaySummary], goal: Int) -> Int {
        var best = 0
        var run = 0
        for day in days {
            run = day.reached(goal) ? run + 1 : 0
            best = max(best, run)
        }
        return best
    }

    nonisolated private static func saturatedSum(_ values: [Int]) -> Int {
        values.reduce(0) { running, value in
            let (sum, overflowed) = running.addingReportingOverflow(value)
            return overflowed ? Int.max : sum
        }
    }

    nonisolated private static func neighbour(of firstDay: Int, by offset: Int, exists: Bool, in calendar: Calendar) -> Neighbour? {
        guard exists,
              let moved = Self.firstDay(of: firstDay, movedBy: offset, in: calendar),
              let start = interval(of: moved, in: calendar)?.start
        else { return nil }
        return Neighbour(firstDay: moved, start: start)
    }
}
```

- [ ] **Step 5: GREEN.** `UNIT -only-testing:WaterBuddyTests/MonthHistoryTests -only-testing:WaterBuddyTests/DaySummaryTests`
  (log `t3-green`): 22 passed, and `DaySummaryTests` unchanged.
- [ ] **Step 6:** stage `WaterBuddy/DataManager.swift WaterBuddyTests/MonthHistoryTests.swift`. Ledger.

---

### Task 4: The model publishes a month

**Files:**
- Modify: `WaterBuddy/DataManager.swift` — the stored state (after `storedStreak`), the published
  properties (after `streak`), the `dailyGoal` setter, `dayDidTurn()`, `refresh()`,
  `saveAndRecompute()`, and three new methods after `republishStreak()`
- Test: `WaterBuddyTests/MonthHistoryTests.swift` (`MonthPublishingTests`)

**Interfaces:**
- Consumes: `MonthHistory.make(…)`, `MonthHistory.interval(of:in:)`, `MonthHistory.firstDay(of:movedBy:in:)`,
  `MonthHistory.firstDay(ofMonthHolding:in:)` (Task 3)
- Produces: `DataManager.month: MonthHistory?`, `DataManager.monthLogs: [Int: [WaterLog]]`,
  `DataManager.thisMonth: Int`, `DataManager.showMonth(_ firstDay: Int?)`

- [ ] **Step 1: The tests.** Append to `WaterBuddyTests/MonthHistoryTests.swift`:

```swift
// MARK: - Publishing

private final class Counter: @unchecked Sendable {
    var count = 0
}

/// A `DataManager` over a throwaway suite and an in-memory store — or `container`, for the failed read —
/// with every side effect injected away (rule `85-testing`).
@MainActor
private func withMonthStore<T>(
    now: @escaping () -> Date,
    container: ModelContainer? = nil,
    _ body: (DataManager) throws -> T
) throws -> T {
    let name = "test.waterbuddy.month.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    let manager = DataManager(
        defaults: defaults,
        modelContainer: try container ?? ModelContainer(
            for: WaterLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ),
        calendar: utcDay,
        now: now,
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
    return try body(manager)
}

/// One suite and one store two managers share — the app and `AddWaterIntent`'s instance.
@MainActor
private func withSharedMonthStore<T>(_ body: (UserDefaults, ModelContainer) throws -> T) throws -> T {
    let name = "test.waterbuddy.month.shared.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    let container = try ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    defer {
        defaults.removePersistentDomain(forName: name)
        UserDefaults.standard.removeSuite(named: name)
    }
    return try body(defaults, container)
}

@MainActor
private func makeMonthManager(_ defaults: UserDefaults, container: ModelContainer, now: @escaping () -> Date) -> DataManager {
    DataManager(
        defaults: defaults,
        modelContainer: container,
        calendar: utcDay,
        now: now,
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
}

/// The month as `DataManager` publishes it (spec §3.7): only while History has asked for one, from
/// every site that changes what it draws, and never from a failed read.
@MainActor
struct MonthPublishingTests {

    @Test func nothingIsPublishedUntilHistoryAsksForAMonth() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 5))
            #expect(manager.month == nil)
            #expect(manager.monthLogs.isEmpty)
        }
    }

    @Test func askingForAMonthPublishesItAndItsRows() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 5, 9))
            manager.addLog(amount: 250, at: utc(2026, 10, 5, 15))
            manager.addLog(amount: 750, at: utc(2026, 9, 30))

            manager.showMonth(manager.thisMonth)

            let month = try #require(manager.month)
            #expect(month.firstDay == 20261001)
            #expect(month.days[4].summary.total == 750)
            #expect(manager.monthLogs[20261005]?.map(\.amount) == [250, 500], "newest first")
            #expect(manager.monthLogs[20260930] == nil, "the month before is read for the change, never published")
        }
    }

    @Test func askingForNoMonthClearsBoth() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 5))
            manager.showMonth(manager.thisMonth)

            manager.showMonth(nil)

            #expect(manager.month == nil)
            #expect(manager.monthLogs.isEmpty)
        }
    }

    /// Review Focus 5.
    @Test func aMonthThatNamesNoMonthPublishesNothing() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 5))
            manager.showMonth(20261301)
            #expect(manager.month == nil)
            #expect(manager.monthLogs.isEmpty)
        }
    }

    @Test func aPourWhileAMonthIsShownRepublishesIt() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.showMonth(manager.thisMonth)
            let counter = Counter()
            withObservationTracking { _ = manager.month } onChange: { counter.count += 1 }

            manager.addLog(amount: 3_000)

            #expect(counter.count == 1, "a month that never redraws is the whole hazard")
            #expect(manager.month?.days[21].summary.total == 3_000)
            #expect(manager.monthLogs[20261022]?.count == 1)
        }
    }

    /// `month` is a value, so it may carry `history`'s equality guard; `refresh()` runs on every
    /// foreground, and an unguarded republish would redraw the month for nothing.
    @Test func aRefreshThatChangesNothingDoesNotChurnTheMonth() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 250)
            manager.showMonth(manager.thisMonth)
            let counter = Counter()
            withObservationTracking { _ = manager.month } onChange: { counter.count += 1 }

            manager.refresh()

            #expect(counter.count == 0, "nothing moved, so nothing should redraw")
        }
    }

    /// A failed read is not an empty month (rule `20-state`).
    @Test func aFailedReadLeavesTheMonthAsItStands() throws {
        let store = try UnreadableStore()
        defer { store.remove() }
        try withMonthStore(now: { thursday22 }, container: store.container) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 5))
            manager.showMonth(manager.thisMonth)
            let before = try #require(manager.month, "the store must be healthy before it is broken")

            try store.breakReads()
            #expect(!store.stillReads, "the store must be unreadable before anything is asserted about a failed read")
            manager.refresh()

            #expect(manager.month == before)
            #expect(manager.monthLogs[20261005]?.count == 1)
        }
    }

    /// Review Focus 3.
    @Test func aMonthEndingOnScreenStaysShownAndBecomesPast() throws {
        var clock = utc(2026, 10, 31, 22)
        try withMonthStore(now: { clock }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 10, 1))
            manager.showMonth(manager.thisMonth)
            #expect(manager.month?.later == nil)

            clock = utc(2026, 11, 1, 0, 30)
            manager.dayDidTurn()

            let month = try #require(manager.month)
            #expect(month.firstDay == 20261001)
            #expect(month.later?.firstDay == 20261101)
            #expect(month.daysCounted == 31)
            #expect(!month.days.contains { $0.isToday })
        }
    }

    @Test func aGoalChangeRejudgesTheShownMonth() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 2_500, at: utc(2026, 10, 5))
            manager.dailyGoal = 3_000
            manager.showMonth(manager.thisMonth)
            #expect(manager.month?.daysMet == 0)

            manager.dailyGoal = 2_000

            #expect(manager.month?.daysMet == 1)
        }
    }

    @Test func aSecondInstancesServingIsPickedUpByARefresh() throws {
        try withSharedMonthStore { defaults, container in
            let app = makeMonthManager(defaults, container: container, now: { thursday22 })
            let widget = makeMonthManager(defaults, container: container, now: { thursday22 })
            app.showMonth(app.thisMonth)

            widget.addLog(amount: 250)
            app.refresh()

            #expect(app.month?.days[21].summary.total == 250)
        }
    }

    @Test func thisMonthFollowsTheClock() throws {
        var clock = thursday22
        try withMonthStore(now: { clock }) { manager in
            #expect(manager.thisMonth == 20261001)
            clock = utc(2027, 1, 3)
            #expect(manager.thisMonth == 20270101)
        }
    }

    /// Review Focus 2.
    @Test func deletingTheFirstServingMovesTheEarliestBound() throws {
        try withMonthStore(now: { thursday22 }) { manager in
            manager.addLog(amount: 500, at: utc(2026, 9, 10))
            manager.addLog(amount: 500, at: utc(2026, 10, 5))
            manager.showMonth(manager.thisMonth)
            #expect(manager.month?.earlier?.firstDay == 20260901)

            // `allLogs()` is newest first: its last row is September's.
            manager.deleteLog(try #require(manager.allLogs().last))

            #expect(manager.month?.earlier == nil)
            #expect(manager.month?.days[4].isCounted == true, "the 5th is the first serving now")
            #expect(manager.month?.days[3].canOpen == false)
        }
    }
}
```

- [ ] **Step 2: A stub.** In `DataManager`, after the `streak` property:

```swift
    var month: MonthHistory? { nil }
    var monthLogs: [Int: [WaterLog]] { [:] }
    var thisMonth: Int { 0 }
    func showMonth(_ firstDay: Int?) {}
```

- [ ] **Step 3: RED.** `UNIT -only-testing:WaterBuddyTests/MonthPublishingTests` (log `t4-red`). Expected:
  `askingForAMonthPublishesItAndItsRows`, `aPourWhileAMonthIsShownRepublishesIt`,
  `aFailedReadLeavesTheMonthAsItStands`, `aMonthEndingOnScreenStaysShownAndBecomesPast`,
  `aGoalChangeRejudgesTheShownMonth`, `aSecondInstancesServingIsPickedUpByARefresh`,
  `thisMonthFollowsTheClock` and `deletingTheFirstServingMovesTheEarliestBound` fail; the other four
  pass on the stub (first seen green, ledgered — they guard what must stay quiet).
- [ ] **Step 4: The model.** Replace the stub's four lines with the published properties; then each
  `Edit` below.
  - After `@ObservationIgnored private var storedStreak = 0`:

```swift
    @ObservationIgnored private var storedMonth: MonthHistory?
    @ObservationIgnored private var storedMonthLogs: [Int: [WaterLog]] = [:]

    /// The month History has asked for (``showMonth(_:)``), as the ordinal of its 1st — `nil` for none.
    /// Not observed: what is drawn is ``month``.
    @ObservationIgnored private var wantedMonth: Int?
```

  - After the `streak` property, in place of the stub:

```swift
    /// The month History's Month view shows, or `nil` while none is asked for (``showMonth(_:)``).
    ///
    /// Derived, never stored: ``MonthHistory/make(rows:month:firstServing:goal:now:calendar:)`` over
    /// the rows, republished from every site that can change what it draws — a mutation, a refresh, the
    /// day turning, the goal moving — and only while a month is asked for, so a user who never opens
    /// it pays nothing (spec `2026-10-22-month-view-design.md` §3.7).
    ///
    /// **Equality-guarded**, like ``history``: a value that did not move redraws nothing, and
    /// ``refresh()`` runs on every foreground. **A failed read leaves it as it stands.** `nil` wherever
    /// ``role`` does not draw history. Read-only — a consequence of the rows, never an input.
    var month: MonthHistory? {
        access(keyPath: \.month)
        return storedMonth
    }

    /// The shown month's servings by day ordinal, newest first within each day — what History lists
    /// for a day the month has opened, read-only.
    ///
    /// **Published from the fetch ``month`` is worked out from**, as ``historyLogs`` is from
    /// ``history``'s. **No equality guard**, for ``historyLogs``' reason: a `[WaterLog]` compares by
    /// `persistentModelID`, so the rows after an edit equal the rows before it. Empty while no month is
    /// shown, and wherever ``role`` does not draw history.
    var monthLogs: [Int: [WaterLog]] {
        access(keyPath: \.monthLogs)
        return storedMonthLogs
    }

    /// The ordinal of the 1st of this month, on this model's clock and calendar — what History asks for
    /// when Month is chosen. Worked out on read and stored nowhere.
    var thisMonth: Int {
        MonthHistory.firstDay(ofMonthHolding: now(), in: calendar)
    }
```

  - After `republishStreak()`'s closing brace:

```swift
    /// Asks for the month whose 1st is `firstDay`, or for none.
    ///
    /// History's one call into the month (spec §3.8): when Month is chosen, when an arrow is tapped, and
    /// with `nil` when Week is chosen, the page is left or Premium stops being held. **It writes neither
    /// store**, rings no doorbell and reschedules nothing — a read, like ``refresh()``, not a mutation.
    /// With `nil` both properties go quiet, so a later Month never draws a stale month first.
    func showMonth(_ firstDay: Int?) {
        wantedMonth = firstDay
        guard firstDay != nil else {
            if storedMonth != nil {
                withMutation(keyPath: \.month) { storedMonth = nil }
            }
            if !storedMonthLogs.isEmpty {
                withMutation(keyPath: \.monthLogs) { storedMonthLogs = [:] }
            }
            return
        }
        republishMonth()
    }

    /// Republishes the wanted month's rows to ``monthLogs``, then works the month out from the same
    /// rows and publishes it if it moved.
    ///
    /// **Two reads**: the store's one range query (``readLogs(from:to:)``), from the 1st of the month
    /// before — whose average ``MonthHistory/change`` compares with — to the end of the wanted one; and
    /// the first serving ever (``readOldestLog()``). **Either failing returns** and leaves both
    /// properties as they stand: an empty month is indistinguishable from a user who never drank.
    ///
    /// Behind `role.drawsHistory` for ``republishHistory()``'s reason — cost, not correctness — and a
    /// no-op while no month is wanted.
    private func republishMonth() {
        guard Self.role.drawsHistory, let wanted = wantedMonth else { return }
        guard let shown = MonthHistory.interval(of: wanted, in: calendar),
              let before = MonthHistory.firstDay(of: wanted, movedBy: -1, in: calendar),
              let start = MonthHistory.interval(of: before, in: calendar)?.start,
              let rows = readLogs(from: start, to: shown.end),
              let oldest = readOldestLog(),
              let month = MonthHistory.make(
                  rows: rows,
                  month: wanted,
                  firstServing: oldest.first?.timestamp,
                  goal: storedDailyGoal,
                  now: now(),
                  calendar: calendar
              )
        else { return }

        // The month before's rows are read for the change and published nowhere.
        let days = Set(month.days.map(\.summary.dayOrdinal))
        withMutation(keyPath: \.monthLogs) {
            storedMonthLogs = Dictionary(grouping: rows.filter { days.contains(dayOrdinal(for: $0.timestamp)) }) {
                dayOrdinal(for: $0.timestamp)
            }
        }

        guard month != storedMonth else { return }
        withMutation(keyPath: \.month) { storedMonth = month }
    }

    /// The oldest serving in the store as a one-row read: `nil` when the store could not be read, empty
    /// when it holds none — never the same thing (``fetch(_:)``'s ruling). Its own descriptor because
    /// ``fetch(_:)`` sorts newest first (plan M10).
    private func readOldestLog() -> [WaterLog]? {
        var descriptor = FetchDescriptor<WaterLog>(sortBy: [SortDescriptor(\.timestamp, order: .forward)])
        descriptor.fetchLimit = 1
        descriptor.includePendingChanges = true
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            #if DEBUG
            // Names the condition, never the user's water (rule `75-diagnostics`).
            print("[WaterBuddy] Could not read the first serving; leaving the month as it stands.")
            #endif
            return nil
        }
    }
```

  - The `dailyGoal` setter — after its `republishStreak()`:

```swift
            // And for every day the shown month judges (spec §3.5).
            republishMonth()
```

  - `dayDidTurn()` — after `republishHistory()`:

```swift
        // A month that ends on screen stays shown, and turns past (spec §3.7).
        republishMonth()
```

  - `refresh()` — after `republishHistory()`, before the reminders' backstop comment:

```swift
        republishMonth()
```

  - `saveAndRecompute()` — after `recomputeTodayAndTheWeek()`:

```swift
        // Every path that changes a row ends here, so the shown month hears of each.
        republishMonth()
```

- [ ] **Step 5: GREEN.** `UNIT -only-testing:WaterBuddyTests/MonthPublishingTests -only-testing:WaterBuddyTests/MonthHistoryTests -only-testing:WaterBuddyTests/HistoryWindowTests -only-testing:WaterBuddyTests/StreakRecountTests`
  (log `t4-green`): every test passes.
- [ ] **Step 6: The cost, measured on the code.** In a copy of the index
  (`git checkout-index -a --prefix="$SCRATCH/cost/"`), Task 1's `ProbeTests` gains, inside
  `theReadsCost` after its `refresh` line:

```swift
        manager.showMonth(manager.thisMonth)
        let shown = median { manager.refresh() }
        let pour = median { manager.addLog(amount: 1) }
        manager.showMonth(nil)
        let pourWithout = median { manager.addLog(amount: 1) }
        print("PROBE shown days=\(days) refresh=\(refresh)ms withMonth=\(shown)ms pour=\(pourWithout)ms pourWithMonth=\(pour)ms")
```

  Run it as in Task 1, ledger the lines, remove the copy. Expected at 500 days: `withMonth − refresh`
  and `pourWithMonth − pour` each under **3 ms**. Over it, stop: the first fallback (spec §3.7) is
  ``readOldestLog()``'s answer held in memory and forgotten on every delete — re-planned with the
  owner, not built here.
- [ ] **Step 7:** stage `WaterBuddy/DataManager.swift WaterBuddyTests/MonthHistoryTests.swift`. Ledger.

---

### Task 5: History's decisions — the switch, the grid, the week's letters, the litres

**Files:**
- Modify: `WaterBuddy/HistoryView.swift` (statics, after `daySlot(across:count:)`)
- Test: `WaterBuddyTests/HistoryViewTests.swift` (`MonthLayoutTests`, appended)

**Interfaces — produces (all `nonisolated static` on `HistoryView`):**
- `offersMonth(status: PremiumAccess.Status?, offered: Bool) -> Bool`
- `monthGrid(dayCount: Int, weekdayOfFirst: Int, firstWeekday: Int) -> [[Int?]]`
- `firstWeekday(in: Locale) -> Int`
- `weekdayLetters(in: Locale) -> [String]`
- `litres(_ millilitres: Int, locale: Locale) -> String`

- [ ] **Step 1: The tests.** Append to `WaterBuddyTests/HistoryViewTests.swift`:

```swift
// MARK: - The month, as values

/// History's Month decisions, pinned without building a view (spec `2026-10-22-month-view-design.md`
/// §3.1, §3.3, §3.5). Not `@MainActor`: everything read here is `nonisolated` on purpose
/// (rule `43-concurrency`). The month's seven columns are the week card's ``DayRow`` slots, whose
/// 44-pt floor `everyDayClearsTheTapFloor(across:)` already holds.
struct MonthLayoutTests {

    @Test func theSwitchWaitsForTheFirstReadOfPurchases() {
        #expect(!HistoryView.offersMonth(status: nil, offered: true))
        #expect(!HistoryView.offersMonth(status: nil, offered: false))
    }

    @Test func aHolderKeepsTheMonthWhereThePaywallIsNotOffered() {
        #expect(HistoryView.offersMonth(status: .lifetime, offered: false))
        #expect(HistoryView.offersMonth(status: .monthly(until: .distantFuture), offered: true))
    }

    @Test func aFreeUserMeetsTheSwitchOnlyWhereThePaywallIs() {
        #expect(HistoryView.offersMonth(status: .free, offered: true))
        #expect(!HistoryView.offersMonth(status: .free, offered: false))
    }

    @Test func aMonthIsLaidUnderItsWeekdays() {
        // 1 October 2026 is a Thursday (5).
        let sundayFirst = HistoryView.monthGrid(dayCount: 31, weekdayOfFirst: 5, firstWeekday: 1)
        #expect(sundayFirst.count == 5)
        #expect(sundayFirst[0] == [nil, nil, nil, nil, 0, 1, 2])
        let mondayFirst = HistoryView.monthGrid(dayCount: 31, weekdayOfFirst: 5, firstWeekday: 2)
        #expect(mondayFirst[0] == [nil, nil, nil, 0, 1, 2, 3])
        #expect(mondayFirst.last == [25, 26, 27, 28, 29, 30, nil])
    }

    @Test func aMonthTakesFourToSixWeeks() {
        // February 2026 starts on a Sunday, August 2026 on a Saturday, September 2026 on a Tuesday.
        #expect(HistoryView.monthGrid(dayCount: 28, weekdayOfFirst: 1, firstWeekday: 1).count == 4)
        #expect(HistoryView.monthGrid(dayCount: 31, weekdayOfFirst: 7, firstWeekday: 1).count == 6)
        #expect(HistoryView.monthGrid(dayCount: 30, weekdayOfFirst: 3, firstWeekday: 1).count == 5)
    }

    @Test(arguments: [(28, 1), (29, 4), (30, 3), (31, 7)])
    func everyDayStandsOnceAndInOrder(dayCount: Int, weekdayOfFirst: Int) {
        for firstWeekday in 1...7 {
            let weeks = HistoryView.monthGrid(dayCount: dayCount, weekdayOfFirst: weekdayOfFirst, firstWeekday: firstWeekday)
            #expect(weeks.allSatisfy { $0.count == 7 })
            #expect(weeks.flatMap { $0 }.compactMap { $0 } == Array(0..<dayCount))
        }
    }

    @Test func noDaysIsNoWeeks() {
        #expect(HistoryView.monthGrid(dayCount: 0, weekdayOfFirst: 1, firstWeekday: 1).isEmpty)
    }

    @Test func theWeekStartsOnTheLanguagesFirstDay() {
        #expect(HistoryView.firstWeekday(in: Locale(identifier: "en")) == 1)
        #expect(HistoryView.firstWeekday(in: Locale(identifier: "ru")) == 2)
        #expect(HistoryView.firstWeekday(in: Locale(identifier: "uz")) == 2)
    }

    @Test func theLettersFollowTheFirstDay() {
        #expect(HistoryView.weekdayLetters(in: Locale(identifier: "en")) == ["S", "M", "T", "W", "T", "F", "S"])
        let russian = HistoryView.weekdayLetters(in: Locale(identifier: "ru"))
        #expect(russian.count == 7)
        #expect(russian.first == "П", "Monday first, in Russian's own letter: \(russian)")
    }

    @Test func litresAreDrawnToOneDecimal() {
        #expect(HistoryView.litres(62_570, locale: Locale(identifier: "en")) == "62.6")
        #expect(HistoryView.litres(62_570, locale: Locale(identifier: "ru")) == "62,6")
        #expect(HistoryView.litres(0, locale: Locale(identifier: "en")) == "0.0")
        #expect(HistoryView.litres(1_234_500, locale: Locale(identifier: "en")) == "1,234.5")
    }
}
```

- [ ] **Step 2: A stub** after `daySlot(across:count:)`: the five signatures of Step 4, answering
  `false`, `[]`, `0`, `[]` and `""`.
- [ ] **Step 3: RED.** `UNIT -only-testing:WaterBuddyTests/MonthLayoutTests` (log `t5-red`). Expected:
  every test fails but `theSwitchWaitsForTheFirstReadOfPurchases` and `noDaysIsNoWeeks` (first seen
  green on the stub, ledgered).
- [ ] **Step 4: The decisions**, replacing the stub:

```swift
    /// Whether History draws its *Week · Month* switch (spec `2026-10-22-month-view-design.md` §3.1):
    /// never while the first StoreKit read is outstanding, so a holder never sees a locked month flash;
    /// always for a holder, who keeps the month even where the paywall is not offered; for a free user
    /// only where it is, so the locked month always has a paywall to open.
    nonisolated static func offersMonth(status: PremiumAccess.Status?, offered: Bool) -> Bool {
        guard let status else { return false }
        return status.isPremium || offered
    }

    /// The month's days laid into weeks of seven, `nil` where a week runs past either end: the 1st
    /// under its own weekday, counted from the locale's first (§3.3). The entries index
    /// ``MonthHistory/days``. `weekdayOfFirst` comes from the model's calendar, `firstWeekday` from the
    /// app's locale (``firstWeekday(in:)``) — a view holds no calendar of its own (rule `30-rollover`).
    nonisolated static func monthGrid(dayCount: Int, weekdayOfFirst: Int, firstWeekday: Int) -> [[Int?]] {
        guard dayCount > 0 else { return [] }
        let leading = ((weekdayOfFirst - firstWeekday) % 7 + 7) % 7
        var cells: [Int?] = Array(repeating: nil, count: leading) + (0..<dayCount).map { Optional($0) }
        cells += Array(repeating: nil, count: (7 - cells.count % 7) % 7)
        return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<($0 + 7)]) }
    }

    /// The locale's first weekday, `1` for Sunday: Sunday under US English, Monday under Russian and
    /// Uzbek, and the user's own *First Day of Week* under *Follow device*, which `firstDayOfWeek`
    /// honours. Never `Calendar.waterBuddyDay`'s, which is fixed to `en_US_POSIX` (§3.3).
    nonisolated static func firstWeekday(in locale: Locale) -> Int {
        let week: [Locale.Weekday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        return (week.firstIndex(of: locale.firstDayOfWeek) ?? 0) + 1
    }

    /// The grid's weekday letters in the locale's own script, from its first weekday.
    nonisolated static func weekdayLetters(in locale: Locale) -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        let letters = calendar.veryShortStandaloneWeekdaySymbols
        let first = firstWeekday(in: locale)
        return (0..<7).map { letters[(first - 1 + $0) % 7] }
    }

    /// Millilitres as litres to one decimal, through `Decimal` — never a `Double`, which may only be a
    /// drawing fraction (rule `20-state`) — in the app's locale: *62.6*, *62,6* (§3.5).
    nonisolated static func litres(_ millilitres: Int, locale: Locale) -> String {
        (Decimal(millilitres) / 1_000).formatted(.number.precision(.fractionLength(1)).locale(locale))
    }
```

- [ ] **Step 5: GREEN.** `UNIT -only-testing:WaterBuddyTests/MonthLayoutTests -only-testing:WaterBuddyTests/HistoryLayoutTests`
  (log `t5-green`): every test passes.
- [ ] **Step 6:** stage `WaterBuddy/HistoryView.swift WaterBuddyTests/HistoryViewTests.swift`. Ledger.

---

### Task 6: The words

**Files:**
- Modify: `WaterBuddy/Localizable.xcstrings` (20 keys) — **Xcode closed**
- Test: `WaterBuddyTests/LocalizationTests.swift` (`historyKeys`, `countedKeys`, `expected`)

- [ ] **Step 1: The tests.** In `WaterBuddyTests/LocalizationTests.swift`:
  - `historyKeys` gains, after its last entry, every key of Step 4's two tables (20 lines, in their
    order);
  - `countedKeys` gains, after `"%1$d servings"`'s entry:

```swift
    CountedKey(key: "%1$d of %2$d days", arity: 2, counted: [1], bundles: ["app"]),
    CountedKey(key: "%1$d of %2$d days on goal", arity: 2, counted: [1], bundles: ["app"]),
    CountedKey(key: "Average %1$d millilitres a day", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "Up %1$d millilitres on the month before", arity: 1, counted: [0], bundles: ["app"]),
    CountedKey(key: "Down %1$d millilitres on the month before", arity: 1, counted: [0], bundles: ["app"]),
```

  - `expected(_:_:_:_:)` gains, after the `"%1$d servings"` cases:

```swift
    case ("%1$d of %2$d days", "en"): return "\(f[0]) of \(f[1]) " + english(n[1], "day", "days")
    case ("%1$d of %2$d days", "ru"): return "\(f[0]) из \(f[1]) " + russian(n[1], "дня", "дней", "дней")
    case ("%1$d of %2$d days", "uz"): return "\(f[1]) kundan \(f[0])"

    case ("%1$d of %2$d days on goal", "en"): return "\(f[0]) of \(f[1]) " + english(n[1], "day", "days") + " on goal"
    case ("%1$d of %2$d days on goal", "ru"):
        return "Цель достигнута в \(f[0]) из \(f[1]) " + russian(n[1], "дня", "дней", "дней")
    case ("%1$d of %2$d days on goal", "uz"): return "\(f[1]) kundan \(f[0]) kunida maqsadga erishildi"

    case ("Average %1$d millilitres a day", "en"): return "Average \(f[0]) \(ml(0)) a day"
    case ("Average %1$d millilitres a day", "ru"): return "В среднем \(f[0]) \(mlRu(0)) в день"
    case ("Average %1$d millilitres a day", "uz"): return "Kuniga o‘rtacha \(f[0]) millilitr"

    case ("Up %1$d millilitres on the month before", "en"): return "Up \(f[0]) \(ml(0)) on the month before"
    case ("Up %1$d millilitres on the month before", "ru"): return "На \(f[0]) \(mlRu(0)) больше, чем в предыдущем месяце"
    case ("Up %1$d millilitres on the month before", "uz"): return "Oldingi oydan \(f[0]) millilitr ko‘p"

    case ("Down %1$d millilitres on the month before", "en"): return "Down \(f[0]) \(ml(0)) on the month before"
    case ("Down %1$d millilitres on the month before", "ru"): return "На \(f[0]) \(mlRu(0)) меньше, чем в предыдущем месяце"
    case ("Down %1$d millilitres on the month before", "uz"): return "Oldingi oydan \(f[0]) millilitr kam"
```

- [ ] **Step 2: RED.** `UNIT -only-testing:WaterBuddyTests/HistoryStringTests -only-testing:WaterBuddyTests/PluralFormTests`
  (log `t6-red`), the catalogue untouched. Expected: `HistoryStringTests` fails in every language on the
  20 keys; `PluralFormTests` fails on the five counted keys.
- [ ] **Step 3: Xcode closed.** `pgrep -x Xcode` prints nothing; if it prints a pid, ask the owner to
  quit Xcode and wait.
- [ ] **Step 4: The catalogue.** Each key of the first table becomes one entry in the file's own shape —

```json
    "<key>" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "translated", "value" : "<en>" } },
        "ru" : { "stringUnit" : { "state" : "translated", "value" : "<ru>" } },
        "uz" : { "stringUnit" : { "state" : "translated", "value" : "<uz>" } }
      }
    },
```

  — written out with the file's own line breaks, spacing and indentation (as the `"Goal met"` entry
  reads), inserted with `Edit` in the file's key order. `en` is the key.

| Key | `ru` | `uz` |
|---|---|---|
| `Month` | `Месяц` | `Oy` |
| `Part of it` | `Частично` | `Qisman` |
| `Days on goal` | `Дни с целью` | `Maqsadli kunlar` |
| `Best streak` | `Лучшая серия` | `Eng uzun seriya` |
| `This month` | `За месяц` | `Shu oy` |
| `%1$@/%2$@` | `%1$@/%2$@` | `%1$@/%2$@` |
| `%1$@ L` | `%1$@ л` | `%1$@ l` |
| `Average %1$@ ml a day` | `В среднем %1$@ мл в день` | `Kuniga o‘rtacha %1$@ ml` |
| `Up %1$@ ml on the month before` | `На %1$@ мл больше, чем в предыдущем месяце` | `Oldingi oydan %1$@ ml ko‘p` |
| `Down %1$@ ml on the month before` | `На %1$@ мл меньше, чем в предыдущем месяце` | `Oldingi oydan %1$@ ml kam` |
| `The same as the month before` | `Столько же, сколько в предыдущем месяце` | `Oldingi oy bilan bir xil` |
| `Your whole month at a glance` | `Весь месяц на одном экране` | `Butun oyingiz bir qarashda` |
| `Every day you have logged is kept. Premium shows it as months, with your patterns and a recap.` | `Каждый записанный день сохраняется. Premium показывает их по месяцам — с вашими привычками и итогами.` | `Yozilgan har bir kun saqlanadi. Premium ularni oylar bo‘yicha, odatlaringiz va xulosa bilan ko‘rsatadi.` |
| `Back to this week` | `Назад к этой неделе` | `Shu haftaga qaytish` |
| `The week, today and every serving stay free. Nothing you logged is ever hidden or deleted.` | `Неделя, сегодняшний день и каждая порция остаются бесплатными. Ничто из записанного не скрывается и не удаляется.` | `Hafta, bugungi kun va har bir porsiya bepul qoladi. Yozganlaringizdan hech narsa yashirilmaydi va o‘chirilmaydi.` |

  The five counted keys take plural variations — `one` and `other` in English; `one`, `few`, `many` and
  `other` in Russian, `other` the genitive singular (rule `70-privacy`); Uzbek one value. A key whose
  count is its **second** argument takes the shape `"%1$d of %2$d millilitres"` already has — a
  `%#@arg2@` substitution with `"argNum" : 2` and `"formatSpecifier" : "d"` — copied from that entry
  and changed only in its words:

| Key | `en` | `ru` | `uz` |
|---|---|---|---|
| `%1$d of %2$d days` | `%1$d of %#@arg2@` — one `%arg day`, other `%arg days` | `%1$d из %#@arg2@` — one `%arg дня`, few `%arg дней`, many `%arg дней`, other `%arg дня` | `%2$d kundan %1$d` |
| `%1$d of %2$d days on goal` | `%1$d of %#@arg2@ on goal` — one `%arg day`, other `%arg days` | `Цель достигнута в %1$d из %#@arg2@` — as above | `%2$d kundan %1$d kunida maqsadga erishildi` |
| `Average %1$d millilitres a day` | one `Average %1$d millilitre a day`, other `Average %1$d millilitres a day` | one `В среднем %1$d миллилитр в день`, few `В среднем %1$d миллилитра в день`, many `В среднем %1$d миллилитров в день`, other `В среднем %1$d миллилитра в день` | `Kuniga o‘rtacha %1$d millilitr` |
| `Up %1$d millilitres on the month before` | one `Up %1$d millilitre on the month before`, other `Up %1$d millilitres on the month before` | one `На %1$d миллилитр больше, чем в предыдущем месяце`, few `На %1$d миллилитра больше, …`, many `На %1$d миллилитров больше, …`, other `На %1$d миллилитра больше, …` | `Oldingi oydan %1$d millilitr ko‘p` |
| `Down %1$d millilitres on the month before` | as *Up*, with `Down` | as *Up*, with `меньше` for `больше` | `Oldingi oydan %1$d millilitr kam` |

  (In the Russian *Up* and *Down* rows, `…` stands for the same `чем в предыдущем месяце` every form
  ends with — written out whole in the file.) A single-argument key takes the shape `"%1$d days"`
  already has — `variations.plural` directly under the language.

  `python3 -I -c "import json;json.load(open('WaterBuddy/Localizable.xcstrings'))"` prints nothing, and
  the key count is 167 + 20 = **187** (a read-only `python3` count).
- [ ] **Step 5: GREEN.** `UNIT -only-testing:WaterBuddyTests/HistoryStringTests -only-testing:WaterBuddyTests/PluralFormTests -only-testing:WaterBuddyTests/LocalizationTests`
  (log `t6-green`): every test passes.
- [ ] **Step 6:** stage `WaterBuddy/Localizable.xcstrings WaterBuddyTests/LocalizationTests.swift`. Ledger.

---

### Task 7: The screen — the switch, the month, the locked month

**Files:**
- Modify: `WaterBuddy/PaywallView.swift` (`Entry`)
- Modify: `WaterBuddy/HistoryView.swift` (environment, state, `body`, the week's rows moved into
  `weekRows`, `monthRows`, the actions, `ServingRow`, six private types, the previews)
- Test: `WaterBuddyUITests/PremiumUITests.swift`

**Interfaces:**
- Consumes: `DataManager.month`, `.monthLogs`, `.thisMonth`, `.showMonth(_:)` (Task 4);
  `MonthHistory`, `.Day`, `.Neighbour` (Task 3); the five statics (Task 5); the keys (Task 6);
  `PremiumStore.state`, `PaywallView.isOfferedHere`, `\.pageIsShown`, `.premiumRim()`,
  `.primarySurface(in:)`, `LiquidGlass.Selection`, `DayRow`, `DayStrip`, `Motion.land`
- Produces: `PaywallView.Entry.history`

- [ ] **Step 1: The UI tests.** In `WaterBuddyUITests/PremiumUITests.swift`, after
  `testTheCardLeadsSettingsAndOpensThePaywall`:

```swift
    /// Step 2 (spec `2026-10-22-month-view-design.md` §6, plan M1): an ordinary run's History has no
    /// *Week · Month* switch.
    @MainActor
    func testAnOrdinaryRunsHistoryHasNoMonthSwitch() throws {
        let app = XCUIApplication()
        app.launch()
        completeWelcomeIfShown(app)

        app.buttons["History"].tap()
        XCTAssertTrue(app.buttons["Add a serving"].waitForExistence(timeout: 5))
        // The switch waits for the first StoreKit read; give it the time it would take to come.
        XCTAssertFalse(app.buttons["Month"].waitForExistence(timeout: 3),
                       "the switch showed in a run not launched to offer it")
    }

    /// A free user's Month is the locked month: *See Premium* opens the paywall and *Back to this week*
    /// returns to the week. A holder's month has no UI test (spec §6): holding Premium here would take
    /// a StoreKit testing purchase.
    @MainActor
    func testAFreeUsersMonthIsLockedAndOpensThePaywall() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyPremium", "YES"]
        app.launch()
        completeWelcomeIfShown(app)

        app.buttons["History"].tap()
        let week = app.buttons["Week"]
        let month = app.buttons["Month"]
        XCTAssertTrue(month.waitForExistence(timeout: 10), "no Week · Month switch")
        XCTAssertEqual(app.buttons.matching(identifier: "Week").count, 1)
        XCTAssertEqual(app.buttons.matching(identifier: "Month").count, 1)
        XCTAssertEqual(month.value as? String, "Premium")
        XCTAssertTrue(week.isSelected)
        tapWhenReady(month)

        let locked = app.staticTexts["Your whole month at a glance"]
        XCTAssertTrue(locked.waitForExistence(timeout: 5), "no locked month")
        XCTAssertTrue(month.isSelected)
        XCTAssertEqual(count("See Premium", in: app), 1, "See Premium is not one element")
        XCTAssertEqual(count("Back to this week", in: app), 1, "Back to this week is not one element")
        tapWhenReady(app.buttons["See Premium"])

        let paywall = app.staticTexts["See how you really drink, and what would help."]
        XCTAssertTrue(paywall.waitForExistence(timeout: 5), "See Premium opened no paywall")
        app.buttons["Not now"].tap()
        XCTAssertTrue(paywall.waitForNonExistence(timeout: 5), "Not now did not close the paywall")

        tapWhenReady(app.buttons["Back to this week"])
        XCTAssertTrue(locked.waitForNonExistence(timeout: 5), "Back to this week left the locked month up")
        XCTAssertTrue(week.isSelected)
    }
```

- [ ] **Step 2: RED.** `UI -only-testing:WaterBuddyUITests/PremiumUITests` (log `t7-red`). Expected:
  `testAFreeUsersMonthIsLockedAndOpensThePaywall` fails on *no Week · Month switch*;
  `testAnOrdinaryRunsHistoryHasNoMonthSwitch` passes (it guards an absence — first seen green,
  ledgered); the two step-1 tests pass.
- [ ] **Step 3: The paywall's entry.** In `WaterBuddy/PaywallView.swift`, `Entry`:

```swift
    enum Entry: Identifiable, Hashable {
        /// Settings' *See Premium*.
        case settings
        /// History's locked month (spec `2026-10-22-month-view-design.md` §3.6).
        case history

        var id: Self { self }
    }
```

- [ ] **Step 4: A read-only serving row.** In `ServingRow`: `let edit: () -> Void` →
  `let edit: (() -> Void)?`, with the DocC line *"`nil` in Month mode, whose rows are read-only (spec
  §3.4)."*; replace `private func row(stacked: Bool) -> some View { … }` with:

```swift
    @ViewBuilder
    private func row(stacked: Bool) -> some View {
        if let edit {
            Button(action: edit) { pane(stacked: stacked) }
                .buttonStyle(PressStyle())
                // One serving, one stop. The swipe action reaches VoiceOver on its own, as a rotor action.
                //
                // The label goes on the **button**, not on an `.accessibilityElement(children: .ignore)`
                // wrapper around it. That is the idiom the vessel uses, and it is wrong here: the vessel
                // wraps plain drawing, while this wraps a *control*, which VoiceOver surfaces
                // regardless. The wrapper became a second element above it and every serving was
                // announced twice — "250 millilitres, 21:22", then "250 ml, 21:22, button". Only the real
                // accessibility tree shows that; no unit test in this project can see one.
                .accessibilityLabel(strings.localized("%1$d millilitres", log.amount, locale: locale))
                .accessibilityValue(log.timestamp.formatted(date: .omitted, time: .shortened))
                .accessibilityHint(Text("Edits this serving", bundle: strings))
        } else {
            // Month mode's row: the same pane, drawn, and no control to wrap — so here the wrapper is
            // the right idiom, one element speaking what the button would (spec §3.9).
            pane(stacked: stacked)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(strings.localized("%1$d millilitres", log.amount, locale: locale))
                .accessibilityValue(log.timestamp.formatted(date: .omitted, time: .shortened))
        }
    }

    private func pane(stacked: Bool) -> some View {
        HStack(spacing: 14) {
            // The vessel's glyph when the amount is one of the current three; the drop
            // otherwise.
            Image(systemName: vessel?.symbol ?? "drop.fill")
                // A ratio of the disc it sits in, never its own text style.
                .font(.system(size: disc * 0.44, weight: .semibold))
                // White on the canvas's cyan wash. The canvas's glyph was cyan, and a cyan
                // glyph on a cyan wash read 2.46–2.79:1 against the 3:1 floor for a non-text
                // mark at every wash tried — the wash lightens its own ground, and the sheen
                // lands on the row's top left, where the glyph sits. White on the 0.16 wash
                // read 4.42–5.30 swept (`docs/DESIGN.md`, *The look, measured*). The canvas's
                // wash is not an `Aurora` colour; `Aurora.cyan` stands in.
                .foregroundStyle(.white)
                .frame(width: disc, height: disc)
                .background(Circle().fill(Aurora.cyan.opacity(0.16)))
                .accessibilityHidden(true)

            if stacked {
                // The last layout, so the one that may shrink: each line has the row's
                // whole width to do it in.
                VStack(alignment: .leading, spacing: 1) {
                    amount
                    name
                    time
                }
                .minimumScaleFactor(0.6)

                Spacer(minLength: 0)
            } else {
                // At their own size or not at all.
                VStack(alignment: .leading, spacing: 1) {
                    amount
                    name
                }
                .fixedSize()

                Spacer(minLength: 8)

                time
                    .fixedSize()
            }
        }
        .foregroundStyle(.white)
        .lineLimit(1)
        .padding(.leading, 12)
        .padding(.trailing, 20)
        .padding(.vertical, 10)
        // WidgetKit's 44pt floor is a widget rule, but a list row is a control here too, and a
        // `minHeight` lets it grow with Dynamic Type instead of clipping.
        .frame(minHeight: 56)
        // Pressable only where it is a button.
        .liquidGlass(in: Capsule(), density: .frosted, elevation: .resting, interactive: edit != nil)
    }
```

  — `pane(stacked:)` is the old label moved whole (`HistoryView.swift:1281–1331` at `a6e287b`), every
  comment kept; the one change is `interactive: edit != nil`.
- [ ] **Step 5: The view's state.** In `HistoryView`, after `@Environment(\.dynamicTypeSize) …`:

```swift
    @Environment(PremiumStore.self) private var premium
    @Environment(\.pageIsShown) private var pageIsShown
```

  and after `@State private var removals = 0`:

```swift
    /// Week or Month — presentation state, Week whenever the page is built (spec
    /// `2026-10-22-month-view-design.md` §3.2). Which month is shown is the model's
    /// (``DataManager/showMonth(_:)``): History holds no month of its own and does no month arithmetic
    /// (rule `30-rollover`).
    @State private var mode = HistoryMode.week

    /// The month's opened day, as an ordinal — `nil` for none (§3.4).
    @State private var openedDay: Int?

    /// The paywall, while the locked month has it open — its `.sheet(item:)` selection (rule `50-views`).
    @State private var paywall: PaywallView.Entry?

    /// Bumped by the user's own taps on the switch and on a month's arrows, as ``picks`` is by a day
    /// (rule `60-design-system`).
    @State private var switches = 0
    @State private var steps = 0
```

- [ ] **Step 6: The body.** Replace the `List { … }`'s content — everything after the header's
  `.historyRow(…)` line — with:

```swift
            // Under the header, in both modes, so it never moves under the finger (spec §3.2).
            if drawsSwitch {
                ModeSwitch(mode: mode, locked: !holdsPremium) { choose($0) }
                    .arrives(arrived, order: 0)
                    .historyRow(top: 0, bottom: 8)
            }

            if showsMonth {
                monthRows
            } else {
                weekRows
            }
```

  and move the replaced content (`HistoryView.swift:227–264` at `a6e287b`), every comment kept and
  nothing else changed, into:

```swift
    /// Week mode — History as it was before the month: the week card, then the shown day's strip and
    /// servings, or its empty state (spec §3.2).
    @ViewBuilder
    private var weekRows: some View {
        // Drawn only once there is a past to show. A fresh install would otherwise open on
        // seven empty bars, which reads as a broken chart rather than as a new account — and
        // this is the one screen guaranteed to render its empty state for every new user.
        // Note the condition is `history`, not `todaysLogs`: the morning after a rollover,
        // today is empty and the week is exactly what the user wants to see.
        if hasSomethingToShow {
            HistoryCard(
                shown: shownPastDay?.dayOrdinal ?? manager.history.last?.dayOrdinal,
                arrived: arrived
            ) { ordinal in
                let picked = Self.selection(forDay: ordinal, in: manager.history)
                // A tick for a choice, and none for a tap on the day already shown.
                if picked != selectedDay { picks += 1 }
                selectedDay = picked
            }
            // Were History the page the app opens on, everything under the header would
            // settle in; a page that slides in is whole as it comes (``Arrival``).
            .arrives(arrived, order: 0)
            .historyRow()
        }

        if shownLogs.isEmpty {
            emptyState
                .arrives(arrived, order: 1)
                .historyRow(top: 22)
        } else {
            // Today's strip also marks the next reminder; a past day has none to mark.
            DayStrip(
                logs: shownLogs,
                day: shownPastDay?.dayOrdinal ?? manager.history.last?.dayOrdinal,
                marksReminder: shownPastDay == nil,
                arrived: arrived
            )
                .arrives(arrived, order: 1)
                .historyRow()

            servings
        }
    }
```

  Then, among the `List`'s modifiers:
  - after `.animation(.smooth(duration: 0.35), value: shownLogs.map(\.id))`:

```swift
        // The opened day comes and goes, and Month's rows with the mode (spec §3.8).
        .animation(.smooth(duration: 0.35), value: openedDay)
        .animation(.smooth(duration: 0.35), value: showsMonth)
```

  - `.onAppear { manager.refresh() }` →

```swift
        .onAppear {
            // A page is built in Week mode: a month a previous visit left the model reading is let go
            // before the refresh would read it again (plan M13).
            if !showsMonth { manager.showMonth(nil) }
            manager.refresh()
        }
        // The pager keeps a page it has left for the length of its slide, so this, and not
        // `onDisappear`, is the moment History stops asking for a month (`tasks/lessons.md`).
        .onChange(of: pageIsShown) { _, shown in
            if !shown { manager.showMonth(nil) }
        }
        // Premium bought, or refunded, with Month on screen: the month is read, or let go.
        .onChange(of: holdsPremium) { _, holds in
            guard mode == .month else { return }
            openedDay = nil
            manager.showMonth(holds ? manager.thisMonth : nil)
        }
```

  - after `.sensoryFeedback(Haptics.remove, trigger: removals)`:

```swift
        .sensoryFeedback(Haptics.select, trigger: switches)
        .sensoryFeedback(Haptics.select, trigger: steps)
```

  - after the editor's `.sheet(item: $editor) { … }`:

```swift
        .sheet(item: $paywall) { entry in PaywallView(entry: entry) }
```

- [ ] **Step 7: What the body reads, and the actions.** `shownPastDay`'s `guard` gains a first
  condition:

```swift
        // Month mode's header is today's (spec §3.2); the week's selection waits for Week.
        guard !showsMonth,
              let day = Self.shownDay(selected: hasSomethingToShow ? selectedDay : nil, in: manager.history),
              day.dayOrdinal != manager.history.last?.dayOrdinal
        else { return nil }
```

  and after `shownLogs`:

```swift
    /// Whether the switch is drawn (``offersMonth(status:offered:)``).
    private var drawsSwitch: Bool {
        Self.offersMonth(status: premium.state.status, offered: PaywallView.isOfferedHere)
    }

    /// Whether the user holds Premium — `false` while the first read is outstanding.
    private var holdsPremium: Bool {
        premium.state.status?.isPremium == true
    }

    /// Whether Month mode is on screen. With no switch drawn History is the week, whatever ``mode`` holds.
    private var showsMonth: Bool {
        drawsSwitch && mode == .month
    }

    /// The month's opened day, while the shown month holds it and it can be opened.
    private var openedMonthDay: MonthHistory.Day? {
        manager.month?.days.first { $0.summary.dayOrdinal == openedDay && $0.canOpen }
    }

    /// Month mode: for a holder the month, the day opened in it and the month's figures; for a free user
    /// the locked month (spec §3.2).
    @ViewBuilder
    private var monthRows: some View {
        if holdsPremium {
            MonthCard(month: manager.month, opened: openedDay, open: { open($0) }, move: { move(to: $0) })
                .historyRow()

            if let day = openedMonthDay {
                OpenedDayHeading(day: day)
                    .historyRow(top: 14, bottom: 2)

                // A day with nothing logged draws its heading alone (plan M12).
                let logs = manager.monthLogs[day.summary.dayOrdinal] ?? []
                if !logs.isEmpty {
                    DayStrip(logs: logs, day: day.summary.dayOrdinal, marksReminder: false, arrived: arrived)
                        .historyRow()

                    // Read-only, for every day (spec §3.4): no sheet, no swipe.
                    ForEach(logs, id: \.id) { log in
                        ServingRow(log: log, vessel: Self.vessel(forAmount: log.amount, amounts: manager.servings), edit: nil)
                            .historyRow(top: 5, bottom: 5, sides: Self.margin)
                    }
                }
            }

            if let month = manager.month, month.daysCounted > 0 {
                MonthFigures(month: month)
                    .historyRow(top: 8, bottom: 24)
            }
        } else {
            LockedMonth { paywall = .history } back: { choose(.week) }
                .historyRow(bottom: 24)
        }
    }

    /// The switch: Week, or Month — this month on the model's own clock, for a holder alone; a free
    /// user's Month asks for nothing (spec §3.6).
    private func choose(_ chosen: HistoryMode) {
        guard chosen != mode else { return }
        switches += 1
        mode = chosen
        openedDay = nil
        manager.showMonth(chosen == .month && holdsPremium ? manager.thisMonth : nil)
    }

    /// An arrow: the month it names, which the shown month says exists.
    private func move(to month: Int?) {
        guard let month else { return }
        steps += 1
        openedDay = nil
        manager.showMonth(month)
    }

    /// A day on the month: opened, or closed when it is the one open (spec §3.4).
    private func open(_ ordinal: Int) {
        picks += 1
        openedDay = openedDay == ordinal ? nil : ordinal
    }
```

- [ ] **Step 8: The month's views.** Before `// MARK: - The day` in `HistoryView.swift`:

```swift
// MARK: - The month

/// Week or Month — History's two modes (spec `2026-10-22-month-view-design.md` §3.2).
private enum HistoryMode {
    case week, month
}

/// History's own measures for the month.
private enum MonthStyle {
    /// The primary buttons' 56 (rule `65-accessibility`), as the paywall's and the Premium card's are.
    static let buttonHeight: CGFloat = 56
}

/// *Week · Month*: two buttons on one frosted capsule, the shown one marked as a selected slot is —
/// `LiquidGlass.Selection`'s fill and rim, never solid white, which would read as the primary surface
/// the locked month's *See Premium* is (spec §3.8, rule `60-design-system`).
///
/// For a free user Month carries a lock, drawn and not spoken: its value says *Premium* (spec §3.9).
private struct ModeSwitch: View {

    @Environment(\.strings) private var strings

    let mode: HistoryMode
    let locked: Bool
    let choose: (HistoryMode) -> Void

    var body: some View {
        HStack(spacing: 4) {
            segment(.week, Text("Week", bundle: strings))
            segment(.month, Text("Month", bundle: strings))
        }
        .padding(3)
        // The screen's own pair: sibling panes on one screen share one (rule `60-design-system`).
        .liquidGlass(in: Capsule(), density: .frosted, elevation: .raised)
        .padding(.horizontal, HistoryView.margin)
    }

    private func segment(_ choice: HistoryMode, _ title: Text) -> some View {
        let isSelected = choice == mode
        let isLocked = choice == .month && locked

        return Button {
            choose(choice)
        } label: {
            HStack(spacing: 6) {
                title
                if isLocked {
                    Image(systemName: "lock.fill")
                        .imageScale(.small)
                        .accessibilityHidden(true)
                }
            }
            .font(.subheadline.weight(isSelected ? .bold : .semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            // The whole half is the target (rule `65-accessibility`).
            .frame(maxWidth: .infinity, minHeight: HistoryView.dayTapFloor)
            .background {
                Capsule()
                    .fill(.white.opacity(isSelected ? LiquidGlass.Selection.fillOpacity : 0))
                    .strokeBorder(.white.opacity(isSelected ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
                    .animation(Motion.land, value: isSelected)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityValue(isLocked ? Text("Premium", bundle: strings) : Text(verbatim: ""))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

/// The month as rings: ‹, its name, ›; the weekday letters; a ring a day; the legend and the
/// disclosure (spec §3.3).
///
/// **The days are laid out by ``DayRow``, a week to a row** — the week card's own slots, seven of which
/// clear the 44-pt floor on the narrowest supported iPhone (`everyDayClearsTheTapFloor(across:)`).
///
/// **Every mark is the model's answer** — counted, openable, met, today, the arc
/// (``MonthHistory/Day``): nothing is judged against the goal here (rule `50-views`). A met ring is
/// closed as well as cyan, never colour alone (rule `65-accessibility`).
///
/// **VoiceOver hears a summary and a button a day**: the month's name as a heading, the days on goal
/// its value; each day that can be opened one button, its date the label, its total against the goal
/// the value, selected when it is open. The quiet days, the letters and the legend are hidden.
private struct MonthCard: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// The month on screen, or `nil` before its first read has answered.
    let month: MonthHistory?

    /// The opened day's ordinal, marked and announced as selected.
    let opened: Int?

    let open: (Int) -> Void
    let move: (Int?) -> Void

    /// A ring's diameter: a real magnitude scaled with the text, capped at its use site inside the
    /// 44-pt slot with room for the opened day's ring round it (rule `65-accessibility`).
    @ScaledMetric(relativeTo: .body) private var scaledRing: CGFloat = 34

    private var ring: CGFloat { min(scaledRing, 36) }

    /// The arc's width, a ratio of the ring.
    private var arc: CGFloat { ring * 0.1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let month {
                titleRow(month)
                    .padding(.horizontal, 8)
                letters
                weeks(month)
                legend
                    .padding(.horizontal, 20)
                Text("Measured against your current goal", bundle: strings)
                    .font(.caption2)
                    // The week card's value, measured on its pane (`docs/DESIGN.md`, *The look,
                    // measured*); measured on this one in the walk.
                    .foregroundStyle(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
            } else {
                // Before the first read answers: the quiet form — no title, no arrow, no ring, no
                // figure (spec §3.3).
                DrawnMonth(pattern: false)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        // The week card's pair (rule `60-design-system`).
        .liquidGlass(density: .frosted, elevation: .raised)
        .padding(.horizontal, HistoryView.margin)
        .animation(.smooth(duration: 0.3), value: month)
    }

    private func titleRow(_ month: MonthHistory) -> some View {
        HStack(spacing: 8) {
            arrow(to: month.earlier, systemName: "chevron.left")
            Spacer(minLength: 0)
            if let first = month.days.first {
                // Formatted in the app's language, never keyed (spec §3.11).
                Text(first.summary.date, format: .dateTime.month(.wide).year())
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityValue(strings.localized("%1$d of %2$d days on goal", month.daysMet, month.daysCounted, locale: locale))
            }
            Spacer(minLength: 0)
            arrow(to: month.later, systemName: "chevron.right")
        }
    }

    /// ‹ or ›: a chevron with a 44-pt target, labelled with the month it goes to (plan M8). At a bound
    /// it is drawn quieter, does nothing, and VoiceOver does not stop on it — there is no month to name.
    private func arrow(to neighbour: MonthHistory.Neighbour?, systemName: String) -> some View {
        Button {
            move(neighbour?.firstDay)
        } label: {
            Image(systemName: systemName)
                // A ratio of its target, never a text style of its own (rule `65-accessibility`).
                .font(.system(size: HistoryView.dayTapFloor * 0.4, weight: .semibold))
                .frame(width: HistoryView.dayTapFloor, height: HistoryView.dayTapFloor)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressStyle())
        .disabled(neighbour == nil)
        .opacity(neighbour == nil ? 0.35 : 1)
        .accessibilityLabel(Text(neighbour?.start.formatted(.dateTime.month(.wide).year().locale(locale)) ?? ""))
        .accessibilityHidden(neighbour == nil)
    }

    /// The weekday letters, from the app's language's first weekday. Hidden: each day speaks its date.
    private var letters: some View {
        DayRow {
            ForEach(Array(HistoryView.weekdayLetters(in: locale).enumerated()), id: \.offset) { _, letter in
                Text(letter)
                    .font(.system(size: ring * 0.34, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityHidden(true)
    }

    private func weeks(_ month: MonthHistory) -> some View {
        let grid = HistoryView.monthGrid(
            dayCount: month.days.count,
            weekdayOfFirst: month.weekdayOfFirst,
            firstWeekday: HistoryView.firstWeekday(in: locale)
        )
        return VStack(spacing: 4) {
            ForEach(grid.indices, id: \.self) { week in
                DayRow {
                    ForEach(0..<7, id: \.self) { weekday in
                        cell(grid[week][weekday].map { month.days[$0] })
                    }
                }
                // As the week card's row: its slots claim their height (`tasks/lessons.md`).
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func cell(_ day: MonthHistory.Day?) -> some View {
        if let day, day.canOpen {
            dayButton(day)
        } else if let day {
            quietDay(day)
        } else {
            Color.clear
                .frame(height: HistoryView.dayTapFloor)
                .accessibilityHidden(true)
        }
    }

    private func dayButton(_ day: MonthHistory.Day) -> some View {
        let ordinal = day.summary.dayOrdinal
        let isOpened = ordinal == opened

        return Button {
            open(ordinal)
        } label: {
            ZStack {
                // The track, then the day's arc over it from twelve o'clock, both inside the ring.
                Circle()
                    .inset(by: arc / 2)
                    .stroke(.white.opacity(0.14), lineWidth: arc)
                Circle()
                    .inset(by: arc / 2)
                    .trim(from: 0, to: day.fraction)
                    .stroke(day.isMet ? Aurora.cyan : Color.white, style: StrokeStyle(lineWidth: arc, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                // The opened day's ring and disc, at zero opacity on every other day, so what animates
                // is a mark and not a layer (rule `60-design-system`, plan M7).
                Circle()
                    .strokeBorder(.white.opacity(isOpened ? LiquidGlass.Selection.ringOpacity : 0), lineWidth: LiquidGlass.Selection.ringWidth)
                    .padding(-3)
                Circle()
                    .fill(LiquidGlass.Selection.discFill.opacity(isOpened ? 1 : 0))
                    .padding(arc + 2)
                Text(day.summary.date, format: .dateTime.day())
                    // A ratio of the ring, never a text style of its own (rule `65-accessibility`).
                    .font(.system(size: ring * 0.38, weight: isOpened || day.isToday ? .heavy : .semibold, design: .rounded))
                    .monospacedDigit()
                    // `Aurora.top` on the white disc, as the week card's shown letter is
                    // (`theShownDaysLetterReadsOnItsDisc`).
                    .foregroundStyle(isOpened ? Aurora.top : Color.white)
            }
            .frame(width: ring, height: ring)
            .animation(Motion.land, value: isOpened)
            .frame(maxWidth: .infinity, minHeight: HistoryView.dayTapFloor)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name(of: day))
        .accessibilityValue(strings.localized("%1$d of %2$d millilitres", day.summary.total, manager.dailyGoal, locale: locale))
        .accessibilityAddTraits(isOpened ? [.isSelected] : [])
    }

    /// A day that cannot be opened — still to come, or before the first serving: a faint disc and its
    /// number, not a button (spec §3.3). Its white is the empty state's 0.7 until the walk measures it
    /// on this pane (plan M9).
    private func quietDay(_ day: MonthHistory.Day) -> some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.06))
            Text(day.summary.date, format: .dateTime.day())
                .font(.system(size: ring * 0.38, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(width: ring, height: ring)
        .frame(maxWidth: .infinity, minHeight: HistoryView.dayTapFloor)
        .accessibilityHidden(true)
    }

    /// *Goal met* and *Part of it*, each beside its mark — side by side while they fit, one above the
    /// other where they do not. Hidden: every day speaks its own figures.
    private var legend: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 18) {
                legendItem(Text("Goal met", bundle: strings), colour: Aurora.cyan, fraction: 1)
                legendItem(Text("Part of it", bundle: strings), colour: .white, fraction: 0.6)
            }
            .fixedSize()
            VStack(alignment: .leading, spacing: 6) {
                legendItem(Text("Goal met", bundle: strings), colour: Aurora.cyan, fraction: 1)
                legendItem(Text("Part of it", bundle: strings), colour: .white, fraction: 0.6)
            }
        }
        .font(.caption)
        .foregroundStyle(.white.opacity(0.9))
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private func legendItem(_ title: Text, colour: Color, fraction: Double) -> some View {
        let mark = ring * 0.34

        return HStack(spacing: 6) {
            ZStack {
                Circle()
                    .inset(by: mark * 0.125)
                    .stroke(.white.opacity(0.14), lineWidth: mark * 0.25)
                Circle()
                    .inset(by: mark * 0.125)
                    .trim(from: 0, to: fraction)
                    .stroke(colour, style: StrokeStyle(lineWidth: mark * 0.25, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: mark, height: mark)
            title
        }
    }

    /// What VoiceOver calls a day: *Today*, or its date spelled out.
    private func name(of day: MonthHistory.Day) -> Text {
        guard !day.isToday else { return Text("Today", bundle: strings) }
        return Text(day.summary.date.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(locale)))
    }
}

/// The month's opened day: its name and its total against the goal, a heading on the aurora above its
/// strip and its servings (spec §3.4, plan M6) — one element, as History's own heading is.
private struct OpenedDayHeading: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    let day: MonthHistory.Day

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Group {
                if day.isToday {
                    Text("Today", bundle: strings)
                } else {
                    Text(day.summary.date, format: .dateTime.weekday(.wide).day().month(.wide))
                }
            }
            .font(.title3.weight(.bold))
            // Two lines before a word is cut: a day's name is the longest word this screen draws.
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .legibleOnBackdrop()
            .accessibilityAddTraits(.isHeader)
            .accessibilityValue(strings.localized("%1$d of %2$d millilitres", day.summary.total, manager.dailyGoal, locale: locale))

            Text(strings.figure("%1$@ of %2$@ ml", day.summary.total, manager.dailyGoal, locale: locale))
                .font(.subheadline.weight(.semibold))
                .fontDesign(.rounded)
                .monospacedDigit()
                .legibleOnBackdrop()
                .accessibilityHidden(true)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, HistoryView.margin)
    }
}

/// The month's figures: *Days on goal*, *Best streak* and *This month* as tiles — three across where
/// they fit, a column where they do not — then the average and the change (spec §3.5, §3.9). Drawn
/// only for a month with a counted day.
private struct MonthFigures: View {

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    let month: MonthHistory

    var body: some View {
        VStack(spacing: 10) {
            // Offered the row's whole width; it chooses among whole layouts (`tasks/lessons.md`).
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 10) { tiles(fixed: true) }
                VStack(spacing: 10) { tiles(fixed: false) }
            }
            .frame(maxWidth: .infinity)

            if let average = month.average {
                averageLine(average)
            }
        }
        .padding(.horizontal, HistoryView.margin)
    }

    @ViewBuilder
    private func tiles(fixed: Bool) -> some View {
        tile(
            strings.figure("%1$@/%2$@", month.daysMet, month.daysCounted, locale: locale),
            label: Text("Days on goal", bundle: strings),
            spoken: strings.localized("%1$d of %2$d days", month.daysMet, month.daysCounted, locale: locale),
            fixed: fixed
        )
        tile(
            strings.localized("%1$d days", month.bestRun, locale: locale),
            label: Text("Best streak", bundle: strings),
            spoken: strings.localized("%1$d days", month.bestRun, locale: locale),
            fixed: fixed
        )
        // Litres drawn, millilitres spoken, as the sliders speak them (spec §3.9).
        tile(
            strings.localized("%1$@ L", HistoryView.litres(month.total, locale: locale), locale: locale),
            label: Text("This month", bundle: strings),
            spoken: strings.localized("%1$d millilitres", month.total, locale: locale),
            fixed: fixed
        )
    }

    private func tile(_ figure: String, label: Text, spoken: String, fixed: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(figure)
                .font(.title3.weight(.bold))
                .fontDesign(.rounded)
                .monospacedDigit()
            label
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .lineLimit(1)
        // At its own size across the row; in the column, with a line to itself, it may shrink.
        .minimumScaleFactor(fixed ? 1 : 0.6)
        .fixedSize(horizontal: fixed, vertical: false)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .foregroundStyle(.white)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(spoken)
    }

    private func averageLine(_ average: Int) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(strings.figure("Average %1$@ ml a day", average, locale: locale))
                    .font(.subheadline.weight(.bold))
                if let change = month.change {
                    Text(drawnChange(change))
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            if let change = month.change {
                Image(systemName: change > 0 ? "arrow.up.right" : change < 0 ? "arrow.down.right" : "equal")
                    .font(.body.weight(.semibold))
                    // A glyph on dark glass, read at 3:1 in the walk (`tasks/lessons.md`, 2026-10-22).
                    .foregroundStyle(Aurora.cyan)
                    .accessibilityHidden(true)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(strings.localized("Average %1$d millilitres a day", average, locale: locale))
        .accessibilityValue(month.change.map(spokenChange) ?? "")
    }

    /// Names no month: Russian would need it in the prepositional case, which Foundation does not
    /// produce (spec §3.11).
    private func drawnChange(_ change: Int) -> String {
        if change > 0 { return strings.figure("Up %1$@ ml on the month before", change, locale: locale) }
        if change < 0 { return strings.figure("Down %1$@ ml on the month before", -change, locale: locale) }
        return strings.localizedString(forKey: "The same as the month before", value: nil, table: nil)
    }

    private func spokenChange(_ change: Int) -> String {
        if change > 0 { return strings.localized("Up %1$d millilitres on the month before", change, locale: locale) }
        if change < 0 { return strings.localized("Down %1$d millilitres on the month before", -change, locale: locale) }
        return strings.localizedString(forKey: "The same as the month before", value: nil, table: nil)
    }
}

/// What a free user meets in Month: a drawn month — not theirs, and never read (spec §3.6) — blurred
/// under a card that offers Premium, and the promise under it.
private struct LockedMonth: View {

    @Environment(\.strings) private var strings

    let open: () -> Void
    let back: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                DrawnMonth(pattern: true)
                    .blur(radius: 5)
                    .opacity(0.75)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .liquidGlass(density: .frosted, elevation: .raised)
                    .accessibilityHidden(true)

                card
                    .padding(.horizontal, 16)
            }
            promise
        }
        .padding(.horizontal, HistoryView.margin)
    }

    private var card: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar")
                // White, as the Settings card's glyph is: cyan read 2.88:1 there (step 1's walk, R4).
                .font(.title2.weight(.semibold))
                .accessibilityHidden(true)
            Text("Your whole month at a glance", bundle: strings)
                .font(.title3.weight(.bold))
                .accessibilityAddTraits(.isHeader)
            Text("Every day you have logged is kept. Premium shows it as months, with your patterns and a recap.", bundle: strings)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.92))
            Button(action: open) {
                // The surface sets its label's colour (rule `60-design-system`).
                Text("See Premium", bundle: strings)
                    .font(.body.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: MonthStyle.buttonHeight)
                    .primarySurface(in: Capsule())
            }
            .buttonStyle(PressStyle())
            .padding(.top, 6)
            Button(action: back) {
                Text("Back to this week", bundle: strings)
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: HistoryView.dayTapFloor)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        // Sentence-length text, on `.frosted` (rule `60-design-system`), and Premium's mark.
        .liquidGlass(density: .frosted, elevation: .raised)
        .premiumRim()
    }

    private var promise: some View {
        HStack(alignment: .top, spacing: 12) {
            // White, step 1's ruling R4 for the paywall's check.
            Image(systemName: "checkmark")
                .font(.body.weight(.semibold))
                .accessibilityHidden(true)
            Text("The week, today and every serving stay free. Nothing you logged is ever hidden or deleted.", bundle: strings)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(density: .frosted, elevation: .raised)
        .accessibilityElement(children: .combine)
    }
}

/// A month drawn, not read: five weeks of rings, with no number, date or name (spec §3.3, §3.6) — the
/// locked month's backdrop, `pattern` cyan and white as a month of water would be, and a month's quiet
/// form before its first read, every ring empty. No pane of its own; its callers hide it from VoiceOver.
private struct DrawnMonth: View {

    let pattern: Bool

    @ScaledMetric(relativeTo: .body) private var scaledRing: CGFloat = 34

    private var ring: CGFloat { min(scaledRing, 36) }

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { week in
                DayRow {
                    ForEach(0..<7, id: \.self) { weekday in
                        Circle()
                            .inset(by: ring * 0.05)
                            .stroke(colour(at: week * 7 + weekday), lineWidth: ring * 0.1)
                            .frame(width: ring, height: ring)
                            .frame(maxWidth: .infinity, minHeight: HistoryView.dayTapFloor)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// The board's drawn month (*Step 2 — Month, free user*): the third and seventh of every nine days
    /// short of the goal, the last week still to come.
    private func colour(at index: Int) -> Color {
        guard pattern, index < 28 else { return .white.opacity(0.10) }
        return [2, 6].contains(index % 9) ? .white.opacity(0.45) : Aurora.cyan
    }
}
```

- [ ] **Step 9: The previews.** Both existing previews gain `.environment(PremiumStore(source: .silent()))`
  after their `.environment(manager)`; and after them:

```swift
#Preview("Month, held") {
    let manager = previewManager(named: "preview.waterbuddy.history.month")

    // Pinned to the start of the day, as the other previews are; twenty days back, every fourth short.
    let start = Calendar.waterBuddyDay.startOfDay(for: .now)
    for offset in 1...20 {
        if let day = Calendar.waterBuddyDay.date(byAdding: .day, value: -offset, to: start) {
            manager.addLog(amount: offset % 4 == 0 ? 1_500 : 2_600, at: day.addingTimeInterval(10 * 3_600))
        }
    }

    // A source that holds the lifetime purchase and reaches no store (rule `85-testing`).
    var source = PremiumStore.Source.silent()
    source.entitlements = { [PremiumAccess.Entitlement(productID: PremiumAccess.lifetimeID, expires: nil, revoked: nil)] }

    return HistoryView()
        .background { AuroraBackground() }
        .environment(manager)
        .environment(PremiumStore(source: source))
}
```

- [ ] **Step 10: Four builds.** `xcodebuild build-for-testing … -scheme WaterBuddy`,
  `xcodebuild build … -scheme WaterBuddyWidgetExtension`, `… -scheme WaterBuddyWatch`,
  `… -scheme WaterBuddyWatchWidget` (the gate's destinations), each `** … SUCCEEDED **`; each log's
  warnings in `DataManager.swift`, `HistoryView.swift` and `PaywallView.swift`, reduced as Task 0
  reduces them, are compared with Task 0's files — no message that is not already there. A new one is
  read and fixed at the declaration it names (rule `43-concurrency`) — `MonthHistory`'s members are
  `nonisolated`, as `DaySummary`'s statics are — never by an annotation on a suite. Task 9 makes the
  whole comparison from a clean build.
- [ ] **Step 11: GREEN.** `UI -only-testing:WaterBuddyUITests/PremiumUITests` (log `t7-green`): four
  executed, 0 failures. Then Week mode unchanged — `UI` with
  `-only-testing:WaterBuddyUITests/GoalSetupUITests/testHistoryReturnsToTodayWhenItsTabIsLeft
  -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheWeekCardIsOneSummaryAndOneButtonPerDay
  -only-testing:WaterBuddyUITests/GoalSetupUITests/testAServingAddedToYesterdayShowsUnderYesterday
  -only-testing:WaterBuddyUITests/GoalSetupUITests/testAServingRowOpensItsSheetWhereverItIsTapped
  -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheStripIsOneHeadingOverADaysServings
  -only-testing:WaterBuddyUITests/GoalSetupUITests/testTheTitleHoldsItsPlaceOnEveryTab` (log
  `t7-week`): six executed, 0 failures. Then `UNIT -only-testing:WaterBuddyTests` (log `t7-unit`): the
  attribute grep's count, **812**, every one passed but the URL test (#159), one skipped (#157).
- [ ] **Step 12:** stage `WaterBuddy/HistoryView.swift WaterBuddy/PaywallView.swift
  WaterBuddyUITests/PremiumUITests.swift`. Ledger.

---

### Task 8: By hand, with the owner

**Files:** none in the tree; `$SCRATCH/shots/*`; measurements for `docs/DESIGN.md` (written in Task 10).

- [ ] **Step 1: The setup.** *WaterBuddy Probe 27*, the `WaterBuddy` scheme run from Xcode with
  `-WaterBuddyPremium YES` under **Arguments Passed On Launch** and the local StoreKit configuration;
  removed from the scheme before Task 9 (lesson 2026-10-22). A month and more of servings entered
  through History's sheet over the week, and older rows through a throwaway DEBUG-only seed in a scratch
  copy of the index — never the real store of a device. Captures with
  `xcrun simctl io 43E0B902-C6D5-48DD-B513-F22AF3BE9BEA screenshot`, each read before the next step;
  the owner's iPhone only when the owner says "done".
- [ ] **Step 2: The walk**, one capture each:
  1. Free: History with the switch; Month locked — the drawn month, the card, its rim, *See Premium*,
     *Back to this week*, the promise; *See Premium* → the paywall; *Not now*; *Back to this week*.
  2. A plan bought: Month — this month, today heavier, days to come quiet, the legend, the disclosure.
  3. A day opened, another, the same again (closed); a day with nothing logged (its heading alone).
  4. ‹ to the first month — counted from the first serving, ‹ quiet; › back to this month, › quiet.
  5. The tiles and the average line; the change up, down and the same.
  6. A pour from the widget while Month is open (the simulator's widget, or `AddWaterIntent` from
     Shortcuts) → today's ring and the total move.
  7. Russian, then Uzbek: Monday first, the letters, the month's name, *62,6 л*, the change line.
  8. VoiceOver: the switch's two buttons and Month's *Premium*; the month's heading and value; a day
     button's label, value and *Selected*; the tiles; the locked card.
  9. A refund from Xcode's transaction manager with Month open → the locked month, and no month read
     after it (Review Focus's last line).
  10. The largest accessibility size: the slots at 44, the rings capped, the tiles in a column,
      nothing cut; Reduce Transparency: the panes opaque, the rim drawn.
  11. The board's three states beside the screen — differences ledgered, and those that change the
      look shown to the owner.
- [ ] **Step 3: Measure the colour pairs** off Step 2's shots, by the ring-around-ink method
  `docs/DESIGN.md`'s *The paywall, measured* records, at the aurora's brightest frame: the switch's two
  labels; the month's name; a counted day's number and a quiet day's (white 0.7, plan M9); the cyan
  and white arcs against their track; the opened day's number on its disc; the legend; the disclosure;
  the opened day's heading on the aurora; the tiles' figures and labels; the average line and its
  change; the trend glyph; the locked card's three lines and *Back to this week*; the promise. Text
  holds 4.5:1, a glyph or arc 3:1. One that does not is raised to the lowest value that passes and
  measured again; one whose fix changes the look goes to the owner.

---

### Task 9: The review, the gate, the warnings

- [ ] **Step 1: A fresh reviewer**, read-only, on the most capable model, over a package of
  `git diff --cached -U10 a6e287b` (code, tests and the rules' unstaged wording), the spec, this plan,
  its ledger's `Ruling:` lines and *Review Focus*; it also confirms nothing written to any
  `UserDefaults`, no key added, the paywall opened from Settings and History only, Month's servings
  read-only, and no `#available`. Save its report beside the ledger; check every finding against the
  code; fix Critical and Important ones test-first in the owning task; ledger minors.
- [ ] **Step 2: The gate** — rule `85-testing`'s invocations, `uptime` before each, by UDID between
  systems:
  1. Unit, *iPhone 17*: `UNIT -only-testing:WaterBuddyTests` — **812**, every one passed but the URL
     test (#159), one skipped (#157).
  2. UI, *WaterBuddy Gate 27*, in three runs under 600 s — `GoalSetupUITests` in two halves, then the
     rest:

```zsh
grep -oE "func test[A-Za-z0-9]+" WaterBuddyUITests/GoalSetupUITests.swift | sed 's/^func //' | sort > "$SCRATCH/goalsetup.txt"; N=$(wc -l < "$SCRATCH/goalsetup.txt"); H=$(( (N + 1) / 2 )); echo "$N $H"
FLAGS=$(sed -n "1,${H}p" "$SCRATCH/goalsetup.txt" | sed 's#^#-only-testing:WaterBuddyUITests/GoalSetupUITests/#' | tr '\n' ' '); xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' ${=FLAGS} -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|failed" | tail -8
FLAGS=$(sed -n "$(( H + 1 )),${N}p" "$SCRATCH/goalsetup.txt" | sed 's#^#-only-testing:WaterBuddyUITests/GoalSetupUITests/#' | tr '\n' ' '); xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' ${=FLAGS} -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|failed" | tail -8
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -skip-testing:WaterBuddyUITests/GoalSetupUITests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|failed" | tail -8
```

     Together **73** executed, 1 skipped by design.
  3. The same three on *WaterBuddy Gate 26.5* (`OS=26.5`).
  4. Watch, *WaterBuddy Watch 27*: `-scheme WaterBuddyWatch -only-testing:WaterBuddyWatchTests` — 70.
  5. `WaterBuddyWidgetExtension` and 6. `WaterBuddyWatchWidget` builds — `** BUILD SUCCEEDED **`.
  A UI failure is re-run alone, interleaved with the `HEAD` export, before it is called a flake (#140,
  #166).
- [ ] **Step 3: The warning comparison** from the staged index (`git checkout-index -a
  --prefix="$SCRATCH/after/"`), the four schemes into one empty DerivedData, by Task 0's commands with
  `after` for `head`, then `comm -13` of each against Task 0's files. Expected: every `new:` list empty.

---

### Task 10: Records, docs — then stop

- [ ] `docs/AI_CONTEXT.md`: a *Current state* block for step 2; *Files on disk* rows by `wc -l`
  (`MonthHistoryTests.swift` new; `DataManager.swift`, `HistoryView.swift`, `PaywallView.swift`,
  `HistoryViewTests.swift`, `LocalizationTests.swift`, `PremiumUITests.swift`); the catalogue's 187 keys;
  the gate and the warnings; the probe's cost figures; known issues — #159 still gates Release; the
  Russian and Uzbek drafts for the owner's sweep.
- [ ] `docs/STATE.md`: `month` and `monthLogs` — published, stored nowhere, no key; the two reads and
  their measured cost; the counting rule.
- [ ] `docs/DESIGN.md`: *The month, measured* — Task 8's pairs, each with its figure, and the values
  any of them moved.
- [ ] `docs/WIDGET.md`: a dated note — `DataManager.swift` changed (the month), the widget's read path
  untouched, both widget builds green.
- [ ] `docs/ROADMAP.md` §5: 1.4.2's line — step 2 specified, built, gated and staged; nobody meets it
  until step 5.
- [ ] `CLAUDE.md`: the warning trail gains this step's measurement as `docs/AI_CONTEXT.md` gives it.
- [ ] `HISTORY.md` appended with `Edit`, anchored on its last lines; `tasks/lessons.md` if the work
  earned a lesson.
- [ ] Before the records are final, search every sheet for "seven days", "the week only", "History
  reaches" and "Month" and check every `File.swift:N` cited against the tree.
- [ ] Stage by explicit path: the code and tests of Tasks 3–7, the plan, `CLAUDE.md`, the five docs,
  `HISTORY.md` (and `tasks/lessons.md`). The rule files stay unstaged. Write the git block last, from
  `git status --short` and `git diff --cached --name-status` run then.
- [ ] **Stop.** Report: what was built and that no user meets it until step 5; the probe's figures; the
  walk with its shots; the gate's counts and the warnings; the rule wording waiting; the commit order —
  the spec and this plan as `docs`; the code as `feat(app)`; the records as `docs`; the rules as
  `chore(claude)`.
