//
//  PasswordFields.swift
//  DosiRock
//
//  회원가입·비밀번호 찾기가 함께 쓰는 "비밀번호 + 확인" 입력과 검증.
//

import SwiftUI

@Observable @MainActor
final class PasswordFields {

    var password = ""
    var passwordConfirm = ""

    // 영문·숫자 포함 8~20자 (AuthError.weakPassword 문구 기준)
    var isValid: Bool {
        password.range(
            of: #"^(?=.*[A-Za-z])(?=.*\d).{8,20}$"#,
            options: .regularExpression
        ) != nil
    }

    var canSubmit: Bool { isValid && password == passwordConfirm }

    // 입력 전에는 에러를 숨김. InputTextField.errorMsg가 String이라 번역해서 반환
    var error: String? {
        password.isEmpty || isValid
            ? nil : String(localized: "sign_up_password_error_invalid")
    }

    var confirmError: String? {
        passwordConfirm.isEmpty || passwordConfirm == password
            ? nil : String(localized: "sign_up_password_error_mismatch")
    }
}
