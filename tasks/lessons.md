# Lessons

Append-only. Newest at the bottom. One `##` heading per dated topic; never edit or delete a prior
entry.

---

## 2026-08-28 — Counting `@Test` functions: grep the attribute, not the string

`grep -c '@Test'` over `WaterBuddyTests/` returns **73**. The real count is **71**. Two of those
hits are the word `@Test` inside DocC comments that explain why each test builds its own suite
("swift-testing runs `@Test` functions in parallel inside one process…").

Count the attribute in the position it can only be an attribute:

```
grep -cE '^[[:space:]]*@Test' WaterBuddyTests/*.swift
```

**Why it matters:** `docs/AI_CONTEXT.md` publishes a test count, and a doc that overstates coverage
is worse than one that omits it. The first draft of that number was wrong by two.

## 2026-08-28 — `xcodebuild`'s test output interleaves; the source is the authority

Parsing `Test case '…' passed` lines out of a raw `xcodebuild test` log undercounted by exactly
two, because concurrent writers spliced lines together mid-string:

```
Test case 'DailyGoalSetupTests/savingTheSameGoalTwiceDoesNotChurnObservers()' passed on 'Clone 2 of iPh2026-08-28 15:53:45.901 xcodebuild[…]
```

Reconciling against the declarations in the source found every case accounted for. Two habits from
this:

- Derive counts from **source**; use the log for the **verdict** (`** TEST SUCCEEDED **`, failure
  lines, warning lines).
- swift-testing reports through xcodebuild as `Suite/function(argumentLabels:)` — parameterised
  `@Test(arguments: zip(…))` cases report **once**, under their argument labels, not once per case.
  Do not expect a case-per-argument in that output.

## 2026-08-28 — A green gate says nothing about staging

Both halves of the gate passed while the index held two entries — `.claude/CLAUDE.md` and
`WaterBuddyUITests/CLAUDE.md` — staged as *added* for files that do not exist on disk. `xcodebuild`
builds the working tree; it cannot see the index, so nothing about a passing build rules out a
commit that would land files nobody has.

**Check `git diff --cached --name-status` against `git diff --name-status` before `/commit`**, not
just `git status --short` — the porcelain `AD` code is easy to read past.

## 2026-08-28 — swift-testing's `Comment` takes a literal, not a built `String`

`#expect`'s second argument is a `Comment`, which is `ExpressibleByStringLiteral`. That means a
concatenated message does **not** compile:

```swift
#expect(cond, "first half "        // error: cannot convert value of type 'String'
        + "second half")           //        to expected argument type 'Comment?'
```

The failure surfaces as a type error on the *comment*, which reads like a problem with the
assertion. Write the message as one literal, however long, and let it run past the column guide.

**Why it matters:** the RED step is only informative if the compile errors are the ones you
predicted. Two spurious errors in the first RED run here had to be triaged before the real
`cannot find 'GoalSetupView' in scope` was trustworthy.

## 2026-08-28 — Uninstalling on the simulator does not clear the App Group container

`xcrun simctl uninstall <device> sardor.WaterBuddy` removes the app and its *own* container. The
**App Group** container is not the app's — it belongs to `group.sardor.WaterBuddy` — so it
survives, and `isGoalSet` stays `true`. Reinstalling therefore boots straight into `HomeView` and
the first-run screen cannot be reached.

To genuinely reach first-run state: `xcrun simctl erase <device>` (and re-apply any
`simctl ui … content_size` afterwards — erase resets that too).

**Why it matters:** two "verification" screenshots in this session were of the wrong screen before
this was understood. It is also a product fact worth knowing: on a real device a user cannot reset
their goal by deleting the app either, which is why "no way to change the goal after setup" is
recorded in `AI_CONTEXT.md` as tech debt rather than as a cosmetic gap.

## 2026-08-28 — `.minimumScaleFactor` will not prevent hyphenation on its own

At the accessibility sizes the setup title rendered as **"WaterBud-dy"** — the product's own name
broken across a line. Adding `.lineLimit(3)` and `.minimumScaleFactor(0.6)` did **not** fix it,
and the reason is worth keeping: with the break permitted, the text genuinely *fits* hyphenated,
so nothing ever asks it to scale down. `minimumScaleFactor` is a response to "does not fit".

The fix is to make not-fitting the only option — split the lockup by hand and give each line its
own `lineLimit(1)`:

```swift
VStack(spacing: 2) { Text("Welcome to"); Text("WaterBuddy") }
    .lineLimit(1)
    .minimumScaleFactor(0.5)
    .accessibilityElement(children: .combine)   // one greeting, not two stops
```

**Why it matters:** it is invisible at the default text size and only appears from about
`accessibilityLarge` up, so it survives every screenshot nobody took at a large size.

## 2026-08-28 — "Failed to get descriptors" is a missing widget, not a broken signature

Running the **WaterBuddyWidgetExtension scheme** on a physical device produced:

```
Failed to show Widget 'sardor.WaterBuddy.WaterBuddyWidget'
  SBAvocadoDebuggingControllerErrorDomain Code=1
  "Failed to get descriptors for extensionBundleID (sardor.WaterBuddy.WaterBuddyWidget)"
  … denied by service delegate (SBMainWorkspace)
… failed to launch or exited before the debugger could attach to it. Please verify that
"sardor.WaterBuddy.WaterBuddyWidget" has a valid code signature …
```

**The trailing code-signature sentence is boilerplate Xcode prints for any launch failure, and it
is misleading here.** Signing was fine. Verified, in this order:

| Checked | Result |
|---|---|
| `xcodebuild build -scheme WaterBuddyWidgetExtension -destination 'generic/platform=iOS'` | `** BUILD SUCCEEDED **` |
| Profiles | real ones resolved for both bundle IDs |
| `codesign -d --entitlements` on the `.appex` | carries `group.sardor.WaterBuddy` |
| `WaterBuddy.app/PlugIns/` | the `.appex` is embedded |
| merged `Info.plist` | `CFBundleVersion`, `CFBundleShortVersionString`, `NSExtensionPointIdentifier` all present |
| rule `40` interpolation trap | absent — both gallery strings are literals |

The real cause is the **inner** error. "Avocado" is SpringBoard's internal name for widgets;
running the extension scheme asks SpringBoard to *show* the widget so the debugger can attach, and
that needs descriptors WidgetKit only has once the widget exists on the device.

**Order that works:** run the **app** scheme → unlock the phone → launch the app once → add
*Hydration* from the Home Screen gallery → *then* run/attach the widget scheme.

Two device-side preconditions produce the same `SBMainWorkspace` "RequestDenied" on their own: a
**locked device**, and **Developer Mode** off (iOS 16+).

**Why it matters:** the error names code signing three times and the actual cause zero times.
Reading the innermost `NSUnderlyingError` first would have skipped the entire signing
investigation. If *Hydration* does not appear in the gallery, that is a genuine registration bug
and a different problem.

## 2026-08-28 — A defaulted dependency silently pointed every existing test at live data

Adding SwiftData meant `DataManager.init` gained a parameter:

```swift
init(defaults: UserDefaults = .sharedDefaults,
     modelContainer: ModelContainer = DataManager.sharedModelContainer,   // ← the hazard
     …)
```

The default resolves the **real App Group store**. Every one of the 74 existing tests called a
`makeManager` helper that did not pass one, so all 74 silently acquired live storage — running in
parallel, in one process, against one file. 17 of them failed; the other 57 passed *by luck*.

The failure looked like the refactor breaking the rollover and the goal logic. It was neither.

**The rule:** when a type gains an injectable dependency, the production default is the dangerous
one. Update the **test fixture in the same change** — every fixture in this repo already builds a
UUID-named `UserDefaults` suite for exactly this reason, and the container needed the same
treatment (`ModelConfiguration(isStoredInMemoryOnly: true)`).

**Why it matters:** a green suite would have meant nothing, and rule `85-testing`'s "no test ever
touches `group.sardor.WaterBuddy`" would have been violated by every test in the project.

## 2026-08-28 — A failed read must never be written back

`fetch` caught its error and returned `[]`. `recomputeToday()` summed that to `0` and wrote it
through the `currentWater` setter — which persists to the cache and rings the widget doorbell. So a
**transient read failure permanently destroyed the user's total**, and told the widget about it.

```swift
// before: indistinguishable from "no water today"
catch { return [] }

// after: the caller can tell the difference
catch { return nil }
```

`recomputeToday()` now `guard`s on that and leaves the figure exactly as it stands.

**The rule:** an empty result and a failed lookup are different facts. Collapsing them is only safe
when nothing writes the answer back. Here something did.

## 2026-08-28 — Stop at three failed fixes, and check what the product actually did

A UI test asserting a tap logs 250 ml failed four times reporting `750 → 0`. Three fixes went into
the *test* — an idempotent baseline, an exact-value wait instead of "any change", then a
data-destroying read bug that was real and worth fixing on its own.

Then reading the store directly ended it:

```
ZWATERLOG: 4 rows, SUM(ZAMOUNT) = 1000
cache:     currentWater => 1000
```

The product had done exactly the right thing, every time. Only the test's reading of the
accessibility value was wrong.

**The rule:** when a test and the code disagree, go and look at the ground truth before the third
fix, not after the fourth. `sqlite3` on the simulator's App Group container is one command, and it
would have settled this at attempt one.

## 2026-08-28 — A doc's git block goes stale the moment you stage after writing it

`AI_CONTEXT.md` said **"`.claude/` is still untracked, deliberately"** — true when written, false
about twenty minutes later, because the same session then staged all 25 files in it. The next
`/doc_sync` caught it only because the command insists on re-deriving the claim from
`git status` rather than trusting the paragraph already on the page.

The same pass produced a second, self-inflicted version of the same bug: a sentence claiming
"33 paths staged in total" written from a mental tally. The real number was **58**.
`tasks/lessons.md` already carried an entry about publishing an unverified count, and it happened
again anyway.

**Two habits:**

- **Write the git/staging block last**, after every `git add` the session is going to make — it is
  the only part of the doc describing state that a later step in the *same* session can invalidate.
- **Never write a number you did not just print.** `git diff --cached --name-only | wc -l` costs
  nothing. Any count in a doc — files, tests, paths — is a claim, and an unverified claim in the
  orientation document is worse than no claim, because it reads as having been checked.

## 2026-08-28 — The previews had the live-store bug the tests were fixed for

`tasks/lessons.md` already carried "A defaulted dependency silently pointed every existing test at
live data". The fixtures were fixed. **The two `#Preview`s were not**, and nobody looked:

