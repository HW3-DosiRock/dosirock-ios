//
//  IngredientItem.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/15/26.
//

nonisolated struct IngredientItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String  // 에셋 폴더명과 동일
    let imageName: String  // 에셋 이름 그대로
}

nonisolated extension IngredientItem {
    static let samples: [IngredientItem] = [
        .init(
            id: "pork_belly",
            name: "삼겹살",
            category: "meat",
            imageName: "ingredient_meat_pork_belly"
        ),
        .init(
            id: "chicken",
            name: "닭고기",
            category: "meat",
            imageName: "ingredient_meat_chicken"
        ),
        .init(
            id: "enoki",
            name: "팽이버섯",
            category: "mushroom",
            imageName: "ingredient_mushroom_enoki"
        ),
        .init(
            id: "zucchini",
            name: "애호박",
            category: "vegetable",
            imageName: "ingredient_vegetable_zucchini"
        ),
    ]
}
