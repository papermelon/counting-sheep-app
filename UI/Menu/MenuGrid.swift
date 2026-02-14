//
//  MenuGrid.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct MenuGrid: View {
    let onSelect: (ActiveScreen) -> Void
    let onClose: () -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            VStack(spacing: 0) {
                // Close button
                HStack {
                    closeButton
                    Spacer()
                }
                .padding(.bottom, 12)
                
                // Menu grid
                LazyVGrid(columns: columns, spacing: 16) {
                    menuItem(icon: "🕑", label: "Check-in", screen: .checkIn)
                    menuItem(icon: "🐑", label: "Sheep", screen: .sheepBook)
                    menuItem(icon: "🛒", label: "Shop", screen: .shop)
                    menuItem(icon: "📦", label: "Goodies", screen: .goodies)
                    menuItem(icon: "⚙️", label: "Settings", screen: .settings)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 1.0, green: 0.97, blue: 0.9))
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.8, green: 0.7, blue: 0.5), lineWidth: 3)
            )
            .padding(.horizontal, 40)
        }
    }
    
    private var closeButton: some View {
        Button(action: onClose) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.95, green: 0.85, blue: 0.6))
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 0.7, green: 0.55, blue: 0.35), lineWidth: 2)
                    )
                
                VStack(spacing: 2) {
                    Text("✕")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(red: 0.5, green: 0.35, blue: 0.2))
                    Text("Close")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(Color(red: 0.5, green: 0.35, blue: 0.2))
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func menuItem(icon: String, label: String, screen: ActiveScreen) -> some View {
        Button {
            onSelect(screen)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(colorForScreen(screen))
                        .frame(width: 70, height: 70)
                    
                    Text(icon)
                        .font(.system(size: 32))
                }
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(red: 0.4, green: 0.3, blue: 0.2))
            }
        }
        .buttonStyle(.plain)
    }
    
    private func colorForScreen(_ screen: ActiveScreen) -> Color {
        switch screen {
        case .checkIn:
            return Color(red: 0.9, green: 0.9, blue: 1.0) // soft blue
        case .sheepBook:
            return Color(red: 1.0, green: 0.85, blue: 0.9) // Pink
        case .shop:
            return Color(red: 0.8, green: 0.95, blue: 0.85) // Mint
        case .goodies:
            return Color(red: 1.0, green: 0.95, blue: 0.75) // Yellow
        case .settings:
            return Color(red: 1.0, green: 0.9, blue: 0.75) // Orange tint
        default:
            return Color(red: 0.9, green: 0.9, blue: 0.9)
        }
    }
}

#Preview {
    MenuGrid(onSelect: { _ in }, onClose: { })
}