```swift
let manager = DataManager(defaults: defaults, reloadWidgets: {})   // no modelContainer:
manager.addWater(amount: 1_150)                                    // → the REAL App Group store
```

`HomeView`'s preview wrote a real 1,150 ml row into the user's own `WaterBuddy.store` on every
canvas rebuild. The throwaway `UserDefaults` suite beside it made it *look* handled — which is
exactly why it survived: the line reads as though someone had already thought about isolation.

**The rule:** when a lesson is "a defaulted dependency is dangerous", grep for **every**
construction site, not just the ones the failing test named. `grep -rn "DataManager(" WaterBuddy/`
is one command and finds all four.

## 2026-08-28 — `.accessibilityElement(children: .ignore)` on a control adds a stop, it does not replace one

The vessel and the history header both use `.accessibilityElement(children: .ignore)` + label +
value, and it is right there — they wrap plain `Text`. Copying it onto a list row whose content is
a `Button` produced **two** elements:

```
Other,  label: '250 millilitres', value: 21:22     ← the wrapper
  Button, label: '250 ml, 21:22'                    ← the control, surfaced anyway
```

VoiceOver announced every serving twice. The fix is to put `.accessibilityLabel` / `.accessibilityValue`
on the button itself, the way `HomeView`'s pour button already does.

**Why it matters:** nothing in the unit suite can see an accessibility tree, and the screen *looks*
perfect. It only showed up in `app.debugDescription` from a real run on the simulator. When a view
adds a control, dump the tree once — the shape of the tree is the assertion.

## 2026-08-28 — A read path that re-derives can destroy the other process's write

Adding `recomputeToday()` to `refresh()` looked obviously right: re-derive today's total from the
source of truth on every foreground. `refreshPicksUpAnExternalWrite` failed immediately, and the
test was right.

`refresh()` runs when the app returns to the foreground — precisely when the *widget* may have
logged a serving. A cross-process SwiftData fetch can **succeed while returning stale rows**, so
re-deriving computes a smaller total, writes it over the extension's correct figure, and rings the
doorbell to announce the loss.

`republishTodaysLogs()` now publishes the rows (a read) and only mutation paths write the total.

**The rule:** the existing guard was `catch { return nil }` — "a failed read must never be written
back". This is the same rule one step out: **a read that did not throw can still be wrong**, and
whether it may be written back depends on whether this process is the one that knows the answer.
When a test disagrees with an "obviously right" change, the test is the finding.

## 2026-08-28 — `add` replaces, `remove` cannot be awaited: the asymmetry that shapes a reschedule

Three assumptions went into the reminders design and **all three were wrong**. The one that changed
the most:

> "A repeating `UNCalendarNotificationTrigger` can't be shifted, so rescheduling needs
> non-repeating per-occurrence requests."

Half right. Triggers *are* immutable (`UNNotificationTrigger.h:19`, `init NS_UNAVAILABLE`), but
`UNUserNotificationCenter.h:62` says plainly: **"Calling `-addNotificationRequest:` will replace an
existing notification request with the same identifier."** So a reschedule is one awaited `add`
under a stable id — not remove-then-add.

That matters because the two halves are not equally durable:

| | Awaitable? |
|---|---|
| `add(_:)` | **yes** — `async throws` |
| `removePendingNotificationRequests(withIdentifiers:)` | **no** — no completion handler, no async form |

…and Apple documents the removal as "execut[ing] asynchronously … on a secondary thread". A widget
extension only lives as long as the awaited work inside `perform()`, so a removal issued as the
process is torn down can vanish with no error path. A pass that only removes therefore has to end on
an awaited read, so the ordering guarantee carries it.

**The rule:** before designing around an API's shape, read the header for what it *replaces* and
check whether each call has a completion signal at all. "Asynchronous with no way to observe it" is
a real category, and it is invisible in the Swift signature — `remove…` just looks synchronous.

## 2026-08-28 — An app extension has no notification identity of its own

Whether the widget could cancel the app's reminders looked like a coin flip, and headers could not
answer it. Disassembling the shipping framework did:

```
+[UNUserNotificationCenter currentNotificationCenter]:
    CFBundlePackageType == "APPL" ?  mainBundle.bundleIdentifier
                                  :  [LSBundleProxy bundleProxyForCurrentProcess].un_applicationBundleIdentifier

-[LSPlugInKitProxy(UserNotifications) un_applicationBundleIdentifier] = containingBundle.bundleIdentifier
```

A widget `.appex` is `XPC!`, not `APPL`, so it takes the second branch and its centre is built with
**`sardor.WaterBuddy`**. Every daemon selector is `…ForBundleIdentifier:`. App and widget share one
pending set.

Two consequences worth more than the finding itself:

- **`removeAllPendingNotificationRequests()` from the widget would clear the app's entire set.**
  Only ever remove identifiers you can name.
- The extension has no *authorization* of its own either — it reads the app's, and cannot usefully
  prompt.

Still unproven: whether the **sandbox** permits the call at runtime. Framework addressing is not
sandbox permission, sandbox profiles are kernel-compiled and unreadable, and Apple denies this exact
call to Background Assets extensions. Design so a denial degrades instead of breaking.

**The rule:** when headers cannot answer a question the architecture rests on, the shipping binary
can. `otool -tV` on the simulator runtime is a legitimate source, and it beat both documentation and
a confident guess here.

## 2026-08-28 — The simulator's pending notifications are not a file you can read

`~/Library/Developer/CoreSimulator/Devices/<id>/data/Library/UserNotifications/` exists and looks
promising. It is not the pending set — `grep -r "sardor.WaterBuddy.reminder"` across the entire
device data directory returns **nothing** while 21 requests are genuinely scheduled. The set lives
in `usernotificationsd`, and `simctl` has no command to list it (`simctl push` only *sends* a
remote-shaped payload; it cannot verify a local schedule).

What works: the unit-test bundle is **hosted by the app**, so a throwaway `@Test` that calls
`UNUserNotificationCenter.current().pendingNotificationRequests()` runs in the app's own process,
under the app's bundle identifier, and prints the real set.

**The rule:** when host-side inspection fails, ask the app. A hosted test bundle is a process inside
the app, and that is often the only place a system framework will tell the truth.

## 2026-08-28 — Adding a row to a table is not the same as updating the table

The reminders pass added three files to `AI_CONTEXT.md`'s "Files on disk" block and, in the same
edit, left three *existing* rows stale — `DataManager.swift` still said 847 (it is 939),
`HistoryView.swift` 460 (479), `AddWaterIntent.swift` 77 (100). Every one of those files had been
edited by the very same change that added the new rows.

It is a specific blind spot: attention goes to the *new* entries, and the untouched-looking rows
read as already correct because they were correct when written. The block as a whole looked
freshly maintained, which is worse than looking out of date.

The whole `git status` summary underneath it had gone stale the same way — still claiming
`membershipExceptions → 4 files` and `.claude/rules/*.md (15)` when the answers were 6 and 18.

**The habit:** don't hand-patch a derived block, **re-derive the whole of it**. A dozen lines of
`python3` diffing the documented list against `find … -name '*.swift'` found all three drifts in
one pass, and the staging summary was better replaced by counts printed from
`git diff --cached --name-only` than by editing the numbers in place.

This is the third entry in this file about publishing an unverified number. The first two said
"never write a number you did not just print". This one adds: **a number you printed last week is
not a number you just printed**, and a table is a set of claims, not one claim.

## 2026-08-29 — Copying a fixture copies its omissions, and the default was the dangerous half

`HomeServingTests` got its `withTempStore` by copying `HistoryViewTests`'. That fixture passes
`defaults:`, `modelContainer:`, `calendar:`, `now:` and `reloadWidgets:` — and **not**
`rescheduleReminders:`, which defaults to `DataManager.requestReminderReschedule`:

```swift
rescheduleReminders: @escaping ([ReminderPlan.Slot]) -> Void = DataManager.requestReminderReschedule
```

That production closure builds a real `UNUserNotificationCenter` and reconciles against it. So
every `addLog` in the new suite reached the real notification service and could remove real pending
requests under `ReminderPlan.identifierPrefix` — which rule `85-testing` forbids outright, in the
line "❌ A test that constructs a real `UNUserNotificationCenter`".

This file already carries **two** entries on this exact trap: the one where a defaulted
`modelContainer:` pointed all 74 tests at the live store, and the one where the same bug survived
in the two `#Preview`s. This is the third, and the new part is *how it spread*: not by writing a
fresh call site, but by **copying a known-good-looking fixture**. The copy looked handled — five
arguments injected is a fixture somebody clearly thought about — which is exactly why the sixth
was invisible.

**The habit:** when you copy a fixture, diff its argument list against the initialiser, not against
the fixture you copied. `grep -n 'init(' DataManager.swift` and count. And note that the older
fixture still has the bug: copying propagated it forward without fixing it backward.

## 2026-08-29 — An annotation sized with its own text style will overtake a capped figure

Rule `65-accessibility` says: *"Size an annotation as a ratio of the figure it annotates, never
with its own text style… A ratio cannot invert."* The quick-add caption was written as
`.footnote` beside a glyph sized `servingDiameter * 0.34`, where `servingDiameter` is **capped**
at 104pt. At the default size those are both about 13pt and it looks deliberate.

At `accessibility-extra-extra-extra-large` the glyph is pinned at 35pt and `.footnote` is not, so
the caption rendered **visibly larger than the vessel it labels** — the exact inversion the rule
describes, reached by a different route than the widget case the rule was written from.

The cap is what makes it certain: any figure with a ceiling, annotated by anything without one,
crosses over eventually. `.font(.system(size: servingDiameter * 0.17, …))` cannot.

**Why it matters:** it is invisible at every text size anyone screenshots by default, the unit
suite cannot see a font size, and the rule that forbids it was already written down and still
did not stop it being introduced. Take the accessibility-size screenshot *before* claiming a
layout is done.

## 2026-08-29 — A `ScrollView` aligns its content leading, so it is the wrong default for a row that usually fits

The quick-add row was built as `ScrollView(.horizontal)` because it must scroll at the
accessibility sizes. At every size where the three buttons *fit* — which is nearly always — the
scroll view took the full width and aligned its content to the leading edge, so the row sat hard
against the left margin while the *Today's log* button below it stayed centred.

Nothing failed. 141 unit tests and 6 UI tests passed, both halves of the gate were green, and the
accessibility tree was correct. It was visible only in a screenshot.

