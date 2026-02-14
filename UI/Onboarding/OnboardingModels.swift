//
//  OnboardingModels.swift
//  Counting Sheep
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
    // New wellbeing questions
    var exerciseFrequency: String?
    var screentimeConcerns: [String]
    var dietGoals: [String]

    init(
        userName: String = "",
        habitTrackRecord: String? = nil,
        typicalBedtime: Date? = nil,
        sleepDurationBucket: String? = nil,
        sleepChallenges: [String] = [],
        selectedHabitIds: [String] = [],
        exerciseFrequency: String? = nil,
        screentimeConcerns: [String] = [],
        dietGoals: [String] = []
    ) {
        self.userName = userName
        self.habitTrackRecord = habitTrackRecord
        self.typicalBedtime = typicalBedtime
        self.sleepDurationBucket = sleepDurationBucket
        self.sleepChallenges = sleepChallenges
        self.selectedHabitIds = selectedHabitIds
        self.exerciseFrequency = exerciseFrequency
        self.screentimeConcerns = screentimeConcerns
        self.dietGoals = dietGoals
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

// MARK: - Exercise frequency

enum ExerciseFrequencyOption: String, CaseIterable {
    case rarely = "Rarely or never"
    case oneToTwo = "1-2 times a week"
    case threeToFour = "3-4 times a week"
    case fivePlus = "5+ times a week"
}

// MARK: - Screen time concerns

enum ScreentimeConcernOption: String, CaseIterable {
    case socialMediaAtNight = "Scrolling social media at night"
    case morningPhoneCheck = "Checking phone first thing"
    case tooMuchOverall = "Too much screen time overall"
    case workLifeBlur = "Work notifications bleeding into rest"
    case noConcern = "Not a concern for me"
}

// MARK: - Diet goals

enum DietGoalOption: String, CaseIterable {
    case eatHealthier = "Eat healthier overall"
    case drinkMoreWater = "Drink more water"
    case cutLateSnacks = "Stop late-night snacking"
    case mealPrep = "Cook or prep meals more"
    case noConcern = "Not a focus right now"
}

// MARK: - Habit category

import SwiftUI

enum HabitCategory: String, Codable, CaseIterable {
    case sleep
    case exercise
    case focus
    case diet
    case relationships

    var displayName: String {
        switch self {
        case .sleep:         return "Sleep"
        case .exercise:      return "Exercise & movement"
        case .focus:         return "Focus & screentime"
        case .diet:          return "Diet"
        case .relationships: return "Relationships"
        }
    }

    var color: Color {
        switch self {
        case .sleep:         return Color(red: 0.7, green: 0.5, blue: 1.0)      // purple
        case .exercise:      return Color(red: 0.55, green: 0.85, blue: 0.35)    // apple-fitness green
        case .focus:         return Color(red: 0.3, green: 0.75, blue: 0.7)      // teal green
        case .diet:          return Color(red: 0.95, green: 0.65, blue: 0.2)     // orange
        case .relationships: return Color(red: 0.95, green: 0.8, blue: 0.2)      // yellow
        }
    }

    /// How this category relates back to sleep (shown as subtitle in onboarding)
    var sleepNarrative: String {
        switch self {
        case .sleep:         return ""
        case .exercise:      return "Regular exercise deepens sleep and helps you fall asleep faster."
        case .focus:         return "Managing screen time protects your circadian rhythm and wind-down time."
        case .diet:          return "What you eat and drink directly affects how well you sleep."
        case .relationships: return "Social connection reduces stress hormones that keep you awake."
        }
    }
}

// MARK: - Habit (expanded from SleepHabit)

struct SleepHabit: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let isRecommended: Bool
    let usesHealthData: Bool
    var category: HabitCategory
    var usesScreenTime: Bool
    var sleepConnection: String  // how this habit ties back to sleep

    init(id: String, title: String, systemImage: String, isRecommended: Bool = false, usesHealthData: Bool = false,
         category: HabitCategory = .sleep, usesScreenTime: Bool = false, sleepConnection: String = "") {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.isRecommended = isRecommended
        self.usesHealthData = usesHealthData
        self.category = category
        self.usesScreenTime = usesScreenTime
        self.sleepConnection = sleepConnection
    }

    // MARK: Sleep habits

    static let sleepHabits: [SleepHabit] = [
        SleepHabit(id: "eight_hours", title: "Get 8 hours of sleep", systemImage: "moon.zzz.fill", usesHealthData: true, category: .sleep),
        SleepHabit(id: "in_bed_by_1030", title: "Get in bed by 10:30pm", systemImage: "bed.double.fill", category: .sleep),
        SleepHabit(id: "read_fiction", title: "Read fiction before bed", systemImage: "book.fill", category: .sleep, sleepConnection: "Reading calms your mind and signals it's time for sleep."),
        SleepHabit(id: "no_blue_light_8pm", title: "No blue light after 8pm", systemImage: "iphone", category: .sleep, usesScreenTime: true),
        SleepHabit(id: "phone_away_10pm", title: "Put phone away at 10pm", systemImage: "clock.badge.checkmark", category: .sleep, usesScreenTime: true),
        SleepHabit(id: "phone_out_of_bedroom", title: "Sleep with phone out of bedroom", systemImage: "iphone.slash", category: .sleep),
        SleepHabit(id: "calm_sleep", title: "Calm sleep routine", systemImage: "sparkles", category: .sleep, sleepConnection: "A consistent wind-down routine trains your brain to expect sleep."),
    ]

    // MARK: Exercise habits

    static let exerciseHabits: [SleepHabit] = [
        SleepHabit(id: "walk_30min", title: "Walk for 30 minutes", systemImage: "figure.walk", usesHealthData: true, category: .exercise, sleepConnection: "A daily walk regulates your circadian clock through light and movement."),
        SleepHabit(id: "morning_stretch", title: "Morning stretch routine", systemImage: "figure.flexibility", category: .exercise, sleepConnection: "Stretching releases tension that accumulates overnight."),
        SleepHabit(id: "sunlight_first_thing", title: "Get sunlight first thing", systemImage: "sun.max.fill", category: .exercise, sleepConnection: "Morning light resets your circadian rhythm for better sleep tonight."),
        SleepHabit(id: "bodyweight_workout", title: "Body weight workout", systemImage: "figure.strengthtraining.traditional", usesHealthData: true, category: .exercise, sleepConnection: "Strength training promotes deeper slow-wave sleep."),
        SleepHabit(id: "run_or_jog", title: "Run or jog", systemImage: "figure.run", usesHealthData: true, category: .exercise, sleepConnection: "Cardio exercise increases total sleep time and sleep quality."),
        SleepHabit(id: "yoga_session", title: "Yoga or pilates session", systemImage: "figure.yoga", usesHealthData: true, category: .exercise, sleepConnection: "Yoga reduces cortisol and calms the nervous system before bed."),
        SleepHabit(id: "no_exercise_3h_bed", title: "No intense exercise within 3 hours of bed", systemImage: "figure.cooldown", category: .exercise, sleepConnection: "Late exercise raises core temperature, delaying sleep onset."),
        SleepHabit(id: "stand_every_hour", title: "Stand every hour", systemImage: "figure.stand", usesHealthData: true, category: .exercise, sleepConnection: "Reducing sedentary time improves sleep quality."),
    ]

    // MARK: Focus & screentime habits

    static let focusHabits: [SleepHabit] = [
        SleepHabit(id: "no_social_media_before_10am", title: "No social media before 10am", systemImage: "eye.slash.fill", category: .focus, usesScreenTime: true, sleepConnection: "A phone-free morning lowers anxiety that disrupts tonight's sleep."),
        SleepHabit(id: "no_social_media_after_9pm", title: "No social media after 9pm", systemImage: "moon.haze.fill", category: .focus, usesScreenTime: true, sleepConnection: "Late scrolling stimulates your brain when it should be winding down."),
        SleepHabit(id: "screen_time_under_2h", title: "Recreational screen time under 2 hours", systemImage: "hourglass", category: .focus, usesScreenTime: true, sleepConnection: "Less recreational screen time means more time for sleep-friendly activities."),
        SleepHabit(id: "do_important_work_first", title: "Do most important work first", systemImage: "star.fill", category: .focus, sleepConnection: "Front-loading deep work reduces evening stress that keeps you awake."),
        SleepHabit(id: "digital_sabbath", title: "Digital sabbath (1 day/week)", systemImage: "power.circle.fill", category: .focus, usesScreenTime: true, sleepConnection: "A full day offline resets dopamine and improves sleep patterns."),
        SleepHabit(id: "no_work_after_dinner", title: "No work emails after dinner", systemImage: "envelope.badge.shield.half.filled.fill", category: .focus, sleepConnection: "Separating work from rest protects your evening wind-down."),
    ]

    // MARK: Diet habits

    static let dietHabits: [SleepHabit] = [
        SleepHabit(id: "no_caffeine_12pm", title: "No caffeine after 12pm", systemImage: "cup.and.saucer.fill", category: .diet, sleepConnection: "Caffeine has a 6-hour half-life and blocks sleep-promoting adenosine."),
        SleepHabit(id: "no_alcohol_4h", title: "No alcohol within 4 hours of bed", systemImage: "wineglass.fill", category: .diet, sleepConnection: "Alcohol fragments sleep and suppresses REM in the second half of the night."),
        SleepHabit(id: "no_liquids_9pm", title: "No liquids after 9pm", systemImage: "drop.triangle.fill", category: .diet, sleepConnection: "Reducing late fluids prevents disruptive bathroom trips."),
        SleepHabit(id: "last_meal_3h", title: "Finish last meal 3 hours before bed", systemImage: "fork.knife", category: .diet, sleepConnection: "Late digestion raises body temperature and disrupts sleep."),
        SleepHabit(id: "drink_water_morning", title: "Drink water first thing", systemImage: "drop.fill", category: .diet, sleepConnection: "Morning hydration kickstarts metabolism and daytime alertness."),
        SleepHabit(id: "no_sugary_drinks", title: "No sugary drinks", systemImage: "xmark.circle.fill", category: .diet, sleepConnection: "Sugar spikes and crashes affect energy levels and sleep quality."),
        SleepHabit(id: "eat_salad_lunch", title: "Eat a vegetable-rich lunch", systemImage: "leaf.fill", category: .diet, sleepConnection: "Nutrient-dense meals support stable energy and better rest."),
    ]

    // MARK: Relationship habits

    static let relationshipHabits: [SleepHabit] = [
        SleepHabit(id: "call_loved_one", title: "Call a loved one", systemImage: "phone.fill", category: .relationships, sleepConnection: "Social connection lowers cortisol, helping you sleep more peacefully."),
        SleepHabit(id: "compliment_someone", title: "Give someone a genuine compliment", systemImage: "heart.fill", category: .relationships, sleepConnection: "Acts of kindness boost oxytocin, which promotes calm and rest."),
        SleepHabit(id: "text_friend", title: "Text a friend you haven't talked to", systemImage: "message.fill", category: .relationships, sleepConnection: "Maintaining connections reduces the loneliness that impairs sleep."),
        SleepHabit(id: "gratitude_journal", title: "Write 3 things you're grateful for", systemImage: "pencil.and.list.clipboard", category: .relationships, sleepConnection: "Gratitude journaling before bed quiets anxious thoughts."),
        SleepHabit(id: "no_phone_during_meals", title: "No phone during meals with others", systemImage: "person.2.fill", category: .relationships, sleepConnection: "Present connection reduces stress and improves evening mood."),
    ]

    // MARK: - All habits & helpers

    static let recommended: [SleepHabit] = sleepHabits.filter(\.isRecommended)
    static let moreOptions: [SleepHabit] = sleepHabits.filter { !$0.isRecommended }

    static var all: [SleepHabit] {
        sleepHabits + exerciseHabits + focusHabits + dietHabits + relationshipHabits
    }

    static func habits(for category: HabitCategory) -> [SleepHabit] {
        all.filter { $0.category == category }
    }

    /// Returns habits recommended for the user based on their onboarding answers.
    static func recommended(for answers: OnboardingAnswers) -> [SleepHabit] {
        var ids: Set<String> = []
        let challenges = Set(answers.sleepChallenges)
        let duration = answers.sleepDurationBucket
        let trackRecord = answers.habitTrackRecord
        let exerciseFreq = answers.exerciseFrequency
        let screenConcerns = Set(answers.screentimeConcerns)
        let dietGoals = Set(answers.dietGoals)

        // --- Sleep-based recommendations ---
        if challenges.contains(SleepChallengeOption.troubleFallingAsleep.rawValue) {
            ids.formUnion(["no_caffeine_12pm", "no_blue_light_8pm", "read_fiction", "no_alcohol_4h", "calm_sleep"])
        }
        if challenges.contains(SleepChallengeOption.lateToBed.rawValue) || challenges.contains(SleepChallengeOption.wakeTooEarly.rawValue) {
            ids.formUnion(["in_bed_by_1030", "phone_away_10pm", "eight_hours", "no_social_media_after_9pm"])
        }
        if challenges.contains(SleepChallengeOption.wakeDuringNight.rawValue) {
            ids.formUnion(["no_liquids_9pm", "no_alcohol_4h", "last_meal_3h"])
        }
        if challenges.contains(SleepChallengeOption.enoughStillTired.rawValue) {
            ids.formUnion(["sunlight_first_thing", "no_caffeine_12pm", "eight_hours", "walk_30min"])
        }
        if duration == SleepDurationOption.lessThan5.rawValue || duration == SleepDurationOption.fiveToSix.rawValue {
            ids.formUnion(["in_bed_by_1030", "no_liquids_9pm", "phone_out_of_bedroom"])
        }

        // --- Exercise-based recommendations ---
        if exerciseFreq == ExerciseFrequencyOption.rarely.rawValue {
            ids.formUnion(["walk_30min", "morning_stretch", "sunlight_first_thing"])
        } else if exerciseFreq == ExerciseFrequencyOption.oneToTwo.rawValue {
            ids.formUnion(["walk_30min", "yoga_session", "stand_every_hour"])
        } else if exerciseFreq == ExerciseFrequencyOption.fivePlus.rawValue {
            ids.insert("no_exercise_3h_bed")
        }

        // --- Screentime-based recommendations ---
        if screenConcerns.contains(ScreentimeConcernOption.socialMediaAtNight.rawValue) {
            ids.formUnion(["no_social_media_after_9pm", "no_blue_light_8pm", "phone_away_10pm"])
        }
        if screenConcerns.contains(ScreentimeConcernOption.morningPhoneCheck.rawValue) {
            ids.formUnion(["no_social_media_before_10am", "sunlight_first_thing"])
        }
        if screenConcerns.contains(ScreentimeConcernOption.tooMuchOverall.rawValue) {
            ids.formUnion(["screen_time_under_2h", "digital_sabbath"])
        }
        if screenConcerns.contains(ScreentimeConcernOption.workLifeBlur.rawValue) {
            ids.formUnion(["no_work_after_dinner", "do_important_work_first"])
        }

        // --- Diet-based recommendations ---
        if dietGoals.contains(DietGoalOption.cutLateSnacks.rawValue) {
            ids.formUnion(["last_meal_3h", "no_liquids_9pm"])
        }
        if dietGoals.contains(DietGoalOption.drinkMoreWater.rawValue) {
            ids.insert("drink_water_morning")
        }
        if dietGoals.contains(DietGoalOption.eatHealthier.rawValue) {
            ids.formUnion(["eat_salad_lunch", "no_sugary_drinks"])
        }

        // --- Struggled with habits → simpler ones ---
        if trackRecord == HabitTrackRecordOption.struggled.rawValue {
            ids.formUnion(["no_liquids_9pm", "walk_30min", "gratitude_journal"])
        }

        // Always include relationship habits if nothing else gives them some
        if ids.intersection(Set(relationshipHabits.map(\.id))).isEmpty {
            ids.insert("gratitude_journal")
        }

        // Default: always include a few sensible starters if nothing matched
        if ids.isEmpty {
            ids.formUnion(["no_liquids_9pm", "no_caffeine_12pm", "walk_30min", "gratitude_journal"])
        }

        return all.filter { ids.contains($0.id) }
    }

    /// Habits not in the recommended list, for "More options".
    static func remainingHabits(excluding recommendedIds: Set<String>) -> [SleepHabit] {
        all.filter { !recommendedIds.contains($0.id) }
    }
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
    case exerciseFrequency
    case screentimeConcerns
    case dietGoals
    case pickHabit
    case finish

    var progress: Double {
        Double(rawValue) / Double(Self.allCases.count)
    }

    var canGoBack: Bool { rawValue > 0 }
    var isLast: Bool { self == .finish }
}
