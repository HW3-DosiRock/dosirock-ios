//
//  TabMainHeader.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI
 
struct TabMainHeader: View {

    let title: LocalizedStringResource
    var actionTitle: LocalizedStringResource? = nil
    var actionIcon: ImageResource? = nil
    var action: () -> Void = {}

    var body: some View {
        HStack {
            Text(title)
                .appFont(.brandTitle)
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let actionTitle {
                TextLinkButton(
                    title: actionTitle,
                    icon: actionIcon,
                    textColor: .appTextSecondary,
                    action: action
                )
            }
        }
        // 좌우 여백은 쓰는 화면이 준다 (탭 화면은 바깥에 이미 Spacing.screenHorizontal이 있음)
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        TabMainHeader(
            title: "이번주",
            actionTitle: "추천 조건 변경",
            actionIcon: .sliders
        ) {
            print("눌림")
        }
        TabMainHeader(title: "냉장고")
        TabMainHeader(title: "마이페이지")
    }
    .padding(.horizontal, Spacing.screenHorizontal)
    .background(Color.appBackground)
}