`ViewThatFits(in: .horizontal) { row; ScrollView(.horizontal) { row } }` is the honest shape: the
common case is a plain, self-centring `HStack`, and the scroll view is reached only when the row
genuinely overflows. It also made the DocC true — the comment already claimed "a Dynamic Type
escape hatch, not a carousel", which the bare `ScrollView` was not.

**The rule:** a container chosen for the exceptional case will govern the ordinary one too. Ask
what it does when the exception does *not* apply.

## 2026-08-29 — A simulator remembers its rotation, and this app does not fit in landscape

A probe that taps a tab failed with:

```
Failed to scroll to visible (by AX action) Button, {{428.0, 427.7}, {315.0, 44.0}},
label: 'History', error: kAXErrorCannotComplete
```

The frame is the finding. An iPhone 16 is 393x852pt, so an origin of `x = 428` is nowhere on a
portrait screen — the device had been left in **landscape**, where the canvas is 393pt tall, the
vessel alone is 280pt, and the tab bar is pushed clean off the bottom.

Two separate facts came out of one error:

- **The app declares landscape support** — `INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone`
  still carries the Xcode template's `LandscapeLeft`/`LandscapeRight`, which nobody chose. The
  layout has never fitted there; the tab bar is what turned "clipped" into "unreachable".
- **A UI test that does not pin orientation is at the mercy of how somebody last rotated a
  simulator.** The same tap had passed minutes earlier in the full suite. Nothing about the code
  changed in between.

`XCUIDevice.shared.orientation = .portrait` in `setUp` makes the suite deterministic — and is
explicitly *not* a fix for the layout, which is recorded as tech debt instead.

**The rule:** read the frame in an accessibility error before reading the message. "Cannot scroll
to visible" is a coordinate problem, and the coordinates are printed right there. And a passing UI
test does not mean the device state it assumed is guaranteed — only that it happened to hold.

## 2026-08-29 — A `Material` pane's contrast cannot be reasoned about, only rendered and sampled

The tab bar's active tab was drawn in `Aurora.cyan` — glyph *and* label. Cyan is bright, the pane
is dark, and it looked obviously safe. It was not:

| | Measured | Floor |
|---|---|---|
| `Aurora.cyan` on the pane | **4.34:1** | 4.5:1 for small text — **fails** |
| white @ 0.72 | 4.89:1 | passes |
| white, full | 7.66:1 | passes |

The pane sampled at sRGB `(0.388, 0.282, 0.484)` — much lighter than "dark glass over a dark
backdrop" suggests, because `.frosted` over the aurora's magenta lobe is genuinely a mid purple.

**The number was not derivable.** `LiquidGlass.Base` in the app is a `Material`, which samples
whatever is behind it; there is no token to compute from. The only honest route is to render the
bar, screenshot it, and read the pixels — which took one throwaway probe and twenty lines of Swift
using `NSBitmapImageRep` and the WCAG luminance formula.

The fix keeps the design: an **icon is not text**, so its floor is 3:1 and 4.34:1 clears it. The
glyph stays cyan and keeps its glow; the label went white. State is carried by the thing that is
allowed to carry it.

**The rule:** when a colour lands on a `Material`, "it looks like plenty of contrast" is not a
measurement and the palette cannot tell you either. Render it and sample it, and write the number
down — `docs/DESIGN.md` has a section for exactly this, and every figure in it exists because
somebody checked rather than assumed.

## 2026-08-29 — The device you do not normally run on is where stale copy shows up

Booting an iPad *once* — to check whether landscape genuinely fitted before deciding not to
restrict it — put this on screen:

```
Nothing logged yet today
Tap + on the home screen to log 250 ml.
```

There has been no `+` for two checkpoints. The quick-add row replaced it, and that copy sat in
`HistoryView`'s empty state the whole time, on every device, unread.

It survived because of *where* it lives: an empty state only renders when there is nothing logged,
and every screenshot taken during the row work was of a store with rows in it. The iPad had a fresh
container, so it was empty, so the copy drew.

Worse, the line had a comment above it explaining that the amount was spelled from
`DataManager.standardServing` "so this copy cannot drift from what the buttons actually do". That
was true and it still missed: the constant did not drift, the **product** did. Three vessels make
naming any one of them wrong, so the replacement names no amount at all.

**Two habits:**

- **Empty states need their own look.** They are the one screen guaranteed not to appear in normal
  use, which is exactly why nobody sees them go stale. `simctl erase`, or a fresh device, once per
  feature that changes what the user is told to tap.
- **"Spelled from the constant" protects against one kind of drift only.** It pins copy to a value.
  It does not pin copy to a *gesture*, a control that still exists, or a screen that still has one
  button rather than three.

## 2026-08-29 — A rule written into two of its five homes is a rule that will be broken

The one-simulator rule was added to `.claude/rules/85-testing.md` (the authority) and to
`CLAUDE.md` (which restates the gate). Five files in this repo actually spell an `xcodebuild`
command, and the other three were missed:

```
.claude/rules/85-testing.md      -parallel-testing-enabled NO   ✓
CLAUDE.md                        -parallel-testing-enabled NO   ✓
.claude/commands/doc_sync.md     no flag
.claude/commands/start_task.md   no flag
.claude/commands/commit.md       no flag
```

It surfaced immediately and in the most direct way possible: `/doc_sync`'s own verification section
instructed the run to execute the gate **without** the flag, one turn after the flag became
mandatory. A command file is not documentation of the workflow — it *is* the workflow, read aloud
into the next session's context.

**The habit:** when a rule constrains a *command*, `grep` for every place that command is written
down before calling the change complete. `grep -ln xcodebuild .claude/**/*.md CLAUDE.md` is one
line and finds all five. The same applies to the gate's other half, to `simctl`, and to anything
else a future session will copy-paste out of a command file rather than re-derive.

Related, and the reason this is its own entry rather than a footnote: `tasks/lessons.md` already
carries three entries about publishing an unverified number, and one about a table being "a set of
claims, not one claim". This is that shape again at a different altitude — **a rule is a set of
copies, not one copy.**

## 2026-08-29 — An inferred flag is not a stored flag, and a guard on the in-memory value loses the difference

`saveDailyGoal(ml:)` ended with:

```swift
guard !storedIsGoalSet else { return }
withMutation(keyPath: \.isGoalSet) {
    storedIsGoalSet = true
    defaults.set(true, forKey: Key.isGoalSet)   // the ONLY write of this key in the product
}
```

That was correct for as long as it had one caller. `GoalSetupView` is presented **only** while
`isGoalSet` is `false`, so the guard could never short-circuit and the key was always written.
Adding a second caller — `SettingsView`'s `GoalCard` — made the short-circuit reachable, and it
takes the key with it.

The state that breaks is the upgrade path, which is deliberate and tested elsewhere:
`resolveIsGoalSet(in:goal:)` **infers** `true` from a non-default stored goal when the key is
absent, and rule `25-shared-storage` forbids materialising the key. So an instance can hold
`storedIsGoalSet == true` with *nothing on disk behind it*. Edit that goal down to exactly
`defaultDailyGoal` and the write is skipped; the next `resolveIsGoalSet` re-derives
`2_000 != 2_000` = `false`; `RootView` cross-fades the whole app back into setup, mid-session, for
a user who only moved a slider.

The fix separates two things that had been fused into one guard:

```swift
// Persistence — on the KEY, whatever this instance believes.
if defaults.object(forKey: Key.isGoalSet) as? Bool != true {
    defaults.set(true, forKey: Key.isGoalSet)
}
// Observation — still guarded, so a no-op save does not redraw the root gate.
guard !storedIsGoalSet else { return }
withMutation(keyPath: \.isGoalSet) { storedIsGoalSet = true }
```

**The habit, and it generalises past this key:** whenever a value can be *derived* as well as
*stored*, an equality guard written against the derived value is not the same guard as one written
against the store. Ask which of the two the next reader actually reads. Here the next reader is
`resolveIsGoalSet`, and it reads the key.

**And the meta-lesson, which is the reason this is its own entry:** the bug was introduced by a
change that never touched `saveDailyGoal`. Adding a *second call site* to a function is an edit to
that function's preconditions — every `guard` in it that was previously unreachable becomes live
code. `tasks/lessons.md` already carries "a rule is a set of copies, not one copy"; this is the
same shape once more — **a guard is a claim about its callers, and it silently expires when you add
one.**

## 2026-08-29 — A verification probe can fail for being wrong about the product, and pass for testing nothing

The temporary UI probe written to prove `GoalCard` works got both failure modes in one run.

**It failed on an assertion that could never pass.** It queried the accessibility tree for the
card's readout — but `readoutRow` carries `.accessibilityHidden(true)` *by design*, because the
slider beside it announces the label and the value as one sentence and rule `65-accessibility`
forbids the duplicate stop. The product was right; the probe was asking through a channel the
product deliberately closed. `tasks/lessons.md` already records a session where four fixes went
into a test that was misreading an accessibility value. Same trap, one turn later: **before
changing anything, read the store.** The App Group plist said `dailyGoal => 2500`. The feature had
worked on the first run.

**And it passed while proving nothing.** The Dynamic Type check launched with

```
-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge
```

which is not a content size category — the raw value is `UICTContentSizeCategoryAccessibilityXXXL`.
An unrecognised value is not an error: the app launches at the **default** size, every assertion
passes, and the screenshot is a default-size render wearing an accessibility-size filename. Caught
only by comparing it against the earlier screenshot and noticing the text had not moved.

**The habit:** a test for a *condition* must assert that the condition took hold, not only that the
subject survived it. The probe now also asserts the reminders explanation — the one string on that
screen with no `minimumScaleFactor` to hide the change — is present and reflowed. A passing test
whose setup silently no-op'd is worse than a missing one, because it is counted.

## 2026-08-29 — A synchronized-folder `membershipException` carries source, not resources — and the build deletes the entry

The app and the widget need the same localized strings: `NotificationManager` is one of the six
shared files, and `AddWaterIntent` files reminders from the extension. The obvious move was to put
`Localizable.xcstrings` in `WaterBuddy/` and add it to the widget's `membershipExceptions`,
alongside the six shared `.swift` files. One declaration, two bundles, exactly the contract rule
`15-project` already describes.

**It does not work, and it fails in the most expensive way available: quietly.**

- `xcodebuild` ran `xcstringstool` **once**, `--output-directory …/WaterBuddy.build` — the *app*
  target's build directory. The extension never got a compile step.
- `WaterBuddyWidgetExtension.appex` came out with **no `.lproj` at all**. The app had `ru.lproj`
  and `uz.lproj` with 43 strings each, so every check aimed at the app passed.
