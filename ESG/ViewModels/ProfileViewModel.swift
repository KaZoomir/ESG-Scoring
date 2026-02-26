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

    // UI state
    @Published var showEditDialog = false
    @Published var showLogoutConfirm = false
    @Published var isLoggedOut = false

    private let userService = UserService.shared
    private var cancellables = Set<AnyCancellable>()
    private let firestore = Firestore.firestore()

    init() { loadProfile() }

    func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true

        firestore.collection("users").document(uid).getDocument { [weak self] snapshot, _ in
            DispatchQueue.main.async {
                if let data = snapshot?.data() {
                    self?.user = User(
                        id: uid,
                        name: data["name"] as? String ?? "User",
                        email: data["email"] as? String ?? "",
                        totalESGScore: data["overallPoints"] as? Int ?? data["totalESGScore"] as? Int ?? 0,
                        studentID: data["studentId"] as? String,
                        faculty: data["faculty"] as? String,
                        environmentalScore: data["environmentalScore"] as? Int ?? 0,
                        socialScore: data["socialScore"] as? Int ?? 0,
                        governanceScore: data["governanceScore"] as? Int ?? 0,
                        eventsAttended: data["eventsAttended"] as? Int ?? 0,
                        eventsCompleted: data["eventsCompleted"] as? Int ?? 0,
                        currentStreak: data["currentStreak"] as? Int ?? 0,
                        longestStreak: data["longestStreak"] as? Int ?? 0
                    )
                } else {
                    // Fallback mock
                    self?.user = User(
                        id: uid,
                        name: Auth.auth().currentUser?.displayName ?? "User",
                        email: Auth.auth().currentUser?.email ?? "",
                        totalESGScore: 450,
                        studentID: "22B030477",
                        faculty: "SITE",
                        environmentalScore: 150,
                        socialScore: 200,
                        governanceScore: 100,
                        eventsAttended: 12,
                        eventsCompleted: 10,
                        currentStreak: 5,
                        longestStreak: 8
                    )
                }
                self?.isLoading = false
            }
        }

        // Badges
        userService.fetchBadges(userId: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.badges = $0 }
            )
            .store(in: &cancellables)
    }

    func updateUser(studentId: String, email: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let updates: [String: Any] = ["studentId": studentId, "email": email]
        firestore.collection("users").document(uid).updateData(updates)
        user?.studentID = studentId
        user?.email = email
    }

    func logout() {
        try? Auth.auth().signOut()
        isLoggedOut = true
    }
}
