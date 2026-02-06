//
//  ScreenTimeService.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import Foundation
import Combine
import DeviceActivity
import FamilyControls
import ManagedSettings

@MainActor
class ScreenTimeService: ObservableObject {
    static let shared = ScreenTimeService()
    
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    
    private let center = DeviceActivityCenter()
    private let scheduleName = DeviceActivityName("bedtimeSchedule")
    
    private init() {
        checkAuthorization()
    }
    
    // MARK: - Authorization
    
    func checkAuthorization() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }
    
    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        checkAuthorization()
    }
    
    // MARK: - Bedtime Schedule
    
    func startMonitoring(bedtimeStart: Date, bedtimeEnd: Date) {
        guard authorizationStatus == .approved else { return }
        
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: bedtimeStart)
        let endComponents = calendar.dateComponents([.hour, .minute], from: bedtimeEnd)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: startComponents.hour, minute: startComponents.minute),
            intervalEnd: DateComponents(hour: endComponents.hour, minute: endComponents.minute),
            repeats: true
        )
        
        do {
            try center.startMonitoring(scheduleName, during: schedule)
        } catch {
            // Avoid crashing on failed monitor start; consider surfacing this to UI if needed.
            print("Failed to start Screen Time monitoring: \(error)")
        }
    }
    
    func stopMonitoring() {
        center.stopMonitoring([scheduleName])
    }
    
    // MARK: - Fetch Usage Data
    
    /// Fetches total usage minutes during the bedtime window for yesterday
    func fetchLastNightUsageMinutes(bedtimeStart: Date, bedtimeEnd: Date) async -> Int? {
        guard authorizationStatus == .approved else { return nil }
        
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else { return nil }
        
        // Get bedtime window for yesterday
        let startComponents = calendar.dateComponents([.hour, .minute], from: bedtimeStart)
        let endComponents = calendar.dateComponents([.hour, .minute], from: bedtimeEnd)
        
        guard let windowStart = calendar.date(
            bySettingHour: startComponents.hour ?? 22,
            minute: startComponents.minute ?? 30,
            second: 0,
            of: yesterday
        ),
        let windowEnd = calendar.date(
            bySettingHour: endComponents.hour ?? 7,
            minute: endComponents.minute ?? 0,
            second: 0,
            of: yesterday
        ) else { return nil }
        
        _ = (windowStart, windowEnd)
        
        // Note: DeviceActivityReport requires a DeviceActivityReport extension
        // For now, we'll use a simplified approach that queries the interval
        // Full implementation would require a custom report extension
        
        // Simplified: Return placeholder for now
        // Real implementation needs DeviceActivityReport extension
        // DeviceActivityReport is not directly instantiable - it requires an extension
        return nil
    }
    
    // MARK: - Simplified Usage Fetch (Alternative Approach)
    
    /// Simplified approach: Query usage for a specific time interval
    /// This requires the app to have a DeviceActivityReport extension
    /// For MVP, we'll use a placeholder that can be replaced with real data
    func fetchUsageMinutesForInterval(start: Date, end: Date) async -> Int {
        // TODO: Implement actual DeviceActivityReport query
        // This requires:
        // 1. DeviceActivityReport extension target
        // 2. Custom report implementation
        // 3. Querying the report for the interval
        
        // Placeholder: Return 0 for now
        // In production, this would query Screen Time APIs
        return 0
    }
}

// MARK: - DeviceActivityMonitor (for real-time monitoring)

class BedtimeMonitor: DeviceActivityMonitor {
    nonisolated override init() {
        super.init()
    }

    nonisolated override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Bedtime started - could show Live Activity here
    }
    
    nonisolated override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Bedtime ended - fetch usage and log night result
        Task { @MainActor in
            // This would be called when bedtime window ends
            // Fetch usage and update game state
            // Access ScreenTimeService.shared here if needed
        }
    }
    
    nonisolated override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // Handle threshold events if needed
    }
}
