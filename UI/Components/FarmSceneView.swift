//
//  FarmSceneView.swift
//  Counting Sheep
//
//  Reusable farm scene with pixel art sheep that roam the pasture.
//  Compact mode (Home header) or full-screen (Community tab).
//  Takes [HabitSheep] as input so it can render any user's farm.
//

import SwiftUI
import Combine

/// A roaming-sheep farm scene. Each sheep wanders the pasture using its pixel art sprite.
struct FarmSceneView: View {
    let sheep: [HabitSheep]
    var isCompact: Bool = false
    var onTapSheep: ((String) -> Void)?

    /// Internal state: current animated positions keyed by habitId.
    @State private var positions: [String: CGPoint] = [:]
    /// Whether initial positions have been set (prevents re-randomising on redraws).
    @State private var didInitialize = false

    /// Timer that periodically picks new wander targets (grazing pace).
    private let wanderTimer = Timer.publish(every: 4.0, on: .main, in: .common).autoconnect()

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let pasture = pastureRect(in: geo.size)

            ZStack {
                FarmBackground()

                ForEach(sheep) { s in
                    let pos = positions[s.habitId] ?? center(of: pasture)
                    let scale = spriteScale(for: s.growthStage)

                    Button {
                        onTapSheep?(s.habitId)
                    } label: {
                        PixelArtMenuSheepView(seed: s.spriteSeed, scale: scale)
                    }
                    .buttonStyle(.plain)
                    .position(pos)
                }
            }
            .clipped()
            .onAppear {
                guard !didInitialize else { return }
                didInitialize = true
                initializePositions(in: pastureRect(in: geo.size))
            }
            .onReceive(wanderTimer) { _ in
                let p = pastureRect(in: geo.size)
                withAnimation(.easeInOut(duration: 3.0)) {
                    wander(in: p)
                }
            }
        }
    }

    // MARK: - Pasture geometry

    /// The rectangle where sheep are allowed to roam (the grass area of FarmBackground).
    private func pastureRect(in size: CGSize) -> CGRect {
        // FarmBackground grass starts at ~50% from top.
        // In compact mode we use a tighter vertical band so sheep sit nicely.
        let topFraction: CGFloat = isCompact ? 0.55 : 0.50
        let bottomFraction: CGFloat = isCompact ? 0.92 : 0.88
        let horizontalInset: CGFloat = size.width * 0.08
        return CGRect(
            x: horizontalInset,
            y: size.height * topFraction,
            width: size.width - horizontalInset * 2,
            height: size.height * (bottomFraction - topFraction)
        )
    }

    private func center(of rect: CGRect) -> CGPoint {
        CGPoint(x: rect.midX, y: rect.midY)
    }

    // MARK: - Positioning

    /// Scatter sheep across the pasture on first appearance.
    private func initializePositions(in pasture: CGRect) {
        var newPositions: [String: CGPoint] = [:]
        for s in sheep {
            newPositions[s.habitId] = randomPoint(in: pasture)
        }
        positions = newPositions
    }

    /// Move each sheep to a nearby spot, like grazing – small steps instead of crossing the field.
    private func wander(in pasture: CGRect) {
        let maxStep: CGFloat = min(pasture.width, pasture.height) * 0.15
        var newPositions = positions
        for s in sheep {
            let oldPos = positions[s.habitId] ?? center(of: pasture)
            let newTarget = nearbyPoint(from: oldPos, maxDistance: maxStep, within: pasture)
            newPositions[s.habitId] = newTarget
        }
        positions = newPositions
    }

    /// Pick a point within maxDistance of the origin, clamped to the pasture.
    private func nearbyPoint(from origin: CGPoint, maxDistance: CGFloat, within pasture: CGRect) -> CGPoint {
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let dist = CGFloat.random(in: 0...maxDistance)
        let x = origin.x + cos(angle) * dist
        let y = origin.y + sin(angle) * dist
        return CGPoint(
            x: min(max(x, pasture.minX), pasture.maxX),
            y: min(max(y, pasture.minY), pasture.maxY)
        )
    }

    private func randomPoint(in rect: CGRect) -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: rect.minX...rect.maxX),
            y: CGFloat.random(in: rect.minY...rect.maxY)
        )
    }

    // MARK: - Sprite sizing

    /// Sprite scale multiplier. Compact mode uses smaller sprites; growth stage adjusts further.
    private func spriteScale(for stage: SheepGrowthStage) -> CGFloat {
        let base: CGFloat = isCompact ? 2.5 : 3.5
        switch stage {
        case .needsCare: return base * 0.8
        case .growing:   return base
        case .thriving:  return base * 1.15
        }
    }
}

// MARK: - Previews

#Preview("Compact – Home header") {
    VStack(spacing: 0) {
        FarmSceneView(
            sheep: [
                HabitSheep(habitId: "a", title: "Put phone away", systemImage: "clock.badge.checkmark", growthStage: .thriving, consecutiveDaysDone: 5),
                HabitSheep(habitId: "b", title: "No caffeine", systemImage: "cup.and.saucer.fill", growthStage: .growing, consecutiveDaysDone: 2),
                HabitSheep(habitId: "c", title: "Get sunlight", systemImage: "sun.max.fill", growthStage: .needsCare),
            ],
            isCompact: true,
            onTapSheep: { id in print("Tapped \(id)") }
        )
        .frame(height: 250)

        Color(white: 0.08)
    }
    .ignoresSafeArea()
}

#Preview("Full-screen – Community") {
    FarmSceneView(
        sheep: [
            HabitSheep(habitId: "a", title: "Put phone away", systemImage: "clock.badge.checkmark", growthStage: .thriving, consecutiveDaysDone: 5),
            HabitSheep(habitId: "b", title: "No caffeine", systemImage: "cup.and.saucer.fill", growthStage: .growing, consecutiveDaysDone: 2),
            HabitSheep(habitId: "c", title: "Get sunlight", systemImage: "sun.max.fill", growthStage: .needsCare),
            HabitSheep(habitId: "d", title: "No blue light", systemImage: "iphone", growthStage: .growing, consecutiveDaysDone: 1),
        ],
        isCompact: false
    )
    .ignoresSafeArea()
}
