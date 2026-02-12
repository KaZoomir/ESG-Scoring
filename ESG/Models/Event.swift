//
//  Event.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation

enum ESGCategory: String, Codable, CaseIterable {
    case environmental = "Environmental"
    case social = "Social"
    case governance = "Governance"
    
    var color: String {
        switch self {
        case .environmental: return "greenPrimary"
        case .social: return "bluePrimary"
        case .governance: return "purplePrimary"
        }
    }
    
    var icon: String {
        switch self {
        case .environmental: return "leaf.fill"
        case .social: return "person.3.fill"
        case .governance: return "building.columns.fill"
        }
    }
}

enum EventStatus: String, Codable {
    case upcoming = "Upcoming"
    case ongoing = "Ongoing"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

struct Event: Codable, Identifiable {
    let id: String
    var title: String
    var category: ESGCategory
    var date: Date
    var endDate: Date?
    var points: Int
    var description: String
    var location: String?
    var organizer: String?
    var imageURL: String?
    var maxParticipants: Int?
    var currentParticipants: Int
    var isOnline: Bool
    var tags: [String]
    var requirements: String?
    var status: EventStatus
    
    init(
        id: String = UUID().uuidString,
        title: String,
        category: ESGCategory,
        date: Date,
        endDate: Date? = nil,
        points: Int,
        description: String,
        location: String? = nil,
        organizer: String? = nil,
        imageURL: String? = nil,
        maxParticipants: Int? = nil,
        currentParticipants: Int = 0,
        isOnline: Bool = false,
        tags: [String] = [],
        requirements: String? = nil,
        status: EventStatus = .upcoming
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.date = date
        self.endDate = endDate
        self.points = points
        self.description = description
        self.location = location
        self.organizer = organizer
        self.imageURL = imageURL
        self.maxParticipants = maxParticipants
        self.currentParticipants = currentParticipants
        self.isOnline = isOnline
        self.tags = tags
        self.requirements = requirements
        self.status = status
    }
    
    // Business logic
    func isFull() -> Bool {
        guard let max = maxParticipants else { return false }
        return currentParticipants >= max
    }
    
    func canJoin() -> Bool {
        return status == .upcoming && !isFull() && date > Date()
    }
    
    func timeUntilEvent() -> String {
        let interval = date.timeIntervalSince(Date())
        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
        
        if days > 0 {
            return "\(days) day(s)"
        } else if hours > 0 {
            return "\(hours) hour(s)"
        } else {
            return "Starting soon"
        }
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy • HH:mm"
        return formatter.string(from: date)
    }
}
