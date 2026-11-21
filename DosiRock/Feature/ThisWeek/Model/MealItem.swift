//
//  MealItem.swift
//  DosiRock
//
//  Created by Admin on 11/19/26.
//
 
import Foundation

// 계획 상태
nonisolated enum MealPlanStatus: String, Decodable {
    case none = "NONE"
    case draft = "DRAFT"
    case confirmed = "CONFIRMED"
}

// GET /meal-plans/current, POST /meal-plans, POST .../regenerate 의 data
nonisolated struct MealPlanCurrent: Decodable {
    let hasInventory: Bool
    let status: MealPlanStatus  //계획 상태
    let weekStartDate: String  // 대상 주 월요일 "yyyy-MM-dd"
    let defaultSelectedDate: String  // 처음 선택할 날짜 (평일은 오늘, 주말은 월요일)
    let plan: MealPlan?  // 계획이 없으면 null
    let remainingDailyCount: Int  // 전체 제안 남은 일일 횟수 (0~15)
    let remainingWeeklyResuggestionCount: Int  // 주간 다시 제안 남은 일일 횟수 (0~2)
    let resetsAt: String  // 다음 한국 자정 (date-time)
}

nonisolated struct MealPlan: Decodable {
    let mealPlanId: Int  // 확정·다시 제안 요청에 사용
    let priorityIngredientIds: [Int]  // 먼저 사용할 재료
    let preferredIngredientIds: [Int]  // 먹고 싶은 재료
    let includeSoup: Bool
    let days: [MealPlanDay]  // 월~금 5일
}

// 한그릇 ONE, 반찬 SIDE, 국물 포함 SOUP
nonisolated enum MealPlanDayType: String, Decodable {
    case one = "ONE"
    case side = "SIDE"
    case soup = "SOUP"
}

nonisolated struct MealPlanDay: Decodable {
    let dayOfWeek: String  // ENUM "MONDAY" ...
    let date: String
    let type: MealPlanDayType
    let totalCookMinutes: Int  // 국+조리 요리 합계, 상비 반찬 제외
    let soup: Menu?  // SOUP이 아니면 null
    let dishes: [Menu]  // 국·상비 반찬 제외한 조리 요리
    let readySides: [MenuIngredient]  // 그대로 내는 상비 반찬, 없으면 빈 배열
    let remainingResuggestionCount: Int  // 이 요일 다시 제안 남은 횟수 (0~2)
}

nonisolated extension MealPlanDay {
    // 기존 화면 호환용: 국 + 조리 요리
    var menus: [Menu] { (soup.map { [$0] } ?? []) + dishes }
}

nonisolated struct Menu: Decodable {
    let menuId: Int
    let name: String
    let cookMinutes: Int
    let ingredients: [MenuIngredient]
}

nonisolated struct MenuIngredient: Decodable {
    let ingredientId: Int
    let name: String
    let amount: Double
    let unit: String
}

nonisolated struct Shortage: Decodable {
    let ingredientId: Int
    let name: String
    let amount: Double
    let unit: String
}

// 화면 표시용
nonisolated extension MealPlanDay {
    private static let dayFormat = Date.ISO8601FormatStyle(timeZone: .current).year().month().day()

    private func formatted(_ pattern: String) -> String {
        guard let parsed = try? Date(date, strategy: Self.dayFormat) else { return "" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = pattern
        return f.string(from: parsed)
    }

    var weekdayText: String { formatted("E") }  // "월"
    var dayText: String { formatted("M/d") }  // "11/16"
    var weekdayFullText: String { formatted("EEEE") }  // "월요일"
}

nonisolated extension MenuIngredient {
    var imageName: String { IngredientImageMap.assetName(for: name) }

    // 150 → "150g", 0.2 → "0.2포기" (정수면 소수점 없이)
    var amountText: String {
        amount.formatted(.number.grouping(.never).precision(.fractionLength(0...2))) + unit
    }
}

nonisolated extension Shortage: Identifiable {
    var id: Int { ingredientId }

    var imageName: String { IngredientImageMap.assetName(for: name) }

    // shortcut: 응답에 관리 방식이 없어 부족한 양이 0이면 기본 재료(보유 여부만 관리)로 봄, managementType 필드가 오면 교체
    var isPresence: Bool { amount == 0 }

    // 60 → "60g", 0.5 → "0.5개" (정수면 소수점 없이)
    var amountText: String {
        amount.formatted(.number.grouping(.never).precision(.fractionLength(0...2))) + unit
    }
}
