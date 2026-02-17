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
                Color.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "leaf.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.primaryGreen)
                            
                            Text("ESG KBTU")
                                .font(.h1)
                                .foregroundColor(.textPrimary)
                            
                            Text("Building a sustainable future together")
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                        }
                        .padding(.top, Spacing.xxxl)
                        
                        VStack(spacing: Spacing.lg) {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("Email")
                                    .font(.bodyMedium)
                                    .foregroundColor(.textSecondary)
                                
                                TextField("your.email@kbtu.kz", text: $viewModel.email)
                                    .textFieldStyle()
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                
                                if let error = viewModel.emailError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.errorColor)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                Text("Password")
                                    .font(.bodyMedium)
                                    .foregroundColor(.textSecondary)
                                
                                HStack {
                                    if viewModel.showPassword {
                                        TextField("Enter your password", text: $viewModel.password)
                                    } else {
                                        SecureField("Enter your password", text: $viewModel.password)
                                    }
                                    
                                    Button(action: viewModel.togglePasswordVisibility) {
                                        Image(systemName: viewModel.showPassword ? "eye.slash.fill" : "eye.fill")
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                                .textFieldStyle()
                                
                                if let error = viewModel.passwordError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.errorColor)
                                }
                            }
                            
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    viewModel.resetPassword()
                                }
                                .font(.bodySmall)
                                .foregroundColor(.primaryGreen)
                            }
                            
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.bodySmall)
                                    .foregroundColor(.errorColor)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.errorColor.opacity(0.1))
                                    .cornerRadius(CornerRadius.small)
                            }
                            
                            Button(action: viewModel.login) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Log In")
                                }
                            }
                            .primaryButtonStyle()
                            .disabled(viewModel.isLoading)
                            
                            HStack {
                                Text("Don't have an account?")
                                    .font(.bodyMedium)
                                    .foregroundColor(.textSecondary)
                                
                                NavigationLink("Sign Up") {
//                                    SignUpView()
                                }
                                .font(.bodyMedium)
                                .foregroundColor(.primaryGreen)
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onChange(of: viewModel.isAuthenticated) { authenticated in
            if authenticated {
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
