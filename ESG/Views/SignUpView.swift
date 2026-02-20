//
//  SignUpView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.20.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToLogin = false
    @State private var passwordVisible = false
    @State private var confirmPasswordVisible = false
    
    var body: some View {
          NavigationView {
              ZStack {
                  Color(.systemBackground).ignoresSafeArea()

                  ScrollView(showsIndicators: false) {
                      VStack(spacing: 0) {

                          // MARK: - Back Button
                          HStack {
                              Button(action: { dismiss() }) {
                                  Image(systemName: "chevron.left")
                                      .font(.system(size: 24))
                                      .foregroundColor(Color(.label))
                              }
                              Spacer()
                          }
                          .padding(.top, 32)

                          Color.clear.frame(height: 60)

                          // MARK: - Title
                          Text("Sign Up")
                              .font(.system(size: 30, weight: .medium))
                              .foregroundStyle(Color(.label))
                              .frame(maxWidth: .infinity, alignment: .center)
                              .padding(.bottom, 10)

                          Color.clear.frame(height: 24)

                          // MARK: - Full Name
                          VStack(alignment: .leading, spacing: 4) {
                              Text("Full Name")
                                  .font(.system(size: 14))
                                  .foregroundStyle(Color(.systemGray))

                              TextField("", text: $viewModel.signUpFullName)
                                  .font(.system(size: 14))
                                  .autocapitalization(.words)
                                  .padding(.horizontal, 12)
                                  .frame(height: 52)
                                  .overlay(
                                      RoundedRectangle(cornerRadius: 4)
                                          .stroke(Color.primaryGreen, lineWidth: 1)
                                  )

                              if let error = viewModel.nameError {
                                  Text(error)
                                      .font(.system(size: 12))
                                      .foregroundStyle(.red)
                                      .padding(.top, 2)
                              }
                          }

                          Color.clear.frame(height: 16)

                          // MARK: - Student ID
                          VStack(alignment: .leading, spacing: 4) {
                              Text("Student ID (optional)")
                                  .font(.system(size: 14))
                                  .foregroundStyle(Color(.systemGray))

                              TextField("", text: $viewModel.signUpStudentID)
                                  .font(.system(size: 14))
                                  .autocapitalization(.allCharacters)
                                  .padding(.horizontal, 12)
                                  .frame(height: 52)
                                  .overlay(
                                      RoundedRectangle(cornerRadius: 4)
                                          .stroke(Color.primaryGreen, lineWidth: 1)
                                  )
                          }

                          Color.clear.frame(height: 16)

                          // MARK: - Email
                          VStack(alignment: .leading, spacing: 4) {
                              Text("Email")
                                  .font(.system(size: 14))
                                  .foregroundStyle(Color(.systemGray))

                              TextField("", text: $viewModel.signUpEmail)
                                  .font(.system(size: 14))
                                  .autocapitalization(.none)
                                  .keyboardType(.emailAddress)
                                  .padding(.horizontal, 12)
                                  .frame(height: 52)
                                  .overlay(
                                      RoundedRectangle(cornerRadius: 4)
                                          .stroke(
                                              !viewModel.signUpEmail.isEmpty && !Validators.isValidEmail(viewModel.signUpEmail)
                                                  ? Color.errorColor : Color.primaryGreen,
                                              lineWidth: 1
                                          )
                                  )

                              if let error = viewModel.emailError, !viewModel.signUpEmail.isEmpty {
                                  Text(error)
                                      .font(.system(size: 12))
                                      .foregroundStyle(.red)
                                      .padding(.top, 2)
                              }
                          }

                          Color.clear.frame(height: 16)

                          // MARK: - Password
                          VStack(alignment: .leading, spacing: 4) {
                              Text("Password")
                                  .font(.system(size: 14))
                                  .foregroundStyle(Color(.systemGray))

                              HStack {
                                  Group {
                                      if passwordVisible {
                                          TextField("", text: $viewModel.signUpPassword)
                                      } else {
                                          SecureField("", text: $viewModel.signUpPassword)
                                      }
                                  }
                                  .font(.system(size: 14))

                                  Button(action: { passwordVisible.toggle() }) {
                                      Image(systemName: passwordVisible ? "eye.fill" : "eye.slash.fill")
                                          .foregroundStyle(Color(.secondaryLabel))
                                  }
                              }
                              .padding(.horizontal, 12)
                              .frame(height: 52)
                              .overlay(
                                  RoundedRectangle(cornerRadius: 4)
                                      .stroke(
                                          !viewModel.signUpPassword.isEmpty && !Validators.isValidPassword(viewModel.signUpPassword).isValid
                                              ? Color.errorColor : Color.primaryGreen,
                                          lineWidth: 1
                                      )
                              )

                              if !viewModel.signUpPassword.isEmpty,
                                 let message = Validators.isValidPassword(viewModel.signUpPassword).message {
                                  Text(message)
                                      .font(.system(size: 12))
                                      .foregroundStyle(.red)
                                      .padding(.top, 2)
                              }
                          }

                          Color.clear.frame(height: 16)

                          // MARK: - Confirm Password
                          VStack(alignment: .leading, spacing: 4) {
                              Text("Confirm Password")
                                  .font(.system(size: 14))
                                  .foregroundStyle(Color(.systemGray))

                              HStack {
                                  Group {
                                      if confirmPasswordVisible {
                                          TextField("", text: $viewModel.signUpConfirmPassword)
                                      } else {
                                          SecureField("", text: $viewModel.signUpConfirmPassword)
                                      }
                                  }
                                  .font(.system(size: 14))

                                  Button(action: { confirmPasswordVisible.toggle() }) {
                                      Image(systemName: confirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                          .foregroundStyle(Color(.secondaryLabel))
                                  }
                              }
                              .padding(.horizontal, 12)
                              .frame(height: 52)
                              .overlay(
                                  RoundedRectangle(cornerRadius: 4)
                                      .stroke(
                                          !viewModel.signUpConfirmPassword.isEmpty && viewModel.signUpConfirmPassword != viewModel.signUpPassword
                                              ? Color.errorColor : Color.primaryGreen,
                                          lineWidth: 1
                                      )
                              )

                              if !viewModel.signUpConfirmPassword.isEmpty && viewModel.signUpConfirmPassword != viewModel.signUpPassword {
                                  Text("Passwords do not match")
                                      .font(.system(size: 12))
                                      .foregroundStyle(.red)
                                      .padding(.top, 2)
                              }
                          }

                          Color.clear.frame(height: 24)

                          // MARK: - Sign Up Button
                          Button(action: {
                              if viewModel.isFormValid {
                                  viewModel.signUpWithEmail(
                                      email: viewModel.signUpEmail,
                                      password: viewModel.signUpPassword,
                                      studentId: viewModel.signUpStudentID,
                                      fullName: viewModel.signUpFullName
                                  )
                              }
                          }) {
                              if viewModel.uiState.isLoading {
                                  ProgressView()
                                      .progressViewStyle(.circular)
                                      .tint(.white)
                              } else {
                                  Text("SIGN UP")
                                      .font(.system(size: 16, weight: .medium))
                                      .foregroundStyle(.white)
                              }
                          }
                          .frame(maxWidth: .infinity)
                          .frame(height: 56)
                          .background(viewModel.isFormValid ? Color.primaryGreen : Color.primaryGreen.opacity(0.5))
                          .clipShape(RoundedRectangle(cornerRadius: 6))
                          .shadow(
                              color: Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 0.2),
                              radius: 10, x: 0, y: 4
                          )
                          .disabled(!viewModel.isFormValid || viewModel.uiState.isLoading)

                          Color.clear.frame(height: 16)

                          // MARK: - Error Message
                          if !viewModel.uiState.errorMessage.isEmpty {
                              Text(viewModel.uiState.errorMessage)
                                  .font(.system(size: 14))
                                  .foregroundStyle(.red)
                                  .multilineTextAlignment(.center)
                                  .padding(16)
                          }

                          // MARK: - Success Message
                          if !viewModel.uiState.successMessage.isEmpty {
                              Text(viewModel.uiState.successMessage)
                                  .font(.system(size: 14))
                                  .foregroundStyle(Color.primaryGreen)
                                  .multilineTextAlignment(.center)
                                  .padding(16)
                          }

                          Color.clear.frame(height: 24)

                          // MARK: - Already have an account
                          HStack(spacing: 0) {
                              Text("Already have an account? ")
                                  .font(.system(size: 14))
                                  .foregroundStyle(Color(.label))

                              Button("Sign in") {
                                  dismiss()
                              }
                              .font(.system(size: 14))
                              .foregroundStyle(Color.primaryGreen)
                          }
                          .frame(maxWidth: .infinity, alignment: .center)

                          Color.clear.frame(height: 32)
                      }
                      .padding(.horizontal, 20)
                  }
              }
              .navigationBarHidden(true)
          }
          .onChange(of: viewModel.navigateToLogin) { shouldNavigate in
              if shouldNavigate { dismiss() }
          }
      }
  }


#Preview{
    SignUpView()
}
