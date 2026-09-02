#!/bin/bash
#
#  Tools/CaptureWatchScreenshot.sh — the Apple Watch App Store screenshot.
#
#  Run:  bash Tools/CaptureWatchScreenshot.sh
#
#  Invoked through `bash` rather than as an executable: `chmod` is on this project's permission
#  deny list, so the file ships without the executable bit.
#
#  TWO MODES, because getting water into the vessel needs a human and nothing else here does.
#
#    bash Tools/CaptureWatchScreenshot.sh
#        Builds, boots, installs, launches, then PAUSES for you to tap the pour button, and only
#        then shoots. Use this for a populated screenshot.
#
#    WATERBUDDY_SCREENSHOT_NOWAIT=1 bash Tools/CaptureWatchScreenshot.sh
#        Unattended. Shoots the empty state. **This is what produced the shipped v1.0 asset** — the
#        owner's call on 2026-09-02, made against the App Review 2.3.3 caveat below.
#
#  Why a human at all: `simctl` has no tap primitive for watchOS (checked against `simctl help` —
#  it offers `io` and `ui`, neither of which touches the screen), and Apple has never shipped
#  XCUITest for watchOS, so there is no watchOS UI-test target to write and no automated route to
#  create. `docs/AI_CONTEXT.md` known issue #27 records the same gap for `WristServingMenu`.
#
#  CAVEAT ON THE EMPTY STATE. App Review guideline 2.3.3 says screenshots "should show the app in
#  use, and not merely the title art, login page, or splash screen". A 0% vessel captioned "Not yet
#  synced · default goal" is a weak reading of "in use". It was shipped knowingly; if review pushes
#  back, the remedy is a populated shot from the interactive mode above.
#
#  App Store Connect requires a watch screenshot for any app that embeds a watchOS app, and demands
#  ONE size used consistently across every localization. This pins 416x496 — Apple Watch Series 11
#  46mm — because it is on Apple's accepted list AND is the device rule `85-testing`'s gate already
#  names. Do not substitute the installed 42mm (374x446) or SE 3 40mm (324x394): neither size is
#  accepted, and the failure is silent until upload.
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Apple Watch Series 11 (46mm), watchOS 26.5 → 416x496.
WATCH="${WATERBUDDY_SCREENSHOT_WATCH:-A47014EF-3ED5-4F92-BD1B-47AE0810F32B}"

OUT="$ROOT/Screenshots/en-US/AppleWatch"
WORK="$ROOT/build/screenshots-watch"
DD="$WORK/DerivedData"
BUNDLE_ID="sardor.WaterBuddy.watchkitapp"

rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"

echo "── 1. build the watch app for the simulator ─────────────────────────────────"
xcodebuild build \
  -project WaterBuddy.xcodeproj \
  -scheme WaterBuddyWatch \
  -destination "id=$WATCH" \
  -derivedDataPath "$DD" \
  > "$WORK/build.log" 2>&1
echo "   $(tail -2 "$WORK/build.log" | tr -d '\n')"

APP="$DD/Build/Products/Debug-watchsimulator/WaterBuddyWatch.app"
[ -d "$APP" ] || { echo "watch app not built at $APP"; exit 1; }

echo "── 2. a watch with no state ─────────────────────────────────────────────────"
# The watch keeps its own local App Group suite (`Key.wristOutbox`, `Key.wristMirror`) on the watch
# device — a *different container* from the phone's despite the identical identifier string (rule
# `25-shared-storage`). A clean container is what makes the pour totals below predictable.
#
# This script never erases: that is destructive and `Bash(xcrun simctl erase:*)` is denied in
# .claude/settings.json. It warns and carries on, because unlike the iPhone run a dirty watch is not
# fatal — there is no first-run gate to miss, only a starting total that may not be zero.
xcrun simctl shutdown all 2>/dev/null || true

