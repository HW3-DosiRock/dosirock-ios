//
//  FoundPasswordView.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct FoundPasswordView: View {

    private enum Layout {
        static let logoWidth: CGFloat = 104
    }
    
    @State private var vm: FoundPasswordViewModel
    @Environment(Router<AuthRoute>.self) private var router
    
    init(vm: FoundPasswordViewModel) {
        _vm = State(initialValue: vm)
    }

    var body: some View {

        VStack {

            //header
            NavigationHeader(
                title: "비밀번호 찾기",
                leadingTitle: "로그인"
            )

            switch vm.step {
            case .input: inputContent
            case .sent: sentContent
            }

        }
        .padding(.horizontal, Spacing.l)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .animation(.easeInOut, value: vm.step)
        .navigationBarBackButtonHidden(true)
    }

    var inputContent: some View {
        VStack {

            InputTextField(
                label: "가입한 이메일",
                placeHolder: "이메일을 입력해 주세요",
                text: $vm.email,
                inputType: .email,
                errorMsg: vm.errorMessage,
                infoMsg: "가입한 이메일로 재설정 링크를 보내드려요",

            )

            Spacer()

            Rectangle()
                .fill(Color.appBorder)
                .frame(height: 1)
                .padding(.horizontal, -Spacing.l)  // 바깥 좌우 패딩을 상쇄해서 화면 끝까지 늘림
                .padding(.bottom, Spacing.l)  // 선과 버튼 사이 간격

            PrimaryButton(
                title: "재설정 링크 받기",
                isEnable: vm.isEmailValid,
                isLoading: vm.isLoading
            ) {
                Task { await vm.sendResetLink() }
            }
        }
    }

    var sentContent: some View {
        VStack {

            
            VStack(spacing: Spacing.l){
                
                Image("logo-stone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Layout.logoWidth)
                    .padding(.bottom, Spacing.xs)

                Text("메일 전송 완료")
                    .appFont(.brandTitle)
                
                Text(vm.email)
                    .foregroundStyle(Color.appTextSecondary)
                    .appFont(.subbody)
                
                
                Text("메일의 링크에서 새 비밀번호를 설정하세요")
                    .foregroundStyle(Color.appTextSecondary)
                    .appFont(.subbody)
                
            }
            .frame(maxHeight: .infinity)
            
            Spacer()

            Rectangle()
                .fill(Color.appBorder)
                .frame(height: 1)
                .padding(.horizontal, -Spacing.l)  // 바깥 좌우 패딩을 상쇄해서 화면 끝까지 늘림
                .padding(.bottom, Spacing.l)  // 선과 버튼 사이 간격

            PrimaryButton(title: "로그인으로") {
                router.pop()
            }

            TextLinkButton(
                title: "메일 다시 보내기",
                textColor: .appTextPrimary,
                textStyle: .heading
            ) {
                vm.backToInput()
            }

        }
    }

}

#Preview {
    FoundPasswordView(vm: .init(service: MockAuthService()))
        .environment(Router<AuthRoute>())
}
