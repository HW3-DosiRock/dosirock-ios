//
//  GroupedListCard.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

/// 여러 줄을 하나의 카드로 묶고, 줄 사이에 구분선을 그리는 컨테이너.
/// 줄 안쪽 디자인은 호출하는 쪽이 정한다. (iOS 17 호환: 데이터 배열을 받는 방식)
struct GroupedListCard<Data: RandomAccessCollection, Row: View>: View
where Data.Element: Identifiable {

    let items: Data
    @ViewBuilder var row: (Data.Element) -> Row

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                row(item)
                    .padding(Spacing.l)

                // 마지막 줄 뒤에는 구분선 없음
                if item.id != items.last?.id {
                    Rectangle()
                        .fill(Color.appBorder)
                        .frame(height: 1)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.appSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.medium)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }
}

#Preview {
    let ingredients = [
        Ingredient(code: "ingredient_vegetable_carrot", name: "당근"),
        Ingredient(code: "ingredient_vegetable_onion", name: "양파"),
        Ingredient(code: "ingredient_vegetable_leek", name: "대파"),
    ]

    VStack(spacing: Spacing.l) {
        GroupedListCard(items: ingredients) { ingredient in
            ListRow(
                iconCodes: [ingredient.code],
                title: ingredient.name,
                subtitle: "120g"
            )
        }

        // 줄이 하나일 때: 구분선 없음
        GroupedListCard(items: Array(ingredients.prefix(1))) { ingredient in
            ListRow(
                iconCodes: [ingredient.code],
                title: ingredient.name,
                subtitle: "120g"
            )
        }
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}
