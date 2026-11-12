//
//  AuthError.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/7/26.
//

import Foundation

enum AuthError: LocalizedError {

    //signin
    case invalidCredentials  //이메일,비밀번호 불일치

    //signup
    case emailTaken  //이미 가입된 이메일
    case weakPassword  //비밀번호 조건 미충족
    case invalidNumber  //인증번호 불일치
    case verificationTimeout  //인증번호 타임아웃
    case verificationAttemptLimit  //인증번호 5회 틀려서 차단
    case verificationNotFound  //인증번호 발송 내역 없음
    case verificationAlreadyUsed  //이미 사용된 인증번호
    case resendTooSoon  //60초 안에 재전송
    case signupTokenInvalid  //가입 토큰 만료/무효 → 이메일 인증부터 다시
    case agreementVersionMismatch  //약관 버전 불일치
    case validation([String: String])  //입력값 검증 실패 (필드명: 문구)

    //common
    case network  //네트워크 상태
    case server  // 5xx
    case unknown

    //API
    case api(code: String, message: String, details: [String: String]?)  //서버 오류 응답

    var code: String? {
        if case .api(let code, _, _) = self {
            code
        } else {
            nil
        }
    }

    var errorDescription: String? {
        switch self {

        case .invalidCredentials:
            "이메일 또는 비밀번호가 일치하지 않아요"
        case .emailTaken:
            "이미 가입한 이메일이에요"
        case .weakPassword:
            "영문,숫자 포함 8~20자로 입력해주세요"
        case .invalidNumber:
            "인증번호가 일치하지 않아요"
        case .verificationTimeout:
            "인증 시간이 지났어요. 인증번호를 다시 요청해주세요."
        case .verificationAttemptLimit:
            "인증번호를 5번 틀렸어요. 인증번호를 다시 요청해주세요."
        case .verificationNotFound:
            "인증번호 요청 내역이 없어요. 인증번호를 다시 요청해주세요."
        case .verificationAlreadyUsed:
            "이미 사용된 인증번호예요. 인증번호를 다시 요청해주세요."
        case .resendTooSoon:
            "잠시 후에 다시 요청해주세요"
        case .signupTokenInvalid:
            "인증이 만료되었어요. 이메일 인증을 다시 진행해주세요."
        case .agreementVersionMismatch:
            "약관이 변경되었어요. 앱을 업데이트해주세요."
        case .validation(let details):
            details.values.first ?? "입력값을 확인해주세요"
        case .network:
            "네트워크 연결을 확인해 주세요"
        case .server:
            "잠시후 다시 시도해 주세요"
        case .unknown:
            "알 수 없는 오류가 발생했어요"
        case .api(_, let message, _):
            message
        }
    }
}

//약관 버전
struct SignUpAgreement {
    let serviceTermsVersion: String
    let privacyConsentVersion: String
}

protocol AuthService {
    func login(email: String, password: String) async throws
    func requestVerificationNumber(email: String) async throws
    func checkVerificationNumber(email: String, vNumber: String) async throws
        -> String
    func signUp(
        email: String,
        password: String,
        nickName: String,
        signupToken: String,
        agreement: SignUpAgreement
    ) async throws
    func resetPassword(email: String, newPassword: String) async throws

}
