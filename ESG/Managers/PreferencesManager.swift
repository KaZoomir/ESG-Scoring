//
//  PreferencesManager.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.20.
//

import Foundation
import Combine

class PreferencesManager {
    static let shared = PreferencesManager()
    
    private let userDefaults = UserDefaults.standard
    
    // Keys
    private enum Keys {
        static let rememberMe = "rememberMe"
        static let jwtToken = "jwtToken"
        static let userId = "userId"
        static let userEmail = "userEmail"
    }
    
    private init() {}
    
    // MARK: - Remember Me State
    
    func saveRememberState(_ remember: Bool) {
        userDefaults.set(remember, forKey: Keys.rememberMe)
    }
    
    func getRememberState() -> AnyPublisher<Bool, Never> {
        let remember = userDefaults.bool(forKey: Keys.rememberMe)
        return Just(remember).eraseToAnyPublisher()
    }
    
    func getRememberStateSync() -> Bool {
        return userDefaults.bool(forKey: Keys.rememberMe)
    }
    
    // MARK: - JWT Token Management
    
    func saveJwt(_ token: String) {
        // For production, use Keychain instead of UserDefaults
        userDefaults.set(token, forKey: Keys.jwtToken)
    }
    
    func getJwt() -> String? {
        return userDefaults.string(forKey: Keys.jwtToken)
    }
    
    func clearJwt() {
        userDefaults.removeObject(forKey: Keys.jwtToken)
    }
    
    // MARK: - User Data
    
    func saveUserId(_ userId: String) {
        userDefaults.set(userId, forKey: Keys.userId)
    }
    
    func getUserId() -> String? {
        return userDefaults.string(forKey: Keys.userId)
    }
    
    func saveUserEmail(_ email: String) {
        userDefaults.set(email, forKey: Keys.userEmail)
    }
    
    func getUserEmail() -> String? {
        return userDefaults.string(forKey: Keys.userEmail)
    }
    
    // MARK: - Clear All
    
    func clearAll() {
        userDefaults.removeObject(forKey: Keys.rememberMe)
        userDefaults.removeObject(forKey: Keys.jwtToken)
        userDefaults.removeObject(forKey: Keys.userId)
        userDefaults.removeObject(forKey: Keys.userEmail)
    }
}

// MARK: - Keychain Helper (for Production)

/// Use this for secure JWT storage in production
class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        
        return nil
    }
    
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
