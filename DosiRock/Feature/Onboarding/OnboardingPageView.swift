//
//  OnboardingView.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

struct OnboardingPageView: View {

    let page: OnboardingPage

    var body: some View {

        VStack(spacing: Spacing.xl) {
            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 280)

            VStack(spacing: Spacing.s) {
                Text(page.title)
                    .appFont(.brandSubtitle)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .appFont(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
    }
}

#Preview {
    OnboardingPageView(
        page: OnboardingPage(image: "desc_1", title: "냉장고 재료 등록", description: "있는 재료의 양을 기록해요.")
    )
}
