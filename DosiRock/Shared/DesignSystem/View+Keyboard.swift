//
//  View+Keyboard.swift
//  DosiRock
//

import SwiftUI

extension View {
    /// 입력창 바깥을 탭하면 키보드를 내림. 버튼 탭은 가로채지 않음.
    func dismissKeyboardOnTap() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}
