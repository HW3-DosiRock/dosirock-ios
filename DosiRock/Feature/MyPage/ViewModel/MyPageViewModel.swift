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

    // 이번 달 요약 (실패하면 nil, 프로필은 그대로 보여주고 숫자만 "-")
    private(set) var summary: CookingSummary?

    var completedText: String {
        summary.map { String(format: String(localized: "my_menu_complete_count"), $0.completedCount) } ?? "-"
    }

    // 조리한 기록이 모두 가격 미산정이면 0원이 아니라 "미산정"
    var savingText: String {
        guard let summary else { return "-" }
        if summary.completedCount > 0, summary.unavailableEstimationCount == summary.completedCount {
            return String(localized: "my_menu_saving_unavailable")
        }
        return String(
            format: String(localized: "common_won_format"),
            Int(summary.estimatedSavings.rounded()).formatted()
        )
    }

    // 예상 절약액 섹션 - 월 표시 (서버의 한국 기준 월, 형식이 다르면 기기 달력)
    var monthText: String {
        let month =
            summary.flatMap { Int($0.month.split(separator: "-").last ?? "") }
            ?? Calendar.current.component(.month, from: .now)
        return "\(month)월"
    }

    init(users: UserRepository, auth: AuthService) {
        self.users = users
        self.auth = auth
    }

    func load() async {

        state = .loading

        async let fetchedSummary = try? users.fetchSummary()  // 프로필과 같이 받되, 실패해도 프로필 화면은 보여줌
        do {
            state = .loaded(try await users.fetchMe())
        } catch {
            state = .failed
        }
        summary = await fetchedSummary
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

    func applyDiningOutCost(_ cost: Int) {
        guard let p = profile else { return }
        state = .loaded(UserProfile(email: p.email, nickname: p.nickname, diningOutCost: cost))
    }

    func logout() async {
        
        try? await auth.logout()  // 서버 요청이 실패해도 기기의 토큰은 지워짐
        
        SessionStore.shared.expire(
            message: String(localized: "dialog_logout_done_toast")
        )
    }
}
