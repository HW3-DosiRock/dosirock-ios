//
//  MockAuthService.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/7/26.
//

#if DEBUG
    struct MockAuthService: AuthService {

        enum Scenario {
            case success, network, slow, server
            case failure(AuthError)
        }

        nonisolated enum Method: Hashable {
            case login, requestVerificationNumber, checkVerificationNumber
            case signUp, resetPassword
        }

        let scenario: Scenario
        // 메서드별로 다른 시나리오를 쓰고 싶을 때만 지정 (없으면 scenario)
        let overrides: [Method: Scenario]

        init(scenario: Scenario = .success, overrides: [Method: Scenario] = [:])
        {
            self.scenario = scenario
            self.overrides = overrides
        }

        func login(email: String, password: String) async throws {
            try await simulate(.login)
        }

        func requestVerificationNumber(email: String) async throws {
            try await simulate(.requestVerificationNumber)
        }

        func checkVerificationNumber(email: String, vNumber: String)
            async throws -> String
        {
            try await simulate(.checkVerificationNumber)
            return "mock-signup-token"
        }

        func signUp(
            email: String,
            password: String,
            nickName: String,
            signupToken: String,
            agreement: SignUpAgreement
        ) async throws {
            try await simulate(.signUp)
        }

        func resetPassword(email: String, newPassword: String) async throws {
            try await simulate(.resetPassword)
        }

        private func simulate(_ method: Method) async throws {

            switch overrides[method] ?? scenario {
            case .success:
                try await Task.sleep(for: .milliseconds(500))
            case .slow:
                try await Task.sleep(for: .seconds(5))
            case .network:
                try await Task.sleep(for: .milliseconds(500))
                throw AuthError.network
            case .server:
                try await Task.sleep(for: .milliseconds(500))
                throw AuthError.server
            case .failure(let error):
                try await Task.sleep(for: .milliseconds(500))
                throw error
            }
        }

    }

#endif
