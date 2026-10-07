# CLAUDE.md

Context for AI-assisted development on this repo. Read this first when picking up a new session.

## Project

**DailyCheck** — a date-oriented to-do app shipped on the [App Store](https://apps.apple.com/kr/app/dailycheck-to-do-list/id1544950171) since 2020. This repo is being modernized as an iOS portfolio project (SwiftUI, TCA, Tuist, AI-assisted workflow). The App Store build is live, so existing user data must survive the rewrite.

## State of the migration

Mixed codebase; migration is in flight.

| Area | Current | Target |
|---|---|---|
| UI | UIKit + Storyboard + XIB | SwiftUI |
| State | RxSwift + MVVM | TCA (`swift-composable-architecture`) |
| Persistence | `UserDefaults` + JSONEncoder | SwiftData with one-shot migration from the legacy keys |
| Dependencies | CocoaPods (`FSCalendar`, `RxSwift`, `RxCocoa`, `RxDataSources`, `RxTest`) | SPM only |
| Project format | `.xcodeproj` + `.xcworkspace` | Tuist-generated |
| App entry | `AppDelegate` + `SceneDelegate` + `Main.storyboard` | `@main App` + `WindowGroup` |

Progress is tracked as [GitHub milestones](https://github.com/bigtoy2645/todoList-iOS/milestones) Phase 0 through Phase 5. Phase 0 (toolchain) is partially done; Phases 1–5 are open.

## Workflow

- **Branches**: issue-per-branch off `develop`. Naming: `<type>/#<issue>-<slug>` (e.g. `infra/#5-toolchain-upgrade`, `docs/#7-claude-md`). `master` only receives `develop` merges at App Store release time; no `release/*` branches.
- **PRs**: open against `develop`. Self-review via `/code-review` is fine. `Closes #N` in the PR body does **not** auto-close because `develop` is not the default branch — close issues manually with `gh issue close <N> --comment "Merged via #<PR>." --reason completed` after merge.
- **Commits**: single-line title only. Format: `<type>: <lowercase description> (#<issue>)`. Types in use: `feat`, `fix`, `refactor`, `test`, `docs`, `chore` (chore covers build system / tooling / dependencies). No body, no `Co-Authored-By` trailer — long rationale goes in the PR description instead.
- **Language**: English for GitHub issues, PR titles/bodies, commit messages, README, and CLAUDE.md. Chat and personal notes can be Korean.

## Build & test

Workspace: `todoList.xcworkspace` (CocoaPods — do not use `.xcodeproj` directly). Scheme: `todoList`. Bundle id: `com.yurim.dailycheck`.

```sh
# Install pods (post_install hook forces every pod to iOS 17.0)
pod install

# Build + run unit tests on the minimum deployment target
xcodebuild \
  -workspace todoList.xcworkspace \
  -scheme todoList \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
  -configuration Debug \
  build test

# Smoke test manually
xcrun simctl boot 52BB9B47-CA08-4FE0-B24F-5581C8C97077   # iPhone 15 / iOS 17.5
open -a Simulator
xcrun simctl install booted /path/to/DailyCheck.app
xcrun simctl launch booted com.yurim.dailycheck
xcrun simctl io booted screenshot /tmp/out.png
```

## Critical invariants

- **Deployment target: iOS 17.0.** Covers ~97.7% of active devices (TelemetryDeck, Sep 2026). Enables SwiftData, `@Observable`, modern SwiftUI. Do not lower.
- **Preserve existing user data.** The App Store build stores todos in `UserDefaults` under keys `Scheduled` and `Anytime` plus a flag `isFirstLaunch`. When persistence moves to SwiftData (issue #16), the first launch of the new version must read those keys, seed SwiftData, and only then clear them. A regression here deletes real users' todos.
- **`CFBundleVersion` auto-bumps on every build.** `Info.plist` will show as dirty after any local build — this is from the `chore: add script to increment build number` script. Do not commit the bump as part of unrelated PRs.
- **Pods deployment target is forced by `Podfile`'s `post_install` hook.** Without it, FSCalendar's iOS 8.0 target fails to link on Xcode 26 (missing `libarclite`). Preserve the hook when touching the Podfile.

## WIP preserved out-of-tree

- `stash@{0}` on `develop` contains an in-progress push-notification + settings-screen prototype from 2020~2021. Includes remote-push code (device token registration) that is not needed for the planned local scheduled reminders. Reuse only the auth-request pattern during Phase 3 (issue to be created, see milestone Phase 3: New Features).

## Learning goals (why this repo exists)

Portfolio project to demonstrate the stack most Korean iOS job postings currently require: SwiftUI, TCA, Tuist, and AI-assisted developer workflow. Hiring managers read the PR history and milestone progress, so prefer slightly ceremonious workflow (issues, PRs, labels, milestones) over speed shortcuts.
