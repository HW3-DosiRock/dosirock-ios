//
//  LoadFailedView.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/18/26.
//

import SwiftUI

/// 탭 화면에서 데이터를 불러오지 못했을 때 (경고 아이콘 + 제목 + 안내 + 다시 시도).
/// 탭마다 제목만 바꿔서 쓴다. 예) "이번 주 정보를 불러오지 못했어요"
struct LoadFailedView: View {

    let title: LocalizedStringResource
    var message: LocalizedStringResource = .commonLoadFailedDesc
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: Spacing.s) {
            AppIcon(.alert, size: Size.Icon.xLarge)
                .foregroundStyle(Color.appAttention)

            Text(title)
                .appFont(.brandSubtitle)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)

            Text(message)
                .appFont(.subbody)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)

            PrimaryButton(title: .commonRetry, action: onRetry)
                .frame(width: 120)  // 화면 폭이 아니라 버튼 크기만큼
                .padding(.top, Spacing.m)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadFailedView(title: .thisweekLoadFailed) {}
        .padding(Spacing.screenHorizontal)
        .background(Color.appBackground)
}
