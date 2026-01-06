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
    
    var sheepCount: Int
    
    init(
        coins: Int = 0,
        streak: Int = 0,
        lastNightResult: NightResult? = nil,
        sheepCount: Int = 0,
        mode: GameMode = .cozy,
        bedtimeStart: Date = GameState.defaultBedtimeStart,
        bedtimeEnd: Date = GameState.defaultBedtimeEnd,
        notificationsEnabled: Bool = false,
        lastUsageMinutes: Int? = nil
    ) {
        self.coins = coins
        self.streak = streak
        self.lastNightResult = lastNightResult
        self.sheepCount = sheepCount
        self.mode = mode
        self.bedtimeStart = bedtimeStart
        self.bedtimeEnd = bedtimeEnd
        self.notificationsEnabled = notificationsEnabled
        self.lastUsageMinutes = lastUsageMinutes
        
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
        guard let last = lastNightResult?.date else { return true }
        return !Calendar.current.isDateInToday(last)
    }
    
    // MARK: - Persistence (simple UserDefaults)
    private let storageKey = "GameState.persistence.v1"
    
    private struct PersistedState: Codable {
        let coins: Int
        let streak: Int
        let lastNightResult: NightResult?
        let mode: GameMode
        let bedtimeStart: Date
        let bedtimeEnd: Date
        let notificationsEnabled: Bool
        let lastUsageMinutes: Int?
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
            lastUsageMinutes: lastUsageMinutes
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadPersistedState() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data) else { return }
        coins = state.coins
        streak = state.streak
        lastNightResult = state.lastNightResult
        mode = state.mode
        bedtimeStart = state.bedtimeStart
        bedtimeEnd = state.bedtimeEnd
        notificationsEnabled = state.notificationsEnabled
        lastUsageMinutes = state.lastUsageMinutes
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

