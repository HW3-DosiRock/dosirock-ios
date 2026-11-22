//
//  WithdrawCompleteView.swift
//  DosiRock
//

import SwiftUI

// A-08 탈퇴 완료: 탈퇴가 끝난 뒤 보여주고, "확인"을 누르면 로그인 화면으로 돌아간다
struct WithdrawCompleteView: View {

    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            Spacer()

            VStack(spacing: Spacing.l) {
                Image(.logoStone)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104)
                    .accessibilityHidden(true)

                VStack(spacing: Spacing.s) {
                    Text(.myWithdrawDoneTitle)
                        .appFont(.brandSubtitle)
                        .foregroundStyle(Color.appTextPrimary)
                    Text(.myWithdrawDoneMessage)
                        .appFont(.subbody)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            PrimaryButton(title: .myWithdrawDoneConfirm, action: onConfirm)
                .padding(.bottom, Spacing.l)
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

#if DEBUG
    #Preview {
        WithdrawCompleteView {}
    }
#endif
