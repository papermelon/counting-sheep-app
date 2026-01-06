//
//  FarmTabView.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct FarmTabView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Farm")
                    .font(.largeTitle)
            }
            .navigationTitle("Farm")
        }
    }
}

#Preview {
    FarmTabView()
}

