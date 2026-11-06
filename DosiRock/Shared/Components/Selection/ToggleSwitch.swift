//
//  Switch.swift
//  DosiRock
//
//  Created by Admin on 11/4/26.
//

import SwiftUI

struct ToggleSwitch: View {

    @Binding var isOn : Bool
    var isEnable: Bool = true

    //size
    private let width: CGFloat = 51
    private let height: CGFloat = 31
    private let knobPadding: CGFloat = 2

    var body: some View {

        ZStack(alignment: isOn ? .trailing : .leading) {

            //back
            Capsule()
                .fill(isOn ? Color.appSuccess : Color.appDisabled)
            //thumb
            Circle()
                .fill(Color.appSurface)
                .padding(knobPadding)
                .shadow(color: .black.opacity(0.15), radius: 2, y: 1)

        }
        .frame(width: width, height: height)
        .opacity(isEnable ? 1 : 0.5)
        .frame(minWidth: Size.minTouch, minHeight: Size.minTouch)
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEnable else { return }
            withAnimation(.spring(duration: 0.25)){
                isOn.toggle()
            }
        }
        .sensoryFeedback(.selection, trigger: isOn)
        .accessibilityElement()
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isOn ? "켜짐" : "꺼짐")
    }
}

#Preview {
    @Previewable @State var a = true
    @Previewable @State var b = false

    VStack(spacing: Spacing.l) {
        HStack {
            Text("알림 받기").appFont(.body)
            Spacer()
            ToggleSwitch(isOn: $a)
        }
        HStack {
            Text("비활성").appFont(.body)
            Spacer()
            ToggleSwitch(isOn: $b, isEnable: false)
        }
    }
    .padding(Spacing.screenHorizontal)
    .background(Color.appBackground)
}