- Then the build **rewrote `project.pbxproj` and removed the entry.** A `diff` against the
  pre-change backup showed only the `knownRegions` addition surviving. Xcode did not warn, it
  normalised.

The fix is a second catalogue in `WaterBuddyWidget/`, which is that target's own synchronized root
and joins with no project edit at all. That reintroduces exactly the duplication the shared-file
contract exists to prevent, so it is covered by `LocalizationTests` instead — the widget's table
must be a subset of the app's, value for value, in every language.

**The habit:** `membershipExceptions` is for *compiled sources*. For anything that lands in a
resources phase, each target needs its own copy. And when a project-file edit is meant to change a
build, diff `project.pbxproj` **after** the build, not just before — the toolchain edits that file
too, and an entry it silently drops looks identical to an entry you forgot to add.

## 2026-08-29 — A test that reads the source tree does not fail on the simulator, it hangs the gate

The first version of `LocalizationTests` compared the two `.xcstrings` files by reading them off
disk, locating the repo with `#filePath`. It looked reasonable and the path arithmetic was correct.

The gate then ran for **over ten minutes and had to be killed** — twice, once as the full run and
once as the unit half alone. The log's last line was
`◇ Test bothCataloguesAreEnglishSourced() started.`

Unit tests here are **hosted by the app and execute on the simulator**. The repo lives under
`~/Desktop`, which macOS protects with TCC. A simulator process reaching a host path there blocks
waiting on a privacy prompt that a headless `xcodebuild` run can never answer. Not a crash, not a
failure — an indefinite stall that reads exactly like a slow build.

Two things follow, and the second is the more useful:

1. **Assert the artifact, not the inputs.** The rewritten suite reads the *built* bundles —
   `Bundle.main` for the app, `PlugIns/…appex` for the extension — via
   `localizedString(forKey:value:table:)`. That is strictly better anyway: it is what actually
   ships, and it is what caught the `membershipExceptions` failure above. Reading the `.xcstrings`
   would have shown two healthy files while the widget shipped English.
2. **A hung gate is a bug report.** The instinct was "the build got slow after the pbxproj edit".
   The log said otherwise: the last line names the test that never returned. `pgrep` plus the tail
   of the log located it in under a minute, where re-running would have cost another ten.

## 2026-08-29 — "The translation differs from the key" cannot detect a missing translation

The presence check for a localized string started as:

```swift
#expect(resolved != key, "falls back to English")
```

It failed on `%1$d ml` and `+%1$d ml` in Uzbek — both **correct**, and both identical to the
English, because Uzbek also writes `500 ml`. `localizedString` returns the key when a lookup misses,
so "equals the key" conflates *not translated* with *translated to the same string*.

The honest fix strengthens the assertion rather than relaxing it: ask the table whether it holds the
key at all, using a sentinel default no translation could ever be.

```swift
let resolved = lproj.localizedString(forKey: key, value: missingMarker, table: nil)
return resolved == missingMarker ? nil : resolved
```

**The habit:** when a check's failure mode and its success mode can produce the same value, the
check is measuring the wrong thing. Look for an API that answers the question directly — here,
`value:` exists precisely so a caller can tell "absent" from "present and equal".

Related and worth knowing on its own: **`contains(where:)` is `rethrows`, so it cannot sit inside
`#expect`** — the macro's expansion has nowhere to write the `try`. Hoist it into a `let` first.
This is the same family as the `Comment`-takes-a-literal entry above, which also bit this session
when an `#expect` message was built with `+` instead of one interpolated literal.

## 2026-08-29 — A String Catalogue emits no `.lproj` for its own source language

`AppLanguage.english.bundle` resolves `Bundle.main.url(forResource: "en", withExtension: "lproj")`.
With `"sourceLanguage": "en"` and only `ru`/`uz` localisations in the catalogue, **there is no
`en.lproj`** — the development language lives in the binary. So the lookup returned `nil` and the
resolver fell back to `Bundle.main`.

`Bundle.main` is not English. It is *the device's* language. So on a Russian phone, choosing
**English** in the picker would have kept drawing Russian — the one failure a language switcher
cannot afford, because the user's own language is the only thing they can actually verify.

The fix is to give every key an explicit `en` value in the catalogue, which makes the build emit
`en.lproj` alongside the other two:

```python
for key, entry in catalogue["strings"].items():
    entry.setdefault("localizations", {})["en"] = unit(key)
```

**The habit:** "the source language" and "a language you can select" are different things. Anywhere
a default is *implicit* — the development region, `Bundle.main`, `Locale.current` — it resolves to
whatever the environment says, not to the value you had in mind when you wrote it. If a user can
choose it, it needs to exist as a thing, not as an absence.

Related, and the reason the switch works at all: **iOS resolves `Bundle.main`'s localisation once
at launch and never again.** No amount of writing `AppleLanguages` changes the running process. The
only way to switch live is to stop asking `Bundle.main` — every string in this product now resolves
through `EnvironmentValues.strings`, injected at each root from the model. That is also why
`AppTab.title` and `HomeView.Serving.name` had to become *functions taking a bundle*: both were
`static let`s resolved once at first access, which froze them in whatever language the app launched
in even after everything around them had switched.

## 2026-08-29 — `#available` cannot stand in for an SDK you do not have

The owner asked for Apple's Liquid Glass — `glassEffect(_:in:)`, `GlassEffectContainer`,
`glassEffectID`, `.buttonStyle(.glass)` — to be applied to WaterBuddy's elements.

```
Xcode 16.4 · the only installed SDK is iphoneos18.5
every one of those symbols ships in the iOS 26 SDK
```

The instinct is "guard it with `if #available(iOS 26, *)` and ship both paths". **That does not
work, and the distinction is worth holding onto:** an availability guard is a *runtime* check
against the deployment target. It lets you call a symbol the compiler can already see, on an OS old
enough not to have it. It cannot conjure a declaration the SDK does not contain — with only the
18.5 SDK, `glassEffect` is not "unavailable", it is *undeclared*, and the build fails at name
resolution long before availability is considered.

So the honest answer was: report the blocker, and offer what the *guidance* can buy without the API.
That turned out to be real — Apple documents `Glass.interactive()` as glass that "reacts to touch
and pointer interactions in real time", and WaterBuddy's hand-rolled system had no equivalent:
`PressStyle` recoiled the frame while the material sat inert. Adding that was a genuine improvement
traceable to the doc.

**The habit:** before promising an API, check `xcodebuild -showsdks`, not just the deployment
target. "We support iOS 18" and "we can compile against iOS 26" are independent facts, and only the
second one decides whether code exists.

## 2026-08-29 — You cannot measure a control that scales by sampling a fixed rectangle

Proving the pressed glass was actually brighter meant sampling pixels from a real mid-press frame.
The first measurement said the opposite:

```
120x120 box over the button      rest 135.5  ->  pressed 129.7   "darker"
```

`PressStyle` scales a pressed button to **0.93**. A fixed box therefore contains a smaller button
and *more dark backdrop* while the finger is down, and the shrink swamped the effect being measured.
The control patch of bare backdrop was flat across all three frames, which is what proved the
problem was the box and not the aurora.

The fix was a sample region that is inside the control in **both** states and clear of its white
glyph — a band 45–75px from the centre of a ~109px-radius circle that shrinks to ~101:

```
30x30 band, left of the glyph    rest 84.6   ->  pressed 91.3    +7.9%
30x30 band, right of the glyph   rest 78.8   ->  pressed 83.2    +5.6%
control, bare backdrop           rest 86.5   ->  pressed 86.5     0.0%
```

**The habit:** when measuring a thing that also *moves or resizes*, the measurement window has to be
valid in every state being compared, and there has to be a control region that should not change. A
number that moved is not evidence until you know what else moved with it.

## 2026-08-29 — A String Catalogue is half contract and half build output, and the build half is where the gaps hide

`WaterBuddyWidget/Localizable.xcstrings` was written by hand with exactly 10 keys — the strings the
extension draws or files, copied from the app's catalogue so the two could not drift. A `/doc_sync`
verification pass found **19**.

Xcode's build extracts every `Text`, `Label` and `LocalizedStringResource` literal in a target and
appends it to that target's catalogue. So the file is not a contract you author; it is a contract
you author *plus* whatever the compiler found. Nine keys had arrived on their own, every one of them
with no localisations at all:

```
%                                             deliberate — a symbol
+%lld  ·  1,450 ml  ·  Today                  dead: extracted before those Text sites
                                              became String(format:), now produced by nothing
Log Water                                     AddWaterIntent.title
Adds a serving of water to today's total…     IntentDescription
Amount  ·  Millilitres of water to log.       @Parameter title and description
Log ${amount} ml of water                     parameterSummary
```

The last five are `AddWaterIntent`'s **entire Shortcuts-facing vocabulary**. A Russian user who adds
the WaterBuddy action gets an English one, while the widget beside it draws Russian.

Two habits out of it:

**Read the catalogue, not your memory of it.** The count you wrote and the count on disk diverge
silently, and the divergence is exactly where the untranslated strings are. `len(json.load(...))`
against the doc's claim took one line and found this; nothing else had, across two passes.

**A coverage check is only as wide as the bundle you point it at.**
`everyDrawnStringIsTranslatedUnlessDeliberatelyNot` compares the app's English table against its
Russian one and would have caught all five instantly — it just never looked at the `.appex`. The
earlier `Delete` finding came from that same check working; this one is the same check not being
aimed. When a test proves something valuable about one artefact, ask which *other* artefacts it
should be proving it about.

And a constraint worth knowing before attempting the fix: `LocalizedStringResource` and `@Parameter`
arguments must be **compile-time constants**, so they cannot take a runtime bundle the way
`Text(_:bundle:)` can. Translating them makes Shortcuts follow the *device* language; making it
follow the app's in-app picker may not be possible at all.

## 2026-08-30 — A `Text` can truncate because it is *squeezed*, not because it is too wide

The week card's disclosure line carried `.lineLimit(2)` and still rendered as
**"Measured again…"** at `AccessibilityXXXL`. The instinct is a width problem, and it was not: the
card sits above `HistoryView`'s `List` in a plain `VStack` with no outer `ScrollView`, so at large
text sizes the stack is **vertically** compressed and `Text` responds by giving up lines rather
than by pushing back. `.fixedSize(horizontal: false, vertical: true)` is what makes it claim the
height it needs; the line limit was never the constraint doing the truncating.

