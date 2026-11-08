//
//  MockAuthService.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/7/26.
//

#if DEBUG
struct MockAuthService : AuthService{
    
    enum Scenario { case success, network, slow ,server}
    
    func login(email: String, password: String) async throws {
        <#code#>
    }
    
    func requestVerificationNumber(email: String) async throws {
        <#code#>
    }
    
    func checkVerificationNumber(email: String, vNumber: String) async throws {
        <#code#>
    }
    
    func signUp(email: String, password: String, nickName: String) async throws {
        <#code#>
    }
    
}

#endif
