//
//  FarmView.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct FarmView: View {
    @EnvironmentObject var gameState: GameState

    private var displaySheep: [HabitSheep] {
        if gameState.habitSheep.isEmpty {
            return [HabitSheep(habitId: "default", title: "Sleep well", systemImage: "moon.zzz.fill", growthStage: .needsCare)]
        }
        return gameState.habitSheep
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                FarmBackground()
                sheepLayer(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func sheepLayer(in size: CGSize) -> some View {
        let pasture = CGRect(
            x: size.width * 0.1,
            y: size.height * 0.35,
            width: size.width * 0.8,
            height: size.height * 0.5
        )
        let columns = 3
        let count = displaySheep.count
        let rows = max(1, Int(ceil(Double(count) / Double(columns))))
        let cellWidth = pasture.width / CGFloat(columns)
        let cellHeight = pasture.height / CGFloat(rows)

        ForEach(Array(displaySheep.enumerated()), id: \.element.habitId) { index, sheep in
            let row = index / columns
            let col = index % columns
            let x = pasture.minX + cellWidth * (CGFloat(col) + 0.5)
            let y = pasture.minY + cellHeight * (CGFloat(row) + 0.5)

            SheepSprite(sheep: sheep)
                .position(x: x, y: y)
                .id("sheep-\(sheep.habitId)-\(sheep.growthStage.rawValue)")
        }
    }
}

struct SheepSprite: View {
    let sheep: HabitSheep

    private var scale: CGFloat {
        switch sheep.growthStage {
        case .needsCare: return 0.75
        case .growing: return 1.0
        case .thriving: return 1.15
        }
    }

    private var opacity: Double {
        switch sheep.growthStage {
        case .needsCare: return 0.85
        case .growing: return 1.0
        case .thriving: return 1.0
        }
    }

    var body: some View {
        Text("🐑")
            .font(.system(size: 48))
            .scaleEffect(scale)
            .opacity(opacity)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 2)
    }
}

#Preview {
    FarmView()
        .environmentObject(GameState(habitSheep: [
            HabitSheep(habitId: "a", title: "Habit A", systemImage: "moon.fill", growthStage: .thriving),
            HabitSheep(habitId: "b", title: "Habit B", systemImage: "sun.fill", growthStage: .growing),
            HabitSheep(habitId: "c", title: "Habit C", systemImage: "star.fill", growthStage: .needsCare)
        ]))
}
