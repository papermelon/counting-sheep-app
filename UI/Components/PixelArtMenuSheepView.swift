//
//  PixelArtMenuSheepView.swift
//  Counting Sheep
//
//  Two-frame idle animation using placeholder sheep sprites (16×16). Pixel-perfect scaling.
//

import SwiftUI

/// Sheep sprite with two-frame idle animation. Uses SheepIdleA / SheepIdleB. Scale multiplies the 16×16 base size.
struct PixelArtMenuSheepView: View {
    /// Kept for API compatibility (future: seed could select different sprite sets).
    var seed: Int
    /// Multiplier for the 16×16 sprite; e.g. 8 → 128×128 pt.
    var scale: CGFloat = 6

    private static let spriteSize: CGFloat = 16
    /// Time per frame; slower = calmer idle (e.g. 0.8–1.0 s).
    private static let frameInterval: TimeInterval = 0.85

    var body: some View {
        TimelineView(.periodic(from: .now, by: Self.frameInterval)) { context in
            let showFrameB = Int(context.date.timeIntervalSinceReferenceDate / Self.frameInterval) % 2 == 1
            Image(showFrameB ? "SheepIdleB" : "SheepIdleA")
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(
                    width: Self.spriteSize * scale,
                    height: Self.spriteSize * scale
                )
                .animation(nil, value: showFrameB)
        }
    }
}

#Preview {
    ZStack {
        Color(white: 0.12).ignoresSafeArea()
        HStack(spacing: 24) {
            PixelArtMenuSheepView(seed: 0, scale: 6)
            PixelArtMenuSheepView(seed: 1, scale: 8)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
