//
//  FarmView.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct FarmView: View {
    @EnvironmentObject var gameState: GameState
    
    private var sheepCount: Int {
        max(1, gameState.streak)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: Background
                FarmBackground()
                
                // Layer 2: Sheep sprites
                sheepLayer(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func sheepLayer(in size: CGSize) -> some View {
        // Position sheep in the pasture area (lower 2/3 of screen)
        let pastureTop = size.height * 0.35
        let pastureHeight = size.height * 0.5
        let pastureWidth = size.width * 0.8
        let startX = size.width * 0.1
        
        ForEach(0..<sheepCount, id: \.self) { index in
            SheepSprite()
                .position(
                    x: startX + CGFloat.random(in: 0...pastureWidth),
                    y: pastureTop + CGFloat.random(in: 0...pastureHeight)
                )
                .id("sheep-\(index)-\(sheepCount)") // Stable positioning per count
        }
    }
}

struct SheepSprite: View {
    var body: some View {
        Text("🐑")
            .font(.system(size: 48))
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 2)
    }
}

#Preview {
    FarmView()
        .environmentObject(GameState(streak: 3))
}

