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
        
        flow = EmailVerificationFlow(
            request: { try await service.requestVerificationNumber(email: $0 ,purpose: .passwordReset) },
            check: {
                try await service.checkVerificationNumber(
                    email: $0,
                    vNumber: $1,
                    purpose: .passwordReset
                )
            }
        )

        // 비밀번호 화면에 있는 동안 시간이 다 되면 처음으로
        flow.onExpired = { [weak self] in
            guard let self, self.step == .password else { return }
            self.backToStart(AuthError.verificationTimeout.errorDescription)
        }
    }

    func next() async {
        guard !isLoading, canProceed else { return }
        switch step {
        case .email:
            if await flow.verify(keepTimer: true) { step = .password }
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
                code : flow.vNumber,
                newPassword: passwordFields.password
            )
            isCompleted = true
            onCompleted()
        } catch {
            let authError = error as? AuthError
            let message =
                authError?.errorDescription
                ?? AuthError.unknown.errorDescription

            switch authError?.code {
            case "AUTH_VERIFICATION_NOT_FOUND",
                "AUTH_VERIFICATION_EXPIRED",
                "AUTH_VERIFICATION_ATTEMPT_LIMIT_REACHED":
                backToStart(message)  // 새 코드를 받아야 함
            case "AUTH_VERIFICATION_NOT_CONFIRMED",
                "AUTH_VERIFICATION_ALREADY_USED",
                "AUTH_VERIFICATION_CODE_MISMATCH":
                backToCode(message)  // 코드만 다시 입력
            default:
                errorMessage = message  // 비밀번호 문제 등은 이 화면에 표시
            }
        }
    }

    // 처음부터 다시: 인증 상태와 입력한 비밀번호를 모두 초기화하고 이메일 화면으로
    private func backToStart(_ message: String?) {
        flow.reset()
        flow.emailErrorMessage = message
        passwordFields.password = ""
        passwordFields.passwordConfirm = ""
        step = .email
    }

    // 코드만 다시: 코드 칸만 비우고 이메일 화면으로
    private func backToCode(_ message: String?) {
        flow.vNumber = ""
        flow.errorMessage = message
        step = .email
    }
}
