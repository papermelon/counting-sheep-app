//
//  SheepBookScreen.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct SheepBookScreen: View {
    @EnvironmentObject var gameState: GameState
    let onClose: () -> Void
    var onSelectHabit: ((String) -> Void)?

    var body: some View {
        ZStack {
            // Background
            Color(red: 1.0, green: 0.85, blue: 0.9)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                screenHeader(title: "Sheep Book", icon: "🐑")

                ScrollView {
                    VStack(spacing: 12) {
                        if gameState.habitSheep.isEmpty {
                            Text("Your sheep will appear here after onboarding.")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 40)
                        } else {
                            ForEach(gameState.habitSheep) { sheep in
                                habitSheepRow(sheep)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private func habitSheepRow(_ sheep: HabitSheep) -> some View {
        Button {
            onSelectHabit?(sheep.habitId)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: sheep.systemImage)
                    .font(.system(size: 24))
                    .foregroundStyle(Color(red: 0.5, green: 0.35, blue: 0.6))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.7)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(sheep.displayTitle)
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
                    Text(sheep.growthStage.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.8))
            )
        }
        .buttonStyle(.plain)
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
}

#Preview {
    SheepBookScreen(onClose: { }, onSelectHabit: nil)
        .environmentObject(GameState(habitSheep: [
            HabitSheep(habitId: "phone_away_10pm", title: "Put phone away at 10pm", systemImage: "clock.badge.checkmark", growthStage: .growing)
        ]))
}

