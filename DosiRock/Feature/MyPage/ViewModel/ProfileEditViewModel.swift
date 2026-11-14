//
//  ProfileEditViewModel.swift
//  DosiRock
//

import Foundation

@Observable @MainActor
final class ProfileEditViewModel {

    private let users: UserRepository
    private let original: String

    let email: String
    var nickname: String
    var isSaving = false
    var errorMessage: String?  // 저장 요청 실패 문구 → 닉네임 칸 아래

    init(users: UserRepository, profile: UserProfile) {
        self.users = users
        email = profile.email
        nickname = profile.nickname
        original = profile.nickname
    }

    private var trimmed: String {
        nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // 한글·영문·숫자 2~10자 (회원가입과 같은 규칙)
    var error: String? {
        if trimmed.isEmpty { return String(localized: "my_profile_nickname_empty") }
        if trimmed.range(of: #"^[가-힣A-Za-z0-9]+$"#, options: .regularExpression) == nil {
            return String(localized: "my_profile_nickname_invalid")
        }
        if !(2...10).contains(trimmed.count) {
            return String(localized: "my_profile_nickname_length")
        }
        return nil
    }

    var canSave: Bool { error == nil && trimmed != original && !isSaving }

    // 성공하면 새 닉네임을 돌려줌
    func save() async -> String? {
        guard canSave else { return nil }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            try await users.updateNickname(trimmed)
            return trimmed
        } catch {
            errorMessage =
                (error as? AuthError)?.errorDescription
                ?? String(localized: "common_save_failed")
            return nil
        }
    }
}
