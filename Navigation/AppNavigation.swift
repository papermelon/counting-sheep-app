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
}

@Observable
class AppNavigation {
    var activeScreen: ActiveScreen = .farm
    var isTutorialActive: Bool = false
    var tutorialStep: Int = 0
    
    func openMenu() {
        activeScreen = .menu
    }
    
    func closeToFarm() {
        activeScreen = .farm
    }
    
    func navigate(to screen: ActiveScreen) {
        activeScreen = screen
    }
}
