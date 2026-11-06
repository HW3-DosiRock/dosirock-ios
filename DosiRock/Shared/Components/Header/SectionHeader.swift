//
//  SectionHeader.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

/// 섹션 제목 줄. 왼쪽 제목(+개수), 오른쪽 보조 설명.
/// 예) "수량 7        눌러서 수량 추가·수정"
struct SectionHeader: View {

    let title: String
    var count: Int? = nil
    var caption: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
            Text(title)
                .appFont(.heading)
                .foregroundStyle(Color.appTextPrimary)

            if let count {
                Text("\(count)")
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer(minLength: Spacing.s)

            if let caption {
                Text(caption)
                    .appFont(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    VStack(spacing: Spacing.xl) {
        SectionHeader(title: "빨리 써야 할 재료", caption: "권장 사용일이 가까운 순")
        SectionHeader(title: "수량", count: 7, caption: "눌러서 수량 추가·수정")
        SectionHeader(title: "기본 재료", count: 3)
    }
    .padding(.horizontal, Spacing.screenHorizontal)
    .background(Color.appBackground)
}
