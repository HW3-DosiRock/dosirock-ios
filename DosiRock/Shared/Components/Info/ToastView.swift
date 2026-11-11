//
//  ToastView.swift
//  DosiRock
//
//  Created by Admin on 11/11/26.
//

import SwiftUI

struct ToastView: View {

    let message: LocalizedStringKey

    var body: some View {

        HStack {

            Image("logo-stone")
                .resizable()
                .scaledToFit()                 // 비율 유지
                .frame(width: Size.minTouch, height: Size.minTouch)  // 원하는 크기

            Text(message)
                .appFont(.subbody)
                .foregroundStyle(Color.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)  // 좌우로 꽉 채움
        .padding(.horizontal, Spacing.l).padding(.vertical, Spacing.m)
        .background(Color.appTextPrimary, in: Capsule())
        .padding(.horizontal, Spacing.screenHorizontal)  // 화면 가장자리 여백
    }
}

extension View {
    func toast(_ message: Binding<LocalizedStringKey?>) -> some View {
            overlay(alignment: .bottom) {
                if let text = message.wrappedValue {
                    ToastView(message: text)
                        .padding(.bottom, Spacing.xl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .task {                       // 2초 뒤 자동으로 사라짐
                            try? await Task.sleep(for: .seconds(2))
                            message.wrappedValue = nil
                        }
                }
            }
            .animation(.easeOut(duration: 0.25), value: message.wrappedValue != nil)
        }
}

#Preview {
    ToastView(message: "테스트 토스트 프리뷰")
}
