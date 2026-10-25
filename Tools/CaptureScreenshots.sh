#!/bin/bash
#
#  Tools/CaptureScreenshots.sh — eight of the ten iPhone App Store screenshots, English only: the
#  app's own screens (spec `docs/superpowers/specs/2026-10-25-store-page-design.md` §1). Shots 02 and
#  04 — the Home Screen and the Lock Screen — and the watch's three are `Tools/CapturePairScreenshots.sh`'s.
#
#  Lives in `Tools/` because that directory sits outside every PBXFileSystemSynchronizedRootGroup
#  and therefore belongs to no build target (rule `15-project`). It drives
#  `WaterBuddyUITests/AppStoreScreenshotUITests.swift`, which the ordinary gate skips.
#
#  Run:  bash Tools/CaptureScreenshots.sh
#
#  Invoked through `bash` rather than as an executable: `chmod` is on this project's permission deny
#  list, so the file ships without the executable bit. `chmod +x Tools/*.sh` by hand if you would
#  rather run it directly.
#
#  Nothing else may hold a simulator while this runs — CLAUDE.md's hard limits allow one at a time,
#  and a cloned parallel run writes into a container that cannot be read back.
#
#  Run it between 1:45 PM and 11:45 PM, from the 8th of a month. The app logs the harness's history
#  as it launches (`-WaterBuddyStoreSample`), today's last serving at 1:30 PM and none later than now;
#  Patterns need seven finished days of the month holding today, and the recap is then on the month
#  before's page. Outside either window it fails at once, saying so.
#
#  THIS SCRIPT NEVER ERASES ANYTHING, and since 2026-10-18 it no longer needs to. The harness
#  launches the app with `-WaterBuddyFreshStart`: a throwaway suite cleared at launch and an
#  in-memory store, so every run is a new install whatever the device holds; the seed and the held
#  Premium act only beside it. The launch still resolves the device's App Group suite and runs the
#  one-shot migration, as every launch does; the run's servings, goal and total live only in the
#  throwaway (rule `85-testing`).
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# The clock, read once: checked against the window here, before the boot and the build, and frozen
# into the status bar at step 3 — so the frozen time is always later than the last row. Read after
# the build instead, a run begun at 1:20 PM could pass the harness's own check and draw 13:20 over a
# serving at 1:30 PM. The harness keeps its check, for a build that carries the run past 11:45 PM.
NOW="$(date '+%H:%M')"
CLOCK=$((10#${NOW/:/}))
if (( CLOCK < 1345 || CLOCK >= 2345 )); then
  echo "it is $NOW: the store capture runs between 1:45 PM and 11:45 PM — today's last serving is at 1:30 PM, and a run across midnight would split the history it shows" >&2
  exit 1
fi
DAY=$((10#$(date '+%d')))
if (( DAY < 8 )); then
  echo "it is the $DAY of the month: the store capture runs from the 8th — Patterns need seven finished days of the month holding today, and the recap is then on the month before's page" >&2
  exit 1
fi

# An iPhone 18 Pro Max on iOS 27.0, found by name and runtime rather than by a UDID that dies with
# the simulator set (it did on 2026-10-08). Its device-type profile reads 1320x2868 at scale 3 —
# exactly App Store Connect's 6.9" slot, as 1.1's set was. When two devices share the name, the
# first listed is used and named below; its state does not matter, because the run starts clean.
# WATERBUDDY_SCREENSHOT_PHONE takes a UDID; the other two take a name and a runtime as
# `simctl list` prints them.
NAME="${WATERBUDDY_SCREENSHOT_NAME:-iPhone 18 Pro Max}"
RUNTIME="${WATERBUDDY_SCREENSHOT_RUNTIME:-iOS 27.0}"
if [ -n "${WATERBUDDY_SCREENSHOT_PHONE:-}" ]; then
  PHONE="$WATERBUDDY_SCREENSHOT_PHONE"
else
  MATCHES="$(xcrun simctl list devices available | awk -v rt="-- $RUNTIME --" -v name="$NAME" '
    /^-- / { inrt = ($0 == rt); next }
    inrt { line = $0; sub(/^ +/, "", line)
           if (index(line, name " (") == 1 && match(line, /\([0-9A-F-]+\)/)) print substr(line, RSTART + 1, RLENGTH - 2) }')"
  PHONE="$(printf '%s\n' "$MATCHES" | head -n 1)"
  if [ -z "$PHONE" ]; then
    echo "no available simulator named \"$NAME\" on $RUNTIME — set WATERBUDDY_SCREENSHOT_PHONE to a UDID" >&2
    exit 1
  fi
  echo "   $NAME, $RUNTIME: $PHONE ($(printf '%s\n' "$MATCHES" | grep -c .) installed, the first used)"
fi

# Which App Store slot this run fills. App Store Connect validates the pixel size against the slot
# it is uploaded to and rejects a mismatch outright — a 6.9" capture in the 6.5" well is refused with
# "Screenshot dimensions must be 1242 x 2688px, 2688 x 1242px, 1284 x 2778px or 2778 x 1284px".
#
#   iPhone-6.9  (default)  1260x2736 / 1290x2796 / 1320x2868 — iPhone Air, 17 Pro Max, 16 Pro Max…
#   iPhone-6.5             1242x2688 / 1284x2778             — iPhone 11 Pro Max, 14 Plus, 13 Pro Max…
#
# Filling 6.9" alone satisfies Apple's requirement (6.5" reads "Required if app runs on iPhone and
# screenshots for 6.9\" display aren't provided"), so a 6.5" set is only needed when uploading into
# that well specifically. Pair it with WATERBUDDY_SCREENSHOT_PHONE pointing at a device of that size.
SLOT="${WATERBUDDY_SCREENSHOT_SLOT:-iPhone-6.9}"
OUT="$ROOT/Screenshots/en-US/$SLOT"
WORK="$ROOT/build/screenshots"          # build/ is already gitignored
RESULT="$WORK/iPhone.xcresult"
DD="$WORK/DerivedData"

# The result bundle is this run's alone (step 5 clears the attachments); the DerivedData is kept,
# so a second run builds only what changed rather than the app, its widget and its watch app.
rm -rf "$RESULT"
mkdir -p "$WORK" "$OUT"

echo "── 1. one simulator, booted ─────────────────────────────────────────────────"
xcrun simctl shutdown all 2>/dev/null || true
xcrun simctl bootstatus "$PHONE" -b

echo "── 2. pin the environment ───────────────────────────────────────────────────"
# Both roots declare `.preferredColorScheme(.dark)`, so `appearance dark` changes nothing visible —
# it is one line of determinism. `content_size large` is iOS's default and is what `@ScaledMetric`
# resolves against: the vessel diameter, the quick-add buttons and the hero readout all scale off it.
xcrun simctl ui "$PHONE" appearance dark
xcrun simctl ui "$PHONE" content_size large

echo "── 3. freeze the status bar ─────────────────────────────────────────────────"
# The clock is frozen at the time read and checked at the top, so the eight shots read one time, and
# every row under it — the last is at 1:30 PM, and the run starts after 1:45 — is earlier. From
# 2026-10-09 to 2026-10-18 it was left live, after a 12-hour string drawn over 24-hour rows had
# contradicted them.
#
# It is given in 24-hour form, and it is drawn in the device's own hour cycle. Tried on 2026-10-18,
# `--time` took `14:53`, and took `2:53` and drew it as 02:53 on a capture device in `en_UZ` —
# night, over rows saying 1:30 PM. It refused `2:53 PM`, `2:53 ` and the three ISO dates tried,
# though `simctl`'s own help says an ISO date is taken. The app's rows are 12-hour, because the
# harness launches it in `en_US`; the owner chose the 24-hour clock over changing the device's own
# hour cycle (2026-10-18).
xcrun simctl status_bar "$PHONE" override \
  --time "$NOW" \
  --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --operatorName "" \
  --batteryState charged --batteryLevel 100

echo "── 4. drive it (two launches: a free user, then a Premium holder) ─────────────"
# `id=` rather than a platform/OS/name triple: the device is already booted with the overrides on it,
# and naming it by identity is what stops xcodebuild resolving a sibling instead. The private
# -derivedDataPath keeps this out of the DerivedData the gate uses.
xcodebuild test \
  -project WaterBuddy.xcodeproj \
  -scheme WaterBuddy \
  -destination "id=$PHONE" \
  -only-testing:WaterBuddyUITests/AppStoreScreenshotUITests/testCaptureAppStoreScreenshots \
  -parallel-testing-enabled NO \
  -derivedDataPath "$DD" \
  -resultBundlePath "$RESULT"

echo "── 5. extract ───────────────────────────────────────────────────────────────"
# `export attachments` is the current subcommand, as it was on Xcode 26.6 (xcresulttool 24757).
# Do NOT use `export object` — it was deprecated there and slated for removal.
rm -rf "$WORK/attachments"
xcrun xcresulttool export attachments \
  --path "$RESULT" \
  --output-path "$WORK/attachments"

echo "── 6. rename UUID → slot ────────────────────────────────────────────────────"
# The eight slugs are named explicitly so a partial run fails loudly; 02 and 04 are the pair
# script's, and this list leaves them alone. The full census (Tools/CaptureFullCensus.sh)
# deliberately omits this list, because several of its shots are conditional and a missing one there
# is a recorded outcome rather than a failure.
python3 "$ROOT/Tools/RenameScreenshots.py" "$WORK/attachments" "$OUT" \
  01-home,03-history,05-month,06-insights,07-patterns,08-recap,09-goal-setup,10-settings

echo "── 7. verify ────────────────────────────────────────────────────────────────"
bash "$ROOT/Tools/VerifyScreenshots.sh"

echo
echo "Done. Eight iPhone screenshots in $OUT"
echo "Shots 02 and 04 and the watch's three are a separate, human-driven run: bash Tools/CapturePairScreenshots.sh"
