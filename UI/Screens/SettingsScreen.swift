//
//  SettingsScreen.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var gameState: GameState
    let onClose: () -> Void
    var onOpenHabitCustomization: ((String) -> Void)?
    var onOpenCheckIn: (() -> Void)?

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.9, blue: 0.75)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                screenHeader(title: "Settings", icon: "⚙️")

                ScrollView {
                    VStack(spacing: 20) {
                        habitsSection
                        checkInSection
                        modeSection
                        bedtimeSection
                        notificationsSection
                        roadmapSection
                    }
                    .padding()
                }
            }
        }
    }

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your habits")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))

            if gameState.habitSheep.isEmpty {
                Text("No habits yet. Complete onboarding to add habits.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                ForEach(gameState.habitSheep) { sheep in
                    Button {
                        onOpenHabitCustomization?(sheep.habitId)
                    } label: {
                        HStack {
                            Image(systemName: sheep.systemImage)
                                .font(.title3)
                                .foregroundStyle(Color(red: 0.5, green: 0.35, blue: 0.6))
                                .frame(width: 36, alignment: .center)
                            Text(sheep.displayTitle)
                                .font(.subheadline)
                                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
        )
    }

    private var checkInSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily check-in")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
            Button {
                onOpenCheckIn?()
            } label: {
                HStack {
                    Label("Mark how your habits went", systemImage: "checkmark.circle")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
        )
    }
    
    @ViewBuilder
    private func screenHeader(title: String, icon: String) -> some View {
        HStack {
            // Close button
            Button(action: onClose) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.95, green: 0.85, blue: 0.6))
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.7, green: 0.55, blue: 0.35), lineWidth: 2)
                        )
                    
                    VStack(spacing: 2) {
                        Text("✕")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color(red: 0.5, green: 0.35, blue: 0.2))
                        Text("Close")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(Color(red: 0.5, green: 0.35, blue: 0.2))
                    }
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Title
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
                Text(icon)
                    .font(.system(size: 28))
            }
            
            Spacer()
            
            // Spacer for balance
            Color.clear.frame(width: 50, height: 50)
        }
        .padding()
        .background(Color.white.opacity(0.5))
    }
    
    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tracking")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))

            VStack(alignment: .leading, spacing: 6) {
                Text("Each habit can be self-reported (you mark it done) or auto-tracked with Screen Time. Open a habit and turn on \"Use Screen Time\" for screen habits like \"Put phone away at 10pm\" to check it from device usage during your bedtime window.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
        )
    }
    
    private var roadmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coming soon")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("• Screen Time integration for Verified mode")
                Text("• Live Activity: \"Sheep are grazing...\"")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
        )
    }
    
    private var bedtimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bedtime window")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
            
            DatePicker("Start", selection: $gameState.bedtimeStart, displayedComponents: .hourAndMinute)
                .onChange(of: gameState.bedtimeStart) { _, _ in
                    NotificationScheduler.scheduleBedtimeAndMorning(
                        bedtimeStart: gameState.bedtimeStart,
                        bedtimeEnd: gameState.bedtimeEnd,
                        enabled: gameState.notificationsEnabled
                    )
                    gameState.syncSettingsToStorage()
                }
            DatePicker("End", selection: $gameState.bedtimeEnd, displayedComponents: .hourAndMinute)
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
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
        )
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
            
            Toggle("Remind me to check in", isOn: $gameState.notificationsEnabled)
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
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
        )
    }
}

#Preview {
    SettingsScreen(onClose: { }, onOpenHabitCustomization: nil)
        .environmentObject(GameState())
}
