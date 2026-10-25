#!/bin/bash
#
#  Tools/CapturePairScreenshots.sh — the store page's shots of the system's own surfaces: the iPhone's
#  Home Screen and Lock Screen (shots 02 and 04) and the Apple Watch's three, English only (spec
#  `docs/superpowers/specs/2026-10-25-store-page-design.md` §1, §3.5). The other eight iPhone shots
#  are `Tools/CaptureScreenshots.sh`'s.
#
#  Run:  bash Tools/CapturePairScreenshots.sh setup
#        … a person arranges one surface in DeviceHub.app, then:
#        bash Tools/CapturePairScreenshots.sh shoot <02-widgets | 04-lock-screen | 01-wrist |
#                                                    02-face-modular | 03-face-infograph>
#
#  Invoked through `bash` rather than as an executable: `chmod` is on this project's permission deny
#  list. Lives in `Tools/`, in no build target (rule `15-project`).
#
#  A PERSON IS NEEDED between the steps. XCUITest cannot place a widget, a control or a complication,
#  and `simctl` cannot touch a screen. The person does it in DeviceHub.app — Xcode 27 ships it in
#  place of Simulator.app, and its clicks reach both simulators (`docs/AI_CONTEXT.md` #152) — and each
#  surface is shot by its own `shoot`, so the script never waits on a terminal.
#
#  WHY A NEW PAIR EVERY RUN. The widgets and the watch read the phone's own App Group, which the
#  store harness's fresh start never opens, so `setup` writes a lived-in week into a phone's real
#  stores (`AppStoreScreenshotUITests.testBuildTheLivedInWeek`). Its figures are only right on a phone
#  that held nothing before, and erase is denied — so `setup` deletes the pair it made last time, by
#  name, and makes a new one, left for re-shoots until the next `setup`. It never touches a simulator
#  by any other name.
#
#  TWO SIMULATORS AT ONCE. CLAUDE.md allows one at a time; a watch shot needs its phone booted beside
#  it — the exception known issue #51 records.
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PHONE_NAME="WaterBuddy Store iPhone"
WATCH_NAME="WaterBuddy Store Watch"
# 1320x2868 at scale 3 — App Store Connect's 6.9" slot, as `CaptureScreenshots.sh`'s phone is.
PHONE_TYPE="com.apple.CoreSimulator.SimDeviceType.iPhone-18-Pro-Max"
# 416x496 by its device-type profile — on Apple's accepted list for the watch slot, which the
# installed 42mm (374x446) is not (`Tools/VerifyScreenshots.sh`).
WATCH_TYPE="com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-12-46mm"
PHONE_RUNTIME="com.apple.CoreSimulator.SimRuntime.iOS-27-0"
WATCH_RUNTIME="com.apple.CoreSimulator.SimRuntime.watchOS-27-0"

OUT_PHONE="$ROOT/Screenshots/en-US/iPhone-6.9"
OUT_WATCH="$ROOT/Screenshots/en-US/AppleWatch"
WORK="$ROOT/build/screenshots-pair"     # build/ is already gitignored
DD="$WORK/DerivedData"
RESULT="$WORK/LivedIn.xcresult"
PHONE_ID="sardor.WaterBuddy"
WATCH_ID="sardor.WaterBuddy.watchkitapp"

# Every simulator by this exact name, one udid a line.
udids_named() {
  xcrun simctl list devices -j | python3 -I -c '
import json, sys
name = sys.argv[1]
for devices in json.load(sys.stdin)["devices"].values():
    for device in devices:
        if device["name"] == name:
            print(device["udid"])
' "$1"
}

# The one simulator by this name that `setup` made, or a refusal.
the_one_named() {
  local found
  found="$(udids_named "$1")"
  if [ "$(printf '%s\n' "$found" | grep -c .)" != "1" ]; then
    echo "expected exactly one simulator named \"$1\" — run: bash Tools/CapturePairScreenshots.sh setup" >&2
    exit 1
  fi
  printf '%s\n' "$found"
}

