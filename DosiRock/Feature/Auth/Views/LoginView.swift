//
//  LoginView.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct LoginView: View {

    private enum Layout {
        static let logoTop: CGFloat = 90
        static let logoWidth: CGFloat = 72
    }

    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {

        VStack(spacing: Spacing.m) {
            logoSection
            loginSection
            footerSection

        }
        .padding(.horizontal, Spacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())

    }

    private var logoSection: some View {

        VStack {
            Image("logo-stone")
                .resizable()
                .scaledToFit()
                .frame(width: Layout.logoWidth)
                .padding(.bottom, Spacing.xs)

            Text("도시의 돌멩이")
                .appFont(.brandTitle)
        }
    }

    private var loginSection: some View {

        VStack(spacing: Spacing.m) {

            InputTextField(
                label: "이메일",
                placeHolder: "이메일을 입력해주세요",
                text: $email,
                inputType: .email,
                labelColor: .appTextPrimary
            )

            InputTextField(
                label: "비밀번호",
                placeHolder: "비밀번호를 입력해주세요",
                text: $password,
                inputType: .password,
                labelColor: .appTextPrimary
            )

            PrimaryButton(title: "로그인") {
                //todo
            }
        }
    }

    private var footerSection: some View {
        HStack(spacing: Spacing.m) {
            TextLinkButton(
                title: "비밀번호 찾기",
                textColor: .appPrimary,
                textStyle: .subbody
            ) {
                //todo
            }

            Rectangle()
                .fill(Color.appPrimary.opacity(0.25))
                .frame(width: 1, height: 12)

            TextLinkButton(
                title: "회원가입",
                textColor: .appPrimary,
                textStyle: .subbody
            ) {
                //todo
            }
        }
        .frame(width: .infinity)
    }
}

#Preview {
    LoginView()
}
