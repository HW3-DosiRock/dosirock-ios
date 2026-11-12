//
//  SignUpPasswordSection.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct PasswordSection: View {

    @Bindable var fields: PasswordFields
    var title: LocalizedStringKey = "sign_up_password_section_title"
    var submitError: String? = nil  // 최종 요청 실패 문구 (확인 칸 아래)
    @State private var confirmFocused = false

    var body: some View {
        VStack(alignment: .leading) {

            SectionHeader(
                title: title,
                titleStyle: .brandEmphasis
            )
            .frame(maxWidth: .infinity)

            InputTextField(
                label: "sign_up_password_label",
                placeHolder: "sign_up_password_placeholder",
                text: $fields.password,
                inputType: .password,
                errorMsg: fields.error,
                infoMsg: "sign_up_password_description",
                showsErrorAfterBlur: true,
                submitLabel: .next,
                onSubmit: { confirmFocused = true },
                labelColor: .appTextPrimary
            )

            InputTextField(
                label: "sign_up_password_confirm_label",
                placeHolder: "sign_up_password_confirm_placeholder",
                text: $fields.passwordConfirm,
                inputType: .password,
                errorMsg: fields.confirmError ?? submitError,
                showsErrorAfterBlur: true,
                onSubmit: { confirmFocused = false },
                focused: $confirmFocused,
                labelColor: .appTextPrimary
            )
        }
    }
}

#Preview {
    PasswordSection(fields: PasswordFields())
        .background(Color.appBackground)
        .padding()
}