The figures line beside it failed for the *other* reason and needed a different fix.
`"Average %1$d ml · Best %2$d ml"` with `.lineLimit(1).minimumScaleFactor(0.6)` truncated to
**"Average 2871 ml · Best…"** — at `AccessibilityXXXL` a `.footnote` is around 44pt, so even at the
0.6 floor the sentence is wider than the pane. Allowing it to wrap then produced a second line
beginning with the separator: **"· Best 8050 ml"**. The fix was to stop treating it as one string:
two keys and `ViewThatFits(in: .horizontal) { HStack; VStack }`, so the row becomes a column when
it has to. That is the shape rule `65-accessibility` already prescribes for scaled content that
overflows, and it hands a translator two independent phrases instead of one word order.

**Three habits:**

- Ask **which axis** is truncating before reaching for `lineLimit` or `minimumScaleFactor`. A
  container with no scroller above a `List` compresses vertically, and that failure looks identical
  to a width failure in a screenshot.
- `minimumScaleFactor` has a floor, and at the accessibility sizes the floor is not enough. It
  buys about 40%; a `.footnote` grows by roughly 300%.
- A separator baked into a format string becomes a dangling character the moment the string wraps.
  If two figures might stack, they are two strings.

## 2026-08-30 — The contrast rule caught a second violation, in the same way, one screen later

`tasks/lessons.md` already carries *"A `Material` pane's contrast cannot be reasoned about, only
rendered and sampled"*, written when the tab bar shipped `Aurora.cyan` at 4.34:1 against a 4.5:1
floor. The week card was built with that entry in the file and introduced the same class of defect
anyway: the disclosure caption at `white.opacity(0.55)` measured **4.06:1**, and the weekday
captions at `0.60` measured **exactly 4.50:1** — the floor itself, with no margin.

What is new is the **sampling method**, and it is the part worth keeping:

```
pane at the card's head   sRGB (0.191, 0.244, 0.376)   L = 0.0497
pane at the card's foot    sRGB (0.214, 0.283, 0.398)   L = 0.0640   ← the aurora is lighter here
```

The pane is not one colour. It is a `Material` over a moving gradient, so it is measurably lighter
at the bottom of a 223pt card than at the top, and **the ratio must be computed against the lighter
end** because that is the worst case for white ink. Sampling the top alone would have reported the
disclosure line as passing and shipped the violation.

**The habit:** a sampled contrast figure is only as honest as the worst pixel under the text.
Sample a pane at both ends of the text it carries, take the lighter one, and leave margin — a
figure that lands exactly on the floor is a figure that fails as soon as anything moves, and in
this app the backdrop is animating continuously.

## 2026-08-30 — A measured number can be real and still measure the wrong thing

The week card's bars were published in `docs/DESIGN.md` at **3.33:1**, sampled off a rendered bar
exactly as the earlier tab-bar lesson prescribes. The number was honest. It was also the wrong
number: the fill was a `Aurora.blue` → `Aurora.cyan` gradient, and a patch of a *short bar* is the
average of that gradient across its whole height, not the value at its blue endpoint. Pure
`Aurora.blue` on that pane is **2.72:1** — under the 3:1 non-text floor — and a nearly-empty day is
drawn almost entirely in that end.

It survived because the sampling method was right and only the *target* was wrong. "I rendered it
and read the pixels" felt like the end of the argument.

**The habit:** when the thing being measured varies across itself — a gradient, an animation, a
material over a moving backdrop — sampling it gives you a number about *that patch*, not about the
colour. Identify the extreme the colour actually reaches and compute against that. Rendering tells
you what a token composites to; it does not tell you which token to composite.

Related, and the reason this was caught at all: an eight-candidate adversarial review confirmed
**zero** findings, and two of the refutations were wrong. Both were 2-of-3 splits with one
dissenter. **A split verdict is not a refutation** — it is a disagreement worth resolving yourself.
Both dissenters turned out to be right, and both findings were real.

## 2026-08-30 — A saturation test that never reaches the overflow branch

`theDailyTotalSaturatesRatherThanTrappingOnACorruptRow` fed `[Int.max, 500]` and asserted the day
saturated at `maximumDailyIntake`. It passed. It also passes with a plain `+`:

```
running = 0        + Int.max  -> no overflow, min() clamps to 100_000
running = 100_000  + 500      -> no overflow
```

The clamp produces the right answer on its own, so the test pins the clamp and says nothing about
`addingReportingOverflow`. Reverse the order and the guard becomes the only thing between a corrupt
store and a crash:

```
running = 0        + 500      -> 500
running = 500      + Int.max  -> OVERFLOW  (a plain '+' traps here)
```

`fetch(_:)` returns rows newest-first, so which order a corrupt row arrives in is not something the
code gets to choose — both belong in the suite.

**The habit:** for a test whose subject is a *guard*, ask what the code would do with the guard
removed. If the answer is "the same thing", the test is aimed at something else — usually at a
clamp or a default sitting next to the guard. Tracing the arithmetic by hand took one short script
and settled it; three adversarial verifiers had all said the finding was wrong.

## 2026-08-30 — The doc section nobody re-derived was the one describing something that never existed

`docs/AI_CONTEXT.md` carried a **### Git** section across several `/doc_sync` passes describing
`HEAD = 2095ff0` on `main`, **83 paths staged**, a self-consistent index that "builds", and a
line-by-line breakdown of its composition — `26 .claude/`, `14 WaterBuddy/`, and so on. It even
carried the caveats you write only after looking: that git recorded a particular file as a rename
rather than a delete-plus-add, and that `git ls-files --others --exclude-standard` was empty.

There is no `.git` directory. There never was one in this tree. One command settles it:

```
$ git rev-parse --short HEAD
fatal: not a git repository (or any of the parent directories): .git
```

`tasks/lessons.md` already carries three entries about publishing an unverified number, and the
`/doc_sync` command grew a verification checklist because of them. Every item on that checklist
re-derives something — the file list from `find`, the `@Test` count from the attribute grep, the
shared six from `project.pbxproj`. **None of them covered the Git section**, so it was the one block
that got *edited* forward each pass instead of *recomputed*, and editing a paragraph forward
preserves whatever was wrong in it. The richness of the detail is what made it credible: nobody
invents an `R059` rename by accident, so it read as observed.

**Two habits:**

- A verification checklist protects exactly the claims it enumerates, and nothing else. When you add
  a section to a derived document, ask what command re-derives it — and if the answer is "none", the
  section is prose about state, which is the kind that rots silently.
- **The most detailed paragraph is not the most trustworthy one.** Specificity is evidence that
  somebody once looked; it is not evidence that the thing is still true, and in a doc that is edited
  forward it is not even evidence that it was ever true.

Corrected here rather than deleted: the section now shows the failing command and states plainly
that every previous edition of it was wrong, because a doc that silently drops a false claim teaches
the next reader nothing.

## 2026-08-30 — A memberwise initialiser is a field list, and a field list rots

`getTimeline` built the widget's midnight entry by enumeration:

```swift
HydrationEntry(date: midnight, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: current.dailyGoal))
```

`WaterSnapshot.language` carries `= .system`. So **every field the author did not name was silently
reset at local midnight**, and a user who chose Russian in the app watched the widget revert to the
*device* language overnight and stay there until something else reloaded the timeline. That is the
one failure rule `70-privacy` names explicitly — "the widget takes its language from
`entry.snapshot.language`, never `Bundle.main` or the device locale" — shipped for two releases.

Nothing could see it. The app scheme does not compile the widget's sources; the widget's rendering
has no automated coverage at all; and the bug needs a *language change plus a midnight* to appear.
It was found by an agent reading `getTimeline` while mapping an unrelated feature.

The fix is not "remember the field". It is to make forgetting impossible:

```swift
func rolledOver() -> WaterSnapshot {
    var next = self
    next.currentWater = 0
    return next
}
```

