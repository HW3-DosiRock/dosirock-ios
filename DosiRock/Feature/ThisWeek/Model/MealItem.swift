//
//  MealItem.swift
//  DosiRock
//
//  Created by Admin on 11/19/26.
//
 
import Foundation

// 계획 상태 (20번 실제 API 기준 + 더미용 READY)
nonisolated enum MealPlanStatus: String, Decodable {
    case none = "NONE"
    case draft = "DRAFT"
    case confirmed = "CONFIRMED"
    case ready = "READY"   // 더미 전용. 20번 전환 후 삭제
}

// GET /meal-plans/current 의 data
nonisolated struct MealPlanCurrent: Decodable {
    let hasInventory: Bool
    let status: MealPlanStatus  //계획 상태
    let plan: MealPlan?          // 계획이 없으면 null
}

nonisolated struct MealPlan: Decodable {
    let weekStartDate: String    // "yyyy-MM-dd"
    let days: [MealPlanDay]     // 계획 목록
    let shortages: [Shortage]   // 부족 재료
}

nonisolated struct MealPlanDay: Decodable {
    let dayOfWeek: String        // ENUM "MONDAY" ...
    let date: String
    let totalCookMinutes: Int
    let menus: [Menu]
}

nonisolated struct Menu: Decodable {
    let name: String
    let cookMinutes: Int
    let ingredients: [MenuIngredient]
    let steps: [String]
}

nonisolated struct MenuIngredient: Decodable {
    let ingredientId: Int
    let name: String
    let amount: Double
    let unit: String
    let owned: Bool
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
}

nonisolated extension Shortage {
    var imageName: String { IngredientImageMap.assetName(for: name) }

    // 60 → "60g", 0.5 → "0.5개" (정수면 소수점 없이)
    var amountText: String {
        amount.formatted(.number.grouping(.never).precision(.fractionLength(0...2))) + unit
    }
}
