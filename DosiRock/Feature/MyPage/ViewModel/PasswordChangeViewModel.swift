//
//  PasswordChangeViewModel.swift
//  DosiRock
//

import Foundation

@Observable @MainActor
final class PasswordChangeViewModel {

    private let users: UserRepository

    var current = ""
    let fields = PasswordFields()  // 새 비밀번호 + 확인 (회원가입과 공용)
    var isSubmitting = false
    var currentError: String?  // 현재 비밀번호가 틀렸을 때
    var errorMessage: String?  // 그 밖의 요청 실패 문구

    init(users: UserRepository) { self.users = users }

    var newError: String? {
        if fields.password.isEmpty { return nil }
        if !fields.isValid { return String(localized: "my_password_new_invalid") }
        if fields.password == current { return String(localized: "my_password_new_same") }
        return nil
    }

    var confirmError: String? {
        fields.passwordConfirm.isEmpty || fields.passwordConfirm == fields.password
            ? nil : String(localized: "my_password_confirm_mismatch")
    }

    var canSubmit: Bool {
        !current.isEmpty && fields.canSubmit && newError == nil && !isSubmitting
    }

    func submit() async -> Bool {
        guard canSubmit else { return false }
        isSubmitting = true
        currentError = nil
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            try await users.changePassword(current: current, new: fields.password)
            return true
        } catch {
            let authError = error as? AuthError
            // shortcut: 서버의 "현재 비밀번호 불일치" 코드를 몰라 코드에 PASSWORD가 들어가면 그 경우로 봄, 확정되면 정확한 코드로 교체
            if authError?.code?.contains("PASSWORD") == true {
                currentError = String(localized: "my_password_current_mismatch")
            } else {
                errorMessage =
                    authError?.errorDescription
                    ?? String(localized: "my_password_save_failed")
            }
            return false
        }
    }
}
