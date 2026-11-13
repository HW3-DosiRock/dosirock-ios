//
//  RecipeCard.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

struct RecipeCard: View {

    let recipe: Recipe
    var isDone: Bool = false
    var action: () -> Void = {}

    var body: some View {

        Button(action: action) {
            row
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isDone ? Color.appBorder : Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.medium)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
        }
        .buttonStyle(TilePressStyle())
        .accessibilityElement(children: .combine)  //보이스오버가 한번에 읽도록 (접근성)
    }

    // 완료 상태에서는 뱃지를 숨긴다 (빈 뱃지 영역이 간격을 만들지 않도록 분기)
    @ViewBuilder
    private var row: some View {
        let codes = recipe.ingredients.map(\.code)
        if isDone {
            ListRow(
                iconCodes: codes,
                title: recipe.name,
                subtitle: recipe.subTitle
            )
        } else {
            ListRow(
                iconCodes: codes,
                title: recipe.name,
                subtitle: recipe.subTitle
            ) {
                ForEach(recipe.badges, id: \.self) { RecipeBadge(type: $0) }
            }
        }
    }
}

#Preview {

    VStack {
        RecipeCard(
            recipe: Recipe(
                id: 0,
                name: "당근볶음",
                cookTime: 15,
                ingredients: [
                    Ingredient(
                        code: "ingredient_vegetable_carrot",
                        name: "당근"
                    ),
                    Ingredient(
                        code: "ingredient_vegetable_carrot",
                        name: "당근"
                    ),
                ],
                badges: [RecipeState.useSoon]
            ),
            isDone: true
        )

        RecipeCard(
            recipe: Recipe(
                id: 0,
                name: "당근볶음",
                cookTime: 15,
                ingredients: [
                    Ingredient(
                        code: "ingredient_vegetable_carrot",
                        name: "당근"
                    ),
                ],
                badges: [RecipeState.useSoon]
            ),
            isDone: false
        )
        
        RecipeCard(
            recipe: Recipe(
                id: 0,
                name: "당근볶음",
                cookTime: 15,
                ingredients: [
                    Ingredient(
                        code: "ingredient_vegetable_carrot",
                        name: "당근"
                    ),
                    Ingredient(
                        code: "ingredient_vegetable_carrot",
                        name: "당근"
                    ),
                ],
                badges: [RecipeState.useSoon]
            ),
            isDone: false
        )
    }
    .padding()
}
