//
//  PrimaryButton.swift
//  cityStone
//
//  Created by Seungyeon Jeon on 11/2/26.
//

import SwiftUI

struct PrimaryButton: View {

    let title: LocalizedStringKey
    var icon: String? = nil
    var textColor: Color = .appSurface
    var bgColor: Color = .appPrimary
    var isEnable: Bool = true
    var isLoading: Bool = false
    let action: () -> Void

    private var isDisabled: Bool {
        !isEnable || isLoading
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    LoadingSpinner(
                        color: textColor,
                        size: Size.Spinner.small,
                        lineWidth: Size.Spinner.smallLineWidth
                    )
                } else if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }

        }
        .buttonStyle(
            PrimaryButtonStyle(
                textColor: textColor,
                bgColor: bgColor,
                isDisabled: isDisabled
            )
        )
        .disabled(isDisabled)
    }
}

private struct PrimaryButtonStyle: ButtonStyle {

    let textColor: Color
    let bgColor: Color
    let isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: Size.buttonHeight)
            .background(isDisabled ? bgColor.opacity(0.4) : bgColor)
            .overlay(
                Color.black.opacity(
                    configuration.isPressed && !isDisabled ? 0.2 : 0
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Radius.small))
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
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
