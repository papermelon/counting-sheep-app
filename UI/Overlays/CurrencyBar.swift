//
//  CurrencyBar.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct CurrencyBar: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        HStack(spacing: 20) {
            // Coins
            currencyItem(icon: "🪙", value: gameState.coins)
            
            // Streak
            currencyItem(icon: "🔥", value: gameState.streak)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(red: 1.0, green: 0.98, blue: 0.94).opacity(0.95))
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        )
        .overlay(
            Capsule()
                .stroke(Color(red: 0.85, green: 0.75, blue: 0.6), lineWidth: 2)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func currencyItem(icon: String, value: Int) -> some View {
        HStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 20))
            
            Text("\(value)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
        }
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.3)
        VStack {
            Spacer()
            CurrencyBar()
        }
    }
    .environmentObject(GameState(coins: 150, streak: 5))
}

