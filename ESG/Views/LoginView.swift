//
//  LoginView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import SwiftUI

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Kotlin: .background(MaterialTheme.colorScheme.background)
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Kotlin: Column.padding(top = 80.dp)
                        Color.clear.frame(height: 80)
                        
                        // MARK: - Logo
                        // Kotlin: Image(R.drawable.icon_esg, size(92.dp), ContentScale.Crop)
                        Image(systemName: "leaf.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 92, height: 92)
                            .foregroundStyle(Color.primaryGreen)
                        
                        // Kotlin: Spacer(height = 32.dp)
                        Color.clear.frame(height: 32)
                        
                        // MARK: - Title
                        // Kotlin: Text("Sign In", fontSize = 30.sp, fontWeight = W500)
                        Text("Sign In")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundStyle(Color(.label))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 10)
                        
                        // MARK: - Email Field
                        // Kotlin: OutlinedTextField with green border
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
                        }
                        
                        // Kotlin: Spacer(height = 16.dp)
                        Color.clear.frame(height: 16)
                        
                        // MARK: - Password Field
                        // Kotlin: OutlinedTextField with trailingIcon
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
                        }
                        
                        // Kotlin: Spacer(height = 8.dp)
                        Color.clear.frame(height: 8)
                        
                        // MARK: - Remember Me + Forgot Password
                        // Kotlin: Row(SpaceBetween) { Switch(scale 0.8f) + "Remember Me" } + "Forgot Password?"
                        HStack {
                            HStack(spacing: 4) {
                                // Kotlin: Switch with green colors, scale 0.8f
                                Toggle("", isOn: .constant(false))
                                    .labelsHidden()
                                    .scaleEffect(0.8)
                                    .tint(Color.primaryGreen)
                                
                                Text("Remember Me")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(.label))
                            }
                            
                            Spacer()
                            
                            Button("Forgot Password?") {
                                viewModel.resetPassword()
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(Color(.darkGray))
                        }
                        
                        // Kotlin: Spacer(height = 16.dp)
                        Color.clear.frame(height: 16)
                        
                        // MARK: - Sign In Button
                        // Kotlin: Box + shadow(elevation = 10.dp, RoundedCornerShape(6.dp))
                        // Button: height = 56.dp, RoundedCornerShape(6.dp), green container, white text, fontSize = 16.sp
                        Button(action: viewModel.login) {
                            Text("Sign In")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        }
                        .background(Color.primaryGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .shadow(
                            color: Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.2),
                            radius: 10,
                            x: 0,
                            y: 4
                        )
                        .disabled(viewModel.isLoading)
                        
                        // Kotlin: if (uiState.isLoading) CircularProgressIndicator(padding = 16.dp)
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        // Kotlin: if (errorMessage.isNotEmpty) Text(color = Red, padding = 16.dp)
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(16)
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Kotlin: Spacer(height = 20.dp)
                        Color.clear.frame(height: 20)
                        
                        // MARK: - Divider "Or"
                        // Kotlin: Row(padding vertical = 16.dp) { HorizontalDivider + Text("Or", 14.sp, W500) + HorizontalDivider }
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
                        // Kotlin: Row(Center) { Text("Don't have an account? ", 14.sp) + Text("Sign up", 14.sp, green) }
                        HStack(spacing: 0) {
                            Text("Don't have an account? ")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.label))
                            
                            NavigationLink("Sign up") {
                                // SignUpView()
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
        .onChange(of: viewModel.isAuthenticated) { authenticated in
            if authenticated { navigateToHome = true }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            // MainTabView()
        }
    }
}

#Preview {
    LoginView()
}
