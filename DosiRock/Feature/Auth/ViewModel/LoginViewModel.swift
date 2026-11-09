//
//  LoginViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import Foundation

@Observable
@MainActor
final class LoginViewModel {

    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    var onSuccess: (() -> Void)?
    
    private let service: AuthService

    init(service: AuthService) {
        self.service = service
    }

    var isEmailValid: Bool {
        email.range(
            of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#,
            options: .regularExpression
        ) != nil
    }

    var canSubmit: Bool { isEmailValid && !password.isEmpty }

    func login() async {
        
        guard canSubmit else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await service.login(email: email, password: password)
            onSuccess?()
        } catch {
            errorMessage =
                (error as? AuthError)?.errorDescription
                ?? AuthError.unknown.errorDescription
        }
    }
    
}
