//
//  AuthViewModel.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//
import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // Login fields
    @Published var email = ""
    @Published var password = ""
    @Published var rememberMe = false
    
    // Sign Up fields
    @Published var signUpFullName = ""
    @Published var signUpEmail = ""
    @Published var signUpPassword = ""
    @Published var signUpConfirmPassword = ""
    @Published var signUpStudentID = ""
    
    // UI State (mirrors Kotlin AuthState)
    @Published var uiState = AuthState()
    
    // Navigation flags
    @Published var navigateToMain = false
    @Published var navigateToLogin = false
    
    // User data
    @Published var fullName: String = ""
    
    // Password visibility
    @Published var showPassword = false
    
    // Validation errors
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var nameError: String?
    
    // MARK: - Private Properties
    
    private let auth: Auth
    private let firestore: Firestore
    private let preferencesManager: PreferencesManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        auth: Auth = Auth.auth(),
        firestore: Firestore = Firestore.firestore(),
        preferencesManager: PreferencesManager = PreferencesManager.shared
    ) {
        self.auth = auth
        self.firestore = firestore
        self.preferencesManager = preferencesManager
        
        setupBindings()
        fetchUserFullName()
    }
    
    private func setupBindings() {
        // Monitor authentication state
        NotificationCenter.default.publisher(for: NSNotification.Name("AuthStateDidChange"))
            .sink { [weak self] _ in
                self?.fetchUserFullName()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Fetch User Data
    
    private func fetchUserFullName() {
        guard let userId = auth.currentUser?.uid else { return }
        
        firestore.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                print("❌ Failed to fetch full name: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data(),
               let fullName = data["fullName"] as? String {
                DispatchQueue.main.async {
                    self?.fullName = fullName
                }
            } else {
                DispatchQueue.main.async {
                    self?.fullName = "Unknown User"
                }
            }
        }
    }
    
    // MARK: - Sign Up with Email
    
    func signUpWithEmail(email: String, password: String, studentId: String, fullName: String) {
        // Update loading state
        uiState = AuthState(isLoading: true)
        
        auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.uiState = AuthState(
                        isLoading: false,
                        errorMessage: error.localizedDescription
                    )
                }
                return
            }
            
            guard let userId = authResult?.user.uid else {
                DispatchQueue.main.async {
                    self.uiState = AuthState(
                        isLoading: false,
                        errorMessage: "User ID not found"
                    )
                }
                return
            }
            
            // Create user document in Firestore
            let userData: [String: Any] = [
                "email": email,
                "studentId": studentId,
                "fullName": fullName,
                "studentType": "student",
                "createdAt": FieldValue.serverTimestamp(),
                "role": "user" // default role
            ]
            
            self.firestore.collection("users").document(userId).setData(userData) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Failed to write user data: \(error.localizedDescription)")
                        self.uiState = AuthState(
                            isLoading: false,
                            errorMessage: error.localizedDescription
                        )
                    } else {
                        print("✅ User successfully added to Firestore")
                        self.uiState = AuthState(
                            isLoading: false,
                            successMessage: "Account created successfully!"
                        )
                        
                        // Navigate to login screen after signup
                        self.navigateToLogin = true
                    }
                }
            }
        }
    }
    
    // MARK: - Sign In with Email and Password
    
    func signInWithEmailAndPassword(email: String, password: String, rememberMe: Bool) {
        // Validate input first
        guard validateEmail(email), validatePassword(password) else {
            uiState = AuthState(errorMessage: "Please check your input")
            return
        }
        
        uiState = AuthState(isLoading: true)
        
        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.uiState = AuthState(
                        isLoading: false,
                        errorMessage: error.localizedDescription
                    )
                }
                return
            }
            
            guard let userId = authResult?.user.uid else {
                DispatchQueue.main.async {
                    self.uiState = AuthState(
                        isLoading: false,
                        errorMessage: "User ID not found"
                    )
                }
                return
            }
            
            // Fetch Student Data from Firestore
            self.firestore.collection("users").document(userId).getDocument { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.uiState = AuthState(
                            isLoading: false,
                            errorMessage: error.localizedDescription
                        )
                        return
                    }
                    
                    guard let data = snapshot?.data() else {
                        self.uiState = AuthState(
                            isLoading: false,
                            errorMessage: "User data not found"
                        )
                        return
                    }
                    
                    let studentId = data["studentId"] as? String ?? ""
                    let fullName = data["fullName"] as? String ?? ""
                    let registeredEvents = data["registeredEvents"] as? [String] ?? []
                    
                    print("✅ Student ID: \(studentId), Name: \(fullName), Events: \(registeredEvents)")
                    
                    self.fullName = fullName
                    
                    self.uiState = AuthState(
                        isLoading: false,
                        successMessage: "Sign in successful!"
                    )
                    
                    // Save remember me state
                    self.saveRememberMeState(rememberMe)
                    
                    // Navigate to main screen
                    self.navigateToMain = true
                }
            }
        }
    }
    
    // MARK: - Reset Password
    
    func resetPassword(email: String) {
        guard validateEmail(email) else {
            uiState = AuthState(errorMessage: "Please enter a valid email")
            return
        }
        
        uiState = AuthState(isLoading: true)
        
        auth.sendPasswordReset(withEmail: email) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.uiState = AuthState(
                        isLoading: false,
                        errorMessage: error.localizedDescription
                    )
                } else {
                    self.uiState = AuthState(
                        isLoading: false,
                        successMessage: "Password reset email sent successfully!"
                    )
                }
            }
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        do {
            try auth.signOut()
            
            // Clear JWT token
            preferencesManager.clearJwt()
            
            // Clear fields
            clearFields()
            
            print("✅ User logged out successfully")
        } catch {
            print("❌ Logout error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Validation Methods
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let isValid = emailPredicate.evaluate(with: email)
        
        emailError = isValid ? nil : "Please enter a valid email address"
        return isValid
    }
    
    func validatePassword(_ password: String) -> Bool {
        let isValid = password.count >= 6
        passwordError = isValid ? nil : "Password must be at least 6 characters"
        return isValid
    }
    
    func validateName(_ name: String) -> Bool {
        let isValid = name.count >= 2
        nameError = isValid ? nil : "Name must be at least 2 characters"
        return isValid
    }
    
    func passwordsMatch() -> Bool {
        return signUpPassword == signUpConfirmPassword
    }
    
    // MARK: - Helper Methods
    
    func clearMessages() {
        uiState = AuthState(
            isLoading: uiState.isLoading,
            errorMessage: "",
            successMessage: ""
        )
    }
    
    func clearFields() {
        email = ""
        password = ""
        signUpFullName = ""
        signUpEmail = ""
        signUpPassword = ""
        signUpConfirmPassword = ""
        signUpStudentID = ""
        emailError = nil
        passwordError = nil
        nameError = nil
    }
    
    func togglePasswordVisibility() {
        showPassword.toggle()
    }
    
    private func saveRememberMeState(_ rememberMe: Bool) {
        preferencesManager.saveRememberState(rememberMe)
    }
    
    func getRememberMeState() -> AnyPublisher<Bool, Never> {
        return preferencesManager.getRememberState()
    }
    
    // MARK: - Convenience Methods for Views
    
    func login() {
        signInWithEmailAndPassword(email: email, password: password, rememberMe: rememberMe)
    }
    
    func signUp() {
        guard validateName(signUpFullName),
              validateEmail(signUpEmail),
              validatePassword(signUpPassword),
              passwordsMatch() else {
            uiState = AuthState(errorMessage: "Please check your input")
            return
        }
        
        signUpWithEmail(
            email: signUpEmail,
            password: signUpPassword,
            studentId: signUpStudentID,
            fullName: signUpFullName
        )
    }
    
    // MARK: - Check Validation
    
    var isFormValid: Bool{
        Validators.isValidName(signUpFullName).isValid && Validators.isValidPassword(signUpPassword).isValid && signUpPassword == signUpConfirmPassword
    }
}

// MARK: - Auth State (mirrors Kotlin AuthState)

struct AuthState {
    let isLoading: Bool
    let errorMessage: String
    let successMessage: String
    
    init(
        isLoading: Bool = false,
        errorMessage: String = "",
        successMessage: String = ""
    ) {
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.successMessage = successMessage
    }
}



