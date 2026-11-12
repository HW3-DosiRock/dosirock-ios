//
//  EmailVerificationFlow.swift
//  DosiRock
//
//  회원가입·비밀번호 찾기가 함께 쓰는 "이메일 입력 → 인증번호 전송 → 인증번호 확인" 로직.
//  서버 호출만 각 화면이 클로저로 넘겨준다.
//

import SwiftUI

@Observable @MainActor
final class EmailVerificationFlow {

    // MARK: - Dependencies

    private let request: (String) async throws -> Void  // 인증번호 요청(email)
    private let check: (String, String) async throws -> String  // 인증번호 확인(email, 번호)
    private var expiresAt: Date?
    private var timerTask: Task<Void, Never>?

    // MARK: - State

    var email = "" {
        didSet {
            if Self.trim(email) != Self.trim(oldValue) {
                isVerificationSent = false
                stopTimer()
                emailErrorMessage = nil
                errorMessage = nil
            }
        }
    }
    var vNumber = ""  // 숫자·6자리 제한은 입력칸(InputTextField.maxLength)에서 처리

    var isLoading = false
    var isVerificationSent = false
    var remainingSeconds = 0  // 인증번호 남은 시간(초). 0이면 타이머 없음/만료
    var resendSeconds = 0  // 재전송 가능까지 남은 시간(초). 0이면 재전송 가능
    private var resendAt : Date?
    var emailErrorMessage: String?  // 인증번호 요청 실패 → 이메일 칸 아래
    var errorMessage: String?  // 인증번호 확인·만료 → 인증번호 칸 아래

    // MARK: - Derived

    // 공백은 검증·서버 전송 모두 제거한 값 기준
    var trimmedEmail: String { Self.trim(email) }

    var isEmailValid: Bool {
        trimmedEmail.count <= 255  // 서버 최대 길이
            && trimmedEmail.range(
            of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#,
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

    var canVerify: Bool {
        isEmailValid && isVerificationNumberValid && remainingSeconds > 0
    }

    // MARK: - Init

    init(
        request: @escaping (String) async throws -> Void,
        check: @escaping (String, String) async throws -> String
    ) {
        self.request = request
        self.check = check
    }

    // MARK: - Actions

    // "전송" / "재전송". 성공했을 때만 타이머 시작
    func sendVerificationNumber() async {
        guard !isLoading, isEmailValid , resendSeconds == 0  else { return }
        let target = trimmedEmail
        if await run(
            { try await self.request(target) },
            errorTo: \.emailErrorMessage
        ), target == trimmedEmail {  // 요청 중 이메일을 바꿨다면 무시
            isVerificationSent = true
            vNumber = ""
            startTimer()
        }
    }

    // "다음"에서 호출. 확인에 성공하면 signupToken, 실패하면 nil
    func verify() async -> String? {
        guard !isLoading, canVerify else { return nil }
        var token : String?
        _ = await run {
            token = try await self.check(self.trimmedEmail,Self.trim(self.vNumber))
        }
        if token != nil { stopTimer() }
        return token
    }

    // 인증을 처음부터 다시 하도록 상태 초기화 (이메일 입력값은 유지)
    func reset() {
        isVerificationSent = false
        vNumber = ""
        stopTimer()
        emailErrorMessage = nil
        errorMessage = nil
    }
    
    // MARK: - Private

    // 만료 시각 기준으로 계산해서 백그라운드를 다녀와도 시간이 틀어지지 않음
    private func startTimer() {
        timerTask?.cancel()
        expiresAt = Date().addingTimeInterval(300)
        remainingSeconds = 300
        resendAt = Date().addingTimeInterval(60)
        resendSeconds = 60
        
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                
                try? await Task.sleep(for: .seconds(1))
                guard let self, let end = self.expiresAt, !Task.isCancelled
                else { return }
                
                self.remainingSeconds = max(
                    0,
                    Int(end.timeIntervalSinceNow.rounded(.up))
                )
                self.resendSeconds = max(
                    0,
                    Int((self.resendAt?.timeIntervalSinceNow ?? 0 ).rounded(.up))
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
        resendAt = nil
        resendSeconds = 0
    }

    private static func trim(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // 로딩·에러 처리를 한 곳에서. 성공하면 true. 실패 문구는 errorTo 위치에 담김
    private func run(
        _ work: () async throws -> Void,
        errorTo target: ReferenceWritableKeyPath<EmailVerificationFlow, String?> =
            \.errorMessage
    ) async -> Bool {
        isLoading = true
        emailErrorMessage = nil
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await work()
            return true
        } catch {
            self[keyPath: target] =
                (error as? AuthError)?.errorDescription
                ?? AuthError.unknown.errorDescription
            return false
        }
    }
}
