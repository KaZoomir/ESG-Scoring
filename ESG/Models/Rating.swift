//
//  Rating.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation

struct Rating: Codable, Identifiable {
    let id: String
    let userId: String
    var userName: String
    var userAvatar: String?
    var rank: Int
    var score: Int
    var faculty: String?
    var change: Int? // Position change from previous period
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        userName: String,
        userAvatar: String? = nil,
        rank: Int,
        score: Int,
        faculty: String? = nil,
        change: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userAvatar = userAvatar
        self.rank = rank
        self.score = score
        self.faculty = faculty
        self.change = change
    }
    
    func getRankBadge() -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
}
