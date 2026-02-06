//
//  GameState.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import Foundation
import Combine

enum GameMode: String, Codable, CaseIterable {
    case cozy
    case verified
    
    var displayName: String {
        switch self {
        case .cozy: return "Cozy"
        case .verified: return "Verified"
        }
    }
}

class GameState: ObservableObject {
    @Published var coins: Int
    @Published var streak: Int
    @Published var lastNightResult: NightResult?
    @Published var mode: GameMode
    @Published var bedtimeStart: Date
    @Published var bedtimeEnd: Date
    @Published var notificationsEnabled: Bool
    @Published var lastUsageMinutes: Int?
    @Published var habitSheep: [HabitSheep]
    @Published var lastCheckInDate: Date?
    @Published var checkInStreak: Int

    var sheepCount: Int { max(1, habitSheep.count) }

    init(
        coins: Int = 0,
        streak: Int = 0,
        lastNightResult: NightResult? = nil,
        mode: GameMode = .cozy,
        bedtimeStart: Date = GameState.defaultBedtimeStart,
        bedtimeEnd: Date = GameState.defaultBedtimeEnd,
        notificationsEnabled: Bool = false,
        lastUsageMinutes: Int? = nil,
        habitSheep: [HabitSheep] = [],
        lastCheckInDate: Date? = nil,
        checkInStreak: Int = 0
    ) {
        self.coins = coins
        self.streak = streak
        self.lastNightResult = lastNightResult
        self.mode = mode
        self.bedtimeStart = bedtimeStart
        self.bedtimeEnd = bedtimeEnd
        self.notificationsEnabled = notificationsEnabled
        self.lastUsageMinutes = lastUsageMinutes
        self.habitSheep = habitSheep
        self.lastCheckInDate = lastCheckInDate
        self.checkInStreak = checkInStreak

        loadPersistedState()
    }
    
    func logNight(level: NightSuccessLevel) {
        let result = NightResult(date: Date(), level: level)
        lastNightResult = result
        
        // Streak: maintain for 2+ stars
        switch level {
        case .threeStars, .twoStars:
            streak += 1
        case .oneStar, .zeroStars:
            streak = 0
        }
        
        // Coins based on stars
        switch level {
        case .threeStars:
            coins += 10
        case .twoStars:
            coins += 6
        case .oneStar:
            coins += 2
        case .zeroStars:
            break
        }
        
        persistState()
    }
    
    // Placeholder for Verified mode: map usage minutes to star level
    @discardableResult
    func logNightFromUsageMinutes(_ minutes: Int) -> NightSuccessLevel {
        let level = Self.level(forUsageMinutes: minutes)
        lastUsageMinutes = minutes
        logNight(level: level)
        return level
    }
    
    static func level(forUsageMinutes minutes: Int) -> NightSuccessLevel {
        switch minutes {
        case ..<5: return .threeStars
        case 5..<20: return .twoStars
        case 20..<45: return .oneStar
        default: return .zeroStars
        }
    }
    
    func needsCheckInToday() -> Bool {
        let cal = Calendar.current
        guard !habitSheep.isEmpty else { return false }
        guard let last = lastCheckInDate else { return true }
        return !cal.isDateInToday(last)
    }

    /// Submit morning check-in: habitId -> did the user do it today.
    func submitCheckIn(habitResults: [String: Bool]) {
        let today = Calendar.current.startOfDay(for: Date())
        var updated: [HabitSheep] = []
        for var sheep in habitSheep {
            let didIt = habitResults[sheep.habitId] ?? false
            if didIt {
                sheep.consecutiveDaysDone += 1
                sheep.lastCheckedDate = Date()
                sheep.growthStage = growthStage(forConsecutiveDays: sheep.consecutiveDaysDone)
                if !sheep.completionDateSet.contains(today) {
                    sheep.completionDates = (sheep.completionDates + [today]).sorted()
                }
            } else {
                sheep.consecutiveDaysDone = 0
                sheep.growthStage = .needsCare
            }
            updated.append(sheep)
        }
        habitSheep = updated
        let previousCheckIn = lastCheckInDate
        lastCheckInDate = Date()
        if let prev = previousCheckIn {
            let cal = Calendar.current
            if cal.isDateInToday(prev) { /* already checked in today, don't change streak */ }
            else if cal.isDateInYesterday(prev) { checkInStreak += 1 }
            else { checkInStreak = 1 }
        } else {
            checkInStreak = 1
        }
        persistState()
    }

