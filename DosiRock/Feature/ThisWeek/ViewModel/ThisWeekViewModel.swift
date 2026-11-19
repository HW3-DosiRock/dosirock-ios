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
    private(set) var plan: MealPlan?  // 응답 받은 계획

    private let inventory: InventoryRepository

    // 추천 조건
    var priorityItems: [PriorityItem] = []  // 우선 순위 아이템
    var likeIngredients: [IngredientItem] = []  // 먹고 싶은 재료 (고른 순서대로)
    var soupOption: SoupOption = .exclude  // 국물 기본값: 제외
    
    //계획 목록 화면
    var selectedDate: String?  // 사용자가 고른 요일의 날짜 (고르기 전이면 첫날)
    var days: [MealPlanDay] { plan?.days ?? [] }
    var shortages: [Shortage] { plan?.shortages ?? [] }
    // 고른 날이 새 계획에 없으면(다시 제안 등) 첫날로
    var selectedDay: MealPlanDay? { days.first { $0.date == selectedDate } ?? days.first }
    // 메뉴 카드 뱃지: 빨리 써야 할 재료를 쓰면 "빨리 쓸 재료 사용", 없는 재료가 있으면 "추가 재료 필요"
    func badges(for menu: Menu) -> [RecipeState] {
        let priorityIds = Set(priorityItems.map(\.id))
        var result: [RecipeState] = []
        if menu.ingredients.contains(where: { priorityIds.contains($0.ingredientId) }) {
            result.append(.useSoon)
        }
        if menu.ingredients.contains(where: { !$0.owned }) {
            result.append(.needMore)
        }
        return result
    }

    // "닭고기, 양파 외 4종" (2개 이하면 이름만)
    var shortageSummary: String {
        let names = shortages.prefix(2).map(\.name).joined(separator: ", ")
        let rest = shortages.count - 2
        guard rest > 0 else { return names }
        return String(format: String(localized: "thisweek_shortage_more"), names, rest)
    }

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
                await loadPriorityItems()  // 메뉴의 "빨리 쓸 재료 사용" 뱃지용
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
