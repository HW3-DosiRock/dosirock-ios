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
        RealAuthService(baseURL: URL(string: "http://10.242.18.134:3001/api")!)
        #else
        fatalError("RealAuthService가 아직 없어요")   // TODO 실서비스 만들면 교체
        #endif
    }
}
