//
//  EventService.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation
import Combine

class EventService {
    static let shared = EventService()
    private let networkService = NetworkService.shared
    
    private init() {}
    
    // MARK: - Event Methods
    
    func fetchEvents(category: ESGCategory? = nil) -> AnyPublisher<[Event], NetworkError> {
        if networkService.useMockData {
            return mockFetchEvents(category: category)
        }
        
        var endpoint = "/events"
        if let category = category {
            endpoint += "?category=\(category.rawValue)"
        }
        
        return networkService.request(endpoint: endpoint)
    }
    
    func fetchEventDetails(eventId: String) -> AnyPublisher<Event, NetworkError> {
        if networkService.useMockData {
            return mockFetchEventDetails(eventId: eventId)
        }
        
        return networkService.request(endpoint: "/events/\(eventId)")
    }
    
    func joinEvent(eventId: String, userId: String) -> AnyPublisher<EventParticipation, NetworkError> {
        if networkService.useMockData {
            return mockJoinEvent(eventId: eventId, userId: userId)
        }
        
        let body = ["userId": userId, "eventId": eventId]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.decodingError).eraseToAnyPublisher()
        }
        
        return networkService.request(
            endpoint: "/events/\(eventId)/join",
            method: "POST",
            body: jsonData
        )
    }
    
    func fetchUserEvents(userId: String) -> AnyPublisher<[EventParticipation], NetworkError> {
        if networkService.useMockData {
            return mockFetchUserEvents(userId: userId)
        }
        
        return networkService.request(endpoint: "/users/\(userId)/events")
    }
    
    // MARK: - Mock Data
    
    private func mockFetchEvents(category: ESGCategory?) -> AnyPublisher<[Event], NetworkError> {
        var events = [
            Event(
                title: "Campus Clean-Up Day",
                category: .environmental,
                date: Date().addingTimeInterval(86400 * 3),
                points: 50,
                description: "Join us for a campus-wide clean-up initiative. Bring gloves and help make our university greener!",
                location: "Main Campus",
                organizer: "Green Club",
                maxParticipants: 50,
                currentParticipants: 23,
                tags: ["cleaning", "outdoor", "teamwork"]
            ),
            Event(
                title: "Mental Health Workshop",
                category: .social,
                date: Date().addingTimeInterval(86400 * 5),
                points: 30,
                description: "Learn about mental health awareness and stress management techniques.",
                location: "Conference Hall A",
                organizer: "Student Welfare",
                maxParticipants: 100,
                currentParticipants: 67,
                tags: ["workshop", "wellness", "learning"]
            ),
            Event(
                title: "Student Council Elections",
                category: .governance,
                date: Date().addingTimeInterval(86400 * 7),
                points: 40,
                description: "Participate in the democratic process of selecting your student representatives.",
                location: "Online",
                organizer: "Student Council",
                isOnline: true,
                tags: ["voting", "democracy", "leadership"]
            ),
            Event(
                title: "Tree Planting Initiative",
                category: .environmental,
                date: Date().addingTimeInterval(86400 * 10),
                points: 60,
                description: "Plant trees around campus and contribute to carbon offset goals.",
                location: "Campus Gardens",
                organizer: "Eco Warriors",
                maxParticipants: 30,
                currentParticipants: 15,
                tags: ["nature", "planting", "environment"]
            ),
            Event(
                title: "Charity Fundraiser",
                category: .social,
                date: Date().addingTimeInterval(86400 * 14),
                points: 45,
                description: "Raise funds for local orphanages through a bake sale and entertainment.",
                location: "Student Center",
                organizer: "Charity Club",
                tags: ["charity", "community", "fundraising"]
            )
        ]
        
        if let category = category {
            events = events.filter { $0.category == category }
        }
        
        return networkService.mockRequest(result: .success(events))
    }
    
    private func mockFetchEventDetails(eventId: String) -> AnyPublisher<Event, NetworkError> {
        let event = Event(
            id: eventId,
            title: "Campus Clean-Up Day",
            category: .environmental,
            date: Date().addingTimeInterval(86400 * 3),
            points: 50,
            description: "Join us for a campus-wide clean-up initiative. Help make our university cleaner and greener!",
            location: "Main Campus",
            organizer: "Green Club",
            maxParticipants: 50,
            currentParticipants: 23,
            tags: ["cleaning", "outdoor", "teamwork"],
            requirements: "Bring your own gloves and water bottle"
        )
        
        return networkService.mockRequest(result: .success(event))
    }
    
    private func mockJoinEvent(eventId: String, userId: String) -> AnyPublisher<EventParticipation, NetworkError> {
        let participation = EventParticipation(
            userId: userId,
            eventId: eventId,
            status: .registered
        )
        
        return networkService.mockRequest(result: .success(participation))
    }
    
    private func mockFetchUserEvents(userId: String) -> AnyPublisher<[EventParticipation], NetworkError> {
        let participations = [
            EventParticipation(
                userId: userId,
                eventId: "1",
                status: .completed,
                completionDate: Date().addingTimeInterval(-86400 * 7),
                pointsEarned: 50
            ),
            EventParticipation(
                userId: userId,
                eventId: "2",
                status: .registered
            )
        ]
        
        return networkService.mockRequest(result: .success(participations))
    }
}
