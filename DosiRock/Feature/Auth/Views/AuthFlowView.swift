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

    init(onLoginSuccess: @escaping () -> Void) {
        let vm = LoginViewModel(service: AppEnvironment.makeAuthService())
        vm.onSuccess = onLoginSuccess        // 로그인 성공 시 RootView가 준 동작 실행
        _loginVM = State(initialValue: vm)  //처음 들어갈 값을 직접 넣어 주는 코드
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            LoginView(vm: loginVM)
                .navigationDestination(for: AuthRoute.self) { route in
                    switch route {
                    case .signUp: Text("회원가입")
                    case .findPassword: Text("비밀번호 찾기")
                    }
                }
        }
        .environment(router)
    }
}
