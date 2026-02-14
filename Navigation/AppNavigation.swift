//
//  AppNavigation.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import SwiftUI

enum ActiveScreen: Equatable {
    case farm
    case menu
    case shop
    case goodies
    case sheepBook
    case settings
    case checkIn
    case habitCustomization(habitId: String)
}

@Observable
class AppNavigation {
    var selectedTab: Int = 0
    var activeScreen: ActiveScreen = .farm
    var habitCustomizationReturnTo: ActiveScreen = .settings
    var showCheckInSheet: Bool = false
    var isTutorialActive: Bool = false
    var tutorialStep: Int = 0
    
    // Session-only tutorial steps (no persistence yet)
    let tutorialSteps: [(title: String, message: String)] = [
        (
            "Each sheep is a habit you chose",
            "Take care of them by sticking to your habits. When you keep a habit, that sheep grows healthier."
        ),
        (
            "Check in each morning",
            "Mark how you did for each habit. When you keep a habit, that sheep grows. Miss it and they need care."
        ),
        (
            "Use the tabs",
            "Home shows today’s habits. Progress, Toolkit, and Community are in the tab bar."
        )
    ]
    
    func navigate(to screen: ActiveScreen) {
        activeScreen = screen
    }
    
    func startTutorial() {
        tutorialStep = 0
        isTutorialActive = true
    }
    
    func nextTutorialStep() {
        let next = tutorialStep + 1
        if next < tutorialSteps.count {
            tutorialStep = next
        } else {
            endTutorial()
        }
    }
    
    func endTutorial() {
        isTutorialActive = false
        OnboardingPersistence.hasCompletedTutorial = true
    }
}
