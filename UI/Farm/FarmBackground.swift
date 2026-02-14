//
//  FarmBackground.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct FarmBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.53, green: 0.81, blue: 0.92), // Light sky blue
                        Color(red: 0.68, green: 0.85, blue: 0.90)  // Pale blue
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Distant hills
                hillLayer(
                    height: geometry.size.height * 0.25,
                    yOffset: geometry.size.height * 0.35,
                    color: Color(red: 0.6, green: 0.75, blue: 0.55)
                )
                
                // Mid hills
                hillLayer(
                    height: geometry.size.height * 0.2,
                    yOffset: geometry.size.height * 0.45,
                    color: Color(red: 0.55, green: 0.72, blue: 0.48)
                )
                
                // Grass field (main pasture area)
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.48, green: 0.68, blue: 0.38),
                                Color(red: 0.42, green: 0.62, blue: 0.32)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: geometry.size.height * 0.5)
                    .offset(y: geometry.size.height * 0.24)
                
                // Simple fence at bottom
                fenceRow(width: geometry.size.width)
                    .offset(y: geometry.size.height * 0.34)
                
                // Sun
                Circle()
                    .fill(Color(red: 1.0, green: 0.95, blue: 0.7))
                    .frame(width: 60, height: 60)
                    .shadow(color: .yellow.opacity(0.5), radius: 20)
                    .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.1)
                
                // Clouds
                cloudShape()
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.12)
                
                cloudShape()
                    .scaleEffect(0.7)
                    .position(x: geometry.size.width * 0.6, y: geometry.size.height * 0.08)
            }
        }
    }
    
    @ViewBuilder
    private func hillLayer(height: CGFloat, yOffset: CGFloat, color: Color) -> some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geometry.size.height))
                path.addCurve(
                    to: CGPoint(x: geometry.size.width, y: geometry.size.height),
                    control1: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height - height),
                    control2: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height - height * 0.6)
                )
                path.closeSubpath()
            }
            .fill(color)
            .offset(y: yOffset)
        }
    }
    
    @ViewBuilder
    private func fenceRow(width: CGFloat) -> some View {
        HStack(spacing: 24) {
            ForEach(0..<Int(width / 36), id: \.self) { _ in
                fencePost()
            }
        }
    }
    
    @ViewBuilder
    private func fencePost() -> some View {
        VStack(spacing: 0) {
            // Top of post
            Circle()
                .fill(Color(red: 0.45, green: 0.32, blue: 0.18))
                .frame(width: 9, height: 9)
            
            // Post
            Rectangle()
                .fill(Color(red: 0.5, green: 0.38, blue: 0.22))
                .frame(width: 7, height: 42)
        }
    }
    
    @ViewBuilder
    private func cloudShape() -> some View {
        HStack(spacing: -15) {
            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: 40, height: 40)
            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: 55, height: 55)
            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: 35, height: 35)
        }
    }
}

#Preview {
    FarmBackground()
}

