//
//  Color+App.swift
//  cityStone
//
//  Created by Seungyeon Jeon on 11/2/26.
//
import SwiftUI

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    // 배경 · 면 · 테두리
    static let appBackground     = Color(hex: 0xF6EFE4)
    static let appSurface        = Color(hex: 0xFFFCF7)
    static let appSurfaceSubtle  = Color(hex: 0xEFE5D6)
    static let appBorder         = Color(hex: 0xE6D9C7)
    // 글자
    static let appTextPrimary    = Color(hex: 0x3A2314)
    static let appTextSecondary  = Color(hex: 0x7D6250)
    // 주요 강조
    static let appPrimary        = Color(hex: 0x7A4423)
    static let appPrimaryPressed = Color(hex: 0x5E3219)
    static let appDisabled       = Color(hex: 0xB59A82)
    static let appScrollbar      = Color(hex: 0xCDBBA5)
    // 성공
    static let appSuccess           = Color(hex: 0x2C5525)
    static let appSuccessBackground = Color(hex: 0xE1EDDA)
    // 주의 · 오류
    static let appAttention           = Color(hex: 0xA93A23)
    static let appAttentionBorder     = Color(hex: 0xF9B49B)
    static let appAttentionBackground = Color(hex: 0xFBE1D3)
    // 정보
    static let appInfo           = Color(hex: 0x21497F)
    static let appInfoBackground = Color(hex: 0xE0E8F5)
    // 딤 (모달 뒤 배경)
    static let appDim = Color(red: 43/255, green: 26/255, blue: 16/255, opacity: 0.4)
}