DEVDIR="$HOME/Library/Developer/CoreSimulator/Devices/$WATCH"
if find "$DEVDIR/data/Containers/Shared/AppGroup" -maxdepth 2 -name '*.plist' 2>/dev/null \
   | xargs grep -l 'sardor.WaterBuddy' 2>/dev/null | grep -q .; then
  echo "   WARNING: this watch already carries WaterBuddy state, so it may not start at 0 ml."
  echo "            To start clean, run:  xcrun simctl erase $WATCH"
else
  echo "   clean: no WaterBuddy App Group container on this watch"
fi

xcrun simctl bootstatus "$WATCH" -b

echo "── 3. install and launch ────────────────────────────────────────────────────"
xcrun simctl install "$WATCH" "$APP"
xcrun simctl launch "$WATCH" "$BUNDLE_ID" >/dev/null

# The shipped v1.0 screenshot is the empty state — the owner's call on 2026-09-02, after weighing
# it against App Review 2.3.3 ("screenshots should show the app in use"). WATERBUDDY_SCREENSHOT_NOWAIT=1
# reproduces exactly that, unattended. Leave it unset to pause for a human, which is the ONLY way to
# get water into the vessel: simctl has no tap primitive for watchOS (verified against `simctl help`
# — it offers `io` and `ui` and nothing that touches the screen) and Apple has never shipped
# XCUITest for watchOS, so no automated route exists.
if [ "${WATERBUDDY_SCREENSHOT_NOWAIT:-0}" = "1" ]; then
  echo "   WATERBUDDY_SCREENSHOT_NOWAIT=1 — shooting the empty state without waiting"
  sleep 6
else
  echo
  echo "══════════════════════════════════════════════════════════════════════════════"
  echo "  YOUR TURN. Open Simulator.app — the watch is booted and WaterBuddy is running."
  echo
  echo "  Tap the pour button a few times so the vessel is not empty. The screen is"
  echo "  usable before its first sync by design, so each tap goes straight into the"
  echo "  local outbox and the total moves immediately — no paired phone needed."
  echo
  echo "  Three taps of the default 250 ml vessel gives 750 / 2000 ml, about 38%."
  echo
  echo "  NOTE: the caption will read \"Not yet synced · default goal\" until a real"
  echo "  WristMirror arrives from a paired phone. Pouring locally raises the number"
  echo "  but does not change that line. If you want it gone, the watch has to be"
  echo "  paired to a booted iPhone simulator running the app — a manual setup no part"
  echo "  of the gate performs."
  echo
  echo "  Leave the app on its main screen, then come back here."
  echo "══════════════════════════════════════════════════════════════════════════════"
  echo
  read -r -p "  Press Return when the watch screen is ready to shoot… " _
fi


echo "── 4. shutter ───────────────────────────────────────────────────────────────"
# --mask=ignored, explicitly. The watch display is non-rectangular (its device profile carries a
# framebufferMask), and `--mask=alpha` would write transparent corners — which App Store Connect
# rejects outright ("Images can't include alpha channels or transparencies"). `ignored` takes the
# framebuffer as rendered.
xcrun simctl io "$WATCH" screenshot --mask=ignored "$OUT/01-wrist.png"

echo "── 5. flatten ───────────────────────────────────────────────────────────────"
# `--mask=ignored` is NOT enough. Measured: simctl writes PNG colour type 6 (RGBA) on watchOS
# whatever the mask policy, because the display is non-rectangular and the framebuffer carries a
# mask regardless of how the corners are filled. App Store Connect rejects any screenshot with an
# alpha channel, so the capture is re-encoded to colour type 2 with the RGB planes untouched
# (verified byte-identical over 619,008 bytes on the first real capture).
swift "$ROOT/Tools/FlattenPNG.swift" "$OUT/01-wrist.png"

echo "── 6. verify ────────────────────────────────────────────────────────────────"
bash "$ROOT/Tools/VerifyScreenshots.sh"

echo
echo "Done. Watch screenshot at $OUT/01-wrist.png"
