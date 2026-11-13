//
//  SessionStore.swift
//  DosiRock
//
//  Created by Admin on 11/13/26.
//

import Foundation

// 앱 전체가 공유하는 로그인 상태.
// RootView가 이 값을 보고 로그인 화면/메인 화면을 고르고,
// 네트워크 코드는 토큰을 더 쓸 수 없게 되면 isLoggedIn을 false로 바꿔서 로그인 화면으로 보낸다.
@Observable @MainActor
final class SessionStore {

    static let shared = SessionStore()  // 앱 전체에서 하나만 쓴다
    private init() {}

    var isLoggedIn = false

    // 로그인이 강제로 풀렸을 때 안내할 문구. 로그인 화면이 토스트로 보여주고 비운다
    var expiredMessage: String?

    // 서버가 토큰을 거부해서(만료, 다른 기기 로그인 등) 로그인 화면으로 보낼 때 쓴다.
    // 사용자가 직접 로그아웃하는 경우와 구분하려고 따로 만든 함수 (그때는 안내가 필요 없음)
    func expire(message: String?) {
        TokenStore.clear()
        expiredMessage = message
        isLoggedIn = false
    }
}
