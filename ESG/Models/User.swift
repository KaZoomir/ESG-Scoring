//
//  User.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
    var totalESGScore: Int
    var badges: [Badge]
    var avatar: String?
    var studentID: String?
    var faculty: String?
    var joinedDate: Date
    
    // ESG Score breakdown
    var environmentalScore: Int
    var socialScore: Int
    var governanceScore: Int
    
    // Statistics
    var eventsAttended: Int
    var eventsCompleted: Int
    var currentStreak: Int
    var longestStreak: Int
    
    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        totalESGScore: Int = 0,
        badges: [Badge] = [],
        avatar: String? = nil,
        studentID: String? = nil,
        faculty: String? = nil,
        joinedDate: Date = Date(),
        environmentalScore: Int = 0,
        socialScore: Int = 0,
        governanceScore: Int = 0,
        eventsAttended: Int = 0,
        eventsCompleted: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.totalESGScore = totalESGScore
        self.badges = badges
        self.avatar = avatar
        self.studentID = studentID
        self.faculty = faculty
        self.joinedDate = joinedDate
        self.environmentalScore = environmentalScore
        self.socialScore = socialScore
        self.governanceScore = governanceScore
        self.eventsAttended = eventsAttended
        self.eventsCompleted = eventsCompleted
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
    }
    
    // Business logic
    func getUserLevel() -> String {
        switch totalESGScore {
        case 0..<100: return "Beginner"
        case 100..<300: return "Activist"
        case 300..<600: return "Champion"
        case 600..<1000: return "Leader"
        default: return "Legend"
        }
    }
    
    func getProgressToNextLevel() -> Double {
        let levels = [0, 100, 300, 600, 1000, 2000]
        for i in 0..<levels.count - 1 {
            if totalESGScore < levels[i + 1] {
                let current = totalESGScore - levels[i]
                let total = levels[i + 1] - levels[i]
                return Double(current) / Double(total)
            }
        }
        return 1.0
    }
}
