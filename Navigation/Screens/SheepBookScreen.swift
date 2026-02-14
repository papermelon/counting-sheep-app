//
//  SheepBookScreen.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct SheepBookScreen: View {
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 1.0, green: 0.85, blue: 0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                screenHeader(title: "Sheep Book", icon: "🐑")
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Your sheep collection will appear here...")
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
    SheepBookScreen(onClose: { })
}

