//
//  ShopView.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct ShopView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Shop")
                    .font(.largeTitle)
            }
            .navigationTitle("Shop")
        }
    }
}

#Preview {
    ShopView()
}

