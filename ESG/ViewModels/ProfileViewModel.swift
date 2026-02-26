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

class ProfileViewModel: ObservableObject{
    // MARK: - Published
    
    @Published var user: User?
    @Published var badges: [Badge] = []
    @Published var leaderboard: [Rating] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showLogoutConfirm = false
    @Published var isLoggedOut = false
    
    // MARK: - Private
    private var userService = UserService.shared
    private var cancellables = Set<AnyCancellable>()
    private var firestore = Firestore.firestore()
    
    init(){
        loadProfile()
    }
    
    func loadProfile(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        isLoading = true
        
        firestore.collection("users").document(uid).getDocument{[weak self] snapshot, error in
            DispatchQueue.main.async{
                if let data = snapshot?.data(){
                    self?.user = User(
                        id: uid,
                        name: data["name"] as? String ?? "User",
                        email: data["email"] as? String ?? "",
                        totalESGScore: data["totalESGScore"] as? Int ?? 0,
                        badges: [],
                        studentID: data["studentID"] as? String ?? "",
                        faculty: data["faculty"] as? String ?? "",
                        environmentalScore: data["environmentalScore"] as? Int ?? 0,
                        socialScore: data["socialScore"] as? Int ?? 0,
                        governanceScore: data["governanceScore"] as? Int ?? 0,
                        eventsAttended: data["eventsAttended"] as? Int ?? 0,
                        eventsCompleted: data["eventsCompleted"] as? Int ?? 0,
                        currentStreak: data["currentStreak"] as? Int ?? 0,
                        longestStreak: data["longestStreak"] as? Int ?? 0
                    )
                }
                else {
                    self?.user = User(
                        id: uid,
                        name: Auth.auth().currentUser?.displayName ?? "User",
                        email: Auth.auth().currentUser?.email ?? "",
                        totalESGScore: 450,
                        studentID: "22B030477",
                        faculty: "SITE",
                        environmentalScore: 150,
                        socialScore: 100,
                        governanceScore: 200,
                        eventsAttended: 12,
                        eventsCompleted: 10,
                        currentStreak: 8,
                        longestStreak: 10
                        
                    )
                }
            }
        }
        userService.fetchBadges(userId: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: {[weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion{
                        self? .errorMessage = error.localizedDescription
                    }
                    
                },
                receiveValue: {[weak self] badges in
                    self?.badges = badges
                }
            )
            .store(in: &cancellables)
        
        userService.fetchLeaderboard(limit: 10)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: {_ in},
                receiveValue: {[weak self] ratings in
                    self?.leaderboard = ratings
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Log Out
    
    func logout(){
        do{
            try Auth.auth().signOut()
            isLoggedOut = true
        }
        catch{
            errorMessage = "Failed to sign out"
        }
    }
    
    // MARK: - Helpers
    
    func myRank() -> Rating? {
        guard let uid = Auth.auth().currentUser?.uid else {return nil}
        return leaderboard.first(where: { $0.userId == uid})
    }
    
    func clearerror(){
        errorMessage = nil
    }
                                 
}
