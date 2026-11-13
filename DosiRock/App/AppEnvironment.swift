//
//  AppEnvironment.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//
import Foundation

enum AppEnvironment {
    static func makeAuthService() -> AuthService {
        #if DEBUG
//        MockAuthService(scenario: .success)   // 시나리오를 바꿔 가며 테스트
//        MockAuthService(scenario: .failure(AuthError.invalidCredentials))   // 시나리오를 바꿔 가며 테스트
        //Mockoon 
//        RealAuthService(baseURL: URL(string: "http://127.0.0.1:3001/api")!)
        //배포
        RealAuthService(baseURL: URL(string: "https://dosirock.duckdns.org/api")!)
        #else
        RealAuthService(baseURL: URL(string: "https://dosirock.duckdns.org/api")!)
        #endif
    }
}
