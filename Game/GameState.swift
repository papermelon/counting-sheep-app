//
//  GameState.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import Foundation
import Combine

class GameState: ObservableObject {
    @Published var coins: Int
    @Published var streak: Int
    @Published var lastNightResult: NightResult?
    var sheepCount: Int
    
    init(
        coins: Int = 0,
        streak: Int = 0,
        lastNightResult: NightResult? = nil,
        sheepCount: Int = 0
    ) {
        self.coins = coins
        self.streak = streak
        self.lastNightResult = lastNightResult
        self.sheepCount = sheepCount
    }
    
    func logNight(level: NightSuccessLevel) {
        let result = NightResult(date: Date(), level: level)
        lastNightResult = result
        
        if level.rawValue >= NightSuccessLevel.okay.rawValue {
            streak += 1
        } else {
            streak = 0
        }
        
        switch level {
        case .great:
            coins += 10
        case .okay:
            coins += 6
        case .slipped:
            coins += 2
        case .bad:
            break
        }
    }
}

