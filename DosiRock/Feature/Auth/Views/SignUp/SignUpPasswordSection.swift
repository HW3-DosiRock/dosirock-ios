//
//  SignUpPasswordSection.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct SignUpPasswordSection: View {

    @Bindable var vm: SignUpViewModel
    @State private var confirmFocused = false

    var body: some View {
        VStack(alignment: .leading) {

            SectionHeader(
                title: "sign_up_password_section_title",
                titleStyle: .brandEmphasis
            )
            .frame(maxWidth: .infinity)

            InputTextField(
                label: "sign_up_password_label",
                placeHolder: "sign_up_password_placeholder",
                text: $vm.password,
                inputType: .password,
                errorMsg: vm.passwordError,
                infoMsg: "sign_up_password_description",
                showsErrorAfterBlur: true,
                submitLabel: .next,
                onSubmit: { confirmFocused = true },
                labelColor: .appTextPrimary
            )

            InputTextField(
                label: "sign_up_password_confirm_label",
                placeHolder: "sign_up_password_confirm_placeholder",
                text: $vm.passwordConfirm,
                inputType: .password,
                errorMsg: vm.passwordConfirmError,
                showsErrorAfterBlur: true,
                onSubmit: { confirmFocused = false },
                focused: $confirmFocused,
                labelColor: .appTextPrimary
            )
        }
    }
}

#Preview {
    SignUpPasswordSection(vm: .init(service: MockAuthService()))
        .background(Color.appBackground)
        .padding()
}
