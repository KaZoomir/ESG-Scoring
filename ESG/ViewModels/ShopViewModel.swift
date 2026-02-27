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
    @Published var shopItem: [ShopItem] = []
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
                self.shopItem = snapshot?.documents.compactMap { doc in
                    let d = doc.data()
                    return ShopItem(
                        id: doc.documentID,
                        name: d["name"] as? String ?? "",
                        description: d["description"] as? String ?? "",
                        price: d["price"] as? Int ?? 0,
                        type: d["type"] as? String ?? ""
                    )
                } ?? []
            }
        }
    }
}
