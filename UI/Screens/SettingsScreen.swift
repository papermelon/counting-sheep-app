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
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 1.0, green: 0.9, blue: 0.75)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                screenHeader(title: "Settings", icon: "⚙️")
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
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
            Text("Mode")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
            
            Picker("Mode", selection: $gameState.mode) {
                ForEach(GameMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Cozy: manual check-ins; sheep always return safely with common rewards.")
                Text("Verified: uses Screen Time at night to auto-grade stars; better growth and rare items.")
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
            DatePicker("End", selection: $gameState.bedtimeEnd, displayedComponents: .hourAndMinute)
                .environment(\.locale, Locale(identifier: "en_US_POSIX"))
            
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
    SettingsScreen(onClose: { })
        .environmentObject(GameState())
}

