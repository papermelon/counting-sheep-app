//
//  TutorialOverlay.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct TutorialOverlay: View {
    let title: String
    let message: String
    let isLast: Bool
    let onNext: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    onNext()
                }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    Button("Skip") {
                        onSkip()
                    }
                    .buttonStyle(.bordered)
                    
                    Button(isLast ? "Done" : "Next") {
                        onNext()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(red: 0.86, green: 0.78, blue: 0.65), lineWidth: 1)
            )
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    TutorialOverlay(
        title: "Welcome to Counting Sheep",
        message: "Nightly check-ins keep your flock rested. Great/Okay/Slipped/Bad give +10/+6/+2/+0 coins.",
        isLast: false,
        onNext: {},
        onSkip: {}
    )
}

