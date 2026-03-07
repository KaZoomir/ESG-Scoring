//
//  SettingsView.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.03.07.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View{
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutConfirm = false
    @State private var showPasswordAlert = false
    @State private var passwordMessage = ""
    
    var body: some View{
        ScrollView{
            VStack(alignment: .leading, spacing: 24){
                
                SettingRow(
                    icon: "bell.fill",
                    title: "Enable Notificatons",
                    toggle: $notificationsEnabled
                    )
                
                SettingRow(
                    icon: "circle.lefthalf.fill",
                    title: "Use System Theme",
                    toggle: $useSystemTheme
                    )
                
                if !useSystemTheme{
                    SettingRow(
                        icon: "moon.fill",
                        title: "Dark Mode",
                        toggle: $darkModeEnabled
                        )
                }
                
                Divider()
                
                SettingRow(icon: "person.circle.fill", title: "Account Settings"){
                    dismiss()
                }
                
                SettingRow(icon: "lock.fill", title: "Change Password"){
//                    sendPasswordReset()
                }
                
                Divider()
                
                SettingRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", tint: .red) {
                    showLogoutConfirm = true
                }
            }
            .padding(.top, 8)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Sign Out", isPresented: $showLogoutConfirm){
            Button("Sign Out", role: .destructive){
                try? Auth.auth().signOut()
            }
            Button("Cancel", role: .cancel){}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Password Reset", isPresented: $showPasswordAlert){
            Button("OK", role: .cancel){}
        } message: {
            Text(passwordMessage)
        }
        .preferredColorScheme(useSystemTheme ? nil : (darkModeEnabled ? .dark: .light))
    }
    
    private func sendPasswordReset(){
        guard let email = Auth.auth().currentUser?.email else {return}
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error {
                passwordMessage = "Failed to send password reset email: \(error.localizedDescription)"
            } else{
                passwordMessage = "Password reset email sent to \(email)"
            }
            showPasswordAlert = true
        }
    }
}

private struct SettingRow: View {
    let icon: String
    let title: String
    var tint: Color = Color.primaryGreen
    var toggle: Binding<Bool>? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button{
            action?()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(tint)
                    .frame(height: 28)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(.label))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let toggle{
                    Toggle("", isOn: toggle)
                        .labelsHidden()
                        .tint(Color.primaryGreen)
                        .scaleEffect(0.8)
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 24)
        }
        .disabled(toggle != nil)
        .overlay {
            if toggle != nil {
                Color.clear
            }
        }
    }
}
