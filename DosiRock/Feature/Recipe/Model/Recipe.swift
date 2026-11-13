//
//  Recipe.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

struct Recipe: Codable, Identifiable {
    let id: Int
    let name: String
    let cookTime: Int
    let ingredients: [Ingredient]
    let badges: [RecipeState]

    var subTitle: String {
        let names = ingredients.map(\.name).joined(separator: "·")
        return "\(cookTime)분 · \(names)"
    }

}

struct Ingredient: Codable, Identifiable {
    let code: String  // 이미지 찾기용
    let name: String  // 화면 표시용
    var id: String { code }
}
