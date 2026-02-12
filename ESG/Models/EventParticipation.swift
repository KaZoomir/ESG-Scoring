//
//  EventParticipation.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation

struct EventParticipation: Codable, Identifiable {
    let id: String
    let userId: String
    let eventId: String
    var event: Event?
    var status: ParticipationStatus
    var registrationDate: Date
    var completionDate: Date?
    var pointsEarned: Int?
    var feedback: String?
    var rating: Int? // 1-5 stars
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        eventId: String,
        event: Event? = nil,
        status: ParticipationStatus = .registered,
        registrationDate: Date = Date(),
        completionDate: Date? = nil,
        pointsEarned: Int? = nil,
        feedback: String? = nil,
        rating: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.eventId = eventId
        self.event = event
        self.status = status
        self.registrationDate = registrationDate
        self.completionDate = completionDate
        self.pointsEarned = pointsEarned
        self.feedback = feedback
        self.rating = rating
    }
}

enum ParticipationStatus: String, Codable {
    case registered = "Registered"
    case attended = "Attended"
    case completed = "Completed"
    case missed = "Missed"
    case cancelled = "Cancelled"
}
