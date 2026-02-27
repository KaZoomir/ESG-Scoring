//
//  ProfileViewModel.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.27.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {

    @Published var user: User?
    @Published var badges: [Badge] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var showEditDialog = false
    @Published var showLogoutConfirm = false
    @Published var isLoggedOut = false

    private let firestore = Firestore.firestore()

    init() { loadProfile() }

    // MARK: - Load (mirrors fetchUserProfile + fetchAllBadges + fetchUserBadges)

    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            // Not signed in yet — clear state so view doesn't hang
            user = nil
            isLoading = false
            return
        }

        isLoading = true

        // 1. Fetch user document (same as Android: firestore.collection("users").document(userId).get())
        firestore.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self else { return }

            DispatchQueue.main.async {
                if let error {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    return
                }

                let data = snapshot?.data() ?? [:]

                // Always set user — fallback to Firebase Auth if Firestore doc missing
                let overallPoints = data["overallPoints"] as? Int ?? 0

                self.user = User(
                    id: uid,
                    name:          data["fullName"]  as? String ?? Auth.auth().currentUser?.displayName ?? "User",
                    email:         data["email"]     as? String ?? Auth.auth().currentUser?.email ?? "",
                    totalESGScore: overallPoints,
                    studentID:     data["studentId"] as? String,
                    faculty:       data["faculty"]   as? String,
                    role:          data["role"]      as? String ?? "user"
                )
                self.isLoading = false

                // 2. After user is loaded, fetch badges
                self.fetchBadges(uid: uid, earnedBadgeIds: data["badges"] as? [String: Bool] ?? [:])
            }
        }
    }

    // MARK: - Fetch badges
    // Android: fetchAllBadges() → collection("badges").get(), then fetchUserBadges() filters by user's Map<String,Bool>

    private func fetchBadges(uid: String, earnedBadgeIds: [String: Bool]) {
        firestore.collection("badges").getDocuments { [weak self] snapshot, error in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let docs = snapshot?.documents else { return }

                // Build all badges from "badges" collection
                // Filter only earned ones (earnedBadgeIds[docId] == true)
                self.badges = docs.compactMap { doc -> Badge? in
                    guard earnedBadgeIds[doc.documentID] == true else { return nil }

                    let data = doc.data()
                    return Badge(
                        id:             doc.documentID,
                        title:          data["name"]        as? String ?? "",
                        icon:           data["icon"]        as? String ?? "",
                        description:    data["description"] as? String ?? "",
                        type:           self.badgeType(from: data["type"] as? String ?? ""),
                        pointsRequired: data["condition"]   as? Int ?? 0,
                        isUnlocked:     true
                    )
                }
            }
        }
    }

    // MARK: - Refresh

    func refreshProfile() {
        loadProfile()
    }

    // MARK: - Update user (mirrors Android updateUser — only updates studentId)

    func updateUser(studentId: String, email: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let updates: [String: Any] = ["studentId": studentId]

        firestore.collection("users").document(uid).updateData(updates) { [weak self] error in
            DispatchQueue.main.async {
                if let error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.user?.studentID = studentId
                }
            }
        }
    }

    // MARK: - Logout

    func logout() {
        try? Auth.auth().signOut()
        isLoggedOut = true
    }

    // MARK: - Helpers

    private func badgeType(from string: String) -> BadgeType {
        switch string.lowercased() {
        case "event":  return .social
        case "shop":   return .governance
        case "points": return .environmental
        default:       return .milestone
        }
    }
}
