//
//  ESGApp.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import SwiftUI
import FirebaseCore

@main
struct ESGApp: App {
    
    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
