# Counting Sheep

An iOS sleep and habit companion that turns healthy bedtime behavior into a playful sheep-growth game.

Counting Sheep combines cozy game mechanics with device-native wellness signals. Users set bedtime habits, complete morning check-ins, grow sheep, collect wool, and earn coins while building better sleep routines.

## Why This Project

Most habit trackers feel clinical. Counting Sheep is designed to make consistency feel rewarding, visual, and fun while staying privacy-first.

## Skills Demonstrated

- Agentic product development: rapid iteration from idea -> prototype -> shipped features using AI-assisted coding workflows
- UX for AI-assisted applications: interaction patterns that blend automation, user intent, and clear manual override paths
- Multimodal context integration: combines habit actions, sleep signals (HealthKit), and Screen Time signals into one gameplay loop
- Domain-focused system design: wellness-focused mechanics with practical constraints (on-device privacy, permissioned data access)
- Evaluation mindset: explicit roadmap for improving verification quality, measurement, and behavior-change outcomes

## Core Features

- Cozy + Verified play modes
- Habit-based sheep growth (care -> growing -> thriving)
- Morning check-ins and streak tracking
- Wool shearing economy and in-app coin rewards
- Bedtime + morning local notifications
- HealthKit sleep-read integration (read-only)
- Screen Time authorization + verified tracking scaffolding
- Multi-tab app experience: Home, Progress, Toolkit, Community

## Tech Stack

- Swift
- SwiftUI
- Combine
- UserNotifications
- HealthKit
- DeviceActivity / FamilyControls / ManagedSettings (for verified mode flow)

## Architecture

- App state is managed by `GameState` (`ObservableObject`).
- Data models are `Codable` structs/enums for safe persistence and migration.
- Persistence is currently local-only via `UserDefaults` with versioned JSON state (`GameState.persistence.v4`).
- Sleep metrics are read on-device from HealthKit and mapped into app-friendly `SleepRecord` models.
- Notifications are scheduled locally on-device using `UNUserNotificationCenter`.

## Product Direction

Counting Sheep is being developed as a practical example of an AI-assisted consumer product: strong UX, constrained data access, and measurable improvement loops. The focus is to keep shipping quality features while tightening verification and evaluation over time.

### Current Backend Status

This app currently has **no remote backend/database**. User and game data are stored on-device only.

## Project Structure

- `/App` - app entry and root composition
- `/Game` - game state and domain models
- `/UI` - screens and reusable UI components
- `/Utilities` - platform services (Screen Time, HealthKit, notifications)
- `/Resources` - bundled content

## Run Locally (Xcode)

1. Clone the repo.
2. Open `Counting Sheep.xcodeproj` in Xcode.
3. Select an iOS Simulator or physical device.
4. Build and run.
5. If testing sleep features, grant Health permissions when prompted.

## Permissions

- HealthKit (read-only sleep analysis)
- Notifications
- Screen Time / Family Controls (for verified tracking flows)

## Roadmap

- Near-term: add Lock Screen and Home Screen widgets for bedtime reminders, streaks, and quick check-ins
- Near-term: add Apple Watch companion features for habit check-ins, bedtime prompts, and glanceable sleep progress
- Complete Screen Time report-extension pipeline for real verified usage scoring
- Add optional cloud sync for cross-device continuity
- Add social/community progression loops
- Add analytics/evaluation framework for behavior-change outcomes

## Author

Ngawang Chime
