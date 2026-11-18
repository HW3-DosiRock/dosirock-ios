//
//  IngredientNameBreak.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

// 타일에서 긴 재료 이름을 두 줄로 나눌 위치를 정하는 표 (표에 없는 이름은 그대로 표시)
// 서버 이름이 바뀌어도 줄바꿈 처리만 빠질 뿐, 표시가 깨지지는 않는다
nonisolated enum IngredientNameBreak {

    static func display(_ main: String) -> String { map[main] ?? main }

    // 띄어쓰기가 없어서 자동 줄바꿈이 글자 중간에서 끊기는 이름만 적는다
    private static let map: [String: String] = [
        "느타리버섯": "느타리\n버섯",
        "새송이버섯": "새송이\n버섯",
        "양송이버섯": "양송이\n버섯",
        "오이맛고추": "오이맛\n고추",
    ]
}
