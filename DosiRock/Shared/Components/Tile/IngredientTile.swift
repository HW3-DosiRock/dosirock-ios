//
//  IngredientTile.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

/// 타일 종류. 종류별 차이(색, 클릭 여부, 체크 표시)는 여기 한 곳에서만 정의한다.
enum IngredientTileType {
    case selectable  // 눌러서 선택, 체크 표시
    case info        // 표시 전용 (클릭 없음)
    case shortage    // 표시 전용 + 부족 강조색

    var background: Color {
        switch self {
        case .selectable, .info: .appSurface
        case .shortage: .appAttentionBackground
        }
    }

    var border: Color {
        switch self {
        case .selectable, .info: .appBorder
        case .shortage: .appAttentionBorder
        }
    }

    var isInteractive: Bool { self == .selectable }
    var showsCheck: Bool { self == .selectable }
}

struct IngredientTile: View {

    let label: String
    let imageName: String
    var details: [String] = []  // 이름 아래 보조 텍스트 (예: "300g", "사용 11/10(화)")
    var type: IngredientTileType = .selectable
    var isChecked: Bool = false  // selectable 에서만 의미 있음
    var action: () -> Void = {}  // selectable 에서만 의미 있음

    // 에셋에 있으면 그 이름, 없으면 기본 그림
    private var resolvedImage: Image {
        if UIImage(named: imageName) != nil {
            return Image(imageName)
        }
        return Image(systemName: "questionmark.circle")  // 대체 이미지 (임시)
    }

    var body: some View {
        if type.isInteractive {
            Button(action: action) { card }
                .buttonStyle(TilePressStyle())
        } else {
            card
        }
    }

    private var card: some View {
        VStack(spacing: Spacing.s) {
            resolvedImage
                .resizable()
                .scaledToFit()
                .frame(width: Size.Icon.xLarge, height: Size.Icon.xLarge)
                .foregroundStyle(Color.appDisabled)

            VStack(spacing: Spacing.xs) {
                Text(label)
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                ForEach(details, id: \.self) { detail in
                    Text(detail)
                        .appFont(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity)
        .background(type.background)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.medium)
                .stroke(type.border, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            if type.showsCheck && isChecked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: Size.Icon.medium))
                    .foregroundStyle(Color.appSurface, Color.appSuccess)
                    .padding(Spacing.s)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.15), value: isChecked)
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

    VStack(spacing: Spacing.l) {
        // 선택용
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
                    details: name == "당근" ? ["120g", "사용 11/18(수)"] : [],
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

        // 표시 전용 (일반 / 부족)
        HStack(spacing: Spacing.s) {
            IngredientTile(
                label: "다진 마늘",
                imageName: "ingredient_vegetable_carrot",
                details: ["1작은술"],
                type: .info
            )
            IngredientTile(
                label: "배추",
                imageName: "ingredient_vegetable_carrot",
                details: ["0.2포기"],
                type: .shortage
            )
        }
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}
