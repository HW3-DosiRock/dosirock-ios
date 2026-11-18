//
//  ThisWeekMakingRecipe.swift
//  DosiRock
//
//  Created by Admin on 11/12/26.
//

import SwiftUI

// 상태 3 . AI가 재료 만드는 중일떄
// 돌멩이가 통통 튀고, 아래 문구가 몇 초마다 바뀐다
struct ThisWeekMakingRecipe: View {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var phraseIndex = 0
    @State private var isSlow = false  // 오래 걸릴 때 안내 문구로 바꿈

    // 실제 서버 진행률과는 무관한 연출 문구
    private let phrases: [LocalizedStringResource] = [
        .thisweekMakingStepFridge,
        .thisweekMakingStepPriority,
        .thisweekMakingStepMenu,
    ]

    var body: some View {
        VStack(spacing: Spacing.l) {

            Spacer()

            stone
                .accessibilityHidden(true)

            Text(.thisweekMakingRecipeDesc)
                .appFont(.brandSubtitle)
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)  // 여러 줄일 때 가운데 정렬

            // 바뀌는 문구 한 줄 (바뀔 때 살짝 올라오며 교체)
            Text(isSlow ? .thisweekMakingSlow : phrases[phraseIndex])
                .appFont(.body)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
                .id(isSlow ? -1 : phraseIndex)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 6)),
                        removal: .opacity
                    )
                )

            Spacer()
            Spacer()  // 내용이 화면 가운데보다 살짝 위에 오게
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task { await rotatePhrases() }
    }

    // MARK: 돌멩이

    @ViewBuilder
    private var stone: some View {
        let image = Image("logo-stone")
            .resizable()
            .scaledToFit()
            .frame(width: 104)

        if reduceMotion {
            image
        } else {
            // 눌렸다(찌그러짐) → 뛰어오름 → 착지를 계속 반복
            image.phaseAnimator(Bounce.allCases) { view, phase in
                view
                    .scaleEffect(x: phase.scaleX, y: phase.scaleY, anchor: .bottom)
                    .offset(y: phase.offsetY)
            } animation: { phase in
                phase.animation
            }
        }
    }

    private enum Bounce: CaseIterable {
        case squash, jump, land

        var offsetY: CGFloat { self == .jump ? -12 : 0 }
        var scaleX: CGFloat { self == .squash ? 1.06 : self == .jump ? 0.97 : 1 }
        var scaleY: CGFloat { self == .squash ? 0.94 : self == .jump ? 1.03 : 1 }

        var animation: Animation {
            switch self {
            case .squash: .easeIn(duration: 0.18)
            case .jump: .easeOut(duration: 0.28)
            case .land: .easeIn(duration: 0.22)
            }
        }
    }

    // MARK: 문구

    private func rotatePhrases() async {
        var elapsed: Double = 0
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            elapsed += 2.5
            withAnimation(.easeOut(duration: 0.3)) {
                if elapsed >= 15 {
                    isSlow = true  // 한참 걸리면 안내 문구로 고정
                } else {
                    phraseIndex = (phraseIndex + 1) % phrases.count
                }
            }
            if isSlow { return }
        }
    }
}

#Preview {
    ThisWeekMakingRecipe()
        .padding(Spacing.screenHorizontal)
        .background(Color.appBackground)
}
