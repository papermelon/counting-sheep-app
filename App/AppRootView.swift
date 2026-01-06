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
    @State private var didStartTutorial = false
    
    var body: some View {
        ZStack {
            // Layer 1: Farm is ALWAYS rendered underneath
            FarmView()
            
            // Layer 1.5: Status card (top-left under menu)
            if navigation.activeScreen == .farm || navigation.activeScreen == .menu {
                VStack(alignment: .leading) {
                    HStack {
                        MenuButton {
                            navigation.openMenu()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    farmStatusCard
                        .padding(.leading, 16)
                        .padding(.top, 8)
                    
                    Spacer()
                }
            }
            
            // Layer 2: Menu button (top-left) - visible on farm or menu
            // (covered by the status card stack above)
            
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
                
            case .checkIn:
                MorningCheckInScreen(onClose: { navigation.closeToFarm() })
                    .transition(.move(edge: .trailing))
            }
            
            // Layer 5: Tutorial overlay (highest priority)
            if navigation.isTutorialActive {
                if navigation.tutorialStep < navigation.tutorialSteps.count {
                    let step = navigation.tutorialSteps[navigation.tutorialStep]
                    TutorialOverlay(
                        title: step.title,
                        message: step.message,
                        isLast: navigation.tutorialStep == navigation.tutorialSteps.count - 1,
                        onNext: { navigation.nextTutorialStep() },
                        onSkip: { navigation.endTutorial() }
                    )
                }
            }
        }
        .environmentObject(gameState)
        .environment(navigation)
        .animation(.easeInOut(duration: 0.25), value: navigation.activeScreen)
        .onAppear {
            if !didStartTutorial {
                navigation.startTutorial()
                didStartTutorial = true
            }
            
            // Auto-prompt daily check-in when opening the app
            if navigation.activeScreen == .farm && gameState.needsCheckInToday() {
                navigation.navigate(to: .checkIn)
            }
        }
    }
}

#Preview {
    AppRootView()
}

// MARK: - Farm Status Card
private extension AppRootView {
    var farmStatusCard: some View {
        let result = gameState.lastNightResult?.level
        let (title, desc, delta) = statusText(for: result)
        
        return VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(red: 0.32, green: 0.24, blue: 0.16))
            
            Text(desc)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Label("\(gameState.streak)", systemImage: "flame.fill")
                    .labelStyle(.titleAndIcon)
                    .font(.footnote)
                    .foregroundStyle(Color.orange)
                
                if let delta = delta {
                    Label("+\(delta) coins", systemImage: "plus.circle.fill")
                        .labelStyle(.titleAndIcon)
                        .font(.footnote)
                        .foregroundStyle(Color.green)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(red: 0.86, green: 0.78, blue: 0.65), lineWidth: 1)
        )
        .frame(maxWidth: 240, alignment: .leading)
    }
    
    func statusText(for level: NightSuccessLevel?) -> (String, String, Int?) {
        switch level {
        case .threeStars:
            return ("Great night ⭐⭐⭐", "Your sheep are well-rested.", 10)
        case .twoStars:
            return ("Okay night ⭐⭐", "A decent night for the flock.", 6)
        case .oneStar:
            return ("Slipped ⭐", "Some sheep wandered last night.", 2)
        case .zeroStars:
            return ("Rough night ☆", "A new day begins.", 0)
        case .none:
            return ("Welcome", "Check in nightly to grow your streak and earn coins.", nil)
        }
    }
}
