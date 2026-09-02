#!/usr/bin/env python3
"""Rename xcresult attachment exports from UUIDs to their slot names.

`xcresulttool export attachments` writes UUID-named files plus a `manifest.json` that carries, per
attachment, `exportedFileName` and `suggestedHumanReadableName`. The latter is shaped
"<attachment.name>_<index>_<UUID>.png", and `attachment.name` is the slot this harness set
("01-home", "02-history", "03-settings", "04-goal-setup").

Run:  python3 Tools/RenameScreenshots.py <attachments-dir> <output-dir> [expected,names,…]

The optional third argument is a comma-separated list of slugs that MUST be present; the run fails
if any is missing. Omit it to accept whatever the harness produced — which is what the full census
does, since several of its shots are conditional (the .large sheet detent and the notification
permission alert are both skipped rather than retried when they do not materialise).
"""

import json
import os
import re
import shutil
import sys

PATTERN = re.compile(r"^(?P<name>.+?)_\d+_[0-9A-Fa-f-]{36}\.png$")


def main() -> int:
    if len(sys.argv) not in (3, 4):
        print("usage: RenameScreenshots.py <attachments-dir> <output-dir> [expected,names,…]",
              file=sys.stderr)
        return 2
    src, dst = sys.argv[1], sys.argv[2]
    expected = set(sys.argv[3].split(",")) if len(sys.argv) == 4 else None

    manifest_path = os.path.join(src, "manifest.json")
    if not os.path.exists(manifest_path):
        print(f"no manifest.json in {src} — did the export run?", file=sys.stderr)
        return 1
    with open(manifest_path) as handle:
        manifest = json.load(handle)

    os.makedirs(dst, exist_ok=True)
    seen: dict[str, str] = {}

    for test in manifest:
        for attachment in test.get("attachments", []):
            human = attachment.get("suggestedHumanReadableName", "")
            match = PATTERN.match(human)
            if not match:
                continue
            name = match.group("name")
            if expected is not None and name not in expected:
                continue
            if name in seen:
                # Two attachments claiming one slot means a configuration matrix is running — the
                # template's WaterBuddyUITestsLaunchTests overrides
                # runsForEachTargetApplicationUIConfiguration and produces an orientation x language
                # spread, landscape included. If that ever leaks in here, this is where it is caught
                # rather than silently shipping a landscape shot to the portrait slot.
                print(f"two attachments named {name!r} — a configuration matrix is running",
                      file=sys.stderr)
                return 1
            seen[name] = attachment["exportedFileName"]
            shutil.copyfile(os.path.join(src, attachment["exportedFileName"]),
                            os.path.join(dst, name + ".png"))
            print(f"  {name + '.png':<18} <- {attachment['exportedFileName']}")

    if not seen:
        print("no attachments matched — did the harness capture anything?", file=sys.stderr)
        return 1
    if expected is not None:
        missing = expected - set(seen)
        if missing:
            print(f"missing screenshots: {', '.join(sorted(missing))}", file=sys.stderr)
            return 1
    print(f"  {len(seen)} screenshot(s) written to {dst}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
