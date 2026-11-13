//
//  Untitled.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//
 
import SwiftUI
import UIKit

enum AppTypography {
    case brandTitle, brandEmphasis, brandSubtitle
    case heading, body, subbody, caption

    var uiFont: UIFont {
        switch self {
        case .brandTitle:    return brand(34)
        case .brandEmphasis: return brand(28)
        case .brandSubtitle: return brand(22)
        case .heading: return .systemFont(ofSize: 17, weight: .semibold)
        case .body:    return .systemFont(ofSize: 16, weight: .regular)
        case .subbody: return .systemFont(ofSize: 14, weight: .regular)
        case .caption: return .systemFont(ofSize: 12, weight: .medium)
        }
    }

    var lineHeight: CGFloat {
        switch self {
        case .brandTitle: 42
        case .brandEmphasis: 36
        case .brandSubtitle: 28
        case .heading, .body: 24
        case .subbody: 20
        case .caption: 16
        }
    }

    private func brand(_ size: CGFloat) -> UIFont {
        // ⚠️ 폰트 파일의 PostScript 이름과 정확히 같아야 함
        UIFont(name: "GriunYaongEommaFont-Regular", size: size) ?? .systemFont(ofSize: size)
    }
}

extension View {
    // 사용: Text("이번 주").appFont(.brandTitle)
    func appFont(_ style: AppTypography) -> some View {
        let font = style.uiFont
        let extra = max(0, style.lineHeight - font.lineHeight)
        return self
            .font(Font(font))
            .lineSpacing(extra)               // 여러 줄일 때 줄 간격
            .padding(.vertical, extra / 2)    // 한 줄일 때도 줄 높이 맞춤
    }
}
