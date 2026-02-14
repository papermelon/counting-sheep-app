//
//  HabitCustomizationScreen.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct HabitCustomizationScreen: View {
    @EnvironmentObject var gameState: GameState
    let habitId: String
    let onSave: () -> Void
    let onClose: () -> Void

    @State private var customTitle: String = ""
    @State private var schedule: HabitSchedule = .everyDay
    @State private var remindersEnabled: Bool = true
    @State private var smartRemindersEnabled: Bool = false
    @State private var targetTime: Date = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var goalMinutes: Int = 480 // 8 hours
    @State private var useVerifiedTracking: Bool = false

    private var sheep: HabitSheep? {
        gameState.habitSheep.first { $0.habitId == habitId }
    }

    private var supportsTimePicker: Bool {
        guard let s = sheep else { return false }
        return ["phone_away_10pm", "no_blue_light_8pm", "in_bed_by_1030", "no_caffeine_12pm"].contains(s.habitId)
    }

    private var supportsGoalMinutes: Bool {
        sheep?.habitId == "eight_hours"
    }

    /// Screen habits can be auto-checked via Screen Time during the bedtime window.
    private var supportsScreenTimeTracking: Bool {
        guard let s = sheep else { return false }
        return GameState.screenHabitIds.contains(s.habitId)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let s = sheep {
                VStack(spacing: 0) {
                    header(s)
                    ScrollView {
                        VStack(spacing: 24) {
                            iconCircle(s)
                            nameField
                            optionsCard(s)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    }
                    Spacer(minLength: 16)
                    saveButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
                .foregroundStyle(.white)
            } else {
                Text("Habit not found")
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            if let s = sheep {
                customTitle = s.customTitle ?? s.title
                schedule = s.schedule
                remindersEnabled = s.remindersEnabled
                smartRemindersEnabled = s.smartRemindersEnabled
                targetTime = s.targetTime ?? Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
                goalMinutes = s.goalMinutes ?? 480
                useVerifiedTracking = s.useVerifiedTracking
            }
        }
    }

    private func header(_ s: HabitSheep) -> some View {
        HStack(spacing: 12) {
            Button(action: onClose) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            Image(systemName: s.systemImage)
                .font(.system(size: 20))
                .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
            Text(s.displayTitle)
                .font(.system(size: 20, weight: .semibold))
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private func iconCircle(_ s: HabitSheep) -> some View {
        Image(systemName: s.systemImage)
            .font(.system(size: 56))
            .foregroundStyle(Color(red: 0.7, green: 0.5, blue: 1.0))
            .frame(width: 120, height: 120)
            .background(Circle().fill(Color.white.opacity(0.12)))
    }

    private var nameField: some View {
        HStack {
            TextField("Habit name", text: $customTitle)
                .font(.system(size: 17))
                .foregroundStyle(.white)
            Image(systemName: "pencil")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.12)))
    }

    private func optionsCard(_ s: HabitSheep) -> some View {
        VStack(spacing: 0) {
            scheduleRow
            remindersRow
            if supportsScreenTimeTracking {
                screenTimeRow
            }
            if supportsTimePicker {
                timeRow
            }
            if supportsGoalMinutes {
                goalRow
            }
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.12)))
    }

    private var screenTimeRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Use Screen Time")
                    .font(.system(size: 17))
                Text("Auto-check this habit from device usage during bedtime")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Toggle("", isOn: $useVerifiedTracking)
                .labelsHidden()
                .tint(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var scheduleRow: some View {
        HStack {
            Text("Schedule")
                .font(.system(size: 17))
            Spacer()
            Menu {
                Button("Every day") { schedule = .everyDay }
                Button("Weekdays") { schedule = .weekdays }
            } label: {
                HStack(spacing: 4) {
                    Text(schedule.displayName)
                        .foregroundStyle(.gray)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var remindersRow: some View {
        HStack {
            Text("Remind Me")
                .font(.system(size: 17))
            Spacer()
            Toggle("", isOn: $remindersEnabled)
                .labelsHidden()
                .tint(.green)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var timeRow: some View {
        HStack {
            Text("Time")
                .font(.system(size: 17))
            Spacer()
            DatePicker("", selection: $targetTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var goalRow: some View {
        HStack {
            Text("Goal")
                .font(.system(size: 17))
            Spacer()
            Text("\(goalMinutes / 60) hours")
                .foregroundStyle(.gray)
            Stepper("", value: $goalMinutes, in: 360...600, step: 60)
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var saveButton: some View {
        Button(action: saveAndClose) {
            Text("Save")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
        }
        .buttonStyle(.plain)
    }

    private func saveAndClose() {
        guard var s = sheep else { return }
        s.customTitle = customTitle.trimmingCharacters(in: .whitespaces).isEmpty ? nil : customTitle
        s.schedule = schedule
        s.remindersEnabled = remindersEnabled
        s.smartRemindersEnabled = smartRemindersEnabled
        s.targetTime = supportsTimePicker ? targetTime : nil
        s.goalMinutes = supportsGoalMinutes ? goalMinutes : nil
        s.useVerifiedTracking = useVerifiedTracking
        gameState.updateHabitSheep(s)
        onSave()
        onClose()
    }
}

#Preview {
    HabitCustomizationScreen(habitId: "phone_away_10pm", onSave: {}, onClose: {})
        .environmentObject(GameState(habitSheep: [
            HabitSheep(habitId: "phone_away_10pm", title: "Put phone away at 10pm", systemImage: "clock.badge.checkmark")
        ]))
}
