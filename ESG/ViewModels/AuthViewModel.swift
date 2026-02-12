//
//  AuthViewModel.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject{
    
    // login
    
    @Published var email = ""
    @Published var password = ""
    
    // sign up
    
    @Published var signUpName = ""
    @Published var signUpEmail = ""
    @Published var signUpPassword = ""
    @Published var signUpConfirmPassword = ""
    @Published var studentID = ""
    
    // state
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var showPassword = false
    
    // validation
    
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var nameError: String?
    
    // Private
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // init
    
    init(){
        setupBildings()
    }
    
    func setupBildings(){
        authService.$isAuthenticated
            .assign(to: &$isAuthenticated)
    }
    
    func validateEmail(_ email: String) -> Bool{
        let emailRegex = "[A-Z0-9a-z.%+-]+@[A-Z0-9a-z]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let isValid = emailPredicate.evaluate(with:email)
        
        if !isValid{
            emailError = "Please enter a valid email address"
        }
        else{
            emailError = nil
        }
        
        return isValid
    }
    
    func validatePassword(_ password: String) -> Bool{
        let isValid = password.count >= 8
        
        if !isValid {
            passwordError = "Password must be at least 8 characters"
        }
        else{
            passwordError = nil
        }
        
        return isValid
    }
    
    func validateName(_ name: String) -> Bool{
        let isValid = name.count >= 2
        
        if !isValid {
            nameError = "Name must be at least 2 character"
        }
        else{
            nameError = nil
        }
        
        return isValid
    }
    
    func passwordsMatch() -> Bool{
        return signUpPassword == signUpConfirmPassword
    }
    
    // MARK: - Actions
    
    func login(){
        guard validateEmail(email), validatePassword(password) else{
            errorMessage = "Please fill in all the fields correctly"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion{
                    self?.errorMessage = error.message
                }
            }
            receiveValue: {[weak self] user in
                print ("Login successful: \(user.name)")
                self?.isAuthenticated = true
            }
            .store(in: &cancellables)
    }
    
    func signUp(){
        guard validateName(signUpName),
              validateEmail(signUpEmail),
              validatePassword(signUpPassword),
              passwordsMatch() else{
            errorMessage = "Please fill in all the fields correctly"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authService.signUp(
            name: signUpName,
            email: signUpEmail,
            password: signUpPassword,
            studentID: studentID.isEmpty ? nil : studentID
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            
            if case .failure(let error) = completion{
                self?.errorMessage = error.message
            }
        }
        receiveValue: {  [weak self] user in
            print("Sign up successful: \(user.name)")
            self?.isAuthenticated = true
        }
        .store(in: &cancellables)
    }
    
    
    func resetPassword(){
        guard validateEmail(email) else{
            errorMessage = "Please fill in all the fields correctly"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        authService.resetPassword(email:email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.message
                }
            }
        receiveValue: { [weak self] success in
            if success {
                self?.errorMessage = "Check your inbox for a password reset email"
            }
        }
        .store(in: &cancellables)
    }
    
    func logout(){
        authService.logout()
        clearFields()
    }
    
    // MARK: Extra Methods
    
    func clearFields(){
        email = ""
        password = ""
        signUpName = ""
        signUpEmail = ""
        signUpPassword = ""
        signUpConfirmPassword = ""
        studentID = ""
        errorMessage = nil
        emailError = nil
        passwordError = nil
        nameError = nil
    }
    
    func togglePasswordVisibility(){
        showPassword.toggle()
    }
}

