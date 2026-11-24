#!/bin/bash
#
#  Tools/CaptureThemeCensus.sh — one theme's census on one runtime, one group of screens a run
#  (spec docs/superpowers/specs/2026-11-22-set-c-design.md §3.9). Drives
#  `AppStoreScreenshotUITests.testCaptureThemeCensus`, which the ordinary gate skips, and leaves every frame and
#  each screen's element frames in build/themes/<theme>-<runtime>/ for `Tools/MeasureContrast.swift`.
#
#  Lives in `Tools/` because that directory sits outside every PBXFileSystemSynchronizedRootGroup and therefore
#  belongs to no build target (rule `15-project`).
#
#  Run:  bash Tools/CaptureThemeCensus.sh build <27.0|18.6>
#        bash Tools/CaptureThemeCensus.sh <aurora|lagoon|dusk|midnight|bloom> <27.0|18.6> <group>
#  Groups: paywall | home,history-week | history-month,history-insights | settings,settings-lower,library
#          | settings-appearance,settings-end
#
#  Invoked through `bash` rather than as an executable: `chmod` is on this project's permission deny list.
#
#  Each command ends inside 600 s: the build is its own run, and no group sweeps more than three screens (a minute
#  each). Never erases a simulator, never shuts one down. The device is named, never chosen: iPhone 17 on iOS 27.0
#  for Apple's glass, iPhone 16 on iOS 18.6 for the hand-made stack — read `xcrun simctl list devices` first, and
#  hold nothing else on the simulator while it runs (CLAUDE.md's hard limits).
#
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
MODE="${1:?build, or a theme code}"
RUNTIME="${2:?iOS runtime, 27.0 or 18.6}"
case "$RUNTIME" in
  27.0) DEVICE="iPhone 17" ;;
  18.6) DEVICE="iPhone 16" ;;
  *) echo "runtime must be 27.0 or 18.6"; exit 2 ;;
esac
DD="$ROOT/build/themes/DerivedData-$RUNTIME"
DEST="platform=iOS Simulator,OS=$RUNTIME,name=$DEVICE"
if [ "$MODE" = build ]; then
  rm -rf "$DD"
  xcodebuild build-for-testing -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination "$DEST" -derivedDataPath "$DD"
  exit 0
fi
case "$MODE" in
  aurora|lagoon|dusk|midnight|bloom) ;;
  *) echo "theme must be aurora, lagoon, dusk, midnight or bloom"; exit 2 ;;
esac
# The store sample's last serving today is at 1:30 PM, and a launch drops any serving later than now; and a theme is
# compared with Aurora taken the same day — the week, the month and the insights are the day's. So a sitting captures
# Aurora and the themes together, between 1:45 PM and 11:45 PM, as the store capture does.
NOW=$((10#$(date +%H%M)))
if [ "$NOW" -lt 1345 ] || [ "$NOW" -gt 2345 ]; then
  echo "the theme census runs between 1:45 PM and 11:45 PM: today's last serving is at 1:30 PM"; exit 2
fi
GROUP="${3:?a group of screens, comma-separated}"
OUT="$ROOT/build/themes/$MODE-$RUNTIME"
mkdir -p "$OUT"
RESULT="$OUT/census-${GROUP//,/-}.xcresult"
rm -rf "$RESULT"
TEST_RUNNER_WATERBUDDY_THEME="$MODE" TEST_RUNNER_WATERBUDDY_SCREENS="$GROUP" xcodebuild test-without-building \
  -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination "$DEST" -derivedDataPath "$DD" \
  -parallel-testing-enabled NO -collect-test-diagnostics never \
  -only-testing:WaterBuddyUITests/AppStoreScreenshotUITests/testCaptureThemeCensus \
  -resultBundlePath "$RESULT"
# Each group exports into a folder of its own: the export writes a manifest.json and stops at one already there.
EXPORT="$OUT/export-${GROUP//,/-}"
rm -rf "$EXPORT"
xcrun xcresulttool export attachments --path "$RESULT" --output-path "$EXPORT"
# The export names each file by an id; its manifest keeps the name the census gave it. Put that name back —
# `<theme>-<screen>-NN.png`, `<theme>-<screen>-frames.json` — which is what MeasureContrast.swift reads.
python3 -I - "$EXPORT" "$OUT" <<'PY'
import json, os, re, sys
export, out = sys.argv[1], sys.argv[2]
for test in json.load(open(os.path.join(export, "manifest.json"))):
    for a in test["attachments"]:
        name = re.sub(r"_\d+_[0-9A-Fa-f-]{36}(?=\.[A-Za-z]+$)", "", a["suggestedHumanReadableName"])
        os.replace(os.path.join(export, a["exportedFileName"]), os.path.join(out, name))
PY
rm -rf "$EXPORT"
echo "captured $GROUP into $OUT"
