//
//  InfoBanner.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

enum BannerType {
    case info  //정보
    case success  //성공
    case attention  //오류

    var foreground: Color {
        switch self {
        case .info: .appInfo
        case .success: .appSuccess
        case .attention: .appAttention
        }
    }

    var background: Color {
        switch self {
        case .info: .appSuccessBackground
        case .success: .appSuccessBackground
        case .attention: .appAttentionBackground
        }
    }

    var icon: String {
        switch self {
        case .info: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        case .attention: "exclamationmark.triangle.fill"
        }
    }
}

struct AppBanner: View {

    let type: BannerType
    let message: String
    var actionMessage: LocalizedStringKey? = nil
    var action: () -> Void = {}

    var body: some View {

        VStack(alignment: .leading) {

            //title
            HStack(alignment: .top, spacing: Spacing.s) {
                Image(systemName: type.icon)
                    .foregroundStyle(type.foreground)

                Text(message)
                    .foregroundStyle(type.foreground)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)  // 긴 문구는 줄바꿈
            }

            //Action
            if let actionMessage {
                TextLinkButton(
                    title: actionMessage,
                    textColor: .appPrimary,
                    textStyle: .subbody
                ) {
                    action()
                }
            }
        }
        .appFont(.subbody)
        .padding(Spacing.m)
        .background(type.background)
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
    
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        AppBanner(
            type: .info,
            message: "재료를 추가하면 추천이 더 정확해져요",
            actionMessage: "이번주 메뉴 제안받기"
        )
        AppBanner(type: .success, message: "이번 주 식단이 저장됐어요")
        AppBanner(type: .attention, message: "네트워크 연결을 확인해주세요")
        AppBanner(
            type: .attention,
            message: "문구가 길어지면 이렇게 자동으로 줄바꿈이 되면서 아래로 늘어나요. 아이콘은 첫 줄에 맞춰져요."
        )
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}
