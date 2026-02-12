//
//  ShopItem.swift
//  ESG
//
//  Created by Alikhan Kassiman on 2026.02.12.
//

import Foundation

struct ShopItem: Codable, Identifiable {
    let id: String
    var title: String
    var cost: Int // ESG points cost
    var description: String
    var imageURL: String?
    var category: ShopItemCategory
    var stockAvailable: Int?
    var isAvailable: Bool
    var validUntil: Date?
    var termsAndConditions: String?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        cost: Int,
        description: String,
        imageURL: String? = nil,
        category: ShopItemCategory,
        stockAvailable: Int? = nil,
        isAvailable: Bool = true,
        validUntil: Date? = nil,
        termsAndConditions: String? = nil
    ) {
        self.id = id
        self.title = title
        self.cost = cost
        self.description = description
        self.imageURL = imageURL
        self.category = category
        self.stockAvailable = stockAvailable
        self.isAvailable = isAvailable
        self.validUntil = validUntil
        self.termsAndConditions = termsAndConditions
    }
    
    func canPurchase(userPoints: Int) -> Bool {
        return isAvailable && cost <= userPoints && (stockAvailable ?? 1) > 0
    }
}


enum ShopItemCategory: String, Codable {
    case merchandise = "Merchandise"
    case discounts = "Discounts"
    case privileges = "Privileges"
    case experiences = "Experiences"
}
