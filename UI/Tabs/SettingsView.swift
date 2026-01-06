//
//  SettingsView.swift
//  Sheep Atsume - Test
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Manual Check-in") {
                    Button("Great 🌟") {
                        gameState.logNight(level: .great)
                    }
                    
                    Button("Okay 🙂") {
                        gameState.logNight(level: .okay)
                    }
                    
                    Button("Slipped 😬") {
                        gameState.logNight(level: .slipped)
                    }
                    
                    Button("Bad 😴") {
                        gameState.logNight(level: .bad)
                    }
                    
                    Text("Manual check-in for MVP. Verification will be added later.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameState())
}

