//
//  OnboardingView.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//
import SwiftUI

struct OnboardingView: View {

    let pages: [OnboardingPage]
    var onFinish: () -> Void

    @State private var current = 0

    private var isLast: Bool { current == pages.count - 1 }

    var body: some View {
        VStack(spacing: Spacing.l) {

            // 건너뛰기 (오른쪽 위)
            HStack {
                Spacer()
                TextLinkButton(
                    title: "건너뛰기",
                    textColor: .appTextSecondary,
                    action: onFinish
                )
                .opacity(isLast ? 0 : 1)  // 지우지 않고 투명하게 (자리 유지)
                .disabled(isLast)  // 투명해도 눌리지 않게
                .accessibilityHidden(isLast)  // VoiceOver가 읽지 않게
            }
            .frame(height: Size.minTouch)  // 줄 높이 고정 → 화면이 안 움직임
            .padding(.horizontal, Spacing.screenHorizontal)
            .animation(.easeOut(duration: 0.2), value: isLast)  // 스와이프/버튼 모두 같은 페이드

            // 페이지 (스와이프)
            TabView(selection: $current) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)  // selection과 연결되는 값
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))  // 기본 점은 숨김

            PageIndicator(count: pages.count, current: current)

            // 다음 / 시작하기
            PrimaryButton(title: isLast ? "시작하기" : "다음") {
                if isLast {
                    onFinish()
                } else {
                    withAnimation { current += 1 }
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
        }
        .padding(.bottom, Spacing.l)
        .background(Color.appBackground)
    }
}

#Preview {
    OnboardingView(
        pages: [
            OnboardingPage(
                image: "desc_1",
                title: "첫 번째 안내",
                description: "설명 문구"
            ),
            OnboardingPage(
                image: "desc_2",
                title: "두 번째 안내",
                description: "설명 문구"
            ),
            OnboardingPage(
                image: "desc_3",
                title: "세 번째 안내",
                description: "설명 문구"
            ),
        ],
        onFinish: {}
    )
}
