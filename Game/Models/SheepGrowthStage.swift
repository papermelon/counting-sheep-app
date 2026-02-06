//
//  SheepGrowthStage.swift
//  Sheep Atsume
//
//  Created by Ngawang Chime on 5/1/26.
//

import Foundation

enum SheepGrowthStage: String, Codable, CaseIterable {
    case needsCare
    case growing
    case thriving

    var displayName: String {
        switch self {
        case .needsCare: return "Needs care"
        case .growing: return "Growing"
        case .thriving: return "Thriving"
        }
    }
}
