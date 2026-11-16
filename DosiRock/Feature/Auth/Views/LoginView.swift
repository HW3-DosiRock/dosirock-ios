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

    @Environment(Router<AuthRoute>.self) private var router
    @State private var vm: LoginViewModel

    init(vm: LoginViewModel) {
        _vm = State(initialValue: vm)
    }

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

            Text("login_header_title")
                .appFont(.brandTitle)
        }
    }

    private var loginSection: some View {

        VStack(spacing: Spacing.m) {

            InputTextField(
                label: "login_email_label",
                placeHolder: "login_email_placeholder",
                text: $vm.email,
                inputType: .email,
                labelColor: .appTextPrimary
            )

            InputTextField(
                label: "login_password_label",
                placeHolder: "login_password_placeholder",
                text: $vm.password,
                inputType: .password,
                errorMsg: vm.errorMessage,
                reserveMessageSpace: true,
                labelColor: .appTextPrimary
            )

            PrimaryButton(
                title: "login_button_submit",
                isEnable: vm.canSubmit,
                isLoading: vm.isLoading
            ) {
                Task {
                    await vm.login()
                }
            }
        }
    }

    private var footerSection: some View {
        HStack(spacing: Spacing.m) {
            TextLinkButton(
                title: "login_footer_find_password",
                textColor: .appPrimary,
                textStyle: .subbody
            ) {
                router.push(.findPassword)
            }

            Rectangle()
                .fill(Color.appPrimary.opacity(0.25))
                .frame(width: 1, height: 12)

            TextLinkButton(
                title: "login_footer_sign_up",
                textColor: .appPrimary,
                textStyle: .subbody
            ) {
                router.push(.signUp)
            }
        }
    }
}

#if DEBUG
#Preview("성공") {
    LoginView(vm: .init(service: MockAuthService(scenario: .success)))
        .environment(Router<AuthRoute>())
}
#Preview("실패") {
    LoginView(
        vm: .init(
            service: MockAuthService(
                scenario: .failure(AuthError.invalidCredentials)
            )
        )
    )
    .environment(Router<AuthRoute>())
}
#endif
