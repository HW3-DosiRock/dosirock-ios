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
        OnboardingPage(image: "desc_1", title: "첫 번째 안내", description: "설명 문구"),
        OnboardingPage(image: "desc_2", title: "두 번째 안내", description: "설명 문구"),
        OnboardingPage(image: "desc_3", title: "세 번째 안내", description: "설명 문구"),
    ]
}
