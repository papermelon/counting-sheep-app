//
//  AddHabitSheet.swift
//  Counting Sheep
//

import SwiftUI

struct AddHabitSheet: View {
    @EnvironmentObject var gameState: GameState
    let onDismiss: () -> Void

    @State private var searchText: String = ""
    @State private var selectedCategory: HabitCategory? = nil  // nil = "Popular"

    private var existingIds: Set<String> {
        Set(gameState.habitSheep.map(\.habitId))
    }

    private var availableHabits: [SleepHabit] {
        SleepHabit.all.filter { !existingIds.contains($0.id) }
    }

    private var filteredHabits: [SleepHabit] {
        var habits: [SleepHabit]
        if let cat = selectedCategory {
            habits = availableHabits.filter { $0.category == cat }
        } else {
            // "Popular" tab: show a curated mix from each category
            habits = availableHabits
        }

        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return habits
        }
        let query = searchText.lowercased()
        return habits.filter { $0.title.lowercased().contains(query) }
    }

    /// For "Popular" tab, whether the habit is a popular pick
    private static let popularIds: Set<String> = [
        "no_caffeine_12pm", "in_bed_by_1030", "eight_hours", "walk_30min",
        "no_social_media_after_9pm", "no_social_media_before_10am",
        "gratitude_journal", "no_liquids_9pm", "last_meal_3h", "read_fiction",
        "call_loved_one", "drink_water_morning", "yoga_session",
        "do_important_work_first"
    ]

    private var popularHabits: [SleepHabit] {
        availableHabits.filter { Self.popularIds.contains($0.id) }
    }

    /// Category tabs including "Popular"
    private let categories: [HabitCategory?] = [nil] + HabitCategory.allCases

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        TextField("Find or create custom habit", text: $searchText)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // Category pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories.indices, id: \.self) { idx in
                                let cat = categories[idx]
                                let label = cat?.displayName ?? "Popular"
                                let isSelected = selectedCategory == cat && (cat != nil || selectedCategory == nil)
                                    && (idx == 0 ? selectedCategory == nil : true)

                                Button {
                                    selectedCategory = cat
                                } label: {
                                    Text(label)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(isSelected ? .black : .white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule().fill(isSelected ? (cat?.color ?? .white) : Color.white.opacity(0.12))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }

                    // Habit list
                    if selectedCategory == nil {
                        // Popular tab
                        popularListView
                    } else {
                        categoryListView
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(white: 0.08), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
    }

    // MARK: - Popular tab (curated mix)

    @ViewBuilder
    private var popularListView: some View {
        let habits = searchText.isEmpty ? popularHabits : filteredHabits
        if habits.isEmpty {
            Spacer()
            Text("No habits found.")
                .foregroundStyle(.secondary)
            Spacer()
        } else {
            // Find the first popular habit for the "Most Popular" badge
            let firstPopularId = habits.first?.id
            ScrollView {
                LazyVStack(spacing: 0) {
                    // "Custom habit" row at top
                    customHabitRow
                        .padding(.bottom, 4)

                    ForEach(habits) { habit in
                        VStack(alignment: .leading, spacing: 0) {
                            if habit.id == firstPopularId {
                                Text("Most Popular")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.orange)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                                    .padding(.bottom, 2)
                            }
                            habitRow(habit)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Category tab

    @ViewBuilder
    private var categoryListView: some View {
        let habits = filteredHabits
        if habits.isEmpty {
            Spacer()
            Text("No habits in this category yet.")
                .foregroundStyle(.secondary)
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    customHabitRow
                        .padding(.bottom, 4)

                    ForEach(habits) { habit in
                        habitRow(habit)
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Row views

    @ViewBuilder
    private var customHabitRow: some View {
        Button {
            // Future: open custom habit creation
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18))
                    .foregroundStyle(HabitCategory.focus.color)
                    .frame(width: 40, height: 40)
                    .background(HabitCategory.focus.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text("Custom habit")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)

                Spacer()

                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func habitRow(_ habit: SleepHabit) -> some View {
        Button {
            addHabit(habit)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: habit.systemImage)
                    .font(.system(size: 18))
                    .foregroundStyle(habit.category.color)
                    .frame(width: 40, height: 40)
                    .background(habit.category.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                    // Metadata badges
                    HStack(spacing: 8) {
                        if habit.usesHealthData {
                            HStack(spacing: 3) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.red.opacity(0.8))
                                Text("Health Data")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.gray)
                            }
                        }
                        if habit.usesScreenTime {
                            HStack(spacing: 3) {
                                Image(systemName: "hourglass")
                                    .font(.system(size: 9))
                                    .foregroundStyle(HabitCategory.focus.color.opacity(0.8))
                                Text("Screen Time Block")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                }

                Spacer()

                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func addHabit(_ habit: SleepHabit) {
        let sheep = HabitSheep(habitId: habit.id, title: habit.title, systemImage: habit.systemImage, spriteSeed: HabitSheep.randomSpriteSeed())
        gameState.habitSheep.append(sheep)
        gameState.syncSettingsToStorage()
    }
}

#Preview {
    AddHabitSheet(onDismiss: {})
        .environmentObject(GameState())
}
