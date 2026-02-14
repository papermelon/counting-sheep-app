//
//  SettingsScreen.swift
//  Counting Sheep
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
                        // Manual Check-in Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Manual Check-in")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
                            
                            VStack(spacing: 10) {
                                checkInButton(label: "Great 🌟", level: .great, color: Color(red: 0.95, green: 0.85, blue: 0.4))
                                checkInButton(label: "Okay 🙂", level: .okay, color: Color(red: 0.7, green: 0.85, blue: 0.95))
                                checkInButton(label: "Slipped 😬", level: .slipped, color: Color(red: 1.0, green: 0.8, blue: 0.7))
                                checkInButton(label: "Bad 😴", level: .bad, color: Color(red: 0.85, green: 0.85, blue: 0.85))
                            }
                            
                            Text("Manual check-in for MVP. Verification will be added later.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.7))
                        )
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
    
    @ViewBuilder
    private func checkInButton(label: String, level: NightSuccessLevel, color: Color) -> some View {
        Button {
            gameState.logNight(level: level)
        } label: {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(red: 0.3, green: 0.2, blue: 0.1))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.6, green: 0.5, blue: 0.4), lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsScreen(onClose: { })
        .environmentObject(GameState())
}

