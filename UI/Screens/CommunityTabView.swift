//
//  CommunityTabView.swift
//  Sheep Atsume
//

import SwiftUI

struct CommunityTabView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.white.opacity(0.4))
                    Text("Coming soon")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Text("Form accountability pacts with friends to stay on track with your sleep habits.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("Community")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color(white: 0.08), for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
        }
    }
}

#Preview {
    CommunityTabView()
}
