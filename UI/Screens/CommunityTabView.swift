//
//  CommunityTabView.swift
//  Counting Sheep
//

import SwiftUI

struct CommunityTabView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen farm showing the user's own sheep
                FarmSceneView(
                    sheep: gameState.habitSheep,
                    isCompact: false
                )
                .ignoresSafeArea()

                // Overlay: subtle bottom banner explaining the future feature
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                            .font(.subheadline)
                        Text("Friends will be able to visit your farm soon")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.55))
                    )
                    .padding(.bottom, 80) // above tab bar
                }
            }
            .navigationTitle("Your Farm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    CommunityTabView()
        .environmentObject(GameState(habitSheep: [
            HabitSheep(habitId: "a", title: "Put phone away", systemImage: "clock.badge.checkmark", growthStage: .thriving, consecutiveDaysDone: 5),
            HabitSheep(habitId: "b", title: "No caffeine", systemImage: "cup.and.saucer.fill", growthStage: .growing, consecutiveDaysDone: 2),
            HabitSheep(habitId: "c", title: "Get sunlight", systemImage: "sun.max.fill", growthStage: .needsCare),
        ]))
}
