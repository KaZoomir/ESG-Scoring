//
//  ContentView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isUserLoggedIn = false
    
    var body: some View {
        Group {
            if isUserLoggedIn {
//                MainTabView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            checkAuthState()
        }
    }
    
    private func checkAuthState() {
        // Check if user is already logged in
        isUserLoggedIn = Auth.auth().currentUser != nil
    }
}
