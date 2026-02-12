//
//  AuthService.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation
import Combine

class AuthService {
    static let shared = AuthService()
    private let networkService = NetworkService.shared
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private init() {
        loadCurrentUser()
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) -> AnyPublisher<User, NetworkError> {
        if networkService.useMockData {
            return mockLogin(email: email, password: password)
        }
        
        let body = ["email": email, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.decodingError).eraseToAnyPublisher()
        }
        
        return networkService.request(
            endpoint: "/auth/login",
            method: "POST",
            body: jsonData
        )
        .map { (response: AuthResponse) -> User in
            self.saveAuthToken(response.token)
            self.currentUser = response.user
            self.isAuthenticated = true
            self.saveCurrentUser(response.user)
            return response.user
        }
        .eraseToAnyPublisher()
    }
    
    func signUp(name: String, email: String, password: String, studentID: String?) -> AnyPublisher<User, NetworkError> {
        if networkService.useMockData {
            return mockSignUp(name: name, email: email)
        }
        
        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "studentID": studentID ?? ""
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.decodingError).eraseToAnyPublisher()
        }
        
        return networkService.request(
            endpoint: "/auth/signup",
            method: "POST",
            body: jsonData
        )
        .map { (response: AuthResponse) -> User in
            self.saveAuthToken(response.token)
            self.currentUser = response.user
            self.isAuthenticated = true
            self.saveCurrentUser(response.user)
            return response.user
        }
        .eraseToAnyPublisher()
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "currentUser")
        currentUser = nil
        isAuthenticated = false
    }
    
    func resetPassword(email: String) -> AnyPublisher<Bool, NetworkError> {
        if networkService.useMockData {
            return networkService.mockRequest(result: .success(true))
        }
        
        let body = ["email": email]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            return Fail(error: NetworkError.decodingError).eraseToAnyPublisher()
        }
        
        return networkService.request(
            endpoint: "/auth/reset-password",
            method: "POST",
            body: jsonData
        )
        .map { (_: MessageResponse) -> Bool in
            return true
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Token Management
    
    private func saveAuthToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    // MARK: - User Persistence
    
    private func saveCurrentUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    private func loadCurrentUser() {
        guard let data = UserDefaults.standard.data(forKey: "currentUser"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return
        }
        
        if getAuthToken() != nil {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    // MARK: - Mock Data for Development
    
    private func mockLogin(email: String, password: String) -> AnyPublisher<User, NetworkError> {
        let mockUser = User(
            name: "Kassi",
            email: email,
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
        
        let response = AuthResponse(token: "mock_token_12345", user: mockUser)
        
        return networkService.mockRequest(result: .success(response))
            .map { response -> User in
                self.saveAuthToken(response.token)
                self.currentUser = response.user
                self.isAuthenticated = true
                self.saveCurrentUser(response.user)
                return response.user
            }
            .eraseToAnyPublisher()
    }
    
    private func mockSignUp(name: String, email: String) -> AnyPublisher<User, NetworkError> {
        let mockUser = User(
            name: name,
            email: email,
            totalESGScore: 0,
            badges: [],
            studentID: nil,
            faculty: nil
        )
        
        let response = AuthResponse(token: "mock_token_new_user", user: mockUser)
        
        return networkService.mockRequest(result: .success(response))
            .map { response -> User in
                self.saveAuthToken(response.token)
                self.currentUser = response.user
                self.isAuthenticated = true
                self.saveCurrentUser(response.user)
                return response.user
            }
            .eraseToAnyPublisher()
    }
}
