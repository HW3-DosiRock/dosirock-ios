//
//  FoundPasswordView.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct FoundPasswordView: View {

    @State private var vm: FoundPasswordViewModel
    @Environment(Router<AuthRoute>.self) private var router: Router<AuthRoute>?
    private let leadingTitle: LocalizedStringKey
    private let onBack: (() -> Void)?  // 마이페이지처럼 AuthRoute 밖에서 쓸 때 뒤로가기 동작

    init(
        vm: FoundPasswordViewModel,
        leadingTitle: LocalizedStringKey = "find_password_header_back",
        onBack: (() -> Void)? = nil
    ) {
        _vm = State(initialValue: vm)
        self.leadingTitle = leadingTitle
        self.onBack = onBack
    }

    var body: some View {
        VStack {
            NavigationHeader(
                title: "find_password_header_title",
                leadingTitle: leadingTitle,
                trailingText:
                    "\(vm.step.rawValue + 1)/\(FoundPasswordViewModel.Step.allCases.count)",
                onLeadingTap: { onBack?() ?? router?.pop() }
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
                    ? "find_password_button_complete" : "common_next",
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
    FoundPasswordView(vm: .init(service: PreviewAuthService()))
        .environment(Router<AuthRoute>())
}
#endif
