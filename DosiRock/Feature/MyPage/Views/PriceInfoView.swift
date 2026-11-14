//
//  PriceInfoView.swift
//  DosiRock
//

import SwiftUI

// 가격 데이터 안내
struct PriceInfoView: View {

    @Environment(Router<MyPageRoute>.self) private var router

    private struct Source: Identifiable {
        let label: LocalizedStringKey
        let value: LocalizedStringKey
        var id: String { "\(label)" }
    }

    private let sources = [
        Source(label: "my_price_info_produce", value: "my_price_info_produce_source"),
        Source(label: "my_price_info_livestock", value: "my_price_info_livestock_source"),
        Source(label: "my_price_info_etc", value: "my_price_info_etc_source"),
        Source(label: "my_price_info_update", value: "my_price_info_update_value"),
    ]

    private let notes: [LocalizedStringKey] = [
        "my_price_info_cost_desc",
        "my_price_info_saving_desc",
        "my_price_info_price_desc",
        "my_price_info_missing_desc",
        "my_price_info_coupang_desc",
    ]

    var body: some View {
        VStack(spacing: Spacing.l) {
            NavigationHeader(
                title: "my_price_info_title",
                leadingTitle: "tab_my_page",
                onLeadingTap: { router.pop() }
            )

            ScrollView {
                VStack(spacing: Spacing.m) {
                    GroupedListCard(items: sources) { source in
                        HStack(alignment: .top, spacing: Spacing.l) {
                            Text(source.label)
                                .appFont(.body)
                                .foregroundStyle(Color.appTextPrimary)
                                .frame(width: 96, alignment: .leading)
                            Text(source.value)
                                .appFont(.subbody)
                                .foregroundStyle(Color.appTextSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    VStack(alignment: .leading, spacing: Spacing.m) {
                        ForEach(Array(notes.enumerated()), id: \.offset) { _, note in
                            Text(note)
                                .appFont(.subbody)
                                .foregroundStyle(Color.appTextPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.l)
                    .background(
                        Color.appSurface,
                        in: RoundedRectangle(cornerRadius: Radius.medium)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.medium)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                }
            }
        }
        .padding(Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    PriceInfoView().environment(Router<MyPageRoute>())
}
