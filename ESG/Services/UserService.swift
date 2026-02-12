//
//  UserService.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation
import Combine

class UserService {
    static let shared = UserService()
    private let networkService = NetworkService.shared
    
    private init() {}
    
    // MARK: - User Methods
    
    func fetchUserProfile(userId: String) -> AnyPublisher<User, NetworkError> {
        if networkService.useMockData {
            return mockFetchUserProfile(userId: userId)
        }
        
        return networkService.request(endpoint: "/users/\(userId)")
    }
    
    func updateUserProfile(userId: String, updates: [String: Any]) -> AnyPublisher<User, NetworkError> {
        if networkService.useMockData {
            return mockUpdateUserProfile(userId: userId)
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: updates) else {
            return Fail(error: NetworkError.decodingError).eraseToAnyPublisher()
        }
        
        return networkService.request(
            endpoint: "/users/\(userId)",
            method: "PUT",
            body: jsonData
        )
    }
    
    func fetchLeaderboard(limit: Int = 100) -> AnyPublisher<[Rating], NetworkError> {
        if networkService.useMockData {
            return mockFetchLeaderboard()
        }
        
        return networkService.request(endpoint: "/leaderboard?limit=\(limit)")
    }
    
    func fetchBadges(userId: String) -> AnyPublisher<[Badge], NetworkError> {
        if networkService.useMockData {
            return mockFetchBadges()
        }
        
        return networkService.request(endpoint: "/users/\(userId)/badges")
    }
    
    func fetchShopItems() -> AnyPublisher<[ShopItem], NetworkError> {
        if networkService.useMockData {
            return mockFetchShopItems()
        }
        
        return networkService.request(endpoint: "/shop/items")
    }
    
    func purchaseItem(itemId: String, userId: String) -> AnyPublisher<Bool, NetworkError> {
        if networkService.useMockData {
            return networkService.mockRequest(result: .success(true))
        }
        
        let body = ["userId": userId, "itemId": itemId]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.decodingError).eraseToAnyPublisher()
        }
        
        return networkService.request(
            endpoint: "/shop/purchase",
            method: "POST",
            body: jsonData
        )
        .map { (_: MessageResponse) -> Bool in true }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Mock Data
    
    private func mockFetchUserProfile(userId: String) -> AnyPublisher<User, NetworkError> {
        let user = User(
            id: userId,
            name: "Kassi",
            email: "a_kassiman@kbtu.kz",
            totalESGScore: 450,
            badges: [],
            studentID: "22B030477",
            faculty: "SITE",
            environmentalScore: 150,
            socialScore: 200,
            governanceScore: 100,
            eventsAttended: 12,
            eventsCompleted: 10,
            currentStreak: 5,
            longestStreak: 8
        )
        
        return networkService.mockRequest(result: .success(user))
    }
    
    private func mockUpdateUserProfile(userId: String) -> AnyPublisher<User, NetworkError> {
        return mockFetchUserProfile(userId: userId)
    }
    
    private func mockFetchLeaderboard() -> AnyPublisher<[Rating], NetworkError> {
        let ratings = [
            Rating(userId: "1", userName: "Aru", rank: 1, score: 1250, faculty: "IT", change: 0),
            Rating(userId: "2", userName: "Gaukhar", rank: 2, score: 1180, faculty: "Business", change: 1),
            Rating(userId: "3", userName: "Darkhan", rank: 3, score: 1050, faculty: "Engineering", change: -1),
            Rating(userId: "4", userName: "Kassi", rank: 4, score: 890, faculty: "IT", change: 2),
            Rating(userId: "5", userName: "Dana", rank: 5, score: 845, faculty: "Law", change: 0)
        ]
        
        return networkService.mockRequest(result: .success(ratings))
    }
    
    private func mockFetchBadges() -> AnyPublisher<[Badge], NetworkError> {
        let badges = [
            Badge(title: "First Steps", icon: "star.fill", description: "Join your first event", type: .milestone, pointsRequired: 0, isUnlocked: true, unlockedDate: Date()),
            Badge(title: "Eco Warrior", icon: "leaf.fill", description: "Complete 5 environmental events", type: .environmental, pointsRequired: 250, isUnlocked: true),
            Badge(title: "Social Butterfly", icon: "person.3.fill", description: "Attend 10 social events", type: .social, pointsRequired: 300, isUnlocked: false),
            Badge(title: "Rising Leader", icon: "star.circle.fill", description: "Reach 500 ESG points", type: .milestone, pointsRequired: 500, isUnlocked: false)
        ]
        
        return networkService.mockRequest(result: .success(badges))
    }
    
    private func mockFetchShopItems() -> AnyPublisher<[ShopItem], NetworkError> {
        let items = [
            ShopItem(title: "ESG T-Shirt", cost: 200, description: "Official ESG KBTU T-shirt", category: .merchandise, stockAvailable: 50),
            ShopItem(title: "Library Pass", cost: 150, description: "Extended library access for 1 month", category: .privileges),
            ShopItem(title: "Cafeteria 20% Off", cost: 100, description: "20% discount at campus cafeteria", category: .discounts, validUntil: Date().addingTimeInterval(86400 * 30)),
            ShopItem(title: "Mentor Session", cost: 300, description: "1-on-1 session with a sustainability expert", category: .experiences, stockAvailable: 10)
        ]
        
        return networkService.mockRequest(result: .success(items))
    }
}