setup() {
  # The lived-in week is built at the sheet's own times; a run across midnight would split it.
  local now clock
  now="$(date '+%H:%M')"
  clock=$((10#${now/:/}))
  if (( clock >= 2345 )); then
    echo "it is $now: the lived-in week is built before 11:45 PM — a run across midnight would split it" >&2
    exit 1
  fi

  rm -rf "$RESULT"
  mkdir -p "$WORK" "$OUT_PHONE" "$OUT_WATCH"

  echo "── 1. a new pair ────────────────────────────────────────────────────────────"
  local name udid
  for name in "$PHONE_NAME" "$WATCH_NAME"; do
    for udid in $(udids_named "$name"); do
      xcrun simctl shutdown "$udid" 2>/dev/null || true
      xcrun simctl delete "$udid"
      echo "   deleted the last run's $name ($udid)"
    done
  done
  local phone watch
  phone="$(xcrun simctl create "$PHONE_NAME" "$PHONE_TYPE" "$PHONE_RUNTIME")"
  watch="$(xcrun simctl create "$WATCH_NAME" "$WATCH_TYPE" "$WATCH_RUNTIME")"
  xcrun simctl pair "$watch" "$phone" >/dev/null
  echo "   $PHONE_NAME: $phone"
  echo "   $WATCH_NAME: $watch"

  echo "── 2. both booted, the environment pinned ───────────────────────────────────"
  xcrun simctl shutdown all 2>/dev/null || true
  xcrun simctl bootstatus "$phone" -b >/dev/null
  xcrun simctl bootstatus "$watch" -b >/dev/null
  # As `CaptureScreenshots.sh` pins its phone: dark and iOS's default text size. Its clock is frozen
  # at step 4, after the week, so it is never earlier than a serving the week logged.
  xcrun simctl ui "$phone" appearance dark
  xcrun simctl ui "$phone" content_size large

  echo "── 3. the lived-in week, on the phone (ten minutes or more) ─────────────────"
  xcodebuild test \
    -project WaterBuddy.xcodeproj \
    -scheme WaterBuddy \
    -destination "id=$phone" \
    -only-testing:WaterBuddyUITests/AppStoreScreenshotUITests/testBuildTheLivedInWeek \
    -parallel-testing-enabled NO \
    -derivedDataPath "$DD" \
    -resultBundlePath "$RESULT"

  echo "── 4. the watch app, after the phone's ──────────────────────────────────────"
  # The phone app is installed again through `simctl` — the same build, over itself, its stores kept —
  # and then the watch app: in that order the phone's session counts the watch app installed. The test
  # run's own install is not enough: after it, every publish failed with
  # `WCErrorCodeWatchAppNotInstalled` until the phone app was installed this way (2026-10-25; the
  # order itself, `tasks/lessons.md`, 2026-10-05). The watch's copy is the one embedded in the phone
  # app, the copy that ships; a standalone watch build is invisible to `WCSession`.
  local phone_app="$DD/Build/Products/Debug-iphonesimulator/WaterBuddy.app"
  local watch_app="$phone_app/Watch/WaterBuddyWatch.app"
  [ -d "$watch_app" ] || { echo "no watch app embedded at $watch_app" >&2; exit 1; }
  xcrun simctl terminate "$phone" "$PHONE_ID" 2>/dev/null || true
  xcrun simctl install "$phone" "$phone_app"
  xcrun simctl install "$watch" "$watch_app"
  xcrun simctl launch "$watch" "$WATCH_ID" >/dev/null
  # Launched last, so its activation publish carries the week to a watch that now has an app to land in.
  xcrun simctl launch "$phone" "$PHONE_ID" >/dev/null
  # The clock, frozen now — after every serving the week logged — in 24-hour form, the device's own
  # hour cycle (2026-10-18), as `CaptureScreenshots.sh` freezes its phone's.
  xcrun simctl status_bar "$phone" override \
    --time "$(date '+%H:%M')" \
    --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 --operatorName "" \
    --batteryState charged --batteryLevel 100

  cat <<'STEPS'

Ready. Arrange each surface in DeviceHub.app, then shoot it:

  02-widgets       The phone's Home Screen: touch and hold, Edit ▸ Add Widget ▸ WaterBuddy — the
                   small Hydration widget, the medium one and the week widget, on the first page.
                   They read 1,300 ml and 65 %. Leave the Home Screen showing, not editing.
  04-lock-screen   Lock the phone, wake it, touch and hold ▸ Customize ▸ Lock Screen: WaterBuddy's
                   line above the clock, its ring and its rectangle below it, and Log Water in a
                   bottom corner's control slot. Leave the Lock Screen showing.
  01-wrist         The watch: WaterBuddy open on its main screen, 65 %, "Synced just now". If it
                   reads "Not yet synced", open WaterBuddy on the phone once, then look again.
  02-face-modular  The watch face: Modular, WaterBuddy's rectangle in the large slot and its circle
                   in a small one.
  03-face-infograph Infograph: WaterBuddy's corner in a corner and its circle in a subdial.

  bash Tools/CapturePairScreenshots.sh shoot <name>
STEPS
}

shoot() {
  local slot="${1:-}" device out
  case "$slot" in
    02-widgets|04-lock-screen)
      device="$(the_one_named "$PHONE_NAME")"; out="$OUT_PHONE/$slot.png" ;;
    01-wrist|02-face-modular|03-face-infograph)
      device="$(the_one_named "$WATCH_NAME")"; out="$OUT_WATCH/$slot.png" ;;
    *)
      echo "shoot what? 02-widgets, 04-lock-screen, 01-wrist, 02-face-modular or 03-face-infograph" >&2
      exit 2 ;;
  esac
  mkdir -p "$(dirname "$out")"
  # --mask=ignored takes the framebuffer as rendered; a watch's still carries alpha, which App Store
  # Connect rejects, so every shot is flattened — a file already free of alpha is left alone.
  xcrun simctl io "$device" screenshot --mask=ignored "$out" >/dev/null
  swift "$ROOT/Tools/FlattenPNG.swift" "$out"
  bash "$ROOT/Tools/VerifyScreenshots.sh"
  echo "Shot $out"
}

case "${1:-}" in
  setup) setup ;;
  shoot) shoot "${2:-}" ;;
  *)
    echo "usage: bash Tools/CapturePairScreenshots.sh setup | shoot <name>" >&2
    exit 2 ;;
esac
