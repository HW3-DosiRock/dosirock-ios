//
//  TabSkeletonView.swift
//  DosiRock
//
//  Created by Admin on 11/18/26.
//

import SwiftUI

/// 탭 화면 공통 스켈레톤 (불러오는 중 자리표시).
/// 탭 제목은 바깥 화면이 그리고, 이 뷰는 그 아래 내용 자리만 채운다.
struct TabSkeletonView: View {

    var cardCount: Int = 3  // 탭마다 카드 개수만 바꿔서 사용

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {

            // 소제목 줄 (예: "11월 16일~20일 도시락")
            SkeletonBlock(width: 160, height: 20)
                .padding(.bottom, Spacing.s)

            // 카드들
            ForEach(0..<cardCount, id: \.self) { _ in
                SkeletonBlock(height: 120, cornerRadius: Radius.large)
            }
        }
        .shimmer()  // 묶음 전체에 한 번 (maxHeight frame보다 먼저)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(.commonLoading))
    }
}

#Preview {
    TabSkeletonView()
        .padding(Spacing.screenHorizontal)
        .background(Color.appBackground)
}

#Preview("카드 1개") {
    TabSkeletonView(cardCount: 1)
        .padding(Spacing.screenHorizontal)
        .background(Color.appBackground)
}
