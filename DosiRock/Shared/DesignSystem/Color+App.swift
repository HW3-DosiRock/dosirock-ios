//
//  Color+App.swift
//  cityStone
//
//  Created by Seungyeon Jeon on 11/2/26.
//

import SwiftUI

extension Color {
    
    // hex 코드로 색 만들기 (예: Color(hex: 0x7A4423))
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    // 앱 색상
    static let appPrimary = Color(hex: 0x7A4423)
    static let appOnPrimary = Color(hex: 0xFFFFFF)
}
