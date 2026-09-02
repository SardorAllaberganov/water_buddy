#!/bin/bash
#
#  Tools/CaptureScreenshots.sh — the four iPhone App Store screenshots, English only.
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
#  THIS SCRIPT NEVER ERASES ANYTHING. It *requires* a device with no WaterBuddy state — the run
#  captures `GoalSetupView`, reachable only while `Key.isGoalSet` is absent, and the totals in the
#  other three shots are only correct from an empty store — but erasing is destructive and
#  `Bash(xcrun simctl erase:*)` is on this project's permission deny list. So the check below is a
#  *gate*, not a fix: if the device is dirty it prints the exact command and stops, and a human
#  decides whether to destroy that container.
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# iPhone 17 Pro Max on iOS 26.5. Its device-type profile reads mainScreenWidth 1320,
# mainScreenHeight 2868, mainScreenScale 3 — exactly App Store Connect's 6.9" slot. iPhone Air
# (1260x2736) is the only other installed device that lands in that slot.
PHONE="${WATERBUDDY_SCREENSHOT_PHONE:-EDF19A71-1CA8-4D79-A5B6-06340C4560E8}"

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

rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"

echo "── 1. a device with no state at all ─────────────────────────────────────────"
xcrun simctl shutdown all 2>/dev/null || true

# Read the container metadata off disk rather than booting to ask. An app container whose
# MCMMetadataIdentifier carries the bundle id, or an App Group container mentioning it, means the
# app has run here before — so `Key.isGoalSet` may be set and today's SwiftData rows may be
# non-empty, which silently invalidates every figure in the captures.
DEVDIR="$HOME/Library/Developer/CoreSimulator/Devices/$PHONE"
dirty=0
if find "$DEVDIR/data/Containers/Data/Application" -maxdepth 2 \
     -name '.com.apple.mobile_container_manager.metadata.plist' 2>/dev/null \
   | xargs -I{} plutil -extract MCMMetadataIdentifier raw -o - {} 2>/dev/null \
   | grep -q 'sardor.WaterBuddy'; then dirty=1; fi
if find "$DEVDIR/data/Containers/Shared/AppGroup" -maxdepth 2 -name '*.plist' 2>/dev/null \
   | xargs grep -l 'sardor.WaterBuddy' 2>/dev/null | grep -q .; then dirty=1; fi

if [ "$dirty" -ne 0 ]; then
  cat <<EOF

  STOP — this simulator already carries WaterBuddy state.

  GoalSetupView is unreachable once a goal has been committed, and the totals in the Home and
  History shots would be whatever a previous run left behind. The capture needs a clean container.

  This script will not erase it for you: that destroys everything on the device, and
  \`Bash(xcrun simctl erase:*)\` is denied in .claude/settings.json. Run it yourself if you are
  content to lose what is there:

      xcrun simctl erase $PHONE

  Or point the run at a device that has never had the app, e.g.:

      WATERBUDDY_SCREENSHOT_PHONE=<udid> bash Tools/CaptureScreenshots.sh

EOF
  exit 1
fi
echo "   clean: no WaterBuddy app or App Group container on this device"

xcrun simctl bootstatus "$PHONE" -b

echo "── 2. pin the environment ───────────────────────────────────────────────────"
# Both roots declare `.preferredColorScheme(.dark)`, so `appearance dark` changes nothing visible —
# it is one line of determinism. `content_size large` is iOS's default and is what `@ScaledMetric`
# resolves against: the vessel diameter, the quick-add buttons and the hero readout all scale off it.
xcrun simctl ui "$PHONE" appearance dark
xcrun simctl ui "$PHONE" content_size large

echo "── 3. freeze the status bar ─────────────────────────────────────────────────"
# Not Apple's 9:41: the run pours five servings 65 s apart, so `HistoryView`'s newest row lands about
# five minutes from here. A frozen 9:41 would contradict the timestamps printed directly beneath it.
# Real clock plus six minutes agrees with them.
STATUS_TIME="$(date -v+6M '+%-l:%M')"
xcrun simctl status_bar "$PHONE" override \
  --time "$STATUS_TIME" \
  --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --operatorName "" \
  --batteryState charged --batteryLevel 100

echo "── 4. drive it (about 5 minutes — the pours are spaced deliberately) ────────"
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
# `export attachments` is the current subcommand on Xcode 26.6 (xcresulttool 24757). Do NOT use
# `export object` — it is deprecated on this toolchain and slated for removal.
rm -rf "$WORK/attachments"
xcrun xcresulttool export attachments \
  --path "$RESULT" \
  --output-path "$WORK/attachments"

echo "── 6. rename UUID → slot ────────────────────────────────────────────────────"
# The four slugs are named explicitly so a partial run fails loudly. The full census
# (Tools/CaptureFullCensus.sh) deliberately omits this list, because several of its shots are
# conditional and a missing one there is a recorded outcome rather than a failure.
python3 "$ROOT/Tools/RenameScreenshots.py" "$WORK/attachments" "$OUT" \
  01-home,02-history,03-settings,04-goal-setup

echo "── 7. verify ────────────────────────────────────────────────────────────────"
bash "$ROOT/Tools/VerifyScreenshots.sh"

echo
echo "Done. Four iPhone screenshots in $OUT"
echo "The watch shot is a separate, human-driven run: bash Tools/CaptureWatchScreenshot.sh"
