//
//  FoundPasswordViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import Foundation

@Observable
@MainActor
final class FoundPasswordViewModel {
    enum Step { case input, sent }

    var step: Step = .input
    var email = ""
    var isLoading = false
    var errorMessage: String?

    private let service: AuthService

    init(service: AuthService) {
        self.service = service
    }

    var isEmailValid: Bool {
        email.range(
            of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#,
            options: .regularExpression
        ) != nil
    }

    // 완료 화면에서 입력 화면으로 돌아감 (email은 유지)
    func backToInput() {
        step = .input
        errorMessage = nil
    }

    // "재설정 링크 받기"와 "메일 다시 보내기"가 같이 사용
    func sendResetLink() async {
        guard isEmailValid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await service.requestPasswordReset(email: email)
            step = .sent
        } catch {
            errorMessage =
                (error as? AuthError)?.errorDescription
                ?? AuthError.unknown.errorDescription
        }
    }
}
