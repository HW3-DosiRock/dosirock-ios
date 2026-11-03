//
//  PrimaryButton.swift
//  cityStone
//
//  Created by Seungyeon Jeon on 11/2/26.
//

import SwiftUI

struct TextLinkButton: View {

    let title: String
    var icon: String? = nil
    var textColor: Color = .appSurface
    var textStyle : AppTypography = .body
    var bgColor: Color = .appPrimary
    var isEnable: Bool = true
    let action: () -> Void

    private var isDisabled: Bool {
        !isEnable
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .appFont(textStyle)
            .foregroundStyle(isEnable ? textColor : Color.appDisabled)
            .frame(height: Size.minTouch)
            .contentShape(Rectangle())  // 글자 사이 빈 곳도 눌리도록
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.s) {
        TextLinkButton(title: "비밀번호를 잊으셨나요?") {}
        TextLinkButton(title: "전체 보기", icon: "chevron.right", textColor: .appTextSecondary, textStyle: .caption) {}
        TextLinkButton(title: "회원 탈퇴", textColor: .appAttention) {}
        TextLinkButton(title: "비활성 링크", isEnable: false) {}
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}
