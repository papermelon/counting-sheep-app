//
//  HabitSheep.swift
//  Counting Sheep
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
    /// Seed for pixel-art sheep sprite. Same seed → same look. Change when user taps "Personalise" to re-roll the sprite.
    var spriteSeed: Int
    /// Redeemable wool balance. Shearing converts this KG amount into coins.
    var woolKg: Int
    /// Last time the sheep was sheared (used for cooldown).
    var lastShearedDate: Date?

    enum CodingKeys: String, CodingKey {
        case habitId, title, systemImage, growthStage, consecutiveDaysDone, lastCheckedDate
        case completionDates, customTitle, schedule, remindersEnabled, smartRemindersEnabled, targetTime, goalMinutes, useVerifiedTracking, spriteSeed
        case woolKg, lastShearedDate
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
        spriteSeed = try c.decodeIfPresent(Int.self, forKey: .spriteSeed) ?? habitId.hashValue
        if c.contains(.woolKg) {
            woolKg = try c.decodeIfPresent(Int.self, forKey: .woolKg) ?? 0
        } else {
            // Backward-compat: infer a starting wool balance for older saves that predate `woolKg`.
            woolKg = Self.estimatedWoolKgForLegacyData(consecutiveDaysDone: consecutiveDaysDone)
        }
        lastShearedDate = try c.decodeIfPresent(Date.self, forKey: .lastShearedDate)
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
        try c.encode(spriteSeed, forKey: .spriteSeed)
        try c.encode(woolKg, forKey: .woolKg)
        try c.encodeIfPresent(lastShearedDate, forKey: .lastShearedDate)
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
        useVerifiedTracking: Bool = false,
        spriteSeed: Int? = nil,
        woolKg: Int = 0,
        lastShearedDate: Date? = nil
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
        self.spriteSeed = spriteSeed ?? habitId.hashValue
        self.woolKg = woolKg
        self.lastShearedDate = lastShearedDate
    }

    /// Use when creating a new habit to assign a random sprite. Re-roll on "Personalise".
    static func randomSpriteSeed() -> Int { Int.random(in: 0..<Int.max) }

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

    private static func estimatedWoolKgForLegacyData(consecutiveDaysDone days: Int) -> Int {
        guard days > 0 else { return 0 }
        if days <= 2 { return days * 2 }
        return (3 * days) - 2
    }

    /// Display-facing sheep body weight in KG (habit strength surrogate).
    var weightKg: Int {
        switch growthStage {
        case .needsCare:
            return 28 + min(consecutiveDaysDone, 6)
        case .growing:
            return 38 + min(consecutiveDaysDone * 2, 20)
        case .thriving:
            return 58 + min(consecutiveDaysDone * 2, 42)
        }
    }
}
