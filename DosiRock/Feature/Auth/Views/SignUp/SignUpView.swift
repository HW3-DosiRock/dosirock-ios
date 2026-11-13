//
//  SignUpView.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct SignUpView: View {

    @Environment(Router<AuthRoute>.self) private var router
    @State private var vm: SignUpViewModel
    @State private var showExitDialog = false

    init(vm: SignUpViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        VStack() {
            NavigationHeader(
                title: "sign_up_header_title",
                leadingTitle: "sign_up_header_back",
                trailingText:
                    "\(vm.step.rawValue + 1)/\(SignUpViewModel.Step.allCases.count)",
                onLeadingTap: { showExitDialog = true }
            )
            switch vm.step {
            case .terms: SignUpTermsSection(vm: vm)
            case .email: EmailVerificationSection(flow: vm.flow)
            case .password: PasswordSection(fields: vm.passwordFields)
            case .nickname: SignUpNicknameSection(vm: vm)
            }
            
            Spacer()

            Rectangle()
                .fill(Color.appBorder)
                .frame(height: 1)
                .padding(.horizontal, -Spacing.l)  // 바깥 좌우 패딩을 상쇄해서 화면 끝까지 늘림
                .padding(.bottom, Spacing.l)  // 선과 버튼 사이 간격

            PrimaryButton(
                title: vm.step == .nickname ? "sign_up_button_complete" : "다음",
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
        .swipeBackDisabled()
        .appDialog(
            isPresented: $showExitDialog,
            title: "sign_up_exit_dialog_title",
            message: "sign_up_exit_dialog_message",
            cancelTitle: "sign_up_exit_dialog_continue",
            confirmTitle: "sign_up_exit_dialog_leave",
            onConfirm: { router.pop() }
        )
        
        
    }
}

#if DEBUG
#Preview {
    SignUpView(vm: .init(service: MockAuthService()))
        .environment(Router<AuthRoute>())

}
#endif
