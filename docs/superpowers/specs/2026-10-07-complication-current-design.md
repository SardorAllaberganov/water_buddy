# The complication stays current — design

**Status:** approved by the owner in conversation on 2026-10-07, **implemented the same day** — tests
RED then GREEN, the five-invocation gate green, no new warning — and staged for the owner's
`/commit`; **the owner's device check (§8.3) is pending**. The results and the rulings made in
execution are in `HISTORY.md`'s checkpoint of that date. Roadmap item 2
(pain #2 in the 2026-10-06 review scan, ~24 mentions). §4's two halves were presented and approved one
at a time; the owner then answered "all looks right and go implement". §7 and §8 — testing and
verification — were not presented as a separate section. They are recorded here, and the owner may
amend them. The owner chose to verify the background path on their own iPhone and Apple Watch (§8.3),
so this work is not done until that result is in.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `05a6998` on 2026-10-07. Apple's
statements (§3) were researched the same day; forum posts are paraphrased, because they could only be
read through a summarising fetch.

**Amends** `docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §4 (a second phone → wrist
carrier) and §12 (`transferCurrentComplicationUserInfo` leaves "Not in v1"). That document's §18 points
here.

---

## 1. What is being built

The watch face's ring shows the right number without the user opening the watch app.

Done means all of these:

1. A pour in the watch app moves the ring at once.
2. A drink logged in the phone app reaches the ring within seconds while the watch app is closed, as
   long as the complication is on the active face — on any watchOS where the system's complication push
   reaches a WidgetKit complication (§3).
3. Tests pin every decision this adds (§7); the five-invocation gate is green; no warning is new
   against a clean build of HEAD (§8.2); and the owner's device check passes (§8.3).

## 2. What happens today

1. **A watch pour reloads nothing.** `WristModel.pour(amount:)` writes the outbox and sends it. The face
   catches up on its next 15-minute refresh.
2. **A mirror reloads nothing either.** `WristModel.apply(_:)` writes the mirror and retires acked pours,
   and never touches the face.
3. **The background wake returns at once.** `.backgroundTask(.watchConnectivity)` activates the session,
   calls `reloadAllTimelines()` and returns. The system counts the task complete when the closure
   returns (§3), and delivery reaches the delegate only after activation — so no delegate delivery,
   and no pushed mirror, can land before the app may be suspended. Only a context already held in
   `receivedApplicationContext` gets through, because `activate()` re-reads it synchronously before the
   reload. *(Until the 2026-10-07 doc-sync re-run this said the reload "draws the old store",
   overlooking that re-read.)*
4. **The phone sends only an application context.** `DataManager.requestWristPublish(from:)` calls
   `updateApplicationContext`, which the system transfers "at an appropriate time" (`WCSession.h:107`).
5. **So the 15-minute refresh helps a phone drink only after the watch app has run.** It re-reads a store
   that only the watch app writes — and since a foreground launch applied a mirror without reloading the
   face, the timer was what eventually drew it. *(Until the 2026-10-07 doc-sync re-run this said the
   refresh "cannot help a phone drink", overlooking that path.)*

## 3. What Apple says

Researched 2026-10-07. *Apple* means documentation, headers, sample code or WWDC; *forum* means an Apple
engineer on the Developer Forums.

| Claim | Source | Kind |
|---|---|---|
| A SwiftUI background task is complete when its closure returns; if time runs out first, the system cancels it | `/documentation/swiftui/scene/backgroundtask(_:action:)` | Apple |
| For a WatchConnectivity background task, defer completion until the session is activated and the pending data received, checking `hasContentPending` | `/documentation/watchkit/wkwatchconnectivityrefreshbackgroundtask` | Apple |
| `activationState` is key-value observable; `hasContentPending` is not documented as such | `WCSession` docs and header | Apple |
| A complication push is sent immediately, launches the watch app in the background, and can be superseded: the earlier copy is untagged but stays queued | `WCSession.h:119` | Apple |
| 50 pushes a day while the complication is on the active face; 0 otherwise; at 0, a push travels as an ordinary user-info transfer | `WCSession.h:69`, `/documentation/watchconnectivity/wcsession` | Apple |
| A push jumps the user-info queue while budget remains; ordinary user info is delivered in the order sent | WWDC21 10003; `transferUserInfo(_:)` docs | Apple |
| The sample app pushes while the complication is active, and the watch saves the data and calls `reloadTimelines(ofKind:)` | `/documentation/watchconnectivity/transferring-data-with-watch-connectivity` | Apple |
| The push did not work with WidgetKit complications (July 2024) | forum thread 759389 | forum |
| Updating widgets over Watch Connectivity "works now" | WWDC26 watchOS group lab (8014) | Apple |
| A complication on the face gets up to ~75 reloads a day | `/documentation/widgetkit/converting-a-clockkit-app` | Apple |
| A reload from a backgrounded watch app counts against that budget; one from the foreground does not | forum thread 788713 | forum |
| Apple's own watch samples use the `.never` reload policy | the two sample projects above | Apple |
| `WCSession` is not available in iOS app extensions (2016) | forum thread 51600 | forum |

The push therefore should work on watchOS 27 and is uncertain on 26.x, which the app supports
(`WATCHOS_DEPLOYMENT_TARGET = 26.0`). Where it does not work, nothing regresses: the application context
still carries every mirror, as today.

## 4. The design

### 4.1 The watch reloads its own face

`WristModel` gains one injected closure, `reloadComplication: () -> Void`, shaped like `send:`. Its
production default, `WristModel.requestComplicationReload`, is a `nonisolated static func` that calls
`WidgetCenter.shared.reloadAllTimelines()` — the watch's twin of `DataManager.requestWidgetReload`, and
`nonisolated` for the reason `requestSend` is: `WristModel` is `@MainActor`, and a `@MainActor` function
value defaulting a plain closure parameter is a warning today and an error at Swift 6.

It fires:
- **after every pour**, once the outbox is persisted and before the transport is handed it;
- **after `apply(_:)`**, only when the mirror is news (§4.6) or it retired a pour from the outbox.

A mirror that only moves "synced at" still updates the screen's caption, through `withMutation`, but
spends no reload: a reload from the background counts against the face's daily budget (§3).

### 4.2 The background wake waits for delivery

The `.backgroundTask(.watchConnectivity)` closure, after `activate()`, awaits
`WristLink.waitForPendingDelivery()` instead of returning. That polls every 0.1 s until the session is
activated and `hasContentPending` is false, gives up after 100 checks (about ten seconds), and returns
the moment the system cancels the task — so it can never hold the task past the system's own limit.
Polling, rather than observing, because `hasContentPending` is not documented as observable.

The loop itself is `WristLink.poll(until:every:atMost:)`, pure, with the condition injected, so it is
testable with no session. Both are `#if os(watchOS)`.

The closure's own `reloadAllTimelines()` is removed: reloads now happen where the store is written
(§4.1), which also makes `WaterBuddyWatchApp.swift`'s `WidgetKit` import dead.

### 4.3 The face asks once a day

`WristWidgetProvider.getTimeline` changes its policy from `.after(now + 15 minutes)` to `.atEnd`.

- Every write the watch app makes now reloads the face, and every instant at which the total changes
  with nothing arriving is already a timeline entry (spec 2026-08-31 §17). The timer has nothing left to
  catch.
- It was requesting 96 reloads a day of the ~75 the face is given (§3), the same budget the pushed
  reloads need.
- `.atEnd` asks once, after the last boundary — exactly when the next day's boundaries need scheduling.

### 4.4 The phone pushes news to the face

`DataManager.requestWristPublish(from:)` keeps its signature, so no phone fixture changes. Its body:

1. Reads `session.applicationContext` — what the phone last sent the watch — before overwriting it.
2. Updates the context, as today. If that throws, it stops there, as today.
3. On iOS, calls `WristLink.pushToFace(_:encoded:after:in:)`, which pushes the same encoded mirror with
   `transferCurrentComplicationUserInfo(["mirror": data])` only when all three hold:
   - the mirror `isNews(since:)` the one last sent;
   - `isComplicationEnabled` is true;
   - `remainingComplicationUserInfoTransfers > 0`. At 0 the SDK would send an ordinary transfer, which
     the context already covers, so the push is skipped and a `DEBUG` line says so (rule
     `75-diagnostics`).
4. Just before pushing, cancels every outstanding user-info transfer that carries a `"mirror"` key. Only a
   replacement cancels: a publish that is not news leaves a waiting push alone, because it may be the
   only fast copy of a real change.

That costs about one push per drink, wherever the drink was logged, against 50 a day. The republishes
`refresh()` makes on every foreground and every tab appearance cost nothing.

### 4.5 The watch keeps the newest mirror

- **One door.** `WristLink.session(_:didReceiveUserInfo:)` gains a watchOS branch: a pushed mirror is
  decoded and posted on the same `didReceiveMirrorNotification` an application context uses. The watch
  receives no other user info — batches only travel wrist → phone.
- **Never older.** `apply(_:)` takes a mirror unless it is older than the one held, by `composedAt`. A
  tie goes through: it is the same composition arriving by both lanes, and the language tests apply three
  mirrors stamped alike. This is what stops a superseded push (§3) landing last, and it also covers the
  context re-read at activation (`WristLink.applyPersistedContext`), which can lag a push.
- **The clock caveat.** The phone's stamps compare only while its clock runs forward. So a held mirror
  stamped more than a minute ahead of the watch's own clock (the injected `now`) never blocks: a clock has
  been set back since it was composed. That covers a phone set forward and back again, whatever the
  watch's clock did, and a phone set back if the watch's clock moved with it. A set-back of under a minute
  stalls the watch at most that long.

### 4.6 What counts as news

`WristMirror.isNews(since:)`: `true` when there is no earlier mirror, or when the two differ in any field
but `composedAt`, which differs on every composition. Implemented by copying the earlier mirror whole,
re-stamping the copy with this one's `composedAt`, and comparing the whole value with `==` — so
`composedAt` becomes the mirror's one `var`. Not through the memberwise initialiser, as this section first
said: a field list is correct only on the day it is written (`tasks/lessons.md`, 2026-08-30), and a field
added later as a `var` with a default would have compiled there unseen and been compared at its default.
Copied whole, any field added later is compared for free.

Both ends use it: the phone to decide a push (§4.4), the watch to decide a reload (§4.1).

## 5. What this amends, and what it leaves alone

- **Spec 2026-08-31 §4** gains a second phone → wrist carrier: the complication push, for news only,
  beside the context, which stays the record.
- **Spec 2026-08-31 §12** no longer lists `transferCurrentComplicationUserInfo`.
- **Rule `70-privacy`** describes the transfer queue for pours only. A pushed mirror now waits there too,
  holding the same fields the context does. Proposed for the owner, not edited here: rule text is theirs.
- **Unchanged:** the wire's fields, every stored key, the entitlements, every target's membership, the
  percentage formula, and what the face draws.

## 6. Privacy

The same mirror, over the same paired link, with at most one push queued at a time (§4.4). It lands on the
watch's own complication, the surface rule `70-privacy` already names as its carve-out. No new field, key,
entitlement or framework.

## 7. Testing

Tests first: each is written against a seam that compiles and behaves as HEAD does, run RED, then made
GREEN.

**`WaterBuddyTests/WristSyncTests.swift` — new suite, not `@MainActor`:**
- the first mirror ever sent is news;
- a mirror differing only in `composedAt` is not news;
- a change to any other field is news, field by field.

The phone compares against a mirror decoded from its last context; that the round trip changes nothing
is already pinned by `WristWireTests.aWristMirrorRoundTripsThroughJSON`, so it gets no second test.

**`WaterBuddyWatchTests/WristModelTests.swift`:** `makeModel` gains a reload counter, defaulting to a
no-op.
- a pour reloads the face; a refused pour does not;
- a mirror that changes the total reloads; the same mirror twice reloads once; a mirror that only moves
  `composedAt` is taken but reloads nothing;
- a mirror older than the one held is ignored, and reloads nothing;
- a mirror composed at the same instant is taken;
- a held mirror slightly ahead of the watch's clock (30 s, ordinary skew) still blocks an older one; one
  far ahead (an hour, a clock set back) does not. Neither pins the one-minute value itself, which is a
  decision, not a behaviour.

**`WaterBuddyWatchTests/WristLinkDeliveryTests.swift` — new file, not `@MainActor`:**
- waiting ends as soon as delivery is done;
- waiting gives up after its last check;
- waiting ends when the task is cancelled.

Not unit-tested, verified by inspection and §8.3: the SDK calls in `pushToFace`, the watchOS branch of
`didReceiveUserInfo`, `waitForPendingDelivery`'s condition, the background-task closure, and the face's
policy. No test target compiles `WaterBuddyWatchWidget`.

## 8. Verification

### 8.1 The gate
Rule `85-testing`'s five invocations, exactly as written, in the foreground, one device and
`-parallel-testing-enabled NO`; `ps` checked for another session's `xcodebuild` before any
`simctl shutdown all`.

### 8.2 Warnings
A clean build of a `git archive HEAD` export is compared with the same export plus only this change's
files: `build-for-testing` of `WaterBuddy` and `WaterBuddyWatch`, and `build` of
`WaterBuddyWidgetExtension` and `WaterBuddyWatchWidget`, in one empty DerivedData folder per side.
Identical per file and message, or the difference is explained.

### 8.3 The owner's device check
A Debug build of the `WaterBuddy` scheme on the owner's iPhone, which installs the embedded watch app. The
watch app is opened once, and the WaterBuddy complication is on the active face. Record the watchOS
version first.

1. **A watch pour.** Pour in the watch app, press the crown. The ring has already moved.
2. **A phone drink, the watch app closed.** With the face showing, log a drink in the phone app. Within
   about 30 seconds the ring moves, without the watch app being opened. Note how long it took.
3. **A double tap.** Log two drinks a second apart on the phone. The ring ends at both, not one.
4. **A deletion.** Delete a drink in the phone's History. The ring drops.
5. **The Home Screen widget, expected not to reach the watch.** Close the phone app, then log from its
   widget. The ring is expected not to move until the phone app is next opened; it should then move within
   seconds. Record what happens either way — it settles whether `AddWaterIntent`'s `WCSession` activation
   does anything (§9).

If check 2 fails, note whether the watch app shows the new total once opened: if it does, the context path
works and the push did not arrive. The Xcode console prints any "No complication pushes left today".

### 8.4 Afterwards
`/doc_sync` (rule `99-docs-cascade`), a `HISTORY.md` checkpoint, and the work staged for the owner's
`/commit`.

## 9. Known limitations, and what is not in scope

- **Drinks logged from the phone's Home Screen widget** reach the watch when the phone app next comes
  forward, as today: `WCSession` is not available in iOS app extensions (§3). Check 5 tests it.
- **A complication added mid-day** shows what the watch last heard, until the next change.
- **A phone set behind real time while the watch keeps real time** stalls the watch until the phone's clock
  catches up (§4.5).
- **watchOS 26.x** may not deliver the push to a WidgetKit complication (§3). The face then updates when
  the watch app next runs, as today.
- **The Smart Stack** is not a complication; Watch Connectivity cannot update it (an Apple engineer on the
  forums, thread 745581). The app ships only `.accessoryCircular`.

## 10. Sequence

1. This spec, and the pointer in spec 2026-08-31 §18.
2. Seams: `isNews(since:)` returning `true`, `reloadComplication:` stored but never called, no ordering
   rule in `apply(_:)`, `poll` returning `false` without checking.
3. The tests in §7, run RED.
4. The implementation of §4.1, §4.5 and §4.6, and `poll`, run GREEN.
5. The unit-untested wiring: §4.2's wait and closure, §4.3's policy, §4.4's push, §4.5's watchOS branch.
6. Self-review against the rules; the gate; the warning comparison.
7. The owner's device check.
8. `/doc_sync`, `HISTORY.md`, staged.