    private func growthStage(forConsecutiveDays days: Int) -> SheepGrowthStage {
        switch days {
        case 0: return .needsCare
        case 1..<3: return .growing
        default: return .thriving
        }
    }

    func updateHabitSheep(_ sheep: HabitSheep) {
        guard let idx = habitSheep.firstIndex(where: { $0.habitId == sheep.habitId }) else { return }
        var updated = habitSheep
        updated[idx] = sheep
        habitSheep = updated
        persistState()
    }

    /// Record a single habit result (e.g. from Screen Time in Verified mode). Updates that sheep's growth and sets lastCheckInDate for today.
    func recordHabitResult(habitId: String, didIt: Bool) {
        guard let idx = habitSheep.firstIndex(where: { $0.habitId == habitId }) else { return }
        var sheep = habitSheep[idx]
        let today = Calendar.current.startOfDay(for: Date())
        if didIt {
            sheep.consecutiveDaysDone += 1
            sheep.lastCheckedDate = Date()
            sheep.growthStage = growthStage(forConsecutiveDays: sheep.consecutiveDaysDone)
            if !sheep.completionDateSet.contains(today) {
                sheep.completionDates = (sheep.completionDates + [today]).sorted()
            }
        } else {
            sheep.consecutiveDaysDone = 0
            sheep.growthStage = .needsCare
        }
        habitSheep[idx] = sheep
        let previousCheckIn = lastCheckInDate
        lastCheckInDate = Date()
        if let prev = previousCheckIn {
            let cal = Calendar.current
            if cal.isDateInToday(prev) { }
            else if cal.isDateInYesterday(prev) { checkInStreak += 1 }
            else { checkInStreak = 1 }
        } else {
            checkInStreak = 1
        }
        persistState()
    }

    /// Habit IDs that can be auto-checked from Screen Time (per-habit "Use Screen Time" toggle).
    static let screenHabitIds = ["phone_away_10pm", "no_blue_light_8pm", "phone_out_of_bedroom"]

    /// Habit IDs that currently have "Use Screen Time" enabled and are screen habits.
    var verifiedScreenHabitIds: [String] {
        habitSheep.filter { $0.useVerifiedTracking && Self.screenHabitIds.contains($0.habitId) }.map(\.habitId)
    }

    /// True if any habit uses Screen Time for tracking (used to start/stop bedtime monitoring).
    var hasAnyVerifiedScreenHabit: Bool {
        !verifiedScreenHabitIds.isEmpty
    }

    /// Mark a single habit as completed today (e.g. from Habit detail "Completed Today" button).
    func markHabitCompletedToday(habitId: String) {
        guard let idx = habitSheep.firstIndex(where: { $0.habitId == habitId }) else { return }
        var sheep = habitSheep[idx]
        let today = Calendar.current.startOfDay(for: Date())
        if sheep.completionDateSet.contains(today) { return }
        sheep.consecutiveDaysDone += 1
        sheep.lastCheckedDate = Date()
        sheep.growthStage = growthStage(forConsecutiveDays: sheep.consecutiveDaysDone)
        sheep.completionDates = (sheep.completionDates + [today]).sorted()
        habitSheep[idx] = sheep
        let previousCheckIn = lastCheckInDate
        lastCheckInDate = Date()
        if let prev = previousCheckIn {
            let cal = Calendar.current
            if cal.isDateInToday(prev) { }
            else if cal.isDateInYesterday(prev) { checkInStreak += 1 }
            else { checkInStreak = 1 }
        } else {
            checkInStreak = 1
        }
        persistState()
    }

