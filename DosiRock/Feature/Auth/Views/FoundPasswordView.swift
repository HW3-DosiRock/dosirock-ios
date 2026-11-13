//
//  FoundPasswordView.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct FoundPasswordView: View {

    @State private var vm: FoundPasswordViewModel
    @Environment(Router<AuthRoute>.self) private var router

    init(vm: FoundPasswordViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        VStack {
            NavigationHeader(
                title: "비밀번호 찾기",
                leadingTitle: "로그인",
                trailingText:
                    "\(vm.step.rawValue + 1)/\(FoundPasswordViewModel.Step.allCases.count)",
                onLeadingTap: { router.pop() }
            )

            switch vm.step {
            case .email:
                EmailVerificationSection(flow: vm.flow)
            case .password:
                PasswordSection(
                    fields: vm.passwordFields,
                    title: "find_password_password_section_title",
                    submitError: vm.errorMessage,
                    timerText: vm.flow.remainingText  // 확인 후에도 최초 코드의 남은 시간을 보여줌
                )
            }

            Spacer()

            BottomActionBar(
                title: vm.step == .password
                    ? "find_password_button_complete" : "다음",
                isEnable: vm.canProceed,
                isLoading: vm.isLoading
            ) {
                Task { await vm.next() }
            }
        }
        .padding(Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .dismissKeyboardOnTap()
    }
}

#if DEBUG
#Preview {
    FoundPasswordView(vm: .init(service: MockAuthService()))
        .environment(Router<AuthRoute>())
}
#endif
