//
//  SignUpViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//
import SwiftUI

@Observable @MainActor
final class SignUpViewModel {

    // MARK: - Types

    enum Step: Int, CaseIterable {
        case terms, email, password, nickname
    }

    // MARK: - Dependencies

    private let service: AuthService

    // 이메일 인증·비밀번호 입력은 비밀번호 찾기와 공용
    let flow: EmailVerificationFlow
    let passwordFields = PasswordFields()

    // 가입 완료 시 AuthFlowView가 준 동작 실행 (토스트 + 로그인 화면 이동)
    var onCompleted: () -> Void = {}

    // MARK: - State

    var step: Step = .terms

    var agreed: Set<Term> = []
    var nickName = ""

    var isSubmitting = false  // 가입 요청 중
    var isCompleted = false  // 가입 완료 후 재요청 방지
    var errorMessage: String?  // 가입 요청 실패 문구 → 닉네임 칸 아래
    private var signupToken: String?  //회원 가입 인증번호 반환 토큰

    // MARK: - Derived

    var isLoading: Bool { flow.isLoading || isSubmitting }

    var agreedAll: Bool {
        get { agreed.count == Term.allCases.count }
        set { agreed = newValue ? Set(Term.allCases) : [] }
    }

    private var trimmedNickName: String {
        nickName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // 한글·영문·숫자 2~10자 (공백 불가)
    var isNicknameValid: Bool {
        trimmedNickName.range(
            of: #"^[가-힣A-Za-z0-9]{2,10}$"#,
            options: .regularExpression
        ) != nil
    }

    var canProceed: Bool {
        if isCompleted { return false }
        return switch step {
        case .terms: agreedAll
        case .email: flow.canVerify
        case .password: passwordFields.canSubmit
        case .nickname: isNicknameValid
        }
    }

    // MARK: - Init

    init(service: AuthService) {
        self.service = service
        flow = EmailVerificationFlow(
            request: {
                try await service.requestVerificationNumber(
                    email: $0,
                    purpose: .signup
                )
            },
            check: {
                try await service.checkVerificationNumber(
                    email: $0,
                    vNumber: $1,
                    purpose: .signup
                )
            }
        )
    }

    // MARK: - Actions

    func binding(for term: Term) -> Binding<Bool> {
        Binding(
            get: { self.agreed.contains(term) },
            set: {
                if $0 {
                    self.agreed.insert(term)
                } else {
                    self.agreed.remove(term)
                }
            }
        )
    }

    func next() async {
        guard !isLoading, canProceed else { return }
        switch step {
        case .terms, .password:
            advance()
        case .email:
            if await flow.verify(), let token = flow.token {
                signupToken = token
                advance()
            }
        case .nickname:
            await signUp()
        }
    }

    // MARK: - Private

    private func advance() {
        if let n = Step(rawValue: step.rawValue + 1) { step = n }
    }

    private func signUp() async {
        guard let token = signupToken else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        do {
            try await service.signUp(
                email: flow.trimmedEmail,
                password: passwordFields.password,
                nickName: trimmedNickName,
                signupToken: token,
                agreement: SignUpAgreement(
                    // shortcut: 약관 파일을 못 읽으면 "1.0"으로 보냄, 약관 버전이 바뀌면 파일 기준으로만 보내도록 수정
                    serviceTermsVersion: Term.service.document?.version
                        ?? "1.0",
                    privacyConsentVersion: Term.privacy.document?.version
                        ?? "1.0"
                )
            )
            isCompleted = true
            onCompleted()
        } catch {
            let authError = error as? AuthError
            let message =
                authError?.errorDescription
                ?? AuthError.unknown.errorDescription
            if authError?.code == "AUTH_SIGNUP_TOKEN_INVALID" {
                // 토큰 만료 → 이메일 인증부터 다시
                signupToken = nil
                flow.reset()
                flow.emailErrorMessage = message
                step = .email
            } else {
                errorMessage = message
            }
        }
    }
}
