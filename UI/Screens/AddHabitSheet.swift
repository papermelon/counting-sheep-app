//
//  AddHabitSheet.swift
//  Sheep Atsume
//

import SwiftUI

struct AddHabitSheet: View {
    @EnvironmentObject var gameState: GameState
    let onDismiss: () -> Void
    @State private var selectedHabitId: String?

    private var existingIds: Set<String> {
        Set(gameState.habitSheep.map(\.habitId))
    }

    private var availableHabits: [SleepHabit] {
        SleepHabit.all.filter { !existingIds.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                if availableHabits.isEmpty {
                    Text("You've added all available habits.")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(availableHabits) { habit in
                            Button {
                                addHabit(habit)
                                onDismiss()
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: habit.systemImage)
                                        .font(.title2)
                                        .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(Color.white.opacity(0.12)))
                                    Text(habit.title)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.white.opacity(0.08))
                            .listRowSeparatorTint(.white.opacity(0.2))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Add habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(white: 0.08), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { onDismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
    }

    private func addHabit(_ habit: SleepHabit) {
        let sheep = HabitSheep(habitId: habit.id, title: habit.title, systemImage: habit.systemImage)
        gameState.habitSheep.append(sheep)
        gameState.syncSettingsToStorage()
    }
}

#Preview {
    AddHabitSheet(onDismiss: {})
        .environmentObject(GameState())
}
