//
//  HabitDetailScreen.swift
//  Counting Sheep
//

import SwiftUI

struct HabitDetailScreen: View {
    @EnvironmentObject var gameState: GameState
    let habitId: String
    let onClose: () -> Void
    @State private var showCustomization = false
    @State private var showHeatmap = false

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
                        sheepHeader(s)
                        weightCard(s)
                        shearingCard(s)
                        streakCard(s)
                        weeklyDots(s)
                        last30Card(s)
                        completedTodayButton(s)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .padding(.bottom, 80)
                }
                .scrollIndicators(.hidden)
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
                .sheet(isPresented: $showHeatmap) {
                    if let s = sheep {
                        HeatmapSheetView(habitTitle: s.displayTitle, completionDates: s.completionDateSet, onDismiss: { showHeatmap = false })
                    }
                }
            } else {
                Text("Habit not found")
                    .foregroundStyle(.white)
            }
        }
        .toolbarBackground(Color(white: 0.08), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func sheepHeader(_ s: HabitSheep) -> some View {
        VStack(spacing: 12) {
            PixelArtMenuSheepView(seed: s.spriteSeed, scale: 8)
            HStack(spacing: 8) {
                Image(systemName: s.systemImage)
                    .font(.body)
                    .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
                Text(s.displayTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .multilineTextAlignment(.center)
            Button {
                regenerateSprite(for: s)
            } label: {
                Label("Personalise", systemImage: "paintbrush.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func regenerateSprite(for s: HabitSheep) {
        var updated = s
        updated.spriteSeed = HabitSheep.randomSpriteSeed()
        gameState.updateHabitSheep(updated)
    }

    private static let labelColor = Color.white.opacity(0.9)

    private func weightCard(_ s: HabitSheep) -> some View {
        let (label, value) = weightLabelAndValue(s)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Sheep weight")
                .font(.subheadline)
                .foregroundStyle(Self.labelColor)
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

    private func weightLabelAndValue(_ s: HabitSheep) -> (String, Double) {
        switch s.growthStage {
        case .needsCare: return ("\(s.weightKg) KG • Needs care", 0.2)
        case .growing: return ("\(s.weightKg) KG • Growing", 0.5)
        case .thriving: return ("\(s.weightKg) KG • Thriving", 1.0)
        }
    }

    private func shearingCard(_ s: HabitSheep) -> some View {
        let canShear = gameState.canShearSheep(s)
        let projectedCoins = s.woolKg * GameState.coinsPerWoolKg
        return VStack(alignment: .leading, spacing: 12) {
            Text("Wool redemption")
                .font(.subheadline)
                .foregroundStyle(Self.labelColor)

            Text("\(s.woolKg) KG wool ready")
                .font(.headline)
                .foregroundStyle(.white)

            Text(shearingStatusText(for: s))
                .font(.caption)
                .foregroundStyle(Self.labelColor)

            Button {
                _ = gameState.shearSheep(habitId: habitId)
            } label: {
                Text("Shear for \(projectedCoins) coins")
                    .font(.headline)
                    .foregroundStyle(canShear ? Color.black : Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(canShear ? Color.white : Color.white.opacity(0.2))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canShear)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func shearingStatusText(for s: HabitSheep) -> String {
        if s.woolKg < GameState.minimumShearKg {
            return "Need at least \(GameState.minimumShearKg) KG wool before shearing."
        }
        let remaining = gameState.remainingShearCooldown(for: s)
        if remaining <= 0 {
            return "Ready to shear now."
        }
        let hoursTotal = Int(ceil(remaining / 3600))
        let days = hoursTotal / 24
        let hours = hoursTotal % 24
        if days > 0 {
            return "Shearing cooldown: \(days)d \(hours)h remaining."
        }
        return "Shearing cooldown: \(hours)h remaining."
    }

    private func streakCard(_ s: HabitSheep) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current streak")
                .font(.subheadline)
                .foregroundStyle(Self.labelColor)
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
                .foregroundStyle(Self.labelColor)
            HStack(spacing: 8) {
                ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                    VStack(spacing: 4) {
                        Text(symbols[cal.component(.weekday, from: day) - 1])
                            .font(.caption2)
                            .foregroundStyle(Self.labelColor)
                        Circle()
                            .fill(s.completed(on: day) ? Color.green : Color.white.opacity(0.25))
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
                .foregroundStyle(Self.labelColor)
            if let pct = pct {
                Text("\(Int(round(pct)))% of days completed")
                    .font(.headline)
                    .foregroundStyle(.white)
            } else {
                Text("—% (keep going)")
                    .font(.headline)
                    .foregroundStyle(Self.labelColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
        .contentShape(Rectangle())
        .onTapGesture { showHeatmap = true }
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
                .foregroundStyle(doneToday ? Color.white : Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(doneToday ? Color.green.opacity(0.5) : Color.white)
                )
        }
        .disabled(doneToday)
        .buttonStyle(.plain)
    }
}

// MARK: - Heatmap sheet (from "Last 30 days" tap)

private struct HeatmapSheetView: View {
    let habitTitle: String
    let completionDates: Set<Date>
    let onDismiss: () -> Void

    @State private var heatmapMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
    private let cal = Calendar.current

    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: heatmapMonth)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        monthNavigator
                        HeatmapCalendarView(month: heatmapMonth, completionDates: completionDates, cellSize: 32)
                            .padding(.top, 8)
                    }
                    .padding(16)
                }
            }
            .navigationTitle(habitTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(white: 0.08), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { onDismiss() }
                        .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
                }
            }
        }
    }

    private var monthNavigator: some View {
        HStack {
            Button {
                if let prev = cal.date(byAdding: .month, value: -1, to: heatmapMonth) {
                    heatmapMonth = prev
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Text(monthTitle)
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Button {
                if let next = cal.date(byAdding: .month, value: 1, to: heatmapMonth) {
                    heatmapMonth = next
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        HabitDetailScreen(habitId: "no_caffeine_12pm", onClose: {})
            .environmentObject(GameState())
    }
}
