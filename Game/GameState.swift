//
//  GameState.swift
//  Counting Sheep
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
    static let minimumShearKg = 10
    static let shearCooldownDays = 3
    static let coinsPerWoolKg = 1

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

    // MARK: - Sleep / HealthKit
    @Published var healthKitAuthorized: Bool
    @Published var sleepGoalHours: Double
    @Published var sleepRecords: [SleepRecord] = []

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
        checkInStreak: Int = 0,
        healthKitAuthorized: Bool = false,
        sleepGoalHours: Double = 8.0
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
        self.healthKitAuthorized = healthKitAuthorized
        self.sleepGoalHours = sleepGoalHours

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
            let alreadyCompletedToday = sheep.completionDateSet.contains(today)
            if didIt {
                if !alreadyCompletedToday {
                    sheep.consecutiveDaysDone += 1
                    sheep.lastCheckedDate = Date()
                    sheep.growthStage = growthStage(forConsecutiveDays: sheep.consecutiveDaysDone)
                    sheep.woolKg += woolGain(for: sheep.growthStage)
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
        let alreadyCompletedToday = sheep.completionDateSet.contains(today)
        if didIt {
            if !alreadyCompletedToday {
                sheep.consecutiveDaysDone += 1
                sheep.lastCheckedDate = Date()
                sheep.growthStage = growthStage(forConsecutiveDays: sheep.consecutiveDaysDone)
                sheep.woolKg += woolGain(for: sheep.growthStage)
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
        sheep.woolKg += woolGain(for: sheep.growthStage)
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

    /// Convert a sheep's accumulated wool (KG) into coins, respecting minimum wool and cooldown.
    @discardableResult
    func shearSheep(habitId: String) -> Int {
        guard let idx = habitSheep.firstIndex(where: { $0.habitId == habitId }) else { return 0 }
        var sheep = habitSheep[idx]
        guard canShearSheep(sheep) else { return 0 }
        let wool = sheep.woolKg
        guard wool >= Self.minimumShearKg else { return 0 }
        let earned = wool * Self.coinsPerWoolKg
        sheep.woolKg = 0
        sheep.lastShearedDate = Date()
        habitSheep[idx] = sheep
        coins += earned
        persistState()
        return earned
    }

    func canShearSheep(_ sheep: HabitSheep, now: Date = Date()) -> Bool {
        guard sheep.woolKg >= Self.minimumShearKg else { return false }
        return remainingShearCooldown(for: sheep, now: now) <= 0
    }

    /// Remaining seconds until this sheep can be sheared again (0 means ready now).
    func remainingShearCooldown(for sheep: HabitSheep, now: Date = Date()) -> TimeInterval {
        guard let last = sheep.lastShearedDate else { return 0 }
        let cooldown = TimeInterval(Self.shearCooldownDays * 24 * 60 * 60)
        let remaining = cooldown - now.timeIntervalSince(last)
        return max(0, remaining)
    }

    private func woolGain(for growthStage: SheepGrowthStage) -> Int {
        switch growthStage {
        case .needsCare: return 1
        case .growing: return 2
        case .thriving: return 3
        }
    }

    // MARK: - Sleep data refresh

    /// Fetches the last 30 days of sleep data from HealthKit into `sleepRecords`.
    func refreshSleepData() {
        guard healthKitAuthorized else { return }
        let cal = Calendar.current
        let endDate = Date()
        guard let startDate = cal.date(byAdding: .day, value: -30, to: cal.startOfDay(for: endDate)) else { return }
        Task {
            let records = await SleepHealthService.shared.fetchSleepRecords(from: startDate, to: endDate)
            self.sleepRecords = records
        }
    }

    // MARK: - Persistence (simple UserDefaults)
    private let storageKey = "GameState.persistence.v4"

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
        // v4 additions (optional for backward compat)
        let healthKitAuthorized: Bool?
        let sleepGoalHours: Double?
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
            checkInStreak: checkInStreak,
            healthKitAuthorized: healthKitAuthorized,
            sleepGoalHours: sleepGoalHours
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadPersistedState() {
        // Try v4 first
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let state = try? JSONDecoder().decode(PersistedState.self, from: data) {
            applyPersistedState(state)
            return
        }
        // Fallback: try v3 then v2 then v1 for backward compat
        let v3Key = "GameState.persistence.v3"
        if let data = UserDefaults.standard.data(forKey: v3Key),
           let state = try? JSONDecoder().decode(PersistedState.self, from: data) {
            applyPersistedState(state)
            persistState()
            return
        }
        let v2Key = "GameState.persistence.v2"
        if let data = UserDefaults.standard.data(forKey: v2Key),
           let state = try? JSONDecoder().decode(PersistedState.self, from: data) {
            applyPersistedState(state)
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
        healthKitAuthorized = false
        sleepGoalHours = 8.0
        persistState()
    }

    private func applyPersistedState(_ state: PersistedState) {
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
        healthKitAuthorized = state.healthKitAuthorized ?? false
        sleepGoalHours = state.sleepGoalHours ?? 8.0
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
