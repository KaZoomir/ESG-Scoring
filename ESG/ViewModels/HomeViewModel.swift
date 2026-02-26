//
//  HomeViewModel.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.20.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var events: [Event] = []
    @Published var projects: [Project] = []
    @Published var currentUser: User? = nil
    
    @Published var selectedTab: HomeTab = .all
    
    @Published var isLoading = false
    @Published var isRefreshing = false
    
    @Published var errorMessage: String? = nil
    @Published var navigateToEventDetail: String? = nil
    
    // MARK: - Private Properties
    
    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()
    private var cancellables = Set<AnyCancellable>()
    private var listeners: [ListenerRegistration] = []
    
    // MARK: - Computed Properties
    
    var upcomingEvents: [Event] {
        events
            .filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
    }
    
    var showEventsRow: Bool {
        selectedTab == .all || selectedTab == .events
    }
    
    var feedProjects: [Project] {
        switch selectedTab {
        case .all, .projects: return projects
        default: return []
        }
    }
    
    // MARK: - Initialization
    
    init() {
        fetchEvents()
        fetchProjects()
        fetchCurrentUser()
    }
    
    deinit {
        listeners.forEach { $0.remove() }
    }
    
    // MARK: - Fetch Events
    
    func fetchEvents() {
        isLoading = true
        
        firestore.collection("events").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                return
            }
            
            let fetched = snapshot?.documents.compactMap { doc in
                try? doc.data(as: Event.self)
            } ?? []
            
            DispatchQueue.main.async {
                self.events = fetched
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Fetch Projects
    
    func fetchProjects() {
        firestore.collection("projects")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }
                
                let fetched = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Project.self)
                } ?? []
                
                DispatchQueue.main.async {
                    self.projects = fetched
                }
            }
    }
    
    // MARK: - Fetch Current User
    
    private func fetchCurrentUser() {
        guard let userId = auth.currentUser?.uid else { return }
        
        firestore.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Failed to fetch user: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data() else { return }
            
            let user = User(
                id: userId,
                name: data["fullName"] as? String ?? "",
                email: data["email"] as? String ?? "",
                totalESGScore: data["overallPoints"] as? Int ?? 0,
                studentID: data["studentId"] as? String
            )
            
            DispatchQueue.main.async {
                self.currentUser = user
            }
        }
    }
    
    // MARK: - Refresh
    
    func refresh() {
        isRefreshing = true
        fetchEvents()
        fetchProjects()
        fetchCurrentUser()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isRefreshing = false
        }
    }
    
    // MARK: - Like Project
    
    func likeProject(_ project: Project) {
        guard let uid = auth.currentUser?.uid else { return }
        
        let isLiked = project.isLikedBy(userId: uid)
        let update: [String: Any] = isLiked
            ? ["liked": FieldValue.arrayRemove([uid])]
            : ["liked": FieldValue.arrayUnion([uid])]
        
        guard let projectId = project.id else { return }
        
        // Optimistic local update
        if let index = projects.firstIndex(where: { $0.id == projectId }) {
            if isLiked {
                projects[index].liked.removeAll { $0 == uid }
            } else {
                projects[index].liked.append(uid)
            }
        }
        
        firestore.collection("projects").document(projectId).updateData(update) { [weak self] error in
            if let error = error {
                print("❌ Failed to like project: \(error.localizedDescription)")
                self?.fetchProjects()
            }
        }
    }
    
    // MARK: - Create Project
    
    func createProject(name: String, description: String, responseLink: String, completion: @escaping (Bool) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            errorMessage = "Not logged in"
            completion(false)
            return
        }
        
        let docRef = firestore.collection("projects").document()
        let data: [String: Any] = [
            "id": docRef.documentID,
            "name": name,
            "description": description,
            "responseLink": responseLink,
            "creator": uid,
            "liked": [String](),
            "createdAt": Timestamp(date: Date())
        ]
        
        docRef.setData(data) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
                return
            }
            
            self.firestore.collection("users").document(uid).updateData([
                "projects": FieldValue.arrayUnion([docRef.documentID])
            ]) { error in
                if let error = error {
                    print("❌ Failed to update user projects list: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                self.fetchProjects()
                completion(true)
            }
        }
    }
    
    // MARK: - Register for Event
    
    func registerForEvent(eventId: String, role: String, completion: @escaping (Bool, String?) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            completion(false, "Not logged in")
            return
        }
        
        firestore.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data(),
                  let studentId = data["studentId"] as? String else {
                completion(false, "User data not found")
                return
            }
            
            let eventStory = data["eventStory"] as? [String] ?? []
            if eventStory.contains(eventId) {
                completion(false, "Already registered for this event")
                return
            }
            
            self.firestore.collection("events").document(eventId).getDocument { snapshot, error in
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }
                
                guard let eventData = snapshot?.data(),
                      let roles = eventData["roles"] as? [String: [String: Any]],
                      let roleDetails = roles[role],
                      let rolePoints = roleDetails["points"] as? Int else {
                    completion(false, "Event or role not found")
                    return
                }
                
                let eventUserData: [String: Any] = [
                    "role": role,
                    "points": rolePoints,
                    "status": "registered"
                ]
                
                let batch = self.firestore.batch()
                let userRef = self.firestore.collection("users").document(uid)
                let eventRef = self.firestore.collection("events").document(eventId)
                
                batch.updateData(["eventStory": FieldValue.arrayUnion([eventId])], forDocument: userRef)
                batch.updateData(["registeredUsers.\(studentId)": eventUserData], forDocument: eventRef)
                
                batch.commit { error in
                    if let error = error {
                        completion(false, error.localizedDescription)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.fetchEvents()
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Real-time Listeners
    
    func startListening() {
        let eventsListener = firestore.collection("events")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, error == nil, let snapshot = snapshot else { return }
                
                let fetched = snapshot.documents.compactMap { doc in
                    try? doc.data(as: Event.self)
                }
                
                DispatchQueue.main.async {
                    self.events = fetched
                }
            }
        
        let projectsListener = firestore.collection("projects")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, error == nil, let snapshot = snapshot else { return }
                
                let fetched = snapshot.documents.compactMap { doc in
                    try? doc.data(as: Project.self)
                }
                
                DispatchQueue.main.async {
                    self.projects = fetched
                }
            }
        
        listeners = [eventsListener, projectsListener]
    }
    
    func stopListening() {
        listeners.forEach { $0.remove() }
        listeners = []
    }
    
    // MARK: - Helpers
    
    func clearError() {
        errorMessage = nil
    }
}
