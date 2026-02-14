//
//  SettingsScreen.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

private let appAccent = Color(red: 0.6, green: 0.5, blue: 0.9)
private let settingsCardBackground = Color.white.opacity(0.08)
private let settingsLabelColor = Color.white.opacity(0.9)

struct SettingsScreen: View {
    @EnvironmentObject var gameState: GameState
    let onClose: () -> Void
    var onOpenHabitCustomization: ((String) -> Void)?
    var onOpenCheckIn: (() -> Void)?

    var body: some View {
        ZStack {
            Color(white: 0.08).ignoresSafeArea()

            VStack(spacing: 0) {
                screenHeader(title: "Settings")

                ScrollView {
                    VStack(spacing: 16) {
                        habitsSection
                        checkInSection
                        modeSection
                        sleepTrackingSection
                        bedtimeSection
                        notificationsSection
                        roadmapSection
                    }
                    .padding(16)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your habits")
                .font(.headline)
                .foregroundStyle(settingsLabelColor)

            if gameState.habitSheep.isEmpty {
                Text("No habits yet. Complete onboarding to add habits.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(gameState.habitSheep) { sheep in
                    Button {
                        onOpenHabitCustomization?(sheep.habitId)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: sheep.systemImage)
                                .font(.title3)
                                .foregroundStyle(appAccent)
                                .frame(width: 36, alignment: .center)
                            Text(sheep.displayTitle)
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settingsCardBackground)
        )
    }

    private var checkInSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily check-in")
                .font(.headline)
                .foregroundStyle(settingsLabelColor)
            Button {
                onOpenCheckIn?()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.title3)
                        .foregroundStyle(appAccent)
                    Text("Mark how your habits went")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settingsCardBackground)
        )
    }

    private func screenHeader(title: String) -> some View {
        HStack {
            Button(action: onClose) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                    Text("Close")
                        .font(.subheadline)
                }
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Color.clear.frame(width: 60, height: 32)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(white: 0.06))
    }

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tracking")
                .font(.headline)
                .foregroundStyle(settingsLabelColor)
            Text("Each habit can be self-reported (you mark it done) or auto-tracked with Screen Time. Open a habit and turn on \"Use Screen Time\" for screen habits like \"Put phone away at 10pm\" to check it from device usage during your bedtime window.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settingsCardBackground)
        )
    }

    // MARK: - Sleep tracking

    private var sleepTrackingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep tracking")
                .font(.headline)
                .foregroundStyle(settingsLabelColor)

            Toggle("Connect Apple Health", isOn: Binding(
                get: { gameState.healthKitAuthorized },
                set: { newValue in
                    if newValue {
                        Task {
                            let granted = await SleepHealthService.shared.requestAuthorization()
                            gameState.healthKitAuthorized = granted
                            if granted {
                                gameState.refreshSleepData()
                            }
                            gameState.syncSettingsToStorage()
                        }
                    } else {
                        gameState.healthKitAuthorized = false
                        gameState.sleepRecords = []
                        gameState.syncSettingsToStorage()
                    }
                }
            ))
            .tint(appAccent)

            if gameState.healthKitAuthorized {
                HStack {
                    Text("Sleep goal")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Spacer()
                    Stepper(
                        value: $gameState.sleepGoalHours,
                        in: 5.0...12.0,
                        step: 0.5
                    ) {
                        Text(String(format: "%.1f hrs", gameState.sleepGoalHours))
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.white)
                    }
                    .onChange(of: gameState.sleepGoalHours) { _, _ in
                        gameState.syncSettingsToStorage()
                    }
                }
            }

            Text("Sleep data from Apple Watch or iPhone is used to show your sleep trends.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settingsCardBackground)
        )
    }

    private var roadmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coming soon")
                .font(.headline)
                .foregroundStyle(settingsLabelColor)
            VStack(alignment: .leading, spacing: 6) {
                Text("• Screen Time integration for Verified mode")
                Text("• Live Activity: \"Sheep are grazing...\"")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settingsCardBackground)
        )
    }

    private var bedtimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bedtime window")
                .font(.headline)
                .foregroundStyle(settingsLabelColor)

            DatePicker("Start", selection: $gameState.bedtimeStart, displayedComponents: .hourAndMinute)
                .tint(appAccent)
                .foregroundStyle(.white)
                .onChange(of: gameState.bedtimeStart) { _, _ in
                    NotificationScheduler.scheduleBedtimeAndMorning(
                        bedtimeStart: gameState.bedtimeStart,
                        bedtimeEnd: gameState.bedtimeEnd,
                        enabled: gameState.notificationsEnabled
                    )
                    gameState.syncSettingsToStorage()
                }
            DatePicker("End", selection: $gameState.bedtimeEnd, displayedComponents: .hourAndMinute)
                .tint(appAccent)
                .foregroundStyle(.white)
                .environment(\.locale, Locale(identifier: "en_US_POSIX"))
                .onChange(of: gameState.bedtimeEnd) { _, _ in
                    NotificationScheduler.scheduleBedtimeAndMorning(
                        bedtimeStart: gameState.bedtimeStart,
                        bedtimeEnd: gameState.bedtimeEnd,
                        enabled: gameState.notificationsEnabled
                    )
                    gameState.syncSettingsToStorage()
                }

            Text("Used for nightly tracking and notifications.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settingsCardBackground)
        )
    }

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .font(.headline)
                .foregroundStyle(settingsLabelColor)

            Toggle("Remind me to check in", isOn: $gameState.notificationsEnabled)
                .tint(appAccent)
                .onChange(of: gameState.notificationsEnabled) { _, _ in
                    NotificationScheduler.requestAuthorization { granted in
                        if granted {
                            NotificationScheduler.scheduleBedtimeAndMorning(
                                bedtimeStart: gameState.bedtimeStart,
                                bedtimeEnd: gameState.bedtimeEnd,
                                enabled: gameState.notificationsEnabled
                            )
                        } else {
                            gameState.notificationsEnabled = false
                        }
                        gameState.syncSettingsToStorage()
                    }
                }

            Text("Evening reminders for bedtime, morning reminders for check-in.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settingsCardBackground)
        )
    }
}

#Preview {
    SettingsScreen(onClose: { }, onOpenHabitCustomization: nil)
        .environmentObject(GameState())
}
