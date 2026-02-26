//
//  Project.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.26.
//

import Foundation
import FirebaseFirestore

// MARK: - Project (mirrors Android Project.kt)

struct Project: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var responseLink: String
    var creator: String
    var liked: [String]     // array of UIDs
    var createdAt: Date
    
    init(
        id: String? = nil,
        name: String = "",
        description: String = "",
        responseLink: String = "",
        creator: String = "",
        liked: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.responseLink = responseLink
        self.creator = creator
        self.liked = liked
        self.createdAt = createdAt
    }
    
    func isLikedBy(userId: String) -> Bool {
        liked.contains(userId)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm d MMM"
        return formatter.string(from: createdAt)
    }
}

enum HomeTab: String, CaseIterable, Identifiable{
    case all = "All"
    case live = "Live"
    case events = "Events"
    case projects = "Projects"
    
    var id: String {rawValue}
}
