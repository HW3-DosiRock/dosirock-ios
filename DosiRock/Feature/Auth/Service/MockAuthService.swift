//
//  MockAuthService.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/7/26.
//

#if DEBUG
    struct MockAuthService: AuthService {

        enum Scenario { case success, network, slow, server, failure(AuthError) }

        let scenario: Scenario

        init(scenario: Scenario = .success) {
            self.scenario = scenario
        }

        func login(email: String, password: String) async throws {
            try await simulate()
        }

        func requestVerificationNumber(email: String) async throws {
            try await simulate()
        }
        
        func checkVerificationNumber(email: String, vNumber: String)
            async throws
        {
            try await simulate()
        }

        func signUp(email: String, password: String, nickName: String)
            async throws
        {
            try await simulate()
        }

        func requestPasswordReset(email: String) async throws {
            try await simulate()
        }

        private func simulate() async throws {

            switch scenario {
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
