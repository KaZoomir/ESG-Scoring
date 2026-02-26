//
//  Event.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//


import Foundation
import FirebaseFirestore

// MARK: - ESGCategory (unchanged)

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

// MARK: - EventStatus (unchanged)

enum EventStatus: String, Codable {
    case upcoming  = "Upcoming"
    case ongoing   = "Ongoing"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// MARK: - Event
// Added @DocumentID and Firestore-compatible fields to match Android Event.kt
// All existing business logic methods are preserved

struct Event: Codable, Identifiable {
    @DocumentID var id: String?
    
    // Firestore fields — match Android Event.kt exactly
    var title: String
    var description: String
    var date: Date
    var time: String           // "HH:mm" string — same as Android
    var location: String?
    var type: String?          // event type string from Android
    var organizer: String?
    var imageURL: String?
    var registeredUsers: [String: EventUserData]  // studentId → data, mirrors Android
    var roles: [String: RoleDetails]              // roleName  → details, mirrors Android
    
    // Fields used by existing iOS app
    var category: ESGCategory?
    var endDate: Date?
    var points: Int
    var maxParticipants: Int?
    var currentParticipants: Int
    var isOnline: Bool
    var tags: [String]
    var requirements: String?
    var status: EventStatus
    
    // MARK: - Init (kept for EventService mock data)
    init(
        id: String? = nil,
        title: String,
        description: String,
        date: Date,
        time: String = "",
        location: String? = nil,
        type: String? = nil,
        organizer: String? = nil,
        imageURL: String? = nil,
        registeredUsers: [String: EventUserData] = [:],
        roles: [String: RoleDetails] = [:],
        category: ESGCategory? = nil,
        endDate: Date? = nil,
        points: Int = 0,
        maxParticipants: Int? = nil,
        currentParticipants: Int = 0,
        isOnline: Bool = false,
        tags: [String] = [],
        requirements: String? = nil,
        status: EventStatus = .upcoming
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.time = time
        self.location = location
        self.type = type
        self.organizer = organizer
        self.imageURL = imageURL
        self.registeredUsers = registeredUsers
        self.roles = roles
        self.category = category
        self.endDate = endDate
        self.points = points
        self.maxParticipants = maxParticipants
        self.currentParticipants = currentParticipants
        self.isOnline = isOnline
        self.tags = tags
        self.requirements = requirements
        self.status = status
    }
    
    // MARK: - Computed (mirrors Android)
    
    var participantCount: Int {
        registeredUsers.count
    }
    
    var dayNumber: String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }
    
    var monthName: String {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f.string(from: date)
    }
    
    // MARK: - Business Logic (unchanged from original)
    
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

// MARK: - EventUserData (mirrors Android EventUserData.kt)

struct EventUserData: Codable {
    var role: String   = ""
    var points: Int    = 0
    var status: String = "registered"   // registered | approved | rejected | completed
    var criteria: [String: Bool]?
}

// MARK: - RoleDetails (mirrors Android RoleDetails.kt)

struct RoleDetails: Codable {
    var activity: String = ""
    var points: Int      = 0
    var time: String     = ""
    var status: String   = "registered"
}
