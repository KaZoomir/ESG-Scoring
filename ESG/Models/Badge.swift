//
//  Badge.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation

struct Badge: Codable, Identifiable {
    let id: String
    var title: String
    var icon: String
    var description: String
    var type: BadgeType
    var pointsRequired: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        icon: String,
        description: String,
        type: BadgeType,
        pointsRequired: Int,
        isUnlocked: Bool = false,
        unlockedDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.description = description
        self.type = type
        self.pointsRequired = pointsRequired
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}

enum BadgeType: String, Codable {
    case environmental = "Environmental"
    case social = "Social"
    case governance = "Governance"
    case special = "Special"
    case milestone = "Milestone"
}
