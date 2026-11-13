//
//  pageIndicator.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

struct PageIndicator: View {

    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: Spacing.s) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == current ? Color.appPrimary : Color.appBorder)
                    .frame(width: index == current ? 20 : 8, height: 8)  // 현재 페이지는 길게
            }
        }
        .animation(.easeOut(duration: 0.2), value: current)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(count)페이지 중 \(current + 1)페이지")
    }
}

#Preview {
    PageIndicator(count: 3, current: 1)
}
