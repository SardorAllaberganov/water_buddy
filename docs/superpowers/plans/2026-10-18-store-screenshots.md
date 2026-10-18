# Plan — roadmap item 1.2.8: the iPhone store set

**Design.** Approved by the owner in chat on 2026-10-17 (the session that then parked it for the lag
fix, known issue #142), and approved again to go on 2026-10-18. It was never written to a spec: this
file is its only record in the repository. No product code changes; the work is the capture harness,
its script, and rule `85-testing`'s wording, which the owner approved at 23:59 on 2026-10-17, with
the design, and which was typed into the tree seconds after midnight and left unstaged until this
change.

**The owner's answers (2026-10-17).** A lived-in week; raw screens, no framing or headline; English
only; screenshots only, no listing copy. That the watch shot stays as it is (its redesign is 1.3.2)
was the design's own assumption, approved with the rest of it.

## What the set shows

The same four screens as 1.1, retaken on the redesign: `01-home`, `02-history`, `03-settings`,
`04-goal-setup`, 6.9″ (iPhone 18 Pro Max, iOS 27.0, 1320 × 2868).

- **Today**, five servings at set times, through History's `+` and the sheet's wheel:
  7:40 AM Glass, 9:15 Cup, 10:50 Bottle, 12:25 PM Glass, 1:30 PM Cup — 1,300 ml, 65 % of the default
  2,000, the 1.1 figure. Short of the goal, so no confetti; no pour on Home, so no *Undo* and no
  rating request.
- **The six days before**, oldest first: 1,650 (short), 2,000, 2,250, 2,150, 2,500, 2,000 — five
  met, the week card's cyan and white bars, and a *5 days* chip on Home. Built from the sheet's
  Cup, Glass and Bottle shortcuts, 27 saves; their servings keep the time of day the sheet opens on,
  because none of their rows is in a shot.

## Steps

1. **`WaterBuddyUITests/AppStoreScreenshotUITests.swift`** — `testCaptureAppStoreScreenshots`
   rewritten, with its DocC:
   - launches with `-WaterBuddyFreshStart YES -AppleLanguages (en) -AppleLocale en_US`: every run
     opens on the welcome on a throwaway suite and an in-memory store, with no erase; figures read
     *2,000* and times *1:30 PM*, as an en-US listing should, whatever the device's region;
   - fails, saying why, outside 13:45–23:45 local: the wheel offers nothing later than now, and a run
     across midnight would split the week;
   - the welcome's goal step → `04`; *Continue*, *Continue*, *Not now*;
   - today's five through History's `+`: each wheel spun in the morning — *AM* first, then hour,
     then minute, then the serving's own half of the day — because a wheel stopped on a time later
     than now snaps back to now, and each time read back off the wheel before *Save*. *(Corrected
     on 2026-10-18 by the first capture run: the plan said "AM/PM first, then hour, then minute",
     and at 2:42 PM the hour, asked for 12, read back 2. The log shows only the request and the
     read-back; that it snapped back from a time later than now is inferred, and the morning
     order built on it passed twice.)*;
   - the six earlier days: each day's button, then `+`, a shortcut, *Save*, its total read back off
     the day's button;
   - Home's vessel and chip asserted, then `01`, `02`, `03`.
   The census method is untouched but for one sentence that says its sibling "stays exactly as it
   is"; the class's `tapSpacing`, which only the census now reads, has its DocC reworded to say so.
2. **`Tools/CaptureScreenshots.sh`** — the phone found by name and runtime (default *iPhone 18 Pro
   Max*, iOS 27.0; `WATERBUDDY_SCREENSHOT_PHONE` takes a UDID), the first match when two share the
   name (#45's dead UDID); the dirty-device gate removed; the status-bar clock frozen at the run's
   start, later than every row; stale comments corrected. *(2026-10-18: "in 12-hour form" was not
   to be had. `--time` takes a bare time — `2:53` and `14:53` were accepted; `2:53 PM`, `2:53 `
   and full ISO dates were refused — and draws it in the device's own hour cycle, and the capture
   device is in `en_UZ`, 24-hour: `2:53` came out as *02:53*. The owner chose the 24-hour
   clock, frozen, over changing the device's hour cycle. The DerivedData is also kept between runs,
   so a second capture does not rebuild the app, its widget and its watch app from nothing.)*
   *(2026-10-18, known issue #144, before `/commit`: the clock was read after the boot and checked
   only by the harness, after the build, so a run begun before 1:30 PM could freeze an earlier time.
   The script now reads it once at the top, refuses a run outside 1:45–11:45 PM there, and freezes
   that value.)*
3. **Check:** `build-for-testing`; the capture, foreground; all four PNGs read; `VerifyScreenshots.sh`;
   the full gate, five invocations and the UI run on iOS 26.5. *(2026-10-18: the first capture's
   call came back at the foreground limit while `xcodebuild` sat out #101's ten-minute exit after the
   failure, and finished in the background; the other two, and the whole gate, ran in the
   foreground. The `build-for-testing` compiled the harness before its last edit.)*
4. **Records:** `HISTORY.md`; `/doc_sync` — #142 retired, #45, #82 and #88 updated, the roadmap's
   1.2.8 entry, `CLAUDE.md`'s gate line 2.

## Out of scope

The census method and `Tools/CaptureFullCensus.sh` (#82); the watch script (#45); the product page
header, which is done; the listing copy.
