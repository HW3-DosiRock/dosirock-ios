//
//  TabMainHeader.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI
 
struct TabMainHeader: View {

    let title: String
    var actionTitle: String? = nil
    var actionIcon: String? = nil
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
        .padding(.horizontal, Spacing.screenHorizontal)
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        TabMainHeader(
            title: "이번 주",
            actionTitle: "추천 조건 변경",
            actionIcon: "slider.horizontal.3"
        ) {
            print("눌림")
        }
        TabMainHeader(title: "냉장고")
        TabMainHeader(title: "마이페이지")
    }
    .background(Color.appBackground)
}
