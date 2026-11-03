//
//  PrimaryButton.swift
//  cityStone
//
//  Created by Seungyeon Jeon on 11/2/26.
//

import SwiftUI

struct TextLink: View {

    let title: String
    var icon: String? = nil
    var textColor: Color = .appSurface
    var bgColor: Color = .appPrimary
    var isEnable: Bool = true
    let action: () -> Void

    private var isDisabled: Bool {
        !isEnable
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.headline)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isDisabled ? bgColor.opacity(0.4) : bgColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack {
        PrimaryButton(title: "시작하기") {}
        PrimaryButton(title: "좋아요", icon: "heart.fill") {}
        PrimaryButton(title: "저장 중...", isLoading: true) {}
        PrimaryButton(title: "다음", isEnable: false, isLoading: false) {}
        PrimaryButton(
            title: "다음",
            textColor: Color.appSuccess,
            bgColor: .appAttention,
            isEnable: false,
            isLoading: false
        ) {}
    }
    .padding()
}
