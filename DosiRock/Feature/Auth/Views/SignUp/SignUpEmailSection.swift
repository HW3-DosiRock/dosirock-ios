//
//  EmailSection.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct SignUpEmailSection: View {

    @Bindable var vm: SignUpViewModel

    var body: some View {
        VStack(alignment: .leading) {

            SectionHeader(
                title: "sign_up_email_section_title",
                titleStyle: .brandEmphasis
            )
            .frame(maxWidth: .infinity)

            InputTextField(
                label: "sign_up_email_label",
                placeHolder: "sign_up_email_placeholder",
                text: $vm.email,
                inputType: .email,
                labelColor: .appTextPrimary,
                trailing: AnyView(
                    PrimaryButton(
                        title: vm.isVerificationSent
                            ? "sign_up_button_resend" : "sign_up_button_send",
                        isEnable: vm.isEmailValid,
                        isLoading: vm.isLoading
                    ) {
                        Task { await vm.sendVerificationNumber() }
                    }
                    .frame(width: 72)
                )
            )
            .disabled(vm.isLoading)

            if vm.isVerificationSent {
                InputTextField(
                    label: "sign_up_verification_label",
                    placeHolder: "sign_up_verification_placeholder",
                    text: $vm.vNumber,
                    inputType: .number,
                    suffix: LocalizedStringKey(vm.remainingText),
                    errorMsg: vm.errorMessage,
                    infoMsg: "sign_up_verification_description",
                    labelColor: .appTextPrimary,
                )
            }
        }
    }
}

#Preview {
    SignUpEmailSection(vm: .init(service: MockAuthService()))
        .background(Color.appBackground)
        .padding()
}
