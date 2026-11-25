#!/bin/bash
#
#  Tools/FrameScreenshots.sh — frames the ten raw iPhone captures into the App Store's upload set.
#
#  Run:  bash Tools/FrameScreenshots.sh [--in DIR] [--out DIR]
#
#  Reads   AppStore/screenshots/captures/iPhone-6.9/<slug>.png   1320 x 2868: Tools/CaptureScreenshots.sh's eight of
#          the app's own screens, and Tools/CapturePairScreenshots.sh's two of the system's (02-widgets, 04-lock-screen)
#  Writes  AppStore/screenshots/iPhone-6.9/<n>-<name>.png        the upload names, in upload order, by default
#
#  Each shot is Tools/StoreScreenshots.html drawn by headless Chrome. The page reports on
#  <body data-status>; a shot is taken only when it reads "ready", then read back: 1320 x 2868, PNG, no
#  alpha. A missing capture is reported and skipped, and the run exits 1, so a partial set is never taken
#  for the whole (docs/superpowers/specs/2026-11-06-framed-store-screenshots-design.md §6).
#  Tools/VerifyScreenshots.sh checks the output too: it keys the 6.9" sizes on /iPhone-6.9/.
#
#  Invoked through `bash`, as the other scripts here are: `chmod` is on this project's deny list.
#
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IN="$ROOT/AppStore/screenshots/captures/iPhone-6.9"
OUT="$ROOT/AppStore/screenshots/iPhone-6.9"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
# capture:upload name, in upload order — the page's own table lists the slugs in this order.
SHOTS="01-home:1-home 02-widgets:2-widgets 04-lock-screen:3-lock-screen 03-history:4-history 10-settings:5-settings
11-schedule:6-schedule 05-month:7-month 06-insights:8-insights 13-themes:9-themes 08-recap:10-recap"

usage() { echo "usage: FrameScreenshots.sh [--in DIR] [--out DIR]" >&2; exit 2; }
while [ $# -gt 0 ]; do
  case "$1" in
    --in)  [ $# -ge 2 ] || usage; IN="$(cd "$2" 2>/dev/null && pwd)" || { echo "no such directory: $2" >&2; exit 2; }; shift 2 ;;
    --out) [ $# -ge 2 ] || usage; OUT="$2"; shift 2 ;;
    *)     usage ;;
  esac
done

[ -x "$CHROME" ] || { echo "Google Chrome is not at $CHROME" >&2; exit 2; }
mkdir -p "$OUT"
PROFILE="$(mktemp -d)"
trap 'rm -rf "$PROFILE"' EXIT

# Percent-encode a path: this repository's own path holds an "&", which a query reads as a separator.
encode() { python3 -I -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=sys.argv[2]))' "$1" "$2"; }
PAGE="file://$(encode "$ROOT/Tools/StoreScreenshots.html" /)"
QUERY_IN="$(encode "$IN" "")"

chrome() {
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 \
    --window-size=660,1434 --allow-file-access-from-files --user-data-dir="$PROFILE" \
    --virtual-time-budget=3000 "$@" 2>/dev/null
}

fail=0
made=0
for pair in $SHOTS; do
  slug="${pair%%:*}"
  name="${pair#*:}"
  if [ ! -f "$IN/$slug.png" ]; then
    echo "  missing  $slug — no capture at $IN/$slug.png"
    fail=1
    continue
  fi
  url="$PAGE?shot=$slug&in=$QUERY_IN"
  status=$(chrome --dump-dom "$url" | grep -o 'data-status="[^"]*"' | head -1 | sed 's/^data-status="//; s/"$//')
  if [ "$status" != "ready" ]; then
    echo "  FAIL     $slug — ${status:-the page reported nothing}"
    fail=1
    continue
  fi
  png="$OUT/$name.png"
  rm -f "$png"
  chrome --screenshot="$png" "$url" >/dev/null
  w=$(sips -g pixelWidth "$png" 2>/dev/null | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$png" 2>/dev/null | awk '/pixelHeight/{print $2}')
  alpha=$(sips -g hasAlpha "$png" 2>/dev/null | awk '/hasAlpha/{print $2}')
  fmt=$(sips -g format "$png" 2>/dev/null | awk '/format:/{print $2}')
  if [ "${w}x${h}" != "1320x2868" ] || [ "$alpha" != "no" ] || [ "$fmt" != "png" ]; then
    echo "  FAIL     $slug — wrote ${w:-?}x${h:-?}, alpha ${alpha:-?}, ${fmt:-?} (want 1320x2868, no alpha, png; swift Tools/FlattenPNG.swift removes alpha)"
    rm -f "$png"
    fail=1
    continue
  fi
  echo "  ok       $slug → $name.png"
  made=$((made + 1))
done

echo
echo "$made of 10 framed into $OUT"
exit $fail
