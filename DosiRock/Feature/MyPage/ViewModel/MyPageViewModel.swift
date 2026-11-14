//
//  MyPageViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/13/26.
//

import Foundation

@Observable @MainActor
final class MyPageViewModel {

    enum State {
        case loading
        case loaded(UserProfile)
        case failed
    }

    let users: UserRepository
    private let auth: AuthService

    var state: State = .loading
    var showLogoutDialog = false  //로그아웃 다이얼로그
    var showWithdrawDialog = false  //탈퇴 다이얼로그

    //TODO API 작업 후 수정
    let completedCount = 4
    let estimatedSaving = 30774

    //에상 절약액 섹션 - 월 표시
    var monthText: String {
        "\(Calendar.current.component(.month, from: .now))월"
    }

    init(users: UserRepository, auth: AuthService) {
        self.users = users
        self.auth = auth
    }

    func load() async {

        state = .loading

        do {
            state = .loaded(try await users.fetchMe())
        } catch {
            state = .failed
        }
    }

    var profile: UserProfile? {
        if case .loaded(let p) = state { p } else { nil }
    }

    // 프로필 수정 후 다시 불러오지 않고 닉네임만 바꿔 반영
    func applyNickname(_ nickname: String) {
        guard let p = profile else { return }
        state = .loaded(
            UserProfile(email: p.email, nickname: nickname, diningOutCost: p.diningOutCost)
        )
    }

    func logout() async {
        
        try? await auth.logout()  // 서버 요청이 실패해도 기기의 토큰은 지워짐
        
        SessionStore.shared.expire(
            message: String(localized: "dialog_logout_done_toast")
        )
    }
}
