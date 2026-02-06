//
//  HabitSchedule.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import Foundation

enum Weekday: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
}

enum HabitSchedule: Codable, Equatable {
    case everyDay
    case weekdays
    case custom(Set<Weekday>)

    var displayName: String {
        switch self {
        case .everyDay: return "Every day"
        case .weekdays: return "Weekdays"
        case .custom(let days):
            if days.isEmpty { return "Custom" }
            let sorted = days.sorted { $0.rawValue < $1.rawValue }
            return sorted.map(\.shortName).joined(separator: ", ")
        }
    }

    /// Whether this schedule includes the given date (start of day used for weekday).
    func isScheduled(on date: Date) -> Bool {
        let cal = Calendar.current
        let weekdayRaw = cal.component(.weekday, from: date)
        guard let w = Weekday(rawValue: weekdayRaw) else { return false }
        switch self {
        case .everyDay: return true
        case .weekdays: return (Weekday.monday.rawValue...Weekday.friday.rawValue).contains(weekdayRaw)
        case .custom(let days): return days.contains(w)
        }
    }
}
