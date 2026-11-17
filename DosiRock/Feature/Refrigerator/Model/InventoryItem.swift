//
//  InventoryItem.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

import Foundation

// TODO 명세 나오면 수정 예정
nonisolated struct InventoryItem : Identifiable , Hashable {
    let id : String
    let name : String
    let ingredientId: Int
    var quantity: Double? = nil  // 보유 수량 (기본 재료는 nil) / TODO 명세 나오면 확정
    var unit: String = ""  // 단위 (g, 개 ...) / TODO 명세 나오면 확정
    var managementType: IngredientItem.ManagementType = .quantity  // 수량 재료 / 기본 재료 구분

    var imageName: String { IngredientImageMap.assetName(for: name) }

    // 타일에 보여줄 수량 글자: 300g, 1.5개 (수량이 없으면 nil)
    var quantityText: String? {
        guard let quantity else { return nil }
        return quantity.formatted(.number.grouping(.never).precision(.fractionLength(0...2))) + unit
    }
}
