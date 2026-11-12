//
//  FoundPasswordViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import Foundation

// 이메일 인증 → 새 비밀번호 설정 (회원가입과 같은 인증·비밀번호 로직을 공용으로 사용)
@Observable
@MainActor
final class FoundPasswordViewModel {

    enum Step: Int, CaseIterable { case email, password }

    private let service: AuthService

    let flow: EmailVerificationFlow
    let passwordFields = PasswordFields()

    // 변경 완료 시 AuthFlowView가 준 동작 실행 (토스트 + 로그인 화면 이동)
    var onCompleted: () -> Void = {}

    var step: Step = .email
    var isSubmitting = false
    var isCompleted = false
    var errorMessage: String?  // 비밀번호 변경 요청 실패 문구

    var isLoading: Bool { flow.isLoading || isSubmitting }

    var canProceed: Bool {
        if isCompleted { return false }
        return switch step {
        case .email: flow.canVerify
        case .password: passwordFields.canSubmit
        }
    }

    init(service: AuthService) {
        self.service = service
        // shortcut: 회원가입과 같은 인증 API를 씀. 서버가 용도(purpose) 구분을 요구하면 여기서 넘김
        flow = EmailVerificationFlow(
            request: { try await service.requestVerificationNumber(email: $0) },
            check: {
                try await service.checkVerificationNumber(
                    email: $0,
                    vNumber: $1
                )
            }
        )
    }

    func next() async {
        guard !isLoading, canProceed else { return }
        switch step {
        case .email:
            if await flow.verify() != nil { step = .password }
        case .password:
            await resetPassword()
        }
    }

    private func resetPassword() async {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            try await service.resetPassword(
                email: flow.trimmedEmail,
                newPassword: passwordFields.password
            )
            isCompleted = true
            onCompleted()
        } catch {
            errorMessage =
                (error as? AuthError)?.errorDescription
                ?? AuthError.unknown.errorDescription
        }
    }
}
