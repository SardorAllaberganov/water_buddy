---
description: Fail soft, loudly — DEBUG-only, condition-named, never carrying user data
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift"]
---

# Diagnostics

The app degrades rather than crashes, and every fallback says so — to a developer, in `DEBUG`, and
never to a log that could carry the user's water.

## No bare `print`
- Every diagnostic sits inside `#if DEBUG`
- The only bare `print` calls in the repository are in `Tools/GenerateAppIcon.swift` — a standalone
  script that belongs to no target and is run with `swift Tools/GenerateAppIcon.swift`. A repo-wide
  grep enforcing this rule will flag those four; they are correct
- No `os.Logger`, no analytics, no crash reporter (rule `70-privacy`)

## What a diagnostic may say
- Name the **failing condition** and, where it helps, the remedy — the App Group prints name the
  missing capability and say to add App Groups under Signing & Capabilities
- Never an amount, a goal, a timestamp, a log id, or any user value
- Never a full file path or anything identifying the device

## Prefer a test, then a value, then a log
- If a caller can react to a failure, **return it** rather than logging it. `ReconcileOutcome` is the
  channel for `reconcile`, carrying `deniedAuthorization` and the failed set — do not add a `print`
  beside it (rule `80-notifications`)
- If nobody can react, the failure still gets a test that pins the degraded behaviour
- A log is the last resort, for a condition only a developer can fix

## Fail soft, loudly
Every fallback in the product is announced in `DEBUG`:
- the App Group container missing → `sharedDefaults` degrades to `.standard`
- the store unopenable → App Group file, then process-local, then in-memory
- a failed log read → the total is left exactly as it stands, never written back as zero
- a failed save → logged, and the in-memory state is not rolled back
- an unrecognised language code → `.system`

## Never trap
- No `fatalError`, `assertionFailure` or `precondition` in app or widget source — there are currently
  zero
- The single `try!` is the terminal in-memory `ModelContainer`, the last rung of the ladder. A `try!`
  on the App Group path would turn a missing entitlement into a launch crash
- Saturate rather than overflow: sum with `addingReportingOverflow` and clamp (rule `20-state`)
