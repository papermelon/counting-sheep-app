//
//  PixelArtSheepView.swift
//  Counting Sheep
//
//  Stylized sheep for habit cards (pixel-art inspired: blocky, limited colors).
//

import SwiftUI

struct PixelArtSheepView: View {
    /// 0–100; affects size and “health” tint.
    var habitStrength: Double
    var size: CGFloat = 56

    private var bodyColor: Color {
        if habitStrength >= 66 { return Color(white: 0.98) }
        if habitStrength >= 33 { return Color(white: 0.92) }
        return Color(white: 0.85)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Body: blocky rounded rect (pixel-art style with small radius)
            RoundedRectangle(cornerRadius: 4)
                .fill(bodyColor)
                .frame(width: size * 0.85, height: size * 0.6)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
                )
                .offset(y: -size * 0.08)

            // Wool texture: 3 overlapping circles for a fluffy blocky look
            ForEach(0..<3, id: \.self) { i in
                let x: CGFloat = (CGFloat(i) - 1) * size * 0.18
                Circle()
                    .fill(bodyColor)
                    .frame(width: size * 0.32, height: size * 0.32)
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.5), lineWidth: 1))
                    .offset(x: x, y: -size * 0.22)
            }

            // Head
            Circle()
                .fill(bodyColor)
                .frame(width: size * 0.45, height: size * 0.45)
                .overlay(Circle().strokeBorder(Color.white.opacity(0.6), lineWidth: 1))
                .offset(y: -size * 0.52)

            // Ears (two small rounded rects)
            HStack(spacing: size * 0.28) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(white: 0.75))
                    .frame(width: size * 0.12, height: size * 0.18)
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(white: 0.75))
                    .frame(width: size * 0.12, height: size * 0.18)
            }
            .offset(y: -size * 0.68)

            // Eyes (two small circles)
            HStack(spacing: size * 0.18) {
                Circle().fill(Color.black).frame(width: size * 0.08, height: size * 0.08)
                Circle().fill(Color.black).frame(width: size * 0.08, height: size * 0.08)
            }
            .offset(y: -size * 0.48)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color(white: 0.15).ignoresSafeArea()
        HStack(spacing: 24) {
            PixelArtSheepView(habitStrength: 20)
            PixelArtSheepView(habitStrength: 55)
            PixelArtSheepView(habitStrength: 100)
        }
        .padding()
    }
    .preferredColorScheme(.dark)
}
