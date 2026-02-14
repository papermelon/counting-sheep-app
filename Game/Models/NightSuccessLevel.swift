//
//  NightSuccessLevel.swift
//  Counting Sheep
//
//  Created by Ngawang Chime on 5/1/26.
//

import Foundation

enum NightSuccessLevel: Int, Codable {
    case zeroStars = 0   // ☆
    case oneStar = 1     // ⭐
    case twoStars = 2    // ⭐⭐
    case threeStars = 3  // ⭐⭐⭐
    
    var displayTitle: String {
        switch self {
        case .threeStars: return "Great night"
        case .twoStars: return "Okay night"
        case .oneStar: return "Slipped"
        case .zeroStars: return "Rough night"
        }
    }
    
    var starsText: String {
        switch self {
        case .threeStars: return "⭐⭐⭐"
        case .twoStars: return "⭐⭐"
        case .oneStar: return "⭐"
        case .zeroStars: return "☆"
        }
    }
}

