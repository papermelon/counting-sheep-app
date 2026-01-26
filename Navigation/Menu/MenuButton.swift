//
//  MenuButton.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct MenuButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                // Sheep icon
                Text("🐑")
                    .font(.system(size: 24))
                
                Text("Menu")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color(red: 0.4, green: 0.3, blue: 0.2))
            }
            .frame(width: 56, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.95, green: 0.85, blue: 0.6))
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 1, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.7, green: 0.55, blue: 0.35), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.green.opacity(0.3)
        MenuButton { }
    }
}