    // MARK: - Persistence (simple UserDefaults)
    private let storageKey = "GameState.persistence.v3"

    private struct PersistedState: Codable {
        let coins: Int
        let streak: Int
        let lastNightResult: NightResult?
        let mode: GameMode
        let bedtimeStart: Date
        let bedtimeEnd: Date
        let notificationsEnabled: Bool
        let lastUsageMinutes: Int?
        let habitSheep: [HabitSheep]?
        let lastCheckInDate: Date?
        let checkInStreak: Int?
    }

    private func persistState() {
        let state = PersistedState(
            coins: coins,
            streak: streak,
            lastNightResult: lastNightResult,
            mode: mode,
            bedtimeStart: bedtimeStart,
            bedtimeEnd: bedtimeEnd,
            notificationsEnabled: notificationsEnabled,
            lastUsageMinutes: lastUsageMinutes,
            habitSheep: habitSheep.isEmpty ? nil : habitSheep,
            lastCheckInDate: lastCheckInDate,
            checkInStreak: checkInStreak
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadPersistedState() {
        // Try v2 first
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let state = try? JSONDecoder().decode(PersistedState.self, from: data) {
            coins = state.coins
            streak = state.streak
            lastNightResult = state.lastNightResult
            mode = state.mode
            bedtimeStart = state.bedtimeStart
            bedtimeEnd = state.bedtimeEnd
            notificationsEnabled = state.notificationsEnabled
            lastUsageMinutes = state.lastUsageMinutes
            habitSheep = state.habitSheep ?? []
            lastCheckInDate = state.lastCheckInDate
            checkInStreak = state.checkInStreak ?? 0
            return
        }
        // Fallback: try v2 then v1 for backward compat
        let v2Key = "GameState.persistence.v2"
        if let data = UserDefaults.standard.data(forKey: v2Key),
           let state = try? JSONDecoder().decode(PersistedState.self, from: data) {
            coins = state.coins
            streak = state.streak
            lastNightResult = state.lastNightResult
            mode = state.mode
            bedtimeStart = state.bedtimeStart
            bedtimeEnd = state.bedtimeEnd
            notificationsEnabled = state.notificationsEnabled
            lastUsageMinutes = state.lastUsageMinutes
            habitSheep = state.habitSheep ?? []
            lastCheckInDate = state.lastCheckInDate
            checkInStreak = state.checkInStreak ?? 0
            persistState()
            return
        }
        let v1Key = "GameState.persistence.v1"
        guard let data = UserDefaults.standard.data(forKey: v1Key),
              let state = try? JSONDecoder().decode(PersistedStateV1.self, from: data) else { return }
        coins = state.coins
        streak = state.streak
        lastNightResult = state.lastNightResult
        mode = state.mode
        bedtimeStart = state.bedtimeStart
        bedtimeEnd = state.bedtimeEnd
        notificationsEnabled = state.notificationsEnabled
        lastUsageMinutes = state.lastUsageMinutes
        habitSheep = []
        lastCheckInDate = nil
        checkInStreak = 0
        persistState()
    }

    private struct PersistedStateV1: Codable {
        let coins: Int
        let streak: Int
        let lastNightResult: NightResult?
        let mode: GameMode
        let bedtimeStart: Date
        let bedtimeEnd: Date
        let notificationsEnabled: Bool
        let lastUsageMinutes: Int?
    }
    
    // Call when user changes settings
    func syncSettingsToStorage() {
        persistState()
    }
    
    // MARK: - Reward gating (example multiplier)
    var rewardMultiplier: Double {
        mode == .verified ? 1.2 : 1.0
    }
    
    var isVerifiedEligible: Bool {
        mode == .verified && lastUsageMinutes != nil
    }
    
    // MARK: - Defaults
    static var defaultBedtimeStart: Date {
        Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: Date()) ?? Date()
    }
    static var defaultBedtimeEnd: Date {
        Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    }
}