Copy and clear, so any field added later is carried for free. The test asserts the **whole value**
(`midnight == evening` after zeroing the receiver's total) rather than a list of fields, so it
cannot go stale the way the initialiser did.

**The habit:** a memberwise initialiser called with a subset of arguments is a *list of fields that
was correct when it was written*. Every default it relies on is a silent reset. When one value is
derived from another, express it as a transformation of the whole — the compiler cannot warn you
about a default you meant to override, but it also cannot drop a field you never enumerated.

Related: this is the same shape as `tasks/lessons.md`'s "adding a row to a table is not the same as
updating the table". Enumerating is the failure mode; deriving is the fix.

## 2026-08-30 — `MainActor.assumeIsolated` is a `precondition` wearing a different name

Making the quick-add amounts editable meant `HomeView.servings` had to read them off the model. The
first shape was `nonisolated static func servings(for manager: DataManager)`, reaching a
`@MainActor` property from a `nonisolated` function the only way that compiles without an `await`:

```swift
let amounts = MainActor.assumeIsolated { manager.servings }
```

It compiled, and the `@MainActor` suite passed. `WaterSnapshotTests` then failed to compile, because
it is deliberately **not** `@MainActor` — and that is the canary working. Had the suite been
annotated to make it build, the call would have *trapped at runtime* the first time anything
off-main reached it.

`assumeIsolated` does not assert an isolation, it **assumes** one and crashes when wrong. Rule
`75-diagnostics` records that this codebase contains no `fatalError`, `assertionFailure` or
`precondition`; this would have been the first, hidden inside a helper that reads like a getter.

The fix removes the question instead of answering it: pass the state, not the thing that holds it.

```swift
nonisolated static func servings(amounts: [Int]) -> [Serving]
```

The caller is a `body`, already on the main actor, so it reads `manager.servings` and hands the
array over — and that read is also what registers the observation that redraws the row.

**The habit:** when a `nonisolated` helper needs actor-isolated state, the isolation is telling you
the *parameter list* is wrong, not that you need an escape hatch. And a suite that refuses to
compile is the cheapest possible version of this bug — annotate the declaration it reads, never the
suite.

## 2026-08-31 — A doc's prose and its code sample are two places, and only one gets edited

`docs/WIDGET.md` was updated during the editable-vessels change: its language section gained a
paragraph explaining that `rolledOver()` now carries every field across the midnight entry, and why
the old memberwise call had been silently resetting the language. Careful, specific, correct.

Twenty lines above it, the fenced sample under **### The timeline** still read:

```swift
HydrationEntry(date: midnight, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: current.dailyGoal)),
```

The exact line that had been fixed. The same document explained the bug in prose and demonstrated
it in code.

It survives because a prose edit and a code sample are reached by different searches. Grepping for
`standardServing` found every stale *name*; nothing in that sweep was looking for a stale *shape*,
and the sample contained no renamed symbol at all — every identifier in it is still valid, which is
why no compiler, no grep and no reviewer's eye caught it.

**The habit:** when a change alters how something is *constructed*, grep the docs for the old
construction, not only for the old names. And treat a fenced code block as its own claim with its
own verification — `grep -F` the exact line you deleted from the source across `docs/`, because a
sample is the one part of a document a reader will copy.

## 2026-08-31 — A borrowed contrast figure held, and that was luck

`ServingsCard` shipped citing the week card's **5.49:1** for its disclosure line — a figure measured
on `HistoryView`, reused on `SettingsView` because both cards are `.frosted`/`.raised`. That is
borrowing, not measuring, and `tasks/lessons.md` already says to sample the pane the text lands on.

Measured properly afterwards, it holds — and the reason is worth keeping:

```
week card pane, foot      sRGB (0.214, 0.283, 0.398)   L = 0.0640
Settings card pane, foot  sRGB (0.350, 0.227, 0.440)   L = 0.0631
```

The two panes are **visibly different colours** — the Settings card sits lower, over the aurora's
magenta lobe — and their *luminance* is near-identical, so white at 0.70 lands on 5.50:1 either way.

Contrast is a luminance relationship, so hue can move a long way without touching the ratio. That is
why the borrow survived, and precisely why it cannot be a method: nothing in the design guarantees
two panes share a luminance, and the next card placed somewhere else has no such guarantee. A figure
that happens to be right is indistinguishable, in the diff, from one that was checked.

**The habit:** when reusing a measured number on a new surface, either measure it there or write
"borrowed from X, unverified" beside it. The cost of measuring was one screenshot already on disk
and twenty lines of arithmetic.

## 2026-08-31 — A known-issue entry is a document, and its numbers rot like any other

`docs/AI_CONTEXT.md` known issue #6 opened with a precise, confident count:

> Six of the eight `DataManager(` sites in the test target omit `rescheduleReminders:` … Re-counted
> this pass — every earlier edition of this document named only `HistoryServingTests`, understating
> it by five.

The entry had already been corrected once, *by counting*, and said so. It was still wrong. Grepping
the tree before starting the fix found **eleven** sites, not eight — `ServingSeamTests` and
`HistoryRangeTests` had each added construction sites afterwards, and all three of the new ones were
correct. So the six named were exactly right and the denominator was two changes stale.

Nothing bad followed from it here, because the numerator is what you act on. But the failure mode is
obvious once seen: a known issue is written at the moment of discovery and then *read* at the moment
of repair, and everything between those two moments is invisible to it. A count is the part most
likely to have moved, and the part a reader is most likely to trust — it looks like a measurement,
not a claim.

**The habit:** re-derive a known issue's numbers before acting on it, and record the delta in the
checkpoint. One `grep -rn 'DataManager(' WaterBuddyTests/` cost nothing and is what turned "apply the
six one-line patches this entry prescribes" into "look at the shape of all eleven first" — which is
where the factory came from.

## 2026-08-31 — When both obvious guards are forbidden, the guard is the fixture watching itself

Six test fixtures were reaching a real `UNUserNotificationCenter` because they let
`rescheduleReminders:` default. Two guards suggest themselves immediately, and this repo forbids
both:

- **Count the call sites from a test.** A test that reads the source tree does not fail on the
  simulator — under TCC it *hangs the gate* (recorded above, 2026-08-29).
- **Inspect the real pending set and assert it was untouched.** Rule `85-testing` forbids a test that
  constructs a real centre outright, which is the very thing being guarded against.

That looked like "this defect is not test-drivable; fix it and rely on review". It is not. The thing
that *is* observable from inside the process is the seam **firing**: hand the fixture a spy and
assert it was called.

```swift
@Test func theStoreFixtureRoutesTheReminderPlanToTheInjectedSeam() throws {
    var plans = 0
    try withTempStore(onReschedule: { _ in plans += 1 }) { manager, _ in
        manager.addLog(amount: 250)
    }
    #expect(plans > 0, "the fixture is reaching a real UNUserNotificationCenter")
}
```

Delete the argument from the fixture and the counter stays at zero. It does not detect a *new*
fixture written wrong — nothing available here can — but it permanently pins the ones that exist,
which is the half that kept regressing. `DataManagerTests` turned out to have had this guard all
along without anyone naming it: `togglingRemindersRePlansImmediately` fails on the same condition,
which is why that file's fixture is the one that never rotted.

And the RED was watchable rather than a compile error, which mattered for confidence: adding the
parameter to the fixture's *signature* first and leaving it unwired builds clean (an unused Swift
parameter raises no warning), so the two new tests failed on `(plans → 0) > 0` while all 250 existing
tests stayed green. That intermediate state is not a contrivance — a fixture that accepts a seam and
ignores it is behaviourally identical to one that never had it.

**The habit:** when a defect's direct assertion is forbidden, do not conclude it is unguardable. Ask
what the correct code *does* that the broken code does not, and assert that instead. Here the
difference was one closure call.

## 2026-08-31 — `-only-testing:` without the parentheses passes vacuously

The first RED run was filtered to the two new tests:

```
-only-testing:WaterBuddyTests/WaterLogStoreTests/theStoreFixtureRoutesTheReminderPlanToTheInjectedSeam
```

Output:

```
Executed 0 tests, with 0 failures (0 unexpected) in 0.000 seconds
** TEST SUCCEEDED **
```

Two tests that were *supposed to be failing* reported success. swift-testing test identifiers carry
the parentheses — `…theStoreFixtureRoutesTheReminderPlanToTheInjectedSeam()` — and without them the
filter matches nothing, runs nothing, and exits zero.

This file already carries two entries on the same shape from a different direction: a probe that
queried an accessibility tree the product deliberately closed, and
`UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge`, which is not a real category name and so
launched the app at the default size while every assertion passed. Same failure, third costume: **the
harness silently did nothing, and reported that nothing as success.**

It was caught here only because the run was *expected* to be red, and green was the surprise. Filtered
to a test expected to pass, it would have sailed through.

**The habit:** read the executed-test count, never the exit status, on any filtered run — `Executed 0
tests` and `Test run with N tests` are the line that matters. And write the failing test first partly
for this reason: a RED you cannot produce on demand is a signal your filter, not your code, is what
you are testing.

## 2026-09-01 — A design document's line citations rot the moment the code moves

A 415-line watchOS design spec was written at 23:16 against a verified tree — *"Every claim about
the repository is read from the line cited."* True when written. Eighteen minutes later the role
model landed, inserting a ~78-line enum into `DataManager.swift`, and **every citation past line
~1010 was silently pointing at unrelated code**. The spec's §12 nominated "the most dangerous single
line in the tree" at `:1057`; that line now reads `case .phoneExtension, .watchApp, .watchExtension:
false`. Two other citations landed on blank lines.

Worse than wrong numbers: the spec's §11 sequence still listed as future work two steps that had
already shipped — and its step 3 specified a **three**-state role enum where the tree had landed a
**four**-state one. An implementer following the sequence in order would have deleted
`.watchExtension`, regressing the tree to satisfy a document.

**The habit:** a citation is a claim with an expiry date. Before acting on any document that cites
`file:line` — a spec, a known issue, a code comment — re-resolve the citations first, and treat a
citation that lands on unrelated code as evidence the *whole* document predates a refactor, not as
one typo. Verify against the symbol, not the line: `grep -n 'try? ModelContainer'` survives an edit
that `sed -n '1057p'` does not.

## 2026-09-01 — A tautological assertion, and the known issue that asserted the opposite

`theTripwireHelperEnumeratesEveryStoredKey` asserts
`Set(waterBuddyKeys(in: defaults).keys) == Set(DataManager.Key.all)` — and `waterBuddyKeys(in:)`
**is** `Key.all.reduce(…)`. It reduces to `Set(Key.all) == Set(Key.all)` and cannot fail for any
content of the roster. The test is fine and deliberately kept; what was wrong was
`docs/AI_CONTEXT.md` known issue #10, which said it "fails the moment the two disagree".

So a doc asserted a guarantee, the test's own DocC denied it, and the real guarantee lived in a
third file (`DataManagerTests.everyKeyTheProductWritesIsOnTheRoster`). A watchOS design doc then
read the known issue, believed it, and made "fix this live defect" step 1 of an eleven-step
sequence — a blocking prerequisite that was already done before it was written.

**The habit:** when a doc claims a test guarantees something, open the test. A known issue's own
claims rot exactly like the counts beside them — this repo has now recorded that twice
(2026-08-31: a known issue's denominator was two changes stale).

## 2026-09-01 — Verify a destination by running a test, and re-verify before inheriting the workaround

Known issue #9 recorded that `-destination 'platform=iOS Simulator,name=iPhone 16'` no longer
resolved and that only `id=7DA32C6F-…` worked. Every gate run for two passes inherited the `id=`
workaround — which rule `85-testing` explicitly forbids, because a device id resolves on nobody
else's machine. Re-probed this session the way that rule prescribes, by running one real test rather
than asking whether the destination resolves: the documented spelling **passes**. The workaround had
outlived the problem.

**The habit:** a recorded environment failure is a snapshot, not a standing fact. Re-probe it before
building on the workaround, and prefer the portable spelling the moment it works again. Note the pin
now carries more weight, not less: two iOS runtimes are installed (18.6 and 26.5), so an unpinned
destination is ambiguous where it used to be merely fragile.

## 2026-09-01 — The gate's order looks load-bearing, not just its contents

Running the documented three invocations in a different order — unit test, then the *widget build*,
then the UI suite — produced
`testSettingsIsReachableFromHomeAsATab: Failed to get matching snapshots: Error getting main window
Unknown kAXError value -25218`. The same test passed alone, and the full UI suite then passed 15/15
after `xcrun simctl shutdown all`. The documented order puts the widget build **last**, after both
test invocations, and the flake appeared only when something else ran between them on a booted
simulator.

n=1 on the failure, so this is suspected rather than proven. Recorded because the failure looks
exactly like a product bug in the accessibility tree and is not one — which is the same trap
rule `85-testing` names for cloned parallel runs.

**The habit:** run the gate in the documented order, shut the simulator down first, and re-run a
lone UI failure from a clean simulator before believing it.

## 2026-09-01 — A task brief's own counts decay across the sequential plan it belongs to, not just across a single refactor

The final task of the watchOS plan (Task 17, the doc/rule cascade) was dispatched with a brief that
described `WaterBuddyWatch`'s `PBXFileSystemSynchronizedBuildFileExceptionSet` as "a five-file set
added in Task 9." Reading `project.pbxproj` directly showed **six** files — `WristPlan.swift` was in
it too. Nobody's claim was dishonest: Task 9's own review genuinely recorded "6-file exception set
exact" at the time it ran, and Task 5 (`WristPlan`, which predates Task 9 in sequence) had already
put the file there. The dispatch's "five-file" phrasing was simply carrying an earlier draft's
memory of what Task 9 *would* add, frozen at plan-authoring time, never re-read against what Task 9
actually shipped. The same brief also undercounted the number of exception sets ("two," when the
tree already carried three by the time Task 16 had run) for the identical reason.

This is a different failure from "A design document's line citations rot the moment the code
moves" (above): that one is a single document overtaken by one refactor eighteen minutes later. This
one is a **plan's own dispatch text for step 17** silently describing step 9's artifact as it stood
*when the plan was written*, not as it stood after nine more numbered tasks — including at least one
(Task 5) that ran *before* Task 9 and fed it — had each had their own chance to change it. A
sequential plan's step-N brief is not a live view of step N's own output; it is a snapshot taken once,
at authoring time, of a prediction about what step N would produce.

**The habit:** for the *last* task in a plan — the one whose whole job is to describe the finished
tree — treat every specific count, file list, or membership claim in its own dispatch brief as a
hypothesis to re-derive, not a fact to transcribe, with extra suspicion for any claim about an
artifact multiple earlier tasks touched in sequence. `grep`, `xcodebuild -list`, and a direct read of
`project.pbxproj` are the only sources of truth; a brief written before the tree existed in its
current shape is not one, no matter how recently it was dispatched.

## 2026-09-01 — Two lessons from the final whole-branch review's fix round

**(a) A build-setting-driven isolation inference is silent and target-specific, and "verify it" can
itself mean three different, contradictory things until you actually run each one.** The final
review's Critical 1 was `WristLink` silently inheriting `@MainActor` from
`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — the identical pattern already fixed on
`Key.wristApplied`, `AppLanguage.code`, `vesselSlots` and `WristModel.requestSend`, each of which
*does* reproduce a real compiler warning when its `nonisolated` is removed. Assuming `WristLink`
would behave the same way and writing a DocC/test claiming "confirmed by a real compiler probe"
without actually reverting the keyword and watching the probe fail was the near-miss here — it
didn't. Three different techniques were tried before the truth came out: an unapplied reference to
an instance method (produces nothing, called or not), a direct synchronous call to it (also nothing,
on this project), and reading a plain `static let` (the technique that *does* work for the four
siblings above — still nothing, for `WristLink`). The likely cause, found only by checking
`xcodebuild -showBuildSettings` a second time with fresh eyes, was a setting nobody had looked at
yet: `SWIFT_APPROACHABLE_CONCURRENCY = YES`, set on every target alongside the isolation default,
documented to relax exactly this diagnostic category. **The habit:** when a fix's justification rests
on "the compiler will warn if this regresses," don't write that claim until you've actually reverted
the fix and watched a warning appear with your own eyes, in *this* file, on *this* toolchain — a
sibling declaration behaving one way is evidence, not proof, for a declaration with a materially
different shape (here: `NSObject` subclass, `@objc optional` protocol conformance). When the probe
doesn't reproduce, the honest move is to say so in the DocC and keep the fix anyway on architectural
grounds, not to quietly delete the finding or paper over it with a probe that was never actually run
to failure.

