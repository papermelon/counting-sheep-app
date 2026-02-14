//
//  MorningCheckInScreen.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

private let appAccent = Color(red: 0.6, green: 0.5, blue: 0.9)
private let cardBackground = Color.white.opacity(0.08)

struct MorningCheckInScreen: View {
    @EnvironmentObject var gameState: GameState
    let onClose: () -> Void

    @State private var habitResults: [String: Bool] = [:]

    var body: some View {
        ZStack {
            Color(white: 0.08).ignoresSafeArea()

            VStack(spacing: 16) {
                header

                ScrollView {
                    VStack(spacing: 20) {
                        Text("How did your habits go?")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.dark)
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
                HStack(spacing: 6) {
                    Image(systemName: "xmark")
                    Text("Close")
                        .font(.subheadline)
                }
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Morning Check-in")
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            if gameState.checkInStreak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(gameState.checkInStreak)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                }
            } else {
                Color.clear.frame(width: 44, height: 32)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private func habitCheckRow(_ sheep: HabitSheep) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                SheepWithBadge(spriteSeed: sheep.spriteSeed, systemImage: sheep.systemImage, spriteScale: 3, badgeSize: 16)

                Text(sheep.displayTitle)
                    .font(.body)
                    .foregroundStyle(.white)
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
                            RoundedRectangle(cornerRadius: 12)
                                .fill(habitResults[sheep.habitId] == false ? Color.white.opacity(0.25) : cardBackground)
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
                            RoundedRectangle(cornerRadius: 12)
                                .fill(habitResults[sheep.habitId] == true ? Color.green.opacity(0.6) : cardBackground)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
        )
    }

    private var doneButton: some View {
        Button {
            gameState.submitCheckIn(habitResults: habitResults)
            onClose()
        } label: {
            Text("Done")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.green.opacity(0.7))
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
