//
//  IngredientImage.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI
import UIKit

struct IngredientImage: View {

    let code: String                      // 서버에서 받은 재료 코드
    var size: CGFloat = Size.Icon.xLarge

    private var image: Image {
        if UIImage(named: code) != nil {
            return Image(code)
        }
        return Image(systemName: "questionmark.circle")   // 없는 코드 → 대체
    }

    var body: some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(Color.appDisabled)            // 대체 아이콘일 때만 적용됨
    }
}

#Preview {
    HStack(spacing: Spacing.l) {
        IngredientImage(code: "ingredient_vegetable_carrot")
        IngredientImage(code: "없는코드")
    }
}
