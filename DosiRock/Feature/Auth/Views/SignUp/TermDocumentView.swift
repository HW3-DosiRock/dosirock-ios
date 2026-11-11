//
//  TermDocumentView.swift
//  DosiRock
//
//  Created by Admin on 11/11/26.
//

import SwiftUI

struct TermDocumentView: View {

    let document: TermDocument
    @Environment(\.dismiss) private var dismiss

    var body: some View {

        VStack {
            NavigationHeader(
                title: LocalizedStringKey(document.title),
                leadingTitle: "닫기",
                showsBackIcon: false,
                onLeadingTap: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {

                    header
                    // heading이 겹쳐도 안전하도록 순서(offset)를 id로 사용
                    ForEach(Array(document.sections.enumerated()), id: \.offset)
                    {
                        _,
                        section in
                        sectionView(section)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.l)

        }
        .padding(.top, Spacing.xl)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(document.title)
                .appFont(.brandSubtitle)
                .foregroundStyle(Color.appTextPrimary)
            Text("버전 \(document.version)")
                .appFont(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    // MARK: - Section

    private func sectionView(_ section: TermDocument.Section) -> some View {

        VStack(alignment: .leading, spacing: Spacing.m) {

            HStack(spacing: Spacing.s) {
                Capsule()
                    .fill(Color.appPrimary)
                    .frame(width: 3, height: 16)
                Text(section.heading)
                    .appFont(.heading)
                    .foregroundStyle(Color.appTextPrimary)
            }

            ForEach(section.body ?? [], id: \.self) { text in
                Text(text)
                    .appFont(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let items = section.items, !items.isEmpty {
                itemsCard(items)
            }
        }
    }

    // 항목(label/text)은 한 장의 카드 안에 구분선으로 나열
    private func itemsCard(_ items: [TermDocument.Item]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if index > 0 { Divider().overlay(Color.appBorder) }
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(item.label)
                        .appFont(.caption)
                        .foregroundStyle(Color.appPrimary)
                    Text(item.text)
                        .appFont(.body)
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.l)
            }
        }
        .background(
            Color.appSurface,
            in: RoundedRectangle(cornerRadius: Radius.large)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.large)
                .stroke(Color.appBorder, lineWidth: 1)
        )
    }
}

#Preview {
    if let doc = Term.privacy.document {
        TermDocumentView(document: doc)
    }
}
