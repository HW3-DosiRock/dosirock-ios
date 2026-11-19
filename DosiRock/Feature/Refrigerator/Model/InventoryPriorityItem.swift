//
//  InventoryPriorityItem.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

import Foundation


nonisolated struct InventoryPriorityItem : Identifiable , Hashable {
    
    var id: Int { ingredientId }
    let name : String
    let ingredientId: Int
    var quantity: Double 
    var unit: String  // 단위 (g, 개 ...)
    var expirationDate: Date
    var remainingDays : Int // 오늘 0일 최대 7
  
    var imageName: String { IngredientImageMap.assetName(for: name) }

    // 300g, 1.5개
    var quantityText: String {
        quantity.formatted(.number.grouping(.never).precision(.fractionLength(0...2))) + unit
    }
 
}
