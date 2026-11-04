//
//  IngredientTile.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

struct IngredientTile: View {

    let label: String
    let imageName: String
    var isChecked: Bool = false
    var action: () -> Void = {}

    // 에셋에 있으면 그 이름, 없으면 기본 그림
    private var resolvedImage: Image {
        if UIImage(named: imageName) != nil {
            return Image(imageName)
        }
        return Image(systemName: "questionmark.circle")  // 대체 이미지 (임시)
    }

    var body: some View {

        Button(action: action) {
            VStack(spacing: Spacing.s) {
                resolvedImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: Size.Icon.xLarge, height: Size.Icon.xLarge)
                    .foregroundStyle(Color.appDisabled)

                Text(label)
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
            }
            .padding(Spacing.m)
            .frame(maxWidth: .infinity)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.medium)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
            .overlay(alignment: .topTrailing) {
                if isChecked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: Size.Icon.medium))
                        .foregroundStyle(Color.appSurface, Color.appSuccess)
                        .padding(Spacing.s)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeOut(duration: 0.15), value: isChecked)
        }
        .buttonStyle(TilePressStyle())
    }
    
}

#Preview {
    @Previewable @State var selected: Set<String> = [
        "ingredient_vegetable_carrot"
    ]

    let items = [
        ("당근", "ingredient_vegetable_carrot"),
        ("애호박", "ingredient_vegetable_zucchini"),
        ("알 수 없음", "dragonfruit"),
    ]

    LazyVGrid(
        columns: Array(
            repeating: GridItem(.flexible(), spacing: Spacing.s),
            count: 3
        ),
        spacing: Spacing.s
    ) {
        ForEach(items, id: \.1) { name, code in
            IngredientTile(
                label: name,
                imageName: code,
                isChecked: selected.contains(code)
            ) {
                if selected.contains(code) {
                    selected.remove(code)
                } else {
                    selected.insert(code)
                }
            }
        }
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}
