//
//  SettingsView.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

