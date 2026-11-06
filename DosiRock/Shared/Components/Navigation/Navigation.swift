//
//  Navigation.swift
//  DosiRock
//
//  Created by Admin on 11/6/26.
//

import SwiftUI

enum Navigation : CaseIterable, Hashable {
    case thisweek
    case fridge
    case mypage

    var label: String {
        switch self {
        case .thisweek:
            "이번주"
        case .fridge:
            "냉장고"
        case .mypage:
            "마이페이지"
        }
    }
    
    var icDef: String {
        switch self {
        case .thisweek:
            "tab-week"
        case .fridge:
            "fridge"
        case .mypage:
            "tab-my"
        }
    }
    
    var icActive: String {
        switch self {
        case .thisweek:
            "tab-week-active"
        case .fridge:
            "tab-fridge-active"
        case .mypage:
            "tab-my-active"
        }
    }

}
