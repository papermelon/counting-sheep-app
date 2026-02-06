//
//  HomeTabView.swift
//  Sheep Atsume
//

import SwiftUI

private struct HabitDetailDestination: Identifiable, Hashable {
    let id: String
}

struct HomeTabView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(AppNavigation.self) private var navigation
    @State private var selectedDay: Date = Date()
    @State private var showAddHabit = false
    @State private var showSettings = false
    @State private var habitDetailDestination: HabitDetailDestination?

    private let cal = Calendar.current
    /// Scrollable range: from 60 days ago through 7 days from now (dates left and right of today).
    private var dateRange: [Date] {
        let today = cal.startOfDay(for: Date())
        return (-60...7).compactMap { cal.date(byAdding: .day, value: $0, to: today) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                VStack(spacing: 0) {
                    dateStrip
                    habitList
                }
                .navigationTitle(selectedDayTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color(white: 0.08), for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { }
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 16) {
                            Button {
                                showAddHabit = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showAddHabit) {
                    AddHabitSheet(onDismiss: { showAddHabit = false })
                        .environmentObject(gameState)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsScreen(
                        onClose: { showSettings = false },
                        onOpenHabitCustomization: { habitId in
                            showSettings = false
                            navigation.habitCustomizationReturnTo = .settings
                            navigation.navigate(to: .habitCustomization(habitId: habitId))
                        },
                        onOpenCheckIn: {
                            showSettings = false
                            navigation.showCheckInSheet = true
                        }
                    )
                    .environmentObject(gameState)
                }
                .navigationDestination(item: $habitDetailDestination) { dest in
                    HabitDetailScreen(habitId: dest.id, onClose: { habitDetailDestination = nil })
                        .environmentObject(gameState)
                }
            }
        }
    }

    private var dateStrip: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(dateRange, id: \.timeIntervalSince1970) { day in
                        let isSelected = cal.isDate(selectedDay, inSameDayAs: day)
                        let dayNum = cal.component(.day, from: day)
                        let monthNum = cal.component(.month, from: day)
                        let weekday = cal.shortWeekdaySymbols[cal.component(.weekday, from: day) - 1]
                        Button {
                            selectedDay = day
                        } label: {
                            VStack(spacing: 4) {
                                Text(weekday)
                                    .font(.caption)
                                    .foregroundStyle(isSelected ? Color.black : Color.secondary)
                                Text("\(dayNum)")
                                    .font(.headline)
                                    .foregroundStyle(isSelected ? Color.black : Color.white)
                                Text(shortMonth(monthNum))
                                    .font(.caption2)
                                    .foregroundStyle(isSelected ? Color.black.opacity(0.8) : Color.white.opacity(0.6))
                            }
                            .frame(width: 48, height: 58)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? Color.white : Color.white.opacity(0.15))
                            )
                        }
                        .buttonStyle(.plain)
                        .id(day.timeIntervalSince1970)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(white: 0.06))
            .onAppear {
                let today = cal.startOfDay(for: Date())
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(today.timeIntervalSince1970, anchor: .center)
                }
            }
            .onChange(of: selectedDay) { _, newDay in
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(cal.startOfDay(for: newDay).timeIntervalSince1970, anchor: .center)
                }
            }
        }
    }

    private func shortMonth(_ month: Int) -> String {
        var comps = DateComponents()
        comps.year = 2020
        comps.month = month
        comps.day = 1
        guard let d = cal.date(from: comps) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: d)
    }

    private var selectedDayTitle: String {
        if cal.isDateInToday(selectedDay) { return "Today" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: selectedDay)
    }

    /// Habits that are scheduled for the selected day (every day, weekdays, or custom).
    private var habitsForSelectedDay: [HabitSheep] {
        gameState.habitSheep.filter { $0.schedule.isScheduled(on: selectedDay) }
    }

    private var habitList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if habitsForSelectedDay.isEmpty {
                    Text("No habits scheduled for this day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 32)
                } else {
                    ForEach(habitsForSelectedDay) { sheep in
                        HabitCardView(
                            sheep: sheep,
                            selectedDay: selectedDay,
                            onTap: { habitDetailDestination = HabitDetailDestination(id: sheep.habitId) },
                            onMarkDoneToday: cal.isDateInToday(selectedDay) ? { gameState.markHabitCompletedToday(habitId: sheep.habitId) } : nil
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}

/// Maps growth stage (and optional streak) to a 0–100 HP-style value.
private func habitStrengthHP(for sheep: HabitSheep) -> Double {
    switch sheep.growthStage {
    case .needsCare: return 20
    case .growing: return min(100, 50 + Double(sheep.consecutiveDaysDone) * 5)
    case .thriving: return min(100, 80 + Double(sheep.consecutiveDaysDone) * 2)
    }
}

private struct HabitCardView: View {
    let sheep: HabitSheep
    let selectedDay: Date
    let onTap: () -> Void
    /// When non-nil (e.g. when selected day is today), tapping the done control marks the habit done for today.
    let onMarkDoneToday: (() -> Void)?
    private let cal = Calendar.current

    private var isDone: Bool {
        sheep.completed(on: selectedDay)
    }

    private var hp: Double {
        habitStrengthHP(for: sheep)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                PixelArtSheepView(habitStrength: hp, size: 52)

                VStack(alignment: .leading, spacing: 6) {
                    Text(sheep.displayTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack(spacing: 14) {
                        HStack(spacing: 4) {
                            Text("HP")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("\(Int(hp))")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(hpColor)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("\(sheep.consecutiveDaysDone)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                doneControl
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var doneControl: some View {
        if isDone {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
        } else if let markDone = onMarkDoneToday {
            Button(action: markDone) {
                Image(systemName: "circle")
                    .font(.title2)
                    .foregroundStyle(.gray)
            }
            .buttonStyle(.plain)
        } else {
            Image(systemName: "circle")
                .font(.title2)
                .foregroundStyle(.gray)
        }
    }

    private var hpColor: Color {
        if hp >= 66 { return Color(red: 0.4, green: 0.8, blue: 0.5) }
        if hp >= 33 { return Color.orange }
        return Color(red: 0.95, green: 0.4, blue: 0.35)
    }
}

#Preview {
    HomeTabView()
        .environmentObject(GameState())
        .environment(AppNavigation())
}
