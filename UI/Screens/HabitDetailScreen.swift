//
//  HabitDetailScreen.swift
//  Sheep Atsume
//

import SwiftUI

struct HabitDetailScreen: View {
    @EnvironmentObject var gameState: GameState
    let habitId: String
    let onClose: () -> Void
    @State private var showCustomization = false

    private var sheep: HabitSheep? {
        gameState.habitSheep.first { $0.habitId == habitId }
    }

    private let cal = Calendar.current

    var body: some View {
        ZStack {
            Color(white: 0.08).ignoresSafeArea()
            if let s = sheep {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header(s)
                        strengthCard(s)
                        streakCard(s)
                        weeklyDots(s)
                        last30Card(s)
                        completedTodayButton(s)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showCustomization = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(.white)
                        }
                    }
                }
                .sheet(isPresented: $showCustomization) {
                    HabitCustomizationScreen(habitId: habitId, onSave: { gameState.syncSettingsToStorage() }, onClose: { showCustomization = false })
                        .environmentObject(gameState)
                }
            } else {
                Text("Habit not found")
                    .foregroundStyle(.white)
            }
        }
        .toolbarBackground(Color(white: 0.08), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func header(_ s: HabitSheep) -> some View {
        HStack(spacing: 16) {
            Image(systemName: s.systemImage)
                .font(.largeTitle)
                .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.white.opacity(0.12)))
            VStack(alignment: .leading, spacing: 2) {
                Text(s.displayTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func strengthCard(_ s: HabitSheep) -> some View {
        let (label, value) = strengthLabelAndValue(s)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Habit strength")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.headline)
                .foregroundStyle(.white)
            ProgressView(value: value, total: 1.0)
                .tint(Color(red: 0.6, green: 0.5, blue: 0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func strengthLabelAndValue(_ s: HabitSheep) -> (String, Double) {
        switch s.growthStage {
        case .needsCare: return ("Needs care", 0.2)
        case .growing: return ("Growing", 0.5)
        case .thriving: return ("Thriving", 1.0)
        }
    }

    private func streakCard(_ s: HabitSheep) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current streak")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(s.consecutiveDaysDone) \(s.consecutiveDaysDone == 1 ? "day" : "days")")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func weeklyDots(_ s: HabitSheep) -> some View {
        let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: weekStart) }
        let symbols = cal.shortWeekdaySymbols
        return VStack(alignment: .leading, spacing: 12) {
            Text("This week")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                    VStack(spacing: 4) {
                        Text(symbols[cal.component(.weekday, from: day) - 1])
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Circle()
                            .fill(s.completed(on: day) ? Color.green : Color.white.opacity(0.2))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: s.completed(on: day) ? "checkmark" : "")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func last30Card(_ s: HabitSheep) -> some View {
        let pct = last30Percent(s)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Last 30 days")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let pct = pct {
                Text("\(Int(round(pct)))% of days completed")
                    .font(.headline)
                    .foregroundStyle(.white)
            } else {
                Text("—% (keep going)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func last30Percent(_ s: HabitSheep) -> Double? {
        guard let end = cal.date(byAdding: .day, value: -29, to: Date()) else { return nil }
        let start = cal.startOfDay(for: end)
        let today = cal.startOfDay(for: Date())
        let totalDays = max(1, cal.dateComponents([.day], from: start, to: today).day ?? 30)
        let completed = s.completionDateSet.filter { $0 >= start && $0 <= today }.count
        return Double(completed) / Double(totalDays) * 100
    }

    private func completedTodayButton(_ s: HabitSheep) -> some View {
        let doneToday = s.completed(on: Date())
        return Button {
            if !doneToday {
                gameState.markHabitCompletedToday(habitId: habitId)
            }
        } label: {
            Text(doneToday ? "Done today" : "Mark completed today")
                .font(.headline)
                .foregroundStyle(doneToday ? Color.secondary : Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(doneToday ? Color.white.opacity(0.2) : Color.white)
                )
        }
        .disabled(doneToday)
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HabitDetailScreen(habitId: "no_caffeine_12pm", onClose: {})
            .environmentObject(GameState())
    }
}
