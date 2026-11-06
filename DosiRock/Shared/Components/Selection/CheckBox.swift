//
//  CheckBox.swift
//  DosiRock
//
//  Created by Admin on 11/4/26.
//

import SwiftUI

struct CheckBox: View {

    @Binding var isChecked: Bool
    let message: String
    var appFontStyle: AppTypography = .body

    var body: some View {

        Button {
            isChecked.toggle()
        } label: {
            HStack {

                //원형
                checkIcon
                    .frame(width: Size.Icon.large, height: Size.Icon.large)
                //라벨
                Text(message)
                    .appFont(appFontStyle)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.leading)
            }
            .frame(minHeight: Size.minTouch)
            .contentShape(Rectangle())  //  글자까지 눌리도록
        }
    }

    @ViewBuilder
    private var checkIcon: some View {
        if isChecked {
                Circle()
                    .fill(Color.appSuccess)                    // 배경 초록
                    .overlay(
                        Image("check-agree")
                            .renderingMode(.template)          // 색을 입히려면 필요
                            .resizable()
                            .scaledToFit()
                            .padding(Spacing.xs)               // 원 안쪽 여백
                            .foregroundStyle(Color.appSurface) // 체크 흰색
                            .accessibilityHidden(true)
                    )
            } else {
                Circle()
                    .fill(Color.appSurface)
                    .stroke(Color.appDisabled, lineWidth: 1)
            }
    }
}

#Preview {

    @Previewable @State var a = false
    @Previewable @State var b = false

    VStack(spacing: Spacing.l) {
        CheckBox(isChecked: $a, message: "만 14세 이상", appFontStyle: .heading)
        CheckBox(isChecked: $b, message: "전체 동의")
    }
    .padding()
    .background(Color.appBackground)

}
