//
//  RealAuthService.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import Foundation

//서버 공통 응답
nonisolated struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let error: ApiErrorBody?
}

nonisolated struct ApiErrorBody: Decodable {
    let code: String
    let message: String
    let details: [String: String]?
}

//data가 null인 응답
nonisolated struct Empty: Decodable {}

//인증번호 확인 응답 데이터
nonisolated struct SignupTokenData: Decodable {
    let signupToken: String
}

struct RealAuthService {

    let baseURL: URL

    // 갱신이 진행 중이면 그 작업. 동시에 여러 요청이 401을 받아도 갱신은 하나만 실행하기 위함
    // (서버는 갱신에 성공하면 이전 리프레시 토큰을 바로 폐기해서, 두 번 갱신하면 쫓겨남)
    private static var refreshTask: Task<Void, Error>?

    // 요청을 보낸다. 로그인이 필요한 요청이 "액세스 토큰 무효(401)"를 받으면
    // 토큰을 갱신하고 한 번만 다시 보낸다. 갱신도 거절되면 로그인 화면으로 보낸다.
    private func send<T: Decodable>(
        _ path: String,
        body: [String: Any],
        authorized: Bool = false,
        as type: T.Type
    ) async throws -> T? {
        do {
            return try await sendOnce(
                path,
                body: body,
                authorized: authorized,
                as: type
            )
        } catch let error as AuthError
            where authorized && error.code == "AUTH_ACCESS_TOKEN_INVALID"
        {
            try await refreshOnce()
            return try await sendOnce(
                path,
                body: body,
                authorized: authorized,
                as: type
            )
        }
    }

    // 갱신은 동시에 하나만. 이미 진행 중이면 그 결과를 같이 기다린다
    private func refreshOnce() async throws {
        if let task = Self.refreshTask {
            return try await task.value
        }
        let task = Task { try await self.refresh() }
        Self.refreshTask = task
        defer { Self.refreshTask = nil }

        do {
            try await task.value
        } catch let error as AuthError where error.code != nil {
            // 서버가 리프레시 토큰을 거부함(만료, 다른 기기 로그인 등) → 로그인 화면으로
            SessionStore.shared.expire(message: error.errorDescription)
            throw error
        }
        // 네트워크 오류 등은 로그인 상태를 유지한 채 그대로 던진다
    }

    // 요청 한 번을 실제로 보낸다 (재시도 없음)
    private func sendOnce<T: Decodable>(
        _ path: String,
        body: [String: Any],
        authorized: Bool = false,
        as type: T.Type
    ) async throws -> T? {

        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 로그인이 필요한 API는 액세스 토큰을 헤더에 붙인다
        if authorized, let access = TokenStore.read(.access) {
            request.setValue(
                "Bearer \(access)",
                forHTTPHeaderField: "Authorization"
            )
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let data: Data
        do {
            data = try await URLSession.shared.data(for: request).0
        } catch {
            throw AuthError.network  //서버 꺼짐, 인터넷 끊김 등
        }

        //서버 공통 응답 형식이 아니면 서버 문제로 처리
        guard
            let response = try? JSONDecoder().decode(
                APIResponse<T>.self,
                from: data
            )
        else {
            throw AuthError.server
        }

        if let e = response.error {
            throw AuthError.api(
                code: e.code,
                message: e.message,
                details: e.details
            )
        }

        return response.data
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
        _ = try await send(
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

        let result = try await send(
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
        _ = try await send(
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

        let result = try await send(
            "auth/login",
            body: ["email": email, "password": password],
            as: LoginTokenData.self
        )

        guard let tokens = result else { throw AuthError.server }

        TokenStore.save(tokens.accessToken, for: .access)
        TokenStore.save(tokens.refreshToken, for: .refresh)
    }

    func refresh() async throws {
        guard let refreshToken = TokenStore.read(.refresh) else {
            throw AuthError.unknown
        }
        let result = try await send(
            "auth/refresh",
            body: ["refreshToken": refreshToken],
            as: LoginTokenData.self
        )
        guard let tokens = result else { throw AuthError.server }
        TokenStore.save(tokens.accessToken, for: .access)
        TokenStore.save(tokens.refreshToken, for: .refresh)
    }

    func logout() async throws {
        // 서버 요청이 성공하든 실패하든 내 기기의 토큰은 지운다
        defer { TokenStore.clear() }
        _ = try await send(
            "auth/logout",
            body: [:],
            authorized: true,
            as: Empty.self
        )
    }

    func resetPassword(email: String, code: String, newPassword: String)
        async throws
    {

        _ = try await send(
            "auth/password-reset",
            body: ["email": email, "code": code, "newPassword": newPassword],
            as: Empty.self
        )
    }

}
