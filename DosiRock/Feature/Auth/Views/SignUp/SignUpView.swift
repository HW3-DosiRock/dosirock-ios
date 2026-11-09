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

    init(vm: SignUpViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        VStack {
            NavigationHeader(
                title: String(localized: "sign_up_header_title"),
                leadingTitle: String(localized: "sign_up_header_back"),
                trailingText:
                    "\(vm.step.rawValue + 1)/\(SignUpViewModel.Step.allCases.count)",
                onLeadingTap: { router.pop() }  //TODO 알림 추가
            )
            switch vm.step {
            case .terms: SignUpTermsSection()
            case .email: SignUpEmailSection()
            case .password: SignUpPasswordSection()
            case .nickname: SignUpNicknameSection()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

#Preview {
    SignUpView(vm: .init(service: MockAuthService()))
        .environment(Router<AuthRoute>())

}
