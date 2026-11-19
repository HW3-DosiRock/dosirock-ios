//
//  ListRow.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

/// 재료/레시피 목록 한 줄의 내용(아이콘 · 제목 · 부제 · 뱃지 · 화살표).
/// 배경·테두리·탭 처리는 하지 않는다 → 호출하는 쪽에서 Button, 카드, 묶음 카드로 감싼다.
struct ListRow<Badges: View>: View {

    enum BadgePlacement {
        case below     // 텍스트 아래 (레시피 카드)
        case trailing  // 화살표 앞 오른쪽 (냉장고 재료 행)
    }

    let iconCodes: [String]  // 재료 이미지 코드 (최대 2개 표시)
    let title: String
    let subtitle: String
    var badgePlacement: BadgePlacement = .below
    var showsChevron: Bool = true
    @ViewBuilder var badges: () -> Badges

    var body: some View {
        // 글자·뱃지·화살표 사이는 좁게(m) 해서 부제목 폭을 확보, 아이콘과 글자 사이만 넓게(xl) 유지
        HStack(spacing: Spacing.m) {

            // 아이콘 (개수와 무관하게 너비 고정 → 텍스트 시작 위치 일정)
            VStack {
                ForEach(Array(iconCodes.prefix(2).enumerated()), id: \.offset) {
                    _, code in
                    IngredientImage(code: code, size: Size.Icon.large)
                }
            }
            .frame(width: Size.Icon.large)
            .padding(.trailing, Spacing.xl - Spacing.m)

            // 제목 · 부제 (· 뱃지)
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(title)
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                Text(subtitle)
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)  // 목록 줄 높이를 맞추려고 한 줄 고정
                    .minimumScaleFactor(0.85)  // 넘칠 때만 최대 15% 작게 (문구는 줄이지 않음)

                if badgePlacement == .below {
                    HStack { badges() }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if badgePlacement == .trailing {
                HStack { badges() }
            }

            if showsChevron {
                Image("chevron-right")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Size.Icon.medium, height: Size.Icon.medium)
                    .foregroundStyle(Color.appDisabled)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// 뱃지가 없는 경우
extension ListRow where Badges == EmptyView {
    init(
        iconCodes: [String],
        title: String,
        subtitle: String,
        showsChevron: Bool = true
    ) {
        self.init(
            iconCodes: iconCodes,
            title: title,
            subtitle: subtitle,
            showsChevron: showsChevron
        ) { EmptyView() }
    }
}

#Preview {
    VStack(spacing: Spacing.l) {
        ListRow(
            iconCodes: ["ingredient_vegetable_carrot"],
            title: "당근",
            subtitle: "120g · 권장 사용일 11/18(수)",
            badgePlacement: .trailing
        ) {
            RecipeBadge(type: .tomorrow)
        }
        // 긴 부제목 (냉장고 빨리 써야 할 재료)
        ListRow(
            iconCodes: ["ingredient_vegetable_carrot"],
            title: "우유",
            subtitle: "1000ml · 소비기한 11/22(토)",
            badgePlacement: .trailing
        ) {
            RecipeBadge(type: .tomorrow, title: "3일 안에")
        }
        ListRow(
            iconCodes: ["ingredient_vegetable_carrot", "ingredient_vegetable_carrot"],
            title: "당근볶음",
            subtitle: "15분 · 당근 · 양파"
        ) {
            RecipeBadge(type: .useSoon)
        }
        ListRow(
            iconCodes: ["ingredient_vegetable_carrot"],
            title: "당근",
            subtitle: "뱃지 없음"
        )
    }
    .padding(Spacing.l)
    .background(Color.appSurface)
}

#Preview("큰 글자") {
    ListRow(
        iconCodes: ["ingredient_vegetable_carrot"],
        title: "우유",
        subtitle: "1000ml · 소비기한 11/22(토)",
        badgePlacement: .trailing
    ) {
        RecipeBadge(type: .tomorrow, title: "3일 안에")
    }
    .padding(Spacing.l)
    .background(Color.appSurface)
    .environment(\.dynamicTypeSize, .xxxLarge)
}
