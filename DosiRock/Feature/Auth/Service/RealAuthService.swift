//
//  RealAuthService.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import Foundation

//인증번호 확인 응답 데이터
nonisolated struct SignupTokenData: Decodable {
    let signupToken: String
}

struct RealAuthService {

    private let client: APIClient

    init(baseURL: URL) {
        client = APIClient(baseURL: baseURL)
    }

    // 로그인 응답의 data
    nonisolated struct LoginTokenData: Decodable {
        let accessToken: String
        let refreshToken: String
    }

}

extension RealAuthService: AuthService {

    func requestVerificationNumber(email: String, purpose: VerificationPurpose)
        async throws
    {
        _ = try await client.send(
            "auth/email-verifications",
            body: ["email": email, "purpose": purpose.rawValue],
            as: Empty.self
        )
    }

    func checkVerificationNumber(
        email: String,
        vNumber: String,
        purpose: VerificationPurpose
    ) async throws
        -> String?
    {

        let result = try await client.send(
            "auth/email-verifications/confirm",
            body: [
                "email": email, "purpose": purpose.rawValue, "code": vNumber,
            ],
            as: SignupTokenData.self
        )

        return result?.signupToken
    }

    func signUp(
        email: String,
        password: String,
        nickName: String,
        signupToken: String,
        agreement: SignUpAgreement
    ) async throws {
        _ = try await client.send(
            "auth/signup",
            body: [
                "email": email,
                "password": password,
                "nickname": nickName,  // 서버 필드명은 소문자 n
                "signupToken": signupToken,
                "ageConfirmed": true,
                "serviceTermsAgreed": true,
                "serviceTermsVersion": agreement.serviceTermsVersion,
                "privacyConsentAgreed": true,
                "privacyConsentVersion": agreement.privacyConsentVersion,
            ],
            as: Empty.self
        )
    }

    func login(email: String, password: String) async throws {

        let result = try await client.send(
            "auth/login",
            body: ["email": email, "password": password],
            as: LoginTokenData.self
        )

        guard let tokens = result else { throw AuthError.server }

        TokenStore.save(tokens.accessToken, for: .access)
        TokenStore.save(tokens.refreshToken, for: .refresh)
    }

    func refresh() async throws {
        try await client.refresh()
    }

    func logout() async throws {
        // 서버 요청이 성공하든 실패하든 내 기기의 토큰은 지운다
        defer { TokenStore.clear() }
        _ = try await client.send(
            "auth/logout",
            body: [:],
            authorized: true,
            as: Empty.self
        )
    }

    func resetPassword(email: String, code: String, newPassword: String)
        async throws
    {

        _ = try await client.send(
            "auth/password-reset",
            body: ["email": email, "code": code, "newPassword": newPassword],
            as: Empty.self
        )
    }

}
