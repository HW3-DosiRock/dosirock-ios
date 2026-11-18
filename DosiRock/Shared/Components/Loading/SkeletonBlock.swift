//
//  SkeletonBlock.swift
//  DosiRock
//
//  Created by Admin on 11/18/26.
//

import SwiftUI

struct SkeletonBlock: View {

    var width: CGFloat? = nil  // nil이면 가로를 꽉 채움
    let height: CGFloat
    var cornerRadius: CGFloat = Radius.small

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.appSurfaceSubtle)
            .frame(width: width, height: height)
            .frame(
                maxWidth: width == nil ? .infinity : nil,
                alignment: .leading
            )
            .accessibilityHidden(true)  // 읽어줄 내용이 없는 장식
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.m) {
        SkeletonBlock(width: 140, height: 20)  // 짧은 줄 (소제목)
        SkeletonBlock(height: 16)  // 긴 줄 (본문)
        SkeletonBlock(height: 120, cornerRadius: Radius.large)  // 카드
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)

}
