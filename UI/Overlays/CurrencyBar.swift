//
//  CurrencyBar.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct CurrencyBar: View {
    @EnvironmentObject var gameState: GameState
    
    private var thrivingCount: Int {
        gameState.habitSheep.filter { $0.growthStage == .thriving }.count
    }

    private var habitCount: Int {
        gameState.habitSheep.count
    }

    var body: some View {
        HStack(spacing: 16) {
            currencyItem(icon: "🔥", label: "Check-in streak", value: gameState.checkInStreak)
            if habitCount > 0 {
                currencyItem(icon: "🐑", label: "Thriving", value: thrivingCount, suffix: "/\(habitCount)")
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(red: 1.0, green: 0.98, blue: 0.94).opacity(0.95))
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        )
        .overlay(
            Capsule()
                .stroke(Color(red: 0.85, green: 0.75, blue: 0.6), lineWidth: 2)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    private func currencyItem(icon: String, label: String, value: Int, suffix: String = "") -> some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(value)\(suffix)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
            }
        }
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.3)
        VStack {
            Spacer()
            CurrencyBar()
        }
    }
    .environmentObject(GameState(habitSheep: [
        HabitSheep(habitId: "a", title: "Habit A", systemImage: "moon.fill", growthStage: .thriving),
        HabitSheep(habitId: "b", title: "Habit B", systemImage: "sun.fill", growthStage: .growing)
    ], checkInStreak: 5))
}

