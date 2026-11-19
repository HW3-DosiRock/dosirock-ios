//
//  MealRepository.swift
//  DosiRock
//
//  Created by Admin on 11/19/26.
//

import Foundation

protocol MealRepository {

    //GET  meal-plans/current
    func fetchCurrent() async throws -> MealPlanCurrent

    //POST meal-plans
    func suggest(
        priorityIngredientIds: [Int],
        preferredIngredientIds: [Int],
        includeSoup: Bool
    ) async throws -> MealPlan

}

struct MealPlanRepositoryImpl: MealRepository {

    let client: APIClient

    func fetchCurrent() async throws -> MealPlanCurrent {

        try await client.sendRequired(
            "meal-plans/current",
            method: .get,
            authorized: true,
            as: MealPlanCurrent.self,
        )

    }

    func suggest(
        priorityIngredientIds: [Int],
        preferredIngredientIds: [Int],
        includeSoup: Bool
    ) async throws -> MealPlan {

        try await client.sendRequired(
            "meal-plans",
            method: .post,
            body: [
                "priorityIngredientIds": priorityIngredientIds,
                "preferredIngredientIds": preferredIngredientIds,
                "includeSoup": includeSoup,
            ],
            timeout: 200,
            authorized: true,
            as: MealPlan.self
        )
    }

}

#if DEBUG
    // 프리뷰·화면 확인용 가짜 (더미 서버는 항상 "계획 있음"이라 다른 분기는 여기서 확인)
    struct PreviewMealRepository: MealRepository {

        enum Scenario { case hasPlan, noPlan, noInventory, failure }
        var scenario: Scenario = .hasPlan

        // shortcut: 계획 내용은 비어 있음, 계획 목록 화면 만들 때 샘플 채우기
        static let samplePlan = MealPlan(
            weekStartDate: "2026-11-16",
            days: [],
            shortages: []
        )

        func fetchCurrent() async throws -> MealPlanCurrent {
            try await Task.sleep(for: .milliseconds(500))  // 로딩 화면 잠깐 보이게
            switch scenario {
            case .hasPlan:
                return MealPlanCurrent(
                    hasInventory: true,
                    status: .draft,
                    plan: Self.samplePlan
                )
            case .noPlan:
                return MealPlanCurrent(
                    hasInventory: true,
                    status: .none,
                    plan: nil
                )
            case .noInventory:
                return MealPlanCurrent(
                    hasInventory: false,
                    status: .none,
                    plan: nil
                )
            case .failure:
                throw APIError.network
            }
        }

        func suggest(
            priorityIngredientIds: [Int],
            preferredIngredientIds: [Int],
            includeSoup: Bool
        ) async throws -> MealPlan {
            try await Task.sleep(for: .seconds(3))  // 더미처럼 3초
            return Self.samplePlan
        }
    }
#endif
