# Daily Check

![Swift](https://img.shields.io/badge/Swift-5-orange.svg) ![Xcode](https://img.shields.io/badge/Xcode-26-blue.svg) ![iOS](https://img.shields.io/badge/iOS-17%2B-lightgrey.svg)

DailyCheck makes it easy to manage your to-dos by date.

## Download

- English: https://apps.apple.com/kr/app/dailycheck-to-do-list/id1544950171?l=en
- 한국어: https://apps.apple.com/kr/app/데일리체크-오늘의-할-일/id1544950171

## Status

Shipping on the App Store since 2020. Actively being modernized — the current codebase is UIKit + RxSwift + CocoaPods, migrating to **SwiftUI + The Composable Architecture + SwiftData + Tuist**. The App Store build is live, so the migration preserves existing user data.

Progress is tracked as [GitHub milestones](https://github.com/bigtoy2645/todoList-iOS/milestones) (Phase 0 → Phase 5). See [CLAUDE.md](./CLAUDE.md) for architecture state and development conventions.

## Architecture

| Area | Today | Target |
|---|---|---|
| UI | UIKit, Storyboard, XIB | SwiftUI |
| State | RxSwift + MVVM | TCA (`swift-composable-architecture`) |
| Persistence | `UserDefaults` + JSONEncoder | SwiftData (with migration from legacy keys) |
| Dependencies | CocoaPods | SPM |
| Project | `.xcodeproj` / `.xcworkspace` | Tuist-generated |
| App entry | `AppDelegate` + `SceneDelegate` + storyboard | `@main App` + `WindowGroup` |

## Learning goals

This repo doubles as a portfolio project for the stack most Korean iOS job postings currently require: SwiftUI, TCA, Tuist, and AI-assisted developer workflow. The migration is executed one screen at a time behind GitHub issues so the PR history reflects the process end-to-end.

## Screenshots

#### Light Mode
|![](/Image/light+dailytasks.png)|![](/Image/light+createtask.png)|
|----|----|
|![](/Image/light+calendar+month.png)|![](/Image/light+changeorder.png)|

#### Dark Mode
|![](/Image/dark+dailytasks.png)|![](/Image/dark+createtask.png)|
|----|----|
|![](/Image/dark+calendar+month.png)|![](/Image/dark+changeorder.png)|

> Screenshots reflect the current UIKit build; they will be refreshed as the SwiftUI migration lands.
