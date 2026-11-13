//
//  BottomActionBar.swift
//  DosiRock
//
//  Created by Admin on 11/13/26.
//

import SwiftUI

// 화면 하단의 "구분선 + 버튼" 영역.
// 부모가 .padding(Spacing.screenHorizontal)을 준 화면에서 쓴다 (구분선만 그 여백을 상쇄해서 화면 끝까지 늘림)
struct BottomActionBar: View {

    let title: LocalizedStringKey
    var isEnable: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.appBorder)
                .frame(height: 1)
                .padding(.horizontal, -Spacing.screenHorizontal)  // 바깥 좌우 패딩을 상쇄해서 화면 끝까지 늘림
                .padding(.bottom, Spacing.l)  // 선과 버튼 사이 간격

            PrimaryButton(
                title: title,
                isEnable: isEnable,
                isLoading: isLoading,
                action: action
            )
        }
    }
}

#Preview {
    VStack {
        Spacer()
        BottomActionBar(title: "다음") {}
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}
