//
//  IngredientPickerViewModel.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/15/26.
//

import Foundation

@Observable @MainActor
final class IngredientPickerViewModel {
    var ingredients: [IngredientItem]
    var query = ""

    init(ingredients: [IngredientItem] = IngredientItem.samples) {
        self.ingredients = ingredients
    }

    private var filtered: [IngredientItem] {
        // 자모로 풀어서 비교: "ㅍ", "패", "팽" 모두 "팽이버섯"에 매치
        let q = query.decomposedStringWithCompatibilityMapping
        return query.isEmpty
            ? ingredients
            : ingredients.filter {
                $0.name.decomposedStringWithCompatibilityMapping
                    .range(of: q, options: .literal) != nil
            }
    }
    var isEmptyResult: Bool { filtered.isEmpty }

    var grouped: [(category: String, items: [IngredientItem])] {
        Dictionary(grouping: filtered, by: \.category)
            .map { (category: $0.key, items: $0.value) }
            .sorted { $0.category < $1.category }
    }
}
