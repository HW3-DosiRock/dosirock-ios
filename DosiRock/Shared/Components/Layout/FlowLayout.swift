//
//  FlowLayout.swift
//  DosiRock
//
//  Created by Seungyeon Jeon on 11/18/26.
//

import SwiftUI

/// 왼쪽부터 가로로 채우다가 폭이 모자라면 다음 줄로 넘기는 배치 (칩 목록용).
struct FlowLayout: Layout {

    var spacing: CGFloat = Spacing.s  // 가로·세로 간격

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let width = rows.map(\.width).max() ?? 0
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                // 한 줄 안에서는 세로 가운데 맞춤
                subviews[index].place(
                    at: CGPoint(x: x, y: y + (row.height - size.height) / 2),
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    // 줄 나누기: 다음 칸이 폭을 넘으면 새 줄
    private func arrange(width maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let needed = current.indices.isEmpty ? size.width : current.width + spacing + size.width
            if needed > maxWidth, !current.indices.isEmpty {
                rows.append(current)
                current = Row()
            }
            current.width = current.indices.isEmpty ? size.width : current.width + spacing + size.width
            current.height = max(current.height, size.height)
            current.indices.append(index)
        }
        if !current.indices.isEmpty { rows.append(current) }
        return rows
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }
}

#Preview {
    FlowLayout {
        ForEach(["시금치", "오이", "오이맛고추", "가지", "상추", "감자", "애호박"], id: \.self) {
            Text($0)
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.s)
                .background(Capsule().fill(Color.appSurfaceSubtle))
        }
    }
    .padding(Spacing.screenHorizontal)
    .frame(width: 300)
}
