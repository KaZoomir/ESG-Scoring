//
//  LoginView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 80)
                        
                        // MARK: - Logo
                        Image(systemName: "leaf.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 92, height: 92)
                            .foregroundStyle(Color.primaryGreen)

                        Color.clear.frame(height: 32)
                        
                        // MARK: - Title
                        Text("Sign In")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundStyle(Color(.label))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 10)
                        
                        // MARK: - Email Field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Email")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.systemGray))
                            
                            TextField("", text: $viewModel.email)
                                .font(.system(size: 14))
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding(.horizontal, 12)
                                .frame(height: 52)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.primaryGreen, lineWidth: 1)
                                )
                            
                            // Show email validation error
                            if let error = viewModel.emailError {
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.red)
                                    .padding(.top, 2)
                            }
                        }
                        
                        // Kotlin: Spacer(height = 16.dp)
                        Color.clear.frame(height: 16)
                        
                        // MARK: - Password Field
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Password")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.systemGray))
                            
                            HStack {
                                if viewModel.showPassword {
                                    TextField("", text: $viewModel.password)
                                        .font(.system(size: 14))
                                } else {
                                    SecureField("", text: $viewModel.password)
                                        .font(.system(size: 14))
                                }
                                
                                Button(action: viewModel.togglePasswordVisibility) {
                                    Image(systemName: viewModel.showPassword ? "eye.fill" : "eye.slash.fill")
                                        .foregroundStyle(Color(.secondaryLabel))
                                }
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 52)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.primaryGreen, lineWidth: 1)
                            )
                            
                            // Show password validation error
                            if let error = viewModel.passwordError {
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.red)
                                    .padding(.top, 2)
                            }
                        }
                        
                        Color.clear.frame(height: 8)
                        
                        // MARK: - Remember Me + Forgot Password
                        HStack {
                            HStack(spacing: 4) {
                                Toggle("", isOn: $viewModel.rememberMe)
                                    .labelsHidden()
                                    .scaleEffect(0.8)
                                    .tint(Color.primaryGreen)
                                
                                Text("Remember Me")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(.label))
                            }
                            
                            Spacer()
                            
                            Button("Forgot Password?") {
                                viewModel.resetPassword(email: viewModel.email)
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(Color(.darkGray))
                        }
                        
                        Color.clear.frame(height: 16)
                        
                        // MARK: - Sign In Button
                        Button(action: viewModel.login) {
                            if viewModel.uiState.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Sign In")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.primaryGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(
                            color: Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.2),
                            radius: 10,
                            x: 0,
                            y: 4
                        )
                        .disabled(viewModel.uiState.isLoading)
                        
                        Color.clear.frame(height: 16)
                        
                        // MARK: - Error Message
                        if !viewModel.uiState.errorMessage.isEmpty {
                            Text(viewModel.uiState.errorMessage)
                                .font(.system(size: 14))
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // MARK: - Success Message
                        if !viewModel.uiState.successMessage.isEmpty {
                            Text(viewModel.uiState.successMessage)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.primaryGreen)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.primaryGreen.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Color.clear.frame(height: 20)
                        
                        // MARK: - Divider "Or"
                        HStack {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(height: 1)
                            
                            Text("Or")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 14)
                            
                            Rectangle()
                                .fill(Color.gray)
                                .frame(height: 1)
                        }
                        .padding(.vertical, 16)
                        
                        // Kotlin: Spacer(height = 20.dp)
                        Color.clear.frame(height: 20)
                        
                        // MARK: - Sign Up
                        HStack(spacing: 0) {
                            Text("Don't have an account? ")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.label))
                            
                            NavigationLink("Sign up") {
//                                SignUpView()
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Color.primaryGreen)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: viewModel.navigateToMain) { shouldNavigate in
            if shouldNavigate {
                navigateToHome = true
            }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
//            MainTabView()
        }
    }
}

#Preview {
    LoginView()
}
