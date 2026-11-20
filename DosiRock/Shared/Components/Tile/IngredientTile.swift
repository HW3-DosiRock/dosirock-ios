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
    var subLabel: String? = nil  // 이름 바로 아래 작은 글씨 (예: 삼겹살 / 수입)
    var reservesNameSpace = false  // true면 이름 두 줄 자리를 항상 확보 (그리드에서 높이를 맞출 때)
    var details: [String] = []  // 이름 아래 보조 텍스트 (예: "300g", "사용 11/10(화)")
    var badge: RecipeBadge? = nil  // 맨 아래 상태 뱃지 (예: 레시피 재료의 충분 · 보유 · 부족 · 사용함)
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

    // 이름 영역: 보조 글씨가 없고 자리를 확보하는 타일만 이름을 두 줄까지 허용
    private var nameBlock: some View {
        ZStack(alignment: .top) {
            if reservesNameSpace {
                Text("가\n가")  // 보이지 않는 두 줄: 글자 크기 설정이 바뀌어도 자리가 따라감
                    .appFont(.subbody)
                    .hidden()
            }
            VStack(spacing: 0) {
                Text(label)
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(reservesNameSpace && subLabel == nil ? 2 : 1)
                if let subLabel {
                    Text(subLabel)
                        .appFont(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                }
            }
        }
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
                nameBlock

                ForEach(details, id: \.self) { detail in
                    Text(detail)
                        .appFont(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                }
            }

            if let badge { badge }
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
        ("돼지 앞다리살", "ingredient_vegetable_carrot"),
        ("느타리\n버섯", "ingredient_vegetable_carrot"),
        ("삼겹살", "ingredient_vegetable_carrot"),
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
                    subLabel: name == "삼겹살" ? "수입" : nil,
                    reservesNameSpace: true,
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
