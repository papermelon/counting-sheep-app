//
//  VerifiedModeButton.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI
import FamilyControls

struct VerifiedModeButton: View {
    @ObservedObject var gameState: GameState
    let onComplete: () -> Void
    
    @StateObject private var screenTimeService = ScreenTimeService.shared
    @State private var isFetching = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                Task {
                    await fetchAndLogNight()
                }
            } label: {
                HStack {
                    if isFetching {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "clock.fill")
                    }
                    
                    Text(isFetching ? "Fetching Screen Time..." : "Update from Screen Time")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(buttonColor)
                )
            }
            .buttonStyle(.plain)
            .disabled(isFetching || screenTimeService.authorizationStatus != .approved)
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else if screenTimeService.authorizationStatus == .notDetermined {
                Button("Authorize Screen Time") {
                    Task {
                        await requestAuthorization()
                    }
                }
                .font(.caption)
                .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
            } else if screenTimeService.authorizationStatus == .denied {
                Text("Screen Time access denied. Enable in Settings.")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }
    
    private var buttonColor: Color {
        if isFetching {
            return Color(red: 0.5, green: 0.4, blue: 0.7)
        } else if screenTimeService.authorizationStatus == .approved {
            return Color(red: 0.6, green: 0.5, blue: 0.9)
        } else {
            return Color.white.opacity(0.2)
        }
    }
    
    private func requestAuthorization() async {
        do {
            try await screenTimeService.requestAuthorization()
        } catch {
            errorMessage = "Failed to authorize: \(error.localizedDescription)"
        }
    }
    
    private func fetchAndLogNight() async {
        isFetching = true
        errorMessage = nil
        
        // Check authorization
        guard screenTimeService.authorizationStatus == .approved else {
            errorMessage = "Screen Time authorization required"
            isFetching = false
            return
        }
        
        // Fetch usage for last night's bedtime window
        let minutes = await screenTimeService.fetchLastNightUsageMinutes(
            bedtimeStart: gameState.bedtimeStart,
            bedtimeEnd: gameState.bedtimeEnd
        )
        
        if let minutes = minutes {
            applyScreenTimeResult(minutes: minutes)
            isFetching = false
            onComplete()
        } else {
            let fallbackMinutes = await screenTimeService.fetchUsageMinutesForInterval(
                start: gameState.bedtimeStart,
                end: gameState.bedtimeEnd
            )
            if fallbackMinutes > 0 {
                applyScreenTimeResult(minutes: fallbackMinutes)
                isFetching = false
                onComplete()
            } else {
                errorMessage = "Could not fetch Screen Time data. Try manual check-in."
                isFetching = false
            }
        }
    }

    private func applyScreenTimeResult(minutes: Int) {
        let level = GameState.level(forUsageMinutes: minutes)
        let didIt = (level == .threeStars || level == .twoStars)
        for habitId in gameState.verifiedScreenHabitIds {
            gameState.recordHabitResult(habitId: habitId, didIt: didIt)
        }
    }
}
