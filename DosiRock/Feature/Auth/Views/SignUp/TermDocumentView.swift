//
//  TermDocumentView.swift
//  DosiRock
//
//  Created by Admin on 11/11/26.
//

import SwiftUI

struct TermDocumentView: View {

    let document: TermDocument
    var backTitle: LocalizedStringKey? = nil  // 지정하면 시트가 아닌 별도 화면 모양(‹ 뒤로)
    @Environment(\.dismiss) private var dismiss

    var body: some View {

        VStack {
            NavigationHeader(
                title: LocalizedStringKey(document.title),
                leadingTitle: backTitle ?? "common_close",
                showsBackIcon: backTitle != nil,
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
            .tint(Color.appPrimary)  // 링크 색

        }
        .padding(.top, backTitle == nil ? Spacing.xl : 0)
        .background {
            if backTitle != nil { Color.appBackground.ignoresSafeArea() }
        }
        .navigationBarBackButtonHidden(true)
    }

    // [이름](주소) 형태의 마크다운 링크를 눌러서 열 수 있게 변환 (링크가 없는 문서는 그대로 글자)
    private func linked(_ text: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        guard var result = try? AttributedString(markdown: text, options: options)
        else { return AttributedString(text) }
        // 링크는 밑줄을 그어서 일반 글자와 구분
        for run in result.runs where run.link != nil {
            result[run.range].underlineStyle = .single
        }
        return result
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(document.title)
                .appFont(.brandSubtitle)
                .foregroundStyle(Color.appTextPrimary)
            Text(String(format: String(localized: "term_document_version"), document.version))
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
                Text(linked(text))
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
                    // 첫 줄은 본문(예: 보관 기준), 둘째 줄부터는 작고 흐리게(예: 참고 자료)
                    let lines = item.text.components(separatedBy: "\n")
                    Text(linked(lines[0]))
                        .appFont(.body)
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(Array(lines.dropFirst().enumerated()), id: \.offset) { _, line in
                        Text(linked(line))
                            .appFont(.subbody)
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
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
