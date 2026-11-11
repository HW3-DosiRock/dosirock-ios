//
//  AuthFlowView.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct AuthFlowView: View {

    @State private var router = Router<AuthRoute>()

    @State private var loginVM: LoginViewModel
    @State private var toastMessage: LocalizedStringKey?

    init(onLoginSuccess: @escaping () -> Void) {

        //로그인
        let vm = LoginViewModel(service: AppEnvironment.makeAuthService())
        vm.onSuccess = onLoginSuccess  // 로그인 성공 시 RootView가 준 동작 실행
        _loginVM = State(initialValue: vm)  //처음 들어갈 값을 직접 넣어 주는 코드
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView(vm: loginVM)
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .signUp:
                        signUpView
                    case .findPassword:
                        FoundPasswordView(
                            vm: .init(service: AppEnvironment.makeAuthService())
                        )
                    }
                }
        }
        .environment(router)
        .toast($toastMessage)  // NavigationStack 바깥이라 화면이 pop돼도 유지됨
    }

    // ViewBuilder 안에서는 대입문을 못 쓰므로 따로 뺌
    private var signUpView: some View {
        let vm = SignUpViewModel(service: AppEnvironment.makeAuthService())
        vm.onCompleted = {
            router.popToRoot()  // 로그인 화면으로
            toastMessage = "sign_up_toast_completed"
        }
        return SignUpView(vm: vm)
    }
}
