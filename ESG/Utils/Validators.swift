//
//  Validators.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.17.
//

import Foundation

struct Validators{
    static func isValidEmail(_ email: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return emailPredicate.evaluate(with: email)
    }
    static func isValidPassword(_ password: String) -> (isValid: Bool, message: String?) {
            guard password.count >= AppConfig.minPasswordLength else {
                return (false, "Password must be at least \(AppConfig.minPasswordLength) characters")
            }
            
            return (true, nil)
    }
    
    static func isValidName(_ name: String) -> (isValid: Bool, message: String?) {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !trimmed.isEmpty else {
                return (false, "Name cannot be empty")
            }
            
            guard trimmed.count >= 2 else {
                return (false, "Name must be at least 2 characters")
            }
            
            return (true, nil)
        }
    
    
    static func isValidStudentID(_ id: String) -> Bool {
            let pattern = "^\\d{2}[A-Z]\\d{7}$" // Example: 22B030477
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: id)
        }
    
    static func isValidPhoneNumber(_ phone: String) -> Bool {
           let phoneRegex = "^[+]?[0-9]{10,15}$"
           let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
           return phonePredicate.evaluate(with: phone)
    }
}


struct ErrorMessages {
    static let genericError = "Something went wrong. Please try again."
    static let networkError = "Network error. Please check your connection."
    static let authenticationError = "Authentication failed. Please log in again."
    static let validationError = "Please check your input and try again."
    static let serverError = "Server error. Please try again later."
}


