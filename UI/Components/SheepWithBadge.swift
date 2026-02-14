//
//  SheepWithBadge.swift
//  Counting Sheep
//
//  Reusable component: pixel art sheep sprite with a small SF Symbol icon badge
//  in the bottom-trailing corner. Used on engagement screens (Home, Detail, Check-In)
//  so users learn the icon ↔ habit association while keeping the tamagotchi feel.
//

import SwiftUI

private let appAccent = Color(red: 0.6, green: 0.5, blue: 0.9)

/// Pixel art sheep with a small circular icon badge overlay.
struct SheepWithBadge: View {
    let spriteSeed: Int
    let systemImage: String
    var spriteScale: CGFloat = 4
    var badgeSize: CGFloat = 20

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PixelArtMenuSheepView(seed: spriteSeed, scale: spriteScale)

            Image(systemName: systemImage)
                .font(.system(size: badgeSize * 0.5, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: badgeSize, height: badgeSize)
                .background(Circle().fill(appAccent))
                .offset(x: 4, y: 4)
        }
    }
}

#Preview {
    ZStack {
        Color(white: 0.12).ignoresSafeArea()
        HStack(spacing: 32) {
            SheepWithBadge(spriteSeed: 0, systemImage: "clock.badge.checkmark", spriteScale: 4, badgeSize: 20)
            SheepWithBadge(spriteSeed: 1, systemImage: "moon.zzz.fill", spriteScale: 6, badgeSize: 26)
        }
    }
    .preferredColorScheme(.dark)
}
