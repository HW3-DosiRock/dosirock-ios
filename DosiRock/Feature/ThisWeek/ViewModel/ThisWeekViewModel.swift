//
//  ThisWeekViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import Foundation

@Observable @MainActor
final class ThisWeekViewModel {

    var state: ThisWeekState  // 어떤 화면을 보여줄지
    var errorMessage: String?  // 불러오기 실패 문구

    private let mealPlans: MealRepository
    private(set) var plan: MealPlan?  // 응답 받은 계힉
    private let inventory: InventoryRepository

    // 추천 조건
    var priorityItems: [PriorityItem] = []  // 우선 순위 아이템
    var likeIngredients: [IngredientItem] = []  // 먹고 싶은 재료 (고른 순서대로)
    var soupOption: SoupOption = .exclude  // 국물 기본값: 제외

    init(
        mealPlans: MealRepository,
        inventory: InventoryRepository,
        state: ThisWeekState = .loading
    ) {
        self.mealPlans = mealPlans
        self.inventory = inventory
        self.state = state
    }

    // "11월 9일~13일" (월~금). 월이 바뀌는 주는 "10월 28일~11월 1일"
    var weekRangeText: String {
        var cal = Calendar(identifier: .iso8601)  // 주가 월요일에 시작
        cal.locale = Locale(identifier: "ko_KR")

        guard let week = cal.dateInterval(of: .weekOfYear, for: .now),
            let friday = cal.date(byAdding: .day, value: 4, to: week.start)
        else { return "" }

        let start = cal.dateComponents([.month, .day], from: week.start)
        let end = cal.dateComponents([.month, .day], from: friday)

        if start.month == end.month {
            return
                "\(start.month ?? 0)월 \(start.day ?? 0)일~\(end.day ?? 0)일 도시락"
        }
        return
            "\(start.month ?? 0)월 \(start.day ?? 0)일~\(end.month ?? 0)월 \(end.day ?? 0)일 도시락"
    }

    // 화면이 나타날 때 호출. 서버 응답에 따라 state를 정한다
    func load() async {

        state = .loading

        do {

            let current = try await mealPlans.fetchCurrent()
            plan = current.plan
            if current.plan != nil {
                state = .recipeList  // 계획 있음 -> 목록
            } else if current.hasInventory {
                await loadPriorityItems()
                state = .emptyRecipe  // 계획 없음 + 재료 있음 -> 추천 조건
            } else {
                state = .emptyIngredient  // 둘 다 없음 -> 재료 등록 안내
            }

        } catch {
            state = .error
        }
    }

    func suggest() async {

        state = .makingRecipe

        do {
            plan = try await mealPlans.suggest(
                priorityIngredientIds: priorityItems.filter(\.isOn).map(\.id),
                preferredIngredientIds: likeIngredients.map(\.id),
                includeSoup: soupOption == .include
            )

            state = .recipeList
        } catch {
            state = .emptyRecipe
        }
    }

    // 빨리 써야 할 재료 (실패하면 빈 목록, 조건 화면은 그대로)
    private func loadPriorityItems() async {
        let items = (try? await inventory.fetchPriority()) ?? []
        priorityItems = items.map {
            PriorityItem(
                id: $0.ingredientId,
                code: $0.imageName,
                name: $0.name,
                amount: $0.quantityText,
                daysLeft: $0.remainingDays
            )
        }
    }
}
