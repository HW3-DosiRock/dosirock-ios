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
    var errorMessage: String?  // 서버가 준 실패 문구 → 현재 비밀번호 칸 아래

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
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            try await users.changePassword(current: current, new: fields.password)
            return true
        } catch {
            errorMessage =
                (error as? AuthError)?.errorDescription
                ?? String(localized: "my_password_save_failed")
            return false
        }
    }
}
