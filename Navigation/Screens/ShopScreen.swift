//
//  ShopScreen.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct ShopScreen: View {
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.8, green: 0.95, blue: 0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                screenHeader(title: "Shop", icon: "🛒")
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Items coming soon...")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.top, 40)
                    }
                    .padding()
                }
            }
        }
    }
    
    @ViewBuilder
    private func screenHeader(title: String, icon: String) -> some View {
        HStack {
            // Close button
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
            
            Spacer()
            
            // Title
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
                Text(icon)
                    .font(.system(size: 28))
            }
            
            Spacer()
            
            // Spacer for balance
            Color.clear.frame(width: 50, height: 50)
        }
        .padding()
        .background(Color.white.opacity(0.5))
    }
}

#Preview {
    ShopScreen(onClose: { })
}

