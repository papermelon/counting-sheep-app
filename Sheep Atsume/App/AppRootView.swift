//
//  AppRootView.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct AppRootView: View {
    var body: some View {
        TabView {
            FarmTabView()
                .tabItem {
                    Label("Farm", systemImage: "house")
                }
            
            ShopView()
                .tabItem {
                    Label("Shop", systemImage: "cart")
                }
            
            SheepBookView()
                .tabItem {
                    Label("Sheep Book", systemImage: "book")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    AppRootView()
}

