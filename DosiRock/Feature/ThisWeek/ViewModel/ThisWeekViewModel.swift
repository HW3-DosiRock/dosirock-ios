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
    var toastMessage: LocalizedStringResource?  // 잠깐 보이는 완료 안내 (예: 요일 다시 제안 반영)
    private(set) var errorIsRetryable = true  // 다시 시도하면 성공할 수 있는 실패인지 (횟수 초과는 아님)

    private let mealPlans: MealRepository
    private(set) var plan: MealPlan?  // 응답 받은 계획
    private(set) var planStatus: MealPlanStatus = .none  // 확정 전(DRAFT) / 확정(CONFIRMED)
    var isConfirmed: Bool { planStatus == .confirmed }  // 확정된 계획만 조리 완료 가능

    private let inventory: InventoryRepository
    private let ingredients: IngredientRepository  // 재료 기준 정보 (보관 일수, 소수 자릿수)

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
    // 부족 재료 (GET /meal-plans/{id}/shortages)
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
        ingredients: IngredientRepository,
        state: ThisWeekState = .loading
    ) {
        self.mealPlans = mealPlans
        self.inventory = inventory
        self.ingredients = ingredients
        self.state = state
    }

    // 토요일부터는 서버가 다음 주 계획을 주므로, 계획의 주가 이번 주(한국 시간)보다 뒤인지
    var isNextWeek: Bool {
        guard let weekStartDate else { return false }
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        guard let thisMonday = cal.dateInterval(of: .weekOfYear, for: .now)?.start else {
            return false
        }
        let format = DateFormatter()
        format.calendar = cal
        format.timeZone = cal.timeZone
        format.locale = Locale(identifier: "en_US_POSIX")
        format.dateFormat = "yyyy-MM-dd"
        return weekStartDate > format.string(from: thisMonday)  // "yyyy-MM-dd"는 문자열 비교가 곧 날짜 비교
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
    // 화면이 나타날 때와 "다시 시도"에서 부름
    func load() async {

        // 다른 탭에 다녀와서 화면이 다시 나타나도, 서버에서 만드는 중인 요청을 덮어쓰지 않음
        guard state != .makingRecipe, regeneratingDate == nil else { return }

        errorMessage = nil  // 지난 안내가 다시 나타나지 않게
        recipes = [:]  // 다른 탭에서 재고가 바뀌었을 수 있어 레시피(사용 가능량)를 다시 받음
        await reload()
    }

    // 서버에서 이번 주 상태를 다시 읽음 (제안·확정·구매 등록 뒤 내부에서 부름, 진행 중 가드 없음)
    private func reload() async {

        state = .loading

        do {

            let current = try await mealPlans.fetchCurrent()
            apply(current)
            if current.plan != nil {
                await loadPriorityItems()  // 메뉴의 "빨리 쓸 재료 사용" 뱃지용
                await loadShortages()  // 메뉴의 "추가 재료 필요" 뱃지, 부족 재료 목록용
                await prefillLikeIngredients()  // 조건 변경 화면에 지난 선택 채우기
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
        if let plan = current.plan { soupOption = plan.includeSoup ? .include : .exclude }  // 조건 변경 화면의 기본값
        weekStartDate = current.weekStartDate
        selectedDate = current.defaultSelectedDate
        remainingDailyCount = current.remainingDailyCount
        remainingWeeklyResuggestionCount = current.remainingWeeklyResuggestionCount
    }

    // POST /meal-plans (계획이 없을 때 처음 제안)
    func suggest() async {
        await generate(failureState: .emptyRecipe) {
            try await mealPlans.suggest(
                priorityIngredientIds: priorityItems.filter(\.isOn).map(\.id),
                preferredIngredientIds: likeIngredients.map(\.id),
                includeSoup: soupOption == .include
            )
        }
    }

    // POST /meal-plans/{id}/regenerate (이미 있는 계획을 새 조건으로 전체 교체)
    func resuggest() async {
        guard let id = plan?.mealPlanId else { return }
        await generate(failureState: .recipeList) {
            try await mealPlans.regenerate(
                mealPlanId: id,
                priorityIngredientIds: priorityItems.filter(\.isOn).map(\.id),
                preferredIngredientIds: likeIngredients.map(\.id),
                includeSoup: soupOption == .include
            )
        }
    }

    // 제안·다시 제안 공통: 로딩 → 응답 반영 → 실패하면 failureState로 돌아가 안내
    private func generate(
        failureState: ThisWeekState,
        _ request: () async throws -> MealPlanCurrent
    ) async {

        state = .makingRecipe
        errorMessage = nil

        do {
            apply(try await request())
            await loadShortages()
            state = .recipeList
        } catch {
            await handleGenerationError(error, failureState: failureState)
        }
    }

    // 제안·다시 제안 실패 처리: 코드별 안내, 그 외는 서버 상태를 다시 읽음
    private func handleGenerationError(_ error: Error, failureState: ThisWeekState) async {
        errorIsRetryable = true
        guard let error = error as? APIError else {
            errorMessage = error.localizedDescription
            state = failureState
            return
        }
        switch error.code {
        case "MEALPLAN_DAILY_LIMIT_EXCEEDED":
            errorMessage = String(localized: "thisweek_suggest_limit_exceeded")
            errorIsRetryable = false
            state = failureState
        case "MEALPLAN_RESUGGESTION_LIMIT_EXCEEDED":
            errorMessage = String(localized: "thisweek_resuggest_limit_exceeded")
            errorIsRetryable = false
            state = failureState
        case "MEALPLAN_GENERATION_FAILED", "MEALPLAN_GENERATION_UNAVAILABLE",
            "MEALPLAN_GENERATION_TIMEOUT":
            errorMessage = String(localized: "thisweek_suggest_generation_failed")
            state = failureState
        default:
            // shortcut: 409의 code 문자열이 명세에 없어 그 외 에러는 서버 상태를 다시 불러옴(이미 계획이 있으면 목록으로), 네트워크 오류 등은 메시지만 보여줌
            if case .network = error {
                errorMessage = error.errorDescription
                state = failureState
            } else {
                await reload()
                if state == failureState { errorMessage = error.errorDescription }
            }
        }
    }

    // 지금 다시 제안받는 중인 요일의 날짜 (그 요일 영역만 로딩으로 바꿈)
    private(set) var regeneratingDate: String?

    // POST /meal-plans/{id}/days/{dayOfWeek}/regenerate (저장된 추천 조건 그대로, 그 요일만 교체)
    func resuggestDay(_ day: MealPlanDay) async {
        guard let id = plan?.mealPlanId, regeneratingDate == nil else { return }
        regeneratingDate = day.date
        errorMessage = nil
        defer { regeneratingDate = nil }

        let keptDate = selectedDate  // apply가 선택일을 서버 기본값으로 되돌리므로 보존
        do {
            apply(try await mealPlans.regenerateDay(mealPlanId: id, dayOfWeek: day.dayOfWeek))
            await loadShortages()
            toastMessage = LocalizedStringResource(
                stringLiteral: String(
                    format: String(localized: "thisweek_day_regenerated_toast"),
                    day.weekdayFullText
                )
            )
        } catch {
            await handleGenerationError(error, failureState: .recipeList)
        }
        selectedDate = keptDate
    }

    var isConfirming = false  // 확정 요청 중 (버튼 로딩, 중복 탭 방지)

    // POST /meal-plans/{id}/confirm → 성공하면 서버 상태를 다시 읽어 확정 상태 반영
    func confirm() async {
        guard let id = plan?.mealPlanId, !isConfirming else { return }
        isConfirming = true
        errorMessage = nil
        defer { isConfirming = false }
        do {
            try await mealPlans.confirm(mealPlanId: id)
            await reload()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
        }
    }

    // 서버가 요일별 조리 완료 여부(completed)를 주면 그 값, 아직 안 주면 미완료
    func isCooked(_ day: MealPlanDay) -> Bool { day.completed == true }

    // 조리 완료 시트가 열려 있는 요일의 날짜 (목록의 하단 버튼과 레시피 상세의 조리 완료 버튼이 같이 씀)
    var completingDate: String?
    var completingDay: MealPlanDay? { days.first { $0.date == completingDate } }

    private var catalog: [Int: IngredientItem] = [:]  // 재료 기준 정보 (기본 재료 구분용, 한 번 받아 둠)
    private var completeKeys: [String: String] = [:]  // 날짜 → Idempotency-Key (성공할 때까지 재전송에 같은 키)

    // 조리 완료 시트의 "사용된 재료": 그날 메뉴 재료의 합계, 기본 재료는 서버가 차감하지 않아 제외
    func cookUsage(of day: MealPlanDay) async -> [CookUsage] {
        if catalog.isEmpty, let list = try? await ingredients.fetchAll() {
            catalog = Dictionary(list.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        }
        var order: [Int] = []
        var sums: [Int: CookUsage] = [:]
        for item in day.menus.flatMap(\.ingredients) {
            if catalog[item.ingredientId]?.managementType == .presence { continue }
            let before = sums[item.ingredientId]
            if before == nil { order.append(item.ingredientId) }
            sums[item.ingredientId] = CookUsage(
                id: item.ingredientId, name: item.name,
                amount: (before?.amount ?? 0) + item.amount, unit: item.unit)
        }
        return order.compactMap { sums[$0] }
    }

    // POST /meal-plans/{id}/days/{dayOfWeek}/complete → 성공하면 계획을 다시 읽어 조리 완료 반영
    func completeDay(_ day: MealPlanDay, usedCount: Int) async throws {
        guard let id = plan?.mealPlanId else { throw APIError.unknown }
        let key = completeKeys[day.date] ?? UUID().uuidString
        completeKeys[day.date] = key
        try await mealPlans.completeDay(mealPlanId: id, dayOfWeek: day.dayOfWeek, idempotencyKey: key)
        completeKeys[day.date] = nil
        // 조리는 이미 성공했으므로 갱신이 실패해도 에러로 보지 않음
        let kept = selectedDate
        if let current = try? await mealPlans.fetchCurrent() {
            apply(current)
            await loadShortages()
        }
        await refreshLoadedRecipes()  // 재고가 바뀌어 사용 가능량·부족량을 다시 받음
        selectedDate = kept
        toastMessage = LocalizedStringResource(
            stringLiteral: String(
                format: String(localized: "thisweek_cook_done_toast"),
                day.dayText, day.weekdayText, usedCount
            )
        )
    }

    // 메뉴별 상세 레시피 (메뉴 ID → 불러오는 중 / 실패 / 완료). 한 번 받으면 다시 안 부름
    private(set) var recipes: [Int: RecipeLoad] = [:]

    // 이미 받은 레시피를 다시 받아 바꿈. 비우지 않아서 열려 있는 상세 화면이 "만드는 중"으로 바뀌지 않고, 실패하면 이전 것을 유지
    private func refreshLoadedRecipes() async {
        for (menuId, load) in recipes {
            guard case .loaded = load else { continue }
            if let fresh = try? await mealPlans.fetchRecipe(menuId: menuId) {
                recipes[menuId] = .loaded(fresh)
            }
        }
    }

    func loadRecipe(menuId: Int) async {
        switch recipes[menuId] {
        case .loading, .loaded: return
        default: break
        }
        recipes[menuId] = .loading
        do {
            recipes[menuId] = .loaded(try await mealPlans.fetchRecipe(menuId: menuId))
        } catch {
            recipes[menuId] = .failed
        }
    }

    // 같은 입력으로 다시 저장할 때 같은 키·같은 내용을 보내기 위해 마지막 시도를 기억 (성공하면 지움)
    private struct SaveAttempt {
        let amounts: [Int: Double]
        let bought: Set<Int>
        let entries: [InventoryUpsertEntry]
        let key: String
    }
    private var saveAttempt: SaveAttempt?

    // 구매한 재료 등록 (POST /inventory) → 성공하면 이번 주 계획을 다시 불러옴 (부족 재료·뱃지 갱신). 실패는 시트에서 안내
    // 서버는 입력값으로 재고를 "대체"하므로 산 양이 아니라 (기존 보유량 + 산 양)을 보낸다
    func registerBought(amounts: [Int: Double], bought: Set<Int>) async throws {

        let attempt: SaveAttempt
        if let last = saveAttempt, last.amounts == amounts, last.bought == bought {
            attempt = last  // 재시도: 서버가 처리했는데 응답만 놓친 경우 중복 합산을 막으려고 같은 내용·키 재사용
        } else {
            attempt = SaveAttempt(
                amounts: amounts,
                bought: bought,
                entries: try await makeEntries(amounts: amounts, bought: bought),
                key: UUID().uuidString
            )
            saveAttempt = attempt
        }

        try await inventory.addAll(attempt.entries, idempotencyKey: attempt.key)
        saveAttempt = nil
        await refreshLoadedRecipes()  // 사용 가능량·부족량은 현재 재고 기준이라 다시 받음
        await reload()
    }

    private func makeEntries(amounts: [Int: Double], bought: Set<Int>) async throws -> [InventoryUpsertEntry] {

        async let stock = inventory.fetch()
        async let catalog = ingredients.fetchAll()
        let owned = Dictionary(try await stock.map { ($0.ingredientId, $0) }, uniquingKeysWith: { a, _ in a })
        let byId = Dictionary(try await catalog.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })

        var entries: [InventoryUpsertEntry] = []

        for (id, boughtAmount) in amounts.sorted(by: { $0.key < $1.key }) {
            guard let ingredient = byId[id] else { throw APIError.unknown }
            let current = owned[id]

            let scale = pow(10, Double(ingredient.decimalPlaces))
            let total = (((current?.quantity ?? 0) + boughtAmount) * scale).rounded() / scale
            guard total <= 99999 else {  // 서버 최대 보유량
                throw APIError.validation(["quantity": String(localized: "thisweek_shortage_register_too_large")])
            }

            // 소비기한: 이미 있으면 유지, 새 재료는 오늘 + 보관 일수
            let defaultExpiration = ingredient.storageDays.flatMap {
                Calendar.current.date(byAdding: .day, value: $0, to: .now)
            }
            guard let expiration = current?.recommendedDate ?? defaultExpiration else {
                throw APIError.unknown
            }

            entries.append(InventoryUpsertEntry(ingredient: ingredient, quantity: total, expirationDate: expiration))
        }

        for id in bought.sorted() {
            guard let ingredient = byId[id] else { throw APIError.unknown }
            entries.append(InventoryUpsertEntry(ingredient: ingredient, quantity: nil, expirationDate: nil))
        }

        return entries
    }

    // 부족 재료 (실패하면 빈 목록, 뱃지·목록만 비고 계획 화면은 그대로)
    private func loadShortages() async {
        guard let id = plan?.mealPlanId else {
            shortages = []
            return
        }
        shortages = (try? await mealPlans.fetchShortages(mealPlanId: id).items) ?? []
    }

    // 계획을 만들 때 고른 "먹고 싶은 재료"를 조건 화면에 채움 (재료 목록을 못 받으면 그대로 둠)
    private func prefillLikeIngredients() async {
        guard let ids = plan?.preferredIngredientIds, !ids.isEmpty,
            let catalog = try? await ingredients.fetchAll()
        else { return }
        let byId = Dictionary(catalog.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        likeIngredients = ids.compactMap { byId[$0] }
    }

    // 빨리 써야 할 재료 (실패하면 빈 목록, 조건 화면은 그대로)
    private func loadPriorityItems() async {
        let items = (try? await inventory.fetchPriority()) ?? []
        let chosen = plan?.priorityIngredientIds  // 계획을 만들 때 "먼저 사용"으로 고른 재료
        priorityItems = items.map { item in
            PriorityItem(
                id: item.ingredientId,
                code: item.imageName,
                name: item.name,
                amount: item.quantityText,
                daysLeft: item.remainingDays,
                // 계획이 있으면 그때 고른 재료만 켬, 계획이 없으면 모두 켬
                isOn: chosen?.contains(item.ingredientId) ?? true
            )
        }
    }
}

// 상세 레시피를 받는 상태
enum RecipeLoad {
    case loading
    case failed
    case loaded(RecipeDetail)

    var detail: RecipeDetail? {
        if case .loaded(let recipe) = self { recipe } else { nil }
    }

    var phase: RecipeDetailView.Phase {
        switch self {
        case .loading: .generating
        case .failed: .failed
        case .loaded: .ready
        }
    }
}
