//
//  ContentView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isUserLoggedIn: Bool = false
    
    var body: some View{
        Group {
            if isUserLoggedIn{
//                MainView()
            }
            else{
                LoginView()
            }
        }
        .onAppear{
            checkAuthState()
        }
    }
    private func checkAuthState(){
        isUserLoggedIn = Auth.auth().currentUser != nil
    }
}
