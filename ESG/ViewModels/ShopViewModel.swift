//
//  ShopViewModel.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.27.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class ShopViewModel: ObservableObject{
    
    // MARK: - Published
    @Published var shopItems: [ShopItem] = []
    @Published var filteredItems: [ShopItem] = []
    @Published var userPoints: Int = 0
    @Published var isLoading = false
    @Published var selectedType: String = "All"
    @Published var isRefreshing: Bool = false
    @Published var toast: String? = nil
    
    let availableTypes = ["All", "merch", "disount"]
    
    private let db = Firestore.firestore()
    private var uid: String? {Auth.auth().currentUser? .uid}
    
    init(){
        fetchShopItem()
//        fetchUserPoints()
    }
    
    // MARK: - Fetch shop Item
    
    func fetchShopItem(){
        isLoading = true
        db.collection("shopItem").getDocuments {[weak self] snapshot , error in
            guard let self else {return}
            DispatchQueue.main.async {
                self.isLoading = false
                if let error {
                    print("Shpp: \(error.localizedDescription)")
                    return
                }
                self.shopItems = snapshot?.documents.compactMap { doc in
                    let d = doc.data()
                    return ShopItem(
                        id: doc.documentID,
                        name: d["name"] as? String ?? "",
                        description: d["description"] as? String ?? "",
                        price: d["price"] as? Int ?? 0,
                        type: d["type"] as? String ?? ""
                    )
                } ?? []
                self.applyFilter()
            }
        }
    }
    
    func fetchUserPoints(){
        guard let uid else {return}
        db.collection("users").document(uid).getDocument() {[weak self] snap, _  in
            DispatchQueue.main.async{
                self?.userPoints = snap?.data()?["overallPoints"] as? Int ?? 0
            }
        }
    }
    
    // MARK: - Filter
    func setSelectedType(_ type: String){
        selectedType = type
        applyFilter()
    }
    
    private func applyFilter(){
        if selectedType == "All" {
            filteredItems = shopItems
        }
        else{
            filteredItems = shopItems.filter{ $0.type.lowercased() == selectedType.lowercased()}
        }
    }
    
    // MARK: - Refresh
    func refresh(){
        isRefreshing = true
        fetchShopItem()
        fetchUserPoints()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.isRefreshing = false
        }
    }
    
    // MARK: - Purchase
    func purchaseItem(_ item: ShopItem) {
        guard let uid else{return}
        
        db.collection("users").document(uid).getDocument{[weak self] snap, _ in
            guard let self, let data = snap?.data() else{return}
            let overall = data["overallPoints"] as? Int ?? 0
            let used = data["userPoints"] as? Int ?? 0
            let totalPurchases = data["totalPurchases"] as? Int ?? 0
            let purchaseStory = data["purchaseStory"] as? [String: [String: Any]] ?? [:]
            let existing = purchaseStory[item.id]
            
            if item.type.lowercased() == "discount", let ex = existing {
                let usedFlag = ex["used"] as? Bool ?? true
                if !usedFlag{
                    DispatchQueue.main.async{ self.toast = "Used the previos discount before buying again"}
                    return
                }
            }
            guard overall >= item.price else{
                DispatchQueue.main.async {self.toast = "Not enough points"}
                return
            }
            
            let newCount = (existing?["count"] as? Int ?? 0) + 1
            
            let updates: [String: Any] = [
                "overallPoints": overall - item.price,
                "userPoints": used + item.price,
                "totalPurchases": totalPurchases + 1,
                "purchaseStory.\(item.id)": [
                    "used": false,
                    "count": newCount
                ]
            ]
            
            self.db.collection("users").document(uid).updateData(updates) { [weak self] error in
                guard let self else {return}
                if let error {
                    DispatchQueue.main.async {self.toast = "\(error.localizedDescription)"}
                    return
                }
                
                self.db.collection("purchases").addDocument(data: [
                    "userId" : uid,
                    "itemId" : item.id,
                    "timestamp": Timestamp(date: Date()),
                    "used": false
                ])
                
                DispatchQueue.main.async {
                    self.userPoints = overall - item.price
                    self.toast = "Purchased \(item.name)"
                }
            }
        }
    }
}
