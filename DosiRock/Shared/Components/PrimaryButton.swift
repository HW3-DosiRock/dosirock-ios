//
//  PrimaryButton.swift
//  cityStone
//
//  Created by Seungyeon Jeon on 11/2/26.
//

import SwiftUI

struct PrimaryButton: View {
    
    let title: String
    var icon: String? = nil
    var isEnable: Bool = true
    var isLoading: Bool = false
    let action: () -> Void
    
    private var isDisabled: Bool {
        !isEnable || isLoading
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    LoadingSpinner(color: .appOnPrimary, size: 15, lineWidth: 2)
                } else if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.headline)
            .foregroundStyle(Color.appOnPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isDisabled ? Color.appPrimary.opacity(0.4) : Color.appPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack {
        PrimaryButton(title: "시작하기") { }
        PrimaryButton(title: "좋아요", icon: "heart.fill") { }
        PrimaryButton(title: "저장 중...", isLoading: true) { }
        PrimaryButton(title: "다음", isEnable: false,isLoading: false ) { }
    }
    .padding()
}
