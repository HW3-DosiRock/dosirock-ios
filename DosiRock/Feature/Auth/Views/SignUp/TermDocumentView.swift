//
//  TermDocumentView.swift
//  DosiRock
//
//  Created by Admin on 11/11/26.
//

import SwiftUI

struct TermDocumentView: View {
    let document: TermDocument

    var body: some View {

        ScrollView {
            VStack(
                alignment: .leading,
                spacing: Spacing.l
            ) {
                ForEach(document.sections, id: \.heading) { section in
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text(section.heading)
                            .appFont(.heading)
                            .foregroundStyle(Color.appTextPrimary)
                        ForEach(section.body ?? [], id: \.self) { text in
                            Text(text).appFont(.body).foregroundStyle(
                                Color.appTextSecondary
                            )
                        }
                        ForEach(section.items ?? [], id: \.label) { item in
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text(item.label).appFont(.subbody)
                                    .foregroundStyle(Color.appTextPrimary)
                                Text(item.text).appFont(.body).foregroundStyle(
                                    Color.appTextSecondary
                                )
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.l)
        }
        .background(Color.appBackground)
    }
}
