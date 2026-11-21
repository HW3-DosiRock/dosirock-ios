//
//  ThisWeekRoute.swift
//  DosiRock
//

// 이번주 탭에서 이동하는 화면 (마이페이지의 MyPageRoute와 같은 방식)
enum ThisWeekRoute: Hashable {
    case shortages  // 추가로 필요한 재료
    case editCondition  // 추천 조건 변경
    case recipe(date: String, menuIndex: Int)  // 레시피 상세 (그날의 몇 번째 메뉴)
}
