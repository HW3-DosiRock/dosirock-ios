//
//  OnboardingPage.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import Foundation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String        // 에셋 이름
    let title: String
    let description: String
}

extension OnboardingPage {
    static let samples: [OnboardingPage] = [
        OnboardingPage(image: "desc_1", title: "냉장고 재료 등록", description: "냉장고에 있는 재료와 양을 기록해요"),
        OnboardingPage(image: "desc_2", title: "이번 주 메뉴 제안", description: "냉장고 재료로 월~금 도시락 구성을 짜 줘요"),
        OnboardingPage(image: "desc_3", title: "조리 완료로 기록", description: "사용한 재료는 냉장고에서 빠지고, 절약액이 쌓여요"),
    ]
}
