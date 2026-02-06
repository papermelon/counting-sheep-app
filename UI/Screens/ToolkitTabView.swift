//
//  ToolkitTabView.swift
//  Sheep Atsume
//

import SwiftUI

struct ToolkitTabView: View {
    private let placeholderItems: [(title: String, icon: String)] = [
        ("Yoga nidra", "figure.mind.and.body"),
        ("Guided sleep stories", "moon.zzz.fill"),
        ("Wind-down sounds", "waveform"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                List {
                    Section {
                        ForEach(placeholderItems, id: \.title) { item in
                            HStack(spacing: 16) {
                                Image(systemName: item.icon)
                                    .font(.title2)
                                    .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
                                    .frame(width: 44, height: 44)
                                    .background(Circle().fill(Color.white.opacity(0.12)))
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            .listRowBackground(Color.white.opacity(0.08))
                            .listRowSeparatorTint(.white.opacity(0.2))
                        }
                    } header: {
                        Text("Sleep resources")
                            .foregroundStyle(.secondary)
                    } footer: {
                        Text("Curated audio and guides coming soon.")
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Toolkit")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color(white: 0.08), for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
        }
    }
}

#Preview {
    ToolkitTabView()
}
