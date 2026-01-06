//
//  FarmTabView.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct FarmTabView: View {
    @EnvironmentObject var gameState: GameState
    
    private var subtitle: String {
        switch gameState.lastNightResult?.level {
        case .great:
            return "Your sheep are well-rested 🌙✨"
        case .okay:
            return "A decent night for the flock 🙂"
        case .slipped:
            return "Some sheep wandered last night 😬"
        case .bad, .none:
            return "A new day begins 🌅"
        }
    }
    
    private var sheepCount: Int {
        max(1, gameState.streak)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your Sheep Farm")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sheep Yard")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                            ForEach(0..<sheepCount, id: \.self) { _ in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray6))
                                        .frame(height: 80)
                                    Text("🐑")
                                        .font(.largeTitle)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stats")
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Coins 💰")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(gameState.coins)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Streak 🔥")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(gameState.streak)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )
                    }
                    
                    Text("Sheep roam at night based on your bedtime habits.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Farm")
        }
    }
}

#Preview {
    FarmTabView()
        .environmentObject(GameState())
}

