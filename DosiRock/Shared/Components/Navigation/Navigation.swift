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

    var label: LocalizedStringKey {
        switch self {
        case .thisweek:
            "tab_this_week"
        case .fridge:
            "tab_fridge"
        case .mypage:
            "tab_my_page"
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
