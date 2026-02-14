//
//  OnboardingStepViews.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

// MARK: - Name step

struct OnboardingNameStep: View {
    @Binding var answers: OnboardingAnswers
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What's your name?")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            TextField("Your name", text: $answers.userName)
                .textFieldStyle(.plain)
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .focused($isFocused)
                .padding(.vertical, 12)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(height: 1)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .onAppear { isFocused = true }
    }
}

// MARK: - Habit track record step (single choice)

struct OnboardingHabitTrackRecordStep: View {
    @Binding var answers: OnboardingAnswers

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Which best describes your track record building habits?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 12) {
                    ForEach(Array(HabitTrackRecordOption.allCases.enumerated()), id: \.element.rawValue) { _, option in
                        OnboardingSingleChoiceRow(
                            title: option.rawValue,
                            isSelected: answers.habitTrackRecord == option.rawValue
                        ) {
                            answers.habitTrackRecord = option.rawValue
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Motivational step (info only)

struct OnboardingMotivationalStep: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("You're not alone.")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Many people struggle with habits because motivation fades.")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}

// MARK: - App value step (info with gradient highlight)

struct OnboardingAppValueStep: View {
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Counting Sheep helps you build better sleep habits")
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            VStack(alignment: .center, spacing: 4) {
                Text("so you can wake")
                Text("up rested.")
            }
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.7, green: 0.5, blue: 1.0),
                        Color(red: 0.85, green: 0.65, blue: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .font(.system(size: 24, weight: .bold))
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}

// MARK: - Bedtime step (time picker)

struct OnboardingBedtimeStep: View {
    @Binding var answers: OnboardingAnswers

    private var defaultBedtime: Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 23
        comps.minute = 0
        return cal.date(from: comps) ?? Date()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("About your sleep")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))

            Text("What time do you typically get in bed?")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            DatePicker("", selection: Binding(
                get: { answers.typicalBedtime ?? defaultBedtime },
                set: { answers.typicalBedtime = $0 }
            ), displayedComponents: [.hourAndMinute])
            .datePickerStyle(.wheel)
            .labelsHidden()
            .colorScheme(.dark)
            .colorMultiply(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .onAppear {
            if answers.typicalBedtime == nil {
                answers.typicalBedtime = defaultBedtime
            }
        }
    }
}

// MARK: - Sleep duration step (single choice)

struct OnboardingSleepDurationStep: View {
    @Binding var answers: OnboardingAnswers

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("About your sleep")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))

                Text("How many hours of quality sleep do you get on a typical night?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 12) {
                    ForEach(SleepDurationOption.allCases, id: \.rawValue) { option in
                        OnboardingSingleChoiceRow(
                            title: option.rawValue,
                            isSelected: answers.sleepDurationBucket == option.rawValue
                        ) {
                            answers.sleepDurationBucket = option.rawValue
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Sleep challenges step (multi-select)

struct OnboardingSleepChallengesStep: View {
    @Binding var answers: OnboardingAnswers

    func toggle(_ rawValue: String) {
        if answers.sleepChallenges.contains(rawValue) {
            answers.sleepChallenges.removeAll { $0 == rawValue }
        } else {
            answers.sleepChallenges.append(rawValue)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("About your sleep")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))

                Text("What sleep challenges do you face?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 12) {
                    ForEach(SleepChallengeOption.allCases, id: \.rawValue) { option in
                        OnboardingMultiChoiceRow(
                            title: option.rawValue,
                            isSelected: answers.sleepChallenges.contains(option.rawValue)
                        ) {
                            toggle(option.rawValue)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Exercise frequency step (single choice)

struct OnboardingExerciseStep: View {
    @Binding var answers: OnboardingAnswers

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Your activity level")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(HabitCategory.exercise.color)

                Text("How often do you exercise?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Regular movement is one of the best things you can do for deep, restorative sleep.")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 12) {
                    ForEach(ExerciseFrequencyOption.allCases, id: \.rawValue) { option in
                        OnboardingSingleChoiceRow(
                            title: option.rawValue,
                            isSelected: answers.exerciseFrequency == option.rawValue
                        ) {
                            answers.exerciseFrequency = option.rawValue
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Screen time concerns step (multi-select)

struct OnboardingScreentimeStep: View {
    @Binding var answers: OnboardingAnswers

    func toggle(_ rawValue: String) {
        if rawValue == ScreentimeConcernOption.noConcern.rawValue {
            // "Not a concern" clears others
            answers.screentimeConcerns = [rawValue]
            return
        }
        answers.screentimeConcerns.removeAll { $0 == ScreentimeConcernOption.noConcern.rawValue }
        if answers.screentimeConcerns.contains(rawValue) {
            answers.screentimeConcerns.removeAll { $0 == rawValue }
        } else {
            answers.screentimeConcerns.append(rawValue)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Focus & screentime")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(HabitCategory.focus.color)

                Text("Does screen time ever get in the way of your rest?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Blue light and late-night scrolling are top sleep disruptors.")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 12) {
                    ForEach(ScreentimeConcernOption.allCases, id: \.rawValue) { option in
                        OnboardingMultiChoiceRow(
                            title: option.rawValue,
                            isSelected: answers.screentimeConcerns.contains(option.rawValue)
                        ) {
                            toggle(option.rawValue)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Diet goals step (multi-select)

struct OnboardingDietStep: View {
    @Binding var answers: OnboardingAnswers

    func toggle(_ rawValue: String) {
        if rawValue == DietGoalOption.noConcern.rawValue {
            answers.dietGoals = [rawValue]
            return
        }
        answers.dietGoals.removeAll { $0 == DietGoalOption.noConcern.rawValue }
        if answers.dietGoals.contains(rawValue) {
            answers.dietGoals.removeAll { $0 == rawValue }
        } else {
            answers.dietGoals.append(rawValue)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Diet & nutrition")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(HabitCategory.diet.color)

                Text("Any nutrition goals on your mind?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text("What you eat and drink — especially in the evening — directly shapes how well you sleep.")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 12) {
                    ForEach(DietGoalOption.allCases, id: \.rawValue) { option in
                        OnboardingMultiChoiceRow(
                            title: option.rawValue,
                            isSelected: answers.dietGoals.contains(option.rawValue)
                        ) {
                            toggle(option.rawValue)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Pick one habit step (recommended + more options, + to add)

struct OnboardingPickHabitStep: View {
    @Binding var answers: OnboardingAnswers

    private var recommendedHabits: [SleepHabit] {
        SleepHabit.recommended(for: answers)
    }

    private var moreHabits: [SleepHabit] {
        let recommendedIds = Set(recommendedHabits.map(\.id))
        return SleepHabit.remainingHabits(excluding: recommendedIds)
    }

    /// Group "More options" by category for browsing
    private var moreByCategory: [(HabitCategory, [SleepHabit])] {
        let grouped = Dictionary(grouping: moreHabits, by: \.category)
        return HabitCategory.allCases.compactMap { cat in
            guard let habits = grouped[cat], !habits.isEmpty else { return nil }
            return (cat, habits)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Build your routine")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))

                Text("Pick habits to start with.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                Text("Start small. Every habit here is chosen to help you sleep better.")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))

                // Recommended (personalized from onboarding answers)
                if !recommendedHabits.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("Recommended for you")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.orange)
                    }
                    .padding(.top, 4)

                    ForEach(recommendedHabits) { habit in
                        OnboardingHabitRow(
                            habit: habit,
                            isSelected: answers.selectedHabitIds.contains(habit.id),
                            onAdd: { toggleHabit(habit.id) }
                        )
                    }
                }

                // More options grouped by category
                ForEach(moreByCategory, id: \.0) { category, habits in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 8, height: 8)
                        Text(category.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 8)

                    ForEach(habits) { habit in
                        OnboardingHabitRow(
                            habit: habit,
                            isSelected: answers.selectedHabitIds.contains(habit.id),
                            onAdd: { toggleHabit(habit.id) }
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }

    private func toggleHabit(_ id: String) {
        if answers.selectedHabitIds.contains(id) {
            answers.selectedHabitIds.removeAll { $0 == id }
        } else {
            answers.selectedHabitIds.append(id)
        }
    }
}

// MARK: - Finish step

struct OnboardingFinishStep: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text("You're all set.")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)

            Text("Your flock is ready. Check in each morning to grow your streak.")
                .font(.system(size: 18))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}

// MARK: - Shared row: single choice (radio)

struct OnboardingSingleChoiceRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shared row: multi choice (checkbox)

struct OnboardingMultiChoiceRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Habit row (icon, title, + button)

struct OnboardingHabitRow: View {
    let habit: SleepHabit
    let isSelected: Bool
    let onAdd: () -> Void

    private var iconColor: Color { habit.category.color }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: habit.systemImage)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.title)
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                // Subtitle badges
                HStack(spacing: 8) {
                    if habit.usesHealthData {
                        HStack(spacing: 3) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.red.opacity(0.8))
                            Text("Health Data")
                                .font(.system(size: 11))
                                .foregroundStyle(.gray)
                        }
                    }
                    if habit.usesScreenTime {
                        HStack(spacing: 3) {
                            Image(systemName: "hourglass")
                                .font(.system(size: 9))
                                .foregroundStyle(HabitCategory.focus.color.opacity(0.8))
                            Text("Screen Time Block")
                                .font(.system(size: 11))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }

            Spacer()

            Button(action: onAdd) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? iconColor : .white.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.12))
        )
    }
}
