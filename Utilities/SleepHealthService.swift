//
//  SleepHealthService.swift
//  Counting Sheep
//
//  Wraps HealthKit sleep analysis queries. Only reads data, never writes.
//

import Foundation
import HealthKit

@MainActor
class SleepHealthService {
    static let shared = SleepHealthService()

    private let healthStore = HKHealthStore()
    private let sleepType = HKCategoryType(.sleepAnalysis)

    private init() {}

    // MARK: - Availability

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    /// Requests read-only access to sleep analysis data.
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [sleepType])
            return true
        } catch {
            print("[SleepHealthService] Authorization failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Fetch sleep records

    /// Fetches sleep records for a date range. Each record represents one night, attributed to the wake-up date.
    func fetchSleepRecords(from startDate: Date, to endDate: Date) async -> [SleepRecord] {
        guard isAvailable else { return [] }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let samples: [HKCategorySample] = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error = error {
                    print("[SleepHealthService] Query error: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                    return
                }
                continuation.resume(returning: (results as? [HKCategorySample]) ?? [])
            }
            healthStore.execute(query)
        }

        return groupSamplesIntoRecords(samples)
    }

    // MARK: - Grouping

    /// Groups raw HealthKit samples by night (using the wake-up calendar date) and aggregates stage durations.
    private func groupSamplesIntoRecords(_ samples: [HKCategorySample]) -> [SleepRecord] {
        let cal = Calendar.current

        // Group by the calendar date of each sample's endDate (wake-up date).
        var buckets: [Date: [HKCategorySample]] = [:]
        for sample in samples {
            let day = cal.startOfDay(for: sample.endDate)
            buckets[day, default: []].append(sample)
        }

        var records: [SleepRecord] = []
        for (day, daySamples) in buckets {
            var deep: Double = 0
            var core: Double = 0
            var rem: Double = 0
            var unspecified: Double = 0
            var inBed: Double = 0

            for sample in daySamples {
                let minutes = sample.endDate.timeIntervalSince(sample.startDate) / 60.0
                guard minutes > 0 else { continue }

                let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)
                switch value {
                case .asleepDeep:
                    deep += minutes
                case .asleepCore:
                    core += minutes
                case .asleepREM:
                    rem += minutes
                case .asleepUnspecified, .asleep:
                    unspecified += minutes
                case .inBed:
                    inBed += minutes
                case .awake:
                    // Counted in inBed but not in total asleep
                    inBed += minutes
                default:
                    break
                }
            }

            let totalAsleep = deep + core + rem + unspecified
            // If there's no inBed data but we have sleep data, use total asleep as a fallback.
            let effectiveInBed = inBed > 0 ? inBed : totalAsleep

            // Skip days with negligible data (< 30 min).
            guard totalAsleep >= 30 else { continue }

            records.append(SleepRecord(
                date: day,
                totalMinutes: totalAsleep,
                deepMinutes: deep,
                coreMinutes: core,
                remMinutes: rem,
                inBedMinutes: effectiveInBed
            ))
        }

        return records.sorted { $0.date < $1.date }
    }
}
