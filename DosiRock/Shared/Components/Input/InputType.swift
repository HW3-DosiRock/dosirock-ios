//
//  InputType.swift
//  DosiRock
//
//  Created by Admin on 11/3/26.
//
import SwiftUI

enum InputType {
    case text       // 일반 글자
    case email      // 이메일
    case password   // 비밀번호 (●●● 가림)
    case number     // 숫자만

    var keyboardType: UIKeyboardType {
        switch self {
        case .text, .password: .default
        case .email:           .emailAddress    // @ 있는 키보드
        case .number:          .numberPad       // 숫자 키패드
        }
    }

    var isSecure: Bool {
        self == .password
    }
}
