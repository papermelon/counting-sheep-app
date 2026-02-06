//
//  AppRootView.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

struct AppRootView: View {
    @AppStorage(OnboardingPersistence.hasCompletedKey) private var hasCompletedOnboarding = false
    @State private var navigation = AppNavigation()
    @StateObject private var gameState = GameState()
    @State private var didStartTutorial = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainContent
            } else {
                OnboardingFlowView(onComplete: {
                    applyOnboardingToGameState()
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if hasCompletedOnboarding {
                Color.clear
            } else {
                Color.black
            }
        }
        .ignoresSafeArea()
        .environmentObject(gameState)
        .environment(navigation)
    }

    private var mainContent: some View {
        ZStack {
            Group {
                switch navigation.selectedTab {
                case 1: ProgressTabView().environmentObject(gameState)
                case 2: ToolkitTabView()
                case 3: CommunityTabView()
                default: HomeTabView().environmentObject(gameState)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                tabBar
            }

            // Full-screen overlays when navigation requests them (e.g. habit customization from Settings)
            if case .habitCustomization(let habitId) = navigation.activeScreen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { navigation.navigate(to: navigation.habitCustomizationReturnTo) }
                HabitCustomizationScreen(
                    habitId: habitId,
                    onSave: { gameState.syncSettingsToStorage() },
                    onClose: { navigation.navigate(to: navigation.habitCustomizationReturnTo) }
                )
                .environmentObject(gameState)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.move(edge: .trailing))
            }

        }
        .animation(.easeInOut(duration: 0.25), value: navigation.activeScreen)
        .onAppear {
            if !didStartTutorial {
                didStartTutorial = true
            }
            seedHabitSheepFromOnboardingIfNeeded()
            NotificationScheduler.requestAuthorization { granted in
                if granted && gameState.notificationsEnabled {
                    NotificationScheduler.scheduleBedtimeAndMorning(
                        bedtimeStart: gameState.bedtimeStart,
                        bedtimeEnd: gameState.bedtimeEnd,
                        enabled: true
                    )
                }
            }
            if gameState.hasAnyVerifiedScreenHabit {
                ScreenTimeService.shared.startMonitoring(
                    bedtimeStart: gameState.bedtimeStart,
                    bedtimeEnd: gameState.bedtimeEnd
                )
            }
        }
        .onChange(of: gameState.verifiedScreenHabitIds.sorted().joined(separator: ",")) { _, _ in
            if gameState.hasAnyVerifiedScreenHabit {
                ScreenTimeService.shared.startMonitoring(
                    bedtimeStart: gameState.bedtimeStart,
                    bedtimeEnd: gameState.bedtimeEnd
                )
            } else {
                ScreenTimeService.shared.stopMonitoring()
            }
        }
        .onChange(of: gameState.bedtimeStart) { _, _ in
            if gameState.hasAnyVerifiedScreenHabit {
                ScreenTimeService.shared.startMonitoring(
                    bedtimeStart: gameState.bedtimeStart,
                    bedtimeEnd: gameState.bedtimeEnd
                )
            }
        }
        .onChange(of: gameState.bedtimeEnd) { _, _ in
            if gameState.hasAnyVerifiedScreenHabit {
                ScreenTimeService.shared.startMonitoring(
                    bedtimeStart: gameState.bedtimeStart,
                    bedtimeEnd: gameState.bedtimeEnd
                )
            }
        }
        .sheet(isPresented: $navigation.showCheckInSheet) {
            MorningCheckInScreen(onClose: { navigation.showCheckInSheet = false })
                .environmentObject(gameState)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabBarItem(index: 0, icon: "house.fill", label: "Home")
            tabBarItem(index: 1, icon: "chart.line.uptrend.xyaxis", label: "Progress")
            tabBarItem(index: 2, icon: "wrench.and.screwdriver.fill", label: "Toolkit")
            tabBarItem(index: 3, icon: "person.3.fill", label: "Community")
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(Color(white: 0.06).ignoresSafeArea(edges: .bottom))
    }

    private func tabBarItem(index: Int, icon: String, label: String) -> some View {
        let selected = navigation.selectedTab == index
        return Button {
            navigation.selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(selected ? .white : .secondary)
        }
        .buttonStyle(.plain)
    }

    private func applyOnboardingToGameState() {
        guard let answers = OnboardingPersistence.loadAnswers() else { return }
        if let bedtime = answers.typicalBedtime {
            gameState.bedtimeStart = bedtime
        }
        seedHabitSheepFromOnboardingIfNeeded()
        gameState.syncSettingsToStorage()
    }

    private func seedHabitSheepFromOnboardingIfNeeded() {
        guard gameState.habitSheep.isEmpty,
              let answers = OnboardingPersistence.loadAnswers() else { return }
        let list = answers.selectedHabitIds.compactMap { id -> HabitSheep? in
            guard let h = SleepHabit.all.first(where: { $0.id == id }) else { return nil }
            return HabitSheep(habitId: h.id, title: h.title, systemImage: h.systemImage)
        }
        gameState.habitSheep = list.isEmpty ? [defaultHabitSheep] : list
        gameState.syncSettingsToStorage()
    }

    private var defaultHabitSheep: HabitSheep {
        HabitSheep(habitId: "default", title: "Sleep well", systemImage: "moon.zzz.fill")
    }
}

#Preview {
    AppRootView()
}
