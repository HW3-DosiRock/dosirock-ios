//
//  UserRepository.swift
//  DosiRock
//
//  Created by Admin on 11/13/26.
//

import Foundation

// 내 정보 (api 목록)
protocol UserRepository {

    func fetchMe() async throws -> UserProfile
    func updateNickname(_ nickname: String) async throws
    func updateDiningOutCost(_ cost: Int) async throws
    func changePassword(current: String, new: String) async throws
    func fetchSummary() async throws -> CookingSummary  // 이번 달 조리 완료 횟수 · 예상 절약액
    func withdraw() async throws  // 회원 탈퇴

}

struct UserRepositoryImpl: UserRepository {

    let client: APIClient
    
    func fetchMe() async throws -> UserProfile {
        try await client.sendRequired(
            "users/me",
            method: .get,
            authorized: true,
            as: UserProfile.self
        )

    }

    func updateNickname(_ nickname: String) async throws {

        _ = try await client.send(
            "users/me",
            method: .patch,
            body: ["nickname": nickname],
            authorized: true,
            as: Empty.self
        )
    }

    func fetchSummary() async throws -> CookingSummary {
        try await client.sendRequired(
            "users/me/summary",
            method: .get,
            authorized: true,
            as: CookingSummary.self
        )
    }

    func withdraw() async throws {
        _ = try await client.send(
            "users/me",
            method: .delete,
            authorized: true,
            as: Empty.self
        )
    }

    func updateDiningOutCost(_ cost: Int) async throws {
        _ = try await client.send(
            "users/me/dining-out-cost",
            method: .patch,
            body: ["diningOutCost": cost],
            authorized: true,
            as: Empty.self
        )
    }

    func changePassword(current: String, new: String) async throws {
        _ = try await client.send(
            "users/me/password",
            method: .patch,
            body: ["currentPassword": current, "newPassword": new],
            authorized: true,
            as: Empty.self
        )

    }

}

#if DEBUG
    // 프리뷰·화면 확인용 가짜. 서버 없이 샘플을 바로 돌려준다
    struct PreviewUserRepository: UserRepository {
        var shouldFail = false  // true면 불러오기 실패 상태를 볼 수 있다

        func fetchMe() async throws -> UserProfile {
            if shouldFail { throw APIError.network }
            return UserProfile(
                email: "dosirak@example.com",
                nickname: "배고픈돌멩",
                diningOutCost: 12000
            )
        }
        func updateNickname(_ nickname: String) async throws {}
        func updateDiningOutCost(_ cost: Int) async throws {}
        func changePassword(current: String, new: String) async throws {}
        func withdraw() async throws {}
        func fetchSummary() async throws -> CookingSummary {
            CookingSummary(
                month: "2026-11", completedCount: 4, estimatedSavings: 30774,
                partialEstimationCount: 0, unavailableEstimationCount: 0
            )
        }
    }
#endif
