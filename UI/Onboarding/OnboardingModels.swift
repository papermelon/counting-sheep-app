//
//  OnboardingModels.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import Foundation
import Combine

// MARK: - Persistence

enum OnboardingPersistence {
    static let hasCompletedKey = "SheepAtsume.hasCompletedOnboarding"
    static let answersKey = "SheepAtsume.onboardingAnswers.v1"
    static let hasCompletedTutorialKey = "SheepAtsume.hasCompletedTutorial"

    /// Onboarding (name, habits, bedtime, etc.) is shown only once per install. It does not reappear after inactivity.
    static var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasCompletedKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasCompletedKey) }
    }

    /// True once the user has skipped or finished the in-app tutorial (sheep = habits, check-in, tabs).
    static var hasCompletedTutorial: Bool {
        get { UserDefaults.standard.bool(forKey: hasCompletedTutorialKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasCompletedTutorialKey) }
    }

    static func saveAnswers(_ answers: OnboardingAnswers) {
        guard let data = try? JSONEncoder().encode(answers) else { return }
        UserDefaults.standard.set(data, forKey: answersKey)
    }

    static func loadAnswers() -> OnboardingAnswers? {
        guard let data = UserDefaults.standard.data(forKey: answersKey),
              let answers = try? JSONDecoder().decode(OnboardingAnswers.self, from: data) else { return nil }
        return answers
    }
}

// MARK: - OnboardingAnswers

struct OnboardingAnswers: Codable {
    var userName: String
    var habitTrackRecord: String?
    var typicalBedtime: Date?
    var sleepDurationBucket: String?
    var sleepChallenges: [String]
    var selectedHabitIds: [String]

    init(
        userName: String = "",
        habitTrackRecord: String? = nil,
        typicalBedtime: Date? = nil,
        sleepDurationBucket: String? = nil,
        sleepChallenges: [String] = [],
        selectedHabitIds: [String] = []
    ) {
        self.userName = userName
        self.habitTrackRecord = habitTrackRecord
        self.typicalBedtime = typicalBedtime
        self.sleepDurationBucket = sleepDurationBucket
        self.sleepChallenges = sleepChallenges
        self.selectedHabitIds = selectedHabitIds
    }
}

// MARK: - Habit track record

enum HabitTrackRecordOption: String, CaseIterable {
    case struggled = "I've struggled to build habits"
    case mixed = "Some successes; some failures"
    case good = "I'm good at building habits"
}

// MARK: - Sleep duration

enum SleepDurationOption: String, CaseIterable {
    case lessThan5 = "Less than 5"
    case fiveToSix = "5-6"
    case sixToSeven = "6-7"
    case sevenToEight = "7-8"
    case moreThan8 = "More than 8"
}

// MARK: - Sleep challenges

enum SleepChallengeOption: String, CaseIterable {
    case lateToBed = "Get in bed too late"
    case troubleFallingAsleep = "Trouble falling asleep"
    case wakeDuringNight = "Wake during the night"
    case wakeTooEarly = "Wake too early"
    case enoughStillTired = "Sleep \"enough\", still tired"
    case otherOrNotSure = "Other or not sure"
}

// MARK: - Sleep habit (for pick-one-habit step)

struct SleepHabit: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let isRecommended: Bool
    let usesHealthData: Bool

    static let recommended: [SleepHabit] = [
        SleepHabit(id: "no_liquids_9pm", title: "No liquids after 9pm", systemImage: "drop.triangle.fill", isRecommended: true, usesHealthData: false),
        SleepHabit(id: "no_caffeine_12pm", title: "No caffeine after 12pm", systemImage: "cup.and.saucer.fill", isRecommended: true, usesHealthData: false),
        SleepHabit(id: "no_alcohol_4h", title: "No alcohol within 4 hours of bed", systemImage: "wineglass.fill", isRecommended: true, usesHealthData: false),
    ]

    static let moreOptions: [SleepHabit] = [
        SleepHabit(id: "eight_hours", title: "Get 8 hours of sleep", systemImage: "moon.zzz.fill", isRecommended: false, usesHealthData: true),
        SleepHabit(id: "sunlight_first_thing", title: "Get sunlight first thing", systemImage: "sun.max.fill", isRecommended: false, usesHealthData: false),
        SleepHabit(id: "phone_out_of_bedroom", title: "Sleep with phone out of bedroom", systemImage: "iphone.slash", isRecommended: false, usesHealthData: false),
        SleepHabit(id: "last_meal_3h", title: "Finish last meal 3 hours before bed", systemImage: "fork.knife", isRecommended: false, usesHealthData: false),
        SleepHabit(id: "in_bed_by_1030", title: "Get in bed by 10:30pm", systemImage: "bed.double.fill", isRecommended: false, usesHealthData: false),
        SleepHabit(id: "no_blue_light_8pm", title: "No blue light after 8pm", systemImage: "iphone", isRecommended: false, usesHealthData: false),
        SleepHabit(id: "phone_away_10pm", title: "Put phone away at 10pm", systemImage: "clock.badge.checkmark", isRecommended: false, usesHealthData: false),
        SleepHabit(id: "read_fiction", title: "Read fiction before bed", systemImage: "book.fill", isRecommended: false, usesHealthData: false),
    ]

    static var all: [SleepHabit] { recommended + moreOptions }
}

// MARK: - OnboardingFlowState

final class OnboardingFlowState: ObservableObject {
    @Published var currentStep: OnboardingStep
    @Published var answers: OnboardingAnswers

    init(answers: OnboardingAnswers = OnboardingAnswers()) {
        self.currentStep = .name
        self.answers = answers
    }

    var progress: Double { currentStep.progress }

    func nextStep() {
        guard let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = next
    }

    func previousStep() {
        guard currentStep.canGoBack, let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prev
    }

    func complete() {
        OnboardingPersistence.hasCompletedOnboarding = true
        OnboardingPersistence.saveAnswers(answers)
    }
}

// MARK: - OnboardingStep

enum OnboardingStep: Int, CaseIterable {
    case name = 0
    case habitTrackRecord
    case motivational
    case appValue
    case bedtime
    case sleepDuration
    case sleepChallenges
    case pickHabit
    case finish

    var progress: Double {
        Double(rawValue) / Double(Self.allCases.count)
    }

    var canGoBack: Bool { rawValue > 0 }
    var isLast: Bool { self == .finish }
}
