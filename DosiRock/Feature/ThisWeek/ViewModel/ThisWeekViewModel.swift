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

    init(mealPlans: MealRepository, state: ThisWeekState = .loading) {
        self.mealPlans = mealPlans
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
                state = .recipeList // 계획 있음 -> 목록
            } else if current.hasInventory {
                state = .emptyRecipe  // 계획 없음 + 재료 있음 -> 추천 조건
            } else {
                state = .emptyIngredient  // 둘 다 없음 -> 재료 등록 안내
            }

        } catch {
            state = .error
        }
    }

    // 레시피를 너무 오래 기다리면 이전 화면(재료는 있고 레시피 없음)으로 돌려보낸다
    static let makingTimeout: Duration = .seconds(200)

    // "만드는 중" 화면이 떠 있는 동안 호출. 화면이 사라지면(결과 도착 등) 같이 취소된다
    func waitForRecipe() async {
        try? await Task.sleep(for: Self.makingTimeout)
        guard !Task.isCancelled, state == .makingRecipe else { return }
        state = .emptyRecipe
    }
}
