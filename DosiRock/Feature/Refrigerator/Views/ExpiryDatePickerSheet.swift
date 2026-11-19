//
//  ExpiryDatePickerSheet.swift
//  DosiRock
//
//  Created by Admin on 11/16/26.
//

import SwiftUI

extension Date {
    // "11/14(토)"
    var shortKorean: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M/d(E)"
        return f.string(from: self)
    }

    // "2026년 11월 14일 (토)"
    var longKorean: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일 (E)"
        return f.string(from: self)
    }
}

// 포장 소비기한 달력 시트 (F-06)
struct ExpiryDatePickerSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var draft: Date  // "선택"을 눌러야 바깥에 반영됨
    @State private var sheetHeight: CGFloat = 560  // 시트 높이 (내용 높이를 재서 갱신)
    let onSelect: (Date) -> Void

    init(initial: Date, onSelect: @escaping (Date) -> Void) {
        _draft = State(initialValue: initial)
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: Spacing.l) {
            NavigationHeader(
                title: "fridge_register_expiry_title",
                leadingTitle: "common_cancel",
                showsBackIcon: false,
                titleStyle: .heading,
                onLeadingTap: { dismiss() }
            )

            DatePicker("", selection: $draft, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(Color.appPrimary)
                .padding(Spacing.s)
                .background(Color.appSurface)
                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                .padding(.horizontal, Spacing.screenHorizontal)

            PrimaryButton(
                title: LocalizedStringResource(stringLiteral: 
                    String(
                        format: String(localized: "fridge_register_expiry_select"),
                        draft.shortKorean
                    )
                )
            ) {
                onSelect(draft)
                dismiss()
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.bottom, Spacing.l)
        }
        // 1) 내용 자체의 높이를 잼 (하단 안전 영역 포함). 아래 frame보다 먼저 와야 내용 높이가 나옴
        .onGeometryChange(for: CGFloat.self) {
            $0.size.height + $0.safeAreaInsets.bottom
        } action: {
            sheetHeight = $0
        }
        // 2) iPad처럼 시트가 크게 뜨면 내용은 위쪽에 붙이고, 배경색은 시트 전체에 칠함
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xLarge)
        .modifier(PageSheetSizing())
        .presentationDetents([.height(sheetHeight)])
    }
}

#if DEBUG
    #Preview { ExpiryDatePickerSheet(initial: Date()) { _ in } }
#endif
