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

    private func send<T: Decodable>(
        _ path: String,
        body: [String : Any],
        as type : T.Type
    ) async throws -> T? {

        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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

}

extension RealAuthService: AuthService {

    func requestVerificationNumber(email: String) async throws {
        _ = try await send(
            "auth/email-verifications",
            body: ["email": email, "purpose": "SIGNUP"],
            as: Empty.self
        )
    }

    func checkVerificationNumber(email: String, vNumber: String) async throws
        -> String
    {

        let result = try await send(
            "auth/email-verifications/confirm",
            body: ["email": email, "purpose": "SIGNUP", "code": vNumber],
            as: SignupTokenData.self
        )

        guard let token = result?.signupToken else {
            throw AuthError.server
        }
        return token
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
        _ = try await send(
            "auth/login",
            body: ["email": email, "password": password],
            as: Empty.self  // TODO 응답의 토큰 2개는 저장 단계에서 사용
        )
    }
    
    func resetPassword(email: String, newPassword: String) async throws {
        #if DEBUG
            try await MockAuthService().resetPassword(
                email: email,
                newPassword: newPassword
            )
        #else
            throw AuthError.unknown
        #endif
    }

}
