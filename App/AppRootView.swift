//
//  AppRootView.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct AppRootView: View {
    @State private var navigation = AppNavigation()
    @StateObject private var gameState = GameState()
    
    var body: some View {
        ZStack {
            // Layer 1: Farm is ALWAYS rendered underneath
            FarmView()
            
            // Layer 2: Menu button (top-left) - visible on farm or menu
            if navigation.activeScreen == .farm || navigation.activeScreen == .menu {
                VStack {
                    HStack {
                        MenuButton {
                            navigation.openMenu()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Spacer()
                }
            }
            
            // Layer 3: Currency bar (always visible except in full screens)
            if navigation.activeScreen == .farm || navigation.activeScreen == .menu {
                VStack {
                    Spacer()
                    CurrencyBar()
                }
            }
            
            // Layer 4: Modals/Screens overlay
            switch navigation.activeScreen {
            case .farm:
                EmptyView()
                
            case .menu:
                MenuGrid(
                    onSelect: { screen in
                        navigation.navigate(to: screen)
                    },
                    onClose: {
                        navigation.closeToFarm()
                    }
                )
                .transition(.opacity)
                
            case .shop:
                ShopScreen(onClose: { navigation.closeToFarm() })
                    .transition(.move(edge: .trailing))
                
            case .goodies:
                GoodiesScreen(onClose: { navigation.closeToFarm() })
                    .transition(.move(edge: .trailing))
                
            case .sheepBook:
                SheepBookScreen(onClose: { navigation.closeToFarm() })
                    .transition(.move(edge: .trailing))
                
            case .settings:
                SettingsScreen(onClose: { navigation.closeToFarm() })
                    .transition(.move(edge: .trailing))
            }
            
            // Layer 5: Tutorial overlay (highest priority)
            if navigation.isTutorialActive {
                // TutorialOverlay will be added later
                EmptyView()
            }
        }
        .environmentObject(gameState)
        .environment(navigation)
        .animation(.easeInOut(duration: 0.25), value: navigation.activeScreen)
    }
}

#Preview {
    AppRootView()
}
