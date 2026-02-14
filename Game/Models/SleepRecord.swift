//
//  SleepRecord.swift
//  Counting Sheep
//
//  One night of sleep data, decoupled from HealthKit types.
//

import Foundation

struct SleepRecord: Codable, Identifiable {
    var id: Date { date }

    /// Start-of-day for the morning the user woke up (the date the sleep is attributed to).
    let date: Date

    /// Total time asleep across all stages (minutes).
    let totalMinutes: Double

    /// Deep sleep minutes (AASM stage 3).
    let deepMinutes: Double

    /// Core / light sleep minutes (AASM stages 1-2).
    let coreMinutes: Double

    /// REM sleep minutes.
    let remMinutes: Double

    /// Total time spent in bed (includes awake periods).
    let inBedMinutes: Double

    // MARK: - Convenience

    var totalHours: Double { totalMinutes / 60.0 }
    var inBedHours: Double { inBedMinutes / 60.0 }

    /// Sleep efficiency: proportion of in-bed time actually spent asleep.
    var efficiency: Double {
        guard inBedMinutes > 0 else { return 0 }
        return min(1.0, totalMinutes / inBedMinutes)
    }

    /// Whether the user met a given sleep goal (in hours).
    func metGoal(_ goalHours: Double) -> Bool {
        totalHours >= goalHours
    }
}
