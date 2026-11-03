//
//  LoadingView.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import SwiftUI

struct LoadingView: View {
    var message: String? = nil

    var body: some View {
        VStack(spacing: Spacing.m) {
            LoadingSpinner(size: Size.Spinner.large, lineWidth: Size.Spinner.largeLineWidth)
            if let message {
                Text(message)
                    .appFont(.subbody)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)   // 화면 가운데
        .background(Color.appBackground)
    }
}

#Preview {
    LoadingView(message: "로딩 중..")
}
