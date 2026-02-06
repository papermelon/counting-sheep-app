//
//  MorningCheckInScreen.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct MorningCheckInScreen: View {
    @EnvironmentObject var gameState: GameState
    let onClose: () -> Void

    @State private var habitResults: [String: Bool] = [:]

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.98, blue: 1.0)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                header

                ScrollView {
                    VStack(spacing: 20) {
                        Text("How did your habits go?")
                            .font(.title3.bold())
                            .foregroundStyle(Color(red: 0.25, green: 0.2, blue: 0.15))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if gameState.habitSheep.isEmpty {
                            Text("No habits yet. Complete onboarding to add habits.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding()
                        } else {
                            ForEach(gameState.habitSheep) { sheep in
                                habitCheckRow(sheep)
                            }
                        }

                        if gameState.hasAnyVerifiedScreenHabit {
                            VerifiedModeButton(
                                gameState: gameState,
                                onComplete: onClose
                            )
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                }

                doneButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            let cal = Calendar.current
            habitResults = Dictionary(uniqueKeysWithValues: gameState.habitSheep.map { sheep in
                let alreadyDoneToday = sheep.lastCheckedDate.map { cal.isDateInToday($0) } ?? false
                return (sheep.habitId, alreadyDoneToday)
            })
        }
    }

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Label("Close", systemImage: "xmark")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.bordered)

            Spacer()

            Text("Morning Check-in")
                .font(.title3.bold())

            Spacer()

            if gameState.checkInStreak > 0 {
                Label("\(gameState.checkInStreak)", systemImage: "flame.fill")
                    .font(.footnote)
                    .foregroundStyle(Color.orange)
            } else {
                Color.clear.frame(width: 60)
            }
        }
        .padding(.horizontal)
    }

    private func habitCheckRow(_ sheep: HabitSheep) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: sheep.systemImage)
                    .font(.title2)
                    .foregroundStyle(Color(red: 0.5, green: 0.35, blue: 0.6))
                    .frame(width: 40, height: 40)

                Text(sheep.displayTitle)
                    .font(.body)
                    .foregroundStyle(Color(red: 0.3, green: 0.25, blue: 0.2))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                Button {
                    habitResults[sheep.habitId] = false
                } label: {
                    Text("No")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(habitResults[sheep.habitId] == false ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(habitResults[sheep.habitId] == false ? Color.red.opacity(0.7) : Color.gray.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)

                Button {
                    habitResults[sheep.habitId] = true
                } label: {
                    Text("Yes")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(habitResults[sheep.habitId] == true ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(habitResults[sheep.habitId] == true ? Color.green.opacity(0.8) : Color.gray.opacity(0.2))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        )
    }

    private var doneButton: some View {
        Button {
            gameState.submitCheckIn(habitResults: habitResults)
            onClose()
        } label: {
            Text("Done")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red: 0.4, green: 0.6, blue: 0.5))
                )
        }
        .buttonStyle(.plain)
        .disabled(gameState.habitSheep.isEmpty)
    }
}

#Preview {
    MorningCheckInScreen(onClose: {})
        .environmentObject(GameState(
            habitSheep: [
                HabitSheep(habitId: "phone_away_10pm", title: "Put phone away at 10pm", systemImage: "clock.badge.checkmark"),
                HabitSheep(habitId: "no_caffeine_12pm", title: "No caffeine after 12pm", systemImage: "cup.and.saucer.fill")
            ],
            checkInStreak: 3
        ))
}
