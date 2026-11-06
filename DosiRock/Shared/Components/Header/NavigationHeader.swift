//
//  NavigationHeader.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

struct NavigationHeader: View {

    let title: String
    var leadingTitle: String? = nil  // "마이페이지" / "이전" / "닫기" / "취소"
    var showsBackIcon: Bool = true  // 닫기·취소는 false
    var trailingText: String? = nil  // "2/4" 등
    var titleStyle: AppTypography = .brandSubtitle
    var onLeadingTap: () -> Void = {}

    var body: some View {

        ZStack {

            Text(title)
                .appFont(titleStyle)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            HStack {
                leadingButton
                Spacer()
                trailingView
            }

        }
        .frame(minHeight: Size.minTouch)
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.vertical, Spacing.s)
    }

    @ViewBuilder
    private var leadingButton: some View {
        if let leadingTitle {
            TextLinkButton(
                title: leadingTitle,
                icon: showsBackIcon ? "chevron.left" : nil,
                textColor: .appTextSecondary,
                textStyle: .body,
                action: onLeadingTap
            )
        }
    }

    @ViewBuilder
    private var trailingView: some View {
        if let trailingText {
            Text(trailingText)
                .appFont(.subbody)
                .foregroundStyle(Color.appTextSecondary)
        }
    }

}

#Preview {
    VStack(spacing: Spacing.l) {
        // 상세 헤더
        NavigationHeader(
            title: "프로필 수정",
            leadingTitle: "마이페이지"
        )

        // 단계 헤더 (진행 바는 아래에 따로 붙일 예정)
        NavigationHeader(
            title: "회원가입",
            leadingTitle: "이전",
            trailingText: "2/4",
        )

        // 시트 헤더
        NavigationHeader(
            title: "재료 선택",
            leadingTitle: "닫기",
            showsBackIcon: false,
            titleStyle: .heading,
        )
    }
    .background(Color.appBackground)
}
