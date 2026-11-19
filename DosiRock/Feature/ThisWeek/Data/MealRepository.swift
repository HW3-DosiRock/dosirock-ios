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

        // 더미 서버 고정 응답과 같은 내용 (월~금 메뉴, 부족 재료 대파 60g)
        static let samplePlan = MealPlan(
            weekStartDate: "2026-11-16",
            days: [
                day("MONDAY", "2026-11-16", menu("닭고기 간장조림", 25, [
                    item(35, "닭고기", 200, "g"), item(1, "양파", 100, "g"), item(57, "간장", 10, "ml"),
                ], ["닭고기를 한입 크기로 썬다", "양파와 함께 볶는다", "간장을 넣고 졸인다"])),
                day("TUESDAY", "2026-11-17", menu("팽이버섯 달걀말이", 15, [
                    item(39, "달걀", 3, "개"), item(25, "팽이버섯", 100, "g"), item(2, "대파", 30, "g", owned: false),
                ], ["달걀을 풀고 잘게 썬 팽이버섯·대파를 섞는다", "팬에 부어 돌돌 만다"])),
                day("WEDNESDAY", "2026-11-18", menu("두부조림", 20, [
                    item(40, "두부", 1, "개"), item(57, "간장", 10, "ml"), item(2, "대파", 30, "g", owned: false),
                ], ["두부를 도톰하게 썰어 굽는다", "간장 양념을 붓고 졸인다", "대파를 올린다"])),
                day("THURSDAY", "2026-11-19", menu("닭고기 양파볶음", 20, [
                    item(35, "닭고기", 200, "g"), item(1, "양파", 150, "g"),
                ], ["닭고기를 볶는다", "양파를 넣고 함께 볶는다"])),
                day("FRIDAY", "2026-11-20", menu("달걀 볶음밥", 15, [
                    item(39, "달걀", 2, "개"), item(1, "양파", 50, "g"), item(57, "간장", 10, "ml"),
                ], ["양파를 볶는다", "밥과 달걀을 넣고 볶는다", "간장으로 간한다"])),
            ],
            shortages: [Shortage(ingredientId: 2, name: "대파", amount: 60, unit: "g")]
        )

        // 샘플을 짧게 쓰기 위한 도우미
        private static func day(_ dayOfWeek: String, _ date: String, _ menu: Menu) -> MealPlanDay {
            MealPlanDay(dayOfWeek: dayOfWeek, date: date, totalCookMinutes: menu.cookMinutes, menus: [menu])
        }
        private static func menu(
            _ name: String, _ minutes: Int, _ ingredients: [MenuIngredient], _ steps: [String]
        ) -> Menu {
            Menu(name: name, cookMinutes: minutes, ingredients: ingredients, steps: steps)
        }
        private static func item(
            _ id: Int, _ name: String, _ amount: Double, _ unit: String, owned: Bool = true
        ) -> MenuIngredient {
            MenuIngredient(ingredientId: id, name: name, amount: amount, unit: unit, owned: owned)
        }

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
