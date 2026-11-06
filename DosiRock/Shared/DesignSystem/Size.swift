//
//  Size.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//

import CoreGraphics

enum Size {
    // 터치 영역
    static let minTouch: CGFloat = 44        // 디자인 시스템: 최소 44×44

    // 버튼
    static let buttonHeight: CGFloat = 52

    // 아이콘
    enum Icon {
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 48
    }

    // 로딩 스피너
    enum Spinner {
        static let small: CGFloat = 15        // 버튼 안
        static let large: CGFloat = 30        // 화면 로딩
        static let smallLineWidth: CGFloat = 2
        static let largeLineWidth: CGFloat = 4
    }
}
