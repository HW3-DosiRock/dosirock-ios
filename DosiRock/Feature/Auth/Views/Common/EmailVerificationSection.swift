//
//  EmailVerificationSection..swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct EmailVerificationSection: View {

    @Bindable var flow: EmailVerificationFlow
    var title: LocalizedStringKey = "sign_up_email_section_title"

    var body: some View {
        VStack(alignment: .leading) {

            SectionHeader(
                title: title,
                titleStyle: .brandEmphasis
            )
            .frame(maxWidth: .infinity)

            InputTextField(
                label: "sign_up_email_label",
                placeHolder: "sign_up_email_placeholder",
                text: $flow.email,
                inputType: .email,
                suffix: flow.resendSeconds > 0
                    ? LocalizedStringKey("00:\(flow.resendSeconds)") : "",
                errorMsg: flow.emailErrorMessage,
                labelColor: .appTextPrimary,
                trailing: AnyView(
                    PrimaryButton(
                        title: flow.isVerificationSent
                            ? "sign_up_button_resend" : "sign_up_button_send",
                        isEnable: flow.resendSeconds > 0 ? false : flow.isEmailValid,
                        isLoading: flow.isLoading
                    ) {
                        Task { await flow.sendVerificationNumber() }
                    }
                    .frame(width: 72)
                )
            )
            .disabled(flow.isLoading)

            if flow.isVerificationSent {
                InputTextField(
                    label: "sign_up_verification_label",
                    placeHolder: "sign_up_verification_placeholder",
                    text: $flow.vNumber,
                    inputType: .number,
                    suffix: LocalizedStringKey(flow.remainingText),
                    errorMsg: flow.errorMessage,
                    infoMsg: "sign_up_verification_description",
                    maxLength: 6,
                    labelColor: .appTextPrimary,
                )
            }
        }
    }
}

#Preview {
    EmailVerificationSection(
        flow: EmailVerificationFlow(
            request: { _ in },
            check: { _, _ in "token" }
        )
    )
    .background(Color.appBackground)
    .padding()
}
