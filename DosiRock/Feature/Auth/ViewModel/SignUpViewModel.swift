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

    // MARK: - State

    var step: Step = .terms

    // 입력값
    var agreed: Set<Term> = []
    var email = ""
    var vNumber = ""
    var password = ""
    var nickName = ""

    // 요청 상태
    var isLoading = false
    var errorMessage: String?

    // MARK: - Derived

    var agreedAll: Bool {
        get { agreed.count == Term.allCases.count }
        set { agreed = newValue ? Set(Term.allCases) : [] }
    }

    var isEmailValid: Bool {
        email.range(
            of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#,
            options: .regularExpression
        ) != nil
    }

    // 영문·숫자 포함 8~20자 (AuthError.weakPassword 문구 기준)
    var isPasswordValid: Bool {
        password.range(
            of: #"^(?=.*[A-Za-z])(?=.*\d).{8,20}$"#,
            options: .regularExpression
        ) != nil
    }

    var canProceed: Bool {
        switch step {
        case .terms: agreedAll
        case .email: isEmailValid && !vNumber.isEmpty
        case .password: isPasswordValid
        case .nickname: !nickName.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    // MARK: - Init

    init(service: AuthService) {
        self.service = service
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

    // 이메일 단계의 "인증번호 받기"
    func sendVerificationNumber() async {
        guard isEmailValid else { return }
        _ = await run {
            try await self.service.requestVerificationNumber(email: self.email)
        }
    }

    func next() async {
        guard canProceed else { return }
        switch step {
        case .terms, .password:
            advance()
        case .email:
            if await run({
                try await self.service.checkVerificationNumber(
                    email: self.email,
                    vNumber: self.vNumber
                )
            }) {
                advance()
            }
        case .nickname:
            if await run({
                try await self.service.signUp(
                    email: self.email,
                    password: self.password,
                    nickName: self.nickName
                )
            }) {
                // TODO 가입 완료 처리 (완료 화면 이동 등)
            }
        }
    }

    // MARK: - Private

    private func advance() {
        if let n = Step(rawValue: step.rawValue + 1) { step = n }
    }

    // 로딩·에러 처리를 한 곳에서. 성공하면 true
    private func run(_ work: () async throws -> Void) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await work()
            return true
        } catch {
            errorMessage =
                (error as? AuthError)?.errorDescription
                ?? AuthError.unknown.errorDescription
            return false
        }
    }
}
