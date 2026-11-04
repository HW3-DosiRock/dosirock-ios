//
//  SegmentContol.swift
//  DosiRock
//
//  Created by Admin on 11/4/26.
//

import SwiftUI

struct SegmentControl<Item: Hashable>: View {

    let items: [Item]
    @Binding var selected: Item
    let title: (Item) -> String

    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                segment(for: item)
            }
        }
        .padding(Spacing.xs)
        .background(Color.appSurfaceSubtle)
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
    }

    // 칸 하나
    private func segment(for item: Item) -> some View {
        let isSelected = (item == selected)      // ← 미리 계산

        return Button {
            withAnimation(.spring(duration: 0.25)) {
                selected = item
            }
        } label: {
            Text(title(item))
                .appFont(.subbody)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Color.appTextPrimary : Color.appTextSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .frame(height: Size.minTouch - Spacing.xs * 2)
                .background { selectionBackground(isSelected) }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // 선택 배경
    @ViewBuilder
    private func selectionBackground(_ isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: Radius.small - Spacing.xs)
                .fill(Color.appSurface)
                .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
                .matchedGeometryEffect(id: "segment", in: namespace)
        }
    }
}

// MARK: - Preview

private enum WeekTab: String, CaseIterable {
    case thisWeek = "이번 주"
    case nextWeek = "다음 주"
}

#Preview {
    @Previewable @State var tab: WeekTab = .thisWeek
    @Previewable @State var storage = "전체"

    VStack(spacing: Spacing.l) {
        SegmentControl(items: WeekTab.allCases, selected: $tab) { $0.rawValue }
        SegmentControl(items: ["전체", "냉장", "냉동", "실온"], selected: $storage) { $0 }
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}
