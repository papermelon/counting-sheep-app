//
//  OnboardingStepViews.swift
//  Sheep Atsume
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
        HStack(spacing: 4) {
            Text("Sheep Atsume helps you build better sleep habits ")
                .foregroundStyle(.white)
            Text("so you wake up rested.")
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
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
            Text("Sleep")
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
                Text("Sleep")
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
                Text("Sleep")
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

// MARK: - Pick one habit step (recommended + more options, + to add)

struct OnboardingPickHabitStep: View {
    @Binding var answers: OnboardingAnswers

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Sleep")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))

                Text("Pick one habit to start.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                Text("Start small and easy. Consistency matters more than intensity.")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.7))

                // Recommended
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text("Recommended for you")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }

                ForEach(SleepHabit.recommended) { habit in
                    OnboardingHabitRow(
                        habit: habit,
                        isSelected: answers.selectedHabitIds.contains(habit.id),
                        onAdd: { toggleHabit(habit.id) }
                    )
                }

                // More options
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Text("More options")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                }
                .padding(.top, 8)

                ForEach(SleepHabit.moreOptions) { habit in
                    OnboardingHabitRow(
                        habit: habit,
                        isSelected: answers.selectedHabitIds.contains(habit.id),
                        onAdd: { toggleHabit(habit.id) }
                    )
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

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: habit.systemImage)
                .font(.system(size: 22))
                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
                .frame(width: 32, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.title)
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                if habit.usesHealthData {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundStyle(.red.opacity(0.8))
                        Text("Health Data")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                }
            }

            Spacer()

            Button(action: onAdd) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? Color(red: 0.7, green: 0.5, blue: 1.0) : .white.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.12))
        )
    }
}
