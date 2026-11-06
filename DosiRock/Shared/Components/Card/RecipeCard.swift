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
            HStack(spacing: Spacing.xl) {

                //아이콘(최대 2개)
                VStack {
                    ForEach(recipe.ingredients.prefix(2)) { ingredient in
                        IngredientImage(
                            code: ingredient.code,
                            size: Size.Icon.large
                        )
                    }
                }
                //정보 (이름 , 시간 , 메인 재료 , 밷지)
                VStack(alignment: .leading, spacing: Spacing.s) {
                    Text(recipe.name)
                        .appFont(.heading)
                        .lineLimit(1)
                        .foregroundStyle(Color.appTextPrimary)
                    Text(recipe.subTitle)
                        .appFont(.subbody)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)

                    if isDone {
                        HStack {
                            ForEach(recipe.badges, id: \.self) {
                                RecipeBadge(type: $0)
                            }
                        }
                    }

                }
                Spacer()
                //arrow
                Image(systemName: "chevron.right")
                    .font(
                        .system(size: Size.Icon.medium * 0.7, weight: .semibold)
                    )
                    .foregroundStyle(Color.appDisabled)
                    .accessibilityHidden(true)

            }
            .padding(Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isDone ? Color.appSurface : Color.appBorder)
            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.medium)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
        }
        .buttonStyle(TilePressStyle())
        .accessibilityElement(children: .combine)   //보이스오버가 한번에 읽도록 (접근성)
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
