//
//  HomeTabView.swift
//  Counting Sheep
//

import SwiftUI

private struct HabitDetailDestination: Identifiable, Hashable {
    let id: String
}

struct HomeTabView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(AppNavigation.self) private var navigation
    @AppStorage("HomeTabView.showFarm") private var showFarm: Bool = false
    @State private var selectedDay: Date = Date()
    @State private var showAddHabit = false
    @State private var showSettings = false
    @State private var habitDetailDestination: HabitDetailDestination?
    /// The sheep whose stats card is shown at the bottom in farm mode.
    @State private var selectedFarmSheepId: String?

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
                    if showFarm {
                        FarmSceneView(
                            sheep: gameState.habitSheep,
                            isCompact: true,
                            onTapSheep: { habitId in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selectedFarmSheepId = selectedFarmSheepId == habitId ? nil : habitId
                                }
                            }
                        )
                        .frame(height: 250)
                    }

                    dateStrip
                    habitList
                }

                // Bottom stats card when a sheep is tapped in farm mode
                if showFarm, let sheepId = selectedFarmSheepId,
                   let sheep = gameState.habitSheep.first(where: { $0.habitId == sheepId }) {
                    VStack {
                        Spacer()
                        farmSheepStatsCard(sheep)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 80) // above tab bar
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle(selectedDayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(white: 0.08), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showFarm.toggle()
                            if !showFarm { selectedFarmSheepId = nil }
                        }
                    } label: {
                        Image(systemName: showFarm ? "list.bullet" : "leaf.fill")
                            .font(.body)
                            .foregroundStyle(.white)
                    }
                }
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
                            VStack(spacing: 2) {
                                Text(weekday)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(isSelected ? Color.black : Color.white.opacity(0.75))
                                Text("\(dayNum)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(isSelected ? Color.black : Color.white)
                                Text(shortMonth(monthNum))
                                    .font(.caption2)
                                    .foregroundStyle(isSelected ? Color.black.opacity(0.8) : Color.white.opacity(0.6))
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 8)
                            .frame(width: 52, height: 62)
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

    // MARK: - Farm sheep stats card (shown at bottom when tapping a sheep in farm mode)

    private func farmSheepStatsCard(_ sheep: HabitSheep) -> some View {
        let weightKg = habitWeightKg(for: sheep)
        let doneToday = sheep.completed(on: Date())
        return HStack(spacing: 14) {
            SheepWithBadge(spriteSeed: sheep.spriteSeed, systemImage: sheep.systemImage, spriteScale: 3.5, badgeSize: 18)

            VStack(alignment: .leading, spacing: 6) {
                Text(sheep.displayTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Text("\(weightKg)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                        Text("KG")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("\(sheep.consecutiveDaysDone)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                    Text(sheep.growthStage.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 6) {
                // Navigate to detail
                Button {
                    habitDetailDestination = HabitDetailDestination(id: sheep.habitId)
                    selectedFarmSheepId = nil
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .buttonStyle(.plain)

                // Mark done
                if doneToday {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                } else {
                    Button {
                        gameState.markHabitCompletedToday(habitId: sheep.habitId)
                    } label: {
                        Image(systemName: "circle")
                            .font(.title3)
                            .foregroundStyle(.gray)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
        )
    }
}

/// Display-facing sheep weight in KG for home cards.
private func habitWeightKg(for sheep: HabitSheep) -> Int {
    sheep.weightKg
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

    private var weightKg: Int {
        habitWeightKg(for: sheep)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                SheepWithBadge(spriteSeed: sheep.spriteSeed, systemImage: sheep.systemImage, spriteScale: 4, badgeSize: 20)

                VStack(alignment: .leading, spacing: 6) {
                    Text(sheep.displayTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    HStack(spacing: 14) {
                        HStack(spacing: 4) {
                            Text("\(weightKg)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                            Text("KG")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("\(sheep.consecutiveDaysDone)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
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

}

#Preview {
    HomeTabView()
        .environmentObject(GameState())
        .environment(AppNavigation())
}
