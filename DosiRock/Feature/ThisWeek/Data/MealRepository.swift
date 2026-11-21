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
    ) async throws -> MealPlanCurrent

    //POST meal-plans/{mealPlanId}/confirm (이미 확정한 계획도 성공)
    func confirm(mealPlanId: Int) async throws

    //GET  meal-plans/{mealPlanId}/shortages
    func fetchShortages(mealPlanId: Int) async throws
        -> MealPlanShortageResponse

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
    ) async throws -> MealPlanCurrent {

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
            as: MealPlanCurrent.self
        )
    }

    func fetchShortages(mealPlanId: Int) async throws
        -> MealPlanShortageResponse
    {

        try await client.sendRequired(
            "meal-plans/\(mealPlanId)/shortages",
            method: .get,
            authorized: true,
            as: MealPlanShortageResponse.self
        )
    }

    func confirm(mealPlanId: Int) async throws {

        _ = try await client.send(
            "meal-plans/\(mealPlanId)/confirm",
            method: .post,
            authorized: true,
            as: Empty.self
        )
    }

}

#if DEBUG
    // 프리뷰·화면 확인용 가짜 (더미 서버는 항상 "계획 있음"이라 다른 분기는 여기서 확인)
    struct PreviewMealRepository: MealRepository {

        enum Scenario { case hasPlan, noPlan, noInventory, failure }
        var scenario: Scenario = .hasPlan

        // 월~금 메뉴 샘플 (부족 재료는 아래 sampleShortages)
        static let samplePlan = MealPlan(
            mealPlanId: 1,
            priorityIngredientIds: [35, 25],
            preferredIngredientIds: [],
            includeSoup: false,
            days: [
                day(
                    "MONDAY",
                    "2026-11-16",
                    menu(
                        1,
                        "닭고기 간장조림",
                        25,
                        [
                            item(35, "닭고기", 200, "g"), item(1, "양파", 100, "g"),
                            item(57, "간장", 10, "ml"),
                        ]
                    )
                ),
                day(
                    "TUESDAY",
                    "2026-11-17",
                    menu(
                        2,
                        "팽이버섯 달걀말이",
                        15,
                        [
                            item(39, "달걀", 3, "개"), item(25, "팽이버섯", 100, "g"),
                            item(2, "대파", 30, "g"),
                        ]
                    )
                ),
                day(
                    "WEDNESDAY",
                    "2026-11-18",
                    menu(
                        3,
                        "두부조림",
                        20,
                        [
                            item(40, "두부", 1, "개"), item(57, "간장", 10, "ml"),
                            item(2, "대파", 30, "g"),
                        ]
                    )
                ),
                day(
                    "THURSDAY",
                    "2026-11-19",
                    menu(
                        4,
                        "닭고기 양파볶음",
                        20,
                        [
                            item(35, "닭고기", 200, "g"), item(1, "양파", 150, "g"),
                        ]
                    )
                ),
                day(
                    "FRIDAY",
                    "2026-11-20",
                    menu(
                        5,
                        "달걀 볶음밥",
                        15,
                        [
                            item(39, "달걀", 2, "개"), item(1, "양파", 50, "g"),
                            item(57, "간장", 10, "ml"),
                        ]
                    )
                ),
            ]
        )

        // 부족 재료 샘플 (대파 60g)
        static let sampleShortages = [
            Shortage(
                ingredientId: 2,
                name: "대파",
                amount: 60,
                unit: "g",
                managementType: .quantity,
                menuNames: ["팽이버섯 달걀말이", "두부조림"],
                purchaseUrl: nil
            )
        ]

        // 샘플을 짧게 쓰기 위한 도우미
        private static func day(
            _ dayOfWeek: String,
            _ date: String,
            _ menu: Menu
        ) -> MealPlanDay {
            MealPlanDay(
                dayOfWeek: dayOfWeek,
                date: date,
                type: .side,
                totalCookMinutes: menu.cookMinutes,
                soup: nil,
                dishes: [menu],
                readySides: [],
                remainingResuggestionCount: 2
            )
        }
        private static func menu(
            _ id: Int,
            _ name: String,
            _ minutes: Int,
            _ ingredients: [MenuIngredient]
        ) -> Menu {
            Menu(
                menuId: id,
                name: name,
                cookMinutes: minutes,
                ingredients: ingredients
            )
        }
        private static func item(
            _ id: Int,
            _ name: String,
            _ amount: Double,
            _ unit: String
        ) -> MenuIngredient {
            MenuIngredient(
                ingredientId: id,
                name: name,
                amount: amount,
                unit: unit
            )
        }

        private static func current(
            _ status: MealPlanStatus,
            plan: MealPlan?,
            hasInventory: Bool = true
        ) -> MealPlanCurrent {
            MealPlanCurrent(
                hasInventory: hasInventory,
                status: status,
                weekStartDate: "2026-11-16",
                defaultSelectedDate: "2026-11-16",
                plan: plan,
                remainingDailyCount: 15,
                remainingWeeklyResuggestionCount: 2,
                resetsAt: "2026-11-22T00:00:00+09:00"
            )
        }

        func fetchCurrent() async throws -> MealPlanCurrent {
            try await Task.sleep(for: .milliseconds(500))  // 로딩 화면 잠깐 보이게
            switch scenario {
            case .hasPlan: return Self.current(.draft, plan: Self.samplePlan)
            case .noPlan: return Self.current(.none, plan: nil)
            case .noInventory:
                return Self.current(.none, plan: nil, hasInventory: false)
            case .failure: throw APIError.network
            }
        }

        func suggest(
            priorityIngredientIds: [Int],
            preferredIngredientIds: [Int],
            includeSoup: Bool
        ) async throws -> MealPlanCurrent {
            try await Task.sleep(for: .seconds(3))  // 더미처럼 3초
            return Self.current(.draft, plan: Self.samplePlan)
        }

        func confirm(mealPlanId: Int) async throws {
            try await Task.sleep(for: .milliseconds(500))
            if scenario == .failure { throw APIError.network }
        }

        func fetchShortages(mealPlanId: Int) async throws
            -> MealPlanShortageResponse
        {
            if scenario == .failure { throw APIError.network }
            return MealPlanShortageResponse(
                items: Self.sampleShortages,
                totalCost: 0,
                costEstimationStatus: .unavailable
            )
        }
    }
#endif
