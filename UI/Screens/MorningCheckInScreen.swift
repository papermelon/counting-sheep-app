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
    
    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.98, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                header
                
                VStack(spacing: 24) {
                    if let result = gameState.lastNightResult {
                        resultCard(result.level)
                    } else {
                        Text("No check-in yet. Choose how the night went:")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    ratingButtons
                    
                    modeInfo
                }
                .padding()
            }
            .padding()
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
            
            Color.clear.frame(width: 60)
        }
    }
    
    @ViewBuilder
    private func resultCard(_ level: NightSuccessLevel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(level.displayTitle)
                .font(.headline)
            Text(level.starsText)
                .font(.title2)
            Text(description(for: level))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Label("\(gameState.streak)", systemImage: "flame.fill")
                    .foregroundStyle(Color.orange)
                Label("\(gameState.coins)", systemImage: "creditcard.circle.fill")
                    .foregroundStyle(Color.green)
            }
            .font(.footnote)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
        )
    }
    
    private var ratingButtons: some View {
        VStack(spacing: 10) {
            checkInButton(title: "⭐⭐⭐ Great night", level: .threeStars, color: Color(red: 0.9, green: 0.95, blue: 1.0))
            checkInButton(title: "⭐⭐ Okay night", level: .twoStars, color: Color(red: 0.9, green: 1.0, blue: 0.9))
            checkInButton(title: "⭐ Slipped", level: .oneStar, color: Color(red: 1.0, green: 0.95, blue: 0.9))
            checkInButton(title: "☆ Rough night", level: .zeroStars, color: Color(red: 0.95, green: 0.95, blue: 0.95))
            
            if gameState.mode == .verified {
                Button {
                    // Placeholder: in real Verified mode, use Screen Time minutes from bedtime window
                    _ = gameState.logNightFromUsageMinutes(12)
                    onClose()
                } label: {
                    Text("Auto-grade (Screen Time)")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.88, green: 0.92, blue: 1.0))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func checkInButton(title: String, level: NightSuccessLevel, color: Color) -> some View {
        Button {
            gameState.logNight(level: level)
            onClose()
        } label: {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                )
        }
        .buttonStyle(.plain)
    }
    
    private var modeInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Modes")
                .font(.headline)
            Text("Cozy Mode: manual check-ins; sheep always return safely but with common rewards.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Verified Mode: uses Screen Time at night to auto-grade your stars. Better streaks, growth, and rare items.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func description(for level: NightSuccessLevel) -> String {
        switch level {
        case .threeStars:
            return "Sheep return healthy and happy. Best growth and rewards."
        case .twoStars:
            return "A decent night. Solid progress."
        case .oneStar:
            return "Some wandering. Small gains."
        case .zeroStars:
            return "Sheep are tired. No gains, but no penalties."
        }
    }
}

#Preview {
    MorningCheckInScreen(onClose: {})
        .environmentObject(GameState(coins: 12, streak: 3, lastNightResult: NightResult(date: .now, level: .twoStars)))
}

