# Code Review

**Reviewed:** `feat/cocoa-sdk-skill` — Sentry Cocoa SDK skill bundle (SKILL.md + 6 reference files + README update)
**Verdict:** NEEDS CHANGES

## Summary

Solid, well-structured SDK skill bundle that follows established patterns from Go/Svelte/Python skills. The coverage of Apple-specific features (crash reporting, app hangs, watchdog termination, Liquid Glass caveats) is thorough. However, there is one fabricated API, a v9 vs v8 API mismatch in the Quick Start, several type/default inaccuracies in config tables, and a tvOS/Session Replay contradiction that need fixing before merge.

## Findings

### [P0] Fabricated API: `SentrySDK.showUserFeedbackForm()` does not exist
**File:** `skills/sentry-cocoa-sdk/references/user-feedback.md:48`
**Issue:** `SentrySDK.showUserFeedbackForm()` is not a real method in the Sentry Cocoa SDK. The actual public API for showing feedback is `SentrySDK.feedback.showWidget()` (shows the floating button) or `SentrySDK.capture(feedback:)` (programmatic submission). There is no public method to show the form directly — `showForm()` exists only as internal API on `SentryUserFeedbackIntegrationDriver`.
**Impact:** An agent following this instruction will produce code that won't compile.
**Suggested Fix:**
```swift
// Show the floating widget button (which opens the form on tap)
SentrySDK.feedback.showWidget()
```

### [P1] Quick Start uses `experimental.enableLogs` despite targeting SDK 9.5.1
**File:** `skills/sentry-cocoa-sdk/SKILL.md:175` and `SKILL.md:219`
**Issue:** Both SwiftUI and UIKit Quick Start examples use `options.experimental.enableLogs = true`. The SKILL.md header states it targets sentry-cocoa 9.5.1, and the logging reference correctly documents that `enableLogs` is stable in v9.0.0+ while `experimental.enableLogs` is the v8.55.0–8.x API. Using the experimental path in a v9+ Quick Start is incorrect.
**Suggested Fix:** Change both occurrences to:
```swift
options.enableLogs = true
```

### [P1] Session Replay tvOS contradiction
**File:** `skills/sentry-cocoa-sdk/SKILL.md:82` and `SKILL.md:239`
**Issue:** Two tables recommend Session Replay for "iOS/tvOS user-facing apps", but the Platform Feature Support Matrix at line 296 correctly shows Session Replay as ❌ for tvOS. Session Replay is iOS-only in the Sentry Cocoa SDK. The matrix is correct; the recommendation text is wrong.
**Suggested Fix:** Change both occurrences from "iOS/tvOS" to "iOS only":
- Line 82: `| Session Replay | iOS user-facing apps (check iOS 26+ caveat) |`
- Line 239: `| Session Replay | ... | User-facing iOS apps |`

### [P1] `tracesSampleRate` type and default are wrong in SKILL.md config table
**File:** `skills/sentry-cocoa-sdk/SKILL.md:264`
**Issue:** The config reference states `tracesSampleRate` is type `Float` with default `0.0`. The actual SDK type is `NSNumber?` with default `nil`. `nil` means "tracing not configured" which is semantically different from `0.0` (explicitly set to zero). The tracing reference file at line 11 says `Double (0.0–1.0)` with default `nil` — closer but still not matching the actual `NSNumber?` type.
**Impact:** An agent checking the default value may incorrectly assume tracing is configured when it isn't.
**Suggested Fix:** SKILL.md line 264:
```
| `tracesSampleRate` | `NSNumber?` | `nil` | Transaction sample rate; `nil` = tracing disabled |
```
Also fix `sampleRate` at line 272 — likely also `NSNumber?` not `Float`.

### [P2] `beforeSend` example uses stale V1 exception type string
**File:** `skills/sentry-cocoa-sdk/references/error-monitoring.md:238`
**Issue:** The `beforeSend` example filters `event.exceptions?.first?.type == "App Hanging"`, but with App Hang Tracking V2 (default in v9), the exception types are `"App Hang Fully Blocked"`, `"App Hang Non Fully Blocked"`, etc. (documented correctly at lines 137–140 in the same file). The `"App Hanging"` string is the V1 type and won't match V2 events.
**Suggested Fix:**
```swift
if event.exceptions?.first?.type?.hasPrefix("App Hang") == true {
    return nil
}
```

### [P2] Cross-link table suggests frontend skills for Node.js backend
**File:** `skills/sentry-cocoa-sdk/SKILL.md:349`
**Issue:** The Phase 4 cross-link table suggests `sentry-react-setup` or `sentry-svelte-sdk` when `package.json` is detected. But `package.json` in a companion `../backend` or `../server` directory indicates a Node.js backend, not a React/Svelte frontend. There's no `sentry-node-sdk` skill in the repo, so either note it as "no matching skill yet" or suggest the setup skills (`sentry-setup-tracing`, `sentry-setup-logging`).
**Suggested Fix:**
```
| Node/JS (`package.json`) | `sentry-setup-tracing` + `sentry-setup-logging` (no Node SDK skill yet) | ✅ automatic |
```

### [P2] `enablePropagateTraceparent` missing v9.0.0+ version note
**File:** `skills/sentry-cocoa-sdk/references/tracing.md:360`
**Issue:** `options.enablePropagateTraceparent = true` is documented without noting it was introduced in v9.0.0. It does not exist in v8.x. Since the reference file's minimum SDK note at the top says `v7.0.0+`, someone on v8.x would hit a compile error.
**Suggested Fix:** Add an inline comment:
```swift
// W3C traceparent header (v9.0.0+)
options.enablePropagateTraceparent = true
```
Or add it to the config table with a version note.

## What's Good

- **iOS 26 / Liquid Glass handling is excellent** — the session-replay.md thoroughly covers the auto-disable safeguard (v8.57.0+), the compile-time + runtime conditions, and the experimental force-enable flag. This is critical information that's hard to find.
- **Profiling migration guide is well done** — clear before/after for the v8→v9 `profilesSampleRate` → `configureProfiling` transition, with an API history table showing exactly when each API was introduced and removed.
- **Phase 1: Detect commands are practical** — the bash commands to detect SwiftUI vs UIKit, platform targets, and companion backends are real and useful. Good pattern matching with existing skills.
- **SPM product guidance** — the warning about selecting only one of `Sentry`, `Sentry-Dynamic`, `SentrySwiftUI`, `Sentry-WithoutUIKitOrAppKit` addresses a real foot-gun in Xcode's UI.
- **Privacy masking coverage** — comprehensive across both session replay and screenshots with SwiftUI modifiers, UIKit instance methods, and class-level configuration.
- **379 lines for main SKILL.md** — well within the 500-line budget.

## Next Steps

- [ ] Fix P0: Replace `SentrySDK.showUserFeedbackForm()` with `SentrySDK.feedback.showWidget()` in user-feedback.md:48
- [ ] Fix P1: Change `experimental.enableLogs` → `enableLogs` in SKILL.md Quick Start (lines 175, 219)
- [ ] Fix P1: Remove tvOS from Session Replay recommendations (SKILL.md lines 82, 239)
- [ ] Fix P1: Correct `tracesSampleRate` type to `NSNumber?` and default to `nil` in SKILL.md:264 (and `sampleRate` at line 272)
- [ ] Fix P2: Update `"App Hanging"` exception type string in error-monitoring.md:238
- [ ] Fix P2: Update cross-link table Node/JS suggestion in SKILL.md:349
- [ ] Fix P2: Add v9.0.0+ version note to `enablePropagateTraceparent` in tracing.md:360
