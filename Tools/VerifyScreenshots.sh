#!/bin/bash
#
#  Tools/VerifyScreenshots.sh — proves every captured screenshot is one App Store Connect accepts.
#
#  Run:  bash Tools/VerifyScreenshots.sh
#
#  Checks each file under AppStore/screenshots/ (the raw captures and the upload set alike) against
#  the three rules that actually reject an upload:
#    · pixel size is one of the accepted pairs for its slot
#    · no alpha channel  ("Images can't include alpha channels or transparencies")
#    · format is PNG
#
#  Sizes are from Apple's screenshot specification, re-read 2026-09-02. The iPhone 6.9" slot accepts
#  three pairs, not one — a pipeline that hard-codes 1320x2868 would wrongly reject a perfectly valid
#  iPhone Air capture at 1260x2736. The Apple Watch slot accepts six; note that two *installed*
#  simulators (Series 11 42mm at 374x446, SE 3 40mm at 324x394) produce sizes that are NOT on the
#  list, which is why the watch script pins the 46mm.
#
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHOTS="$ROOT/AppStore/screenshots"

IPHONE_69="1260x2736 1290x2796 1320x2868"
IPHONE_65="1242x2688 1284x2778"
IPAD_13="2064x2752 2048x2732"
WATCH="422x514 410x502 416x496 396x484 368x448 312x390"

fail=0
count=0

if [ ! -d "$SHOTS" ]; then
  echo "no AppStore/screenshots/ directory — nothing to verify"
  exit 0
fi

while IFS= read -r file; do
  count=$((count + 1))
  rel="${file#"$ROOT"/}"

  w=$(sips -g pixelWidth  "$file" 2>/dev/null | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$file" 2>/dev/null | awk '/pixelHeight/{print $2}')
  alpha=$(sips -g hasAlpha "$file" 2>/dev/null | awk '/hasAlpha/{print $2}')
  fmt=$(sips -g format "$file" 2>/dev/null | awk '/format:/{print $2}')
  size="${w}x${h}"

  # The census, a coverage run that deliberately includes sizes Connect does not accept, writes
  # under the ignored build/census/ since 2026-11-06, so nothing here is exempt from the size check.
  case "$file" in
    *"/iPhone-6.9/"*)       accepted="$IPHONE_69"; slot="iPhone 6.9\"" ;;
    *"/iPhone-6.5/"*)       accepted="$IPHONE_65"; slot="iPhone 6.5\"" ;;
    *"/iPad-13/"*)          accepted="$IPAD_13";   slot="iPad 13\""    ;;
    *"/AppleWatch/"*)       accepted="$WATCH";     slot="Apple Watch"  ;;
    *)                      accepted="";           slot="(unknown slot)" ;;
  esac

  problems=""
  if [ -n "$accepted" ] && ! printf '%s\n' $accepted | grep -qx "$size"; then
    problems="$problems size $size not accepted for $slot (accepted: $accepted);"
  fi
  [ "$alpha" = "yes" ] && problems="$problems has an alpha channel;"
  [ "$fmt" != "png" ] && problems="$problems format is $fmt, not png;"

  if [ -n "$problems" ]; then
    echo "  FAIL  $rel — $problems"
    fail=1
  else
    echo "  ok    $rel  ($size, $slot, no alpha, png)"
  fi
done < <(find "$SHOTS" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) | sort)

echo
if [ "$count" -eq 0 ]; then
  echo "no screenshots found under AppStore/screenshots/"
  exit 0
fi
if [ "$fail" -ne 0 ]; then
  echo "$count file(s) checked — at least one would be rejected."
  exit 1
fi
echo "$count file(s) checked — all acceptable to App Store Connect."
