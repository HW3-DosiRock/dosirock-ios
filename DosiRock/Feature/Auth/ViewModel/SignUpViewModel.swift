//
//  SignUpViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//
import Foundation

@Observable @MainActor
final class SignUpViewModel {

    private let service: AuthService

    init(service: AuthService) {
        self.service = service
    }

    enum Step: Int, CaseIterable {
        case terms, email, password, nickname
    }

    var step: Step = .terms
    var email = ""
    var vNumber = ""
    var password = ""
    var nickName = ""
    var isLoading = false
    var errorMessage: String?
 
    var canProceed: Bool { true }  // TODO 스텝별 조건

    func next() async {}  // TODO 스텝별 서비스 호출 → 성공하면 다음 스텝
}
