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
}

// 포장 소비기한 달력 시트 (F-06)
struct ExpiryDatePickerSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var draft: Date  // "선택"을 눌러야 바깥에 반영됨
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

            Spacer(minLength: 0)

            PrimaryButton(
                title: LocalizedStringKey(
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
        .background(Color.appBackground)
        .presentationDetents([.height(580)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xLarge)
        .modifier(PageSheetSizing())
    }
}

#if DEBUG
    #Preview { ExpiryDatePickerSheet(initial: Date()) { _ in } }
#endif