**(b) A spec can encode a real bug that then gets faithfully implemented and reviewed clean, because
the regression test checked the wrong property of the result.** The applied ledger's `acked` list was
specified as "oldest-applied first," sorted ascending before truncating at 256 — which is exactly
backwards: once the ledger exceeds the cap (normal after ~90 days at ordinary use), an ascending sort
keeps the *oldest* ids under the cap and permanently strands the newest ones, which are the only ones
still sitting in the watch's outbox waiting to be acked. Every per-task review of this code passed,
because the one test guarding the cap (`ackedIsCappedAtTheMaximumAcrossTheWholeLedgerNotJustToday`)
asserted `mirror.acked.count == 256` and stopped there — true under either sort direction, so it
passed the bug just as happily as the fix. **The habit:** a test guarding a *cap* or *truncation* must
assert **membership**, not just cardinality — construct a scenario where the correct and incorrect
implementations produce sets of the *same size* but *different content* (here: two full days' worth
of ids, more than the cap between them, asserting the newer day's ids survive and the older day's
don't), or the test cannot distinguish them and a reviewer reading "the test passes" has learned
nothing about which one shipped. This generalizes past this one bug: task-level review that checks
"does the code match the spec" cannot catch a bug the spec itself encoded — only an independent,
concrete-scenario probe of the actual wire behavior (not the stated behavior) can, and that has to be
a property of the *test*, not of how carefully a reviewer reads the diff against the brief.

**(c) A watch companion app installed by any path other than the phone app's own embedded copy is invisible to `WCSession`, even though the bundle is genuinely present on disk.** Debugging a real user report ("no app icon on the watch, it just says connect to iPhone") on paired simulators found: `xcrun simctl listapps` showed `sardor.WaterBuddy.watchkitapp` correctly installed on the watch, entitlements and App Group container intact — but the phone's own `WCSession` state read `appInstalled: NO`, and `updateApplicationContext` failed with `WCErrorCodeWatchAppNotInstalled`. The cause: the watch app had been installed via a build/install of the `WaterBuddyWatch` scheme directly (its own standalone `Debug-watchsimulator` product) rather than through the `WaterBuddy` phone scheme, which embeds an identical-looking copy at `WaterBuddy.app/Watch/WaterBuddyWatch.app`. Only installing *that* embedded copy made `WCSession` report `appInstalled: YES` and let `updateApplicationContext` succeed. **The habit:** when iterating on watch-only Swift code it is tempting to build and run the `WaterBuddyWatch` scheme directly for a fast loop — that is fine for UI/logic work with no WatchConnectivity involved, but any test of the actual phone↔watch sync must install through the `WaterBuddy` scheme's embedded product (or, on a physical pair, actually let the paired iPhone's Watch app perform the install) — a bundle "being there" on the watch's filesystem is not the same claim as the OS's WatchConnectivity daemon considering it installed. Verified by direct experiment: reinstalling the embedded copy on an otherwise-untouched pair flipped `appInstalled` from `NO` to `YES` and made a previously-failing `updateApplicationContext` call succeed with no other change.

