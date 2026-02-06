//
//  HabitSheep.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import Foundation

struct HabitSheep: Identifiable, Codable, Equatable {
    var id: String { habitId }
    let habitId: String
    var title: String
    var systemImage: String
    var growthStage: SheepGrowthStage
    var consecutiveDaysDone: Int
    var lastCheckedDate: Date?
    /// Dates (start of day) when this habit was completed. Used for weekly dots and 30-day %.
    var completionDates: [Date]
    // Customization
    var customTitle: String?
    var schedule: HabitSchedule
    var remindersEnabled: Bool
    var smartRemindersEnabled: Bool
    var targetTime: Date?
    var goalMinutes: Int?
    /// When true and this habit is a screen habit, Screen Time is used to auto-check it (e.g. phone away during bedtime).
    var useVerifiedTracking: Bool

    enum CodingKeys: String, CodingKey {
        case habitId, title, systemImage, growthStage, consecutiveDaysDone, lastCheckedDate
        case completionDates, customTitle, schedule, remindersEnabled, smartRemindersEnabled, targetTime, goalMinutes, useVerifiedTracking
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        habitId = try c.decode(String.self, forKey: .habitId)
        title = try c.decode(String.self, forKey: .title)
        systemImage = try c.decode(String.self, forKey: .systemImage)
        growthStage = try c.decode(SheepGrowthStage.self, forKey: .growthStage)
        consecutiveDaysDone = try c.decode(Int.self, forKey: .consecutiveDaysDone)
        lastCheckedDate = try c.decodeIfPresent(Date.self, forKey: .lastCheckedDate)
        completionDates = try c.decodeIfPresent([Date].self, forKey: .completionDates) ?? []
        customTitle = try c.decodeIfPresent(String.self, forKey: .customTitle)
        schedule = try c.decodeIfPresent(HabitSchedule.self, forKey: .schedule) ?? .everyDay
        remindersEnabled = try c.decodeIfPresent(Bool.self, forKey: .remindersEnabled) ?? true
        smartRemindersEnabled = try c.decodeIfPresent(Bool.self, forKey: .smartRemindersEnabled) ?? false
        targetTime = try c.decodeIfPresent(Date.self, forKey: .targetTime)
        goalMinutes = try c.decodeIfPresent(Int.self, forKey: .goalMinutes)
        useVerifiedTracking = try c.decodeIfPresent(Bool.self, forKey: .useVerifiedTracking) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(habitId, forKey: .habitId)
        try c.encode(title, forKey: .title)
        try c.encode(systemImage, forKey: .systemImage)
        try c.encode(growthStage, forKey: .growthStage)
        try c.encode(consecutiveDaysDone, forKey: .consecutiveDaysDone)
        try c.encodeIfPresent(lastCheckedDate, forKey: .lastCheckedDate)
        try c.encode(completionDates, forKey: .completionDates)
        try c.encodeIfPresent(customTitle, forKey: .customTitle)
        try c.encode(schedule, forKey: .schedule)
        try c.encode(remindersEnabled, forKey: .remindersEnabled)
        try c.encode(smartRemindersEnabled, forKey: .smartRemindersEnabled)
        try c.encodeIfPresent(targetTime, forKey: .targetTime)
        try c.encodeIfPresent(goalMinutes, forKey: .goalMinutes)
        try c.encode(useVerifiedTracking, forKey: .useVerifiedTracking)
    }

    var displayTitle: String {
        customTitle?.trimmingCharacters(in: .whitespaces).isEmpty == false ? (customTitle ?? title) : title
    }

    init(
        habitId: String,
        title: String,
        systemImage: String,
        growthStage: SheepGrowthStage = .needsCare,
        consecutiveDaysDone: Int = 0,
        lastCheckedDate: Date? = nil,
        completionDates: [Date] = [],
        customTitle: String? = nil,
        schedule: HabitSchedule = .everyDay,
        remindersEnabled: Bool = true,
        smartRemindersEnabled: Bool = false,
        targetTime: Date? = nil,
        goalMinutes: Int? = nil,
        useVerifiedTracking: Bool = false
    ) {
        self.habitId = habitId
        self.title = title
        self.systemImage = systemImage
        self.growthStage = growthStage
        self.consecutiveDaysDone = consecutiveDaysDone
        self.lastCheckedDate = lastCheckedDate
        self.completionDates = completionDates
        self.customTitle = customTitle
        self.schedule = schedule
        self.remindersEnabled = remindersEnabled
        self.smartRemindersEnabled = smartRemindersEnabled
        self.targetTime = targetTime
        self.goalMinutes = goalMinutes
        self.useVerifiedTracking = useVerifiedTracking
    }

    /// Normalized set of completion dates (start of day) for this habit.
    var completionDateSet: Set<Date> {
        let cal = Calendar.current
        return Set(completionDates.map { cal.startOfDay(for: $0) })
    }

    /// Whether this habit was completed on the given day (start of day).
    func completed(on date: Date) -> Bool {
        let cal = Calendar.current
        let day = cal.startOfDay(for: date)
        return completionDateSet.contains(day)
    }
}
