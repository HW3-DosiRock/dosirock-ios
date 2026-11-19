//
//  InventoryItem.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

import Foundation

// TODO 명세 나오면 수정 예정
nonisolated struct InventoryItem : Identifiable , Hashable {
    
    var id: Int { ingredientId }
    let name : String
    let ingredientId: Int
    var quantity: Double? = nil  // 보유 수량 (기본 재료는 nil) / TODO 명세 나오면 확정
    var unit: String = ""  // 단위 (g, 개 ...) / TODO 명세 나오면 확정
    var managementType: IngredientItem.ManagementType = .quantity  // 수량 재료 / 기본 재료 구분
    var recommendedDate: Date? = nil  // 권장 사용일 / TODO 명세 나오면 확정

    // 오늘부터 권장 사용일까지 남은 일수 (0 = 오늘, 1 = 내일, 지났으면 음수)
    func daysUntilRecommended(from today: Date = Date()) -> Int? {
        guard let recommendedDate else { return nil }
        let cal = Calendar.current
        return cal.dateComponents(
            [.day],
            from: cal.startOfDay(for: today),
            to: cal.startOfDay(for: recommendedDate)
        ).day
    }

    var imageName: String { IngredientImageMap.assetName(for: name) }

    // 타일에 보여줄 수량 글자: 300g, 1.5개 (수량이 없으면 nil)
    var quantityText: String? {
        guard let quantity else { return nil }
        return quantity.formatted(.number.grouping(.never).precision(.fractionLength(0...2))) + unit
    }
}