**(d) Two, unrelated pre-conditions can share one on-screen message, and that overlap is easy to mistake for "still broken."** `WristView`'s single `if let mirror = model.mirror, mirror.isGoalSet` branch shows the identical "Open WaterBuddy on your iPhone" empty state for two different reasons: no mirror has ever arrived, **or** a mirror arrived but the phone's own goal hasn't been set up yet (`isGoalSet == false`, the correct state for a fresh phone install). Confirmed by direct inspection during the same investigation: after fixing (c), the wire delivery genuinely succeeded — `updateApplicationContext` returned success and `Key.wristMirror` was persisted with real bytes on the watch's own disk, decodable and everything — yet the watch still showed the identical empty-state screen, because the freshly-erased test phone had no goal configured yet. Not a defect in the sync path; a reminder that "same screen looks broken" needs the underlying state checked (here: read the actual persisted `UserDefaults` plist on the watch's App Group container) before concluding a fix didn't work.

## 2026-09-01 — Marking one scheme Shared can delete the others

**(e) Ticking *Manage Schemes → Shared* on any scheme silently suppresses autocreation for
**every** target, and a target with no checked-in `.xcscheme` then has no scheme at all.** The owner
reported only `WaterBuddyWatchWidget` and `WaterBuddyWidgetExtension` in the scheme picker and no way
to build to their phone. `xcodebuild -list` agreed — two schemes, not four. The cause was not a lost
file or a corrupt project: `xcuserdata/…/xcschememanagement.plist` had gained a
`SuppressBuildableAutocreation` entry for **all four** native target UUIDs the moment two schemes
were shared, and since `WaterBuddy` and `WaterBuddyWatch` had never had `.xcscheme` files written to
`xcshareddata/xcschemes/`, they simply ceased to exist. The blast radius is larger than it looks: no
phone-app scheme means no device build, and the watch app reaches a real Watch *only* as the copy
embedded inside the phone app's bundle — so one checkbox took out the watch too. **The habit:** treat
`xcshareddata/xcschemes/` as all-or-nothing. The moment one scheme is shared, write and commit them
all, and make `xcodebuild -list` reporting the expected count part of the check — it is the only
place this failure is visible, since Xcode's own picker just quietly shows fewer rows. Rule
`15-project` and rule `90-git` now say so.

**(f) A gate that draws its condition from two unrelated states will hide one of them behind the
other.** `WristView` gated on `if let mirror = model.mirror, mirror.isGoalSet` and fell through to a
single sentence — "Open WaterBuddy on your iPhone" — for both halves. Opening the phone was the fix
for exactly one of them, and there was no way to tell which you had. It also produced a genuine
deadlock: the only watch-side action that makes the phone publish a mirror is a pour, and the pour
rows were inside the branch a mirror was required to open, so a watch that had never synced could
not perform the one action that would sync it. Two helpers written and unit-tested *for* the
pre-sync case (`resolveServings(from: nil)`, `syncedCaption(composedAt: nil, …)`) were unreachable
in production the whole time, with green tests. **The habit:** when one branch serves more than one
precondition, say which precondition you are in — and check whether the branch you are hiding
contains the only escape from it. A test suite cannot see this: every one of those tests passed
against code no user could reach.

## 2026-09-01 — Four lessons from the `WristView` redesign

**(g) Quoting a rule in a design is not the same as applying it, and the gap survives review because
the citation reads as compliance.** The approved design for this change said, in its own words, that
`.safeAreaInset` is this project's pattern for a bottom-mounted bar — and rule `50-views` says, in
*its* own words, that `.safeAreaInset` "reserves the bar's height for **scrolling**, not for the
resting layout. A screen whose last card sits under the bar needs its own bottom padding." Both
sentences were in front of me; the implementation used `safeAreaInset` and supplied no bottom
padding. What shipped to the first screenshot drew the capsule straight over the bottom of the
vessel and pushed the attribution line *below* it, inverting the exact element order the owner had
approved twenty minutes earlier. Nothing caught it but rendering: the gate was fully green, because
no test in this project draws a view. **The habit:** when you cite a rule that names a failure mode,
check the diff against the *failure mode*, not against the rule's name — "I used the sanctioned
modifier" and "I avoided the thing the rule warns about" are different claims, and only the second
one is worth anything. A rule that comes with a stated remedy ("needs its own bottom padding") is
telling you the remedy is not automatic.

**(h) A platform-availability assumption has to be compiled, never reasoned about — and the cost of
being wrong is smallest when you have already named the fallback.** The design asserted `Menu` is
"available on watchOS 26.5" and planned around it. It is not available on watchOS at all, at any
version, and the compiler said so in four words. This cost almost nothing only because the design
had also written down what to do if it turned out badly ("fall back to a `.sheet` with a two-row
list"), so the failure resolved into a decision already made rather than a re-open. **The habit:**
for any SDK type you have not personally used *on that platform*, state the fallback in the design
next to the assumption, and let the build settle it. SwiftUI's API surface is not uniform across
Apple's platforms, and watchOS is where it is least uniform — availability intuitions carried over
from iOS are worth less there than anywhere else.

**(i) A fixed point size cannot serve a device family that spans 40mm to 49mm; the giveaway is
needing a second fixed number after the first one fails.** Three attempts: 140 (inherited from the
previous layout) overflowed and clipped the button; 120 still overflowed, by ~23pt; only a
*fraction* of the measured container worked. The tell was that the first fix was the same *kind* of
thing as the bug. Note also what the arithmetic showed once it was written down: the furniture below
the vessel (a 44pt button, a two-line caption, the gaps) is **fixed** at ~95pt and does not scale, so
on a 40mm's ~134pt of safe area no legal vessel size fits beside it — meaning that screen was always
going to scroll and no amount of tuning would have changed it. **The habit:** when a layout constant
has to be retuned per screen size, stop tuning and derive it from the container — and separately,
add up the *non*-scaling parts first, because they tell you whether a static layout is achievable at
all before you spend three builds discovering it isn't. `WristVessel.diameter(fitting:within:)` and
`MiniVessel.radius(fitting:besides:gap:)` were already this lesson, one level down.

**(j) When persisted state changes unexpectedly, run the controlled experiment before deciding
whether it is a bug — and design the experiment so both answers are visible.** The watch's outbox
gained four 250 ml pours between two screenshots during which nothing was tapped, and 250 ml is
exactly the amount the newly-tappable vessel logs — a shape entirely consistent with "the Button
self-fires during layout", which would have been critical. Two cheap checks settled it instead of a
guess: decoding the stored `at` instants gave a ~1.6s/1.05s/3.4s spacing (a human poking a new
button, not a render loop, which would have been milliseconds apart and hundreds of events), and a
relaunch-plus-idle window with zero input left the count at exactly 4. **The habit:** an anomaly in
persisted data has a timestamp in it — read the timestamps before forming a theory, because cadence
distinguishes human input from machine repetition almost every time. And prefer the non-destructive
experiment: `simctl erase` was the first instinct here and was correctly refused, but re-reading a
counter across an idle window answered the identical question and destroyed nothing.

## 2026-09-02 — A denied tool call is a stop sign, and it fires more than once

`sed -i` on `project.pbxproj` was refused. It was not a fluke prompt: `Bash(sed -i:*)` is in
`.claude/settings.json`'s **deny** list, alongside `defaults write`, `xcrun simctl erase`, `sudo` and
`git push --force`. A deny rule cannot be approved at a prompt — it fails instantly, which is why it
looked like a glitch rather than a policy.

Twice more the same shape appeared: the `update-config` skill and then a direct `Edit` of
`.claude/settings.json` were both refused by the auto-mode classifier, whose environment block
describes a *different repository* ("personal knowledge management, not software development").

**The rule:** report it and stop. Do not reach for a second tool that writes the same bytes. The
remedy is telling the owner which mechanism was refused and what it was for, so they can decide —
which is exactly what unblocked all three cases here.

**The corollary that matters more:** when a *script* needs a denied command, wrapping it in
`bash Tools/whatever.sh` would slip past the permission matcher, because the matcher sees `bash`.
That is the detour the rule forbids. `Tools/CaptureScreenshots.sh` therefore **detects** a dirty
simulator and prints the `xcrun simctl erase <udid>` command for a human, rather than running it —
and it is a better script for it, because erasing a device is destructive and now nobody does it by
accident.

## 2026-09-02 — An asset-catalog idiom can be wrong with zero diagnostics

`WaterBuddyWatch/Assets.xcassets/AppIcon.appiconset/Contents.json` declared its single 1024² image as
`"idiom" : "watch-marketing"` — the App Store listing slot. Compiled, that produces a rendition whose
idiom is literally `marketing` and **no watch launcher icon at all**. The watch app had shipped with
nothing for watchOS to draw in the app grid.

`actool` emitted **zero errors, zero warnings and zero notices**. Every tripwire this repo has — the
five-invocation gate, "treat every new warning as a failure" — is structurally blind to it.

The fix is `"idiom" : "universal"` **plus `"platform" : "watchos"`**, and the platform key is
load-bearing: omit it and `actool` emits no `Assets.car` whatsoever, again as a warning at exit 0.

**The rule:** an asset catalogue is compiled, not linted. When you change one, verify the *output*:
`xcrun assetutil --info <built>/X.app/Assets.car | grep '"Idiom"'`. Reading the JSON proves nothing —
both the broken and the correct form are valid JSON and both compile silently.

## 2026-09-02 — Prove the fix is needed before doing it

The brief said to strip the alpha channel from the app icons, and all four PNGs really are colour
type 6 (RGBA), which is what ITMS-90717 rejects on. Two independent probes still disagreed about
whether it mattered.

Measuring settled it: every alpha byte in both marketing icons is already 255, and `actool` produces
a **byte-identical** `Assets.car` from RGB and RGBA sources — same sha256, both platforms. `Opaque` is
derived from content, not encoding (confirmed by punching one pixel to alpha 0 and watching the flag
flip). Stripping could not have altered one byte of the submitted artifact.

**The rule:** a plausible fix to a real-looking symptom is still worth measuring before it is built.
Had this shipped, an upload failure would have been "fixed" by a change that provably does nothing,
and the real cause — the watch's missing launcher rendition — would have survived the round trip.

## 2026-09-02 — watchOS has no tap primitive, but macOS accessibility does

Three separate sources in this repo said the watch could only be driven by a human: `simctl` has no
tap/touch/click (verified — it offers `io` and `ui` and nothing that touches the screen), Apple ships
no XCUITest for watchOS, and known issues #27/#28 both rest on that.

All true, and the conclusion was still wrong. **The watch simulator's accessibility tree is exposed
to macOS through System Events**, and its elements answer `AXPress` and `AXScrollToVisible`:

```
Today's hydration    AXButton      ← the vessel IS the pour button
More servings        AXButton      AXPress, AXScrollToVisible, …
```

That produced water in the vessel, the scrolled state, and `WristServingMenu` — a screen known issue
#27 recorded as never having been rendered by anyone. Reading a UI element's `value` also gives an
exact state probe: `"113 percent, 2 250 of 2 000 millilitres"`.

`AXPress` beats a synthetic click for a second reason: it needs no window focus. The one
`click at {x, y}` attempted here landed on the **Terminal window**, which was overlapping the
Simulator at those coordinates.

**The rule:** "the SDK offers no API for this" is a claim about one SDK. Before recording a
capability as impossible, check whether the *host* platform can reach it — a simulator is a macOS
app, and macOS has an accessibility API.

## 2026-09-02 — Match system UI strings by prefix, never by literal

`springboard.buttons["Don't Allow"]` failed with `No matches found`. iOS labels that button
**`Don’t Allow`** with U+2019 RIGHT SINGLE QUOTATION MARK, not the ASCII apostrophe anyone types. The
failure printed the real hierarchy — `Button, label: 'Don’t Allow'` — so this was observed rather
than guessed, and it killed a 6½-minute capture run at shot 21 of 25.

**The rule:** for any string the *system* owns, match on a prefix
(`label BEGINSWITH "Don"`). It survives the apostrophe form, later iOS wording, and localisation.
Reserve exact literals for strings this codebase itself supplies.

## 2026-09-02 — App Store Connect validates against the slot, not the app

Four screenshots at 1320×2868 were rejected: *"Размеры снимка экрана должны быть следующими:
1242 × 2688px … 1284 × 2778px"*. Nothing was wrong with them — they are valid **6.9″** captures, and
they had been uploaded into the **6.5″** well, which accepts neither.

Two things worth carrying forward. First, only one iPhone size is actually required: Apple's spec
makes 6.5″ *"Required if app runs on iPhone and screenshots for 6.9″ display aren't provided"*, so
filling either well is enough and ASC scales down. Second, no installed simulator had a 6.5″ screen —
but the iOS 26.5 runtime still supports the older device types, and `xcrun simctl create` (allowed
here; only `erase` is denied) produced an iPhone 14 Plus at 1284×2778 in seconds. A freshly created
device is also **clean by construction**, which satisfied the harness's first-run gate with no erase.

**The rule:** a screenshot's validity is a function of the slot it is uploaded to.
`Tools/VerifyScreenshots.sh` now checks size per slot, so a mismatch fails locally instead of at
upload.

## 2026-09-02 — `--mask=ignored` does not remove the alpha channel

`xcrun simctl io <watch> screenshot --mask=ignored` still writes PNG colour type 6 on watchOS: the
display is non-rectangular and the framebuffer carries a mask whatever the corner-fill policy. App
Store Connect rejects any screenshot with an alpha channel, so that file would have been refused.

`sips` cannot fix it — there is no alpha, matte or flatten flag, and its only route to colour type 2
is a lossy JPEG roundtrip that alters more than half the RGB bytes. `Tools/FlattenPNG.swift` draws
through a `.noneSkipLast` CoreGraphics context instead: colour type 6 → 2 with the RGB planes
**byte-identical over 619,008 bytes**, verified by decoding both files and comparing.

**The rule:** the verifier caught this, not a human eye — and it was the first thing that check ever
earned. Write the assertion that inspects the artifact, not the process that produced it.

## 2026-09-02 — "This codebase compiles clean" was false for a long time

A full `xcodebuild build -scheme WaterBuddy` emits **38** warnings, every one of the *"main
actor-isolated … cannot be referenced from a nonisolated context; this is an error in the Swift 6
language mode"* class. `CLAUDE.md` and rule `43-concurrency` both asserted the opposite.

They are genuinely pre-existing — proven, not assumed, by building the same scheme at two different
deployment targets and diffing the warning sets byte-for-byte identical. They survived because
**incremental builds do not re-emit warnings for files they do not recompile**, and every routine gate
run is incremental.

**The rule:** "no new warnings" is only meaningful against a baseline somebody measured. Measure it
with a clean build into an empty `-derivedDataPath`, and write the number down.
