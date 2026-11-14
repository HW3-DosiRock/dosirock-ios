//
//  ThisWeekViewModel.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import Foundation

@Observable @MainActor
final class ThisWeekViewModel {

    // MARK: - State

    var state: ThisWeekState  // 어떤 화면을 보여줄지
    var errorMessage: String?  // 불러오기 실패 문구

    // MARK: - Init

    // 프리뷰에서 원하는 상태로 바로 확인할 수 있게 초기 상태를 받는다
    init(state: ThisWeekState = .loading) {
        self.state = state
    }

    // MARK: - Derived

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
            return "\(start.month ?? 0)월 \(start.day ?? 0)일~\(end.day ?? 0)일"
        }
        return
            "\(start.month ?? 0)월 \(start.day ?? 0)일~\(end.month ?? 0)월 \(end.day ?? 0)일 도시락"
    }

    // MARK: - Actions

    // 화면이 나타날 때 호출. 서버 응답에 따라 state를 정한다
    func load() async {
        // TODO API 연동 시 교체: 응답을 보고 아래처럼 상태를 정한다
        //   재료 없음 → .emptyIngredient / 재료 있고 레시피 없음 → .emptyRecipe ...
        state = .emptyRecipe
    }
}
