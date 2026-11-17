//
//  InventoryItem.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

// TODO 명세 나오면 수정 예정
nonisolated struct InventoryItem : Identifiable , Hashable {
    let id : String
    let name : String
    let ingredientId: Int
    var quantity: Double? = nil  // 보유 수량 (기본 재료는 nil) / TODO 명세 나오면 확정
}
