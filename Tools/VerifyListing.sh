#!/bin/bash
#
#  Tools/VerifyListing.sh — every App Store text field, counted against Apple's limits and the ASO playbook's
#  keyword rules, for each listing language (spec docs/superpowers/specs/2026-11-20-release-1-4-1-design.md
#  §5, D7).
#
#  Run:  bash Tools/VerifyListing.sh
#
#  Reads  AppStore/        the en-US fields, one file each, and README.md's App Store Connect blocks
#         AppStore/en-GB/  the English (U.K.) listing — the en-US text but for its keywords
#         AppStore/ru/     the Russian listing
#  Exits 1 on a missing or empty file, a trailing newline, a field over its limit, a keyword that breaks a
#  rule, an en-US file unlike its README block, or an en-GB field unlike en-US's. Prints every count either
#  way. Reads only.
#
#  Invoked through `bash`, as the other scripts here are: `chmod` is on this project's deny list. Lives in
#  Tools/, in no build target (rule 15-project).
#
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec python3 -I - "$ROOT" <<'PY'
import re
import sys

root = sys.argv[1]
# Apple's limits, as the owner's aso skill records them (references/apple-rules.md, read 2026-11-20):
# characters, but bytes for the keyword field and the review notes.
LIMITS = {
    "name.txt": (30, "chars"),
    "subtitle.txt": (30, "chars"),
    "keywords.txt": (100, "bytes"),
    "promotional-text.txt": (170, "chars"),
    "whats-new.txt": (4000, "chars"),
    "description.txt": (4000, "chars"),
    "review-notes.txt": (4000, "bytes"),
}
LISTINGS = [("en-US", "AppStore"), ("en-GB", "AppStore/en-GB"), ("ru", "AppStore/ru")]
failures = []
texts = {}


def words(text):
    return {w for w in re.split(r"[^\w]+", text.lower()) if w}


for label, folder in LISTINGS:
    print(f"== {label}  ({folder}/)")
    fields = texts.setdefault(label, {})
    for name, (limit, unit) in LIMITS.items():
        if name == "review-notes.txt" and label != "en-US":
            continue
        try:
            text = open(f"{root}/{folder}/{name}", encoding="utf-8").read()
        except FileNotFoundError:
            failures.append(f"{label}: {name} is missing")
            print(f"  {name:22} MISSING")
            continue
        fields[name] = text
        size = len(text.encode("utf-8")) if unit == "bytes" else len(text)
        flags = [flag for flag, bad in (("OVER", size > limit), ("ends with a newline", text.endswith("\n")),
                                         ("empty", not text.strip())) if bad]
        failures += [f"{label}: {name} {flag}" for flag in flags]
        print(f"  {name:22} {size:5} / {limit} {unit}  {', '.join(flags) or 'ok'}")
    keywords = fields.get("keywords.txt")
    if keywords is not None:
        terms = keywords.split(",")
        taken = words(fields.get("name.txt", "")) | words(fields.get("subtitle.txt", ""))
        problems = ["a space"] if " " in keywords else []
        for term in terms:
            if len(term) <= 2:
                problems.append(f"'{term}' is two characters or fewer")
            if term in taken or term.rstrip("s") in taken or f"{term}s" in taken:
                problems.append(f"'{term}' repeats the name or subtitle")
            if term in ("apple", "iphone"):
                problems.append(f"'{term}' is Apple's mark")
        if len(set(terms)) != len(terms):
            problems.append("a duplicate")
        failures += [f"{label}: keywords: {problem}" for problem in problems]
        print("  keyword rules:", "; ".join(problems) or "pass")

# en-US against README.md's App Store Connect section, the master copy (spec §5.4).
readme = open(f"{root}/README.md", encoding="utf-8").read()
section = readme[readme.index("# App Store Connect"):]


def block_after(heading):
    start = section.index(heading)
    opening = section.index("```\n", start) + 4
    return section[opening:section.index("\n```", opening)]


def row(field):
    match = re.search(rf"\| \*\*{field}\*\* \(≤30\) \| `([^`]*)`", section)
    return match.group(1) if match else None


masters = {
    "name.txt": row("Name"),
    "subtitle.txt": row("Subtitle"),
    "promotional-text.txt": block_after("## Promotional text"),
    "keywords.txt": block_after("## Keywords"),
    "description.txt": block_after("## Description"),
    "whats-new.txt": block_after("## What's New"),
    "review-notes.txt": block_after("## Review notes"),
}
print("== en-US against README.md")
for name, master in masters.items():
    if name in texts["en-US"]:
        same = texts["en-US"][name] == master
        failures += [] if same else [f"en-US: {name} differs from README.md"]
        print(f"  {name:22} {'same' if same else 'DIFFERS'}")

# en-GB is en-US's text but for the keywords (spec §5.2).
print("== en-GB against en-US")
for name, text in texts["en-GB"].items():
    if name != "keywords.txt" and name in texts["en-US"]:
        same = text == texts["en-US"][name]
        failures += [] if same else [f"en-GB: {name} differs from en-US"]
        print(f"  {name:22} {'same' if same else 'DIFFERS'}")

print()
if failures:
    print(f"{len(failures)} problem(s):")
    print("\n".join(f"  - {failure}" for failure in failures))
    sys.exit(1)
print("Every field is inside its limit, and every rule holds.")
PY
