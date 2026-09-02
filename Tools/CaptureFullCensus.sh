#!/bin/bash
#
#  Tools/CaptureFullCensus.sh — every screen, every state, every scroll position.
#
#  Run:  bash Tools/CaptureFullCensus.sh
#
#  Twenty-five captures in one session, driving
#  `WaterBuddyUITests/AppStoreScreenshotUITests/testCaptureFullScreenCensus`. Unlike
#  `Tools/CaptureScreenshots.sh`, which produces the four shipped store assets, this is a COVERAGE
#  run: its output is for looking at the product, and only a subset of it belongs in a store listing
#  (the harness's own DocC says which). Both live in the same test class and are filtered separately.
#
#  Takes about 10 minutes, most of it deliberate waiting — five pours are spaced 65 s apart so each
#  History row lands on a distinct minute, and every shutter is preceded by a settle.
#
#  THIS SCRIPT NEVER ERASES ANYTHING, for the same reason its sibling does not: erasing is
#  destructive and `Bash(xcrun simctl erase:*)` is on this project's permission deny list. It gates
#  on a clean device and stops with the exact command if one is needed.
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PHONE="${WATERBUDDY_SCREENSHOT_PHONE:-EDF19A71-1CA8-4D79-A5B6-06340C4560E8}"

OUT="$ROOT/Screenshots/census/iPhone-6.9"
WORK="$ROOT/build/census"
RESULT="$WORK/census.xcresult"
DD="$WORK/DerivedData"

rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"

echo "── 1. a device with no state at all ─────────────────────────────────────────"
xcrun simctl shutdown all 2>/dev/null || true

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

  The census opens on GoalSetupView and shoots two empty states before the first pour. All three are
  unreachable on a device that has run the app: the goal screen dies when Key.isGoalSet is set, and
  the empty states die at the first serving. Every percentage in the other 22 shots is also computed
  against a 2,000 ml goal and a store that starts empty.

  This script will not erase it for you. Run it yourself if you are content to lose what is there:

      xcrun simctl erase $PHONE

  Or point the run at a device that has never had the app:

      WATERBUDDY_SCREENSHOT_PHONE=<udid> bash Tools/CaptureFullCensus.sh

EOF
  exit 1
fi
echo "   clean: no WaterBuddy app or App Group container on this device"

xcrun simctl bootstatus "$PHONE" -b

echo "── 2. pin the environment ───────────────────────────────────────────────────"
# Every root in this product declares .preferredColorScheme(.dark) — RootTabView for the three tabs,
# GoalSetupView for setup, HistoryView for the edit sheet's own hosting controller — so there is no
# light appearance to capture and `appearance dark` is determinism only, not a variant.
xcrun simctl ui "$PHONE" appearance dark
xcrun simctl ui "$PHONE" content_size large

echo "── 3. freeze the status bar ─────────────────────────────────────────────────"
STATUS_TIME="$(date -v+10M '+%-l:%M')"
xcrun simctl status_bar "$PHONE" override \
  --time "$STATUS_TIME" \
  --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --operatorName "" \
  --batteryState charged --batteryLevel 100

echo "── 4. drive it (about 10 minutes) ───────────────────────────────────────────"
xcodebuild test \
  -project WaterBuddy.xcodeproj \
  -scheme WaterBuddy \
  -destination "id=$PHONE" \
  -only-testing:WaterBuddyUITests/AppStoreScreenshotUITests/testCaptureFullScreenCensus \
  -parallel-testing-enabled NO \
  -derivedDataPath "$DD" \
  -resultBundlePath "$RESULT"

echo "── 5. extract ───────────────────────────────────────────────────────────────"
rm -rf "$WORK/attachments"
xcrun xcresulttool export attachments --path "$RESULT" --output-path "$WORK/attachments"

echo "── 6. rename UUID → slot ────────────────────────────────────────────────────"
# No expected-names list, deliberately: shots 11 (the .large sheet detent) and 20/21 (the system
# notification prompt) are attempted, verified and SKIPPED rather than retried blind, so a run that
# produces 22 files instead of 25 is a recorded outcome, not a failure. The harness logs which.
python3 "$ROOT/Tools/RenameScreenshots.py" "$WORK/attachments" "$OUT"

echo "── 7. verify ────────────────────────────────────────────────────────────────"
bash "$ROOT/Tools/VerifyScreenshots.sh"

echo
echo "Done. Census in $OUT"
echo "Skipped shots, if any, are named in the test log: grep 'skipped' \"$WORK\"/../census.xcresult"
