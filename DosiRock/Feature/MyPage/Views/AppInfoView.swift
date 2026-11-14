//
//  AppInfoView.swift
//  DosiRock
//

import SwiftUI

// 앱 안내
struct AppInfoView: View {

    @Environment(Router<MyPageRoute>.self) private var router

    private let steps: [LocalizedStringKey] = [
        "my_app_info_step1", "my_app_info_step2",
        "my_app_info_step3", "my_app_info_step4",
    ]

    private struct Row: Identifiable {
        let label: LocalizedStringKey
        let value: LocalizedStringKey
        var id: String { "\(label)" }
    }

    private let rows = [
        Row(label: "my_app_info_version", value: LocalizedStringKey(AppEnvironment.appVersion)),
        Row(label: "my_app_info_ai", value: "OpenAI"),
    ]

    var body: some View {
        VStack(spacing: Spacing.l) {
            NavigationHeader(
                title: "my_app_info_title",
                leadingTitle: "tab_my_page",
                onLeadingTap: { router.pop() }
            )

            ScrollView {
                VStack(spacing: Spacing.m) {
                    intro
                    howTo
                    GroupedListCard(items: rows) { row in
                        HStack {
                            Text(row.label)
                                .appFont(.body)
                                .foregroundStyle(Color.appTextSecondary)
                            Spacer()
                            Text(row.value)
                                .appFont(.body)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }
            }
        }
        .padding(Spacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private var intro: some View {
        VStack(spacing: Spacing.s) {
            Image("logo-stone")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .accessibilityHidden(true)
            Text("my_app_info_name")
                .appFont(.brandSubtitle)
                .foregroundStyle(Color.appTextPrimary)
            Text("my_app_info_tagline")
                .appFont(.body)
                .foregroundStyle(Color.appTextPrimary)
            Text("my_app_info_subtitle")
                .appFont(.subbody)
                .foregroundStyle(Color.appTextSecondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private var howTo: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            SectionHeader(title: "my_app_info_howto")
            VStack(alignment: .leading, spacing: Spacing.m) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: Spacing.m) {
                        Text("\(index + 1)")
                            .appFont(.caption)
                            .foregroundStyle(Color.appSurface)
                            .frame(width: 22, height: 22)
                            .background(Color.appTextPrimary, in: Circle())
                        Text(step)
                            .appFont(.body)
                            .foregroundStyle(Color.appTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
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

#Preview {
    AppInfoView().environment(Router<MyPageRoute>())
}
