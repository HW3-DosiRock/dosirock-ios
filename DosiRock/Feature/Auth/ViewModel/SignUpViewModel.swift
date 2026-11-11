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
    private var expiresAt: Date?
    private var timerTask: Task<Void, Never>?

    // 가입 완료 시 AuthFlowView가 준 동작 실행 (토스트 + 로그인 화면 이동)
    var onCompleted: () -> Void = {}

    // MARK: - State

    var step: Step = .terms

    // 입력값
    var agreed: Set<Term> = []
    var email = "" {
        didSet {
            if Self.trim(email) != Self.trim(oldValue) {
                isVerificationSent = false
                stopTimer()
            }
        }
    }
    var vNumber = "" {
        didSet {
            let digits = String(
                vNumber.filter { $0.isASCII && $0.isNumber }.prefix(6)
            )
            if digits != vNumber { vNumber = digits }
        }
    }

    var password = ""
    var passwordConfirm = ""
    var nickName = ""

    // 요청 상태
    var isLoading = false
    var isVerificationSent = false
    var isCompleted = false  // 가입 완료 후 재요청 방지
    var remainingSeconds = 0  // 인증번호 남은 시간(초). 0이면 타이머 없음/만료
    var errorMessage: String?

    // MARK: - Derived

    var agreedAll: Bool {
        get { agreed.count == Term.allCases.count }
        set { agreed = newValue ? Set(Term.allCases) : [] }
    }

    // 공백은 검증·서버 전송 모두 제거한 값 기준 (비밀번호는 공백도 문자라 그대로)
    private var trimmedEmail: String { Self.trim(email) }
    private var trimmedNickName: String { Self.trim(nickName) }

    var isEmailValid: Bool {
        trimmedEmail.range(
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

    // 입력 전에는 에러를 숨김. InputTextField.errorMsg가 String이라 번역해서 반환
    var passwordError: String? {
        password.isEmpty || isPasswordValid
            ? nil : String(localized: "sign_up_password_error_invalid")
    }

    var passwordConfirmError: String? {
        passwordConfirm.isEmpty || passwordConfirm == password
            ? nil : String(localized: "sign_up_password_error_mismatch")
    }

    // 한글·영문·숫자 2~10자 (공백 불가)
    var isNicknameValid: Bool {
        trimmedNickName.range(
            of: #"^[가-힣A-Za-z0-9]{2,10}$"#,
            options: .regularExpression
        ) != nil
    }

    var remainingText: String {  // "04:59"
        String(
            format: "%02d:%02d",
            remainingSeconds / 60,
            remainingSeconds % 60
        )
    }

    // 인증번호: 숫자 6자리 (일치 여부는 다음 버튼에서 서버가 판단)
    var isVerificationNumberValid: Bool {
        let number = Self.trim(vNumber)
        return number.count == 6
            && number.allSatisfy { $0.isASCII && $0.isNumber }
    }

    var canProceed: Bool {
        if isCompleted { return false }
        return switch step {
        case .terms: agreedAll
        case .email:
            isEmailValid && isVerificationNumberValid && remainingSeconds > 0
        case .password: isPasswordValid && password == passwordConfirm
        case .nickname: isNicknameValid
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
        guard !isLoading, isEmailValid else { return }
        let target = trimmedEmail
        if await run({
            try await self.service.requestVerificationNumber(email: target)
        }), target == trimmedEmail {  // 요청 중 이메일을 바꿨다면 무시
            isVerificationSent = true
            vNumber = ""
            startTimer()
        }
    }

    func next() async {
        guard !isLoading, canProceed else { return }
        switch step {
        case .terms, .password:
            advance()
        case .email:
            if await run({
                try await self.service.checkVerificationNumber(
                    email: self.trimmedEmail,
                    vNumber: Self.trim(self.vNumber)
                )
            }) {
                stopTimer()
                advance()
            }
        case .nickname:
            if await run({
                try await self.service.signUp(
                    email: self.trimmedEmail,
                    password: self.password,
                    nickName: self.trimmedNickName
                )
            }) {
                isCompleted = true
                onCompleted()
            }
        }
    }

    // MARK: - Private

    // 만료 시각 기준으로 계산해서 백그라운드를 다녀와도 시간이 틀어지지 않음
    private func startTimer() {
        timerTask?.cancel()
        expiresAt = Date().addingTimeInterval(300)
        remainingSeconds = 300
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, let end = self.expiresAt, !Task.isCancelled
                else { return }
                self.remainingSeconds = max(
                    0,
                    Int(end.timeIntervalSinceNow.rounded(.up))
                )
                if self.remainingSeconds == 0 {
                    self.errorMessage =
                        AuthError.verificationTimeout.errorDescription
                    return
                }
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        expiresAt = nil
        remainingSeconds = 0
    }

    private static func trim(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

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
