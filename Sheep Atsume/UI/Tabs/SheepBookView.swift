//
//  SheepBookView.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct SheepBookView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Sheep Book")
                    .font(.largeTitle)
            }
            .navigationTitle("Sheep Book")
        }
    }
}

#Preview {
    SheepBookView()
}

