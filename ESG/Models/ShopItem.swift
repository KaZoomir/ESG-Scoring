//
//  ShopItem.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation

struct ShopItem: Identifiable, Decodable{
    var id: String
    var name: String
    var description: String
    var price: Int       // points cost — "price" in Firestore
    var type: String     // "merch" | "discount" — "type" in Firestore

    init(id: String = "", name: String = "", description: String = "", price: Int = 0, type: String = "") {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.type = type
    }
}
