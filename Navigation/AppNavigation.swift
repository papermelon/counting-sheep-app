//
//  AppNavigation.swift
//  Sheep Atsume
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
}

@Observable
class AppNavigation {
    var activeScreen: ActiveScreen = .farm
    var isTutorialActive: Bool = false
    var tutorialStep: Int = 0
    
    // Session-only tutorial steps (no persistence yet)
    let tutorialSteps: [(title: String, message: String)] = [
        (
            "Welcome to Counting Sheep",
            "Nightly check-ins keep your flock rested. Great/Okay/Slipped/Bad give +10/+6/+2/+0 coins."
        ),
        (
            "Grow your streak",
            "Higher streak → more sheep appear on your farm. Miss a night and the streak resets."
        ),
        (
            "Open the Menu",
            "Use the Menu to reach Shop, Goodies, Sheep Book, and Settings."
        )
    ]
    
    func openMenu() {
        activeScreen = .menu
    }
    
    func closeToFarm() {
        activeScreen = .farm
    }
    
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
    }
}
