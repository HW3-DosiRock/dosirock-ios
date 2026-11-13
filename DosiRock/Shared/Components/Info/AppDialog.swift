//
//  AppDialog.swift
//  DosiRock
//
//  Created by Admin on 11/11/26.
//

import SwiftUI

// 제목 + 안내 문구 + 가로 2버튼(왼쪽: 취소 성격, 오른쪽: 확정 성격) 다이얼로그
struct AppDialog: View {

    let title: LocalizedStringKey
    let message: LocalizedStringKey
    let cancelTitle: LocalizedStringKey
    let confirmTitle: LocalizedStringKey
    var isDestructive = true  // 오른쪽 버튼을 경고색으로
    var onCancel: () -> Void = {}
    var onConfirm: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: Spacing.s) {
                Text(title)
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)
                Text(message)
                    .appFont(.body)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.xl)

            Divider().overlay(Color.appBorder)

            HStack(spacing: 0) {
                button(cancelTitle, color: .appPrimary, action: onCancel)
                Divider().overlay(Color.appBorder)
                button(
                    confirmTitle,
                    color: isDestructive ? .appAttention : .appPrimary,
                    action: onConfirm
                )
            }
            .frame(height: Size.buttonHeight)
        }
        .background(
            Color.appSurface,
            in: RoundedRectangle(cornerRadius: Radius.large)
        )
    }

    private func button(
        _ title: LocalizedStringKey,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .appFont(.heading)
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension View {
    /// 화면 위에 딤 + 다이얼로그를 띄움. 어느 버튼이든 누르면 먼저 닫힘.
    func appDialog(
        isPresented: Binding<Bool>,
        title: LocalizedStringKey,
        message: LocalizedStringKey,
        cancelTitle: LocalizedStringKey,
        confirmTitle: LocalizedStringKey,
        isDestructive: Bool = true,
        onConfirm: @escaping () -> Void
    ) -> some View {
        overlay {
            if isPresented.wrappedValue {
                ZStack {
                    Color.appDim
                        .ignoresSafeArea()
                        .onTapGesture {}  // 뒤 화면 탭 막기

                    AppDialog(
                        title: title,
                        message: message,
                        cancelTitle: cancelTitle,
                        confirmTitle: confirmTitle,
                        isDestructive: isDestructive,
                        onCancel: { isPresented.wrappedValue = false },
                        onConfirm: {
                            isPresented.wrappedValue = false
                            onConfirm()
                        }
                    )
                    .padding(.horizontal, Spacing.xl * 2)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.2), value: isPresented.wrappedValue)
    }
}

#Preview {
    AppDialog(
        title: "회원가입을 그만둘까요?",
        message: "입력한 내용은 저장되지 않아요.",
        cancelTitle: "계속 입력",
        confirmTitle: "나가기"
    )
    .padding(Spacing.xl * 2)
    .background(Color.appBackground)
}
