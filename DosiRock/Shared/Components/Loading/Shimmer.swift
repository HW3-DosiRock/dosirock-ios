//
//  Shimmer.swift
//  DosiRock
//
//  Created by Admin on 11/18/26.
//

import SwiftUI

struct Shimmer: ViewModifier {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion  // 동작 줄이기
    @State private var phase: CGFloat = 0  // 0: 왼쪽 끝 , 1: 오른쪽 끝

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion {  //"동작 줄이기"가 켜져 있으면 띠를 아예 안 그리고 블록만 남음
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [
                                .clear, Color.appSurface.opacity(0.4),.clear
                            ],  // 가운데 색상있고 양 끝 투명
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.4)
                        // 띠 폭(0.4)만큼 왼쪽 밖에서 출발 → 블록 너비 + 띠 폭(1.4)만큼 이동해서 오른쪽으로 빠져나감
                        .offset(x: -geo.size.width * 0.4 + phase * geo.size.width * 1.4)
                    }
                    .mask(content)  //원래 내용 모양 만큼만 자르기
                    .onAppear {
                        withAnimation(
                            .linear(duration: 1.3).repeatForever(
                                autoreverses: false // 왔다갔다 false
                            )
                        ) {
                            phase = 1
                        }
                    }
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(Shimmer()) //.shimmer()로 사용 가능하게 해줌
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.m) {
        SkeletonBlock(width: 140, height: 20)
        SkeletonBlock(height: 16)
        SkeletonBlock(height: 120, cornerRadius: Radius.large)
    }
    .shimmer()   // 묶음 전체에 한 번
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
    .shimmer()
}
