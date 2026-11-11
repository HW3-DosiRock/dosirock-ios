//
//  TermsSection.swift
//  DosiRock
//
//  Created by Admin on 11/9/26.
//

import SwiftUI

struct SignUpTermsSection: View {

    @Bindable var vm: SignUpViewModel
    @State private var viewing: Term?

    var body: some View {

        VStack(alignment: .leading) {

            SectionHeader(
                title: "sign_up_terms_section_title",
                titleStyle: .brandEmphasis
            )
            .frame(maxWidth: .infinity)

            //전체 동의
            HStack {
                CheckBox(
                    isChecked: $vm.agreedAll,
                    message: "signup_total_agree",
                    appFontStyle: .heading
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.l)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
            .background(
                Color.appSurface,
                in: RoundedRectangle(cornerRadius: Radius.large)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.xLarge)
                    .stroke(Color.appBorder)
            )
            .contentShape(Rectangle())

            //약관 목록
            termsList
                .padding(.top, Spacing.l)
        }
    }

    var termsList: some View {
        VStack(spacing: 0) {
            ForEach(Term.allCases) { term in
                HStack {
                    CheckBox(
                        isChecked: vm.binding(for: term),
                        message: LocalizedStringKey(term.title)
                    )
                    Spacer()
                    if term.hasDocument {
                        Button {
                            viewing = term
                        } label: {
                            Text("보기")
                                .appFont(.subbody)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }
                .padding(.horizontal, Spacing.l)
                .padding(.vertical, Spacing.m)

                if term != Term.allCases.last {
                    Divider().padding(.horizontal, Spacing.l)
                }
            }
        }
        .background(
            Color.appSurface,
            in: RoundedRectangle(cornerRadius: Radius.large)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.large)
                .stroke(Color.appBorder)
        )
        .sheet(item: $viewing) { term in
            if let doc = term.document {
                TermDocumentView(document: doc)
                    .presentationDetents([.large])  // 높이: .medium, .large, .fraction(0.9)
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(Radius.xLarge)  // 위쪽 모서리
                    .presentationBackground(Color.appBackground)
            }

        }
    }
}

#Preview {
    SignUpTermsSection(vm: .init(service: MockAuthService()))
        .background(Color.appBackground)
        .padding()

}
