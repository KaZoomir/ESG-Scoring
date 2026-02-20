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
    
    var body: some View{
        NavigationView{
            ZStack{
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView(showsIndicators: false){
                    VStack(spacing: 0){
                        HStack{
                            Button(action: { dismiss()}){
                                Image(systemName: "chevron.left")
                                    .font(.system(size:24))
                                    .foregroundColor(Color(.label))
                            }
                            Spacer()
                        }
                        .padding(.top, 32)
                        
                        Color.clear.frame(height:60)
                        
                        // MARK: - Title
                        Text("Sign Up")
                            .font(.system(size:30, weight: .medium))
                            .foregroundStyle(Color(.label))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 10)
                        
                        Color.clear.frame(height:24)
                        
                        //MARK: - Full Name field
                        VStack(alignment: .leading, spacing : 4){
                            Text("Full Name")
                                .font(.system(size:14))
                                .foregroundStyle(Color(.systemGray))
                            
                            TextField("", text: $viewModel.signUpFullName)
                                .font(.system(size:14))
                                .autocapitalization(.words)
                                .padding(.horizontal, 12)
                                .frame(height:52)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.primaryGreen, lineWidth:1)
                                    )
                            
                            if let error = viewModel.nameError{
                                Text(error)
                                    .font(.system(size:12))
                                    .foregroundStyle(.red)
                                    .padding(.top, 2)
                            }
                        }
                        
                        Color.clear.frame(height:16)
                        
                        // MARK: - Student ID Field
                        
                        VStack(alignment: .leading, spacing:4){
                            Text("Student ID")
                                .font(.system(size:14))
                                .foregroundStyle(Color(.systemGray))
                            
                            TextField("", text: $viewModel.signUpStudentID)
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .frame(height: 52)
                                .overlay(
                                    RoundedRectangle(cornerRadius:4)
                                        .stroke(Color.primaryGreen, lineWidth: 1)
                                )
                        }
                        
                        Color.clear.frame(height:16)
                        
                        // MARK: - Email
                        VStack(alignment: .leading, spacing: 4){
                            Text("Email")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.systemGray))
                            
                            TextField("", text: $viewModel.signUpEmail)
                                .font(.system(size:14))
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding(.horizontal, 12)
                                .frame(height:52)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(!viewModel.signUpEmail.isEmpty && viewModel.signUpEmail != nil ? Color.red: Color.primaryGreen, lineWidth: 1)
                                )
                            
                            if let error = viewModel.emailError, !viewModel.signUpEmail.isEmpty{
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.red)
                                    .padding(.top,2)
                            }
                        }
                        
                        Color.clear.frame(height:16)
                        
                        // MARK: - Password
                        VStack(alignment: .leading, spacing: 4){
                            Text ("Password")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.systemGray))
                            
                            HStack {
                                if passwordVisible{
                                    TextField("", text: $viewModel.signUpPassword)
                                        .font(.system(size: 14))
                                }
                                else{
                                    SecureField("", text: $viewModel.signUpPassword)
                                        .font(.system(size: 14))
                                }
                                
                                Button(action:{ passwordVisible.toggle()}){
                                    Image(systemName: passwordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundStyle(Color(.secondaryLabel))
                                }
                            }
                            .padding(12)
                            .frame(height: 52)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(
                                        !viewModel.signUpPassword.isEmpty && !isValidPassword(viewModel.signUpPassword) ? Color.red : Color.primaryGreen, lineWidth : 1
                                )
                            )
                            
                        }
                    }
                }
            }
        }
    }
}


#Preview{
    SignUpView()
}
