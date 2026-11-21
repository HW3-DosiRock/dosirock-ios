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
    private(set) var planStatus: MealPlanStatus = .none  // 확정 전(DRAFT) / 확정(CONFIRMED)
    var isConfirmed: Bool { planStatus == .confirmed }  // 확정된 계획만 조리 완료 가능

    private let inventory: InventoryRepository

    // 추천 조건
    var priorityItems: [PriorityItem] = []  // 우선 순위 아이템
    var likeIngredients: [IngredientItem] = []  // 먹고 싶은 재료 (고른 순서대로)
    var soupOption: SoupOption = .exclude  // 국물 기본값: 제외
    
    //계획 목록 화면
    var selectedDate: String?  // 사용자가 고른 요일의 날짜 (고르기 전이면 서버의 기본 선택일)
    private(set) var weekStartDate: String?  // 대상 주 월요일 "yyyy-MM-dd"
    private(set) var remainingDailyCount: Int?  // 전체 제안 남은 일일 횟수
    private(set) var remainingWeeklyResuggestionCount: Int?  // 주간 다시 제안 남은 일일 횟수
    var days: [MealPlanDay] { plan?.days ?? [] }
    // shortcut: 부족 재료 조회 API(GET /meal-plans/{id}/shortages) 연동 전까지 빈 목록
    private(set) var shortages: [Shortage] = []
    var shortageIds: Set<Int> { Set(shortages.map(\.ingredientId)) }  // 부족한 재료 id
    // 고른 날이 새 계획에 없으면(다시 제안 등) 첫날로
    var selectedDay: MealPlanDay? { days.first { $0.date == selectedDate } ?? days.first }
    // 메뉴 카드 뱃지: 빨리 써야 할 재료를 쓰면 "빨리 쓸 재료 사용", 없는 재료가 있으면 "추가 재료 필요"
    func badges(for menu: Menu) -> [RecipeState] {
        let priorityIds = Set(priorityItems.map(\.id))
        var result: [RecipeState] = []
        if menu.ingredients.contains(where: { priorityIds.contains($0.ingredientId) }) {
            result.append(.useSoon)
        }
        if menu.ingredients.contains(where: { shortageIds.contains($0.ingredientId) }) {
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

        // 서버는 토요일부터 다음 주 계획을 주므로 .now가 아니라 응답의 weekStartDate 기준
        let monday =
            weekStartDate.flatMap {
                try? Date($0, strategy: Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
            } ?? cal.dateInterval(of: .weekOfYear, for: .now)?.start

        guard let monday, let friday = cal.date(byAdding: .day, value: 4, to: monday)
        else { return "" }

        let start = cal.dateComponents([.month, .day], from: monday)
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
            apply(current)
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

    // 서버 응답(GET /meal-plans/current, POST /meal-plans)을 화면 상태에 반영
    private func apply(_ current: MealPlanCurrent) {
        plan = current.plan
        planStatus = current.status
        weekStartDate = current.weekStartDate
        selectedDate = current.defaultSelectedDate
        remainingDailyCount = current.remainingDailyCount
        remainingWeeklyResuggestionCount = current.remainingWeeklyResuggestionCount
    }

    // POST /meal-plans
    func suggest() async {

        state = .makingRecipe
        errorMessage = nil

        do {
            apply(
                try await mealPlans.suggest(
                    priorityIngredientIds: priorityItems.filter(\.isOn).map(\.id),
                    preferredIngredientIds: likeIngredients.map(\.id),
                    includeSoup: soupOption == .include
                )
            )
            state = .recipeList
        } catch let error as APIError {
            switch error.code {
            case "MEALPLAN_DAILY_LIMIT_EXCEEDED":
                errorMessage = String(localized: "thisweek_suggest_limit_exceeded")
                state = .emptyRecipe
            case "MEALPLAN_GENERATION_FAILED", "MEALPLAN_GENERATION_UNAVAILABLE",
                "MEALPLAN_GENERATION_TIMEOUT":
                errorMessage = String(localized: "thisweek_suggest_generation_failed")
                state = .emptyRecipe
            default:
                // shortcut: 409의 code 문자열이 명세에 없어 그 외 에러는 서버 상태를 다시 불러옴(이미 계획이 있으면 목록으로), 네트워크 오류 등은 메시지만 보여줌
                if case .network = error {
                    errorMessage = error.errorDescription
                    state = .emptyRecipe
                } else {
                    await load()
                    if state == .emptyRecipe { errorMessage = error.errorDescription }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            state = .emptyRecipe
        }
    }

    // 구매한 재료 등록 → 성공하면 이번 주 계획을 다시 불러옴 (부족 재료·뱃지 갱신). 실패는 시트에서 안내
    func registerBought(amounts: [Int: Double], bought: Set<Int>) async throws {
        try await mealPlans.registerBought(amounts: amounts, bought: bought)
        await load()
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
