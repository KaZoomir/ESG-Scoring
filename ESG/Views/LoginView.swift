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
    
    var body: some View{
        NavigationView{
            ZStack{
                Color.backgroundPrimary.ignoresSafeAreaEdges()
                
                ScrollView{
                    VStack(spacing: Spacing.xl)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
