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
