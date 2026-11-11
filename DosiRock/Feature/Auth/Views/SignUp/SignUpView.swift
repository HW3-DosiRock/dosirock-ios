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
        VStack() {
            NavigationHeader(
                title: "sign_up_header_title",
                leadingTitle: "sign_up_header_back",
                trailingText:
                    "\(vm.step.rawValue + 1)/\(SignUpViewModel.Step.allCases.count)",
                onLeadingTap: { router.pop() }  //TODO 알림 추가
            )
            switch vm.step {
            case .terms: SignUpTermsSection(vm: vm)
            case .email: SignUpEmailSection(vm: vm)
            case .password: SignUpPasswordSection(vm: vm)
            case .nickname: SignUpNicknameSection()
            }
            
            Spacer()

            Rectangle()
                .fill(Color.appBorder)
                .frame(height: 1)
                .padding(.horizontal, -Spacing.l)  // 바깥 좌우 패딩을 상쇄해서 화면 끝까지 늘림
                .padding(.bottom, Spacing.l)  // 선과 버튼 사이 간격

            PrimaryButton(
                title: "다음",
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

#Preview {
    SignUpView(vm: .init(service: MockAuthService()))
        .environment(Router<AuthRoute>())

}
