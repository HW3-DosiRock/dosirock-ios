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

    //common
    case network  //네트워크 상태
    case server  // 5xx
    case unknown
    
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
        case .network:
            "네트워크 연결을 확인해 주세요"
        case .server:
            "잠시후 다시 시도해 주세요"
        case .unknown:
            "알 수 없는 오류가 발생했어요"
        }
    }
}

protocol AuthService {
    func login(email : String , password : String ) async throws
    func requestVerificationNumber(email : String) async throws
    func checkVerificationNumber(email : String, vNumber : String) async throws
    func signUp(email : String , password : String ,nickName : String) async throws
    func resetPassword(email : String, newPassword : String) async throws

}
